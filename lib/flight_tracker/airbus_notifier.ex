defmodule FlightTracker.AirbusNotifier do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    FlightTracker.subscribe()
    {:ok, []}
  end

  @impl GenServer
  def handle_info({:flight_spotted, flight_data}, state) do
    desc = Map.get(flight_data, "desc", "unknown") |> String.downcase()

    if String.contains?(desc, "airbus") do
      Logger.info(
        "#{flight_data["desc"]} flight #{String.trim(flight_data["flight"] || "(unknown)")} spotted! ICAO: #{flight_data["hex"]}, LAT: #{flight_data["lat"]}, LON: #{flight_data["lon"]}"
      )
    end

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
