defmodule App.Plugs.RedirectPlugTest do
  import Ecto.Query
  use ExUnit.Case, async: true
  use Plug.Test

  @sample_url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  setup do
    # Reset state per run.
    App.Repo.delete_all(App.Schemas.Redirect)
    App.Repo.delete_all(App.Schemas.User)
    # we need a user for tests
    alfred = %App.Schemas.User{
      email: "alfred@nobel.se",
      password: "avgebtylpreva",
    }
    App.Repo.insert!(alfred)
    # quick cheat, we stored the password as hashed db entry above
    # the one that will be sent through BA will be the plaintext
    alfred = %{alfred | password: "nitroglycerin"}
    {:ok, alfred: alfred}
  end

  defp to_basic(u) do
    "Basic #{Base.encode64("#{u.email}:#{u.password}")}"
  end

  alias App.Router
  @opts Router.init([])


  test "returns an error for missing 'url' parameter", %{alfred: alfred} do
    conn = conn(:post, "/api/redirect/new", Jason.encode!(%{}))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", to_basic(alfred))
      |> Router.call(@opts)


    assert conn.status == 400
    assert conn.resp_body == "Invalid parameters"
  end

  test "disallows unauthorized access" do
    body = Jason.encode!(%{"url" => @sample_url})
    conn = conn(:post, "/api/redirect/new", Jason.encode!(%{"url" => @sample_url}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 401
  end


  test "inserts with default tactic", %{alfred: alfred} do
    body = Jason.encode!(%{"url" => @sample_url})
    conn = conn(:post, "/api/redirect/new", body)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", to_basic(alfred))
      |> Router.call(@opts)

    assert conn.status == 201

    query = from r in App.Schemas.Redirect,
      select: r.source,
      where: r.source == @sample_url

    assert App.Repo.exists?(query)
  end

  test "inserts with explicit tactic", %{alfred: alfred} do
    body = Jason.encode!(%{
      "url" => @sample_url,
      "tactic" => "bankid"
    })
    conn = conn(:post, "/api/redirect/new", body)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", to_basic(alfred))
      |> Router.call(@opts)

    assert conn.status == 201

    query = from r in App.Schemas.Redirect,
      select: r.source,
      where: r.source == @sample_url

    assert App.Repo.exists?(query)
  end

  test "handles missing explicit tactic", %{alfred: alfred} do
    body = Jason.encode!(%{
      "url" => @sample_url,
      "tactic" => "blockchain"
    })
    conn = conn(:post, "/api/redirect/new", body)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", to_basic(alfred))
      |> Router.call(@opts)

    assert conn.status == 400
    assert conn.resp_body == "Invalid tactic"
  end
end
