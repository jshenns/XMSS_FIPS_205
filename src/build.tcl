# Define a procedure (function)
# It will compile all the .sv, .v, and .vhd files in a directory.
# top is the name of the top level module in the design
proc compile {top} {
    puts "Closing any designs that are currently open..."
    puts ""
    close_project -quiet
    puts "Continuing..."

    # Create a design for a specific part
    link_design -part xc7a100t-csg324-3
    
    # Compile any .sv, .v, and .vhd files that exist in the current directory
    if {[glob -nocomplain *.sv] != ""} {
	puts "Reading SV files..."
	read_verilog -sv [glob *.sv]
    }
    if {[glob -nocomplain *.v] != ""} {
	puts "Reading Verilog files..."
	read_verilog  [glob *.v]
    }
    if {[glob -nocomplain *.vhd] != ""} {
	puts "Reading VHDL files..."
	read_vhdl [glob *.vhd]
    }

    puts "Synthesizing design..."
    synth_design -top $top -flatten_hierarchy full 
    
    # Here is how you add a .xdc file to the project
    #read_xdc $top.xdc
    
    # You will get DRC errors without the next two lineswhen you
    # generate a bitstream.
    set_property CFGBVS VCCO [current_design]
    set_property CONFIG_VOLTAGE 3.3 [current_design]

    # If you don't need an .xdc for pinouts (just generating designs for analysis),
    # you can include the next line to avoid errors about unconstrained pins.
    #set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]

    #puts "Placing Design..."
    #place_design
    
    #puts "Routing Design..."
    #route_design

    #puts "Writing checkpoint"
    #write_checkpoint -force $top.dcp

    #puts "Writing bitstream"
    #write_bitstream -force $top.bit
    
    puts "All done..."

    # You might want to close the project at this point, 
    # but probably not since you may want to do things with the design.
    #close_project

    }