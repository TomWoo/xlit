LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY xmt_tb0 IS
	PORT (	Clock		: IN		STD_LOGIC;
			Reset		: IN		STD_LOGIC;
            test_start	: IN	    STD_LOGIC;
            start_out	: OUT		STD_LOGIC;
            ctlblk_out  : out       std_logic_vector(23 downto 0);
            data_out    : out	    std_logic_vector(7 downto 0);
            ctlblk_en   : out       std_logic;
            data_en     : out       std_logic;
				hi_priority	: out			std_logic
			);			

END xmt_tb0;

ARCHITECTURE test_bench_simple OF xmt_tb0 IS
	


component tbrom8a1
	PORT
	(
        aclr        : in STD_LOGIC;
        address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;


component count12bit
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		cnt_en		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
end component;

component shift2
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		shiftin		: IN STD_LOGIC ;
		shiftout		: OUT STD_LOGIC 
	);
end component;


	
	TYPE State_type IS (resetz,wait4start,run,done);
	SIGNAL y_current, y_next			: State_type;	
	SIGNAL crc_enable, crc_init			: STD_LOGIC;
    signal data_enable_x : std_logic;    -- for delay by 2
	SIGNAL crc_input					: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL count_enable	: STD_LOGIC;
	SIGNAL mem_out		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL count_val	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL crc_result	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	CONSTANT check_val	: STD_LOGIC_VECTOR(31 DOWNTO 0) := "11000111000001001101110101111011";
    constant  count_len : std_logic_vector(11 downto 0) := "000001000100";
    constant ctlblk : std_logic_vector(23 downto 0) := "000000000000000001000100";
    


BEGIN

-- instantiate the components and map the ports

delayby2 : shift2 PORT MAP (
		aclr	 => Reset,
		clock	 => Clock,
		shiftin	 => data_enable_x,
		shiftout	 => data_en
	);


  

crc_test_mem : tbrom8a1 PORT MAP (
		address	 => count_val,
        aclr => Reset,
		clock	 => Clock,
		q	 => mem_out
	);

cntr12bit : count12bit PORT MAP (
		aclr	 => Reset,
		clock	 => Clock,
		cnt_en	 => count_enable,
		q	 => count_val
	);



-- state update 
	PROCESS(Reset,Clock)
	BEGIN
		IF Reset = '1' THEN y_current <= resetz;
		ELSIF Clock'EVENT AND Clock = '1' THEN
			y_current <= y_next;
		END IF;
	END PROCESS;

-- logic for next_state and output
	PROCESS(y_current,count_val,test_start)
	BEGIN
		count_enable <= '0';
		start_out <= '0';
        ctlblk_en <= '0';
        data_enable_x <= '0';
		  hi_priority <= '0';


		CASE y_current IS
			WHEN resetz =>
              y_next <= wait4start;
            when wait4start =>
              y_next <= wait4start;
              if test_start = '1' then
                y_next <= run;
                start_out <= '1';
                count_enable <= '1';    -- Mealy output
              end if;
            WHEN run =>
			  count_enable <= '1';
              data_enable_x <= '1';
				  hi_priority <= '1';
              if count_val = "000000000010" then
                ctlblk_en <= '1';
              end if;
			  IF count_val = count_len THEN 
					y_next <= done;
                    count_enable <= '0';
				ELSE y_next <= run;
			END IF;			
			WHEN done =>
			  y_next <= done;
              data_enable_x <= '0';
				  hi_priority <= '0';

		END CASE;
	END PROCESS;
	

	data_out <= mem_out;
    ctlblk_out <= ctlblk;


END test_bench_simple;






