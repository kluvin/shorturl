defmodule App.Schemas.Redirect do
  use Ecto.Schema

  schema "redirect" do
    field :source, :string
    field :destination, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:source, :destination])
    |> Ecto.Changeset.validate_required([:source, :destination])
  end
end
