defmodule ManagementWeb.WriterProfileLive.Index do
  use ManagementWeb, :live_view

  alias Management.WriterManager
  alias Management.WriterManager.WriterProfile

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :writer_profiles, list_writer_profiles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Writer profile")
    |> assign(:writer_profile, WriterManager.get_writer_profile!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Writer profile")
    |> assign(:writer_profile, %WriterProfile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Writer profiles")
    |> assign(:writer_profile, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    writer_profile = WriterManager.get_writer_profile!(id)
    {:ok, _} = WriterManager.delete_writer_profile(writer_profile)

    {:noreply, assign(socket, :writer_profiles, list_writer_profiles())}
  end

  defp list_writer_profiles do
    WriterManager.list_writer_profiles()
  end
end
