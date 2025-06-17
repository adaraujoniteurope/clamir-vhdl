-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : clamir_pkg
-- Description : NIT Processing block common utilities package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package memory is
  component dual_port_sram is
    generic (
      addr_width : integer := 32;
      data_width : integer := 16;
      ram_length : integer := 1024
    );
    port (
      clka  : in std_logic;
      ena   : in std_logic;
      wea   : in std_logic_vector(data_width/8-1 downto 0);
      addra : in std_logic_vector(addr_width-1 downto 0);
      dia   : in std_logic_vector(data_width-1 downto 0);
      doa   : out std_logic_vector(data_width-1 downto 0);

      clkb  : in std_logic;
      enb   : in std_logic;
      web   : in std_logic_vector(data_width/8-1 downto 0);
      addrb : in std_logic_vector(addr_width-1 downto 0);
      dib   : in std_logic_vector(data_width-1 downto 0);
      dob   : out std_logic_vector(data_width-1 downto 0)
    );
  end component;

end package;