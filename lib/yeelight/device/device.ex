defmodule Yeelight.Device do
  defstruct [
    :location,
    :id,
    :model,
    :fw_ver,
    :power,
    :support,
    :bright,
    :color_mode,
    :ct,
    :rgb,
    :hue,
    :sat,
    :device_name
  ]

  @color_modes %{"1" => "Color", "2" => "Temperature", "3" => "HSV"}

  def from_discovery_response(response_payload) do
    %Yeelight.Device{
      location: location(response_payload),
      id: device_id(response_payload),
      model: model(response_payload),
      fw_ver: fw_ver(response_payload),
      power: power(response_payload),
      support: support(response_payload),
      bright: bright(response_payload),
      color_mode: color_mode(response_payload),
      ct: ct(response_payload),
      rgb: rgb(response_payload),
      hue: hue(response_payload),
      sat: sat(response_payload),
      device_name: device_name(response_payload)
    }
  end

  def ip(device) do
    {:ok, parsed_ip} =
      :inet.parse_address(to_charlist(get_first_match(device.location, ~r/.*\/\/(.*):/)))

    parsed_ip
  end

  def port(device) do
    String.to_integer(get_first_match(device.location, ~r/:([0-9]+)$/))
  end

  defp location(response_payload) do
    get_first_match(response_payload, ~r/.*Location: (.*)\r/)
  end

  defp device_id(response_payload) do
    get_first_match(response_payload, ~r/.*id: (.*)\r/)
  end

  defp model(response_payload) do
    get_first_match(response_payload, ~r/.*model: (.*)\r/)
  end

  defp fw_ver(response_payload) do
    get_first_match(response_payload, ~r/.*fw_ver: (.*)\r/)
  end

  defp power(response_payload) do
    get_first_match(response_payload, ~r/.*power: (.*)\r/)
  end

  defp support(response_payload) do
    get_first_match(response_payload, ~r/.*support: (.*)\r/)
  end

  defp bright(response_payload) do
    String.to_integer(get_first_match(response_payload, ~r/.*bright: (.*)\r/))
  end

  defp color_mode(response_payload) do
    @color_modes[get_first_match(response_payload, ~r/.*color_mode: (.*)\r/)]
  end

  defp ct(response_payload) do
    String.to_integer(get_first_match(response_payload, ~r/.*ct: (.*)\r/))
  end

  defp rgb(response_payload) do
    String.to_integer(get_first_match(response_payload, ~r/.*rgb: (.*)\r/))
  end

  defp hue(response_payload) do
    String.to_integer(get_first_match(response_payload, ~r/.*hue: (.*)\r/))
  end

  defp sat(response_payload) do
    String.to_integer(get_first_match(response_payload, ~r/.*sat: (.*)\r/))
  end

  defp device_name(response_payload) do
    get_first_match(response_payload, ~r/.*name: (.*)\r/)
  end

  defp get_first_match(data, regex) do
    List.last(Regex.run(regex, data, capture: :all_but_first))
  end
end
