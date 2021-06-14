defmodule HackerAggregatorWeb.StoriesChannel do
  use Phoenix.Channel
  alias HackerAggregator.Boundary.StoryServer

  require Logger

  def join("stories", _message, socket) do
    stories = StoryServer.get_stories()
    {:ok, stories, socket}
  end

  def handle_in("new_story", story, socket) do
    {:reply, {:ok, story}, socket}
  end
end
