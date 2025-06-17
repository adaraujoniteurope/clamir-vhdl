library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package streaming_algorithm is

  component mm_drift is

    generic (
      addr_width     : integer := 32;
      data_width     : integer := 16;
      frame_length   : integer := 4;
      histogram_bins : integer := 16
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

  end component;
  
end package;