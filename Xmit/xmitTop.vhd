library ieee;
use ieee.std_logic_1164.all;

entity xmitTop is port(
	f_hi_priority:		in std_logic;
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
end entity;

architecture rtl of xmitTop is
	
	component in_FSM
	PORT(
		in_priority:			in std_logic;

		clk_sys:					in std_logic;
		clk_phy:					in std_logic;
		reset:					in std_logic;
		
		controli: 				in std_logic_vector(23 downto 0);
		wrend: 					in std_logic; --data write enable;
		wrenc: 					in std_logic; --ctrl write enable;
		datai: 					in std_logic_vector(7 downto 0);
		
		datao: 					out std_logic_vector(7 downto 0);
		controlo: 				out std_logic_vector(23 downto 0);
		out_m_discard_en:		out std_logic;
		out_wren:				out std_logic;
		out_priority: 			out std_logic;
		
		stop:						out std_logic;
		numusedhi:				in std_logic_vector(10 downto 0);
		numusedlo: 				in std_logic_vector(10 downto 0)
	);
	end component;
	
	component monitoring_logic
	PORT(
		clk, reset: 			in std_logic;
		
		discard_enable:		in std_logic;
		xmit_done:				in std_logic;
		discard_frame:			in std_logic_vector (11 downto 0);	
		frame_seq:				in std_logic_vector (23 downto 0);
		
		discard_looknow:		out std_logic;
		ctrl_block_out:		out std_logic_vector(23 downto 0);
		discard_frame_out:	out std_logic_vector(11 downto 0);
		xmit_looknow:			out std_logic
	
	);
	end component;

	component priority_FSM
	PORT(
		clk_phy				: in std_logic;
		reset					: in std_logic;
		
		data_lo_in			: in std_logic_vector(7 downto 0);
		ctrl_block_lo_in	: in std_logic_vector(23 downto 0);
		data_hi_in			: in std_logic_vector(7 downto 0);
		ctrl_block_hi_in	: in std_logic_vector(23 downto 0);
		
		pop_lo				: out std_logic;
		pop_hi				: out std_logic;
		
		wren_out				: out std_logic;
		data_out				: out std_logic_vector(7 downto 0);
		ctrl_block_out		: out std_logic_vector(23 downto 0);
		
		hi_stop_in			: in std_logic;
		hi_fifo_used_in	: in std_logic_vector(10 downto 0);
		lo_stop_in			: in std_logic;
		lo_fifo_used_in	: in std_logic_vector(10 downto 0);
		stop_out				: out std_logic
	);
	end component;
	
	component out_FSM 
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
	end component;
	
	component ctrlFIFO
	PORT(
		aclr					: IN STD_LOGIC  := '0';
		data					: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdclk					: IN STD_LOGIC ;
		rdreq					: IN STD_LOGIC ;
		wrclk					: IN STD_LOGIC ;
		wrreq					: IN STD_LOGIC ;
		
		q						: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdempty				: OUT STD_LOGIC ;
		rdfull				: OUT STD_LOGIC ;
		wrempty				: OUT STD_LOGIC ;
		wrfull				: OUT STD_LOGIC ;
		wrusedw				: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
	end component;
	
	component dataFIFO
	PORT(
		aclr					: IN STD_LOGIC  := '0';
		data					: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk					: IN STD_LOGIC ;
		rdreq					: IN STD_LOGIC ;
		wrclk					: IN STD_LOGIC ;
		wrreq					: IN STD_LOGIC ;
		
		q						: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty				: OUT STD_LOGIC ;
		rdfull				: OUT STD_LOGIC ;
		wrempty				: OUT STD_LOGIC ;
		wrfull				: OUT STD_LOGIC ;
		wrusedw				: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
	end component;
	
	component FIFO_1
	PORT(
		aclr					: IN STD_LOGIC  := '0';
		data					: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdclk					: IN STD_LOGIC ;
		rdreq					: IN STD_LOGIC ;
		wrclk					: IN STD_LOGIC ;
		wrreq					: IN STD_LOGIC ;
		
		q						: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdempty				: OUT STD_LOGIC ;
		wrfull				: OUT STD_LOGIC 
	);
	end component;
	
	SIGNAL inBuffer_data_out: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL inBuffer_ctrl_out: STD_LOGIC_VECTOR (23 DOWNTO 0);
	SIGNAL inFSM_hi_priority_out: STD_LOGIC;
	SIGNAL inFSM_wren_out:		STD_LOGIC;
	SIGNAL inFSM_discard_out:	STD_LOGIC;
	
	SIGNAL HI_FIFO_overflow:	STD_LOGIC;
	SIGNAL LO_FIFO_overflow:	STD_LOGIC;
	
	SIGNAL lo_empty:				STD_LOGIC;
	SIGNAL hi_empty:				STD_LOGIC;
	
	SIGNAL xmit_done_wire:		STD_LOGIC;
	SIGNAL xmit_sequence_wire:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	
	SIGNAL out_wren_wire:		STD_LOGIC;
	SIGNAL out_priority_wire:	STD_LOGIC;
	
	SIGNAL low_fifo_enable:		STD_LOGIC;
	SIGNAL hi_fifo_enable:		STD_LOGIC;
	
	SIGNAL between_out_data:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL between_out_ctrl:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	
	SIGNAL hi_overflow:			STD_LOGIC;
	SIGNAL lo_overflow:			STD_LOGIC;
	
	SIGNAL hiho_data:				STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL hiho_ctrl:				STD_LOGIC_VECTOR (23 DOWNTO 0);
	SIGNAL hiho_stop:				STD_LOGIC_VECTOR (0 DOWNTO 0);
	SIGNAL lilo_data:				STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL lilo_ctrl:				STD_LOGIC_VECTOR (23 DOWNTO 0);
	SIGNAL lilo_stop:				STD_LOGIC_VECTOR (0 DOWNTO 0);
	
	SIGNAL hi_rereq:				STD_LOGIC;
	SIGNAL lo_rereq:				STD_LOGIC;
	
	signal stop			: std_logic_vector(0 DOWNTO 0);
	signal numusedhi	: std_logic_vector(10 downto 0);
	signal numusedlo	: std_logic_vector(10 downto 0);
	
	signal wren_priority_out_FSM: std_logic;
	signal stop_priority_out_FSM: std_logic;
	
	begin
	process(out_wren_wire, out_priority_wire, clk_sys)
	begin
		if(clk_phy'event and clk_phy='1') then
			low_fifo_enable <= out_wren_wire and not out_priority_wire;
			hi_fifo_enable <= out_wren_wire and out_priority_wire;
		end if;


	
	end process;
	
	
	in_FSM_inst: in_FSM PORT MAP (
		in_priority					=> f_hi_priority,

		out_m_discard_en			=> inFSM_discard_out,
		out_wren						=> out_wren_wire,
		out_priority				=> out_priority_wire,
		clk_sys						=> clk_sys,
		clk_phy						=> clk_sys,
		reset							=> reset,
		controli						=> f_ctrl_in,
		wrend							=> f_rec_data_valid,
		wrenc							=> f_rec_frame_valid,
		datai							=> f_data_in,
		datao							=> inBuffer_data_out,
		controlo						=> inBuffer_ctrl_out,
		
		stop							=> stop(0),
		numusedhi					=> numusedhi,
		numusedlo					=> numusedlo
	);
	
	monitoring_logic_inst: monitoring_logic PORT MAP (
		clk						=> clk_sys, 
		reset						=> reset,
		discard_enable			=> inFSM_discard_out,
		xmit_done				=> xmit_done_wire,
		discard_frame			=> inBuffer_ctrl_out (23 DOWNTO 12),
		frame_seq				=> xmit_sequence_wire,
		
		discard_looknow		=> m_discard_en,
		ctrl_block_out			=> m_tx_frame,
		discard_frame_out		=> m_discard_frame,
		xmit_looknow			=> m_tx_done
	
	);
	
	priority_FSM_inst: priority_FSM PORT MAP(
		clk_phy					=> clk_phy,
		reset						=> reset,
		
		data_lo_in				=> lilo_data,
		ctrl_block_lo_in		=> lilo_ctrl,
		pop_lo					=> lo_rereq,
		data_hi_in				=> hiho_data,
		ctrl_block_hi_in		=> hiho_ctrl,
		pop_hi					=> hi_rereq,
		
		wren_out					=> wren_priority_out_FSM,
		data_out					=> between_out_data,
		ctrl_block_out			=> between_out_ctrl,
		
		hi_stop_in				=> hiho_stop(0),
		lo_stop_in				=> lilo_stop(0),
		hi_fifo_used_in		=> numusedhi,
		lo_fifo_used_in		=> numusedlo,
		stop_out					=> stop_priority_out_FSM
	);
	
	output_FSM_inst: out_FSM PORT MAP(
		clk_phy					=> clk_phy,
		reset						=> reset,
		
		wren						=> wren_priority_out_FSM,
		data_in					=> between_out_data,	
		ctrl_block_in			=> between_out_ctrl,
		stop_in					=> stop_priority_out_FSM,
		
		tx_en						=> phy_tx_en,
		frame_seq_out			=> xmit_sequence_wire,
		xmit_done_out			=> xmit_done_wire,
		data_out					=> phy_data_out
	);

	data_hi_fifo: dataFIFO PORT MAP(
		aclr						=> reset,
		data						=> inBuffer_data_out,
		rdclk						=> clk_sys,
		rdreq						=> hi_rereq,
		wrclk						=> clk_phy,
		wrreq						=> hi_fifo_enable,
		q							=> hiho_data,
		rdempty					=> hi_empty,
--		rdfull					=> ,
--		wrempty					=> ,
		wrfull					=> hi_overflow,
		wrusedw					=> numusedhi
	);
	
	ctrl_hi_fifo: ctrlFIFO PORT MAP(
		aclr						=> reset,
		data						=> inBuffer_ctrl_out,
		rdclk						=> clk_sys,
		rdreq						=> hi_rereq,
		wrclk						=> clk_phy,
		wrreq						=> hi_fifo_enable,
		q							=> hiho_ctrl
--		rdempty					=> ,
--		rdfull					=> ,
--		wrempty					=> ,
--		wrfull					=> ,
--		wrusedw					=> 
		);
	
	stop_hi_fifo: FIFO_1 PORT MAP(
		aclr						=> reset,
		data						=> stop,
		rdclk						=> clk_sys,
		rdreq						=> hi_rereq,
		wrclk						=> clk_phy,
		wrreq						=> hi_fifo_enable,
		q							=> hiho_stop
--		rdempty					=> ,
--		rdfull					=> ,
--		wrempty					=> ,
--		wrfull					=> ,
--		wrusedw					=> 
		);
	
	data_lo_fifo: dataFIFO PORT MAP(
		aclr						=> reset,
		data						=> inBuffer_data_out,
		rdclk						=> clk_sys,
		rdreq						=> lo_rereq,
		wrclk						=> clk_phy,
		wrreq						=> low_fifo_enable,
		q							=> lilo_data,
		rdempty					=> lo_empty,
--		rdfull					=> ,
--		wrempty					=> ,
		wrfull					=> lo_overflow,
		wrusedw					=> numusedlo
		);
	
	ctrl_lo_fifo: ctrlFIFO PORT MAP(
		aclr						=> reset,
		data						=> inBuffer_ctrl_out,
		rdclk						=> clk_sys,
		rdreq						=> lo_rereq,
		wrclk						=> clk_phy,
		wrreq						=> low_fifo_enable,
		q							=> lilo_ctrl
--		rdempty					=> ,
--		rdfull					=> ,
--		wrempty					=> ,
--		wrfull					=> ,
--		wrusedw					=> 
		);
	
	stop_lo_fifo: FIFO_1 PORT MAP(
		aclr						=> reset,
		data						=> stop,
		rdclk						=> clk_sys,
		rdreq						=> lo_rereq,
		wrclk						=> clk_phy,
		wrreq						=> low_fifo_enable,
		q							=> lilo_stop
--		rdempty					=> ,
--		wrempty					=> ,
--		wrfull					=> ,
		);
	
	
	
end architecture;
