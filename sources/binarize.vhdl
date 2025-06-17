-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : binarize
-- Description : Image moments calculation based on threshold binarization
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binarize is
  generic (
    -- BRAM Address width
    C_S_BRAM_ADDR_WIDTH : natural;
    -- AXI4-Stream Data width
    C_S_AXIS_DATA_WIDTH : natural;
    -- Sensor image resolution (bits per pixel)
    C_S_SENSOR_IMG_RES  : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- Common ports
    ---------------------------------------------------------------------------
    clk           : in  std_logic;
    rstn          : in  std_logic;
    ---------------------------------------------------------------------------
    -- AXI4-Stream slave ports
    ---------------------------------------------------------------------------
    s_axis_tvalid : in  std_logic;
    s_axis_tready : out std_logic;
    s_axis_tdata  : in  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
    s_axis_tlast  : in  std_logic;
    s_axis_tuser  : in  std_logic;
    ---------------------------------------------------------------------------
    -- Pixel location - DIN
    ---------------------------------------------------------------------------
    row_din       : in  std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    col_din       : in  std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    ---------------------------------------------------------------------------
    -- Configuration registers
    ---------------------------------------------------------------------------
    threshold     : in  std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0);
    ---------------------------------------------------------------------------
    -- Moments and frame data, block status
    ---------------------------------------------------------------------------
    irq_mb        : out std_logic;
    frame_max     : out std_logic_vector(31 downto 0);
    moment_00     : out std_logic_vector(31 downto 0);
    moment_01     : out std_logic_vector(31 downto 0);
    moment_10     : out std_logic_vector(31 downto 0);
    moment_11     : out std_logic_vector(31 downto 0);
    moment_02     : out std_logic_vector(31 downto 0);
    moment_20     : out std_logic_vector(31 downto 0)
  );
end binarize;

architecture behavioral of binarize is

  type fsm_t is (WAIT_TVALID, CALC_MOMENT, UPDATE_MOMENT);

  signal fsm           : fsm_t;
  signal binary        : unsigned( 0 downto 0);
  signal pd_row        : unsigned(C_S_BRAM_ADDR_WIDTH-1 downto 0);
  signal pd_col        : unsigned(C_S_BRAM_ADDR_WIDTH-1 downto 0);
  signal pd_rmc        : unsigned(C_S_BRAM_ADDR_WIDTH-1 downto 0);
  signal row           : unsigned((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal col           : unsigned((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal temp_m00      : unsigned(31 downto 0);
  signal temp_m10      : unsigned(31 downto 0);
  signal temp_m01      : unsigned(31 downto 0);
  signal temp_m11      : unsigned(31 downto 0);
  signal temp_m20      : unsigned(31 downto 0);
  signal temp_m02      : unsigned(31 downto 0);
  signal asin_temp_m00 : unsigned(31 downto 0);
  signal asin_temp_m10 : unsigned(31 downto 0);
  signal asin_temp_m01 : unsigned(31 downto 0);
  signal temp_max      : std_logic_vector(15 downto 0);

  alias axis_tdata : std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0) is s_axis_tdata(C_S_SENSOR_IMG_RES-1 downto 0);

begin

  p_axi : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        s_axis_tready <= '0';
      else
        s_axis_tready <= '1';
      end if;
    end if;
  end process;

  -- Cast pixel row/col info
  row <= unsigned(row_din);
  col <= unsigned(col_din);

  binary(0) <= '1' when (signed(axis_tdata) > signed('0' & threshold)) else '0';

  pd_row <= row * row;
  pd_col <= col * col;
  pd_rmc <= row * col;

  asin_temp_m00 <= temp_m00 + 1;
  asin_temp_m10 <= temp_m10 + row;
  asin_temp_m01 <= temp_m01 + col;

  p_mom : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        fsm       <= WAIT_TVALID;
        temp_m00  <= (others => '0');
        temp_m01  <= (others => '0');
        temp_m10  <= (others => '0');
        temp_m11  <= (others => '0');
        temp_m02  <= (others => '0');
        temp_m20  <= (others => '0');
        moment_00 <= (others => '0');
        moment_10 <= (others => '0');
        moment_01 <= (others => '0');
        moment_11 <= (others => '0');
        moment_20 <= (others => '0');
        moment_02 <= (others => '0');
        temp_max  <= (others => '0');
        frame_max <= (others => '0');
      else
        case (fsm) is
          -- Wait until valid data received, start moments computation
          when WAIT_TVALID =>
            temp_m00 <= resize(binary, temp_m00'length);
            temp_m10 <= (others => '0');
            temp_m01 <= (others => '0');
            temp_m11 <= (others => '0');
            temp_m20 <= (others => '0');
            temp_m02 <= (others => '0');
            temp_max <= (others => '0');
            if (s_axis_tvalid = '1') then
              fsm <= CALC_MOMENT;
            end if;
          -- Moment calculation until EOF (tuser) pulse received
          when CALC_MOMENT =>
            if ((s_axis_tvalid = '1') and (binary(0) = '1')) then
              temp_m00 <= asin_temp_m00;
              temp_m10 <= asin_temp_m10;
              temp_m01 <= asin_temp_m01;
              temp_m11 <= temp_m11 + pd_rmc;
              temp_m20 <= temp_m20 + pd_row;
              temp_m02 <= temp_m02 + pd_col;
            end if;

            if ((s_axis_tvalid = '1') and (signed(axis_tdata) > signed('0' & temp_max))) then
              temp_max <= s_axis_tdata;
            end if;

            if (s_axis_tuser = '1') then
              fsm <= UPDATE_MOMENT;
            end if;
          -- Register calculated moments
          when UPDATE_MOMENT =>
            fsm       <= WAIT_TVALID;
            moment_00 <= std_logic_vector(temp_m00);
            moment_10 <= std_logic_vector(temp_m10);
            moment_01 <= std_logic_vector(temp_m01);
            moment_11 <= std_logic_vector(temp_m11);
            moment_20 <= std_logic_vector(temp_m20);
            moment_02 <= std_logic_vector(temp_m02);
            frame_max <= std_logic_vector(x"0000" & temp_max);
          when others =>
            -- Shouldn't enter this state
            fsm <= WAIT_TVALID;
        end case;
      end if;
    end if;
  end process;

  -- EOF indicator forwarded to MicroBlaze as moments calculation ready IRQ flag
  p_irq : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        irq_mb <= '0';
      else
        -- Delay one cycle to match UPDATE_MOMENT latency
        irq_mb <= s_axis_tuser;
      end if;
    end if;
  end process;

end behavioral;