defmodule Support.DockerTestUtils do
  @sample_image "alpine:20201218"

  defmacro create_a_container() do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["create", unquote(@sample_image), "sleep", "infinity"])
      container_id = String.trim(stdout)

      on_exit(fn -> remove_container(container_id) end)

      container_id
    end
  end

  defmacro run_a_container() do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["run", "-d", "--rm", unquote(@sample_image), "sleep", "infinity"])
      container_id = String.trim(stdout)
      on_exit(fn -> remove_container(container_id) end)

      container_id
    end
  end

  def remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name], stderr_to_stdout: true)

  def image_exists?(image_name) do
    {stdout, _exit_code = 0} = System.cmd("docker", ["images", "-q", image_name])

    stdout != ""
  end

  def pull_image(image_name), do: System.cmd("docker", ["pull", image_name], stderr_to_stdout: true)

  def remove_image(image_name), do: System.cmd("docker", ["rmi", image_name], stderr_to_stdout: true)

  def short_id(docker_id), do: String.slice(docker_id, 1..11)
end
