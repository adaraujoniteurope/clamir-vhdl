library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.memory_types.all;

entity mm_linear_correction is
    generic (
        FRAME_LENGTH : integer := 4096;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk : in std_logic := '0';
        arstn : in std_logic := '0';

        scale_bram_clk : out std_logic := '0';
        scale_bram_rst : out std_logic := '0';
        scale_bram_ena : out std_logic := '1';
        scale_bram_wea : out std_logic_vector(DATA_WIDTH/8 - 1 downto 0) := (others => '0');
        scale_bram_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        scale_bram_din : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        scale_bram_dout : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

        offset_bram_clk : out std_logic := '0';
        offset_bram_rst : out std_logic := '0';
        offset_bram_ena : out std_logic := '1';
        offset_bram_wea : out std_logic_vector(DATA_WIDTH/8 - 1 downto 0) := (others => '0');
        offset_bram_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        offset_bram_din : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        offset_bram_dout : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

        a_mm_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        a_mm_wren : in std_logic := '0';
        a_mm_data : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

        y_mm_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        y_mm_wren : out std_logic := '0';
        y_mm_data : out std_logic_vector((2*DATA_WIDTH)-1 downto 0) := (others => '0')
    );

    attribute x_interface_info : string;

    attribute x_interface_info of scale_bram_clk : signal is "xilinx.com:interface:bram:1.0 scale_bram clk";
    attribute x_interface_info of scale_bram_addr : signal is "xilinx.com:interface:bram:1.0 scale_bram addr";
    attribute x_interface_info of scale_bram_rst : signal is "xilinx.com:interface:bram:1.0 scale_bram rst";
    attribute x_interface_info of scale_bram_wea : signal is "xilinx.com:interface:bram:1.0 scale_bram we";
    attribute x_interface_info of scale_bram_ena : signal is "xilinx.com:interface:bram:1.0 scale_bram en";
    attribute x_interface_info of scale_bram_din : signal is "xilinx.com:interface:bram:1.0 scale_bram din";
    attribute x_interface_info of scale_bram_dout : signal is "xilinx.com:interface:bram:1.0 scale_bram dout";

    attribute x_interface_info of offset_bram_clk : signal is "xilinx.com:interface:bram:1.0 offset_bram clk";
    attribute x_interface_info of offset_bram_addr : signal is "xilinx.com:interface:bram:1.0 offset_bram addr";
    attribute x_interface_info of offset_bram_rst : signal is "xilinx.com:interface:bram:1.0 offset_bram rst";
    attribute x_interface_info of offset_bram_wea : signal is "xilinx.com:interface:bram:1.0 offset_bram we";
    attribute x_interface_info of offset_bram_ena : signal is "xilinx.com:interface:bram:1.0 offset_bram en";
    attribute x_interface_info of offset_bram_din : signal is "xilinx.com:interface:bram:1.0 offset_bram din";
    attribute x_interface_info of offset_bram_dout : signal is "xilinx.com:interface:bram:1.0 offset_bram dout";

end mm_linear_correction;

architecture rtl of mm_linear_correction is
    -- attribute x_interface_info of aclk: signal is "xilinx.com:signal:clock:1.0 aclk clk";
    -- attribute x_interface_info of arstn: signal is "xilinx.com:signal:reset:1.0 arstn rst";



    signal result : signed(2*a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal a_mm_wren_d0 : std_logic := '0';
    signal a_mm_wren_d1 : std_logic := '0';
    signal a_mm_wren_d2 : std_logic := '0';
    
    signal a_mm_addr_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_addr_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_addr_d2 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal a_mm_data_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_data_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_data_d2 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal scale_bram_dout_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal scale_bram_dout_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal offset_bram_dout_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal offset_bram_dout_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal y_mm_data_pre0 : std_logic_vector(y_mm_data'length-1 downto 0) := ( others => '0' );

begin

    scale_bram_clk <= aclk;
    scale_bram_rst <= '0';
    scale_bram_ena <= '1';
    scale_bram_wea <= ( others => '0' );
    
    offset_bram_clk <= aclk;
    offset_bram_rst <= '0';
    offset_bram_ena <= '1';
    offset_bram_wea <= ( others => '0' );
    
    
    process(aclk) begin
    if (rising_edge(aclk)) then
    if (arstn = '0') then
        
            a_mm_addr_d0 <= ( others => '0' );
            a_mm_addr_d1 <= ( others => '0' );
            a_mm_addr_d2 <= ( others => '0' );
            
            a_mm_data_d0 <= ( others => '0' );
            a_mm_data_d1 <= ( others => '0' );
            a_mm_data_d2 <= ( others => '0' );
            
            a_mm_wren_d0 <= '0';
            a_mm_wren_d1 <= '0';
            a_mm_wren_d2 <= '0';
            
            y_mm_addr <= ( others => '0' );
            y_mm_data <= ( others => '0' );
            y_mm_wren <= '0';
            
            
        else
        
            scale_bram_addr <= a_mm_addr( a_mm_addr'length-3 downto 0) & "00";
            offset_bram_addr <= a_mm_addr( a_mm_addr'length-3 downto 0) & "00";
        
            a_mm_addr_d0 <= a_mm_addr;
            a_mm_addr_d1 <= a_mm_addr_d0;
            a_mm_addr_d2 <= a_mm_addr_d1;
            
            a_mm_wren_d0 <= a_mm_wren;
            a_mm_wren_d1 <= a_mm_wren_d0;
            a_mm_wren_d2 <= a_mm_wren_d1;
            
            a_mm_data_d0 <= a_mm_data;
            a_mm_data_d1 <= a_mm_data_d0;
            a_mm_data_d2 <= a_mm_data_d1;
            
            offset_bram_dout_d0 <= offset_bram_dout;
            offset_bram_dout_d1 <= offset_bram_dout_d0;
            
            y_mm_addr <= a_mm_addr_d1;
            y_mm_wren <= a_mm_wren_d1;
            
            scale_bram_dout_d0 <= scale_bram_dout;
            scale_bram_dout_d1 <= scale_bram_dout_d0;
            
            if (unsigned(a_mm_addr_d1) < FRAME_LENGTH) then
                y_mm_data_pre0 <= std_logic_vector(signed(scale_bram_dout_d0) * signed(a_mm_data_d0));
                y_mm_data <= std_logic_vector(shift_right(signed(y_mm_data_pre0), 14) + signed(offset_bram_dout_d1));
            else
                y_mm_data <= std_logic_vector(resize(signed(a_mm_data_d1), y_mm_data'length));
            end if;
            
        end if;
        
    end if;
    end process;

end rtl;