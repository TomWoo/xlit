library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

entity discard_logic is
port(
	num_used_hi:	in std_logic_vector(14 downto 0);
	num_used_lo:	in std_logic_vector(14 downto 0);
	discard_en:		out std_logic;
	wren:				out std_logic;
	priority:		in std_logic;
	frame_len:		in std_logic_vector(11 downto 0)
);
end entity;

architecture arch of discard_logic is
	signal num_used_hi_int:	integer range 0 to 32767;
	signal num_used_lo_int:	integer range 0 to 32767;
	signal frame_len_int:	integer range 0 to 4095;
begin

-- Asynchronous signals
process(all) begin
	num_used_hi_int <= to_integer(unsigned(num_used_hi));
	num_used_lo_int <= to_integer(unsigned(num_used_lo));
	frame_len_int   <= to_integer(unsigned(frame_len  ));
	
	if((32768-num_used_hi_int<frame_len_int and priority='1') or (32768-num_used_lo_int<frame_len_int and priority='0')) then
		discard_en <= '1';
		wren <= '0';
	else
		discard_en <= '0';
		wren <= '1';
	end if;
end process;

end architecture;
