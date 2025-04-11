LIBRARY ieee;
LIBRARY work;

USE ieee.std_logic_1164.ALL;
-- use ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.memory_types.ALL;

ENTITY mm_linear_correction IS
    GENERIC (
        FRAME_LENGTH : INTEGER := 4;
        addr_width : INTEGER := 32;
        data_width : INTEGER := 32;
        VALUE_MAX : INTEGER := 32767;
        VALUE_MIN : INTEGER := - 32768
    );

    PORT (

        aclk : IN STD_LOGIC := '0';
        arstn : IN STD_LOGIC := '0';

        scale_bram_clk : OUT STD_LOGIC := '0';
        scale_bram_rst : OUT STD_LOGIC := '0';
        scale_bram_ena : OUT STD_LOGIC := '1';
        scale_bram_wea : OUT STD_LOGIC_VECTOR(data_width/8 - 1 DOWNTO 0) := (OTHERS => '0');
        scale_bram_addr : OUT STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        scale_bram_din : IN STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');
        scale_bram_dout : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

        offset_bram_clk : OUT STD_LOGIC := '0';
        offset_bram_rst : OUT STD_LOGIC := '0';
        offset_bram_ena : OUT STD_LOGIC := '1';
        offset_bram_wea : OUT STD_LOGIC_VECTOR(data_width/8 - 1 DOWNTO 0) := (OTHERS => '0');
        offset_bram_addr : OUT STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        offset_bram_din : IN STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');
        offset_bram_dout : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

        a_mm_addr : IN STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        a_mm_wren : IN STD_LOGIC := '0';
        a_mm_data : IN STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

        y_mm_addr : OUT STD_LOGIC_VECTOR(addr_width - 1 DOWNTO 0) := (OTHERS => '0');
        y_mm_wren : OUT STD_LOGIC := '0';
        y_mm_data : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');

        debug_scale : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');
        debug_offset : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0) := (OTHERS => '0');
        debug_mult : OUT STD_LOGIC_VECTOR(data_width + data_width - 1 DOWNTO 0) := (OTHERS => '0')
    );

END mm_linear_correction;

ARCHITECTURE rtl OF mm_linear_correction IS
    -- ATTRIBUTE X_INTERFACE_INFO of aclk: SIGNAL is "xilinx.com:signal:clock:1.0 aclk clk";
    -- ATTRIBUTE X_INTERFACE_INFO of arstn: SIGNAL is "xilinx.com:signal:reset:1.0 arstn rst";

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_clk : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram CLK";
    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_addr : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram ADDR";
    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_rst : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram RST";
    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_wea : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram WE";
    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_ena : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram EN";
    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_din : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram DIN";
    ATTRIBUTE X_INTERFACE_INFO OF scale_bram_dout : SIGNAL IS "xilinx.com:interface:bram:1.0 scale_bram DOUT";

    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_clk : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram CLK";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_addr : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram ADDR";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_rst : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram RST";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_wea : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram WE";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_ena : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram EN";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_din : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram DIN";
    ATTRIBUTE X_INTERFACE_INFO OF offset_bram_dout : SIGNAL IS "xilinx.com:interface:bram:1.0 offset_bram DOUT";

    SIGNAL addr_pipeline : memory_32b_type(0 TO 3) := (OTHERS => (OTHERS => '0'));
    SIGNAL data_pipeline : memory_32b_type(0 TO 7) := (OTHERS => (OTHERS => '0'));
    SIGNAL scale_pipeline : memory_32b_type(0 TO 3) := (OTHERS => (OTHERS => '0'));
    SIGNAL offset_pipeline : memory_32b_type(0 TO 3) := (OTHERS => (OTHERS => '0'));

    SIGNAL mult_pipeline : memory_64b_type(0 TO 3) := (OTHERS => (OTHERS => '0'));
    SIGNAL result_pipeline : memory_32b_type(0 TO 3) := (OTHERS => (OTHERS => '0'));

    SIGNAL y_mm_wren_pipeline : STD_LOGIC_VECTOR(0 TO 4) := (OTHERS => '0');

    --    function shr(arg: std_logic_vector; count: unsigned) return std_logic_vector is
    --        variable result : std_logic_vector(count - 1 downto 0);
    --        variable complement : 
    --    begin
    --        if (arg(arg'length) = '1') then result := ( others = '1') & arg(arg'length - 1 downto count); end if;
    --        if (arg(arg'length) = '0') then result := ( others = '0') & arg(arg'length - 1 downto count); end if;
    --        return result; 
    --    end;
    FUNCTION min(L, R : INTEGER) RETURN INTEGER IS
    BEGIN
        IF L < R THEN
            RETURN L;
        ELSE
            RETURN R;
        END IF;
    END;

    FUNCTION SXT(ARG : STD_LOGIC_VECTOR; SIZE : INTEGER) RETURN STD_LOGIC_VECTOR IS
        CONSTANT msb : INTEGER := min(ARG'length, SIZE) - 1;
        SUBTYPE rtype IS STD_LOGIC_VECTOR (SIZE - 1 DOWNTO 0);
        VARIABLE new_bounds : STD_LOGIC_VECTOR (ARG'length - 1 DOWNTO 0);
        VARIABLE result : rtype;
        -- synopsys built_in SYN_SIGN_EXTEND
        -- synopsys subpgm_id 386
    BEGIN
        -- synopsys synthesis_off
        -- new_bounds := MAKE_BINARY(ARG);
        IF (ARG(0) = 'X') THEN
            result := rtype'(OTHERS => 'X');
            RETURN result;
        END IF;
        result := rtype'(OTHERS => ARG(ARG'left));
        result(msb DOWNTO 0) := ARG(msb DOWNTO 0);
        RETURN result;
        -- synopsys synthesis_on
    END;

BEGIN

    scale_bram_clk <= aclk;
    offset_bram_clk <= aclk;

    y_mm_addr <= addr_pipeline(2) WHEN arstn = '1' ELSE
        (OTHERS => '0');
    y_mm_wren <= y_mm_wren_pipeline(4) WHEN arstn = '1' ELSE
        '0';
    -- y_mm_data <= result_pipeline(0) when arstn = '1' else (others => '0');

    debug_scale <= scale_pipeline(0) WHEN arstn = '1' ELSE
        (OTHERS => '0');
    debug_offset <= offset_pipeline(0) WHEN arstn = '1' ELSE
        (OTHERS => '0');
    debug_mult <= mult_pipeline(0) WHEN arstn = '1' ELSE
        (OTHERS => '0');

    y_mm_wren_pipeline_process : PROCESS (aclk, arstn) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                y_mm_wren_pipeline <= (OTHERS => '0');
            ELSE
                y_mm_wren_pipeline(0) <= a_mm_wren;
                y_mm_wren_pipeline(1) <= y_mm_wren_pipeline(0);
                y_mm_wren_pipeline(2) <= y_mm_wren_pipeline(1);
                y_mm_wren_pipeline(3) <= y_mm_wren_pipeline(2);
                y_mm_wren_pipeline(4) <= y_mm_wren_pipeline(3);
            END IF;
        END IF;
    END PROCESS;

    addr_pipeline_process : PROCESS (aclk, arstn) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                addr_pipeline <= (OTHERS => (OTHERS => '0'));
            ELSE
                addr_pipeline(0) <= a_mm_addr;
                addr_pipeline(1) <= addr_pipeline(0);
                addr_pipeline(2) <= addr_pipeline(1);
                addr_pipeline(3) <= addr_pipeline(2);
            END IF;
        END IF;

    END PROCESS;

    data_pipeline_process : PROCESS (aclk, arstn) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                data_pipeline <= (OTHERS => (OTHERS => '0'));
            ELSE
                data_pipeline(0) <= a_mm_data;
                data_pipeline(1) <= data_pipeline(0);
                data_pipeline(2) <= data_pipeline(1);
                data_pipeline(3) <= data_pipeline(2);
                data_pipeline(4) <= data_pipeline(3);
                data_pipeline(5) <= data_pipeline(4);
                data_pipeline(6) <= data_pipeline(5);
                data_pipeline(7) <= data_pipeline(6);
            END IF;
        END IF;

    END PROCESS;

    scale_fetch_process : PROCESS (aclk, arstn) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                scale_bram_addr <= (OTHERS => '0');
                scale_pipeline <= (OTHERS => (OTHERS => '0'));
            ELSE
                -- BRAM is 1 byte addressed
                scale_bram_addr <= a_mm_addr((ADDR_WIDTH - 1) - 2 DOWNTO 0) & "00";
                scale_pipeline(0) <= scale_bram_din;
                scale_pipeline(1) <= scale_pipeline(0);
                scale_pipeline(2) <= scale_pipeline(1);
                scale_pipeline(3) <= scale_pipeline(2);
            END IF;
        END IF;

    END PROCESS;

    offset_fetch_process : PROCESS (aclk, arstn) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                offset_bram_addr <= (OTHERS => '0');
                offset_pipeline <= (OTHERS => (OTHERS => '0'));
            ELSE
                offset_bram_addr <= a_mm_addr((ADDR_WIDTH - 1) - 2 DOWNTO 0) & "00";
                offset_pipeline(0) <= offset_bram_din;
                offset_pipeline(1) <= offset_pipeline(0);
                offset_pipeline(2) <= offset_pipeline(1);
                offset_pipeline(3) <= offset_pipeline(2);
            END IF;
        END IF;

    END PROCESS;

    multiply_process : PROCESS (aclk, arstn)
        VARIABLE result : signed(63 DOWNTO 0) := (OTHERS => '0');
    BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                mult_pipeline <= (OTHERS => (OTHERS => '0'));
            ELSE
                mult_pipeline(0) <= std_logic_vector(signed(shift_right(signed(signed(scale_pipeline(0)) * signed(data_pipeline(2))), 14)) + signed(offset_pipeline(0)));
                mult_pipeline(1) <= mult_pipeline(0);
                mult_pipeline(2) <= mult_pipeline(1);
                mult_pipeline(3) <= mult_pipeline(2);
            END IF;
        END IF;

    END PROCESS;

    result_fetch_process : PROCESS (aclk, arstn) BEGIN

        IF (rising_edge(aclk)) THEN
            IF (arstn = '0') THEN
                result_pipeline <= (OTHERS => (OTHERS => '0'));
            ELSE

            IF (ADDR_PIPELINE(3) < FRAME_LENGTH) THEN
                IF (signed(result_pipeline(0)) < VALUE_MAX AND signed(result_pipeline(0)) > VALUE_MIN) THEN
                    y_mm_data <= mult_pipeline(0)(data_width - 1 DOWNTO 0);
                ELSIF (to_integer(signed(result_pipeline(0))) > VALUE_MAX) THEN
                    y_mm_data <= STD_LOGIC_VECTOR(to_signed(VALUE_MAX, y_mm_data'length));
                ELSIF (to_integer(signed(result_pipeline(0))) <= VALUE_MIN) THEN
                    y_mm_data <= STD_LOGIC_VECTOR(to_signed(VALUE_MIN, y_mm_data'length));
                END IF;
            ELSE
                y_mm_data <= data_pipeline(3);
            END IF;
            END IF;
        END IF;

    END PROCESS;

END rtl;