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


entity Tachyon16k_IF_VU is

GENERIC(
      sys_clk         : INTEGER := 100000000; --system clock frequency in Hz
      CNT_WITH : INTEGER := 23);
port ( 
  
      CLK  : in std_logic;
      RESET : in std_logic;
        
  --TACHYON16K
     roic_CLK : out std_logic;
     roic_CLK_periph : out std_logic;
     roic_xcount : out std_logic;
     roic_bus : out std_logic;
     roic_xrst : out std_logic;
     roic_xanalog_rst : out std_logic;
     roic_xtest : out std_logic;
     roic_gain2 : out std_logic;
     roic_DB: out std_logic;
     roic_phi4: out std_logic;
     roic_progdac: out std_logic;
     roic_rstneg: out std_logic;
     
     roic_rowsel: out std_logic_vector (6 downto 0);
     roic_colsel: out std_logic_vector (6 downto 0);
     
     roic_DIN10: out std_logic;
     roic_DINDB10: out std_logic;
     
     roic_DOUT: in std_logic_vector (13 downto 0);
     roic_DOUTDB:in std_logic_vector (13 downto 0);
          
        
      IMG_ADDR : out STD_LOGIC_VECTOR (10 downto 0);
      IMG_Data_Out : out STD_LOGIC_VECTOR (13 downto 0);
      IMG_Data_Out_DB : out STD_LOGIC_VECTOR (13 downto 0);
      IMG_Data_write : out std_logic;
      
      --windowing_conf : in std_logic_vector (7 downto 0);
      
     --ap_ctrl_chain last block
     ap_start : in STD_logic;
     ap_done : out STD_logic;  
     ap_idle: out STD_logic;  
         
     --configuration registers    
     --reg_addr: in std_logic_vector (7 downto 0); --posible depuracion
     --reg_data: in std_logic_vector (15 downto 0); --posible depuracion
     --new_reg_wr: in std_logic; --posible depuracion
     INTEGRATION_TIME_in: in std_logic_vector (22 downto 0);
     --gain_in: in std_logic;
     debug_din: in std_logic;
     ENA: in std_logic 
     
);
end Tachyon16k_IF_VU;

architecture Behavioral of Tachyon16k_IF_VU is

   
constant XCOUNT_TO_RSTNEG_cte : integer :=1;    
constant RSTNEG_TO_XANALOGRST_cte : integer :=1;
constant XANALOGRST_TO_BUS_cte : integer :=1;   
constant BUS_TO_IO_cte : integer :=1;           
constant IO_cte : integer :=8192;                  
constant BUS_TO_RSTNEG_cte : integer :=1;       
constant RSTNEG_TO_CLK_cte  : integer :=1;      
constant CLK_TO_PHI4_cte : integer :=1;         
constant PHI4_TO_CLK_cte : integer :=1;         
constant CLK_TO_PROGDAC_cte : integer :=1;      
constant PROGDAC_TO_PHI4_cte  : integer :=2000;    
constant PHI4_TO_XRST_cte  : integer :=1;       
constant XRST_TO_XRST_cte  : integer :=300;       
constant XRST_TO_INTEGRACION_cte : integer :=1;

constant IO_TO_BUS_cte : integer :=4000; --cambiados en Clamir

--duda comprobar
constant PROGDAC_TO_PHI4_windowing_cte  : integer :=4000;    --cambiados en clamir
constant IO_TO_BUS_windowing_cte : integer :=4000;   --cambiados en clamir



constant ROW_START_INIT_cte : integer :=0;
constant COLUMN_START_INIT_cte : integer :=0;
constant ROW_END_INIT_cte : integer :=127;
constant COLUMN_END_INIT_cte : integer :=127;

constant W64x64ROW_START_INIT_cte : integer :=32;
constant W64x64COLUMN_START_INIT_cte : integer :=32;
constant W64x64ROW_END_INIT_cte : integer :=95;
constant W64x64COLUMN_END_INIT_cte : integer :=95;

constant W32x32ROW_START_INIT_cte : integer :=48;
constant W32x32COLUMN_START_INIT_cte : integer :=48;
constant W32x32ROW_END_INIT_cte : integer :=79;
constant W32x32COLUMN_END_INIT_cte : integer :=79;


constant NO_WINDOWING : std_logic_vector(7 downto 0):= x"00";
constant WINDOWING64X64 : std_logic_vector(7 downto 0):= x"01";
constant WINDOWING32X32 : std_logic_vector(7 downto 0):= x"02";

type TIPO_ESTADO_state is (IDLE, INTEGRATION,XCOUNT_TO_RSTNEG, RSTNEG_TO_XANALOGRST,XANALOGRST_TO_BUS,BUS_TO_IO,
                            FIRST_IO, IO,LAST_IO,IO_TO_BUS,BUS_TO_RSTNEG,RSTNEG_TO_CLK,CLK_TO_PHI4,PHI4_TO_CLK,CLK_TO_PROGDAC,
                            PROGDAC_TO_PHI4, PHI4_TO_XRST, XRST_TO_XRST, XRST_TO_INTEGRATION,
                            IDLE_windowing, INTEGRATION_windowing,XCOUNT_TO_RSTNEG_windowing, RSTNEG_TO_XANALOGRST_windowing,
                            XANALOGRST_TO_BUS_windowing,BUS_TO_IO_windowing,FIRST_IO_windowing, IO_windowing,LAST_IO_windowing,
                            IO_TO_BUS_windowing,BUS_TO_RSTNEG_windowing,RSTNEG_TO_CLK_windowing,CLK_TO_PHI4_windowing,
                            PHI4_TO_CLK_windowing,CLK_TO_PROGDAC_windowing,PROGDAC_TO_PHI4_windowing, PHI4_TO_XRST_windowing,
                             XRST_TO_XRST_windowing, XRST_TO_INTEGRATION_windowing);
  signal ESTADO: TIPO_ESTADO_state;
    attribute dont_touch : string;
  --attribute dont_touch of ESTADO : signal is "true";
  
   signal gain_reg: std_logic:='0';
   signal xtest_reg: std_logic;
   signal DB_reg: std_logic;
   
   signal cnt_SM: std_logic_vector (CNT_WITH-1 downto 0);
   
   signal INTEGRATION_time: std_logic_vector (CNT_WITH-1 downto 0);
   signal XCOUNT_TO_RSTNEG_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal RSTNEG_TO_XANALOGRST_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal XANALOGRST_TO_BUS_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal BUS_TO_IO_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal IO_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal IO_TO_BUS_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal IO_TO_BUS_windowing_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal BUS_TO_RSTNEG_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal RSTNEG_TO_CLK_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal CLK_TO_PHI4_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal PHI4_TO_CLK_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal CLK_TO_PROGDAC_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal PROGDAC_TO_PHI4_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal PROGDAC_TO_PHI4_windowing_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal PHI4_TO_XRST_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal XRST_TO_XRST_time : std_logic_vector (CNT_WITH-1 downto 0);
   signal XRST_TO_INTEGRACION_time : std_logic_vector (CNT_WITH-1 downto 0);
   
   signal impar_flag: std_logic;
   
   signal CNT_ROW: std_logic_vector (6 downto 0);
   signal CNT_ROW_REG: std_logic_vector (6 downto 0);  
   signal CNT_COL: std_logic_vector (5 downto 0); -- solo 6 bits porque siempre suamos DB
   signal CNT_COL_JUMP: std_logic_vector (5 downto 0); -- solo 6 bits porque siempre suamos DB
   signal delay_reg: std_logic;
       
   signal  IMG_ADDR_reg : std_logic_vector (10 downto 0);
   signal IMG_Data_write_reg: std_logic;
   
   --Image Memory directioning
   signal Row_start : std_logic_vector (6 downto 0);
   signal Column_start : std_logic_vector (6 downto 0);
   signal Row_end : std_logic_vector (6 downto 0);
   signal Column_end: std_logic_vector (6 downto 0);
   signal Height : std_logic_vector (6 downto 0);
   signal Width : std_logic_vector (6 downto 0);
   signal Width_quarter : std_logic_vector (6 downto 0);
   signal Width_half : std_logic_vector (6 downto 0);
   signal Width_3quarter : std_logic_vector (6 downto 0);
   signal width_half_plus2 : std_logic_vector (6 downto 0);
   
   signal roic_CLK_reg: std_logic;
   signal DEBUG_progdacCLK : std_logic_vector (6 downto 0);
   signal DEBUG_progdacCLK_windowing : std_logic_vector (6 downto 0);
     
   --camera_v1
   signal Windowing_reg : std_logic_vector ( 7 downto 0):=WINDOWING64X64;  
   signal roic_row_start_windowing : std_logic_vector (6 downto 0);
   signal roic_row_end_windowing : std_logic_vector (6 downto 0);
   signal roic_col_start_windowing : std_logic_vector (6 downto 0);
   signal roic_col_end_windowing : std_logic_vector (6 downto 0);
   signal IMG_ADDR_start_windowing :  std_logic_vector (12 downto 0);
   signal IMG_jump_windowing : std_logic_vector (12 downto 0);
   signal LAST_IO_end : std_logic_vector (6 downto 0);
     

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
      roic_gain2 <=  '0';
      roic_xcount <=  '0';
      roic_xrst <=  '0';
      roic_xanalog_rst <=  '0';
      roic_xtest <=  '0';
      roic_rstneg <=  '0';    
      roic_bus <=  '0';
      roic_progdac <=  '0';
      roic_phi4 <=  '0';
      --roic_CLK <=  '0';
      roic_CLK_periph <=  '0';
      roic_DB <=  '0';                 
      roic_DIN10 <=  '0';
      roic_DINDB10 <=  '0';
      
      IMG_ADDR  <=  (others => '0');
      IMG_Data_Out <=  (others => '0');
      IMG_Data_Out_DB <=  (others => '0');
      IMG_Data_write <='0';
      roic_CLK_reg<='0';
      
      --gain_reg<=gain_in;
      xtest_reg<='1';
      DB_reg<='1';
      delay_reg <='0';
      
      cnt_SM <= (others => '0');
      IMG_ADDR_reg<= (others => '0');
      IMG_Data_write_reg<='0';
      
      
      INTEGRATION_time <= INTEGRATION_TIME_in;
      XCOUNT_TO_RSTNEG_time <= conv_std_logic_vector(XCOUNT_TO_RSTNEG_cte,CNT_WITH);
      RSTNEG_TO_XANALOGRST_time <= conv_std_logic_vector(RSTNEG_TO_XANALOGRST_cte,CNT_WITH);
      XANALOGRST_TO_BUS_time <= conv_std_logic_vector(XANALOGRST_TO_BUS_cte,CNT_WITH);
      BUS_TO_IO_time <= conv_std_logic_vector(BUS_TO_IO_cte,CNT_WITH);
      IO_time <= conv_std_logic_vector(IO_cte,CNT_WITH);
      IO_TO_BUS_time<= conv_std_logic_vector(IO_TO_BUS_cte,CNT_WITH);
      IO_TO_BUS_windowing_time<= conv_std_logic_vector(IO_TO_BUS_windowing_cte,CNT_WITH);
      BUS_TO_RSTNEG_time<= conv_std_logic_vector(BUS_TO_RSTNEG_cte,CNT_WITH);
      RSTNEG_TO_CLK_time <= conv_std_logic_vector(RSTNEG_TO_CLK_cte,CNT_WITH);
      CLK_TO_PHI4_time <= conv_std_logic_vector(CLK_TO_PHI4_cte,CNT_WITH);
      PHI4_TO_CLK_time <= conv_std_logic_vector(PHI4_TO_CLK_cte,CNT_WITH);
      CLK_TO_PROGDAC_time <= conv_std_logic_vector(CLK_TO_PROGDAC_cte,CNT_WITH);
      PROGDAC_TO_PHI4_time <= conv_std_logic_vector(PROGDAC_TO_PHI4_cte,CNT_WITH);
      PROGDAC_TO_PHI4_windowing_time <= conv_std_logic_vector(PROGDAC_TO_PHI4_windowing_cte,CNT_WITH);
      PHI4_TO_XRST_time<= conv_std_logic_vector(PHI4_TO_XRST_cte,CNT_WITH);
      XRST_TO_XRST_time <= conv_std_logic_vector(XRST_TO_XRST_cte,CNT_WITH);
      XRST_TO_INTEGRACION_time <= conv_std_logic_vector(XRST_TO_INTEGRACION_cte,CNT_WITH);
      
      impar_flag <='0';
      CNT_ROW <= (others =>'0');
      CNT_ROW_REG <= (others =>'0');
      CNT_COL <= (others =>'0');
     
      Column_start <= conv_std_logic_vector(COLUMN_START_INIT_cte,7);
      Row_start <=  conv_std_logic_vector(ROW_START_INIT_cte,7);
      Column_end <= conv_std_logic_vector(COLUMN_END_INIT_cte,7);
      Row_end <= conv_std_logic_vector(ROW_END_INIT_cte,7);
      Width <= conv_std_logic_vector(COLUMN_END_INIT_cte - COLUMN_START_INIT_cte,7);
      Height <= conv_std_logic_vector(ROW_END_INIT_cte - ROW_START_INIT_cte,7);
      Width_quarter <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/4),7);
      Width_half <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/2),7);
      DEBUG_progdacCLK<=conv_std_logic_vector(47,7);
      DEBUG_progdacCLK_windowing<=conv_std_logic_vector(27,7);
            
   else
    
      cnt_SM<=cnt_SM+1;
    
--      if(new_reg_wr <='1') then
--         case reg_addr is
--            when x"00" =>                
--                      --constant XCOUNT_TO_RSTNEG_cte : integer :=100;
--                      XCOUNT_TO_RSTNEG_time <= reg_data(CNT_WITH-1 downto 0);
--              when x"01" =>                
--                      --constant RSTNEG_TO_XANALOGRST_cte : integer :=115;
--                      RSTNEG_TO_XANALOGRST_time <=reg_data(CNT_WITH-1 downto 0);
--              when x"02" =>                
--                      --constant XANALOGRST_TO_BUS_cte : integer :=440;
--                      XANALOGRST_TO_BUS_time <= reg_data(CNT_WITH-1 downto 0);
--              when x"03" =>                
--                      --constant BUS_TO_IO_cte : integer :=60;
--                      BUS_TO_IO_time <= reg_data(CNT_WITH-1 downto 0);                   
--              when x"04" =>                
--                      --constant IO_cte : integer :=8192;   
--                      IO_time <= reg_data(CNT_WITH-1 downto 0);                                  
--              when x"05" =>                
--                      --constant IO_TO_BUS_cte : integer :=70; 
--                      IO_TO_BUS_time<= reg_data(CNT_WITH-1 downto 0);                     
--              when x"06" =>                
--                      --constant BUS_TO_RSTNEG_cte : integer :=1250; 
--                      BUS_TO_RSTNEG_time<= reg_data(CNT_WITH-1 downto 0);             
--              when x"07" =>                
--                      --constant RSTNEG_TO_CLK_cte  : integer :=1250;  
--                      RSTNEG_TO_CLK_time <= reg_data(CNT_WITH-1 downto 0);            
--              when x"08" =>                
--                      --constant CLK_TO_PHI4_cte : integer :=50;  
--                      CLK_TO_PHI4_time <= reg_data(CNT_WITH-1 downto 0);               
--              when x"09" =>                
--                      --constant PHI4_TO_CLK_cte : integer :=2200; 
--                      PHI4_TO_CLK_time <=reg_data(CNT_WITH-1 downto 0);               
--              when x"0a" =>                
--                      --constant CLK_TO_PROGDAC_cte : integer :=120;   
--                      CLK_TO_PROGDAC_time <= reg_data(CNT_WITH-1 downto 0);          
--              when x"0b" =>                
--                      --constant PROGDAC_TO_PHI4_cte  : integer :=2000
--                     PROGDAC_TO_PHI4_time <= reg_data(CNT_WITH-1 downto 0);      
--              when x"0c" =>                
--                      --constant PHI4_TO_XRST_cte  : integer :=1200;    
--                      PHI4_TO_XRST_time<= reg_data(CNT_WITH-1 downto 0);               
--              when x"0d" =>                
--                      --constant XRST_TO_XRST_cte  : integer :=250;  
--                      XRST_TO_XRST_time <= reg_data(CNT_WITH-1 downto 0);              
--              when x"0e" =>                
--                      --constant XRST_TO_INTEGRACION_cte : integer :=1200; 
--                      XRST_TO_INTEGRACION_time <= reg_data(CNT_WITH-1 downto 0);
--              when x"11" =>        
--                      DEBUG_progdacCLK <=  reg_data(6 downto 0); 
--             when x"25" =>  
--                      IO_TO_BUS_windowing_time<= reg_data(CNT_WITH-1 downto 0);  
--             when x"2b" =>          
--                      PROGDAC_TO_PHI4_windowing_time <= reg_data(CNT_WITH-1 downto 0);
--             when x"31" =>        
--                      DEBUG_progdacCLK_windowing <=  reg_data(6 downto 0);
                                     
--              when x"ff" =>    
--                   XCOUNT_TO_RSTNEG_time <= conv_std_logic_vector(XCOUNT_TO_RSTNEG_cte,CNT_WITH);
--                   RSTNEG_TO_XANALOGRST_time <= conv_std_logic_vector(RSTNEG_TO_XANALOGRST_cte,CNT_WITH);
--                   XANALOGRST_TO_BUS_time <= conv_std_logic_vector(XANALOGRST_TO_BUS_cte,CNT_WITH);
--                   BUS_TO_IO_time <= conv_std_logic_vector(BUS_TO_IO_cte,CNT_WITH);
--                   IO_time <= conv_std_logic_vector(IO_cte,CNT_WITH);
--                   IO_TO_BUS_time<= conv_std_logic_vector(IO_TO_BUS_cte,CNT_WITH);
--                   IO_TO_BUS_windowing_time<= conv_std_logic_vector(IO_TO_BUS_windowing_cte,CNT_WITH);
--                   BUS_TO_RSTNEG_time<= conv_std_logic_vector(BUS_TO_RSTNEG_cte,CNT_WITH);
--                   RSTNEG_TO_CLK_time <= conv_std_logic_vector(RSTNEG_TO_CLK_cte,CNT_WITH);
--                   CLK_TO_PHI4_time <= conv_std_logic_vector(CLK_TO_PHI4_cte,CNT_WITH);
--                   PHI4_TO_CLK_time <= conv_std_logic_vector(PHI4_TO_CLK_cte,CNT_WITH);
--                   CLK_TO_PROGDAC_time <= conv_std_logic_vector(CLK_TO_PROGDAC_cte,CNT_WITH);
--                   PROGDAC_TO_PHI4_time <= conv_std_logic_vector(PROGDAC_TO_PHI4_cte,CNT_WITH);
--                   PROGDAC_TO_PHI4_windowing_time <= conv_std_logic_vector(PROGDAC_TO_PHI4_windowing_cte,CNT_WITH);
--                   PHI4_TO_XRST_time<= conv_std_logic_vector(PHI4_TO_XRST_cte,CNT_WITH);
--                   XRST_TO_XRST_time <= conv_std_logic_vector(XRST_TO_XRST_cte,CNT_WITH);
--                   XRST_TO_INTEGRACION_time <= conv_std_logic_vector(XRST_TO_INTEGRACION_cte,CNT_WITH);    
                      
--              when others =>
              
--              end case;
--          end if;
         case ESTADO is
            when IDLE => 
             
               roic_rowsel <=  (others => '0');
               roic_colsel <=  (others => '0');
               roic_gain2 <=  gain_reg;
               roic_xcount <=  '1'; 
               roic_xrst <=  '1';--change
               roic_xanalog_rst <=  '1'; 
               roic_xtest <= xtest_reg;
               roic_rstneg <=  '0';   
               roic_bus <=  '0'; 
               roic_progdac <=  '1'; 
               roic_phi4 <=  '1';
               roic_CLK_reg <=  '0';
               roic_CLK_periph <=  '0';
               roic_DB <=  DB_reg;                 
               roic_DIN10 <=  '0';
               roic_DINDB10 <=  '0';
                
               IMG_ADDR  <=  (others => '0');
               IMG_Data_Out <=  (others => '0');  
                
               cnt_SM <= (others => '0');
                
               ap_done<='0';
               
               if (ap_start = '1') then
                  --Windowing_reg <= windowing_conf;    
                  ESTADO <= INTEGRATION;
                  INTEGRATION_time<= INTEGRATION_TIME_in;
                  --gain_reg<=gain_in;
               end if; 
             
            when INTEGRATION =>
               
                roic_rowsel <=  (others => '0');
                roic_colsel <=  (others => '0');
                roic_gain2 <=  gain_reg;
                roic_xcount <=  '0';
                roic_xrst <=  '1';
                roic_xanalog_rst <=  '0';
                roic_xtest <= xtest_reg;
                roic_rstneg <=  '0';    
                roic_bus <=  '0';
                roic_progdac <=  '1';
                roic_phi4 <=  '1';
                roic_CLK_reg <=  '0';
                roic_CLK_periph <=  '0';
                roic_DB <=  DB_reg;                 
                roic_DIN10 <=  '0';
                roic_DINDB10 <=  '0';
                
                IMG_ADDR  <=  (others => '0');
                IMG_Data_Out <=  (others => '0');
                --if (cnt_SM >= INTEGRATION_time) then
                if (cnt_SM >= conv_std_logic_vector(2000,16)) then --cambiado en Clamir
                  ESTADO <= XCOUNT_TO_RSTNEG;
                  cnt_SM <= (others => '0');
                else
                  ESTADO <= INTEGRATION;
                end if;
                    
             when XCOUNT_TO_RSTNEG =>
             
                roic_rowsel <=  (others => '0');
                roic_colsel <=  (others => '0');
                roic_gain2 <=  gain_reg;
                roic_xcount <=  '1'; --change
                roic_xrst <=  '1';
                roic_xanalog_rst <=  '0';
                roic_xtest <= xtest_reg;
                roic_rstneg <=  '0';    
                roic_bus <=  '0';
                roic_progdac <=  '1';
                roic_phi4 <=  '1';
                roic_CLK_reg <=  '0';
                roic_CLK_periph <=  '0';
                roic_DB <=  DB_reg;                 
                roic_DIN10 <=  '0';
                roic_DINDB10 <=  '0';
                
                IMG_ADDR  <=  (others => '0');
                IMG_Data_Out <=  (others => '0');  
              
                if (cnt_SM >= XCOUNT_TO_RSTNEG_time)
                then
                   ESTADO <= RSTNEG_TO_XANALOGRST;
                   cnt_SM <= (others => '0');
                else
                   ESTADO <= XCOUNT_TO_RSTNEG;
                end if;      
             
             when RSTNEG_TO_XANALOGRST => 
             
                roic_rowsel <=  (others => '0');
                roic_colsel <=  (others => '0');
                roic_gain2 <=  gain_reg;
                roic_xcount <=  '1'; 
                roic_xrst <=  '1';
                roic_xanalog_rst <=  '0';
                roic_xtest <= xtest_reg;
                roic_rstneg <=  '1'; --change   
                roic_bus <=  '0';
                roic_progdac <=  '1';
                roic_phi4 <=  '1';
                roic_CLK_reg <=  '0';
                roic_CLK_periph <=  '0';
                roic_DB <=  DB_reg;                 
                roic_DIN10 <=  '0';
                roic_DINDB10 <=  '0';
                
                IMG_ADDR  <=  (others => '0');
                IMG_Data_Out <=  (others => '0');  
                
                if (cnt_SM >= RSTNEG_TO_XANALOGRST_time)
                then
                   ESTADO <= XANALOGRST_TO_BUS;
                   cnt_SM <= (others => '0');
                else
                   ESTADO <= RSTNEG_TO_XANALOGRST;
                end if;   
                
             when XANALOGRST_TO_BUS =>
                
                roic_rowsel <=  (others => '0');
                roic_colsel <=  (others => '0');
                roic_gain2 <=  gain_reg;
                roic_xcount <=  '1'; 
                roic_xrst <=  '1';
                roic_xanalog_rst <=  '1'; --change
                roic_xtest <= xtest_reg;
                roic_rstneg <=  '1';   
                roic_bus <=  '0';
                roic_progdac <=  '1';
                roic_phi4 <=  '1';
                roic_CLK_reg <=  '0';
                roic_CLK_periph <=  '0';
                roic_DB <=  DB_reg;                 
                roic_DIN10 <=  '0';
                roic_DINDB10 <=  '0';
                
                IMG_ADDR  <=  (others => '0');
                IMG_Data_Out <=  (others => '0');  
                
                if (cnt_SM >= XANALOGRST_TO_BUS_time)
                then
                   ESTADO <= BUS_TO_IO;
                   cnt_SM <= (others => '0');
                else
                   ESTADO <= XANALOGRST_TO_BUS;
                end if;   
              
              when BUS_TO_IO =>
                 
                 roic_rowsel <=  (others => '0');
                 roic_colsel <=  (others => '0');
                 roic_gain2 <=  gain_reg;
                 roic_xcount <=  '1'; 
                 roic_xrst <=  '1';
                 roic_xanalog_rst <=  '1'; 
                 roic_xtest <= xtest_reg;
                 roic_rstneg <=  '1';   
                 roic_bus <=  '1'; --change
                 roic_progdac <=  '0'; --change
                 roic_phi4 <=  '1';
                 roic_CLK_reg <=  '0';
                 roic_CLK_periph <=  '0';
                 roic_DB <=  DB_reg;                 
                 roic_DIN10 <=  '0';
                 roic_DINDB10 <=  '0';
                 
                 IMG_ADDR  <=  (others => '0');
                 IMG_Data_Out <=  (others => '0');  
                 CNT_ROW_REG <= CNT_ROW;
                 
                 if (cnt_SM >= BUS_TO_IO_time)
                 then
                    ESTADO <= FIRST_IO;
                    cnt_SM <= (others => '0');
                 else
                    ESTADO <= BUS_TO_IO;
                 end if;
             
             when FIRST_IO =>
                  roic_rowsel <= (127 - CNT_ROW_REG);
                  CNT_ROW_REG <= CNT_ROW;
                  roic_colsel <=  CNT_COL & '0';
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '1';   
                  roic_bus <=  '1';
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';
                  
                  if (((CNT_COL & '0') = width_quarter) and (cnt_SM(0) = '1')) --fijos para 128
                  then
                     roic_CLK_reg <= not roic_CLK_reg;
                  end if;
                  
                  roic_CLK_periph <=  not (cnt_SM(0));
                  roic_DB <=  DB_reg;
--apagado para leer en windowing clamir
                     roic_DIN10 <=  '0';
                     roic_DINDB10 <=  '0';

                  IMG_ADDR_reg <=  (others=> '0');
                  IMG_ADDR  <=   (others=> '0');
                  IMG_Data_Out <=  (others=> '0');
                  IMG_Data_Out_DB <=  (others=> '0');
                  
                  if ( cnt_SM(0) = '1') then
                     CNT_COL <= CNT_COL +1;
                  end if;
                  if ( CNT_COL = x"3F") then
                      CNT_ROW <= CNT_ROW +1;
                      CNT_COL <= (others =>'0');
                  end if;
                                  
                  if (((CNT_COL & '0') = width_half) and (cnt_SM(0) = '1')) --fijos para 128
                  then
                     ESTADO <= IO;
                     cnt_SM <= (others => '0');
                     IMG_ADDR_reg <=(others => '0');
                     roic_CLK_reg <= not roic_CLK_reg;
                  else
                     ESTADO <= FIRST_IO;
                  end if; 
                 
               when IO =>
             
                  -- 255 medias filas
                  --(final - incicial *2)-1
                  roic_rowsel <=  (127 - CNT_ROW_REG);
                  CNT_ROW_REG <= CNT_ROW;
                  roic_colsel <=  CNT_COL & '0';
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '1';   
                  roic_bus <=  '1';
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';

                  if (cnt_SM(0) = '1') then
                     if (((CNT_COL & '0') = 0) or (('0' & CNT_COL(4 downto 0) & '0') = width_quarter) or ((CNT_COL & '0') = width_half)) then --fijos para 128
                        roic_CLK_reg <= not roic_CLK_reg;
                     end if;
                  end if;
                
                  roic_CLK_periph <=  not (cnt_SM(0));
                  roic_DB <=  DB_reg;      

                     roic_DIN10 <=  '0';
                     roic_DINDB10 <=  '0';
                    
                  IMG_ADDR_reg <=  (others=> '0');
                 IMG_ADDR  <=   (others=> '0');
                 IMG_Data_Out <=  (others=> '0');
                 IMG_Data_Out_DB <=  (others=> '0');
                
                  IMG_Data_write <= '0';
                    
                  if ( cnt_SM(0) = '1') then
                     if ( CNT_COL = Width(6 downto 1)) then
                        CNT_ROW <= CNT_ROW +1;
                        CNT_COL <= (others =>'0');
                     else      
                        CNT_COL <= CNT_COL +1;
                     end if;
                  end if;
                                  
                  if ((CNT_COL = Width(6 downto 1)) and (CNT_ROW = height)and (cnt_SM(0) = '1')) then
                     ESTADO <= LAST_IO;
                     cnt_SM <= (others => '0');
                  else
                     ESTADO <= IO;
                  end if; 
                    
               when LAST_IO =>
                  roic_rowsel <=  (127 - CNT_ROW_REG);
                  roic_colsel <=  CNT_COL & '0';
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '1';   
                  roic_bus <=  '1';
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';
                  
                  roic_CLK_periph <=  not (cnt_SM(0));
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                 
                 IMG_ADDR_reg <=  (others=> '0');
                  IMG_ADDR  <=   (others=> '0');
                  IMG_Data_Out <=  (others=> '0');
                  IMG_Data_Out_DB <=  (others=> '0');
                  IMG_Data_write <= '0';
                  
                  if ( cnt_SM(0) = '1') then
                      CNT_COL <= CNT_COL +1;
                      
                      roic_CLK_reg<='0';
                  end if;
                  
                  if ((CNT_COL = 32) and (cnt_SM(0) = '1')) then
                     ESTADO <= IO_TO_BUS;
                    
                     cnt_SM <= (others => '0');
                  else
                     ESTADO <= LAST_IO;
                  end if; 
                               
               when IO_TO_BUS =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '1';   
                  roic_bus <=  '1';
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';
                  roic_CLK_reg <=  '0';
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
              
                 IMG_ADDR_reg <=  (others=> '0');
                 IMG_ADDR  <=   (others=> '0');
                 IMG_Data_Out <=  (others=> '0');
                 IMG_Data_Out_DB <=  (others=> '0');
                                 
                  CNT_COL <= (others => '0');
                  CNT_ROW <= (others => '0'); 
                   
                  if (cnt_SM >= IO_TO_BUS_time) then
                     ESTADO <= BUS_TO_RSTNEG;
                     cnt_SM <= (others => '0');
                  else
                     ESTADO <= IO_TO_BUS;
                  end if;
                  
               when BUS_TO_RSTNEG =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '1';   
                  roic_bus <=  '0'; --change
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';
                  roic_CLK_reg <=  '0';
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= BUS_TO_RSTNEG_time)
                  then
                    ESTADO <= RSTNEG_TO_CLK;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= BUS_TO_RSTNEG;
                  end if; 
                
               when RSTNEG_TO_CLK =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   --change 
                  roic_bus <=  '0'; 
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';
                  roic_CLK_reg <=  '0';
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= RSTNEG_TO_CLK_time) then
                    ESTADO <= CLK_TO_PHI4;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= RSTNEG_TO_CLK;
                  end if;         
               
               when CLK_TO_PHI4 =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '1';
                  roic_CLK_reg<=  '1';--change
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= CLK_TO_PHI4_time) then
                    ESTADO <= PHI4_TO_CLK;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= CLK_TO_PHI4;
                  end if;
                
               when PHI4_TO_CLK =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '0';--change
                  roic_CLK_reg <=  '1';
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= PHI4_TO_CLK_time) then
                    ESTADO <= CLK_TO_PROGDAC;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= PHI4_TO_CLK;
                  end if;   
             
               when CLK_TO_PROGDAC =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  roic_progdac <=  '0'; 
                  roic_phi4 <=  '0';
                  roic_CLK_reg <=  '0';--change
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= CLK_TO_PROGDAC_time)
                  then
                    ESTADO <= PROGDAC_TO_PHI4;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= CLK_TO_PROGDAC;
                  end if; 
                  
               when PROGDAC_TO_PHI4 =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  roic_progdac <=  '1'; --change
                  roic_phi4 <=  '0';
                  --roic_CLK_reg <=  '0';
                  roic_CLK_reg <=  cnt_SM(7);
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  --if (cnt_SM >= PROGDAC_TO_PHI4_time)
                  --if (cnt_SM (11 downto 5) >= 79)
                   if (cnt_SM (11 downto 5) >= DEBUG_progdacCLK)
                  then
                    ESTADO <= PHI4_TO_XRST;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= PROGDAC_TO_PHI4;
                  end if;      
               
               when PHI4_TO_XRST =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '1';
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  roic_progdac <=  '1'; 
                  roic_phi4 <=  '1';--change
                  roic_CLK_reg <=  '1';--change
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= PHI4_TO_XRST_time)
                  then
                    ESTADO <= XRST_TO_XRST;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= PHI4_TO_XRST;
                  end if;
               
               when XRST_TO_XRST =>
                  roic_rowsel <=  (others => '0');
                  roic_colsel <=  (others => '0');
                  roic_gain2 <=  gain_reg;
                  roic_xcount <=  '1'; 
                  roic_xrst <=  '0';--change
                  roic_xanalog_rst <=  '1'; 
                  roic_xtest <= xtest_reg;
                  roic_rstneg <=  '0';   
                  roic_bus <=  '0'; 
                  roic_progdac <=  '1'; 
                  roic_phi4 <=  '1';
                  roic_CLK_reg <=  '0';--change
                  roic_CLK_periph <=  '0';
                  roic_DB <=  DB_reg;                 
                  roic_DIN10 <=  '0';
                  roic_DINDB10 <=  '0';
                   
                  IMG_ADDR  <=  (others => '0');
                  IMG_Data_Out <=  (others => '0');  
                   
                  if (cnt_SM >= XRST_TO_XRST_time) then
                    ESTADO <= XRST_TO_INTEGRATION;
                    cnt_SM <= (others => '0');
                  else
                    ESTADO <= XRST_TO_XRST;
                  end if;
                  
               when XRST_TO_INTEGRATION =>
                 roic_rowsel <=  (others => '0');
                 roic_colsel <=  (others => '0');
                 roic_gain2 <=  gain_reg;
                 roic_xcount <=  '1'; 
                 roic_xrst <=  '1';--change
                 roic_xanalog_rst <=  '1'; 
                 roic_xtest <= xtest_reg;
                 roic_rstneg <=  '0';   
                 roic_bus <=  '0'; 
                 roic_progdac <=  '1'; 
                 roic_phi4 <=  '1';
                 roic_CLK_reg <=  '0';
                 roic_CLK_periph <=  '0';
                 roic_DB <=  DB_reg;                 
                 roic_DIN10 <=  '0';
                 roic_DINDB10 <=  '0';
                  
                 IMG_ADDR  <=  (others => '0');
                 IMG_Data_Out <=  (others => '0');  
                  
                 if (cnt_SM >= XRST_TO_INTEGRACION_time) then
                    cnt_SM <= (others => '0');
                    if (impar_flag = '1') then  
                       case windowing_reg is
                                  
                          when NO_WINDOWING =>
                             ESTADO <= IDLE;
                             --ap_done<='1';
                             impar_flag <= '0';
                       
                          when WINDOWING64X64 =>
                             ESTADO <= IDLE_windowing;
                             --ap_done<='1';
                             impar_flag <= '0';
                                               
                          when WINDOWING32x32 =>
                             ESTADO <= IDLE_windowing;
                             --ap_done<='1';
                             impar_flag <= '0';
                          
                         when others =>    
                          
                          end case;    
                    else
                       impar_flag <= '1';
                       ESTADO <= INTEGRATION;
                    end if;  
                 else
                    ESTADO <= XRST_TO_INTEGRATION;
                 end if;   

--- windowing states   
---************************************************************************************************
--- windowing states   
          
        when IDLE_windowing => 
           
           roic_rowsel <=  roic_row_start_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';--change
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   
           roic_bus <=  '0'; 
           roic_progdac <=  '1'; 
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
           IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
            cnt_SM <= (others => '0');
            
            ap_done<='0';
           --Windowing_reg <= windowing_conf;
           
            
           case Windowing_reg is
              when NO_WINDOWING =>
               
                  --128 data
                  Column_start <= conv_std_logic_vector(COLUMN_START_INIT_cte,7);
                  Row_start <=  conv_std_logic_vector(ROW_START_INIT_cte,7);
                  Column_end <= conv_std_logic_vector(COLUMN_END_INIT_cte,7);
                  Row_end <= conv_std_logic_vector(ROW_END_INIT_cte,7);
                  Width <= conv_std_logic_vector(COLUMN_END_INIT_cte - COLUMN_START_INIT_cte,7);
                  Height <= conv_std_logic_vector(ROW_END_INIT_cte - ROW_START_INIT_cte,7);
                  Width_quarter <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/4),7);
                  Width_half <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/2),7);            
                           
              when WINDOWING64x64 =>
                 roic_row_start_windowing <= conv_std_logic_vector(32,7);
                 roic_row_end_windowing <= conv_std_logic_vector(95,7);
                 roic_col_start_windowing <= conv_std_logic_vector(32,7);
                 roic_col_end_windowing <= conv_std_logic_vector(95,7);
                 IMG_jump_windowing<=conv_std_logic_vector(33,13); -- half due to double bus
                    
                 Column_start <= conv_std_logic_vector(W64x64COLUMN_START_INIT_cte,7);
                 Row_start <=  conv_std_logic_vector(W64x64ROW_START_INIT_cte,7);
                 Column_end <= conv_std_logic_vector(W64x64COLUMN_END_INIT_cte,7);
                 Row_end <= conv_std_logic_vector(W64x64ROW_END_INIT_cte,7);
                 Width <= conv_std_logic_vector(W64x64COLUMN_END_INIT_cte - W64x64COLUMN_START_INIT_cte,7);
                 Height <= conv_std_logic_vector(W64x64ROW_END_INIT_cte - W64x64ROW_START_INIT_cte,7);
                 Width_quarter <= conv_std_logic_vector((((W64x64COLUMN_END_INIT_cte - W64x64COLUMN_START_INIT_cte)+1)/4),7);
                 Width_half <= conv_std_logic_vector((((W64x64COLUMN_END_INIT_cte - W64x64COLUMN_START_INIT_cte)+1)/2),7);      
                 Width_3quarter <= conv_std_logic_vector((((W64x64COLUMN_END_INIT_cte - W64x64COLUMN_START_INIT_cte)+1)/4)*3,7);                                                                                                          
                 width_half_plus2<= conv_std_logic_vector((((W64x64COLUMN_END_INIT_cte - W64x64COLUMN_START_INIT_cte)+1)/2)+2,7);
                 CNT_COL_JUMP<=(others => '0');
                 LAST_IO_end<=conv_std_logic_vector(0,7);
              
              when WINDOWING32x32 =>
                 roic_row_start_windowing <= conv_std_logic_vector(48,7);
                 roic_row_end_windowing <= conv_std_logic_vector(79,7);
                 roic_col_start_windowing <= conv_std_logic_vector(48,7);
                 roic_col_end_windowing <= conv_std_logic_vector(79,7);
                 IMG_jump_windowing<=conv_std_logic_vector(49,13); -- half due to double bus
                    
                 Column_start <= conv_std_logic_vector(W32x32COLUMN_START_INIT_cte,7);
                 Row_start <=  conv_std_logic_vector(W32x32ROW_START_INIT_cte,7);
                 Column_end <= conv_std_logic_vector(W32x32COLUMN_END_INIT_cte,7);
                 Row_end <= conv_std_logic_vector(W32x32ROW_END_INIT_cte,7);
                 Width <= conv_std_logic_vector(W32x32COLUMN_END_INIT_cte - W32x32COLUMN_START_INIT_cte,7);
                 Height <= conv_std_logic_vector(W32x32ROW_END_INIT_cte - W32x32ROW_START_INIT_cte,7);
                 Width_quarter <= conv_std_logic_vector((((W32x32COLUMN_END_INIT_cte - W32x32COLUMN_START_INIT_cte)+1)/4),7);
                 Width_half <=conv_std_logic_vector((((W32x32COLUMN_END_INIT_cte - W32x32COLUMN_START_INIT_cte)+1)/2),7);--especifico 32
                 --Width_3quarter <= conv_std_logic_vector((((W32x32COLUMN_END_INIT_cte - W32x32COLUMN_START_INIT_cte)+1)/4)*3,7);
                 Width_3quarter <= conv_std_logic_vector((((W32x32COLUMN_END_INIT_cte - W32x32COLUMN_START_INIT_cte )+1)/4)*3,7); --especifico 32x32  
                 width_half_plus2<= conv_std_logic_vector((((W32x32COLUMN_END_INIT_cte - W32x32COLUMN_START_INIT_cte)+1)/2)+2,7);   
                 CNT_COL_JUMP<=conv_std_logic_vector(16,6);
                 LAST_IO_end<=conv_std_logic_vector(0,7);
                                                                
                 
              when others =>
              
              end case;
           if(ENA = '0')
           then
           
                 ESTADO <= IDLE;
                 --128 data
                 Column_start <= conv_std_logic_vector(COLUMN_START_INIT_cte,7);
                 Row_start <=  conv_std_logic_vector(ROW_START_INIT_cte,7);
                 Column_end <= conv_std_logic_vector(COLUMN_END_INIT_cte,7);
                 Row_end <= conv_std_logic_vector(ROW_END_INIT_cte,7);
                 Width <= conv_std_logic_vector(COLUMN_END_INIT_cte - COLUMN_START_INIT_cte,7);
                 Height <= conv_std_logic_vector(ROW_END_INIT_cte - ROW_START_INIT_cte,7);
                 Width_quarter <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/4),7);
                 Width_half <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/2),7);
             end if;   
                      
                
           if (ap_start = '1') then
             INTEGRATION_time<= INTEGRATION_TIME_in;
                        --gain_reg<=gain_in;
              if(windowing_reg= NO_WINDOWING) then
              ESTADO <= INTEGRATION;
              else  
              ESTADO <= INTEGRATION_windowing;
             end if;
           end if; 
           
        when INTEGRATION_windowing =>
             
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '0';
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '0';
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';    
           roic_bus <=  '0';
           roic_progdac <=  '1';
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
           
           IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');
           if (cnt_SM >= INTEGRATION_time) then
              ESTADO <= XCOUNT_TO_RSTNEG_windowing;
              cnt_SM <= (others => '0');
           else
             ESTADO <= INTEGRATION_windowing;
           end if;
               
        when XCOUNT_TO_RSTNEG_windowing =>
        
            roic_rowsel <=  roic_row_end_windowing;
            roic_colsel <=  roic_col_start_windowing;
            roic_gain2 <=  gain_reg;
            roic_xcount <=  '1'; --change
            roic_xrst <=  '1';
            roic_xanalog_rst <=  '0';
            roic_xtest <= xtest_reg;
            roic_rstneg <=  '0';    
            roic_bus <=  '0';
            roic_progdac <=  '1';
            roic_phi4 <=  '1';
            roic_CLK_reg <=  '0';
            roic_CLK_periph <=  '0';
            roic_DB <=  DB_reg;                 
            roic_DIN10 <=  '0';
            roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
            IMG_Data_Out <=  (others => '0');  
         
            if (cnt_SM >= XCOUNT_TO_RSTNEG_time) then
               ESTADO <= RSTNEG_TO_XANALOGRST_windowing;
               cnt_SM <= (others => '0');
            else
               ESTADO <= XCOUNT_TO_RSTNEG_windowing;
            end if;      
        
        when RSTNEG_TO_XANALOGRST_windowing => 
           
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '0';
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1'; --change   
           roic_bus <=  '0';
           roic_progdac <=  '1';
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
           
           IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
           
           if (cnt_SM >= RSTNEG_TO_XANALOGRST_time) then
              ESTADO <= XANALOGRST_TO_BUS_windowing;
              cnt_SM <= (others => '0');
           else
              ESTADO <= RSTNEG_TO_XANALOGRST_windowing;
           end if;   
                  
        when XANALOGRST_TO_BUS_windowing =>
           
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; --change
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '0';
           roic_progdac <=  '1';
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
           
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
           
           if (cnt_SM >= XANALOGRST_TO_BUS_time)
           then
              ESTADO <= BUS_TO_IO_windowing;
              cnt_SM <= (others => '0');
           else
              ESTADO <= XANALOGRST_TO_BUS_windowing;
           end if;   
         
        when BUS_TO_IO_windowing =>
           
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '1'; --change
           roic_progdac <=  '0'; --change
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
           
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
           CNT_ROW_REG <= CNT_ROW;
           
           if (cnt_SM >= BUS_TO_IO_time)
           then
              ESTADO <= FIRST_IO_windowing;
              cnt_SM <= (others => '0');
           else
              ESTADO <= BUS_TO_IO_windowing;
           end if;
           
        when FIRST_IO_windowing =>
           roic_rowsel <= (roic_row_end_windowing - CNT_ROW_REG);
           CNT_ROW_REG <= CNT_ROW;
           if( Windowing_reg = WINDOWING32x32 ) then
              if(CNT_COL < width_half) then  
                 roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0');
              else
                 roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0') + 32;
              end if;    
           else
              roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0');
           end if;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '1';
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
          
           --if ((CNT_COL  = 16)  and (cnt_SM(0) = '1')) --fijos para 128
           if ((CNT_COL  = width_quarter)  and (cnt_SM(0) = '1')) --fijos para 128
           then
               roic_CLK_reg <= not roic_CLK_reg;
           end if;
           
           roic_CLK_periph <=  not (cnt_SM(0));
           roic_DB <=  DB_reg;
           roic_DIN10 <= '1';
           roic_DINDB10 <= '1';
                    
           IMG_ADDR_reg <=  (others => '0');
           IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others=> '0');
           IMG_Data_Out_DB <=  (others=> '0');
           
           if ( cnt_SM(0) = '1') then
               CNT_COL <= CNT_COL +1;
           end if;
                              
           --if ((CNT_COL  = 32) and (cnt_SM(0) = '1')) --fijos para 128
           if (((CNT_COL  = width_half)or (CNT_COL  = 32)) and (cnt_SM(0) = '1')) --fijos para 128
           then
             --CNT_COL <= CNT_COL + 1 + CNT_COL_JUMP;
             ESTADO <= IO_windowing;
             cnt_SM <= (others => '0');
             IMG_ADDR_reg <=(others=>'0');
             roic_CLK_reg <= not roic_CLK_reg;
             IMG_Data_write_reg<='0';
           else
             ESTADO <= FIRST_IO_windowing;
           end if;  
                      
             
        when IO_windowing =>
           roic_rowsel <= (roic_row_end_windowing - CNT_ROW_REG);
           CNT_ROW_REG <= CNT_ROW;
           if( Windowing_reg = WINDOWING32x32 ) then
              if(CNT_COL < width_half) then  
                 roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0');
              else
                 roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0') + 32;
              end if;    
           else
              roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0');
           end if;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '1';
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
           
           if (cnt_SM(0) = '1') then
              --if ((CNT_COL  = 0) or (CNT_COL = 16) or (CNT_COL = 32)or (CNT_COL  = 48)) then --fijos para 64
              if ((CNT_COL  = 0) or (CNT_COL = Width_quarter) or (CNT_COL = Width_half)or (CNT_COL  = Width_3quarter)) then 
                 roic_CLK_reg <= not roic_CLK_reg;
              end if;
                           
           end if;
           
           roic_CLK_periph <=  not (cnt_SM(0));
           roic_DB <=  DB_reg;      
           IMG_ADDR <= IMG_ADDR_reg;
           IMG_Data_Out <= roic_DOUT;  
           IMG_Data_Out_DB <=  roic_DOUTDB;
           IMG_Data_write_reg <= not (cnt_SM(0));
           --if ( CNT_COL >= 35) or ( CNT_COL < 3) then especifico del 64
           if ( CNT_COL >width_half_plus2) or ( CNT_COL < 3) then --
              IMG_Data_write <= IMG_Data_write_reg;
           else
              IMG_Data_write <= '0';
               
           end if;   
           
           if ( cnt_SM(0) = '1') then
              CNT_COL <= CNT_COL +1;
--              if(CNT_COL= 15)or (CNT_COL= 47) then
--                CNT_COL <= CNT_COL + 1 + CNT_COL_JUMP;
--              end if;  
              --if ( CNT_COL >= 32) and ( CNT_COL < 63)then
              --maloif ( CNT_COL >= roic_col_start_windowing) and ( CNT_COL < roic_col_end_windowing)then
              if (( CNT_COL >= width_half) and ( CNT_COL < width )and (windowing_reg /=WINDOWING32x32 ))then
                 roic_DIN10 <= '0';
                 roic_DINDB10 <= '0';
              else
                
                roic_DIN10 <= '1';
                roic_DINDB10 <= '1';
               
              end if;
              
                                              
              --if(CNT_COL > 34)then
              if(CNT_COL > width_half_plus2) then 
                 IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
              end if;
              --if(CNT_COL = 63)then
              
              if(CNT_COL = width)then
                 CNT_ROW <= CNT_ROW +1;
                 CNT_COL<= (others => '0');
              end if; 
              if ( CNT_COL = 0) then
                 IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
              elsif (CNT_COL < 3) then --duda si el 3 se puede calcular de constantes
                  IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
                  
              else
              end if;                        
           end if;
           if ((CNT_COL = Width(6 downto 1)) and (CNT_ROW = height)and (cnt_SM(0) = '1')) then
              ESTADO <= LAST_IO_windowing;
              cnt_SM <= (others => '0');
           else
              ESTADO <= IO_windowing;
           end if; 
                                                     
        when LAST_IO_windowing =>
           roic_rowsel <= (roic_row_end_windowing - CNT_ROW_REG);
           if( Windowing_reg = WINDOWING32x32 ) then
              if(CNT_COL < width_half) then  
                 roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0');
              else
                 roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0') + 32;
              end if;    
           else
              roic_colsel <=  roic_col_start_windowing + (CNT_COL & '0');
           end if;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '1';
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
           
           roic_CLK_periph <=  not (cnt_SM(0));
           roic_DB <=  DB_reg;                 
           if ( cnt_SM(0) = '1') then
              --if ( CNT_COL >= 32) and ( CNT_COL < 63)then
              if (( CNT_COL >= width_half) and ( CNT_COL < width )and (windowing_reg /=WINDOWING32x32 )) then
                 roic_DIN10 <= '0';
                 roic_DINDB10 <= '0';
              else
                
               roic_DIN10 <= '1';
               roic_DINDB10 <= '1';
               
              end if;
           end if;   
           
           IMG_ADDR <= IMG_ADDR_reg;
           IMG_Data_Out <= roic_DOUT;  
           IMG_Data_Out_DB <=  roic_DOUTDB;
           IMG_Data_write_reg <= not (cnt_SM(0));
           --if ( CNT_COL >= 35) or ( CNT_COL < 3) then
           --if ( CNT_COL > 34) or ( CNT_COL < 3) then
           if ( CNT_COL > width_half_plus2) or ( CNT_COL < 3)  then
              IMG_Data_write <= IMG_Data_write_reg;
           else
              IMG_Data_write <= '0';
           end if;
           
           
            
           if ( cnt_SM(0) = '1') then
              CNT_COL <= CNT_COL +1;  
              if(CNT_COL = width)then
                 CNT_ROW <= CNT_ROW +1;
                 CNT_COL<= (others => '0');
              end if; 
              if ((CNT_COL  = 0) or (CNT_COL = width_quarter) or (CNT_COL = width_half)or (CNT_COL  = width_3quarter)) then  --fijos para 64
                 roic_CLK_reg <= not roic_CLK_reg;
              end if;
              
              if(CNT_COL > width_half_plus2) or (CNT_COL = 0)then
                 IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
              end if;
           end if;
           if ((CNT_COL = LAST_IO_end) and (cnt_SM(0) = '1')) then
              ESTADO <= IO_TO_BUS_windowing;
              IMG_Data_write_reg<='0'; 
              cnt_SM <= (others => '0');
           else
              ESTADO <= LAST_IO_windowing;
           end if; 
                          
        when IO_TO_BUS_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '1';
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           --roic_DIN10 <=  '0';
           --roic_DINDB10 <=  '0';
           roic_DIN10 <=  '1';-- mirar si ahce cosas raras cambio en los windowings
           roic_DINDB10 <=  '1';
                      
           
           if(cnt_SM<4) then
              IMG_Data_write_reg <= not (cnt_SM(0));
              IMG_Data_write <= IMG_Data_write_reg;
              IMG_ADDR <= IMG_ADDR_reg;
              IMG_Data_Out <= roic_DOUT;  
              IMG_Data_Out_DB <=  roic_DOUTDB;
              if ( cnt_SM(0) = '1') then
                 IMG_ADDR_reg  <=  IMG_ADDR_reg +1;
              end if;  
           else
              IMG_Data_write_reg <= '0';                    
              IMG_Data_write <= IMG_Data_write_reg;    
           end if;
           
           CNT_COL <= (others => '0');
           CNT_ROW <= (others => '0'); 
           
           if (cnt_SM >= IO_TO_BUS_windowing_time) then --afinando
              ESTADO <= BUS_TO_RSTNEG_windowing;
              cnt_SM <= (others => '0');
           else
             ESTADO <= IO_TO_BUS_windowing;
           end if;
 
                                                     
        when BUS_TO_RSTNEG_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '1';   
           roic_bus <=  '0'; --change
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM >= BUS_TO_RSTNEG_time) then
              ESTADO <= RSTNEG_TO_CLK_windowing;
              cnt_SM <= (others => '0');
           else
              ESTADO <= BUS_TO_RSTNEG_windowing;
           end if; 
           
        when RSTNEG_TO_CLK_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   --change 
           roic_bus <=  '0'; 
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM >= RSTNEG_TO_CLK_time)
           then
             ESTADO <= CLK_TO_PHI4_windowing;
             cnt_SM <= (others => '0');
           else
             ESTADO <= RSTNEG_TO_CLK_windowing;
           end if;         
        
        when CLK_TO_PHI4_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   
           roic_bus <=  '0'; 
           roic_progdac <=  '0'; 
           roic_phi4 <=  '1';
           roic_CLK_reg<=  '1';--change
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM >= CLK_TO_PHI4_time)
           then
             ESTADO <= PHI4_TO_CLK_windowing;
             cnt_SM <= (others => '0');
           else
             ESTADO <= CLK_TO_PHI4_windowing;
           end if;
           
        when PHI4_TO_CLK_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   
           roic_bus <=  '0'; 
           roic_progdac <=  '0'; 
           roic_phi4 <=  '0';--change
           roic_CLK_reg <=  '1';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM >= PHI4_TO_CLK_time)
           then
             ESTADO <= CLK_TO_PROGDAC_windowing;
             cnt_SM <= (others => '0');
           else
             ESTADO <= PHI4_TO_CLK_windowing;
           end if;   
        
        when CLK_TO_PROGDAC_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   
           roic_bus <=  '0'; 
           roic_progdac <=  '0'; 
           roic_phi4 <=  '0';
           roic_CLK_reg <=  '0';--change
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM >= CLK_TO_PROGDAC_time)
           then
             ESTADO <= PROGDAC_TO_PHI4_windowing;
             cnt_SM <= (others => '0');
           else
             ESTADO <= CLK_TO_PROGDAC_windowing;
           end if; 
           
        when PROGDAC_TO_PHI4_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   
           roic_bus <=  '0'; 
           roic_progdac <=  '1'; --change
           roic_phi4 <=  '0';
           roic_CLK_reg <=  cnt_SM(7);
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM (11 downto 5) >= DEBUG_progdacCLK_windowing)
           then
             ESTADO <= PHI4_TO_XRST_windowing;
             cnt_SM <= (others => '0');
           else
             ESTADO <= PROGDAC_TO_PHI4_windowing;
           end if;      
        
        when PHI4_TO_XRST_windowing =>
          --roic_rowsel <=  (others => '0');
          roic_rowsel <=  roic_row_end_windowing;
          --roic_colsel <=  (others => '0');
          roic_colsel <=  roic_col_start_windowing;
          roic_gain2 <=  gain_reg;
          roic_xcount <=  '1'; 
          roic_xrst <=  '1';
          roic_xanalog_rst <=  '1'; 
          roic_xtest <= xtest_reg;
          roic_rstneg <=  '0';   
          roic_bus <=  '0'; 
          roic_progdac <=  '1'; 
          roic_phi4 <=  '1';--change
          roic_CLK_reg <=  '1';--change
          roic_CLK_periph <=  '0';
          roic_DB <=  DB_reg;                 
          roic_DIN10 <=  '0';
          roic_DINDB10 <=  '0';
           
          IMG_ADDR  <=  (others => '0');
          IMG_Data_Out <=  (others => '0');  
           
          if (cnt_SM >= PHI4_TO_XRST_time)
          then
            ESTADO <= XRST_TO_XRST_windowing;
            cnt_SM <= (others => '0');
          else
            ESTADO <= PHI4_TO_XRST_windowing;
          end if;
        
        when XRST_TO_XRST_windowing =>
          roic_rowsel <=  roic_row_end_windowing;
          roic_colsel <=  roic_col_start_windowing;
          roic_gain2 <=  gain_reg;
          roic_xcount <=  '1'; 
          roic_xrst <=  '0';--change
          roic_xanalog_rst <=  '1'; 
          roic_xtest <= xtest_reg;
          roic_rstneg <=  '0';   
          roic_bus <=  '0'; 
          roic_progdac <=  '1'; 
          roic_phi4 <=  '1';
          roic_CLK_reg <=  '0';--change
          roic_CLK_periph <=  '0';
          roic_DB <=  DB_reg;                 
          roic_DIN10 <=  '0';
          roic_DINDB10 <=  '0';
          
          IMG_ADDR  <=  (others => '0');
          IMG_Data_Out <=  (others => '0');  
           
          if (cnt_SM >= XRST_TO_XRST_time)
          then
            ESTADO <= XRST_TO_INTEGRATION_windowing;
            cnt_SM <= (others => '0');
          else
            ESTADO <= XRST_TO_XRST_windowing;
          end if;
          
        when XRST_TO_INTEGRATION_windowing =>
           roic_rowsel <=  roic_row_end_windowing;
           roic_colsel <=  roic_col_start_windowing;
           roic_gain2 <=  gain_reg;
           roic_xcount <=  '1'; 
           roic_xrst <=  '1';--change
           roic_xanalog_rst <=  '1'; 
           roic_xtest <= xtest_reg;
           roic_rstneg <=  '0';   
           roic_bus <=  '0'; 
           roic_progdac <=  '1';
           roic_phi4 <=  '1';
           roic_CLK_reg <=  '0';
           roic_CLK_periph <=  '0';
           roic_DB <=  DB_reg;                 
           roic_DIN10 <=  '0';
           roic_DINDB10 <=  '0';
            
            IMG_ADDR  <=  (others => '0');
           IMG_Data_Out <=  (others => '0');  
            
           if (cnt_SM >= XRST_TO_INTEGRACION_time) then
              cnt_SM <= (others => '0');
              if (windowing_reg =  NO_WINDOWING) then
                  ESTADO <= IDLE;
                  ap_done<='1';
                  --128 data
                  Column_start <= conv_std_logic_vector(COLUMN_START_INIT_cte,7);
                  Row_start <=  conv_std_logic_vector(ROW_START_INIT_cte,7);
                  Column_end <= conv_std_logic_vector(COLUMN_END_INIT_cte,7);
                  Row_end <= conv_std_logic_vector(ROW_END_INIT_cte,7);
                  Width <= conv_std_logic_vector(COLUMN_END_INIT_cte - COLUMN_START_INIT_cte,7);
                  Height <= conv_std_logic_vector(ROW_END_INIT_cte - ROW_START_INIT_cte,7);
                  Width_quarter <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/4),7);
                  Width_half <= conv_std_logic_vector((((COLUMN_END_INIT_cte - COLUMN_START_INIT_cte)+1)/2),7);
              else
                ESTADO <= IDLE_windowing;
                ap_done<='1';
              end if;  
           else
              ESTADO <= XRST_TO_INTEGRATION_windowing;
           end if;   
                   
        when Others =>
             
        end case;
    
    if(debug_din = '1') then
        roic_DIN10 <=  '1';
        roic_DINDB10 <=  '1';
     end if;   
        
    
    end if;
end if;

end process;

end Behavioral;
