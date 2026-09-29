# ============================================
# OUTPUTS: ECS
# ============================================

output "cluster_arn" {
  description = "ARN del cluster ECS"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "Nombre del servicio patrón"
  value       = aws_ecs_service.patron.name
}

output "task_execution_role_arn" {
  description = "ARN del rol de ejecución de tasks"
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ARN del rol de la task"
  value       = aws_iam_role.task.arn
}
