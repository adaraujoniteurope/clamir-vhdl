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

entity signed_rescale is
Generic
(
    data_in_width : integer := 32;
    data_out_width : integer := 16
);
Port (
    a_data : in std_logic_vector(data_in_width - 1 downto 0) := ( others => '0');
    y_data : out std_logic_vector(data_out_width - 1 downto 0) := ( others => '0')
);
end signed_rescale;

architecture impl of signed_rescale is
begin

y_data <= std_logic_vector(resize(signed(a_data), y_data'length));

end impl;
