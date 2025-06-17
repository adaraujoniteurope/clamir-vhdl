library ieee;
use ieee.std_logic_1164.all;

package misc is

component moment_track_timer is
  port (
    clk       : in  std_logic;
    rstn      : in  std_logic;
    enable    : in  std_logic;
    ticks_max : in  std_logic_vector(47 downto 0); 
    timeout   : out std_logic
  );
end component;

end package;