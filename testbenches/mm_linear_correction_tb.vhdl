library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity mm_linear_correction_tb is
  generic (

    addr_width : integer := 32;
    data_width : integer := 32;

    image_width : integer := 2;
    image_height : integer := 2
  );
end entity;

architecture testbench of mm_linear_correction_tb is

  component mm_pattern_generator is
    generic (
      memory_length : integer := image_width * image_height;
      addr_width : integer := 32;
      data_width : integer := 32;
      default_value : integer := 0
    );

    port (
      aclk : in std_logic := '0';
      arstn : in std_logic := '0';

      out_addr : inout std_logic_vector(addr_width - 1 downto 0) := (others => '0');
      out_wren : inout std_logic := '0';
      out_data : inout std_logic_vector(data_width - 1 downto 0) := (others => '0')
    );
  end component;

  component xilinx_block_ram

    generic (
      memory_length : integer := image_width * image_height;
      addr_width : integer := addr_width;
      data_width : integer := data_width;
      memory_initialization_file : string
    );

    port (
      port_a_clk : in std_logic;
      port_a_rst : in std_logic;
      port_a_ena : in std_logic;
      port_a_wea : in std_logic;
      port_a_addr : in std_logic_vector(addr_width - 1 downto 0);
      port_a_din : in std_logic_vector(data_width - 1 downto 0);
      port_a_dout : out std_logic_vector(data_width - 1 downto 0);

      port_b_clk : in std_logic := '0';
      port_b_rst : in std_logic := '0';
      port_b_ena : in std_logic := '0';
      port_b_wea : in std_logic := '0';
      port_b_addr : in std_logic_vector(addr_width - 1 downto 0);
      port_b_din : in std_logic_vector(data_width - 1 downto 0);
      port_b_dout : out std_logic_vector(data_width - 1 downto 0)
    );

  end component;

  component mm_linear_correction
    generic (
      addr_width : integer := addr_width;
      data_width : integer := data_width
    );

    port (

      aclk : in std_logic := '0';
      arstn : in std_logic := '0';

      scale_bram_clk : out std_logic := '0';
      scale_bram_rst : out std_logic := '0';
      scale_bram_ena : out std_logic := '1';
      scale_bram_wea : out std_logic := '0';
      scale_bram_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
      scale_bram_din : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
      scale_bram_dout : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

      offset_bram_clk : out std_logic := '0';
      offset_bram_rst : out std_logic := '0';
      offset_bram_ena : out std_logic := '1';
      offset_bram_wea : out std_logic := '0';
      offset_bram_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
      offset_bram_din : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
      offset_bram_dout : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

      in_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := (others => '0');
      in_mm_wren : in std_logic := '0';
      in_mm_data : in std_logic_vector(data_width - 1 downto 0) := (others => '0');

      out_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
      out_mm_wren : out std_logic := '0';
      out_mm_data : out std_logic_vector(data_width - 1 downto 0) := (others => '0')

    );

  end component;

  signal aclk : std_logic := '0';
  signal arstn : std_logic := '0';

  signal scale_sram_port_a_clk : std_logic := '0';
  signal scale_sram_port_a_rst : std_logic := '0';
  signal scale_sram_port_a_ena : std_logic := '0';
  signal scale_sram_port_a_wea : std_logic := '0';
  signal scale_sram_port_a_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal scale_sram_port_a_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal scale_sram_port_a_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal scale_sram_port_b_clk : std_logic := '0';
  signal scale_sram_port_b_rst : std_logic := '0';
  signal scale_sram_port_b_ena : std_logic := '0';
  signal scale_sram_port_b_wea : std_logic := '0';
  signal scale_sram_port_b_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal scale_sram_port_b_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal scale_sram_port_b_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal offset_sram_port_a_clk : std_logic := '0';
  signal offset_sram_port_a_rst : std_logic := '0';
  signal offset_sram_port_a_ena : std_logic := '0';
  signal offset_sram_port_a_wea : std_logic := '0';
  signal offset_sram_port_a_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal offset_sram_port_a_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal offset_sram_port_a_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal offset_sram_port_b_clk : std_logic := '0';
  signal offset_sram_port_b_rst : std_logic := '0';
  signal offset_sram_port_b_ena : std_logic := '0';
  signal offset_sram_port_b_wea : std_logic := '0';
  signal offset_sram_port_b_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal offset_sram_port_b_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal offset_sram_port_b_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal image_sram_port_a_clk : std_logic := '0';
  signal image_sram_port_a_rst : std_logic := '0';
  signal image_sram_port_a_ena : std_logic := '0';
  signal image_sram_port_a_wea : std_logic := '0';
  signal image_sram_port_a_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal image_sram_port_a_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal image_sram_port_a_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal image_sram_port_b_clk : std_logic := '0';
  signal image_sram_port_b_rst : std_logic := '0';
  signal image_sram_port_b_ena : std_logic := '0';
  signal image_sram_port_b_wea : std_logic := '0';
  signal image_sram_port_b_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal image_sram_port_b_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal image_sram_port_b_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal pattern_generator_out_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal pattern_generator_out_wren : std_logic := '0';
  signal pattern_generator_out_data : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal dut_mm_scale_bram_clk : std_logic := '0';
  signal dut_mm_scale_bram_rst : std_logic := '0';
  signal dut_mm_scale_bram_ena : std_logic := '0';
  signal dut_mm_scale_bram_wea : std_logic := '0';
  signal dut_mm_scale_bram_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal dut_mm_scale_bram_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal dut_mm_scale_bram_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal dut_mm_offset_bram_clk : std_logic := '0';
  signal dut_mm_offset_bram_rst : std_logic := '0';
  signal dut_mm_offset_bram_ena : std_logic := '0';
  signal dut_mm_offset_bram_wea : std_logic := '0';
  signal dut_mm_offset_bram_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal dut_mm_offset_bram_din : std_logic_vector(data_width - 1 downto 0) := (others => '0');
  signal dut_mm_offset_bram_dout : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal dut_mm_in_addr : std_logic_vector (addr_width - 1 downto 0) := (others => '0');
  signal dut_mm_in_wren : std_logic := '0';
  signal dut_mm_in_data : std_logic_vector (data_width - 1 downto 0) := (others => '0');

  signal dut_mm_out_addr : std_logic_vector (addr_width - 1 downto 0) := (others => '0');
  signal dut_mm_out_wren : std_logic := '0';
  signal dut_mm_out_data : std_logic_vector (data_width - 1 downto 0) := (others => '0');

begin

  pattern_generator : mm_pattern_generator
  generic map(
    memory_length => image_width * image_height,
    addr_width => addr_width,
    data_width => data_width,
    default_value => 0
  )
  port map(
    aclk => aclk,
    arstn => arstn,

    out_addr => pattern_generator_out_addr,
    out_wren => pattern_generator_out_wren,
    out_data => pattern_generator_out_data
  );

  scale_sram : xilinx_block_ram

  generic map
  (
    memory_length => image_width * image_height,
    memory_initialization_file => "coefficients/scale.txt"
  )

  port map
  (
    port_a_clk => scale_sram_port_a_clk,
    port_a_rst => scale_sram_port_a_rst,
    port_a_ena => scale_sram_port_a_ena,
    port_a_wea => scale_sram_port_a_wea,
    port_a_addr => scale_sram_port_a_addr,
    port_a_din => scale_sram_port_a_din,
    port_a_dout => scale_sram_port_a_dout,

    port_b_clk => scale_sram_port_b_clk,
    port_b_rst => scale_sram_port_b_rst,
    port_b_ena => scale_sram_port_b_ena,
    port_b_wea => scale_sram_port_b_wea,
    port_b_addr => scale_sram_port_b_addr,
    port_b_din => scale_sram_port_b_din,
    port_b_dout => scale_sram_port_b_dout

  );

  offset_sram : xilinx_block_ram
  generic map
  (
    memory_length => image_width * image_height,
    memory_initialization_file => "coefficients/offset.txt"
  )
  port map
  (
    port_a_clk => offset_sram_port_a_clk,
    port_a_rst => offset_sram_port_a_rst,
    port_a_ena => offset_sram_port_a_ena,
    port_a_wea => offset_sram_port_a_wea,
    port_a_addr => offset_sram_port_a_addr,
    port_a_din => offset_sram_port_a_din,
    port_a_dout => offset_sram_port_a_dout,

    port_b_clk => offset_sram_port_b_clk,
    port_b_rst => offset_sram_port_b_rst,
    port_b_ena => offset_sram_port_b_ena,
    port_b_wea => offset_sram_port_b_wea,
    port_b_addr => offset_sram_port_b_addr,
    port_b_din => offset_sram_port_b_din,
    port_b_dout => offset_sram_port_b_dout

  );

  dut_mm_in_addr <= pattern_generator_out_addr;
  dut_mm_in_wren <= pattern_generator_out_wren;
  dut_mm_in_data <= pattern_generator_out_data;

  scale_sram_port_a_clk <= dut_mm_scale_bram_clk;
  scale_sram_port_a_ena <= dut_mm_scale_bram_ena;
  scale_sram_port_a_wea <= dut_mm_scale_bram_wea;
  scale_sram_port_a_addr <= dut_mm_scale_bram_addr;
  scale_sram_port_a_din <= dut_mm_scale_bram_dout;
  dut_mm_scale_bram_din <= scale_sram_port_a_dout;

  offset_sram_port_a_clk <= dut_mm_offset_bram_clk;
  offset_sram_port_a_ena <= dut_mm_offset_bram_ena;
  offset_sram_port_a_wea <= dut_mm_offset_bram_wea;
  offset_sram_port_a_addr <= dut_mm_offset_bram_addr;
  offset_sram_port_a_din <= dut_mm_offset_bram_dout;
  dut_mm_offset_bram_din <= offset_sram_port_a_dout;

  dut : mm_linear_correction
  generic map
  (
    addr_width => addr_width,
    data_width => data_width
  )
  port map
  (
    aclk => aclk,
    arstn => arstn,

    scale_bram_clk => dut_mm_scale_bram_clk,
    scale_bram_rst => dut_mm_scale_bram_rst,
    scale_bram_ena => dut_mm_scale_bram_ena,
    scale_bram_wea => dut_mm_scale_bram_wea,
    scale_bram_addr => dut_mm_scale_bram_addr,
    scale_bram_din => dut_mm_scale_bram_din,
    scale_bram_dout => dut_mm_scale_bram_dout,

    offset_bram_clk => dut_mm_offset_bram_clk,
    offset_bram_rst => dut_mm_offset_bram_rst,
    offset_bram_ena => dut_mm_offset_bram_ena,
    offset_bram_wea => dut_mm_offset_bram_wea,
    offset_bram_addr => dut_mm_offset_bram_addr,
    offset_bram_din => dut_mm_offset_bram_din,
    offset_bram_dout => dut_mm_offset_bram_dout,

    in_mm_addr => dut_mm_in_addr,
    in_mm_wren => dut_mm_in_wren,
    in_mm_data => dut_mm_in_data,

    out_mm_addr => dut_mm_out_addr,
    out_mm_wren => dut_mm_out_wren,
    out_mm_data => dut_mm_out_data

  );

  image_sram : xilinx_block_ram
  generic map
  (
    memory_length => image_width * image_height,
    memory_initialization_file => "coefficients/image.txt"
  )
  port map
  (
    port_a_clk => image_sram_port_a_clk,
    port_a_rst => image_sram_port_a_rst,
    port_a_ena => image_sram_port_a_ena,
    port_a_wea => image_sram_port_a_wea,
    port_a_addr => image_sram_port_a_addr,
    port_a_din => image_sram_port_a_din,
    port_a_dout => image_sram_port_a_dout,

    port_b_clk => image_sram_port_b_clk,
    port_b_rst => image_sram_port_b_rst,
    port_b_ena => image_sram_port_b_ena,
    port_b_wea => image_sram_port_b_wea,
    port_b_addr => image_sram_port_b_addr,
    port_b_din => image_sram_port_b_din,
    port_b_dout => image_sram_port_b_dout
  );

  aclk <= not aclk after 1 ns;

  process begin
    arstn <= '1' after 1 ns;
    wait;
  end process;

end;