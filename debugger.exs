defmodule Debugger do

  @doc """
  iex(1)> c "debugger.exs"
  [Debugger]
  iex(2)> remote_api_call = fn -> IO.puts("calling remote API...") end
  #Function<20.52032458/0 in :erl_eval.expr/5>
  iex(3)> require Debugger
  Debugger
  iex(4)> Debugger.log(remote_api_call.()) ##########this obviously just called the function, but did not step into the quote block because we're not in :dev':
  calling remote API...
  :ok
  iex(5)> Application.put_env(:debugger, :log_level, :debug)
  :ok
  iex(6)> Debugger.log(remote_api_call.())
  calling remote API...
  ==========
  :ok
  ==========
  :ok
  iex(7)>


  ####### further:
  iex(7)> quote do: remote_api_call.()
  {{:., [], [{:remote_api_call, [], Elixir}]}, [], []}

  in the example before the function call is executed and evaluated and it's like the result is stored
  ...and bind_quoted: makes sure it doesn't re-evaluate it again so it doesn't run it's code again where we
  don't want it to. ("accidental re-evaluation" - pg. 31)

  """
  defmacro log(expression) do
    if Application.get_env(:debugger, :log_level) == :debug do
      quote bind_quoted: [expression: expression] do
        IO.puts "=========="
        IO.inspect expression
        IO.puts "=========="
        expression
      end
    else
      expression
    end
  end
end