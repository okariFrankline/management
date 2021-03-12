defmodule Management.WriterManager.WriterProfile do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "writer_profiles" do
    # personal information
    field(:full_name, :string)
    # defaults to "SU" which meants "Sotoo User"
    field(:name_initials, :string)
    field(:gender, :string)
    field(:profile_image, :string)
    # indicates that the subscription is active or not
    # defaults to true
    field :subscription_active, :boolean
    # team memberships
    # holds the ids of all the accounts that this writer belongs to
    # added upon accepting join invitations
    field :team_memberships, {:array, :binary_id}
    # subscription information
    field(:sub_expiry_date, :naive_datetime)
    field(:sub_start_date, :naive_datetime)

    # A shttps://irinenabwire.github.io/tourist-website/ubscription package indicates the package that the current user has
    # The subscription package includes:
    # 1. Standard Account => This is the most basic package that a writer account can be of
    # 2. Pro Account => This is the most advanced with package that a writer account can be
    #     and also contains many features.
    # 3. Free Trial Account
    field(:subscription_package, :string)
    # vitual fields
    field(:last_name, :string, virtual: true)
    field(:first_name, :string, virtual: true)

    belongs_to(:account, Management.AccountManager.Account, type: :binary_id)

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(writer_profile, attrs) do
    writer_profile
    |> cast(attrs, [
      :first_name,
      :last_name,
      :gender
      # :subscription_package
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :gender
      # :subscription_package
    ])
    |> validate_inclusion(:gender, ["Female", "Male"])
    |> put_full_name()

    # |> foreign_key_constraint(:account)
  end

  @doc false
  @spec profile_image_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def profile_image_changeset(account, params) do
    change(account)
    |> cast(params, [
      :profile_image
    ])
    |> validate_required(
      [
        :profile_image
      ],
      message: "The profile image must be given."
    )
  end

  @spec subscription_changeset(Ecto.Changeset.t() | t(), map()) :: Ecto.Changeset.t()
  def subscription_changeset(writer_profile, params) do
    writer_profile
    |> change(params)
    |> cast(params, [
      :subscription_package
    ])
    |> validate_required([
      :subscription_package
    ])
    |> set_subscription_dates()
  end

  @spec put_full_name(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp put_full_name(%Ecto.Changeset{} = changeset) do
    if changeset.valid? do
      f_name =
        changeset
        |> get_change(:first_name)
        |> String.trim()
        |> String.capitalize()

      l_name =
        changeset
        |> get_change(:last_name)
        |> String.trim()
        |> String.capitalize()

      changeset
      |> put_change(:full_name, "#{l_name} #{f_name}")
      |> put_change(:name_initials, name_initials(f_name, l_name))
      |> delete_change(:first_name)
      |> delete_change(:last_name)
    else
      changeset
    end
  end

  # sets the subscription date to 30 days from the current time
  @spec set_subscription_dates(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp set_subscription_dates(%Ecto.Changeset{} = changeset) do
    if changeset.valid? do
      current_datetime = NaiveDateTime.utc_now()

      expiry_datetime =
        current_datetime
        |> Timex.shift(months: 1)

      changeset
      |> put_change(:sub_start_date, current_datetime)
      |> put_change(:sub_expiry_date, expiry_datetime)
    else
      changeset
    end
  end

  @spec name_initials(binary(), binary()) :: binary()
  defp name_initials(f_name, l_name) do
    "#{String.at(f_name, 0)}#{String.at(l_name, 0)}"
  end
end
