defmodule Yeelight.Control.Commands do
  require Logger
  # Commands as defined by the Yeelight Inter-Operation Spec

  def get_prop(server, props) do
    control(server, "get_prop", props)
  end

  def set_ct_abx(server, ct_value, effect, duration) do
    control(server, "set_ct_abx", [ct_value, effect, duration])
  end

  def set_rgb(server, rgb_value, effect, duration) do
    control(server, "set_rgb", [rgb_value, effect, duration])
  end

  def set_hsv(server, hue, sat, effect, duration) do
    control(server, "set_hsv", [hue, sat, effect, duration])
  end

  def set_bright(server, brightness, effect, duration) do
    control(server, "set_bright", [brightness, effect, duration])
  end

  def set_power(server, power, effect, duration, mode \\ 0) do
    duration = unless is_integer(duration), do: Integer.parse(duration) |> elem(0), else: duration
    control(server, "set_power", [power, effect, duration, mode])
  end

  def toggle(server) do
    control(server, "toggle", [])
  end

  def set_default(server) do
    control(server, "set_default", [])
  end

  def start_cf(server, state_count, action, cf_expression) do
    state_count = unless is_integer(state_count), do: Integer.parse(state_count) |> elem(0), else: state_count
    action = unless is_integer(action), do: Integer.parse(action) |> elem(0), else: action
    control(server, "start_cf", [state_count, action, cf_expression])
  end

  def stop_cf(server) do
    control(server, "stop_cf", [])
  end

  def set_scene(server, class, val1, val2, val3) do
    control(server, "set_scene", [class, val1, val2, val3])
  end

  def cron_add(server, type, value) do
    control(server, "cron_add", [type, value])
  end

  def cron_get(server, type) do
    control(server, "cron_get", [type])
  end

  def cron_del(server, type) do
    control(server, "cron_del", [type])
  end

  def set_adjust(server, action, prop) do
    control(server, "set_adjust", [action, prop])
  end

  def set_music(server, action, host, port) do
    control(server, "set_music", [action, host, port])
  end

  def set_name(server, name) do
    Logger.debug("Setting name: #{name |> inspect}")
    control(server, "set_name", [name])
  end

  def bg_set_rgb(server, rgb_value, effect, duration) do
    control(server, "bg_set_rgb", [rgb_value, effect, duration])
  end

  def bg_set_hsv(server, hue, sat, effect, duration) do
    control(server, "bg_set_hsv", [hue, sat, effect, duration])
  end

  def bg_set_ct_abx(server, ct_value, effect, duration) do
    control(server, "bg_set_ct_abx", [ct_value, effect, duration])
  end

  def bg_start_cf(server, state_count, action, cf_expression) do
    control(server, "bg_start_cf", [state_count, action, cf_expression])
  end

  def bg_stop_cf(server) do
    control(server, "bg_stop_cf", [])
  end

  def bg_set_scene(server, class, val1, val2, val3) do
    control(server, "bg_set_scene", [class, val1, val2, val3])
  end

  def bg_set_default(server) do
    control(server, "bg_set_default", [])
  end

  def bg_set_power(server, power, effect, duration, mode \\ 0) do
    control(server, "bg_set_power", [power, effect, duration, mode])
  end

  def bg_set_bright(server, brightness, effect, duration) do
    control(server, "bg_set_bright", [brightness, effect, duration])
  end

  def bg_set_adjust(server, action, prop) do
    control(server, "bg_set_adjust", [action, prop])
  end

  def bg_toggle(server) do
    control(server, "bg_toggle", [])
  end

  def dev_toggle(server) do
    control(server, "dev_toggle", [])
  end

  def adjust_bright(server, percentage, duration) do
    percentage = unless is_integer(percentage), do: Integer.parse(percentage) |> elem(0), else: percentage
    duration = unless is_integer(duration), do: Integer.parse(duration) |> elem(0), else: duration
    control(server, "adjust_bright", [percentage, duration])
  end

  def adjust_ct(server, percentage, duration) do
    percentage = unless is_integer(percentage), do: Integer.parse(percentage) |> elem(0), else: percentage
    duration = unless is_integer(duration), do: Integer.parse(duration) |> elem(0), else: duration
    control(server, "adjust_ct", [percentage, duration])
  end

  def adjust_color(server, percentage, duration) do
    control(server, "adjust_color", [percentage, duration])
  end

  def bg_adjust_bright(server, percentage, duration) do
    control(server, "bg_adjust_bright", [percentage, duration])
  end

  def bg_adjust_ct(server, percentage, duration) do
    control(server, "bg_adjust_ct", [percentage, duration])
  end

  def bg_adjust_color(server, percentage, duration) do
    control(server, "bg_adjust_color", [percentage, duration])
  end

  # Helper/Shortcut commands

  def set_color_scene(server, color, brightness) do
    set_scene(server, "color", color, brightness, nil)
  end

  def set_hsv_scene(server, hue, saturation, brightness) do
    set_scene(server, "hsv", hue, saturation, brightness)
  end

  def set_ct_scene(server, ct, brightness) do
    set_scene(server, "ct", ct, brightness, nil)
  end

  def set_cf_scene(server, state_count, action, cf_expression) do
    set_scene(server, "cf", state_count, action, cf_expression)
  end

  def set_auto_delay_off_scene(server, brightness, off_timer) do
    set_scene(server, "auto_delay_off", brightness, off_timer, nil)
  end

  defp control(server, method, params) do
    case GenServer.call(server, {:control, method, params}) do
      :ok ->
        Logger.debug("Control action successful")
        :ok
      :error ->
        Logger.debug("Control action failed")
        :error
    end
  end
end