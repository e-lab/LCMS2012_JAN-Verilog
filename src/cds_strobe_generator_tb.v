`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:59:33 09/06/2011
// Design Name:   cds_strobe_generator
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/cds_strobe_generator_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cds_strobe_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cds_strobe_generator_tb;

	// Inputs
	reg clk;
	reg reset;
	reg trigger;
	reg [0:15] cds_delay1;
	reg [0:15] cds_delay2;

	// Outputs
	wire cds_strobe;

	// Instantiate the Unit Under Test (UUT)
	cds_strobe_generator uut (
		.clk(clk), 
		.reset(reset), 
		.trigger(trigger), 
		.cds_delay1(cds_delay1), 
		.cds_delay2(cds_delay2), 
		.cds_strobe(cds_strobe)
	);

// Clock generator
	always begin
		#25  clk = ~clk; // Toggle clock high/low every 50ns => (20 MHz)
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
		trigger = 0;
		cds_delay1 = 2;
		cds_delay2 = 95;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
        
		// Add stimulus here
		#500000; //run for 500us to see a few reset cycles

	end
      
endmodule

