defmodule Management.Repo.Migrations.CreateOwners do
  use Ecto.Migration

  def change do
    create table(:owner_profiles, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:full_name, :string)
      add(:subscription_package, :string, null: false, default: "Free Trial Account")
      add(:sub_start_date, :naive_datetime)
      add(:sub_expiry_date, :naive_datetime)
      add(:writer_limit, :integer, default: 3, null: false)
      add(:profile_image, :string)
      add :account_code, :binary
      add(:phone_number, :string, unique: true)
      add(:sub_is_active, :boolean, default: false, null: false)
      add(:account_id, references(:accounts, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end

    create(index(:owner_profiles, [:account_id]))
    create(unique_index(:owner_profiles, [:phone_number]))
    create unique_index(:owner_profiles, [:account_code])
  end
end
