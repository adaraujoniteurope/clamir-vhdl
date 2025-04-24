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
use IEEE.STD_LOGIC_MISC.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mm_rescale_32b_16b is
Generic
(
        FRAME_LENGTH : INTEGER := 4096;
    addr_width : integer := 32;
    data_in_width : integer := 32;
    data_out_width : integer := 16
);
Port (
    aclk : std_logic := '0';
    arstn : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    a_mm_data : in std_logic_vector(data_in_width - 1 downto 0) := ( others => '0');
    
    y_mm_addr : out std_logic_vector(addr_width - 1 downto 0) := ( others => '0');
    y_mm_wren : out std_logic := '0';
    y_mm_data : out std_logic_vector(data_out_width - 1 downto 0) := ( others => '0')
);
end mm_rescale_32b_16b;

architecture impl of mm_rescale_32b_16b is

constant y_mm_data_max : integer := 2**(y_mm_data'length-1)-1;
constant y_mm_data_min : integer := -1*2**(y_mm_data'length - 1);

begin

sel_process: process(aclk) begin

    if (rising_edge(aclk)) then
        if (arstn = '0') then
            y_mm_addr <= (others => '0');
            y_mm_wren <= '0';
            y_mm_data <= (others => '0');
        else
            y_mm_addr <= a_mm_addr;
            y_mm_wren <= a_mm_wren;
            
            if (a_mm_addr < FRAME_LENGTH) then
                if (to_integer(signed(a_mm_data)) > y_mm_data_max) then
                    y_mm_data <= std_logic_vector(to_signed(y_mm_data_max, y_mm_data'length));
                elsif (to_integer(signed(a_mm_data)) < y_mm_data_min) then
                    y_mm_data <= std_logic_vector(to_signed(y_mm_data_min, y_mm_data'length));
                else
                    y_mm_data <= std_logic_vector(resize(signed(a_mm_data), y_mm_data'length));
                end if;
            else
                y_mm_data <= std_logic_vector(resize(unsigned(a_mm_data), y_mm_data'length));
            end if;
        end if;
    end if;
end process;

end impl;
