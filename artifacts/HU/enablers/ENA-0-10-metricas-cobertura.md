# ENA-0-10 · Métricas de Cobertura de Tests

| Campo | Valor |
|---|---|
| **ID** | ENA-0-10 |
| **Tipo** | STORY-ENABLER |
| **Rol** | DevOps / Backend |
| **Sprint** | S0-B |
| **Estado** | ⏳ Pendiente |
| **Esfuerzo** | M (4–6h) |
| **Fuente** | Blueprint §6 Gap #7 · Visión §15.5 |
| **Dependencia** | ENA-0-03 (pipeline patrón CI/CD) |

---

## Descripción

Configurar JaCoCo (Java) + cobertura Go nativa integrados al pipeline CI con fail-gate ≥80% en lógica de negocio. Dashboard local opcional (SonarQube Community o report HTML).

## Criterio de Aceptación

- [ ] JaCoCo configurado en todos los servicios Java (pom.xml)
- [ ] `go test -cover` integrado en pipeline para servicio Go
- [ ] Fail-gate en pipeline: PR rechazado si cobertura < 80% en lógica de negocio
- [ ] Reporte de cobertura visible en el PR (HTML artifact o comment automático)
- [ ] Cobertura medida solo sobre capa `domain/` y `application/` (no adapters/infra)

## Tareas Técnicas

1. Añadir plugin JaCoCo a `pom.xml` patrón con configuración de exclusión de adapters
2. Configurar `go test -coverprofile` en workflow Go
3. Añadir step de cobertura al pipeline `service-ci.yml` con umbral configurable
4. Generar reporte HTML como artifact del workflow

## Dependencias

| Bloqueado por | Tipo |
|---|---|
| ENA-0-03 | Pipeline patrón CI/CD |

| Bloquea | Tipo |
|---|---|
| ENA-0-09 | Scaffold (debe tener cobertura configurada) |

---

✅ Revisado por Product Owner Agent
