----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2025 10:22:35 AM
-- Design Name: 
-- Module Name: mm_crossbar - impl
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mm_crossbar is
Generic
(
    addr_width : integer := 32;
    data_width : integer := 32
);
Port (
    aclk : std_logic := '0';
    arstn : std_logic := '0';
    sel : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    a_mm_data : in std_logic_vector(data_width - 1 downto 0) := ( others => '0');
    
    y0_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    y0_mm_wren : out std_logic := '0';
    y0_mm_data : out std_logic_vector(data_width - 1 downto 0) := ( others => '0');
    
    y1_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    y1_mm_wren : out std_logic := '0';
    y1_mm_data : out std_logic_vector(data_width - 1 downto 0) := ( others => '0')
);
end mm_crossbar;

architecture impl of mm_crossbar is

begin

sel_process: process(aclk) begin

    if (aclk'event and aclk = '1') then
        if (arstn = '0') then
            y0_mm_addr <= (others => '0');
            y0_mm_wren <= '0';
            y0_mm_data <= (others => '0');

            y1_mm_addr <= (others => '0');
            y1_mm_wren <= '0';
            y1_mm_data <= (others => '0');
        else
            case(sel) is
            when '0' =>
                y0_mm_addr <= a_mm_addr;
                y0_mm_wren <= a_mm_wren;
                y0_mm_data <= a_mm_data;
            when '1' =>
                y1_mm_addr <= a_mm_addr;
                y1_mm_wren <= a_mm_wren;
                y1_mm_data <= a_mm_data;
            when others =>
                y0_mm_addr <= a_mm_addr;
                y0_mm_wren <= a_mm_wren;
                y0_mm_data <= a_mm_data;
            end case;
        end if;
    end if;

end process;

end impl;
