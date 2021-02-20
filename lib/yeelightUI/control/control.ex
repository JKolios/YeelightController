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

  # Callbacks
  @impl true
  def init(state) do
    Yeelight.Control.MessageIdCounter.start_link()
    
    {:ok, socket} = open_socket(Yeelight.Device.ip(state[:device]), Yeelight.Device.port(state[:device]))
    Logger.debug("Created socket: #{socket |> inspect}")
    Logger.debug("Opened connection to device: #{state.device.location}")
    {:ok, %{state | socket: socket}}
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
        Yeelight.Device.update_from_notification(state[:device], msg)

      is_error_message?(msg) ->
        Logger.debug("Message identified as ERROR")
        Logger.debug("Error message: #{msg}")

      true ->
        Logger.debug("Message discarded. This indicates a bug")
    end
    
    {:noreply, state}
  end
  
  @impl true
  def handle_info({:tcp_closed, _socket}, state) do
    Logger.debug("TCP socket closed")
    {:stop, "Socket is closed", state} 
  end
  
  @impl true  
  def handle_info({:tcp_error, _socket, reason}, state) do      
    Logger.error("Tcp error: #{inspect(reason)}")    
    {:stop, "Tcp error: #{inspect(reason)}", state}
  end  

  @impl true
  def terminate(reason, state) do
    Logger.debug("Terminating the control server. Reason: #{reason}")
    :ok = :gen_tcp.close(state[:socket])
  end

  defp open_socket(ip, port) do
    opts = [:binary, active: :once, reuseaddr: true, keepalive: false]
    Logger.debug("Opening TCP socket to #{ip |> inspect}:#{port}")
    :gen_tcp.connect(ip, port, opts)
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
