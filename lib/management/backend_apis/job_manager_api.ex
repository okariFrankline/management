defmodule Management.JobManager.API do
  @moduledoc """
  Defines api functions for the job resource
  """
  import Ecto.Query, only: [from: 2]
  # import Ecto.Query.API, only: [map: 2]
  alias Management.{JobManager, Repo}
  alias Management.JobManager.Job
  alias Management.AccountManager.Account
  alias Management.OwnerManager.OwnerProfile

  @doc """
  Lists all the jobs that have not been picked for a given management account

  ## Examples
      iex> list_unpicked_jobs_for(owner_profile_id)
      [%{}, ...]

      iex> list_unpicked_jobs_for(owner_profile_id)
      []
  """
  @spec list_unpicked_jobs_for(binary()) :: [%{atom() => term()}, ...] | []
  def list_unpicked_jobs_for(owner_profile_id) do
    from(
      job in Job,
      where: job.owner_profile_id == ^owner_profile_id and is_nil(job.writer_profile_id),
      select:
        map(job, [
          :id,
          :job_type,
          :deadline,
          :subject
        ])
    )
    |> Repo.all()
  end

  @doc """
  Returns all the jobs picked by a giver writer for a given management account,
  with a given payment status, for the last one month

  ## Examples
      iex> list_jobs_picked_by(owner_profile_id, valid_params)
      [%{}, ...]

      iex> list_jobs_picked_by(owner_rpfiel_id, params)
      []
  """
  @spec list_jobs_picked_by(binary(), %{binary() => term()}) :: [%{atom() => term()}] | []
  def list_jobs_picked_by(owner_profile_id, %{
        "writer_profile_id" => id,
        "payment_status" => status
      }) do
    initial_query =
      from(
        job in Job,
        where: job.owner_profile_id == ^owner_profile_id and job.writer_profile_id == ^id,
        select:
          map(job, [
            :id,
            :payment_status,
            :subject,
            :status,
            :job_type,
            :picked_on
          ])
      )

    final_query =
      if status != "" do
        from(
          query in initial_query,
          where: query.payment_status == ^status
        )
      else
        initial_query
      end

    Repo.all(final_query)
  end

  @doc """
  Gets the details about a given job

  ## Examples
      iex> get_job_details(valid_job_id)
      {:ok, %Job{}}

      iex> get_job_details(invalid_job_details)
      {:error, :not_found}
  """
  @spec get_job_details(binary()) :: {:ok, Job.t()} | {:error, :not_found}
  def get_job_details(job_id) do
    %Job{} = job = JobManager.get_job!(job_id)

    {:ok, job}
  rescue
    Ecto.NoResultsError ->
      {:error, :not_found}
  end

  @doc """
  Creates a new job and posts it to the portal

  ## Examples
      iex> create_new_job(%Account{} = account, valid_params)
      {:ok, %Job{}}

      iex> create_new_job(%Account{} = account, invalid_params)
      {:error, %Ecto.Changeset{}}
  """
  @spec create_new_job(Account.t(), %{binary() => binary()}) ::
          {:ok, Job.t()} | {:error, Ecto.Changeset.t()}
  def create_new_job(%Account{} = account, params) do
    job =
      account
      |> get_profile_for_account!()
      |> Ecto.build_assoc(:jobs)

    with {:ok, %Job{} = _job} = result <- JobManager.create_job(job, params), do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  @doc """
  Sets the job's description

  ## Examples
      iex> set_description(job_id, valid_description)
      {:ok, %Job{}}

      iex> set_description(job_id, invalid_description)
      {:error, %Ecto.Changeset{}}

      iex> set_description(invalid_job_id, description)
      {:error, :job_not_found}
  """
  @spec set_description(binary(), %{binary() => binary()}) ::
          {:ok, Job.t()} | {:error, Ecto.Changeset.t()} | {:error, :job_not_found}
  def set_description(job_id, params) do
    %Job{} = job = JobManager.get_job!(job_id)

    with {:ok, %Job{} = _job} = result <- JobManager.update_job_description(job, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :job_not_found}
  end

  @doc """
  Set job visibility

  ## Examples
      iex> set_job_visibility(job_id, valid_visibility_params)
      {:ok, %Job{}}

      iex> set_job_visibility(job_id, invalid_visibility_params)
      {:error, %Ecto.Changeset{}}

      iex> set_job_visibility(invalid_job_id, visibility_params)
      {:error, :job_not_found}
  """
  @spec set_job_visibility(binary(), %{binary() => binary()}) ::
          {:ok, Job.t()} | {:error, Ecto.Changeset.t()} | {:error, :job_not_found}
  def set_job_visibility(job_id, params) do
    %Job{} = job = JobManager.get_job!(job_id)

    with {:ok, %Job{} = _job} = result <- JobManager.update_job_visibility(job, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, :job_not_found}
  end

  @doc """
  Enables a writer to pick a job

  ## Examples
      iex> pick_job(job_id, writer_profile_id)
      :ok

      iex> pick_job(job_id, writer_profile_id)
  """
  @spec pick_job(binary(), binary()) :: :ok | {:error, Ecto.Changeset.t()} | {:error, atom()}
  def pick_job(job_id, writer_profile_id) do
    %Job{} = job = JobManager.get_job!(job_id)

    if is_nil(job.writer_profile_id) do
      job_changeset =
        job
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:writer_profile_id, writer_profile_id)

      with {:ok, %Job{} = _job} <- Repo.update(job_changeset), do: :ok
    else
      {:error, :already_picked}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :job_not_found}
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
end
