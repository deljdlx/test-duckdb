# load variables from .env file
# -include .env

SHELL := bash
DC := docker compose

WEB := $(shell cat .env | grep COMPOSE_PROJECT_NAME | sed s/COMPOSE_PROJECT_NAME=//)-web-1

.PHONY:


dbtInit: ## Create a new dbt project , prompt for name
	@echo "Please enter the name of the new dbt project:"
	@read PROJECT_NAME; \

# 	go to /data/projects in the duckdb container and run dbt init
	${DC} exec duckdb bash -c "cd /data/projects && dbt init $$PROJECT_NAME"

# 	$(DC) exec duckdb dbt init $$PROJECT_NAME
# 	@docker compose exec duckdb dbt init pro