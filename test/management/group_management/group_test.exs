defmodule Management.GroupManager.GroupTest do
  use Management.DataCase
  alias Management.GroupManager.Group
  alias Management.OwnerManager.OwnerProfile, as: Profile

  @expected_schema_fields [
    {:id, :binary_id},
    {:description, :string},
    {:group_name, :string},
    {:is_active, :boolean},
    {:owner_profile_id, :binary_id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime},
    {:members, {:array, :binary_id}}
  ]

  @creation_schema_fields [
    {:group_name, :string},
    {:description, :string}
  ]

  describe "schema definiton" do
    @tag :group_schema_definition
    test "Ensures that if the schema fields are changed, then changes should propagate" do
      actual_fields =
        for field <- Group.__schema__(:fields) do
          type = Group.__schema__(:type, field)

          {field, type}
        end

      assert MapSet.new(@expected_schema_fields) == MapSet.new(actual_fields)
    end
  end

  describe "creation_changeset/2" do
    setup do
      # create a new account
      owner_params = Factory.params_for(:owner)

      {:ok, owner} =
        %Profile{}
        |> Profile.changeset(owner_params)
        |> Ecto.Changeset.apply_action(:insert)

      %{owner: owner}
    end

    @tag :group_creation_changeset
    test "Success: Ensures that given correct parameters, the changeset will always be valid.", %{
      owner: owner
    } do
      # create a new account
      group_params = Factory.params_for(:group)

      assert %Changeset{valid?: true, changes: changes} =
               %Group{}
               |> Group.creation_changeset(group_params, owner)

      for {field, _type} <- @creation_schema_fields do
        expected_value =
          if field == :group_name do
            [_account_code, group_name] =
              Map.get(changes, field)
              |> String.split(":")

            group_name
          else
            Map.get(changes, field)
          end

        actual_value = Map.get(group_params, field)

        assert actual_value == expected_value,
               "ERROR:\nActual Value: #{actual_value}\nExpected Value: #{expected_value}"
      end
    end

    @tag :group_creation_changeset
    test "Error: Ensures that given missing required params, the changeset will always be invalid",
         %{owner: owner} do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               %Group{}
               |> Group.creation_changeset(params, owner)

      for {field, _type} <- @creation_schema_fields do
        assert errors[field], "Expected field: #{field} to be in the errors arrays"
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "ERROR:\nExpected error: #{meta[:validation]}\nCompared to: ':cast'"
      end
    end

    @tag :group_creation_changeset
    test "Error: Ensures that given params that are invalid, the changeset will always be invalid",
         %{owner: owner} do
      wrong_params = invalid_params(@creation_schema_fields)

      assert %Changeset{valid?: false, errors: errors} =
               %Group{}
               |> Group.creation_changeset(wrong_params, owner)
               |> IO.inspect()

      for {field, _type} <- @creation_schema_fields do
        assert errors[field], "Expected field: #{field} to be in the errors arrays"
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "ERROR:\nExpected error: #{meta[:validation]}\nCompared to: ':cast'"
      end
    end
  end

  # invlaid params
  defp invalid_params(fields_with_types) do
    invalid_values = %{
      string: fn -> DateTime.utc_now() end
    }

    for {field, type} <- fields_with_types, into: %{} do
      {field, invalid_values[type].()}
    end
  end
end
