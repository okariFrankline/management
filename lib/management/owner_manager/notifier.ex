defmodule Management.OwnerManager.Notifier do
  @moduledoc """
  Sends emails concerning a Management Account notifications
  """
  use Bamboo.Phoenix, view: ManagementWeb.EmailView
  import Ecto.Query, only: [select: 3]
  alias Management.{Mailer, Repo}
  alias Management.AccountManager.Account

  @app_name Application.compile_env!(:management, :app_name)
  @from Application.compile_env!(:management, :bamboo_from_email)

  @doc """
  Sends a writer join invitation link to a writer
  """
  def send_writer_join_invitation(
        %Account{} = sender_account,
        %Account{} = receiver_account,
        invitation_url
      ) do
    "#{@app_name}: Writer Team Join Invitation"
    |> base_email()
    |> to(receiver_account)
    # the account owner as the assigns to be accessed in the layout
    |> assign(:sender_account, get_account_owner(sender_account))
    |> assign(:receiver_account, get_account_owner(receiver_account))
    |> assign(:invitation_url, invitation_url)
    # renders the reset_password.html
    |> render(:join_invitation)
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
    |> select([owner], map(owner, [:full_name]))
    |> Repo.one()
  end
end
