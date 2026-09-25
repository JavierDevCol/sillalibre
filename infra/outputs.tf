# ============================================
# OUTPUTS GLOBALES
# ============================================

output "aws_account_id" {
  description = "ID de la cuenta AWS actual"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Región de AWS configurada"
  value       = var.aws_region
}

output "environment" {
  description = "Ambiente actual"
  value       = var.environment
}

# Backend outputs
output "tfstate_bucket_name" {
  description = "Nombre del bucket S3 para estado de Terraform"
  value       = module.backend.bucket_id
}

output "tfstate_bucket_arn" {
  description = "ARN del bucket S3 para estado de Terraform"
  value       = module.backend.bucket_arn
}

output "tflock_table_name" {
  description = "Nombre de la tabla DynamoDB para locking"
  value       = module.backend.dynamodb_table_name
}

# KMS outputs
output "kms_key_arn" {
  description = "ARN de la clave KMS principal"
  value       = module.kms.key_arn
}

output "kms_key_alias" {
  description = "Alias de la clave KMS principal"
  value       = module.kms.key_alias
}
