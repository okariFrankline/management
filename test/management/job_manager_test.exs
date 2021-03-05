# defmodule Management.JobManagerTest do
#   use Management.DataCase

#   alias Management.JobManager

#   describe "jobs" do
#     alias Management.JobManager.Job

#     @valid_attrs %{attachments: [], contains_corrections: true, deadline: ~D[2010-04-17], description: "some description", done_by: "some done_by", is_submitted: true, payment_status: "some payment_status", status: "some status", subject: "some subject", visibility: "some visibility"}
#     @update_attrs %{attachments: [], contains_corrections: false, deadline: ~D[2011-05-18], description: "some updated description", done_by: "some updated done_by", is_submitted: false, payment_status: "some updated payment_status", status: "some updated status", subject: "some updated subject", visibility: "some updated visibility"}
#     @invalid_attrs %{attachments: nil, contains_corrections: nil, deadline: nil, description: nil, done_by: nil, is_submitted: nil, payment_status: nil, status: nil, subject: nil, visibility: nil}

#     def job_fixture(attrs \\ %{}) do
#       {:ok, job} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> JobManager.create_job()

#       job
#     end

#     test "list_jobs/0 returns all jobs" do
#       job = job_fixture()
#       assert JobManager.list_jobs() == [job]
#     end

#     test "get_job!/1 returns the job with given id" do
#       job = job_fixture()
#       assert JobManager.get_job!(job.id) == job
#     end

#     test "create_job/1 with valid data creates a job" do
#       assert {:ok, %Job{} = job} = JobManager.create_job(@valid_attrs)
#       assert job.attachments == []
#       assert job.contains_corrections == true
#       assert job.deadline == ~D[2010-04-17]
#       assert job.description == "some description"
#       assert job.done_by == "some done_by"
#       assert job.is_submitted == true
#       assert job.payment_status == "some payment_status"
#       assert job.status == "some status"
#       assert job.subject == "some subject"
#       assert job.visibility == "some visibility"
#     end

#     test "create_job/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = JobManager.create_job(@invalid_attrs)
#     end

#     test "update_job/2 with valid data updates the job" do
#       job = job_fixture()
#       assert {:ok, %Job{} = job} = JobManager.update_job(job, @update_attrs)
#       assert job.attachments == []
#       assert job.contains_corrections == false
#       assert job.deadline == ~D[2011-05-18]
#       assert job.description == "some updated description"
#       assert job.done_by == "some updated done_by"
#       assert job.is_submitted == false
#       assert job.payment_status == "some updated payment_status"
#       assert job.status == "some updated status"
#       assert job.subject == "some updated subject"
#       assert job.visibility == "some updated visibility"
#     end

#     test "update_job/2 with invalid data returns error changeset" do
#       job = job_fixture()
#       assert {:error, %Ecto.Changeset{}} = JobManager.update_job(job, @invalid_attrs)
#       assert job == JobManager.get_job!(job.id)
#     end

#     test "delete_job/1 deletes the job" do
#       job = job_fixture()
#       assert {:ok, %Job{}} = JobManager.delete_job(job)
#       assert_raise Ecto.NoResultsError, fn -> JobManager.get_job!(job.id) end
#     end

#     test "change_job/1 returns a job changeset" do
#       job = job_fixture()
#       assert %Ecto.Changeset{} = JobManager.change_job(job)
#     end
#   end
# end
