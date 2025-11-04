# === CONFIG ===
DBT_LOCAL_BASE_DIR := ./data/projects
DBT_BASE_DIR       := /data/projects
SERVICE            := duckdb
DC                 := docker compose
SHELL              := bash

.PHONY: dbtInit dbtBuild dbtRun dbtTest dbtDocs dbtShow

# --- util: choisir un projet (renvoie le NOM du dossier) ---
define choose_project
$$( \
  projects=$$(find $(DBT_LOCAL_BASE_DIR) -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort); \
  if [ -z "$$projects" ]; then \
    echo "❌ Aucun projet trouvé dans $(DBT_LOCAL_BASE_DIR)"; exit 1; \
  fi; \
  if ! command -v gum >/dev/null 2>&1; then \
    echo "⚠️  gum n'est pas installé, sélection du premier projet par défaut."; \
    echo "$$projects" | head -n 1; \
  else \
    echo "$$projects" | gum choose --height 12 --cursor-prefix "👉 "; \
  fi \
)
endef

# --- init: crée un nouveau projet dbt dans /data/projects ---
dbtInit: ## Create a new dbt project (prompt for name)
	@read -p "Nom du projet dbt : " PROJECT_NAME; \
	if [ -z "$$PROJECT_NAME" ]; then echo "❌ Nom invalide"; exit 1; fi; \
	$(DC) exec -T $(SERVICE) bash -lc "mkdir -p $(DBT_BASE_DIR) && cd $(DBT_BASE_DIR) && dbt init $$PROJECT_NAME"

# --- build: dbt build sur le projet choisi ---
dbtBuild: ## Run `dbt build` in a chosen project
	@proj_name=$(call choose_project); \
	[ -z "$$proj_name" ] && echo "❌ Aucun projet sélectionné" && exit 1; \
	echo "🚀 dbt build → $$proj_name"; \
	$(DC) exec -T $(SERVICE) \
	  env PROJ_NAME="$$proj_name" DBT_BASE_DIR="$(DBT_BASE_DIR)" \
	  bash -lc 'set -e; cd "$$DBT_BASE_DIR/$$PROJ_NAME" && dbt build --project-dir .'

dbtDeps: ## Run `dbt deps` in a chosen project
	@proj_name=$(call choose_project); \
	[ -z "$$proj_name" ] && echo "❌ Aucun projet sélectionné" && exit 1; \
	echo "📦 dbt deps → $$proj_name"; \
	$(DC) exec -T $(SERVICE) \
	  env PROJ_NAME="$$proj_name" DBT_BASE_DIR="$(DBT_BASE_DIR)" \
	  bash -lc 'set -e; cd "$$DBT_BASE_DIR/$$PROJ_NAME" && dbt deps --project-dir .'


# --- run: dbt run (sans tests) ---
dbtRun: ## Run `dbt run` in a chosen project
	@proj_name=$(call choose_project); \
	[ -z "$$proj_name" ] && echo "❌ Aucun projet sélectionné" && exit 1; \
	echo "🏃 dbt run → $$proj_name"; \
	$(DC) exec -T $(SERVICE) \
	  env PROJ_NAME="$$proj_name" DBT_BASE_DIR="$(DBT_BASE_DIR)" \
	  bash -lc 'set -e; cd "$$DBT_BASE_DIR/$$PROJ_NAME" && dbt run --project-dir .'

# --- test: dbt test ---
dbtTest: ## Run `dbt test` in a chosen project
	@proj_name=$(call choose_project); \
	[ -z "$$proj_name" ] && echo "❌ Aucun projet sélectionné" && exit 1; \
	echo "🧪 dbt test → $$proj_name"; \
	$(DC) exec -T $(SERVICE) bash -lc "cd '$(DBT_BASE_DIR)/'\"$$proj_name\"' && dbt test --project-dir . --profiles-dir ."

# --- docs: generate + serve (port 8080 dans le container) ---
dbtDocs: ## Generate & serve docs (opens a server in container)
	@proj_name=$(call choose_project); \
	[ -z "$$proj_name" ] && echo "❌ Aucun projet sélectionné" && exit 1; \
	echo "📚 dbt docs → $$proj_name"; \
	$(DC) exec -T $(SERVICE) bash -lc "cd '$(DBT_BASE_DIR)/'\"$$proj_name\"' && dbt docs generate --project-dir . --profiles-dir . && dbt docs serve --project-dir . --profiles-dir . --no-browser --port 8080"

# --- show: aperçu d'un modèle (prompt nom modèle + limit) ---
dbtShow: ## Preview a model with `dbt show`
	@proj_name=$(call choose_project); \
	[ -z "$$proj_name" ] && echo "❌ Aucun projet sélectionné" && exit 1; \
	read -p "Nom du modèle (ex: my_model) : " MODEL; \
	read -p "LIMIT (default 10) : " LIM; LIM=$${LIM:-10}; \
	echo "👀 dbt show $$MODEL (limit $$LIM) → $$proj_name"; \
	$(DC) exec -T $(SERVICE) bash -lc "cd '$(DBT_BASE_DIR)/'\"$$proj_name\"' && dbt show --project-dir . --profiles-dir . --select \"$$MODEL\" --limit \"$$LIM\""
