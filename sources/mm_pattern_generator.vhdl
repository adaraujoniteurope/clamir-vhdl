library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use std.textio.all;
use work.memory_types.all;

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

        out_addr : inout std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        out_wren : inout std_logic := '0';
        out_data : inout std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0')

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
            out_wren <= '0';
            out_data <= (others => '0');
        else
            if (rising_edge(aclk)) then

                if (addr < MEMORY_LENGTH) then
                    addr <= addr + 1;
                    out_addr <= addr;
                    out_data <= memory(to_integer(unsigned(addr)));
                    out_wren <= '1';
                else
                    addr <= (others => '0');
                    out_addr <= (others => '0');
                    out_data <= (others => '0');
                    out_wren <= '0';
                end if;

            end if;

        end if;

    end process;

end rtl;