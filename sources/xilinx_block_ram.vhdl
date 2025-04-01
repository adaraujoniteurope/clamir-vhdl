library ieee;
library work;
library std;

use std.textio.all;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_types.all;

entity xilinx_block_ram is
    generic (
        MEMORY_LENGTH : integer := 4096;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        MEMORY_INITIALIZATION_FILE : string
    );

    port (

        port_a_clk : in std_logic := '0';
        port_a_ena : in std_logic := '0';
        port_a_wea : in std_logic := '0';
        port_a_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        port_a_data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        port_a_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

        port_b_clk : in std_logic := '0';
        port_b_ena : in std_logic := '0';
        port_b_wea : in std_logic := '0';
        port_b_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        port_b_data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        port_b_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0')

    );
end xilinx_block_ram;

architecture rtl of xilinx_block_ram is

    signal memory : memory_32b_type(0 to MEMORY_LENGTH - 1) := init_ram_from_file(MEMORY_INITIALIZATION_FILE, MEMORY_LENGTH);

    signal port_a_addr_limited : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal port_b_addr_limited : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');

begin

    port_a_addr_limited <= port_a_addr when unsigned(port_a_addr) < MEMORY_LENGTH else
        port_a_addr_limited;
    port_b_addr_limited <= port_b_addr when unsigned(port_b_addr) < MEMORY_LENGTH else
        port_b_addr_limited;

    port_a_process : process (port_a_clk) begin
        if (port_a_ena = '1') then
            if (port_a_clk'event and port_a_clk = '1') then
                if (port_b_wea = '1') then
                    memory(to_integer(unsigned(port_a_addr_limited))) <= port_a_data_in;
                end if;

                port_a_data_out <= memory(to_integer(unsigned(port_a_addr_limited)));
            end if;
        end if;
    end process;

    port_b_process : process (port_b_clk) begin
        if (port_b_ena = '1') then
            if (port_b_clk'event and port_b_clk = '1') then
                if (port_b_wea = '1') then
                    memory(to_integer(unsigned(port_b_addr_limited))) <= port_b_data_in;
                end if;
                port_b_data_out <= memory(to_integer(unsigned(port_b_addr_limited)));
            end if;
        end if;
    end process;

end rtl;