library ieee;
use ieee.std_logic_1164.all;

entity in_FSM is 
port(
	in_priority:			in std_logic;
	in_lo_overflow:		in std_logic;
	in_hi_overflow:		in std_logic;
	in_ctrl_write:			in std_logic;
	out_m_discard_en:		out std_logic;
	out_wren:				out std_logic;
	out_priority: 			out std_logic;
	clk_phy:					in std_logic;
	clk_sys:					in std_logic;
	reset:					in std_logic			
);
end in_FSM;

architecture arch of in_FSM is
--	type numstate is (start_state, frame_state, end_state);
	signal discard_en_next: std_logic;
	signal wren_next:			std_logic;
	signal priority_next:	std_logic;
	
begin

	process(clk_sys, reset)
	begin
		if(reset = '1') then
			out_m_discard_en <= '0';		
			out_wren <= '0';
			out_priority <= '0';
		elsif (clk_sys'event and clk_sys='1' and in_ctrl_write='1') then
			priority_next<=in_priority;
			if ((in_lo_overflow = '1' and in_priority='0') or (in_hi_overflow='1' and in_priority='1')) then
				discard_en_next <= '1';
				wren_next <= '0';
			else
				discard_en_next <= '0';
				wren_next <= '1';
			end if;
		end if;
	end process;
	
	process(clk_phy, discard_en_next, wren_next, priority_next)
	begin
		if(clk_phy'event and clk_phy='1') then
			out_priority<=priority_next;
			out_m_discard_en<=discard_en_next;
			out_wren<=wren_next;
		end if;
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
