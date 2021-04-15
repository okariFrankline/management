defmodule Management.AccountManager.Account.Utils do
  @moduledoc false
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Management.WriterManager.WriterProfile
  alias Management.OwnerManager.OwnerProfile
  alias Management.AccountManager.Account
  alias Management.Types

  @spec validate_email(Types.ecto()) :: Types.ecto()
  def validate_email(changeset) do
    if changeset.valid? do
      changeset
      |> validate_required(
        [
          :email
        ],
        message: "Email Address is required to create a new account."
      )
      |> validate_format(
        :email,
        ~r/^[^\s]+@[^\s]+$/,
        message: "Email must have the @ sign and no spaces."
      )
      |> validate_length(
        :email,
        max: 160
      )
      # unsafe validate unique allows for fast feedback to the user.
      # however, since it is unsafe, it should be used with unique constraint as failure to do so may lead
      # to race conditions.
      |> unsafe_validate_unique(:email, Management.Repo)
      |> unique_constraint(
        :email,
        message: "The email entered is already in use."
      )
    else
      changeset
    end
  end

  @spec validate_password(Types.ecto()) :: Types.ecto()
  def validate_password(%Ecto.Changeset{} = changeset) do
    if changeset.valid? do
      changeset
      |> validate_required(
        [
          :password,
          :password_confirmation
        ],
        message: "New Password and Password confirmation are required."
      )
      |> validate_length(
        :password,
        min: 8,
        max: 100,
        message: "Password must be at least 8 characters long."
      )
      |> validate_confirmation(
        :password,
        required: true,
        message: "Passwords entered do not match."
      )
    else
      changeset
    end
  end

  @spec hash_password(Types.ecto()) :: Types.ecto()
  def hash_password(changeset) do
    if changeset.valid? do
      password = changeset |> get_change(:password)

      changeset
      |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
      |> delete_change(:password_confirmation)
    else
      changeset
    end
  end

  @doc """
  Returns the query for getting the account owner for a given account

  ## Example
     iex> account_owner_query(account)
     {:ok, %Ecto.Query{}}
  """
  @spec account_owner_query(Account.t()) :: {:ok, Ecto.Query.t()}
  def account_owner_query(%Account{account_type: account_type, id: id}) do
    query =
      case account_type do
        "Management Account" ->
          from(
            owner in OwnerProfile,
            where: owner.account_id == ^id
          )

        "Writer Account" ->
          from(
            owner in WriterProfile,
            where: owner.account_id == ^id
          )
      end

    {:ok, query}
  end
end
