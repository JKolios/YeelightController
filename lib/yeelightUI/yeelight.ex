defmodule Yeelight do
  require Logger

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
        if is_nil(device.controller) do 
          create_device_controller(device)  
        end  
        updated_device = Yeelight.Device.Registry.get_by_ip(Yeelight.Device.ip(device))
        Logger.debug("Using controller: #{updated_device.controller |> inspect}")
        result = apply(Yeelight.Control.Commands, func_name, [updated_device.controller | params])
        Logger.debug("Command result: #{result}")
        if result == :error do
          Logger.debug("Command error")
        end
      end
    )
  end

  defp create_device_controller(device) do
    Logger.debug("Opening connection to device")
    {:ok, controller} = Yeelight.Control.start_link(device)
    device = %{device | controller: controller}
    Logger.debug("Device after connection opening: #{device |> inspect}")
    Yeelight.Device.Registry.put(Yeelight.Device.ip(device), device)
    controller
  end
end
