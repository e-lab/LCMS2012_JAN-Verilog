`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Yale
// Engineer: 		Brian Goldstein
// 
// Create Date:    13:54:24 03/29/2012 
// Design Name: 	 LCMS2012 Verilog 
// Module Name:    cds_clk_geberator 
// Project Name:   LCMS2012 Verilog
// Target Devices: XEM6010
// Tool versions:  Xilinx ISE 13.1
// Description:    creates the cds_clk1 and cds_clk2 signals as high


// for 1 clk pulse every cds_delay1 (in us) and cds_delay2 (in us) after the falling edge of the trigger
//						 the trigger is expected to be the signal that resets the integrator/post amp.  when done resetting (trigger rising edge), counts us until
//                 cds_delay1 then sets cds_strobe high for 1 cycle, then counts until cds_delay2 then waits for the next trigger again
//                 for now the input clock is exepected to be 1MHz to have a 1us clock for this module
// Dependencies:   none
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cds_clk_generator(
    input clk,			//adc clock, 20 MHz for counting purposes
    input reset,		//reset
	 input trigger,	//the trigger to start counting on, usually the reset pulse (ie when integrator reset rising edge)
    input [0:15] cds_delay1, //in us, offset from the trigger
    input [0:15] cds_delay2, //in us, offset from the trigger
	 input [0:15] cds_width,  //in us, tells us how long to let the clk be high
	 output cds_clk1,	//this goes high after cds_delay1 for cds_width microseconds,
	 output cds_clk2, //this goes high after cds_delay2 for cds_width microseconds,
	 output cds_done			//this goes high to indicate when cds_clk2 is finished and the adc can sample the result
    );

reg [0:2] state;

//parameter s_reset = 2'b00;
parameter s_latch							= 3'b000;
parameter s_wait_for_trig_high		= 3'b001;
parameter s_wait_for_trig_low			= 3'b010;
parameter s_count_for_first_sample	= 3'b011;
parameter s_high1 						= 3'b100;
parameter s_count_for_second_sample = 3'b101;
parameter s_high2 						= 3'b110;
parameter s_done							= 3'b111;

reg[15:0] low1_time_counter;
reg[15:0] low2_time_counter;
reg[15:0] high_time_counter;
reg[15:0] low1_time_latch;
reg[15:0] low2_time_latch;
reg[15:0] high_time_latch;

reg cds_clk1_r;
reg cds_clk2_r;
reg cds_done_r;

assign cds_clk1 = cds_clk1_r;
assign cds_clk2 = cds_clk2_r;
assign cds_done = cds_done_r;

//always @ (posedge clk or posedge reset) begin

	always @ (posedge clk) begin  //negedge because we are looking for the positive edge of the trigger, integrator reset 
		if (reset) begin
				low1_time_counter <= 0;
				low2_time_counter <= 0;
				low1_time_latch <= 0;
				low2_time_latch <= 0;
				high_time_latch <= 0;
				cds_clk1_r <= 0;
				cds_clk2_r <= 0;
				cds_done_r <= 0;
				state <= s_latch;
		end
		else begin
			case(state)
				
				s_latch:	begin
								cds_done_r <= 0;
								//cds_first <= 0;
								low1_time_counter <= 0;
								low2_time_counter <= 0;
								high_time_counter <= 0;
								low1_time_latch <= cds_delay1 *20; //convert from 20MHz clock to 1us
								low2_time_latch <= cds_delay2 *20;
								high_time_latch <= cds_width * 20;
								cds_clk1_r <= 0;
								cds_clk2_r <= 0;
								state <= s_wait_for_trig_high;
							end
								
				s_wait_for_trig_high :	begin
								cds_done_r <= 0;
								//cds_first <= 0;
								if(1 == trigger) begin
									state <= s_count_for_first_sample;
								end
							end

							
				s_count_for_first_sample : begin
								cds_done_r <= 0;
								//cds_first <= 0;
								low1_time_counter <= low1_time_counter + 1'b1;
								low2_time_counter <= low2_time_counter + 1'b1;
								state <= s_count_for_first_sample;
								if (low1_time_counter >= (low1_time_latch - 2'b10)) begin  //-2 because one tick is wasted low during s_latch
									state <= s_high1;
									low1_time_counter <= 0;
								end
							end
							
				s_high1:	begin
								cds_clk1_r <= 1;
								//cds_first <= 1;
								cds_done_r <= 0;
								low2_time_counter <= low2_time_counter + 1'b1;
								high_time_counter <= high_time_counter + 1'b1;
								state <= s_high1;
								if (high_time_counter >= (high_time_latch)) begin
									state <= s_count_for_second_sample;
									high_time_counter <= 0;
								end
							end
							
				s_count_for_second_sample : begin
								cds_clk1_r <= 0;
								cds_done_r <= 0;
								//cds_first <= 0;
								low2_time_counter <= low2_time_counter + 1'b1;
								state <= s_count_for_second_sample;
								if (low2_time_counter >= (low2_time_latch - 2'b10)) begin  //-2 because one tick is wasted low during s_latch
									state <= s_high2;
									low2_time_counter <=0;
								end
							end
							
				s_high2:	begin
								//cds_first <= 0;
								cds_clk2_r <= 1;
								high_time_counter <= high_time_counter +1'b1;
								state <= s_high2;
								if (high_time_counter >= (high_time_latch)) begin
									high_time_counter <=0;
									state <= s_done;
								end
							end
							
				s_done : begin
								cds_clk2_r <= 0;
								cds_done_r <= 1;
								high_time_counter <=0;
								state <= s_latch;
							end							
							
				default: state <= s_latch;
				
			endcase
		end
	end
endmodule
