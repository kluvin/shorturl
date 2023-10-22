defmodule App.Plugs.Shorteners do
  def b62() do
    # N = 62^5 = ~1B.
    b62_alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

    1..5
    |> Enum.map(fn _ -> Enum.random(b62_alphabet) end)
    |> List.to_string()
  end

  def bankid() do
    # N = 100^2 = 10k
    adjectives = [
      "Stor",
      "Liten",
      "Vakker",
      "Stygg",
      "Rask",
      "Langsom",
      "Smart",
      "Dum",
      "Lykkelig",
      "Trist",
      "Modig",
      "Feig",
      "Vennlig",
      "Frodig",
      "Sterk",
      "Svak",
      "Aktiv",
      "Lat",
      "Høy",
      "Lav",
      "Rik",
      "Fattig",
      "Ung",
      "Gammel",
      "Kreativ",
      "Uoriginal",
      "Spennende",
      "Kjedelig",
      "Søt",
      "Sur",
      "Kald",
      "Varm",
      "Morsom",
      "Alvorlig",
      "Flittig",
      "Sløv",
      "Dyktig",
      "Udyktig",
      "Snill",
      "Slem",
      "Lys",
      "Mørk",
      "Tynn",
      "Tykk",
      "Enkel",
      "Komplisert",
      "Rund",
      "Firkantet",
      "Myk",
      "Hard",
      "Klar",
      "Uklar",
      "Tom",
      "Full",
      "Skarp",
      "Utydelig",
      "Glatt",
      "Ru",
      "Ren",
      "Skitten",
      "Tung",
      "Lett",
      "Våt",
      "Tørr",
      "Rask",
      "Treg",
      "Frisk",
      "Syk",
      "Pen",
      "Stygg",
      "Stille",
      "Høylytt",
      "Ensom",
      "Populær",
      "Ny",
      "Gammel",
      "Tidløs",
      "Modern",
      "Tradisjonell",
      "Lokal",
      "Global",
      "Ekte",
      "Falsk",
      "Sulten",
      "Mett",
      "Ren",
      "Uren",
      "Glatt",
      "Humpete",
      "Våken",
      "Trøtt",
      "Åpen",
      "Lukket",
      "Tett",
      "Løs",
      "Kort",
      "Lang",
      "Skarp",
      "Flat",
      "Fersk",
      "Støl",
      "Frisk",
      "Muggen",
      "Lykkelig",
      "Elendig",
      "Optimal",
      "Dårlig",
      "Første",
      "Siste",
      "Øverste",
      "Nederste",
      "Innenfor",
      "Utenfor",
      "Langt",
      "Kort",
      "Fjern",
      "Nær",
      "Lys",
      "Tung",
      "Tom",
      "Hel",
      "Delvis",
      "Fullstendig",
      "Ufullstendig",
      "Fleksibel",
      "Stiv",
      "Stor",
      "Liten"
    ]

    nouns = [
      "Hund",
      "Katt",
      "Bil",
      "Hus",
      "Tre",
      "Elv",
      "Fjell",
      "Sjø",
      "Bok",
      "Sko",
      "Data",
      "Hage",
      "Fugl",
      "Vind",
      "Stol",
      "Bord",
      "Lampe",
      "Dør",
      "Vindu",
      "Himmel",
      "Sol",
      "Måne",
      "Stjerne",
      "Hav",
      "Strand",
      "By",
      "Landsby",
      "Skog",
      "Ørken",
      "Snø",
      "Regn",
      "Sommer",
      "Vinter",
      "Høst",
      "Vår",
      "Klokke",
      "Telefon",
      "Datamaskin",
      "TV",
      "Radio",
      "Kamera",
      "Tog",
      "Fly",
      "Båt",
      "Sykkel",
      "Mat",
      "Drikke",
      "Vann",
      "Melk",
      "Brød",
      "Ost",
      "Frukt",
      "Grønnsak",
      "Kjøtt",
      "Sukker",
      "Salt",
      "Pepper",
      "Krydder",
      "Blomst",
      "Gress",
      "Rot",
      "Blad",
      "Gren",
      "Fugl",
      "Fisk",
      "Flue",
      "Insekt",
      "Menneske",
      "Barn",
      "Voksen",
      "Lærer",
      "Student",
      "Leger",
      "Sykepleier",
      "Advokat",
      "Politi",
      "Brannmann",
      "Kokk",
      "Mekaniker",
      "Kunstner",
      "Musiker",
      "Sanger",
      "Skuespiller",
      "Idrettsutøver",
      "Spill",
      "Lek",
      "Sport",
      "Musikk",
      "Kunst",
      "Film",
      "Teater",
      "Bok",
      "Magasin",
      "Avis",
      "Penn",
      "Blyant",
      "Tusj",
      "Farge",
      "Lyd",
      "Bilde"
    ]

    "#{Enum.random(adjectives)}-#{Enum.random(nouns)}"
  end
end


defmodule App.Plugs.RedirectPlug do
  # We could compute this from the Shorteners module.
  @allowed_tactics %{
    b62: &App.Plugs.Shorteners.b62/0,
    bankid: &App.Plugs.Shorteners.bankid/0
  }
  @allowed_tactics_keys Map.keys(@allowed_tactics) |> Enum.map(&Atom.to_string/1)

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case validate_params(conn.params) do
      {:ok, params} -> handle_redirect(conn, params)
      {:error, error_msg} -> send_resp(conn, 400, error_msg)
    end
  end

  # explicit tactic
  defp validate_params(%{"url" => _, "tactic" => tactic} = params)
    when tactic in @allowed_tactics_keys, do: {:ok, params}

  # explicit tactic, missing
  defp validate_params(%{"url" => _, "tactic" => tactic} = params)
    when tactic not in @allowed_tactics_keys, do: {:error, "Invalid tactic"}


  # default tactic
  defp validate_params(%{"url" => _} = params), do: {:ok, params}

  defp validate_params(_), do: {:error, "Invalid parameters"}

  defp handle_redirect(conn, params) do
    destination =
      case params["tactic"] do
        nil -> App.Plugs.Shorteners.b62
        # at this point we are sure the tactic exists
        # but this approach feels volatile
        tactic -> @allowed_tactics[String.to_atom(tactic)].()
      end

    %App.Schemas.Redirect{}
    |> App.Schemas.Redirect.changeset(%{
      source: params["url"],
      destination: destination
    })
    |> App.Repo.insert()

    send_resp(conn, 201, destination)
  end
end
