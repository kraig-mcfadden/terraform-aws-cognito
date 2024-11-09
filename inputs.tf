variable "user_pool_name" {
  type        = string
  description = "What to call the user pool"
  nullable    = false
}

variable "custom_domain" {
  type        = string
  description = "Domain to alias to the hosted UI"
  nullable    = false
}

variable "custom_domain_acm_cert_arn" {
  type        = string
  description = "ARN of the ACM certification for the hosted UI custom domain"
  nullable    = false
}

variable "hosted_zone_id" {
  type        = string
  description = "Id of the hosted zone for the UI alias"
  nullable    = false
}

variable "verification_email_subject" {
  type        = string
  description = "Subject line of the verification email that goes to new users"
  nullable    = false
  default     = "Your verification code"
}

variable "verification_email_body" {
  type        = string
  description = "Body of the verification email that goes to new users"
  nullable    = false
  default     = "Please verify your email with the following verification code: {####}."
}

variable "hosted_ui_button_color" {
  type        = string
  description = "CSS compatible color string; e.g. #eb5e28"
  nullable    = false
  default     = "#eb5e28"
}

variable "hosted_ui_button_hover_color" {
  type        = string
  description = "CSS compatible color string; e.g. #ba2d0b"
  nullable    = false
  default     = "#ba2d0b"
}

variable "hosted_ui_logo_file_base64" {
  type        = string
  description = "Base64 encoded logo image"
  nullable    = true
}
