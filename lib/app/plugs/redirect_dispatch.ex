defmodule App.Plugs.RedirectDispatchPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.path_params do
      %{"destination" => destination} ->
        case App.Repo.get_by(App.Schemas.Redirect, destination: destination) do
          nil -> send_resp(conn, 404, "Not found")
          redirect ->
            conn
            |> put_resp_header("location", redirect.source)
            |> send_resp(301, "Redirecting")
        end
      _ -> send_resp(conn, 400, "Invalid parameters")
    end
  end
end
