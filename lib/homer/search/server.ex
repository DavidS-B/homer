defmodule Homer.Search.Server do
  @moduledoc """
  This module is the server of the Homer application.
  """
  use GenServer, restart: :transient

  alias Homer.Search
  alias Homer.Search.{OfferRequest, Duffel}

  require Logger

  @timeout 900_000

  # API #

  def fetch_offers({%OfferRequest{} = offer_request, pid}) do
    DynamicSupervisor.start_child(
      Homer.ServerSupervisor,
      {__MODULE__, {offer_request, pid}}
    )
  end

  def child_spec({%OfferRequest{}, pid} = args) do
    %{
      id: {__MODULE__, pid},
      start: {__MODULE__, :start_link, [args]},
      restart: :temporary
    }
  end

  def start_link({%OfferRequest{}, pid} = args) do
    GenServer.start_link(__MODULE__, args, name: via(pid))
  end

  def via(pid) do
    {:via, Registry, {Homer.ServerRegistry, pid}}
  end

  @doc """
  Get the filtered and sorted list of offers.
  """
  def list_offers(pid, limit \\ 10) do
    GenServer.call(pid, {:list_offers, limit}, :infinity)
  end

  @doc """
  Notify the server that an offer request has been updated.
  """
  def offer_request_updated(pid, %OfferRequest{} = offer_request) do
    [registry] = registry_select(pid)

    GenServer.cast(registry.pid, {:offer_request_updated, offer_request})
  end

  def registry_select(pid) do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:==, :"$1", pid}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(Homer.ServerRegistry, [{match_all, guards, map_result}])
  end

  # SERVER #

  @impl true
  def init(state) do
    {:ok, state, {:continue, state}}
  end

  @impl true
  def handle_continue({offer_request, _pid}, state) do
    Duffel.fetch_offers(offer_request)

    {:noreply, state, @timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    Logger.warn("timeout - state: #{state}")
    {:noreply, state}
  end

  @impl true
  def handle_call({:list_offers, limit}, _from, {offer_request, _pid} = state) do
    reply = Search.get_offers(offer_request, limit)

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:offer_request_updated, offer_request}, _state) do
    {:noreply, offer_request}
  end
end
