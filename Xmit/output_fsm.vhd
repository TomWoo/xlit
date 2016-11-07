library ieee;
use ieee.std_logic_1164.all;
entity output_fsm is			
	port(
			clk, reset: 		in std_logic;
			ctrl_block:			in std_logic_vector (24 downto 0);
			fr_seq:				out std_logic_vector (11 downto 0);
			data_valid:			out std_logic;
			xmit_done:			out std_logic;
end output_fsm;

architecture machine of output_fsm is
	
begin
	
end machine;