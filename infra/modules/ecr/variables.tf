# ============================================
# VARIABLES: ECR
# ============================================

variable "project_name" {
  description = "Nombre del proyecto para naming de repositorios"
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

variable "services" {
  description = "Lista de nombres de servicio para crear repositorio ECR"
  type        = list(string)
}
