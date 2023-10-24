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
    conn = App.Plugs.AuthPlug.call(conn, [])
    unless conn.halted do
      App.Plugs.RedirectPlug.call(conn, [])
    else
      conn
    end
  end

  post "/api/user/new" do
    conn |>
    App.Plugs.UserPlug.call([])
  end

  get "/:destination" do
    conn |>
    App.Plugs.RedirectDispatchPlug.call([])  end

end
