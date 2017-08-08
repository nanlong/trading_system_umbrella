defmodule TradingSystem.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :nickname, :string
      add :password_hash, :string
      add :vip_expire, :naive_datetime

      timestamps()
    end

    create unique_index(:users, ["lower(email)"])
    create index(:users, [:vip_expire])
  end
end
