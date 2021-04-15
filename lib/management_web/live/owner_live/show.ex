defmodule ManagementWeb.OwnerLive.Show do
  use ManagementWeb, :live_view

  alias Management.OwnerManager

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:owner, OwnerManager.get_owner!(id))}
  end

  defp page_title(:show), do: "Show Owner"
  defp page_title(:edit), do: "Edit Owner"
end
