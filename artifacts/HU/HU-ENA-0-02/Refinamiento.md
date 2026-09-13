# Refinamiento: HU-ENA-0-02 - Terraform Base Endurecido

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-02 |
| **Título** | Terraform Base Endurecido |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación Horas** | 12-16 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener infraestructura base con Terraform,
**Para** que la infra productiva sea reproducible, destruible y restaurable.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que ejecuto `terraform apply` desde cero, cuando verifico los recursos, entonces existen: VPC con subnets privadas/públicas, NAT Gateway, RDS PostgreSQL 17, KMS key, S3 bucket con Gateway Endpoint
- [ ] **CA-02:** Dado que configuro workspaces, cuando creo `dev` y `prod`, entonces cada uno tiene estado separado y configuración independiente (instance type, backups, deletion_protection)
- [ ] **CA-03:** Dado que RDS está configurado, cuando reviso los parámetros, entonces tiene: backups habilitados (7d retención + PITR), deletion_protection=true en prod, max_connections=200
- [ ] **CA-04:** Dado que ejecuto `terraform destroy` y luego `terraform apply`, cuando verifico la restauración, entonces el drill PITR funciona con RPO≤5min y RTO≤30min documentado
- [ ] **CA-05:** Dado que existe docker-compose, cuando levanto Kafka y RabbitMQ, entonces corren localmente con la misma versión que se despliega en AWS
- [ ] **CA-06:** Dado que reviso los módulos Terraform, cuando los inspecciono, entonces siguen la estructura: `modules/vpc/`, `modules/rds/`, `modules/s3/`, `modules/kms/`

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Por qué RDS PostgreSQL 17? | Última versión LTS, soporte a 2031 | Alto |
| 2 | ¿S3 Gateway Endpoint o Interface Endpoint? | Gateway (gratis, tráfico same-region) | Medio |
| 3 | ¿Kafka en ECS o docker-compose local? | docker-compose en local, módulo separado para ECS en S0-C | Bajo |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos remote state en S3 con DynamoDB locking? | Alta |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: VPC + Red

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-02-INFRA-01 | Crear módulo `modules/vpc/` con VPC, subnets, NAT, route tables | Infra | 3h |
| HU-ENA-0-02-INFRA-02 | Configurar workspaces dev/prod con variables separadas | Infra | 1h |

#### Slice 2: RDS + KMS

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-02-INFRA-03 | Crear módulo `modules/rds/` con PostgreSQL 17, backups, PITR | Infra | 2h |
| HU-ENA-0-02-INFRA-04 | Crear módulo `modules/kms/` para encriptación RDS y S3 | Infra | 1h |

#### Slice 3: S3 + Endpoint

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-02-INFRA-05 | Crear módulo `modules/s3/` con bucket + Gateway Endpoint | Infra | 1h |
| HU-ENA-0-02-INFRA-06 | Configurar versionado y lifecycle en S3 | Infra | 0.5h |

#### Slice 4: Docker Compose Local

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-02-LOCAL-01 | Crear `docker-compose.yml` con PostgreSQL, Kafka KRaft, RabbitMQ | Local | 2h |
| HU-ENA-0-02-LOCAL-02 | Crear script de inicialización de BDs lógicas por servicio | Local | 1h |

#### Slice 5: Validación

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-02-TEST-01 | Ejecutar `terraform apply` desde cero y verificar recursos | Test | 1h |
| HU-ENA-0-02-TEST-02 | Ejecutar drill destroy/recreate + PITR y documentar | Test | 1.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 8 SP | Múltiples módulos Terraform + docker-compose |
| Incertidumbre | +3 SP | Configuración RDS PITR, workspaces |
| Riesgo | +2 SP | Drill de restauración puede fallar |
| **Total SP** | **13 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Incremental (VPC → RDS → S3 → Docker → Validación)
- **Razón:** Cada slice es validable independientemente

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| PITR no funciona como se espera | Media | Alto | Timebox para drill, documentar hallazgos |
| Workspaces causan confusión de estado | Baja | Medio | Convención clara de naming |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| HU previa | HU-ENA-0-01 (FinOps) | ✅ Completado |
| Decisión | ADR-003 | ✅ Aprobado |

---

## Aprobación

| Campo | Valor |
|-------|-------|
| **Estado** | ⏳ Pendiente |
| **Aprobado por** | — |
| **Fecha aprobación** | — |

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-02/Refinamiento.md`
> **Creado por:** `refinar-hu`
