----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 04/16/2025 12:21:10 pm
-- design name: 
-- module name: mm_memory_writer - impl
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

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity mm_memory_writer is
generic (
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 16
);
port (
    aclk    : std_logic := '0';
    arstn   : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    
    intr : out std_logic := '0';
    
    bram_clk : out std_logic := '0';
    bram_rst : out std_logic := '0';
    bram_ena : out std_logic := '1';
    bram_wea : out std_logic_vector((2*DATA_WIDTH)/8 - 1 downto 0) := (others => '0');
    bram_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    bram_din : out std_logic_vector(2*DATA_WIDTH - 1 downto 0) := (others => '0');
    bram_dout : in std_logic_vector(2*DATA_WIDTH - 1 downto 0) := (others => '0')
    
);
end mm_memory_writer;

architecture impl of mm_memory_writer is
    attribute x_interface_info : string;

    attribute x_interface_info of bram_clk : signal is "xilinx.com:interface:bram:1.0 bram clk";
    attribute x_interface_info of bram_addr : signal is "xilinx.com:interface:bram:1.0 bram addr";
    attribute x_interface_info of bram_rst : signal is "xilinx.com:interface:bram:1.0 bram rst";
    attribute x_interface_info of bram_wea : signal is "xilinx.com:interface:bram:1.0 bram we";
    attribute x_interface_info of bram_ena : signal is "xilinx.com:interface:bram:1.0 bram en";
    attribute x_interface_info of bram_din : signal is "xilinx.com:interface:bram:1.0 bram din";
    attribute x_interface_info of bram_dout : signal is "xilinx.com:interface:bram:1.0 bram dout";
    
    signal a_mm_data_d0 : std_logic_vector(a_mm_data'length - 1 downto 0) := ( others => '0');
    signal bram_write_enable : std_logic := '0';
begin

bram_clk <= aclk;
bram_rst <= '0';
bram_ena <= '1';


process(aclk) begin
if (rising_edge(aclk)) then
    if (arstn = '0') then
        bram_addr <= ( others => '0' );
        bram_din <= ( others => '0' );
        bram_wea <= ( others => '0' );
    else
        if (a_mm_wren = '1') then
            a_mm_data_d0 <= a_mm_data; 
            bram_din <= a_mm_data & a_mm_data_d0;
            
            if (a_mm_addr(0) = '0') then
                bram_addr <= std_logic_vector(shift_left(unsigned(a_mm_addr), 1));
                bram_wea <= ( others => '0');
            else
                bram_wea <= ( others => '1');
            end if;
        end if;
    end if;
end if;
end process;

end impl;
