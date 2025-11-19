# Docker Setup for COOL Compiler (Apple Silicon Mac)

This setup allows you to run the COOL compiler and tools in a Docker container while editing files on your Mac with your preferred IDE.

## Prerequisites

- Docker Desktop for Mac (with Apple Silicon support)
- Make (comes pre-installed on macOS)

## Quick Start

### 1. Build the Docker Image

```bash
make build
```

This builds a Docker image with all necessary dependencies, including 32-bit library support for the COOL compiler binaries.

### 2. Open an Interactive Shell

```bash
make shell
```

This opens a bash shell inside the container where you can run COOL commands directly:

```bash
# Inside the container
coolc examples/hello_world.cl
spim examples/hello_world.s
```

### 3. Compile COOL Files

From your Mac terminal (outside the container):

```bash
make compile FILE=examples/hello_world.cl
```

## Common Commands

All these commands are run from your Mac terminal:

```bash
# Build the Docker image
make build

# Open interactive shell
make shell

# Compile a COOL file
make compile FILE=path/to/file.cl

# Run lexer only
make lex FILE=path/to/file.cl

# Run parser only
make parse FILE=path/to/file.cl

# Run semantic analyzer only
make semant FILE=path/to/file.cl

# Run custom command
make run CMD="cd assignments/PA2 && make"

# Stop containers
make stop

# Clean up Docker resources
make clean
```

## Working on Assignments

### Option 1: Edit on Mac, Build in Docker

1. Edit your assignment files using your IDE on macOS
2. When ready to build/test, run:

```bash
make run CMD="cd assignments/PA2 && make"
```

### Option 2: Interactive Development

1. Open a shell in the container:

```bash
make shell
```

2. Navigate to your assignment:

```bash
cd assignments/PA2
```

3. Build and test:

```bash
make
./mycoolc test.cl
```

All changes to files are reflected immediately on both your Mac and in the container (via volume mounting).

## How It Works

- **Dockerfile**: Sets up Ubuntu 22.04 with x86_64 architecture (required for 32-bit COOL binaries on Apple Silicon)
- **docker-compose.yml**: Mounts your project directory at `/cool` in the container
- **Makefile**: Provides convenient shortcuts for common operations
- **Volume Mounting**: Your entire project directory is mounted, so file changes are instant and bidirectional

## Troubleshooting

### "exec format error" when running coolc

This means the platform wasn't set correctly. Rebuild with:

```bash
make clean
make build
```

### Port conflicts or container name already in use

Stop and remove existing containers:

```bash
make stop
make clean
```

### Changes not reflecting in container

Make sure you're working in subdirectories of this project. The volume mount only covers this directory and below.

## Tips

- Keep the container running in one terminal with `make shell` and edit files in your IDE
- Use `make run CMD="..."` for one-off commands without entering the shell
- The COOL binaries (coolc, lexer, parser, semant, spim) are all in your PATH inside the container
- All standard build tools (gcc, g++, make, flex, bison) are available in the container
