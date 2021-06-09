defmodule HackerAggregator.Boundary.NoOpHackerNewsApi do
  @behaviour HackerAggregator.Boundary.HackerNewsApi.Behaviour

  @spec fetch_top_stories() :: {:ok, list()} | {:error, term()}
  def fetch_top_stories() do
    list =
      File.read!("test/support/top_stories_list.json")
      |> Jason.decode!()

    {:ok, list}
  end

  @spec fetch_story(story_id :: integer()) :: {:ok, map()} | {:error, term()}
  def fetch_story(_story_id) do
    story =
      File.read!("test/support/url_story_response.json")
      |> Jason.decode!()

    {:ok, story}
  end
end
