library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity pakstak is -- phy-synchronous architecture for determining whether packet is available in fifos. DEPENDENT ON DELAY?
	port(	incountdone: 	in std_logic;
			outcountdone: 	in std_logic;
			pakavail:		out std_logic;
			aclr: 			in std_logic;
			phyclk: 			in std_logic
	);
end pakstak;

architecture arch of pakstak is
	signal curr, inc, ouc: std_logic_vector(5 downto 0);
	signal parityi, parityo: std_logic;
	type st_type is (a,b,c,d,e,f,g,h,i,j);
	signal currst: st_type;
	
begin 
	process(curr)
	begin
		if (curr = "000000") then
			pakavail <= '0';
		else 
			pakavail <= '1';
		end if;
	end process;
	
	process(curr, inc, ouc, aclr, phyclk)
	begin
		if (aclr = '1') then
			curr <= "000000";
		elsif (phyclk'event and phyclk = '1') then
			curr <= curr - inc + ouc;
		end if;
	end process;
	
	process(incountdone, outcountdone, parityi, parityo)
	begin
		if (incountdone = '1') then 
			if (parityi = '0') then
				inc <= "000001";
				parityi <= '1';
			else 
				inc <= "000000";
				parityi <= '1';
			end if;
		else 
			inc <= "000000";
			parityi <= '1';
		end if;
		if (outcountdone = '1') then
			if (parityo = '0') then 
				ouc <= "000001";
				parityo <= '1';
			else 
				ouc <= "000000";
				parityo <= '1';
			end if;
		else 
			ouc <= "000000";
			parityo <= '0';
		end if;
	end process;
end arch;