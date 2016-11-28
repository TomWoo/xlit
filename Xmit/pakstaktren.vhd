library ieee;
use ieee.std_logic_1164.all;

entity pakstaktren is 
	port (
			incountdone: 	in std_logic;
			outcountdone: 	in std_logic;
			aclr: 			in std_logic;
			phyclk: 			in std_logic;
			txen:			out std_logic;
			txone:		out std_logic;
			stop:			in std_logic
			);
end pakstaktren;

architecture arch of pakstaktren is
	signal pakavails: std_logic;
	
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
	
begin

	packetstack: pakstak
		port map(
			aclr => aclr,
			incountdone => incountdone,
			outcountdone => outcountdone,
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
			stop => stop
		);
end arch;