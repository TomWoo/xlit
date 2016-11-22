LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity inBuffer is 
	port(
	sysclk: in std_logic;
	phyclk: in std_logic;
	aclr: in std_logic;
	controli: in std_logic_vector(23 downto 0);
	wrend: in std_logic; --data write enable;
	wrenc: in std_logic; --ctrl write enable;
	datai: in std_logic_vector(7 downto 0);
	datao: out std_logic_vector(7 downto 0);
	controlo: out std_logic_vector(23 downto 0)
	);
end inBuffer;
	
architecture arch of inBuffer is
	signal hi: std_logic := '1';
	signal emptyd, emptyc: std_logic;
	signal fulld, fullc: std_logic;
	signal incountdone: std_logic:='0';
	signal outcountdone: std_logic:='0';
	signal datam: std_logic_vector (7 downto 0);
	signal ctrlm: std_logic_vector (23 downto 0);
	signal readen: std_logic;
	signal outtrans: std_logic:='0';
	signal canout: std_logic;
	
	component inbuff 
		port (aclr		: IN STD_LOGIC;
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
		port(	aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	END component;
	
begin 
	PROCESS (sysclk, controli, wrenc) --incounter
			VARIABLE   cnt         : INTEGER:=4095;
			VARIABLE   direction    : INTEGER:=-1;
	BEGIN		
		IF (sysclk'EVENT AND sysclk = '1') THEN
			if (wrenc = '1') then
				cnt := to_integer(unsigned(controli(11 downto 0)));
			else
				if (cnt>0) then
					cnt := cnt + direction;
				end if;
			end if;
		END IF;
		if (cnt <= 1) then
			incountdone <= '1';
		else 
			incountdone <= '0';
		end if;
	END PROCESS;

	PROCESS (phyclk, ctrlm, outcountdone) --outcounter
			VARIABLE   cnt         : INTEGER:=4095;
			VARIABLE   direction    : INTEGER:=-1;
	BEGIN	
		IF (phyclk'EVENT AND phyclk = '1') THEN
			if (outcountdone = '1' or (incountdone = '1' and outtrans = '0')) then
				cnt := to_integer(unsigned(ctrlm(11 downto 0)));
			else
				if (cnt>0) then
					cnt := cnt + direction;
				end if;
			end if;
		END IF;
		if (cnt <= 1) then
			outcountdone <= '1';
			outtrans <= '0';
		else 
			outcountdone <= '0';
			outtrans <= '1';
		end if;
	END PROCESS;
	
	process(phyclk, emptyd, outcountdone) --ctrlout
	begin
		if (phyclk'event AND phyclk = '1') then
			controlo <= ctrlm;
		end if;
	end process;
	
	process(phyclk, emptyd) --dataout always outputs data from the buffer
	begin
		if (phyclk'event AND phyclk = '1') then
			datao <= datam;
		end if;
	end process;
	
	inbuff_comp : inbuff
		port map (
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk and outtrans,
			q => datam,
			data => datai,
			wrreq => wrend,
			rdreq => hi,
			rdempty => emptyd,
			wrfull => fulld
			);
			
	inbuffcon_comp: inbuffcon
		port map(
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk and outtrans,
			q => ctrlm,
			data => controli,
			wrreq => wrenc,
			rdreq => hi,
			rdempty => emptyc,
			wrfull => fullc
		);
		
end arch;
