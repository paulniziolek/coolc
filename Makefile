.PHONY: build shell run clean test help

# Build the Docker image
build:
	docker-compose build

# Start an interactive shell in the container
shell:
	docker-compose run --rm coolc /bin/bash

# Run a specific coolc command (usage: make run CMD="coolc myfile.cl")
run:
	docker-compose run --rm coolc $(CMD)

# Clean up Docker resources
clean:
	docker-compose down -v
	docker-compose rm -f

# Stop any running containers
stop:
	docker-compose down

# Run coolc compiler on a file (usage: make compile FILE=myfile.cl)
compile:
	docker-compose run --rm coolc coolc $(FILE)

# Run lexer on a file (usage: make lex FILE=myfile.cl)
lex:
	docker-compose run --rm coolc lexer $(FILE)

# Run parser on a file (usage: make parse FILE=myfile.cl)
parse:
	docker-compose run --rm coolc parser $(FILE)

# Run semantic analyzer on a file (usage: make semant FILE=myfile.cl)
semant:
	docker-compose run --rm coolc semant $(FILE)

# Help command
help:
	@echo "Available commands:"
	@echo "  make build          - Build the Docker image"
	@echo "  make shell          - Open an interactive shell in the container"
	@echo "  make run CMD=\"...\"  - Run a custom command in the container"
	@echo "  make compile FILE=  - Compile a COOL file"
	@echo "  make lex FILE=      - Run lexer on a COOL file"
	@echo "  make parse FILE=    - Run parser on a COOL file"
	@echo "  make semant FILE=   - Run semantic analyzer on a COOL file"
	@echo "  make stop           - Stop running containers"
	@echo "  make clean          - Clean up Docker resources"
	@echo ""
	@echo "Examples:"
	@echo "  make compile FILE=examples/hello_world.cl"
	@echo "  make run CMD=\"cd assignments/PA2 && make\""
