# ============================================
# OUTPUTS: OIDC-ROLE
# ============================================

output "role_arn" {
  description = "ARN del rol que asume GitHub Actions vía OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "Nombre del rol GitHub Actions"
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "ARN del provider OIDC de GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}
