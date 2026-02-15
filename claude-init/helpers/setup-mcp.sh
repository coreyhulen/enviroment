#!/bin/bash
# Setup all MCP servers for Claude Code
# Can be run standalone or called from install.sh

set -e

# Colors
if [ -t 1 ]; then
    GREEN=$(printf '\033[32m')
    RED=$(printf '\033[31m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[36m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
else
    GREEN="" RED="" YELLOW="" BLUE="" BOLD="" RESET=""
fi

info()  { echo "${BLUE}$*${RESET}" >&2; }
warn()  { echo "${YELLOW}Warning: $*${RESET}" >&2; }
error() { echo "${RED}Error: $*${RESET}" >&2; }

# Unset CLAUDECODE so we can call claude from within a Claude Code session
unset CLAUDECODE

# Check if claude command exists
if ! command -v claude &> /dev/null; then
    error "Claude Code CLI not found. Please install Claude Code first."
    exit 1
fi

# Check if npm/npx is available
if ! command -v npx &> /dev/null; then
    error "npx not found. Please install Node.js first."
    exit 1
fi

# Check if uvx is available (needed for fetch-server)
if ! command -v uvx &> /dev/null; then
    warn "uvx not found. Install with 'brew install uv'. fetch-server will fail."
fi

info "Setting up Claude Code MCP servers..."
echo ""

SUCCEEDED=0
FAILED=0

add_mcp_server() {
    local name="$1"
    shift
    local description="$1"
    shift

    echo -n "${BOLD}  Adding ${name}${RESET} (${description})... "
    # Remove existing entry first to make this idempotent
    claude mcp remove "$name" -s user 2>/dev/null || true
    if claude mcp add "$name" -s user -- "$@" 2>/dev/null; then
        echo "${GREEN}done${RESET}"
        SUCCEEDED=$((SUCCEEDED + 1))
    else
        echo "${RED}failed${RESET}"
        FAILED=$((FAILED + 1))
    fi
}

# Sequential thinking - extended reasoning for complex problems
add_mcp_server "seq-server" "sequential thinking" \
    npx -y @modelcontextprotocol/server-sequential-thinking

# Gemini CLI - Google Gemini integration
add_mcp_server "gemini-cli" "Google Gemini" \
    gemini mcp

# OpenAI Codex - OpenAI Codex integration
add_mcp_server "codex-native" "OpenAI Codex" \
    codex mcp-server

# Fetch - HTTP fetch capabilities (Python-based, uses uvx)
add_mcp_server "fetch-server" "HTTP fetch" \
    uvx mcp-server-fetch

# Filesystem - file operations scoped to home directory
add_mcp_server "filesystem-server" "filesystem operations" \
    npx -y @modelcontextprotocol/server-filesystem "$HOME"

# Chrome DevTools - browser automation and debugging
add_mcp_server "chrome-devtools" "Chrome DevTools" \
    npx -y chrome-devtools-mcp

# Memory - persistent knowledge graph
add_mcp_server "memory" "knowledge graph memory" \
    npx -y @modelcontextprotocol/server-memory

# Postgres - PostgreSQL database access
add_mcp_server "postgres-server" "PostgreSQL" \
    npx -y @modelcontextprotocol/server-postgres

echo ""
info "MCP server setup complete: ${GREEN}${SUCCEEDED} succeeded${RESET}, ${RED}${FAILED} failed${RESET}"
