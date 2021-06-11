defmodule HackerAggregator do
  require Logger
  alias HackerAggregator.Core.Pagination
  alias HackerAggregator.Core.Story

  @moduledoc """
  HackerAggregator keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @spec get_stories() :: list(%Story{})
  def get_stories() do
    HackerAggregator.Boundary.StoryServer.get_stories()
  end

  @spec get_page(page_number :: integer()) :: %Pagination{}
  def get_page(page_number) do
    HackerAggregator.Boundary.StoryServer.get_stories()
    |> Pagination.new(page_number: page_number)
  end

  @spec get_story() :: %Story{}
  def get_story() do
    HackerAggregator.Boundary.StoryServer.get_stories()
    |> Enum.random()
  end

  @spec get_story(id :: integer()) :: %Story{}
  def get_story(id) do
    HackerAggregator.Boundary.StoryServer.get_stories()
    |> Enum.find(&(&1.id == id))
  end
end
