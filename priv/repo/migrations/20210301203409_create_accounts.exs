defmodule Management.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :password_hash, :string
      add :account_type, :string
      add :is_active, :boolean, default: false, null: false
      add :is_suspended, :boolean, default: false, null: false
      add :confirmed_at, :utc_datetime
      add :password_hash, :string
      add :account_role, :string
      add :subscription_start_date, :utc_datetime
      add :subscription_end_date, :utc_datetime

      timestamps()
    end

  end
end
