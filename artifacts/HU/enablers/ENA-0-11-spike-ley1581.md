# ENA-0-11 · Spike: Cumplimiento Ley 1581 de 2012

| Campo | Valor |
|---|---|
| **ID** | ENA-0-11 |
| **Tipo** | SPIKE-ENABLER |
| **Rol** | Arquitectura / Backend |
| **Sprint** | S0-A |
| **Estado** | ⏳ Pendiente |
| **Esfuerzo** | S (4–8h) |
| **Timebox** | **8h máximo** |
| **Fuente** | Blueprint §6 Gap #8 · Visión §15.2 |
| **Dependencia** | Ninguna (investigación paralela) |

---

## Descripción

Investigar requisitos concretos de la Ley 1581 de 2012 (protección de datos personales Colombia) aplicables al proyecto SillaLibre. Analizar impacto en el servicio de identidad y en el flujo de registro de usuarios.

## Alcance de la Investigación

1. **Consentimiento:** ¿Requiere opt-in explícito para tratamiento de datos?
2. **Aviso de privacidad:** ¿Debe mostrarse en registro y ser aceptado?
3. **Derechos ARCO:** ¿Debe implementarse flujo de acceso, rectificación, cancelación, oposición?
4. **Registro ante SIC:** ¿Debe registrarse la base de datos ante la Superintendencia de Industria y Comercio?
5. **Datos sensibles:** ¿Algún dato capturado (ubicación, historial) califica como sensible?
6. **Retención:** ¿Hay plazos legales de retención o eliminación?

## Criterio de Aceptación

- [ ] Documento `artifacts/compliance/Ley1581-checklist.md` publicado
- [ ] Cada requisito mapeado a servicio(s) afectado(s)
- [ ] Decisiones de diseño técnicas propuestas (ej. soft-delete, encriptación PII, flujo consentimiento)
- [ ] Clasificación: qué es obligatorio para MVP vs. qué puede diferirse

## Entregable

```markdown
# Checklist Ley 1581 de 2012 — SillaLibre

## Requisitos Aplicables
| # | Requisito | Servicio Afectado | Obligatorio MVP | Decisión de Diseño |
|---|---|---|---|---|
| 1 | ... | identidad | Sí/No | ... |

## Acciones Derivadas
- [ ] HU nueva: ...
- [ ] Modificar CA de HU-identidad-01: ...
```

## Impacto Potencial en el Backlog

| Escenario | Impacto |
|---|---|
| Sin requisitos de MVP | Ninguno — diferir a Fase 2 |
| Consentimiento obligatorio | Modificar CA de HU-identidad-01 (agregar flujo de aceptación) |
| Derechos ARCO obligatorios | Crear HU-identidad-03 en S1 o S2 |
| Registro ante SIC | Tarea administrativa fuera del backlog técnico |

## Dependencias

| Bloqueado por | Tipo |
|---|---|
| — | Ninguna |

| Bloquea | Tipo |
|---|---|
| HU-identidad-01 | Condicional — según resultado del spike |

---

✅ Revisado por Product Owner Agent
