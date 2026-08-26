# ADR-003 — Plataforma Cloud AWS

- **Estado:** ✅ Aceptada — §Mensajería superseded por [ADR-008](ADR-008-mensajeria-hibrida-kafka-rabbitmq.md) (Kafka+RabbitMQ reemplaza EventBridge+SQS). Resto de decisiones vigentes.
- **Decisores:** Javier Garcia (Product Owner), Onad (Arquitecto de Software)
- **Fecha:** 2026-08-23
- **ADR Número:** 003

---

## Contexto y Problema

Los microservicios ([ADR-001](ADR-001-adopcion-microservicios.md)) requieren plataforma de ejecución, mensajería, datos, observabilidad y despliegue. La infraestructura parte de cero y el DevOps del equipo es básico — la nube es también territorio de aprendizaje. Se eligió **AWS** como proveedor (mercado líder, mayor valor formativo-transferible).

Pregunta central: ¿qué servicios gestionados de AWS componen la plataforma minimizando operación manual sin sacrificar aprendizaje?

---

## Drivers de Decisión

- **D1:** Equipo de 2 — prioridad absoluta a servicios gestionados (menos piezas que operar)
- **D2:** Valor formativo: la plataforma debe enseñar prácticas industriales transferibles
- **D3:** Costo controlado para proyecto personal (~$100–170/mes techo aceptado a plena operación)
- **D4:** Observabilidad distribuida desde el inicio (condición de supervivencia de ADR-001)

---

## Opciones Consideradas

Por área de decisión:

| Área | Opción A | Opción B | Opción C |
|------|----------|----------|----------|
| Cómputo | **ECS Fargate** | EKS (Kubernetes) | Lambda |
| Gateway | **Amazon API Gateway** | ALB público directo | Gateway custom (KrakenD/NestJS) |
| Mensajería | EventBridge + SQS | Amazon MQ (RabbitMQ) | SNS directo |
| Datos relacionales | **RDS PostgreSQL** | Aurora Serverless v2 | Instancia EC2 self-managed |
| IaC | **Terraform** | AWS CDK | Consola + CloudFormation |

---

## Decisión

**Elección por área — siempre el servicio gestionado más simple que cumpla el driver:**

| Área | Decisión | Justificación clave |
|------|----------|---------------------|
| **Cómputo** | **ECS Fargate** — un servicio/task definition por microservicio | Contenedores sin gestionar nodos; EKS pospuesto (k8s es otro curso completo); Lambda descartado para workers siempre-on y SSR |
| **Gateway** | **Amazon API Gateway** con **autorizador JWT** apuntando a identidad como emisor OIDC | Gestiona el rol de gateway sin desplegar nada; elimina el microservicio custom de gateway del conteo original (9 → 8 custom) |
| **Mensajería** | ~~EventBridge + SQS~~ → **Kafka KRaft + RabbitMQ** ([ADR-008](ADR-008-mensajeria-hibrida-kafka-rabbitmq.md)) | *Superseded:* EventBridge+SQS era la decisión original; ADR-008 la reemplazó por Kafka (event streaming transferible) + RabbitMQ (task queues) — driver formativo D1 de ADR-001 |
| **Relacional** | **RDS PostgreSQL** (db.t4g.micro) — **una BD lógica por servicio** en instancia compartada inicial; ruta de migración a instancias/Aurora separadas por servicio | Poliglota persistence con costo contenido; separación lógica hoy = separación física mañana |
| **NoSQL** | **DynamoDB** — proyecciones de descubrimiento y registros de envío de notificacion | Caso de uso natural (acceso por clave, sin joins); aprendizaje NoSQL real |
| **Frontends** | Angular → **S3 + CloudFront**; Next.js SSR → **Fargate + CloudFront** | Todo dentro de AWS para aprender la plataforma completa |
| **DNS/TLS** | Route 53 + ACM | Estándar |
| **Envíos** | SES (email) + SNS Mobile Push | Nativos, casi gratis a volumen piloto |
| **Observabilidad** | **CloudWatch** (logs/métricas/alarmas) + **X-Ray** (tracing distribuido) | X-Ray enseña tracing con configuración mínima; condición de supervivencia |
| **Contenedores** | ECR | Registro privado integrado |
| **CI/CD** | GitHub Actions → ECR → despliegue rolling en ECS | Familiar, generoso en free tier |
| **IaC** | **Terraform** con workspaces dev/prod | Estándar de industria transferible a cualquier cloud |
| **Secrets** | Secrets Manager / SSM Parameter Store | Prohibidas credenciales en código o variables de commit |

---

## Consecuencias

### Positivas

- Piezas operadas manualmente ≈ 0 (todo gestionado) — crítico con 2 personas
- Cobertura formativa: contenedores, mensajería event-driven, IaC, tracing distribuido, NoSQL — todo en contexto real
- Ruta de crecimiento clara por componente sin rediseño (db.t4g.micro → Aurora; Fargate → mayor capacidad)

### Negativas

- Vendor lock-in moderado (mitigado: contenedores + Terraform + contratos OpenAPI mantienen portabilidad alta)
- Costo mensual real desde el primer día (ver estimación abajo)
- DynamoDB exige cambio de mentalidad relacional (curva asumida como parte de D2-formativo)

---

## Estimación de Costo Mensual (us-east-1, operación continua)

| Concepto | Estimado/mes |
|----------|-------------|
| Fargate: 8 tareas × 0.25 vCPU/512MB × 730h | $70–80 |
| NAT Gateway | $32 + datos |
| RDS PostgreSQL db.t4g.micro | $13–15 |
| DynamoDB on-demand | $0–2 |
| ~~EventBridge + SQS~~ → **Kafka + RabbitMQ** ([ADR-008](ADR-008-mensajeria-hibrida-kafka-rabbitmq.md)) | $2–4 |
| CloudFront + S3 + Route 53 | $3–5 |
| CloudWatch + X-Ray | $5–10 |
| SES + SNS | $0–1 |
| **Total a plena operación** | **~$125–150** |

**Mitigaciones de costo (obligatorias):**

1. Presupuesto AWS con alarma desde el primer día ($50 aviso, $120 alerta)
2. Schedules de apagado nocturno/fin de semana del ambiente dev (-60% aprox.)
3. Fargate Spot para ambientes no productivos
4. Revisar costos cada cierre de fase

> Precios orientativos 2026 — validar siempre en AWS Pricing Calculator.

---

## Diagrama

Ver documento vivo de arquitectura: [`arquitectura_aws.md`](../../../arquitectura_aws.md) (raíz del proyecto) — incluye el diagrama de paisaje completo, mapeo servicio-recurso y pipeline CI/CD.

---

## Validación

- Fase 0: Terraform levanta toda la plataforma vacía con `terraform apply` desde cero (prueba de destrucción/recreación)
- Alarmas de presupuesto activas antes del primer despliegue
- X-Ray muestra traces end-to-end cruzando ≥3 servicios al cierre de Fase 1

---

## Pros y Contras de las Opciones Clave

### ECS Fargate *(elegido)*

- ✅ Bueno, porque ejecuta contenedores sin administrar nodos ni control planes
- ✅ Bueno, porque las habilidades (Docker, task definitions, blue/green) transfieren a k8s futuro
- ❌ Malo, porque no enseña Kubernetes (diferenciador laboral propio) — pospuesto conscientemente

### EKS

- ✅ Bueno, porque Kubernetes domina el mercado de orquestación
- ❌ Malo, porque su operación excede la capacidad de 2 personas en formación (control plane + nodos + addons)
- ❌ Malo, porque retrasaría meses la primera feature de negocio

### Amazon MQ (RabbitMQ)

- ✅ Bueno, porque replica el estándar AMQP de la industria
- ❌ Malo, porque introduce una instancia que parchear, monitorear y dimensionar (contra D1)

### EventBridge + SQS *(~~elegido~~ → superseded por ADR-008)*

> **⚠️ Decisión reemplazada:** ADR-008 reemplazó EventBridge+SQS por Kafka KRaft (event streaming) + RabbitMQ (task queues). Ver [ADR-008](ADR-008-mensajeria-hibrida-kafka-rabbitmq.md) para la decisión vigente.

- ✅ Bueno, porque cero infraestructura: filtrado, fan-out y DLQ gestionados
- ✅ Bueno, porque enseña arquitectura event-driven moderna AWS-native
- ❌ Malo, porque ata la semántica de eventos al ecosistema AWS (mitigado por puerto de mensajería en código)
- ❌ Malo, porque no enseña Kafka, el estándar de facto industrial para event streaming (driver formativo D1)

---

## Más Información

- AWS Pricing Calculator — validar estimaciones antes de cada fase
- Well-Architected Framework — pillar de Cost Optimization aplicado en cada cierre de fase

---

## ADRs Relacionados

- [ADR-001 — Adopción de Microservicios](ADR-001-adopcion-microservicios.md)
- [ADR-002 — Stack Poliglota Acotado](ADR-002-stack-poliglota-acotado.md)
- [ADR-008 — Mensajería Híbrida Kafka+RabbitMQ](ADR-008-mensajeria-hibrida-kafka-rabbitmq.md) *(reemplaza la decisión de mensajería de este ADR)*

---

✅ Revisado por Javier Garcia
