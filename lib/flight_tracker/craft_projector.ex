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
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call(:get_crafts, _from, stats) do
    {:reply, stats, stats}
  end

  @impl GenServer
  def handle_info({:flight_spotted, flight_data}, stats) do
    desc = flight_data["desc"] || "UNKNOWN"
    stats = Map.update(stats, desc, 1, fn old_val -> old_val + 1 end)
    {:noreply, stats}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
