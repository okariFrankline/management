defmodule Management.GroupManager.API do
  @moduledoc """
  Provides api for managing the group.
  """
  import Ecto.Query, only: [from: 2]
  alias Management.{GroupManager, WriterManager, Repo}
  alias Management.GroupManager.{Group}
  alias Management.AccountManager.Account
  alias Management.OwnerManager.OwnerProfile
  alias Management.API.Utils

  @typep error :: {:error, binary()}

  @doc """
  Returns all the groups for a given management account

  ## Examples
      iex> list_groups_for(%Account{} = account)
      [%Group{}]

      iex> list_groups_for(%Account{} = account)
      []
  """
  @spec list_groups_for(Account.t()) :: [%{atom() => term()}, ...] | []
  def list_groups_for(%Account{id: id} = _account) do
    profile =
      from(
        profile in OwnerProfile,
        where: profile.owner_profile_id == ^id,
        join: group in assoc(profile, :groups),
        preload: [groups: group]
      )
      |> Repo.one!()

    profile.groups
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Account could not be found."}
  end

  @doc """
  Returns all the members of a group

  ## Examples
      iex> list_group_members(group_id)
      [%WriterProfiles{}]

      iex> list_group_members(group_id)
      []
  """
  @spec list_group_members(group_id :: binary()) :: [%{atom() => term()}, ...] | []
  def list_group_members(group_id) do
    %Group{} = group = GroupManager.get_group!(group_id)

    # load all the members of the grops if the list is not empty
    if not group.members != [] do
      Dataloader.new()
      |> Dataloader.add_source(
        WriterManager,
        WriterManager.data()
      )
      |> Dataloader.load_many(
        WriterManager,
        WriterManager.WriterProfile,
        group.members
      )
      |> Dataloader.run()
      |> Dataloader.get_many(
        WriterManager,
        WriterManager.WriterProfile,
        group.members
      )
    else
      []
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Account could not be found."}
  end

  @doc """
  Creates a new group for a given writing Management account

  ## Examples
      iex> create_new_group(%Account{} = account, valid_params)
      {:ok, %Group{}}

      iex> create_new_group(5Account{} = account, invalid_params)
      {:error, %Ecto.Changeset{}}

      iex> create_new_group(%Account{} = invalid_account, params)
      {:error, :account_not_found}
  """
  @spec create_new_group(Account.t(), %{binary() => binary()}) ::
          {:ok, Group.t()} | {:error, Ecto.Changeset.t()} | {:error, :account_not_found}
  def create_new_group(%Account{} = account, params) do
    %OwnerProfile{} =
      profile =
      account
      |> Utils.get_owner_profile_for_account!()

    # add the id to the params
    with {:ok, %Group{} = _group} = result <- GroupManager.create_group(params, profile),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Adds a given writer id to the the list of members of the group

  The writer must a writer for the account owner and not already in the list of
  the members

  ## Examples
      iex> add_member(%Account{} = account, group_id, writer_id)
      {:ok, %Group{}}

      iex> add_member(%Account{} = account, group_id, writer_id)
      {:error, }
  """
  @spec add_member(Account.t(), binary(), binary()) ::
          {:ok, Group.t()} | {:error, Ecto.Changeset.t()} | error()
  def add_member(%Account{} = account, group_id, writer_id) do
    %OwnerProfile{} =
      profile =
      account
      |> Utils.get_owner_profile_for_account!()

    if not Enum.member?(profile.team_members, writer_id) do
      %Group{} = group = GroupManager.get_group!(group_id)

      with {:ok, %Group{} = _group} = result <-
             GroupManager.update_group_membership(group, %{member: writer_id}),
           do: result
    else
      {:error, "The writer is not a member of your team."}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Account Not Found."}
  end

  @doc """
  Removes a writer from a group

  ## Examples
      iex> remove_writer(group_id, writer_id)
      {:ok, %Group{}}

      iex>  remove_writer(group_id, writer_id)
      {:error, reason}
  """
  @spec remove_writer(group_id :: binary(), writer_id :: binary()) :: {:ok, Group.t()} | error()
  def remove_writer(group_id, writer_id) do
    %Group{} =
      group =
      group_id
      |> GroupManager.get_group!()

    members =
      group.members
      |> List.delete(writer_id)

    group
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:members, members)
    |> Repo.update()
    |> case do
      {:ok, %Group{} = _group} = result ->
        result

      {:error, _changeset} ->
        {:error, "Error!. Writer could not be removed."}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Group does not exist."}
  end

  @doc """
  Deletes a group identified by a group id

  ## Examples
      iex> delete_group(group_id)
      :ok
  """
  @spec delete_group(group_id :: binary()) :: :ok | {:error, Ecto.Changeset.t()}
  def delete_group(group_id) do
    %Group{} = group = GroupManager.get_group!(group_id)

    with {:ok, %Group{} = _grroup} <- GroupManager.delete_group(group), do: :ok
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! The group does not exist."}
  end
end
