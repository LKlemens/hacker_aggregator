defmodule HackerAggregator.Core.Story do
  @enforce_keys ~w/by id title/a
  defstruct ~w/by id title url text/a
end
