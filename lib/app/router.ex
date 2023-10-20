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
    case conn.params do
      %{"url" => nil} ->
        send_resp(conn, 400, "Missing 'url' parameter")

      # has tactic
      %{"url" => source_url, "tactic" => tactic} ->
        atom = String.to_atom(tactic)

        destination_url =
          if Function.def?(App.Redirect.Shorteners, atom, 1) do
            apply(App.Redirect.Shorteners, atom, [])
          else
            send_resp(conn, 400, "Invalid shortener tactic")
          end

      # default
      %{"url" => source_url} ->
        %App.Redirect{}
        |> App.Redirect.changeset(%{source: source_url, destination: App.Redirect.Shorteners.b62(source_url)})
        |> App.Repo.insert()

        send_resp(conn, 201, "Redirect added")

      _ ->
        send_resp(conn, 400, "Invalid parameters")
    end
  end
end
