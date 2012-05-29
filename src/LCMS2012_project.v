/***************************************************************************************************
 * Module: xem6010_template_project
 *
 * Description: Simple project for use with a Opal Kelly board.  Takes data piped from the computer
 *              and stores it in an async input buffer.  Then transfers the data into an output
 *              buffer to be piped out to the computer.
 *
 * Created: Fri 22 Jul 2011 13:48:03 EDT
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 *          Adapted for LCMS2010 Rev A (XEM6010) by Brian Goldstein  //brian.goldstein@yale.edu
 *          Added LCMS digitial configuration module to set digital config and DACs for biasing
 *          Updated Tue 27 Mar 2012 for LCMS2012 by Brian Goldstein 
 **************************************************************************************************/
`ifndef _xem6010_template_project_ `define _xem6010_template_project_

//`include "reset_generator.v"  //creates the int and post synchronous reset signals
//`include "ADC_AD7685_Interface.vhd"
//`include "LCMS2012_configuration.v"
`include "reset_sync.v"  
`include "signal_sync.v"
`include "pulse_gen.v"
`include "opalkelly_pipe.v"


module LCMS2012_project #(
	parameter
		MEM_ADDR_WIDTH = 10)    //10 = 1024 buffer spots, bug on xem6010 we can go much bigger here
	(output [7:0]   a_led,
	//input           a_rst_hard,

	input           s_clk,

	input           ti_clk,
	input           ti_rst_soft,

	output [15:0]   ti_in_available,
	input           ti_in_data_en,
	input  [15:0]   ti_in_data,

	output [15:0]   ti_out_available,
	input           ti_out_data_en,
	output [15:0]   ti_out_data,

	//input           ti_in_test_en,
	//input  [15:0]   ti_in_test,
	//input           ti_out_test_en,
	//output [15:0]   ti_out_test,p
	 
	// signals for configuration module
	input config_clk,
	input dac_sm_clk,
	input adc_sm_clk,
	input reset_gen_clk,
	input reset,			//reset comes from wire in 0x01 bit 0
	output DAC_SCLK,
	output DAC1_SYNC,
	output DAC1_DIN,
	output DAC2_SYNC,
	output DAC2_DIN,	
   output INFILTER_SELN,
	output ADDR0,
	output ADDR1,
	output ADDR2,
	output ADDR3,
	output LPF_BYPASS,
	output POST_BYPASS,
	output CDS_BYPASS,
	output CDS_CLK1,
	output CDS_CLK2,
	output INT_CAPSELECT1,
	output INT_CAPSELECT2,
	output RES_SELECT,
	inout INT_RESET,
	output POST_CAPSELECT,
	output POST_RESET,
	output ADC_SDI,
	output ADC_SCK,
	output ADC_CNV,
	input ADC_SDO,
	input [15:0] int_gbt_i,
	input [15:0] int_vbn_i,
	input [15:0] int_vbp_i,
	input [15:0] post_gbt_i,
	input [15:0] post_vbn_i,
	input [15:0] post_vbp_i,
	input [15:0] obuff_gbt_i,
	input [15:0] obuff_vbn_i,
	input [15:0] obuff_vbp_i,
	input [15:0] reset_period_i,
	input [15:0] int_reset_duration_i,
	input [15:0] post_reset_duration_i,	
	input [15:0] v_sampling_period_i,
	input infilter_seln_i,
	input addr0_i,
	input addr1_i,
	input addr2_i,
	input addr3_i,
	input int_capselect1_i,
	input	int_capselect2_i,
	input res_select_i,
	input post_capselect_i,
	input post_bypass_i,
	input lpf_bypass_i,
	input cds_bypass_i,
	input mode_i,
	input [15:0] vref_i,
	//input [15:0] VCMD,
	input [15:0] cds_time1_delay_i,
	input [15:0] cds_time2_delay_i,
	input [15:0] cds_width_i,
	input mode2_i,
	output [15:0] adc_result,
	inout start_meas,							//start is 1 bit, to signify when to start setting dac vcmd to pipe in values
	output reg adc_cnv_start, //output for debug
	output dac_start,			  //output for debug
	output adc_fs_pulse		  //output for debug
   );


	/************************************************************************************
	* Internal signals
	************************************************************************************/
	localparam ADC_DELAY_NUM = 160;  //wait 8 us for dac settling time (in number of adc_sm_clk cycles) before starting adc convert
	reg [ADC_DELAY_NUM-1 : 0] adc_pulse_delayer;  //we want the adc to read a delayed amount of time after the dac starts
	localparam ADC_DELAY_NUM2 = 20;
	reg [ADC_DELAY_NUM2-1 : 0] adc_pulse_delayer2;  //we want the adc to read a delayed amount of time after the dac starts
			
	
	// resets
	//wire        a_rst;
	wire        s_rst;
	wire        ti_rst;

	//for pipe in and out
	reg         dac_rx_ready;
	wire        dac_rx_valid;
	wire [15:0] dac_rx;
	reg [15:0]  VCMD;

	wire        adc_tx_ready;
	reg         adc_tx_valid;
	reg  [15:0] adc_tx;
	
	reg measurement_in_progress_dac;
	reg measurement_in_progress_adc;
	
	
	//reg [15:0] adc_cds1;
	//reg [15:0] adc_cds2;
	//reg [16:0] adc_tx_temp;
	reg signed [15:0] adc_cds1;
	reg signed [15:0] adc_cds2;
	reg signed [15:0] adc_tx_temp;
	

	//for synchronous voltage sampling clock
//	reg fs_clk;   			//user selected sampling frequency for adc and dac
	reg[15:0] fs_cnt;		// counter to create the fs_clk
	wire [23:0] fs_cnt_max_dac;	//max value of the counter before toggling dac_fs_clk
	wire [23:0] fs_cnt_max_adc;	//max value of the counter before toggling adc_fs_clk
	

	//for clock domain crossing
	wire reset_gen_rst; 			//reset signal synced to reset_gen_clk
	wire config_rst;   			//reset signal synced to config_clk
	wire dac_sm_rst;  			//reset signal synced to dac_sm_clk
	wire dac_sm_start_meas;    //start signal synced to dac_sm_clk
	wire dac_fs_clk;   			//fs_clk signal synced to dac_sm_clk	
	wire adc_sm_rst;    			//reset signal synced to adc_sm_clk
	wire adc_sm_start_meas;    //start signal synced to adc_sm_clk
	wire adc_fs_clk;				//fs_clk signal synced to adc_sm_clk
	
	wire measurement_in_progress_dac_adc_sm; //measurement_in_progress_dac signal synced to adc_sm_clk
	wire measurement_in_progress_adc_dac_sm; //measurement_in_progress_adc signal synced to dac_sm_clk
	
	
	//for dac control
	wire dac_start_sync; 		//when start_meas is true, dac_start_sync goes high after the next reset pulse starts, and goes low again when start_meas is false
	
	
	//for adc control
	wire adc_cnv_start_v;	//signal to control when the adc converts in sync v mode (this is a delayed version of adc_start, to give dac settling time before reading adc
	wire adc_cnv_start_cds;  //signal to control when the adc converts in sync i mode (this is on the adc clock)
	wire adc_cnv_start_hw_cds; //signal to control when the adc converts in sync i hardware cds mode
	wire cds_first;  //high when the first adc value after reset is read, low otherwise
	wire adc_valid;  //goes high for 1 clock cycle after adc data is collected, use this to know when to put the result to the pipe out transmit buffer
	//	wire adc_start;      //a small pulse is created on the adc clock based on how the user chooses fs rate (adc sampling rate)
	reg cds_flag;  //high after the second cds value is captured to trigger the subtraction and put the value on the tx pipe out buffer 
	
	wire adc_cnv_start_hw_cds_delay; //signal to delay the adc sampling 1us when in hardware cds mode

	
	//moved to outputs
	//reg adc_cnv_start;  //multiplexed signal to send to the adc, either adc_cnv_start_v or adc_cnv_start_cds based on mode_i
	//wire dac_start; 				//dac_start tells the DAC exactly when to take a value off the rx pipe in and change the dac to that value by ANDING dac_start_sync and dac_fs_clk.
		
	//reset integrator  and post-amp signals
	wire [15:0] int_low_time;
	wire [15:0] int_high_time;
	wire [15:0] post_low_time;
	wire [15:0] post_high_time;
	
	//for new on chip CDS circuit on LCMS2012 (older cds function does not use this cds_done wire)
	wire cds_done; 
	
	//for dac state machine
	reg [0:1] dac_state;
	localparam s_1	= 2'b00;
	localparam s_2 = 2'b01;

	//for adc state machine
	reg [0:3] adc_state;
	localparam s_sync_v           = 3'b000; 
	localparam s_sync_i_s			= 3'b001;
	localparam s_cds 					= 3'b010;
	localparam s_tx					= 3'b011;
	localparam s_tx2					= 3'b100;
	localparam s_sync_v_hw_cds		= 3'b101;

	reset_sync rst_rstgen (	//use this for reset sync of the reset generators
		.clk    (reset_gen_clk),
		.arst   (reset),					//asynchronous input reset
		.rst    (reset_gen_rst) );		//reset signal synced to the reset_gen_clk

	reset_generator int_reset_generator (
		.clk(reset_gen_clk), 
		.reset(reset_gen_rst), 
		.low_time(int_low_time), 
		.high_time(int_high_time), 
		.RESET_OUT(INT_RESET)
	);

	reset_generator post_reset_generator (
		.clk(reset_gen_clk), 
		.reset(reset_gen_rst), 
		.low_time(post_low_time), 
		.high_time(post_high_time), 
		.RESET_OUT(POST_RESET)
	);
	
	fs_clk_generator dac_fs_clk_gen (
		.clk(dac_sm_clk), 
		.reset(dac_sm_rst), 
		.start(dac_sm_start_meas), 
		.trigger(dac_sm_int_reset), 
		.fs_cnt_max(fs_cnt_max_dac), 
		.fs_clk(dac_fs_clk)
    );
	 
	 fs_clk_generator adc_fs_clk_gen (
		.clk(adc_sm_clk), 
		.reset(adc_sm_rst), 
		.start(adc_sm_start_meas), 
		.trigger(adc_sm_int_reset), 
		.fs_cnt_max(fs_cnt_max_adc), 
		.fs_clk(adc_fs_clk)
    );


	reset_sync rst_dac_sm_clk (	//use this for the reset sync of the dacs
		.clk    (dac_sm_clk),
		.arst   (reset),				//asynchronous input reset
		.rst    (dac_sm_rst) );		//reset signal synced to the dac_sm_clk
		 
	signal_sync int_reset_dac_sync ( // for crossing clock domains
		 .o_clk(dac_sm_clk), 
		 .rst(dac_sm_rst), 
		 .i_signal(INT_RESET), 		//input signal
		 .o_signal(dac_sm_int_reset) ); //integrator reset synced to the dac_sm_clk
		 
	signal_sync dac_sm_start_sync ( // for crossing clock domains
		 .o_clk(dac_sm_clk), 
		 .rst(dac_sm_rst), 
		 .i_signal(start_meas),   //input signal
		 .o_signal(dac_sm_start_meas) );		 //start meas signal synced to the dac_sm_clk
		 
	dac_start_generator dac_start_gen (
		.clk(dac_sm_clk), 
		.reset(dac_sm_rst), 
		.start(dac_sm_start_meas), 
		.trigger(dac_sm_int_reset), 
		.dac_start(dac_start_sync)	//dac_start_sync goes high after the integrator reset if start_meas is true and stays high until start_meas_falls
    );
	
	cds_strobe_generator cds_manual_sample_generator (  //for old style cds where the adc needs to take two samples and substract (LCMS2009 style)
		.clk(adc_sm_clk), 
		.reset(adc_sm_rst), 
		.trigger(adc_sm_int_reset), 
		.cds_delay1(cds_time1_delay_i), 
		.cds_delay2(cds_time2_delay_i), 
		.cds_strobe(adc_cnv_start_cds),
		.cds_first(cds_first)
    );
	 	 
	 //insert new CDS CLK generator here
	 cds_clk_generator cds_chip_clk_generator ( //for new style of CDS on chip, a clock controls the charge transfer and only 1 adc sample needed at the end
    .clk(adc_sm_clk), 
    .reset(adc_sm_rst), 
    .trigger(adc_sm_int_reset), 
    .cds_delay1(cds_time1_delay_i), 
    .cds_delay2(cds_time2_delay_i), 
    .cds_width(cds_width_i), 
    .cds_clk1(CDS_CLK1), 
    .cds_clk2(CDS_CLK2), 
    .cds_done(adc_cnv_start_hw_cds)
    );
	 
	reset_sync	rst_adc_sm_clk (	//use this for reset sync of the adc
		.clk    (adc_sm_clk),
		.arst   (reset),				//async reset
		.rst    (adc_sm_rst) );		//reset synced to the adc_sm_clk
			 
	signal_sync adc_start_sync ( //for crossing clock domains
		 .o_clk(adc_sm_clk), 
		 .rst(adc_sm_rst), 
		 .i_signal(start_meas), 	//input signal
		 .o_signal(adc_sm_start_meas) );  //start_meas synced to the adc_sm_clk

	signal_sync int_reset_adc_sync ( // for crossing clock domains
		 .o_clk(adc_sm_clk), 
		 .rst(adc_sm_rst), 
		 .i_signal(INT_RESET), 		//input signal
		 .o_signal(adc_sm_int_reset) ); //integrator reset synced to the dac_sm_clk
		 
		 
	ADC_AD7685_Interface_verilog ADC ( //new adc verilog controller module
    .CLK(adc_sm_clk), 
    .rst(adc_sm_rst), 
    .CNV_START(adc_cnv_start), //delayed start pulse or cds start pulse
    .SDO(ADC_SDO), 
    .BUSY(), 
    .CNV(ADC_CNV), 
    .SCK(ADC_SCK), 
    .SDI(ADC_SDI), 
    .RESULT(adc_result), 
    .VALID(adc_valid)
    );
	 
// for old vhdl interface
//	ADC_AD7685_Interface ADC (
//		.CLK(adc_sm_clk),
//		//.CNV_START(1'b1),  
//		.CNV_START(adc_cnv_start),  //delayed start pulse or cds start pulse
//		.BUSY(), 
//		.CNV(ADC_CNV), 
//		.SCK(ADC_SCK), 
//		.SDI(ADC_SDI), 
//		.SDO(ADC_SDO), 
//		.RESULT(adc_result),
//		.VALID(adc_valid)
//    );
	 
	reset_sync rst_lcms2012config ( //use this for reset sync of the lcms2012 config
		.clk    (config_clk),
		.arst   (reset),			//asynchronous reset
		.rst    (config_rst) 	//reset synced to the config_clk
	);
	 
	LCMS2012_configuration LCMS2012_config (
		//.clk						(config_clk),
		.dac_sm_clk				(dac_sm_clk),
		//.dac_sm_rst				(dac_sm_rst),
		//.reset					(config_rst),
		
		// DAC Pins
		.DAC_SCLK				(DAC_SCLK),
		.DAC1_SYNC				(DAC1_SYNC),
		.DAC1_DIN				(DAC1_DIN),
		.DAC2_SYNC				(DAC2_SYNC),
		.DAC2_DIN				(DAC2_DIN),
		
		// LCMS Interface Digital Pins
		.ADDR0					(ADDR0),
		.ADDR1					(ADDR1),
		.ADDR2					(ADDR2),
		.ADDR3					(ADDR3),
		.LPF_BYPASS				(LPF_BYPASS),
		.POST_BYPASS			(POST_BYPASS),
		.CDS_BYPASS				(CDS_BYPASS),
		.INT_CAPSELECT1		(INT_CAPSELECT1),
		.INT_CAPSELECT2		(INT_CAPSELECT2),
		.RES_SELECT				(RES_SELECT),
		.INFILTER_SELN			(INFILTER_SELN),
		.POST_CAPSELECT		(POST_CAPSELECT),
		
		// LCMS bias signals
		.int_gbt_i				(int_gbt_i),
		.int_vbn_i				(int_vbn_i),
		.int_vbp_i				(int_vbp_i),
		.post_gbt_i				(post_gbt_i),
		.post_vbn_i				(post_vbn_i),
		.post_vbp_i				(post_vbp_i),
		.obuff_gbt_i			(obuff_gbt_i),
		.obuff_vbn_i			(obuff_vbn_i),
		.obuff_vbp_i			(obuff_vbp_i),
		
		// LCMS configuration signals		
		.addr0_i					(addr0_i),
		.addr1_i					(addr1_i),
		.addr2_i					(addr2_i),
		.addr3_i					(addr3_i),
		.int_capselect1_i		(int_capselect1_i),
		.int_capselect2_i		(int_capselect2_i),
		.res_select_i			(res_select_i),
		.post_capselect_i		(post_capselect_i),
		.post_bypass_i			(post_bypass_i),
		.lpf_bypass_i			(lpf_bypass_i),
		.cds_bypass_i			(cds_bypass_i),
		.infilter_seln_i		(infilter_seln_i),
		
		// signals for current measurement
		.vref_i					(vref_i),
		.VCMD						(VCMD) );

	 pulse_gen dac_pulse_gen ( //creates a pulse on dac_fs_pulse when dac_fs_clk toggles
		 .clk(dac_sm_clk), 
		 .rst(dac_sm_rst), 
		 .toggle(dac_fs_clk), 
		 .pulse(dac_fs_pulse) );  //update dac on this pulse
		 
	 pulse_gen adc_pulse_gen ( //creates a pulse on adc_fs_pulse when dac_fs_clk toggles
		 .clk(adc_sm_clk), 
		 .rst(adc_sm_rst), 
		 .toggle(adc_fs_clk), 
		 .pulse(adc_fs_pulse) ); //update adc on a delayed version of this pulse

//	reset_sync rst_a2s (		//use this for initial reset of the fifos (the fifos are part of opal kelly pipe)
//		.clk    (s_clk),
//		.arst   (reset),
//		.rst    (s_rst) );

	reset_sync	rst_a2ti ( //reset ti
		.clk    (ti_clk),
		.arst   (reset),
		.rst    (ti_rst) );
	
	
	opalkelly_pipe #(
		.TX_ADDR_WIDTH  (MEM_ADDR_WIDTH),
		.RX_ADDR_WIDTH  (0))	//no need for rx buffer in tx pipe, and we are using two opalkelly pipes because tx and rx need seperate clocks!!!!
	tx_pipe (
		// Opal Kelly Side
		.ti_clk             (ti_clk),
		.ti_rst             (ti_rst),

		.ti_out_available   (ti_out_available),
		.ti_out_data_en     (ti_out_data_en),
		.ti_out_data        (ti_out_data),

		// User Side
		.sys_clk            (adc_sm_clk),   
		.sys_rst            (adc_sm_rst),   

	  .sys_tx_ready		  (adc_tx_ready),  
	  .sys_tx_valid        (adc_tx_valid), 
	  .sys_tx              (adc_tx) );  

	opalkelly_pipe #(
		.TX_ADDR_WIDTH  (0),  //no need for tx buffer in rx pipe, and we are using two opalkelly pipes because tx and rx need seperate clocks!!!!
		.RX_ADDR_WIDTH  (MEM_ADDR_WIDTH))
	rx_pipe (
		// Opal Kelly Side
		.ti_clk             (ti_clk),
		.ti_rst             (ti_rst),

		.ti_in_available    (ti_in_available),
		.ti_in_data_en      (ti_in_data_en),
		.ti_in_data         (ti_in_data),

		// User Side
		.sys_clk            (dac_sm_clk),
		.sys_rst            (dac_sm_rst),

	   .sys_rx_ready       (dac_rx_ready),
	   .sys_rx_valid       (dac_rx_valid),
	   .sys_rx             (dac_rx) );

	signal_sync measurement_in_progress_dac_adc_sync ( // for crossing clock domains
		 .o_clk(adc_sm_clk), 
		 .rst(adc_sm_rst), 
		 .i_signal(measurement_in_progress_dac), 		//input signal
		 .o_signal(measurement_in_progress_dac_adc_sm) ); //integrator reset synced to the dac_sm_clk
		 
	signal_sync measurement_in_progress_adc_dac_sync ( // for crossing clock domains
		 .o_clk(dac_sm_clk), 
		 .rst(dac_sm_rst), 
		 .i_signal(measurement_in_progress_adc), 		//input signal
		 .o_signal(measurement_in_progress_adc_dac_sm) ); //integrator reset synced to the dac_sm_clk		 
		 

	/************************************************************************************
	* Implementation
	************************************************************************************/

	assign fs_cnt_max_dac = (v_sampling_period_i * 8'd10) - 24'd1; //sampling period is in us and dac_clk is in 10 MHz
	assign fs_cnt_max_adc = (v_sampling_period_i * 8'd20) - 24'd1; //sampling period is in us and adc_clk is in 20 MHz
	
	assign dac_start = dac_start_sync && dac_fs_pulse;
	
	assign int_high_time[15:0]  = int_reset_duration_i[15:0];
	assign int_low_time[15:0]   = reset_period_i[15:0] - int_reset_duration_i[15:0];
	assign post_high_time[15:0] = post_reset_duration_i[15:0];	
	assign post_low_time[15:0]  = reset_period_i[15:0] - post_reset_duration_i[15:0];

// assign a_led = {1'b0, reset_gen_clk, config_clk, dac_sm_clk, adc_sm_clk, fs_clk, mode_i, 1'b1};  //setting a 1 turns the LED off
//	assign a_led = {1'b0, reset, reset_gen_rst, adc_sm_rst, dac_sm_rst, 1', 1'b1, 1'b1};
//	assign a_led = adc_result[15:8];
//	assign a_led[7:0] = v_sampling_period_i[15:8];
//	assign a_led = {1'b1, adc_tx_ready, adc_tx_valid, dac_rx_ready, dac_rx_valid, start, 2'b0};
//             LED D9,   D8,   D7,    D6,          D5,          D4,          D3,          D2,  
	assign a_led = {1'b1, start_meas,cds_first,dac_rx_valid,dac_rx_ready,adc_tx_valid,adc_tx_ready,mode_i};  //1 turns the led off, so D9 should be off, D2 ON
	
	assign adc_cnv_start_v = adc_pulse_delayer[ADC_DELAY_NUM-1];
	
	assign adc_cnv_start_hw_cds_delay = adc_pulse_delayer2[ADC_DELAY_NUM2-1];
	
	//multiplexer for adc convert signal based on mode, 0 is for sync voltage mode, 1 is for sync current (cds) mode
	always @(posedge adc_sm_clk) begin
		if ((mode_i == 1'b0) && (mode2_i == 1'b0))
			adc_cnv_start <= adc_cnv_start_v && adc_sm_start_meas;  //only do conversions if start is true
		else if ((mode_i == 1'b1) && (mode2_i == 1'b0))
			adc_cnv_start <= adc_cnv_start_cds && adc_sm_start_meas; //only do conversions if start is true
			//nneed another mode to do the new form of cds using on chip cds and cds_done signal
		else if ((mode_i == 1'b0) && (mode2_i == 1'b1))
			adc_cnv_start <= adc_cnv_start_hw_cds_delay && adc_sm_start_meas;
		else //if mode_i ==1 and mode2_i == 1
			adc_cnv_start <= adc_cnv_start_v && adc_sm_start_meas;  //default to v mode
	end
	
	//create slow sampling clock as user requests
	//always @(posedge s_clk) begin  //based off the 100 MHz clock from PLL_CLK_1
//		if (reset) begin
//			fs_clk <= 0;
//			fs_cnt <= 0;
//		end
//		else begin
//			if (s_reset_int) //if the integrator just reset, start sampling
	//		fs_cnt <= fs_cnt + 1;
//			if (fs_cnt == fs_cnt_max) begin
//				fs_clk <= !fs_clk; //toggle the fs_clk 
//				fs_cnt <= 0;
//			end
//		end
//	end
	

	//create the delayed adc start pulse
	always @(posedge adc_sm_clk) begin  //based off the 20 MHz adc clock from PLL_CLK_2
		if (adc_sm_rst) begin
			adc_pulse_delayer <= 'b0;
		end
		else begin
			adc_pulse_delayer <= {adc_pulse_delayer,adc_fs_pulse};  //adc_cnv_start_v is assigned to adc_pulse delayer, which delays adc_start by the size of the delayer, 160 for 8 us
		end
	end
	
	//create a delayed adc start pulse for the hw cds mode
	always @(posedge adc_sm_clk) begin  //based off the 20 MHz adc clock from PLL_CLK_2
		if (adc_sm_rst) begin
			adc_pulse_delayer2 <= 'b0;
		end
		else begin
			adc_pulse_delayer2 <= {adc_pulse_delayer2,adc_cnv_start_hw_cds};  //adc_cnv_start_v is assigned to adc_pulse delayer, which delays adc_start by the size of the delayer, 160 for 8 us
		end
	end	
	
	
	//for pipes, dac does the same thing whether in sync v mode or sync i mode
	always @(posedge dac_sm_clk) begin
		if (dac_sm_rst) begin
			dac_rx_ready <= 1'b0;
			measurement_in_progress_dac <= 1'b0;
			dac_state <= s_1;
			//dont forget to set dac initial value during reset/coming out of reset
			//VCMD[15:0] <= 16'h7FFF; //better to  have a wire here for vcmdoffset then hardcode 1.65V
		end
		else begin
			case(dac_state)
			s_1:	begin
						dac_rx_ready <= 1'b0; //dont ask for data until start
						if (measurement_in_progress_adc_dac_sm == 1'b0) begin // if the adc isn't waiting to finish collecting data
							if (dac_sm_start_meas) begin //if user said start changing dac values
								dac_state <= s_2;
							end
						end
					end
			
			s_2 : begin
						if (dac_sm_start_meas) begin   //the software should not lower dac_sm_start_meas until after it is done sending the last bit of profile
							dac_rx_ready <= dac_start;  //pops data off on dac_start pulse , if not empty
							measurement_in_progress_dac <= 1'b1;
							if (dac_rx_valid) begin  //if the pipe in has valid data
								VCMD[15:0] <= dac_rx[15:0]; 
							end
							if (ti_in_available == ((2**MEM_ADDR_WIDTH[31:0])-1)) begin  //(2^MEM_ADDR_WIDTH)-1, 1023 for 10 bits)
								measurement_in_progress_dac <= 1'b0;
								dac_state <= s_1;
							end
						end
					end
					//else begin //user said stop, lets clear the in buffer
					//dac_rx_ready <= 1'b1;	// set ready				
			default: dac_state <= s_1;
			endcase
		end
	end
		
	//for pipes continued, the adc works differently in sync v mode and sync i mode
	always @(posedge adc_sm_clk) begin
		if (adc_sm_rst)  begin
			adc_tx_valid <= 1'b0;
			measurement_in_progress_adc <= 1'b0;
		//	cds_flag <= 1'b0;
			adc_state <= s_sync_v;
		end
		else begin
			case(adc_state)
				//sync v states 
				s_sync_v :				begin
												if ((1==mode_i) & (0==mode2_i) & (0 == adc_sm_start_meas))	//check if we need to change from v mode to digital (software) cds mode
													adc_state <= s_sync_i_s;
												else if ((0==mode_i) & (1==mode2_i) & (0 == adc_sm_start_meas)) //check if we need to change from v mode to hw cds mode
													adc_state <= s_sync_v_hw_cds;
												else begin
													adc_state <= s_sync_v;
													adc_tx_valid <=1'b0;
													if(measurement_in_progress_dac_adc_sm == 1) begin
														measurement_in_progress_adc = 1'b1;
													end
													if(adc_sm_start_meas & adc_tx_ready & adc_valid & measurement_in_progress_adc) begin  //sample only if we are doing a measurement and the adc fifo has room and the adc result is valid
														//adc_tx[15:0] <= dac_rx[15:0]; //for now only, put the profile buffer into the tx buffer instead of the adc's output!!!!
														adc_tx[15:0] <= adc_result[15:0];
														adc_tx_valid <= 1'b1;
														if(measurement_in_progress_dac_adc_sm == 0) begin //the dac is done outputting stuff, so the adc can be done now that it collected its last bit of data)
															measurement_in_progress_adc = 1'b0;
														end
													end
												end
											end
											
				s_sync_v_hw_cds:		begin
												if ((1==mode_i) & (0==mode2_i) & (0 == adc_sm_start_meas))	//check if we need to change from hw cds mode to digital (software) cds mode
													adc_state <= s_sync_i_s;
												else if ((0==mode_i) & (0==mode2_i) & (0 == adc_sm_start_meas)) //check if we need to change from hw cds mode to v mode
													adc_state <= s_sync_v;
												else begin
													adc_state <= s_sync_v_hw_cds;
													adc_tx_valid <=1'b0;
													if(measurement_in_progress_dac_adc_sm == 1) begin
														measurement_in_progress_adc = 1'b1;
													end
													if(adc_sm_start_meas & adc_tx_ready & adc_valid & measurement_in_progress_adc) begin  //sample only if we are doing a measurement and the adc fifo has room and the adc result is valid
														//adc_tx[15:0] <= vref_i[15:0] - dac_rx[15:0]; //for now only, put the profile buffer into the tx buffer instead of the adc's output!!!!
														adc_tx[15:0] <= adc_result[15:0];  //still need to deal with the issue of the minus sign
														adc_tx_valid <= 1'b1;
														if(measurement_in_progress_dac_adc_sm == 0) begin //the dac is done outputting stuff, so the adc can be done now that it collected its last bit of data)
															measurement_in_progress_adc = 1'b0;
														end
													end
												end				
											end
				//sync i states 
				s_sync_i_s :			begin
												if ((0==mode_i) & (0==mode2_i) & (0 == adc_sm_start_meas))  //check if we need to change from digital (software) cds mode to v mode
													adc_state <= s_sync_v;
												else if ((0==mode_i) & (1==mode2_i) & (0 == adc_sm_start_meas)) //check if we need to change from digital (software) cds mode to hw cds mode
													adc_state <= s_sync_v_hw_cds;
												else begin
													adc_tx_valid <= 1'b0;
													adc_state <= s_sync_i_s;		//do we really need to check for adc_tx_ready here?
													if(measurement_in_progress_dac_adc_sm == 1) begin
														measurement_in_progress_adc = 1'b1;
													end
													if(adc_sm_start_meas & adc_tx_ready & adc_valid & measurement_in_progress_adc) begin	//sample only if we are doing a measurement and the adc buffer has room and the adc result is valid
														if(cds_first == 0) begin
															adc_cds1[15:0] <= adc_result[15:0];
															//adc_cds1[15:0] <= dac_rx[15:0]; //for testing only
														end
														else begin
															adc_cds2[15:0] <= adc_result[15:0];
															//adc_cds2[15:0] <= dac_rx[15:0]; //for testing only
															adc_state <= s_cds;
														end
													end
												end
											end
				s_cds					:	begin
												adc_tx_valid <= 1'b0;
												//adc_tx_temp[16:0] <= adc_cds2[15:0] - adc_cds1[15:0];	 //temp is 1 bit wider in case of negative sign
												adc_tx_temp[15:0] <= adc_cds2[15:0] - adc_cds1[15:0];	 //temp is 1 bit wider in case of negative sign
												//adc_tx_temp[15:0] <= adc_cds1;  //only output adc_cds1 for testing purposes
												//adc_tx_temp[15:0] <= adc_cds2;  //only output adc_cds2 for testing purposes
												adc_state <= s_tx;
											end
				s_tx					:	begin
												adc_tx_valid <= 1'b0;
												adc_state <= s_tx;
												if(adc_tx_ready) begin  //if there is room in the tx fifo add the first 16 bits of the result
													adc_tx[15:0] <= adc_tx_temp[15:0];
													adc_tx_valid <= 1'b1;
											//		adc_state <= s_tx2;
											//new stuff:
													adc_state <= s_sync_i_s;
													if(measurement_in_progress_dac_adc_sm == 0) begin //the dac is done outputting stuff, so the adc can be done now that it collected its last bit of data)
															measurement_in_progress_adc = 1'b0;
													end
												end
											end
				s_tx2					:	begin
												adc_tx_valid <= 1'b0;
												adc_state <= s_tx2;
												if(adc_tx_ready) begin //if there is room in the tx fifo add the second 16 bits of the result
													adc_tx[15:0] <= {15'b000000000000000,adc_tx_temp[16]};
													adc_tx_valid <= 1'b1;
													adc_state <= s_sync_i_s;
													if(measurement_in_progress_dac_adc_sm == 0) begin //the dac is done outputting stuff, so the adc can be done now that it collected its last bit of data)
															measurement_in_progress_adc = 1'b0;
													end
												end
											end											
				default: 				adc_state <= s_sync_i_s;
			endcase
		end		
	end
endmodule


`endif //  `ifndef _xem6010_template_project_
