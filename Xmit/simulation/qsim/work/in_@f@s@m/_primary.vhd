library verilog;
use verilog.vl_types.all;
entity in_FSM is
    port(
        in_frame        : in     vl_logic_vector(7 downto 0);
        in_priority     : in     vl_logic;
        in_low_overflow : in     vl_logic;
        in_hi_overflow  : in     vl_logic;
        in_f_rdv        : in     vl_logic;
        out_m_discard_en: out    vl_logic;
        out_frame       : out    vl_logic_vector(7 downto 0);
        out_wren        : out    vl_logic;
        out_priority    : out    vl_logic;
        clk_sys         : in     vl_logic;
        reset           : in     vl_logic
    );
end in_FSM;
