----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2017 19:04:48
-- Design Name: 
-- Module Name: Tachyon16k_IF_VU - Behavioral
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

entity Tachyon16k_IF_v2clamir_VU is



GENERIC(
      SYS_CLK         : INTEGER := 100000000; --system clock frequency in Hz
      CNT_WITH : INTEGER := 20);
port ( 
  
      CLK  : in std_logic;
      RESET : in std_logic;
        
  --TACHYON16K
     roic_CLK : out std_logic;
     roic_CLK_periph : out std_logic;
     roic_bus : out std_logic;
     roic_xrst : out std_logic;
     roic_xanalog_rst : out std_logic;
     roic_DB: out std_logic;
     roic_rstneg: out std_logic;
     roic_rowsel: out std_logic_vector (6 downto 0);
     roic_colsel: out std_logic_vector (6 downto 0);
     roic_DIN10: out std_logic;
     roic_DINDB10: out std_logic;
     roic_DOUT: in std_logic_vector (13 downto 0);
     roic_DOUTDB:in std_logic_vector (13 downto 0);
             
     IMG_ADDR : out STD_LOGIC_VECTOR (10 downto 0);
     IMG_data_out_concat: out std_logic_vector (31 downto 0);
     IMG_Data_write : out std_logic;
     DRIFT_ADDR : out STD_LOGIC_VECTOR (5 downto 0);
     DRIFT_Data_write : out std_logic;
      
     --Windowing
     Y1: in std_logic_vector (6 downto 0);
     Y2: in std_logic_vector (6 downto 0);
      
     --ap_ctrl_chain last block
     ap_start : in STD_logic;
     ap_done : out STD_logic;  
     ap_idle: out STD_logic;  
         
     INTEGRATION_TIME_in: in std_logic_vector (19 downto 0);
     ENA: in std_logic 
     
);
end Tachyon16k_IF_v2clamir_VU;


architecture Behavioral of Tachyon16k_IF_v2clamir_VU is
 

constant XANALOGRST_TO_BUS_cte : integer :=2;   
constant IO_TO_BUS_cte : integer :=13;        
constant BUS_to_XRST_cte  : integer :=7;       
constant XRST_TO_XRST_cte  : integer :=10;       
constant XRST_TO_INTEGRACION_cte : integer :=2;
constant Width : std_logic_vector (6 downto 0):=conv_std_logic_vector(127,7);
constant Width_quarter : std_logic_vector (6 downto 0):=conv_std_logic_vector(32,7);
constant Width_half : std_logic_vector (6 downto 0):=conv_std_logic_vector(64,7);
constant Width_3quarter : std_logic_vector (6 downto 0):=conv_std_logic_vector(96,7);

type TIPO_ESTADO_state is (IDLE, INTEGRATION,XANALOGRST_TO_BUS, FIRST_IO, IO,LAST_IO,IO_TO_BUS,BUS_TO_XRST, XRST_TO_XRST, XRST_TO_INTEGRATION, POWER_OFF);
  signal ESTADO: TIPO_ESTADO_state;
attribute dont_touch : string;
  
   signal cnt_SM: std_logic_vector (CNT_WITH-1 downto 0);
   signal INTEGRATION_time: std_logic_vector (CNT_WITH-1 downto 0);
   signal XANALOGRST_TO_BUS_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal IO_TO_BUS_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal BUS_TO_XRST_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal XRST_TO_XRST_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal XRST_TO_INTEGRACION_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal CNT_ROW: std_logic_vector (6 downto 0);
   signal CNT_ROW_REG: std_logic_vector (6 downto 0);  
   signal CNT_COL: std_logic_vector (5 downto 0); -- solo 6 bits porque siempre suamos DB
   signal IMG_ADDR_reg : std_logic_vector (10 downto 0);
   signal IMG_Data_write_reg: std_logic;
   
   signal IMG_ADDR_reg2 : std_logic_vector (10 downto 0);
      signal IMG_Data_write_reg2: std_logic;
      
   signal IMG_ADDR_reg3 : std_logic_vector (10 downto 0);
         signal IMG_Data_write_reg3: std_logic;   
   
   
   signal Height : std_logic_vector (6 downto 0);
   signal roic_CLK_reg: std_logic;
    
   signal Y1_reg: std_logic_vector (6 downto 0);--prioridad a quitar filas
   signal Y2_reg: std_logic_vector (6 downto 0);
   signal flag_windowing_change: std_logic;
   signal DRIFT_ADDR_reg: std_logic_vector (5 downto 0);

begin

roic_CLK  <= roic_CLK_reg;

process (CLK)
begin

IF (CLK'EVENT AND CLK = '1') THEN
   if(RESET ='1') then
    
      ap_done <= '0';
      ap_idle <=  '0';
      roic_rowsel <=  (others => '0');
      roic_colsel <=  (others => '0');
      roic_xrst <=  '0';
      roic_xanalog_rst <=  '0';
      roic_rstneg <=  '0';    
      roic_bus <=  '0';
      roic_CLK_periph <=  '0';
      roic_DB <=  '1';                 
      roic_DIN10 <=  '1';
      roic_DINDB10 <=  '1';
      
      IMG_ADDR  <=  (others => '0');
      IMG_data_out_concat <= (others =>'0');
      IMG_Data_write <='0';
      roic_CLK_reg<='0';
      cnt_SM <= (others => '0');
      IMG_ADDR_reg<= (others => '0');
      IMG_Data_write_reg<='0';
      
      IMG_ADDR_reg2<= (others => '0');
      IMG_Data_write_reg2<='0';
            
       IMG_ADDR_reg3<= (others => '0');
       IMG_Data_write_reg3<='0';     
      
      INTEGRATION_time <= INTEGRATION_TIME_in;
      XANALOGRST_TO_BUS_time <= conv_std_logic_vector(XANALOGRST_TO_BUS_cte,CNT_WITH);
      IO_TO_BUS_time<= conv_std_logic_vector(IO_TO_BUS_cte,CNT_WITH);
      BUS_TO_XRST_time<= conv_std_logic_vector(bus_TO_XRST_cte,CNT_WITH);
      XRST_TO_XRST_time <= conv_std_logic_vector(XRST_TO_XRST_cte,CNT_WITH);
      XRST_TO_INTEGRACION_time <= conv_std_logic_vector(XRST_TO_INTEGRACION_cte,CNT_WITH);
      
      CNT_ROW <= (others =>'0');
      CNT_ROW_REG <= (others =>'0');
      CNT_COL <= (others =>'0');
      Height <= conv_std_logic_vector(127,7);
      flag_windowing_change <='0';
      
      Y1_reg <= (others =>'0');
      Y2_reg <= (others =>'0');
      DRIFT_ADDR_reg <= (others =>'0');
      DRIFT_ADDR <= (others =>'0');
      DRIFT_Data_write<='0';
            
   else
    
      cnt_SM<=cnt_SM+1;
    
         case ESTADO is
            when IDLE => 
             
               roic_rowsel <=  (others => '0');
               roic_colsel <=  (others => '0');
                
               roic_xrst <=  '1';--change
               roic_xanalog_rst <=  '1'; 
               roic_rstneg <=  '0';   
               roic_bus <=  '0'; 
               roic_CLK_reg <=  '0';
               roic_CLK_periph <=  '0';
               roic_DIN10 <=  '0';
               roic_DINDB10 <=  '0';
                
               IMG_ADDR  <=  (others => '0');
               IMG_data_out_concat <=  (others => '0'); 
                
               cnt_SM <= (others => '0');
               ap_idle<='1'; 
               ap_done<='0';
               DRIFT_ADDR_reg <= (others =>'0');
                     DRIFT_ADDR <= (others =>'0');
                     DRIFT_Data_write<='0';
                Y1_reg<=conv_std_logic_vector(0,7);
                Y2_reg <=conv_std_logic_vector(127,7);
               
               if (ap_start = '1') then
                  Height <= (Y2_reg-Y1_reg);
                  if(flag_windowing_change = '1') then
                    ESTADO<= POWER_OFF;
                  else
                    ESTADO <= INTEGRATION;
                    INTEGRATION_time<= INTEGRATION_TIME_in;
                  end if;
               end if; 
             
            when INTEGRATION =>
               
                roic_xanalog_rst <=  '0';
                ap_idle<='0'; 
                
                if (cnt_SM >= INTEGRATION_time) then
                  ESTADO <= XANALOGRST_TO_BUS;
                  cnt_SM <= (others => '0');
                else
                  ESTADO <= INTEGRATION;
                end if;
                
             when XANALOGRST_TO_BUS =>
                
                roic_xanalog_rst <=  '1'; --change
                                                
                if (cnt_SM >= XANALOGRST_TO_BUS_time)
                then
                   ESTADO <= FIRST_IO;
                   cnt_SM <= (others => '0');
                else
                   ESTADO <= XANALOGRST_TO_BUS;
                end if;   
                                         
             when FIRST_IO =>
                  roic_rstneg <=  '1';   
                  roic_bus <=  '1';  
                  roic_rowsel <= (Y1_reg + CNT_ROW_REG);
                  CNT_ROW_REG <= CNT_ROW;
                  roic_colsel(6 downto 1) <=CNT_COL;-- & '0';
                   
                  if ((CNT_COL & '0') = Width_quarter) and (cnt_SM(0) = '1') 
                  then
                     roic_CLK_reg <= not roic_CLK_reg;
                  end if;
                  
                  roic_CLK_periph <=  not (cnt_SM(0));
                  roic_DIN10 <=  '1';
                  roic_DINDB10 <=  '1';
                                                      
                  if ( cnt_SM(0) = '1') then
                     CNT_COL <= CNT_COL +1;
                  end if;
                                                
                  if (((CNT_COL & '0') = Width_half) and (cnt_SM(0) = '1')) 
                  then
                     ESTADO <= IO;
                     cnt_SM <= (others => '0');                     
                     IMG_ADDR_reg <=(others => '0');  --cambio clamir para direccionar imagen de 0 a 4095
                     roic_CLK_reg <= not roic_CLK_reg;
                  else
                     ESTADO <= FIRST_IO;
                  end if; 
                 
               when IO =>
             
                  roic_rowsel <=  (Y1_reg + CNT_ROW_REG);
                  CNT_ROW_REG <= CNT_ROW;
                  roic_colsel(6 downto 1) <=CNT_COL;-- & '0';
                   
                  if (cnt_SM(0) = '1') then
                     if (((CNT_COL & '0') = 0) or ((CNT_COL(5 downto 0) & '0') = (Width_quarter)) or ((CNT_COL & '0') =  (Width_half))or ((CNT_COL(5 downto 0) & '0') = (Width_3quarter))) then --fijos para 128
                        roic_CLK_reg <= not roic_CLK_reg;
                     end if;
                  end if;
                
                  roic_CLK_periph <=  not (cnt_SM(0));
                  
                  IMG_ADDR_reg2 <= IMG_ADDR_reg;
                  IMG_ADDR_reg3 <= IMG_ADDR_reg2;         
                  IMG_ADDR <= IMG_ADDR_reg3;
                  
                  IMG_data_out_concat <= roic_DoutDB & "00" & roic_DOUT & "00"; --cambiado para CLAMIR
                                                     
                  if (CNT_ROW = 32) then
                    if (CNT_COL >= 48) then
                        IMG_Data_write_reg <= not cnt_SM(0);
                        if ( cnt_SM(0) = '1') then
                            IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
                        end if; 
                     else
                        IMG_Data_write_reg <= '0';   
                     end if;
                  end if;
                  if ((CNT_ROW >32) and (CNT_ROW <96)) then
                    if ((CNT_COL >= 48) or (CNT_COL<16)) then
                        IMG_Data_write_reg <= not cnt_SM(0);
                        if ( cnt_SM(0) = '1') then
                            IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
                        end if;    
                     else
                         IMG_Data_write_reg <= '0'; 
                     end if;
                  end if;
                  if (CNT_ROW = 96) then
                    if (CNT_COL < 16) then
                        IMG_Data_write_reg <= not cnt_SM(0);
                        if ( cnt_SM(0) = '1') then
                            IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
                        end if; 
                     else
                        IMG_Data_write_reg <= '0'; 
                     end if;
                  end if;
                    
                  IMG_Data_write_reg2 <=IMG_Data_write_reg;
                  IMG_Data_write_reg3 <=IMG_Data_write_reg2;
                  IMG_Data_write <= IMG_Data_write_reg3;
                    
                  if ( cnt_SM(0) = '1') then
                     if ( (CNT_COL) = Width(6 downto 1)) then
                        CNT_ROW <= CNT_ROW +1;
                        CNT_COL <= (others => '0');
                     else      
                        CNT_COL <= CNT_COL +1;
                     end if;
                  end if;
                  
                  if ((CNT_ROW = height) and (CNT_COL > (width_quarter-1))) then
                  DRIFT_Data_write <= not cnt_SM(0);
                  DRIFT_ADDR <= DRIFT_ADDR_reg;
                  if ( cnt_SM(0) = '1') then
                                       
                   DRIFT_ADDR_reg  <=  DRIFT_ADDR_reg +1;
                   end if;
                  end if;
                  
                  
                  
                                  
                  if (((CNT_COL ) = Width (6 downto 1)) and (CNT_ROW = height)and (cnt_SM(0) = '1')) then
                     ESTADO <= LAST_IO;
                     cnt_SM <= (others => '0');
                  else
                     ESTADO <= IO;
                  end if; 
                    
               when LAST_IO =>
                  roic_rowsel <=  (Y1_reg + CNT_ROW_REG);
                  roic_colsel(6 downto 1) <=CNT_COL;-- & '0';
                   
                  roic_CLK_periph <=  not (cnt_SM(0));
                  
                  roic_DIN10 <=  '1';
                  roic_DINDB10 <=  '1';
                                    
                   IMG_Data_write<='0';
                   IMG_data_out_concat <= roic_DoutDB & "00" & roic_DOUT & "00";
                   
                   DRIFT_Data_write <= not cnt_SM(0);
                  if ( cnt_SM(0) = '1') then
                      
                      DRIFT_ADDR_reg  <=  DRIFT_ADDR_reg +1;
                      
                  end if;
                    DRIFT_ADDR <= DRIFT_ADDR_reg;
           
                  if ( cnt_SM(0) = '1') then
                      CNT_COL <= CNT_COL +1;
                      roic_CLK_reg<='0';
                  end if;
                  
                  if ((CNT_COL = (width_quarter-1)) and (cnt_SM(0) = '1')) then
                     ESTADO <= IO_TO_BUS;
                     IMG_Data_write_reg<='0'; --mirar
                     cnt_SM <= (others => '0');
                  else
                     ESTADO <= LAST_IO;
                  end if; 
                               
               when IO_TO_BUS =>
                  roic_DIN10 <=  '0'; --prueba rapida viernes 10 enero
                  roic_DINDB10 <=  '0';
                  
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  
                  
                                    
                   if(cnt_SM<2) then  
                      IMG_data_out_concat <= roic_DoutDB & "00" & roic_DOUT & "00";
                      if (( cnt_SM(0) = '1') and (DRIFT_ADDR_reg < 64)) then
                        DRIFT_ADDR_reg  <=  DRIFT_ADDR_reg +1;
                      end if;  
                  end if;
                  
                   
                  CNT_COL <= (others => '0');
                  CNT_ROW <= (others => '0'); 
                  CNT_ROW_REG <= (others => '0');
                   
                  if (cnt_SM >= IO_TO_BUS_time) then
                     ESTADO <= BUS_TO_XRST;
                     cnt_SM <= (others => '0');
                  else
                     ESTADO <= IO_TO_BUS;
                  end if;
                  
               when BUS_TO_XRST =>
                  
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  IMG_ADDR  <=  (others => '0');
                  IMG_data_out_concat <= (others =>'0');
                   
                  if (cnt_SM >= BUS_TO_XRST_time)
                  then
                    ESTADO <= XRST_TO_XRST;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= BUS_TO_XRST;
                  end if;
               
               when XRST_TO_XRST =>
                  roic_xrst <=  '0';--change
                  if (cnt_SM >= XRST_TO_XRST_time) then
                    ESTADO <= XRST_TO_INTEGRATION;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= XRST_TO_XRST;
                  end if;
                  
               when XRST_TO_INTEGRATION =>
                 roic_xrst <=  '1';--change
                 if (cnt_SM >= XRST_TO_INTEGRACION_time) then
                    cnt_SM <= (others => '0');
                    ESTADO <= IDLE;
                    ap_done<='1';
                      
                 else
                    ESTADO <= XRST_TO_INTEGRATION;
                 end if; 
               
               when POWER_OFF=>
               
               roic_rowsel <=  (127 - CNT_ROW_REG);
               CNT_ROW_REG <= CNT_ROW;
               roic_colsel(6 downto 1) <=CNT_COL;-- & '0';
               
               if  ((CNT_ROW_REG)>Y2_reg) or ((CNT_ROW_REG)<Y1_reg) then
                roic_DIN10 <=  '0';
                roic_DINDB10 <=  '0';
               else
                roic_DIN10 <=  '1';
                roic_DINDB10 <=  '1';
               end if;
                 
                if (cnt_SM(0) = '1') then
                   if (((CNT_COL & '0') = 0) or ((CNT_COL(5 downto 0) & '0') = (Width_quarter)) or ((CNT_COL & '0') =  (Width_half))or ((CNT_COL(5 downto 0) & '0') = (Width_3quarter))) then --fijos para 128
                      roic_CLK_reg <= not roic_CLK_reg;
                   end if;
                end if;
               
               roic_CLK_periph <=  not (cnt_SM(0));
                    
               if ( cnt_SM(0) = '1') then
                  if ( (CNT_COL) = Width(6 downto 1)) then
                     CNT_ROW <= CNT_ROW +1;
                     CNT_COL <= (others => '0');
                  else      
                     CNT_COL <= CNT_COL +1;
                  end if;
               end if;
                               
               if (((CNT_COL ) = Width (6 downto 1)) and (CNT_ROW = 127)and (cnt_SM(0) = '1')) then
                  ESTADO <= IDLE;
                  flag_windowing_change <='0';
                  cnt_SM <= (others => '0');
               else
                  ESTADO <= POWER_OFF;
               end if; 
               
               when others=>  
                ESTADO <= IDLE;
                 
             end case;
        end if;  
        roic_colsel(0) <='0';
end if;

end process;

end Behavioral;
