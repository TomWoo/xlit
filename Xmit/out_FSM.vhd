library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity out_FSM is
port(
	clk_phy				: in std_logic;
	reset					: in std_logic;
	wren					: in std_logic;
	data_in				: in std_logic_vector(7 downto 0);
	ctrl_block_in		: in std_logic_vector(23 downto 0);
	stop_in				: in std_logic;
	tx_en					: out std_logic;
	frame_seq_out		: out std_logic_vector(23 downto 0);
	xmit_done_out		: out std_logic;
	data_out				: out std_logic_vector(3 downto 0)
);
end entity;

architecture rtl of out_FSM is
	type state is (s_gap, s_preamble, s_SFD, s_data);
	signal my_state		: state;
	-- 12-bit counters
	signal count_int			: integer range 0 to 131071;
	signal count				: std_logic_vector(11 downto 0);
	signal frame_count_int	: integer range 0 to 131071;
	signal frame_count		: std_logic_vector(11 downto 0);
	
	signal rden				: std_logic;
	signal data_in_fifo	: std_logic_vector(63 downto 0);
	signal data_out_fifo	: std_logic_vector(63 downto 0);
	
	-- Half-rate clock
	signal clk_phy_2		: std_logic;
	
	component output_buffer
	port(
		aclr			: in std_logic;
		clock			: in std_logic;
		data			: in std_logic_vector(63 downto 0);
		rdreq			: in std_logic;
		wrreq			: in std_logic;
		empty			: out std_logic;
		full			: out std_logic;
		q				: out std_logic_vector(63 downto 0);
		usedw			: out std_logic_vector(9 downto 0)
	);
	end component;
begin

-- Asynchronous signals
process(all) begin
	data_in_fifo(7 downto 0) <= data_in;
	data_in_fifo(31 downto 8) <= ctrl_block_in;
	data_in_fifo(63 downto 32) <= X"00000000";
	
--	count_mod <= count mod 32;
--	count_int <= to_integer(unsigned(count));
	count <= std_logic_vector(to_unsigned(count_int, 12));
	frame_count <= std_logic_vector(to_unsigned(frame_count_int, 12));

	-- TODO: check
	frame_seq_out <= data_out_fifo(43 downto 20); -- std_logic_vector(to_unsigned(frame_count_int, 12));
end process;

-- Clock divider register (half-rate)
process(clk_phy, reset) begin
	if(reset = '1') then
		clk_phy_2 <= '1';
	elsif(rising_edge(clk_phy)) then
		clk_phy_2 <= not clk_phy_2;
	end if;
end process;

-- Output buffer
output_buffer_inst : output_buffer PORT MAP (
	aclr	 => reset,
	clock	 => clk_phy,
	data	 => data_in_fifo,
	rdreq	 => rden,
	wrreq	 => wren,
--	empty	 => is_empty,
--	full	 => is_full,
	q		 => data_out_fifo
--	usedw	 => length_fifo
);

-- Moore FSM
process(clk_phy, reset) begin
	if(reset = '1') then
		my_state <= s_gap;
		count_int <= 0;
	elsif(rising_edge(clk_phy)) then
		case my_state is
		when s_gap =>
			if(count_int >= 96/4) then
				my_state <= s_preamble;
				count_int <= 0;
			else
				count_int <= count_int + 1;
			end if;
		when s_preamble =>
			if(count_int >= 56/4) then
				my_state <= s_SFD;
				count_int <= 0;
			else
				count_int <= count_int + 1;
			end if;
		when s_SFD =>
			if(count_int >= 8/4) then
				my_state <= s_data;
				count_int <= 0;
			else
				count_int <= count_int + 1;
			end if;
		when others => -- s_data
			if(stop_in = '1') then
				my_state <= s_gap;
				count_int <= 0;
			else
				count_int <= count_int + 1;
			end if;
		end case;
	end if;
end process;

-- Buffer control
process(clk_phy_2, reset) begin
	if(reset = '1') then
		rden <= '0';
	elsif(rising_edge(clk_phy_2)) then
		rden <= '1';
	end if;
end process;

-- Output signals
process(my_state, count_int, data_out_fifo) begin
	case my_state is
	when s_gap =>
		data_out <= "0000";
		tx_en <= '0';
	when s_preamble =>
		data_out <= "1010";
		tx_en <= '1';
	when s_SFD =>
		if(count_int = 0) then
			data_out <= "1010";
		else -- count = 1
			data_out <= "1011";
		end if;
		tx_en <= '1';
	when others => -- s_data
		if(count_int mod 2 = 0) then
			data_out <= data_out_fifo(3 downto 0);
		else
			data_out <= data_out_fifo(7 downto 4);
		end if;
		tx_en <= '1';
	end case;
end process;

process(clk_phy, reset) begin
	if (reset = '1') then
		xmit_done_out <= '0';
		frame_count_int <= 0;
	elsif(rising_edge(clk_phy)) then
		if(stop_in = '1') then
			xmit_done_out <= '1';
			frame_count_int <= frame_count_int + 1;
		end if;
	end if;
end process;

end architecture;
