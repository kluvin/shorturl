defmodule App.Router do
  use Plug.Router
  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Hello, World!")
  end

  post "/api/redirect/new" do
    conn |>
    App.Plugs.RedirectPlug.call([])
  end
end
