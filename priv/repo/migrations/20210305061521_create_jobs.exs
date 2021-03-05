defmodule Management.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: true
      add :status, :string, default: "Pending"
      add :is_submitted, :boolean, default: false, null: false
      add :deadline, :naive_datetime
      add :contains_corrections, :boolean, default: false, null: false
      add :payment_status, :string
      add :done_by, :string
      add :visibility, :map
      add :subject, :string
      add :attachments, {:array, :string}
      add :writer_id, :binary_id
      add :owner_profile_id, references(:owner_profile, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:jobs, [:owner_profile_id])
    create index(:jobs, [:writer_id])
    create index(:jobs, [:status])
  end
end
