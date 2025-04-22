----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 04/02/2025 05:47:44 pm
-- design name: 
-- module name: mm_split - impl
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

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity mm_split is
generic (
    FRAME_LENGTH : integer := 4096;
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32
);
port (

    aclk : in std_logic := '0';
    arstn : in std_logic := '0';

    y0_mm_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    y0_mm_data : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    y0_mm_wren : out std_logic := '0';
    
    y1_mm_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    y1_mm_data : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    y1_mm_wren : out std_logic := '0';

    a_mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0'
);
end mm_split;

architecture impl of mm_split is
begin

process(aclk) begin
    if (rising_edge(aclk)) then
        if (arstn = '0') then
        y0_mm_addr <= a_mm_addr;
            y0_mm_addr <= (others => '0');
            y0_mm_data <= (others => '0');
            y0_mm_wren <= '0';
            
            y1_mm_addr <= (others => '0');
            y1_mm_data <= (others => '0');
            y1_mm_wren <= '0';
        else
            y0_mm_addr <= a_mm_addr;
            y0_mm_data <= a_mm_data;
            y0_mm_wren <= a_mm_wren;
            
            y1_mm_addr <= a_mm_addr;
            y1_mm_data <= a_mm_data;
            y1_mm_wren <= a_mm_wren;
        end if;
    end if;
end process;

end impl;
