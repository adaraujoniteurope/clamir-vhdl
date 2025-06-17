library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- use work.memory_types.all;

entity mm_linear_correction_add_constant is
  generic (
    FRAME_LENGTH        : integer := 4096;
    addr_width          : integer := 32;
    data_width          : integer := 32;
    subtract_offset     : boolean := false
  );

  port (

    aclk  : in std_logic := '0';
    arstn : in std_logic := '0';

    override : in std_logic                                 := '0';
    offset   : in std_logic_vector(data_width - 1 downto 0) := (others => '0');

    a_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := (others => '0');
    a_mm_wren : in std_logic                                 := '0';
    a_mm_data : in std_logic_vector(data_width - 1 downto 0) := (others => '0');

    y_mm_addr : out std_logic_vector(addr_width - 1 downto 0)       := (others => '0');
    y_mm_wren : out std_logic                                       := '0';
    y_mm_data : out std_logic_vector(data_width downto 0) := (others => '0')
  );

end mm_linear_correction_add_constant;

architecture rtl of mm_linear_correction_add_constant is

  signal result : signed(2 * a_mm_data'length - 1 downto 0) := (others => '0');

begin

  process (aclk) begin
    if (rising_edge(aclk)) then
      if (arstn = '0') then

        y_mm_addr <= (others => '0');
        y_mm_data <= (others => '0');
        y_mm_wren <= '0';
      else

        y_mm_addr <= a_mm_addr;

        if (override = '1') then

          y_mm_data <= std_logic_vector(resize(signed(a_mm_data), y_mm_data'length));

        else

          if (unsigned(a_mm_addr) < FRAME_LENGTH) then
            if (subtract_offset) then
              y_mm_data <= std_logic_vector(resize(signed(a_mm_data) - signed(offset), y_mm_data'length));
            else
              y_mm_data <= std_logic_vector(resize(signed(a_mm_data) + signed(offset), y_mm_data'length));
            end if;
          else
            y_mm_data <= std_logic_vector(resize(signed(a_mm_data), y_mm_data'length));
          end if;

        end if;

      end if;

    end if;
  end process;

end rtl;