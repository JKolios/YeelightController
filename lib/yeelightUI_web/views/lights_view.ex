defmodule YeelightUIWeb.LightsView do
  use YeelightUIWeb, :view
  require Logger

  def devices() do
    for {ip, device} <- Yeelight.devices do
      Map.merge(%{ip: ip}, device)
    end
  end

  def deviceByIP(ipString) do
    ipAsList = for ipSegment <- String.split(ipString, "."), do: String.to_integer(ipSegment)
    Yeelight.device_by_ip(ipAsList |> List.to_tuple)
  end

  def ipTupleToString(ipTuple) do
    ipTuple |> :inet_parse.ntoa |> to_string()
  end
end
