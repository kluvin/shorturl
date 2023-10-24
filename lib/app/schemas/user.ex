defmodule App.Schemas.User do
  use Ecto.Schema

  schema "user" do
    field :email, :string
    field :password, :string

    has_many :redirect, App.Schemas.Redirect
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:email, :password])
    |> Ecto.Changeset.validate_required([:email, :password])
    |> Ecto.Changeset.validate_format(:email, ~r/@/)
    |> Ecto.Changeset.unique_constraint(:email, name: "user_email_index")
    |> Ecto.Changeset.put_change(:password, App.Auth.Caesar.encode(params.password))
  end
end
