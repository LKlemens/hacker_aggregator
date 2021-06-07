defmodule HackerAggregator do
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
          IO.inspect("ERROR: fetching list of stories", msg)
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
        IO.inspect("ERROR: when parsing story", data)
        %{}
    end
  end
end
