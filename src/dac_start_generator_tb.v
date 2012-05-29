`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:23:47 09/12/2011
// Design Name:   dac_start_generator
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/dac_start_generator_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dac_start_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dac_start_generator_tb;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg trigger;

	// Outputs
	wire dac_start;

	// Instantiate the Unit Under Test (UUT)
	dac_start_generator uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.trigger(trigger), 
		.dac_start(dac_start)
	);

// Clock generator
	always begin
		#500  clk = ~clk; // Toggle clock high/low every 500ns => 1us period (1 MHz)
	end
 	
// trigger generator (assume resetting at 10 kHz)
	always begin
		#98000 trigger = 1'b1;
		#2000 trigger = 1'b0; //assuming reset is high for 2 us
	end
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		start = 0;
		trigger = 0;

		// Wait 1000 ns for global reset to finish
		#1000;
		reset = 0;
        
		// Add stimulus here
		start = 0;
		#1000;
		start = 1;
		#500000;
		start = 0;
		#1000;
		

	end
      
endmodule

