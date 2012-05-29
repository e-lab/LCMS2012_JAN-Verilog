`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:58:19 04/04/2012
// Design Name:   LCMS2012_configuration
// Module Name:   C:/LCMS2012/LCMS2012_Verilog/LCMS2012_config_tb.v
// Project Name:  LCMS2012_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LCMS2012_configuration
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module LCMS2012_config_tb;

	// Inputs
	reg dac_sm_clk;
	reg reset;
	reg [15:0] int_gbt_i;
	reg [15:0] int_vbn_i;
	reg [15:0] int_vbp_i;
	reg [15:0] post_gbt_i;
	reg [15:0] post_vbn_i;
	reg [15:0] post_vbp_i;
	reg [15:0] obuff_gbt_i;
	reg [15:0] obuff_vbn_i;
	reg [15:0] obuff_vbp_i;
	reg infilter_seln_i;
	reg addr0_i;
	reg addr1_i;
	reg addr2_i;
	reg addr3_i;
	reg int_capselect1_i;
	reg int_capselect2_i;
	reg res_select_i;
	reg post_capselect_i;
	reg post_bypass_i;
	reg lpf_bypass_i;
	reg cds_bypass_i;
	reg [15:0] vref_i;
	reg [15:0] VCMD;

	// Outputs
	wire DAC_SCLK;
	wire DAC1_SYNC;
	wire DAC1_DIN;
	wire DAC2_SYNC;
	wire DAC2_DIN;
	wire INFILTER_SELN;
	wire ADDR0;
	wire ADDR1;
	wire ADDR2;
	wire ADDR3;
	wire LPF_BYPASS;
	wire POST_BYPASS;
	wire CDS_BYPASS;
	wire INT_CAPSELECT1;
	wire INT_CAPSELECT2;
	wire RES_SELECT;
	wire POST_CAPSELECT;

	// Instantiate the Unit Under Test (UUT)
	LCMS2012_configuration uut (
		.dac_sm_clk(dac_sm_clk), 
		.reset(reset), 
		.DAC_SCLK(DAC_SCLK), 
		.DAC1_SYNC(DAC1_SYNC), 
		.DAC1_DIN(DAC1_DIN), 
		.DAC2_SYNC(DAC2_SYNC), 
		.DAC2_DIN(DAC2_DIN), 
		.INFILTER_SELN(INFILTER_SELN), 
		.ADDR0(ADDR0), 
		.ADDR1(ADDR1), 
		.ADDR2(ADDR2), 
		.ADDR3(ADDR3), 
		.LPF_BYPASS(LPF_BYPASS), 
		.POST_BYPASS(POST_BYPASS), 
		.CDS_BYPASS(CDS_BYPASS), 
		.INT_CAPSELECT1(INT_CAPSELECT1), 
		.INT_CAPSELECT2(INT_CAPSELECT2), 
		.RES_SELECT(RES_SELECT), 
		.POST_CAPSELECT(POST_CAPSELECT), 
		.int_gbt_i(int_gbt_i), 
		.int_vbn_i(int_vbn_i), 
		.int_vbp_i(int_vbp_i), 
		.post_gbt_i(post_gbt_i), 
		.post_vbn_i(post_vbn_i), 
		.post_vbp_i(post_vbp_i), 
		.obuff_gbt_i(obuff_gbt_i), 
		.obuff_vbn_i(obuff_vbn_i), 
		.obuff_vbp_i(obuff_vbp_i), 
		.infilter_seln_i(infilter_seln_i), 
		.addr0_i(addr0_i), 
		.addr1_i(addr1_i), 
		.addr2_i(addr2_i), 
		.addr3_i(addr3_i), 
		.int_capselect1_i(int_capselect1_i), 
		.int_capselect2_i(int_capselect2_i), 
		.res_select_i(res_select_i), 
		.post_capselect_i(post_capselect_i), 
		.post_bypass_i(post_bypass_i), 
		.lpf_bypass_i(lpf_bypass_i), 
		.cds_bypass_i(cds_bypass_i), 
		.vref_i(vref_i), 
		.VCMD(VCMD)
	);

	always begin
		#50   dac_sm_clk = ~dac_sm_clk;   //10 MHz - 10 us = 10,000 ns / 2 = 5000 ns
	end
	
	initial begin
		// Initialize Inputs
		dac_sm_clk = 0;
		reset = 0;
		int_gbt_i = 0;
		int_vbn_i = 0;
		int_vbp_i = 0;
		post_gbt_i = 0;
		post_vbn_i = 0;
		post_vbp_i = 0;
		obuff_gbt_i = 0;
		obuff_vbn_i = 0;
		obuff_vbp_i = 0;
		infilter_seln_i = 0;
		addr0_i = 0;
		addr1_i = 0;
		addr2_i = 0;
		addr3_i = 0;
		int_capselect1_i = 0;
		int_capselect2_i = 0;
		res_select_i = 0;
		post_capselect_i = 0;
		post_bypass_i = 0;
		lpf_bypass_i = 0;
		cds_bypass_i = 0;
		vref_i = 0;
		VCMD = 0;

		reset = 1;
		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		#100
		res_select_i = 1;
      #100
		res_select_i = 0;
		// Add stimulus here

	end
      
endmodule

