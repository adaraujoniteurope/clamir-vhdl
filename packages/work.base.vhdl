library ieee;
use ieee.std_logic_1164.all;

package base is

  component axi4lite_mngr_mb is
    generic (
      C_AXI_ADDR_WIDTH : natural;
      BANK_INDEX_BIT_H : natural;
      BANK_INDEX_BIT_L : natural
    );
    port (
      ---------------------------------------------------------------------------
      -- Common register bank connections
      ---------------------------------------------------------------------------
      slv_wdata    : out std_logic_vector(31 downto 0);
      slv_addr     : out std_logic_vector(BANK_INDEX_BIT_L - 1 downto 0);
      slv_reg_rden : out std_logic;
      ---------------------------------------------------------------------------
      -- Register bank 0 - GEN
      ---------------------------------------------------------------------------
      b0_slv_rdata   : in std_logic_vector(31 downto 0);
      b0_slv_wren    : out std_logic;
      b0_slv_rden    : out std_logic;
      b0_slv_wr_done : in std_logic;
      b0_slv_rd_done : in std_logic;
      ---------------------------------------------------------------------------
      -- Register bank 1 - MOM
      ---------------------------------------------------------------------------
      b1_slv_rdata   : in std_logic_vector(31 downto 0);
      b1_slv_wren    : out std_logic;
      b1_slv_rden    : out std_logic;
      b1_slv_wr_done : in std_logic;
      b1_slv_rd_done : in std_logic;
      ---------------------------------------------------------------------------
      -- Register bank 2 - ROI
      ---------------------------------------------------------------------------
      b2_slv_rdata   : in std_logic_vector(31 downto 0);
      b2_slv_wren    : out std_logic;
      b2_slv_rden    : out std_logic;
      b2_slv_wr_done : in std_logic;
      b2_slv_rd_done : in std_logic;
      ---------------------------------------------------------------------------
      -- Register bank 3 - PWM
      ---------------------------------------------------------------------------
      b3_slv_rdata   : in std_logic_vector(31 downto 0);
      b3_slv_wren    : out std_logic;
      b3_slv_rden    : out std_logic;
      b3_slv_wr_done : in std_logic;
      b3_slv_rd_done : in std_logic;
      ---------------------------------------------------------------------------
      -- AXI4-Lite configuration IF
      ---------------------------------------------------------------------------
      s_axi_aclk    : in std_logic;
      s_axi_aresetn : in std_logic;
      s_axi_awaddr  : in std_logic_vector(C_AXI_ADDR_WIDTH - 1 downto 0);
      s_axi_awvalid : in std_logic;
      s_axi_awready : out std_logic;
      s_axi_wdata   : in std_logic_vector(31 downto 0);
      s_axi_wvalid  : in std_logic;
      s_axi_wready  : out std_logic;
      s_axi_bresp   : out std_logic_vector(1 downto 0);
      s_axi_bvalid  : out std_logic;
      s_axi_bready  : in std_logic;
      s_axi_araddr  : in std_logic_vector(C_AXI_ADDR_WIDTH - 1 downto 0);
      s_axi_arvalid : in std_logic;
      s_axi_arready : out std_logic;
      s_axi_rdata   : out std_logic_vector(31 downto 0);
      s_axi_rresp   : out std_logic_vector(1 downto 0);
      s_axi_rvalid  : out std_logic;
      s_axi_rready  : in std_logic
    );
  end component;

  component gen_reg_bank is
    generic (
      C_S_AXI_ADDR_WIDTH : natural
    );
    port (
      ---------------------------------------------------------------------------
      -- General purpose ports
      ---------------------------------------------------------------------------
      s_axi_aclk    : in std_logic;
      s_axi_aresetn : in std_logic;
      ---------------------------------------------------------------------------
      -- Register bank access
      ---------------------------------------------------------------------------
      slv_rden    : in std_logic;
      slv_wren    : in std_logic;
      slv_wdata   : in std_logic_vector(31 downto 0);
      slv_addr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      slv_rd_done : out std_logic;
      slv_wr_done : out std_logic;
      slv_rdata   : out std_logic_vector(31 downto 0);
      ---------------------------------------------------------------------------
      -- Inputs from DUT
      ---------------------------------------------------------------------------
      irq_mb : in std_logic_vector(0 downto 0);
      IO_in1 : in std_logic_vector(0 downto 0);
      IO_in2 : in std_logic_vector(0 downto 0);
      IO_in3 : in std_logic_vector(0 downto 0);
      IO_in4 : in std_logic_vector(0 downto 0);
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
  end component;

  component mom_reg_bank is
  generic (
    C_S_AXI_ADDR_WIDTH : natural;
    C_S_SENSOR_IMG_RES : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- general purpose ports
    ---------------------------------------------------------------------------
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;
    ---------------------------------------------------------------------------
    -- register bank access
    ---------------------------------------------------------------------------
    slv_rden    : in std_logic;
    slv_wren    : in std_logic;
    slv_wdata   : in std_logic_vector(31 downto 0);
    slv_addr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    slv_rd_done : out std_logic;
    slv_wr_done : out std_logic;
    slv_rdata   : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- inputs from dut
    ---------------------------------------------------------------------------
    moment_00 : in std_logic_vector(31 downto 0);
    moment_01 : in std_logic_vector(31 downto 0);
    moment_10 : in std_logic_vector(31 downto 0);
    moment_11 : in std_logic_vector(31 downto 0);
    moment_02 : in std_logic_vector(31 downto 0);
    moment_20 : in std_logic_vector(31 downto 0);
    track_num : in std_logic_vector(31 downto 0);
    frame_max : in std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- register bank members dut direct access
    ---------------------------------------------------------------------------
    bin_threshold_out  : out std_logic_vector(C_S_SENSOR_IMG_RES - 1 downto 0);
    intensity_min_out  : out std_logic_vector(31 downto 0);
    intensity_max_out  : out std_logic_vector(31 downto 0);
    trk_threshold_out  : out std_logic_vector(31 downto 0);
    trk_mode_out       : out std_logic_vector(1 downto 0);
    trk_time_cnt_l_out : out std_logic_vector(31 downto 0);
    trk_time_cnt_h_out : out std_logic_vector(15 downto 0);
    trk_start_out      : out std_logic_vector(31 downto 0);
    trk_min_mom00_out  : out std_logic_vector(C_S_SENSOR_IMG_RES - 1 downto 0)
  );
end component;

component roi_reg_bank is
  generic (
    C_S_BRAM_ADDR_WIDTH : natural;
    C_S_AXI_ADDR_WIDTH  : natural
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
    x1_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    y1_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    x2_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    y2_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    round     : out std_logic_vector(1 downto 0)
  );
end component;

component pwm_reg_bank is
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
end component;

end package;