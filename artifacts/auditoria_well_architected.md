# 🔍 Auditoría Well-Architected Framework — app-barber (AWS)

| Campo | Valor |
|-------|-------|
| **Proyecto** | app-barber |
| **Fecha** | 2026-08-23 |
| **Versión** | 1.0 |
| **Alcance** | Arquitectura documentada (design-time): [`arquitectura_aws.md`](../arquitectura_aws.md) + [ADR-001](ADR/ADR-001-adopcion-microservicios.md) · [ADR-002](ADR/ADR-002-stack-poliglota-acotado.md) · [ADR-003](ADR/ADR-003-plataforma-cloud-aws.md). No existe aún código IaC/aplicación; los hallazgos se basan en lo especificado en los documentos vigentes. |
| **Marco de evaluación** | AWS Well-Architected Framework — 6 pilares |
| **Estado** | ✅ Vigente — requiere revisión tras ejecutar Fase 0 |

---

## 1. RESUMEN EJECUTIVO Y SCORING GLOBAL

| Métrica | Valor |
|---|---|
| **Porcentaje Global de Calidad** | **57 / 100%** |
| Excelencia Operativa | **62%** |
| Seguridad | **45%** |
| Resiliencia y HA | **40%** |
| Eficiencia y Rendimiento | **52%** |
| Optimización de Costos | **72%** |
| Mantenibilidad | **74%** |

**Diagnóstico Rápido:** La gobernanza arquitectónica es excepcional para un proyecto de 2 personas (ADRs formales, guardarrails anti-dispersión, FinOps desde el día 0, regla de parada por fases) — eso eleva Costos y Mantenibilidad muy por encima del promedio de proyectos personales. Sin embargo, el diseño concentra riesgos estructurales graves en la capa de datos: **una única instancia RDS compartida single-AZ sostiene 7 servicios**, creando un SPOF de plataforma completa y un riesgo casi seguro de agotamiento de conexiones (`max_connections` ≈ 110 en db.t4g.micro vs ~80 conexiones de pools HikariCP + operaciones). La seguridad perimetral está subespecificada (sin WAF, sin throttling, sin scanning de supply chain) y la resiliencia carece de DR, autoscaling y patrones de tolerancia a fallos en las llamadas síncronas críticas. Es un blueprint bien gobernado que necesita endurecimiento antes de ejecutar Fase 0.

---

## 2. PUNTOS CRÍTICOS Y RIESGOS (Matriz Priorizada)

| Severidad | Componente/Área | Descripción del Riesgo | Impacto DevOps/SRE |
|---|---|---|---|
| 🔴 **Crítica** | RDS compartida (db.t4g.micro) | Una instancia single-AZ sirve las BDs de 7 servicios → SPOF de plataforma completa + dominio de fallo correlacionado que viola la independencia de datos de los microservicios | Caída total del producto ante fallo de instancia/AZ; recovery único para todo; imposible desplegar mantenimiento sin ventana global |
| 🔴 **Crítica** | Conexiones a BD | 8 servicios JVM × pool HikariCP (default 10) ≈ 80 conexiones + migraciones/admin vs `max_connections` ≈ 110 en t4g.micro | Errores intermitentes `FATAL: too many connections` bajo carga; debugging distribuido confuso; incidentes en producción |
| 🔴 **Crítica** | Backup / DR | No hay RPO/RTO definidos, ni política de backups/PITR, ni pruebas de restauración documentadas | Pérdida potencial de datos de negocio (citas, cuponeras) ante corrupción/borrado; sin capacidad de respuesta a incidente |
| 🟠 **Alta** | Edge (API GW / CloudFront) | Sin AWS WAF, sin throttling/usage plans, sin rate limiting por cliente | Vulnerable a abuso, scraping masivo de catálogos y ataques de costo (financial DoS); SES/SNS pueden quemar presupuesto |
| 🟠 **Alta** | Supply chain CI/CD | Pipeline solo con tests unit/integración: sin Trivy/scan de imágenes ECR, sin Dependabot/Renovate, sin SAST (CodeQL), sin SBOM | Imágenes vulnerables a producción; CVEs de dependencias sin visibilidad; riesgo reputacional si hay brecha |
| 🟠 **Alta** | Dimensionamiento Fargate | 0.25 vCPU / 512MB para 7 servicios Java 21 + Spring Boot 3 es insuficiente (overhead JVM + metaspace) | OOMKills recurrentes, reinicios, lentitud de arranque (10–20s) que degrada rolling deploys y escalado reactivo |
| 🟠 **Alta** | Acoplamiento síncrono reserva→personal | `GET slots` REST síncrono sin timeouts/circuit breaker/cache especificados; además API GW depende de JWKS vivo de identidad | personal caído ⇒ reservas caídas (función núcleo); identidad caído ⇒ nadie autentica; fallos en cascada sin aislamiento |
| 🟡 **Media** | Autoscaling ausente | No se especifican políticas (target tracking, min/max, métricas); notificacion worker sin escalado por backlog en RabbitMQ | Sobre-provisionamiento estático o saturación ante picos; costo fijo innecesario |
| 🟡 **Media** | Presupuesto vs realidad | Alarma de alerta ($120) < costo proyectado a plena operación ($125–150) | Alarmas falsas permanentes → fatiga de alerta y pérdida de confianza en el sistema de costos |
| 🟡 **Media** | Observabilidad operativa | Sin retención de logs definida (crecimiento ilimitado CW), sin sampling X-Ray, sin alarmas de DLQ depth ni síntéticos de flujos E2E | Costos CW fuera de control; DLQs que acumulan eventos perdidos silenciosamente; detección de incidencia reactiva |
| 🟡 **Media** | Búsqueda geográfica descubrimiento | "Búsqueda por cercanía" sobre DynamoDB no es nativa (requiere geohash/S2 o OpenSearch) | Riesgo de deuda técnica/rediseño en Fase 2; posible sobrecosto no presupuestado |
| ⚪ **Baja** | Región y residencia de datos | Mercado piloto indefinido pero us-east-1 asumido; sin análisis de latencia/residencia regulatoria | Migración de región futura dolorosa (RDS/EBS snapshots entre regiones) |
| ⚪ **Baja** | Entrega de email | SES sin mencionar salida de sandbox, DKIM/SPF/DMARC | Deliverability pobre → recordatorios no llegan → no-shows (impacta hipótesis central del negocio) |
| ⚪ **Baja** | GitOps/gates | Deploy por commit directo a `main` sin PR gates documentados (solo aprobación manual a prod) | Sin revisión de código trazable; riesgo de romper main sin control |

---

## 3. PLAN DE MEJORAS Y RECOMENDACIONES (DevOps & IaC)

| # | Mejora | Estado Actual | Estado Propuesto | Beneficio Clave | Esfuerzo |
|---|---|---|---|---|---|
| 1 | **Resiliencia RDS** | 1× db.t4g.micro single-AZ, sin backups definidos | Fase piloto: Multi-AZ OFF pero con backups automatizados (retención 7d) + PITR + `deletion_protection` + parameter group con `max_connections=200`. Al monetizar: Multi-AZ ON + RDS Proxy o Aurora Serverless v2 | Elimina SPOF de datos, RPO≈5min/RTO<30min, absorbe picos de conexiones | Bajo |
| 2 | **Control de conexiones** | Pools default por servicio | Pool por servicio ≤ 6 (`hikari.maximumPoolSize`) + alarmas sobre `DatabaseConnections` al 75%; evaluar RDS Proxy cuando haya presupuesto | Prevención de caídas por agotamiento de conexiones | Bajo |
| 3 | **Edge security** | API GW abierto tras JWT, sin WAF | WAF managed rules (Core + KnownBadInputs) en CloudFront + throttling en API GW (rate/burst) + usage plans | Previene abuso, scraping y ataques de costo | Medio |
| 4 | **Supply chain CI/CD** | Tests únicamente | Reusable workflow con: OIDC federation (cero claves AWS estáticas), Trivy scan (fail CRITICAL/HIGH), SBOM, Dependabot, PR como unidad de despliegue | Bloquea vulnerabilidades antes de ECR; elimina el secreto más grande del stack (claves de larga vida) | Medio |
| 5 | **Right-sizing Fargate** | 0.25 vCPU / 512MB todos | APIs: 0.5 vCPU / 1GB con JVM container-aware (`-XX:MaxRAMPercentage=75`); notificacion Go: 0.25/512 OK. Validar con load test en Fase 0 | Estabilidad de deploys, cero OOMKills, latencia p99 predecible | Bajo |
| 6 | **Patrones de resiliencia** | REST síncrono plano | Resilience4j: timeout 2s + circuit breaker + fallback cacheado en reserva→personal; JWKS de identidad servido vía CloudFront (cacheable) para que API GW tolere micro-caídas de identidad | Aislamiento de fallos; reservas degradadas ≠ caídas | Medio |
| 7 | **Autoscaling explícito** | No especificado | Target tracking CPU 60% (min 1/max 4 por API); notificacion: scaling por `ApproximateNumberOfMessagesVisible`; schedules ya existentes para dev | Elástico real: rendimiento bajo demanda + costo optimizado | Bajo |
| 8 | **Observabilidad accionable** | CW + X-Ray genéricos | Retención logs 30d dev / 90d prod; sampling rules X-Ray; **alarmas**: DLQ depth > 0, RDS CPU/conexiones, 5xx API GW, latency p95; Canary CW Synthetics del flujo *descubrir→reservar* cada 5 min | MTTR drástico; eventos perdidos en DLQ detectados en minutos, no semanas | Medio |
| 9 | **Corregir umbrales de presupuesto** | Alerta $120 < operación $125–150 | Forecast-based: aviso $100, alerta $160, action SNS→email+Slack; tags de cost allocation por servicio desde Fase 0 | Señal de costo confiable, atribuible por microservicio | Bajo |
| 10 | **Contratos verificados** | OpenAPI declarados | Contract testing en pipeline (spectral lint + compatibilidad backward en CI); considerar Pact más adelante | Evita rupturas entre 8 servicios sin pruebas manuales cruzadas | Medio |
| 11 | **VPC endpoints** | Todo sale por NAT Gateway ($32+datos) | S3 Gateway Endpoint (gratis, cubre pulls de ECR layers) obligatorio; evaluar interface endpoints (ECR API, Secrets Manager) según volumen NAT | Ahorro directo en procesamiento de datos NAT + superficie privada | Bajo |
| 12 | **Decisión de región temprana** | us-east-1 implícito | Decidir región del mercado piloto ANTES de Fase 1 (todo lo demás sigue siendo Terraform) | Evita migración costosa; latencia óptima para usuarios LatAm | Bajo |

---

## 4. EJEMPLOS DE IMPLEMENTACIÓN CÓDIGO/CONFIGURACIÓN

### 4.1 Terraform — Endurecimiento de RDS + presupuesto calibrado *(corrige hallazgos críticos #1/#2/#9)*

```hcl
resource "aws_db_parameter_group" "appbarber" {
  name   = "appbarber-pg17"
  family = "postgres17"

  parameter {
    name  = "max_connections"
    value = "200"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # queries lentas visibles en CloudWatch
  }
}

resource "aws_db_instance" "core" {
  identifier                   = "appbarber-core"
  engine                       = "postgres"
  engine_version               = "17"
  instance_class               = "db.t4g.micro"
  allocated_storage            = 20
  max_allocated_storage        = 100 # storage autoscaling

  db_name                      = "appbarber"
  username                     = "appadmin"
  manage_master_user_password  = true          # Secrets Manager automático
  parameter_group_name         = aws_db_parameter_group.appbarber.name

  multi_az                     = false          # subir a true cuando haya ingresos
  storage_encrypted            = true           # KMS obligatorio
  backup_retention_period      = 7              # PITR
  backup_window                = "03:00-04:00"
  copy_tags_to_snapshot        = true
  deletion_protection          = true
  skip_final_snapshot          = false
  final_snapshot_identifier    = "appbarber-final"
  performance_insights_enabled = true           # free tier 7 días
}

# Presupuesto calibrado a la proyección real (corrige hallazgo #9)
resource "aws_budgets_budget" "monthly" {
  name         = "appbarber-monthly"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  amount       = 160

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 60   # % => $96
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["devops@app-barber.dev"]
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100  # $160
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["devops@app-barber.dev"]
  }
}
```

### 4.2 Terraform — Edge security: WAF + Throttling *(hallazgo #3)*

```hcl
resource "aws_wafv2_web_acl" "edge" {
  name  = "appbarber-edge"
  scope = "CLOUDFRONT"
  default_action { allow {} }

  rule {
    name     = "AWSManagedCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rules"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "RateLimitPerIP"
    priority = 2
    action { block {} }
    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "edge-acl"
    sampled_requests_enabled   = true
  }
}

# En la REST API de API Gateway
resource "aws_api_gateway_method_settings" "global_throttle" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "prod"
  method_path = "*/*"

  settings {
    throttling_rate_limit  = 100
    throttling_burst_limit = 200
    metrics_enabled        = true
    logging_level          = "ERROR"
  }
}
```

### 4.3 GitHub Actions — Reusable workflow con OIDC + supply chain *(hallazgos #4/#14)*

```yaml
# .github/workflows/service-deploy.yml (template único parametrizado)
name: service-ci
on:
  pull_request:
  push:
    branches: [main]

permissions:
  id-token: write   # OIDC: cero credenciales estáticas
  contents: read
  security-events: write

jobs:
  quality-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: "21", cache: maven }
      - run: mvn -B verify                    # unit + integration (Testcontainers/Kafka+RabbitMQ)

  build-scan-push:
    needs: quality-gate
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    outputs: { image: ${{ steps.tag.outputs.image }} }
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ vars.AWS_ACCOUNT }}:role/gha-ecr-deployer
          aws-region: us-east-1
      - uses: aws-actions/amazon-ecr-login@v2
        id: ecr
      - id: tag
        run: echo "image=${{ steps.ecr.outputs.registry }}/svc:${{ github.sha }}" >> "$GITHUB_OUTPUT"
      - run: docker build -t "${{ steps.tag.outputs.image }}" .
      # Supply-chain gate: bloquea CRITICAL/HIGH antes de ECR
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ steps.tag.outputs.image }}
          severity: CRITICAL,HIGH
          exit-code: "1"
          ignore-unfixed: true
      - run: docker push "${{ steps.tag.outputs.image }}"
      - uses: anchore/sbom-action@v0
        with: { format: spdx-json, artifact-name: sbom.spdx.json }

  deploy-dev:
    needs: build-scan-push
    uses: ./.github/workflows/reusable-tf-deploy.yml
    with: { workspace: dev, image: ${{ needs.build-scan-push.outputs.image }} }

  deploy-prod:
    needs: deploy-dev
    uses: ./.github/workflows/reusable-tf-deploy.yml
    with: { workspace: prod, image: ${{ needs.build-scan-push.outputs.image }} }
    environment: production   # required reviewers => aprobación manual nativa de GH
```

### 4.4 Terraform — Autoscaling + alarmas accionables *(hallazgos #7/#8)*

```hcl
resource "aws_appautoscaling_target" "svc" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_service.res.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu60" {
  name               = "res-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.svc.resource_id
  scalable_dimension = aws_appautoscaling_target.svc.scalable_dimension
  service_namespace  = aws_appautoscaling_target.svc.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageCPUUtilization" }
  }
}

# Alarmas mínimas de supervivencia
# RabbitMQ DLQ: monitorear depth vía CloudWatch o custom metric desde worker
resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  alarm_name          = "dlq-${var.service}-depth"
  namespace           = "Custom/RabbitMQ"
  metric_name         = "DLQMessageCount"
  dimensions          = { Broker = aws_mq_broker.rabbitmq.id, Queue = "notificacion.dlq" }
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.ops_alerts.arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_conn_pressure" {
  alarm_name          = "rds-core-connections-high"
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  dimensions          = { DBInstanceIdentifier = aws_db_instance.core.identifier }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 150   # 75% del max_connections endurecido
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.ops_alerts.arn]
}
```

### 4.5 Aplicación — Resiliencia en reserva→personal (Spring Boot 3) *(hallazgo #6)*

```yaml
# application.yml del servicio reserva
resilience4j:
  timelimiter:
    instances:
      personal-slots: { timeout-duration: 2s }
  circuitbreaker:
    instances:
      personal-slots:
        sliding-window-size: 10
        failure-rate-threshold: 50
        wait-duration-in-open-state: 15s
        permitted-number-of-calls-in-half-open-state: 3
  retry:
    instances:
      personal-slots: { max-attempts: 2, wait-duration: 200ms }

spring:
  datasource:
    hikari:
      maximum-pool-size: 6        # 8 servicios x 6 = 48 << max_connections endurecido
      connection-timeout: 3000
```

---

## 5. ROADMAP RECOMENDADO DE ADOPCIÓN

> **Nota sobre las fases:** este roadmap se alinea con las **fases verticales de construcción** definidas en [ADR-001](ADR/ADR-001-adopcion-microservicios.md) §Guardarrails obligatorios (punto 4):
>
> | Fase | Nombre | Contenido |
> |------|--------|-----------|
> | **F0** | Fundamentos | Repositorios, pipeline patrón CI/CD, Terraform base, entorno local docker-compose, observabilidad mínima |
> | **F1** | Núcleo reservable | identidad + establecimiento + personal + reserva + notificacion → flujo *descubrir→reservar→notificar* E2E en AWS |
> | **F2** | Fidelización | fidelizacion + resena + descubrimiento → MVP funcional completo |
> | **F3** | Endurecimiento | Trazabilidad completa, alarmas, hardening, portal admin |

### Corto Plazo — Quick Wins / Seguridad inmediata *(antes y durante Fase 0 · Fundamentos)*

1. **Endurecer RDS en Terraform base**: backups 7d + PITR + encryption KMS + `deletion_protection` + parameter group `max_connections=200` (§4.1). Definir RPO=5min / RTO=30min y un **drill de restauración** como criterio de validación de Fase 0 (ya existe el principio destroy/recreate — extenderlo a restore).
2. **OIDC en GitHub Actions** (nada de Access Keys estáticas) + **Trivy fail-gate** + Dependabot/Renovate activos (§4.3).
3. **Pool sizes ≤6** por servicio desde el primer día + alarmas de conexiones RDS (§4.4/§4.5).
4. Corregir **umbrales del presupuesto** ($96/$160 forecast-based, §4.1) — evita fatiga de alarmas desde el mes 1.
5. **S3 Gateway Endpoint** gratis + retención de logs (30d dev/90d prod) + reglas de sampling de X-Ray.
6. Subir tamaño de tareas JVM a **0.5 vCPU/1GB** (el ahorro de 512MB es falso: lo paga en estabilidad).
7. **Decidir región definitiva** del mercado piloto antes del primer `apply`.

### Mediano Plazo — Optimización y automatización *(Fases 1–2)*

1. **AWS WAF + throttling** en API GW/CloudFront (§4.2) cuando haya tráfico real que proteger.
2. **Alarmas de supervivencia completas**: DLQ depth (todas las colas), 5xx API GW, p95 latency, canary sintético E2E *descubrir→reservar* cada 5 min; SNS→email/Slack; definir 2–3 SLOs simples (ej. disponibilidad reserva 99.5%, p95 checkout <800ms).
3. **Autoscaling formal** (target tracking + backlog-driven para notificacion) y validar dimensionamiento con load test k6/Gatling.
4. **Resilience4j** en toda llamada síncrona interservicio + JWKS de identidad cacheable vía CloudFront.
5. **Contract testing** (lint Spectral + compatibilidad backward en CI de cada OpenAPI) y PR gates obligatorios como unidad de despliegue.
6. **Validación de viabilidad geo-descubrimiento** (geohash/S2 sobre DynamoDB) en diseño de Fase 2 — decidir antes de implementar, no después.

### Largo Plazo — Evolución arquitectónica y FinOps *(Fase 3+ / cuando haya adopción)*

1. **Multi-AZ RDS o Aurora Serverless v2 + RDS Proxy** al primer ingreso monetario: separación física por servicio según el plan de migración ya previsto en ADR-003 (prioridad: reserva primero, luego establecimiento/personal).
2. **Progressive delivery**: blue/green con CodeDeploy para ECS (canary 10%) en servicios de escritura (reserva/identidad); rollback automático por alarmas.
3. **FinOps maduro**: tags de cost-allocation por servicio, dashboard CUR en QuickSight, revisión trimestral de rightsizing, evaluación Compute Savings Plan si el patrón de uso se estabiliza.
4. **DR cross-region**: réplicas de lectura RDS + replicación de tablas DynamoDB globales hacia la región secundaria cuando existan SLAs con clientes de pago.
5. **Hardening continuo**: rotación automática de secretos (Secrets Manager), revisión IAM quarterly (least privilege real por task role), pentest ligero antes de escalar adopción, y ADR-004 documentando la decisión de plataforma de búsqueda si descubrimiento escala.

---

## Veredicto Final

Arquitectura conceptualmente sólida y excepcionalmente bien gobernada para su contexto (**8/10 en decisiones, 5/10 en especificación operacional**). Los tres movimientos de mayor retorno inmediato son:

1. **RDS endurecida con estrategia de restauración probada**
2. **Supply chain segura con OIDC**
3. **Dimensionamiento JVM realista**

Todos alcanzables dentro de la Fase 0 ya planificada **sin cambiar ninguna decisión de los ADRs vigentes**.

---

## Documentos Relacionados

- [`arquitectura_aws.md`](../arquitectura_aws.md) — documento vivo de arquitectura auditado
- [ADR-001 — Adopción de Microservicios](ADR/ADR-001-adopcion-microservicios.md)
- [ADR-002 — Stack Poliglota Acotado](ADR/ADR-002-stack-poliglota-acotado.md)
- [ADR-003 — Plataforma Cloud AWS](ADR/ADR-003-plataforma-cloud-aws.md)
- [`vision_producto.md`](vision_producto.md) — visión del producto y decisiones estratégicas

---

✅ Revisado por Javier Garcia
