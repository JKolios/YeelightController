defmodule Yeelight.Discovery.AdvertisementServer do
  use GenServer
  require Logger

  @discovery_address {239, 255, 255, 250}
  @discovery_port 1982

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Server Callbacks

  @impl true
  def init(_) do
    Logger.debug("Advertisment server starting")
    {:ok, socket} = udp_advertisment_socket()
    {:ok, %{socket: socket}}
  end

  defp udp_advertisment_socket do
    udp_options = [
      :binary,
      active: 10,
      add_membership: {@discovery_address, {0, 0, 0, 0}},
      multicast_if: {0, 0, 0, 0},
      multicast_loop: false,
      multicast_ttl: 4,
      reuseaddr: true
    ]

    case :gen_udp.open(@discovery_port, udp_options) do
      {:ok, socket} -> {:ok, socket}
      {:error, error_message} -> {:error, error_message}
    end
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    Logger.debug(
      "Received UDP message from ip: #{ip |> :inet.ntoa() |> to_string()} port: #{port}"
    )

    Logger.debug("Message data: #{data}")
    :inet.setopts(socket, active: 1)

    if is_advertisment?(data) do
      Logger.debug("Recognised as an advertisment message")
      new_device = Yeelight.Device.from_discovery_response(data)
      Yeelight.Device.Registry.put(ip, new_device)
    else
      Logger.debug("Discarded")
    end

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug("Terminating the advertisment server. Reason: #{reason}")
    :ok = :gen_tcp.close(state[:socket])
  end

  defp is_advertisment?(response_data) do
    Regex.match?(~r/^NOTIFY */, response_data)
  end
end
