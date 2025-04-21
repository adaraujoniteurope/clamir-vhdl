----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2017 17:26:41
-- Design Name: 
-- Module Name: procc_offset - Behavioral
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



library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity procc_offset is

GENERIC(
      sys_clk         : INTEGER := 100_000_000; --system clock frequency in Hz
      IMG_bits        : INTEGER := 16;    
      ADDR_bits : INTEGER := 12);          
  Port ( 
  
      CLK  : in std_logic;
      RESET : in std_logic;
  
  --IMG_Memory
      IMG_Data_In : in STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      IMG_Data_Out : out STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      OFFSET_Data_In :  in STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      OFFSET_Data_out :  out STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      Address_in : out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
      IMG_mem_web : out STD_LOGIC;
      OFFSET_mem_web : out STD_LOGIC;          
      Address_out : out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
      
      substract: in std_logic;
      update: in std_logic;
      
      black_level: in std_logic_vector (15 downto 0);
      drift_level: in std_logic_vector (15 downto 0);
      drift_correction_enable: in std_logic;
      
      --ap_ctrl_chain last block
      ap_start : in STD_logic;
      ap_done : out STD_logic;  
      ap_idle: out STD_logic;  
          
      --configuration registers    
      ENA: in std_logic
  
  );
end procc_offset;

architecture Behavioral of procc_offset is

type TIPO_GLOBAL_STATE is (IDLE, SUBSTRACT_state,READY);
  signal GLOBAL_STATE: TIPO_GLOBAL_STATE;
  
  
signal Address_signal: std_logic_vector (ADDR_bits downto 0);
signal Address_signal_reg: std_logic_vector (ADDR_bits downto 0);
  
signal update_reg: std_logic;
signal drift_level_reg: std_logic_vector (15 downto 0);
signal drift_offset_reg: std_logic_vector (15 downto 0);
signal drift_no_offset_reg: std_logic_vector (15 downto 0);


begin

Address_in<=Address_signal(ADDR_bits-1 downto 0);


process (CLK)
begin


IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') then
    
     ap_done <= '0';
     ap_idle <=  '0';
     Global_state <= IDLE;     
     Address_signal<= (others => '0');
     IMG_Data_Out<= (others => '0');
     OFFSET_Data_out<= (others => '0');
     IMG_mem_web<= '0';
     OFFSET_mem_web <='0';
     update_reg<='0';
     drift_level_reg <= (others => '0');
     drift_offset_reg<= (others => '0');
     drift_no_offset_reg<= (others => '0');
    else
    
  Address_out<=Address_signal_reg(ADDR_bits-1 downto 0);
  Address_signal_reg<=Address_signal;      
        case Global_state is
            
         when IDLE =>
              OFFSET_mem_web <='0';
              IMG_mem_web <='0';  
              ap_idle <=  '1';  
              ap_done <= '0';
              Address_signal<= (others => '0');
              if (update ='1') then
                update_reg<='1';
                drift_offset_reg<=drift_level;
              end if;
              if (ENA = '1')
              then
                  if (ap_start ='1') 
                  then
                       if (drift_correction_enable = '1') then
                        drift_level_reg <= drift_level;
                        drift_no_offset_reg <= drift_level - drift_offset_reg;     
                       else
                        drift_level_reg <= (others => '0');
                        drift_no_offset_reg <= (others => '0');
                       end if; 
                       ap_idle <=  '0';
                       Global_state <= SUBSTRACT_state;     
                       Address_signal<= conv_std_logic_vector(1,ADDR_bits+1);
                  end if;
              else
              
              end if;
              
         when SUBSTRACT_state =>
         
         
         IMG_mem_web<='1';
         if (update_reg = '1') then
            OFFSET_mem_web <='1';
         else
            OFFSET_mem_web <='0';
         end if;
         
         for I in 0 to (IMG_bits/16)-1 loop
            if (substract = '1') then   
                IMG_Data_Out((16*I)+15 downto 16*I) <= IMG_Data_in((16*I)+15 downto 16*I) - OFFSET_Data_in((16*I)+15 downto 16*I) + black_level - drift_no_offset_reg;
            else
                IMG_Data_Out((16*I)+15 downto 16*I) <= IMG_Data_in((16*I)+15 downto 16*I) + black_level - drift_level_reg;
            end if;    
                
                OFFSET_Data_Out((16*I)+15 downto 16*I) <= IMG_Data_in((16*I)+15 downto 16*I);
         
         end loop;
         
         Address_signal <= Address_signal + 1;
         if (Address_signal = (2**ADDR_bits)+1) then
            ap_done<='1';
            Global_state <= IDLE;  
            IMG_mem_web<='0';
            OFFSET_mem_web <='0';
            update_reg<='0';
         end if;     
         
              
         when others =>
              
              Global_state <= IDLE;        
        end case;        
        
    end if;
    
    end if;
    
    end process;
    
    
    end Behavioral;
    
    
    
    
