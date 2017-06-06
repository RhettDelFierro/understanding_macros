defmodule Translator do

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :locales, accumulate: true,
                                                      persist: false
      import unquote(__MODULE__), only: [locale: 2]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :locales))
  end

  defmacro locale(name, mappings) do
    quote bind_quoted: [name: name, mappings: mappings] do
      @locales {name, mappings}
    end
  end

# the translations are the list of attribute registrations. - in this case @locales will have a list of registrations which are functions: {name, mappings}.
  def compile(translations) do
    #return AST for all translation function definitions.

    #locale code generation:
    translations_ast = for {locale, mappings} <- translations do #list of function generations
      deftranslations(locale, "", mappings)
    end

    quote do # we're generating the functions here. - producing the AST for the caller.
      def t(locale, path, bindings \\ [])
      unquote(translations_ast) #traslations_ast will be what t executes given the arguments to t.
      def t(_locale, _path, _bindings), do: {:error, :no_translation} #catch all
    end
  end

  defp deftranslations(locale, current_path, mappings) do
    #return an ast of the t/3 function defs for the given locale
    for {key, val} <- mappings do
      path = append_path(current_path, key)
      if Keyword.keyword?(val) do
        deftranslations(locale, path, val)
      else
        quote do
          def t(unquote(locale), unquote(path), bindings) do
            unquote(interpolate(val))
          end
        end
      end
    end
  end

  defp interpolate(string) do
#    string #interpolate bindings within string - what shows on the screen in the %{name} stuff in i18n.exs
    ~r/(?<head>)%{[^}]+}(?<tail>)/
    |> Regex.split(string, on: [:head, :tail])
    |> Enum.reduce("", fn
        <<"%{" <> rest>>, acc ->
          key = String.to_atom(String.rstrip(rest, ?}))
          quote do
            unquote(acc) <> to_string(Dict.fetch!(bindings, unquote(key)))
          end
        segment, acc -> quote do: (unquote(acc) <> unquote(segment))
        end)
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"
end