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

entity mm_streaming_subtract is

generic (
    addr_width : integer := 32;
    data_width : integer := 16;
    memory_length : integer := 4096
);

port (
    aclk    : std_logic := '0';
    arstn   : std_logic := '0';

    value : std_logic_vector(data_width - 1 downto 0) := ( others => '0' );
    
    a_mm_addr : in std_logic_vector(addr_width-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(data_width-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';

    y_mm_addr : out std_logic_vector(addr_width-1 downto 0) := ( others => '0');
    y_mm_data : out std_logic_vector(data_width-1 downto 0) := ( others => '0');
    y_mm_wren : out std_logic := '0'
);

end mm_streaming_subtract;

architecture impl of mm_streaming_subtract is

    type memory_type is array(integer range<>) of std_logic_vector(y_mm_data'length - 1 downto 0);
    signal memory : memory_type(0 to memory_length) := ( others => ( others => '0' ));
    signal memory_index : std_logic_vector(integer(log2(real(memory_length))) downto 0) := ( others => '0' );

    signal a_mm_addr_d0 : std_logic_vector(y_mm_addr'length - 1 downto 0);
    signal a_mm_wren_d0 : std_logic;

begin

    process(aclk)
    begin
        if (arstn = '0') then
            memory <= ( others => ( others => '0' ));
        else

            if (a_mm_wren = '1') then
                y_mm_addr <= a_mm_addr;
                y_mm_wren <= a_mm_wren;
                y_mm_data <= std_logic_vector(signed(a_mm_data) + signed(value));
            end if;

        end if;
    end process;

end impl;
