# ============================================
# VARIABLES - Módulo VPC
# ============================================

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Debe ser un CIDR block válido."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para subnets públicas (una por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Se requieren al menos 2 subnets públicas (una por AZ)."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks para subnets privadas (una por AZ)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "Se requieren al menos 2 subnets privadas (una por AZ)."
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
