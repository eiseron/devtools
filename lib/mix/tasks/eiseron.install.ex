defmodule Mix.Tasks.Eiseron.Install do
  use Mix.Task

  @shortdoc "Install Eiseron dev toolchain config into the current project"

  @credo_template """
  %{
    configs: [
      %{
        name: "default",
        files: %{
          included: ["lib/", "test/"],
          excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
        },
        requires: [],
        strict: true,
        checks: %{
          enabled: [
            {Eiseron.Credo.Check.Readability.NoComments, []},
            {Eiseron.Credo.Check.Testing.OneAssertPerTest, []},
            {Eiseron.Credo.Check.Design.NoSideEffectsInTransformer, []},
            {Eiseron.Credo.Check.Refactor.StrictFunctionArity, [max_arity: 3]}
          ]
        }
      }
    ]
  }
  """

  @impl Mix.Task
  def run(_args) do
    write_credo_config()
    print_checklist()
  end

  defp write_credo_config do
    path = ".credo.exs"

    if File.exists?(path) do
      Mix.shell().info("#{path} already exists — skipping")
    else
      File.write!(path, @credo_template)
      Mix.shell().info("created #{path}")
    end
  end

  defp print_checklist do
    Mix.shell().info("""

    Eiseron dev toolchain installed. Checklist:

    [ ] Add to mix.exs deps:
          {:eiseron_devtools, git: "https://github.com/eiseron/devtools.git",
           tag: "v0.1.0", only: [:dev, :test], runtime: false}

    [ ] Add precommit alias to mix.exs:
          precommit: [
            "compile --warnings-as-errors",
            "deps.unlock --unused",
            "format",
            "deps.audit",
            "sobelow --exit",
            "credo --strict",
            "test --cover"
          ]

    [ ] Run: mix deps.get
    [ ] Run: mix precommit
    """)
  end
end
