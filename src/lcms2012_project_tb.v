`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:48:52 04/03/2012
// Design Name:   LCMS2012_project
// Module Name:   C:/LCMS2012/LCMS2012_Verilog/lcms2012_project_tb.v
// Project Name:  LCMS2012_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LCMS2012_project
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module lcms2012_project_tb;

	// Inputs
	reg s_clk;
	reg ti_clk;
	reg ti_rst_soft;
	reg ti_in_data_en;
	reg [15:0] ti_in_data;
	reg ti_out_data_en;
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
	reg mode_i;
	reg mode2_i;
	reg [15:0] vref_i;
	reg [15:0] cds_time1_delay_i;
	reg [15:0] cds_time2_delay_i;
	reg [15:0] cds_width_i;

	// Outputs
	wire [7:0] a_led;
	wire [15:0] ti_in_available;
	wire [15:0] ti_out_available;
	wire [15:0] ti_out_data;
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
	wire CDS_CLK1;
	wire CDS_CLK2;
	wire INT_CAPSELECT1;
	wire INT_CAPSELECT2;
	wire RES_SELECT;
	wire POST_CAPSELECT;
	wire POST_RESET;
	wire ADC_SDI;
	wire ADC_SCK;
	wire ADC_CNV;
	wire [15:0] adc_result;
	wire adc_cnv_start;
	wire dac_start;
	wire adc_fs_pulse;

	// Bidirs
	wire INT_RESET;
	//wire start_meas;
	
	reg start;
	wire start_wire;
	assign start_wire = start;

	// Instantiate the Unit Under Test (UUT)
	LCMS2012_project #(
		.MEM_ADDR_WIDTH (10))
	uut (
		.a_led(a_led), 
		.s_clk(s_clk), 
		.ti_clk(ti_clk), 
		.ti_rst_soft(ti_rst_soft), 
		.ti_in_available(ti_in_available), 
		.ti_in_data_en(ti_in_data_en), 
		.ti_in_data(ti_in_data), 
		.ti_out_available(ti_out_available), 
		.ti_out_data_en(ti_out_data_en), 
		.ti_out_data(ti_out_data), 
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
		.INFILTER_SELN(INFILTER_SELN), 
		.ADDR0(ADDR0), 
		.ADDR1(ADDR1), 
		.ADDR2(ADDR2), 
		.ADDR3(ADDR3), 
		.LPF_BYPASS(LPF_BYPASS), 
		.POST_BYPASS(POST_BYPASS), 
		.CDS_BYPASS(CDS_BYPASS), 
		.CDS_CLK1(CDS_CLK1), 
		.CDS_CLK2(CDS_CLK2), 
		.INT_CAPSELECT1(INT_CAPSELECT1), 
		.INT_CAPSELECT2(INT_CAPSELECT2), 
		.RES_SELECT(RES_SELECT), 
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
		.mode_i(mode_i), 
		.mode2_i(mode2_i),
		.vref_i(vref_i), 
		.cds_time1_delay_i(cds_time1_delay_i), 
		.cds_time2_delay_i(cds_time2_delay_i), 
		.cds_width_i(cds_width_i), 
		.adc_result(adc_result), 
		.start_meas(start_wire), 
		.adc_cnv_start(adc_cnv_start), 
		.dac_start(dac_start), 
		.adc_fs_pulse(adc_fs_pulse)
	);


	//test variables
	integer     counter;
	integer		test_counter;
	
	//clocks
	always begin
		#5		s_clk =  ~s_clk; // 100 MHz s_clk toggle every 0.010 us 
	end
	
	always begin
		#5  ti_clk   = !ti_clk;	//for opal kelly pipes/fifos/wires/etc
	end
	
	always begin
		#500  config_clk = ~config_clk; //1 MHz - 1 us = 1000ns period /2 = 500ns toggle time
	end
	
	always begin
		#50   dac_sm_clk = ~dac_sm_clk;   //10 MHz - 10 us = 10,000 ns / 2 = 5000 ns
	end
	
	always begin
		#25 adc_sm_clk = ~adc_sm_clk;       //20 MHz = 50 ns /2 = 25 ns
	end
	
	always begin
		#500 reset_gen_clk = ~reset_gen_clk;  //1 MHz - 1 us = 1000ns period /2 = 500ns toggle time		
	end
	
	//always begin
		//#25	ADC_SDO = counter[0];
		//#25 ADC_SDO = test_counter;
	//end
	
	//always begin
//		#5	test_counter = test_counter + 1;
	//end
	
	always @ (negedge ADC_CNV) begin
		if(INT_RESET) begin
			#75 ADC_SDO = 0;
			#50 ADC_SDO = 1;
		end
		else begin
			#75 ADC_SDO=0; //make this a 1 to integrate positive, else integratoe negative (smaller value)
			#100 ADC_SDO = 0;
			#50 ADC_SDO = 1;
		end
	end
	
	
	initial begin
		// Initialize Inputs
		s_clk = 0;  //10 ns
		ti_clk = 0;	// 10ns 
		ti_rst_soft = 0;
		ti_in_data_en = 0;
		ti_in_data = 0;
		ti_out_data_en = 0;
		config_clk = 0;	//1 us
		dac_sm_clk = 0;   //10 us
		adc_sm_clk = 0;   //50 ns
		reset_gen_clk = 0; // 1 us
		reset = 1;
		//ADC_SDO = 0; //based on counter 
		int_gbt_i = 0;
		int_vbn_i = 0;
		int_vbp_i = 0;
		post_gbt_i = 0;
		post_vbn_i = 0;
		post_vbp_i = 0;
		obuff_gbt_i = 0;
		obuff_vbn_i = 0;
		obuff_vbp_i = 0;
		reset_period_i = 0; // 100 us
		int_reset_duration_i = 0; // 10 us
		post_reset_duration_i = 0; //10 us
		v_sampling_period_i = 0;  //100 us
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
		mode_i = 0;   // 0, for now
		mode2_i = 0;  // 0, for now
		vref_i = 32768; //1.65 V
		cds_time1_delay_i = 0;  //3 us
		cds_time2_delay_i = 0;  //90 us
		cds_width_i = 0;        // 2 us
		
		test_counter = 0;

		counter = 34756; //1.75V, assume a 100mV increase over vref 1.65V
		start = 0;
		// Wait 1000 ns for global reset to finish
		#1000;
		reset = 1;
		#1000;
		reset = 0;
		
		// Add stimulus here		
		
		reset_period_i = 100;  //reset is every 100 us (10 kHz)
		int_reset_duration_i = 10;
		post_reset_duration_i = 10;
		//v_sampling_period_i = 10; //user says sample every 10 us = 100 kHz
		v_sampling_period_i = 100; //user says sample every 100 us = 10 kHz
		//v_sampling_period_i = 50; //user says sample every 100 us = 20 kHz
		cds_time1_delay_i = 2;
		cds_time2_delay_i = 90;
		cds_width_i = 2;
		mode_i = 0;		//mode=1, mode2=0 = (SW) digital cds mode,   mode=0,mode2=1 = HW cds mode
		mode2_i = 1; 
		#100000 //wait 100 us for end of first reset
		
		$display("TEST pipe data in");
	   @(negedge ti_clk);
	      repeat (10) begin
			ti_in_data_en   <= 1'b1;
			ti_in_data      <= counter;
			counter         <= counter + 1;

		 	@(negedge ti_clk);
	      end
	  ti_in_data_en   <= 1'b0;
	  ti_in_data      <= 'b0;
	  counter         <= 1;
	  repeat(20) @(negedge ti_clk);

	
//	  $display("END");
		  
		start=1;
		$display ($time, "### Start ###");
		//#10000000; //10ms
		#500000 //500 us
		start=0;
		$display ($time, "### Stop ###");
		
		//	#1000000
	  $display("TEST pipe data out");
		@(negedge ti_clk);
	  ti_out_data_en <= 1'b1;
	  repeat(16) @(negedge ti_clk);
	  ti_out_data_en <= 1'b0;
	  repeat(5) @(negedge ti_clk);

	  repeat(50) @(negedge ti_clk);

        
	

	end
      
endmodule

