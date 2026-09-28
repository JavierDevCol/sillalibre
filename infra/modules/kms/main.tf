# ============================================
# KMS: Clave de Encriptación
# ============================================
# Clave KMS para encriptar RDS, S3 y estado de Terraform.
# Rotación automática habilitada (365 días).
# ============================================

resource "aws_kms_key" "main" {
  description             = "Clave KMS principal para SillaLibre - ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "EnableRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "sillalibre-${var.environment}"
    Environment = var.environment
    Purpose     = "encryption"
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/sillalibre-${var.environment}"
  target_key_id = aws_kms_key.main.key_id
}

# ============================================
# DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}
