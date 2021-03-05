defmodule Management.Repo.Migrations.CreateWriterProfiles do
  use Ecto.Migration

  def change do
    create table(:writer_profiles, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:full_name, :string)
      add(:gender, :string, null: false, default: "Female")
      add(:name_initials, :string, null: false, default: "SU")
      add(:suscription_package, :string, default: "Standard Account")
      add(:profile_image, :string)
      add(:sub_expiry_date, :naive_datetime)
      add(:sub_start_date, :naive_datetime)
      add(:sub_is_active, :boolean, default: true)

      add(:account_id, references(:accounts, on_delete: :delete_al, type: :binary_id))

      timestamps()
    end

    create(index(:writer_profiles, [:account_id]))
    create(index(:writer_profiles, [:sub_is_active]))
  end
end
