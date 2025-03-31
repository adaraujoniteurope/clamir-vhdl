library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity axis_linear_correction is
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

        axis_in_tdata   : in  std_logic_vector(ADDR_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0' );
        axis_in_tuser   : in  std_logic := '0';
        axis_in_tvalid  : in  std_logic := '0';
        axis_in_tready  : out std_logic := '0';

        axis_out_tdata  : inout std_logic_vector(ADDR_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0' );
        axis_out_tuser  : out  std_logic := '0';
        axis_out_tvalid : out std_logic := '0';
        axis_out_tready : in  std_logic := '0'

    );
  end axis_linear_correction;
  
  architecture rtl of axis_linear_correction is

    signal addr_in  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal data_in  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    signal mult : std_logic_vector(DATA_WIDTH+DATA_WIDTH-1 downto 0) := (others => '0');

    signal addr_out : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

  begin

    addr_in <= axis_in_tdata(ADDR_WIDTH+DATA_WIDTH - 1 downto DATA_WIDTH);

    scale_addr <= addr_in;
    offset_addr <= addr_in;

    data_in <= axis_in_tdata(DATA_WIDTH - 1 downto 0);

    mult <= scale_data * axis_in_tdata(DATA_WIDTH - 1 downto 0);
    data_out <= mult(14+DATA_WIDTH-1 downto 14) + offset_data(DATA_WIDTH-1 downto 0);

    axis_process: process(aclk, arstn) begin
        if (rising_edge(aclk)) then
            if (axis_out_tready = '1') then
                axis_in_tready <= '1';
                if (axis_in_tvalid = '1') then
                    axis_out_tvalid <= '1';
                    axis_out_tdata <= addr_out & data_out;
                else
                    axis_out_tvalid <= '0';
                    axis_out_tdata <= (others => '0');
                end if;
            else
                axis_in_tready <= '0';
                axis_out_tvalid <= '0';
                axis_out_tdata <= (others => '0');
            end if;
        end if;

    end process;

  end rtl;