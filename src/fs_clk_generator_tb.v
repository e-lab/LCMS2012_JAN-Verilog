`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:04:59 09/12/2011
// Design Name:   fs_clk_generator
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/fs_clk_generator_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fs_clk_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fs_clk_generator_tb;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg trigger;
	reg [23:0] fs_cnt_max;

	// Outputs
	wire fs_clk;

	// Instantiate the Unit Under Test (UUT)
	fs_clk_generator uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.trigger(trigger), 
		.fs_cnt_max(fs_cnt_max), 
		.fs_clk(fs_clk)
	);

	always begin
		#5		clk =  ~clk; // 100 MHz s_clk toggle every 0.010 us 
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
		fs_cnt_max = 0;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 0;
		  
		// Add stimulus here
		fs_cnt_max = 999; //100 khz fs, here fs is much faster than reset freq
		#100000
		start = 1;
		#900000;
		start = 0;
		fs_cnt_max = 9999; //10 khz, here fs is the same as the reset freq
		#900000;
		start = 1;
		
		//run for 400us

	end
      
endmodule

