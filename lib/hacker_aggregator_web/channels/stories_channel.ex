defmodule HackerAggregatorWeb.StoriesChannel do
  use Phoenix.Channel
  alias HackerAggregator.Boundary.StoryServer

  require Logger

  def join("stories", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("all_stories", _message, socket) do
    stories = StoryServer.get_stories()
    {:reply, {:ok, stories}, socket}
  end

  def handle_in("new_story", story, socket) do
    {:reply, {:ok, story}, socket}
  end

  def handle_info(:after_join, socket) do
    Logger.error("jestem w handle info push")
    # TODO: find out how to trigger all_stories event from channel
    push(socket, "all_stories", %{})
    {:noreply, socket}
  end
end
