defmodule HackerAggregator.Boundary.FetchStories do
  alias HackerAggregator.Core.Story

  def fetch_top_stories() do
    "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty"
    |> http_get(&Jason.decode/1, "No best stories found")
  end

  def fetch_story(story_id) do
    "https://hacker-news.firebaseio.com/v0/item/#{story_id}.json?print=pretty"
    |> http_get(&parse_story/1, "No story found")
  end

  ###########
  # PRIVATE
  ###########

  defp parse_story(story_id) do
    with {:ok, %{} = story_data} <-
           Jason.decode(story_id) do
      story_data
      |> from_map()
    else
      data ->
        {:error, %{msg: "story parse error", data: data}}
    end
  end

  def from_map(%{"url" => _} = story_data) do
    with %{
           "by" => by,
           "id" => id,
           "score" => score,
           "title" => title,
           "type" => type = "story",
           "url" => url
         } <- story_data do
      {:ok, struct(Story, by: by, id: id, score: score, title: title, url: url, type: type)}
    else
      data -> {:error, %{msg: "story has no all required keys", data: data}}
    end
  end

  def from_map(%{"text" => _} = story_data) do
    with %{
           "by" => by,
           "id" => id,
           "score" => score,
           "title" => title,
           "type" => type = "story",
           "text" => text
         } <- story_data do
      {:ok, struct(Story, by: by, id: id, score: score, title: title, text: text, type: type)}
    else
      data -> {:error, %{msg: "story has no all required keys", data: data}}
    end
  end

  defp http_get(url, decode_fun, error_msg) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> decode_fun.()

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, error_msg}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
