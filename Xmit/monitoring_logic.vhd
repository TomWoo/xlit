library ieee;
use ieee.std_logic_1164.all;
entity monitoring_logic is			
	port(
			clk, reset: 			in std_logic;
			discard_enable:		in std_logic;
			xmit_done:				in std_logic;
			discard_frame:			in std_logic_vector (11 downto 0);
			frame_seq:				in std_logic_vector (23 downto 0);
			discard_looknow:		out std_logic;
			ctrl_block_out:		out std_logic_vector(23 downto 0);
			discard_frame_out:	out std_logic_vector(11 downto 0);
			xmit_looknow:			out std_logic);
end monitoring_logic;

architecture buffered of monitoring_logic is
	
begin
	process(clk, discard_enable, xmit_done, discard_frame, frame_seq)
	begin
		if(clk'event and clk='1') then
			discard_looknow <= discard_enable;
			xmit_looknow <= xmit_done;
			discard_frame_out <= discard_frame;
			ctrl_block_out <= frame_seq;
		
		end if;
	
	
	end process;
	
end buffered;