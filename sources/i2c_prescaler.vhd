library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity i2c_prescaler is
    port (
      clkin   : in std_logic;
      rst     : in std_logic;
      clkout  : out std_logic;
      clkout_threshold : in std_logic_vector(31 downto 0) := x"0000000A"
    );
  end i2c_prescaler;
  
  architecture rtl of i2c_prescaler is

    signal clkout_signal  : std_logic := '0';
    signal clkout_counter : std_logic_vector(31 downto 0) := x"00000000";
  begin

    clkout <= clkout_signal;

    process (clkin, rst)
    begin
    if (rising_edge(clkin)) then
        if (rst = '1') then
            clkout_counter <= x"00000000";
            clkout_signal <= '0';
        else
            if (clkout_counter = clkout_threshold) then
                clkout_counter <= x"00000000";
                clkout_signal <= not clkout_signal;
            else
                clkout_counter <= clkout_counter + 1;
            end if;
        end if;
    end if;
    end process;

  end rtl;