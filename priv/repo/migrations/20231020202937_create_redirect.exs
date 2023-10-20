defmodule App.Repo.Migrations.CreateRedirect do
  use Ecto.Migration

  def change do
    create table(:redirect) do
      add :source, :string
      add :destination, :string

      timestamps()
    end
  end
end
