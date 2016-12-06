library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity priority_FSM is
port(
	clk_phy				: in std_logic;
	reset					: in std_logic;
	
	data_lo_in			: in std_logic_vector(7 downto 0);
	ctrl_block_lo_in	: in std_logic_vector(23 downto 0);
	lo_empty_in 		: in std_logic;
	pop_lo				: out std_logic;
	data_hi_in			: in std_logic_vector(7 downto 0);
	ctrl_block_hi_in	: in std_logic_vector(23 downto 0);
--	hi_empty_in 		: in std_logic;
	pop_hi				: out std_logic;
	
	data_out				: out std_logic_vector(7 downto 0);
	ctrl_block_out		: out std_logic_vector(23 downto 0);
	
	stop_in				: in std_logic;
	hi_fifo_used_in	: in std_logic_vector(10 downto 0);
	lo_fifo_used_in	: in std_logic_vector(10 downto 0)
);
end entity;

architecture rtl of priority_FSM is
	type state is (s_off, s_lo, s_hi);
	signal my_state				: state;
	signal hi_fifo_used_int		: integer range 0 to 2048;
	signal lo_fifo_used_int		: integer range 0 to 2048;
begin

-- Asynchronous signals
process(hi_fifo_used_in) begin
	hi_fifo_used_int <= to_integer(unsigned(hi_fifo_used_in));
end process;

process(pop_lo, pop_hi) begin
	if(pop_hi = '0') then
		data_out <= data_lo_in;
		ctrl_block_out <= ctrl_block_lo_in;
	else
		data_out <= data_hi_in;
		ctrl_block_out <= ctrl_block_hi_in;
	end if;
end process;

-- State machine
process(clk_phy, reset) begin
	if (reset = '1') then
	elsif(rising_edge(clk_phy)) then
		if(stop_in = '1') then
			if(hi_fifo_used_int > 255) then
				my_state <= s_hi;
			elsif(lo_fifo_used_int > 255) then
				my_state <= s_lo;
			else
				my_state <= s_off;
			end if;
		end if;
	end if;
end process;

-- Output signals
process(my_state) begin
	case my_state is
	when s_lo =>
		pop_hi <= '0';
		pop_lo <= '1';
	when s_hi =>
		pop_hi <= '1';
		pop_lo <= '0';
	when others => -- s_off
		pop_hi <= '0';
		pop_lo <= '0';
	end case;
end process;

end architecture;
