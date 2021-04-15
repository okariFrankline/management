defmodule Management.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:email, :string, unique: true, null: false)
      add(:password_hash, :string, null: false)
      add(:account_type, :string, null: false, default: "Management Account")
      add(:is_active, :boolean, default: false, null: false)
      add(:is_suspended, :boolean, default: false, null: false)
      add(:confirmed_at, :naive_datetime, null: true, default: nil)

      timestamps()
    end

    create(unique_index(:accounts, [:email]))

    # create the token table
    create table(:tokens) do
      add(:token, :binary, unique: true, null: false)
      add(:context, :string, null: false)
      add(:sent_to, :string)

      add(:account_id, references(:accounts, on_delete: :delete_all, type: :binary_id),
        null: false
      )

      timestamps(updated_at: false)
    end

    # ensuring the cobination of a given context and token unique nsures that a given user cannot have more tha one token
    # generated for a given context
    create(unique_index(:tokens, [:context, :token]))
  end
end
