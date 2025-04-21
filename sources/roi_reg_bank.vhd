-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : roi_reg_bank
-- Description : Image Region-Of-Interest AXI4-Lite configuration registers
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity roi_reg_bank is
  generic (
    C_S_BRAM_ADDR_WIDTH : natural;
    C_S_AXI_ADDR_WIDTH  : natural
  );
  port (
    ---------------------------------------------------------------------------
    -- General purpose ports
    ---------------------------------------------------------------------------
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    ---------------------------------------------------------------------------
    -- Register bank access
    ---------------------------------------------------------------------------
    slv_rden      : in  std_logic;
    slv_wren      : in  std_logic;
    slv_wdata     : in  std_logic_vector(31 downto 0);
    slv_addr      : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    slv_rd_done   : out std_logic;
    slv_wr_done   : out std_logic;
    slv_rdata     : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------------
    -- Register bank members DUT direct access
    ---------------------------------------------------------------------------
    x1_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    y1_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    x2_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    y2_out        : out std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
    round     : out std_logic_vector(1 downto 0)
  );
end roi_reg_bank;

architecture behavioral of roi_reg_bank is

  signal x1_reg : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal y1_reg : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal x2_reg : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal y2_reg : std_logic_vector((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
  signal round_reg : std_logic_vector(1 downto 0);

  alias axi_addr : std_logic_vector(C_S_AXI_ADDR_WIDTH-3 downto 0) is slv_addr(slv_addr'left downto 2);

begin

  -----------------------------------------------------------------------------
  -- Write logic
  -----------------------------------------------------------------------------
  p_write : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        x1_reg <= (others => '0');
        y1_reg <= (others => '0');
        x2_reg <= (others => '0');
        y2_reg <= (others => '0');
        round_reg <= (others => '0');
      else
        if (slv_wren = '1') then
          case (to_integer(unsigned(axi_addr))) is
            when 0 => -- X1 ROI Coordinate (low-left corner)
              x1_reg <= slv_wdata((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
            when 1 => -- Y1 ROI Coordinate (low-left corner)
              y1_reg <= slv_wdata((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
            when 2 => -- X2 ROI Coordinate (up-right corner)
              x2_reg <= slv_wdata((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
            when 3 => -- Y2 ROI Coordinate (up-right corner)
              y2_reg <= slv_wdata((C_S_BRAM_ADDR_WIDTH/2)-1 downto 0);
            when 4 => -- rounding
              round_reg <= slv_wdata(1 downto 0);  
            when others => NULL;
          end case;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Read logic
  -----------------------------------------------------------------------------
  slv_rdata <= std_logic_vector(resize(unsigned(x1_reg), 32)) when (to_integer(unsigned(axi_addr)) = 0) else
               std_logic_vector(resize(unsigned(y1_reg), 32)) when (to_integer(unsigned(axi_addr)) = 1) else
               std_logic_vector(resize(unsigned(x2_reg), 32)) when (to_integer(unsigned(axi_addr)) = 2) else
               std_logic_vector(resize(unsigned(y2_reg), 32)) when (to_integer(unsigned(axi_addr)) = 3) else
               std_logic_vector(resize(unsigned(round_reg), 32)) when (to_integer(unsigned(axi_addr)) = 4) else
               (others => '0');

  -----------------------------------------------------------------------------
  -- Read/Write done flags
  -----------------------------------------------------------------------------
  slv_rd_done <= slv_rden;
  slv_wr_done <= slv_wren;
  
  -----------------------------------------------------------------------------
  -- Assign output values
  -----------------------------------------------------------------------------
  x1_out <= x1_reg;
  y1_out <= y1_reg;
  x2_out <= x2_reg;
  y2_out <= y2_reg;
  round <= round_reg;

end;