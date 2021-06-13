defmodule HackerAggregator.Boundary.StoryServer do
  use GenServer

  alias HackerAggregator.Core.Story

  require Logger

  @number_of_stories 50
  @seconds 300

  ###############
  ##### API #####
  ###############

  def start_link(_opt \\ nil) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_stories() do
    Logger.info("Get list of stories from StoryServer")
    GenServer.call(__MODULE__, :get)
  end

  #####################
  ##### CALLBACKS #####
  #####################

  @impl GenServer
  def init(:ok) do
    Process.flag(:trap_exit, true)
    send(self(), :fetch)
    {:ok, %{stories: [], pid: nil}}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state.stories, state}
  end

  @impl GenServer
  def handle_info(:fetch, state) do
    Logger.info("Start fetch stories task")
    task = Task.async(&fetch_stories/0)
    {:noreply, Map.put(state, :pid, task.pid)}
  end

  @impl GenServer
  def handle_info({_task, {:stories, result}}, state) do
    Logger.info("Updating StoryServer state with new stories if any")

    state =
      result
      |> Enum.reduce(state, fn story, state ->
        update_in(state.stories, &update_stories(story, &1))
      end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:EXIT, _pid, :normal}, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, reason}, state) do
    if pid == state.pid do
      Logger.error("Task with fetch_stories/0 failed, reason: #{inspect(reason)}")
      schedule_work()
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.warn("#{__MODULE__} terminated with reason: #{inspect(reason)}")
    :ok
  end

  ###########
  # PRIVATE
  ###########

  defp schedule_work() do
    Process.send_after(__MODULE__, :fetch, :timer.seconds(@seconds))
  end

  @spec fetch_stories() :: {:stories, list()}
  defp fetch_stories() do
    list = HackerAggregator.Boundary.FetchStories.get_list(@number_of_stories)
    schedule_work()
    {:stories, list}
  end

  @spec update_stories(story :: %Story{}, stories :: [%Story{}]) :: [%Story{}]
  defp update_stories(story, stories) do
    if Enum.member?(stories, story) do
      stories
    else
      HackerAggregatorWeb.Endpoint.broadcast!("stories", "new_story", story)
      [story | stories]
    end
  end
end
