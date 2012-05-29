`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:36:57 09/16/2011
// Design Name:   DAC_AD5668_Interface
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/dac_ad5668_interface_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DAC_AD5668_Interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dac_ad5668_interface_tb;

	// Inputs
	reg CLK;
	reg [15:0] v_dac_a;
	reg [15:0] v_dac_b;
	reg [15:0] v_dac_c;
	reg [15:0] v_dac_d;
	reg [15:0] v_dac_e;
	reg [15:0] v_dac_f;
	reg [15:0] v_dac_g;
	reg [15:0] v_dac_h;
	reg disable_dac_a;
	reg disable_dac_b;
	reg disable_dac_c;
	reg disable_dac_d;
	reg disable_dac_e;
	reg disable_dac_f;
	reg disable_dac_g;
	reg disable_dac_h;

	// Outputs
	wire SCLK;
	wire SYNC;
	wire DIN;
	
	//for testing
	reg cnv_start;

	// Instantiate the Unit Under Test (UUT)
	DAC_AD5668_Interface uut (
		.CLK(CLK), 
		.v_dac_a(v_dac_a), 
		.v_dac_b(v_dac_b), 
		.v_dac_c(v_dac_c), 
		.v_dac_d(v_dac_d), 
		.v_dac_e(v_dac_e), 
		.v_dac_f(v_dac_f), 
		.v_dac_g(v_dac_g), 
		.v_dac_h(v_dac_h), 
		.disable_dac_a(disable_dac_a), 
		.disable_dac_b(disable_dac_b), 
		.disable_dac_c(disable_dac_c), 
		.disable_dac_d(disable_dac_d), 
		.disable_dac_e(disable_dac_e), 
		.disable_dac_f(disable_dac_f), 
		.disable_dac_g(disable_dac_g), 
		.disable_dac_h(disable_dac_h), 
		.SCLK(SCLK), 
		.SYNC(SYNC), 
		.DIN(DIN)
	);

	// Clock generator
	always begin
		#50  CLK = ~CLK; // Toggle clock high/low every 100ns => (10 MHz)
	end
	
	
	
	// trigger generator (assume resetting at 100 kHz)
	always begin  //high 
		//#99000 cnv_start = 1'b1; //actually make it really fast
		//#50 cnv_start = 1'b0; //assuming convert is high for 1 clock (50ns)
		#99000 v_dac_a = 16'b1111111111111111;
		#50 v_dac_a = 16'b0000000000000000;
	end
	//	always begin
	//		if(cnv_start)	v_dac_a <= v_dac_a + 1;
	//	end
		
	initial begin
		// Initialize Inputs
		CLK = 0;
		cnv_start = 0;
		v_dac_a = 0;
		v_dac_b = 0;
		v_dac_c = 0;
		v_dac_d = 0;
		v_dac_e = 0;
		v_dac_f = 0;
		v_dac_g = 0;
		v_dac_h = 0;
		disable_dac_a = 0;
		disable_dac_b = 0;
		disable_dac_c = 0;
		disable_dac_d = 0;
		disable_dac_e = 0;
		disable_dac_f = 0;
		disable_dac_g = 0;
		disable_dac_h = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
        
		// Add stimulus here


	end
      
endmodule

