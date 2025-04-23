defmodule FlightTracker.CraftProjector do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def crafts() do
    GenServer.call(__MODULE__, :get_crafts)
  end

  @impl GenServer
  def init(_) do
    FlightTracker.subscribe()
    {:ok, []}
  end

  @impl GenServer
  def handle_call(:get_crafts, _from, state) do
    stats = Enum.frequencies(state)
    {:reply, stats, state}
  end

  @impl GenServer
  def handle_info({:flight_spotted, flight_data}, state) do
    state = [flight_data["desc"] || "unknown" | state]
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
