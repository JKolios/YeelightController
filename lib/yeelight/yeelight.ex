defmodule Yeelight do
  use Application

  @impl true
  def start(_type, _args) do
    {:ok, supervisor} = Yeelight.Discovery.start_link()
    :ok = Yeelight.Discovery.DiscoveryServer.send_discovery_message()
    {:ok, supervisor}
  end

  def devices do
    Yeelight.Device.Registry.all()
  end

  def control_by_name(device_name) do
    Yeelight.Device.Registry.get_by_name(device_name) |> control
  end

  def control_by_ip(device_ip) do
    Yeelight.Device.Registry.get_by_ip(device_ip) |> control
  end

  def control(device) do
    device |> Yeelight.Control.start_link()
  end

  def all_devices(func_name, params) do
    Map.values(Yeelight.Device.Registry.all()) |> multiple_devices(func_name, params)
  end

  def multiple_devices(devices, func_name, params) do
    Enum.each(
      devices,
      fn device ->
        {:ok, controller} = device |> control
        apply(Yeelight.Control, func_name, [controller | params])
        Yeelight.Control.stop(controller)
      end
    )
  end
end
