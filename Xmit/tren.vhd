library ieee;
use ieee.std_logic_1164.all;

entity tren is 
	port( pakavail: 	in std_logic;
			aclr: 		in std_logic;
			phyclk:		in std_logic;
			txen:			out std_logic;
			stop:			in std_logic;
	);
end tren;

architecture arch of tren is
	type statety is (a, b, c); -- a is no transmit b is transmitting first cycle c is transmitting not first cycle
	signal curr, ncurr: statety;

begin
	-- determine next state
	process (curr, pakavail)
	-- clock next state
	
end arch;