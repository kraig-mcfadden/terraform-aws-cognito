# terraform-aws-cognito
Terraform module to create an AWS Cognito user pool and zero or more clients for the pool. Forces email verification and account recovery. Can optionally add SMS for account recovery if verified. Also assumes MFA by default with software token, email, and SMS. MFA can be disabled.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.clients](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.pool_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_cognito_user_pool_ui_customization.cognito_hosted_ui_customization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_ui_customization) | resource |
| [aws_iam_role.cognito_sms_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cognito_sms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.cognito_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [random_password.sms_external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_recovery_mechanisms"></a> [account\_recovery\_mechanisms](#input\_account\_recovery\_mechanisms) | List of account recovery mechanisms | <pre>list(object({<br/>    name     = string<br/>    priority = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "verified_email",<br/>    "priority": 1<br/>  },<br/>  {<br/>    "name": "verified_phone_number",<br/>    "priority": 2<br/>  }<br/>]</pre> | no |
| <a name="input_auto_verified_attributes"></a> [auto\_verified\_attributes](#input\_auto\_verified\_attributes) | List of attributes to be auto-verified | `list(string)` | <pre>[<br/>  "email"<br/>]</pre> | no |
| <a name="input_clients"></a> [clients](#input\_clients) | List of user pool clients to create | <pre>list(object({<br/>    name                        = string<br/>    generate_secret             = optional(bool, true)<br/>    access_token_validity_hours = optional(number, 1)<br/>    id_token_validity_hours     = optional(number, 1)<br/>    refresh_token_validity_days = optional(number, 30)<br/>    explicit_auth_flows = optional(list(string), [<br/>      "ALLOW_USER_PASSWORD_AUTH",<br/>      "ALLOW_REFRESH_TOKEN_AUTH",<br/>      "ALLOW_USER_SRP_AUTH"<br/>    ])<br/>    prevent_user_existence_errors = optional(bool, true)<br/>    callback_urls                 = optional(list(string), [])<br/>    logout_urls                   = optional(list(string), [])<br/>    allowed_oauth_scopes = optional(list(string), [<br/>      "openid",<br/>      "email",<br/>      "profile"<br/>    ])<br/>    allowed_oauth_flows                           = optional(list(string), [])<br/>    enable_propagate_additional_user_context_data = optional(bool, false)<br/>    enable_token_revocation                       = optional(bool, true)<br/>    read_attributes = optional(list(string), [<br/>      "email",<br/>      "email_verified",<br/>      "phone_number",<br/>      "phone_number_verified"<br/>    ])<br/>    write_attributes = optional(list(string), [<br/>      "email",<br/>      "phone_number"<br/>    ])<br/>  }))</pre> | `[]` | no |
| <a name="input_device_challenge_required_on_new_device"></a> [device\_challenge\_required\_on\_new\_device](#input\_device\_challenge\_required\_on\_new\_device) | Whether to challenge users on new devices | `bool` | `true` | no |
| <a name="input_device_only_remembered_on_user_prompt"></a> [device\_only\_remembered\_on\_user\_prompt](#input\_device\_only\_remembered\_on\_user\_prompt) | Whether devices are only remembered when user chooses to remember | `bool` | `true` | no |
| <a name="input_email_mfa_message"></a> [email\_mfa\_message](#input\_email\_mfa\_message) | Message template for email MFA | `string` | `"Your authentication code is {####}"` | no |
| <a name="input_email_mfa_subject"></a> [email\_mfa\_subject](#input\_email\_mfa\_subject) | Subject for email MFA messages | `string` | `"Your authentication code"` | no |
| <a name="input_email_verification_message"></a> [email\_verification\_message](#input\_email\_verification\_message) | Email verification message template | `string` | `"Please verify your email with the following verification code: {####}."` | no |
| <a name="input_email_verification_subject"></a> [email\_verification\_subject](#input\_email\_verification\_subject) | Email verification subject | `string` | `"Your verification code"` | no |
| <a name="input_enable_email_mfa"></a> [enable\_email\_mfa](#input\_enable\_email\_mfa) | Whether to enable email MFA | `bool` | `true` | no |
| <a name="input_enable_phone_number_attribute"></a> [enable\_phone\_number\_attribute](#input\_enable\_phone\_number\_attribute) | Whether to enable phone number as a user attribute | `bool` | `true` | no |
| <a name="input_enable_sms_mfa"></a> [enable\_sms\_mfa](#input\_enable\_sms\_mfa) | Whether to enable SMS MFA | `bool` | `true` | no |
| <a name="input_enable_software_token_mfa"></a> [enable\_software\_token\_mfa](#input\_enable\_software\_token\_mfa) | Whether to enable software token (TOTP) MFA | `bool` | `true` | no |
| <a name="input_hosted_ui_config"></a> [hosted\_ui\_config](#input\_hosted\_ui\_config) | Options for configuring the hosted UI custom domain and simple UI styling | <pre>object({<br/>    custom_domain                = string,                      // Domain to alias to the hosted UI<br/>    custom_domain_acm_cert_arn   = string,                      // ARN of the ACM certification for the hosted UI custom domain<br/>    hosted_zone_id               = string,                      // Id of the hosted zone for the UI alias<br/>    hosted_ui_button_color       = optional(string, "#eb5e28"), // CSS compatible color string; e.g. #eb5e28"<br/>    hosted_ui_button_hover_color = optional(string, "#ba2d0b"), // CSS compatible color string; e.g. #ba2d0b<br/>    hosted_ui_logo_file_base64   = optional(string, null),      // Base64 encoded logo image<br/>  })</pre> | `null` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | MFA configuration for user pool (OFF, ON, OPTIONAL) | `string` | `"OPTIONAL"` | no |
| <a name="input_password_minimum_length"></a> [password\_minimum\_length](#input\_password\_minimum\_length) | Minimum length of the password | `number` | `8` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | Whether to require lowercase letters in password | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | Whether to require numbers in password | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | Whether to require symbols in password | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | Whether to require uppercase letters in password | `bool` | `true` | no |
| <a name="input_password_temporary_validity_days"></a> [password\_temporary\_validity\_days](#input\_password\_temporary\_validity\_days) | Number of days temporary passwords are valid | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | Name of the Cognito User Pool | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_details"></a> [client\_details](#output\_client\_details) | Detailed information about all clients |
| <a name="output_client_ids"></a> [client\_ids](#output\_client\_ids) | Map of client names to their IDs |
| <a name="output_client_secrets"></a> [client\_secrets](#output\_client\_secrets) | Map of client names to their secrets (only for clients with secrets) |
| <a name="output_configuration_summary"></a> [configuration\_summary](#output\_configuration\_summary) | Summary of configuration for application integration |
| <a name="output_sms_role_arn"></a> [sms\_role\_arn](#output\_sms\_role\_arn) | ARN of the IAM role created for SMS MFA (if created) |
| <a name="output_sms_role_name"></a> [sms\_role\_name](#output\_sms\_role\_name) | Name of the IAM role created for SMS MFA (if created) |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | ARN of the Cognito User Pool |
| <a name="output_user_pool_creation_date"></a> [user\_pool\_creation\_date](#output\_user\_pool\_creation\_date) | Date the user pool was created |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | Endpoint name of the Cognito User Pool |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | ID of the Cognito User Pool |
| <a name="output_user_pool_last_modified_date"></a> [user\_pool\_last\_modified\_date](#output\_user\_pool\_last\_modified\_date) | Date the user pool was last modified |
| <a name="output_user_pool_name"></a> [user\_pool\_name](#output\_user\_pool\_name) | Name of the Cognito User Pool |
<!-- END_TF_DOCS -->