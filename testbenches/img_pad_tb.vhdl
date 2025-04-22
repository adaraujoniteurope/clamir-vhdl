-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : img_pad_tb
-- Description : Test image metadata padding
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.clamir_pkg.all;

entity img_pad_tb is
end img_pad_tb;

architecture behavioral of img_pad_tb is

  constant X1_REG         : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned( 7, (C_S_BRAM_ADDR_WIDTH/2)));
  constant X2_REG         : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned(56, (C_S_BRAM_ADDR_WIDTH/2)));
  constant Y1_REG         : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned( 7, (C_S_BRAM_ADDR_WIDTH/2)));
  constant Y2_REG         : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned(56, (C_S_BRAM_ADDR_WIDTH/2)));

  constant BIN_THRESHOLD  : std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0) := std_logic_vector(to_unsigned(255, C_S_SENSOR_IMG_RES));
  constant TRK_THRESHOLD  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(255, 32));
  constant TRK_MODE       : std_logic_vector( 1 downto 0) := (others => '0');
  constant TRK_TIME_CNT_L : std_logic_vector(31 downto 0) := (others => '1');
  constant TRK_TIME_CNT_H : std_logic_vector(15 downto 0) := (others => '0');  

  signal clk            : std_logic := '0';
  signal rstn           : std_logic := '0';

  signal s_bram_raddr   : std_logic_vector(C_S_BRAM_ADDR_WIDTH-1 downto 0);
  signal s_bram_rdata   : std_logic_vector(C_S_BRAM_DATA_WIDTH-1 downto 0);
  signal s_bram_rready  : std_logic;

  signal m_b2a_tvalid   : std_logic;
  signal m_b2a_tready   : std_logic;
  signal m_b2a_tdata    : std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
  signal m_b2a_tlast    : std_logic;
  signal m_b2a_tuser    : std_logic;

  signal row_b2a        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal col_b2a        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);

  signal m_roi_tvalid   : std_logic;
  signal m_roi_tready   : std_logic;
  signal m_roi_tdata    : std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
  signal m_roi_tlast    : std_logic;
  signal m_roi_tuser    : std_logic;

  signal row_roi        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal col_roi        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);

  signal moment_00      : std_logic_vector(31 downto 0);
  signal moment_01      : std_logic_vector(31 downto 0);
  signal moment_10      : std_logic_vector(31 downto 0);
  signal moment_11      : std_logic_vector(31 downto 0);
  signal moment_02      : std_logic_vector(31 downto 0);
  signal moment_20      : std_logic_vector(31 downto 0);
  signal track_num      : std_logic_vector(31 downto 0);
  signal frame_max      : std_logic_vector(31 downto 0);
  signal power          : std_logic_vector(31 downto 0) := (others => '0');

begin

  -- Generate clock
  clk <= not(clk) after CLK_PERIOD_2;

  -- Generate reset (active low)
  rstn <= '0', '1' after 250 ns;

  -- Generate image ready pulse (1000 frames/s -> 1ms)
  sns_inst : entity work.sensor_mdl
    port map (
      clk           => clk,
      rstn          => rstn,
      s_bram_rready => s_bram_rready
    );

  rom_inst : img_rom
    port map (
      clka  => clk,
      addra => s_bram_raddr,
      douta => s_bram_rdata
    );

  b2a_inst : entity work.bram2axis
  generic map (
    C_S_IMAGE_SIZE      => C_S_IMAGE_SIZE,
    C_S_BRAM_ADDR_WIDTH => C_S_BRAM_ADDR_WIDTH,
    C_S_BRAM_DATA_WIDTH => C_S_BRAM_DATA_WIDTH,
    C_S_AXIS_DATA_WIDTH => C_S_AXIS_DATA_WIDTH,
    C_S_BRAM_INDEX_H    => C_S_BRAM_INDEX_H,
    C_S_BRAM_INDEX_L    => C_S_BRAM_INDEX_L,
    C_S_BRAM_DDR_ENABLE => false
  )
  port map (
    clk           => clk,
    rstn          => rstn,
    s_bram_raddr  => s_bram_raddr,
    s_bram_rdata  => s_bram_rdata,
    s_bram_rready => s_bram_rready,
    m_axis_tvalid => m_b2a_tvalid,
    m_axis_tready => m_b2a_tready,
    m_axis_tdata  => m_b2a_tdata,
    m_axis_tlast  => m_b2a_tlast,
    m_axis_tuser  => m_b2a_tuser,
    row_dout      => row_b2a,
    col_dout      => col_b2a
  );

  roi_inst : entity work.img_roi
    generic map (
      C_S_BRAM_ADDR_WIDTH => C_S_BRAM_ADDR_WIDTH,
      C_S_AXIS_DATA_WIDTH => C_S_AXIS_DATA_WIDTH
    )
    port map (
      clk           => clk,
      rstn          => rstn,
      enable        => '1',
      X1            => X1_REG,
      Y1            => Y1_REG,
      X2            => X2_REG,
      Y2            => Y2_REG,
      row_din       => row_b2a,
      col_din       => col_b2a,
      row_dout      => row_roi,
      col_dout      => col_roi,
      s_axis_tvalid => m_b2a_tvalid,
      s_axis_tready => m_b2a_tready,
      s_axis_tdata  => m_b2a_tdata,
      s_axis_tlast  => m_b2a_tlast,
      s_axis_tuser  => m_b2a_tuser,
      m_axis_tvalid => m_roi_tvalid,
      m_axis_tready => '1',
      m_axis_tdata  => m_roi_tdata,
      m_axis_tlast  => m_roi_tlast,
      m_axis_tuser  => m_roi_tuser
    );

  mom_inst : entity work.moment_wrapper
    generic map (
      C_S_BRAM_ADDR_WIDTH  => C_S_BRAM_ADDR_WIDTH,
      C_S_AXIS_DATA_WIDTH  => C_S_AXIS_DATA_WIDTH,
      C_S_SENSOR_IMG_RES   => C_S_SENSOR_IMG_RES,
      C_S_TRACK_GEN_ENABLE => true
    )
    port map (
      clk            => clk,
      rstn           => rstn,
      s_axis_tvalid  => m_roi_tvalid,
      s_axis_tready  => open,
      s_axis_tdata   => m_roi_tdata,
      s_axis_tlast   => m_roi_tlast,
      s_axis_tuser   => m_roi_tuser,
      row_din        => row_roi,
      col_din        => col_roi,
      mom_enable     => '1',
      irq_enable     => '1',
      bin_threshold  => BIN_THRESHOLD,
      trk_rst        => '1',
      trk_threshold  => TRK_THRESHOLD,
      trk_mode       => TRK_MODE,
      trk_time_cnt_l => TRK_TIME_CNT_L,
      trk_time_cnt_h => TRK_TIME_CNT_H,
      irq_mb         => open,
      frame_max      => frame_max,
      track_num      => track_num,
      moment_00      => moment_00,
      moment_01      => moment_01,
      moment_10      => moment_10,
      moment_11      => moment_11,
      moment_02      => moment_02,
      moment_20      => moment_20
    );

  pad_inst : entity work.img_pad
    generic map (
      C_S_IMAGE_SIZE      => C_S_IMAGE_SIZE,
      C_S_AXIS_DATA_WIDTH => C_S_AXIS_DATA_WIDTH
    )
    port map (
      clk           => clk,
      rstn          => rstn,
      power         => power,
      frame_max     => frame_max,
      track_num     => track_num,
      moment_00     => moment_00,
      moment_01     => moment_01,
      moment_10     => moment_10,
      moment_11     => moment_11,
      moment_02     => moment_02,
      moment_20     => moment_20,
      s_axis_tvalid => m_roi_tvalid,
      s_axis_tready => m_roi_tready,
      s_axis_tdata  => m_roi_tdata,
      s_axis_tlast  => m_roi_tlast,
      s_axis_tuser  => m_roi_tuser,
      m_axis_tvalid => open,
      m_axis_tready => '1',
      m_axis_tdata  => open,
      m_axis_tlast  => open,
      m_axis_tuser  => open
    );

end behavioral;