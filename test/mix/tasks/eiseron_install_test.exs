defmodule Mix.Tasks.Eiseron.InstallTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  setup do
    tmp = Path.join(System.tmp_dir!(), "eiseron_install_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    original = File.cwd!()
    File.cd!(tmp)
    on_exit(fn ->
      File.cd!(original)
      File.rm_rf!(tmp)
    end)
    :ok
  end

  test "creates .credo.exs when it does not exist" do
    Mix.Tasks.Eiseron.Install.run([])
    assert File.exists?(".credo.exs")
  end

  test ".credo.exs references all Eiseron.Credo.Check modules" do
    Mix.Tasks.Eiseron.Install.run([])
    content = File.read!(".credo.exs")
    assert content =~ "Eiseron.Credo.Check.Readability.NoComments"
    assert content =~ "Eiseron.Credo.Check.Testing.OneAssertPerTest"
    assert content =~ "Eiseron.Credo.Check.Design.NoSideEffectsInTransformer"
    assert content =~ "Eiseron.Credo.Check.Refactor.StrictFunctionArity"
  end

  test "does not overwrite existing .credo.exs" do
    File.write!(".credo.exs", "existing content")
    capture_io(fn -> Mix.Tasks.Eiseron.Install.run([]) end)
    assert File.read!(".credo.exs") == "existing content"
  end

  test "prints checklist mentioning eiseron_devtools dep and precommit alias" do
    output = capture_io(fn -> Mix.Tasks.Eiseron.Install.run([]) end)
    assert output =~ "eiseron_devtools"
    assert output =~ "precommit"
  end
end
