`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:       Yale
// Engineer:      Brian Goldstein
//
// Create Date:   16:28:11 07/28/2011
// Design Name:   reset_generator
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/reset_generator_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device: XEM6010
// Tool versions: Xilinx ISE13.1 and ISIM
// Description:   Verilog Test Fixture created by ISE for module: int_reset_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module reset_generator_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [0:15] low_time;
	reg [0:15] high_time;

	// Outputs
	wire T_RESET;

	// Instantiate the Unit Under Test (UUT)
	reset_generator uut (
		.clk(clk),
		.reset(reset),
      .low_time(low_time),
		.high_time(high_time),
		.RESET_OUT(T_RESET)
    );
	
	// Clock generator
	always begin
		#500  clk = ~clk; // Toggle clock high/low every 500ns => 1us period (1 MHz)
	end
 	initial begin
	
	
		// Initialize Inputs first low 98us and high 2us
		clk = 0;
		reset = 1;
		low_time = 98;
		high_time = 2;

		// Wait 1000 ns for global reset to finish
		#1000;
		reset = 0;
		#1000000;  

		//test never reset
		low_time = 0;
		high_time =65535;
		#1000000;  

		//test always reset
		low_time = 100;
		high_time = 0;
		#1000000;
		
		//back to 100 us
		low_time = 98;
		high_time = 2;
		#1000000;
		

		

	end
      
endmodule

