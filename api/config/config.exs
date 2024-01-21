import Config

config :api, Api.Repo,
  database: "transcription_service_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true

config :api, ecto_repos: [Api.Repo]

config :api, Oban,
  repo: Api.Repo,
  queues: [
    transcribe: 1
  ]
