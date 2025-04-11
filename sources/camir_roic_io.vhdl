library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_BIT.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use IEEE.STD_LOGIC_MISC.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.MATH_COMPLEX.ALL;

entity camir_roic_phy is
generic (
    ROIC_WIDTH : integer := 128;
    ROIC_HEIGHT : integer := 128
);

port (
    aclk : in std_logic := '0';
    arstn : in std_logic := '0';


    roic_rstneg : out std_logic := '0';
    roic_bus : out std_logic := '0';
    roic_xrst : out std_logic := '0';
    roic_xanalogrst : out std_logic := '0';
    roic_clk : out std_logic := '0';
    roic_rowsel : out std_logic := '0';
    roic_clk2 : out std_logic := '0';
    roic_sel_row : out std_logic := '0';
    roic_clk_row : out std_logic := '0';
    roic_wr_en : out std_logic := '0';
    roic_rd_clk : out std_logic := '0';
    roic_clkperiph : out std_logic := '0';
    -- roic_colsel : out std_logic_vector(log(ROIC_WIDTH)/log(2)-1 downto 0) := '0';
    roic_wr_clk : out std_logic_vector(ROIC_WIDTH-1 downto 0) := (others => '0');
    roic_rd_en : out std_logic_vector(ROIC_WIDTH-1 downto 0) := (others => '0');
    roic_din10 : out std_logic := '0';
    roic_dout : in std_logic := '0'
);
end camir_roic_phy;

architecture impl of camir_roic_phy is
begin

end impl;
