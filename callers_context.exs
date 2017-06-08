defmodule Mod do

  defmacro definfo do
    IO.puts "In macro's context #{__MODULE__}'"
    quote do
      IO.puts "In caller's context #{__MODULE__}"

      def friendly_info do
        IO.puts """
        My name is #{__MODULE__}
        My functions are #{inspect __info__(:functions)}
        """
      end
    end
  end
end
# no IO.puts ran with the above module in iex after compile by itself.

#adding the next module though and compiling did run the first two IO.puts (only if the Mod.definfo line is there.
defmodule MyModule do
  require Mod
  #commenting out the function and compiling this file did not run any of the IO.puts.
  Mod.definfo
end