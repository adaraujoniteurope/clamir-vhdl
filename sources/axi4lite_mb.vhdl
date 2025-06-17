-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : axi4lite_mb
-- Description : AXI4-Lite accessible configuration registers top
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- library work;
-- use work.clamir_pkg.all;

library work;
use work.base.all;

entity axi4lite_mb is
  generic (
    -- BRAM Address width
    C_S_BRAM_ADDR_WIDTH : natural;
    -- Sensor image resolution (bits per pixel)
    C_S_SENSOR_IMG_RES : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- AXI4-Lite configuration IF
    ---------------------------------------------------------------------------
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;
    s_axi_awaddr  : in std_logic_vector(31 downto 0);
    s_axi_awvalid : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in std_logic_vector(31 downto 0);
    s_axi_wvalid  : in std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in std_logic;
    s_axi_araddr  : in std_logic_vector(31 downto 0);
    s_axi_arvalid : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in std_logic;
    ---------------------------------------------------------------------------
    -- DUT inputs
    ---------------------------------------------------------------------------
    irq_mb    : in std_logic;
    IO_in1    : in std_logic;
    IO_in2    : in std_logic;
    IO_in3    : in std_logic;
    IO_in4    : in std_logic;
    moment_00 : in std_logic_vector(31 downto 0);
    moment_01 : in std_logic_vector(31 downto 0);
    moment_10 : in std_logic_vector(31 downto 0);
    moment_11 : in std_logic_vector(31 downto 0);
    moment_02 : in std_logic_vector(31 downto 0);
    moment_20 : in std_logic_vector(31 downto 0);
    track_num : in std_logic_vector(31 downto 0);
    frame_max : in std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access - GEN
    ---------------------------------------------------------------------------
    mom_enable_out : out std_logic;
    --trk_enable_out       : out std_logic;
    roi_enable_out : out std_logic;
    pwm_enable_out : out std_logic;
    irq_enable_out : out std_logic;
    trk_rst_out    : out std_logic;
    irq_mb_out     : out std_logic;
    IO_out1_out    : out std_logic;
    IO_out2_out    : out std_logic;
    --IO_out_conf_out : out std_logic_vector(1 downto 0);
    IO_out3_out : out std_logic;
    IO_out4_out : out std_logic;
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access - MOM
    ---------------------------------------------------------------------------
    bin_threshold_out : out std_logic_vector(C_S_SENSOR_IMG_RES - 1 downto 0);
    --intensity_min_out    : out std_logic_vector(31 downto 0);
    --intensity_max_out    : out std_logic_vector(31 downto 0);
    trk_threshold_out  : out std_logic_vector(31 downto 0);
    trk_mode_out       : out std_logic_vector(1 downto 0);
    trk_time_cnt_l_out : out std_logic_vector(31 downto 0);
    trk_time_cnt_h_out : out std_logic_vector(15 downto 0);
    trk_start_out      : out std_logic_vector(31 downto 0);
    trk_min_mom00_out  : out std_logic_vector(C_S_SENSOR_IMG_RES - 1 downto 0);
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access - ROI
    ---------------------------------------------------------------------------
    x1_out : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2) - 1 downto 0);
    y1_out : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2) - 1 downto 0);
    x2_out : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2) - 1 downto 0);
    y2_out : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2) - 1 downto 0);
    round  : out std_logic_vector(1 downto 0);
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access - PWM
    ---------------------------------------------------------------------------
    pwm_max_limit_out : out std_logic_vector(31 downto 0);
    pwm_duty_out      : out std_logic_vector(31 downto 0);
    pwm_power_out     : out std_logic_vector(31 downto 0);
    pwm_min_limit_out : out std_logic_vector(31 downto 0)
  );
end axi4lite_mb;

architecture structural of axi4lite_mb is

  constant BANK_INDEX_BIT_H : integer := 32;
  constant BANK_INDEX_BIT_L : integer := 16;

  -----------------------------------------------------------------------------
  -- Internal register bank signals
  -----------------------------------------------------------------------------
  signal slv_addr     : std_logic_vector(BANK_INDEX_BIT_L - 1 downto 0);
  signal slv_wdata    : std_logic_vector(31 downto 0);
  signal slv_reg_rden : std_logic;

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

  signal b2_slv_rdata   : std_logic_vector(31 downto 0);
  signal b2_slv_wren    : std_logic;
  signal b2_slv_rden    : std_logic;
  signal b2_slv_wr_done : std_logic;
  signal b2_slv_rd_done : std_logic;

  signal b3_slv_rdata   : std_logic_vector(31 downto 0);
  signal b3_slv_wren    : std_logic;
  signal b3_slv_rden    : std_logic;
  signal b3_slv_wr_done : std_logic;
  signal b3_slv_rd_done : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Main AXI interface
  -----------------------------------------------------------------------------
  axi_mngr_i : axi4lite_mngr_mb
    generic map(
      C_AXI_ADDR_WIDTH => 32,
      BANK_INDEX_BIT_H => BANK_INDEX_BIT_H,
      BANK_INDEX_BIT_L => BANK_INDEX_BIT_L
    )
    port map
    (
      -- Register bank signals
      slv_reg_rden => slv_reg_rden,
      slv_addr     => slv_addr,
      slv_wdata    => slv_wdata,
      -- Register bank 0 - GEN
      b0_slv_rdata   => b0_slv_rdata,
      b0_slv_wren    => b0_slv_wren,
      b0_slv_rden    => b0_slv_rden,
      b0_slv_wr_done => b0_slv_wr_done,
      b0_slv_rd_done => b0_slv_rd_done,
      -- Register bank 1 - MOM
      b1_slv_rdata   => b1_slv_rdata,
      b1_slv_wren    => b1_slv_wren,
      b1_slv_rden    => b1_slv_rden,
      b1_slv_wr_done => b1_slv_wr_done,
      b1_slv_rd_done => b1_slv_rd_done,
      -- Register bank 2 - ROI
      b2_slv_rdata   => b2_slv_rdata,
      b2_slv_wren    => b2_slv_wren,
      b2_slv_rden    => b2_slv_rden,
      b2_slv_wr_done => b2_slv_wr_done,
      b2_slv_rd_done => b2_slv_rd_done,
      -- Register bank 3 - PWM
      b3_slv_rdata   => b3_slv_rdata,
      b3_slv_wren    => b3_slv_wren,
      b3_slv_rden    => b3_slv_rden,
      b3_slv_wr_done => b3_slv_wr_done,
      b3_slv_rd_done => b3_slv_rd_done,
      -- AXI4-Lite IF signals
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata   => s_axi_wdata,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,
      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,
      s_axi_araddr  => s_axi_araddr,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready
    );

  -----------------------------------------------------------------------------
  -- Register bank 0 : GEN
  -----------------------------------------------------------------------------
  reg_bnk_0_i : gen_reg_bank
    generic map(
      C_S_AXI_ADDR_WIDTH => BANK_INDEX_BIT_L
    )
    port map
    (
      -- General purpose ports
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      -- Register bank access
      slv_rden    => b0_slv_rden,
      slv_wren    => b0_slv_wren,
      slv_wdata   => slv_wdata,
      slv_addr    => slv_addr,
      slv_rdata   => b0_slv_rdata,
      slv_wr_done => b0_slv_wr_done,
      slv_rd_done => b0_slv_rd_done,
      -- DUT inputs
      irq_mb(0) => irq_mb,
      IO_in1(0) => IO_in1,
      IO_in2(0) => IO_in2,
      IO_in3(0) => IO_in3,
      IO_in4(0) => IO_in4,
      -- Register bank members
      mom_enable_out(0) => mom_enable_out,
      roi_enable_out(0) => roi_enable_out,
      pwm_enable_out(0) => pwm_enable_out,
      irq_enable_out(0) => irq_enable_out,
      --trk_enable_out(0) => trk_enable_out,
      trk_rst_out(0) => trk_rst_out,
      irq_mb_out(0)  => irq_mb_out,
      IO_out1_out(0) => IO_out1_out,
      IO_out2_out(0) => IO_out2_out,
      IO_out3_out(0) => IO_out3_out,
      IO_out4_out(0) => IO_out4_out
      --IO_out_conf_out => IO_out_conf_out
    );

  -----------------------------------------------------------------------------
  -- Register bank 1 : MOM
  -----------------------------------------------------------------------------
  reg_bnk_1_i : mom_reg_bank
    generic map(
      C_S_AXI_ADDR_WIDTH => BANK_INDEX_BIT_L,
      C_S_SENSOR_IMG_RES => C_S_SENSOR_IMG_RES
    )
    port map
    (
      -- General purpose ports
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      -- Register bank access
      slv_rden    => b1_slv_rden,
      slv_wren    => b1_slv_wren,
      slv_wdata   => slv_wdata,
      slv_addr    => slv_addr,
      slv_rdata   => b1_slv_rdata,
      slv_wr_done => b1_slv_wr_done,
      slv_rd_done => b1_slv_rd_done,
      -- DUT inputs
      moment_00 => moment_00,
      moment_01 => moment_01,
      moment_10 => moment_10,
      moment_11 => moment_11,
      moment_02 => moment_02,
      moment_20 => moment_20,
      track_num => track_num,
      frame_max => frame_max,
      -- Register bank members
      bin_threshold_out => bin_threshold_out,
      --      intensity_min_out    => intensity_min_out,
      --      intensity_max_out    => intensity_max_out,
      trk_threshold_out  => trk_threshold_out,
      trk_mode_out       => trk_mode_out,
      trk_time_cnt_l_out => trk_time_cnt_l_out,
      trk_time_cnt_h_out => trk_time_cnt_h_out,
      trk_start_out      => trk_start_out,
      trk_min_mom00_out  => trk_min_mom00_out
    );

  -----------------------------------------------------------------------------
  -- Register bank 2 : ROI
  -----------------------------------------------------------------------------
  reg_bnk_2_i : roi_reg_bank
    generic map(
      C_S_BRAM_ADDR_WIDTH => C_S_BRAM_ADDR_WIDTH,
      C_S_AXI_ADDR_WIDTH  => BANK_INDEX_BIT_L
    )
    port map
    (
      -- General purpose ports
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      -- Register bank access
      slv_rden    => b2_slv_rden,
      slv_wren    => b2_slv_wren,
      slv_wdata   => slv_wdata,
      slv_addr    => slv_addr,
      slv_rdata   => b2_slv_rdata,
      slv_wr_done => b2_slv_wr_done,
      slv_rd_done => b2_slv_rd_done,
      -- Register bank members
      x1_out => x1_out,
      y1_out => y1_out,
      x2_out => x2_out,
      y2_out => y2_out,
      round  => round
    );

  -----------------------------------------------------------------------------
  -- Register bank 3 : PWM
  -----------------------------------------------------------------------------
  reg_bnk_3_i : pwm_reg_bank
    generic map(
      C_S_AXI_ADDR_WIDTH => BANK_INDEX_BIT_L
    )
    port map
    (
      -- General purpose ports
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      -- Register bank access
      slv_rden    => b3_slv_rden,
      slv_wren    => b3_slv_wren,
      slv_wdata   => slv_wdata,
      slv_addr    => slv_addr,
      slv_rdata   => b3_slv_rdata,
      slv_wr_done => b3_slv_wr_done,
      slv_rd_done => b3_slv_rd_done,
      -- Register bank members
      pwm_max_limit_out => pwm_max_limit_out,
      pwm_duty_out      => pwm_duty_out,
      pwm_power_out     => pwm_power_out,
      pwm_min_limit_out => pwm_min_limit_out
    );

end structural;