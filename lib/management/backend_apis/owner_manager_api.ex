defmodule Management.OwnerManager.API do
  @moduledoc """
  Provides API functions that interacts with Account Management accounts
  """
  import Ecto.Query, only: [from: 2]
  alias Management.{OwnerManager, Repo, AccountManager}
  alias Management.OwnerManager.{OwnerProfile, Notifier}
  alias Management.AccountManager.{Account, Token}

  @typep not_found :: {:error, :account_not_found}

  @doc """
  update account personal_information

  ## Example
      iex> update_owner_information(%Account{} = account, valid_params)
      {:ok, %OwnerProfile{}}

      iex> update_owner_information(%Account{} = account, invalid_params)
      {:error, %Ecto.Changeset{}}
  """
  @spec update_owner_information(Account.t(), %{binary() => binary()}) ::
          {:ok, OwnerProfile.t()} | {:error, Ecto.Changeset.t()} | not_found()
  def update_owner_information(%Account{} = account, params) do
    %OwnerProfile{} = profile = get_profile_for_account!(account)

    with {:ok, %OwnerProfile{} = _profile} = result <-
           OwnerManager.update_owner_profile_information(profile, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Updates the profile's subscription information

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
    %OwnerProfile{} = profile = get_profile_for_account!(account)

    subscription_package = get_subscription_package(subscription_type)

    with {:ok, %OwnerProfile{} = _owner_pprofile} = result <-
           OwnerManager.update_subscription_information(profile, %{
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
          {:ok, OwnerProfile.t()}
          | {:error, :server_error}
          | {:error, :already_cancelled}
          | not_found()
  def cancel_subscription(%Account{} = account) do
    %OwnerProfile{} = profile = get_profile_for_account!(account)

    if not profile.subscription_active do
      {:error, :already_cancelled}
    else
      profile
      |> Ecto.Changeset.change(%{
        subscription_active: false
      })
      |> Repo.update()
      |> case do
        {:ok, %OwnerProfile{} = _profile} = result ->
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
  Sends an invitation to a writer to join his/account's team of writiers
  sends the link:
    "https://domain.com/writer_profiles/"

  ## Examples
      iex> send_join_invitation(%Account{} = sender_account, account_id_for_person_been_sent to)
      :ok

      iex> send_join_invitation(%Account{} = sender_account, account_id_for_person_been_sent to)
      :error
  """
  @spec send_join_invitation(Account.t(), binary(), (binary() -> binary())) ::
          :ok | :error | not_found()
  def send_join_invitation(%Account{} = account, recepient_account_id, sending_invitation_url_fn)
      when is_function(sending_invitation_url_fn, 1) do
    recepient_account =
      recepient_account_id
      |> AccountManager.get_account!()

    {encoded_token, _token} =
      account
      |> Token.build_hashed_token("Writer Invitation::#{recepient_account.id}")
      |> elem(1)
      |> Repo.insert!()

    # send email to the writer
    account
    |> Notifier.send_writer_join_invitation(
      recepient_account,
      sending_invitation_url_fn.(encoded_token)
    )
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Removes a team member from the account's team members

  ## Examples
      iex> remove_team_member(%Account{} = account, to_remove_id)
      {:ok, %OwnerProfile{}}

      iex> remove_team_member(%Account{} = account, to_remove_id)
      :error
  """
  @spec remove_team_member(Account.t(), binary()) ::
          {:ok, OwnerProfile.t()} | {:error, :not_team_member} | :error | not_found()
  def remove_team_member(%Account{} = account, to_remove_id) do
    %OwnerProfile{} = profile = get_profile_for_account!(account)

    teams =
      profile.team_members
      |> List.delete(to_remove_id)

    if teams != profile.team_members do
      profile
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:team_members, teams)
      |> Repo.update()
      |> case do
        {:ok, %OwnerProfile{} = _profile} = result ->
          # remove the account from the writer's list of team memberships
          {:ok, _} =
            account.id
            |> remove_account_from_writer_profile_team_memberships(to_remove_id)

          # return the result
          result

        {:error, %Ecto.Changeset{} = _changeset} ->
          :error
      end
    else
      {:error, :not_team_member}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  # gets the owner profile from an account
  @spec get_profile_for_account!(Account.t()) :: OwnerProfile.t() | Ecto.NoResultsError
  defp get_profile_for_account!(%Account{id: id} = _account) do
    from(
      profile in OwnerProfile,
      where: profile.account_id == ^id
    )
    |> Repo.one!()
  end

  @spec get_subscription_package(atom()) :: binary()
  defp get_subscription_package(subscription_type) do
    case subscription_type do
      :free_trial_account ->
        "Free Trial Account"

      :standard_account ->
        "Standard Account"

      :pro_account ->
        "Pro Account"

      :enterprise_account ->
        "Enterprise Account"
    end
  end

  @spec remove_account_from_writer_profile_team_memberships(binary(), binary()) :: {:ok, pid()}
  defp remove_account_from_writer_profile_team_memberships(account_owner_id, to_remove_id) do
    Supervisor.start_link(
      [
        Supervisor.child_spec(
          {Task,
           fn ->
             profile =
               from(
                 profile in Management.WriterManager.WriterProfile,
                 where: profile.account_id == ^to_remove_id
               )
               |> Repo.one!()

             team_memberships =
               profile.team_memberships
               |> List.delete(account_owner_id)

             profile
             |> Ecto.Changeset.change()
             |> Ecto.Changeset.put_change(:team_memberships, team_memberships)
             |> Repo.update()
           end},
          restart: :transient
        )
      ],
      strategy: :one_for_one
    )
  end
end
