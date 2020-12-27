defmodule Docker.ContainerInfo do
  defstruct [:id, :status]

  alias __MODULE__

  defmodule Status do
    @allowed_statuses ~w(created running paused restarting removing exited dead)
    @type state :: :created | :running | :paused | :restarting | :removing | :exited | :dead
    defguardp is_allowed(status) when status in @allowed_statuses

    defstruct [:state, :running]

    def parse_status(status_as_string) when is_allowed(status_as_string), do: String.to_atom(status_as_string)
    def parse_status(_), do: nil
  end

  def running?(container), do: container.status.running

  def parse_docker_response(json_info) do
    %ContainerInfo{
      id: json_info["Id"],
      status: %ContainerInfo.Status{
        state: ContainerInfo.Status.parse_status(json_info["State"]["Status"]),
        running: json_info["State"]["Running"]
      }
    }
  end
end