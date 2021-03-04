defmodule Management.AccountManager.Token do
  @moduledoc """
  Holds tokens that will be used to resetting password, accepting invitations, and switching between
  account for writers
  """
  use Ecto.Schema
  import Ecto.Query, warn: false
  alias Management.AccountManager.Account

  # types
  @type t :: %__MODULE__{}

  # attributes
  @hash_algorithm :sha256
  @rand_size 32
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 1a
  @change_email_validity_in_days 7

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tokens" do
    # the actual token generated for the purposes of
    field(:token, :binary)
    # context explains why the session was generated.
    field(:context, :string)
    # the account's email where the session was sent to
    field(:sent_to, :string)

    # a single user can have a number of tokens
    belongs_to(:account, Account, type: :binary_id)

    timestamps(updated_at: false)
  end

  @doc """
    Builds a hash token for a given context.
  """
  @spec build_hashed_token(Account.t(), binary()) :: {binary(), t()}
  def build_hashed_token(%Account{id: id, email: email} = _account, context)
      when is_binary(context) and is_binary(email) do
    token =
      @rand_size
      |> :crypto.strong_rand_bytes()

    hashed_token =
      @hash_algorithm
      |> :crypto.hash(token)

    {
      Base.url_encode64(token, padding: false),
      %__MODULE__{token: hashed_token, context: context, account_id: id}
    }
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.
  In order to determine if a token is valid, the function is provided the token and
  the context(reason why the token was generated)

  The query returns the account found by the token.
  """
  @spec verify_email_token_query(binary(), binary()) :: {:ok, Ecto.Query.t()} | :error
  def verify_email_token_query(token, context) do
    case token |> Base.url_decode64(padding: false) do
      {:ok, decoded_token} ->
        # the days for how long the token was valid for
        days =
          context
          |> days_for_context()

        # query for the token and the
        token_query =
          @hash_algorithm
          |> :crypto.hash(decoded_token)
          |> token_and_context_query(context)

        # query for the account
        query =
          from(
            token in token_query,
            join: account in assoc(token, :account),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == account.email,
            select: account
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user token record.
  """
  @spec verify_change_email_token_query(binary(), binary()) :: {:ok, Ecto.Query.t()} | :error
  def verify_change_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from(
            token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Gets tokens for the given user for the given contexts.

  If the contexts is an atom :all, then it returna all the contexts for the given account
  If the contexts is a list, it returns all contexts that are within those contexts

  Returns a query for all the contexts
  """
  @spec account_contexts_query(Account.t(), :all) :: Ecto.Query.t()
  def account_contexts_query(%Account{id: id}, :all) do
    from(
      token in __MODULE__,
      where: token.account_id == ^id
    )
  end

  @spec account_contexts_query(Account.t(), list()) :: Ecto.Query.t()
  def account_contexts_query(%Account{id: id}, [_ | _] = contexts) do
    from(
      token in __MODULE__,
      where: token.account_id == ^id and token.context in ^contexts
    )
  end

  @doc """
  Returns a query that represents a token and its given context
  """
  @spec token_and_context_query(binary(), binary()) :: Ecto.Query.t()
  def token_and_context_query(token, context) do
    from(
      __MODULE__,
      where: [token: ^token, context: ^context]
    )
  end

  defp days_for_context("Account Confirmation"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days
end
