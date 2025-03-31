library ieee;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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

    type memory_type is array(integer range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal memory : memory_type(0 to MEMORY_LENGTH-1) := (
        x"00003246",
        x"000034b9",
        x"000025ec",
        x"0000295c",
        x"00003e4a",
        x"00001d94",
        x"00003b2a",
        x"0000014d",
        x"00001ba1",
        x"00002d82",
        x"00000487",
        x"00001983",
        x"000031f2",
        x"0000094b",
        x"00000e1e",
        x"00003994"
    );

    signal addr : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal data : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

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