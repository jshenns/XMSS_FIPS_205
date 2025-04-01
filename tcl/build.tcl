# Set the Vivado project name and path
set project_name "xmss_fips_205_vivado_project"
set project_dir "./$project_name"  
set src_dir "./src"   

# Create a new Vivado project
create_project $project_name $project_dir -force

set_property board_part digilentinc.com:arty-a7-100:part0:1.1 [current_project]

# Add all HDL files from the 'src' directory
set hdl_files [glob -nocomplain $src_dir/*.vhd $src_dir/*.v]

# Add each HDL file to the project
foreach file $hdl_files {
    add_files $file
}

#add necessary bram
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name my_bram_xmss_node_2
set_property -dict [list \
  CONFIG.Operating_Mode_A {READ_FIRST} \
  CONFIG.Write_Depth_A {512} \
  CONFIG.Write_Width_A {256} \
] [get_ips my_bram_xmss_node_2]
generate_target all [get_files  c:/Users/joshe/Documents/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/my_bram_xmss_node_2/my_bram_xmss_node_2.xci]
catch { config_ip_cache -export [get_ips -all my_bram_xmss_node_2] }
export_ip_user_files -of_objects [get_files c:/Users/joshe/Documents/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/my_bram_xmss_node_2/my_bram_xmss_node_2.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] c:/Users/joshe/Documents/XMSS_FIPS_205/xmss_fips_205_vivado_project/xmss_fips_205_vivado_project.srcs/sources_1/ip/my_bram_xmss_node_2/my_bram_xmss_node_2.xci]
launch_runs my_bram_xmss_node_2_synth_1 -jobs 8



# Add HDL files to the project for synthesis
update_compile_order -fileset sources_1

# Open the Vivado GUI
start_gui
