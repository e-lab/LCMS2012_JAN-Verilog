----------------------------------------------------------------------------------
-- Interface to DAC AD56x5R using IIC   -using AD5665R, 16bit resolution
-- The process 'serialize' requires 32 falling edges of the clock to complete a
-- write to the DAC.
----------------------------------------------------------------------------------

-- NOTE REMEMBER TO LOOK AT TURN OFF AND POWER DOWN SIGNAL CREATION!!!

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity DAC_AD5668_Interface is
	port(
		CLK		: in	std_logic;	

--		v_dac_a	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC A plus one bit for updates
--		v_dac_b	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC B plus one bit for updates
--		v_dac_c	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC C plus one bit for updates
--		v_dac_d	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC D plus one bit for updates	
--		v_dac_e	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC E plus one bit for updates 
--		v_dac_f	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC F plus one bit for updates
--		v_dac_g	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC G plus one bit for updates
--		v_dac_h	: in	std_logic_vector(16 downto 0);  --16 bit target value for DAC H plus one bit for updates
		
		v_dac_a	: in	std_logic_vector(15 downto 0);
		v_dac_b	: in	std_logic_vector(15 downto 0);
		v_dac_c	: in	std_logic_vector(15 downto 0);
		v_dac_d	: in	std_logic_vector(15 downto 0);
		v_dac_e	: in	std_logic_vector(15 downto 0);
		v_dac_f	: in	std_logic_vector(15 downto 0);
		v_dac_g	: in	std_logic_vector(15 downto 0);
		v_dac_h	: in	std_logic_vector(15 downto 0);
		
		disable_dac_a : in	std_logic;
		disable_dac_b : in	std_logic;
		disable_dac_c : in	std_logic;
		disable_dac_d : in	std_logic;
		disable_dac_e : in	std_logic;
		disable_dac_f : in	std_logic;
		disable_dac_g : in	std_logic;
		disable_dac_h : in	std_logic;		

		SCLK		: out		std_logic;
		SYNC		: out 	std_logic;
		DIN		: out		std_logic
	);
	
end DAC_AD5668_Interface;

architecture behavioral of DAC_AD5668_Interface is
	subtype index_integer is integer range 0 to 31;
	signal index 				: index_integer;  --used in serialize state machine to send this number # of bits of data

	signal command_bits		: std_logic_vector(7 downto 0); --tells the DAC what command to perform
	signal address_bits		: std_logic_vector(3 downto 0); --tells the DAC what command to perform	

--	signal v_dac_a_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel a
--	signal v_dac_b_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel b
--	signal v_dac_c_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel c
--	signal v_dac_d_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel d
--	signal v_dac_e_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel e
--	signal v_dac_f_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel f
--	signal v_dac_g_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel g
--	signal v_dac_h_previous	: std_logic_vector(16 downto 0) := b"00000000000000000"; --previous value of dac channel h
--	
	signal v_dac_a_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_b_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_c_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_d_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_e_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_f_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_g_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	signal v_dac_h_previous	: std_logic_vector(15 downto 0) := b"0000000000000000";
	
	signal disable_dac_a_previous : std_logic  := '0';
	signal disable_dac_b_previous : std_logic  := '0';
	signal disable_dac_c_previous : std_logic  := '0';
	signal disable_dac_d_previous : std_logic  := '0';
	signal disable_dac_e_previous : std_logic  := '0';
	signal disable_dac_f_previous : std_logic  := '0';
	signal disable_dac_g_previous : std_logic  := '0';
	signal disable_dac_h_previous : std_logic  := '0';

	signal power_change_mode : std_logic_vector(1 downto 0); --from data sheet table 11, --00 = normal operation, 11 = three-state power down, consult data sheet for 01 and 10
	signal power_change_channel : std_logic_vector(7 downto 0); --from data sheet table 11, bit 0=DAC A, bit 1 = DAC B, bit2 = DAC C, bit3 = DAC D, bit4 = DAC E, bit5=DAC F, bit6=DAC G, bit7=DAC H
	signal power_change_command : std_logic_vector(21 downto 0); --from data sheet table 12, X|X|X|X|0|1|0|0|X|X|X|X|X|X|X|X|X|X|X|X|X|X|PD1|PD0|H|G|F|E|D|C|B|A
	
--	signal v_dac				: std_logic_vector(16 downto 0); --v_dac will be decided to be either v_dac_a's, b's, c's, d's,
--																				--	e's, f's, g's, or h's value based on which channel is being updated
	signal v_dac				: std_logic_vector(15 downto 0); --v_dac will be decided to be either v_dac_a's, b's, c's, d's,
																				--	e's, f's, g's, or h's value based on which channel is being updated

	signal SCLK_ENABLE 		: std_logic := '0';  --used to enable ticking of the SCL clock during communication or disable ticking when idle

   type state_type is (
		s_ready,
		s_init_data_transfer1,
		s_init_data_transfer2,
		s_command_bits,
		s_address_bits,
		s_transmit_data,
		s_finish_transmitting_data,
		s_change_power_init,
		s_change_power_init2,
		s_change_power_command_bits,
		s_change_power_mode_bits,
		s_change_power_channel_bits
	);
	signal state : state_type :=s_ready;

begin

	SCLK <= CLK or (not SCLK_ENABLE); --enable ticking of SCL clock during communication, otherwise holds SCL clock high
	power_change_command <= "1000010000000000000000";
	
	serialize : process (CLK)  --send data serially to the DAC
	begin
		if rising_edge(CLK) then
			case state is
				
				when s_ready =>
					DIN 		<= '0';
					SYNC 		<= '1';     --idle sync high
					SCLK_ENABLE	<= '0';  --do not enable SCL when idle
					command_bits <= b"10000011";  --write to and update dac channel n
					
					
					if ((v_dac_a /= v_dac_a_previous) and (disable_dac_a /= '1')) then
						v_dac_a_previous	<= v_dac_a; --store the previous value
						address_bits		<= b"0000"; --get the command byte ready for channel A
						v_dac					<= v_dac_a; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_b /= v_dac_b_previous) and (disable_dac_b /= '1')) then
						v_dac_b_previous	<= v_dac_b; --store the previous value
						address_bits		<= b"0001"; --get the command byte ready for channel A
						v_dac					<= v_dac_b; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_c /= v_dac_c_previous) and (disable_dac_c /= '1')) then
						v_dac_c_previous	<= v_dac_c; --store the previous value
						address_bits		<= b"0010"; --get the command byte ready for channel A
						v_dac					<= v_dac_c; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_d /= v_dac_d_previous) and (disable_dac_d /= '1')) then
						v_dac_d_previous	<= v_dac_d; --store the previous value
						address_bits		<= b"0011"; --get the command byte ready for channel A
						v_dac					<= v_dac_d; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_e /= v_dac_e_previous) and (disable_dac_e /= '1')) then
						v_dac_e_previous	<= v_dac_e; --store the previous value
						address_bits		<= b"0100"; --get the command byte ready for channel A
						v_dac					<= v_dac_e; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_f /= v_dac_f_previous) and (disable_dac_f /= '1')) then
						v_dac_f_previous	<= v_dac_f; --store the previous value
						address_bits		<= b"0101";  --get the command byte ready for channel A
						v_dac					<= v_dac_f; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_g /= v_dac_g_previous) and (disable_dac_g /= '1')) then
						v_dac_g_previous	<= v_dac_g; --store the previous value
						address_bits		<= b"0110";  --get the command byte ready for channel A
						v_dac					<= v_dac_g; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					elsif ((v_dac_h /= v_dac_h_previous) and (disable_dac_h /= '1')) then
						v_dac_h_previous	<= v_dac_h; --store the previous value
						address_bits		<= b"0111";  --get the command byte ready for channel A
						v_dac					<= v_dac_h; --get the target v ready for channel A
						state					<= s_init_data_transfer1;
					end if;
					
					
					--note this implementation assumes the selected channels will all either be powered up, or all powered down, at once.
					--it will not handle some channels requesting to be powered up while others are requesting to be powered down.
					
					power_change_channel <= (others => '0');  --no change to power mode unless we enter a branch below
					if (disable_dac_a /= disable_dac_a_previous) then  --the requested power state for this channel has changed
						disable_dac_a_previous	<= disable_dac_a;  --update previous value
						power_change_channel(0)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_a & disable_dac_a;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					if (disable_dac_b /= disable_dac_b_previous) then
						disable_dac_b_previous  <= disable_dac_b;
						power_change_channel(1)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_b & disable_dac_b;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					if (disable_dac_c /= disable_dac_c_previous) then
						disable_dac_c_previous  <= disable_dac_c;
						power_change_channel(2)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_c & disable_dac_c;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					if (disable_dac_d /= disable_dac_d_previous) then
						disable_dac_d_previous <= disable_dac_d;
						power_change_channel(3)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_d & disable_dac_d;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					if (disable_dac_e /= disable_dac_e_previous) then
						disable_dac_e_previous <= disable_dac_e;
						power_change_channel(4)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_e & disable_dac_e;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					if (disable_dac_f /= disable_dac_f_previous) then
						disable_dac_f_previous <= disable_dac_f;
						power_change_channel(5)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_f & disable_dac_f;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;								
					end if;
					if (disable_dac_g /= disable_dac_g_previous) then
						disable_dac_g_previous <= disable_dac_g;
						power_change_channel(6)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_g & disable_dac_g;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					if (disable_dac_h /= disable_dac_h_previous) then
						disable_dac_h_previous <= disable_dac_h;
						power_change_channel(7)	<= '1'; --set the channel to update
						power_change_mode			<= disable_dac_h & disable_dac_h;  --if disabling this will set power_change_mode to 11, if enabling it will be 00
						state	<= s_change_power_init;
					end if;
					
				--the write sequence begins by bringing the SYNC line low
				--data from DIN is is clocked into the 32-bit shift register on the falling edge of SCLK
				--the SCLK frequency can be as high as 50MHz
				--on the 32nd falling clock edge, the last data bit is clocked in
				--at this stage, the SYNC line can be kept low or brought high
				--note that SYNC must be high for a minimum of 15ns before the next write sequence.
				--idling sync low between write sequences reduces power consumption.
				when s_init_data_transfer1 =>
					SYNC 		<= '0';				
					index 	<= 7;
					state		<= s_init_data_transfer2;

				when s_init_data_transfer2 =>
					SCLK_ENABLE <= '1'; --set SCL Low (start the transmit clock)
					DIN 			<= command_bits(index);
					index 		<= index - 1;
					state			<= s_command_bits;

				when s_command_bits  =>
					index 	<= index -1;
					DIN		<= command_bits(index);
					if(index=0) then
						index	<=3;
						state	<= s_address_bits;
					end if;
				
				when s_address_bits =>
					index 	<= index -1;
					DIN		<= address_bits(index);
					if(index=0) then
						index <= 15;
						state	<= s_transmit_data;
					end if;
				
				when s_transmit_data =>
					index	<= index-1;
					DIN	<= v_dac(index);
					if(index=0) then
						state	<= s_finish_transmitting_data;
						index	<= 3;
					end if;
					
				when s_finish_transmitting_data =>
					index		<= index-1;
					DIN		<= '0';
					if (index=0) then
						state <= s_ready;
					end if;
					
				--states for changing power modes
				when s_change_power_init =>
					index		<= 21;
					SYNC 		<= '0';
					state		<= s_change_power_init2;
				
				when s_change_power_init2 =>
					
					SCLK_ENABLE <= '1'; --set SCL Low (start the transmit clock)
					DIN		<= power_change_command(index);
					index		<= index -1;
					state		<= s_change_power_command_bits;
				
				when s_change_power_command_bits =>
					index <= index - 1;
					DIN <= power_change_command(index);
					if (index=0) then
						index	<= 1;
						state <= s_change_power_mode_bits;
					end if;
				
				when s_change_power_mode_bits =>
					index <= index - 1;
					DIN <= power_change_mode(index);
					if (index=0) then
						index <= 7;
						state <= s_change_power_channel_bits;
					end if;
					
				when s_change_power_channel_bits =>
					index <= index - 1;
					DIN <= power_change_channel(index);
					if (index=0) then
						--DIN <= '0';
						state <= s_ready;
					end if;
						
					
			end case;
		end if;
	end process serialize;

end behavioral;