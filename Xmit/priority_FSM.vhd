library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

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
	hi_empty_in 		: in std_logic;
	pop_hi				: out std_logic;
	
	data_out				: out std_logic_vector(7 downto 0);
	ctrl_block_out		: out std_logic_vector(23 downto 0)
);
end entity;

architecture rtl of priority_FSM is
	signal data_sel	: std_logic;
begin

-- Asynchronous signals
process(data_sel) begin
	if(data_sel = '0') then
		data_out <= data_lo_in;
		ctrl_block_out <= ctrl_block_lo_in;
	else
		data_out <= data_hi_in;
		ctrl_block_out <= ctrl_block_hi_in;
	end if;
end process;

-- Synchronous signals
process(clk_phy, reset) begin
	if (reset = '1') then
		pop_hi <= '0';
		pop_lo <= '0';
		data_sel <= '0';
	elsif(rising_edge(clk_phy)) then
		if(lo_empty_in = '0' and hi_empty_in = '0') then
			pop_hi <= '1';
			pop_lo <= '0';
			data_sel <= '1';
		elsif(lo_empty_in = '0' and hi_empty_in = '1') then
			pop_hi <= '0';
			pop_lo <= '1';
			data_sel <= '0';
		elsif(lo_empty_in = '1' and hi_empty_in = '0') then
			pop_hi <= '1';
			pop_lo <= '0';
			data_sel <= '1';
		else -- both empty
			pop_hi <= '0';
			pop_lo <= '0';
			data_sel <= '0';
		end if;
	else
		pop_hi <= pop_hi;
		pop_lo <= pop_lo;
		data_sel <= data_sel;
	end if;
end process;

end architecture;
