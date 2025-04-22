----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2017 19:00:27
-- Design Name: 
-- Module Name: Trigger_CTRL - Behavioral
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

entity Trigger_CTRL is
GENERIC(
      sys_clk         : INTEGER := 100_000_000; --system clock frequency in Hz
      debounce_ticks    : integer :=100;
      sys_prescaler    : integer :=99);  
      
Port (
  --sys
      CLK  : in std_logic;
      RESET : in std_logic;
      ENA: in std_logic;
      
      Trigger_setpoint: in std_logic_vector (15 downto 0);
      Trigger_out_sys: out std_logic
      );

end Trigger_CTRL;

architecture Behavioral of Trigger_CTRL is


signal CNT_TRIGGER: std_logic_vector (15 downto 0);
signal CNT_prescaler: std_logic_vector (7 downto 0);
signal tick: std_logic;
signal Trigger_out_sys_reg:std_logic;



begin


Internal_Trigger: process (CLK, RESET)
begin 
IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') then
        CNT_TRIGGER <= (others=>'0');
        CNT_prescaler <=conv_std_logic_vector(sys_prescaler, 8);
        Trigger_out_sys_reg<='0';
        Trigger_out_sys<='0';
        tick <= '0';
        
    else
    
    
    Trigger_out_sys <= Trigger_out_sys_reg and tick;
    
    if (CNT_prescaler = 0) 
    then
        CNT_prescaler<=conv_std_logic_vector(sys_prescaler, 8);
        tick <= '1';
    else    
       CNT_prescaler<= CNT_prescaler - 1;  
       tick <= '0';
    end if;  
    
    if (ENA = '0') then
     CNT_TRIGGER<= Trigger_setpoint-1;
     else
    if (tick = '1')
     then   
        
        if (CNT_TRIGGER = 0)
        then
            Trigger_out_sys_reg<='1';
            CNT_TRIGGER<= Trigger_setpoint-1;
                       
        else
            Trigger_out_sys_reg<='0';
            CNT_TRIGGER<= CNT_TRIGGER - 1 ;
        end if;
     end if;
    end if;
       
    end if;
  end if;    
end process;

end Behavioral;
