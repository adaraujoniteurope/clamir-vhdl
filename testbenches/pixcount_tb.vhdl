-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : pixcount_tb
-- Description : Test pixel counter from AXI4-Stream data input
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.clamir_pkg.all;

entity pixcount_tb is
end pixcount_tb;

architecture behavioral of pixcount_tb is

  signal clk  : std_logic := '0';
  signal rstn : std_logic := '0';

  signal s_bram_raddr  : std_logic_vector(C_S_BRAM_ADDR_WIDTH-1 downto 0);
  signal s_bram_rdata  : std_logic_vector(C_S_BRAM_DATA_WIDTH-1 downto 0);
  signal s_bram_rready : std_logic;

  signal m_b2a_tvalid  : std_logic;
  signal m_b2a_tready  : std_logic;
  signal m_b2a_tdata   : std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
  signal m_b2a_tlast   : std_logic;
  signal m_b2a_tuser   : std_logic;

  signal row_dbg       : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal col_dbg       : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);

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
    row_dout      => open,
    col_dout      => open
  );

  pix_inst : entity work.pixel_count
    generic map (
      C_S_BRAM_ADDR_WIDTH => C_S_BRAM_ADDR_WIDTH,
      C_S_AXIS_DATA_WIDTH => C_S_AXIS_DATA_WIDTH
    )
    port map (
      clk           => clk,
      rstn          => rstn,
      enable        => '1',
      row_dout      => row_dbg,
      col_dout      => col_dbg,
      s_axis_tvalid => m_b2a_tvalid,
      s_axis_tready => m_b2a_tready,
      s_axis_tdata  => m_b2a_tdata,
      s_axis_tlast  => m_b2a_tlast,
      s_axis_tuser  => m_b2a_tuser,
      m_axis_tvalid => open,
      m_axis_tready => '1',
      m_axis_tdata  => open,
      m_axis_tlast  => open,
      m_axis_tuser  => open
    );

end behavioral;