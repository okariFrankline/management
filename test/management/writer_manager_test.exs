# defmodule Management.WriterManagerTest do
#   use Management.DataCase

#   alias Management.WriterManager

#   describe "writer_profiles" do
#     alias Management.WriterManager.WriterProfile

#     @valid_attrs %{first_name: "some first_name", full_name: "some full_name", gender: "some gender", last_name: "some last_name", profile_image: "some profile_image", sub_expiry_date: ~N[2010-04-17 14:00:00], sub_start_date: ~N[2010-04-17 14:00:00], suscription_type: "some suscription_type"}
#     @update_attrs %{first_name: "some updated first_name", full_name: "some updated full_name", gender: "some updated gender", last_name: "some updated last_name", profile_image: "some updated profile_image", sub_expiry_date: ~N[2011-05-18 15:01:01], sub_start_date: ~N[2011-05-18 15:01:01], suscription_type: "some updated suscription_type"}
#     @invalid_attrs %{first_name: nil, full_name: nil, gender: nil, last_name: nil, profile_image: nil, sub_expiry_date: nil, sub_start_date: nil, suscription_type: nil}

#     def writer_profile_fixture(attrs \\ %{}) do
#       {:ok, writer_profile} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> WriterManager.create_writer_profile()

#       writer_profile
#     end

#     test "list_writer_profiles/0 returns all writer_profiles" do
#       writer_profile = writer_profile_fixture()
#       assert WriterManager.list_writer_profiles() == [writer_profile]
#     end

#     test "get_writer_profile!/1 returns the writer_profile with given id" do
#       writer_profile = writer_profile_fixture()
#       assert WriterManager.get_writer_profile!(writer_profile.id) == writer_profile
#     end

#     test "create_writer_profile/1 with valid data creates a writer_profile" do
#       assert {:ok, %WriterProfile{} = writer_profile} = WriterManager.create_writer_profile(@valid_attrs)
#       assert writer_profile.first_name == "some first_name"
#       assert writer_profile.full_name == "some full_name"
#       assert writer_profile.gender == "some gender"
#       assert writer_profile.last_name == "some last_name"
#       assert writer_profile.profile_image == "some profile_image"
#       assert writer_profile.sub_expiry_date == ~N[2010-04-17 14:00:00]
#       assert writer_profile.sub_start_date == ~N[2010-04-17 14:00:00]
#       assert writer_profile.suscription_type == "some suscription_type"
#     end

#     test "create_writer_profile/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = WriterManager.create_writer_profile(@invalid_attrs)
#     end

#     test "update_writer_profile/2 with valid data updates the writer_profile" do
#       writer_profile = writer_profile_fixture()
#       assert {:ok, %WriterProfile{} = writer_profile} = WriterManager.update_writer_profile(writer_profile, @update_attrs)
#       assert writer_profile.first_name == "some updated first_name"
#       assert writer_profile.full_name == "some updated full_name"
#       assert writer_profile.gender == "some updated gender"
#       assert writer_profile.last_name == "some updated last_name"
#       assert writer_profile.profile_image == "some updated profile_image"
#       assert writer_profile.sub_expiry_date == ~N[2011-05-18 15:01:01]
#       assert writer_profile.sub_start_date == ~N[2011-05-18 15:01:01]
#       assert writer_profile.suscription_type == "some updated suscription_type"
#     end

#     test "update_writer_profile/2 with invalid data returns error changeset" do
#       writer_profile = writer_profile_fixture()
#       assert {:error, %Ecto.Changeset{}} = WriterManager.update_writer_profile(writer_profile, @invalid_attrs)
#       assert writer_profile == WriterManager.get_writer_profile!(writer_profile.id)
#     end

#     test "delete_writer_profile/1 deletes the writer_profile" do
#       writer_profile = writer_profile_fixture()
#       assert {:ok, %WriterProfile{}} = WriterManager.delete_writer_profile(writer_profile)
#       assert_raise Ecto.NoResultsError, fn -> WriterManager.get_writer_profile!(writer_profile.id) end
#     end

#     test "change_writer_profile/1 returns a writer_profile changeset" do
#       writer_profile = writer_profile_fixture()
#       assert %Ecto.Changeset{} = WriterManager.change_writer_profile(writer_profile)
#     end
#   end
# end
