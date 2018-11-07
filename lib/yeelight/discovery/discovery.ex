defmodule Yeelight.Discovery do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      Yeelight.Device.Registry,
      Yeelight.Discovery.DiscoveryServer,
      Yeelight.Discovery.AdvertisementServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def send_discovery_message do
    Yeelight.Discovery.DiscoveryServer.send_discovery_message()
  end
end
