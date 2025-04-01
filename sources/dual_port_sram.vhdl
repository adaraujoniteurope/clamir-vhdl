library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;
use work.memory_types.all;

entity dual_port_sram is
    generic
    (
        memory_length  : integer := 4096;
        addr_width : integer := 32;
        data_width : integer := 32;
        default_value : integer := 0
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        port_a_addr : in std_logic_vector(addr_width-1 downto 0) := ( others => '0' );
        port_a_wren : in std_logic := '0';
        port_a_data_in  : in std_logic_vector(data_width-1 downto 0) := ( others => '0' );
        port_a_data_out : out std_logic_vector(data_width-1 downto 0) := ( others => '0' );

        port_b_addr : in std_logic_vector(addr_width-1 downto 0) := ( others => '0' );
        port_b_wren : in std_logic := '0';
        port_b_data_in  : in std_logic_vector(data_width-1 downto 0) := ( others => '0' );
        port_b_data_out : out std_logic_vector(data_width-1 downto 0) := ( others => '0' )

    );
  end dual_port_sram;
  
  architecture rtl of dual_port_sram is
    
    signal memory : memory_32b_type(memory_length - 1 downto 0) := (others => std_logic_vector(to_unsigned(default_value, data_width)));

    signal port_a_data : std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal port_b_data : std_logic_vector(data_width-1 downto 0) := (others => '0');
    
  begin
    
    port_a_process: process(aclk, arstn) begin
        if (arstn = '0') then
            port_a_data_out <= (others => '0');
        else
            if (rising_edge(aclk)) then
                port_a_data_out <= memory(to_integer(unsigned(port_a_addr)));
                if (port_a_wren = '1') then
                    memory(to_integer(unsigned(port_a_addr))) <= port_a_data_in;
                end if;
            end if;
        end if;
    end process;

    port_b_process: process(aclk, arstn) begin
        if (arstn = '0') then
            port_b_data_out <= (others => '0');
        else
            if (rising_edge(aclk)) then
                port_b_data_out <= memory(to_integer(unsigned(port_b_addr)));
                if (port_b_wren = '1') then
                    memory(to_integer(unsigned(port_b_addr))) <= port_b_data_in;
                end if;
            end if;
        end if;
    end process;

  end rtl;