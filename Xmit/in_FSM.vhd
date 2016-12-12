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
	-- from sys_clk domain
	wrend: 					in std_logic; --data write enable;
	wrenc: 					in std_logic; --ctrl write enable;
	datai: 					in std_logic_vector(7 downto 0);
	controli: 				in std_logic_vector(23 downto 0);
	in_priority:			in std_logic;
	-- phy_clk domain
	numusedhi:				in std_logic_vector(10 downto 0);
	numusedlo: 				in std_logic_vector(10 downto 0);	
	
	out_m_discard_en:		out std_logic; -- synchronized to sys_clk externally
	out_wren:				out std_logic;
	out_priority: 			out std_logic;
	datao: 					out std_logic_vector(7 downto 0);
	controlo: 				out std_logic_vector(23 downto 0);
	stop:						out std_logic
);
end in_FSM;

architecture arch of in_FSM is
	-- Remapped inputs
	signal aclr:				std_logic;
	signal sysclk: 			std_logic;
	signal phyclk:				std_logic;
	
	-- FIFO signals
	signal emptyd, emptyc, empty_priority: std_logic;
	signal  fulld,  fullc,  full_priority: std_logic;
	
	component inbuff 
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
	
	component inbuffcon
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
	
	component FIFO_1
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
	
	-- State
	type state is (s_discard, s_stream);
	signal my_state	: state;
	
	-- Registered signals
	signal count					: std_logic_vector(8 downto 0);
	signal count_prev				: std_logic_vector(8 downto 0);
	
	-- Wires
	signal frame_len				: std_logic_vector(11 downto 0);
	signal is_zero					: std_logic;
	signal discard_en				: std_logic;
	signal stream_en				: std_logic;
	signal ctrl_wren				: std_logic;
	signal priority_fifo_out	: std_logic;
begin

-- Asynchronous signals
process(all) begin
	-- Remapped inputs
	aclr <= reset;
	sysclk <= clk_sys;
	phyclk <= clk_phy;
	
	frame_len <= controlo(11 downto 0);
	
	if(count = "000000000") then
		is_zero <= '1';
	else
		is_zero <= '0';
	end if;
	
	-- Remapped outputs
	out_priority <= priority_fifo_out;
end process;

-- Moore FSM (phy_clk)
process(reset, clk_phy) begin
	if(reset = '1') then
		my_state <= s_discard;
		count_prev <= "000000000";
		count <= "111111111"; -- high value to guarantee correct initialization
	elsif(rising_edge(clk_phy)) then
		if(is_zero) then
			if(discard_en) then
				my_state <= s_discard;
			else
				my_state <= s_stream;
			end if;
		end if;
		
		count_prev <= count;
		if(ctrl_wren = '1') then
			count <= frame_len(8 downto 0);
		elsif(not(is_zero)) then
			count <= count - '1';
		end if;
		
		-- stop logic
		if(not(count_prev = "00000000")) then
			stop <= is_zero;
		else
			stop <= '0';
		end if;
	end if;
end process;

-- Synchronous output signals
process(my_state) begin
	case my_state is
	when s_discard =>
		out_wren <= '0';
		out_m_discard_en <= '1';
	when others => -- s_stream
		out_wren <= '1';
		out_m_discard_en <= '0';
	end case;
end process;

inbuff_data: inbuff
port map (
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q => datao,
	data => datai,
	wrreq => wrend,
	rdreq => '1',
	rdempty => emptyd,
	wrfull => fulld
);

inbuff_ctrl: inbuffcon
port map(
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q => controlo,
	data => controli,
	wrreq => wrend,
	rdreq => '1',
	rdempty => emptyc,
	wrfull => fullc
);

inbuff_priority: FIFO_1
port map(
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q(0) => priority_fifo_out,
	data(0) => in_priority,
	wrreq => wrend,
	rdreq => '1',
	rdempty => empty_priority,
	wrfull => full_priority
);

ctrl_wren_fifo: FIFO_1
port map(
	aclr => aclr,
	wrclk => sysclk,
	rdclk => phyclk,
	q(0) => ctrl_wren,
	data(0) => wrenc,
	wrreq => wrend,
	rdreq => '1'
);

discard_logic_async: discard_logic
port map (
	num_used_hi => numusedhi,
	num_used_lo => numusedlo,
	discard_en => discard_en,
	wren_out => stream_en,
	priority => priority_fifo_out,
	frame_len => frame_len
);

end architecture;
