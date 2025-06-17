----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2025 12:21:10 PM
-- Design Name: 
-- Module Name: mm_memory_writer - impl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mm_memory_writer is

Generic (
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 16
);

Port (
	
    aclk    : std_logic := '0';
    arstn   : std_logic := '0';

    enable : in std_logic := '0';
    
    a_mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    
    bram_clk : OUT STD_LOGIC := '0';
    bram_rst : OUT STD_LOGIC := '0';
    bram_ena : OUT STD_LOGIC := '1';
    bram_wea : OUT STD_LOGIC_VECTOR((2*DATA_WIDTH)/8 - 1 DOWNTO 0) := (OTHERS => '0');
    bram_addr : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    bram_din : OUT STD_LOGIC_VECTOR(2*DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    bram_dout : IN STD_LOGIC_VECTOR(2*DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

	intr : out std_logic := '0'
);

end mm_memory_writer;

architecture impl of mm_memory_writer is

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO OF bram_clk : SIGNAL IS "xilinx.com:interface:bram:1.0 bram CLK";
    ATTRIBUTE X_INTERFACE_INFO OF bram_addr : SIGNAL IS "xilinx.com:interface:bram:1.0 bram ADDR";
    ATTRIBUTE X_INTERFACE_INFO OF bram_rst : SIGNAL IS "xilinx.com:interface:bram:1.0 bram RST";
    ATTRIBUTE X_INTERFACE_INFO OF bram_wea : SIGNAL IS "xilinx.com:interface:bram:1.0 bram WE";
    ATTRIBUTE X_INTERFACE_INFO OF bram_ena : SIGNAL IS "xilinx.com:interface:bram:1.0 bram EN";
    ATTRIBUTE X_INTERFACE_INFO OF bram_din : SIGNAL IS "xilinx.com:interface:bram:1.0 bram DIN";
    ATTRIBUTE X_INTERFACE_INFO OF bram_dout : SIGNAL IS "xilinx.com:interface:bram:1.0 bram DOUT";
    
    signal a_mm_data_d0 : std_logic_vector(a_mm_data'length - 1 downto 0) := ( others => '0');
    signal a_mm_wren_d0 : std_logic := '0';
    
    signal intr_reg : std_logic := '0';

    type state_type is ( STATE_IDLE, STATE_ACTIVE );
    signal state : state_type := STATE_IDLE;
    
begin

    bram_clk <= aclk;
    bram_rst <= '0';
    bram_ena <= '1';
    
    process(aclk) begin
    if (rising_edge(aclk)) then

        if (arstn = '0') then

            bram_addr <= ( others => '0' );
            bram_din <= ( others => '0' );
            bram_wea <= ( others => '0' );
            intr_reg <= '0';

        else

            a_mm_wren_d0 <= a_mm_wren;
            a_mm_data_d0 <= a_mm_data; 
            bram_din <= a_mm_data & a_mm_data_d0;
            a_mm_wren_d0 <= a_mm_wren;
            intr_reg <= (a_mm_wren xor a_mm_wren_d0) and a_mm_wren;
        
            case(state) is
                when STATE_IDLE =>

                    if (a_mm_wren = '0' and enable = '1') then
                        state <= STATE_ACTIVE;
                    end if;

                when STATE_ACTIVE =>

                if (a_mm_wren = '1') then
                    if (a_mm_addr(0) = '0') then
                        bram_addr <= std_logic_vector(shift_left(unsigned(a_mm_addr), integer(log2(real(DATA_WIDTH/8)))));
                        bram_wea <= ( others => '0');
                    else
                        bram_wea <= ( others => '1');
                    end if;
                end if;

                if (((a_mm_wren_d0 xor a_mm_wren) and not a_mm_wren) = '1') then
                    state <= STATE_IDLE;
                end if;

            end case;

        end if;
    end if;
end process;

-- User logic ends

end impl;
