defmodule ManagementWeb.WriterProfileLive.Show do
  use ManagementWeb, :live_view

  alias Management.WriterManager

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:writer_profile, WriterManager.get_writer_profile!(id))}
  end

  defp page_title(:show), do: "Show Writer profile"
  defp page_title(:edit), do: "Edit Writer profile"
end
