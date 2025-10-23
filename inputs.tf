variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

// ------------ Password config ------------

variable "password_minimum_length" {
  description = "Minimum length of the password"
  type        = number
  default     = 8
}

variable "password_require_uppercase" {
  description = "Whether to require uppercase letters in password"
  type        = bool
  default     = true
}

variable "password_require_lowercase" {
  description = "Whether to require lowercase letters in password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether to require numbers in password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether to require symbols in password"
  type        = bool
  default     = true
}

variable "password_temporary_validity_days" {
  description = "Number of days temporary passwords are valid"
  type        = number
  default     = 7
}

// ------------ MFA config ------------

variable "mfa_configuration" {
  description = "MFA configuration for user pool (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"
  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be one of: OFF, ON, OPTIONAL."
  }
}

variable "enable_software_token_mfa" {
  description = "Whether to enable software token (TOTP) MFA"
  type        = bool
  default     = true
}

variable "enable_sms_mfa" {
  description = "Whether to enable SMS MFA"
  type        = bool
  default     = true
}

# variable "enable_email_mfa" {
#   description = "Whether to enable email MFA"
#   type        = bool
#   default     = true
# }

# variable "email_mfa_message" {
#   description = "Message template for email MFA"
#   type        = string
#   default     = "Your authentication code is {####}"
# }

# variable "email_mfa_subject" {
#   description = "Subject for email MFA messages"
#   type        = string
#   default     = "Your authentication code"
# }

// ------------ Account recovery ------------

variable "account_recovery_mechanisms" {
  description = "List of account recovery mechanisms"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]
  validation {
    condition = contains(var.account_recovery_mechanisms, {
      name     = "verified_email"
      priority = 1
    })
    error_message = "Must allow email account recovery at minimum"
  }
}

// ------------ Email verification ------------

variable "auto_verified_attributes" {
  description = "List of attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
  validation {
    condition     = contains(var.auto_verified_attributes, "email")
    error_message = "Must auto verify email at minimum"
  }
}

variable "email_verification_message" {
  description = "Email verification message template"
  type        = string
  default     = "Please verify your email with the following verification code: {####}."
}

variable "email_verification_subject" {
  description = "Email verification subject"
  type        = string
  default     = "Your verification code"
}

variable "enable_phone_number_attribute" {
  description = "Whether to enable phone number as a user attribute"
  type        = bool
  default     = true
}

// ------------ Device challenge config ------------

variable "device_challenge_required_on_new_device" {
  description = "Whether to challenge users on new devices"
  type        = bool
  default     = true
}

variable "device_only_remembered_on_user_prompt" {
  description = "Whether devices are only remembered when user chooses to remember"
  type        = bool
  default     = true
}

// ------------ User pool client configs ------------

variable "clients" {
  description = "List of user pool clients to create"
  type = list(object({
    name                        = string
    generate_secret             = optional(bool, true)
    access_token_validity_hours = optional(number, 1)
    id_token_validity_hours     = optional(number, 1)
    refresh_token_validity_days = optional(number, 30)
    explicit_auth_flows = optional(list(string), [
      "ALLOW_USER_PASSWORD_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH",
      "ALLOW_USER_SRP_AUTH"
    ])
    prevent_user_existence_errors = optional(bool, true)
    callback_urls                 = optional(list(string), [])
    logout_urls                   = optional(list(string), [])
    allowed_oauth_scopes = optional(list(string), [
      "openid",
      "email",
      "profile"
    ])
    allowed_oauth_flows                           = optional(list(string), [])
    enable_propagate_additional_user_context_data = optional(bool, false)
    enable_token_revocation                       = optional(bool, true)
    read_attributes = optional(list(string), [
      "email",
      "email_verified",
      "phone_number",
      "phone_number_verified"
    ])
    write_attributes = optional(list(string), [
      "email",
      "phone_number"
    ])
  }))
  default = []
}

// ------------ Tags ------------

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

// ------------ Optional Hosted UI config ------------

variable "hosted_ui_config" {
  type = object({
    custom_domain                = string,                      // Domain to alias to the hosted UI
    custom_domain_acm_cert_arn   = string,                      // ARN of the ACM certification for the hosted UI custom domain
    hosted_zone_id               = string,                      // Id of the hosted zone for the UI alias
    hosted_ui_button_color       = optional(string, "#eb5e28"), // CSS compatible color string; e.g. #eb5e28"
    hosted_ui_button_hover_color = optional(string, "#ba2d0b"), // CSS compatible color string; e.g. #ba2d0b
    hosted_ui_logo_file_base64   = optional(string, null),      // Base64 encoded logo image
  })
  description = "Options for configuring the hosted UI custom domain and simple UI styling"
  default     = null
}
