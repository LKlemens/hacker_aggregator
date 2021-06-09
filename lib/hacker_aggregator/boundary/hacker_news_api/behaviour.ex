defmodule HackerAggregator.Boundary.HackerNewsApi.Behaviour do
  @callback fetch_top_stories() :: {:ok, list()} | {:error, term()}
  @callback fetch_story(story_id :: integer()) :: {:ok, map()} | {:error, term()}
end
