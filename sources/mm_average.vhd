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

entity mm_sync is
Generic(
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32;
    
    FRAME_PIXEL_COUNT : integer := 4096;
    FRAME_BUFFER_LENGTH : integer := 1
    
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

    type memory_type is array(integer range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type fifo_type is array(integer range<>) of memory_type;
    
    signal data_pipeline : fifo_type(0 to FRAME_BUFFER_LENGTH-1) := ( others => ( others => '0' ));
    

begin

process(aclk) begin

    if (rising_edge(aclk)) then
        if (arstn = '0') then
            wren_pipeline <= ( others => '0' );
            data_pipeline <= ( others => ( others => '0' ));
        else
            for i in 1 to FRAME_BUFFER_LENGTH-1 loop
                data_pipeline(i) <= data_pipeline(i-1);
            end loop;
        end if;
    end if;
end process;

end impl;
