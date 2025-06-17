----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 06/09/2025 12:37:58 pm
-- design name: 
-- module name: mm_drift - impl
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.memory_types.all;

entity mm_drift is

  generic (
    addr_width     : integer := 32;
    data_width     : integer := 16;
    frame_length   : integer := 4;
    histogram_bins : integer := 20
  );

  port (

    aclk  : in std_logic := '0';
    arstn : in std_logic := '0';

    a_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := (others => '0');
    a_mm_wren : in std_logic                                 := '0';
    a_mm_data : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
    
    drift_level : in std_logic_vector(data_width - 1 downto 0)  := (others => '0');
    drift_value : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

    intr : out std_logic := '0'

  );

end mm_drift;

architecture impl of mm_drift is

  type memory_type is array(integer range <>) of std_logic_vector(2 * data_width - 1 downto 0);

  signal histogram_memory : memory_type(0 to histogram_bins - 1) := (others => (others => '0'));
  signal a_mm_wren_last : std_logic := '0';

begin

  process (aclk) begin

    if (rising_edge(aclk)) then

      if (arstn = '0') then

        for i in 0 to histogram_bins - 1 loop
          histogram_memory(i) <= (others => '0');
        end loop;

      else

        a_mm_wren_last <= a_mm_wren;

        if (a_mm_wren = '1') then

          for i in 0 to histogram_bins - 1 loop

            if to_integer(signed(a_mm_data)) > i * 16384/histogram_bins and to_integer(signed(a_mm_data)) < (i + 1) * 16384/histogram_bins then
              histogram_memory(i) <= std_logic_vector(signed(histogram_memory(i)) + signed(a_mm_data));
            end if;

          end loop;

        end if;

        if ((a_mm_wren xor a_mm_wren_last) = '1' and a_mm_wren = '0') then
          if (to_integer(signed(drift_level)) > histogram_bins - 1) then
            drift_value <= std_logic_vector(signed(histogram_memory(to_integer(signed(drift_level)))) / histogram_bins);
          else
            drift_value <= std_logic_vector(signed(histogram_memory(0)) / histogram_bins);
          end if;
          
          intr <= '1';
        else
          intr <= '0';
        end if;

      end if;

    end if;

  end process;

end impl;
