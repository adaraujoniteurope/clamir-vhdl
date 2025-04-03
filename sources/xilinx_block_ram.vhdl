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
        port_a_rst : in std_logic := '0';
        port_a_ena : in std_logic := '0';
        port_a_wea : in std_logic_vector(data_width/8-1 downto 0) := ( others => '0');
        port_a_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        port_a_din : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        port_a_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

        port_b_clk : in std_logic := '0';
        port_b_rst : in std_logic := '0';
        port_b_ena : in std_logic := '0';
        port_b_wea : in std_logic_vector(data_width/8-1 downto 0) := ( others => '0');
        port_b_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        port_b_din : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        port_b_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0')

    );

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO of port_a_clk: SIGNAL is "xilinx.com:interface:bram:1.0 port_a CLK";
    ATTRIBUTE X_INTERFACE_INFO of port_a_addr: SIGNAL is "xilinx.com:interface:bram:1.0 port_a ADDR";
    ATTRIBUTE X_INTERFACE_INFO of port_a_rst: SIGNAL is "xilinx.com:interface:bram:1.0 port_a RST";
    ATTRIBUTE X_INTERFACE_INFO of port_a_wea: SIGNAL is "xilinx.com:interface:bram:1.0 port_a WE";
    ATTRIBUTE X_INTERFACE_INFO of port_a_ena: SIGNAL is "xilinx.com:interface:bram:1.0 port_a EN";
    ATTRIBUTE X_INTERFACE_INFO of port_a_din: SIGNAL is "xilinx.com:interface:bram:1.0 port_a DIN";
    ATTRIBUTE X_INTERFACE_INFO of port_a_dout: SIGNAL is "xilinx.com:interface:bram:1.0 port_a DOUT";

    ATTRIBUTE X_INTERFACE_INFO of port_b_clk: SIGNAL is "xilinx.com:interface:bram:1.0 port_b CLK";
    ATTRIBUTE X_INTERFACE_INFO of port_b_addr: SIGNAL is "xilinx.com:interface:bram:1.0 port_b ADDR";
    ATTRIBUTE X_INTERFACE_INFO of port_b_rst: SIGNAL is "xilinx.com:interface:bram:1.0 port_b RST";
    ATTRIBUTE X_INTERFACE_INFO of port_b_wea: SIGNAL is "xilinx.com:interface:bram:1.0 port_b WE";
    ATTRIBUTE X_INTERFACE_INFO of port_b_ena: SIGNAL is "xilinx.com:interface:bram:1.0 port_b EN";
    ATTRIBUTE X_INTERFACE_INFO of port_b_din: SIGNAL is "xilinx.com:interface:bram:1.0 port_b DIN";
    ATTRIBUTE X_INTERFACE_INFO of port_b_dout: SIGNAL is "xilinx.com:interface:bram:1.0 port_b DOUT";

end xilinx_block_ram;

architecture rtl of xilinx_block_ram is

    signal memory : memory_8b_type(0 to MEMORY_LENGTH - 1) := init_ram_from_file(MEMORY_INITIALIZATION_FILE, MEMORY_LENGTH);

    signal port_a_addr_limited : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal port_b_addr_limited : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');

begin

    port_a_addr_limited <= port_a_addr when unsigned(port_a_addr) < MEMORY_LENGTH else
        port_a_addr_limited;
    port_b_addr_limited <= port_b_addr when unsigned(port_b_addr) < MEMORY_LENGTH else
        port_b_addr_limited;

    port_a_process : process (port_a_clk) begin
        if (port_a_clk'event and port_a_clk = '1') then

            if (port_a_ena = '1') then

                port_a_dout <= memory(to_integer(unsigned(port_a_addr_limited)) + 0)
                            & memory(to_integer(unsigned(port_a_addr_limited)) + 1)
                            & memory(to_integer(unsigned(port_a_addr_limited)) + 2)
                            & memory(to_integer(unsigned(port_a_addr_limited)) + 3);

                if (port_a_wea(0) = '1' and port_b_wea(0) = '0') then
                    memory(to_integer(unsigned(port_a_addr_limited)) + 0) <= port_a_din(31 downto 24);
                end if;

                if (port_a_wea(1) = '1' and port_b_wea(1) = '0') then
                    memory(to_integer(unsigned(port_a_addr_limited)) + 1) <= port_a_din(23 downto 16);
                end if;

                if (port_a_wea(2) = '1' and port_b_wea(2) = '0') then
                    memory(to_integer(unsigned(port_a_addr_limited)) + 2) <= port_a_din(15 downto 8);
                end if;

                if (port_a_wea(3) = '1' and port_b_wea(3) = '0') then
                    memory(to_integer(unsigned(port_a_addr_limited)) + 3) <= port_a_din(7 downto 0);
                end if;

            end if;
        end if;
    end process;

    port_b_process : process (port_b_clk) begin
        if (port_b_clk'event and port_b_clk = '1') then

            if (port_b_ena = '1') then

                port_b_dout <= memory(to_integer(unsigned(port_b_addr_limited)) + 0)
                            & memory(to_integer(unsigned(port_b_addr_limited)) + 1)
                            & memory(to_integer(unsigned(port_b_addr_limited)) + 2)
                            & memory(to_integer(unsigned(port_b_addr_limited)) + 3);

                if (port_b_wea(0) = '0' and port_b_wea(0) = '1') then
                    memory(to_integer(unsigned(port_b_addr_limited)) + 0) <= port_b_din(31 downto 24);
                end if;

                if (port_b_wea(1) = '0' and port_b_wea(0) = '1') then
                    memory(to_integer(unsigned(port_b_addr_limited)) + 1) <= port_b_din(23 downto 16);
                end if;

                if (port_b_wea(2) = '0' and port_b_wea(0) = '1') then
                    memory(to_integer(unsigned(port_b_addr_limited)) + 2) <= port_b_din(15 downto 8);
                end if;

                if (port_b_wea(3) = '0' and port_b_wea(0) = '1') then
                    memory(to_integer(unsigned(port_b_addr_limited)) + 3) <= port_b_din(7 downto 0);
                end if;

            end if;
        end if;
    end process;

end rtl;