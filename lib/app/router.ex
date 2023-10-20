defmodule Router do
  use Plug.Router
  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Hello, World!")
  end

  post "/api/redirect/new" do
    case Map.get(conn.params, "url") do
      nil ->
        send_resp(conn, 400, "Missing 'url' parameter")

      source_url ->
        destination_url = "example.com"

        %App.Redirect{}
        |> App.Redirect.new(%{source: source_url, destination: destination_url})
        |> App.Repo.insert()

        send_resp(conn, 201, "Redirect added")
    end
  end
end
