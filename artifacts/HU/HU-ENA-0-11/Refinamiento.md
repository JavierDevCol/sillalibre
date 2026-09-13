# Refinamiento: ENA-0-11 - Spike Cumplimiento Ley 1581 de 2012

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | ENA-0-11 |
| **Título** | Spike Cumplimiento Ley 1581 de 2012 |
| **Complejidad** | 🟢 BAJO |
| **Story Points** | 3 SP |
| **Estimación Horas** | 4-8 horas (timebox 8h) |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** investigar los requisitos de la Ley 1581 de 2012 aplicables al proyecto,
**Para** saber qué implementar en identidad (consentimiento, ARCO, privacidad) antes de Sprint 1.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que investigo la Ley 1581 de 2012, cuando reviso los 6 alcances (consentimiento, aviso privacidad, derechos ARCO, registro SIC, datos sensibles, retención), entonces cada uno tiene una respuesta clara: aplica/no aplica + justificación
- [ ] **CA-02:** Dado que tengo los resultados, cuando mapeo a servicios, entonces cada requisito indica qué servicio(s) afecta (identidad, reserva, etc.)
- [ ] **CA-03:** Dado que clasifico los requisitos, cuando reviso la tabla, entonces tengo columna "Obligatorio MVP" con Sí/No para cada requisito
- [ ] **CA-04:** Dado que existen requisitos de MVP, cuando propongo decisiones de diseño, entonces tengo: soft-delete, encriptación PII, flujo consentimiento (al menos los aplicables)
- [ ] **CA-05:** Dado que el spike está completo, cuando publico el entregable, entonces existe `artifacts/compliance/Ley1581-checklist.md` con el formato definido
- [ ] **CA-06:** Dado que el spike genera impacto, cuando reviso el backlog, entonces identifico si hay que: modificar CA de HU-identidad-01, crear HU-identidad-03, o no hay cambios

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿El spike tiene timebox? | Sí, 8h máximo | Alto |
| 2 | ¿Quién ejecuta? | Arquitecto/Backend | Medio |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Necesitamos asesoría legal externa o basta con investigación documental? | Media |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Investigación y documentación

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| ENA-0-11-01 | Investigar requisitos de consentimiento (opt-in explícito) | Investigación | 1.5h |
| ENA-0-11-02 | Investigar aviso de privacidad (obligatorio en registro) | Investigación | 1h |
| ENA-0-11-03 | Investigar derechos ARCO (acceso, rectificación, cancelación, oposición) | Investigación | 1.5h |
| ENA-0-11-04 | Investigar registro ante SIC (obligatorio?) | Investigación | 1h |
| ENA-0-11-05 | Investigar datos sensibles (ubicación, historial) | Investigación | 1h |
| ENA-0-11-06 | Investigar retención y eliminación de datos | Investigación | 1h |
| ENA-0-11-07 | Mapear requisitos a servicios afectados | Análisis | 0.5h |
| ENA-0-11-08 | Clasificar obligatorio MVP vs diferible | Análisis | 0.5h |
| ENA-0-11-09 | Proponer decisiones de diseño técnicas | Análisis | 1h |
| ENA-0-11-10 | Publicar `artifacts/compliance/Ley1581-checklist.md` | Documentación | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 2 SP | Investigación documental, no hay código |
| Incertidumbre | +1 SP | Resultado puede impactar HUs existentes |
| Riesgo | +0 SP | Timebox controlado |
| **Total SP** | **3 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Spike primero (investigación → análisis → documento)
- **Razón:** Es investigación, no implementación; el timebox protege

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Resultado requiere cambios en HU-identidad-01 | Media | Alto | Gate: resultado disponible antes de planning S1 |
| Necesidad de asesoría legal externa | Baja | Medio | Investigación documental basta para MVP |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| — | Ninguna | Investigación paralela |

---

## Aprobación

<!-- Generado por >validar_hu al aprobar -->

| Campo | Valor |
|-------|-------|
| **Estado** | ⏳ Pendiente |
| **Aprobado por** | — |
| **Fecha aprobación** | — |
| **Nivel validación** | — |
| **Notas** | — |

### Directrices de Planificación

- **Fases sugeridas:** Investigar 6 alcances → Mapear a servicios → Clasificar MVP → Proponer diseño → Publicar
- **Componentes clave:** `artifacts/compliance/Ley1581-checklist.md`
- **Dependencias entre HUs:** Gate antes de HU-identidad-01 (Sprint 1)
- **Riesgos a mitigar:** Timebox 8h, resultado disponible antes de S1
- **Notas adicionales:** Blueprint §6 Gap #8 · Visión §15.2

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |

---

> **Archivo:** `artifacts/HU/ENA-0-11/Refinamiento.md`
> **Creado por:** `refinar-hu`
