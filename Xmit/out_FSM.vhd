library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity out_FSM is
port(
	clk_phy				: in std_logic;
	reset					: in std_logic;
	data_in				: in std_logic_vector(7 downto 0);
	ctrl_block_in		: in std_logic_vector(23 downto 0);
	tx_en					: out std_logic;
	frame_seq_out		: out std_logic_vector(11 downto 0);
	xmit_done_out		: out std_logic;
	data_out				: out std_logic_vector(3 downto 0)
);
end entity;

architecture rtl of out_FSM is
	type state is (s_gap, s_preamble, s_SFD, s_DA, s_SA, s_length, s_data, s_FCS);
	signal my_state		: state;
	signal count			: integer range 0 to 4095; -- 12 bits
	signal frame_count	: integer range 0 to 4095;
	
	signal data_in_fifo	: std_logic_vector(63 downto 0);
	signal rden				: std_logic;
	signal wren				: std_logic := '1';
	signal is_empty		: std_logic;
	signal is_full			: std_logic;
	signal data_out_fifo	: std_logic_vector(63 downto 0);
	signal length_fifo	: std_logic_vector(9 downto 0);
	
	-- Half-rate clock
	signal clk_phy_2		: std_logic;
	
	-- Asynchronous signals
	signal count_mod		: integer range 0 to 4095;
	
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
process(count, data_in, ctrl_block_in, frame_count) begin
	data_in_fifo(7 downto 0) <= data_in;
	data_in_fifo(31 downto 8) <= ctrl_block_in;
	data_in_fifo(63 downto 32) <= X"00000000";
	
	count_mod <= count mod 32;
	frame_seq_out <= std_logic_vector(to_unsigned(frame_count, 12));
end process;

-- Prescaler (half-rate)
process(clk_phy, reset) begin
	if(reset = '1') then
		clk_phy_2 <= '1';
	elsif(rising_edge(clk_phy)) then
		clk_phy_2 <= not clk_phy_2;
	else
		clk_phy_2 <= clk_phy_2;
	end if;
end process;

-- Output buffer
output_buffer_inst : output_buffer PORT MAP (
	aclr	 => reset,
	clock	 => clk_phy,
	data	 => data_in_fifo,
	rdreq	 => rden,
	wrreq	 => wren,
	empty	 => is_empty,
	full	 => is_full,
	q	 => data_out_fifo,
	usedw	 => length_fifo
);

-- Moore FSM
process(clk_phy, reset) begin
	if(reset = '1') then
		my_state <= s_gap;
		count <= 0;
	elsif(rising_edge(clk_phy)) then
		case my_state is
		when s_gap =>
			if(count >= 96/4) then
				my_state <= s_preamble;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_preamble =>
			if(count >= 56/4) then
				my_state <= s_SFD;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_SFD =>
			if(count >= 8/4) then
				my_state <= s_DA;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_DA =>
			if(count >= 48/4) then
				my_state <= s_SA;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_SA =>
			if(count >= 48/4) then
				my_state <= s_length;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_length =>
			if(count >= 16/4) then
				my_state <= s_data;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_data =>
			if(count >= 12000/4) then -- TODO: constants
				my_state <= s_FCS;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when s_FCS =>
			if(count >= 32/4) then
				my_state <= s_gap;
				count <= 0;
			else
				count <= count + 1;
			end if;
		when others =>
			my_state <= my_state;
			count <= count + 1;
		end case;
	else
		my_state <= my_state;
		count <= count;
	end if;
end process;

-- Buffer control
process(clk_phy_2, reset) begin
	if(reset = '1') then
		rden <= '0';
	elsif(rising_edge(clk_phy_2)) then
		rden <= '1';
	else
		rden <= rden;
	end if;
end process;

-- Output signals
process(my_state) begin
	case my_state is
	when s_gap =>
		data_out <= "0000";
		tx_en <= '0';
	when s_preamble =>
		data_out <= "1010";
		tx_en <= '1';
	when s_SFD =>
		if(count = 0) then
			data_out <= "1010";
		else -- count = 1
			data_out <= "1011";
		end if;
		tx_en <= '1';
	when s_DA | s_SA | s_length =>
		case count_mod is -- TODO: generate
		when 0 =>
			data_out <= data_out_fifo(3 downto 0);
		when 1 =>
			data_out <= data_out_fifo(7 downto 4);
		when 2 =>
			data_out <= data_out_fifo(11 downto 8);
		when 3 =>
			data_out <= data_out_fifo(15 downto 12);
		when 4 =>
			data_out <= data_out_fifo(19 downto 16);
		when 5 =>
			data_out <= data_out_fifo(23 downto 20);
		when 6 =>
			data_out <= data_out_fifo(27 downto 24);
		when others => -- when 7
			data_out <= data_out_fifo(31 downto 28);
		end case;
		tx_en <= '1';
	when others => -- s_FCS
		if(count mod 2 = 0) then
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
		frame_count <= 0;
	elsif(rising_edge(clk_phy)) then
		if(my_state = s_FCS and count = 7) then
			xmit_done_out <= '1';
			frame_count <= frame_count + 1;
		else
			xmit_done_out <= '0';
			frame_count <= frame_count;
		end if;
	else
		xmit_done_out <= xmit_done_out;
		frame_count <= frame_count;
	end if;
end process;

end architecture;
