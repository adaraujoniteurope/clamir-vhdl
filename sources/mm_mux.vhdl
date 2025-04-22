----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 04/03/2025 10:22:35 am
-- design name: 
-- module name: mm_mux - impl
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
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity mm_mux is
generic
(
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32
);
port (
    aclk : std_logic := '0';
    arstn : std_logic := '0';
    sel : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    a_mm_data : in std_logic_vector(DATA_WIDTH - 1 downto 0) := ( others => '0');

    b_mm_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := ( others => '0');
    b_mm_wren : in std_logic := '0';
    b_mm_data : in std_logic_vector(DATA_WIDTH - 1 downto 0) := ( others => '0');
    
    y0_mm_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0) := ( others => '0');
    y0_mm_wren : out std_logic := '0';
    y0_mm_data : out std_logic_vector(DATA_WIDTH - 1 downto 0) := ( others => '0')

);
end mm_mux;

architecture impl of mm_mux is

begin

sel_process: process(aclk) begin

    if (aclk'event and aclk = '1') then
        if (arstn = '0') then
            y0_mm_addr <= (others => '0');
            y0_mm_wren <= '0';
            y0_mm_data <= (others => '0');
        else
            case(sel) is
            when '0' =>
                y0_mm_addr <= a_mm_addr;
                y0_mm_wren <= a_mm_wren;
                y0_mm_data <= a_mm_data;
            when '1' =>
                y0_mm_addr <= b_mm_addr;
                y0_mm_wren <= b_mm_wren;
                y0_mm_data <= b_mm_data;
            when others =>
                y0_mm_addr <= a_mm_addr;
                y0_mm_wren <= a_mm_wren;
                y0_mm_data <= a_mm_data;
            end case;
        end if;
    end if;

end process;

end impl;
