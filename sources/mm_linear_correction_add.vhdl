LIBRARY ieee;
LIBRARY work;

USE ieee.std_logic_1164.ALL;
-- use ieee.std_logic_arith.all;
USE ieee.std_logic_misc.ALL;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.memory_types.ALL;

ENTITY mm_linear_correction_add IS
    GENERIC (
        FRAME_LENGTH : INTEGER := 4096;
        addr_width : INTEGER := 32;
        data_width : INTEGER := 32
    );

    PORT (

        aclk : IN STD_LOGIC := '0';
        arstn : IN STD_LOGIC := '0';

        offset_bram_clk : OUT STD_LOGIC := '0';
        offset_bram_rst : OUT STD_LOGIC := '0';
        offset_bram_ena : OUT STD_LOGIC := '1';
        offset_bram_wea : OUT STD_LOGIC_VECTOR(data_width/8 - 1 DOWNTO 0) := (OTHERS => '0');
        offset_bram_addr : OUT STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        offset_bram_din : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');
        offset_bram_dout : IN STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

        a_mm_addr : IN STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        a_mm_wren : IN STD_LOGIC := '0';
        a_mm_data : IN STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

        y_mm_addr : OUT STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        y_mm_wren : OUT STD_LOGIC := '0';
        y_mm_data : OUT STD_LOGIC_VECTOR(data_width DOWNTO 0) := (OTHERS => '0')
    );

END mm_linear_correction_add;

ARCHITECTURE rtl OF mm_linear_correction_add IS
    -- ATTRIBUTE X_INTERFACE_INFO of aclk: SIGNAL is "xilinx.com:signal:clock:1.0 aclk clk";
    -- ATTRIBUTE X_INTERFACE_INFO of arstn: SIGNAL is "xilinx.com:signal:reset:1.0 arstn rst";

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_clk : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram CLK";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_addr : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram ADDR";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_rst : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram RST";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_wea : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram WE";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_ena : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram EN";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_din : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram DIN";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_dout : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram DOUT";

    signal result : signed(2*a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal a_mm_wren_d0 : std_logic := '0';
    signal a_mm_wren_d1 : std_logic := '0';
    signal a_mm_wren_d2 : std_logic := '0';
    
    signal a_mm_addr_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_addr_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_addr_d2 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal a_mm_data_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_data_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal a_mm_data_d2 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal offset_bram_dout_d0 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    signal offset_bram_dout_d1 : std_logic_vector(a_mm_data'length-1 downto 0) := ( others => '0' );
    
    signal y_mm_data_pre0 : std_logic_vector(y_mm_data'length-1 downto 0) := ( others => '0' );

BEGIN
    
    offset_bram_clk <= aclk;
    offset_bram_rst <= '0';
    offset_bram_ena <= '1';
    offset_bram_wea <= ( others => '0' );
    
    
    process(aclk) begin
    if (rising_edge(aclk)) then
    if (arstn = '0') then
        
            a_mm_addr_d0 <= ( others => '0' );
            a_mm_addr_d1 <= ( others => '0' );
            a_mm_addr_d2 <= ( others => '0' );
            
            a_mm_data_d0 <= ( others => '0' );
            a_mm_data_d1 <= ( others => '0' );
            a_mm_data_d2 <= ( others => '0' );
            
            a_mm_wren_d0 <= '0';
            a_mm_wren_d1 <= '0';
            a_mm_wren_d2 <= '0';
            
            y_mm_addr <= ( others => '0' );
            y_mm_data <= ( others => '0' );
            y_mm_wren <= '0';
            
            
        else
        
            offset_bram_addr <= a_mm_addr( a_mm_addr'length-3 downto 0) & "00";
        
            a_mm_addr_d0 <= a_mm_addr;
            a_mm_addr_d1 <= a_mm_addr_d0;
            a_mm_addr_d2 <= a_mm_addr_d1;
            
            a_mm_wren_d0 <= a_mm_wren;
            a_mm_wren_d1 <= a_mm_wren_d0;
            a_mm_wren_d2 <= a_mm_wren_d1;
            
            a_mm_data_d0 <= a_mm_data;
            a_mm_data_d1 <= a_mm_data_d0;
            a_mm_data_d2 <= a_mm_data_d1;
            
            offset_bram_dout_d0 <= offset_bram_dout;
            offset_bram_dout_d1 <= offset_bram_dout_d0;
            
            y_mm_addr <= a_mm_addr_d2;
            y_mm_wren <= a_mm_wren_d2;
            
            if (unsigned(a_mm_addr_d2) < FRAME_LENGTH) then
                y_mm_data <= std_logic_vector(resize(signed(offset_bram_dout_d0) + signed(a_mm_data_d2), y_mm_data'length));
            else
                y_mm_data <= std_logic_vector(resize(signed(a_mm_data_d2), y_mm_data'length));
            end if;
            
        end if;
        
    end if;
    end process;

END rtl;