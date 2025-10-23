data "aws_region" "current" {}

resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  deletion_protection = "ACTIVE"

  password_policy {
    minimum_length                   = var.password_minimum_length
    require_uppercase                = var.password_require_uppercase
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    temporary_password_validity_days = var.password_temporary_validity_days
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  username_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  auto_verified_attributes = var.auto_verified_attributes

  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.account_recovery_mechanisms
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }

  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.enable_software_token_mfa ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "sms_configuration" {
    for_each = var.enable_sms_mfa ? [1] : []
    content {
      external_id    = random_password.sms_external_id[0].result
      sns_caller_arn = aws_iam_role.cognito_sms_role[0].arn
      sns_region     = data.aws_region.current.region
    }
  }

  # TODO: this is only usable if email sending config is not COGNITO_DEFAULT! Once we allow
  # customized emails then we can uncomment this and add a check to make sure the sending
  # account isn't COGNITO_DEFAULT.
  # TF docs say there needs to be at least 2 account recovery mechanisms to use this
  # dynamic "email_mfa_configuration" {
  #   for_each = var.enable_email_mfa && length(var.account_recovery_mechanisms) >= 2 ? [1] : []
  #   content {
  #     message = var.email_mfa_message
  #     subject = var.email_mfa_subject
  #   }
  # }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 5 // _@_._ <- seems like 5 min
      max_length = 256
    }
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }

  dynamic "schema" {
    for_each = var.enable_phone_number_attribute ? [1] : []
    content {
      name                = "phone_number"
      attribute_data_type = "String"
      required            = false
      mutable             = true

      string_attribute_constraints {
        min_length = 7
        max_length = 15
      }
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = var.email_verification_message
    email_subject        = var.email_verification_subject
  }

  device_configuration {
    challenge_required_on_new_device      = var.device_challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_only_remembered_on_user_prompt
  }

  tags = var.tags
}

resource "random_password" "sms_external_id" {
  count   = var.enable_sms_mfa ? 1 : 0
  length  = 16
  special = false
}

# IAM role for SMS MFA (created only if SMS MFA is enabled and no custom role provided)
resource "aws_iam_role" "cognito_sms_role" {
  count = var.enable_sms_mfa ? 1 : 0
  name  = "${var.user_pool_name}-sms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = random_password.sms_external_id[0].result
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cognito_sms_policy" {
  count = var.enable_sms_mfa ? 1 : 0
  name  = "${var.user_pool_name}-sms-policy"
  role  = aws_iam_role.cognito_sms_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cognito_user_pool_client" "clients" {
  for_each = { for client in var.clients : client.name => client }

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = each.value.generate_secret

  access_token_validity  = each.value.access_token_validity_hours
  id_token_validity      = each.value.id_token_validity_hours
  refresh_token_validity = each.value.refresh_token_validity_days
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  explicit_auth_flows = each.value.explicit_auth_flows

  prevent_user_existence_errors = each.value.prevent_user_existence_errors ? "ENABLED" : "LEGACY"

  allowed_oauth_flows_user_pool_client = (
    length(each.value.allowed_oauth_flows) > 0
    || length(each.value.allowed_oauth_scopes) > 0
    || length(each.value.callback_urls) > 0
    || length(each.value.logout_urls) > 0
  )
  allowed_oauth_scopes = each.value.allowed_oauth_scopes
  allowed_oauth_flows  = each.value.allowed_oauth_flows
  callback_urls        = each.value.callback_urls
  logout_urls          = each.value.logout_urls

  enable_propagate_additional_user_context_data = each.value.enable_propagate_additional_user_context_data
  enable_token_revocation                       = each.value.enable_token_revocation

  read_attributes  = each.value.read_attributes
  write_attributes = each.value.write_attributes
}

/* ------- Cognito hosted UI ------- */

resource "aws_cognito_user_pool_domain" "pool_domain" {
  count = var.hosted_ui_config != null ? 1 : 0

  domain          = var.hosted_ui_config.custom_domain
  certificate_arn = var.hosted_ui_config.custom_domain_acm_cert_arn
  user_pool_id    = aws_cognito_user_pool.pool.id
}

resource "aws_route53_record" "cognito_alias" {
  count = var.hosted_ui_config != null ? 1 : 0

  name    = aws_cognito_user_pool_domain.pool_domain[0].domain
  type    = "A"
  zone_id = var.hosted_ui_config.hosted_zone_id

  alias {
    evaluate_target_health = false

    name    = aws_cognito_user_pool_domain.pool_domain[0].cloudfront_distribution
    zone_id = aws_cognito_user_pool_domain.pool_domain[0].cloudfront_distribution_zone_id
  }
}

resource "aws_cognito_user_pool_ui_customization" "cognito_hosted_ui_customization" {
  count = var.hosted_ui_config != null ? 1 : 0

  css          = ".submitButton-customizable {background-color: ${var.hosted_ui_config.hosted_ui_button_color};} .submitButton-customizable:hover {background-color: ${var.hosted_ui_config.hosted_ui_button_hover_color};}"
  image_file   = var.hosted_ui_config.hosted_ui_logo_file_base64
  user_pool_id = aws_cognito_user_pool_domain.pool_domain[0].user_pool_id
}
