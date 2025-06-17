----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2025 10:07:31 AM
-- Design Name: 
-- Module Name: i2c_shutter_controller_protocol_converter - Behavioral
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

entity i2c_shutter_controller_protocol_converter is
Port (
    clk             : in std_logic;
    rst             : in std_logic;
    ena_sys         : in std_logic;
    open_nclose     : in std_logic;
    ap_start        : in std_logic;
    debug_high_z    : in std_logic;
    
    cmd_open        : out std_logic := '0';
    cmd_close       : out std_logic := '0';
    cmd_calibrate   : out std_logic := '0'
);
end i2c_shutter_controller_protocol_converter;

architecture rtl of i2c_shutter_controller_protocol_converter is

signal ctrl : std_logic_vector(4 downto 0);

begin

ctrl  <= rst & ena_sys & open_nclose & ap_start & debug_high_z;

process (clk,ctrl) begin

    if (rising_edge(clk)) then

        case(ctrl) is
    
            when "01110" =>
                cmd_open <= '1';
                cmd_close <= '0';
                cmd_calibrate <= '0';
                
            when "01010" =>
                cmd_open <= '0';
                cmd_close <= '1';
                cmd_calibrate <= '0';
            
            when others =>
                cmd_open <= '0';
                cmd_close <= '0';
                cmd_calibrate <= '0';
            
            end case;

    end if;
    
end process;

end rtl;
