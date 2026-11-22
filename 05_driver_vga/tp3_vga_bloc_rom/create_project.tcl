# ---------------------------------------------------------------------------
# Cree (ou rouvre) le projet Vivado VGA_blocROM - Basys 3 (xc7a35tcpg236-1)
# Vivado : Tools > Run Tcl Script...  puis choisir ce fichier.
#
# - Le projet est cree dans le sous-dossier vivado/ : il ne rentre donc jamais en
#   conflit avec les dossiers sources/, simulation/, constraints/, ip/ (pas d'erreur
#   "Project already exists on disk").
# - Les fichiers sont references a leur place (aucune copie).
# - L'IP sprite_rom (Block Memory Generator, Single Port ROM 38400 x 8 bits,
#   initialisee par ip/COE240x160.coe) est creee par ce script.
#   Si une propriete CONFIG est refusee par votre version de Vivado, creez l'IP a la
#   main (IP Catalog) en suivant LISEZ-MOI.md, section "Creation manuelle de l'IP".
# ---------------------------------------------------------------------------
set d [file dirname [file normalize [info script]]]
set p $d/vivado

if {[file exists $p/VGA_blocROM.xpr]} {
    open_project $p/VGA_blocROM.xpr
    puts "Projet existant ouvert : $p/VGA_blocROM.xpr"
    return
}

create_project VGA_blocROM $p -part xc7a35tcpg236-1
set_property target_language VHDL [current_project]

add_files -norecurse -fileset sources_1 [list \
    $d/sources/div_clk.vhd \
    $d/sources/VGA640x480.vhd \
    $d/sources/VGA_PROM_2.vhd \
    $d/sources/TOP_VGA_PROM_2.vhd ]

add_files -norecurse -fileset sim_1 [list \
    $d/simulation/div_clk_tb.vhd \
    $d/simulation/VGA640x480_tb.vhd \
    $d/simulation/TOP_VGA_PROM_2_tb.vhd ]

add_files -norecurse -fileset constrs_1 $d/constraints/Basys3_VGA_PROM_2.xdc

# --- IP : Block Memory Generator = ROM de l'image 240 x 160 ----------------
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name sprite_rom
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Write_Width_A {8} \
    CONFIG.Write_Depth_A {38400} \
    CONFIG.Read_Width_A {8} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File $d/ip/COE240x160.coe \
] [get_ips sprite_rom]
generate_target all [get_ips sprite_rom]

set_property top TOP_VGA_PROM_2    [get_filesets sources_1]
set_property top TOP_VGA_PROM_2_tb [get_filesets sim_1]
set_property top_auto_set false    [get_filesets sources_1]
set_property top_auto_set false    [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {35ms} -objects [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Projet cree : $p/VGA_blocROM.xpr"
