defmodule Management.WriterManager.API do
  @moduledoc """
  Provides api functions for the the writer manager
  """
  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Management.AccountManager.{Account, Token}
  alias Management.{WriterManager, Repo}
  alias Management.WriterManager.WriterProfile

  @type not_found :: {:error, :account_not_found}

  @doc """
  Updates the personal information about the account.

  ## Example
      iex> update_personal_informartion(%Account{} = account, valid_params)
      {:ok, %WriterProfile{}}

      iex update_personal_information(%Account{} = account, invalid_params)
      {:error, %Ecto.Changeset{}}
  """
  @spec update_personal_information(Account.t(), %{binary() => binary()}) ::
          {:ok, WriterProfile.t()} | {:error, Ecto.Changeset.t()} | not_found()
  def update_personal_information(%Account{} = account, params) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    with {:ok, %WriterProfile{} = _writer_profiel} = result <-
           WriterManager.update_personal_information(profile, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Sets the subscription package that the curren account is for.

  Reciieves the type of subscription packages as the second arguement and
  defualt to "Free Trial Account"

  ## Example
      iex> set_subscription_pacakge(%Account{} = account)
      {:ok, %WriterProfile{}}

      iex> set_subscription_package(%Account{} = account, :standard)
      {:ok, %WriterProfile}

      iex set_sbscription_package(%Account{} = account)
      {:error, %Ecto.Changeset{}}
  """
  @spec set_subscription_package(Account.t(), atom()) ::
          {:ok, WriterProfile.t()} | {:error, Ecto.Changeset.t()} | not_found()
  def set_subscription_package(
        %Account{} = account,
        subscription_type \\ :free_trial_account
      ) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    subscription_package =
      case subscription_type do
        :free_trial_account ->
          "Free Trial Account"

        :standard_account ->
          "Standard Account"

        :pro_account ->
          "Pro Account"
      end

    with {:ok, %WriterProfile{} = _work_pprofile} = result <-
           WriterManager.update_subscription_information(profile, %{
             subscription_package: subscription_package
           }),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Cancels the subscription for a the writers account upon expiry

  ## Examples
      iex> cancel_subscription(%Account{} = active_account)
      {:ok, %WriterProfile{}}

      iex> cancel_subscription(%Account{} = expired_subscription_account)
      {:error, :already_cancelled}

      iex> cancel_subscription(%Account{} = error_occured)
      {:error, :server_error}
  """
  @spec cancel_subscription(Account.t()) ::
          {:ok, WriterProfile.t()}
          | {:error, :server_error}
          | {:error, :already_cancelled}
          | not_found()
  def cancel_subscription(%Account{} = account) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    if not profile.subscription_active do
      {:error, :already_cancelled}
    else
      profile
      |> Ecto.Changeset.change(%{
        subscription_active: false
      })
      |> Repo.update()
      |> case do
        {:ok, %WriterProfile{} = _profile} = result ->
          result

        {:error, %Ecto.Changeset{} = _changeset} ->
          {:error, :server_error}
      end
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Accepts an invitation to join a writing account's team
  Checks the token for which the account belongs to and adds the account's id to
  it's list of accounts

  ## Example
      iex> accept_join_invitation(%Account{} = invitation_sender_account, valid_token)
      {:ok, %WriterProfile{}}

      iex> accept_join_invitation(%Account{} = invitation_sender_account, invalid_token)
      {:error, reason}
  """
  @spec accept_join_invitation(Account.t(), binary()) ::
          {:ok, WriterProfile.t()} | {:error, atom()} | not_found()
  def accept_join_invitation(%Account{id: id} = account, token) do
    with {:ok, account_query} <-
           Token.verify_email_token_query(token, "#{id}::Writer Invitation"),
         %Account{} = ^account <- Repo.one!(account_query) do
      %WriterProfile{} = profile = get_profile_for_account!(account)

      changeset =
        Ecto.Changeset.change(profile)
        |> Ecto.Changeset.put_change(:team_memberships, [:id | profile.team_memberships])

      Multi.new()
      |> Multi.update(:profile, changeset)
      |> Multi.delete_all(
        :tokens,
        Token.account_contexts_query(account, ["#{id}::Writer Invitation"])
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{profile: profile}} ->
          {:ok, profile}

        {:error, :profile, _, _} ->
          {:error, :server_error}
      end
    else
      :error ->
        {:error, :invalid_token}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Rejects an invitation for joining an account owner's team

  ## Examples
      iex> reject_join_invitation(%Account{} = invitation_senders_account, token)
      :ok

      iex> reject_join_invitation(%Account{} = invitation_senders_account, token)
      :error
  """
  @spec reject_join_invitation(Account.t(), binary()) :: :ok | :error | not_found()
  def reject_join_invitation(%Account{id: id} = account, token) do
    with {:ok, account_query} <-
           Token.verify_email_token_query(token, "#{id}::Writer Invitation"),
         %Account{} = ^account <- Repo.one!(account_query) do
      Multi.new()
      |> Multi.delete_all(
        :tokens,
        Token.account_contexts_query(account, ["#{id}::Writer Invitation"])
      )
      |> Repo.transaction()
      |> case do
        {:ok, _results} ->
          :ok

        {:error, _, _, _} ->
          :error
      end
    else
      :error ->
        {:error, :invalid_token}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Removes the current writer from an account owners team memberships

  ## Examples
      iex> leave_team(id_for_which_writer_belongs_to)
      {:ok, %WriterProfile{}}

      iex> leave_team(id_for_which_writer_belongs_to)
      {:error, reason}
  """
  @spec leave_team(Account.t(), binary()) ::
          {:ok, WriterProfile.t()} | {:error, atom()} | not_found()
  def leave_team(%Account{} = account, team_id) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    teams =
      profile.team_memberships
      |> List.delete(team_id)

    profile
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:team_memberships, teams)
    |> Repo.update()
    |> case do
      {:ok, %WriterProfile{} = _profile} = result ->
        result

      {:error, _changeset} ->
        {:error, :server_error}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @spec get_profile_for_account!(Account.t()) :: WriterProfile.t() | Ecto.NoResultsError
  defp get_profile_for_account!(%Account{id: id} = _account) do
    from(
      profile in WriterProfile,
      where: profile.account_id == ^id
    )
    |> Repo.one!()
  end
end
