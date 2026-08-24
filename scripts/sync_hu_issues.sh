#!/usr/bin/env bash
# ============================================================
# sync_hu_issues.sh — Puente SAC → GitHub (decisión R5)
# Sincroniza artifacts/HU/<id>/HU.md hacia Issues de GitHub.
#
# Reglas de diseño:
#   * IDEMPOTENTE: crea la issue solo si no existe una con
#     título que empiece por "[<id>]". Si existe, actualiza
#     el cuerpo (la fuente de verdad es SIEMPRE el archivo).
#   * NUNCA cierra issues: el cierre ocurre vía PR ("Closes #N").
#   * Solo gestiona carpetas artifacts/HU/HU-*/  (los Enablers
#     ENA-* se gestionan manualmente por el PO/agente).
#
# Uso:
#   bash scripts/sync_hu_issues.sh             # aplica cambios
#   bash scripts/sync_hu_issues.sh --dry-run   # solo reporta
#
# Convenciones que lee de HU.md (tabla Metadatos):
#   | **Título** | ... |   → título de la issue
#   | **Sprint** | S1  |   → milestone cuyo título empiece por "S1"
# ============================================================
set -euo pipefail

REPO="${GITHUB_REPOSITORY:-JavierDevCol/sillalibre}"
HU_ROOT="artifacts/HU"
DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

command -v gh >/dev/null 2>&1 || { echo "❌ gh CLI no disponible"; exit 1; }
[[ -d "$HU_ROOT" ]] || { echo "ℹ️  Sin carpeta '$HU_ROOT' todavía — nada que sincronizar."; exit 0; }

# --- helpers -------------------------------------------------
# Extrae el valor de una fila "| **Campo** | valor |" de un md.
row_val() {
  local campo="$1" archivo="$2" out=""
  out=$(grep -m1 -E "^\|\s*\*\*${campo}\*\*" "$archivo" 2>/dev/null |
        sed -E 's/^\|[^|]*\|\s*([^|]*?)\s*\|.*$/\1/' |
        tr -d '*' || true)
  echo "$out"
}

resolve_milestone() {
  local token="$1"
  [[ -z "$token" || "$token" == "—" ]] && return 0
  gh api "repos/$REPO/milestones" --paginate 2>/dev/null \
    --jq ".[] | select(.title | startswith(\"$token\")) | .title" | head -1 || true
}

# Índice local de issues existentes (evita N llamadas API)
declare -A ISSUE_BY_PREFIX
while IFS=$'\t' read -r num title; do
  [[ -z "${num:-}" ]] && continue
  key="${title%%] *}"          # "[HU-IAM-01"
  ISSUE_BY_PREFIX["${key}]"]="$num"
done < <(gh issue list --repo "$REPO" --state all --limit 1000 \
           --json number,title --jq '.[] | "\(.number)\t\(.title)"' 2>/dev/null)

created=0; updated=0; total=0
shopt -s nullglob
for hu_dir in "$HU_ROOT"/HU-*/; do
  hu_id="$(basename "$hu_dir")"
  f="${hu_dir}HU.md"
  total=$((total+1))
  [[ -f "$f" ]] || { echo "⚠️  $hu_id sin HU.md — omitida"; continue; }

  title="$(row_val "Título" "$f")"
  [[ -z "$title" ]] && title="$(head -n1 "$f" | sed 's/^#\+\s*//')"
  sprint="$(row_val "Sprint" "$f")"

  # Cuerpo regenerado: archivo íntegro embebido (fuente única)
  body_file="$(mktemp)"
  {
    echo "> 🤖 Cuerpo generado desde \`${hu_dir}\` — **edita el archivo y haz push**, no esta issue."
    echo ""
    cat "$f"
    if [[ -f "${hu_dir}Refinamiento.md" ]]; then
      echo ""
      echo "<details><summary>📄 Refinamiento.md (CAs BDD)</summary>"
      echo ""
      cat "${hu_dir}Refinamiento.md"
      echo ""
      echo "</details>"
    fi
  } > "$body_file"

  existing="${ISSUE_BY_PREFIX["[${hu_id}]"]:-}"

  if [[ -z "$existing" ]]; then
    ms="$(resolve_milestone "$sprint")"
    ms_args=(); [[ -n "$ms" ]] && ms_args=(--milestone "$ms")
    if (( DRY )); then
      echo "🟢 [dry-run] crearía issue: [$hu_id] $title ${ms:+(milestone: $ms)}"
    else
      gh issue create --repo "$REPO" \
        --title "[$hu_id] $title" \
        --body-file "$body_file" \
        --label hu "${ms_args[@]}" >/dev/null
      echo "🟢 creada: [$hu_id] $title"
    fi
    created=$((created+1))
  else
    if (( DRY )); then
      echo "🔵 [dry-run] actualizaría cuerpo de #$existing ($hu_id)"
    else
      gh issue edit "$existing" --repo "$REPO" \
        --title "[$hu_id] $title" \
        --body-file "$body_file" >/dev/null
      echo "🔵 actualizada #$existing: [$hu_id] $title"
    fi
    updated=$((updated+1))
  fi
  rm -f "$body_file"
done

echo ""
echo "📊 Resumen: $total HU(s) detectadas · $created nueva(s) · $updated actualizada(s)"
(( DRY )) && echo "(modo dry-run: no se aplicó ningún cambio)"
exit 0
