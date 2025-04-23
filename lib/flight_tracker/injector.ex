defmodule FlightTracker.Injector do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    schedule_fetch()
    {:ok, []}
  end

  @impl GenServer
  def handle_info(:fetch, state) do
    get_flights() |> FlightTracker.ingest_snapshot()
    schedule_fetch()
    {:noreply, state}
  end

  def get_flights() do
    Req.get!("https://opendata.adsb.fi/api/v2/lat/53.551086/lon/9.993682/dist/25").body[
      "aircraft"
    ]

    # Req.get!("https://opendata.adsb.fi/api/v2/lat/40.730610/lon/-73.935242/dist/5").body[
    #   "aircraft"
    # ]
  end

  defp schedule_fetch() do
    Process.send_after(self(), :fetch, to_timeout(second: 10))
  end
end
