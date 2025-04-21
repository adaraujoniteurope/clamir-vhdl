----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2017 17:26:41
-- Design Name: 
-- Module Name: procc_offset - Behavioral
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



library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity iob_register is
    
  Port ( 
  
      CLK  : in std_logic;
      in_external: in std_logic_vector (13 downto 0);
      out_internal: out std_logic_vector (13 downto 0));
end iob_register;

architecture Behavioral of iob_register is

begin

process (CLK)
begin


IF (CLK'EVENT AND CLK = '1') THEN
    
    out_internal <= in_external;
    
    end if;
    
    end process;
    
    
    end Behavioral;
    
    
    
    
