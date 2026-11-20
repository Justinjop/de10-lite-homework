create_clock -name CLOCK_50 -period 20.000 [get_ports CLOCK_50]
derive_clock_uncertainty
# buttons, switches and LEDs are slow: do not time them
set_false_path -from [get_ports {BUTTON* SW*}]
set_false_path -to [get_ports {HEX* LEDG*}]
