defmodule ControlFlow do

  @doc "when if expression has no else block"
  defmacro my_if(expr, do: if_block), do: if(expr, do: if_block, else: nil)

  @doc "when if expression has an else block"
  defmacro my_if(expr, do: if_block, else: else_block) do
    quote do
      case unquote(expr) do
        result when result in [false, nil] -> unquote(else_block)
        _ -> unquote(if_block)
      end
    end
  end
end