library verilog;
use verilog.vl_types.all;
entity xmitTop is
    port(
        f_hi_priority   : in     vl_logic;
        f_rec_data_valid: in     vl_logic;
        f_data_in       : in     vl_logic_vector(7 downto 0);
        f_ctrl_in       : in     vl_logic_vector(24 downto 0);
        clk_sys         : in     vl_logic;
        clk_phy         : in     vl_logic;
        phy_data_out    : out    vl_logic_vector(3 downto 0);
        m_discard_en    : out    vl_logic;
        m_discard_frame : out    vl_logic_vector(7 downto 0);
        m_frame         : out    vl_logic_vector(7 downto 0);
        m_tx_done       : out    vl_logic;
        reset           : in     vl_logic
    );
end xmitTop;
