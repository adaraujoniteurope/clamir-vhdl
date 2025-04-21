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


--New version for 16 bits ad5060 (ad5040 its obsolete)
--change from 16 bits (00 + data) to 24 bits 00000000 + data16
--input 14 bits shifted 2 positiones 00000000 + data14 + 00


entity SPI_ctrl_VU is
GENERIC(
      clk_prescaler  : INTEGER := 8); 

Port (
  --sys
      CLK  : in std_logic;
      RESET : in std_logic;
      
      ADC_CSn : out std_logic;
      DAC_CSn : out std_logic;
      SCLK: out std_logic;
      DIN: in std_logic;
      DOUT: out std_logic;
       
      TEMP1 : out std_logic_vector (11 downto 0):=(others => '0');
      TEMP2 : out std_logic_vector (11 downto 0):=(others => '0');
      TEMP3 : out std_logic_vector (11 downto 0):=(others => '0');
      TEMP4 : out std_logic_vector (11 downto 0):=(others => '0');
      
      DAC : in std_logic_vector (13 downto 0);
      --DAC_test_in  : in std_logic;
            
      --ap_ctrl_chain last block
      ap_start_ADC : in STD_logic;
      ap_done_ADC : out STD_logic;  
      ap_idle_ADC: out STD_logic;  
      
       --ap_ctrl_chain last block
      ap_start_DAC : in STD_logic;
      ap_done_DAC : out STD_logic;  
      ap_idle_DAC: out STD_logic
                
     );
end SPI_ctrl_VU;

architecture Behavioral of SPI_ctrl_VU is

type TIPO_SPI_state is (SPI_IDLE, ADC_TX, DAC_TX);
  signal SPI_state: TIPO_SPI_state;

signal clk_counter : std_logic_vector (7 downto 0);
signal bits_counter : std_logic_vector (5 downto 0);

signal data_in_reg : std_logic_vector (11 downto 0):=(others => '0');
signal dac_counter : std_logic_vector (3 downto 0);
signal ap_start_ADC_REG: std_logic:='0';
signal ap_start_DAC_REG: std_logic:='0';
signal DAC_reg: std_logic_vector (15 downto 0):=(others => '0');
signal DAC_test_counter: std_logic_vector (9 downto 0):=(others => '0');



begin

process (CLK)
begin

IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') 
    then
--        TEMP1 <= (others => '0');
--        TEMP2 <= (others => '0');
--        TEMP3 <= (others => '0');
--        TEMP4 <= (others => '0');
        ap_done_ADC <= '0';
        ap_idle_ADC <= '0';  
        ap_done_DAC <= '0';
        ap_idle_DAC <= '0';  
        clk_counter <= (others => '0');
        bits_counter <= (others => '0');
        --data_in_reg <= (others => '0');
        dac_counter<= (others => '0');
        --dac_test_counter<= (others => '0');
        --DAC_reg<= (others => '0'); 
        ADC_CSn <= '1';
        DAC_CSn <= '1';
        SCLK <='1';
        DOUT <='0';
        --ap_start_ADC_REG <= '0';
        --ap_start_DAC_REG <= '0';
        SPI_state <= SPI_IDLE;
    
    else
    
    if (ap_start_ADC ='1') then
    ap_start_ADC_REG<= '1';
    end if;
    
    if (ap_start_DAC ='1') then
      ap_start_DAC_REG<= '1';
    end if;
        
        case SPI_state is
            
            when SPI_IDLE =>
                SCLK <='1';
                DOUT <='0';
                ADC_CSn <= '1';
                DAC_CSn <= '1';
                ap_done_ADC <= '0';
                ap_idle_ADC <= '1';  
                bits_counter<= (others => '0');
                data_in_reg<= (others => '0');
                dac_counter <= x"F";
                
                               
                if (ap_start_ADC_REG = '1') then
                    ap_start_ADC_REG<='0';
                   SPI_state <= ADC_TX;
                   ADC_CSn <= '0';
                   clk_counter <=(others => '0');
                   ap_idle_ADC <= '0'; 
                elsif (ap_start_DAC_REG = '1') then
                if (DAC_reg = (DAC & "00")) then
                     ap_start_DAC_REG<='0';
                else     
                     
                -- if (DAC_test_in = '1') then 
                --      DAC_reg<=DAC + (dac_test_counter & "0000");
                --  else
                      DAC_reg<= DAC & "00";
               --   end if;
                
                   ap_start_DAC_REG<='0';
                   SPI_state <= DAC_TX;
                   DAC_CSn <= '0';
                   clk_counter <=(others => '0');
                   ap_idle_DAC <= '0'; 
                end if;   
               end if; 
            
           when ADC_TX =>
           
            clk_counter <= clk_counter + 1 ;
                                      
                         if(clk_counter = conv_std_logic_vector((clk_prescaler/2),8)) then
                             data_in_reg <= data_in_reg(10 downto 0) & Din; 
                             if (bits_counter = 15) then
                             TEMP1 <= data_in_reg(10 downto 0) & Din; 
                             end if;  
                             if (bits_counter = 31) then
                             TEMP2 <= data_in_reg(10 downto 0) & Din; 
                             end if; 
                             if (bits_counter = 47) then
                             TEMP3 <= data_in_reg(10 downto 0) & Din; 
                             end if; 
                             if (bits_counter = 63) then
                             TEMP4 <= data_in_reg(10 downto 0) & Din; 
                             end if; 
                         end if;
                         
                         if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,8)) then
                            clk_counter <=(others => '0');
                            SCLK <= '1';
                            bits_counter <= bits_counter +1 ;
                            if (bits_counter = 63) then
                                     SPI_state <= SPI_IDLE; 
                                     ap_done_ADC <= '1';
                                
                            end if;  
                            
                         
                         
                         elsif(clk_counter >= conv_std_logic_vector(clk_prescaler/2,8)) then
                             SCLK <= '1';
                           
                         else
                             SCLK <= '0';
                         end if;
                         
                         if(bits_counter = 4) or (bits_counter = 19) or (bits_counter = 35) or (bits_counter = 36) then
                         Dout<= '1';
                         else
                         Dout<= '0';
                         end if;
                         
                
            
            when DAC_TX =>
            
            clk_counter <= clk_counter + 1 ;
                            
            if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,8)) then
                clk_counter <=(others => '0');
                SCLK <= '0';
                bits_counter <= bits_counter +1 ;
                if(bits_counter >7)and (dac_counter > 0)  then
                   dac_counter <=   dac_counter - 1;
                end if; 
                               
                if (bits_counter = 23) then              
                --if (bits_counter = 15) then
                   SPI_state <= SPI_IDLE; 
                   dac_test_counter <= dac_test_counter + 1; 
                   ap_done_DAC <= '1';
                    
                end if;  
            
             elsif(clk_counter = conv_std_logic_vector(clk_prescaler/2,8)) then
                 SCLK <= '0';
                 
             elsif(clk_counter > conv_std_logic_vector(clk_prescaler/2,8)) then
                 SCLK <= '0';
             else
                 SCLK <= '1';
             end if;
             
             if(bits_counter < 8) then
                Dout<= '0';
             else
                Dout<= DAC_reg(conv_integer(dac_counter));
             end if;
            
            when others =>
            
            end case;
               
  end if;
end if;

end process;

end Behavioral;
