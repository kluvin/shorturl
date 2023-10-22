defmodule App.Application do
  require Logger
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    App.Release.migrate()
    children = [
      App.Repo,
      {Plug.Cowboy, scheme: :http, plug: App.Router, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: App.Supervisor]
    Logger.info("Plug now running on localhost:4001")
    Supervisor.start_link(children, opts)
  end
end
