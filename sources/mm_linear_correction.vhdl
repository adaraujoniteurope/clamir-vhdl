library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.memory_types.all;

entity mm_linear_correction is
    generic
    (
        addr_width : integer := 32;
        data_width : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        scale_bram_clk : out std_logic := '0';
        scale_bram_ena : out std_logic := '1';
        scale_bram_wea : out std_logic := '0';
        scale_bram_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
        scale_bram_data_in : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
        scale_bram_data_out : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

        offset_bram_clk : out std_logic := '0';
        offset_bram_ena : out std_logic := '1';
        offset_bram_wea : out std_logic := '0';
        offset_bram_addr : out std_logic_vector(addr_width - 1 downto 0) := (others => '0');
        offset_bram_data_in : in std_logic_vector(data_width - 1 downto 0) := (others => '0');
        offset_bram_data_out : out std_logic_vector(data_width - 1 downto 0) := (others => '0');

        in_addr   : in  std_logic_vector(addr_width - 1 downto 0) := (others => '0' );
        in_wren   : in  std_logic := '0';
        in_data   : in  std_logic_vector(data_width - 1 downto 0) := (others => '0' );

        out_addr   : out  std_logic_vector(addr_width - 1 downto 0) := (others => '0' );
        out_wren   : out  std_logic := '0';
        out_data   : out  std_logic_vector(data_width - 1 downto 0) := (others => '0' )
    );
  end mm_linear_correction;
  
  architecture rtl of mm_linear_correction is

    signal addr_pipeline   : memory_32b_type(0 to 3) := ( others => ( others => '0') );
    signal data_pipeline   : memory_32b_type(0 to 3) := ( others => ( others => '0') );
    signal scale_pipeline  : memory_32b_type(0 to 3) := ( others => ( others => '0') );
    signal offset_pipeline : memory_32b_type(0 to 3) := ( others => ( others => '0') );

    signal mult_pipeline   : memory_64b_type(0 to 3) := ( others => ( others => '0') );
    signal result_pipeline : memory_32b_type(0 to 3) := ( others => ( others => '0') );

    signal out_wren_pipeline : std_logic_vector(0 to 3) := ( others => '0');

  begin

    scale_bram_clk <= aclk;
    offset_bram_clk <= aclk;

    out_addr <= addr_pipeline(2) when arstn = '1' else (others => '0');
    out_wren <= out_wren_pipeline(2) when arstn = '1' else '0';
    out_data <= result_pipeline(0) when arstn = '1' else (others => '0');

    out_wren_pipeline_process: process(aclk, arstn) begin
        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                out_wren_pipeline(0) <= in_wren;
                out_wren_pipeline(1) <= out_wren_pipeline(0);
                out_wren_pipeline(2) <= out_wren_pipeline(1);
                out_wren_pipeline(3) <= out_wren_pipeline(2);
            end if;
        end if;
    end process;

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
                scale_bram_addr <= in_addr;
            end if;
            if (falling_edge(aclk)) then
                scale_pipeline(0) <= scale_bram_data_in;
                scale_pipeline(1) <= scale_pipeline(0);
                scale_pipeline(2) <= scale_pipeline(1);
                scale_pipeline(3) <= scale_pipeline(2);
            end if;
        end if;

    end process;

    offset_fetch_process: process(aclk, arstn) begin

        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                offset_bram_addr <= in_addr;
            end if;
            if (falling_edge(aclk)) then    
                offset_pipeline(0) <= offset_bram_data_in;
                offset_pipeline(1) <= offset_pipeline(0);
                offset_pipeline(2) <= offset_pipeline(1);
                offset_pipeline(3) <= offset_pipeline(2);
            end if;

        end if;
    end process;

    mult_fetch_process: process(aclk, arstn) begin

        if (arstn = '0') then
        else
            if (rising_edge(aclk)) then
                mult_pipeline(0) <= scale_pipeline(0) * data_pipeline(0);
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
                result_pipeline(0) <= mult_pipeline(0)(14+data_width-1 downto 14) + offset_pipeline(0)(data_width-1 downto 0);
                result_pipeline(1) <= result_pipeline(0);
                result_pipeline(2) <= result_pipeline(1);
                result_pipeline(3) <= result_pipeline(2);
            end if;
            if (falling_edge(aclk)) then
            end if;

        end if;
    end process;

  end rtl;