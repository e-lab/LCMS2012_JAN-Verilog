`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:24:59 09/15/2011
// Design Name:   ADC_AD7685_Interface
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/adc_7685_interface_test.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ADC_AD7685_Interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module adc_7685_interface_test;

	// Inputs
	reg CLK;
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
	ADC_AD7685_Interface uut (
		.CLK(CLK), 
		.CNV_START(CNV_START), 
		.BUSY(BUSY), 
		.CNV(CNV), 
		.SCK(SCK), 
		.SDI(SDI), 
		.SDO(SDO), 
		.RESULT(RESULT), 
		.VALID(VALID)
	);
	
	// Clock generator
	always begin
		#25  CLK = ~CLK; // Toggle clock high/low every 50ns => (20 MHz)
	end
 	
// trigger generator (assume resetting at 100 kHz)
	always begin  //high 
		#99000 CNV_START = 1'b1; //actually make it really fast
		#50 CNV_START = 1'b0; //assuming convert is high for 1 clock (50ns)
		
	end
	

	initial begin
		// Initialize Inputs
		CLK = 0;
		CNV_START = 0;
		SDO = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

