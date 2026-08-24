# 🪒 app-barber

> **Plataforma digital (marketplace bilateral)** que conecta establecimientos de barbería y belleza con clientes finales en **Cúcuta, Norte de Santander (Colombia)**.
> Los negocios publican su operación; los clientes descubren, reservan y fidelizan. Diferenciador: **cuponera/fidelización por establecimiento**.

---

## 📚 Documentación estratégica

| Documento | Descripción |
|-----------|-------------|
| [`artifacts/vision_producto.md`](artifacts/vision_producto.md) | Visión del producto, decisiones D1–D6, alcance del MVP |
| [`artifacts/backlog_roadmap.md`](artifacts/backlog_roadmap.md) | Marco de ejecución, Sprint 0, User Story Map y roadmap S0–S8 |
| [`artifacts/ADR/`](artifacts/ADR/) | Decisiones arquitectónicas: microservicios · stack poliglota · AWS |
| [`arquitectura_aws.md`](arquitectura_aws.md) | Documento vivo de arquitectura (paisaje, pipeline, costos) |
| [`artifacts/auditoria_well_architected.md`](artifacts/auditoria_well_architected.md) | Auditoría WAF y plan de endurecimiento |

## 🚦 Estado

**Fase actual: Sprint 0 · Fundamentos** — iteraciones S0-A/S0-B (inicio 2026-08-24). Regla de parada ADR-001: ninguna fase inicia sin la anterior E2E desplegada.

## 🏗️ Estructura del monorepo (ADR-002)

```
app-barber/
├── artifacts/              # Documentación de producto y ADRs
├── services/               # 8 microservicios (carpeta por servicio)
│   ├── iam/                # Identidad, JWT, roles          [Java · Spring Boot 3]
│   ├── est/                # Establecimientos, sedes, catálogo [Java]
│   ├── stf/                # Staff, jornadas, disponibilidad   [Java]
│   ├── res/                # ⭐ Reservas (núcleo)              [Java]
│   ├── cpn/                # Cuponera / fidelización          [Java]
│   ├── rsn/                # Reseñas verificadas              [Java]
│   ├── dsc/                # Descubrimiento (CQRS)            [Java]
│   └── ntf/                # Notificaciones                   [Go 1.22+]
├── apps/
│   ├── web-cliente/        # Frontend público                 [Next.js 14+]
│   └── portal-negocio/     # Back-office dueños/barberos/admin [Angular 17+]
└── infra/                  # Terraform (única fuente de verdad de la nube)
    ├── modules/
    └── environments/       # workspaces dev / prod
```

## 🛠️ Stack (ADR-002/003)

- **Backend:** Java 21 · Spring Boot 3 (7 servicios) + Go 1.22 (NTF)
- **Frontends:** Next.js 14 (cliente, SSR/SEO) · Angular 17 (portal negocio)
- **Cloud AWS:** ECS Fargate · API Gateway (JWT) · EventBridge + SQS(+DLQ) · RDS PostgreSQL 17 · DynamoDB · SES/SNS · CloudWatch + X-Ray
- **Plataforma:** Terraform (workspaces dev/prod) · GitHub Actions → ECR · contratos OpenAPI 3

> Máximo 2 lenguajes backend (guardarrail ADR-001). La comunicación entre servicios es solo vía OpenAPI o eventos de dominio.

---

✅ Proyecto revisado por Javier Garcia
