defmodule Loop do

  defmacro while(expression, do: block) do
    quote do
      try do
        for _ <- Stream.cycle([:ok]) do
          if unquote(expression) do
            unquote(block)
          end
          else
            Loop.break #remember, you cannot call break/0 by itself here because this code is injected into the caller's context and there may be no break/0 function there.
        end
      catch
        :break -> ok
      end
    end
  end

  def break, do: throw :break
end