defmodule Management.Factory do
  use ExMachina.Ecto, repo: Management.Repo
  alias Management.AccountManager.Account
  alias Management.WriterManager.WriterProfile
  alias Management.OwnerManager.OwnerProfile
  alias Management.GroupManager.Group
  alias Management.JobManager.Job

  @spec account_factory :: Account.t()
  @doc false
  def account_factory do
    # account_type =

    %Account{
      email: Faker.Internet.email(),
      password: "randompassword12345678",
      password_confirmation: "randompassword12345678",
      account_type: Enum.random(["Management Account", "Writer Account"])
    }
  end

  @doc false
  def writer_factory do
    %WriterProfile{
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      gender: Enum.random(["Male", "Female"]),
      subscription_package:
        Enum.random([
          "Free Trial Account",
          "Standard Account",
          "Pro Account"
        ])
    }
  end

  def owner_factory do
    %OwnerProfile{
      full_name: Faker.Person.first_name(),
      phone_number: Faker.Phone.EnGb.mobile_number(),
      organization_type:
        Enum.random([
          "Corporate Account",
          "Individual Account"
        ])
    }
  end

  def group_factory do
    %Group{
      group_name: Faker.Person.first_name(),
      description:
        "The arrival of Jeff Koinange at Royal Media Services (RMS) has begun to exert pressure on Citizen TV, which is now facing a fallout among some of its best presenters. It is understood that Jeff Konainge’s pay package – figured at Ksh2 million per month for the next two years – has caused disquiet among senior TV presenters who feel short-changed and ‘mocked’ by the media house."
    }
  end

  def job_factory do
    date =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(120, :second)
      |> NaiveDateTime.truncate(:second)

    # |> NaiveDateTime.to_iso8601()

    %Job{
      subject: Faker.Lorem.word(),
      job_type: Enum.random(["Standard", "Express"]),
      deadline: date
    }
  end
end
