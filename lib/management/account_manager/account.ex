defmodule Management.AccountManager.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :account_role, :string
    field :account_type, :string
    field :confirmed_at, :utc_datetime
    field :email, :string
    field :is_active, :boolean, default: false
    field :is_suspended, :boolean, default: false
    field :password_hash, :string
    field :subscription_end_date, :utc_datetime
    field :subscription_start_date, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :password_hash, :account_type, :is_active, :is_suspended, :confirmed_at, :password_hash, :account_role, :subscription_start_date, :subscription_end_date])
    |> validate_required([:email, :password_hash, :account_type, :is_active, :is_suspended, :confirmed_at, :password_hash, :account_role, :subscription_start_date, :subscription_end_date])
  end
end
