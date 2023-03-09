defmodule Yeelight.Control do
  require Logger
  use GenServer

  @initial_state %{socket: nil, ip: nil, port: nil}

  def start_link(ip, port) do
    GenServer.start_link(__MODULE__, %{@initial_state | ip: ip, port: port})
  end

  # Callbacks
  @impl true
  def init(state) do
    Yeelight.Control.MessageIdCounter.start_link()

    case init_control_socket(state.ip, state.port) do
      {:ok, socket} ->
        {:ok, %{state | socket: socket}}

      {:error, _} ->
        {:stop, "Socket could not be opened", state}
    end
  end

  @impl true
  def handle_call({:control, method, params}, _from, state) do
    payload = Yeelight.Control.Message.construct(method, params)
    Logger.debug("Sending control payload: #{payload}")
    Logger.debug("Using socket: #{state[:socket] |> inspect}")

    case :gen_tcp.send(state[:socket], payload) do
      :ok ->
        Logger.debug("Control payload sent")
        {:reply, :ok, state}

      {:error, cause} ->
        Logger.debug("Control payload send error, cause: #{cause |> inspect}")
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_info({:tcp, socket, msg}, state) do
    Logger.debug("Received message on control connection: #{msg}")
    :inet.setopts(socket, active: :once)

    cond do
      is_result_message?(msg) ->
        Logger.debug("Message identified as RESULT")

      is_notification_message?(msg) ->
        Logger.debug("Message identified as NOTIFICATION")
        Yeelight.Device.update_from_notification(state.ip, msg)

      is_error_message?(msg) ->
        Logger.debug("Message identified as ERROR")
        Logger.debug("Error message: #{msg}")

      true ->
        Logger.debug("Message discarded. This indicates a bug")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, state) do
    Logger.debug("TCP socket #{socket |> inspect} closed, trying to reopen")

    case init_control_socket(state.ip, state.port) do
      {:ok, socket} ->
        {:ok, %{state | socket: socket}}

      {:error, _} ->
        {:stop, "Socket could not be opened", state}
    end
  end

  @impl true
  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.error("Tcp error: #{inspect(reason)}")
    {:stop, "Tcp error: #{inspect(reason)}", state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug("Terminating the control server. Reason: #{inspect(reason)}")
    :ok = :gen_tcp.close(state[:socket])
  end

  defp init_control_socket(ip, port) do
    Logger.debug("Opening TCP socket to #{ip |> inspect}:#{port}")
    opts = [:binary, active: true, reuseaddr: true, keepalive: false]

    case :gen_tcp.connect(ip, port, opts) do
      {:ok, socket} ->
        Logger.debug("Opened socket: #{socket |> inspect} to device: #{ip |> inspect}")
        {:ok, socket}

      {:error, cause} ->
        Logger.debug("Socket open error: #{cause |> inspect}")
        {:error, cause}
    end
  end

  defp is_result_message?(msg) do
    Regex.match?(~r/\"result\"/, msg)
  end

  defp is_notification_message?(msg) do
    Regex.match?(~r/{\"method\":\"props\"/, msg)
  end

  defp is_error_message?(msg) do
    Regex.match?(~r/\"error\":/, msg)
  end
end
