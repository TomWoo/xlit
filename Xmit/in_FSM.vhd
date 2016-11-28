library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity in_FSM is 
port(
	in_priority:			in std_logic;
	in_lo_overflow:		in std_logic;
	in_hi_overflow:		in std_logic;
	in_ctrl_ctrl:			in std_logic;
	out_m_discard_en:		out std_logic;
	out_wren:				out std_logic;
	out_priority: 			out std_logic;
	clk_phy:					in std_logic;
	clk_sys:					in std_logic;
	reset:					in std_logic;
	controli: 				in std_logic_vector(23 downto 0);
	wrend: 					in std_logic; --data write enable;
	wrenc: 					in std_logic; --ctrl write enable;
	datai: 					in std_logic_vector(7 downto 0);
	datao: 					out std_logic_vector(7 downto 0);
	controlo: 				out std_logic_vector(23 downto 0);
	stop:						out std_logic;
	db_ctrlm:				out std_logic_vector(23 downto 0);
	db_incountdone:		out std_logic;
	db_outcountdone:		out std_logic;
	db_last:					out std_logic
	
);
end in_FSM;

architecture arch of in_FSM is
--	type numstate is (start_state, frame_state, end_state);
	signal discard_en_next: std_logic;
	signal wren_next:			std_logic;
	signal priority_next:	std_logic;
	
	signal aclr:				std_logic;
	signal sysclk: 			std_logic;
	signal phyclk:				std_logic;
	
	signal ctrl_ctrl_prev:	std_logic;
	
	signal hi: std_logic := '1';
	signal emptyd, emptyc, empty_priority, empty_stop: std_logic;
	signal fulld, fullc, full_priority, full_stop: std_logic;
	signal incountdone: std_logic:='0';
	signal outcountdone: std_logic:='0';
	signal datam: std_logic_vector (7 downto 0);
	signal ctrlm: std_logic_vector (23 downto 0);
	signal readen: std_logic;
	signal canout: std_logic;
	signal cnto: unsigned(11 downto 0);
	signal cnti: unsigned(11 downto 0);
	signal cntot: unsigned(11 downto 0);
	signal cntit: unsigned(11 downto 0);
	signal last: std_logic;
	signal lastm: std_logic;
	signal opri: std_logic;
	signal outstart: std_logic;
	signal outstartas: std_logic;
	signal dir: unsigned(11 downto 0) := "000000000001";
	signal transen: std_logic := '1';
	
	component inbuff 
		port (
		aclr		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
		);
	end component;   
	
	component inbuffcon
		port(	aclr		: IN STD_LOGIC;
			data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	END component;
	
	component FIFO_1
		port(	aclr		: IN STD_LOGIC;
			data		: IN STD_LOGIC;
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC;
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	END component;
	
begin

	process(clk_sys, reset, ctrl_ctrl_prev, in_ctrl_ctrl) begin
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
		
		--out_priority<=in_priority;
	end process;
	
	---------------- buffer logic ----------------
	
	process(reset, clk_sys, clk_phy, ctrlm, incountdone, outcountdone, last) begin
		aclr <= reset;
		sysclk <= clk_sys;
		phyclk <= clk_phy;
		db_ctrlm <= ctrlm;
		db_incountdone <= incountdone;
		db_outcountdone <= outcountdone;
		db_last <= last;
	end process;
	
	PROCESS (sysclk, controli, wrenc, aclr, cnti, cntit) --incounter	
	BEGIN		
		if(aclr = '1') then
			cnti <= "111111111111";
			incountdone <= '0';
			last <='0';
		elsif (sysclk'EVENT AND sysclk = '1') THEN
			if (wrenc = '1') then
				cnti <= not (unsigned(controli(11 downto 0)))+dir; -- SOMETHING HERE IS BREAKING TRIES TO ASSIGN 00F TO FF0
				cntit <= not (unsigned(controli(11 downto 0)))+dir+dir;
			else
				if (to_integer(cnti)>2) then
					cnti <= cnti + dir;
				end if;
				if (to_integer(cntit)>2) then
					cntit <= cntit +dir;
				end if;
			end if;
		END IF;
		if (to_integer(cnti) <= 2) then
			incountdone <= '1';
		else 
			incountdone <= '0';
		end if;
		if (to_integer(cntit) <= 2) then
			last <= '1';
		else
			last <= '0';
		end if;
	END PROCESS;

	PROCESS (phyclk, ctrlm, aclr, cnto) --outcounter
	BEGIN	
		if (aclr = '1') then
			cnto <= "111111111111";
			outcountdone <= '0';
		elsif (phyclk'EVENT AND phyclk = '1') THEN
			if (incountdone = '1' and outcountdone = '1') then -- if transmit enable
				cnto <= not (unsigned(ctrlm(11 downto 0)));	-- SOMETHING HERE IS ALSO BREAKING
			else
				if (to_integer(cnto)>2) then
					cnto <= cnto + dir;
				end if;
			end if;
		END IF;
		if (to_integer(cnto) <= 2) then
			outcountdone <= '1';
		else 
			outcountdone <= '0';
		end if;
	END PROCESS;
	
	
	process(phyclk, emptyd, aclr) --ctrlout
	begin
		if(aclr = '1') then
			out_priority <= '0';
			controlo <= "000000000000000000000000";
		elsif (phyclk'event AND phyclk = '1') then
			controlo <= ctrlm;
			out_priority <= opri;
		end if;
	end process;
	
	process(phyclk, emptyd, aclr) --dataout always outputs data from the buffer
	begin
		if (aclr = '1') then
			datao <= "00000000";
			stop <= '0';
		elsif (phyclk'event AND phyclk = '1') then
			datao <= datam;
			stop <= lastm;
		end if;
	end process;
	
	--last latch
	
	inbuff_comp : inbuff
		port map (
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => datam,
			data => datai,
			wrreq => wrend,
			rdreq => hi and incountdone and not lastm, -- transmit enable
			rdempty => emptyd,
			wrfull => fulld
			);
			
	inbuffcon_comp: inbuffcon
		port map(
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => ctrlm,
			data => controli,
			wrreq => wrenc,
			rdreq => hi and incountdone and not outcountdone, -- transmit enable clock 1
			rdempty => emptyc,
			wrfull => fullc
		);
		
	inbuff_priority: FIFO_1
		port map(
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => opri,
			data => in_priority,
			wrreq => wrenc,
			rdreq => hi and incountdone and not outcountdone, -- transmit enable clock 1
			rdempty => empty_priority,
			wrfull => full_priority
		);
		
	inbuff_stop: FIFO_1
		port map(
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => lastm,
			data => incountdone,
			wrreq => wrend,
			rdreq => hi and incountdone and not lastm, -- transmit enable
			rdempty => empty_stop,
			wrfull => full_stop
		);
end arch;
