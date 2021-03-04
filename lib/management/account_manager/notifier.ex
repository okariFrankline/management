defmodule Management.AccountManager.Notifier do
  @moduledoc """
  Module responsible for sending an email about account management
  """
  use BambooPhoenix, view: ManagementWeb.EmailView
  import Ecto.Query, warn: false
  alias Management.{Mailer, Repo}
  alias Management.AccountManager.Account

  @from Application.compile_env!(:management, :bamboo_from_email)
  @app_name Application.compile_env!(:management, :app_name)

  @doc """
  Sends an email containing the verfication link
  """
  def send_verification_email(%Account{} = account, confirmation_url) do
    "#{@app_name} Account Verification"
    |> base_email()
    |> to(account)
    # the account owner as the assigns to be accessed in the layout
    |> assign(:account, get_account_owner(account))
    |> assign(:confirmation_url, confirmation_url)
    # renders the reset_password.html
    |> render(:account_confirmation)
    # deliver the email
    |> Mailer.deliver_later()
  end

  # provides the base email
  defp base_email(subject) do
    new_email()
    # set the from
    |> from(@from)
    # set the subject of the email
    |> subject(subject)
  end

  @spec get_account_owner(Account.t()) :: Ecto.Schema.t()
  defp get_account_owner(%Account{} = account) do
    account
    |> Account.Utils.account_owner_query()
    |> elem(1)
    |> select([owner], %{
      first_name: owner.first_name,
      last_name: owner.last_name
    })
    |> Repo.one()
  end
end
