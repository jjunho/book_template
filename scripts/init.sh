#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LICENSE_DIR="$REPO_ROOT/templates/licenses"

declare -A LICENSE_MAP=(
  ["cc-by-4.0"]="cc-by-4.0.txt"
  ["cc0-1.0"]="cc0-1.0.txt"
  ["mit"]="mit.txt"
  ["all-rights-reserved"]="all-rights-reserved.txt"
)

usage() {
  cat <<'USAGE'
Uso: ./scripts/init.sh -n "Título" -a "Autora" \
       [-s slug] [-t "Subtítulo"] [-y 2025] [-r "Direitos"] \
       [-L cc-by-4.0|cc0-1.0|mit|all-rights-reserved]

Opções:
  -n  Título do livro (obrigatório)
  -a  Nome da autora/autor (obrigatório)
  -s  Slug do projeto (opcional, será derivado do título se omitido)
  -t  Subtítulo (opcional)
  -y  Ano de publicação (opcional, padrão: ano atual)
  -r  Texto de direitos autorais (opcional, sobrescreve o padrão da licença)
  -L  Tipo de licença (padrão: cc-by-4.0)
  -h  Mostra esta ajuda

Licenças disponíveis:
  cc-by-4.0            Creative Commons Attribution 4.0 International
  cc0-1.0              Creative Commons Zero 1.0 Universal (domínio público)
  mit                  MIT License
  all-rights-reserved  Todos os direitos reservados
USAGE
}

sanitize_slug() {
  local input="$1"
  local sanitized
  if command -v iconv >/dev/null 2>&1; then
    sanitized=$(printf '%s' "$input" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$input")
  else
    sanitized="$input"
  fi
  sanitized=$(printf '%s' "$sanitized" | tr '[:upper:]' '[:lower:]')
  sanitized=$(printf '%s' "$sanitized" | sed 's/[^a-z0-9]/-/g')
  sanitized=$(printf '%s' "$sanitized" | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
  printf '%s' "$sanitized"
}

replace_placeholder() {
  local file="$1"
  local placeholder="$2"
  local value="$3"
  local escaped

  if [[ ! -f "$file" ]]; then
    echo "Aviso: arquivo '$file' não encontrado; ignorando $placeholder." >&2
    return
  fi

  escaped=$(printf '%s' "$value" | sed -e 's/[\\&/]/\\&/g')

  if sed --version >/dev/null 2>&1; then
    sed -i "s/$placeholder/$escaped/g" "$file"
  else
    sed -i '' "s/$placeholder/$escaped/g" "$file"
  fi
}

apply_license() {
  local license="$1"
  local title="$2"
  local author="$3"
  local year="$4"

  local template_file="$LICENSE_DIR/${LICENSE_MAP[$license]}"
  if [[ ! -f "$template_file" ]]; then
    echo "Erro: arquivo de licença '$template_file' não encontrado." >&2
    exit 1
  fi

  cp "$template_file" "$REPO_ROOT/LICENSE"

  replace_placeholder "$REPO_ROOT/LICENSE" "__PROJECT_TITLE__" "$title"
  replace_placeholder "$REPO_ROOT/LICENSE" "__PROJECT_AUTHOR__" "$author"
  replace_placeholder "$REPO_ROOT/LICENSE" "__PROJECT_YEAR__" "$year"
}

main() {
  local title=""
  local author=""
  local slug=""
  local subtitle=""
  local year="$(date +%Y)"
  local rights=""
  local license="cc-by-4.0"
  local license_label=""
  local license_short=""

  while getopts "n:a:s:t:y:r:L:h" opt; do
    case "$opt" in
      n) title="$OPTARG" ;;
      a) author="$OPTARG" ;;
      s) slug="$OPTARG" ;;
      t) subtitle="$OPTARG" ;;
      y) year="$OPTARG" ;;
      r) rights="$OPTARG" ;;
      L) license="$OPTARG" ;;
      h)
        usage
        exit 0
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done

  if [[ -z "$title" || -z "$author" ]]; then
    echo "Erro: título (-n) e autor (-a) são obrigatórios." >&2
    usage
    exit 1
  fi

  if [[ -z ${LICENSE_MAP[$license]+_} ]]; then
    echo "Erro: licença '$license' inválida." >&2
    usage
    exit 1
  fi

  if [[ -z "$slug" ]]; then
    slug=$(sanitize_slug "$title")
    if [[ -z "$slug" ]]; then
      echo "Erro: não foi possível derivar um slug a partir do título. Informe via -s." >&2
      exit 1
    fi
  else
    slug=$(sanitize_slug "$slug")
  fi

  if [[ -z "$subtitle" ]]; then
    subtitle="Subtítulo opcional"
  fi

  case "$license" in
    cc-by-4.0)
      license_label="Creative Commons Attribution 4.0 International"
      license_short="CC BY 4.0"
      [[ -z "$rights" ]] && rights="© ${year}, ${author}. Conteúdo licenciado sob CC BY 4.0."
      ;;
    cc0-1.0)
      license_label="Creative Commons Zero 1.0 Universal"
      license_short="CC0 1.0"
      [[ -z "$rights" ]] && rights="Conteúdo dedicado ao domínio público sob CC0 1.0."
      ;;
    mit)
      license_label="MIT License"
      license_short="MIT"
      [[ -z "$rights" ]] && rights="© ${year}, ${author}. Disponibilizado sob a licença MIT."
      ;;
    all-rights-reserved)
      license_label="Todos os direitos reservados"
      license_short="Todos os direitos reservados"
      [[ -z "$rights" ]] && rights="© ${year}, ${author}. Todos os direitos reservados."
      ;;
  esac

  declare -A files=(
    ["README.md"]=1
    ["CONTRIBUTING.md"]=1
    ["config/metadata.yaml"]=1
    ["book.md"]=1
    ["config/pdf.yml"]=1
    ["config/epub.yml"]=1
    ["config/html.yml"]=1
    ["Makefile"]=1
    [".github/workflows/build.yml"]=1
  )

  for file in "${!files[@]}"; do
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_TITLE__" "$title"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_AUTHOR__" "$author"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_SUBTITLE__" "$subtitle"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_RIGHTS__" "$rights"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_SLUG__" "$slug"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_LICENSE__" "$license_label"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_LICENSE_SHORT__" "$license_short"
    replace_placeholder "$REPO_ROOT/$file" "__PROJECT_YEAR__" "$year"
  done

  apply_license "$license" "$title" "$author" "$year"

  echo "Template configurado com sucesso."
  echo "Resumo:"
  echo "  Título: $title"
  echo "  Subtítulo: $subtitle"
  echo "  Autoria: $author"
  echo "  Ano: $year"
  echo "  Slug: $slug"
  echo "  Licença: $license_label"
  echo "  Direitos: $rights"

  echo "\nRevise os arquivos atualizados, ajuste 'config/pandoc.yml' se necessário e comece a escrever seu livro!"
}

main "$@"
