library ieee;
use ieee.std_logic_1164.all;

entity xmitTop is port(
	f_hi_priority:		in std_logic;
	f_rec_data_valid:	in std_logic;
	f_data_in:			in std_logic_vector(7 downto 0);
	f_ctrl_in: 			in std_logic_vector(24 downto 0);
	clk_sys:				in std_logic;
	clk_phy:				in std_logic;
	phy_data_out: 		out std_logic_vector(3 downto 0);
	m_discard_en: 		out std_logic;
	m_discard_frame:	out std_logic_vector(7 downto 0);
	m_frame:				out std_logic_vector(7 downto 0);
	m_tx_done:			out std_logic;
	reset:				in std_logic
);
end entity;

architecture rtl of xmitTop is
	signal overflow_low:		std_logic; -- TODO
	signal overflow_high:	std_logic;
	signal out_wren:			std_logic;
	signal out_priority:		std_logic;
	
	component in_FSM
	port(
		in_frame:				in std_logic_vector(7 downto 0);
		in_priority:			in std_logic;
		in_low_overflow:		in std_logic;
		in_hi_overflow:		in std_logic;
		in_f_rdv:				in std_logic;
		out_m_discard_en:		out std_logic;
		--out_m_discard_frame:	out std_logic_vector(7 downto 0);
		out_frame:				out std_logic_vector(7 downto 0);
		out_wren:				out std_logic;
		out_priority: 			out std_logic;
		clk_sys:					in std_logic;
		reset:					in std_logic
	);
	end component;
begin

	in_FSM_inst : in_FSM PORT MAP (
		in_frame				=> f_data_in,
		in_priority 		=> f_hi_priority,
		in_low_overflow	=> overflow_low,
		in_hi_overflow 	=> overflow_high,
		in_f_rdv 			=> f_rec_data_valid,
		out_m_discard_en	=> m_discard_en,
		--out_m_discard_frame:	out std_logic_vector(7 downto 0);
		out_frame			=> m_frame,
		out_wren				=> out_wren,
		out_priority 		=> out_priority,
		clk_sys				=> clk_sys,
		reset    			=> reset
	);
	
end architecture;
