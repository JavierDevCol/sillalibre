# 📋 Análisis y Visión del Producto — app-barber

| Campo | Valor |
|-------|-------|
| **Proyecto** | app-barber |
| **Fecha** | 2026-08-23 |
| **Versión** | 2.0 |
| **Estado** | ✅ Vigente — análisis de negocio consolidado + decisiones arquitectónicas formalizadas (ADRs) |
| **Documentos derivados** | [ADR-001](ADR/ADR-001-adopcion-microservicios.md) · [ADR-002](ADR/ADR-002-stack-poliglota-acotado.md) · [ADR-003](ADR/ADR-003-plataforma-cloud-aws.md) · [`arquitectura_aws.md`](../arquitectura_aws.md) |
| **Elaborado por** | Onad — Arquitecto de Software |

> **Historial:** v0.1 = análisis inicial con recomendación de Monolito Modular (superseda por activación del objetivo formativo). v2.0 = integración de la decisión de microservicios sobre AWS.

---

## 1. Visión del Producto

> **Plataforma digital (marketplace bilateral)** que conecta establecimientos de barbería y belleza con clientes finales. Los negocios publican su operación (sedes, staff, servicios, promociones) y los clientes descubren, reservan y fidelizan desde un único punto de contacto.

**Posicionamiento:** Frente a competidores consolidados (Booksy, Fresha, Gliphy), el diferenciador natural es la **cuponera/fidelización personalizada por establecimiento**.

**Objetivos del proyecto (en orden):**
1. Crecimiento profesional del equipo mediante práctica real de tecnologías y patrones nuevos
2. Llevar el producto a producción si es posible
3. Determinar cómo evoluciona la adopción para decidir el futuro del negocio

---

## 2. Modelo de Negocio (Fase Actual)

| Aspecto | Definición actual |
|---------|-------------------|
| Monetización | Sin costo durante el piloto — modelo gratuito para validar adopción |
| Rol de la plataforma | Conector/orquestador: NO mueve dinero |
| Pagos | Realizados directamente en el local; la app solo informa métodos aceptados (efectivo, tarjeta, transferencia) |
| Mercado inicial | Por definir (región acotada para densidad de negocios) |

---

## 3. Decisiones Estratégicas Registradas

| ID | Decisión | Justificación | Fecha |
|----|----------|---------------|-------|
| **D1** | Diferir toda la capa financiera (pagos en-app, billetera prepago, liquidaciones) | Elimina el riesgo regulatorio y operativo más pesado; valida hipótesis central primero | 2026-08-23 |
| **D2** | MVP = Opción A "Agenda Digital" | Valida la adopción bilateral con riesgo bajo-medio | 2026-08-23 |
| **D3** | Cuponera SÍ entra al MVP, con **plantillas de reglas predefinidas** (no motor libre) | Protege el diferenciador competitivo acotando complejidad | 2026-08-23 |
| **D4** | Barberos/estilistas con cuenta propia | Requiere roles y permisos desde el inicio (dueño ≠ barbero ≠ cliente) | 2026-08-23 |
| **D5** | Alta de negocios **asistida** durante piloto | Menos pantallas, mejor calidad de datos, onboarding acompañado | 2026-08-23 |
| **D6** | Reseñas verificadas en MVP | Solo clientes con cita completada pueden reseñar; moderación básica | 2026-08-23 |

> **Nota D1:** La "membresía" fue redefinida durante el análisis como **billetera prepago recargable** (saldo almacenado en plataforma). Tiene implicaciones regulatorias propias (dinero electrónico) que refuerzan diferirla a fase 3+.
>
> Las **decisiones arquitectónicas** (estilo, stack, nube) no se registran aquí: viven formalizadas como ADRs — ver encabezado.

---

## 4. Alcance del MVP

### 4.1 Dentro del MVP ✅

| Módulo | Funcionalidad esencial | Épica |
|--------|----------------------|-------|
| Gestión de establecimiento | Registro asistido, sedes/locales, horarios | E1 |
| Gestión de staff | Barberos con cuenta propia, especialidades, jornadas | E2 |
| Catálogo de servicios | Servicios con precio informativo y duración estimada | E1 |
| Descubrimiento | Búsqueda por cercanía o preferencia | E3 |
| Disponibilidad en vivo | Barberos disponibles, turnos en cola, horario de cierre | E3/E4 |
| Reserva de citas | Servicio + barbero + horario; cancelación básica | E4 |
| Recordatorios | Notificación automática de cita próxima y cambios | E5 |
| Historial del cliente | Citas pasadas por local/barbero ("mi barbero de confianza") | E4 |
| Info de pagos | Informativo: métodos aceptados por el local | E1/E3 |
| Cuponera | Plantillas predefinidas, acumulación automática, redención en local | E6 |
| Reseñas | Reseña tras cita completada, agregados en descubrimiento, moderación | E7 |

### 4.2 Fuera del MVP — Diferidos Conscientes ⏸️

| Funcionalidad | Fase | Motivo |
|---------------|------|--------|
| Billetera prepago (ex-membresías) | 3+ | Requiere análisis regulatorio propio |
| Pagos dentro de la app | 3+ | Depende de la billetera |
| Catálogo de productos a la venta | 2 | Bajo valor para la hipótesis central |
| Promociones complejas / motor libre | 2 | Depende de evolución de la cuponera |
| Liquidación multi-negocio | N/A | Eliminado por D1 (la plataforma no mueve dinero) |

---

## 5. Actores del Sistema

| Actor | Rol en MVP |
|-------|-----------|
| **Cliente final** | Descubre, reserva, recibe recordatorios, consulta historial, acumula/redime cupones, reseña |
| **Propietario/Gerente** | Configura negocio, sedes, staff, servicios, cuponeras; ve agenda del día |
| **Barbero/Estilista** | Cuenta propia: gestiona disponibilidad, ve agenda personal, marca citas completadas, valida redención |
| **Admin de Plataforma** | Equipo fundador: alta asistida de negocios piloto, soporte operativo, moderación |

---

## 6. Flujos Núcleo

```
FLUJO 1 (Negocio):   Alta asistida → configurar sede/staff/servicios/cuponeras → agenda operativa
FLUJO 2 (Cliente):   Descubrir → comparar disponibilidad → reservar → recordatorio → asistir → pagar en local
FLUJO 3 (Operación): Barbero/Dueño gestiona citas del día → marcar asistencia/completada
```

---

## 7. Evento Dominante del Dominio 🔑

> **La "Cita Completada" es el evento corazón del sistema.**

```
                        ┌─→ Historial del cliente (RES)
CITA COMPLETADA ────────┼─→ Contador cuponera +1 visita (CPN)
                        └─→ Habilita reseña verificada (RSN)
```

Un solo momento del flujo operativo alimenta tres módulos simultáneamente vía mensajería asíncrona (EventBridge/SQS). Los módulos futuros (billetera, pagos) colgarán del mismo evento. **Este patrón condiciona favorablemente la arquitectura orientada a eventos adoptada.**

---

## 8. Mapa de Épicas → Servicios → Fases

| Épica | Nombre | Alcance | Servicio MS | Stack | Fase de construcción* |
|-------|--------|---------|-------------|-------|------------------------|
| **E1** | Establecimiento | Alta asistida, sedes, horarios, catálogo | EST | Java/Spring Boot | F1 |
| **E2** | Staff y agendas | Cuenta barbero, jornadas, disponibilidad, agenda personal | STF | Java/Spring Boot | F1 |
| **E3** | Descubrimiento | Búsqueda cercanía/preferencia, fichas (proyecciones CQRS) | DSC | Java/Spring Boot | F2 |
| **E4** | Reservas | Reserva, cancelación, ciclo de vida, historial | RES ⭐ núcleo | Java/Spring Boot | F1 |
| **E5** | Notificaciones | Recordatorios, avisos de cambios/cancelaciones | NTF | **Go** | F1 |
| **E6** | Cuponera | Plantillas predefinidas, acumulación, redención | CPN | Java/Spring Boot | F2 |
| **E7** | Reseñas | Reseña verificada post-cita, agregados, moderación | RSN | Java/Spring Boot | F2 |
| **E8** | Administración de plataforma | Onboarding asistido, soporte, moderación | *(sin servicio propio — portal Angular rol admin)* | Angular | F3 |

\* Fases verticales de construcción definidas en ADR-001 (F0 Fundamentos → F1 Núcleo reservable → F2 Fidelización → F3 Endurecimiento).

---

## 9. Gaps de Negocio — Estado

| # | Gap | Estado | Tratamiento |
|---|-----|--------|-------------|
| 1 | Monetización indefinida | 🟡 Abierto (diferido consciente) | Se abordará tras validar adopción del piloto |
| 2 | Problema huevo-gallina | 🟢 Mitigación planificada | Pilotos con 3–5 negocios reales, onboarding asistido |
| 3 | ¿Quién mueve el dinero? | ✅ Resuelto (MVP) | La app no procesa pagos; solo informa métodos |
| 4 | Portabilidad membresías | ♻️ Redefinido → billetera prepago | Diferido a fase 3+, requiere análisis regulatorio |
| 5 | No-shows y cancelaciones | 🟡 Abierto para refinamiento | Definir política básica al refinar E4 |
| 6 | Confianza y calidad | 🟢 Parcialmente resuelto | Reseñas verificadas (D6) cubren la base |
| 7 | Diferenciación vs competencia | ✅ Resuelto estratégicamente | Cuponera en MVP (D3) |

---

## 10. Supuestos por Validar

1. Los establecimientos hoy gestionan con papel/WhatsApp **y quieren digitalizarse** *(validar con dueños reales)*
2. Los propietarios mantendrán actualizados sus datos (horarios, staff, precios)
3. Los clientes finales instalarán una app más para agendar
4. Existe mercado geográfico acotado con densidad suficiente de negocios

---

## 11. Riesgos y Mitigaciones

| Riesgo | Prob. | Impacto | Mitigación |
|--------|-------|---------|------------|
| Alcance descontrolado del MVP | Alta | Alto | Roadmap por fases; este documento fija el corte |
| Adopción lenta del lado oferta | Alta | Alto | Pilotos con negocios reales + onboarding asistido |
| ~~Complejidad financiera prematura~~ | ~~Media~~ | ~~Muy alto~~ | ✅ Neutralizado por D1 |
| Reglas de cuponera arbitrarias | Media | Medio | Plantillas predefinidas (D3), sin motor libre |
| Competencia consolidada | Alta | Alto | Nicho geográfico + diferenciador fidelización |
| Abandono de datos por parte de dueños | Media | Alto | Alta asistida (D5) + métricas de actividad en piloto |
| **Dispersión operativa por microservicios** | Media | Alto | Guardarrails ADR-001: fases verticales, regla de parada, escala de retroceso documentada |
| **Costo cloud descontrolado** | Media | Medio | Presupuesto con alarmas ($50/$120), apagado nocturno dev, Fargate Spot (ADR-003) |

---

## 12. Arquitectura Vigente (resumen ejecutivo)

Las decisiones formales y su justificación completa viven en los ADRs. Resumen operativo:

### 12.1 Estilo — Microservicios ([ADR-001](ADR/ADR-001-adopcion-microservicios.md))

- **8 microservicios custom** (7 dominio + IAM) + **Amazon API Gateway gestionado** como puerta única
- Comunicación: REST síncrona para consultas; **eventos de dominio asíncronos** para propagación (`CitaCompletada` es el evento semilla — §7)
- Construcción por **fases verticales** con regla de parada y escala de retroceso definida

### 12.2 Stack Poliglota Acotado ([ADR-002](ADR/ADR-002-stack-poliglota-acotado.md))

| Capa | Tecnología |
|------|-----------|
| Backend dominante (7 servicios) | Java 21 · Spring Boot 3 |
| Backend periférico (NTF) | Go 1.22+ |
| Frontends | Next.js 14+ (cliente) · Angular 17+ (negocio) |
| Contratos | OpenAPI 3 por servicio |

Regla dura: máximo 2 lenguajes backend.

### 12.3 Plataforma Cloud AWS ([ADR-003](ADR/ADR-003-plataforma-cloud-aws.md))

ECS Fargate · API Gateway · EventBridge + SQS (+DLQ) · RDS PostgreSQL (BD lógica por servicio) + DynamoDB (proyecciones/envíos) · S3+CloudFront · SES+SNS · CloudWatch + X-Ray · Terraform · GitHub Actions → ECR.

Costo estimado a plena operación: ~$125–150/mes, con mitigaciones obligatorias de costo.

### 12.4 Documento vivo de arquitectura

Diagramas de paisaje, mapeo servicio→recurso, pipeline CI/CD y estrategia local: [`arquitectura_aws.md`](../arquitectura_aws.md)

---

## 13. Pendientes Estratégicos Abiertos (no bloqueantes)

- Definición de país/región del mercado piloto (moneda, idioma, regulación)
- Análisis regulatorio de billetera prepago (para fase 3+)
- Modelo de monetización futuro (comisión / suscripción / freemium)

---

## 14. Próximos Pasos

1. **Refinar épicas en Historias de Usuario con criterios SMART** — inicio sugerido: E4 (Reservas) o E1 (Establecimiento)
2. Configurar **reglas arquitectónicas del proyecto** (`init_reglas_arquitectonicas`) antes de implementación
3. Ejecutar **Fase 0 · Fundamentos** (repos, pipeline patrón, Terraform base, entorno local) según ADR-001

---

✅ Revisado por Javier Garcia
