-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : tb_img_mom
-- Description : Test image moments calculation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.clamir_pkg.all;

entity tb_img_mom is
end tb_img_mom;

architecture behavioral of tb_img_mom is

  constant X1_REG        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned( 7, (C_S_BRAM_ADDR_WIDTH/2)));
  constant X2_REG        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned(56, (C_S_BRAM_ADDR_WIDTH/2)));
  constant Y1_REG        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned( 7, (C_S_BRAM_ADDR_WIDTH/2)));
  constant Y2_REG        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0) := std_logic_vector(to_unsigned(56, (C_S_BRAM_ADDR_WIDTH/2)));

  constant BIN_THRESHOLD : std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0) := std_logic_vector(to_unsigned(255, C_S_SENSOR_IMG_RES));

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
  signal m_roi_tdata    : std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
  signal m_roi_tlast    : std_logic;
  signal m_roi_tuser    : std_logic;

  signal row_roi        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal col_roi        : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);

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

  mom_inst : entity work.binarize
    generic map (
      C_S_BRAM_ADDR_WIDTH => C_S_BRAM_ADDR_WIDTH,
      C_S_AXIS_DATA_WIDTH => C_S_AXIS_DATA_WIDTH,
      C_S_SENSOR_IMG_RES  => C_S_SENSOR_IMG_RES
    )
    port map (
      clk           => clk,
      rstn          => rstn,
      s_axis_tvalid => m_roi_tvalid,
      s_axis_tready => open,
      s_axis_tdata  => m_roi_tdata,
      s_axis_tlast  => m_roi_tlast,
      s_axis_tuser  => m_roi_tuser,
      row_din       => row_roi,
      col_din       => col_roi,
      threshold     => BIN_THRESHOLD,
      irq_mb        => open,
      frame_max     => open,
      moment_00     => open,
      moment_01     => open,
      moment_10     => open,
      moment_11     => open,
      moment_02     => open,
      moment_20     => open
    );

end behavioral;