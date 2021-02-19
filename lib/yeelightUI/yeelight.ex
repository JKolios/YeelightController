defmodule Yeelight do
  def devices do
    Yeelight.Device.Registry.all()
  end

  def device_by_name(device_name) do
    Yeelight.Device.Registry.get_by_name(device_name)
  end

  def device_by_ip(device_ip) do
    Yeelight.Device.Registry.get_by_ip(device_ip)
  end

  def command_device(device, func_name, params) do
    [device] |> multiple_devices(func_name, params)
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
        # Yeelight.Control.stop(controller)
      end
    )
  end

  def control(device) do
    device |> Yeelight.Control.start_link()
  end
end
