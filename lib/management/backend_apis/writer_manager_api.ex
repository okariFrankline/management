defmodule Management.WriterManager.API do
  @moduledoc """
  Provides api functions for the the writer manager
  """
  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Management.AccountManager.{Account, Token}
  alias Management.WriterManager.WriterProfile
  alias Management.OwnerManager.OwnerProfile
  alias Management.{WriterManager, Repo}
  alias Management.GroupManager.Group
  alias Management.API.Utils

  @type not_found :: {:error, :account_not_found}
  @typep reason :: binary()

  @doc """
  Updates the personal information about the account.

  ## Example
      iex> update_personal_informartion(%Account{} = account, valid_params)
      {:ok, %WriterProfile{}}

      iex update_personal_information(%Account{} = account, invalid_params)
      {:error, %Ecto.Changeset{}}
  """
  @spec update_personal_information(Account.t(), %{binary() => binary()}) ::
          {:ok, WriterProfile.t()} | {:error, Ecto.Changeset.t()} | {:error, reason()}
  def update_personal_information(%Account{} = account, params) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    with {:ok, %WriterProfile{} = _writer_profiel} = result <-
           WriterManager.update_personal_information(profile, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writer Profile Account does not exist."}
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
          {:ok, WriterProfile.t()} | {:error, Ecto.Changeset.t()} | {:error, reason()}
  def set_subscription_package(
        %Account{} = account,
        subscription_type \\ :free_trial_account
      ) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    subscription_package = get_subscription_package(subscription_type)

    with {:ok, %WriterProfile{} = _work_pprofile} = result <-
           WriterManager.update_subscription_information(profile, %{
             subscription_package: subscription_package
           }),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writer Profile Account does not exist."}
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
          | {:error, reason()}
  def cancel_subscription(%Account{} = account) do
    %WriterProfile{} = profile = get_profile_for_account!(account)

    if not profile.subscription_active do
      {:error, "Error! Subscription already cancelled"}
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
          {:error, "Error! Subscription could not cancelled."}
      end
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writer Profile Account does not exist."}
  end

  @doc """
  Accepts an invitation to join a writing account's team
  Checks the token for which the account belongs to and adds the account's id to
  it's list of accounts

  ## Example
      iex> accept_join_invitation(%Account{} = invitation_receiver_account, valid_token)
      {:ok, %WriterProfile{}}

      iex> accept_join_invitation(%Account{} = invitation_receiver_account, invalid_token)
      {:error, reason}
  """
  @spec accept_join_invitation(Account.t(), binary()) ::
          {:ok, WriterProfile.t()} | {:error, reason()}
  def accept_join_invitation(%Account{id: id} = account, token) do
    with {:ok, account_query} <-
           Token.verify_email_token_query(token, "Writer Invitation::#{id}"),
         %Account{id: sender_account_id} = _sender_account <- Repo.one!(account_query) do
      # task for getting the sender's profile
      account_owner_profile_task =
        Task.async(fn ->
          from(
            profile in OwnerProfile,
            where: profile.account_id == ^sender_account_id
          )
          |> Repo.one!()
        end)

      {account, account_profile} =
        from(
          acc in account_query,
          join: profile in OwnerProfile,
          where: profile.account_id == ^acc.id,
          preload:
        )

      # add the
      %WriterProfile{} =
        profile =
        account
        |> get_profile_for_account!()

      changeset =
        Ecto.Changeset.change(profile)
        |> Ecto.Changeset.put_change(:team_memberships, [:id | profile.team_memberships])

      owner_profile = Task.await(account_owner_profile_task)

      owner_profile_changeset =
        owner_profile
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:team_members[profile.id | owner_profile.team_members])

      Multi.new()
      |> Multi.update(:writer_profile, changeset)
      |> Multi.update(:owner_profile, owner_profile_changeset)
      |> Multi.delete_all(
        :tokens,
        Token.account_contexts_query(account, ["Writer Invitation::#{id}"])
      )
      |> Repo.transaction()
      |> case do
        {:ok, %{owner_profile: profile}} ->
          {:ok, profile}

        {:error, _, _, _} ->
          {:error, "Error!, Invation could not be accepted."}
      end
    else
      :error ->
        {:error, "Error! Invalid/Expired invitation token"}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Invitation Account Owner does not exist."}
  end

  @doc """
  Rejects an invitation for joining an account owner's team

  ## Examples
      iex> reject_join_invitation(%Account{} = invitation_senders_account, token)
      :ok

      iex> reject_join_invitation(%Account{} = invitation_senders_account, token)
      :error
  """
  @spec reject_join_invitation(Account.t(), binary()) :: :ok | {:error, reason()}
  def reject_join_invitation(%Account{id: id} = account, token) do
    with {:ok, account_query} <-
           Token.verify_email_token_query(token, "Writer Invitation::#{id}"),
         %Account{} = ^account <- Repo.one!(account_query) do
      Multi.new()
      |> Multi.delete_all(
        :tokens,
        Token.account_contexts_query(account, ["Writer Invitation::#{id}"])
      )
      |> Repo.transaction()
      |> case do
        {:ok, _results} ->
          :ok

        {:error, _, _, _} ->
          {:error, "Error!, Invation could not be rejected."}
      end
    else
      :error ->
        {:error, "Error! Invalid/Expired invitation token"}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Invitation Account Owner does not exist."}
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
          {:ok, WriterProfile.t()} | {:error, reason()}
  def leave_team(%Account{} = account, team_id) do
    team_task = team_task(team_id)

    %WriterProfile{} =
      profile =
      account
      |> get_profile_for_account!()

    # remove the writer from the team and all groups for the team
    writer_multi(profile, team_id)
    |> team_multi(team_task, profile.id)
    |> Repo.transaction()
    |> case do
      {:ok, %{writer: %WriterProfile{} = profile}} ->
        {:ok, profile}

      {:error, _, _, _} ->
        {:error, "Error!. Unable to leave team"}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writer Profile does not exist."}
  end

  @doc """
  Returns all the jobs that have been picked by the writer, irrespective of the
  team that the current writer belongs to

  The results can be filtered by status and/or payment_status

  ## Examples
      iex> all_jobs_picked(%Account{} = account, filters)
      [%Job{}]
  """
  @spec all_jobs_picked(account :: Account.t(), filters :: %{binary() => binary()} | %{}) ::
          [%{atom() => term()}, ...] | [] | {:error, reason()}
  def all_jobs_picked(%Account{id: id} = _account, filters) do
    %WriterProfile{} =
      profile =
      from(
        profile in WriterProfile,
        where: profile.account_id == ^id,
        select: map(profile, [:id])
      )
      |> Repo.one!()

    from(
      job in Management.JobManager.Job,
      where: job.writer_profile_id == ^profile.id,
      select:
        map(job, [
          :id,
          :subject,
          :status,
          :payment_status,
          :pciked_on
        ])
    )
    |> Utils.jobs_query(filters)
    |> Repo.all()
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writer Profile Account does not exist."}
  end

  @doc """
  Returns all the jobs picked by a given writer for a given team for which the
  user belongs to

  ## Examples
      iex> all_jobs_picked_for(team_profile_id, filters, %Account{} = writer_account)
      [%Job{}]
  """
  @spec all_jobs_picked_for(
          team_profile_id :: binary(),
          filters :: %{} | %{binary() => binary()},
          account :: Account.t()
        ) ::
          [
            %{atom() => term()},
            ...
          ]
          | {:error, reason()}
  def all_jobs_picked_for(team_profile_id, filters, %Account{id: id} = _account) do
    %WriterProfile{} =
      profile =
      from(
        profile in WriterProfile,
        where: profile.account_id == ^id,
        select: map(profile, [:id])
      )
      |> Repo.one!()

    from(
      job in Management.JobManager.Job,
      where: job.writer_profile_id == ^profile.id and job.owner_profile_id == ^team_profile_id,
      select:
        map(job, [
          :id,
          :subject,
          :status,
          :payment_status,
          :pciked_on
        ])
    )
    |> Utils.jobs_query(filters)
    |> Repo.all()
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writer Profile Account does not exist."}
  end

  @doc """
  Sends a job interest request to an account that is registered as an account owner

  ## Examples
      iex> send_job_interest_request(recipient_account_id)
      :ok
  """
  @spec send_job_interest_request(recipient_account_id :: binary()) :: :ok | {:error, reason()}
  def send_job_interest_request(recipient_account_id) do
    %Account{} =
      _account =
      from(
        account in Account,
        where: account.id == ^recipient_account_id,
        select: map(account, [:email])
      )
      |> Repo.one!()

    :ok
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Writing Account does not exist."}
  end

  @doc """
  Suspends a givern writer

  ## Example
      iex> suspend_writer(Account{} = account, writer_profile_id)
  """

  #############################################################################################
  #################################### PRIVATE FUNCTIONS ######################################

  @spec get_profile_for_account!(Account.t()) :: WriterProfile.t() | Ecto.NoResultsError
  defp get_profile_for_account!(%Account{id: id} = _account) do
    from(
      profile in WriterProfile,
      where: profile.account_id == ^id
    )
    |> Repo.one!()
  end

  # creates a task for getting the owner profile for the account for
  # which the current writer is trying to leave
  @spec team_task(team_id :: binary()) :: Task.t()
  defp team_task(team_id) do
    Task.async(fn ->
      from(
        profile in OwnerProfile,
        where: profile.id == ^team_id,
        join: group in assoc(profile, :groups),
        preload: [groups: group]
      )
      |> Repo.one!()
    end)
  end

  # Removes the team id from the list of team memberships for which the writer
  # belongs to and returns a Multi representing the update action required
  @spec writer_multi(profile :: WriterProfile.t(), team_id :: binary()) :: Multi.t()
  defp writer_multi(profile, team_id) do
    teams =
      profile.team_memberships
      |> List.delete(team_id)

    profile_changeset =
      profile
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:team_memberships, teams)

    Multi.new()
    |> Multi.update(:writer, profile_changeset)
  end

  # team multi gets the profile for the account for which the writer is trying to leave
  # removes the writer profile id from its list os team members, add its own update action
  # to the multi and then adds the group multi update actions
  @spec team_multi(
          writer_multi :: Multi.t(),
          team_task :: Task.t(),
          writer_profile_id :: binary()
        ) :: Multi.t() | Ecto.NoResultsError
  defp team_multi(writer_multi, team_task, writer_profile_id) do
    team = Task.await(team_task)

    teams =
      team.team_member
      |> List.delete(writer_profile_id)

    team_changeset =
      team
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:team_members, teams)

    writer_multi
    |> Multi.update(:team, team_changeset)
    |> group_multi(team.groups, writer_profile_id)
  end

  # for each of the groups in the team, it removes the writer profile if from its
  # list of members, and returns a single multi representing the update changes required
  @spec group_multi(team_multi :: Multi.t(), groups :: [Group.t(), ...], profile_id :: binary()) ::
          Multi.t()
  defp group_multi(team_multi, groups, profile_id) do
    groups
    |> Enum.filter(fn group ->
      profile_id in group.members
    end)
    |> Enum.map(fn group ->
      members =
        group.members
        |> List.delete(profile_id)

      group
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:members, members)
    end)
    |> Enum.reduce(team_multi, fn changeset, acc ->
      acc
      |> Multi.update(changeset.data.id, changeset)
    end)
  end

  @spec get_subscription_package(subscription_type :: atom()) :: binary()
  defp get_subscription_package(subscription_type) do
    case subscription_type do
      :free_trial_account ->
        "Free Trial Account"

      :standard_account ->
        "Standard Account"

      :pro_account ->
        "Pro Account"
    end
  end
end
