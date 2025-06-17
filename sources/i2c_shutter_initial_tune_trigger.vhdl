----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2025 03:23:49 PM
-- Design Name: 
-- Module Name: i2c_shutter_initial_tune_trigger - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_shutter_initial_tune_trigger is
Generic (
    CLOCK_FREQ_HZ : integer := 100000000;
    INITIAL_COUNT_SECONDS : integer := 1
);
Port (
    aclk : in std_logic := '0';
    arstn : in std_logic := '0';
    trigger : out std_logic := '0'
);
end i2c_shutter_initial_tune_trigger;

architecture Behavioral of i2c_shutter_initial_tune_trigger is
    signal counter : integer := 0;
begin

process(aclk) begin
    if (rising_edge(aclk)) then
        if (arstn = '1') then
            counter <= 0;
            trigger <= '1';
        else
            if (counter < CLOCK_FREQ_HZ * INITIAL_COUNT_SECONDS) then
                counter <= counter + 1;
                trigger <= '1';
            else
                trigger <= '0';
            end if;
        end if;
    end if;
end process;


end Behavioral;
