# ============================================
# VARIABLES - Módulo RDS
# ============================================

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

variable "instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t4g.micro"

  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "Debe ser una clase de instancia RDS válida (ej: db.t4g.micro)."
  }
}

variable "allocated_storage" {
  description = "Storage allocado en GB"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "El storage allocado debe ser al menos 20 GB."
  }
}

variable "max_allocated_storage" {
  description = "Storage máximo allocado en GB (para auto-scaling)"
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Período de retención de backups en días"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 7
    error_message = "El período de retención debe ser al menos 7 días."
  }
}

variable "max_connections" {
  description = "Número máximo de conexiones"
  type        = number
  default     = 200
}

variable "deletion_protection" {
  description = "Habilitar protección contra eliminación"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Saltar snapshot final al eliminar"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "sillalibre"
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "sillalibre"
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptación"
  type        = string
}
