defmodule Management.OwnerManager.OwnerProfile do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @organization_types [
    "Corporate Account",
    "Individual Account"
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "owner_profiles" do
    # personal information
    field(:full_name, :string)
    field(:profile_image, :string)
    field(:phone_number, :string)
    # organization type indicates whether the account was a company or an individual use only
    # Options are:
    # 1. Coorporate use
    # 2, Individual Use
    field :organization_type, :string
    # Holds the number of writers that a management account can have.
    # Defaults to 3, which is the number a standard account can have and increases depending on the package
    # that the account belongs tp.
    # However, for Free trial account, the account can have an unlimited number of writers but once it's over and
    # it has not been renewed, all but the first three are deactivated for this account.
    field :writers_limit, :integer, default: 3
    # uniquely identifies an account
    # it is generated by the system.
    field :account_code, :binary
    # subscription information
    field(:sub_expiry_date, :naive_datetime)
    field(:sub_is_active, :boolean, default: false)
    field(:sub_start_date, :naive_datetime)
    # A subscription package indicates the package that the current user has
    # The subscription package includes:
    # 1. Standard Account => This is the most basic package that a writer account can be of
    # 2. Pro Account => This is the most advanced with package that a writer account can be
    #     and also contains many features.
    # 3. Free Trial Account
    field(:subscription_package, :string)

    belongs_to(:account, Management.AccountManager.Account, type: :binary_id)
    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(owner_profile, attrs) do
    owner_profile
    |> cast(attrs, [
      :full_name,
      :phone_number,
      :organization_type
    ])
    |> validate_required([
      :full_name,
      :phone_number,
      :organization_type
    ])
    |> put_account_code()
    |> validate_inclusion(:organization_type, @organization_types)

    # |> unsafe_validate_unique(:phone_number, Management.Repo)
    # |> unique_constraint(:phone_number, message: "The phone number entered is invalid.")
  end

  @doc false
  @spec profile_image_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def profile_image_changeset(owner_profile, params) do
    change(owner_profile, params)
    |> cast(params, [
      :profile_image
    ])
    |> validate_required(
      [
        :profile_image
      ],
      message: "The profile image/Corporate Logo must be provided."
    )
  end

  @spec put_account_code(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp put_account_code(%Ecto.Changeset{} = changeset) do
    if changeset.valid? do
      changeset
      |> put_change(:account_code, Ecto.UUID.generate())
    else
      changeset
    end
  end
end
