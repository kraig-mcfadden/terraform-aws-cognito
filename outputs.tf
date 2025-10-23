output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.arn
}

output "user_pool_name" {
  description = "Name of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.name
}

output "user_pool_endpoint" {
  description = "Endpoint name of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.endpoint
}

output "user_pool_creation_date" {
  description = "Date the user pool was created"
  value       = aws_cognito_user_pool.pool.creation_date
}

output "user_pool_last_modified_date" {
  description = "Date the user pool was last modified"
  value       = aws_cognito_user_pool.pool.last_modified_date
}

# Client outputs - maps of client name to values
output "client_ids" {
  description = "Map of client names to their IDs"
  value       = { for name, client in aws_cognito_user_pool_client.clients : name => client.id }
}

output "client_secrets" {
  description = "Map of client names to their secrets (only for clients with secrets)"
  value       = { for name, client in aws_cognito_user_pool_client.clients : name => client.client_secret if client.generate_secret }
  sensitive   = true
}

output "client_details" {
  description = "Detailed information about all clients"
  value = {
    for name, client in aws_cognito_user_pool_client.clients : name => {
      id                     = client.id
      name                   = client.name
      has_secret             = client.generate_secret
      access_token_validity  = client.access_token_validity
      id_token_validity      = client.id_token_validity
      refresh_token_validity = client.refresh_token_validity
      explicit_auth_flows    = client.explicit_auth_flows
      callback_urls          = client.callback_urls
      logout_urls            = client.logout_urls
      allowed_oauth_scopes   = client.allowed_oauth_scopes
      allowed_oauth_flows    = client.allowed_oauth_flows
    }
  }
}

# SMS IAM role outputs (if created)
output "sms_role_arn" {
  description = "ARN of the IAM role created for SMS MFA (if created)"
  value       = var.enable_sms_mfa ? aws_iam_role.cognito_sms_role[0].arn : null
}

output "sms_role_name" {
  description = "Name of the IAM role created for SMS MFA (if created)"
  value       = var.enable_sms_mfa ? aws_iam_role.cognito_sms_role[0].name : null
}
