# Refinamiento: ENA-0-08 - Estándares de Ingeniería y Convenciones

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | ENA-0-08 |
| **Título** | Estándares de Ingeniería y Convenciones |
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
**Quiero** tener convenciones de ingeniería documentadas,
**Para** que el flujo de trabajo sea consistente y los PRs tengan calidad uniforme.

---

## 2. Criterios de Aceptación

- [ ] **CA-01:** Dado que reviso el documento de convenciones, cuando lo leo, entonces incluye: convención trunk-based con PR gates, nombres de rama `feat|fix/HU-<id>-slug`, conventional commits, template de PR con checklist
- [ ] **CA-02:** Dado que existe el documento, cuando configuro GitHub, entonces el repository tiene branch protection rules documentadas (aunque no configurables en plan Free)
- [ ] **CA-03:** Dado que un PR es creado, cuando uso el template, entonces incluye: descripción, tipo de cambio, checklist de CAs, evidencia de tests
- [ ] **CA-0-04:** Dado que existe el documento, cuando referencio desde `reglas_arquitectonicas.md`, entonces el enlace es válido
- [ ] **CA-05:** Dado que el equipo sigue las convenciones, cuando hago un commit, entonces uso formato `type(scope): description` (conventional commits)

---

## 3. Preguntas de Clarificación

### Resueltas ✅

| # | Pregunta | Respuesta | Impacto |
|---|----------|-----------|---------|
| 1 | ¿Usamos trunk-based desde el inicio? | Sí, eliminada rama develop (decisión R5) | Alto |
| 2 | ¿Revisión cruzada obligatoria? | Sí, equipo de 2 personas | Medio |

### Pendientes ❓

| # | Pregunta | Prioridad |
|---|----------|-----------|
| 1 | ¿Configuramos CODEOWNERS para reviews automáticos? | Baja |

---

## 4. Desglose Técnico (Vertical)

### MODO PLANO

#### Slice 1: Documentación de convenciones

| ID Tarea | Descripción | Capa | Estimación |
|----------|-------------|------|------------|
| ENA-0-08-01 | Definir convención trunk-based y flujo rama→PR→merge | Documentación | 1h |
| ENA-0-08-02 | Documentar nombres de rama `feat\|fix/HU-<id>-slug` | Documentación | 0.5h |
| ENA-0-08-03 | Documentar conventional commits (type(scope): desc) | Documentación | 0.5h |
| ENA-0-08-04 | Crear template de PR en `.github/PULL_REQUEST_TEMPLATE.md` | Configuración | 1h |
| ENA-0-08-05 | Documentar estrategia de versionado de imágenes (SHA de commit) | Documentación | 0.5h |
| ENA-0-08-06 | Documentar criterios de rollback (redeploy tag anterior) | Documentación | 0.5h |
| ENA-0-08-07 | Integrar en `reglas_arquitectonicas.md` §DevOps | Integración | 1h |

---

## 5. Estimación

### Desglose

| Factor | Valor | Justificación |
|--------|-------|---------------|
| Complejidad base | 3 SP | Documentación + template PR |
| Incertidumbre | +1 SP | Configuración de branch protection en repo privado |
| Riesgo | +1 SP | Adopción por parte del equipo |
| **Total SP** | **5 SP** | — |

### Estrategia Recomendada

- **Enfoque:** Incremental (crear template → documentar flujos → integrar con reglas)
- **Razón:** Las convenciones se usan desde el primer PR del S0

---

## 6. Riesgos y Dependencias

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Branch protection no disponible en repo privado (Free) | Alta | Medio | Documentar convención hasta upgrade/público |
| Equipo no sigue convenciones | Baja | Alto | PR template como gate de-recordatorio |

### Dependencias

| Tipo | Referencia | Estado |
|------|------------|--------|
| Decisión | R5 (GitHub Projects) | ✅ Aprobado |
| Decisión | ADR-001 | ✅ Aprobado |

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

- **Fases sugeridas:** Definir flujos → Crear template PR → Integrar con reglas
- **Componentes clave:** `.github/PULL_REQUEST_TEMPLATE.md`, `reglas_arquitectonicas.md` §DevOps
- **Dependencias entre HUs:** ENA-0-07 puede referenciar estas convenciones
- **Riesgos a mitigar:** Branch protection en repo privado
- **Notas adicionales:** R5 como decisión base

---

## Historial

| Fecha | Acción | Detalle |
|-------|--------|---------|
| 2026-09-12 | Refinamiento inicial | Iteración 1 |

---

> **Archivo:** `artifacts/HU/ENA-0-08/Refinamiento.md`
> **Creado por:** `refinar-hu`
