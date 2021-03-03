defmodule Management.AccountManager.AccountTest do
  use Management.DataCase, async: true
  alias Management.AccountManager.Account

  @expected_schema_fields_with_types [
    {:id, :binary_id},
    {:email, :string},
    {:account_type, :string},
    {:confirmed_at, :utc_datetime},
    {:is_active, :boolean},
    {:is_suspended, :boolean},
    {:password_hash, :string},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  @expected_creation_schema_fields [
    {:email, :string},
    {:account_type, :string},
    {:password, :string},
    {:password_confirmation, :string}
  ]

  describe "schema definition" do
    @tag :account_schema_definition
    test "Success: Ensures that the fields and types of the schema are correct." do
      schema_fields_with_types =
        for field <- Account.__schema__(:fields) do
          type = Account.__schema__(:type, field)

          {field, type}
        end

      # ensure that the types are similar
      assert MapSet.new(@expected_schema_fields_with_types) ==
               MapSet.new(schema_fields_with_types)
    end
  end

  describe "creation_changeset/1" do
    @tag :creation_changeset
    test "Success: Ensures that given valid parameters, it returns a valid changeset" do
      # get the stringed params for the creation of a new user
      params = Factory.params_for(:account)

      assert %Changeset{valid?: true, changes: changes} =
               %Account{}
               |> Account.creation_changeset(params)

      for {field, _type} <- @expected_creation_schema_fields,
          field not in [:password, :password_confirmation] do
        # get the expected
        expected_value = Map.get(changes, field)
        # actual value
        actual_value = Map.get(params, field)

        assert expected_value == actual_value,
               "Error for field: #{field}:\nExpected value: #{expected_value}\nActual value: #{
                 actual_value
               }"
      end

      assert changes.password_hash, "Expected the password_hash to be set but is missing"
    end

    @tag :creation_changeset
    test "Error: Ensures that given invalid params, the changeset will always be invalid" do
      invalid_params = invalid_params(@expected_creation_schema_fields)

      assert %Changeset{valid?: false, errors: errors} =
               %Account{}
               |> Account.creation_changeset(invalid_params)

      # ensure that the fields are in the errors array
      for {field, _type} <- @expected_creation_schema_fields do
        assert errors[field], "Expected the field #{field} to be in errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :cast, "The validation in #{meta[:validations]} is invalid."
      end
    end

    @tag :creation_changeset
    test "Error: Ensures that if there are missing fields in the params, then the changeset is invalid" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               %Account{}
               |> Account.creation_changeset(params)

      for {field, _type} <- @expected_creation_schema_fields do
        if errors[field] do
          {_, meta} = errors[field]

          assert meta[:validation] == :required,
                 "The validation in #{meta[:validations]} is invalid."
        end
      end
    end
  end

  # function for returning invalid param
  defp invalid_params(fields_with_values) do
    # map defining functions for returning invalid falues
    invalid_values = %{
      string: fn -> Date.utc_today() end
    }

    for {field, type} <- fields_with_values, into: %{} do
      {field, invalid_values[type].()}
    end
  end
end
