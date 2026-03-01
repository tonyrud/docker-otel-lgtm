#!/bin/bash

# Exit on any error
set -euo pipefail

log_message() {
  # Define ANSI escape codes for colors and reset
  RED="\033[31m"
  GREEN="\033[32m"
  BLUE="\033[34m"
  NC="\033[0m" # No Color - resets to default
  local message=$@
  printf "\n${GREEN}%s${NC}\n\n" "$message"
}

# Set environment variables for local development
export OTEL_SERVICE_NAME="dice-server-phx"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
# Enable JSON logging for OpenTelemetry collector and dev console
export JSON_LOGGER="true"

# Check if Docker is running
#Open Docker, only if is not running
if (! docker stats --no-stream &>/dev/null ); then
  # On Mac OS this would be the terminal command to launch Docker
  open /Applications/Docker.app
 #Wait until Docker daemon is running and has completed initialisation
while (! docker stats --no-stream &>/dev/null ); do
  # Docker takes a few seconds to initialize
  log_message "Waiting for Docker to launch..."
  sleep 1
done
fi

log_message "Starting PostgreSQL database using Docker..."
docker compose up db --remove-orphans -d

# Check for otel stuff
if (! docker ps --filter "name=lgtm" --filter "status=running" --quiet | grep -q .); then
  log_message "OTLP Collector container is not running. Please start from the root directory: ./run-lgtm.sh"
fi

# Get dependencies and compile
log_message "Setting up the Elixir Phoenix application..."
mix setup


log_message "Starting Phoenix server with OpenTelemetry..."
log_message "Server will be available at: http://localhost:4000"
log_message "Dice roll: http://localhost:4000/rolldice"
log_message "Custom dice: http://localhost:4000/api/dice/20"

# Start the Phoenix server
iex -S mix phx.server
