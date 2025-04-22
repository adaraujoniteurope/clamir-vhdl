----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 04/03/2025 10:22:35 am
-- design name: 
-- module name: mm_mux - impl
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE ieee.std_logic_signed.ALL;
USE ieee.numeric_std.ALL;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

ENTITY mm_downscale_limited IS
    GENERIC (
        FRAME_LENGTH : INTEGER := 4096;
        ADDR_WIDTH : INTEGER := 32;
        DATA_IN_WIDTH : INTEGER := 32;
        DATA_OUT_WIDTH : INTEGER := 16
    );
    PORT (
        aclk : STD_LOGIC := '0';
        arstn : STD_LOGIC := '0';

        a_mm_addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
        a_mm_wren : IN STD_LOGIC := '0';
        a_mm_data : IN STD_LOGIC_VECTOR(DATA_IN_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

        y_mm_addr : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
        y_mm_wren : OUT STD_LOGIC := '0';
        y_mm_data : OUT STD_LOGIC_VECTOR(DATA_OUT_WIDTH - 1 DOWNTO 0) := (OTHERS => '0')
    );
END mm_downscale_limited;

ARCHITECTURE impl OF mm_downscale_limited IS

    CONSTANT y_mm_data_max : INTEGER := 2 ** (y_mm_data'length - 1) - 1;
    CONSTANT y_mm_data_min : INTEGER := - 1 * 2 ** (y_mm_data'length - 1);

BEGIN

    sel_process : PROCESS (aclk) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                y_mm_addr <= (OTHERS => '0');
                y_mm_wren <= '0';
                y_mm_data <= (OTHERS => '0');
            ELSE
                y_mm_addr <= a_mm_addr;
                y_mm_wren <= a_mm_wren;

                IF (a_mm_addr < FRAME_LENGTH) THEN
                    IF (to_integer(signed(a_mm_data)) > y_mm_data_max) THEN
                        y_mm_data <= STD_LOGIC_VECTOR(to_signed(y_mm_data_max, y_mm_data'length));
                    ELSIF (to_integer(signed(a_mm_data)) < y_mm_data_min) THEN
                        y_mm_data <= STD_LOGIC_VECTOR(to_signed(y_mm_data_min, y_mm_data'length));
                    ELSE
                        y_mm_data <= STD_LOGIC_VECTOR(resize(signed(a_mm_data), y_mm_data'length));
                    END IF;
                ELSE
                    y_mm_data <= STD_LOGIC_VECTOR(resize(unsigned(a_mm_data), y_mm_data'length));
                END IF;
            END IF;
        END IF;
    END PROCESS;

END impl;