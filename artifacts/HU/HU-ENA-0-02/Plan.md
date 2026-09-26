---
tipo: plan_implementacion
version: "5.0"
generado_por: ">planificar_hu"
actualizado_por: ">ejecutar_plan"
validado_por: ">validar_ca"
---

# Plan de Implementación: HU-ENA-0-02 - Terraform Base Endurecido

## Metadata

| Campo | Valor |
|-------|-------|
| **HU** | HU-ENA-0-02 |
| **Título** | Terraform Base Endurecido |
| **Refinamiento** | HU-ENA-0-02/Refinamiento.md |
| **Arquitectura** | Infra (Terraform + Docker Compose) |
| **Generado por** | ArchDev Pro |
| **Fecha creación** | 2026-09-25 |
| **Última actualización** | 2026-09-25 |
| **Estimación total** | 15 horas |
| **Estado** | EN_PROGRESO (Fases 1-5 completadas, Fase 6 pendiente de ejecución en AWS) |
| **Modo** | Plano |
| **Tasks** | — |

## Progreso General

| Fase | Estado | Progreso |
|------|--------|----------|
| Fase 1: Backend Remoto | COMPLETADA | 1/1 tareas |
| Fase 2: VPC + Red | COMPLETADA | 2/2 tareas |
| Fase 3: RDS + KMS | COMPLETADA | 2/2 tareas |
| Fase 4: S3 + Endpoint | COMPLETADA | 2/2 tareas |
| Fase 5: Docker Compose Local | COMPLETADA | 2/2 tareas |
| Fase 6: Testing | EN_PROGRESO | 0/2 tareas (pendientes de ejecución en AWS) |
| Fase Final: Validación CA | PENDIENTE | 0/6 criterios |

---

## Fase 1: Backend Remoto

### Configuración de Estado Terraform

#### EJEC-01: Backend S3 + DynamoDB Locking [EJECUTADA]

**Objetivo:** Configurar el backend remoto para que el estado de Terraform se almacene en S3 con locking DynamoDB, habilitando trabajo en equipo y separación por workspaces.

- [x] Paso 1: Crear `modules/backend/` con recursos:
  - `aws_s3_bucket` para estado (nombre: `sillalibre-tfstate-{account_id}`)
  - `aws_s3_bucket_versioning` habilitado
  - `aws_s3_bucket_server_side_encryption_configuration` con KMS
  - `aws_s3_bucket_public_access_block` (bloqueo total)
  - `aws_dynamodb_table` para locking (nombre: `sillalibre-tflock`, `LockID` como partition key)
- [x] Paso 2: Configurar `backend "s3"` en `main.tf` raíz:
  ```hcl
  backend "s3" {
    bucket         = "sillalibre-tfstate-{account_id}"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sillalibre-tflock"
    encrypt        = true
  }
  ```
  **Nota:** Backend configurado pero comentado (requiere crear bucket primero con `terraform apply -target=module.backend`)
- [x] Paso 3: Crear `modules/kms/` (requerido por backend para encriptación)
- [x] Paso 4: Crear `environments/dev.tfvars` y `environments/prod.tfvars`
- [ ] Paso 5: Ejecutar `terraform init` y verificar (requiere credenciales AWS)

- **Estimación:** 1h | **Dependencia:** -
- **CA valida:** CA-01 (backend remoto)

---

## Fase 2: VPC + Red

### Infraestructura de Red

#### EJEC-02: Módulo VPC [EJECUTADA]

**Objetivo:** Crear la red base con subnets públicas/privadas, NAT Gateway y route tables.

- [x] Paso 1: Crear `modules/vpc/main.tf` con recursos:
  - `aws_vpc` con CIDR configurable (default: `10.0.0.0/16`)
  - 2 subnets públicas (una por AZ) con `map_public_ip_on_launch = true`
  - 2 subnets privadas (una por AZ)
  - `aws_internet_gateway` asociado a VPC
  - `aws_eip` + `aws_nat_gateway` en subnet pública
  - `aws_route_table` pública (route a IGW)
  - `aws_route_table` privada (route a NAT)
  - `aws_route_table_association` para cada subnet
- [x] Paso 2: Crear `modules/vpc/variables.tf` con variables:
  - `vpc_cidr` (default: `10.0.0.0/16`)
  - `public_subnet_cidrs` (default: `["10.0.1.0/24", "10.0.2.0/24"]`)
  - `private_subnet_cidrs` (default: `["10.0.3.0/24", "10.0.4.0/24"]`)
  - `environment` (dev/prod)
- [x] Paso 3: Crear `modules/vpc/outputs.tf` con outputs:
  - `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_ip`
- [ ] Paso 4: Ejecutar `terraform apply` y verificar con `terraform state list | grep aws_vpc`

- **Estimación:** 3h | **Dependencia:** EJEC-01
- **CA valida:** CA-01, CA-06

#### EJEC-03: Workspaces Dev/Prod [EJECUTADA]

**Objetivo:** Configurar workspaces con variables separadas por ambiente.

- [x] Paso 1: Crear `environments/dev.tfvars`:
  ```hcl
  environment        = "dev"
  instance_class     = "db.t4g.micro"
  deletion_protection = false
  backup_retention_period = 7
  max_connections    = 200
  ```
- [x] Paso 2: Crear `environments/prod.tfvars`:
  ```hcl
  environment        = "prod"
  instance_class     = "db.t4g.small"
  deletion_protection = true
  backup_retention_period = 7
  max_connections    = 200
  ```
- [ ] Paso 3: Ejecutar `terraform workspace new dev` y `terraform workspace new prod`
- [ ] Paso 4: Verificar con `terraform workspace list` que ambos existen

- **Estimación:** 1h | **Dependencia:** EJEC-02
- **CA valida:** CA-02

---

## Fase 3: RDS + KMS

### Base de Datos y Encriptación

#### EJEC-04: Módulo RDS [EJECUTADA]

**Objetivo:** Crear instancia RDS PostgreSQL 17 con backups, PITR y parámetros configurables por workspace.

- [x] Paso 1: Crear `modules/rds/main.tf` con recursos:
  - `aws_db_subnet_group` en subnets privadas
  - `aws_security_group` (regla: ingress TCP 5432 solo desde VPC)
  - `aws_db_parameter_group` PostgreSQL 17:
    - `max_connections = 200`
    - `log_min_duration_statement = 1000` (queries > 1s)
  - `aws_db_instance`:
    - `engine = "postgres"`, `engine_version = "17"`
    - `instance_class` variable (dev: `db.t4g.micro`, prod: `db.t4g.small`)
    - `allocated_storage = 20`, `max_allocated_storage = 100`
    - `backup_retention_period = 7`
    - `backup_window = "03:00-04:00"`
    - `maintenance_window = "Mon:04:00-Mon:05:00"`
    - `enabled_cloudwatch_logs_exports = ["postgresql"]`
    - `performance_insights_enabled = true`
    - `deletion_protection` variable
    - `skip_final_snapshot = false` (dev: true)
    - `final_snapshot_identifier` para prod
    - `storage_encrypted = true`, `kms_key_id` from modules/kms
- [x] Paso 2: Crear `modules/rds/variables.tf` con variables por ambiente
- [x] Paso 3: Crear `modules/rds/outputs.tf`:
  - `db_instance_endpoint`, `db_instance_id`, `db_name`
- [ ] Paso 4: Ejecutar `terraform apply` y verificar con `aws rds describe-db-instances`

- **Estimación:** 2h | **Dependencia:** EJEC-02, EJEC-05
- **CA valida:** CA-03, CA-06

#### EJEC-05: Módulo KMS [EJECUTADA]

**Objetivo:** Crear clave KMS para encriptación de RDS y S3.

- [x] Paso 1: Crear `modules/kms/main.tf`:
  - `aws_kms_key` con descripción y política de rotación automática (365 días)
  - `aws_kms_alias` con nombre `alias/sillalibre-{environment}`
- [x] Paso 2: Crear `modules/kms/variables.tf`:
  - `environment`, `enable_key_rotation` (default: true)
- [x] Paso 3: Crear `modules/kms/outputs.tf`:
  - `key_arn`, `key_id`

- **Estimación:** 1h | **Dependencia:** -
- **CA valida:** CA-01, CA-06

---

## Fase 4: S3 + Endpoint

### Almacenamiento y Gateway

#### EJEC-06: Módulo S3 [EJECUTADA]

**Objetivo:** Crear bucket S3 con versionado, lifecycle y Gateway Endpoint.

- [x] Paso 1: Crear `modules/s3/main.tf`:
  - `aws_s3_bucket` (nombre: `sillalibre-{environment}-{purpose}`)
  - `aws_s3_bucket_versioning` habilitado
  - `aws_s3_bucket_server_side_encryption_configuration` con KMS
  - `aws_s3_bucket_public_access_block` (bloqueo total)
  - `aws_s3_bucket_lifecycle_configuration`:
    - Transición a IA después de 30 días
    - Transición a Glacier después de 90 días
    - Expiración de objetos después de 365 días (opcional)
  - `aws_vpc_endpoint` (type: Gateway, service: `com.amazonaws.us-east-1.s3`)
  - `aws_vpc_endpoint_route_table_association` con route tables privadas
- [x] Paso 2: Crear `modules/s3/variables.tf`:
  - `bucket_name`, `environment`, `enable_versioning` (default: true)
- [x] Paso 3: Crear `modules/s3/outputs.tf`:
  - `bucket_id`, `bucket_arn`, `endpoint_id`

- **Estimación:** 1h | **Dependencia:** EJEC-02
- **CA valida:** CA-01, CA-06

#### EJEC-07: Integración S3 + Lifecycle [EJECUTADA]

**Objetivo:** Configurar versionado y lifecycle rules en S3.

- [x] Paso 1: Verificar que `aws_s3_bucket_versioning` está habilitado
- [x] Paso 2: Verificar lifecycle rules:
  - Transición a IA: 30 días
  - Transición a Glacier: 90 días
- [ ] Paso 3: Ejecutar `terraform apply` y verificar con `aws s3api get-bucket-versioning`

- **Estimación:** 0.5h | **Dependencia:** EJEC-06
- **CA valida:** CA-06

---

## Fase 5: Docker Compose Local

### Entorno de Desarrollo Local

#### EJEC-08: Docker Compose Services [EJECUTADA]

**Objetivo:** Crear `docker-compose.yml` con PostgreSQL, Kafka KRaft y RabbitMQ.

- [x] Paso 1: Crear `docker-compose.yml` en raíz del proyecto:
  ```yaml
  services:
    postgres:
      image: bitnami/postgresql:17
      ports: ["5432:5432"]
      environment:
        POSTGRESQL_USERNAME: sillalibre
        POSTGRESQL_PASSWORD: dev_password
        POSTGRESQL_DATABASE: sillalibre_dev
      volumes: ["postgres_data:/bitnami/postgresql"]

    kafka:
      image: bitnami/kafka:3.7
      ports: ["9092:9092"]
      environment:
        KAFKA_CFG_NODE_ID: 1
        KAFKA_CFG_PROCESS_ROLES: broker,controller
        KAFKA_CFG_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
        KAFKA_CFG_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093
        KAFKA_CFG_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
        KAFKA_CFG_CONTROLLER_LISTENER_NAMES: CONTROLLER
        KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      volumes: ["kafka_data:/bitnami/kafka"]

    rabbitmq:
      image: bitnami/rabbitmq:3.13
      ports: ["5672:5672", "15672:15672"]
      environment:
        RABBITMQ_USERNAME: guest
        RABBITMQ_PASSWORD: guest
      volumes: ["rabbitmq_data:/bitnami/rabbitmq"]

  volumes:
    postgres_data:
    kafka_data:
    rabbitmq_data:
  ```
- [ ] Paso 2: Ejecutar `docker compose up -d`
- [ ] Paso 3: Verificar servicios:
  - PostgreSQL: `docker compose exec postgres psql -U sillalibre -d sillalibre_dev -c "SELECT 1"`
  - Kafka: `docker compose exec kafka kafka-topics.sh --bootstrap-server localhost:9092 --list`
  - RabbitMQ: `curl -u guest:guest http://localhost:15672/api/overview`

- **Estimación:** 2h | **Dependencia:** -
- **CA valida:** CA-05

#### EJEC-09: Script Inicialización BDs [EJECUTADA]

**Objetivo:** Crear script para inicializar bases de datos lógicas por servicio.

- [x] Paso 1: Crear `scripts/init-databases.sh`:
  ```bash
  #!/bin/bash
  # Crea BDs lógicas por microservicio en la instancia PostgreSQL compartida
  SERVICES=("identidad" "establecimiento" "personal" "reserva" "notificacion" "fidelizacion" "resena" "descubrimiento")
  for svc in "${SERVICES[@]}"; do
    docker compose exec -T postgres psql -U sillalibre -d postgres -c \
      "CREATE DATABASE ${svc}_db;" 2>/dev/null || true
  done
  ```
- [x] Paso 2: Ejecutar `chmod +x scripts/init-databases.sh`
- [ ] Paso 3: Ejecutar script y verificar con `docker compose exec postgres psql -U sillalibre -d postgres -c "\l"`

- **Estimación:** 1h | **Dependencia:** EJEC-08
- **CA valida:** CA-05

---

## Fase 6: Testing

### Validación de Infraestructura

#### EJEC-10: Apply desde Cero [PENDIENTE_EJECUCION]

**Objetivo:** Ejecutar `terraform apply` completo y verificar todos los recursos.

- [ ] Paso 1: Ejecutar `terraform destroy -auto-approve` para limpiar estado previo
- [ ] Paso 2: Ejecutar `terraform apply -auto-approve`
- [ ] Paso 3: Verificar recursos con `terraform state list`:
  - `aws_vpc.main`
  - `aws_subnet.public[*]` (2 subnets)
  - `aws_subnet.private[*]` (2 subnets)
  - `aws_nat_gateway.main`
  - `aws_db_instance.main`
  - `aws_kms_key.main`
  - `aws_s3_bucket.main`
  - `aws_vpc_endpoint.s3`
- [ ] Paso 4: Verificar backend con `terraform state pull | jq '.backend'`
- [ ] Paso 5: Documentar evidencia en Tracking.md

- **Estimación:** 1h | **Dependencia:** EJEC-01 a EJEC-09
- **CA valida:** CA-01

#### EJEC-11: Drill PITR [PENDIENTE_EJECUCION]

**Objetivo:** Ejecutar destrucción + restauración PITR y documentar resultados.

- [ ] Paso 1: Crear dato de prueba en RDS:
  ```sql
  CREATE TABLE drill_test (id SERIAL, created_at TIMESTAMP DEFAULT NOW());
  INSERT INTO drill_test VALUES (1, NOW());
  ```
- [ ] Paso 2: Anotar timestamp del dato (T0)
- [ ] Paso 3: Ejecutar `terraform destroy -auto-approve` (destruye RDS)
- [ ] Paso 4: Ejecutar `terraform apply -auto-approve` (restaura RDS desde PITR)
- [ ] Paso 5: Verificar dato restaurado:
  ```sql
  SELECT * FROM drill_test;
  ```
- [ ] Paso 6: Calcular RPO (diferencia entre T0 y restauración)
- [ ] Paso 7: Documentar en `artifacts/HU/HU-ENA-0-02/Tracking.md`:
  ```markdown
  ## Drill PITR - [FECHA]
  - **T0 (dato creado):** [TIMESTAMP]
  - **Destroy iniciado:** [TIMESTAMP]
  - **Apply completado:** [TIMESTAMP]
  - **RPO:** [X] minutos (target: ≤5min)
  - **RTO:** [X] minutos (target: ≤30min)
  - **Resultado:** [EXITOSO/FALLIDO]
  - **Evidencia:** [logs/creenshots]
  ```

- **Estimación:** 1.5h | **Dependencia:** EJEC-10
- **CA valida:** CA-04

---

## Fase Final: Validar Criterios de Aceptación

> 📌 **Los CAs viven en el refinamiento** (fuente de verdad). Esta sección trackea ESTADO de verificación.

### Estado de Verificación de CAs

| CA | Resumen | Verificado |
|----|---------|:----------:|
| CA-01 | `terraform apply` crea todos los recursos + backend S3+DynamoDB | [ ] |
| CA-02 | Workspaces dev/prod con estado y config separados | [ ] |
| CA-03 | RDS: backups 7d+PITR, deletion_protection, max_connections=200 | [ ] |
| CA-04 | Drill PITR: RPO≤5min, RTO≤30min, documentado en Tracking.md | [ ] |
| CA-05 | Docker Compose: Kafka 3.7 + RabbitMQ 3.13 en puertos 9092/5672 | [ ] |
| CA-06 | Módulos siguen estructura: `modules/vpc/`, `modules/rds/`, `modules/s3/`, `modules/kms/` | [ ] |

### Validación Final

- [ ] Todos los recursos Terraform creados y verificados
- [ ] `terraform state list` muestra todos los recursos esperados
- [ ] Docker Compose levanta servicios correctamente
- [ ] Drill PITR documentado con evidencia
- [ ] Sin errores en `terraform plan` (plan limpio)
- [ ] Revisión de código completada

---

## Notas de Implementación

### Decisiones Técnicas

| Decisión | Justificación |
|----------|---------------|
| Backend S3+DynamoDB | Estándar Terraform para trabajo en equipo |
| bitnami/* images | Imágenes oficiales, bien documentadas, LTS |
| KRaft (sin Zookeeper) | Kafka 3.7+ soporta KRaft nativamente |
| deletion_protection=false en dev | Permite `terraform destroy` limpio para testing |
| Lifecycle S3 (IA→Glacier) | Reduce costos de almacenamiento a largo plazo |

### Convenciones de Naming

| Recurso | Patrón | Ejemplo |
|---------|--------|---------|
| VPC | `sillalibre-{env}-vpc` | `sillalibre-dev-vpc` |
| RDS | `sillalibre-{env}-db` | `sillalibre-dev-db` |
| S3 | `sillalibre-{env}-{purpose}` | `sillalibre-dev-assets` |
| KMS | `alias/sillalibre-{env}` | `alias/sillalibre-dev` |

### Estructura de Directorios

```
infrastructure/
├── main.tf                    # Raíz + backend
├── variables.tf               # Variables globales
├── outputs.tf                 # Outputs globales
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
├── modules/
│   ├── backend/               # S3 + DynamoDB
│   ├── vpc/                   # VPC + subnets + NAT
│   ├── rds/                   # PostgreSQL 17
│   ├── kms/                   # Encriptación
│   └── s3/                    # Bucket + Gateway Endpoint
├── docker-compose.yml         # Servicios locales
└── scripts/
    └── init-databases.sh      # Inicialización BDs
```

---

## Historial de Ejecución

| Fecha | Acción | Tarea | Resultado |
|-------|--------|-------|-----------|
| 2026-09-25 | Inicio | — | Plan creado |
| 2026-09-25 | EJEC-01 | Backend S3+DynamoDB | ✅ Completado |
| 2026-09-25 | EJEC-02 | Módulo VPC | ✅ Completado |
| 2026-09-25 | EJEC-03 | Workspaces Dev/Prod | ✅ Completado |
| 2026-09-25 | EJEC-04 | Módulo RDS | ✅ Completado |
| 2026-09-25 | EJEC-05 | Módulo KMS | ✅ Completado |
| 2026-09-25 | EJEC-06 | Módulo S3 | ✅ Completado |
| 2026-09-25 | EJEC-07 | Integración S3 + Lifecycle | ✅ Completado |
| 2026-09-25 | EJEC-08 | Docker Compose Services | ✅ Completado |
| 2026-09-25 | EJEC-09 | Script Inicialización BDs | ✅ Completado |
| 2026-09-25 | EJEC-10 | Apply desde Cero | ⏳ Pendiente (requiere AWS) |
| 2026-09-25 | EJEC-11 | Drill PITR | ⏳ Pendiente (requiere AWS) |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-02/Plan.md`
> **Creado por:** `>planificar_hu`
> **Actualizado por:** `>ejecutar_plan`
