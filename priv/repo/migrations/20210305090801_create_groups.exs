defmodule Management.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_name, :string
      add :description, :text
      add :members, {:array, :binary_id}
      add :is_active, :boolean, default: false, null: false
      add :owner_profile_id, references(:owner_profiles, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:groups, [:owner_profile_id])
  end
end
