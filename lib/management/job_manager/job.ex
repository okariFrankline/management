defmodule Management.JobManager.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @visibilities [
    "Everyone",
    "Group",
    "Individual"
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "jobs" do
    field :attachments, {:array, :string}
    field :contains_corrections, :boolean, default: false
    field :deadline, :naive_datetime
    field :description, :string
    # indicates whether the job is "Express/Rush", "Standard"
    # An express job is one that needs to be done
    field :job_type, :string
    field :is_submitted, :boolean, default: false
    # indicates the payment status for the job,
    # the payment status can be: "Paid", "Pending", "Canceled"
    # defaults to pending
    field :payment_status, :string
    # indicates the status of whether the job has been picked,
    # in progress, Late or pending
    # defaults to "Pending"
    field :status, :string
    field :subject, :string
    # the visibility indicates the
    embeds_one :visibility, Visibility, on_replace: :update do
      # visibility type indicates which gropu can see a givenjob
      # Can be:
      # 1. Individual Member => Indicates that only one person can see the job
      # 2. Gropu Members => Indicates that only members of a given group can the the job
      # 3. Everyone => Every worker in the group can see the job (This is the default)
      field :visibility_type, :string
      # asset_id holds the id the group, or individual writer id
      field :asset_id, :binary_id
    end

    # indicates the id of the writer who will pick this job
    field :writer_profile_id, :binary_id
    # indicates the date the job was picked
    field :picked_on, :naive_datetime

    # this job belongs to one owner
    belongs_to :owner_profile, Management.OwnerManager.OwnerProfile

    timestamps()
  end

  @doc false

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(job, attrs) do
    job
    |> cast(attrs, [
      :description,
      :is_submitted,
      :deadline,
      :visibility,
      :subject,
      :attachments
    ])
  end

  @doc false
  @spec creation_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def creation_changeset(job, attrs) do
    job
    |> change(attrs)
    |> cast(attrs, [
      :subject,
      :job_type,
      :deadline
    ])
    |> validate_required([
      :subject,
      :job_type,
      :deadline
    ])
    |> validate_deadline()
    |> foreign_key_constraint(:owner_profile_id)
  end

  @doc false
  @spec description_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def description_changeset(job, attrs) do
    job
    |> change(attrs)
    |> cast(attrs, [
      :description
    ])
    |> validate_required([
      :description
    ])
    |> validate_description_length()
  end

  @doc false
  @spec attachments_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def attachments_changeset(job, attrs) do
    job
    |> change(attrs)
    |> cast(attrs, [
      :attachments
    ])
    |> validate_required([
      :attachments
    ])
    |> ensure_attachments_has_value()
  end

  @doc false
  @spec visibility_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def visibility_changeset(job, attrs) do
    job
    |> change(attrs)
    |> cast(attrs, [])
    |> cast_embed(:visbility, with: &add_visibility_changeset/2)
  end

  @doc false
  @spec add_visibility_changeset(%__MODULE__.Visibility{} | Ecto.Changeset.t(), map()) ::
          Ecto.Changeset.t()
  def add_visibility_changeset(visibility, attrs) do
    visibility
    |> cast(attrs, [
      :vibility_type,
      :asset_id
    ])
    |> validate_required([
      :visibility_type
    ])
    |> validate_inclusion(:visbility_type, @visibilities)
    |> check_asset_id()
  end

  # ensures that the deadline entered is ahead of time
  @spec validate_deadline(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_deadline(%Ecto.Changeset{} = changeset) do
    if changeset.valid? do
      # get the deadline
      deadline = get_change(changeset, :deadline)
      # compare the deadline and the current time
      case NaiveDateTime.compare(deadline, NaiveDateTime.utc_now()) do
        :gt ->
          changeset

        _ ->
          changeset
          |> add_error(:deadline, "Job deadline should be a date and time that is in the future")
      end
    else
      changeset
    end
  end

  # ensures that the description is at least 50 words
  @spec validate_description_length(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_description_length(%Ecto.Changeset{changes: %{description: desc}} = changeset) do
    if changeset.valid? do
      word_length =
        desc
        |> String.split(" ")
        |> Enum.count()

      # ensure the length is at least 5o words
      if word_length >= 50,
        do: changeset,
        else: changeset |> add_error(:description, "Job description should be at least 50 words.")
    else
      changeset
    end
  end

  @doc false
  @spec ensure_attachments_has_value(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp ensure_attachments_has_value(
         %Ecto.Changeset{changes: %{attachments: attachments}} = changeset
       ) do
    if changeset.valid? do
      case attachments do
        [] ->
          changeset
          |> add_error(:attachments, "Unable to upload documents. Please try again")

        _list_not_empty ->
          changeset
      end
    else
      changeset
    end
  end

  @spec check_asset_id(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp check_asset_id(%Ecto.Changeset{changes: %{visibility_type: type}} = changeset) do
    if changeset.valid? do
      if type == "Everyone", do: changeset |> put_change(:asset_id, nil), else: changeset
    else
      changeset
    end
  end
end
