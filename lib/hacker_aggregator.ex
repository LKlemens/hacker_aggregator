defmodule HackerAggregator do
  require Logger

  @moduledoc """
  HackerAggregator keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @hacker_news_api Application.get_env(
                     :hacker_aggregator,
                     :hacker_news_api,
                     HackerAggregator.Boundary.HackerNewsApi
                   )

  def get_list(n, hacker_news_api \\ @hacker_news_api) do
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
    |> Stream.take(n)
    |> Enum.to_list()
  end

  ###########
  # PRIVATE
  ###########

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
