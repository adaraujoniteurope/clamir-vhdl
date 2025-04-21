-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : moment_track_timer
-- Description : Clock cycles counter
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity moment_track_timer is
  port (
    clk       : in  std_logic;
    rstn      : in  std_logic;
    enable    : in  std_logic;
    ticks_max : in  std_logic_vector(47 downto 0); 
    timeout   : out std_logic
  );
end moment_track_timer;

architecture behavioral of moment_track_timer is

  signal running   : std_logic;
  signal enable_d  : std_logic;
  signal ticks     : unsigned(47 downto 0);
  signal ticks_lim : unsigned(47 downto 0);

begin

  p_ctl : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        enable_d <= '0';
        running  <= '0';
      else
        -- Enable flag rising edge detection
        enable_d <= enable;
        -- Track counter running using timer
        if ((enable = '1') and (enable_d = '0')) then
          running <= '1';
        elsif ((enable = '0') and (enable_d = '1')) then
          running <= '0';
        end if;
      end if;
    end if;
  end process;

  p_run : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        ticks     <= (others => '0');
        ticks_lim <= (others => '1');
      else
        if (running = '1') then
          if (ticks = 0) then
            ticks_lim <= unsigned(ticks_max)-1;
          end if;

          if (ticks = ticks_lim) then
            ticks <= (others => '0');
          else
            ticks <= ticks + 1;
          end if;
        else
          ticks <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  timeout <= '1' when (ticks = ticks_lim) else '0';

end behavioral;