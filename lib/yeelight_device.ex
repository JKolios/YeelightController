defmodule YeelightDevice do
    defstruct [:address, :port, :id, :model, :fw_ver, :power, :support, :bright, :color_mode, :ct, :rgb, :hue, :sat, :device_name]
end