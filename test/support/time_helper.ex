defmodule SonaComments.Support.TimeHelper do
  @moduledoc """
  A module to wait for async assertions to pass.

  ## Examples

  iex> wait_until(fn ->
        assert render(view) =~ "something rendered"
      end)
  """

  def wait_until(fun), do: wait_until(1_000, fun)

  def wait_until(0, fun), do: fun.()

  def wait_until(timeout, fun) do
    fun.()
  rescue
    ExUnit.AssertionError ->
      :timer.sleep(10)
      wait_until(max(0, timeout - 10), fun)
  end
end
