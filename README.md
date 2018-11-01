# YeelightController

 YeelightController is a library which allows the user to operate all Yeelight products in their WiFi network with the same range of functionality (eventually!) as the official Yeelight app.

## Installation

Clone this repo, then run `mix deps.get` to fetch all dependencies.

## Usage
All examples are meant to be executed using `iex -S mix`.

### Device Discovery
```
Yeelight.start_discovery # Probes the local network for Yeelight Products
Yeelight.devices # Lists all discovered devices
```

### Connecting to a Device

```
Yeelight.start_discovery
# Connecting using the device's assigned name
{:ok, connection} = Yeelight.control_by_name("Ceiling_Light") 
# OR
# Connecting using the IP address (tuple format)
{:ok, connection} = Yeelight.control_by_ip({192, 168, 1, 10})
```

### Controlling a Device
```
Yeelight.start_discovery
{:ok, connection} = Yeelight.control_by_name("Ceiling_Light")
connection |> Yeelight.Control.toggle # Toggles the light on or off
```

### Controlling all Devices at once
```
Yeelight.start_discovery
Yeelight.all_devices(:toggle,[]) # toggles all discovered lights on or off
```

## Spec Reference
https://www.yeelight.com/download/Yeelight_Inter-Operation_Spec.pdf


