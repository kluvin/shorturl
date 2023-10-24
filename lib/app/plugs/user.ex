defmodule App.Plugs.UserPlug do
  import Plug.Conn

  def init(opts), do: opts
  def call(conn, _opts) do
    # {email, password} = conn.params
    %App.Schemas.User{}
    |> App.Schemas.User.changeset(%{
      email: conn.params["email"],
      password: conn.params["password"]
    })
    |> App.Repo.insert()

    send_resp(conn, 201, _opts)
  end
end
