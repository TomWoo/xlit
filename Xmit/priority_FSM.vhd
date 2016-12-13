library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity priority_FSM is
port(
	clk_phy				: in std_logic;
	reset					: in std_logic;
	
	data_lo_in			: in std_logic_vector(7 downto 0);
	ctrl_block_lo_in	: in std_logic_vector(23 downto 0);
	pop_lo				: out std_logic;
	data_hi_in			: in std_logic_vector(7 downto 0);
	ctrl_block_hi_in	: in std_logic_vector(23 downto 0);
	pop_hi				: out std_logic;
	
	wren_out				: out std_logic;
	data_out				: out std_logic_vector(7 downto 0);
	ctrl_block_out		: out std_logic_vector(23 downto 0);
	
	hi_stop_in			: in std_logic;
	hi_fifo_used_in	: in std_logic_vector(16 downto 0);
	lo_stop_in			: in std_logic;
	lo_fifo_used_in	: in std_logic_vector(16 downto 0);
	stop_out				: out std_logic
);
end entity;

architecture rtl of priority_FSM is
	type state is (s_off, s_lo, s_hi);
	signal my_state				: state;
	signal hi_fifo_used_int		: integer range 0 to 131071;
	signal lo_fifo_used_int		: integer range 0 to 131071;
	signal pop_hi_ena				: std_logic;
	signal pop_lo_ena				: std_logic;
begin

-- Asynchronous signals
process(all) begin
	hi_fifo_used_int <= to_integer(unsigned(hi_fifo_used_in));
	lo_fifo_used_int <= to_integer(unsigned(lo_fifo_used_in));
	-- stop
	if((my_state = s_hi and hi_stop_in = '1') or (my_state = s_lo and lo_stop_in = '1')) then
		stop_out <= '1';
	else
		stop_out <= '0';
	end if;
	
	-- pop
	pop_hi <= pop_hi_ena and clk_phy;
	pop_lo <= pop_lo_ena and clk_phy;
end process;

-- State machine
process(clk_phy, reset) begin
	if (reset = '1') then
		my_state <= s_off;
	elsif(rising_edge(clk_phy)) then
		-- TODO: check -- hi_stop_in = '1' or lo_stop_in = '1'
		case my_state is
		when s_lo =>
			if(lo_stop_in = '1') then
				my_state <= s_off;
			end if;
		when s_hi =>
			if(hi_stop_in = '1') then
				my_state <= s_off;
			end if;
		when others => -- s_off
			if(hi_fifo_used_int >= 512) then
				my_state <= s_hi;
			elsif(lo_fifo_used_int >= 512) then
				my_state <= s_lo;
			end if;
		end case;
	end if;
end process;

-- Output signals
process(my_state, data_lo_in, ctrl_block_lo_in, data_hi_in, ctrl_block_hi_in) begin
	case my_state is
	when s_lo =>
		pop_hi_ena <= '0';
		pop_lo_ena <= '1';
		
		wren_out <= '1';
		data_out <= data_lo_in;
		ctrl_block_out <= ctrl_block_lo_in;
	when s_hi =>
		pop_hi_ena <= '1';
		pop_lo_ena <= '0';
		
		wren_out <= '1';
		data_out <= data_hi_in;
		ctrl_block_out <= ctrl_block_hi_in;
	when others => -- s_off
		pop_hi_ena <= '0';
		pop_lo_ena <= '0';
		
		wren_out <= '0';
		data_out <= X"00";
		ctrl_block_out <= X"000000";
	end case;
end process;

end architecture;
