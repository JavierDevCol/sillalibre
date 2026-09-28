# ============================================
# OUTPUTS - Módulo RDS
# ============================================

output "db_instance_endpoint" {
  description = "Endpoint de la instancia RDS"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "ID de la instancia RDS"
  value       = aws_db_instance.main.id
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.main.db_name
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS"
  value       = aws_db_instance.main.arn
}

output "security_group_id" {
  description = "ID del security group de RDS"
  value       = aws_security_group.rds.id
}
