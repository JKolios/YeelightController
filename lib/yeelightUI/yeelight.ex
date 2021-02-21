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
    [device] |> command_multiple_devices(func_name, params)
  end

  def command_all_devices(func_name, params) do
    Map.values(Yeelight.Device.Registry.all()) |> command_multiple_devices(func_name, params)
  end

  def command_multiple_devices(devices, func_name, params) do
    Enum.each(
      devices,
      fn device ->
        Logger.debug("Using controller: #{device.controller |> inspect}")
        Logger.debug("Func name: #{func_name |> inspect}")
        Logger.debug("Params: #{params |> inspect}")
        result = apply(Yeelight.Control.Commands, func_name, [device.controller | params])
        Logger.debug("Command result: #{result}")
        if result == :error do
          Logger.debug("Command error")
        end
      end
    )
  end
end
