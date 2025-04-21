----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.02.2017 18:37:46
-- Design Name: 
-- Module Name: ADC_temp_VU - Behavioral
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_DAC_analog_output is
GENERIC(
      clk_prescaler  : INTEGER := 8); 

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
       attribute DONT_TOUCH : string; 
     
end SPI_DAC_analog_output;


  
architecture Behavioral of SPI_DAC_analog_output is

type TIPO_SPI_state is (SPI_IDLE, DAC_TX);
  signal SPI_state: TIPO_SPI_state;
 attribute dont_touch of SPI_state : signal is "true";  

signal clk_counter : std_logic_vector (7 downto 0);
 attribute dont_touch of clk_counter : signal is "true";
signal bits_counter : std_logic_vector (5 downto 0);
 attribute dont_touch of bits_counter : signal is "true";

signal dac_counter : std_logic_vector (3 downto 0);
 attribute dont_touch of dac_counter : signal is "true";
signal ap_start_REG: std_logic:='0';
 attribute dont_touch of ap_start_REG : signal is "true";
signal DAC_reg: std_logic_vector (31 downto 0):=(others => '0');
 attribute dont_touch of DAC_reg : signal is "true";

begin

process (CLK)
begin

IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') 
    then
 
        ap_done <= '0';
        ap_idle <= '0';  
        clk_counter <= (others => '0');
        bits_counter <= (others => '0');

        dac_counter<= (others => '0');
        CSn <= '1';
        SCLK <='1';
        DOUT <='0';
        nCLR <='1';
        ap_start_REG<='0';

        SPI_state <= SPI_IDLE;
    
    else
    
     nCLR <='1';
    
    if (ap_start ='1') then
      ap_start_REG<= '1';
    end if;
        
        case SPI_state is
            
            when SPI_IDLE =>
                SCLK <='1';
                DOUT <='0';
                CSn <= '1';
                ap_done <= '0';
                ap_idle <= '1';  
                bits_counter<= (others => '0');
                dac_counter <= x"D";
                
                if (ap_start_REG = '1') then
                              
                   ap_start_REG<='0';
                   SPI_state <= DAC_TX;
                   CSn <= '0';
                   clk_counter <=(others => '0');
                   ap_idle <= '0';
                   
                   if (DAC_value>DAC_max_lim)
                    then
                      DAC_reg<=DAC_max_lim;
                      if(DAC_reg = DAC_max_lim) then
                           SPI_state <= SPI_IDLE;
                       end if;   
                    elsif (DAC_value<DAC_min_lim)  then
                      DAC_reg<=DAC_min_lim;
                      if(DAC_reg = DAC_min_lim) then
                          SPI_state <= SPI_IDLE;
                        end if;
                    else
                      DAC_reg<=DAC_value;
                       if(DAC_reg = DAC_value) then
                              SPI_state <= SPI_IDLE;
                          end if;
                      
                      end if;   
                  
               end if; 
            
           
            when DAC_TX =>
            
            clk_counter <= clk_counter + 1 ;
                            
            if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,8)) then
                clk_counter <=(others => '0');
                SCLK <= '0';
                bits_counter <= bits_counter +1 ;
                if(bits_counter >1)and (dac_counter > 0)  then
                   dac_counter <=   dac_counter - 1;
                end if; 
                               
                --if (bits_counter = 23) then              
                if (bits_counter = 15) then
                   SPI_state <= SPI_IDLE; 
                   --dac_test_counter <= dac_test_counter + 1; 
                   ap_done <= '1';
                    
                end if;  
            
             elsif(clk_counter = conv_std_logic_vector(clk_prescaler/2,8)) then
                 SCLK <= '0';
                 
             elsif(clk_counter > conv_std_logic_vector(clk_prescaler/2,8)) then
                 SCLK <= '0';
             else
                 SCLK <= '1';
             end if;
             
             if(bits_counter = 0) then
                Dout<= '0';
             elsif(bits_counter = 1) then
                Dout<= '1';
             else
                Dout<= DAC_reg(conv_integer(dac_counter));
             end if;
            
            when others =>
            
            end case;
               
  end if;
end if;

end process;

end Behavioral;
