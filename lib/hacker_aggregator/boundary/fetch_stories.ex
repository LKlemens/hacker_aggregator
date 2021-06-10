defmodule HackerAggregator.Boundary.FetchStories do
  require Logger

  @hacker_news_api Application.get_env(
                     :hacker_aggregator,
                     :hacker_news_api,
                     HackerAggregator.Boundary.HackerNewsApi
                   )

  @spec get_list(number_of_stories :: integer(), hacker_news_api :: module()) :: list()
  def get_list(number_of_stories, hacker_news_api \\ @hacker_news_api) do
    list =
      case hacker_news_api.fetch_top_stories() do
        {:ok, list} ->
          list

        {:error, msg} ->
          Logger.error("fetching list of stories failed: #{inspect(msg)}")
          []
      end

    list
    |> Stream.map(&get_story(&1, hacker_news_api))
    |> Stream.filter(&(&1 != %{}))
    |> Stream.take(number_of_stories)
    |> Enum.to_list()
  end

  ###########
  # PRIVATE
  ###########

  @spec get_story(story_id :: integer(), hacker_news_api :: module()) :: map()
  defp get_story(story_id, hacker_news_api) do
    story =
      hacker_news_api.fetch_story(story_id)
      |> HackerAggregator.Core.HackerNewsApi.ResponseParser.parse_story()

    case story do
      {:ok, story_struct} ->
        story_struct

      {:error, data} ->
        Logger.error("get a story: #{inspect(data)}")
        %{}
    end
  end
end
