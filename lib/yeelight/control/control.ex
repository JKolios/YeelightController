defmodule Yeelight.Control do
  require Logger
  use GenServer

  @initial_state %{socket: nil, device: nil}

  def start_link(device) do
    GenServer.start_link(__MODULE__, %{@initial_state | device: device})
  end

  def stop(server, reason \\ :normal) do
    Logger.debug("Shutting down the control server")
    GenServer.stop(server, reason)
  end

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
    control(server, "set_power", [power, effect, duration, mode])
  end

  def toggle(server) do
    control(server, "toggle", [])
  end

  def set_default(server) do
    control(server, "set_default", [])
  end

  def start_cf(server, state_count, action, cf_expression) do
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
    control(server, "adjust_bright", [percentage, duration])
  end

  def adjust_ct(server, percentage, duration) do
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
    GenServer.call(server, {:control, method, params})
  end

  # Callbacks

  @impl true
  def init(state) do
    Yeelight.Control.MessageIdCounter.start_link()
    opts = [:binary, active: true]

    {:ok, socket} =
      :gen_tcp.connect(
        Yeelight.Device.ip(state[:device]),
        Yeelight.Device.port(state[:device]),
        opts
      )

    Logger.debug("Opened connection to device: #{state.device.location}")
    {:ok, %{state | socket: socket}}
  end

  @impl true
  def handle_call({:control, method, params}, _from, state) do
    payload = Yeelight.Control.Message.construct(method, params)
    Logger.debug("Sending control payload: #{payload}")
    :ok = :gen_tcp.send(state[:socket], payload)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:tcp, _socket, msg}, state) do
    Logger.debug("Received message on control connection: #{msg}")

    cond do
      is_result_message?(msg) ->
        Logger.debug("Message identified as RESULT")

      is_notification_message?(msg) ->
        Logger.debug("Message identified as NOTIFICATION")
        Yeelight.Device.update_from_notification(state[:device], msg)

      is_error_message?(msg) ->
        Logger.debug("Message identified as ERROR")
        Logger.debug("Error message: #{Poison.Parser.parse!(msg)["error"]["message"]}")

      true ->
        Logger.debug("Message discarded. This indicates a bug")
    end

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug("Terminating the control server. Reason: #{reason}")
    :ok = :gen_tcp.close(state[:socket])
  end

  def is_result_message?(msg) do
    Regex.match?(~r/\"result\"/, msg)
  end

  def is_notification_message?(msg) do
    Regex.match?(~r/{\"method\":\"props\"/, msg)
  end

  def is_error_message?(msg) do
    Regex.match?(~r/\"error\":/, msg)
  end
end
