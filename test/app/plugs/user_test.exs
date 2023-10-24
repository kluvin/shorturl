defmodule App.Plugs.UserPlugTest do
  import Ecto.Query
  use ExUnit.Case, async: true
  use Plug.Test

  setup do
    # Reset state per run.
    App.Repo.delete_all(App.Schemas.Redirect)
    App.Repo.delete_all(App.Schemas.User)
    {:ok, %{}}
  end

  alias App.Router
  @opts Router.init([])

  test "creates user" do
    conn = conn(:post, "/api/user/new",
      Jason.encode!(%{
        "email" => "alfred@nobel.se",
        "password" => "avgebtylpreva"
      }))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 201

    query = from u in App.Schemas.User,
      select: u,
      where: u.email == "alfred@nobel.se"

    assert App.Repo.exists?(query)
  end
end
