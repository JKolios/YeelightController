defmodule DeviceRegistry do
    use Agent

    def start_link do
      Agent.start_link(fn -> Map.new end, name: __MODULE__)
    end

    def get(device_ip) do
        Agent.get(__MODULE__, fn map -> Map.get(map, device_ip) end)
    end

    def all do
        Agent.get(__MODULE__, fn map -> map end)
    end

    def put(device_ip, device) do
        Agent.update(__MODULE__, fn map -> Map.put(map, device_ip,  device) end)
    end  
  end