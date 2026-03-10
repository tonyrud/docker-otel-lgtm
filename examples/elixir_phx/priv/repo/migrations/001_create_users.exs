defmodule ElixirPhx.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    # Add some indexes for better query performance
    create index(:users, [:first_name])
    create index(:users, [:last_name])
    create index(:users, [:first_name, :last_name])
  end
end
