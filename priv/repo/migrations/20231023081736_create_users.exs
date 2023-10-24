defmodule App.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :email, :string, null: false
      add :password, :string, null: false
      timestamps()
    end

    create unique_index(:user, [:email])

    alter table(:redirect) do
      add :user_id, references(:user, on_delete: :nothing)
    end

    create index(:redirect, [:user_id])
  end
end
