# ============================================
# ECR: Repositorios de Imágenes
# ============================================
# Un repositorio por servicio, naming `sillalibre/<ambiente>/<servicio>`.
# El pipeline (HU-ENA-0-03) pushea con tag = git SHA.
# ============================================

resource "aws_ecr_repository" "this" {
  for_each = toset(var.services)

  name                 = "${var.project_name}/${var.environment}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false # Escaneo lo hace Trivy en el pipeline (CA-02)
  }

  tags = {
    Name        = "${var.project_name}-${each.value}"
    Environment = var.environment
    Service     = each.value
    ManagedBy   = "terraform"
  }
}
