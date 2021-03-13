defmodule Management.JobManager do
  @moduledoc """
  The JobManager context.
  """

  import Ecto.Query, warn: false
  alias Management.Repo

  alias Management.JobManager.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(%Job{} = job, attrs \\ %{}) do
    job
    |> Job.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a job's description

  ## Examples

      iex> update_job_description(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job_description(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_description(%Job{} = job, attrs) do
    job
    |> Job.description_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a job's visibility

  ## Examples

      iex> update_job_visibility(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job_visibility(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_visibility(%Job{} = job, attrs) do
    job
    |> Job.visibility_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end
end
