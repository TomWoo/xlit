library ieee;
use ieee.std_logic_1164.all;
entity input_buffer is			
	port(
			sys_clk, phy_clk:	in std_logic;
			reset:				in std_logic;
			data_in:				in std_logic_vector (7 downto 0);
			ctrl_in:				in std_logic_vector (24 downto 0);
			ctrl_write_in:		in std_logic;
			data_out:			out std_logic_vector (7 downto 0);
			ctrl_out:			out std_logic_vector (24 downto 0);
			ctrl_write_out:	out std_logic);
end input_buffer;

architecture buffered of input_buffer is
	signal data_next: std_logic_vector (7 downto 0); 
	signal ctrl_next: std_logic_vector (24 downto 0);
	signal ctrl_write_next: std_logic;
	
	
begin
	process(phy_clk, reset)
	begin
		if (reset='1') then 
			data_out<=(others=>'0');
			ctrl_out<=(others=>'0');
			ctrl_write_out<='0';
		elsif (phy_clk'event and phy_clk='1') then
			data_out<=data_next;
			ctrl_out<=ctrl_next;
			ctrl_write_out<=ctrl_write_next;
		end if;
	end process;

	process(sys_clk, data_in, ctrl_in, ctrl_write_in)
	begin
		if (sys_clk'event and sys_clk='1') then
			data_next<=data_in;
			ctrl_next<=ctrl_in;
			ctrl_write_next<=ctrl_write_in;
		end if;
	end process;
	
end buffered;