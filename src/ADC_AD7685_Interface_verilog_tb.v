`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:49:45 12/05/2011
// Design Name:   ADC_AD7685_Interface_verilog
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/ADC_AD7685_Interface_verilog_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ADC_AD7685_Interface_verilog
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ADC_AD7685_Interface_verilog_tb;

	// Inputs
	reg CLK;
	reg RST;
	reg CNV_START;
	reg SDO;

	// Outputs
	wire BUSY;
	wire CNV;
	wire SCK;
	wire SDI;
	wire [15:0] RESULT;
	wire VALID;

	// Instantiate the Unit Under Test (UUT)
	ADC_AD7685_Interface_verilog uut (
		.CLK(CLK), 
		.rst(RST),
		.CNV_START(CNV_START), 
		.SDO(SDO), 
		.BUSY(BUSY), 
		.CNV(CNV), 
		.SCK(SCK), 
		.SDI(SDI), 
		.RESULT(RESULT), 
		.VALID(VALID)
	);
	
	// Clock generator
	always begin
		#25  CLK = ~CLK; // Toggle clock high/low every 50ns => (20 MHz)
	end
	
	integer counter;
	always @ (negedge CNV) begin
		#75 SDO = 0;
		#50 SDO = 1;
	end
	
 	
 //trigger generator (assume resetting at 100 kHz)
	always begin  //high 
		#99000 CNV_START = 1'b1; //actually make it really fast
		#50 CNV_START = 1'b0; //assuming convert is high for 1 clock (50ns)
	end

	initial begin
		// Initialize Inputs
		counter = 0;
		CLK = 0;
		RST = 1;
		CNV_START = 0;
		SDO = 1;

		// Wait 100 ns for global reset to finish
		#100;
		RST = 0;
        
		// Add stimulus here

	end
      
endmodule

