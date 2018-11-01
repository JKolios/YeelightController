defmodule YeelightDiscover do
  use GenServer
  require Logger

  @discovery_message ~s(M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: "ssdp:discover"\r\nST: wifi_bulb\r\n\r\n)
  @discovery_address {239,255,255,250}
  @discovery_port 1982
  @discovery_response_port 1337

  
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def send_discover_message(server) do
    GenServer.cast(server, {:send_discover_message})
  end

  def discovered_devices(server) do
    GenServer.call(server, {:discovered_devices})
end
  
  defp send_discover_message(socket, address, port) do
      socket |> send_data(address, port, @discovery_message)
  end
  
  defp send_data(socket, address, port, data) do
      socket |> :gen_udp.send(address, port, data)
  end
  
  # Server Callbacks

  def init (:ok) do
    Logger.debug("Discovery server starting")
    {:ok, socket } = udp_discovery_socket()
    {:ok, %{socket: socket}}      
  end

  defp udp_discovery_socket do
    udp_options = [
      :binary,
      active:          10,
      reuseaddr:       true
    ]

    case :gen_udp.open(@discovery_response_port, udp_options) do
      {:ok, socket } -> {:ok, socket}
      {:error, error_message } -> {:error, error_message }
    end 
  end


  def handle_info({:udp, socket, ip, port, data}, state) do
    Logger.debug "Received UDP message from ip: #{ip |> :inet.ntoa() |> to_string()} port: #{port}"
    Logger.debug "Message data: #{data}"
    :inet.setopts(socket, [active: 1])
    new_device = YeelightDevice.from_discovery_response(data)
    DeviceRegistry.put(ip, new_device)
    {:noreply, state}
  end

    
  def handle_cast({:send_discover_message}, state) do
    Logger.debug "Received send_discover_message call"
    send_discover_message(state[:socket], @discovery_address, @discovery_port)
    {:noreply, state}
  end
end
