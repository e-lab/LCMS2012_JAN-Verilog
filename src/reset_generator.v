`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Yale
// Engineer: 		Brian Goldstein
// 
// Create Date:    14:47:21 07/27/2011 
// Design Name: 	 LCMS2010 Verilog Rev A
// Module Name:    reset_generator 
// Project Name:   LCMS2010 Verilog Rev A
// Target Devices: XEM6010
// Tool versions:  Xilinx ISE 13.1
// Description:    creates the RESET signal based on the values of low_time and high_time
//                 for now the input clock is exepected to be 100KHz and is divided by 10 to have a 1us clock for this module
//                 low_time and high_time are then the number of us to hold the RESET high and then low
// Dependencies:   none
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module reset_generator(
    input clk,
    input reset,
    input [0:15] low_time,
    input [0:15] high_time,
	 output RESET_OUT
    );

reg [0:1] state;

//parameter s_reset = 2'b00;
parameter s_latch = 2'b00;
parameter s_high = 2'b01;
parameter s_low = 2'b10;
//parameter s_never_reset = 2'b11;

reg[15:0] low_time_counter;
reg[15:0] high_time_counter;
reg[15:0] low_time_latch;
reg[15:0] high_time_latch;
reg rout;

assign RESET_OUT = rout;

//always @ (posedge clk or posedge reset) begin

	always @ (posedge clk) begin
		if (reset) begin
				high_time_counter <= 0;
				low_time_counter <= 0;
				low_time_latch <= 0;
				high_time_latch <= 0;
				state <= s_latch;
				rout <= 1;
		end
		else begin
			case(state)
			//the clock runs at 100 MHz
			//suppose we want to reset for 2 us at a rate of 10 kHz (100us)
			//first conver the 100 MHz to us by dividing by 100 =>1MHz = 1 us => 100Mhz = 100us
			//then the 2us reset high means wait for 2 ticks
			//then the 100-2us reset low means wait for 98 ticks
				
				s_latch:	begin
								low_time_latch <= low_time+1'b1;
								high_time_latch <= high_time;
								state <= s_high;
								rout <= 1;  //rout high during latch, is this ok???
								high_time_counter <= 16'b0000000000000001;
								if (high_time[0:15] == 16'b1111111111111111) begin //special case to never reset
									rout <=0;
									state <= s_latch; // stay here until the high_time input changes 
								end
							end
								
				s_high:	begin
								high_time_counter <= high_time_counter + 1'b1;
								low_time_counter <= 'b0;
								rout <= 1;
								state <= s_high;
								if (high_time[0:15] == 16'b0000000000000000) begin //special case, always keep reset high
									high_time_counter <= 0;
									state <= s_high;
								end
								else if (high_time_counter >= (high_time_latch - 1'b1)) begin
									high_time_counter <= 0;
									state <= s_low;
								end
							end
								
				s_low :	begin
								low_time_counter <= low_time_counter + 1'b1;
								high_time_counter <= 'b0;
								rout <= 0;
								state <= s_low;
								if (low_time_counter >= (low_time_latch - 2'b10)) begin  //-2 because one tick is wasted low during s_latch
									low_time_counter <= 0;
									state <= s_latch;
								end
							end
							
				default: state <= s_latch;
			endcase
		end
	end
endmodule
