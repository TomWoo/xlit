library ieee;
use ieee.std_logic_1164.all;

entity in_FSM is 
port(
	in_priority:			in std_logic;
	in_lo_overflow:		in std_logic;
	in_hi_overflow:		in std_logic;
	in_ctrl_ctrl:			in std_logic;
	
	out_m_discard_en:		out std_logic;
	out_wren:				out std_logic;
	out_priority: 			out std_logic;
	clk_sys:					in std_logic;
	reset:					in std_logic			
);
end in_FSM;

architecture arch of in_FSM is
--	type numstate is (start_state, frame_state, end_state);
	signal ctrl_ctrl_prev:	std_logic;
	
begin

	process(clk_sys, reset) begin
		if(reset = '1') then
			ctrl_ctrl_prev <= '0';
		elsif(rising_edge(clk_sys)) then
			ctrl_ctrl_prev <= in_ctrl_ctrl;
		else
			ctrl_ctrl_prev <= ctrl_ctrl_prev;
		end if;
	end process;
	
	process(clk_sys, reset)
	begin
		if(reset = '1') then
			out_m_discard_en <= '0';		
			out_wren <= '0';
		elsif(clk_sys'event and clk_sys='1') then
			if ((in_lo_overflow = '1' and in_priority='0') or (in_hi_overflow='1' and in_priority='1')) then
				out_wren <= '0';
				out_m_discard_en <= in_ctrl_ctrl;
			else
				out_wren <= in_ctrl_ctrl;
				out_m_discard_en <= '0';
			end if;
		else
			out_m_discard_en <= out_m_discard_en;
			out_wren <= out_wren;
		end if;
		
		out_priority<=in_priority;
	end process;
	
--	process(clk_sys, reset)
--	begin
--		if(reset = '1') then
--			out_wren <= '0';
--		elsif (clk_sys'event and clk_sys='1') then
--			out_wren <= in_f_rdv;
--		end if;
--	end process;
--	
--	process(clk_sys, reset) begin
--		out_frame <= in_frame;
--		out_priority <= in_priority;
--	end process;
--	
--	process(clk_sys, reset) begin
--		if(reset = '1') then
--			
--		end if;
--	end process;
	
end arch;
