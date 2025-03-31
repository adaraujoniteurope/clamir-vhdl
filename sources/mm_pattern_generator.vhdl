library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.io.all;

use std.textio.all;

ENTITY mm_pattern_generator IS
    generic (
        MEMORY_LENGTH : integer := 16;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        DEFAULT_VALUE : integer := 0
    );

    port (

        aclk : in std_logic := '0';
        arstn : in std_logic := '0';

        port_b_addr : inout std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        port_b_wren : inout std_logic := '0';
        port_b_data : inout std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0')

    );
end mm_pattern_generator;

architecture rtl of mm_pattern_generator is

    signal memory : memory_32b_type(0 to MEMORY_LENGTH-1) := init_ram_from_file("coefficients/pattern.txt", MEMORY_LENGTH);

    signal addr : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal data : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal counter : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

begin

    process(aclk, arstn) begin
        
        if (arstn = '0') then
            port_b_wren <= '0';
            port_b_data <= (others => '0');
        else
            if (rising_edge(aclk)) then

                if (addr < MEMORY_LENGTH) then
                    addr <= addr + 1;
                    port_b_addr <= addr;
                    port_b_data <= memory(to_integer(unsigned(addr)));
                    port_b_wren <= '1';
                else
                    addr <= (others => '0');
                    port_b_addr <= (others => '0');
                    port_b_data <= (others => '0');
                    port_b_wren <= '0';
                end if;

            end if;

        end if;

    end process;

end rtl;