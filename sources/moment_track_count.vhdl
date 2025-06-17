-------------------------------------------------------------------------------
-- company     : aimen
-- project     : clamir
-- module      : moment_top
-- description : calculate current tracks depending on operational mode
--               mode:  0 - continuous / 1 - auto tracks
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.misc.all;

entity moment_track_count is
  generic (
    -- sensor image resolution (bits per pixel)
    C_S_SENSOR_IMG_RES : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- common ports
    ---------------------------------------------------------------------------
    clk         : in  std_logic;
    rstn        : in  std_logic;
    ---------------------------------------------------------------------------
    -- configuration
    ---------------------------------------------------------------------------
    mode        : in  std_logic_vector(1 downto 0);
    change_mode : in  std_logic;
    time_cnt    : in  std_logic_vector(47 downto 0);
    ---------------------------------------------------------------------------
    -- moments
    ---------------------------------------------------------------------------
    moment_00   : in  std_logic_vector(31 downto 0);
    threshold   : in  std_logic_vector(31 downto 0);
    track_start : in  std_logic_vector(31 downto 0);
    min_mom00   : in  std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0);
    ---------------------------------------------------------------------------
    -- track count
    ---------------------------------------------------------------------------
    tracks      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture behavioral of moment_track_count is

  signal en_timer  : std_logic;
  signal timeout   : std_logic;
  signal track_num : unsigned(31 downto 0);
  signal mode_i    : std_logic_vector( 1 downto 0);
  signal en_tracks : std_logic_vector( 1 downto 0);
  signal thrs_i    : std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0);

  alias mom00 : std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0) is moment_00(C_S_SENSOR_IMG_RES-1 downto 0);
  alias thres : std_logic_vector(C_S_SENSOR_IMG_RES-1 downto 0) is threshold(C_S_SENSOR_IMG_RES-1 downto 0);

begin

  timer_inst : moment_track_timer
    port map(
      clk       => clk,
      rstn      => rstn,
      enable    => en_timer,
      ticks_max => time_cnt,
      timeout   => timeout
    );

  p_track : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        en_timer   <= '0';
        mode_i     <= (others => '0');
        track_num  <= (others => '0');
        thrs_i     <= (others => '0');
      else
        -- register configuration
        if (change_mode = '1') then
          en_timer  <= '0';
          track_num <= (others => '0');
          mode_i    <= mode;
          thrs_i    <= thres;
        else
          -- enable timer and track counting depending on operational mode
          if (mode_i(0) = '0') then
            en_timer <= '1';
            -- operational mode: continuous
            if (timeout = '1') then
              track_num <= track_num + 1;
            end if;
            --edge detection podria valer para fin y comienzo de proceso continuo
            
          else
            en_timer  <= '0';
            -- operational mode: tracks
            if ((en_tracks(1) = '0') and (en_tracks(0) = '1')) then
              track_num <= track_num + 1;
            end if;
            
            -- numero de tracks podria valer para fin y comienzo de proceso de tracks
                        
          end if;
        end if;
      end if;
    end if;
  end process;

  -- enable tracks (operation change edge-based)
  p_en : process(clk)
  begin
    if rising_edge(clk) then
      if (rstn = '0') then
        en_tracks <= (others => '0');
      else
        -- start of track, warm area greater than threshold
        if ((en_tracks(0) = '0') and (unsigned(mom00) >= unsigned(thrs_i))) then
          en_tracks(0) <= '1';
        -- end of track, warm area smaller than hard-coded limit
        elsif ((en_tracks(0) = '1') and (unsigned(mom00) <= unsigned(min_mom00))) then
          en_tracks(0) <= '0';
        end if;
        -- edge detection used in tracks mode
        en_tracks(1) <= en_tracks(0);
      end if;
      
      -- en_tracks representa el estado del laser, on off
      
    end if;
  end process;

  -- assign outputs
  tracks <= std_logic_vector(track_num);

end behavioral;