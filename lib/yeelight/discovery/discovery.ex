defmodule Yeelight.Discovery do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      Yeelight.Device.Registry,
      Yeelight.Discovery.Socket,
      Yeelight.Discovery.MessageSender
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
