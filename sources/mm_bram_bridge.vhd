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

entity mm_bram_bridge is

Port (
  --sys
      clk : in std_logic;
      rst : in std_logic;
      
      mm_addr : in std_logic_vector (31 downto 0);
      mm_data : in std_logic_vector(31 downto 0);
      mm_wren : in std_logic;
      
      bram_out_clk  : out std_logic := '0';
      bram_out_rst  : out std_logic := '0';
      bram_out_en   : out std_logic := '0';
      bram_out_addr : out std_logic_vector (31 downto 0);
      bram_out_dout : out std_logic_vector(31 downto 0);
      bram_out_we   : out std_logic_vector (3 downto 0)
                
     );
end mm_bram_bridge;

architecture Behavioral of mm_bram_bridge is

begin

bram_out_clk <= clk when rst = '0' else '0';
bram_out_rst <= rst;

process (clk)
begin
IF (clk'EVENT AND clk = '1') THEN
        if(rst ='1') then
        bram_out_en <= '0';
        bram_out_we <="0000";            
    else
        bram_out_we <="1111";
        bram_out_addr <= mm_addr(31-2 downto 0) & "00";
        bram_out_dout <=  mm_data;
  end if;
end if;

end process;

end Behavioral;
