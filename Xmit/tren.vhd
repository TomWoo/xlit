library ieee;
use ieee.std_logic_1164.all;

entity tren is 
	port( pakavail: 	in std_logic;
			aclr: 		in std_logic;
			phyclk:		in std_logic;
			txen:			out std_logic;
			txone:		out std_logic;
			stop:			in std_logic	-- must come on last cycle of real data.
	);
end tren;

architecture arch of tren is
	type statety is (a, b, c); -- a is no transmit b is transmitting first cycle c is transmitting not first cycle
	signal curr, ncurr: statety;

begin
	-- determine next state
	process (curr, pakavail, stop)
	begin
		if (stop = '1') then
			ncurr <= a;
		else
			if (curr = a) then
				if (pakavail = '1') then
					ncurr <= b;
				else
					ncurr <= a;
				end if;
			elsif (curr = b) then
				ncurr <= c;
			else
				ncurr <= c;
			end if;
		end if;
	end process;
	
	-- clock next state
	process (phyclk, aclr)
	begin
		if (aclr = '1') then 
			curr <= a;
		elsif (phyclk'event and phyclk = '1') then
			curr <= ncurr;
		end if;
	end process;
	
	-- output txen based on state
	process (curr)
	begin
		case curr is
			when a =>
				txen <= '0';
				txone <= '0';
			when b => 
				txen <= '1';
				txone <= '1';
			when c =>
				txen <= '1';
				txone <= '0';
		end case;
	end process;
end arch;