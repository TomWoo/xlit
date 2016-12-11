library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity in_FSM is 
port(
	clk_phy:					in std_logic;
	clk_sys:					in std_logic;
	reset:					in std_logic;

	wrend: 					in std_logic; --data write enable;
	wrenc: 					in std_logic; --ctrl write enable;
	datai: 					in std_logic_vector(7 downto 0);
	controli: 				in std_logic_vector(23 downto 0);
	in_priority:			in std_logic;
	
	numusedhi:				in std_logic_vector(10 downto 0);
	numusedlo: 				in std_logic_vector(10 downto 0);	
	
	out_m_discard_en:		out std_logic;
	out_wren:				out std_logic;
	out_priority: 			out std_logic;
	datao: 					out std_logic_vector(7 downto 0);
	controlo: 				out std_logic_vector(23 downto 0);
	stop:						out std_logic
);
end in_FSM;

architecture arch of in_FSM is
	-- remapped inputs
	signal aclr:				std_logic;
	signal sysclk: 			std_logic;
	signal phyclk:				std_logic;
	
	component discard_logic is
	port(
		num_used_hi:	in std_logic_vector(10 downto 0);
		num_used_lo:	in std_logic_vector(10 downto 0);
		discard_en:		out std_logic;
		wren_out:		out std_logic;
		priority:		in std_logic;
		frame_len:		in std_logic_vector(11 downto 0)
	);
	end component;
	
	component inbuff is
	port (
		aclr		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		wrfull	: OUT STD_LOGIC
	);
	end component;   
	
	component inbuffcon is
	port(
		aclr		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		wrfull	: OUT STD_LOGIC
	);
	end component;
	
	component FIFO_1 is
	port(
		aclr		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		wrfull	: OUT STD_LOGIC
	);
	end component;
	
	-- State signals
	type state is (s_buffering, s_streaming);
	signal my_state	: state;
	
	-- Wires
	signal frame_len		: std_logic_vector(11 downto 0);
	signal buffering_en	: std_logic;
	signal streaming_en	: std_logic;
	
	signal priority		: std_logic;
	signal priority_wren	: std_logic;
	signal priority_rden	: std_logic;
	
	signal stop_fifo_in	: std_logic;
	signal stop_wren		: std_logic;
	signal stop_rden		: std_logic;
	
	signal data_fifo_wren	: std_logic;
	signal data_fifo_rden	: std_logic;
	signal ctrl_fifo_wren	: std_logic;
	signal ctrl_fifo_rden	: std_logic;
	
	signal fulld, emptyd, fullc, emptyc, full_priority, empty_priority, full_stop, empty_stop	: std_logic;
	
	-- Reg's
	signal count			: std_logic_vector(8 downto 0);
begin

-- Remapped inputs
process(reset, clk_sys, clk_phy) begin
	aclr <= reset;
	sysclk <= clk_sys;
	phyclk <= clk_phy;
end process;

-- Asynchronous signals
process(all) begin
	frame_len <= controli(11 downto 0);
	
	-- stop logic
	if(count = "000000000") then
		stop_fifo_in <= '1';
	else
		stop_fifo_in <= '0';
	end if;
end process;

-- Initializing FIFO read signals
process(reset, wrenc) begin
	if(reset = '1') then
		data_fifo_rden <= '0';
		ctrl_fifo_rden <= '0';
		
		priority_rden <= '0';
		stop_rden <= '0';
	elsif(rising_edge(wrenc)) then
		data_fifo_rden <= '1';
		ctrl_fifo_rden <= '1';
		
		priority_rden <= '1';
		stop_rden <= '1';
	end if;
end process;

-- Moore FSM
process(reset, clk_sys) begin
	if(reset = '1') then
		my_state <= s_buffering;
		count <= "111111111"; -- highest value to guarantee correct initialization
	elsif(rising_edge(clk_sys)) then
		if(buffering_en) then
			my_state <= s_buffering;
		else
			my_state <= s_streaming;
		end if;
		
		if(wrenc = '1') then
			count <= frame_len(8 downto 0);
		else
			count <= count - '1';
		end if;
	end if;
end process;

-- Moore FSM output signals
process(my_state) begin
	case my_state is
	when s_buffering =>
		out_wren <= '0';
		
		data_fifo_wren <= '0';
		ctrl_fifo_wren <= '0';
		
		priority_wren <= '0';
		stop_wren <= '0';
	when others => -- s_streaming
		out_wren <= '1';
		
		data_fifo_wren <= '1';
		ctrl_fifo_wren <= '1';
		
		priority_wren <= '1';
		stop_wren <= '1';
	end case;
end process;

-- Output signals
process(priority, buffering_en, count) begin
	out_priority <= priority;
	
	if(buffering_en = '1' and count = "000000000") then
		out_m_discard_en <= '1';
	else
		out_m_discard_en <= '0';
	end if;
end process;

buffer_logic: discard_logic
port map (
	num_used_hi => numusedhi,
	num_used_lo => numusedlo,
	discard_en => buffering_en,
	wren_out => streaming_en,
	priority => priority,
	frame_len => frame_len
);

input_buffer_data: inbuff
port map (
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q => datao,
	data => datai,
	wrreq => data_fifo_wren,
	rdreq => data_fifo_rden,
	rdempty => emptyd,
	wrfull => fulld
);

input_buffer_ctrl: inbuffcon
port map(
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q => controlo,
	data => controli,
	wrreq => ctrl_fifo_wren,
	rdreq => ctrl_fifo_rden,
	rdempty => emptyc,
	wrfull => fullc
);

priority_fifo: FIFO_1
port map(
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q(0) => priority,
	data(0) => in_priority,
	wrreq => priority_wren,
	rdreq => priority_rden,
	rdempty => empty_priority,
	wrfull => full_priority
);

stop_fifo: FIFO_1
port map(
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q(0) => stop,
	data(0) => stop_fifo_in,
	wrreq => stop_wren,
	rdreq => stop_rden,
	rdempty => empty_stop,
	wrfull => full_stop
);

end architecture;
