# ============================================
# VARIABLES: Backend Terraform
# ============================================

variable "bucket_name" {
  description = "Nombre del bucket S3 para almacenar el estado de Terraform"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "El nombre del bucket debe ser un nombre de S3 válido (minúsculas, números, guiones, puntos)."
  }
}

variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para locking de Terraform"
  type        = string
  default     = "sillalibre-tflock"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.dynamodb_table_name))
    error_message = "El nombre de la tabla DynamoDB solo puede contener letras, números, guiones y guiones bajos."
  }
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptar el estado de Terraform"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:", var.kms_key_arn))
    error_message = "Debe ser un ARN válido de KMS."
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
