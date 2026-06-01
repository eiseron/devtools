defmodule Mix.Tasks.Eiseron.StripCommentsTest do
  use ExUnit.Case

  alias Mix.Tasks.Eiseron.StripComments

  test "removes a full-line comment" do
    src = """
    defmodule Foo do
      # explanatory comment
      def bar, do: :ok
    end
    """

    out = StripComments.strip(src)
    refute out =~ "explanatory comment"
    assert out =~ "def bar"
  end

  test "removes a trailing inline comment but keeps the code" do
    out = StripComments.strip("x = 1 # trailing note\n")
    refute out =~ "trailing note"
    assert out =~ "x = 1"
  end

  test "preserves @moduledoc and @doc strings" do
    src = """
    defmodule Foo do
      @moduledoc "Keeps this module doc."
      @doc "Keeps this function doc."
      def bar, do: :ok
    end
    """

    out = StripComments.strip(src)
    assert out =~ "Keeps this module doc."
    assert out =~ "Keeps this function doc."
  end

  test "does not touch a # inside a string literal" do
    out = StripComments.strip(~s|color = "#fff"\n|)
    assert out =~ ~s|"#fff"|
  end

  test "does not touch a #-leading line inside a heredoc" do
    src =
      Enum.join(
        [
          "defmodule Foo do",
          "  @moduledoc \"\"\"",
          "  # Markdown heading inside a heredoc — not a comment.",
          "  \"\"\"",
          "  def bar, do: :ok",
          "end",
          ""
        ],
        "\n"
      )

    out = StripComments.strip(src)
    assert out =~ "# Markdown heading inside a heredoc — not a comment."
  end

  test "leaves comment-free source semantically unchanged (still compiles)" do
    src = """
    defmodule Foo do
      def add(a, b), do: a + b
    end
    """

    out = StripComments.strip(src)
    assert out =~ "def add(a, b)"
  end
end
