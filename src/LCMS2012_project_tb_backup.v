`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:21:16 08/11/2011
// Design Name:   LCMS2010_project
// Module Name:   C:/LCMS2010/LCMS2010_VERILOG_REVA/LCMS2010_project_tb.v
// Project Name:  LCMS2010_VERILOG_REVA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LCMS2010_project
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

//`include "LCMS2010_project.v"

module LCMS2012_project_tb;

	// Inputs
	reg a_rst_hard;
	reg s_clk;
	reg ti_clk;
	reg ti_rst_soft;
	reg ti_in_data_en;
	reg [15:0] ti_in_data;
	reg ti_out_data_en;
	reg ti_in_test_en;
	reg [15:0] ti_in_test;
	reg ti_out_test_en;
	reg config_clk;
	reg dac_sm_clk;
	reg adc_sm_clk;
	reg reset_gen_clk;
	reg reset;
	reg ADC_SDO;
	reg [15:0] int_gbt_i;
	reg [15:0] int_vbn_i;
	reg [15:0] int_vbp_i;
	reg [15:0] post_gbt_i;
	reg [15:0] post_vbn_i;
	reg [15:0] post_vbp_i;
	reg [15:0] obuff_gbt_i;
	reg [15:0] obuff_vbn_i;
	reg [15:0] obuff_vbp_i;
	reg [15:0] reset_period_i;
	reg [15:0] int_reset_duration_i;
	reg [15:0] post_reset_duration_i;
	reg [15:0] v_sampling_period_i;
	reg a0_i;
	reg a1_i;
	reg a2_i;
	reg a3_i;
	reg int_capselect_i;
	reg post_capselect_i;
	reg post_bypass_i;
	reg lpf_bypass_i;
	reg mode_i;
	reg [15:0] vref_i;
	reg [15:0] VCMD;

	// Outputs
	wire [7:0] a_led;
	wire [15:0] ti_in_available;
	wire [15:0] ti_out_available;
	wire [15:0] ti_out_data;
	wire [15:0] ti_out_test;
	wire DAC_SCLK;
	wire DAC1_SYNC;
	wire DAC1_DIN;
	wire DAC2_SYNC;
	wire DAC2_DIN;
	wire A0;
	wire A1;
	wire A2;
	wire A3;
	wire LPF_BYPASS;
	wire POST_BYPASS;
	wire INT_CAPSELECT;
	wire INT_RESET;
	wire POST_CAPSELECT;
	wire POST_RESET;
	wire ADC_SDI;
	wire ADC_SCK;
	wire ADC_CNV;
	wire [15:0] adc_result;


	//test variables
	time clk_freq_test_1;
	time clk_freq_test_2;

	// Instantiate the Unit Under Test (UUT)
	LCMS2012_project uut (
		.a_led(a_led), 
		.a_rst_hard(a_rst_hard), 
		.s_clk(s_clk), 
		.ti_clk(ti_clk), 
		.ti_rst_soft(ti_rst_soft), 
		.ti_in_available(ti_in_available), 
		.ti_in_data_en(ti_in_data_en), 
		.ti_in_data(ti_in_data), 
		.ti_out_available(ti_out_available), 
		.ti_out_data_en(ti_out_data_en), 
		.ti_out_data(ti_out_data), 
		.ti_in_test_en(ti_in_test_en), 
		.ti_in_test(ti_in_test), 
		.ti_out_test_en(ti_out_test_en), 
		.ti_out_test(ti_out_test), 
		.config_clk(config_clk), 
		.dac_sm_clk(dac_sm_clk), 
		.adc_sm_clk(adc_sm_clk), 
		.reset_gen_clk(reset_gen_clk), 
		.reset(reset), 
		.DAC_SCLK(DAC_SCLK), 
		.DAC1_SYNC(DAC1_SYNC), 
		.DAC1_DIN(DAC1_DIN), 
		.DAC2_SYNC(DAC2_SYNC), 
		.DAC2_DIN(DAC2_DIN), 
		.A0(A0), 
		.A1(A1), 
		.A2(A2), 
		.A3(A3), 
		.LPF_BYPASS(LPF_BYPASS), 
		.POST_BYPASS(POST_BYPASS), 
		.INT_CAPSELECT(INT_CAPSELECT), 
		.INT_RESET(INT_RESET), 
		.POST_CAPSELECT(POST_CAPSELECT), 
		.POST_RESET(POST_RESET), 
		.ADC_SDI(ADC_SDI), 
		.ADC_SCK(ADC_SCK), 
		.ADC_CNV(ADC_CNV), 
		.ADC_SDO(ADC_SDO), 
		.int_gbt_i(int_gbt_i), 
		.int_vbn_i(int_vbn_i), 
		.int_vbp_i(int_vbp_i), 
		.post_gbt_i(post_gbt_i), 
		.post_vbn_i(post_vbn_i), 
		.post_vbp_i(post_vbp_i), 
		.obuff_gbt_i(obuff_gbt_i), 
		.obuff_vbn_i(obuff_vbn_i), 
		.obuff_vbp_i(obuff_vbp_i), 
		.reset_period_i(reset_period_i), 
		.int_reset_duration_i(int_reset_duration_i), 
		.post_reset_duration_i(post_reset_duration_i), 
		.v_sampling_period_i(v_sampling_period_i), 
		.a0_i(a0_i), 
		.a1_i(a1_i), 
		.a2_i(a2_i), 
		.a3_i(a3_i), 
		.int_capselect_i(int_capselect_i), 
		.post_capselect_i(post_capselect_i), 
		.post_bypass_i(post_bypass_i), 
		.lpf_bypass_i(lpf_bypass_i), 
		.mode_i(mode_i), 
		.vref_i(vref_i), 
		.VCMD(VCMD), 
		.adc_result(adc_result)
	);

	//clocks
	always begin
		#5		s_clk =  ~s_clk; // 100 MHz s_clk toggle every 0.010 us 
	end
	
	always begin
		#500  config_clk = ~config_clk; //1 MHz - 1 us = 1000ns period /2 = 500ns toggle time
	end
	
	always begin
		#50   dac_sm_clk = ~dac_sm_clk;   //10 MHz - 10 us = 10,000 ns / 2 = 5000 ns
	end
	
	always begin
		#12.5 adc_sm_clk = ~adc_sm_clk;       //40 MHz = 25 ns /2 = 12.5 ns
	end
	
	always begin
		#500 reset_gen_clk = ~reset_gen_clk;  //1 MHz - 1 us = 1000ns period /2 = 500ns toggle time		
	end
	
	initial begin
		// Initialize Inputs
		a_rst_hard = 0;
		s_clk = 0;
		ti_clk = 0;
		ti_rst_soft = 0;
		ti_in_data_en = 0;
		ti_in_data = 0;
		ti_out_data_en = 0;
		ti_in_test_en = 0;
		ti_in_test = 0;
		ti_out_test_en = 0;
		config_clk = 0;
		dac_sm_clk = 0;
		adc_sm_clk = 0;
		reset_gen_clk = 0;
		reset = 1;
		ADC_SDO = 0;
		int_gbt_i = 0;
		int_vbn_i = 0;
		int_vbp_i = 0;
		post_gbt_i = 0;
		post_vbn_i = 0;
		post_vbp_i = 0;
		obuff_gbt_i = 0;
		obuff_vbn_i = 0;
		obuff_vbp_i = 0;
		reset_period_i = 0;
		int_reset_duration_i = 0;
		post_reset_duration_i = 0;
		v_sampling_period_i = 0;
		a0_i = 0;
		a1_i = 0;
		a2_i = 0;
		a3_i = 0;
		int_capselect_i = 0;
		post_capselect_i = 0;
		post_bypass_i = 0;
		lpf_bypass_i = 0;
		mode_i = 0;
		vref_i = 0;
		VCMD = 0;

		// Wait 1000 ns for global reset to finish
		#1000;
		reset = 1;
		#1000;
		reset = 0;
		
		// Add stimulus here
		 $display ("###################################################");
		reset_period_i = 100;
		int_reset_duration_i = 2;
		post_reset_duration_i = 3;
		v_sampling_period_i = 100; //user says sample every 100 us = 10 kHz
				
		test_s_clk_freq;
		test_config_clk_freq;
		test_dac_clk_freq;
		test_adc_clk_freq;
		test_reset_gen_clk_freq;
      #1000000
		
		$finish;
		
	end
	
	task test_s_clk_freq;
		time t1;
		time t2;
		time dt;
		time  f;
		begin
			@(posedge s_clk)
				t1 = $time;
			@(posedge s_clk)
				t2 = $time;
				dt=t2-t1;
				f=1E-6/(dt*1E-9);
				$display ("s_clk :", f, "MHz");  //the timescale is 1 ns
				if (f != 100)
					$display ("FAIL");
				else $display ("OK");
		end
   endtask   
	
	task test_config_clk_freq;
		time t1;
		time t2;
		time dt;
		time  f;
		begin
			@(posedge config_clk)
				t1 = $time;
			@(posedge config_clk)
				t2 = $time;
				dt=t2-t1;
				f=1E-6/(dt*1E-9);
				$display ("config_clk :", f, "MHz");  //the timescale is 1 ns
				if (f != 1)
					$display ("FAIL");
				else $display ("OK");
		end
   endtask   
	
	task test_dac_clk_freq;
		time t1;
		time t2;
		time dt;
		time  f;
		begin
			@(posedge dac_sm_clk)
				t1 = $time;
			@(posedge dac_sm_clk)
				t2 = $time;
				dt=t2-t1;
				f=1E-6/(dt*1E-9);
				$display ("dac_clk :", f, "MHz");  //the timescale is 1 ns
				if (f != 10)
					$display ("FAIL");
				else $display ("OK");
		end
   endtask   	

	task test_adc_clk_freq;
		time t1;
		time t2;
		time dt;
		time  f;
		begin
			@(posedge adc_sm_clk)
				t1 = $time;
			@(posedge adc_sm_clk)
				t2 = $time;
				dt=t2-t1;
				f=1E-6/(dt*1E-9);
				$display ("adc_clk :", f, "MHz");  //the timescale is 1 ns
				if (f != 40)
					$display ("FAIL");
				else $display ("OK");
		end
   endtask   	

	task test_reset_gen_clk_freq;
		time t1;
		time t2;
		time dt;
		time  f;
		begin
			@(posedge reset_gen_clk)
				t1 = $time;
			@(posedge reset_gen_clk)
				t2 = $time;
				dt=t2-t1;
				f=1E-6/(dt*1E-9);
				$display ("adc_clk :", f, "MHz");  //the timescale is 1 ns
				if (f != 1)
					$display ("FAIL");
				else $display ("OK");
		end
   endtask   		
endmodule

