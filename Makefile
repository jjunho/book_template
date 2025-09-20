PANDOC := pandoc
OUTPUT_DIR := output
FORMATS := pdf epub html
DEFAULT_DIR := config
OUTPUT_FILES := $(OUTPUT_DIR)/__PROJECT_SLUG__.pdf $(OUTPUT_DIR)/__PROJECT_SLUG__.epub $(OUTPUT_DIR)/__PROJECT_SLUG__.html
DATE := $(shell date +%Y-%m-%d)

.PHONY: all $(FORMATS) clean check-pandoc ensure-output-dir

all: $(FORMATS)

check-pandoc:
	@command -v $(PANDOC) >/dev/null 2>&1 || { echo "Erro: pandoc não encontrado no PATH. Instale o pandoc antes de continuar." >&2; exit 1; }

ensure-output-dir:
	@mkdir -p $(OUTPUT_DIR)

$(FORMATS): check-pandoc ensure-output-dir
	@echo "[pandoc] Gerando '$@'..."
	@$(PANDOC) --defaults=$(DEFAULT_DIR)/$@.yml --metadata=date="$(DATE)"
	@echo "[pandoc] Formato '$@' gerado em $(OUTPUT_DIR)."

clean:
	@rm -f $(OUTPUT_FILES)
	@echo "Saídas removidas de $(OUTPUT_DIR)."
