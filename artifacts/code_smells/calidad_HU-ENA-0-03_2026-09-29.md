# 📊 Reporte de Calidad de Código — HU-ENA-0-03

| Campo | Valor |
|-------|-------|
| **Scope** | `commits` (rama `hu-HU-ENA-0-03-pipeline-cicd` vs `main`) |
| **Modo** | `todos` (code smells + arquitectura, sub-agentes en paralelo) |
| **HU** | HU-ENA-0-03 — Pipeline Patrón CI/CD |
| **Fecha** | 2026-09-29 |
| **Archivos analizados** | 17 de código (23 totales en rama; docs/artifacts excluidos) |
| **Reglas arquitectónicas** | ⚠️ `artifacts/reglas_arquitectonicas.md` no existe → defaults IaC/DevSecOps |

## Resumen

```
📁 Archivos: 17 | 🔍 Hallazgos: 0 Críticos | 5 Altos | 13 Medios | 9 Bajos  (total: 27)
```

Análisis previo de la rama (commits `e9774b5`..`12e7652`): 17 commits, +1358/-61 líneas.
Nota: los hallazgos de calidad reportados en commits anteriores (`fd0fe56`) fueron corregidos; este reporte cubre los hallazgos persistentes tras esa revisión.

## Hallazgos

### 🔴 Altos (5)

| # | Tipo | Archivo | Línea | Severidad | Solución |
|---|------|---------|-------|-----------|----------|
| 1 | Fail-open: `AWS_ENDPOINT_URL=http://localhost:4566` en `env` global del workflow → todos los jobs (incl. deploy-prod) enrutan llamadas AWS a LocalStack | `.github/workflows/service-ci.yml` | 59 | alta | Mover a solo jobs/steps floci condicionado a `vars.USE_FLOCI`, o eliminar al migrar a AWS real |
| 2 | Seguridad: trust OIDC con `StringLike repo:${repo}:*` → cualquier rama/PR/tag asume rol con ECR push + ECS deploy | `infra/modules/oidc-role/main.tf` | 49 | alta | Restringir subject a `ref:refs/heads/main` + `environment:dev` + `environment:prod` |
| 3 | Seguridad: `prod.tfvars.example` define `use_floci = true` → copia sin revisar deja prod planificando contra emulador local | `infra/environments/prod.tfvars.example` | 11 | alta | `use_floci = false` + validación `!(environment == "prod" && use_floci)` |
| 4 | Duplicate Code (Shotgun Surgery): bloque "Configure AWS credentials (OIDC)" idéntico en 4 jobs (build, security, deploy-dev, deploy-prod) | `.github/workflows/service-ci.yml` | 155, 190, 247, 282 | alta | Composite action local `.github/actions/aws-oidc` |
| 5 | Duplicate Code: job `deploy-prod` replica `deploy-dev` línea por línea (solo cambia `environment` y `if`) | `.github/workflows/service-ci.yml` | 264-292 | alta | Job único parametrizado con `matrix: environment: [dev, prod]` o composite action |

### 🟡 Medios (13)

| # | Tipo | Archivo | Línea | Severidad | Solución |
|---|------|---------|-------|-----------|----------|
| 6 | Fail-open: `skip_credentials_validation`, `skip_metadata_api_check`, `skip_requesting_account_id` incondicionales (deshabilitan validación también en AWS real) | `infra/main.tf` | 66 | media | Condicionar cada uno a `var.use_floci` |
| 7 | Permisos excesivos IAM: statement `EcsDeploy` con 6 acciones ECS sobre `Resource = "*"` | `infra/modules/oidc-role/main.tf` | 102 | media | Inputs de ARNs (cluster/service/taskdef); `*` solo para Describe*/List* |
| 8 | Secreto en estado: `db_password` como variable queda en claro en `terraform.tfstate` | `infra/modules/rds/main.tf` | 93 | media | `manage_master_user_password = true` + `kms_key_id`, eliminar `var.db_password` |
| 9 | Fail-open RDS: defaults `deletion_protection = false` y `skip_final_snapshot = true` favorecen pérdida de datos en prod | `infra/variables.tf` | 88-97 | media | Invertir defaults a seguros o validación en raíz |
| 10 | Duplicate Code: ternario `var.use_floci ? local.floci_endpoint : null` repetido 11 veces | `infra/main.tf` | 53-63 | media | Un solo mapa con `for` asignado al provider |
| 11 | Shotgun Surgery: validación `contains(["dev","prod"], var.environment)` duplicada en 4 archivos | `infra/variables.tf` + módulos ecr/ecs/oidc-role | 21 / 16 | media | Mantener solo en raíz; en módulos, regex genérica o eliminar |
| 12 | Inconsistencia: fallback de imagen (`build \|\| inputs \|\| DEFAULT_IMAGE`) implementado de 3 formas distintas | `.github/workflows/service-ci.yml` | 188, 255, 290 | media | Una única expresión resuelta (output de `detect`) |
| 13 | Magic Strings: defaults `'patron'` y `'go'` repetidos en 5 sitios | `.github/workflows/service-ci.yml` | 29, 33, 53, 54, 95 | media | Usar únicamente los defaults de `workflow_call`/`workflow_dispatch` |
| 14 | Magic String: `nginx:alpine` hardcodeado en 3 archivos | `service-ci.yml`, `infra/modules/ecs/variables.tf` | 37, 55, 45 | media | Fuente única (env var o variable de entrada sin default) |
| 15 | Manejo de errores: `taskdef.json`/`taskdef-new.json` escritos en CWD sin `trap` (acumulación en runner self-hosted, colisión en paralelo) | `.github/scripts/deploy-ecs.sh` | 9 | media | `TMP=$(mktemp -d)` + `trap 'rm -rf "$TMP"' EXIT` |
| 16 | Magic Number: `containerDefinitions[0].image` — índice mágico falla silencioso en tasks multi-contenedor | `.github/scripts/deploy-ecs.sh` | 12 | media | Actualizar todos los contenedores o fallar si `length > 1` |
| 17 | Fail-open: `find ... 2>/dev/null` → directorio `services/$SERVICE` inexistente devuelve `has_code=false` y el pipeline queda verde sin tests | `.github/workflows/service-ci.yml` | 79 | media | Validar `[ -d "services/$SERVICE" ]` antes; no redirigir stderr |
| 18 | Seguridad: ECR `image_tag_mutability = "MUTABLE"` permite pisar tags SHA (rompe trazabilidad de despliegues) | `infra/modules/ecr/main.tf` | 12 | media | `image_tag_mutability = "IMMUTABLE"` |

### 🟢 Bajos (9)

| # | Tipo | Archivo | Línea | Severidad | Solución |
|---|------|---------|-------|-----------|----------|
| 19 | DevSecOps: log group ECS sin `kms_key_id` (rds/s3/backend sí reciben KMS) | `infra/modules/ecs/main.tf` | 30 | baja | Input `kms_key_arn` en módulo ecs + `kms_key_id` en log group |
| 20 | Hardcode: `github_repository` con default `"JavierDevCol/sillalibre"` | `infra/variables.tf` | 137 | baja | Variable requerida sin default |
| 21 | Estructura: `vpc_cidr` desde `var` en ecs vs desde `module.vpc` en rds/s3 (fuentes duales) | `infra/main.tf` | 156 | baja | `vpc_cidr = module.vpc.vpc_cidr` |
| 22 | Permisos: `id-token: write` a nivel workflow (detect/tests no usan OIDC) | `.github/workflows/service-ci.yml` | 43 | baja | Declarar `permissions` por job |
| 23 | Magic Numbers: healthCheck (interval 15, timeout 5, retries 3, startPeriod 20) incrustados | `infra/modules/ecs/main.tf` | 124 | baja | Promover a variables o local documentado |
| 24 | Magic Strings: ventanas backup/mantenimiento y umbral de log RDS sin documentar | `infra/modules/rds/main.tf` | 64, 102 | baja | Variables con defaults o locales comentados |
| 25 | Duplicate Code: tags `Environment`/`ManagedBy` manuales duplican `default_tags` del provider | `infra/modules/ecs/main.tf` | 21-168 | baja | Depender de `default_tags`; dejar solo tags específicos |
| 26 | Naming inconsistente: `aws_ecs_service.patron` con `name = "patron"` sin prefijo project/environment | `infra/modules/ecs/main.tf` | 146 | baja | `"${var.project_name}-${var.environment}-patron"` |
| 27 | Estilo: `terraform fmt` no ejecutado en tfvars examples (desalineación de `=`) | `infra/environments/*.tfvars.example` | 22 | baja | `terraform fmt infra/environments/` |

## 📐 Arquitectura

| Sección | Resultado |
|---------|-----------|
| Nomenclatura | ✅ Sin violaciones |
| Estructura | ✅ 1 menor (#21) — módulos con main/variables/outputs separados, sin dependencias circulares |
| Patrones | ⚠️ 3 (#1, #3, #14) — hardcodeo de valores de entorno |
| SOLID | ✅ Sin violaciones — service-ci.yml (292 líneas, 6 jobs) cohesivo para el patrón ADR-009 |
| Calidad (DRY) | ⚠️ 2 (#4/#5, #14) |
| DevSecOps | ⚠️ 5 (#2, #7, #18, #19, #22) |

## 💡 Top 3 recomendaciones

1. **Bloquear riesgo de producción:** corregir endpoint local en global (#1), `use_floci=false` en prod (#3) y restringir el trust OIDC (#2) — son los hallazgos con impacto directo en un despliegue real.
2. **DevSecOps de bajo esfuerzo:** IAM mínimo privilegio (#7) + ECR inmutable (#18) — impacto alto en seguridad con cambios mínimos.
3. **DRY del pipeline:** composite action para AWS OIDC (#4) + unificación de deploy-dev/prod (#5) — elimina ~80 líneas duplicadas y el shotgun surgery.

---

✅ Revisado por javier-garcia
