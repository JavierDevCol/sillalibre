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

# ============================================
# VPC OUTPUTS
# ============================================

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block de la VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "IP del NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

# ============================================
# RDS OUTPUTS
# ============================================

output "rds_endpoint" {
  description = "Endpoint de la instancia RDS"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_id" {
  description = "ID de la instancia RDS"
  value       = module.rds.db_instance_id
}

output "rds_db_name" {
  description = "Nombre de la base de datos"
  value       = module.rds.db_name
}

# ============================================
# S3 OUTPUTS
# ============================================

output "s3_bucket_id" {
  description = "ID del bucket S3"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = module.s3.bucket_arn
}

output "s3_endpoint_id" {
  description = "ID del VPC Endpoint S3"
  value       = module.s3.endpoint_id
}
