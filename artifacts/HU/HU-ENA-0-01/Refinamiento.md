# Refinamiento: ENA-0-01 - Decisión de Región + FinOps Base

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | ENA-0-01 |
| **Título** | Decisión de Región + FinOps Base |
| **Complejidad** | 🟢 BAJO |
| **Story Points** | 2 SP |
| **Estimación Horas** | 2-3 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener la región AWS definida y presupuesto FinOps configurado,
**Para** que los costos estén controlados antes del primer despliegue.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que reviso la configuración AWS, cuando verifico la región, entonces es `us-east-1` (justificada por R1: latencia ~60-80ms desde Cúcuta)
- [ ] **CA-02:** Dado que configuro AWS Budgets, cuando creo un presupuesto, entonces tiene alertas SNS→email configuradas en $96 (forecast) y $160 (max)
- [ ] **CA-03:** Dado que existe el presupuesto, cuando se alcanza el umbral, entonces recibo notificación por email antes del primer despliegue
- [ ] **CA-0-04:** Dado que configuro tags AWS, cuando creo recursos, entonces incluyen `Project=SillaLibre`, `Environment=dev|prod`, `Service=<nombre-servicio>`

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Por qué us-east-1 y no sa-east-1? | us-east-1: mejor costo, latencia aceptable (~60-80ms) | Alto |
| 2 | ¿El presupuesto es mensual o total? | Forecast-based mensual, con alertas progresivas | Medio |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Activamos AWS Cost Explorer desde el inicio? | Baja |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Configuración FinOps

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| ENA-0-01-01 | Configurar región `us-east-1` en credentials/config AWS | Configuración | 0.5h |
| ENA-0-01-02 | Crear SNS Topic para alertas de presupuesto | AWS | 0.5h |
| ENA-0-01-03 | Crear AWS Budget con umbrales $96/$160 y suscripción email | AWS | 1h |
| ENA-0-01-04 | Definir tags estándar y documentar en reglas arquitectónicas | Documentación | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 1 SP | Configuración AWS directa |
| Incertidumbre | +1 SP | Verificación de costos reales vs estimados |
| Riesgo | +0 SP | Bajo riesgo, configuración estándar |
| **Total SP** | **2 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Configuración directa (ya decidido por R1)
- **Razón:** La región y presupuesto ya están definidos, solo falta implementar

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Costos reales difieren de estimación | Media | Medio | Revisar Cost Explorer tras primer despliegue |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| Decisión | R1 | ✅ Aprobado |
| Decisión | ADR-003 | ✅ Aprobado |

---

## Aprobación

<!-- Generado por >validar_hu al aprobar -->

| Campo | Valor |
|-------|-------|
| **Estado** | ✅ Aprobada |
| **Aprobado por** | Product Owner Agent |
| **Fecha aprobación** | 2026-09-24 |
| **Nivel validación** | DoR PASS |
| **Notas** | Criterios INVEST cumplidos, CAs BDD verificables |

### Directrices de Planificación

- **Fases sugeridas:** Configurar AWS → Crear SNS → Crear Budget → Documentar tags
- **Componentes clave:** AWS Budgets, SNS, tags
- **Dependencias entre HUs:** ENA-0-02 (Terraform) usa esta región
- **Riesgos a mitigar:** Costos reales vs estimados
- **Notas adicionales:** R1 y ADR-003 como decisiones base

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |

---

> **Archivo:** `artifacts/HU/ENA-0-01/Refinamiento.md`
> **Creado por:** `refinar-hu`
