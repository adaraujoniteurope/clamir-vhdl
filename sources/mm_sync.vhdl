----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2025 09:32:55 AM
-- Design Name: 
-- Module Name: mm_sync - impl
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
-- this is intented to be used when wren is not in sync with data, you can adjust
-- adding a delay line using registers. Still, it can be used to add a FIFO
-- just add DELAY CYCLES of complete frame counts. I will simplify this block
-- later to make it available to delay lines...

-- This is getting really cool! =) the thing is I will implement this using AXIS4
-- for me.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mm_sync is
Generic(
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32;
    
    WREN_DELAY_CYCLES : integer := 1;
    DATA_DELAY_CYCLES : integer := 1
    
);
Port (
    aclk : std_logic := '0';
    arstn : std_logic := '0';
    
    a_mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    
    y_mm_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    y_mm_data : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    y_mm_wren : out std_logic := '0'
    
);
end mm_sync;

architecture impl of mm_sync is

    type wren_pipeline_type is array(integer range<>) of std_logic;
    type data_pipeline_type is array(integer range<>) of std_logic_vector(DATA_WIDTH+ADDR_WIDTH-1 downto 0);
    
    signal wren_pipeline : wren_pipeline_type(0 to WREN_DELAY_CYCLES-1) := ( others => '0');
    signal data_pipeline : data_pipeline_type(0 to DATA_DELAY_CYCLES-1) := ( others => ( others => '0' ));

begin

process(aclk) begin

    if (rising_edge(aclk)) then
        if (arstn = '0') then
            wren_pipeline <= ( others => '0' );
            data_pipeline <= ( others => ( others => '0' ));
        else
        
            data_pipeline(0) <= a_mm_addr & a_mm_data;
            y_mm_addr <= data_pipeline(DATA_DELAY_CYCLES-1)(DATA_WIDTH+ADDR_WIDTH-1 downto DATA_WIDTH);
            y_mm_data <= data_pipeline(DATA_DELAY_CYCLES-1)(DATA_WIDTH-1 downto 0);
            
            wren_pipeline(0) <= a_mm_wren;
            y_mm_wren <= wren_pipeline(WREN_DELAY_CYCLES-1);
            
            for i in 1 to WREN_DELAY_CYCLES-1 loop
                wren_pipeline(i) <= wren_pipeline(i-1);
            end loop;
            
            for i in 1 to DATA_DELAY_CYCLES-1 loop
                data_pipeline(i) <= data_pipeline(i-1);
            end loop;
            
        end if;
    end if;
end process;

end impl;
