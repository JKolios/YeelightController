defmodule YeelightUIWeb.LightsController do
  use YeelightUIWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, params) do
    render(conn, "show.html", ip: params["id"])
  end

  def update(conn, %{"id" => id, "form_params" => form_params}) do
    Logger.debug("Form params: #{form_params |> inspect}")
    device_ip = for ipSegment <- String.split(id, "."), do: String.to_integer(ipSegment)

    Yeelight.command_device(Yeelight.device_by_ip(device_ip |> List.to_tuple()), :set_name, [
      form_params["device_name"]
    ])

    redirect(conn, to: current_path(conn))
  end

  def update(conn, %{
        "id" => id,
        "controlFunctionName" => controlFunctionName,
        "controlFunctionParams" => controlFunctionParams
      }) do
    device_ip = for ipSegment <- String.split(id, "."), do: String.to_integer(ipSegment)
    controlFunctionParams = if is_nil(controlFunctionParams), do: [], else: controlFunctionParams

    Yeelight.command_device(
      Yeelight.device_by_ip(device_ip |> List.to_tuple()),
      String.to_existing_atom(controlFunctionName),
      controlFunctionParams
    )

    redirect(conn, to: current_path(conn))
  end

  def update(conn, %{"id" => id, "controlFunctionName" => controlFunctionName}) do
    device_ip = for ipSegment <- String.split(id, "."), do: String.to_integer(ipSegment)

    Yeelight.command_device(
      Yeelight.device_by_ip(device_ip |> List.to_tuple()),
      String.to_existing_atom(controlFunctionName),
      []
    )

    redirect(conn, to: current_path(conn))
  end

  def create(conn, params) do
    controlFunctionParams =
      if is_nil(params["controlFunctionParams"]), do: [], else: params["controlFunctionParams"]

    Yeelight.command_all_devices(
      String.to_existing_atom(params["controlFunctionName"]),
      controlFunctionParams
    )

    redirect(conn, to: current_path(conn))
  end

  def edit(conn, %{"id" => id}) do
    render(conn, "edit.html", ip: id)
  end
end
