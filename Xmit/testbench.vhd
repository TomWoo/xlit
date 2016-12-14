LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY testbench IS
	PORT (sysclk		: IN 		STD_LOGIC;
			Reset		: IN		STD_LOGIC;
         test_start	: IN	    STD_LOGIC;
			phy_out:		OUT		STD_LOGIC_VECTOR (3 DOWNTO 0);
			phy_tx_en:	OUT	STD_LOGIC;
			phyclk:		out std_logic;
			data_LSB:	out std_logic
			);			

END entity;

ARCHITECTURE test_bench_o of testbench IS
	
component xmt_tb0
	PORT
	(Clock		: IN		STD_LOGIC;
		Reset		: IN		STD_LOGIC;
            test_start	: IN	    STD_LOGIC;
            start_out	: OUT		STD_LOGIC;
            ctlblk_out  : out       std_logic_vector(23 downto 0);
            data_out    : out	    std_logic_vector(7 downto 0);
            ctlblk_en   : out       std_logic;
            data_en     : out       std_logic;
				hi_priority	: out			std_logic
	);
end component;


component xmitTop
	PORT
	(f_hi_priority:		in std_logic;
	f_rec_data_valid:	in std_logic;
	f_rec_frame_valid:in std_logic;
	f_data_in:			in std_logic_vector(7 downto 0);
	f_ctrl_in: 			in std_logic_vector(23 downto 0);
	
	clk_sys:				in std_logic;
	clk_phy:				in std_logic;
	reset:				in std_logic;
	
	phy_data_out: 		out std_logic_vector(3 downto 0);
	phy_tx_en:			out std_logic;
	m_discard_en: 		out std_logic;
	m_discard_frame:	out std_logic_vector(11 downto 0);
	m_tx_frame:			out std_logic_vector(23 downto 0);
	m_tx_done:			out std_logic
	);
end component;
  
signal start_out:			std_logic;
signal test_ctrlblock:	std_logic_vector(23 downto 0);
signal test_ctrl_en: 	std_logic;
signal test_data:			std_logic_vector(7 downto 0);
signal test_data_en:		std_logic;
signal test_hi_priority:std_logic;

signal m_discard:			std_logic;
signal m_discard_fr:		std_logic_vector(11 downto 0);
signal m_tx_fr:			std_logic_vector(23 downto 0);
signal m_tx_d:				std_logic;

signal phyclk_duplicate: std_logic;

-- instantiate the components and map the ports
begin

	-- Clock divider DFF (half-rate)
	process(sysclk, reset) begin
		data_LSB <= phy_out(0);
		if(reset = '1') then
			phyclk <= sysclk;
		elsif(rising_edge(sysclk)) then
			phyclk <= not phyclk;
		end if;
	end process;
	
	-- asynchronous signals
	process(all) begin
		phyclk_duplicate <= phyclk;
	end process;

tester : xmt_tb0 PORT MAP (
	Clock					=> sysclk, 
	Reset					=> Reset,
   test_start 			=> test_start,
   start_out 			=> start_out,
   ctlblk_out 			=> test_ctrlblock,
   data_out 			=> test_data,
   ctlblk_en 			=> test_ctrl_en,
   data_en 				=> test_data_en,
	hi_priority			=> test_hi_priority
);

xmit : xmitTop PORT MAP (
	f_hi_priority		=> test_hi_priority,
	f_rec_data_valid 	=> test_data_en,
	f_rec_frame_valid => test_ctrl_en,
	f_data_in 			=> test_data,
	f_ctrl_in 			=> test_ctrlblock,
	
	clk_sys				=> sysclk,
	clk_phy				=> phyclk_duplicate,
	reset					=> Reset,
	
	phy_data_out 		=> phy_out,
	phy_tx_en			=> phy_tx_en,
	m_discard_en 		=> m_discard,
	m_discard_frame	=> m_discard_fr,
	m_tx_frame			=> m_tx_fr,
	m_tx_done			=>	m_tx_d);

END test_bench_o;






