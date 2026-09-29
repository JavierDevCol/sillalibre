# Pendientes

| ID | Categoría | Prioridad | Descripción | Estado | HU | Fecha |
|----|-----------|-----------|-------------|--------|----|-------|
| PEN-001 | deuda_tecnica | Media | `AWS_ENDPOINT_URL=http://localhost:4566` (floci) está hardcodeado en el `env:` global de `.github/workflows/service-ci.yml`. Verificado: `~/actions-runner/.env` del runner self-hosted solo define `LANG=es_ES.UTF-8`, **no** define `AWS_ENDPOINT_URL`, por eso se mantuvo en el workflow con comentario `# floci (transitorio): quitar al migrar a AWS real`. Al migrar a AWS real: eliminar esa línea del workflow (o definirla en el `.env` del runner) y, si el repo la necesita, usar `vars.AWS_ENDPOINT_URL`. | [P] | HU-ENA-0-03 | 2026-09-29 |
