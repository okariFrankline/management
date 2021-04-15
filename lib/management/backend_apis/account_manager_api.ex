defmodule Management.AccountsManager.API do
  @moduledoc """
  Provides an API for managing an account
  """
  alias Ecto.Multi
  alias Management.{AccountManager, OwnerManager, WriterManager}
  alias Management.AccountManager.{Notifier, Account, Token}
  alias Management.{Repo, Authentication}

  @type reason :: binary()

  @doc """
  Creates a new account for a user, saves the verfication token and send the
  the user an email with the verification link
  """
  @spec create_account(map(), (binary -> binary)) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_account(params, confirmation_url_fun) when is_function(confirmation_url_fun, 1) do
    with {:ok, %Account{} = account} = result <- AccountManager.create_account(params),
         _profile <- create_profile(account) do
      {encoded_token, token} =
        account
        |> Token.build_hashed_token("Account Confirmation")

      Repo.insert!(token)
      # send the confirmation email
      Notifier.send_verification_email(account, confirmation_url_fun.(encoded_token))
      # return {:ok, account}
      result
    else
      {:error, _changeset} = error ->
        error
    end
  end

  @doc """
  Confirms a given account
  """
  @spec confirm_account(Account.t(), map()) ::
          {:ok, Account.t()} | {:error, reason} | {:error, Ecto.Changeset.t()}
  def confirm_account(%Account{} = account, %{"token" => token}) do
    case account.confirmed_at do
      # the account has not been confirmed
      nil ->
        with {:ok, account_query} <-
               Token.verify_email_token_query(token, "Account Confirmation"),
             %Account{} = account <- Repo.one(account_query) do
          Multi.new()
          |> Multi.update(
            :account,
            Account.confirm_changeset(account)
          )
          |> Multi.delete_all(
            :tokens,
            Token.account_contexts_query(account, ["Account Confirmation"])
          )
          |> Repo.transaction()
          |> case do
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
  def request_password_recovery(%Account{} = account, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, token} =
      account
      |> Token.build_hashed_token("Password Recovery")

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
  @spec reset_password(map()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()} | {:error, :invalid_token}
  def reset_password(%{"token" => token, "password_confirmation" => p_conf, "password" => pass}) do
    with {:ok, account_query} <- Token.verify_email_token_query(token, "Password Recovery"),
         %Account{} = account <- account_query |> Repo.one() do
      password_changeset =
        account
        |> Account.password_changeset(%{
          password_confirmation: p_conf,
          password: pass
        })
        |> elem(1)

      Multi.new()
      |> Multi.update(:account, password_changeset)
      |> Multi.delete(
        :tokens,
        Token.account_contexts_query(account, ["Password Recovery"])
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{account: account}} ->
          {:ok, account}

        {:error, :account, changeset, _} ->
          {:error, changeset}
      end
    else
      :error ->
        {:error, :invalid_token}
    end
  end

  @doc """
  Changes the password for the account.
  Receives the account, and the params that hold the new password

  ## Example
     iex> change_password(%Account{} = account, %{"password" => pass, "password_confirmation" => pass_conf})
     {:ok, %Account{}}

     iex> change_password(%Account{} = account, %{"password" => pass, "password_confirmation" => pass_conf})
     {:error, %Ecto.Changeset{}}
  """
  @spec change_password(Account.t(), %{binary() => binary()}) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def change_password(%Account{} = account, params) do
    changeset =
      account
      |> Account.validate_current_password(params)

    if changeset.valid? do
      case Account.password_changeset(changeset, params) do
        # changeset is valid
        {:ok, changeset} ->
          Multi.new()
          |> Multi.update(:account, changeset)
          |> Multi.delete_all(
            :tokens,
            Token.account_contexts_query(account, :all)
          )
          |> Repo.transaction()
          |> case do
            {:ok, %{account: %Account{} = account}} ->
              {:ok, account}

            {:error, :account, changeset, _} ->
              {:error, changeset}
          end

        # invalid changeset
        {:error, _changeset} = result ->
          result
      end
    else
      {:error, changeset}
    end
  end

  @doc """
  Login
  Login a user using their password and the ermail address

  ##Example
      iex> login_with_email_and_password(email, password)
      {:ok, %Account{}}

      iex> login_with_email_and_password(email, password)
      {:error, :invalid_credentials}
  """
  @spec login_with_email_and_password(binary(), binary()) ::
          {:ok, Account.t()} | {:error, :invalid_credentials}
  def login_with_email_and_password(email, password) do
    case AccountManager.get_account_by_email_and_password(email, password) do
      %Account{} = account ->
        # create a token
        {:ok, token, _claims} = Authentication.Guardian.encode_and_sign(account)

        {
          :ok,
          %{
            token: token,
            account: account
          }
        }

      false ->
        {:error, :invalid_credentials}
    end
  end

  @spec create_profile(Account.t()) :: Ecto.Schema.t()
  defp create_profile(%Account{account_type: account_type, id: id} = _account) do
    changeset =
      case account_type do
        "Writer Account" ->
          %WriterManager.WriterProfile{}
          |> Ecto.Changeset.change(%{
            account_id: id
          })

        "Management Account" ->
          %OwnerManager.OwnerProfile{}
          |> Ecto.Changeset.change(%{
            account_id: id
          })
      end

    Repo.insert!(changeset)
  end
end
