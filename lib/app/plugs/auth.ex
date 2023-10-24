# kindly borrowed
# https://rosettacode.org/wiki/Caesar_cipher
# Obviously, use something better, argon2-elixir seems OK
# but now the process is relatively transparent, which can be a good.
# Amsuingly, rot13 is an involution, so decryption is trivial
# I'm not going to salt, but that's a thing, too

defmodule App.Plugs.AuthPlug do
  use Plug.Builder
  import Plug.Conn

  plug :auth

  defp auth(conn, _opts) do
    with {email, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
      {:ok, _user} <- get_user(email, pass) do
        conn
    else
      _ -> conn |> Plug.BasicAuth.request_basic_auth() |>  halt()
    end
  end

  defp get_user(email, password) do
    case App.Repo.get_by(App.Schemas.User, email: email) do
      nil ->
        {:error, "User not found"}

      user ->
        if Plug.Crypto.secure_compare(App.Auth.Caesar.encode(password), user.password) do
          {:ok, user}
        else
          {:error, "Incorrect password"}
        end
    end
  end
end


defmodule App.Auth.Caesar do
  @key 13
  def encode(text) do
    map = Map.new |> set_map(?a..?z, @key) |> set_map(?A..?Z, @key)
    String.graphemes(text) |> Enum.map_join(fn c -> Map.get(map, c, c) end)
  end

  defp set_map(map, range, @key) do
    org = Enum.map(range, &List.to_string [&1])
    {a, b} = Enum.split(org, @key)
    Enum.zip(org, b ++ a) |> Enum.into(map)
  end
end
