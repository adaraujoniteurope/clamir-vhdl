----------------------------------------------------------------------------------
-- company     : aimen
-- project     : clamir
-- module      : led_reg_bank
-- description : nit processing ip general axi4-lite configuration registers
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_reg_bank is
  generic (
    C_S_AXI_ADDR_WIDTH : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- general purpose ports
    ---------------------------------------------------------------------------
    s_axi_aclk     : in  std_logic;
    s_axi_aresetn  : in  std_logic;
    ---------------------------------------------------------------------------
    -- register bank access
    ---------------------------------------------------------------------------
    slv_rden       : in  std_logic;
    slv_wren       : in  std_logic;
    slv_wdata      : in  std_logic_vector(31 downto 0);
    slv_addr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    slv_rd_done    : out std_logic;
    slv_wr_done    : out std_logic;
    slv_rdata      : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- register bank members dut direct access
    ---------------------------------------------------------------------------
    led_r_out      : out std_logic_vector(0 downto 0);
    led_g_out      : out std_logic_vector(0 downto 0);
    led_b_out      : out std_logic_vector(0 downto 0)
  );
end led_reg_bank;

architecture behavioral of led_reg_bank is

  signal led_r_reg : unsigned(0 downto 0);
  signal led_g_reg : unsigned(0 downto 0);
  signal led_b_reg : unsigned(0 downto 0);

  alias axi_addr : std_logic_vector(C_S_AXI_ADDR_WIDTH-3 downto 0) is slv_addr(slv_addr'left downto 2);

begin

  -----------------------------------------------------------------------------
  -- write logic
  -----------------------------------------------------------------------------
  p_write : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        led_r_reg <= (others => '0');
        led_g_reg <= (others => '0');
        led_b_reg <= (others => '0');
      else
        if (slv_wren = '1') then
          case (to_integer(unsigned(axi_addr))) is
            when 0 =>
              led_r_reg(0) <= slv_wdata(0);
            when 1 =>
              led_g_reg(0) <= slv_wdata(0);
            when 2 =>
              led_b_reg(0) <= slv_wdata(0);
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- read logic
  -----------------------------------------------------------------------------
  slv_rdata <= std_logic_vector(resize(led_r_reg, 32)) when (to_integer(unsigned(axi_addr)) = 0) else
               std_logic_vector(resize(led_g_reg, 32)) when (to_integer(unsigned(axi_addr)) = 1) else
               std_logic_vector(resize(led_b_reg, 32)) when (to_integer(unsigned(axi_addr)) = 2) else
               (others => '0');

  -----------------------------------------------------------------------------
  -- read/write done flags
  -----------------------------------------------------------------------------
  slv_rd_done <= slv_rden;
  slv_wr_done <= slv_wren;
  
  -----------------------------------------------------------------------------
  -- assign output values
  -----------------------------------------------------------------------------
  led_r_out <= std_logic_vector(led_r_reg);
  led_g_out <= std_logic_vector(led_g_reg);
  led_b_out <= std_logic_vector(led_b_reg);

end;