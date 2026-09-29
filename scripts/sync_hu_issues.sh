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
#   | **Título**  | ... |  → título de la issue
#   | **Tipo**    | ... |  → label del tipo (lowercase, auto-creada)
#   | **Sprint**  | S1  |  → milestone cuyo título empiece por "S1"
#   | **Asignado**| user|  → assignee (si la fila existe)
#   | **Estado**  | [X] |  → columna del Project board (decisión R5)
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
  echo "$out" | sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//'
}

resolve_milestone() {
  local token="$1"
  [[ -z "$token" || "$token" == "—" ]] && return 0
  gh api "repos/$REPO/milestones" --paginate 2>/dev/null \
    --jq ".[] | select(.title | startswith(\"$token\")) | .title" | head -1 || true
}

# --- Project board (decisión R5: columna desde Estado del HU) ---
PROJECT_OWNER="JavierDevCol"
PROJECT_NUM=1
PROJECT_ID="PVT_kwHOBVcan84BhWZd"
STATUS_FIELD_ID="PVTSSF_lAHOBVcan84BhWZdzhgScJM"

board_status() {            # Estado del HU → columna del board
  case "$1" in
    *"[X]"*)              echo "🎬 Done" ;;
    *"[E]"*|*Ejecut*)     echo "🔨 En curso (WIP=1)" ;;
    *"[R]"*|*"[A]"*)      echo "✅ Ready (DoR)" ;;
    *)                    echo "📥 Backlog" ;;
  esac
}

board_opt_id() {            # ids de las opciones del campo Status
  case "$1" in
    "📥 Backlog")           echo "a3b70322" ;;
    "✅ Ready (DoR)")       echo "42440c41" ;;
    "🔨 En curso (WIP=1)")  echo "44408d06" ;;
    "👀 Review")            echo "1e2cef80" ;;
    "🎬 Done")              echo "84216f8c" ;;
  esac
}

sync_board() {              # best-effort: jamás rompe el sync, pero SIEMPRE avisa
  local num="$1" status="$2" item opt url
  url="https://github.com/$REPO/issues/$num"
  item="${ITEM_BY_URL[$url]:-}"
  if [[ -z "$item" ]]; then
    item="$(gh project item-add "$PROJECT_NUM" --owner "$PROJECT_OWNER" \
      --url "$url" --format json --jq '.id' 2>&1)" \
      || { echo "⚠️ board: falló item-add $url — ${item:-sin detalle} (¿secret PROJECTS_TOKEN con scope 'project'?)" >&2; return 0; }
    item="${item##*$'\n'}"
  fi
  opt="$(board_opt_id "$status")"
  if [[ -n "$opt" ]]; then
    gh project item-edit --id "$item" --project-id "$PROJECT_ID" \
      --field-id "$STATUS_FIELD_ID" --single-select-option-id "$opt" >/dev/null \
      || echo "⚠️ board: falló mover #$num a \"$status\"" >&2
  fi
  return 0
}

# Índice local de issues existentes (evita N llamadas API)
declare -A ISSUE_BY_PREFIX
while IFS=$'\t' read -r num title; do
  [[ -z "${num:-}" ]] && continue
  key="${title%%] *}"          # "[HU-IAM-01"
  ISSUE_BY_PREFIX["${key}]"]="$num"
done < <(gh issue list --repo "$REPO" --state all --limit 1000 \
           --json number,title --jq '.[] | "\(.number)\t\(.title)"' 2>/dev/null)

# Índice de items del board (evita re-agregar issues ya presentes)
declare -A ITEM_BY_URL
while IFS=$'\t' read -r iid iurl; do
  [[ -n "${iid:-}" && -n "${iurl:-}" ]] && ITEM_BY_URL["$iurl"]="$iid"
done < <(gh project item-list "$PROJECT_NUM" --owner "$PROJECT_OWNER" --limit 1000 \
           --format json --jq '.items[] | "\(.id)\t\(.content.url // empty)"' 2>/dev/null || true)

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
  tipo="$(row_val "Tipo" "$f")"
  tipo_lc="$(echo "$tipo" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
  asignado="$(row_val "Asignado" "$f")"
  labels="hu${tipo_lc:+,$tipo_lc}"
  board_col="$(board_status "$(row_val "Estado" "$f")")"
  # label del tipo: idempotente, solo si no es dry-run
  [[ -n "$tipo_lc" && $DRY -eq 0 ]] && gh label create "$tipo_lc" --repo "$REPO" \
    --color 5319E7 --description "Tipo de HU (auto-sync)" -f >/dev/null 2>&1 || true

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
    if [[ -f "${hu_dir}Tracking.md" ]]; then
      echo ""
      echo "<details><summary>📈 Tracking (progreso y evidencia)</summary>"
      echo ""
      cat "${hu_dir}Tracking.md"
      echo ""
      echo "</details>"
    fi
  } > "$body_file"

  existing="${ISSUE_BY_PREFIX["[${hu_id}]"]:-}"

  if [[ -z "$existing" ]]; then
    ms="$(resolve_milestone "$sprint")"
    ms_args=(); [[ -n "$ms" ]] && ms_args=(--milestone "$ms")
    as_args=(); [[ -n "$asignado" ]] && as_args=(--assignee "$asignado")
    if (( DRY )); then
      echo "🟢 [dry-run] crearía issue: [$hu_id] $title | labels: $labels${ms:+ | milestone: $ms}${asignado:+ | assignee: $asignado} | board: $board_col"
    else
      url="$(gh issue create --repo "$REPO" \
        --title "[$hu_id] $title" \
        --body-file "$body_file" \
        --label "$labels" "${ms_args[@]}" "${as_args[@]}")"
      echo "🟢 creada: [$hu_id] $title (#${url##*/})"
      sync_board "${url##*/}" "$board_col"
    fi
    created=$((created+1))
  else
    ms="$(resolve_milestone "$sprint")"
    if (( DRY )); then
      echo "🔵 [dry-run] actualizaría #$existing ($hu_id) | labels: $labels${ms:+ | milestone: $ms}${asignado:+ | assignee: $asignado} | board: $board_col"
    else
      edit_args=(--title "[$hu_id] $title" --body-file "$body_file" --add-label "$labels")
      [[ -n "$ms" ]] && edit_args+=(--milestone "$ms")
      [[ -n "$asignado" ]] && edit_args+=(--add-assignee "$asignado")
      gh issue edit "$existing" --repo "$REPO" "${edit_args[@]}" >/dev/null
      sync_board "$existing" "$board_col"
      echo "🔵 actualizada #$existing: $hu_id $title"
    fi
    updated=$((updated+1))
  fi
  rm -f "$body_file"
done

echo ""
echo "📊 Resumen: $total HU(s) detectadas · $created nueva(s) · $updated actualizada(s)"
(( DRY )) && echo "(modo dry-run: no se aplicó ningún cambio)"
exit 0
