----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2025 09:32:55 AM
-- Design Name: 
-- Module Name: mm_streaming_fifo - impl
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

-- with almost no handshake it's easy to implement something
-- really performatic but take care to match sync for every frame.

-- avoid complexity on state machine of AXI4 Stream Protocol
-- to make it compatible with Xilinx Blocks...

entity mm_streaming_fifo is
Generic(
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 32;
    
    FRAME_PIXEL_COUNT : integer := 4096;
    FIFO_LENGTH : integer := 1
    
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
end mm_streaming_fifo;

architecture impl of mm_streaming_fifo is

    type memory_type is array(integer range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type fifo_type is array(integer range<>) of memory_type(FRAME_PIXEL_COUNT-1 downto 0);
    
    signal data_pipeline : fifo_type(0 to FIFO_LENGTH-1) := ( others => ( others => ( others => '0' )));
    

begin

process(aclk) begin

    if (rising_edge(aclk)) then
        if (arstn = '0') then
        else

            for i in 1 to FIFO_LENGTH-1 loop
                -- resource intensive, better to use mm_sync
                data_pipeline(i) <= data_pipeline(i-1);
            end loop;

        end if;
    end if;
end process;

end impl;
