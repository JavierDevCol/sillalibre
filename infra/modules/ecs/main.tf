# ============================================
# ECS: Cluster Fargate + Servicio Patrón
# ============================================
# Cluster, task definition placeholder y servicio con
# deployment circuit breaker + rollback automático (CA-09).
# El pipeline real actualiza la task def con la imagen de ECR.
# ponytail: un solo servicio patrón; convertir a for_each sobre
# un map de servicios cuando ENA-0-09 cree los 8 scaffolds.
# ============================================

# --- Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- Logs ---

resource "aws_cloudwatch_log_group" "patron" {
  name              = "/ecs/${var.project_name}-${var.environment}-patron"
  retention_in_days = 14

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- IAM ---

resource "aws_iam_role" "task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { ManagedBy = "terraform" }
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${var.project_name}-${var.environment}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { ManagedBy = "terraform" }
}

# --- Red ---

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-patron"
  description = "Traffic del servicio patrón ECS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Container port desde la VPC"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Salida a internet - pull de imagenes y APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.environment}-ecs-patron"
    ManagedBy = "terraform"
  }
}

# --- Task definition ---

resource "aws_ecs_task_definition" "patron" {
  family                   = "${var.project_name}-${var.environment}-patron"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name  = "patron"
    image = var.image
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
    healthCheck = {
      command     = ["CMD-SHELL", "wget -q --spider http://localhost:${var.container_port}/ || exit 1"]
      interval    = 15
      timeout     = 5
      retries     = 3
      startPeriod = 20
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.patron.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "patron"
      }
    }
    essential = true
  }])

  tags = { ManagedBy = "terraform" }
}

# --- Servicio con circuit breaker (CA-09) ---

resource "aws_ecs_service" "patron" {
  name            = "patron"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.patron.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  health_check_grace_period_seconds = 60

  tags = {
    Name      = "patron"
    ManagedBy = "terraform"
  }
}
