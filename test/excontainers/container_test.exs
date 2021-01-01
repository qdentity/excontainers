defmodule Excontainers.ContainerTest do
  use ExUnit.Case, async: true

  alias Excontainers.Container

  describe "new/2" do
    test "creates container with given image" do
      assert Container.new("some-image") == %Docker.ContainerConfig{image: "some-image"}
    end

    test "when exposing ports, exposes them for TCP by default" do
      container_config = Container.new("any", exposed_ports: [1111, "2222/udp"])
      assert container_config.exposed_ports == ["1111/tcp", "2222/udp"]
    end
  end

  describe "start/2" do
    test "creates and starts a container with the given config" do
      container_config = Container.new("alpine", cmd: ["sleep", "infinity"])

      {:ok, container_id} = Container.start(container_config)

      {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps"])
      assert running_containers_output =~ String.slice(container_id, 1..11)
    end
  end

  describe "mapped_port/2" do
    @http_echo_container Container.new(
      "hashicorp/http-echo:0.2.3",
      cmd: ["-listen=:8080", ~s(-text="hello world")],
      exposed_ports: [8080]
    )

    test "gets the host port corresponding to a mapped port in the container" do
      container_id = run_a_container(@http_echo_container)
      port = Container.mapped_port(container_id, 8080)
      {:ok, response} = Tesla.get("http://localhost:#{port}/")

      assert response.body =~ "hello world"
    end
  end


  defp run_a_container(container) do
    {:ok, container_id} = Container.start(container)
    on_exit(fn -> Container.stop(container_id, timeout_seconds: 1) end)
    container_id
  end
end
