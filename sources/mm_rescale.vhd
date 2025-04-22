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
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity mm_rescale is
generic
(
    ADDR_WIDTH : integer := 32;
    DATA_IN_WIDTH : integer := 32;
    DATA_OUT_WIDTH : integer := 16
);
port (
    aclk : std_logic := '0';
    arstn : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    a_mm_data : in std_logic_vector(DATA_IN_WIDTH - 1 downto 0) := ( others => '0');
    
    y_mm_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0) := ( others => '0');
    y_mm_wren : out std_logic := '0';
    y_mm_data : out std_logic_vector(DATA_OUT_WIDTH - 1 downto 0) := ( others => '0')
);
end mm_rescale;

architecture impl of mm_rescale is
begin

process(aclk) begin

    if (arstn = '0') then
        y_mm_addr <= ( others => '0' );
        y_mm_data <= ( others => '0' );
        y_mm_wren <= '0';
    else
        y_mm_addr <= std_logic_vector(resize(unsigned(a_mm_addr), y_mm_addr'length));
        y_mm_data <= std_logic_vector(resize(signed(a_mm_data), y_mm_data'length));
        y_mm_wren <= a_mm_wren;
    end if;
    
end process;

end impl;
