library IEEE;

use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_arith.all;
-- use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity dual_port_sram is
    generic
    (
        MEMORY_LENGTH  : integer := 4096;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        DEFAULT_VALUE : integer := 0
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        port_a_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_a_wren : in std_logic := '0';
        port_a_data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );
        port_a_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

        port_b_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_b_wren : in std_logic := '0';
        port_b_data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );
        port_b_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' )

    );
  end dual_port_sram;
  
  architecture rtl of dual_port_sram is

    type memory_type is array(integer range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal memory : memory_type(MEMORY_LENGTH - 1 downto 0) := (others => std_logic_vector(to_unsigned(DEFAULT_VALUE, DATA_WIDTH)));

    signal port_a_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal port_b_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    
  begin

    -- memory(to_integer(unsigned(port_a_addr))) <=
    --     port_a_data_in when port_a_wren = '1' and port_b_wren = '0'
    --     port_b_data_in when port_a_wren = '0' and port_b_wren = '1'
    --     else memory(to_integer(unsigned(port_a_addr)));

    -- port_a_data_out <=  when port_a_wren = '0' else port_a_data;

    -- port_b_data_out <= memory(to_integer(unsigned(port_b_addr))) when port_b_wren = '0' else port_b_data;

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