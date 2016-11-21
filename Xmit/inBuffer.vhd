LIBRARY ieee;
USE ieee.std_logic_1164.all;

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


	inbuff_comp : inbuff
		port map (
			aclr => aclr,
			wrclk => sysclk,
			rdclk => phyclk,
			q => datao,
			data => datai,
			wrreq => wrend,
			rdreq => hi,
			rdempty => empty,
			wrfull => full
			);

end arch;
