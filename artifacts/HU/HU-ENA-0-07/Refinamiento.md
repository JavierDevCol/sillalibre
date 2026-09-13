# Refinamiento: ENA-0-07 - Reglas Arquitectónicas del Proyecto

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | ENA-0-07 |
| **Título** | Reglas Arquitectónicas del Proyecto |
| **Complejidad** | 🟡 MEDIO |
| **Story Points** | 5 SP |
| **Estimación Horas** | 4-6 horas |
| **Fecha refinamiento** | 2026-09-12 |
| **Iteración** | 1 |
| **Modo** | Plano |
| **Tasks** | — |

---

## 1. Historia de Usuario

**Como** equipo de desarrollo,
**Quiero** tener reglas arquitectónicas documentadas y validadas,
**Para** que todo PR se evalúe contra estándares claros y se mantenga la consistencia del sistema.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que ejecuto `init-reglas-arquitectonicas`, cuando respondo el cuestionario, entonces se genera `artifacts/reglas_arquitectonicas.md` con todas las secciones completadas
- [ ] **CA-02:** Dado que existe `reglas_arquitectonicas.md`, cuando reviso el documento, entonces incluye: nomenclatura de código, arquitectura interna por servicio (hexagonal ligera / ports & adapters), patrones aprobados, pirámide de testing, manejo de secretos, DoD técnico
- [ ] **CA-03:** Dado que existe `reglas_arquitectonicas.md`, cuando referencio desde `backlog_roadmap.md`, entonces el enlace es válido y el documento está publicado
- [ ] **CA-04:** Dado que un PR es creado, cuando se evalúa contra las reglas, entonces se verifican al menos: naming conventions, estructura de carpetas por servicio, y patrón de testing

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Las reglas aplican a todos los servicios o hay excepciones? | Reglas base comunes + excepciones documentadas por servicio | Medio |
| 2 | ¿Quién mantiene las reglas después de creadas? | El equipo de desarrollo vía PRs al documento | Bajo |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Usamos Convención de Nombres para branches feat|fix/HU-<id>-slug desde el inicio? | Alta |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Generación de reglas arquitectónicas

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| ENA-0-07-01 | Ejecutar cuestionario `init-reglas-arquitectonicas` | Configuración | 1h |
| ENA-0-07-02 | Documentar nomenclatura de código (clases, métodos, variables) | Documentación | 0.5h |
| ENA-0-07-03 | Definir arquitectura interna por servicio (hexagonal ligera) | Documentación | 1h |
| ENA-0-07-04 | Listar patrones aprobados por servicio (Outbox, CQRS, etc.) | Documentación | 0.5h |
| ENA-0-07-05 | Definir pirámide de testing (unit → integration → e2e) | Documentación | 0.5h |
| ENA-0-07-06 | Establecer manejo de secretos (AWS Secrets Manager / SSM) | Documentación | 0.5h |
| ENA-0-07-07 | Definir Definition of Done técnico | Documentación | 0.5h |
| ENA-0-07-08 | Publicar en `artifacts/reglas_arquitectonicas.md` y referenciar desde backlog | Integración | 0.5h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 3 SP | Documentación estructurada, requiere revisión de ADRs |
| Incertidumbre | +1 SP | Cuestionario puede revelar gaps no previstos |
| Riesgo | +1 SP | Consenso del equipo sobre patrones |
| **Total SP** | **5 SP** | — |

### Estrategia Recomendada

- **Enfoque:** TDD de documentación (crear plantilla → validar con equipo → publicar)
- **Razón:** Las reglas deben ser aprobadas antes de usarlas como gate de PRs

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Falta de consenso en patrones | Media | Alto | Sesión de revisión con equipo antes de publicar |
| Reglas demasiado estrictas para MVP | Baja | Medio | Marcar items como "recomendado" vs "obligatorio" |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| Decisión | ADR-001 | ✅ Aprobado |
| Decisión | ADR-002 | ✅ Aprobado |
| Decisión | ADR-003 | ✅ Aprobado |

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

- **Fases sugeridas:** Revisar ADRs → Cuestionario → Borrador → Revisión equipo → Publicación
- **Componentes clave:** `artifacts/reglas_arquitectonicas.md`
- **Dependencias entre HUs:** ENA-0-08 puede referenciar estas reglas
- **Riesgos a mitigar:** Consenso del equipo
- **Notas adicionales:** ADR-001/002/003 como inputs

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |

---

> **Archivo:** `artifacts/HU/ENA-0-07/Refinamiento.md`
> **Creado por:** `refinar-hu`
