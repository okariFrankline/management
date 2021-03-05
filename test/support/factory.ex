defmodule Management.Factory do
  use ExMachina.Ecto, repo: Management.Repo
  alias Management.AccountManager.Account
  alias Management.WriterManager.WriterProfile
  alias Management.OwnerManager.OwnerProfile

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
end
