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
    addr_out : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    write_out : out std_logic := '0';

    mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    mm_wren : in std_logic := '0'
);
end mm_split;

architecture impl of mm_split is

begin

addr_out <= mm_addr;
data_out <= mm_data;
write_out <= mm_wren;

end impl;
