defmodule Management.API.Utils do
  @moduledoc """
  Provides utility functions for backend APIs
  """
  import Ecto.Query, only: [from: 2]
  alias Management.AccountManager.Account
  alias Management.OwnerManager.OwnerProfile
  alias Management.Repo
  # gets the owner profile from an account
  @spec get_owner_profile_for_account!(Account.t()) :: OwnerProfile.t() | Ecto.NoResultsError
  def get_owner_profile_for_account!(%Account{id: id} = _account) do
    from(
      profile in OwnerProfile,
      where: profile.account_id == ^id
    )
    |> Repo.one!()
  end

  @doc """
  Returns the query for an owner profile from a given account

  ## Example
      iex> owner_profile_query_from_account(%Account{} = account)
      %Ecto.Query{}
  """
  @spec owner_profile_query_from_account(Account.t()) :: Ecto.Query.t()
  def owner_profile_query_from_account(%Account{id: id} = _account) do
    from(
      profile in OwnerProfile,
      where: profile.account_id == ^id
    )
  end

  @doc """
  Returns a jobs query applying the filters provided

  This is used in finding all the jobs picked by a given writer

  ## Examples
      iex> jobs_query(job_query, filters)
      %Ecto.Query{}
  """
  @spec jobs_query(job_query :: Ecto.Query.t(), filters :: %{} | %{binary() => binary()}) ::
          Ecto.Query.t()
  def jobs_query(job_query, %{} = _filters), do: job_query
  # only payment status are given
  def jobs_query(job_query, %{"payment_status" => p_status, "status" => nil}) do
    from(
      job in job_query,
      where: job.payment_status == ^p_status
    )
  end

  # only status is given
  def jobs_query(job_query, %{"payment_status" => nil, "status" => status} = _fliters) do
    from(
      job in job_query,
      where: job.status == ^status
    )
  end

  # all filters are given
  def jobs_query(job_query, %{"payment_status" => p_status, "status" => status} = _filters) do
    from(
      job in job_query,
      where: job.status == ^status and job.payment_status == ^p_status
    )
  end
end
