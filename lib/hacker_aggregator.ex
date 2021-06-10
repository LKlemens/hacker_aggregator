defmodule HackerAggregator do
  require Logger

  @moduledoc """
  HackerAggregator keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def get_stories() do
    HackerAggregator.Boundary.StoryServer.get_stories()
  end
end
