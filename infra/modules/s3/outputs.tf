# ============================================
# OUTPUTS - Módulo S3
# ============================================

output "bucket_id" {
  description = "ID del bucket S3"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.main.arn
}

output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.main.bucket
}

output "endpoint_id" {
  description = "ID del VPC Endpoint S3"
  value       = aws_vpc_endpoint.s3.id
}

output "endpoint_arn" {
  description = "ARN del VPC Endpoint S3"
  value       = aws_vpc_endpoint.s3.arn
}
