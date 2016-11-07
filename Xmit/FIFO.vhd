library ieee;
use ieee.std_logic_1164.all;
entity FIFO is			
	port(
			clk, reset: 		in std_logic;
			enable:				in std_logic;
			data_in:				in std_logic_vector (7 downto 0);
			ctrl_in:				in std_logic_vector (24 downto 0);
			data_out:			out std_logic_vector (7 downto 0);
			ctrl_out:			out std_logic_vector (24 downto 0);
			overflow:			out std_logic;
end input_buffer;

architecture queue of FIFO is
	
begin
	
end queue;