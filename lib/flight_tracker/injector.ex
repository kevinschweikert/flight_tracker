defmodule FlightTracker.Injector do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    schedule_fetch(1)
    {:ok, []}
  end

  @impl GenServer
  def handle_info(:fetch, state) do
    get_flights() |> FlightTracker.ingest_snapshot()
    schedule_fetch()
    {:noreply, state}
  end

  def get_flights() do
    req()
    |> Req.get!()
    |> Map.get(:body)
    |> Map.get("aircraft")
  end

  defp req() do
    Req.new(url: "https://opendata.adsb.fi/api/v2/lat/53.551086/lon/9.993682/dist/25")
    |> CurlReq.Plugin.attach()
  end

  defp schedule_fetch(seconds \\ 10) do
    Process.send_after(self(), :fetch, to_timeout(second: seconds))
  end
end
