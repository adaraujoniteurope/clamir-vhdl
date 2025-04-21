----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2025 10:22:35 AM
-- Design Name: 
-- Module Name: mm_mux - impl
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

entity mm_mux is
Generic
(
    addr_width : integer := 32;
    data_width : integer := 32
);
Port (
    aclk : std_logic := '0';
    arstn : std_logic := '0';
    sel : std_logic := '0';
    
    y_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    y_mm_wren : out std_logic := '0';
    y_mm_data : out std_logic_vector(data_width - 1 downto 0) := ( others => '0');
    
    a_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    a_mm_data : in std_logic_vector(data_width - 1 downto 0) := ( others => '0');
    
    b_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    b_mm_wren : in std_logic := '0';
    b_mm_data : in std_logic_vector(data_width - 1 downto 0) := ( others => '0')
);
end mm_mux;

architecture impl of mm_mux is

begin

sel_process: process(aclk) begin

    if (aclk'event and aclk = '1') then
        if (arstn = '0') then
            y_mm_addr <= (others => '0');
            y_mm_wren <= '0';
            y_mm_data <= (others => '0');
        else
            case(sel) is
            when '0' =>
                y_mm_addr <= a_mm_addr;
                y_mm_wren <= a_mm_wren;
                y_mm_data <= a_mm_data;
            when '1' =>
                y_mm_addr <= b_mm_addr;
                y_mm_wren <= b_mm_wren;
                y_mm_data <= b_mm_data;
            end case;
            
        end if;
    end if;

end process;

end impl;
