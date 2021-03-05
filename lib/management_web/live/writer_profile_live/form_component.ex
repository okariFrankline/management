defmodule ManagementWeb.WriterProfileLive.FormComponent do
  use ManagementWeb, :live_component

  alias Management.WriterManager

  @impl true
  def update(%{writer_profile: writer_profile} = assigns, socket) do
    changeset = WriterManager.change_writer_profile(writer_profile)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"writer_profile" => writer_profile_params}, socket) do
    changeset =
      socket.assigns.writer_profile
      |> WriterManager.change_writer_profile(writer_profile_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"writer_profile" => writer_profile_params}, socket) do
    save_writer_profile(socket, socket.assigns.action, writer_profile_params)
  end

  defp save_writer_profile(socket, :edit, writer_profile_params) do
    case WriterManager.update_writer_profile(socket.assigns.writer_profile, writer_profile_params) do
      {:ok, _writer_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Writer profile updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_writer_profile(socket, :new, writer_profile_params) do
    case WriterManager.create_writer_profile(writer_profile_params) do
      {:ok, _writer_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Writer profile created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
