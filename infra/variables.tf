# ============================================
# VARIABLES GLOBALES
# ============================================

variable "aws_region" {
  description = "Región de AWS para todos los recursos"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Debe ser una región AWS válida (ej: us-east-1)."
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

# ============================================
# VARIABLES VPC
# ============================================

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para subnets públicas (una por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks para subnets privadas (una por AZ)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ============================================
# VARIABLES RDS
# ============================================

variable "instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Storage allocado en GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage máximo allocado en GB"
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Período de retención de backups en días"
  type        = number
  default     = 7
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

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

# ============================================
# VARIABLES S3
# ============================================

variable "enable_versioning" {
  description = "Habilitar versionado del bucket S3"
  type        = bool
  default     = true
}

# ============================================
# VARIABLES CI/CD (HU-ENA-0-03)
# ============================================

variable "ecr_services" {
  description = "Servicios con repositorio ECR propio"
  type        = list(string)
  default     = ["patron"]

  validation {
    condition = (
      length(var.ecr_services) > 0 &&
      alltrue([for s in var.ecr_services : can(regex("^[a-z0-9-]+$", s))])
    )
    error_message = "ecr_services debe ser una lista no vacía y cada servicio cumplir ^[a-z0-9-]+$."
  }
}

variable "github_repository" {
  description = "Repositorio GitHub autorizado para asumir el rol OIDC (owner/repo)"
  type        = string
  default     = "JavierDevCol/sillalibre"
}

variable "create_oidc_provider" {
  description = "Crear el provider OIDC de GitHub (global de cuenta — solo en un workspace)"
  type        = bool
  default     = true
}

variable "use_floci" {
  description = "true = usar el emulador local floci (profile + endpoints localhost); false = AWS real"
  type        = bool
  default     = false
}
