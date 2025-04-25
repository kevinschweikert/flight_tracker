defmodule FlightTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :flight_tracker,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FlightTracker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.1"},
      {:req, "~> 0.5.10"},
      {:curl_req, "~> 0.100.1"}
    ]
  end
end
