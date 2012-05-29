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
// Description:    creates the dac_start signal after start is pressed and the trigger is found, dac_start goes high.
//                 Expected use: when the user clicks start button, wait for next reset to trigger and then set dac_start high
// Dependencies:   none
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fs_clk_generator(
    input clk,			   //s clock expected
    input reset,		   //s reset expected
	 input start,			//the start signal synced to s clock expected
	 input trigger,	   //the trigger synced to s clock to look for before setting dac_start high, usually the reset pulse (ie when integrator reset starts)
	 input [23:0] fs_cnt_max,  //max value of the sampling clock counter before resetting based on clk
	 output fs_clk		//this goes high when we are ready to write to the dac, aka just after the reset
    );

reg [0:2] state;
	reg fs_clk_r;   			//user selected sampling frequency for adc and dac
	reg[23:0] fs_cnt;		   // counter to create the fs_clk
//	wire [23:0] fs_cnt_max;	//max value of the counter before toggling fs_clk

//parameter s_reset = 2'b00;
parameter s_wait_for_start			= 2'b00;
parameter s_wait_for_trig_high	= 2'b01;
parameter s_wait_for_stop 			= 2'b10;

assign fs_clk = fs_clk_r;

//always @ (posedge clk or posedge reset) begin

	always @ (posedge clk) begin //posedge because we are looking for the rising edge of the trigger 
		if (reset) begin
				fs_clk_r <= 0;
				fs_cnt <= 0;
				state <= s_wait_for_start;
		end
		else begin
			case(state)								
				s_wait_for_start : begin
								fs_clk_r <= 0;
								fs_cnt <= 0;
								if(1 == start) begin
									state <= s_wait_for_trig_high;
								end
							end
								
				s_wait_for_trig_high :	begin
								fs_cnt <= 0;
								fs_clk_r <= 0; //turn the clock high
								if(1 == trigger) begin
									state <= s_wait_for_stop;
									fs_clk_r <= 1; //turn the clock high
								end
							end

				s_wait_for_stop : begin
								if(0 == start) begin
									state <= s_wait_for_start;
									fs_cnt <= 0;
								end
								
							//	create slow sampling clock as user requests
								fs_cnt <= fs_cnt + 1;
								if (fs_cnt == fs_cnt_max) begin
											fs_clk_r <= !fs_clk_r; //toggle the fs_clk 
											fs_cnt <= 0;
								end
							end
							
				default: state <= s_wait_for_start;
				
			endcase
		end
	end
endmodule
