defmodule FlightTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: FlightTracker.Worker.start_link(arg)
      {Phoenix.PubSub, name: :flight_tracker_pubsub},
      FlightTracker.Injector,
      FlightTracker.CraftProjector,
      FlightTracker,
      FlightTracker.Eventstore,
      FlightTracker.AirbusNotifier
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlightTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
