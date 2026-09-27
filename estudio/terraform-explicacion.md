# Terraform — Guía Completa de Comprensión

> **Fecha:** 2026-09-26
> **Nivel:** Conceptual → Práctico
> **Objetivo:** Entender qué es Terraform, dónde vive en el ecosistema DevOps y cómo usarlo.

---

## ¿Qué es Terraform?

**Terraform NO es una plataforma cloud.** Es una herramienta de **Infrastructure as Code (IaC)** creada por **HashiCorp**.

> **Definición simple:** Terraform te permite definir, provisioning y gestionar infraestructura (servidores, base de datos, redes, etc.) mediante archivos de configuración de texto plano, en vez de hacerlo manualmente desde la consola de AWS, Azure o GCP.

### Analogía cotidiana

| Sin Terraform | Con Terraform |
|:---|:---|
| Construir una casa sin plano, ladrillo por ladrillo | Tener un **plano digital** que genera la casa automáticamente y puede reconstruirla idéntica veces |

---

## ¿Qué NO es?

```
┌─────────────────────────────────────────────────┐
│  Terraform ≠ Cloud Provider                      │
│  Terraform ≠ AWS / Azure / GCP                   │
│  Terraform ≠ Kubernetes                          │
│                                                 │
│  Terraform = Herramienta que GESTIONA            │
│              infraestructura EN CUALQUIER cloud   │
│              o local (On-Prem)                    │
└─────────────────────────────────────────────────┘
```

---

## Diagrama: ¿Dónde vive Terraform?

```
┌──────────────────────────────────────────────────────────────┐
│                     TU MÁQUINA / CI/CD                       │
│                                                              │
│   ┌─────────────┐    ┌─────────────────────────────┐        │
│   │  Archivos   │    │      Terraform Engine        │        │
│   │  .tf        │───▶│  (Plan → Apply → Destroy)    │        │
│   │  (tu código)│    └──────────┬──────────────────┘        │
│   └─────────────┘               │                            │
│                                 │  API Calls                 │
└─────────────────────────────────┼────────────────────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
          ▼                       ▼                       ▼
   ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
   │    AWS      │       │   Azure     │       │    GCP      │
   │  (EC2, RDS, │       │  (VMs, SQL, │       │ (Compute,   │
   │   S3, VPC)  │       │  Blob, VNet)│       │  Cloud SQL) │
   └─────────────┘       └─────────────┘       └─────────────┘
```

---

## Conceptos Clave

| Concepto | Qué significa |
|:---|:---|
| **Provider** | Plugin que conecta Terraform con un cloud (AWS, Azure, GCP, Kubernetes, etc.) |
| **Resource** | Cada objeto que creas (una VM, una base de datos, un bucket S3) |
| **State** | Archivo `.tfstate` que registra qué infraestructura existe actualmente |
| **Plan** | Simulación de cambios antes de ejecutarlos |
| **Apply** | Ejecución real de los cambios |
| **Destroy** | Eliminar toda la infraestructura gestionada |

---

## Flujo de Trabajo

```
   ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
   │  WRITE   │      │  PLAN    │      │  APPLY   │      │ DESTROY  │
   │          │      │          │      │          │      │          │
   │ Escribes │ ──▶  │ Terraform│ ──▶  │ Terraform│ ──▶  │ Elimina  │
   │ tu .tf   │      │ muestra  │      │ ejecuta  │      │ todo     │
   │          │      │ qué va a │      │ los      │      │          │
   │          │      │ hacer    │      │ cambios  │      │          │
   └──────────┘      └──────────┘      └──────────┘      └──────────┘
```

---

## Ejemplo Práctico: Crear una VM en AWS

### Paso 1 — Configurar el Provider

```hcl
# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}
```

### Paso 2 — Definir el Recurso

```hcl
# main.tf
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "MiPrimerServidor"
  }
}
```

### Paso 3 — Ejecutar

```bash
terraform init      # Descarga el provider de AWS
terraform plan      # Muestra qué va a crear (simulación)
terraform apply     # Crea la VM real en AWS
terraform destroy   # Elimina la VM
```

### Resultado del `terraform plan`

```
Terraform will perform the following actions:

  # aws_instance.web_server will be created
  + resource "aws_instance" "web_server" {
      + ami                          = "ami-0c55b159cbfafe1f0"
      + instance_type                = "t2.micro"
      + tags                         = {
          + "Name" = "MiPrimerServidor"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

## Ejemplo: Infraestructura Completa (Más Realista)

```hcl
# infrastructure.tf

# 1. Red Virtual
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = { Name = "vpc-produccion" }
}

# 2. Subred pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = { Name = "subnet-publica" }
}

# 3. Servidor de base de datos
resource "aws_db_instance" "postgres" {
  identifier         = "db-barber"
  engine             = "postgres"
  engine_version     = "15"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_name            = "barber_db"
  username           = var.db_user      # Nunca hardcodear credenciales
  password           = var.db_password  # Usar variables o Vault
  skip_final_snapshot = true
}
```

---

## Terraform State — El Corazón del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                    terraform.tfstate                        │
│                                                             │
│  {                                                          │
│    "resources": [                                           │
│      {                                                      │
│        "type": "aws_instance",                              │
│        "name": "web_server",                                │
│        "attributes": {                                      │
│          "id": "i-0abc123def456",                           │
│          "ami": "ami-0c55b159cbfafe1f0",                    │
│          "instance_type": "t2.micro"                        │
│        }                                                    │
│      }                                                       │
│    ]                                                          │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘

⚠️  Este archivo es SENSIBLE. Contiene IDs reales de recursos.
    NUNCA subirlo a Git público. Usar S3 + DynamoDB remoto.
```

---

## ¿Por qué Terraform y no hacerlo a mano?

| Problema manual | Solución Terraform |
|:---|:---|
| "Funciona en mi máquina" | Infraestructura idéntica en Dev, Staging y Prod |
| Clicks en la consola = errores | Código versionado en Git |
| No sé qué cambiaron | Historial de cambios (state) |
| Difícil de destruir limpiamente | `terraform destroy` elimina todo ordenadamente |
| No hay documentación | Los `.tf` SON la documentación |

---

## Resumen Visual

```
┌─────────────────────────────────────────────────────────────┐
│                     TERRAFORM                               │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Tu código  │    │   Terraform │    │  Tu Cloud   │     │
│  │   (.tf)     │───▶│   Engine    │───▶│  (AWS/Azure │     │
│  │             │◀───│             │◀───│   /GCP/etc) │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
│  • Idempotente: Ejecutar 2 veces = mismo resultado         │
│  • Declarativo: Describes QUÉ quieres, no CÓMO hacerlo    │
│  • Multi-cloud: Un mismo lenguaje para todos los clouds    │
│  • Plan antes de apply: Sabes exactamente qué va a pasar   │
└─────────────────────────────────────────────────────────────┘
```

---

## Próximos Temas a Estudiar

- [ ] State remoto (S3 + DynamoDB)
- [ ] Módulos reutilizables
- [ ] Integración con CI/CD (GitHub Actions)
- [ ] Variables y Sensitive data
- [ ] Trabajo con app-barber (infraestructura específica)
