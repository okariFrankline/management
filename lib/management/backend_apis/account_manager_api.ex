defmodule Management.AccountsManager.API do
  @moduledoc """
  Provides an API for managing an account
  """
  alias Ecto.Multi
  alias Management.AccountManager
  alias Management.AccountManager.{Notifier, Account, Token}
  alias Management.Repo

  @type reason :: binary()

  @doc """
  Creates a new account for a user, saves the verfication token and send the
  the user an email with the verification link
  """
  @spec create_account(map(), (binary -> binary)) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_account(params, confirmation_url_fun) when is_function(confirmation_url_fun, 1) do
    case AccountManager.create_account(params) do
      {:ok, %Account{} = account} = result ->
        {encoded_token, token} =
          account
          |> Token.build_hashed_token("Account Confirmation", account.email)

        Repo.insert!(token)
        # send the confirmation email
        Notifier.send_verification_email(account, confirmation_url_fun.(encoded_token))
        # return {:ok, account}
        result

      {:error, _changeset} = error ->
        error
    end
  end

  @doc """
  Confirms a given account
  """
  @spec confirm_account() :: {:ok, Account.t()} | {:error, reason} | {:error, Ecto.Changeset.t()}
  def confirm_account(%Account{} = account, %{"token" => token}) do
    case account.confirmed_at do
      # the account has not been confirmed
      nil ->
        with {:ok, account_query} <- Token.verify_email_token_query(account, "Account Confirmation"),
        {%Account{} = account} <- Repo.one(query) do
          confirmation_multi =
            Ecto.Multi.new()
            |> Ecto.Multi.update(
              :account,
              Account.confirm_changeset(accout)
            )
            |> Ecto.Multi.delete_all(
              :tokens,
              Token.account_context_query(account, ["Account Confirmation"])
            )
          # run the multi in a tranasction
          case Repo.transaction(confirmation_mutli) do
            {:ok, %{account: account}} ->
              {:ok, account}

            {:error, :account, changeset, _} ->
              {:error, changeset}
          end

        else
          # the token is invalid
          :error ->
            {:error, :invalid_token}
        end

      # the account had already been confirmed
      _ ->
        {:error, :already_confirmed}
    end
  end

  @doc """
  Initiates a password recovery process.

  This is called if the user has forgotten their password and they are locked out of their
  account

  It creates a unique token that will be used to create the url for which the user will
  be asked to change their password
  """
  @spec request_password_recovery(Account.t(), (binary() -> binary())) :: :ok
  def request_password_recovery(Account{} = account, reset_password_url_fn) when is_function(reset_password_fun, 1) do
    {encoded_token, token} ->
      account
      |> Token.build_hashed_token("Password Recovery", account.email)

    Repo.insert!(token)
    # send an email notification to the account owner.
    Notifier.send_password_recovery_email(
      account,
      reset_password_url_fun.(encoded_token)
    )
    :ok
  end

  @doc """
  Resets the password of the account
  """
  @spec reset_password() :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()} | {:error, :invalid_token}
  def reset_password(%{"token" => token} = params) do
    with {:ok, account_query} <- Token.verify_email_token_query(token, "Password Recovery"),
      %Account{} = account <- account_query |> Repo.one() do
         Multi.new()
         |> Multi.update(
           :account,
           Map.drop(params, "token") |> Account.password_changeset()
         )
         |> Multi.delete(
           :tokens,
           Token.account_context_query(account, "Password Recovery")
         )
         |> Repo.transaction()
         |> case  do
          {:ok, %{account: account}}  ->
            {:ok, account}

          {:error, :account, changeset, _} ->
            {:error, changeset}
         end
      else
        :error ->
          {:error, :invalid_token}
      end
  end
end
