resource "aws_cognito_user_pool" "pool" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"
  mfa_configuration        = "ON"
  username_attributes      = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  device_configuration {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = var.verification_email_subject
    email_message        = var.verification_email_body
  }

  software_token_mfa_configuration {
    enabled = true
  }

  username_configuration {
    case_sensitive = false
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
}

/* ------- Cognito hosted UI ------- */

resource "aws_cognito_user_pool_domain" "pool_domain" {
  domain          = var.custom_domain
  certificate_arn = var.custom_domain_acm_cert_arn
  user_pool_id    = aws_cognito_user_pool.pool.id
}

resource "aws_route53_record" "cognito_alias" {
  name    = aws_cognito_user_pool_domain.pool_domain.domain
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    evaluate_target_health = false

    name    = aws_cognito_user_pool_domain.pool_domain.cloudfront_distribution
    zone_id = aws_cognito_user_pool_domain.pool_domain.cloudfront_distribution_zone_id
  }
}

resource "aws_cognito_user_pool_ui_customization" "cognito_hosted_ui_customization" {
  css          = ".submitButton-customizable {background-color: ${var.hosted_ui_button_color};} .submitButton-customizable:hover {background-color: ${var.hosted_ui_button_hover_color};}"
  image_file   = var.hosted_ui_logo_file_base64
  user_pool_id = aws_cognito_user_pool_domain.pool_domain.user_pool_id
}
