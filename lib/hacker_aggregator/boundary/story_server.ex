defmodule HackerAggregator.Boundary.StoryServer do
  use GenServer

  require Logger

  @number_of_stories 50
  @seconds 300

  ###############
  ##### API #####
  ###############

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_stories() do
    GenServer.call(__MODULE__, :get)
  end

  #####################
  ##### CALLBACKS #####
  #####################

  @impl GenServer
  def init(:ok) do
    Process.flag(:trap_exit, true)
    send(self(), :fetch)
    table = :ets.new(:stories, [:ordered_set, :private, :named_table])
    {:ok, %{table: table, pid: nil}}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    # TODO: find out how to take down stories in property order without reversing
    {:reply, :ets.tab2list(:stories) |> Enum.reverse(), state}
  end

  @impl GenServer
  def handle_info(:fetch, state) do
    task = Task.async(&fetch_stories/0)
    {:noreply, Map.put(state, :pid, task.pid)}
  end

  @impl GenServer
  def handle_info({_task, {:stories, result}}, state) do
    result
    |> Enum.map(&insert_story/1)

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
    list = HackerAggregator.get_list(@number_of_stories)
    schedule_work()
    {:stories, list}
  end

  @spec insert_story(story :: struct()) :: nil | true | list()
  def insert_story(story) do
    if new_story?(story) do
      :ets.insert(:stories, {System.system_time(:microsecond), story})
    end
  end

  defp new_story?(story) do
    :ets.match(:stories, {:_, story}) == []
  end
end
