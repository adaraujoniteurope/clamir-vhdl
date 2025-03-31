library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity mm_axis_bridge is
    generic
    (
        DATA_FRAME_LENGTH   : integer := 4096;
        DATA_USER_LENGTH    : integer := 44;

        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        port_a_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_a_wren : in std_logic := '0';
        port_a_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

        axis_out_tdata  : out std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0) := (others => '0' );
        axis_out_tvalid : out std_logic := '0';
        axis_out_tuser  : out std_logic := '0';
        axis_out_tready : in  std_logic := '0'

    );

  end mm_axis_bridge;
  
  architecture impl of mm_axis_bridge is

    constant AXIS_TDATA_WIDTH : integer := ADDR_WIDTH+DATA_WIDTH;
  begin

    process(aclk, arstn) begin

        if (arstn = '0') then

            axis_out_tvalid <= '0';
            axis_out_tdata <= (others => '0');

        else

        if (rising_edge(aclk)) then
            
            axis_out_tvalid <= port_a_wren;
            axis_out_tdata <= port_a_addr & port_a_data;

            if (port_a_addr < DATA_FRAME_LENGTH) then
                axis_out_tuser <= '0';
            elsif (port_a_wren = '1') then
                axis_out_tuser <= '1';
            end if;

        end if;
            
        end if;
    end process;

  end impl;