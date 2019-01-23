#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 12.0 Build 263 08/02/2012 Service Pack 2 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2012 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "clk" -period 37.037ns [get_ports {osc_clk}]


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty
# Not supported for family Cyclone II

# tsu/th constraints

# tco constraints

# tpd constraints

create_generated_clock -name sdram_clk \
    -source [get_pins {u_clkrst|u_pll|altpll_component|auto_generated|pll1|clk[2]}] \
    -divide_by 1 \
    [get_ports srm_clk]

#when sdram_clk lag
set_multicycle_path -from [get_clocks u_clkrst|u_pll|altpll_component|auto_generated|pll1|clk[1]] -to [get_clocks sdram_clk] -setup -end 2

#when sdram_clk lead
#set_multicycle_path -from [get_clocks sdram_clk] -to [get_clocks u_clkrst|u_pll|altpll_component|auto_generated|pll1|clk[1]] -setup -end 2

set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_cke]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_cke]
set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_cas_n]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_cas_n]
set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_ras_n]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_ras_n]
set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_we_n]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_we_n]
set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_ba*]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_ba*]
set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_data*]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_data*]
set_output_delay -clock [get_clocks sdram_clk] -max 1.5  [get_ports srm_addr*]
set_output_delay -clock [get_clocks sdram_clk] -min -0.8 [get_ports srm_addr*]