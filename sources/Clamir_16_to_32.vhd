----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.02.2017 18:37:46
-- Design Name: 
-- Module Name: ADC_temp_VU - Behavioral
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CLAMIR_16_2_32 is

Port (
  --sys
      CLK  : in std_logic;
      RESET : in std_logic;
      
      ADDRESS_in: in std_logic_vector (12 downto 0);
      DATA_in: in std_logic_vector(15 downto 0);
      write_in: in std_logic;
      ADDRESS_out: out std_logic_vector (31 downto 0);
      DATA_out: out std_logic_vector(31 downto 0);
      write_out: out std_logic_vector (3 downto 0)
                
     );
     
     attribute DONT_TOUCH : string; 
         attribute DONT_TOUCH of CLAMIR_16_2_32 : entity is "true";
end CLAMIR_16_2_32;

architecture Behavioral of CLAMIR_16_2_32 is

signal DATA_in_reg: std_logic_vector (15 downto 0);
signal flag: std_logic:='0';

begin



process (CLK)
begin

IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') 
    then
                    
    else
    ADDRESS_out<= x"0000" & "00" & ADDRESS_in(12 downto 1) & "00";
    DATA_out <=  DATA_in & DATA_in_reg;
    write_out <="0000";
    if (write_in ='1')
    then
      if(flag='0')
      then
         DATA_in_reg  <= DATA_in;
         flag<='1';
         
         else
         flag<='0';
         write_out <="1111";
         end if;
    else
    end if;
       
    
  end if;
end if;

end process;

end Behavioral;
