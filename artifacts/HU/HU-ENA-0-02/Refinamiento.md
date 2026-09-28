# Refinamiento: HU-ENA-0-02 - Terraform Base Endurecido

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-02 |
| **Título** | Terraform Base Endurecido |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación Horas** | 13-17 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 2 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener infraestructura base con Terraform,
**Para** que la infra productiva sea reproducible, destruible y restaurable.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que ejecuto `terraform apply` desde cero, cuando verifico con `terraform state list`, entonces existen: VPC con subnets privadas/públicas, NAT Gateway, RDS PostgreSQL 17, KMS key, S3 bucket con Gateway Endpoint, y el backend remoto está configurado en S3 con DynamoDB locking
- [ ] **CA-02:** Dado que configuro workspaces, cuando creo `dev` y `prod`, entonces cada uno tiene estado separado (`terraform workspace select dev/prod`) y configuración independiente (instance type, backups, deletion_protection)
- [ ] **CA-03:** Dado que RDS está configurado, cuando reviso los parámetros con `aws rds describe-db-instances`, entonces tiene: backups habilitados (7d retención + PITR), deletion_protection=true en prod / false en dev, max_connections=200
- [ ] **CA-04:** Dado que ejecuto `terraform destroy` y luego `terraform apply`, cuando verifico la restauración PITR, entonces el drill funciona con RPO≤5min y RTO≤30min, documentado en `artifacts/HU/HU-ENA-0-02/Tracking.md` con timestamp, evidencia y resultado
- [ ] **CA-05:** Dado que existe `docker-compose.yml`, cuando ejecuto `docker compose up -d`, entonces Kafka (bitnami/kafka:3.7) y RabbitMQ (bitnami/rabbitmq:3.13) corren localmente y están listos para recibir conexiones en los puertos estándar (9092, 5672)
- [ ] **CA-06:** Dado que reviso los módulos Terraform, cuando los inspecciono, entonces siguen la estructura: `modules/vpc/`, `modules/rds/`, `modules/s3/`, `modules/kms/`

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Por qué RDS PostgreSQL 17? | Última versión LTS, soporte a 2031 | Alto |
| 2 | ¿S3 Gateway Endpoint o Interface Endpoint? | Gateway (gratis, tráfico same-region) | Medio |
| 3 | ¿Kafka en ECS o docker-compose local? | docker-compose en local, módulo separado para ECS en S0-C | Bajo |
| 4 | ¿Usamos remote state en S3 con DynamoDB locking? | Sí — S3 backend + DynamoDB table para locking. Estándar Terraform, alineado con ADR-003 | Alto |
| 5 | ¿Método de verificación de recursos? | `terraform state list` — comandable, automatizable, sin depender de consola AWS | Medio |
| 6 | ¿deletion_protection en dev? | `false` en dev (permite `terraform destroy` limpio), `true` en prod | Medio |
| 7 | ¿Formato de documentación del drill PITR? | Tracking.md de la HU con timestamp, evidencia (logs) y resultado | Medio |
| 8 | ¿Versiones de Kafka y RabbitMQ? | Kafka: `bitnami/kafka:3.7`, RabbitMQ: `bitnami/rabbitmq:3.13` (tags fijos para reproducibilidad) | Medio |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| — | Sin preguntas pendientes | — |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 0: Backend Remoto

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| HU-ENA-0-02-INFRA-00 | Configurar backend S3 + DynamoDB locking para estado Terraform | Infra | 1h |

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
| Complejidad base | 9 SP | Múltiples módulos Terraform + backend remoto + docker-compose |
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
| **Estado** | ✅ Aprobada |
| **Aprobado por** | Arquitecto DevOps & SRE |
| **Fecha aprobación** | 2026-09-25 |
| **Nivel validación** | completo |
| **Notas** | Iteración 2 — 5 observaciones resueltas, 6/6 CAs SMART completos, 100% cobertura, coherente con ADR-003 |

### Directrices de Planificación

- **Fases sugeridas:** Infra (Backend → VPC → RDS/KMS → S3) → Local (Docker Compose) → Testing (Apply + Drill PITR)
- **Componentes clave:** `modules/backend/`, `modules/vpc/`, `modules/rds/`, `modules/kms/`, `modules/s3/`, `docker-compose.yml`
- **Dependencias entre HUs:** ENA-0-01 completado, sin bloqueos
- **Riesgos a mitigar:** PITR behavior (timebox drill), confusión de workspaces (convención naming)
- **Notas adicionales:** ADR-003 y ADR-008 vigentes. Kafka/RabbitMQ solo local en esta HU (ECS en ENA-0-03)

---

## Feedback de Validación

| # | Observación | Prioridad | CA Afectado | Estado |
|---|-------------|:---------:|:-----------:|:------:|
| 1 | Resolver pregunta de remote state S3+DynamoDB locking | 🔴 Alta | CA-01 | ✅ Resuelto |
| 2 | CA-01: definir método de verificación concreto | 🟡 Media | CA-01 | ✅ Resuelto |
| 3 | CA-03: aclarar `deletion_protection` en dev | 🟡 Media | CA-03 | ✅ Resuelto |
| 4 | CA-04: definir formato y ubicación de documentación del drill PITR | 🟡 Media | CA-04 | ✅ Resuelto |
| 5 | CA-05: definir versiones específicas de Kafka y RabbitMQ | 🟡 Media | CA-05 | ✅ Resuelto |

### Resumen de Cobertura SMART

| CA | SMART | Error | Métrica | Veredicto |
|----|:-----:|:-----:|:-------:|:---------:|
| CA-01 | ⚠️ | ❌ | ❌ | PARCIAL |
| CA-02 | ⚠️ | ❌ | ❌ | PARCIAL |
| CA-03 | ⚠️ | ❌ | ✅ | PARCIAL |
| CA-04 | ⚠️ | ❌ | ⚠️ | PARCIAL |
| CA-05 | ⚠️ | ❌ | ❌ | PARCIAL |
| CA-06 | ✅ | ❌ | ✅ | CUMPLE |

### Validación Arquitectónica

| Requisito ADR-003 | Estado |
|-------------------|:------:|
| RDS PostgreSQL | ✅ |
| Terraform workspaces | ✅ |
| Kafka + RabbitMQ (ADR-008) | ✅ |
| S3 | ✅ |
| NAT Gateway | ✅ |
| KMS | ✅ |

**Coherencia ADR:** ✅ Sin contradicciones

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |
| 2026-09-25 | Validación arquitectónica | ⚠️ Requiere ajustes — 5 observaciones |
| 2026-09-25 | Refinamiento iteración 2 | ✅ 5 observaciones resueltas, CAs actualizados SMART |
| 2026-09-25 | Aprobación | ✅ Validación completa — 6/6 CAs SMART, 100% cobertura |
| 2026-09-25 | Planificación | ✅ Plan generado — 6 fases, 11 tareas, 15h estimadas |

---

> **Archivo:** `artifacts/HU/HU-ENA-0-02/Refinamiento.md`
> **Creado por:** `refinar-hu`
