# ============================================
# OUTPUTS: Backend Terraform
# ============================================

output "bucket_id" {
  description = "ID del bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.tfstate.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.tfstate.arn
}

output "bucket_region" {
  description = "Región del bucket S3"
  value       = aws_s3_bucket.tfstate.region
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para locking"
  value       = aws_dynamodb_table.tflock.name
}

output "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB para locking"
  value       = aws_dynamodb_table.tflock.arn
}
