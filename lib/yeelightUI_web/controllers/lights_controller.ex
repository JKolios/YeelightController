defmodule YeelightUIWeb.LightsController do
  use YeelightUIWeb, :controller
  require Logger

  def index(conn, _params) do
    # Yeelight.Discovery.Socket.send_discovery_message()
    render(conn, "index.html")
  end

  def show(conn, params) do
    render(conn, "show.html", ip: params["id"])
  end

  def update(conn, params) do
    device_ip = for ipSegment <- String.split(params["id"], "."), do: String.to_integer(ipSegment)
    Yeelight.command_device(Yeelight.device_by_ip(device_ip |> List.to_tuple), :toggle, [])
    redirect(conn, to: "/")
  end
end