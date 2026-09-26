# ============================================
# SILLALIBRE - Infraestructura Terraform
# ============================================
# Backend: S3 + DynamoDB locking
# Región: us-east-1 (decidido en ADR-003 / ENA-0-01)
# ============================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3 - Configurar después de crear bucket y DynamoDB
  # Ejecutar primero: terraform apply -target=module.backend
  # Luego descomentar y ejecutar: terraform init -migrate-state
  #
  # backend "s3" {
  #   bucket         = "REEMPLAZAR_CON_BUCKET_ID"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "sillalibre-tflock"
  #   encrypt        = true
  # }
}

# ============================================
# PROVIDER
# ============================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SillaLibre"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ============================================
# DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# MODULES
# ============================================

module "backend" {
  source = "./modules/backend"

  bucket_name         = "sillalibre-tfstate-${data.aws_caller_identity.current.account_id}"
  dynamodb_table_name = "sillalibre-tflock"
  kms_key_arn         = module.kms.key_arn
  environment         = var.environment
}

module "kms" {
  source = "./modules/kms"

  environment       = var.environment
  enable_key_rotation = true
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
  project_name         = var.project_name
}

module "rds" {
  source = "./modules/rds"

  environment          = var.environment
  project_name         = var.project_name
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  backup_retention_period = var.backup_retention_period
  max_connections      = var.max_connections
  deletion_protection  = var.deletion_protection
  skip_final_snapshot  = var.skip_final_snapshot
  db_password          = var.db_password
  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = module.vpc.vpc_cidr
  private_subnet_ids   = module.vpc.private_subnet_ids
  kms_key_arn          = module.kms.key_arn
}

module "s3" {
  source = "./modules/s3"

  bucket_name           = "${var.project_name}-${var.environment}-assets"
  environment           = var.environment
  project_name          = var.project_name
  enable_versioning     = var.enable_versioning
  kms_key_arn           = module.kms.key_arn
  vpc_id                = module.vpc.vpc_id
  private_route_table_ids = [module.vpc.private_route_table_id]
  aws_region            = var.aws_region
}
