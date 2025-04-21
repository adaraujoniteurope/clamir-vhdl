-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : bram_gen
-- Description : BRAM content generator initially simple counter
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_gen is
  generic (
    C_S_BRAM_ADDR_WIDTH : natural;
    C_S_BRAM_DATA_WIDTH : natural;
    C_S_BRAM_WE_WIDTH   : integer := 0;
    C_S_BRAM_DDR_ENABLE : boolean := false
  );
  port (
    clk  : in  std_logic;
    rstn : in  std_logic;
    we   : out std_logic_vector(C_S_BRAM_WE_WIDTH-1 downto 0);
    addr : out std_Logic_vector(C_S_BRAM_ADDR_WIDTH-1 downto 0);
    dout : out std_Logic_vector(C_S_BRAM_DATA_WIDTH-1 downto 0)
  );
end bram_gen;

architecture behavioral of bram_gen is

  function set_addr_limit return integer is
  begin
    if (C_S_BRAM_DDR_ENABLE = true) then
      return 2048;
    else
      return 4096;
    end if;
  end function set_addr_limit;

  constant ADDR_LIMIT : integer := set_addr_limit;

  signal addr_i     : unsigned(C_S_BRAM_ADDR_WIDTH-1 downto 0);
  signal data_ch0_i : unsigned(C_S_BRAM_DATA_WIDTH-1 downto 0);
  signal data_ch1_i : unsigned(C_S_BRAM_DATA_WIDTH-1 downto 0);

begin

  p_bram : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        we         <= (others => '0');
        addr_i     <= (others => '0');
        data_ch0_i <= to_unsigned(0, data_ch0_i'length);
        data_ch1_i <= to_unsigned(1, data_ch1_i'length);
      else
        if (addr_i /= ADDR_LIMIT-1) then
          we     <= (others => '1');
        else
          we     <= (others => '0');
          addr_i <= addr_i + 1;
        end if;
        data_ch0_i <= data_ch0_i + 1;
        data_ch1_i <= data_ch1_i + 1;
      end if;
    end if;
  end process;

  -- Assign outputs
  addr <= std_logic_vector(addr_i);

ddr_gen : if C_S_BRAM_DDR_ENABLE = true generate
  dout <= std_Logic_vector(data_ch1_i(13 downto 0)) & "00" &
          std_logic_vector(data_ch0_i(13 downto 0)) & "00";
end generate ddr_gen;

sdr_gen : if C_S_BRAM_DDR_ENABLE = false generate
  dout <= std_logic_vector(data_ch0_i(13 downto 0)) & "00";
end generate sdr_gen;

end behavioral;