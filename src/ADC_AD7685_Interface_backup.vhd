----------------------------------------------------------------------------------
-- Interface to ADC AD7685.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADC_AD7685_Interface is
	Port ( 
			CLK			: in	std_logic;  --expecting a clock of 25ns period for this module to work  //40MHz
			CNV_START	: in	std_logic;  --set high or low externally when you want to start the conversion (convert latest sample)
			BUSY			: out	std_logic;  --is set high when a conversion and data clock out is in progress, low otherwise
			CNV 	 		: out	std_logic;  --on rising edge, samples analog input, hold for length of conversion, then lower for length of acquisition
			SCK 	 		: out	std_logic;  --serial clock, period should be 25ns
			SDI 	 		: out	std_logic;  --serial data set low to use CHAIN mode, set high to use CSNOT mode
			SDO	 		: in	std_logic;  --serial data out from the AD7685 is read clock by clock here and stored in result
			RESULT	 	: out std_logic_vector(15 downto 0) --16 bit serial data out, shifts out the conversion result, synchronized to SCK
		);
end ADC_AD7685_Interface;

architecture Behavioral of ADC_AD7685_Interface is
	constant	PRECISION	: integer	:= 128;
	subtype index_integer is integer range 0 to PRECISION;
	signal index				: index_integer := 71;  --used in serialize state machine to send this number # of bits of data
	signal CLK_EN	:	std_logic;
	
   type state_type is (
		s_init,
		s_convert,
		s_end_conversion,
		s_read_out
	);
	signal state : state_type := s_init;
	
begin
	
	SDI <= '1'; --always high, use CSNOT mode
	SCK <= CLK and CLK_EN;
	
	ADC_CONTROL : process (CLK) --control the ADC, sensitive to CLK
	begin
		if falling_edge(CLK) then
			case state is
				
				--warning, this init function does not make sure that the ADC aquires data for the full 1.8us
				when s_init =>
					CNV		<= '0';--start with CNV low and aquire data
					CLK_EN	<= '0';
					if (CNV_START = '1') then  --when we get the signal to start the convert process
						index <= 127;  --cnv should be high for 3.2us, assuming clock freq is 25ns, 3.2us/25ns=128 clocks
						state <= s_convert;
						CNV <= '1';
						BUSY <= '1';
					end if;	
				
				when s_convert =>
					index 	<= index-1;
					CLK_EN	<= '0';
					CNV		<= '1';  --set cnv high to sample the analog input until index = 0
					if (index=0) then
						CNV	<= '0';	-- set cnv at the end of the conversion, data will be ready on SDO ten=22ns later (almost 1 clock tick so this state accomplishes the wait) 				
						state <= s_end_conversion;
					end if;
				
				when s_end_conversion =>
					index <= 15;	-- get ready to read 16 bits
					state	<= s_read_out;
					CLK_EN	<= '1';
					
				when s_read_out =>
					index 	<= index-1;
					CLK_EN	<= '1';
					RESULT(index)	<= SDO;
					if(index=0) then
						BUSY 	<= '0';
						state <= s_init;
						CLK_EN	<= '0';
					end if;
					
			end case;
		end if;
	end process ADC_CONTROL;

end Behavioral;
