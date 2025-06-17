library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.streaming_algorithm.all;
use work.memory_mapped_streaming.all;
use work.memory.all;

entity mm_drift_tb is

  generic (
    addr_width     : integer := 32;
    data_width     : integer := 16;
    frame_length   : integer := 16;
    histogram_bins : integer := 20
  );

end mm_drift_tb;

architecture impl of mm_drift_tb is

  signal aclk  : std_logic := '0';
  signal arstn : std_logic := '0';

  signal a_mm_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal a_mm_data : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal a_mm_wren : std_logic;

  signal drift_level : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal drift_value : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal intr : std_logic;

begin

  aclk  <= not aclk after 10 ns;
  arstn <= '1' after 10 ns;

  process (aclk) begin
    if (rising_edge(aclk)) then
        if (arstn = '0') then
        else

            if ((a_mm_addr + 1) < (frame_length * data_width/8)) then

                a_mm_addr <= a_mm_addr + data_width/8;
                a_mm_data <= a_mm_addr;
                a_mm_wren <= '1';

            else
            
                a_mm_addr <= ( others => '0' );
                a_mm_data <= ( others => '0' );
                a_mm_wren <= '0';

            end if;

        end if;
    end if;
  end process;

  mm_drift_inst0 : mm_drift

  generic map(
    addr_width     => addr_width,
    data_width     => data_width,
    frame_length   => frame_length,
    histogram_bins => histogram_bins
  )

  port map
  (

    aclk  => aclk,
    arstn => arstn,

    a_mm_addr => a_mm_addr,
    a_mm_wren => a_mm_wren,
    a_mm_data => a_mm_data,

    drift_level => drift_level,
    drift_value => drift_value,

    intr => intr

  );

end impl;
