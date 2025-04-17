# Set the Vivado project name and path
set project_name "xmss_fips_205_vivado_project"
set project_dir "./$project_name"  
set src_dir "./src"   

# Create a new Vivado project
create_project $project_name $project_dir -force

set_property board_part digilentinc.com:arty-a7-100:part0:1.1 [current_project]

# Add all HDL files from the 'src' directory
set hdl_files [glob -nocomplain $src_dir/*.vhd $src_dir/*.v  $src_dir/*.edn]

# Add each HDL file to the project
foreach file $hdl_files {
    add_files $file
}

#add leaf bram
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name my_bram_xmss_node_2
set_property -dict [list \
  CONFIG.Operating_Mode_A {READ_FIRST} \
  CONFIG.Write_Depth_A {256} \
  CONFIG.Write_Width_A {256} \
] [get_ips my_bram_xmss_node_2]
generate_target all [get_files  **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/my_bram_xmss_node_2/my_bram_xmss_node_2.xci]
catch { config_ip_cache -export [get_ips -all my_bram_xmss_node_2] }
export_ip_user_files -of_objects [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/my_bram_xmss_node_2/my_bram_xmss_node_2.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/my_bram_xmss_node_2/my_bram_xmss_node_2.xci]
launch_runs my_bram_xmss_node_2_synth_1 -jobs 8

#add signature fifo
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name sig_fifo
set_property -dict [list \
  CONFIG.Input_Data_Width {256} \
  CONFIG.Input_Depth {128} \
] [get_ips sig_fifo]
generate_target {instantiation_template} [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/sig_fifo/sig_fifo.xci]
generate_target all [get_files  **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/sig_fifo/sig_fifo.xci]
catch { config_ip_cache -export [get_ips -all sig_fifo] }
export_ip_user_files -of_objects [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/sig_fifo/sig_fifo.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/sig_fifo/sig_fifo.xci]
launch_runs sig_fifo_synth_1 -jobs 8

#add clock fifo
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name clock_fifo
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
] [get_ips clock_fifo]
generate_target {instantiation_template} [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/clock_fifo/clock_fifo.xci]
generate_target all [get_files  **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/clock_fifo/clock_fifo.xci]
catch { config_ip_cache -export [get_ips -all clock_fifo] }
export_ip_user_files -of_objects [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/clock_fifo/clock_fifo.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/clock_fifo/clock_fifo.xci]
launch_runs clock_fifo_synth_1 -jobs 8


#add clock wizard
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name cllk_75
set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {226.435} \
  CONFIG.CLKOUT1_PHASE_ERROR {236.795} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {75} \
  CONFIG.CLK_OUT1_PORT {CLK75MHZ} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {40.125} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {13.375} \
  CONFIG.MMCM_DIVCLK_DIVIDE {4} \
] [get_ips cllk_75]
generate_target {instantiation_template} [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/cllk_75/cllk_75.xci]
generate_target all [get_files  **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/cllk_75/cllk_75.xci]
catch { config_ip_cache -export [get_ips -all cllk_75] }
export_ip_user_files -of_objects [get_files **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/cllk_75/cllk_75.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] **/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/cllk_75/cllk_75.xci]
launch_runs cllk_75_synth_1 -jobs 8



# Add HDL files to the project for synthesis
update_compile_order -fileset sources_1

move_files -fileset sim_1 [get_files **/XMSS_FIPS_205/src/tb_control_system.vhd]

add_files -fileset constrs_1 -norecurse ../XMSS_FIPS_205/xdc/Arty-A7-100-Master.xdc
import_files -fileset constrs_1 ../XMSS_FIPS_205/xdc/Arty-A7-100-Master.xdc

# Open the Vivado GUI
start_gui
