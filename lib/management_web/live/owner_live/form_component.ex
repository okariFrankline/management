defmodule ManagementWeb.OwnerLive.FormComponent do
  use ManagementWeb, :live_component

  alias Management.OwnerManager

  @impl true
  def update(%{owner: owner} = assigns, socket) do
    changeset = OwnerManager.change_owner(owner)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"owner" => owner_params}, socket) do
    changeset =
      socket.assigns.owner
      |> OwnerManager.change_owner(owner_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"owner" => owner_params}, socket) do
    save_owner(socket, socket.assigns.action, owner_params)
  end

  defp save_owner(socket, :edit, owner_params) do
    case OwnerManager.update_owner(socket.assigns.owner, owner_params) do
      {:ok, _owner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Owner updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_owner(socket, :new, owner_params) do
    case OwnerManager.create_owner(owner_params) do
      {:ok, _owner} ->
        {:noreply,
         socket
         |> put_flash(:info, "Owner created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
