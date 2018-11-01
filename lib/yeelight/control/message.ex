defmodule Yeelight.Control.Message do
  @derive [Poison.Encoder]
  defstruct [:id, :method, :params]

  def construct(method, params) do
    {:ok, encoded} =
      Poison.encode(%Yeelight.Control.Message{
        id: Yeelight.Control.MessageIdCounter.next_id(),
        method: method,
        params: params
      })

    encoded <> "\r\n"
  end
end
