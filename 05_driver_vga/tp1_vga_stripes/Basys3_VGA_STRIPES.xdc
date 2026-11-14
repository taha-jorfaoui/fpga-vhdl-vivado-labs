## Contraintes Basys 3 (xc7a35tcpg236-1) pour TOP_VGA_SPRITES
## Les noms de ports doivent correspondre a ceux de l'entity : mclk, btnr, hsync, vsync, red, green, blue

## Horloge 100 MHz
set_property PACKAGE_PIN W5 [get_ports mclk]
set_property IOSTANDARD LVCMOS33 [get_ports mclk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports mclk]

## Reset : bouton BTNR
set_property PACKAGE_PIN T17 [get_ports btnr]
set_property IOSTANDARD LVCMOS33 [get_ports btnr]

## Connecteur VGA - Rouge
set_property PACKAGE_PIN G19 [get_ports {red[0]}]
set_property PACKAGE_PIN H19 [get_ports {red[1]}]
set_property PACKAGE_PIN J19 [get_ports {red[2]}]
set_property PACKAGE_PIN N19 [get_ports {red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {red[*]}]

## Connecteur VGA - Vert
set_property PACKAGE_PIN J17 [get_ports {green[0]}]
set_property PACKAGE_PIN H17 [get_ports {green[1]}]
set_property PACKAGE_PIN G17 [get_ports {green[2]}]
set_property PACKAGE_PIN D17 [get_ports {green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {green[*]}]

## Connecteur VGA - Bleu
set_property PACKAGE_PIN N18 [get_ports {blue[0]}]
set_property PACKAGE_PIN L18 [get_ports {blue[1]}]
set_property PACKAGE_PIN K18 [get_ports {blue[2]}]
set_property PACKAGE_PIN J18 [get_ports {blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blue[*]}]

## Connecteur VGA - Synchronisations
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]
