# terraform-aws-cognito
Terraform module to create an AWS Cognito user pool.

Opinionated and currently defaults to email / password via a hosted UI with MFA on. Allows users to sign themselves up, and creates an alias for the hosted UI. Also allows for some customization of the button color and logo image. Verification emails are sent from the default Cognito email address.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_domain.pool_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_cognito_user_pool_ui_customization.cognito_hosted_ui_customization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_ui_customization) | resource |
| [aws_route53_record.cognito_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | Domain to alias to the hosted UI | `string` | n/a | yes |
| <a name="input_custom_domain_acm_cert_arn"></a> [custom\_domain\_acm\_cert\_arn](#input\_custom\_domain\_acm\_cert\_arn) | ARN of the ACM certification for the hosted UI custom domain | `string` | n/a | yes |
| <a name="input_hosted_ui_button_color"></a> [hosted\_ui\_button\_color](#input\_hosted\_ui\_button\_color) | CSS compatible color string; e.g. #eb5e28 | `string` | `"#eb5e28"` | no |
| <a name="input_hosted_ui_button_hover_color"></a> [hosted\_ui\_button\_hover\_color](#input\_hosted\_ui\_button\_hover\_color) | CSS compatible color string; e.g. #ba2d0b | `string` | `"#ba2d0b"` | no |
| <a name="input_hosted_ui_logo_file_base64"></a> [hosted\_ui\_logo\_file\_base64](#input\_hosted\_ui\_logo\_file\_base64) | Base64 encoded logo image | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Id of the hosted zone for the UI alias | `string` | n/a | yes |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | What to call the user pool | `string` | n/a | yes |
| <a name="input_verification_email_body"></a> [verification\_email\_body](#input\_verification\_email\_body) | Body of the verification email that goes to new users | `string` | `"Please verify your email with the following verification code: {####}."` | no |
| <a name="input_verification_email_subject"></a> [verification\_email\_subject](#input\_verification\_email\_subject) | Subject line of the verification email that goes to new users | `string` | `"Your verification code"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->