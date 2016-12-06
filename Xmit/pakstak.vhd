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
	type st_type is (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z);
	signal ncurrst, currst, nin, nout: st_type;
	signal inon, outon, inonl, outonl: std_logic;
	
begin 
	process (currst)
	begin
		ncurrst <= currst;
	end process;
	
	-- incountdone  next state and assert bit
	process (incountdone, currst, inonl)
	begin
		if (incountdone = '1' and inonl = '0') then
			inon <= '1';
			case currst is
				when a =>
					nin <= b;
				when b =>
					nin <= c;
				when c =>
					nin <= d;
				when d =>
					nin <= e;
				when e =>
					nin <= f;
				when f =>
					nin <= g;
				when g =>
					nin <= h;
				when h =>
					nin <= i;
				when i =>
					nin <= j;
				when j =>
					nin <= k;
				when k =>
					nin <= l;
				when l =>
					nin <= m;
				when m =>
					nin <= n;
				when n =>
					nin <= o;
				when o =>
					nin <= p;
				when p =>
					nin <= q;
				when q =>
					nin <= r;
				when r =>
					nin <= s;
				when s =>
					nin <= t;
				when t =>
					nin <= u;
				when u =>
					nin <= v;
				when v =>
					nin <= w;
				when w =>
					nin <= x;
				when x =>
					nin <= y;
				when y =>
					nin <= z;
				when z =>
					nin <= z;
			end case;
		elsif (incountdone = '1' and inonl = '1') then
			nin <= currst;
			inon <= '1';
		else
			inon <= '0';
			nin <= currst;
		end if;
	end process;
	
	-- outcountdone next state and assert bit
	process (outcountdone, currst, outonl)
	begin
		if (outcountdone = '1' and outonl = '0') then
			outon <= '1';
			case currst is
				when a =>
					nout <= a;
				when b =>
					nout <= a;
				when c =>
					nout <= b;
				when d =>
					nout <= c;
				when e =>
					nout <= d;
				when f =>
					nout <= e;
				when g =>
					nout <= f;
				when h =>
					nout <= g;
				when i =>
					nout <= h;
				when j =>
					nout <= i;
				when k =>
					nout <= j;
				when l =>
					nout <= k;
				when m =>
					nout <= l;
				when n =>
					nout <= m;
				when o =>
					nout <= n;
				when p =>
					nout <= o;
				when q =>
					nout <= p;
				when r =>
					nout <= q;
				when s =>
					nout <= r;
				when t =>
					nout <= s;
				when u =>
					nout <= t;
				when v =>
					nout <= u;
				when w =>
					nout <= v;
				when x =>
					nout <= w;
				when y =>
					nout <= x;
				when z =>
					nout <= y;
			end case;
		elsif (outcountdone = '1' and outonl = '1') then
			nout <= currst;
			outon <= '1';
		else
			outon <= '0';
			nout <= currst;
		end if;
	end process;
	
	-- clock
	-- if incount done assert bit then inc nextstate
	-- if outcountdone assert bit then ouc nextstate
	-- if both, do nothing, if none do nothing
	process(outon, inon, nout, nin, phyclk, aclr, outonl, inonl) 
	begin
		if (aclr = '1') then
			currst <= a;
		elsif (phyclk'event and phyclk = '1') then
			if (inon = '1' and outon = '1' and inonl = '0' and outonl = '0') then
				currst <= ncurrst; -- no state change
			elsif (inon = '1' and inonl = '0') then
				currst <= nin;
			elsif (outon = '1' and outonl = '0') then
				currst <= nout;
			else
				currst <= ncurrst;
			end if;
			inonl <= inon;
			outonl <= outon;
		end if;
	end process;
	
	process(currst)
	begin
		case currst is
			when a => 
				pakavail <= '0';
			when others =>
				pakavail <= '1';
		end case;
	end process;
end arch;




--process(curr)
--	begin
--		if (curr = "000000") then
--			pakavail <= '0';
--		else 
--			pakavail <= '1';
--		end if;
--	end process;
--	
--	process(curr, inc, ouc, aclr, phyclk)
--	begin
--		if (aclr = '1') then
--			curr <= "000000";
--		elsif (phyclk'event and phyclk = '1') then
--			curr <= curr - inc + ouc;
--		end if;
--	end process;
--	
--	process(incountdone, outcountdone, parityi, parityo)
--	begin
--		if (incountdone = '1') then 
--			if (parityi = '0') then
--				inc <= "000001";
--				parityi <= '1';
--			else 
--				inc <= "000000";
--				parityi <= '1';
--			end if;
--		else 
--			inc <= "000000";
--			parityi <= '1';
--		end if;
--		if (outcountdone = '1') then
--			if (parityo = '0') then 
--				ouc <= "000001";
--				parityo <= '1';
--			else 
--				ouc <= "000000";
--				parityo <= '1';
--			end if;
--		else 
--			ouc <= "000000";
--			parityo <= '0';
--		end if;
--	end process;