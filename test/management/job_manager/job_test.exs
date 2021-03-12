defmodule Management.JobManager.JobTest do
  use Management.DataCase, async: true
  alias Management.JobManager.Job

  # @expected_schema_fields [
  #   {:id, :binary_id},
  #   {:deadline, :naive_datetime},
  #   {:description, :string},
  #   {:job_type, :string},
  #   {:is_submitted, :boolean},
  #   {:payment_status, :string},
  #   {:status, :string},
  #   {:subject, :string},
  #   {:writer_id, :binary_id},
  #   {:owner_profile, :binary_id},
  #   {:attachments, {:array, :string}},
  #   {:inserted_at, :naive_datetime},
  #   {:updated_at, :naive_datetime}
  # ]

  @creation_schema_fields [
    {:subject, :string},
    {:job_type, :string},
    {:deadline, :naive_datetime}
  ]

  # describe "schema defintion" do
  #   @tag :job_schema_definition
  #   test "Ensures the schema fields are consistent" do
  #     actual_fields =
  #       for field <- Job.__schema__(:fields), field not in [{:visibility, _}] do
  #         type = Job.__schema__(:type, field)

  #         {field, type}
  #       end

  #     assert MapSet.new(@expected_schema_fields) == MapSet.new(actual_fields)
  #   end
  # end

  describe "creation_changeset/2" do
    @tag :job_creation_changeset
    test "Success: Ensures that given valid params, the changeset will always be valid" do
      job_params = Factory.params_for(:job)

      assert %Changeset{valid?: true, changes: changes} =
               %Job{}
               |> Job.creation_changeset(job_params)

      for {field, _type} <- @creation_schema_fields do
        expected_value = Map.get(changes, field)
        actual_value = Map.get(job_params, field)

        assert expected_value == actual_value,
               "ERROR:\nActual value: #{actual_value}\nExpected value: #{expected_value}"
      end
    end

    @tag :job_creatioin_changeset
    test "Error: Ensures that given missing required params, the changeset will always be invalid" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               %Job{}
               |> Job.creation_changeset(params)

      for {field, _type} <- @creation_schema_fields do
        assert errors[field], "Expected field: #{field} to be in the errors arrays"
        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "ERROR:\nExpected error: #{meta[:validation]}\nCompared to: ':cast'"
      end
    end

    @tag :job_creation_changeset
    test "Error: Ensures that given params that are invalid, the changeset will always be invalid" do
      wrong_params = invalid_params(@creation_schema_fields)

      assert %Changeset{valid?: false, errors: errors} =
               %Job{}
               |> Job.creation_changeset(wrong_params)

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
      string: fn -> DateTime.utc_now() end,
      naive_datetime: fn -> "Not a date" end
    }

    for {field, type} <- fields_with_types, into: %{} do
      {field, invalid_values[type].()}
    end
  end
end
