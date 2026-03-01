import Config

# Do not print debug messages in production
config :logger, level: :info

# JSON logging for production (logger_json v7.x - console formatter)
config :logger, :console,
  format: {LoggerJSON.Formatters.Basic, :format},
  metadata: :all

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
