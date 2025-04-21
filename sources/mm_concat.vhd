----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 05:47:44 PM
-- Design Name: 
-- Module Name: mm_concat - impl
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
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mm_concat is
generic (
    ADDR_IN_WIDTH : integer := 32;
    DATA_IN_WIDTH : integer := 32;
    ADDR_OUT_WIDTH : integer := 32;
    DATA_OUT_WIDTH : integer := 32
);
port (
    aclk : in std_logic := '0';
    arstn : in std_logic := '0';
    
    addr_in : in std_logic_vector(ADDR_IN_WIDTH-1 downto 0) := ( others => '0');
    data_in : in std_logic_vector(DATA_IN_WIDTH-1 downto 0) := ( others => '0');
    write_in : in std_logic := '0';
    mm_addr : out std_logic_vector(ADDR_OUT_WIDTH-1 downto 0) := ( others => '0');
    mm_data : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0) := ( others => '0');
    mm_wren : out std_logic := '0'
);
end mm_concat;

architecture impl of mm_concat is

begin

process(aclk) begin
    if (rising_edge(aclk)) then
        if (arstn = '0') then
            mm_addr <= ( others => '0' );
            mm_data <= ( others => '0' );
            mm_wren <= '0'; 
        else
            mm_addr <= std_logic_vector(resize(unsigned(addr_in), mm_addr'length));
            mm_data <= std_logic_vector(resize(signed(data_in), mm_data'length));
            mm_wren <= write_in;
        end if;
    end if;
end process;

end impl;
