# ============================================
# OUTPUTS: KMS
# ============================================

output "key_arn" {
  description = "ARN de la clave KMS"
  value       = aws_kms_key.main.arn
}

output "key_id" {
  description = "ID de la clave KMS"
  value       = aws_kms_key.main.key_id
}

output "key_alias" {
  description = "Alias de la clave KMS"
  value       = aws_kms_alias.main.name
}
