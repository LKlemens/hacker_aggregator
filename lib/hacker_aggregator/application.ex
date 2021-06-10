defmodule HackerAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HackerAggregatorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HackerAggregator.PubSub},
      # Start the Endpoint (http/https)
      HackerAggregatorWeb.Endpoint,
      story_server()
      # Start a worker by calling: HackerAggregator.Worker.start_link(arg)
      # {HackerAggregator.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HackerAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HackerAggregatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp story_server() do
    if Mix.env() == :test do
      {Task, fn -> nil end}
    else
      HackerAggregator.Boundary.StoryServer
    end
  end
end
