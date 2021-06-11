use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hacker_aggregator, HackerAggregatorWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :error

# NoOpHackerNewsApi for tests
config :hacker_aggregator, :hacker_news_api, HackerAggregator.MockHackerNewsApi
