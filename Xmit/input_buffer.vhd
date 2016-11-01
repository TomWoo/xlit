library ieee;
use ieee.std_logic_1164.all;
entity input_buffer is			
	port(
			clk, reset: 		in std_logic;
			data_in:				in std_logic_vector (7 downto 0);
			ctrl_block:			in std_logic_vector (24 downto 0);
			ctrl_write:			in std_logic;
			discard_frame:		out std_logic_vector (7 downto 0);
			data_out:			out std_logic_vector (7 downto 0);
			ctrl_block_out:	out std_logic_vector (24 downto 0);
			ctrl_hi_out:		out std_logic;
			ctrl_write_out:	out std_logic;
end input_buffer;

architecture buffered of input_buffer is
	
begin
	
end buffered;