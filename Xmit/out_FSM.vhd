library ieee;
use ieee.std_logic_1164.all;

entity out_FSM is
port(
	clk_phy:					in std_logic;
	reset:					in std_logic;
	ctrl_block_in:			in std_logic_vector(24 downto 0);
	wren_ctrl_out:			out std_logic;
	frame_seq_out:			out std_logic_vector(11 downto 0);
	xmit_done_out:			out std_logic
);
end out_FSM;

architecture rtl of out_FSM is
	type state is (s_gap, s_preamble, s_SFD, s_DA, s_SA, s_length, s_data, s_PAD, s_FCS);
	signal my_state	: state;
	signal count		: unsigned(63 downto 0);
begin

	process(clk_phy, reset) begin
		if(reset = '1') then
			my_state <= s_gap
		elsif (rising_edge(clk_phy)) then
			case cur_state is
			when s_gap =>
				if(count > 96) then
					my_state <= s_preamble;
					count <= 0;
				end if;
			when s_preamble =>
				if(count > 56) then
					my_state <= s_SFD;
					count <= 0;
				end if;
			when s_SFD =>
				if(count > 8) then
					my_state <= s_DA;
					count <= 0;
				end if;
			when s_DA =>
				if(count > 56) then
					my_state <= s_SA;
					count <= 0;
				end if;
			when s_SA =>
				if(count > 56) then
					my_state <= s_length;
					count <= 0;
				end if;
			when s_length =>
				if(count > 16) then
					my_state <= s_data;
					count <= 0;
				end if;
			when s_data =>
				if(count > 0) then
					my_state <= s_PAD;
					count <= 0;
				end if;
		end if;
	end process;
	
end architecture;
