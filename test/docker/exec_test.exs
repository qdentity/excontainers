defmodule Docker.ExecTest do
  use ExUnit.Case, async: true

  describe "exec/2" do
    test "starts command inside container and instantly returns exec id" do
      with_running_container(fn container_id ->
        assert {:ok, exec_id} = Docker.Exec.exec(container_id, ["sleep", "1"])

        {:ok, exec_status} = Docker.Exec.inspect_exec(exec_id)
        assert exec_status.running
      end)
    end
  end

  describe "exec_and_wait/2" do
    test "runs command inside container and returns its exit code once it finishes" do
      with_running_container(fn container_id ->
        assert {:ok, {0, ""}} = Docker.Exec.exec_and_wait(container_id, ["sleep", "1"])
      end)
    end
  end

  # TODO: this is duplicated from Docker.Test -> remove duplication!
  defp with_running_container(block) do
    {stdout, _exit_code = 0} = System.cmd("docker", ["run", "-d", "--rm", "alpine:20201218", "sleep", "infinity"])
    container_id = String.trim(stdout)
    on_exit(fn -> remove_container(container_id) end)

    block.(container_id)
  end

  defp remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name], stderr_to_stdout: true)
end
