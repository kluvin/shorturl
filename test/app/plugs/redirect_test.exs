defmodule App.Plugs.RedirectPlugTest do
  import Ecto.Query
  use ExUnit.Case, async: true
  use Plug.Test

  # Reset state per run.
  App.Repo.delete_all(App.Schemas.Redirect)

  alias App.Router
  @opts Router.init([])


  test "returns an error for missing 'url' parameter" do
    conn = conn(:post, "/api/redirect/new", Jason.encode!(%{}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)


    assert conn.status == 400
    assert conn.resp_body == "Invalid parameters"
  end


  test "inserts with default tactic" do
    source = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    conn = conn(:post, "/api/redirect/new", Jason.encode!(%{"url" => source}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 201

    query = from r in App.Schemas.Redirect,
      select: r.source,
      where: r.source == ^source

    assert App.Repo.exists?(query)
  end

  test "inserts with explicit tactic" do
    source = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    conn = conn(:post, "/api/redirect/new", Jason.encode!(%{"url" => source, "tactic" => "bankid"}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 201

    query = from r in App.Schemas.Redirect,
      select: r.source,
      where: r.source == ^source

    assert App.Repo.exists?(query)
  end

  test "handles missing explicit tactic" do
    source = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    conn = conn(:post, "/api/redirect/new", Jason.encode!(%{"url" => source, "tactic" => "blockchain"}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 400
    assert conn.resp_body == "Invalid tactic"
  end
end
