-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : gen_reg_bank
-- Description : NIT Processing IP general AXI4-Lite configuration registers
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_reg_bank is
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
    irq_mb         : in  std_logic_vector(0 downto 0);
    IO_in1         : in  std_logic_vector(0 downto 0);
    IO_in2         : in  std_logic_vector(0 downto 0);
    IO_in3         : in  std_logic_vector(0 downto 0);
    IO_in4         : in  std_logic_vector(0 downto 0);
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access
    ---------------------------------------------------------------------------
    mom_enable_out : out std_logic_vector(0 downto 0);
    roi_enable_out : out std_logic_vector(0 downto 0);
    pwm_enable_out : out std_logic_vector(0 downto 0);
    irq_enable_out : out std_logic_vector(0 downto 0);
    trk_rst_out    : out std_logic_vector(0 downto 0);
    irq_mb_out     : out std_logic_vector(0 downto 0);
    IO_out1_out    : out std_logic_vector(0 downto 0); 
    IO_out2_out    : out std_logic_vector(0 downto 0); 
    IO_out3_out    : out std_logic_vector(0 downto 0); 
    IO_out4_out    : out std_logic_vector(0 downto 0) 
    --IO_out_conf_out : out std_logic_vector(1 downto 0) --desaparece en la nueva version
  );
end gen_reg_bank;

architecture behavioral of gen_reg_bank is

  constant VERSION : unsigned := x"0001_0000";

  signal mom_enable_reg  : unsigned(0 downto 0);
  signal roi_enable_reg  : unsigned(0 downto 0);
  signal pwm_enable_reg  : unsigned(0 downto 0);
  signal irq_enable_reg  : unsigned(0 downto 0);
  signal trk_rst_reg     : unsigned(0 downto 0);
  signal irq_mb_reg      : unsigned(0 downto 0);
  signal IO_out1_reg     : unsigned(0 downto 0);
  signal IO_out2_reg     : unsigned(0 downto 0);
  signal IO_out3_reg     : unsigned(0 downto 0);
  signal IO_out4_reg     : unsigned(0 downto 0);
  signal IO_out_conf_reg : unsigned(1 downto 0);

  alias axi_addr : std_logic_vector(C_S_AXI_ADDR_WIDTH-3 downto 0) is slv_addr(slv_addr'left downto 2);

begin

  -----------------------------------------------------------------------------
  -- Write logic
  -----------------------------------------------------------------------------
  p_write : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        mom_enable_reg <= (others => '1');
        roi_enable_reg <= (others => '0');
        pwm_enable_reg <= (others => '1');
        irq_enable_reg <= (others => '1');
        IO_out1_reg <=    (others => '0');
        IO_out2_reg <=    (others => '0');
        IO_out_conf_reg <= (others => '0');
      else
        if (slv_wren = '1') then
          case (to_integer(unsigned(axi_addr))) is
            when 1 => -- Enable moments calculation
              mom_enable_reg(0) <= slv_wdata(0);
            when 2 => -- Enable Region-Of-Interest calculation
              roi_enable_reg(0) <= slv_wdata(0);
            when 3 => -- Enable PWM pulses generation
              pwm_enable_reg(0) <= slv_wdata(0);
            when 4 => -- Enable MicroBlaze interrupts (moments calculated)
              irq_enable_reg(0) <= slv_wdata(0);
            when 9 => -- Enable MicroBlaze interrupts (moments calculated)
              IO_out1_reg(0) <= slv_wdata(0);
            when 10 => -- Enable MicroBlaze interrupts (moments calculated)
              IO_out2_reg(0) <= slv_wdata(0);
            when 11 => -- Enable MicroBlaze interrupts (moments calculated)
              IO_out_conf_reg <= unsigned(slv_wdata(1 downto 0));
            when 14 => -- Enable MicroBlaze interrupts (moments calculated)
              IO_out3_reg(0) <= slv_wdata(0);
            when 15 => -- Enable MicroBlaze interrupts (moments calculated)
              IO_out4_reg(0) <= slv_wdata(0);  
            when others => NULL;
          end case;
        end if;
      end if;
    end if;
  end process;

  p_trk_rst : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        trk_rst_reg(0) <= '0';
      else
        if ((slv_wren = '1') and (to_integer(unsigned(axi_addr)) = 5)) then
          trk_rst_reg(0) <= '1';
        else
          trk_rst_reg(0) <= '0';
        end if;
      end if;
    end if;
  end process;

  p_irq_mb : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        irq_mb_reg(0) <= '0';
      else
        if ((slv_rden = '1') and (to_integer(unsigned(axi_addr)) = 6)) then
          irq_mb_reg(0) <= '0';
        else
          irq_mb_reg(0) <= irq_mb(0);
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Read logic
  -----------------------------------------------------------------------------
  slv_rdata <= std_logic_vector(resize(VERSION, 32))        when (to_integer(unsigned(axi_addr)) = 0) else
               std_logic_vector(resize(mom_enable_reg, 32)) when (to_integer(unsigned(axi_addr)) = 1) else
               std_logic_vector(resize(roi_enable_reg, 32)) when (to_integer(unsigned(axi_addr)) = 2) else
               std_logic_vector(resize(pwm_enable_reg, 32)) when (to_integer(unsigned(axi_addr)) = 3) else
               std_logic_vector(resize(irq_enable_reg, 32)) when (to_integer(unsigned(axi_addr)) = 4) else
               std_logic_vector(resize(irq_mb_reg,  32))    when (to_integer(unsigned(axi_addr)) = 6) else
               std_logic_vector(resize(unsigned(IO_in1),  32)) when (to_integer(unsigned(axi_addr)) = 7) else
               std_logic_vector(resize(unsigned(IO_in2),  32)) when (to_integer(unsigned(axi_addr)) = 8) else
               std_logic_vector(resize(IO_out1_reg,  32)) when (to_integer(unsigned(axi_addr)) = 9) else
               std_logic_vector(resize(IO_out2_reg,  32)) when (to_integer(unsigned(axi_addr)) = 10) else
               std_logic_vector(resize(IO_out_conf_reg,  32)) when (to_integer(unsigned(axi_addr)) = 11) else
               std_logic_vector(resize(unsigned(IO_in3),  32)) when (to_integer(unsigned(axi_addr)) = 12) else
               std_logic_vector(resize(unsigned(IO_in4),  32)) when (to_integer(unsigned(axi_addr)) = 13) else
               std_logic_vector(resize(IO_out3_reg,  32)) when (to_integer(unsigned(axi_addr)) = 14) else
               std_logic_vector(resize(IO_out4_reg,  32)) when (to_integer(unsigned(axi_addr)) = 15) else
               (others => '0');

  -----------------------------------------------------------------------------
  -- Read/Write done flags
  -----------------------------------------------------------------------------
  slv_rd_done <= slv_rden;
  slv_wr_done <= slv_wren;
  
  -----------------------------------------------------------------------------
  -- Assign output values
  -----------------------------------------------------------------------------
  mom_enable_out <= std_logic_vector(mom_enable_reg);
  roi_enable_out <= std_logic_vector(roi_enable_reg);
  pwm_enable_out <= std_logic_vector(pwm_enable_reg);
  irq_enable_out <= std_logic_vector(irq_enable_reg);
  trk_rst_out    <= std_logic_vector(trk_rst_reg);
  irq_mb_out     <= std_logic_vector(irq_mb_reg);
  IO_out1_out    <= std_logic_vector(IO_out1_reg);
  IO_out2_out     <= std_logic_vector(IO_out2_reg);
  IO_out3_out    <= std_logic_vector(IO_out3_reg);
  IO_out4_out     <= std_logic_vector(IO_out4_reg);
  --IO_out_conf_out    <= std_logic_vector(IO_out_conf_reg);
  

end;