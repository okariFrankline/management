defmodule Management.WriterManager.WriterProfileTest do
  @moduledoc false
  use Management.DataCase, async: true
  alias Management.WriterManager.WriterProfile, as: Profile

  @expected_schema_fields [
    {:id, :binary_id},
    {:full_name, :string},
    {:name_initials, :string},
    {:gender, :string},
    {:sub_expiry_date, :naive_datetime},
    {:sub_start_date, :naive_datetime},
    {:subscription_package, :string},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime},
    {:account_id, :binary_id},
    {:profile_image, :string}
  ]

  @changeset_fields [
    {:full_name, :string},
    {:subscription_package, :string},
    {:gender, :string}
  ]

  @changeset_required_fields [
    {:first_name, :string},
    {:last_name, :string},
    {:subscription_package, :string},
    {:gender, :string}
  ]

  describe "schema fields" do
    @tag :owner_profile_schema_definition
    test "Ensures that all the fields that are defined in the schema are similar" do
      actual_fields =
        for field <- Profile.__schema__(:fields) do
          type = Profile.__schema__(:type, field)

          {field, type}
        end

      assert MapSet.new(@expected_schema_fields) == MapSet.new(actual_fields)
    end
  end

  describe "changeset/2" do
    @tag :writer_profile_changesets
    test "Success: Given the correct params, the changeset returned will be valid" do
      params = Factory.string_params_for(:writer)
      expected_full_name = "#{params["last_name"]} #{params["first_name"]}"

      assert %Changeset{valid?: true, changes: changes} =
               %Profile{}
               |> Profile.changeset(params)

      excluded = ["first_name", "last_name"]

      for {field, _type} <- @changeset_fields, field not in excluded do
        # get the actual value
        actual_value =
          case field do
            :full_name ->
              expected_full_name

            field ->
              Map.get(params, Atom.to_string(field))
          end

        # get the expected value
        expected_value = Map.get(changes, field)

        assert actual_value == expected_value,
               "ERROR:\nActual value: #{actual_value}\nExpected value: #{expected_value}"
      end
    end

    @tag :writer_profile_changesets
    test "Error: Ensures that given params with missing information, the changeset will be invalid" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               %Profile{}
               |> Profile.changeset(params)

      for {field, _type} <- @changeset_required_fields do
        assert errors[field], "Expected field: #{field} to be in the errors array."
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "ERROR:\nExpected error: #{meta[:validations]}\nCompared to: ':required'"
      end
    end

    @tag :writer_profile_changesets
    test "Error: Ensures that given invalid params, the changeset will alwasys be inside" do
      wrong_params =
        @changeset_required_fields
        |> invalid_params()

      assert %Changeset{valid?: false, errors: errors} =
               %Profile{}
               |> Profile.changeset(wrong_params)

      for {field, _type} <- @changeset_required_fields do
        assert errors[field], "Expected field: #{field} to be in the errors array"
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "ERROR:\nExpected error: #{meta[:validation]}\nCompared to: ':required'"
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
