-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : clamir_pkg
-- Description : NIT Processing block common utilities package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package memory_mapped_streaming is

  component mm_memory_reader is

    generic (
      addr_width   : integer := 32;
      data_width   : integer := 16;
      frame_length : integer := 4
    );

    port (

      aclk  : in std_logic := '0';
      arstn : in std_logic := '0';

      ap_start : in std_logic := '0';

      a_bram_clk  : out std_logic                                   := '0';
      a_bram_rst  : out std_logic                                   := '0';
      a_bram_en   : out std_logic                                   := '1';
      a_bram_we   : out std_logic_vector(data_width/8 - 1 downto 0) := (others => '0');
      a_bram_addr : out std_logic_vector(addr_width - 1 downto 0)   := (others => '0');
      a_bram_din  : out std_logic_vector(data_width - 1 downto 0)   := (others => '0');
      a_bram_dout : in std_logic_vector(data_width - 1 downto 0)    := (others => '0');

      y_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
      y_mm_wren : out std_logic                                 := '0';
      y_mm_data : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

      intr : out std_logic := '0'
    );

  end component;

end package;