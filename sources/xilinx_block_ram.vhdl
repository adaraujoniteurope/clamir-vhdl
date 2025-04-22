library ieee;
library work;
library std;

use std.textio.all;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_types.all;

entity xilinx_block_ram is
    generic (
        memory_length : integer := 4096;
        addr_width : integer := 32;
        data_width : integer := 32;
        memory_initialization_file : string
    );

    port (

        port_a_clk : in std_logic := '0';
        port_a_rst : in std_logic := '0';
        port_a_ena : in std_logic := '0';
        port_a_wea : in std_logic_vector(data_width/8-1 downto 0) := ( others => '0');
        port_a_addr : in std_logic_vector(addr_width - 1 downto 0) := (others => '0');
        port_a_din : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
        port_a_dout : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

        port_b_clk : in std_logic := '0';
        port_b_rst : in std_logic := '0';
        port_b_ena : in std_logic := '0';
        port_b_wea : in std_logic_vector(data_width/8-1 downto 0) := ( others => '0');
        port_b_addr : in std_logic_vector(addr_width - 1 downto 0) := (others => '0');
        port_b_din : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
        port_b_dout : out std_logic_vector(data_width - 1 downto 0) := (others => '0')

    );

    attribute x_interface_info : string;

    attribute x_interface_info of port_a_clk: signal is "xilinx.com:interface:bram:1.0 port_a clk";
    attribute x_interface_info of port_a_addr: signal is "xilinx.com:interface:bram:1.0 port_a addr";
    attribute x_interface_info of port_a_rst: signal is "xilinx.com:interface:bram:1.0 port_a rst";
    attribute x_interface_info of port_a_wea: signal is "xilinx.com:interface:bram:1.0 port_a we";
    attribute x_interface_info of port_a_ena: signal is "xilinx.com:interface:bram:1.0 port_a en";
    attribute x_interface_info of port_a_din: signal is "xilinx.com:interface:bram:1.0 port_a din";
    attribute x_interface_info of port_a_dout: signal is "xilinx.com:interface:bram:1.0 port_a dout";

    attribute x_interface_info of port_b_clk: signal is "xilinx.com:interface:bram:1.0 port_b clk";
    attribute x_interface_info of port_b_addr: signal is "xilinx.com:interface:bram:1.0 port_b addr";
    attribute x_interface_info of port_b_rst: signal is "xilinx.com:interface:bram:1.0 port_b rst";
    attribute x_interface_info of port_b_wea: signal is "xilinx.com:interface:bram:1.0 port_b we";
    attribute x_interface_info of port_b_ena: signal is "xilinx.com:interface:bram:1.0 port_b en";
    attribute x_interface_info of port_b_din: signal is "xilinx.com:interface:bram:1.0 port_b din";
    attribute x_interface_info of port_b_dout: signal is "xilinx.com:interface:bram:1.0 port_b dout";

end xilinx_block_ram;

architecture rtl of xilinx_block_ram is

    signal memory : memory_8b_type(0 to memory_length - 1) := init_ram_from_file(memory_initialization_file, memory_length);

    signal port_a_addr_limited : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
    signal port_b_addr_limited : std_logic_vector(addr_width - 1 downto 0) := (others => '0');

begin

    port_a_addr_limited <= port_a_addr when unsigned(port_a_addr) < memory_length else
        port_a_addr_limited;
    port_b_addr_limited <= port_b_addr when unsigned(port_b_addr) < memory_length else
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