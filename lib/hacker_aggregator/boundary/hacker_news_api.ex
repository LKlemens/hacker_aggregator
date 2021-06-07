defmodule HackerAggregator.Boundary.HackerNewsApi do
  def fetch_top_stories() do
    "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty"
    |> http_get("No best stories found")
  end

  def fetch_story(story_id) do
    "https://hacker-news.firebaseio.com/v0/item/#{story_id}.json?print=pretty"
    |> http_get("No story found")
  end

  ###########
  # PRIVATE
  ###########
  defp http_get(url, error_msg) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, error_msg}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
