defmodule YeelightUIWeb.LightsView do
  use YeelightUIWeb, :view
  alias YeelightUIWeb.Router.Helpers
  require Logger

  def devices() do
    for {ip, device} <- Yeelight.devices() do
      Map.merge(%{ip: ip}, device)
    end
  end

  def deviceByIP(ipString) do
    ipAsList = for ipSegment <- String.split(ipString, "."), do: String.to_integer(ipSegment)
    Yeelight.device_by_ip(ipAsList |> List.to_tuple())
  end

  def ipTupleToString(ipTuple) do
    ipTuple |> :inet_parse.ntoa() |> to_string()
  end

  def pulseColorFlowArgs() do
    [
      8,
      0,
      Enum.join(
        [
          "2500,2,2700,100",
          "1000,7,0,0",
          "2500,2,2700,10",
          "1000,7,0,0",
          "2500,2,2700,100",
          "1000,7,0,0",
          "2500,2,2700,10",
          "1000,7,0,0"
        ],
        ","
      )
    ]
  end
end
