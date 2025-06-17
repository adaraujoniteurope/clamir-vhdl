-------------------------------------------------------------------------------
-- company     : aimen
-- project     : clamir
-- module      : mom_reg_bank
-- description : image moments calculation axi4-lite configuration registers
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mom_reg_bank is
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
end mom_reg_bank;

architecture behavioral of mom_reg_bank is

  signal bin_threshold_reg  : unsigned(C_S_SENSOR_IMG_RES - 1 downto 0);
  signal intensity_min_reg  : unsigned(31 downto 0);
  signal intensity_max_reg  : unsigned(31 downto 0);
  signal trk_threshold_reg  : unsigned(31 downto 0);
  signal trk_mode_reg       : unsigned(1 downto 0);
  signal trk_time_cnt_l_reg : unsigned(31 downto 0);
  signal trk_time_cnt_h_reg : unsigned(15 downto 0);
  signal trk_start_reg      : unsigned(31 downto 0);
  signal trk_min_mom00_reg  : unsigned(C_S_SENSOR_IMG_RES - 1 downto 0);

  alias axi_addr : std_logic_vector(C_S_AXI_ADDR_WIDTH - 3 downto 0) is slv_addr(slv_addr'left downto 2);

begin

  -----------------------------------------------------------------------------
  -- write logic
  -----------------------------------------------------------------------------
  p_write : process (s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        bin_threshold_reg  <= (others => '0');
        intensity_min_reg  <= (others => '0');
        intensity_max_reg  <= (others => '0');
        trk_threshold_reg  <= (others => '0');
        trk_mode_reg       <= (others => '0');
        trk_time_cnt_l_reg <= (others => '1');
        trk_time_cnt_h_reg <= (others => '0');
        trk_start_reg      <= (others => '0');
        trk_min_mom00_reg  <= (others => '0');
      else
        if (slv_wren = '1') then
          case (to_integer(unsigned(axi_addr))) is
            when 0 => -- binarization threshold
              bin_threshold_reg <= unsigned(slv_wdata(C_S_SENSOR_IMG_RES - 1 downto 0));
            when 1 => -- intensity min value
              intensity_min_reg <= unsigned(slv_wdata);
            when 2 => -- intensity max value
              intensity_max_reg <= unsigned(slv_wdata);
            when 9 => -- tracks threshold
              trk_threshold_reg <= unsigned(slv_wdata);
            when 11 => -- track operational mode
              trk_mode_reg <= unsigned(slv_wdata(1 downto 0));
            when 12 => -- track mode time counter (low)
              trk_time_cnt_l_reg <= unsigned(slv_wdata);
            when 13 => -- track mode time counter (high)
              trk_time_cnt_h_reg <= unsigned(slv_wdata(15 downto 0));
            when 15 => -- reference track from where control is to be started
              trk_start_reg <= unsigned(slv_wdata);
            when 16 => -- minimum moment 00 value to consider laser active
              trk_min_mom00_reg <= unsigned(slv_wdata(C_S_SENSOR_IMG_RES - 1 downto 0));
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- read logic
  -----------------------------------------------------------------------------
  slv_rdata <= std_logic_vector(resize(bin_threshold_reg, 32)) when (to_integer(unsigned(axi_addr)) = 0) else
    std_logic_vector(resize(intensity_min_reg, 32)) when (to_integer(unsigned(axi_addr)) = 1) else
    std_logic_vector(resize(intensity_max_reg, 32)) when (to_integer(unsigned(axi_addr)) = 2) else
    moment_00 when (to_integer(unsigned(axi_addr)) = 3) else
    moment_01 when (to_integer(unsigned(axi_addr)) = 4) else
    moment_10 when (to_integer(unsigned(axi_addr)) = 5) else
    moment_11 when (to_integer(unsigned(axi_addr)) = 6) else
    moment_02 when (to_integer(unsigned(axi_addr)) = 7) else
    moment_20 when (to_integer(unsigned(axi_addr)) = 8) else
    std_logic_vector(resize(trk_threshold_reg, 32)) when (to_integer(unsigned(axi_addr)) = 9) else
    track_num when (to_integer(unsigned(axi_addr)) = 10) else
    std_logic_vector(resize(trk_mode_reg, 32)) when (to_integer(unsigned(axi_addr)) = 11) else
    std_logic_vector(resize(trk_time_cnt_l_reg, 32)) when (to_integer(unsigned(axi_addr)) = 12) else
    std_logic_vector(resize(trk_time_cnt_h_reg, 32)) when (to_integer(unsigned(axi_addr)) = 13) else
    frame_max when (to_integer(unsigned(axi_addr)) = 14) else
    std_logic_vector(resize(trk_start_reg, 32)) when (to_integer(unsigned(axi_addr)) = 15) else
    std_logic_vector(resize(trk_min_mom00_reg, 32)) when (to_integer(unsigned(axi_addr)) = 16) else
    (others => '0');

  -----------------------------------------------------------------------------
  -- read/write done flags
  -----------------------------------------------------------------------------
  slv_rd_done <= slv_rden;
  slv_wr_done <= slv_wren;

  -----------------------------------------------------------------------------
  -- assign output values
  -----------------------------------------------------------------------------
  bin_threshold_out  <= std_logic_vector(bin_threshold_reg);
  intensity_min_out  <= std_logic_vector(intensity_min_reg);
  intensity_max_out  <= std_logic_vector(intensity_max_reg);
  trk_threshold_out  <= std_logic_vector(trk_threshold_reg);
  trk_mode_out       <= std_logic_vector(trk_mode_reg);
  trk_time_cnt_l_out <= std_logic_vector(trk_time_cnt_l_reg);
  trk_time_cnt_h_out <= std_logic_vector(trk_time_cnt_h_reg);
  trk_start_out      <= std_logic_vector(trk_start_reg);
  trk_min_mom00_out  <= std_logic_vector(trk_min_mom00_reg);

end;