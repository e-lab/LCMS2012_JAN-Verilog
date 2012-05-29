`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Yale
// Engineer: 		Brian Goldstein
// 
// Create Date:    14:47:21 07/27/2011 
// Design Name: 	 LCMS2010 Verilog Rev A
// Module Name:    cds_strobe_geberator 
// Project Name:   LCMS2010 Verilog Rev A
// Target Devices: XEM6010
// Tool versions:  Xilinx ISE 13.1
// Description:    creates the cds_strobe signal as high for 1 clk pulse every cds_delay1 (in us) and cds_delay2 (in us) after the falling edge of the trigger
//						 the trigger is expected to be the signal that resets the integrator/post amp.  when done resetting (trigger falling edge), counts us until
//                 cds_delay1 then sets cds_strobe high for 1 cycle, then counts until cds_delay2 then waits for the next trigger again
//                 for now the input clock is exepected to be 1MHz to have a 1us clock for this module
// Dependencies:   none
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cds_strobe_generator(
    input clk,			//adc clock, 20 MHz for counting purposes
    input reset,		//reset
	 input trigger,	//the trigger to start counting on, usually the reset pulse (ie when integrator reset falling edge)
    input [0:15] cds_delay1, //in us
    input [0:15] cds_delay2, //in us
	 output cds_strobe,	//this goes high to read the adc for 1 cycle
	 output reg cds_first			//this goes high to indicate when we are reading the first measurement from the adc, otherwise low
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

reg[15:0] low1_time_counter;
reg[15:0] low2_time_counter;
reg[15:0] low1_time_latch;
reg[15:0] low2_time_latch;
reg cds_out;

assign cds_strobe = cds_out;

//always @ (posedge clk or posedge reset) begin

	always @ (negedge clk) begin  //negedge because we are looking for the falling edge of the trigger 
		if (reset) begin
				low1_time_counter <= 0;
				low2_time_counter <= 0;
				low1_time_latch <= 0;
				low2_time_latch <= 0;
				cds_first <= 0;
				cds_out <= 0;
				state <= s_latch;
		end
		else begin
			case(state)
				
				s_latch:	begin
								cds_out <= 0;
								cds_first <= 0;
								low1_time_counter <= 0;
								low2_time_counter <= 0;
								low1_time_latch <= cds_delay1 *20; //convert from 20MHz clock to 1us
								low2_time_latch <= cds_delay2 *20;
								state <= s_wait_for_trig_high;
							end
								
				s_wait_for_trig_high :	begin
								cds_out <= 0;
								cds_first <= 0;
								if(1 == trigger) begin
									state <= s_wait_for_trig_low;
								end
							end

				s_wait_for_trig_low : begin
								cds_out <= 0;
								cds_first <= 0;
								if(0 == trigger) begin
									state <= s_count_for_first_sample;
								end
							end
							
				s_count_for_first_sample : begin
								cds_out <= 0;
								cds_first <= 0;
								low1_time_counter <= low1_time_counter + 1'b1;
								low2_time_counter <= low2_time_counter + 1'b1;
								state <= s_count_for_first_sample;
								if (low1_time_counter >= (low1_time_latch - 2'b10)) begin  //-2 because one tick is wasted low during s_latch
									state <= s_high1;
									low1_time_counter <= 0;
								end
							end
							
				s_high1:	begin
								cds_out <= 1;
								cds_first <= 1;
								low2_time_counter <= low2_time_counter + 1'b1;
								state <= s_count_for_second_sample;
							end
							
				s_count_for_second_sample : begin
								cds_out <= 0;
								//cds_first <= 0;
								low2_time_counter <= low2_time_counter + 1'b1;
								state <= s_count_for_second_sample;
								if (low2_time_counter >= (low2_time_latch - 2'b10)) begin  //-2 because one tick is wasted low during s_latch
									state <= s_high2;
									low2_time_counter <=0;
								end
							end
							
				s_high2:	begin
								cds_first <= 0;
								cds_out <= 1;
								state <= s_latch;
							end
							
				default: state <= s_latch;
				
			endcase
		end
	end
endmodule
