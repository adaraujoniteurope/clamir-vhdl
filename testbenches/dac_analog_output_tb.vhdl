-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : tb_track_cnt
-- Description : Test current track calculation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.all;

entity dac_analog_output_tb is
end dac_analog_output_tb;

architecture behavioral of dac_analog_output_tb is

  signal clk  : std_logic := '1';
  signal RESET : std_logic:= '0';
    
 signal CSn :  std_logic;
 signal SCLK:  std_logic;
 signal DOUT:  std_logic;
 signal nCLR:  std_logic;
 signal DAC_max_lim :   std_logic_vector(31 downto 0):=conv_std_logic_vector (5000,32);
 signal DAC_min_lim :   std_logic_vector(31 downto 0):=conv_std_logic_vector (1000,32);
 signal DAC_value    :   std_logic_vector(31 downto 0):=conv_std_logic_vector (2000,32); 
                    
 signal ap_start :  STD_logic:='0';
 signal ap_done :  STD_logic;  
 signal ap_idle:  STD_logic;

 constant CLK_PERIOD : time := 10 ns;
          
 component spi_dac_analog_output is
  GENERIC(
        CLK_PRESCALER  : INTEGER := 8); 
  
  Port (
    --sys
        CLK  : in std_logic;
        RESET : in std_logic;
        
        CSn : out std_logic;
        SCLK: out std_logic;
        DOUT: out std_logic;
        nCLR: out std_logic;
         
        DAC_max_lim : in  std_logic_vector(31 downto 0);
        DAC_min_lim : in  std_logic_vector(31 downto 0);
        DAC_value    : in  std_logic_vector(31 downto 0); 
                    
        ap_start : in STD_logic;
        ap_done : out STD_logic;  
        ap_idle: out STD_logic
                  
       );
       
  end component;

begin

  -- Generate clock
  clk <= not(clk) after 5 ns;
 

  -- Generate reset (active low)
  RESET <= '1', '0' after 250 ns;
 
 -- IMG_data_in <= (cnt_aux + cnt_aux2)  after 20 ns;
  --cnt_aux <= (cnt_aux + 57)  after 20 ns;
  --cnt_aux2 <= (cnt_aux2 + 10237)  after 30700 ns;

 
 
 
  p_mom : process(clk)
  begin
    if rising_edge(clk) then
      if (RESET = '1') then
        
      else
      
      end if;
    end if;
  end process;

 
  p_mode : process
  begin
    wait for 5 us;
    ap_start <='1';
   
    wait for CLK_PERIOD;
    ap_start <='0';
    
    
     wait for 5 us;
       ap_start <='1';
      
       wait for CLK_PERIOD;
       ap_start <='0';
       DAC_value <= conv_std_logic_vector (4999,32); 
        wait for 5 us;
          ap_start <='1';
         
          wait for CLK_PERIOD;
          ap_start <='0';
          DAC_value <= conv_std_logic_vector (5000,32); 
           wait for 5 us;
             ap_start <='1';
            
             wait for CLK_PERIOD;
             ap_start <='0';
             DAC_value <= conv_std_logic_vector (8000,32); 
              wait for 5 us;
                ap_start <='1';
               
                wait for CLK_PERIOD;
                ap_start <='0';
                DAC_max_lim <= conv_std_logic_vector (4500,32); 
                 wait for 5 us;
                   ap_start <='1';
                  
                   wait for CLK_PERIOD;
                   ap_start <='0';
                  
                    wait for 5 us;
                      ap_start <='1';
                     
                      wait for CLK_PERIOD;
                      ap_start <='0';
                      DAC_max_lim <= conv_std_logic_vector (2300,32);  
    --wait for 200 us;
    --BIN_threshold <= conv_std_logic_vector (5000,16);
      
    
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for 200 us;
    wait for CLK_PERIOD;
     ap_start <='1';
     
    
     wait for CLK_PERIOD;
     ap_start <='0';
     
   
    wait;
  end process;

  ROI_round_fly_inst : spi_dac_analog_output
    port map (
      clk => clk,
      RESET => RESET,
      
      CSn => CSn,
      SCLK=> SCLK,
      DOUT=> DOUT,
      nCLR=> nCLR,
      DAC_max_lim => DAC_max_lim,
      DAC_min_lim=> DAC_min_lim,
      DAC_value   => DAC_value,
                  
      ap_start=> ap_start,
      ap_done=> ap_done,
      ap_idle=> ap_idle
      
      
    );

end behavioral;
