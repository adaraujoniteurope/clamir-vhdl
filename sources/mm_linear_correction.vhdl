library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity mm_linear_correction is
    generic
    (
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        scale_addr : inout std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        scale_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

        offset_addr : inout std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
        offset_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

        in_addr   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0' );
        in_wren   : in  std_logic := '0';
        in_data   : in  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0' );

        out_addr   : out  std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0' );
        out_wren   : out  std_logic := '0';
        out_data   : out  std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0' )
    );
  end mm_linear_correction;
  
  architecture rtl of mm_linear_correction IS

    type std_logic_vector_32b_array is array(integer range<>) of std_logic_vector(31 downto 0);

    signal addr_pipeline   : std_logic_vector_32b_array(0 to 3) := ( others => ( others => '0') );
    signal data_pipeline   : std_logic_vector_32b_array(0 to 3) := ( others => ( others => '0') );
    signal scale_pipeline  : std_logic_vector_32b_array(0 to 3) := ( others => ( others => '0') );
    signal offset_pipeline : std_logic_vector_32b_array(0 to 3) := ( others => ( others => '0') );

    signal mult_pipeline   : std_logic_vector_32b_array(0 to 3) := ( others => ( others => '0') );
    signal result_pipeline : std_logic_vector_32b_array(0 to 3) := ( others => ( others => '0') );

  begin

    scale_addr <= in_addr;
    offset_addr <= in_addr;

    addr_pipeline_process: process(aclk, arstn) begin

        if (arstn = '0') then
            addr_pipeline(0) <= (others => '0');
            addr_pipeline(1) <= (others => '0');
            addr_pipeline(2) <= (others => '0');
            addr_pipeline(3) <= (others => '0');
        else
            if (rising_edge(aclk)) then
                addr_pipeline(0) <= in_addr;
                addr_pipeline(1) <= addr_pipeline(0);
                addr_pipeline(2) <= addr_pipeline(1);
                addr_pipeline(3) <= addr_pipeline(2);
            end if;
            if (falling_edge(aclk)) then
            end if;
        end if;
    end process;

    data_pipeline_process: process(aclk, arstn) begin
        if (arstn = '0') then
            data_pipeline(0) <= (others => '0');
            data_pipeline(1) <= (others => '0');
            data_pipeline(2) <= (others => '0');
            data_pipeline(3) <= (others => '0');
        else
            if (rising_edge(aclk)) then
                data_pipeline(0) <= in_data;
                data_pipeline(1) <= data_pipeline(0);
                data_pipeline(2) <= data_pipeline(1);
                data_pipeline(3) <= data_pipeline(2);
            end if;
            if (falling_edge(aclk)) then
            end if;
        end if;
    end process;

    scale_fetch_process: process(aclk, arstn) begin

        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                scale_pipeline(0) <= scale_data;
                scale_pipeline(1) <= scale_pipeline(0);
                scale_pipeline(2) <= scale_pipeline(1);
                scale_pipeline(3) <= scale_pipeline(2);
            end if;
            if (falling_edge(aclk)) then
            end if;
        end if;

    end process;

    offset_fetch_process: process(aclk, arstn) begin

        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                offset_pipeline(0) <= offset_data;
                offset_pipeline(1) <= offset_pipeline(0);
                offset_pipeline(2) <= offset_pipeline(1);
                offset_pipeline(3) <= offset_pipeline(2);
            end if;
            if (falling_edge(aclk)) then    
            end if;

        end if;
    end process;

    mult_fetch_process: process(aclk, arstn) begin

        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                mult_pipeline(0) <= scale_data * in_data;
                mult_pipeline(1) <= mult_pipeline(0);
                mult_pipeline(2) <= mult_pipeline(1);
                mult_pipeline(3) <= mult_pipeline(2);
            end if;

            if (falling_edge(aclk)) then    
            end if;

        end if;
    end process;

    result_fetch_process: process(aclk, arstn) begin

        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                result_pipeline(0) <= mult_pipeline(0)(14+DATA_WIDTH-1 downto 14) + offset_data(DATA_WIDTH-1 downto 0);
                result_pipeline(1) <= result_pipeline(0);
                result_pipeline(2) <= result_pipeline(1);
                result_pipeline(3) <= result_pipeline(2);
            end if;
            if (falling_edge(aclk)) then

            end if;

        end if;
    end process;

  end rtl;