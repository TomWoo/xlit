library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

-- TODO: rename to buffer_logic
entity discard_logic is
port(
	num_used_hi:	in std_logic_vector(10 downto 0);
	num_used_lo:	in std_logic_vector(10 downto 0);
	discard_en:		out std_logic;
	wren_out:		out std_logic;
	priority:		in std_logic;
	frame_len:		in std_logic_vector(11 downto 0)
);
end entity;

architecture arch of discard_logic is
	signal num_used_hi_int:	integer range 0 to 2048;
	signal num_used_lo_int:	integer range 0 to 2048;
	signal frame_len_int:	integer range 0 to 4095;
begin

process(num_used_hi_int, num_used_lo_int, priority, frame_len_int) begin
	num_used_hi_int <= to_integer(unsigned(num_used_hi));
	num_used_lo_int <= to_integer(unsigned(num_used_lo));
	frame_len_int   <= to_integer(unsigned(frame_len  ));
	
	if((2048-num_used_hi_int<frame_len_int and priority='1') or (2048-num_used_lo_int<frame_len_int and priority='0')) then
		discard_en <= '1';
		wren_out <= '0';
	else
		discard_en <= '0';
		wren_out <= '1';
	end if;
end process;

end architecture;
