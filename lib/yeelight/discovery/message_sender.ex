defmodule Yeelight.Discovery.MessageSender do
  use Task
  require Logger

  @discovery_period 300_000

  def start_link(_arg) do
    Yeelight.Discovery.Socket.send_discovery_message()
    Task.start_link(__MODULE__, :poll, [])
  end

  def poll() do
    receive do
    after
      @discovery_period ->
        Yeelight.Discovery.Socket.send_discovery_message()
        poll()
    end
  end
end
