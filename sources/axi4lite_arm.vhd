-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : axi4lite_arm
-- Description : AXI4-Lite accessible configuration registers top
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity axi4lite_arm is
  port (
    ---------------------------------------------------------------------------
    -- AXI4-Lite configuration IF
    ---------------------------------------------------------------------------
    s_axi_aclk           : in  std_logic;
    s_axi_aresetn        : in  std_logic;
    s_axi_awaddr         : in  std_logic_vector(31 downto 0);
    s_axi_awvalid        : in  std_logic;
    s_axi_awready        : out std_logic;
    s_axi_wdata          : in  std_logic_vector(31 downto 0);
    s_axi_wvalid         : in  std_logic;
    s_axi_wready         : out std_logic;
    s_axi_bresp          : out std_logic_vector( 1 downto 0);
    s_axi_bvalid         : out std_logic;
    s_axi_bready         : in  std_logic;
    s_axi_araddr         : in  std_logic_vector(31 downto 0);
    s_axi_arvalid        : in  std_logic;
    s_axi_arready        : out std_logic;
    s_axi_rdata          : out std_logic_vector(31 downto 0);
    s_axi_rresp          : out std_logic_vector( 1 downto 0);
    s_axi_rvalid         : out std_logic;
    s_axi_rready         : in  std_logic;
    ---------------------------------------------------------------------------
    -- DUT inputs
    ---------------------------------------------------------------------------
    irq_arm              : in  std_logic;
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access - LED
    ---------------------------------------------------------------------------
    led_r_out            : out std_logic;
    led_g_out            : out std_logic;
    led_b_out            : out std_logic;
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access - GEN
    ---------------------------------------------------------------------------
    ip_mode_out          : out std_logic;
    rst_fn_out           : out std_logic;
    rst_ts_out           : out std_logic;
    sw_rstn_out          : out std_logic;
    irq_arm_out          : out std_logic;
    irq_dbg_out          : out std_logic
  );
end axi4lite_arm;

architecture structural of axi4lite_arm is

  constant BANK_INDEX_BIT_H : integer := 32;
  constant BANK_INDEX_BIT_L : integer := 16;

  -----------------------------------------------------------------------------
  -- Internal register bank signals
  -----------------------------------------------------------------------------
  signal slv_addr       : std_logic_vector(BANK_INDEX_BIT_L-1 downto 0);
  signal slv_wdata      : std_logic_vector(31 downto 0);
  signal slv_reg_rden   : std_logic;

  signal b0_slv_rdata   : std_logic_vector(31 downto 0);
  signal b0_slv_wren    : std_logic;
  signal b0_slv_rden    : std_logic;
  signal b0_slv_wr_done : std_logic;
  signal b0_slv_rd_done : std_logic;

  signal b1_slv_rdata   : std_logic_vector(31 downto 0);
  signal b1_slv_wren    : std_logic;
  signal b1_slv_rden    : std_logic;
  signal b1_slv_wr_done : std_logic;
  signal b1_slv_rd_done : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Main AXI interface
  -----------------------------------------------------------------------------
  axi_mngr_i : entity work.axi4lite_mngr_arm
    generic map (
      C_AXI_ADDR_WIDTH => 32,
      BANK_INDEX_BIT_H => BANK_INDEX_BIT_H,
      BANK_INDEX_BIT_L => BANK_INDEX_BIT_L
    )
    port map (
      -- Register bank signals
      slv_reg_rden   => slv_reg_rden,
      slv_addr       => slv_addr,
      slv_wdata      => slv_wdata,
      -- Register bank 0 - GEN
      b0_slv_rdata   => b0_slv_rdata,
      b0_slv_wren    => b0_slv_wren,
      b0_slv_rden    => b0_slv_rden,
      b0_slv_wr_done => b0_slv_wr_done,
      b0_slv_rd_done => b0_slv_rd_done,
      -- Register bank 1 - LED
      b1_slv_rdata   => b1_slv_rdata,
      b1_slv_wren    => b1_slv_wren,
      b1_slv_rden    => b1_slv_rden,
      b1_slv_wr_done => b1_slv_wr_done,
      b1_slv_rd_done => b1_slv_rd_done,
      -- AXI4-Lite IF signals
      s_axi_aclk     => s_axi_aclk,
      s_axi_aresetn  => s_axi_aresetn,
      s_axi_awaddr   => s_axi_awaddr,
      s_axi_awvalid  => s_axi_awvalid,
      s_axi_awready  => s_axi_awready,
      s_axi_wdata    => s_axi_wdata,
      s_axi_wvalid   => s_axi_wvalid,
      s_axi_wready   => s_axi_wready,
      s_axi_bresp    => s_axi_bresp,
      s_axi_bvalid   => s_axi_bvalid,
      s_axi_bready   => s_axi_bready,
      s_axi_araddr   => s_axi_araddr,
      s_axi_arvalid  => s_axi_arvalid,
      s_axi_arready  => s_axi_arready,
      s_axi_rdata    => s_axi_rdata,
      s_axi_rresp    => s_axi_rresp,
      s_axi_rvalid   => s_axi_rvalid,
      s_axi_rready   => s_axi_rready
    );

  -----------------------------------------------------------------------------
  -- Register bank 0 : GEN
  -----------------------------------------------------------------------------
  reg_bnk_0_i : entity work.arm_reg_bank
    generic map (
      C_S_AXI_ADDR_WIDTH => BANK_INDEX_BIT_L
    )
    port map (
      -- General purpose ports
      s_axi_aclk        => s_axi_aclk,
      s_axi_aresetn     => s_axi_aresetn,
      -- Register bank access
      slv_rden          => b0_slv_rden,
      slv_wren          => b0_slv_wren,
      slv_wdata         => slv_wdata,
      slv_addr          => slv_addr,
      slv_rdata         => b0_slv_rdata,
      slv_wr_done       => b0_slv_wr_done,
      slv_rd_done       => b0_slv_rd_done,
      -- DUT inputs
      irq_arm(0)        => irq_arm,
      -- Register bank members
      ip_mode_out(0)    => ip_mode_out,
      rst_fn_out(0)     => rst_fn_out,
      rst_ts_out(0)     => rst_ts_out,
      sw_rstn_out(0)    => sw_rstn_out,
      irq_arm_out(0)    => irq_arm_out,
      irq_dbg_out(0)    => irq_dbg_out
    );

  -----------------------------------------------------------------------------
  -- Register bank 1 : LED
  -----------------------------------------------------------------------------
  reg_bnk_1_i : entity work.led_reg_bank
    generic map (
      C_S_AXI_ADDR_WIDTH => BANK_INDEX_BIT_L
    )
    port map (
      -- General purpose ports
      s_axi_aclk        => s_axi_aclk,
      s_axi_aresetn     => s_axi_aresetn,
      -- Register bank access
      slv_rden          => b1_slv_rden,
      slv_wren          => b1_slv_wren,
      slv_wdata         => slv_wdata,
      slv_addr          => slv_addr,
      slv_rdata         => b1_slv_rdata,
      slv_wr_done       => b1_slv_wr_done,
      slv_rd_done       => b1_slv_rd_done,
      -- Register bank members
      led_r_out(0)      => led_r_out,
      led_g_out(0)      => led_g_out,
      led_b_out(0)      => led_b_out
    );

end structural;