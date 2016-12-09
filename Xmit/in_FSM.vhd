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
	numusedhi:				in std_logic_vector(10 downto 0);
	numusedlo: 				in std_logic_vector(10 downto 0)
--	db_ctrlm:				out std_logic_vector(23 downto 0);
--	db_last:					out std_logic;
--	db_lastl:				out std_logic;
--	db_stopint:				out std_logic
--	db_lastm:				out std_logic;
--	db_txen:					out std_logic;
--	db_txone:				out std_logic;
--	db_pakavail: 			out std_logic;
--	db_cnti:					out unsigned(11 downto 0)
	
);
end in_FSM;

architecture arch of in_FSM is
--	type numstate is (start_state, frame_state, end_state);
	signal aclr:				std_logic;
	signal sysclk: 			std_logic;
	signal phyclk:				std_logic;
		
	signal hi: std_logic := '1';
	signal emptyd, emptyc, empty_priority, empty_stop: std_logic;
	signal fulld, fullc, full_priority, full_stop: std_logic;
	signal incountdone: std_logic:='0';
	signal outcountdone: std_logic:='0';
	signal datam: std_logic_vector (7 downto 0);
	signal ctrlm: std_logic_vector (23 downto 0);
	signal cnti: unsigned(11 downto 0);
	signal cntit: unsigned(11 downto 0);
	signal last, lastl: std_logic;
	signal lastm: std_logic;
	signal opri: std_logic;
	signal dissig, wrensig, stopl: std_logic;
	signal dir: unsigned(11 downto 0) := "000000000001";
	signal transen: std_logic := '1';
	signal txen, txone, pakavails, txen2, stopint: std_logic;
	
	component discard_logic is
		port(
			num_used_hi:	in std_logic_vector(10 downto 0);
			num_used_lo:	in std_logic_vector(10 downto 0);
			discard_en:		out std_logic;
			wren:				out std_logic;
			priority:		in std_logic;
			frame_len:		in std_logic_vector(11 downto 0)
		);
	end component;
	
	component pakstak
		port(
			incountdone: 	in std_logic;
			outcountdone: 	in std_logic;
			pakavail:		out std_logic;
			aclr: 			in std_logic;
			phyclk: 			in std_logic
		);
	end component;
	
	component tren
		port(
			pakavail: 	in std_logic;
			aclr: 		in std_logic;
			phyclk:		in std_logic;
			txen:			out std_logic;
			txone:		out std_logic;
			stop:			in std_logic
		);
	end component;
	
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
		port(
			aclr		: IN STD_LOGIC;
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
		port(
			aclr		: IN STD_LOGIC;
			data		: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	END component;
	
begin

--	process(clk_sys, reset, ctrl_ctrl_prev, in_ctrl_ctrl) begin
--		if(reset = '1') then
--			ctrl_ctrl_prev <= '0';
--		elsif(rising_edge(clk_sys)) then
--			ctrl_ctrl_prev <= in_ctrl_ctrl;
--		else
--			ctrl_ctrl_prev <= ctrl_ctrl_prev;
--		end if;
--	end process;
--	
--	process(clk_sys, reset)
--	begin
--		if(reset = '1') then
--			out_m_discard_en <= '0';	
--			--out_wren <= '0';	
--		elsif(clk_sys'event and clk_sys='1') then
--			if ((in_lo_overflow = '1' and in_priority='0') or (in_hi_overflow='1' and in_priority='1')) then
--				--out_wren <= '0';
--				out_m_discard_en <= in_ctrl_ctrl;
--			else
--				--out_wren <= in_ctrl_ctrl;
--				out_m_discard_en <= '0';
--			end if;
--		else
--			out_m_discard_en <= out_m_discard_en;
--			--out_wren <= out_wren;
--		end if;
--		
--		--out_priority<=in_priority;
--	end process;
	
	---------------- buffer logic ----------------
	
	process(reset, clk_sys, clk_phy, ctrlm, incountdone, outcountdone, last, lastm, txen, txone, pakavails) begin
		aclr <= reset;
		sysclk <= clk_sys;
		phyclk <= clk_phy;
--		db_ctrlm <= ctrlm;
--		db_last <= last;
--		db_lastl <= lastl;
--		db_stopint <= stopint;
--		db_txen <= txen;
--		db_txone <= txone;
--		db_pakavail <= pakavails;
--		db_cnti <= cnti;
		dir <="000000000001";
	end process;
	
	PROCESS (sysclk, controli, wrenc, aclr, cnti, cntit, last, lastl) --incounter	
	BEGIN		
		if(aclr = '1') then
--			cnti <= "111111111111";
			cntit <="111111111111";
--			incountdone <= '0';
			last <='0';
			lastl <= '0';
		elsif (sysclk'EVENT AND sysclk = '1') THEN
			if (wrenc = '1') then
--				cnti <= (unsigned(controli(11 downto 0)))-dir; -- SOMETHING HERE IS BREAKING TRIES TO ASSIGN 00F TO FF0
				cntit <= (unsigned(controli(11 downto 0)));
			else
--				if (to_integer(cnti)>2) then
--					cnti <= cnti - dir;
--				end if;
				if (to_integer(cntit)>2) then
					cntit <= cntit -dir;
					lastl <= '0';
				else 
					if ((last = '1' and lastl = '0') or lastl = '1') then
						lastl <= '1';
					else
						lastl <= '0';
					end if;
				end if;
			end if;
--			if (to_integer(cntit) <= 2) then
--				
--			else 
--				
--			end if;
		END IF;
--		if (to_integer(cnti) <= 2) then
--			incountdone <= '1';
--		else 
--			incountdone <= '0';
--		end if;
		if (to_integer(cntit) <= 2) then
			if (lastl = '0') then
				last <= '1';
			else
				last <= '0';
			end if;
		else 
			last <= '0';
		end if;
	END PROCESS;
	
	process(lastm, stopl, stopint)
	begin
		if (lastm = '1' and stopl = '0') then 
			stopint <= '0';
		elsif(lastm = '1' and stopl = '1') then 
			stopint <= '1';
		else 
			stopint <= '0';
		end if;
	end process;

--	PROCESS (phyclk, ctrlm, aclr, cnto, firsttrans) --outcounter
--	BEGIN	
--		if (aclr = '1') then
--			cnto <= "111111111111";
--			outcountdone <= '0'; 
--			firsttrans <= '0';
--		elsif (phyclk'EVENT AND phyclk = '1') THEN
--			if (txen = '0' and pakavails = '1') then -- if transmit enable
--				cnto <= not (unsigned(ctrlm(11 downto 0)));	-- SOMETHING HERE IS ALSO BREAKING
--				firsttrans <='1';
--			else
--				if (to_integer(cnto)>1) then
--					cnto <= cnto + dir;
--				end if;
--			end if;
--		END IF;
--		if (to_integer(cnto) <= 1 and firsttrans = '1') then
--			outcountdone <= '1';
--		else 
--			outcountdone <= '0';
--		end if;
--	END PROCESS;
	
	
	process(phyclk, emptyd, aclr, txone) --ctrlout
	begin
		if(aclr = '1') then
			out_priority <= '0';
			controlo <= "000000000000000000000000";
		elsif (phyclk'event AND phyclk = '1') then
--			if (stopl = '1') then
--				out_priority <= '0';
--				controlo <= "000000000000000000000000";
--			else
				controlo <= ctrlm;
				out_priority <= opri;
--			end if;
		end if;
	end process;
	
	process(phyclk, emptyd, aclr) --dataout always outputs data from the buffer
	begin
		if (aclr = '1') then
			datao <= "00000000";
			stop <= '0';
			out_wren <= '0';
			out_m_discard_en <= '0';
		elsif (phyclk'event AND phyclk = '1') then
			datao <= datam;
			out_wren <= wrensig and txen2 and not stopint;
			txen2 <= txen;
			out_m_discard_en <= dissig and txen2 and not stopint;
			stop <= lastm;
			stopl <= lastm;
		end if;
	end process;
	
	dislog: 	discard_logic
		port map (
		num_used_hi => numusedhi,
		num_used_lo => numusedlo,
		discard_en => dissig,
		wren => wrensig,
		priority => opri,
		frame_len => ctrlm(11 downto 0)
		);
	
	inbuff_comp : inbuff
		port map (
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => datam,
			data => datai,
			wrreq => wrend,
			rdreq => hi and txen, -- transmit enable
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
			rdreq => hi and txone, -- transmit enable clock 1
			rdempty => emptyc,
			wrfull => fullc
		);
		
	inbuff_priority: FIFO_1
		port map(
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q(0) => opri,
			data(0) => in_priority,
			wrreq => wrenc,
			rdreq => hi and txone, -- transmit enable clock 1
			rdempty => empty_priority,
			wrfull => full_priority
		);
		
	inbuff_stop: FIFO_1
		port map(
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q(0) => lastm,
			data(0) => last and not lastl,
			wrreq => wrend,
			rdreq => hi and txen, -- transmit enable
			rdempty => empty_stop,
			wrfull => full_stop
		);
		
	packetstack: pakstak
		port map(
			aclr => aclr,
			incountdone => last,
			outcountdone => lastm,
			phyclk => phyclk,
			pakavail => pakavails
		);
		 
	transmitenable: tren
		port map(
			pakavail => pakavails,
			aclr => aclr,
			phyclk => phyclk,
			txen => txen,
			txone => txone,
			stop => lastm
		);
end arch;
