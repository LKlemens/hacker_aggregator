ExUnit.start()
ExUnit.configure(exclude: [:pending, :real_api])

Mox.defmock(HackerAggregator.MockHackerNewsApi,
  for: HackerAggregator.Boundary.HackerNewsApi.Behaviour
)
