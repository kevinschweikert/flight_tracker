defmodule FlightTracker do
  @moduledoc """
  This is the aggregate
  """
  alias Phoenix.PubSub
  alias FlightTracker.Eventstore

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def ingest_snapshot(airplanes) do
    GenServer.call(__MODULE__, {:cmd, :ingest_snapshot, airplanes})
  end

  def last_events(count \\ 10) do
    GenServer.call(__MODULE__, {:get_last_events, count})
  end

  defdelegate crafts(), to: FlightTracker.CraftProjector

  @impl GenServer
  def init(_) do
    subscribe()

    {:ok, %{crafts: %{}}}
  end

  @impl GenServer
  def handle_call({:cmd, :ingest_snapshot, airplanes}, _from, %{crafts: crafts} = state) do
    identifiers =
      for flight_data <- airplanes do
        case Map.get(crafts, flight_data["hex"]) do
          nil ->
            {:flight_spotted, flight_data} |> publish()
            flight_data["hex"]

          _ ->
            {:flight_updated, flight_data} |> publish()
            flight_data["hex"]
        end
      end

    for {hex, flight_data} <- crafts do
      if hex not in identifiers do
        {:flight_left, flight_data} |> publish()
      end
    end

    {:reply, :ok, state}
  end

  def handle_call({:get_last_events, count}, _from, state) do
    {:reply,
     Eventstore.events()
     |> Enum.take(count)
     |> Enum.map(fn {type, flight_data} -> {type, flight_data["hex"]} end), state}
  end

  @impl GenServer
  def handle_info(evnt, %{crafts: crafts}) do
    new_crafts = apply_event(evnt, crafts)
    {:noreply, %{crafts: new_crafts}}
  end

  defp apply_event({:flight_spotted, flight_data}, crafts) do
    Map.put(crafts, flight_data["hex"], flight_data)
  end

  defp apply_event({:flight_updated, flight_data}, crafts) do
    Map.put(crafts, flight_data["hex"], flight_data)
  end

  defp apply_event({:flight_left, flight_data}, crafts) do
    Map.delete(crafts, flight_data["hex"])
  end

  def subscribe(topic \\ "events") do
    PubSub.subscribe(:flight_tracker_pubsub, topic)
  end

  def publish(event, topic \\ "events") do
    PubSub.broadcast(:flight_tracker_pubsub, topic, event)
  end
end
