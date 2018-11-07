defmodule Yeelight.Device.Registry do
  use Agent
  require Logger

  def start_link(_) do
    Logger.debug("Device Registry started")
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def get_by_ip(device_ip) do
    Agent.get(__MODULE__, fn map -> Map.get(map, device_ip) end)
  end

  def get_by_name(name) do
    Agent.get(__MODULE__, fn map ->
      Enum.find(
        Map.values(map),
        nil,
        fn element -> element.device_name == name end
      )
    end)
  end

  def all do
    Agent.get(__MODULE__, fn map -> map end)
  end

  def put(device_ip, device) do
    Agent.update(__MODULE__, fn map -> Map.put(map, device_ip, device) end)
  end
end
