defmodule Mix.Tasks.Eiseron.StripComments do
  use Mix.Task

  @shortdoc "Strip Elixir line comments from source (token-aware, preserves docs/heredocs/sigils)"

  @moduledoc """
  Removes `#` line comments from Elixir source while leaving everything else
  intact — `@moduledoc`/`@doc` strings, heredocs, and `~H`/`~S` sigils are AST
  literals, not comments, so they are preserved.

  Parsing is token-aware (Sourceror), so a `#` inside a string or heredoc is
  never mistaken for a comment.

      mix eiseron.strip_comments              # default globs (lib/test/config/priv)
      mix eiseron.strip_comments lib/foo.ex   # explicit paths/globs

  Intended for cleaning generated boilerplate (e.g. `mix phx.new`) so it meets
  the Eiseron no-comments standard.
  """

  @default_globs ~w(
    lib/**/*.ex lib/**/*.exs
    test/**/*.ex test/**/*.exs
    config/**/*.exs
    priv/**/*.exs
  )

  @impl Mix.Task
  def run(args) do
    globs = if args == [], do: @default_globs, else: args

    globs
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.each(&strip_file/1)
  end

  defp strip_file(path) do
    original = File.read!(path)
    stripped = strip(original)

    if stripped != original do
      File.write!(path, stripped)
      Mix.shell().info("stripped comments: #{path}")
    end
  end

  @doc "Returns `source` with all `#` line comments removed."
  def strip(source) do
    source
    |> Sourceror.parse_string!()
    |> Macro.prewalk(&drop_comments/1)
    |> Sourceror.to_string()
    |> ensure_trailing_newline()
  end

  defp drop_comments({form, meta, args}) when is_list(meta) do
    {form,
     meta |> Keyword.replace(:leading_comments, []) |> Keyword.replace(:trailing_comments, []),
     args}
  end

  defp drop_comments(node), do: node

  defp ensure_trailing_newline(string), do: String.trim_trailing(string) <> "\n"
end
