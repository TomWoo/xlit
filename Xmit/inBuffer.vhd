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
	controlo: out std_logic_vector(7 downto 0)
	);
end inBuffer;
	
architecture arch of inBuffer is
	signal hi: std_logic := '1';
	signal empty: std_logic;
	signal full: std_logic;
	signal incountdone: std_logic;
	signal outcountdone: std_logic;
	

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
	
begin 

	PROCESS (sysclk, controli, wrenc, outcountdone) --incounter
			VARIABLE   cnt         : INTEGER RANGE 0 TO 4096;
			VARIABLE   direction    : INTEGER:=-1;
	BEGIN
			
		IF (sysclk'EVENT AND sysclk = '1') THEN
			if (wrenc = '1') then
				cnt := to_integer(unsigned(controli));
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

	inbuff_comp : inbuff
		port map (
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => datao,
			data => datai,
			wrreq => wrend,
			rdreq => outcountdone,
			rdempty => empty,
			wrfull => full
			);

end arch;
