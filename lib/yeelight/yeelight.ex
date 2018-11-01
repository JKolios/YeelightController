defmodule Yeelight do
  def start_discovery do
    Yeelight.DeviceRegistry.start_link()
    {:ok, discovery_server} = Yeelight.Discover.start_link()
    {:ok, advertise_server} = Yeelight.Discover.Advertise.start_link()
    discovery_server |> Yeelight.Discover.send_discover_message()
    {:ok, {discovery_server, advertise_server}}
  end

  def devices do
    Yeelight.DeviceRegistry.all
  end

  def control_by_name(device_name) do
    Yeelight.DeviceRegistry.get_by_name(device_name) |> control
  end

  def control_by_ip(device_ip) do
    Yeelight.DeviceRegistry.get_by_ip(device_ip) |> control
  end

  def control(device) do
    device |> Yeelight.Control.start_link()  
  end

  def all_devices(func_name, params) do
    Enum.each(
      Map.values(Yeelight.DeviceRegistry.all()),
      fn device ->
        {:ok, controller} = device |> control
        apply(Yeelight.Control, func_name, [controller | params])
        Yeelight.Control.stop(controller)
      end
    )
  end
end
