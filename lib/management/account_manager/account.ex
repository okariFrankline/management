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
  alias Management.{Types, Repo}

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field(:email, :string, unique: true)
    field(:account_type, :string)
    # confirmed at indicates the date and time that the account was activated
    # it will be used to ensure that the account has been activated as it is set to nil when
    # the account has not been created.
    field(:confirmed_at, :naive_datetime, default: nil)
    field(:is_active, :boolean, default: false)
    field(:is_suspended, :boolean, default: false)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps()
  end

  @doc false
  @spec changeset(t() | Types.ecto(), map()) :: Types.ecto()
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :email,
      :account_type,
      :password,
      :password_confirmation
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
      :account_type,
      :password_confirmation
    ])
    |> validate_required([:account_type])
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
      :password,
      :password_confirmation
    ])
    |> Utils.validate_password()
    |> Utils.hash_password()
  end

  @doc false
  @spec confrim_changeset(t()) :: Ecto.Changeset.t()
  def confrim_changeset(account) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    account
    |> change(%{
      confrimed_at: now,
      is_active: true
    })
  end

  # implemente the bamboo formatter for the account
  defimpl Bamboo.Formatter do
    def format_email_address(%Account{email: email} = account, _opts) do
      # get the account owner
      account_owner =
        account
        |> Utils.account_owner_query()
        |> elem(1)
        |> select([owner], %{
          first_name: owner.first_name,
          last_name: owner.last_name
        })
        |> Repo.one()

      full_name = "#{account.last_name} #{account.first_name}"

      {full_name, email}
    end
  end
end
