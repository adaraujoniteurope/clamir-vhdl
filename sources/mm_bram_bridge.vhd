----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 20.02.2017 18:37:46
-- design name: 
-- module name: adc_temp_vu - behavioral
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

entity mm_bram_bridge is

port (
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

architecture behavioral of mm_bram_bridge is

begin

bram_out_clk <= clk when rst = '0' else '0';
bram_out_rst <= rst;

process (clk)
begin
if (clk'event and clk = '1') then
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

end behavioral;
