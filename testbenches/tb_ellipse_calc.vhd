-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : tb_ellipse_calc
-- Description : Ellipse calculation testbench
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

library work;
use work.clamir_pkg.all;

entity tb_ellipse_calc is
end tb_ellipse_calc;

architecture behavioral of tb_ellipse_calc is


  signal clk  : std_logic := '0';
  signal rstn : std_logic := '0';

  signal mom00S, mom10S, mom01S : std_logic_vector(31 downto 0) := (others => '0');
  signal mom11S, mom20S, mom02S : std_logic_vector(31 downto 0) := (others => '0');

  signal lengthS, widthS : std_logic_vector(263 downto 0) := (others => '0');

  signal mom00R, mom10R, mom01R : real := 0.0;
  signal mom11R, mom20R, mom02R : real := 0.0;

  signal lengthR, widthR : real := 0.0;

begin

  -- Generate clock
  clk  <= not(clk) after CLK_PERIOD_2;

  -- Generate reset (active low)
  rstn <= '0', '1' after 250 ns;

  mom00S <= std_logic_vector(to_unsigned(2, mom00S'length));
  mom10S <= std_logic_vector(to_unsigned(2, mom10S'length));
  mom01S <= std_logic_vector(to_unsigned(2, mom01S'length));
  mom20S <= std_logic_vector(to_unsigned(4, mom20S'length));
  mom02S <= std_logic_vector(to_unsigned(4, mom02S'length));
  mom11S <= std_logic_vector(to_unsigned(4, mom11S'length));

  -- Ellipse calculation DUT
  dut : entity work.ellipse_calc
    port map (
      clk           => clk,
      rstn          => rstn,
      moment_00     => mom00S(11 downto 0),
      moment_01     => mom01S(16 downto 0),
      moment_10     => mom10S(16 downto 0),
      moment_11     => mom11S(22 downto 0),
      moment_02     => mom02S(22 downto 0),
      moment_20     => mom20S(22 downto 0),
      ellipse_width => open
    );

end behavioral;