library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.memory_mapped_streaming.all;
use work.memory.all;

entity mm_memory_reader_tb is
  generic (
    addr_width   : integer := 32;
    data_width   : integer := 16;
    frame_length : integer := 16
  );
end mm_memory_reader_tb;

architecture impl of mm_memory_reader_tb is

  signal aclk    : std_logic := '0';
  signal arstn   : std_logic := '0';
  signal ap_done : std_logic := '0';

  signal src_bram_clk_a  : std_logic                                   := '0';
  signal src_bram_rst_a  : std_logic                                   := '0';
  signal src_bram_en_a   : std_logic                                   := '0';
  signal src_bram_we_a   : std_logic_vector(data_width/8 - 1 downto 0) := (others => '0');
  signal src_bram_addr_a : std_logic_vector(addr_width - 1 downto 0)   := (others => '0');
  signal src_bram_di_a   : std_logic_vector(data_width - 1 downto 0)   := (others => '0');
  signal src_bram_do_a   : std_logic_vector(data_width - 1 downto 0)   := (others => '0');

  signal src_bram_clk_b  : std_logic                                   := '0';
  signal src_bram_rst_b  : std_logic                                   := '0';
  signal src_bram_en_b   : std_logic                                   := '0';
  signal src_bram_we_b   : std_logic_vector(data_width/8 - 1 downto 0) := (others => '0');
  signal src_bram_addr_b : std_logic_vector(addr_width - 1 downto 0)   := (others => '0');
  signal src_bram_di_b   : std_logic_vector(data_width - 1 downto 0)   := (others => '0');
  signal src_bram_do_b   : std_logic_vector(data_width - 1 downto 0)   := (others => '0');

  signal y_mm_addr : std_logic_vector(addr_width - 1 downto 0) := (others => '0');
  signal y_mm_wren : std_logic                                 := '0';
  signal y_mm_data : std_logic_vector(data_width - 1 downto 0) := (others => '0');

  signal intr : std_logic := '0';

  shared variable data_byte_count : integer := integer(real(data_width)/8.0);

  type state_type is
  (
    STATE_INITIAL,
    STATE_LOAD_DATA_START,
    STATE_LOAD_DATA,
    STATE_LOAD_DATA_END,
    STATE_PROCESS_START,
    STATE_PROCESS,
    STATE_PROCESS_END,
    STATE_FINAL
  );

  signal state : state_type := STATE_INITIAL;

begin

  aclk           <= not aclk after 10 ns;
  src_bram_clk_a <= aclk;

  process_stimulus : process (aclk)
  begin
    arstn <= '1' after 10 ns;
  end process;

  process_state_machine : process (aclk)
  begin
    if rising_edge(aclk) then

      case(state) is
        when STATE_INITIAL =>
        state <= STATE_LOAD_DATA_START;

        when STATE_LOAD_DATA_START =>
        src_bram_en_a   <= '1';
        src_bram_we_a   <= (others => '1');
        src_bram_addr_a <= (others => '0');
        src_bram_di_a   <= (others => '0');
        state           <= STATE_LOAD_DATA;

        when STATE_LOAD_DATA =>
        if (src_bram_addr_a < frame_length * data_byte_count) then
          src_bram_addr_a <= src_bram_addr_a + data_byte_count;
          src_bram_di_a   <= src_bram_di_a + 1;
        else
          state <= STATE_LOAD_DATA_END;
        end if;

        when STATE_LOAD_DATA_END   =>
        src_bram_we_a   <= (others => '0');
        src_bram_en_a   <= '0';
        src_bram_addr_a <= (others => '0');
        src_bram_di_a   <= (others => '0');

        if (ap_done = '1') then
          ap_done     <= '0';
          state       <= STATE_PROCESS_START;
        else
          ap_done <= '1';
        end if;

        when STATE_PROCESS_START =>
        state <= STATE_PROCESS;

        when STATE_PROCESS =>
        state <= STATE_PROCESS_END;

        when STATE_PROCESS_END =>
        state <= STATE_FINAL;

        when STATE_FINAL =>
        when others      =>
      end case;
    end if;
  end process;

  mm_memory_reader_inst0 : mm_memory_reader
  generic map(
    addr_width => addr_width,
    data_width => data_width
  )
  port map
  (
    aclk  => aclk,
    arstn => arstn,

    ap_start => ap_done,

    a_bram_clk  => src_bram_clk_b,
    a_bram_rst  => src_bram_rst_b,
    a_bram_en   => src_bram_en_b,
    a_bram_we   => src_bram_we_b,
    a_bram_addr => src_bram_addr_b,
    a_bram_din  => src_bram_di_b,
    a_bram_dout => src_bram_do_b,

    y_mm_addr => y_mm_addr,
    y_mm_wren => y_mm_wren,
    y_mm_data => y_mm_data,

    intr => intr
  );

  dual_port_sram_inst0 : dual_port_sram

  generic map(
    addr_width => addr_width,
    data_width => data_width
  )

  port map
  (
    clka  => src_bram_clk_a,
    ena   => src_bram_en_a,
    wea   => src_bram_we_a,
    addra => src_bram_addr_a,
    dia   => src_bram_di_a,
    doa   => src_bram_do_a,

    clkb  => src_bram_clk_b,
    enb   => src_bram_en_b,
    web   => src_bram_we_b,
    addrb => src_bram_addr_b,
    dib   => src_bram_di_b,
    dob   => src_bram_do_b
  );

end impl;
