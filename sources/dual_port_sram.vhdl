-- dual-port block ram with two write ports
-- correct modelization with a shared variable
-- file: rams_tdp_rf_rf.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity dual_port_sram is

  generic (
    addr_width : integer := 32;
    data_width : integer := 16;
    ram_length : integer := 1024
  );

  port (
    clka  : in std_logic;
    ena   : in std_logic;
    wea   : in std_logic_vector(data_width/8 - 1 downto 0);
    addra : in std_logic_vector(addr_width - 1 downto 0);
    dia   : in std_logic_vector(data_width - 1 downto 0);
    doa   : out std_logic_vector(data_width - 1 downto 0);

    clkb  : in std_logic;
    enb   : in std_logic;
    web   : in std_logic_vector(data_width/8 - 1 downto 0);
    addrb : in std_logic_vector(addr_width - 1 downto 0);
    dib   : in std_logic_vector(data_width - 1 downto 0);
    dob   : out std_logic_vector(data_width - 1 downto 0)
  );

end dual_port_sram;

architecture syn of dual_port_sram is
  type memory_type is array (ram_length - 1 downto 0) of std_logic_vector(data_width - 1 downto 0);
  shared variable memory : memory_type := ( others => std_logic_vector(to_unsigned(0, data_width)));

  -- attribute ram_style        : string;
  -- attribute ram_style of ram : signal is "block";

function print_ram_input(
  addr : std_logic_vector;
  di   : std_logic_vector;
  i     : integer
) return string is
begin
  return
    "addr: " & integer'image(to_integer(unsigned(addr))) &
    " (" & integer'image(8 * i + 7) & " downto " & integer'image(8 * i) & ")" &
    " value: " & integer'image(to_integer(unsigned(di(8 * i + 7 downto 8 * i))));
end function;


begin
  process (clka)
  begin
    if rising_edge(clka) then
      if ena = '1' then
        doa <= memory(to_integer(unsigned(addra)));
        -- Byte-masked write
        for i in 0 to integer(data_width/8) - 1 loop
          if wea(i) = '1' then
              report "port_a: " & print_ram_input(addra, dia, i);
              memory(to_integer(unsigned(addra)))(8 * i + 7 downto 8 * i) := dia(8 * i + 7 downto 8 * i);
          end if;
        end loop;

      end if;
    end if;
  end process;

  process (clkb)
  begin
    if rising_edge(clkb) then
      if enb = '1' then
        dob <= memory(to_integer(unsigned(addrb)));
        -- Byte-masked write
        for i in 0 to integer(data_width/8) - 1 loop
          if web(i) = '1' then
            report "port_b: " & print_ram_input(addrb, dib, i);
            memory(to_integer(unsigned(addrb)))(8 * i + 7 downto 8 * i) := dib(8 * i + 7 downto 8 * i);
          end if;
        end loop;
      end if;
    end if;
  end process;

end syn;