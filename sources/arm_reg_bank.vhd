----------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : arm_reg_bank
-- Description : NIT Processing IP general AXI4-Lite configuration registers
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arm_reg_bank is
  generic (
    C_S_AXI_ADDR_WIDTH : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- General purpose ports
    ---------------------------------------------------------------------------
    s_axi_aclk     : in  std_logic;
    s_axi_aresetn  : in  std_logic;
    ---------------------------------------------------------------------------
    -- Register bank access
    ---------------------------------------------------------------------------
    slv_rden       : in  std_logic;
    slv_wren       : in  std_logic;
    slv_wdata      : in  std_logic_vector(31 downto 0);
    slv_addr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    slv_rd_done    : out std_logic;
    slv_wr_done    : out std_logic;
    slv_rdata      : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- Inputs from DUT
    ---------------------------------------------------------------------------
    irq_arm        : in  std_logic_vector(0 downto 0);
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access
    ---------------------------------------------------------------------------
    ip_mode_out    : out std_logic_vector(0 downto 0);
    rst_fn_out     : out std_logic_vector(0 downto 0);
    rst_ts_out     : out std_logic_vector(0 downto 0);
    sw_rstn_out    : out std_logic_vector(0 downto 0);
    irq_arm_out    : out std_logic_vector(0 downto 0);
    irq_dbg_out    : out std_logic_vector(0 downto 0)
  );
end arm_reg_bank;

architecture behavioral of arm_reg_bank is

  signal ip_mode_reg : unsigned(0 downto 0);
  signal irq_arm_reg : unsigned(0 downto 0);
  signal irq_dbg_reg : unsigned(0 downto 0);
  signal rst_fn_reg  : unsigned(0 downto 0);
  signal rst_ts_reg  : unsigned(0 downto 0);
  signal sw_rstn_reg : unsigned(0 downto 0);

  alias axi_addr : std_logic_vector(C_S_AXI_ADDR_WIDTH-3 downto 0) is slv_addr(slv_addr'left downto 2);

begin

  -----------------------------------------------------------------------------
  -- Write logic
  -----------------------------------------------------------------------------
  p_write : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        ip_mode_reg <= (others => '0');
        sw_rstn_reg <= (others => '1');
      else
        if (slv_wren = '1') then
          case (to_integer(unsigned(axi_addr))) is
            when 0 => -- IP operation mode (0:NORMAL/1:DEBUG)
              ip_mode_reg(0) <= slv_wdata(0);
            when 5 =>
              sw_rstn_reg(0) <= slv_wdata(0);
            when others => NULL;
          end case;
        end if;
      end if;
    end if;
  end process;

  p_irq_arm : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        irq_arm_reg(0) <= '0';
      else
        if ((slv_rden = '1') and (to_integer(unsigned(axi_addr)) = 1)) then
          irq_arm_reg(0) <= '0';
        else
          irq_arm_reg(0) <= irq_arm(0);
        end if;
      end if;
    end if;
  end process;

  p_irq_dbg : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        irq_dbg_reg(0) <= '0';
      else
        if ((slv_wren = '1') and (to_integer(unsigned(axi_addr)) = 2)) then
          irq_dbg_reg(0) <= '1';
        else
          irq_dbg_reg(0) <= '0';
        end if;
      end if;
    end if;
  end process;

  p_rst_fn : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        rst_fn_reg(0) <= '0';
      else
        if ((slv_wren = '1') and (to_integer(unsigned(axi_addr)) = 3)) then
          rst_fn_reg(0) <= '1';
        else
          rst_fn_reg(0) <= '0';
        end if;
      end if;
    end if;
  end process;

  p_rst_ts : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        rst_ts_reg(0) <= '0';
      else
        if ((slv_wren = '1') and (to_integer(unsigned(axi_addr)) = 4)) then
          rst_ts_reg(0) <= '1';
        else
          rst_ts_reg(0) <= '0';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Read logic
  -----------------------------------------------------------------------------
  slv_rdata <= std_logic_vector(resize(ip_mode_reg, 32)) when (to_integer(unsigned(axi_addr)) = 0) else
               std_logic_vector(resize(irq_arm_reg, 32)) when (to_integer(unsigned(axi_addr)) = 1) else
               std_logic_vector(resize(sw_rstn_reg, 32)) when (to_integer(unsigned(axi_addr)) = 5) else
               (others => '0');

  -----------------------------------------------------------------------------
  -- Read/Write done flags
  -----------------------------------------------------------------------------
  slv_rd_done <= slv_rden;
  slv_wr_done <= slv_wren;

  -----------------------------------------------------------------------------
  -- Assign output values
  -----------------------------------------------------------------------------
  ip_mode_out <= std_logic_vector(ip_mode_reg);
  irq_arm_out <= std_logic_vector(irq_arm_reg);
  irq_dbg_out <= std_logic_vector(irq_dbg_reg);
  sw_rstn_out <= std_logic_vector(sw_rstn_reg);
  rst_fn_out  <= std_logic_vector(rst_fn_reg);
  rst_ts_out  <= std_logic_vector(rst_ts_reg);

end;