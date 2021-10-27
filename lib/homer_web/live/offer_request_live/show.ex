defmodule HomerWeb.OfferRequestLive.Show do
  use HomerWeb, :live_view

  alias Homer.Search
  alias Homer.Search.Server

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true -> connected_mount(params, session, socket)
      false -> {:ok, assign(socket, page: "loading")}
    end
  end

  def connected_mount(%{"id" => id}, _session, socket) do
    with _ <- Search.delete_offers(),
         offer_request <- Search.get_offer_request!(id),
         {:ok, pid} <- Server.fetch_offers({offer_request, self()}),
         offers <- Server.list_offers(pid) do
      {:ok,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:offer_request, offer_request)
       |> assign(:offers, offers)}
    end
  end

  def connected_mount(_params, _session, socket) do
    {:ok, assign(socket, page: "error")}
  end

  @impl true
  def render(%{page: "loading"} = assigns) do
    ~L"<div>Please wait while loading offers...</div>"
  end

  def render(%{page: "error"} = assigns) do
    ~L"<div>An error occurred</div>"
  end

  def render(assigns) do
    Phoenix.View.render(HomerWeb.PageView, "show.html", assigns)
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Edit offer request")
     |> assign(:offer_request, Search.get_offer_request!(id))}
  end

  defp page_title(:show), do: "Show offers"
  defp page_title(:edit), do: "Edit offer request"
end
