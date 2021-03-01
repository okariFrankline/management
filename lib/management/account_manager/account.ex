defmodule Management.AccountManager.Account do
  @moduledoc """
  An account represents all the details needed to authenticate and authorize the users in the platform
  There are two types of users:
    1. Management Account => These represents users that own their own writing accounts and will use the platform
      for posting jobs and managing their writers.
    2. Writer Account => These are the writers for whom account owners invite into their accounts so they can
      write for them
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__.Utils
  alias Management.Types

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string, unique: true
    field :account_type, :string, default: "Management Account"
    # confirmed at indicates the date and time that the account was activated
    # it will be used to ensure that the account has been activated as it is set to nil when
    # the account has not been created.
    field :confirmed_at, :utc_datetime, default: nil
    field :is_active, :boolean, default: false
    field :is_suspended, :boolean, default: false
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  @spec changeset(t() | Types.ecto(), map()) :: Types.ecto()
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :email,
      :account_type,
      :password
    ])
  end

  @doc false
  @spec creation_changeset(t() | Types.ecto(), map()) :: Types.ecto()
  def creation_changeset(account, attrs) do
    account
    |> change(attrs)
    |> cast(attrs, [
      :email,
      :password,
      :account_type
    ])
    |> Utils.validate_email()
    |> Utils.validate_password()
    |> Utils.hash_password()
  end

  @doc false
  @spec password_changeset(t() | Types.ecto(), map()) :: Types.ecto()
  def password_changeset(account, attrs) do
    account
    |> change(attrs)
    |> cast(attrs, [
      :password
    ])
    |> Utils.validate_password()
  end
end
