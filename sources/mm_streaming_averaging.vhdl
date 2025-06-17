----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 04/16/2025 12:21:10 pm
-- design name: 
-- module name: mm_video_averaging_filter - impl
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity mm_streaming_averaging is

generic (
    addr_width : integer := 32;
    data_width : integer := 32;
    memory_length : integer := 4096;

    -- this will use the nearest log2 base integer (ceiling)
    -- that is if 10, floor(log2(10)) = 3, 2^3=8
    -- the divider is actually 2^(floor(log2(divider)))
    divider : integer := 10
);

port (
    aclk    : std_logic := '0';
    arstn   : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(addr_width-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(data_width-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';

    y_mm_addr : out std_logic_vector(addr_width-1 downto 0) := ( others => '0');
    y_mm_data : out std_logic_vector(data_width-1 downto 0) := ( others => '0');
    y_mm_wren : out std_logic := '0';
    
    wr_bram_clk  : out std_logic                                     := '0';
    wr_bram_rst  : out std_logic                                     := '0';
    wr_bram_en   : out std_logic                                     := '1';
    wr_bram_we   : out std_logic_vector(data_width/8 - 1 downto 0)   := (others => '0');
    wr_bram_addr : out std_logic_vector(addr_width - 1 downto 0)     := (others => '0');
    wr_bram_din  : inout std_logic_vector(data_width - 1 downto 0)   := (others => '0');
    wr_bram_dout : in std_logic_vector(data_width - 1 downto 0)    := (others => '0');
    
    rd_bram_clk  : out std_logic                                     := '0';
    rd_bram_rst  : out std_logic                                     := '0';
    rd_bram_en   : out std_logic                                     := '1';
    rd_bram_we   : out std_logic_vector(data_width/8 - 1 downto 0)   := (others => '0');
    rd_bram_addr : out std_logic_vector(addr_width - 1 downto 0)     := (others => '0');
    rd_bram_din  : out std_logic_vector(data_width - 1 downto 0)   := (others => '0');
    rd_bram_dout : in std_logic_vector(data_width - 1 downto 0)    := (others => '0')
    
);

end mm_streaming_averaging;

architecture impl of mm_streaming_averaging is

    type memory_type is array(integer range<>) of std_logic_vector(y_mm_data'length - 1 downto 0);
    signal memory : memory_type(memory_length downto 0) := ( others => ( others => '0' ));
    signal memory_index : std_logic_vector(integer(log2(real(memory_length))) downto 0) := ( others => '0' );

    signal a_mm_addr_d0 : std_logic_vector(y_mm_addr'length - 1 downto 0);
    signal a_mm_wren_d0 : std_logic;
    
    signal pixel_average : std_logic_vector(y_mm_addr'length - 1 downto 0);

    attribute ramstyle : string;
    attribute ramstyle of memory : signal is "bram";
    
  attribute x_interface_info                : string;
  attribute x_interface_info of rd_bram_clk  : signal is "xilinx.com:interface:bram:1.0 read_bram clk";
  attribute x_interface_info of rd_bram_addr : signal is "xilinx.com:interface:bram:1.0 read_bram addr";
  attribute x_interface_info of rd_bram_rst  : signal is "xilinx.com:interface:bram:1.0 read_bram rst";
  attribute x_interface_info of rd_bram_we   : signal is "xilinx.com:interface:bram:1.0 read_bram we";
  attribute x_interface_info of rd_bram_en   : signal is "xilinx.com:interface:bram:1.0 read_bram en";
  attribute x_interface_info of rd_bram_din  : signal is "xilinx.com:interface:bram:1.0 read_bram din";
  attribute x_interface_info of rd_bram_dout : signal is "xilinx.com:interface:bram:1.0 read_bram dout";
  
  attribute x_interface_info of wr_bram_clk  : signal is "xilinx.com:interface:bram:1.0 write_bram clk";
  attribute x_interface_info of wr_bram_addr : signal is "xilinx.com:interface:bram:1.0 write_bram addr";
  attribute x_interface_info of wr_bram_rst  : signal is "xilinx.com:interface:bram:1.0 write_bram rst";
  attribute x_interface_info of wr_bram_we   : signal is "xilinx.com:interface:bram:1.0 write_bram we";
  attribute x_interface_info of wr_bram_en   : signal is "xilinx.com:interface:bram:1.0 write_bram en";
  attribute x_interface_info of wr_bram_din  : signal is "xilinx.com:interface:bram:1.0 write_bram din";
  attribute x_interface_info of wr_bram_dout : signal is "xilinx.com:interface:bram:1.0 write_bram dout";

begin

    wr_bram_clk <= aclk;
    wr_bram_rst <= not arstn;
    wr_bram_en <= '1';
    wr_bram_we <= ( others => '1' );
    wr_bram_addr <= a_mm_addr;
    
    rd_bram_clk <= aclk;
    rd_bram_rst <= not arstn;
    rd_bram_en <= '1';
    rd_bram_we  <= ( others => '0' );
    rd_bram_addr <= a_mm_addr;
    
    process(aclk)
    begin
        if (arstn = '0') then
            memory <= ( others => ( others => '0' ));
        else

            if (a_mm_wren = '0') then
                memory_index <= ( others => '0' );

            elsif(a_mm_wren = '1' and memory_index < memory_length) then

                a_mm_addr_d0 <= a_mm_addr;
                a_mm_wren_d0 <= a_mm_wren;
                
                wr_bram_din <=
                    std_logic_vector(resize(signed(rd_bram_dout) + shift_right(signed(a_mm_data) - signed(rd_bram_dout), integer(log2(real(divider)))), pixel_average'length));

                y_mm_addr <= a_mm_addr_d0;
                y_mm_data <= memory(to_integer(unsigned(memory_index)));
                y_mm_wren <= a_mm_wren_d0;

                memory_index <= memory_index + 1;
            else
                -- do nothing, maintain on hold until a_mm_wren goes down

            end if;

        end if;
    end process;

end impl;
