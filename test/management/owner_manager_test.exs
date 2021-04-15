# defmodule Management.OwnerManagerTest do
#   use Management.DataCase

#   alias Management.OwnerManager

#   describe "owners" do
#     alias Management.OwnerManager.Owner

#     @valid_attrs %{full_name: "some full_name", owner_image: "some owner_image", phone_numbers: [], sub_expiry_date: ~N[2010-04-17 14:00:00], sub_is_active: true, sub_start_date: ~N[2010-04-17 14:00:00], subscription_package: "some subscription_package"}
#     @update_attrs %{full_name: "some updated full_name", owner_image: "some updated owner_image", phone_numbers: [], sub_expiry_date: ~N[2011-05-18 15:01:01], sub_is_active: false, sub_start_date: ~N[2011-05-18 15:01:01], subscription_package: "some updated subscription_package"}
#     @invalid_attrs %{full_name: nil, owner_image: nil, phone_numbers: nil, sub_expiry_date: nil, sub_is_active: nil, sub_start_date: nil, subscription_package: nil}

#     def owner_fixture(attrs \\ %{}) do
#       {:ok, owner} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> OwnerManager.create_owner()

#       owner
#     end

#     test "list_owners/0 returns all owners" do
#       owner = owner_fixture()
#       assert OwnerManager.list_owners() == [owner]
#     end

#     test "get_owner!/1 returns the owner with given id" do
#       owner = owner_fixture()
#       assert OwnerManager.get_owner!(owner.id) == owner
#     end

#     test "create_owner/1 with valid data creates a owner" do
#       assert {:ok, %Owner{} = owner} = OwnerManager.create_owner(@valid_attrs)
#       assert owner.full_name == "some full_name"
#       assert owner.owner_image == "some owner_image"
#       assert owner.phone_numbers == []
#       assert owner.sub_expiry_date == ~N[2010-04-17 14:00:00]
#       assert owner.sub_is_active == true
#       assert owner.sub_start_date == ~N[2010-04-17 14:00:00]
#       assert owner.subscription_package == "some subscription_package"
#     end

#     test "create_owner/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = OwnerManager.create_owner(@invalid_attrs)
#     end

#     test "update_owner/2 with valid data updates the owner" do
#       owner = owner_fixture()
#       assert {:ok, %Owner{} = owner} = OwnerManager.update_owner(owner, @update_attrs)
#       assert owner.full_name == "some updated full_name"
#       assert owner.owner_image == "some updated owner_image"
#       assert owner.phone_numbers == []
#       assert owner.sub_expiry_date == ~N[2011-05-18 15:01:01]
#       assert owner.sub_is_active == false
#       assert owner.sub_start_date == ~N[2011-05-18 15:01:01]
#       assert owner.subscription_package == "some updated subscription_package"
#     end

#     test "update_owner/2 with invalid data returns error changeset" do
#       owner = owner_fixture()
#       assert {:error, %Ecto.Changeset{}} = OwnerManager.update_owner(owner, @invalid_attrs)
#       assert owner == OwnerManager.get_owner!(owner.id)
#     end

#     test "delete_owner/1 deletes the owner" do
#       owner = owner_fixture()
#       assert {:ok, %Owner{}} = OwnerManager.delete_owner(owner)
#       assert_raise Ecto.NoResultsError, fn -> OwnerManager.get_owner!(owner.id) end
#     end

#     test "change_owner/1 returns a owner changeset" do
#       owner = owner_fixture()
#       assert %Ecto.Changeset{} = OwnerManager.change_owner(owner)
#     end
#   end
# end
