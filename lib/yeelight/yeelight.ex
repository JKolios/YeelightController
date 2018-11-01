defmodule Yeelight do
  def start_discovery do
    Yeelight.DeviceRegistry.start_link()
    {:ok, discovery_server} = Yeelight.Discover.start_link()
    {:ok, advertise_server} = Yeelight.Discover.Advertise.start_link()
    discovery_server |> Yeelight.Discover.send_discover_message()
    {:ok, {discovery_server, advertise_server}}
  end

  def get_controller(device_name) do
    device = Yeelight.DeviceRegistry.get_by_name(device_name)
    device |> Yeelight.Control.start_link()
  end
end
