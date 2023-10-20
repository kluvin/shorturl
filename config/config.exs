import Config

config :app,
  ecto_repos: [App.Repo]

config :app, App.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "priv/db.sqlite3"
