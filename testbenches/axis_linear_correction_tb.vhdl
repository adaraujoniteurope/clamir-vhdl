library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity axis_linear_correction_tb is
  generic (
    
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32;

    IMAGE_WIDTH  : integer := 4;
    IMAGE_HEIGHT : integer := 4
  );
end entity;

architecture testbench of axis_linear_correction_tb is

  component mm_pattern_generator IS
    generic (
        MEMORY_LENGTH : integer := IMAGE_WIDTH*IMAGE_HEIGHT;
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        DEFAULT_VALUE : integer := 0
    );

    port (
        aclk : in std_logic := '0';
        arstn : in std_logic := '0';

        port_b_addr : inout std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
        port_b_wren : inout std_logic := '0';
        port_b_data : inout std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0')
    );
  end component;

  component mm_axis_bridge is
    generic
    (
        DATA_FRAME_LENGTH   : integer := IMAGE_WIDTH*IMAGE_HEIGHT;
        DATA_USER_LENGTH    : integer := 44;

        ADDR_WIDTH : integer := ADDR_WIDTH;
        DATA_WIDTH : integer := DATA_WIDTH
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        port_a_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_a_wren : in std_logic := '0';
        port_a_data : inout std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

        axis_out_tdata  : inout std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0) := (others => '0' );
        axis_out_tvalid : inout std_logic := '0';
        axis_out_tuser  : inout std_logic := '0';
        axis_out_tready : in  std_logic := '0'

    );

  end component;

  component axis_mm_bridge is
    generic
    (
        DATA_FRAME_LENGTH   : integer := IMAGE_WIDTH*IMAGE_HEIGHT;
        DATA_USER_LENGTH    : integer := 44;

        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        axis_in_tdata  : in std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0) := (others => '0' );
        axis_in_tvalid : in std_logic := '0';
        axis_in_tuser  : in std_logic := '0';
        axis_in_tready : out  std_logic := '0';

        port_a_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_a_wren : out std_logic := '0';
        port_a_data : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' )

    );

  end component;

  component dual_port_sram

  generic
  (
      MEMORY_LENGTH  : integer := IMAGE_WIDTH*IMAGE_HEIGHT;
      ADDR_WIDTH : integer := ADDR_WIDTH;
      DATA_WIDTH : integer := DATA_WIDTH;
      DEFAULT_VALUE : integer := 0
  );

  port (

      aclk  : in std_logic := '0';
      arstn : in std_logic := '0';

      port_a_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
      port_a_wren : in std_logic := '0';
      port_a_data : inout std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

      port_b_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
      port_b_wren : in std_logic := '0';
      port_b_data : inout std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' )

  );

end component;

  component axis_linear_correction
    generic (
      ADDR_WIDTH : integer := ADDR_WIDTH;
      DATA_WIDTH : integer := DATA_WIDTH
    );

    port (

      aclk  : in std_logic := '0';
      arstn : in std_logic := '0';

      scale_addr : inout std_logic_vector(31 downto 0) := (others => '0');
      scale_data : in std_logic_vector(31 downto 0) := (others => '0');
    
      offset_addr : inout std_logic_vector(31 downto 0) := (others => '0');
      offset_data : in std_logic_vector(31 downto 0) := (others => '0');

      axis_in_tdata  : in std_logic_vector(ADDR_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0');
      axis_in_tuser  : in std_logic := '0';
      axis_in_tvalid : in std_logic := '0';
      axis_in_tready : out std_logic := '0';

      axis_out_tdata  : inout std_logic_vector(ADDR_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0');
      axis_out_tuser  : out std_logic := '0';
      axis_out_tvalid : out std_logic := '0';
      axis_out_tready : in std_logic := '0'

    );

  end component;

  signal aclk  : std_logic := '0';
  signal arstn : std_logic := '0';

  signal scale_sram_port_a_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal scale_sram_port_a_wren : std_logic := '0';
  signal scale_sram_port_a_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal scale_sram_port_b_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal scale_sram_port_b_wren : std_logic := '0';
  signal scale_sram_port_b_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal offset_sram_port_a_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal offset_sram_port_a_wren : std_logic := '0';
  signal offset_sram_port_a_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal offset_sram_port_b_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal offset_sram_port_b_wren : std_logic := '0';
  signal offset_sram_port_b_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal image_sram_port_a_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal image_sram_port_a_wren : std_logic := '0';
  signal image_sram_port_a_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal image_sram_port_b_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal image_sram_port_b_wren : std_logic := '0';
  signal image_sram_port_b_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal pattern_generator_port_b_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
  signal pattern_generator_port_b_wren : std_logic := '0';
  signal pattern_generator_port_b_data : std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

  signal axis_in_tdata  : std_logic_vector (ADDR_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0');
  signal axis_in_tuser : std_logic := '0';
  signal axis_in_tvalid : std_logic := '0';
  signal axis_in_tready : std_logic := '0';

  signal axis_out_tdata  : std_logic_vector (ADDR_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0');
  signal axis_out_tuser : std_logic := '0';
  signal axis_out_tvalid : std_logic := '0';
  signal axis_out_tready : std_logic := '0';

  type axis_process_state_type is (
    AXIS_STATE_IDLE
  );

  signal axis_process_state : axis_process_state_type := AXIS_STATE_IDLE;

begin

  pattern_generator : mm_pattern_generator
  generic map(
    MEMORY_LENGTH => IMAGE_WIDTH * IMAGE_HEIGHT,
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH,
    DEFAULT_VALUE => 0
  )
  port map(
    aclk => aclk,
    arstn => arstn,

    port_b_addr => pattern_generator_port_b_addr,
    port_b_wren => pattern_generator_port_b_wren,
    port_b_data => pattern_generator_port_b_data
  );

  mm_axis_bridge_0 : mm_axis_bridge
  generic map(
    DATA_FRAME_LENGTH   => IMAGE_WIDTH*IMAGE_HEIGHT,
    DATA_USER_LENGTH    => 44,
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    aclk  => aclk,
    arstn => arstn,

    port_a_addr => pattern_generator_port_b_addr,
    port_a_wren => pattern_generator_port_b_wren,
    port_a_data => pattern_generator_port_b_data,

    axis_out_tdata  => axis_in_tdata,
    axis_out_tvalid => axis_in_tvalid,
    axis_out_tuser  => axis_in_tuser,
    axis_out_tready => axis_in_tready

  );

  axis_mm_bridge_0 : axis_mm_bridge
  generic map(
    DATA_FRAME_LENGTH   => IMAGE_WIDTH*IMAGE_HEIGHT,
    DATA_USER_LENGTH    => 44,

    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH
  )
  port map(

    aclk  => aclk,
    arstn => arstn,

    port_a_addr => image_sram_port_a_addr,
    port_a_wren => image_sram_port_a_wren,
    port_a_data => image_sram_port_a_data,

    axis_in_tdata  => axis_out_tdata,
    axis_in_tvalid => axis_out_tvalid,
    axis_in_tuser  => axis_out_tuser,
    axis_in_tready => axis_out_tready

  );

  scale_sram : dual_port_sram

  generic map
  (
    MEMORY_LENGTH => IMAGE_WIDTH*IMAGE_HEIGHT,
    DEFAULT_VALUE => 16384
  )

  port map
  (

    aclk  => aclk,
    arstn => arstn,

    port_a_addr => scale_sram_port_a_addr,
    port_a_wren => scale_sram_port_a_wren,
    port_a_data => scale_sram_port_a_data,

    port_b_addr => scale_sram_port_b_addr,
    port_b_wren => scale_sram_port_b_wren,
    port_b_data => scale_sram_port_b_data

  );

  offset_sram : dual_port_sram
  generic map
  (
    -- MEMORY_LENGTH  => 4096,
    -- ADDR_WIDTH => 32;
    -- DATA_WIDTH => 32;
    DEFAULT_VALUE => 0
  )
  port map
  (
    aclk  => aclk,
    arstn => arstn,

    port_a_addr => offset_sram_port_a_addr,
    port_a_wren => offset_sram_port_a_wren,
    port_a_data => offset_sram_port_a_data,

    port_b_addr => offset_sram_port_b_addr,
    port_b_wren => offset_sram_port_b_wren,
    port_b_data => offset_sram_port_b_data

  );

  image_sram : dual_port_sram
  generic map
  (
    -- MEMORY_LENGTH  => 4096,
    -- ADDR_WIDTH => 32;
    -- DATA_WIDTH => 32;
    DEFAULT_VALUE => 0
  )
  port map
  (
    aclk  => aclk,
    arstn => arstn,

    port_a_addr => image_sram_port_a_addr,
    port_a_wren => image_sram_port_a_wren,
    port_a_data => image_sram_port_a_data,

    port_b_addr => image_sram_port_b_addr,
    port_b_wren => image_sram_port_b_wren,
    port_b_data => image_sram_port_b_data

  );

  dut : axis_linear_correction
  generic map
  (
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH
  )
  port map
  (
    aclk => aclk,
    arstn => arstn,

    scale_addr => scale_sram_port_b_addr,
    scale_data => scale_sram_port_b_data,

    offset_addr => offset_sram_port_b_addr,
    offset_data => offset_sram_port_b_data,

    axis_in_tdata => axis_in_tdata,
    axis_in_tuser => axis_in_tuser,
    axis_in_tvalid => axis_in_tvalid,
    axis_in_tready => axis_in_tready,

    axis_out_tdata => axis_out_tdata,
    axis_out_tuser => axis_out_tuser,
    axis_out_tvalid => axis_out_tvalid,
    axis_out_tready => axis_out_tready

  );

  aclk <= not aclk after 1 ns;

  process begin
    arstn <= '1' after 1 ns;
    axis_out_tready <= '1' after 2 ns;
    wait;
  end process;

end;