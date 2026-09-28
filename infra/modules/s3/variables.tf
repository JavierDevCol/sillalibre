# ============================================
# VARIABLES - Módulo S3
# ============================================

variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "El nombre del bucket debe ser válido (solo minúsculas, números, guiones y puntos)."
  }
}

variable "environment" {
  description = "Nombre del ambiente (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El ambiente debe ser 'dev' o 'prod'."
  }
}

variable "project_name" {
  description = "Nombre del proyecto para naming de recursos"
  type        = string
  default     = "sillalibre"
}

variable "enable_versioning" {
  description = "Habilitar versionado del bucket"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptación"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "private_route_table_ids" {
  description = "IDs de las route tables privadas"
  type        = list(string)
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}
