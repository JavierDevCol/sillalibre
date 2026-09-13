# HU-ENA-0-02: Terraform Base Endurecido

## Metadatos

| Campo | Valor |
|-------|-------|
| **ID** | HU-ENA-0-02 |
| **Título** | Terraform Base Endurecido |
| **Tipo** | Enabler |
| **Proyecto** | SillaLibre |
| **Prioridad** | P0 |
| **Complejidad** | 🔴 ALTO |
| **Story Points** | 13 SP |
| **Estimación** | 12-16 horas |
| **Fecha Creación** | 2026-09-12 |
| **Creado por** | Product Owner Agent |
| **Origen** | ADR-003 §Validación · Auditoría #1 🔴 |
| **Padre** | — |
| **Impl Proyecto** | — |

## Descripción

**Como** equipo de desarrollo,
**Quiero** tener infraestructura base con Terraform (VPC, RDS, KMS, S3, workspaces dev/prod),
**Para** que la infra productiva sea reproducible, destruible y restaurable con un solo comando.

## Criterios de Aceptación

<!-- Los CAs se definen en Refinamiento.md como fuente de verdad -->

## Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| Decisión | HU-ENA-0-01 (FinOps/Región) | ✅ Aprobado |
| Decisión | ADR-003 (Plataforma AWS) | ✅ Aprobado |

## Notas

- Incluye: VPC+NAT, RDS PostgreSQL 17, KMS, S3 Gateway Endpoint
- Workspaces dev/prod con separación de estado
- Drill de restauración PITR documentado (RPO≤5min, RTO≤30min)
- Módulos Kafka (KRaft) + RabbitMQ en docker-compose

---

> **Archivo:** `artifacts/HU/HU-ENA-0-02/HU.md`
> **Creado por:** `refinar-hu`
