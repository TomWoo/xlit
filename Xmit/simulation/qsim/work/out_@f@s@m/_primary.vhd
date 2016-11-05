library verilog;
use verilog.vl_types.all;
entity out_FSM is
    port(
        clk_phy         : in     vl_logic;
        reset           : in     vl_logic;
        data_in         : in     vl_logic_vector(7 downto 0);
        ctrl_block_in   : in     vl_logic_vector(23 downto 0);
        frame_seq_out   : out    vl_logic_vector(11 downto 0);
        xmit_done_out   : out    vl_logic;
        data_out        : out    vl_logic_vector(3 downto 0)
    );
end out_FSM;
