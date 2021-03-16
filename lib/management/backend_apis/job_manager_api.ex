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
  alias Management.WriterManager.WriterProfile
  alias Management.API.Utils

  @doc """
  Returns all the jobs created by a given account owner
  Also filtered given filters

  ### Examples
      iex> all_jobs_created(%Account{} = account_owner, filters)
      [%Job{, ...}]
  """
  @spec all_jobs_created(Account.t(), %{binary() => binary()}) ::
          [Job.t(), ...] | [] | {:error, binary()}
  def all_jobs_created(%Account{} = account, filters) do
    owner_profile = Utils.get_owner_profile_for_account!(account)

    from(
      job in Job,
      where: job.owner_profile_id == ^owner_profile.id,
      select:
        map(job, [
          :id,
          :payment_status,
          :subject,
          :job_type
        ])
    )
    |> jobs_query(filters)
    |> Repo.all()
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! Your Writing Management Account could not be found"}
  end

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
      {:error, "Error! The job could not be found."}
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
      {:error, "Error! Your account does not exist."}
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
  @spec set_description(job_id :: binary(), params :: %{binary() => binary()}) ::
          {:ok, Job.t()} | {:error, Ecto.Changeset.t()} | {:error, binary()}
  def set_description(job_id, params) do
    %Job{} = job = JobManager.get_job!(job_id)

    with {:ok, %Job{} = _job} = result <- JobManager.update_job_description(job, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! The job could not be found."}
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
  @spec set_job_visibility(job_id :: binary(), params :: %{binary() => binary()}) ::
          {:ok, Job.t()} | {:error, Ecto.Changeset.t()} | {:error, binary()}
  def set_job_visibility(job_id, params) do
    %Job{} = job = JobManager.get_job!(job_id)

    with {:ok, %Job{} = _job} = result <- JobManager.update_job_visibility(job, params),
         do: result
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! The job could not be found."}
  end

  @doc """
  Enables a writer to pick a job

  ## Examples
      iex> pick_job(job_id, writer_profile_id)
      :ok

      iex> pick_job(job_id, writer_profile_id)
  """
  @spec pick_job(job_id :: binary(), writer_profile_id :: binary()) ::
          :ok | {:error, Ecto.Changeset.t()} | {:error, binary()}
  def pick_job(job_id, writer_profile_id) do
    %Job{} = job = JobManager.get_job!(job_id)

    if is_nil(job.writer_profile_id) do
      job_changeset =
        job
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:writer_profile_id, writer_profile_id)

      with {:ok, %Job{} = _job} <- Repo.update(job_changeset), do: :ok
    else
      {:error, "Error! The job has already been picked."}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! The job could not be found."}
  end

  @doc """
  Enable the owner of the job to change the payment status of a job

  ## Example
    iex> update_payment_status(job_id, %{"status" => status})
    {:ok, %Job{}}

    iex> update_payment_status(job_id, %{"status" => status})
    {:error, reason}
  """
  @spec update_payment_status(job_id :: binary(), params :: %{binary() => binary()}) ::
          {:ok, Job.t()} | {:error, binary()}
  def update_payment_status(job_id, %{"status" => status} = _params) do
    %Job{} = job = JobManager.get_job!(job_id)

    with {:ok, %Job{} = _job} = result <-
           job
           |> Ecto.Changeset.change()
           |> Ecto.Changeset.put_change(:payment_status, status)
           |> Repo.update() do
      result
    else
      {:error, _} ->
        {:error, "Error! The job's payment status could not be updated."}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "Error! The specified job could not be found."}
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

  @spec jobs_query(job_query :: Ecto.Query.t(), filters :: %{binary() => binary()} | %{}) ::
          Ecto.Query.t()
  defp jobs_query(job_query, filters) do
    status = Map.get(filters, "status", "In Progress")
    payment_status = Map.get(filters, "payment_status", "Pending")
    done_by = Map.get(filters, "done_by", nil)

    if is_nil(done_by) do
      from(
        job in job_query,
        where: job.status == ^status and job.payment_status == ^payment_status
      )
    else
      writer_profile =
        from(
          writer_profile in WriterProfile,
          where: writer_profile.account_id == ^done_by,
          select: map(writer_profile, [:id])
        )
        |> Repo.one!()

      from(
        job in job_query,
        where:
          job.status == ^status and job.payment_status == ^payment_status and
            job.writer_profile_id == ^writer_profile.id
      )
    end
  end
end
