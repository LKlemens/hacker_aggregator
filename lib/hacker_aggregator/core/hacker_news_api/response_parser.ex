defmodule HackerAggregator.Core.HackerNewsApi.ResponseParser do
  def parse_story({:ok, story_data}) do
    story_data
    |> from_map()
  end

  def parse_story(data) do
    {:error, %{msg: "bad input provided", data: data}}
  end

  ###########
  # PRIVATE
  ###########

  defp from_map(%{"url" => _} = story_data) do
    with %{
           "by" => by,
           "id" => id,
           "score" => score,
           "title" => title,
           "type" => type = "story",
           "url" => url
         } <- story_data do
      {:ok,
       struct(HackerAggregator.Core.Story,
         by: by,
         id: id,
         score: score,
         title: title,
         url: url,
         type: type
       )}
    else
      data -> {:error, %{msg: "story has no all required keys", data: data}}
    end
  end

  defp from_map(%{"text" => _} = story_data) do
    with %{
           "by" => by,
           "id" => id,
           "score" => score,
           "title" => title,
           "type" => type = "story",
           "text" => text
         } <- story_data do
      {:ok,
       struct(HackerAggregator.Core.Story,
         by: by,
         id: id,
         score: score,
         title: title,
         text: text,
         type: type
       )}
    else
      data -> {:error, %{msg: "story has no all required keys", data: data}}
    end
  end

  defp from_map(undefined) do
    {:error, %{msg: "invalid argument", data: undefined}}
  end
end
