defmodule Management.Factory do
  use ExMachina.Ecto, repo: Management.Repo
  alias Management.AccountManager.Account

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
end
