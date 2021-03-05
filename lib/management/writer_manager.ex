defmodule Management.WriterManager do
  @moduledoc """
  The WriterManager context.
  """

  import Ecto.Query, warn: false
  alias Management.Repo

  alias Management.WriterManager.WriterProfile

  @doc """
  Returns the list of writer_profiles.

  ## Examples

      iex> list_writer_profiles()
      [%WriterProfile{}, ...]

  """
  def list_writer_profiles do
    Repo.all(WriterProfile)
  end

  @doc """
  Gets a single writer_profile.

  Raises `Ecto.NoResultsError` if the Writer profile does not exist.

  ## Examples

      iex> get_writer_profile!(123)
      %WriterProfile{}

      iex> get_writer_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_writer_profile!(id), do: Repo.get!(WriterProfile, id)

  @doc """
  Creates a writer_profile.

  ## Examples

      iex> create_writer_profile(%{field: value})
      {:ok, %WriterProfile{}}

      iex> create_writer_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_writer_profile(attrs \\ %{}) do
    %WriterProfile{}
    |> WriterProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a writer_profile.

  ## Examples

      iex> update_writer_profile(writer_profile, %{field: new_value})
      {:ok, %WriterProfile{}}

      iex> update_writer_profile(writer_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_writer_profile(%WriterProfile{} = writer_profile, attrs) do
    writer_profile
    |> WriterProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a writer_profile.

  ## Examples

      iex> delete_writer_profile(writer_profile)
      {:ok, %WriterProfile{}}

      iex> delete_writer_profile(writer_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_writer_profile(%WriterProfile{} = writer_profile) do
    Repo.delete(writer_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking writer_profile changes.

  ## Examples

      iex> change_writer_profile(writer_profile)
      %Ecto.Changeset{data: %WriterProfile{}}

  """
  def change_writer_profile(%WriterProfile{} = writer_profile, attrs \\ %{}) do
    WriterProfile.changeset(writer_profile, attrs)
  end
end
