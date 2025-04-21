-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : tb_track_cnt
-- Description : Test current track calculation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.clamir_pkg.all;

entity tb_track_cnt is
end tb_track_cnt;

architecture behavioral of tb_track_cnt is

  signal clk            : std_logic := '0';
  signal rstn           : std_logic := '0';

  signal mom_cnt        : unsigned(15 downto 0) := (others => '0');
  signal change_mode    : std_logic := '0';
  signal trk_mode       : std_logic_vector( 1 downto 0) := (others => '0');
  signal mom_00_i       : std_logic_vector(31 downto 0) := (others => '0');
  signal mom_thrs       : std_logic_vector(31 downto 0) := (others => '0');
  signal time_cnt       : std_logic_vector(47 downto 0) := (others => '0');
  signal tracks         : std_logic_vector(31 downto 0) := (others => '0');
  signal tracks_old     : std_logic_vector(31 downto 0) := (others => '0');

begin

  -- Generate clock
  clk <= not(clk) after CLK_PERIOD_2;

  -- Generate reset (active low)
  rstn <= '0', '1' after 250 ns;
  
  time_cnt <= std_logic_vector(to_unsigned(500, 48));
  mom_thrs <= x"0000" & std_logic_vector(to_unsigned(255, 16));

  p_mom : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        mom_cnt <= (others => '0');
      else
        mom_cnt <= mom_cnt + 1;
      end if;
    end if;
  end process;

  mom_00_i <= x"0000" & std_logic_vector(mom_cnt);

  p_mode : process
  begin
    wait for 1 ms;
    change_mode <= '1';
    trk_mode    <= "01";
    wait for CLK_PERIOD;
    change_mode <= '0';
    wait for 1 ms;
    change_mode <= '1';
    trk_mode    <= "00";
    wait for CLK_PERIOD;
    change_mode <= '0';
    wait;
  end process;

  trk_cnt_inst : entity work.moment_track_count
    port map (
      clk         => clk,
      rstn        => rstn,
      mode        => trk_mode, 
      change_mode => change_mode,
      time_cnt    => time_cnt,
      moment_00   => mom_00_i,
      threshold   => mom_thrs,
      tracks      => tracks
    );

end behavioral;