----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 01.03.2017 17:26:41
-- design name: 
-- module name: procc_offset - behavioral
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity iob_register is
    
  port ( 
  
      clk  : in std_logic;
      in_external: in std_logic_vector (13 downto 0);
      out_internal: out std_logic_vector (13 downto 0));
end iob_register;

architecture behavioral of iob_register is

begin

process (clk)
begin


if (clk'event and clk = '1') then
    
    out_internal <= in_external;
    
    end if;
    
    end process;
    
    
    end behavioral;
    
    
    
    
