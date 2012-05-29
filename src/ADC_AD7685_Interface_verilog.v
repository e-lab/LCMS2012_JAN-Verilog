`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Brian Goldstein
// 
// Create Date:    11:43:22 12/05/2011 
// Design Name: 
// Module Name:    ADC_AD7685_Interface_verilog 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Interface to 16-bit ADC, AD7685.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ADC_AD7685_Interface_verilog(
	 input CLK,
	 input rst,
	 input CNV_START,
	 input SDO,
	 output BUSY,
	 output CNV,
	 output reg SCK,
	 output SDI,
	 output [15:0] RESULT,
	 output VALID
	 );

	reg busy_w;
	reg cnv_w;
	reg [15:0] result_w;
	reg valid_w;
	reg clk_en;
	reg [15:0] counter;

	parameter [0:4]  //ERROR is 5'b00000
		IDLE 				= 5'b00001,
		CONVERT			= 5'b00010,
		END_CONVERSION = 5'b00100,
		READ_OUT 		= 5'b01000,
		VALID_F			= 5'b10000,
		WAIT				= 5'b10001;	//FSM Parameter definition for one-hot with zero-idle encoding (almost)
		
	reg [0:4] state;
	//reg [0:4] next; //FSM registers

	//always @(posedge CLK or posedge rst)
	//	if (rst) begin
	//			state <= 5'b0;  //on reset the state register will be assigned all zeros
	//			state[IDLE] <= 1'b1;  //followed by state[IDLE] <= 1'b1
	//		end
	//	else	state <= next;
		
	always @(posedge CLK) begin
		if (rst) begin
				cnv_w		= 1'b0; //start with CNV low and aquire data
				clk_en	= 1'b0; //turn the output clock off 
				busy_w   = 1'b0; //no conversion request yet, so not busy
				valid_w	= 1'b0; //output is not yet valid
				result_w = 16'd0; //zero the result
				counter 	= 16'd0; //zero the counter
				state 	= IDLE;
		end
		else begin		
			case (state)
			IDLE: begin
					cnv_w		= 1'b0; //start with CNV low and aquire data
					clk_en	= 1'b0; //turn the output clock off while aquiring data
					busy_w   = 1'b0; //no conversion request yet, so not busy
					valid_w	= 1'b0; //output is not yet valid
					result_w = 16'd0;
					counter =  16'd0;
					if (CNV_START == 1'b1)	begin
						counter <= 16'd64; //cnv should be high for 3.2us, assuming clock freq is 25ns, 3.2us/25ns=128 clocks
						state <= CONVERT;
					end
					else	state = IDLE;
				end
			
			CONVERT: begin
					cnv_w = 1'b1; //set cnv high to sample the analog input until index = 0
					busy_w = 1'b1; //adc is busy doing a conversion
					if (counter[15:0] == 16'd0) begin  
						counter <= 16'd31;	// get ready to read 16 bits but it will take 32 clock cycles
						cnv_w = 1'b0; 		//set cnv low
						state <= READ_OUT;
					end
					else begin state = CONVERT;
						counter[15:0] = counter[15:0] - 1'b1; //keep track of how many ticks we've been in this state
					end
				end
				
			//END_CONVERSION: begin
			//		cnv_w = 1'b0; 		//set cnv low
			//		state = READ_OUT;
			//	end
				
			READ_OUT: begin
					if (counter == 16'd31) begin
						result_w[15] = SDO;  //use the SDO from the ADC by storing it into RESULT
						counter = counter - 1'b1; //keep track of how many ticks we've been in this state
						clk_en = 1'b1;
						state = READ_OUT;
					end
				//	else if (counter == 16'd29) begin
				//		
				//		counter = counter - 1'b1; 
				//	end
					else if ( (counter == 16'd30) || (counter == 16'd28) || (counter == 16'd26) || (counter == 16'd24) || (counter == 16'd22) || (counter == 16'd20) || (counter == 16'd18) || (counter == 16'd16) || (counter == 16'd14) || (counter == 16'd12) || (counter == 16'd10) || (counter == 16'd8) || (counter == 16'd6) || (counter == 16'd4) || (counter == 16'd2)) begin
						clk_en = 1'b1;
						result_w[counter >> 1] = SDO;
						counter = counter - 1'b1; 
						state = READ_OUT;
					end
					else if (counter == 16'd0) begin
						result_w[counter] = SDO;  //use the SDO from the ADC by storing it into RESULT
						counter <= 16'd35; //clocks to wait for tacq to be 1.8us  (72 ticks - 16)  //orig before tampering 3/15/2012
	//					counter <= 16'd2; //2 is not enuf!
						//valid_w	= 1'b1;	//valid is high for 1 clock cycle after last bit read out
						state = VALID_F;
					end
					else
						counter = counter - 1'b1; 
				end
				
			VALID_F: begin
					valid_w = 1'b1;
					//clk_en	= 1'b0;	//turn the clock off to the chip
					state = WAIT;
				end
				
			WAIT: begin
					busy_w 	= 1'b0; //no longer busy
					clk_en	= 1'b0;	//turn the clock off to the chip
					valid_w = 1'b0; // turn off valid flag;
					if (counter == 16'd0) begin
						state = IDLE;
					end
					else begin 
						state = WAIT;
						counter = counter - 1'b1; //keep track of how many ticks we've been in this state
					end
				end
				
			default: state <= IDLE;
			//	~|state: begin //ERROR
			//				busy_w   =  1'b0;
			//				cnv_w    =  1'b0;
			//				clk_en   =  1'b0;
			//				result_w = 16'd0;
			//				valid_w  =  1'b0;
			//				if (!rst)	next[IDLE] = 1'b1;
			//			end
			endcase
		end
	end

	//continous output assignments
	 assign BUSY = busy_w;
	 assign CNV = cnv_w;
	// assign SCK = CLK & clk_en;
	 assign SDI = 1'b1; //always high, use CSNOT mode
	 assign RESULT[15:0] = result_w[15:0];
	 assign VALID = valid_w;
	 
	 always @(posedge CLK) begin
		SCK = (!SCK) & clk_en;
	end
	 
endmodule
