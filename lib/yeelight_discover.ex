defmodule YeelightDiscover do
  use GenServer
  require Logger

  @discover_local_port 1337
  @discover_message ~s(M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: "ssdp:discover"\r\nST: wifi_bulb\r\n\r\n)
  @discover_address {239,255,255,250}
  @discover_port 1982

  
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
      socket |> send_data(address, port, @discover_message)
  end
  
  defp send_data(socket, address, port, data) do
      socket |> :gen_udp.send(address, port, data)
  end
  
  # Server Callbacks

  def init (:ok) do
    Logger.debug("UDP server starting")
    udp_options = [
        :binary,
        active:          10,
        reuseaddr:       true
      ]
    case :gen_udp.open(@discover_local_port, udp_options) do
      {:ok, socket } -> {:ok, %{socket: socket, devices: %{}}}
      {:error, error_message } -> {:error, error_message }
    end     
  end

  def handle_info({:udp, socket, ip, port, data}, state) do
    Logger.debug "Received UDP discovery message from ip: #{ip |> :inet.ntoa() |> to_string()} port: #{port}"
    :inet.setopts(socket, [active: 1])
    new_device = parse_discovery_response(ip, port, data)
    {:noreply, %{socket: socket, devices: Map.put(state[:devices], ip, new_device)}}
  end
    
  def handle_cast({:send_discover_message}, state) do
    Logger.debug "Received send_discover_message call"
    send_discover_message(state[:socket], @discover_address, @discover_port)
    {:noreply, state}
  end

  def handle_call({:discovered_devices}, _from, state) do
    Logger.debug "Received discovered_devices call"
    {:reply, state[:devices], state}
  end

  defp parse_discovery_response(ip, port, response_data) do
    %YeelightDevice{
      address: ip, 
      port: port,
      id: device_id(response_data),
      model: model(response_data),
      fw_ver: fw_ver(response_data),
      power: power(response_data),
      support: support(response_data),
      bright: bright(response_data), 
      color_mode: color_mode(response_data),
      ct: ct(response_data),
      rgb: rgb(response_data),
      hue: hue(response_data),
      sat: sat(response_data),
      device_name: device_name(response_data)
    }
  end

  defp device_id(response_data) do
    get_first_match(response_data, ~r/.*id: (.*)\r/)
  end

  defp model(response_data) do
    get_first_match(response_data, ~r/.*model: (.*)\r/)
  end

  defp fw_ver(response_data) do
    get_first_match(response_data, ~r/.*fw_ver: (.*)\r/)
  end

  defp power(response_data) do
    get_first_match(response_data, ~r/.*power: (.*)\r/)
  end

  defp support(response_data) do
    get_first_match(response_data, ~r/.*support: (.*)\r/)
  end

  defp bright(response_data) do
    String.to_integer(get_first_match(response_data, ~r/.*bright: (.*)\r/))
  end

  defp color_mode(response_data) do
    get_first_match(response_data, ~r/.*color_mode: (.*)\r/)
  end

  defp ct(response_data) do
    String.to_integer(get_first_match(response_data, ~r/.*ct: (.*)\r/))
  end

  defp rgb(response_data) do
    String.to_integer(get_first_match(response_data, ~r/.*rgb: (.*)\r/))
  end

  defp hue(response_data) do
    String.to_integer(get_first_match(response_data, ~r/.*hue: (.*)\r/))
  end

  defp sat(response_data) do
    String.to_integer(get_first_match(response_data, ~r/.*sat: (.*)\r/))
  end

  defp device_name(response_data) do
    get_first_match(response_data, ~r/.*name: (.*)\r/)
  end

  defp get_first_match(data, regex) do
    List.last(Regex.run(regex, data, capture: :all_but_first))  
  end
end
