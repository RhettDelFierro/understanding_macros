defmodule Loop do

  @doc """
  Infinite loop
  ## Example
    iex(1)> while true do
    ...(1)>   IO.puts "looping"
    ...(1)> end
    looping!
    looping!
    looping!
    ^C^C
  """
  defmacro while(expression, do: block) do
    quote do
      for _ <- Stream.cycle([:ok]) do
        if unquote(expression) do
          unquote(block)
        end
        else
          #break out of loop
      end
    end
  end
end