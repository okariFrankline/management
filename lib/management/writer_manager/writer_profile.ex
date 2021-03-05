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
    # subscription information
    field(:sub_expiry_date, :naive_datetime)
    field(:sub_start_date, :naive_datetime)
    # A subscription package indicates the package that the current user has
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
      :gender,
      :subscription_package
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :gender,
      :subscription_package
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

  defp name_initials(f_name, l_name) do
    "#{String.at(f_name, 0)}#{String.at(l_name, 0)}"
  end
end
