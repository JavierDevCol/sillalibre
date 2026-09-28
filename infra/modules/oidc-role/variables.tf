# ============================================
# VARIABLES: OIDC-ROLE
# ============================================

variable "project_name" {
  description = "Nombre del proyecto para naming del rol"
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

variable "github_repository" {
  description = "Repositorio GitHub autorizado (formato owner/repo)"
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "Debe ser owner/repo (ej: JavierDevCol/sillalibre)."
  }
}

variable "ecr_repository_arns" {
  description = "ARNs de los repositorios ECR con push permitido"
  type        = list(string)
}

variable "task_role_arns" {
  description = "ARNs de los roles de ECS que GitHub Actions puede passhear"
  type        = list(string)
}
