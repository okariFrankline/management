defmodule ManagementWeb.AccountLive.Index do
  use ManagementWeb, :live_view

  alias Management.AccountManager
  alias Management.AccountManager.Account
  alias ManagementWeb.AccountView
  alias Phoenix.View

  @impl true
  def render(assigns) do
    View.render(AccountView, "index.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :accounts, list_accounts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, AccountManager.get_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Accounts")
    |> assign(:account, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = AccountManager.get_account!(id)
    {:ok, _} = AccountManager.delete_account(account)

    {:noreply, assign(socket, :accounts, list_accounts())}
  end

  defp list_accounts do
    AccountManager.list_accounts()
  end
end
