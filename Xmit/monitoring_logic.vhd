library ieee;
use ieee.std_logic_1164.all;
entity monitoring_logic is			
	port(
			clk, reset: 		in std_logic;
			discard_enable:	in std_logic;
			xmit_done:			in std_logic;
			discard_frame:		in std_logic_vector (7 downto 0);
			frame_seq:			in std_logic_vector (24 downto 0);
			discard_xmit:		out std_logic;
			ctrl_block_out:	out std_logic_vector(24 downto 0);
			look_now:			out std_logic;
end monitoring_logic;

architecture buffered of monitoring_logic is
	
begin
	
end buffered;