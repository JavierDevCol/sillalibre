# Tags Estándar - SillaLibre

## Propósito

Definir tags consistentes para todos los recursos AWS del proyecto SillaLibre, facilitando:
- **Cost allocation:** Identificar costos por proyecto, entorno y servicio
- **Gestión:** Agrupar y filtrar recursos
- **Automatización:** Scripts y herramientas que dependen de tags

## Tags Obligatorios

| Tag Key | Tag Value | Descripción | Ejemplo |
|---------|-----------|-------------|---------|
| `Project` | `SillaLibre` | Nombre del proyecto | `Project=SillaLibre` |
| `Environment` | `dev` o `prod` | Entorno de despliegue | `Environment=dev` |
| `Service` | `<nombre-servicio>` | Nombre del microservicio | `Service=identidad` |
| `ManagedBy` | `Terraform` | Gestión de infraestructura | `ManagedBy=Terraform` |

## Tags Opcionales

| Tag Key | Tag Value | Descripción | Ejemplo |
|---------|-----------|-------------|---------|
| `CostCenter` | `<centro-costo>` | Centro de costo (si aplica) | `CostCenter=engineering` |
| `Owner` | `<responsable>` | Responsable del recurso | `Owner=backend-team` |
| `Environment` | `staging` | Entorno intermedio | `Environment=staging` |

## Servicios y Sus Tags

### Microservicios

| Servicio | Service Tag | Descripción |
|----------|-------------|-------------|
| identidad | `Service=identidad` | Autenticación y autorización |
| establecimiento | `Service=establecimiento` | Gestión de negocios |
| personal | `Service=personal` | Gestión de barberos |
| reserva | `Service=reserva` | Sistema de reservas |
| notificacion | `Service=notificacion` | Notificaciones (Go) |
| fidelizacion | `Service=fidelizacion` | Programa de fidelización |
| resena | `Service=resena` | Reseñas y calificaciones |
| descubrimiento | `Service=descubrimiento` | Búsqueda y discovery |

### Infraestructura

| Recurso | Service Tag | Descripción |
|---------|-------------|-------------|
| VPC | `Service=network` | Red virtual privada |
| RDS | `Service=database` | Base de datos relacional |
| S3 | `Service=storage` | Almacenamiento de objetos |
| ECS | `Service=compute` | Orquestación de contenedores |
| API Gateway | `Service=api-gateway` | Punto de entrada API |
| Lambda | `Service=serverless` | Funciones serverless |
| SNS | `Service=messaging` | Notificaciones pub/sub |
| SQS | `Service=queues` | Colas de mensajes |
| KMS | `Service=security` | Gestión de claves |

## Uso en Terraform

### Ejemplo de módulo

```hcl
variable "common_tags" {
  type = map(string)
  default = {
    Project     = "SillaLibre"
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "example" {
  tags = merge(var.common_tags, {
    Environment = var.environment
    Service     = "identidad"
  })
}
```

### Ejemplo de recurso

```hcl
resource "aws_db_instance" "main" {
  tags = merge(var.common_tags, {
    Environment = var.environment
    Service     = "database"
    Backup      = "daily"
  })
}
```

## Uso en AWS CLI

### Aplicar tag a recurso existente

```bash
aws resourcegroupstaggingapi tag-resources \
  --resource-arn-list arn:aws:ec2:us-east-1:000000000000:instance/i-1234567890abcdef0 \
  --tags Project=SillaLibre,Environment=dev,Service=identidad
```

### Buscar recursos por tag

```bash
aws resourcegroupstaggingapi get-resources \
  --tag-filters Key=Project,Values=SillaLibre \
  --tag-filters Key=Environment,Values=dev
```

## Uso en Cost Explorer

### Filtrar por proyecto

```bash
aws ce get-cost-and-usage \
  --time-period Start=2026-09-01,End=2026-09-30 \
  --granularity MONTHLY \
  --filter '{"Tags":{"Key":"Project","Values":["SillaLibre"]}}' \
  --metrics "BlendedCost"
```

### Filtrar por servicio

```bash
aws ce get-cost-and-usage \
  --time-period Start=2026-09-01,End=2026-09-30 \
  --granularity MONTHLY \
  --filter '{"Tags":{"Key":"Service","Values":["identidad","reserva"]}}' \
  --metrics "BlendedCost"
```

## Convenciones

1. **Nomenclatura:** Tags en minúsculas para valores, PascalCase para keys
2. **Valores:** Sin espacios, usar guiones (-) en lugar de espacios
3. **Case-sensitive:** `Project` ≠ `project` ≠ `PROJECT`
4. **Consistencia:** Aplicar tags desde el primer recurso creado

## Referencias

- [AWS Tagging Strategies](https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html)
- [AWS Cost Allocation Tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html)
- [Terraform Tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/tagging)

---

> **Archivo:** `artifacts/tags-estandar.md`
> **Creado por:** Product Owner Agent
> **Fecha:** 2026-09-24
> **HU:** ENA-0-01
