defmodule HackerAggregator.Core.Story do
  @enforce_keys ~w/by id score title/a
  defstruct ~w/by id score title url text/a
end
