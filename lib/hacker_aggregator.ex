defmodule HackerAggregator do
  alias HackerAggregator.Core.Story
  require Logger

  @moduledoc """
  HackerAggregator keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def get_list(n) do
    list =
      case HackerAggregator.Boundary.HackerNewsApi.fetch_top_stories() do
        {:ok, list} ->
          list

        {:error, msg} ->
          Logger.error("fetching list of stories failed: #{inspect(msg)}")
          []
      end

    list
    |> Stream.map(&get_story(&1))
    |> Stream.filter(&(&1 != %{}))
    |> Stream.take(n)
    |> Enum.to_list()
  end

  ###########
  # PRIVATE
  ###########

  defp get_story(story_id) do
    story =
      HackerAggregator.Boundary.HackerNewsApi.fetch_story(story_id)
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
