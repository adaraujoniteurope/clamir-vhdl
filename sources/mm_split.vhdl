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
    addr_out : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    write_out : out std_logic := '0';

    mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    mm_wren : in std_logic := '0'
);
end mm_split;

architecture impl of mm_split is

begin

addr_out <= mm_addr;
data_out <= mm_data;
write_out <= mm_wren;

end impl;
