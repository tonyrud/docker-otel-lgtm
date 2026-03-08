# Use the official Elixir image with Erlang/OTP
FROM elixir:1.18-alpine AS build

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    git \
    postgresql-client

# Set the working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# -------------------------------
# Dev stage
# -------------------------------

FROM build AS dev

ENV MIX_ENV=dev

# Copy mix files first for better caching
COPY mix.exs mix.lock ./

# Install dependencies (this layer will be cached unless mix files change)
RUN mix deps.get && mix deps.compile

# Copy config files
COPY config/config.exs config/${MIX_ENV}.exs config/

# Copy static assets
COPY priv priv

# Copy application source code (this will invalidate cache when app code changes)
COPY lib lib

# Compile the application
RUN mix compile

# Set environment
ENV PHX_SERVER=true

# Expose the port
EXPOSE 4000

# Start the Phoenix server
CMD ["mix", "phx.server"]
