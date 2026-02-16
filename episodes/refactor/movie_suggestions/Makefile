# Makefile for Dev Container Management

CONTAINER_NAME=movie_suggestions_dev
SERVICE_NAME=movie_suggestions_dev

up:
	docker compose up --build -d
	docker compose ps

down:
	docker compose down

conn:
	docker exec -it $$(docker compose ps -q $(SERVICE_NAME)) bash

test:
	docker exec -it $$(docker compose ps -q $(SERVICE_NAME)) rspec

run:
	docker exec -it $$(docker compose ps -q $(SERVICE_NAME)) bash -c "$(wordlist 2,999,$(MAKECMDGOALS))"

.PHONY: up down conn run
