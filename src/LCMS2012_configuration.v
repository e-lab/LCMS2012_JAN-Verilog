`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        E-Lab Yale
// Engineer:       Brian Goldstein
// 
// Create Date:    16:54:56 07/25/2011 
// Design Name:    LCMS2010
// Module Name:    LCMS2010_configuration_xem6010 
// Project Name:   LCMS2010
// Target Devices: XEM6010
// Tool versions:  Xilinx ISE 13.1
// Description:    This module controls the digital configuration bits for the LCMS 2010 chip
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LCMS2012_configuration(
   // input clk,					//main process clock
    input dac_sm_clk,		//dac state machine clock
	// input dac_sm_rst,			//if we reset based on the dac reset here it will screw up the measurements, so leave it out for now
    input reset,					//use a fake reset for now
	 
	 // DAC Pins
    output DAC_SCLK,
    output DAC1_SYNC,
    output DAC1_DIN,
    output DAC2_SYNC,
    output DAC2_DIN,
	 
	 // LCMS Interface Digital Pins
	 output reg INFILTER_SELN,
    output reg ADDR0,
    output reg ADDR1,
    output reg ADDR2,
    output reg ADDR3,
    output reg LPF_BYPASS,
    output reg POST_BYPASS,
	 output reg CDS_BYPASS,
    output reg INT_CAPSELECT1,
	 output reg INT_CAPSELECT2,
	 output reg RES_SELECT,
	 output reg POST_CAPSELECT,
	 
	 // LCMS bias signals
    input [15:0] int_gbt_i,
    input [15:0] int_vbn_i,
    input [15:0] int_vbp_i,
    input [15:0] post_gbt_i,
    input [15:0] post_vbn_i,
    input [15:0] post_vbp_i,
    input [15:0] obuff_gbt_i,
    input [15:0] obuff_vbn_i,
    input [15:0] obuff_vbp_i,
	 
	 // LCMS configuration signals
	 input infilter_seln_i,
    input addr0_i,
    input addr1_i,
    input addr2_i,
    input addr3_i,
    input int_capselect1_i,
	 input int_capselect2_i,
	 input res_select_i,
    input post_capselect_i,
    input post_bypass_i,
    input lpf_bypass_i,
	 input cds_bypass_i,
	 
	 // signals for current measurement
    input [15:0] vref_i,
    input [15:0] VCMD
    );
	 
	/************************************************************************************
	* Internal signals
	************************************************************************************/

	// DAC outputs signals
	reg [15:0] v_dac1_a;
	reg [15:0] v_dac1_b;
	reg [15:0] v_dac1_c;
	reg [15:0] v_dac1_d;
	reg [15:0] v_dac1_e;
	reg [15:0] v_dac1_f;
	reg [15:0] v_dac1_g;
	reg [15:0] v_dac1_h;
	reg dac1_disable_a;
	reg dac1_disable_b;
	reg dac1_disable_c;
	reg dac1_disable_d;
	reg dac1_disable_e;
	reg dac1_disable_f;
	reg dac1_disable_g;
	reg dac1_disable_h;
	wire dac1_sclk;
	
	reg [15:0] v_dac2_a;
	reg [15:0] v_dac2_b;
	reg [15:0] v_dac2_c;
	reg [15:0] v_dac2_d;
	reg [15:0] v_dac2_e;
	reg [15:0] v_dac2_f;
	reg [15:0] v_dac2_g;
	reg [15:0] v_dac2_h;
	reg dac2_disable_a;
	reg dac2_disable_b;
	reg dac2_disable_c;
	reg dac2_disable_d;
	reg dac2_disable_e;
	reg dac2_disable_f;
	reg dac2_disable_g;
	reg dac2_disable_h;
	wire dac2_sclk;
	
	DAC_AD5668_Interface 
	DAC1 (
			.clk					(dac_sm_clk),
			.v_dac_a				(v_dac1_a),
			.v_dac_b				(v_dac1_b),
			.v_dac_c				(v_dac1_c),
			.v_dac_d				(v_dac1_d),
			.v_dac_e				(v_dac1_e),
			.v_dac_f				(v_dac1_f),
			.v_dac_g				(v_dac1_g),
			.v_dac_h			 	(v_dac1_h),
			.disable_dac_a		(dac1_disable_a),
			.disable_dac_b		(dac1_disable_b),
			.disable_dac_c		(dac1_disable_c),
			.disable_dac_d		(dac1_disable_d),
			.disable_dac_e		(dac1_disable_e),
			.disable_dac_f		(dac1_disable_f),
			.disable_dac_g		(dac1_disable_g),
			.disable_dac_h		(dac1_disable_h),
			.SCLK					(dac1_sclk),
			.SYNC					(DAC1_SYNC),
			.DIN					(DAC1_DIN)
		);
	
	DAC_AD5668_Interface 
	DAC2 (
			.clk					(dac_sm_clk),
			.v_dac_a				(v_dac2_a),
			.v_dac_b				(v_dac2_b),
			.v_dac_c				(v_dac2_c),
			.v_dac_d				(v_dac2_d),
			.v_dac_e				(v_dac2_e),
			.v_dac_f				(v_dac2_f),
			.v_dac_g				(v_dac2_g),
			.v_dac_h			 	(v_dac2_h),
			.disable_dac_a		(dac2_disable_a),
			.disable_dac_b		(dac2_disable_b),
			.disable_dac_c		(dac2_disable_c),
			.disable_dac_d		(dac2_disable_d),
			.disable_dac_e		(dac2_disable_e),
			.disable_dac_f		(dac2_disable_f),
			.disable_dac_g		(dac2_disable_g),
			.disable_dac_h		(dac2_disable_h),
			.SCLK					(dac2_sclk),
			.SYNC					(DAC2_SYNC),
			.DIN					(DAC2_DIN)
		);	
	
	
	/************************************************************************************
	* Implementation
	************************************************************************************/

	assign DAC_SCLK = dac1_sclk & dac2_sclk;
	
	// process used for handling inputs
	always @(posedge dac_sm_clk) begin
		if (reset) begin
				INFILTER_SELN <= 0;
				ADDR0 <= 0;
				ADDR1 <= 0;
				ADDR2 <= 0;
				ADDR3 <= 0;
				LPF_BYPASS <= 0;
				POST_BYPASS <= 0;
				CDS_BYPASS <= 0;
			   INT_CAPSELECT1 <= 0;
				INT_CAPSELECT2 <= 0;
				RES_SELECT <= 0;
			   POST_CAPSELECT <= 0;
				dac1_disable_a <= 1'b1; //vcmd
				dac1_disable_b <= 1'b1; 
				dac1_disable_c <= 1'b1; //int_gbt
				dac1_disable_d <= 1'b1; //vref
				dac1_disable_e <= 1'b1; //int_vbn
				dac1_disable_f <= 1'b1; //post_vbn
				dac1_disable_g <= 1'b0; //int_vbp
				dac1_disable_h <= 1'b0; //post_vbp				
				
				dac2_disable_a <= 1'b0;	//post_gbt	
				dac2_disable_b <= 1'b1; //obuff_vbn 
				dac2_disable_c <= 1'b1; //obuff_vbp
				dac2_disable_d <= 1'b1; //obuff_gbt
				dac2_disable_e <= 1'b1;
				dac2_disable_f <= 1'b1;
				dac2_disable_g <= 1'b0;
				dac2_disable_h <= 1'b0;
			end
		else 
			begin
				// enable the DAC channels that we are using
				dac1_disable_a <= 1'b0; 
				dac1_disable_b <= 1'b0; 
				dac1_disable_c <= 1'b0;
				dac1_disable_d <= 1'b0;
				dac1_disable_e <= 1'b0;
				dac1_disable_f <= 1'b0;  
				dac1_disable_g <= 1'b1;
				dac1_disable_h <= 1'b1;
				
				dac2_disable_a <= 1'b1;		
				dac2_disable_b <= 1'b0;
				dac2_disable_c <= 1'b0;
				dac2_disable_d <= 1'b0;  
				dac2_disable_e <= 1'b0;  
				dac2_disable_f <= 1'b0;  
				dac2_disable_g <= 1'b1;  
				dac2_disable_h <= 1'b1;  				
				
				// set digital configuration bits based on values received on wires
				INFILTER_SELN  <= infilter_seln_i;
				ADDR0				<= addr0_i;
				ADDR1				<= addr1_i;
				ADDR2				<= addr2_i;
				ADDR3				<= addr3_i;
				LPF_BYPASS		<= lpf_bypass_i;
				POST_BYPASS		<= post_bypass_i;
				CDS_BYPASS		<= cds_bypass_i;
				POST_CAPSELECT	<= post_capselect_i;
				INT_CAPSELECT1	<= int_capselect1_i;
				INT_CAPSELECT2 <= int_capselect2_i;
				RES_SELECT 		<= res_select_i;
				
				// set DAC inputs based on values received on wires (or vcmd on pipe)
				v_dac1_a <= post_vbp_i;
				v_dac1_b <= obuff_vbn_i;
				v_dac1_c <= post_vbn_i;
				v_dac1_d <= obuff_gbt_i;
				v_dac1_e <= post_gbt_i;
				v_dac1_f <= obuff_vbp_i;
				v_dac1_g <= 16'b0;
				v_dac1_h <= 16'b0;
				v_dac2_a <= 16'b0;
				v_dac2_b <= vref_i;
				v_dac2_c <= VCMD;
				v_dac2_d <= int_vbp_i;
				v_dac2_e <= int_gbt_i;
				v_dac2_f <= int_vbn_i;
				v_dac2_g <= 16'b0;
				v_dac2_h <= 16'b0;
			end	
	end
	

endmodule
