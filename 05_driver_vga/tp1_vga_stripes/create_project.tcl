# ---------------------------------------------------------------------------
# Cree le projet Vivado VGA_STRIPES - TP1 (Basys 3 - xc7a35tcpg236-1)
# Usage : dans Vivado, menu Tools > Run Tcl Script... puis choisir ce fichier,
#         ou dans la console Tcl :  source {chemin/vers/create_project.tcl}
# Le projet Vivado est cree dans le sous-dossier vivado_project/ (ignore par Git).
# Les sources (.vhd), testbenches (_tb.vhd) et le .xdc sont dans ce dossier.
# ---------------------------------------------------------------------------
set script_dir [file dirname [file normalize [info script]]]
set proj_name  VGA_STRIPES
set proj_dir   $script_dir/vivado_project

create_project $proj_name $proj_dir -part xc7a35tcpg236-1 -force
set_property target_language VHDL [current_project]

# Design Sources
add_files -fileset sources_1 [list \
    $script_dir/div_clk.vhd \
    $script_dir/VGA640x480.vhd \
    $script_dir/VGA_STRIPES.vhd \
    $script_dir/TOP_VGA_SPRITES.vhd ]

# Simulation Sources : tous les testbenches, un seul est "top" a la fois
add_files -fileset sim_1 [list \
    $script_dir/div_clk_tb.vhd \
    $script_dir/VGA640x480_tb.vhd \
    $script_dir/TOP_VGA_SPRITES_tb.vhd ]

# Constraints
add_files -fileset constrs_1 $script_dir/Basys3_VGA_STRIPES.xdc

# Tops : synthese = TOP_VGA_SPRITES, simulation = test final par defaut
set_property top TOP_VGA_SPRITES    [get_filesets sources_1]
set_property top TOP_VGA_SPRITES_tb [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Projet $proj_name cree dans $proj_dir"
