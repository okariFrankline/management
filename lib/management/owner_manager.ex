defmodule Management.OwnerManager do
  @moduledoc """
  The OwnerManager context.
  """

  import Ecto.Query, warn: false
  alias Management.Repo

  alias Management.OwnerManager.OwnerProfile, as: Owner

  @doc """
  Returns the list of owners.

  ## Examples

      iex> list_owners()
      [%Owner{}, ...]

  """
  def list_owners do
    Repo.all(Owner)
  end

  @doc """
  Gets a single owner.

  Raises `Ecto.NoResultsError` if the Owner does not exist.

  ## Examples

      iex> get_owner!(123)
      %Owner{}

      iex> get_owner!(456)
      ** (Ecto.NoResultsError)

  """
  def get_owner_profile!(id), do: Repo.get!(Owner, id)

  @doc """
  Creates a owner.

  ## Examples

      iex> create_owner(%{field: value})
      {:ok, %Owner{}}

      iex> create_owner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_owner_profile(attrs \\ %{}) do
    %Owner{}
    |> Owner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a owner's personal information.

  ## Examples

      iex> update_owner_profile_information(owner, %{field: new_value})
      {:ok, %Owner{}}

      iex> update_owner_profile_information(owner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_owner_profile_information(%Owner{} = owner, attrs) do
    owner
    |> Owner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a owner's personal information.

  ## Examples

      iex> update_owner_profile_information(owner, %{field: new_value})
      {:ok, %Owner{}}

      iex> update_owner_profile_information(owner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_information(%Owner{} = owner, attrs) do
    owner
    |> Owner.subscription_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a owner.

  ## Examples

      iex> update_owner(owner, %{field: new_value})
      {:ok, %Owner{}}

      iex> update_owner(owner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_owner(%Owner{} = owner, attrs) do
    owner
    |> Owner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a owner.

  ## Examples

      iex> delete_owner(owner)
      {:ok, %Owner{}}

      iex> delete_owner(owner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_owner(%Owner{} = owner) do
    Repo.delete(owner)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking owner changes.

  ## Examples

      iex> change_owner(owner)
      %Ecto.Changeset{data: %Owner{}}

  """
  def change_owner(%Owner{} = owner, attrs \\ %{}) do
    Owner.changeset(owner, attrs)
  end
end
