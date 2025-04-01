library ieee;

use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

-- package declaration section
package memory_types is

  type memory_32b_type is array(integer range <>) of std_logic_vector(31 downto 0);
  type memory_64b_type is array(integer range <>) of std_logic_vector(63 downto 0);

  impure function init_ram_from_file(filename : in string; line_count : in integer) return memory_32b_type;
  impure function save_ram_to_file(filename : in string; memory : in memory_32b_type) return integer;

end package memory_types;

-- package body section
package body memory_types is

  impure function init_ram_from_file(filename : in string; line_count : in integer) return memory_32b_type is
    file read_file : text is in filename;
    variable read_line : line;
    variable init_ram : memory_32b_type(0 to line_count-1);
    variable value : integer := 0;
  begin

    for i in init_ram'range loop
      readline(read_file, read_line);
      read(read_line, value);
      init_ram(i) := std_logic_vector(to_unsigned(value, init_ram(i)'length));
    end loop;

    return init_ram;
  end function;

  impure function save_ram_to_file(filename : in string; memory : in memory_32b_type) return integer is
    file write_file : text is in filename;
    variable write_line : line;
    variable value : integer := 0;
  begin

    for i in memory'range loop
      value := to_integer(unsigned(memory(i)));
      write(write_line, value);
      writeline(write_file, write_line);
      -- init_ram(i) := std_logic_vector(to_unsigned(value, init_ram(i)'length));
    end loop;

    return 0;
  end function;

end package body memory_types;