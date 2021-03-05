defmodule Management.OwnerManager.OwnerProfileTest do
  use Management.DataCase, async: false
  alias Management.OwnerManager.OwnerProfile, as: Profile

  @expected_schema_fields [
    {:id, :binary_id},
    {:profile_image, :string},
    {:phone_number, :string},
    {:organization_type, :string},
    {:writers_limit, :integer},
    {:account_code, :binary},
    {:sub_expiry_date, :naive_datetime},
    {:sub_is_active, :boolean},
    {:sub_start_date, :naive_datetime},
    {:subscription_package, :string},
    {:account_id, :binary_id},
    {:full_name, :string},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  @changeset_required_fields [
    {:full_name, :string},
    {:phone_number, :string},
    {:organization_type, :string}
  ]

  describe "schema definition" do
    @tag :owner_profile_schema_definition
    test "Ensures that the fields defined in the schema is always consistent" do
      actual_fields =
        for field <- Profile.__schema__(:fields) do
          type = Profile.__schema__(:type, field)

          {field, type}
        end

      assert MapSet.new(@expected_schema_fields) == MapSet.new(actual_fields)
    end
  end

  describe "changeset/2" do
    @tag :owner_profile_changesets
    test "Success: Ensures that given the correct params, the changeset is always valid." do
      params = Factory.string_params_for(:owner)

      assert %Changeset{valid?: true, changes: changes} =
               %Profile{}
               |> Profile.changeset(params)

      for {field, _type} <- @changeset_required_fields do
        actual_value = Map.get(params, Atom.to_string(field))
        expected_value = Map.get(changes, field)

        assert actual_value == expected_value,
               "ERROR:\nActual value: #{actual_value}\nExpected value: #{expected_value}"
      end
    end

    @tag :owner_profile_changesets
    test "Error: Ensures that given params with missing required fields, the changeset is always invalid" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               %Profile{}
               |> Profile.changeset(params)

      for {field, _type} <- @changeset_required_fields do
        assert errors[field], "Expected field: #{field} to be in the errors arrays"
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "ERROR:\nExpected error: #{meta[:validation]}\nCompared to: ':required'"
      end
    end

    @tag :owner_profile_changesets
    test "Error: Ensures that given params with wrong values, then the changeset will always be invalid" do
      wrong_params =
        @changeset_required_fields
        |> invalid_params()

      assert %Changeset{valid?: false, errors: errors} =
               %Profile{}
               |> Profile.changeset(wrong_params)

      for {field, _type} <- @changeset_required_fields do
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
      {Atom.to_string(field), invalid_values[type].()}
    end
  end
end
