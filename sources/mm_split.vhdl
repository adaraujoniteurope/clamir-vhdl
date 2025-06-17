----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 05:47:44 PM
-- Design Name: 
-- Module Name: mm_split - impl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mm_split is
generic (
    FRAME_LENGTH : integer := 4096;
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32
);
port (

    aclk : in std_logic;
    arstn : in std_logic;

    y0_mm_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    y0_mm_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    y0_mm_wren : out std_logic;
    
    y1_mm_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    y1_mm_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    y1_mm_wren : out std_logic;

    a_mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    a_mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
    a_mm_wren : in std_logic
);
end mm_split;

architecture impl of mm_split is
begin

process(aclk) begin
    if (rising_edge(aclk)) then
        if (arstn = '0') then
            y0_mm_addr <= (others => '0');
            y0_mm_data <= (others => '0');
            y0_mm_wren <= '0';
            
            y1_mm_addr <= (others => '0');
            y1_mm_data <= (others => '0');
            y1_mm_wren <= '0';
        else
            y0_mm_addr <= a_mm_addr;
            y0_mm_data <= a_mm_data;
            y0_mm_wren <= a_mm_wren;
            
            y1_mm_addr <= a_mm_addr;
            y1_mm_data <= a_mm_data;
            y1_mm_wren <= a_mm_wren;
        end if;
    end if;
end process;

end impl;
