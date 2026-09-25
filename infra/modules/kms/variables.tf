# ============================================
# VARIABLES: KMS
# ============================================

variable "environment" {
  description = "Nombre del ambiente (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El ambiente debe ser 'dev' o 'prod'."
  }
}

variable "enable_key_rotation" {
  description = "Habilitar rotación automática de la clave KMS (cada 365 días)"
  type        = bool
  default     = true
}
