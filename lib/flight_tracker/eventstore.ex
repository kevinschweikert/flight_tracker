defmodule FlightTracker.Eventstore do
  use GenServer

  @eventstore "./eventstore"

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def events() do
    GenServer.call(__MODULE__, :get_events)
  end

  def replay() do
    GenServer.call(__MODULE__, :replay_events)
  end

  @impl GenServer
  def init(_) do
    events =
      case File.read(@eventstore) do
        {:ok, binary} -> :erlang.binary_to_term(binary)
        _ -> []
      end

    for event <- events do
      FlightTracker.publish(event)
    end

    FlightTracker.subscribe()
    {:ok, events}
  end

  @impl GenServer
  def handle_call(:get_events, _from, events) do
    {:reply, events, events}
  end

  @impl GenServer
  def handle_info(event, events) do
    events = events ++ [event]
    File.write!(@eventstore, :erlang.term_to_binary(events))
    {:noreply, events}
  end
end
