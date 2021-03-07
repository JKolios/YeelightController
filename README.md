# YeelightController

 YeelightController is a phoenix web application which allows the user to operate all Yeelight products in their WiFi network with the same range of functionality (eventually!) as the official Yeelight app.

## Installation

Clone this repo, then run `mix deps.get` to fetch all dependencies.

## Configuration

Standard phoenix configuration is available under `config/`:

## Usage

`mix phx.server` will start a local instance listening on 0.0.0.0/4000.
`iex -S mix phx.server` will do the same while also opening an interactive REPL

## Architecture

`lib/yeelightUI` holds the `Yeelight` namespace which implements all communication with the smart light devices.
`lib/yeelightUI_web` holds the Phoenix web app which acts as a UI.

`Yeelight` can also be used directly on a REPL, according to the examples below:

### Device Discovery

Device discovery will start automatically when the application starts and should automatically monitor new device announcements. Powering down a device does not remove it from the list of discovered devices.

```language=elixir
Yeelight.devices # Lists all discovered devices
```

### Connecting to a Device

```language=elixir
Yeelight.start_discovery
# Connecting using the device's assigned name
{:ok, connection} = Yeelight.control_by_name("Ceiling_Light") 
# OR
# Connecting using the IP address (tuple format)
{:ok, connection} = Yeelight.control_by_ip({192, 168, 1, 10})
```

### Controlling a Device

```language=elixir
{:ok, connection} = Yeelight.control_by_name("Ceiling_Light")
connection |> Yeelight.Control.toggle # Toggles the light on or off
```

### Controlling all Devices at once

```language=elixir
Yeelight.all_devices(:toggle,[]) # toggles all discovered lights on or off
```

## Spec Reference

The `Yeelight` namespace implements the Yeelight Inter-Operation Spec as defined here: https://www.yeelight.com/download/Yeelight_Inter-Operation_Spec.pdf
