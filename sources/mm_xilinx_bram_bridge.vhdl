library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity mm_xilinx_bram_bridge is
    generic
    (
        DATA_FRAME_LENGTH   : integer := 4096;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        in_mm_addr : in std_logic_vector(addr_width-1 downto 0) := ( others => '0' );
        in_mm_wren : in std_logic := '0';
        in_mm_data : in std_logic_vector(data_width-1 downto 0) := ( others => '0' );

        out_bram_clk : out std_logic := '0';
        out_bram_ena : out std_logic := '0';
        out_bram_wea : out std_logic := '0';
        out_bram_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
        out_bram_data_in : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
        out_bram_data_out : out std_logic_vector(data_width - 1 downto 0) := (others => '0')

    );

  end mm_xilinx_bram_bridge;
  
  architecture impl of mm_xilinx_bram_bridge is
  begin

    out_bram_clk <= aclk when in_mm_wren = '1' and arstn = '1' else '0';

    process(aclk, arstn) begin
        if (arstn = '0') then
        else

            if(aclk'event and aclk = '1') then

                if (in_mm_wren = '1') then
                    out_bram_addr <= in_mm_addr;
                end if;

            end if;

            if(aclk'event and aclk = '0') then
                
                if (in_mm_wren = '1') then
                    out_bram_data_out <= in_mm_data;
                end if;

            end if;

        end if;
    end process;

  end impl;