import Config

config :logger, :console, level: :debug,
  compile_time_purge_matching: [
    [ level_lower_than: :debug ]
  ]
