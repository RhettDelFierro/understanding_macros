defmodule Assertion do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true #creates a module attribute @tests where the macro injects this code
      @before_compile unquote(__MODULE__)
    end
  end

  @doc "called right before compile time is finished, so that run/0 will have the list of test function stored on @tests so it can refence it"
  defmacro __before_compile__(_env) do
    quote do
      def run, do: Assertion.Test.run(@tests, __MODULE__)  # remember, this in injected into MathTest which will the the use module's context.'
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do # this injected code will leave us with an accumulated list of test metadata (because of @tests and DEFIED FUNCTIONS to perform test-case evaluation
      @tests {unquote(test_func), unquote(description)} # accumulate the test_func reference and description in @tests - remember - @tests we have as a tuple and we also converted test_func into an atom. - it probably looks like this after the unquotes: {:some_test_we_made_up, "math_test_we_made_up"}
      def unquote(test_func)(), do: unquote(test_block) # test_func :: atom AND test_block :: the block of code we want out test to execute.
    end
  end


  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end

end

defmodule Assertion.Test do
  def run(tests, module) do
    Enum.each tests, fn {test_func, description} ->

      case apply(module, test_func, []) do
        :ok             -> IO.write "."
        {:fail, reason} -> IO.puts """

          =============================================
           FAILURE: #{description}
          =============================================
          #{reason}
          """
      end
    end
  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end

  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected:
      to be equal to: #{rhs}
      """}
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end

  def assert(:>, lhs, rhs) do
    {:fail, """
      Excepted:           #{lhs}
      to be greater than: #{rhs}
      """
    }
  end

end

# defmodule MathTest do
##  require Assertion
##  Assertion.extend
#  use Assertion
#end