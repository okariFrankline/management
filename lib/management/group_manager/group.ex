defmodule Management.GroupManager.Group do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Management.OwnerManager.OwnerProfile

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "groups" do
    field :description, :string
    field :group_name, :string
    field :is_active, :boolean, default: true
    field :members, {:array, :binary_id}

    field :member, :binary_id, virtual: true
    belongs_to :owner_profile, OwnerProfile, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :group_name,
      :description,
      :members
    ])
    |> validate_required([
      :group_name,
      :description,
      :members,
      :is_active
    ])
  end

  @doc false
  @spec creation_changeset(t() | Ecto.Changeset.t(), map(), OwnerProfile.t()) ::
          Ecto.Changeset.t()
  def creation_changeset(group, attrs, %OwnerProfile{} = owner) do
    group
    |> change(attrs)
    |> cast(attrs, [
      :group_name,
      :description
    ])
    |> validate_required([
      :group_name,
      :description
    ])
    |> validate_description_length()
    |> add_group_name(owner)
  end

  @doc false
  @spec member_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def member_changeset(group, attrs) do
    group
    |> change(attrs)
    |> cast(attrs, [
      :member
    ])
    |> validate_required([
      :member
    ])
    |> add_member()
  end

  # ensures the length is at least 20 words in length
  @spec validate_description_length(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_description_length(%Ecto.Changeset{changes: %{descripiton: desc}} = changeset) do
    if changeset.valid? do
      word_count =
        desc
        |> String.split(" ")
        |> Enum.count()

      if word_count >= 20,
        do: changeset,
        else:
          changeset
          |> put_change(:description, "Group description must be at least 20 words in length")
    end
  end

  ### Adding a new mwmber to the team
  # 1. Get the current members already in the team.
  # 2. Get the new member that is to be added
  # 3. Ensure that the member is not already in the members list
  # 4. If member is already, add the error to the changeset else add the member in the members list.
  @spec add_member(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp add_member(%Ecto.Changeset{valid?: true, changes: %{member: member}} = changeset) do
    # get the current members
    %__MODULE__{members: members} = changeset.data

    if Enum.member?(members, member) do
      changeset
      |> add_error(:member, "The team member chosen is already part of the group.")
    else
      changeset
      |> put_change(:members, [member | members])
      |> delete_change(:member)
    end
  end

  defp add_member(changeset), do: changeset

  @spec add_group_name(Ecto.Changeset.t(), OwnerProfile.t()) :: Ecto.Changeset.t()
  defp add_group_name(
         %Ecto.Changeset{changes: %{group_name: g_name}} = changeset,
         %OwnerProfile{account_code: acc_code} = _owner
       ) do
    if changeset.valid? do
      changeset
      |> put_change(:group_name, "#{acc_code}:#{g_name}")
    else
      changeset
    end
  end
end
