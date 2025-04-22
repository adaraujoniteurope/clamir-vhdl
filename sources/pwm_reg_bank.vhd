-------------------------------------------------------------------------------
-- company     : aimen
-- project     : clamir
-- module      : pwm_reg_bank
-- description : pwm generator axi4-lite configuration registers
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_reg_bank is
  generic (
    C_S_AXI_ADDR_WIDTH : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- general purpose ports
    ---------------------------------------------------------------------------
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    ---------------------------------------------------------------------------
    -- register bank access
    ---------------------------------------------------------------------------
    slv_rden      : in  std_logic;
    slv_wren      : in  std_logic;
    slv_wdata     : in  std_logic_vector(31 downto 0);
    slv_addr      : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    slv_rd_done   : out std_logic;
    slv_wr_done   : out std_logic;
    slv_rdata     : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- register bank members dut direct access
    ---------------------------------------------------------------------------
    pwm_max_limit_out : out std_logic_vector(31 downto 0);
    pwm_min_limit_out : out std_logic_vector(31 downto 0);
    pwm_duty_out  : out std_logic_vector(31 downto 0);
    pwm_power_out : out std_logic_vector(31 downto 0)
  );
end pwm_reg_bank;

architecture behavioral of pwm_reg_bank is

  signal pwm_max_limit_reg : std_logic_vector(31 downto 0);
  signal pwm_min_limit_reg : std_logic_vector(31 downto 0);
  signal pwm_duty_reg  : std_logic_vector(31 downto 0);
  signal pwm_power_reg : std_logic_vector(31 downto 0);

  alias axi_addr : std_logic_vector(C_S_AXI_ADDR_WIDTH-3 downto 0) is slv_addr(slv_addr'left downto 2);

begin

  -----------------------------------------------------------------------------
  -- write logic
  -----------------------------------------------------------------------------
  p_write : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        pwm_max_limit_reg <= x"000003e8";
        pwm_min_limit_reg <= (others => '0');
        
        pwm_duty_reg  <= (others => '0');
        pwm_power_reg <= (others => '0');
      else
        if (slv_wren = '1') then
          case (to_integer(unsigned(axi_addr))) is
            when 0 => -- pwm maximum consign value
              pwm_max_limit_reg <= slv_wdata;
            when 1 => -- pwm duty cycle
              pwm_duty_reg  <= slv_wdata;
            when 2 => -- pwm power
              pwm_power_reg <= slv_wdata;
            when 3 => -- pwm maximum consign value
              pwm_min_limit_reg <= slv_wdata;
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- read logic
  -----------------------------------------------------------------------------
  slv_rdata <= pwm_max_limit_reg when (to_integer(unsigned(axi_addr)) = 0) else
               pwm_duty_reg  when (to_integer(unsigned(axi_addr)) = 1) else
               pwm_power_reg when (to_integer(unsigned(axi_addr)) = 2) else
               pwm_min_limit_reg when (to_integer(unsigned(axi_addr)) = 3) else
               (others => '0');

  -----------------------------------------------------------------------------
  -- read/write done flags
  -----------------------------------------------------------------------------
  slv_rd_done <= slv_rden;
  slv_wr_done <= slv_wren;

  -----------------------------------------------------------------------------
  -- assign output values
  -----------------------------------------------------------------------------
  pwm_max_limit_out <= pwm_max_limit_reg;
  pwm_min_limit_out <= pwm_min_limit_reg;
  pwm_duty_out  <= pwm_duty_reg;
  pwm_power_out <= pwm_power_reg;

end;