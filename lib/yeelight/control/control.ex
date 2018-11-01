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

  def set_name(server, name) do
    control(server, "set_name", [name])
  end

  def set_default(server) do
    control(server, "set_default", [])
  end

  defp control(server, method, params) do
    GenServer.call(server, {:control, method, params})
  end

  # Callbacks

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

  def handle_call({:control, method, params}, _from, state) do
    payload = Yeelight.Control.Message.construct(method, params)
    Logger.debug("Sending control payload: #{payload}")
    :ok = :gen_tcp.send(state[:socket], payload)
    {:reply, :ok, state}
  end

  def handle_info({:tcp, _socket, msg}, state) do
    Logger.debug("Received RESULT message:#{msg}")
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.debug("Terminating the control server. Reason: #{reason}")
    :ok = :gen_tcp.close(state[:socket])
  end
end
