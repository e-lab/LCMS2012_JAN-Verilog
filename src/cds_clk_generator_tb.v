`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:19:30 03/29/2012
// Design Name:   cds_clk_generator
// Module Name:   C:/LCMS2012/LCMS2012_Verilog/cds_clk_generator_tb.v
// Project Name:  LCMS2012_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cds_clk_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cds_clk_generator_tb;

	// Inputs
	reg clk;
	reg reset;
	reg trigger;
	reg [0:15] cds_delay1;
	reg [0:15] cds_delay2;
	reg [0:15] cds_width;

	// Outputs
	wire cds_clk1;
	wire cds_clk2;
	wire cds_done;

	// Instantiate the Unit Under Test (UUT)
	cds_clk_generator uut (
		.clk(clk), 
		.reset(reset), 
		.trigger(trigger), 
		.cds_delay1(cds_delay1), 
		.cds_delay2(cds_delay2), 
		.cds_width(cds_width), 
		.cds_clk1(cds_clk1), 
		.cds_clk2(cds_clk2), 
		.cds_done(cds_done)
	);
	
	// Clock generator
	always begin
		#25  clk = ~clk; // Toggle clock high/low every 50ns => (20 MHz)
	end
 	
// trigger generator (assume resetting at 10 kHz)
	always begin
		#90000 trigger = 1'b1;
		#10000 trigger = 1'b0; //assuming reset is high for 10 us
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		trigger = 0;
		cds_delay1 = 2;
		cds_delay2 = 90;
		cds_width = 2;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 0;
		
		// Add stimulus here
		#500000; //run for 500us to see a few reset cycles
	end
      
endmodule

