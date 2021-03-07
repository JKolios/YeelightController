defmodule Yeelight.Discovery.Socket do
  use GenServer
  require Logger

  @discovery_address {239, 255, 255, 250}
  @discovery_port 1982
  @discovery_message ~s(M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: "ssdp:discover"\r\nST: wifi_bulb\r\n\r\n)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Logger.debug("Discovery Socket Initialising")
    socket = udp_discovery_socket()
    {:ok, socket}
  end

  defp udp_discovery_socket do
    udp_options = [
      :binary,
      active: true,
      add_membership: {@discovery_address, {0, 0, 0, 0}},
      multicast_if: {0, 0, 0, 0},
      multicast_loop: false,
      multicast_ttl: 4,
      reuseaddr: true,
      ip: {0, 0, 0, 0}
    ]

    {:ok, socket} = :gen_udp.open(@discovery_port, udp_options)
    Logger.debug("Discovery socket opened")
    socket
  end

  def send_discovery_message() do
    Logger.debug("send_discovery_message called")
    GenServer.cast(__MODULE__, :send_discover_message)
  end

  @impl true
  def handle_info({:udp, _receive_socket, ip, port, data}, socket) do
    Logger.debug(
      "Received UDP message from ip: #{ip |> :inet.ntoa() |> to_string()} port: #{port}"
    )

    Logger.debug("Message data: #{data}")

    cond do
      is_advertisment?(data) || is_discovery_response?(data) ->
        Logger.debug("Message identified as advertisment or discovery response")
        newDevice = Yeelight.Device.from_discovery_response(data)
        existingDevice = Yeelight.Device.Registry.get_by_ip(ip)

        newDevice =
          if !is_nil(existingDevice) do
            Logger.debug("New detection of known device")
            %{newDevice | controller: existingDevice.controller}
          else
            Logger.debug("Detection of a new device")

            %{
              newDevice
              | controller:
                  Yeelight.Device.create_device_controller(ip, Yeelight.Device.port(newDevice))
            }
          end

        Logger.debug("Storing device #{newDevice |> inspect} on ip #{ip |> inspect}")
        Yeelight.Device.Registry.put(ip, newDevice)

      true ->
        Logger.debug("Message discarded")
    end

    Logger.debug("Finished handling message")
    {:noreply, socket}
  end

  @impl true
  def handle_cast(:send_discover_message, socket) do
    send_discover_message(socket)
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug("Terminating the discovery socket. Reason: #{reason |> inspect}")
    :ok = :gen_tcp.close(state)
  end

  defp send_discover_message(socket) do
    socket |> send_data(@discovery_address, @discovery_port, @discovery_message)
    Logger.debug("Discovery message sent")
  end

  defp send_data(socket, address, port, data) do
    Logger.debug(
      "Discovery socket sending to: Address: #{address |> :inet.ntoa() |> to_string()} Port: #{
        port
      }"
    )

    Logger.debug("Payload: \n#{data}")
    socket |> :gen_udp.send(address, port, data)
  end

  defp is_advertisment?(msg) do
    Regex.match?(~r/^NOTIFY */, msg)
  end

  defp is_discovery_response?(msg) do
    Regex.match?(~r/^HTTP\/1.1 200 OK/, msg)
  end
end
