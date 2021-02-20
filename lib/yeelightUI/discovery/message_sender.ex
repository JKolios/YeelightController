defmodule Yeelight.Discovery.MessageSender do
  use Task
  require Logger

  @discovery_period 300000

  def start_link(_arg) do
    Yeelight.Discovery.Socket.send_discovery_message()
    Logger.debug("Starting periodic discovery message sender, interval #{@discovery_period}")
    Task.start_link(&poll/0)
  end

  def poll() do
    receive do
    after
      @discovery_period ->
        Logger.debug("Sending scheduled discovery message")
        Yeelight.Device.Registry.clear()
        Yeelight.Discovery.Socket.send_discovery_message()
        poll()
    end
  end
end
