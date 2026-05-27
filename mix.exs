defmodule EiseronDevtools.MixProject do
  use Mix.Project

  def project do
    [
      app: :eiseron_devtools,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  defp description do
    "Elixir dev toolchain meta-package for Eiseron products."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "Source" => "https://github.com/eiseron/devtools"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:eiseron_credo_checks, git: "https://github.com/eiseron/credo-checks.git", tag: "v0.1.1"},
      {:sobelow, "~> 0.13"},
      {:mix_audit, "~> 2.1"}
    ]
  end
end
