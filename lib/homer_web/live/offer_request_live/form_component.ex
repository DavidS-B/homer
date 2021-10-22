defmodule HomerWeb.OfferRequestLive.FormComponent do
  use HomerWeb, :live_component

  alias Homer.Search

  @impl true
  def mount(socket) do
    {:ok, assign(socket, disabled: true)}
  end

  @impl true
  def update(%{offer_request: offer_request} = assigns, socket) do
    changeset = Search.change_offer_request(offer_request)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"offer_request" => offer_request_params}, socket) do
    changeset =
      socket.assigns.offer_request
      |> Search.change_offer_request(offer_request_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(disabled: !changeset.valid?)}
  end

  def handle_event("save", %{"offer_request" => offer_request_params}, socket) do
    case Search.create_offer_request(offer_request_params) do
      {:ok, _offer_request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Offer request created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
