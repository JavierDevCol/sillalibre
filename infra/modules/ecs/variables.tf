# ============================================
# VARIABLES: ECS
# ============================================

variable "project_name" {
  description = "Nombre del proyecto para naming de recursos"
  type        = string
  default     = "sillalibre"
}

variable "environment" {
  description = "Nombre del ambiente (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El ambiente debe ser 'dev' o 'prod'."
  }
}

variable "aws_region" {
  description = "Región para el log driver awslogs"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID de la VPC donde corre el servicio"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC para el ingress del security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas para las tasks"
  type        = list(string)
}

variable "image" {
  description = "Imagen inicial del servicio patrón (placeholder hasta que el pipeline pushee la de ECR)"
  type        = string
  default     = "nginx:alpine"
}

variable "container_port" {
  description = "Puerto del contenedor"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Unidades CPU de la task (Fargate: 256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memoria MB de la task (Fargate: 512)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Número deseado de tasks"
  type        = number
  default     = 1
}
