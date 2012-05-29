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
module dac_start_generator(
    input clk,			   //dac clock expected
    input reset,		   //dac reset expected
	 input start,			//the start signal synced to dac clock expected
	 input trigger,	   //the trigger synced to dac clock to look for before setting dac_start high, usually the reset pulse (ie when integrator reset starts)
	 output dac_start		//this goes high when we are ready to write to the dac, aka just after the reset
    );

reg [0:2] state;

//parameter s_reset = 2'b00;
parameter s_wait_for_start			= 2'b00;
parameter s_wait_for_trig_high	= 2'b01;
parameter s_wait_for_stop 			= 2'b10;

reg dac_start_out;

assign dac_start = dac_start_out;

//always @ (posedge clk or posedge reset) begin

	always @ (posedge clk) begin //posedge because we are looking for the rising edge of the trigger 
		if (reset) begin
				dac_start_out <= 0;
				state <= s_wait_for_start;
		end
		else begin
			case(state)								
				s_wait_for_start : begin
								dac_start_out <= 0;
								if(1 == start) begin
									state <= s_wait_for_trig_high;
								end
							end
								
				s_wait_for_trig_high :	begin
								dac_start_out <= 0;
								if(1 == trigger) begin
									state <= s_wait_for_stop;
									dac_start_out <= 1;
								end
							end

				s_wait_for_stop : begin
								dac_start_out <= 1;
								if(0 == start) begin
									state <= s_wait_for_start;
								end
							end
							
				default: state <= s_wait_for_start;
				
			endcase
		end
	end
endmodule
