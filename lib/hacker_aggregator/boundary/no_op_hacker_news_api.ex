defmodule HackerAggregator.Boundary.NoOpHackerNewsApi do
  @behaviour HackerAggregator.Boundary.HackerNewsApi.Behaviour

  @impl HackerAggregator.Boundary.HackerNewsApi.Behaviour
  def fetch_top_stories() do
    list =
      File.read!("test/support/top_stories_list.json")
      |> Jason.decode!()

    {:ok, list}
  end

  @impl HackerAggregator.Boundary.HackerNewsApi.Behaviour
  def fetch_story(_story_id) do
    story =
      File.read!("test/support/url_story_response.json")
      |> Jason.decode!()

    {:ok, story}
  end
end
