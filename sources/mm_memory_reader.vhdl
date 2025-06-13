----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 06/09/2025 12:37:58 pm
-- design name: 
-- module name: mm_memory_reader - impl
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.memory_types.all;

entity mm_memory_reader is

  generic (
    addr_width   : integer := 32;
    data_width   : integer := 16;
    frame_length : integer := 4
  );
  port (

    aclk  : in std_logic := '0';
    arstn : in std_logic := '0';

    ap_start : in std_logic := '0';

    a_bram_clk  : out std_logic                                   := '0';
    a_bram_rst  : out std_logic                                   := '0';
    a_bram_en   : out std_logic                                   := '1';
    a_bram_we   : out std_logic_vector(data_width/8 - 1 downto 0) := (others => '0');
    a_bram_addr : out std_logic_vector(addr_width - 1 downto 0)   := (others => '0');
    a_bram_din  : out std_logic_vector(data_width - 1 downto 0)   := (others => '0');
    a_bram_dout : in std_logic_vector(data_width - 1 downto 0)    := (others => '0');

    y_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
    y_mm_wren : out std_logic                                 := '0';
    y_mm_data : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

    intr : out std_logic := '0'
  );

  attribute x_interface_info                : string;
  attribute x_interface_info of a_bram_clk  : signal is "xilinx.com:interface:bram:1.0 a_bram clk";
  attribute x_interface_info of a_bram_addr : signal is "xilinx.com:interface:bram:1.0 a_bram addr";
  attribute x_interface_info of a_bram_rst  : signal is "xilinx.com:interface:bram:1.0 a_bram rst";
  attribute x_interface_info of a_bram_we   : signal is "xilinx.com:interface:bram:1.0 a_bram we";
  attribute x_interface_info of a_bram_en   : signal is "xilinx.com:interface:bram:1.0 a_bram en";
  attribute x_interface_info of a_bram_din  : signal is "xilinx.com:interface:bram:1.0 a_bram din";
  attribute x_interface_info of a_bram_dout : signal is "xilinx.com:interface:bram:1.0 a_bram dout";

end mm_memory_reader;

architecture impl of mm_memory_reader is

  type state_type is (
    idle,
    active
  );

  signal state            : state_type                    := idle;
  signal ap_start_d0      : std_logic                     := '0';
  signal pixel_counter    : std_logic_vector(31 downto 0) := (others => '0');
  signal pixel_counter_d0 : std_logic_vector(31 downto 0) := (others => '0');
  signal pixel_counter_d1 : std_logic_vector(31 downto 0) := (others => '0');
  signal pixel_counter_d2 : std_logic_vector(31 downto 0) := (others => '0');

  signal a_bram_addr_d0 : std_logic_vector(a_bram_addr'length - 1 downto 0) := (others => '0');
  signal a_bram_addr_d1 : std_logic_vector(a_bram_addr'length - 1 downto 0) := (others => '0');

begin

  a_bram_clk  <= aclk;
  a_bram_rst  <= '0';
  a_bram_en   <= '1';
  a_bram_we   <= (others => '0');
  a_bram_addr <= a_bram_addr_d0;
  process (aclk)
    variable addr_increment : integer := integer(real(data_width)/8.0);
    -- variable addr_increment_shift : integer := integer(floor(integer(real(data_width)/8.0)/2));
  begin

    if (aclk'event and aclk = '1') then
      if (arstn = '0') then
        y_mm_wren   <= '0';
        ap_start_d0 <= '0';
      else
        ap_start_d0 <= ap_start;
        case(state) is
          when idle =>
          y_mm_wren <= '0';
          intr      <= '0';
          if (ap_start = '0' and (ap_start_d0 xor ap_start) = '1') then
            state <= active;
          end if;
          when active =>
          y_mm_wren <= '1';

          pixel_counter_d0 <= pixel_counter;
          pixel_counter_d1 <= pixel_counter_d0;
          pixel_counter_d2 <= pixel_counter_d1;

          if (unsigned(pixel_counter_d2) < integer(real(frame_length - 1) * (real(data_width)/8.0))) then
            pixel_counter  <= std_logic_vector(unsigned(pixel_counter) + integer(addr_increment));
            a_bram_addr_d0 <= std_logic_vector(resize(unsigned(pixel_counter), a_bram_addr_d0'length));
            a_bram_addr_d1 <= a_bram_addr_d0;
            y_mm_addr      <= std_logic_vector(shift_right(unsigned(a_bram_addr_d1), integer(addr_increment/2)));
            y_mm_data      <= a_bram_dout;
          else
            pixel_counter <= (others => '0');
            state         <= idle;
            intr          <= '1';
            y_mm_addr     <= (others => '0');
            y_mm_data     <= (others => '0');
          end if;
          when others =>
        end case;
      end if;
    end if;
  end process;

end impl;
