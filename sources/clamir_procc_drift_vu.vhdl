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

entity procc_drift is

GENERIC(
      sys_clk         : INTEGER := 100_000_000; --system clock frequency in Hz
      IMG_bits        : INTEGER := 16;    
      ADDR_bits : INTEGER := 3);          
  Port ( 
  
      CLK  : in std_logic;
      RESET : in std_logic;
  
  --IMG_Memory
      IMG_Data_In : in STD_LOGIC_VECTOR (((IMG_bits)*16) -1 downto 0);
      DRIFT_Out : out STD_LOGIC_VECTOR (IMG_bits - 1 downto 0);
      IMG_Address : out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
      
      Selected_position :  in std_logic_vector (3 downto 0);
            
      --ap_ctrl_chain last block
      ap_start : in STD_logic;
      ap_done : out STD_logic;  
      ap_idle: out STD_logic;  
          
      --configuration registers    
      ENA: in std_logic
  
  );
  
  attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of procc_drift : entity is "true";
end procc_drift;

architecture Behavioral of procc_drift is

 function count_ones(s : std_logic_vector) return std_logic_vector is
          variable temp : std_logic_vector (14 downto 0) := (others => '0');
        begin
          for i in s'range loop
            if s(i) = '1' then temp := temp + 1; 
            end if;
          end loop;
          
          return temp;
        end function count_ones;  

type TIPO_GLOBAL_STATE is (IDLE,GENERATE_ADDRESS, READ_PIXELS,ORDER,ADD, READY);
  signal GLOBAL_STATE: TIPO_GLOBAL_STATE;
 attribute dont_touch of GLOBAL_STATE : signal is "true";  
  

-- 20|21|22
-- 10|11|12
-- 00|01|02


signal PIXEL_0 : std_logic_vector (15 downto 0);
signal PIXEL_1 : std_logic_vector (15 downto 0);
signal PIXEL_2 : std_logic_vector (15 downto 0);
signal PIXEL_3 : std_logic_vector (15 downto 0);
signal PIXEL_4 : std_logic_vector (15 downto 0);
signal PIXEL_5 : std_logic_vector (15 downto 0);
signal PIXEL_6 : std_logic_vector (15 downto 0);
signal PIXEL_7 : std_logic_vector (15 downto 0);
signal PIXEL_8 : std_logic_vector (15 downto 0);
signal PIXEL_9 : std_logic_vector (15 downto 0);
signal PIXEL_10 : std_logic_vector (15 downto 0);
signal PIXEL_11 : std_logic_vector (15 downto 0);
signal PIXEL_12 : std_logic_vector (15 downto 0);
signal PIXEL_13 : std_logic_vector (15 downto 0);
signal PIXEL_14 : std_logic_vector (15 downto 0);
signal PIXEL_15 : std_logic_vector (15 downto 0);

signal sum_0 : std_logic_vector (14 downto 0);
signal sum_1 : std_logic_vector (14 downto 0);
signal sum_2 : std_logic_vector (14 downto 0);
signal sum_3 : std_logic_vector (14 downto 0);
signal sum_4 : std_logic_vector (14 downto 0);
signal sum_5 : std_logic_vector (14 downto 0);
signal sum_6 : std_logic_vector (14 downto 0);
signal sum_7 : std_logic_vector (14 downto 0);
signal sum_8 : std_logic_vector (14 downto 0);
signal sum_9 : std_logic_vector (14 downto 0);
signal sum_10 : std_logic_vector (14 downto 0);
signal sum_11 : std_logic_vector (14 downto 0);
signal sum_12 : std_logic_vector (14 downto 0);
signal sum_13 : std_logic_vector (14 downto 0);
signal sum_14 : std_logic_vector (14 downto 0);
signal sum_15 : std_logic_vector (14 downto 0);

signal tick: std_logic_vector (7 downto 0);
 attribute dont_touch of tick : signal is "true";  


signal BPC_Adress_reg: std_logic_vector (7 downto 0);
signal IMG_ADDR_reg: std_logic_vector (ADDR_bits-1 downto 0);

signal IMG_dump_Address_reg: std_logic_vector (ADDR_bits-1 downto 0):=(others =>'0'); 
signal IMG_out_dump_web_reg: std_logic:='0';
signal cnt_blocks: std_logic_vector (3 downto 0);
signal result: std_logic_vector (18 downto 0);
 attribute dont_touch of result : signal is "true";  
signal selected_position_reg: std_logic_vector (3 downto 0);

begin

--Address_in<=Address_signal(ADDR_bits-1 downto 0);


process (CLK)
begin


IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') then
    

     ap_idle <=  '0';
     Global_state <= IDLE;     
     IMG_Address<= (others => '0');
     Drift_Out <= (others => '0');
    
                 
     BPC_Adress_reg<= (others => '0');
     tick <= (others => '0');
     
     
     IMG_ADDR_reg<= (others => '0');
       result<= (others => '0');
      PIXEL_0 <= (others => '0');
      PIXEL_1 <= (others => '0');
      PIXEL_2 <= (others => '0');
      PIXEL_3 <= (others => '0');
      PIXEL_4 <= (others => '0');
      PIXEL_5 <= (others => '0');
      PIXEL_6<= (others => '0');
      PIXEL_7 <= (others => '0');
      PIXEL_8<= (others => '0');
      PIXEL_9 <= (others => '0');
      PIXEL_10 <= (others => '0');
      PIXEL_11<= (others => '0');
      PIXEL_12 <= (others => '0');
      PIXEL_13 <= (others => '0');
      PIXEL_14 <= (others => '0');
      PIXEL_15 <= (others => '0');
      
      sum_0<=(others=>'0');
      sum_1<=(others=>'0');
      sum_2<=(others=>'0');
      sum_3<=(others=>'0');
      sum_4<=(others=>'0');
      sum_5<=(others=>'0');
      sum_6<=(others=>'0');
      sum_7<=(others=>'0');
      sum_8<=(others=>'0');
      sum_9<=(others=>'0');
      sum_10<=(others=>'0');
      sum_11<=(others=>'0');
      sum_12<=(others=>'0');
      sum_13<=(others=>'0');
      sum_14<=(others=>'0');
      sum_15<=(others=>'0');
      selected_position_reg<=(others=>'0');

       
    else
    
IMG_Address <= IMG_ADDR_reg;

        case Global_state is
            
         when IDLE =>

              ap_idle <=  '1';  
              ap_done <= '0';
              tick<=(others =>'0');
              IMG_ADDR_reg<= (others => '0');
                     result<= (others => '0');
                                      
                    sum_0<=(others=>'0');
                    sum_1<=(others=>'0');
                    sum_2<=(others=>'0');
                    sum_3<=(others=>'0');
                    sum_4<=(others=>'0');
                    sum_5<=(others=>'0');
                    sum_6<=(others=>'0');
                    sum_7<=(others=>'0');
                    sum_8<=(others=>'0');
                    sum_9<=(others=>'0');
                    sum_10<=(others=>'0');
                    sum_11<=(others=>'0');
                    sum_12<=(others=>'0');
                    sum_13<=(others=>'0');
                    sum_14<=(others=>'0');
                    sum_15<=(others=>'0');
              
              
              if (ENA = '1')
              then                    
              
                  if (ap_start ='1') 
                  then
                        selected_position_reg <= selected_position;
                       ap_idle <=  '0';
                             cnt_blocks <=(others => '0');
                           Global_state <= READ_PIXELS;     
--                       end if;
                  end if;
              else
              
              end if;
        
       
     when READ_PIXELS =>
        
        PIXEL_0 <= IMG_Data_In ( (1*(16)-1) downto (1*(16)-16));
        PIXEL_1 <= IMG_Data_In ( (2*(16)-1) downto (2*(16)-16));
        PIXEL_2 <= IMG_Data_In ( (3*(16)-1) downto (3*(16)-16));
        PIXEL_3 <= IMG_Data_In ( (4*(16)-1) downto (4*(16)-16));
        PIXEL_4 <= IMG_Data_In ( (5*(16)-1) downto (5*(16)-16));
        PIXEL_5 <= IMG_Data_In ( (6*(16)-1) downto (6*(16)-16));
        PIXEL_6 <= IMG_Data_In ( (7*(16)-1) downto (7*(16)-16));
        PIXEL_7 <= IMG_Data_In ( (8*(16)-1) downto (8*(16)-16));
        PIXEL_8 <= IMG_Data_In ( (9*(16)-1) downto (9*(16)-16));
        PIXEL_9 <= IMG_Data_In ( (10*(16)-1) downto (10*(16)-16));
        PIXEL_10 <= IMG_Data_In ( (11*(16)-1) downto (11*(16)-16));
        PIXEL_11 <= IMG_Data_In ( (12*(16)-1) downto (12*(16)-16));
        PIXEL_12 <= IMG_Data_In ( (13*(16)-1) downto (13*(16)-16));
        PIXEL_13 <= IMG_Data_In ( (14*(16)-1) downto (14*(16)-16));
        PIXEL_14 <= IMG_Data_In ( (15*(16)-1) downto (15*(16)-16));
        PIXEL_15 <= IMG_Data_In ( (16*(16)-1) downto (16*(16)-16));
        IMG_ADDR_reg<=IMG_ADDR_reg + 1;
        sum_0<=(others=>'0');
        sum_1<=(others=>'0');
        sum_2<=(others=>'0');
        sum_3<=(others=>'0');
        sum_4<=(others=>'0');
        sum_5<=(others=>'0');
        sum_6<=(others=>'0');
        sum_7<=(others=>'0');
        sum_8<=(others=>'0');
        sum_9<=(others=>'0');
        sum_10<=(others=>'0');
        sum_11<=(others=>'0');
        sum_12<=(others=>'0');
        sum_13<=(others=>'0');
        sum_14<=(others=>'0');
        sum_15<=(others=>'0');
        tick <=(others=>'0');
        
      
        Global_state <= ORDER; 
        
      when ORDER => 
        
        tick <= tick + 1;
                              
        --frist tick
        case tick is
           when x"00" =>
            if (PIXEL_0 >= PIXEL_1) then
                sum_0 (0) <= '1';
            end if;
            if (PIXEL_0 >= PIXEL_2) then  
                sum_0 (1) <= '1';          
            end if;                    
            if (PIXEL_0 >= PIXEL_3) then
                sum_0 (2) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_4) then
                sum_0 (3) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_5) then
                sum_0 (4) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_6) then
                sum_0 (5) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_7) then
                sum_0 (6) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_8) then
                sum_0 (7) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_9) then
                sum_0 (8) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_10) then
                sum_0 (9) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_11) then
                sum_0 (10) <= '1';      
            end if;               
            if (PIXEL_0 >= PIXEL_12) then
                sum_0 (11) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_13) then
                sum_0 (12) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_14) then
                sum_0 (13) <= '1';      
            end if;                    
            if (PIXEL_0 >= PIXEL_15) then
                sum_0 (14) <= '1';      
            end if;
           
           when x"01" =>
           sum_0 <= count_ones(sum_0);
           
            if (PIXEL_1 > PIXEL_0) then
                sum_1 (0) <= '1';
            end if;
            if (PIXEL_1 >= PIXEL_2) then  
                sum_1 (1) <= '1';          
            end if;                    
            if (PIXEL_1 >= PIXEL_3) then
                sum_1 (2) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_4) then
                sum_1 (3) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_5) then
                sum_1 (4) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_6) then
                sum_1 (5) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_7) then
                sum_1 (6) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_8) then
                sum_1 (7) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_9) then
                sum_1 (8) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_10) then
                sum_1 (9) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_11) then
                sum_1 (10) <= '1';      
            end if;               
            if (PIXEL_1 >= PIXEL_12) then
                sum_1 (11) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_13) then
                sum_1 (12) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_14) then
                sum_1 (13) <= '1';      
            end if;                    
            if (PIXEL_1 >= PIXEL_15) then
                sum_1 (14) <= '1';      
            end if;
           
           when x"02" =>
           sum_1 <= count_ones(sum_1);
            if (PIXEL_2 > PIXEL_0) then
                sum_2 (0) <= '1';
            end if;
            if (PIXEL_2 > PIXEL_1) then  
                sum_2 (1) <= '1';          
            end if;                    
            if (PIXEL_2 >= PIXEL_3) then
                sum_2 (2) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_4) then
                sum_2 (3) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_5) then
                sum_2 (4) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_6) then
                sum_2 (5) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_7) then
                sum_2 (6) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_8) then
                sum_2 (7) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_9) then
                sum_2 (8) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_10) then
                sum_2 (9) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_11) then
                sum_2 (10) <= '1';      
            end if;               
            if (PIXEL_2 >= PIXEL_12) then
                sum_2 (11) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_13) then
                sum_2 (12) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_14) then
                sum_2 (13) <= '1';      
            end if;                    
            if (PIXEL_2 >= PIXEL_15) then
                sum_2 (14) <= '1';      
            end if;
           
           when x"03" =>
           sum_2 <= count_ones(sum_2);
            if (PIXEL_3 > PIXEL_0) then
                sum_3 (0) <= '1';
            end if;
            if (PIXEL_3 > PIXEL_1) then  
                sum_3 (1) <= '1';          
            end if;                    
            if (PIXEL_3 > PIXEL_2) then
                sum_3 (2) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_4) then
                sum_3 (3) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_5) then
                sum_3 (4) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_6) then
                sum_3 (5) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_7) then
                sum_3 (6) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_8) then
                sum_3 (7) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_9) then
                sum_3 (8) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_10) then
                sum_3 (9) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_11) then
                sum_3 (10) <= '1';      
            end if;               
            if (PIXEL_3 >= PIXEL_12) then
                sum_3 (11) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_13) then
                sum_3 (12) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_14) then
                sum_3 (13) <= '1';      
            end if;                    
            if (PIXEL_3 >= PIXEL_15) then
                sum_3 (14) <= '1';      
            end if;                  
          
          when x"04" =>
          sum_3 <= count_ones(sum_3);
            if (PIXEL_4 > PIXEL_0) then
                sum_4 (0) <= '1';
            end if;
            if (PIXEL_4 > PIXEL_1) then  
                sum_4 (1) <= '1';          
            end if;                    
            if (PIXEL_4 > PIXEL_2) then
                sum_4 (2) <= '1';      
            end if;                    
            if (PIXEL_4 > PIXEL_3) then
                sum_4 (3) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_5) then
                sum_4 (4) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_6) then
                sum_4 (5) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_7) then
                sum_4 (6) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_8) then
                sum_4 (7) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_9) then
                sum_4 (8) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_10) then
                sum_4 (9) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_11) then
                sum_4 (10) <= '1';      
            end if;               
            if (PIXEL_4 >= PIXEL_12) then
                sum_4 (11) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_13) then
                sum_4 (12) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_14) then
                sum_4 (13) <= '1';      
            end if;                    
            if (PIXEL_4 >= PIXEL_15) then
                sum_4 (14) <= '1';      
            end if;
            
           when x"05" =>
           sum_4 <= count_ones(sum_4);
            if (PIXEL_5 > PIXEL_0) then
                sum_5 (0) <= '1';
            end if;
            if (PIXEL_5 > PIXEL_1) then  
                sum_5 (1) <= '1';          
            end if;                    
            if (PIXEL_5 > PIXEL_2) then
                sum_5 (2) <= '1';      
            end if;                    
            if (PIXEL_5 > PIXEL_3) then
                sum_5 (3) <= '1';      
            end if;                    
            if (PIXEL_5 > PIXEL_4) then
                sum_5 (4) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_6) then
                sum_5 (5) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_7) then
                sum_5 (6) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_8) then
                sum_5 (7) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_9) then
                sum_5 (8) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_10) then
                sum_5 (9) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_11) then
                sum_5 (10) <= '1';      
            end if;               
            if (PIXEL_5 >= PIXEL_12) then
                sum_5 (11) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_13) then
                sum_5 (12) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_14) then
                sum_5 (13) <= '1';      
            end if;                    
            if (PIXEL_5 >= PIXEL_15) then
                sum_5 (14) <= '1';      
            end if;                                            
        
        when x"06" =>
        sum_5 <= count_ones(sum_5);
            if (PIXEL_6 > PIXEL_0) then
                sum_6 (0) <= '1';
            end if;
            if (PIXEL_6 > PIXEL_1) then  
                sum_6 (1) <= '1';          
            end if;                    
            if (PIXEL_6 > PIXEL_2) then
                sum_6 (2) <= '1';      
            end if;                    
            if (PIXEL_6 > PIXEL_3) then
                sum_6 (3) <= '1';      
            end if;                    
            if (PIXEL_6 > PIXEL_4) then
                sum_6 (4) <= '1';      
            end if;                    
            if (PIXEL_6 > PIXEL_5) then
                sum_6 (5) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_7) then
                sum_6 (6) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_8) then
                sum_6 (7) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_9) then
                sum_6 (8) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_10) then
                sum_6 (9) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_11) then
                sum_6 (10) <= '1';      
            end if;               
            if (PIXEL_6 >= PIXEL_12) then
                sum_6 (11) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_13) then
                sum_6 (12) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_14) then
                sum_6 (13) <= '1';      
            end if;                    
            if (PIXEL_6 >= PIXEL_15) then
                sum_6 (14) <= '1';      
            end if;  
        
        when x"07" =>
        sum_6 <= count_ones(sum_6);
                if (PIXEL_7 > PIXEL_0) then
                    sum_7 (0) <= '1';
                end if;
                if (PIXEL_7 > PIXEL_1) then  
                    sum_7 (1) <= '1';          
                end if;                    
                if (PIXEL_7 > PIXEL_2) then
                    sum_7 (2) <= '1';      
                end if;                    
                if (PIXEL_7 > PIXEL_3) then
                    sum_7 (3) <= '1';      
                end if;                    
                if (PIXEL_7 > PIXEL_4) then
                    sum_7 (4) <= '1';      
                end if;                    
                if (PIXEL_7 > PIXEL_5) then
                    sum_7 (5) <= '1';      
                end if;                    
                if (PIXEL_7 > PIXEL_6) then
                    sum_7 (6) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_8) then
                    sum_7 (7) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_9) then
                    sum_7 (8) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_10) then
                    sum_7 (9) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_11) then
                    sum_7 (10) <= '1';      
                end if;               
                if (PIXEL_7 >= PIXEL_12) then
                    sum_7 (11) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_13) then
                    sum_7 (12) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_14) then
                    sum_7 (13) <= '1';      
                end if;                    
                if (PIXEL_7 >= PIXEL_15) then
                    sum_7 (14) <= '1';      
                end if;        
    
        
        when x"08" =>
        sum_7 <= count_ones(sum_7);
             if (PIXEL_8 > PIXEL_0) then
                 sum_8 (0) <= '1';
             end if;
             if (PIXEL_8 > PIXEL_1) then  
                 sum_8 (1) <= '1';          
             end if;                    
             if (PIXEL_8 > PIXEL_2) then
                 sum_8 (2) <= '1';      
             end if;                    
             if (PIXEL_8 > PIXEL_3) then
                 sum_8 (3) <= '1';      
             end if;                    
             if (PIXEL_8 > PIXEL_4) then
                 sum_8 (4) <= '1';      
             end if;                    
             if (PIXEL_8 > PIXEL_5) then
                 sum_8 (5) <= '1';      
             end if;                    
             if (PIXEL_8 > PIXEL_6) then
                 sum_8 (6) <= '1';      
             end if;                    
             if (PIXEL_8 > PIXEL_7) then
                 sum_8 (7) <= '1';      
             end if;                    
             if (PIXEL_8 >= PIXEL_9) then
                 sum_8 (8) <= '1';      
             end if;                    
             if (PIXEL_8 >= PIXEL_10) then
                 sum_8 (9) <= '1';      
             end if;                    
             if (PIXEL_8 >= PIXEL_11) then
                 sum_8 (10) <= '1';      
             end if;               
             if (PIXEL_8 >= PIXEL_12) then
                 sum_8 (11) <= '1';      
             end if;                    
             if (PIXEL_8 >= PIXEL_13) then
                 sum_8 (12) <= '1';      
             end if;                    
             if (PIXEL_8 >= PIXEL_14) then
                 sum_8 (13) <= '1';      
             end if;                    
             if (PIXEL_8 >= PIXEL_15) then
                 sum_8 (14) <= '1';      
             end if; 
        
        when x"09" =>
        sum_8 <= count_ones(sum_8);
             if (PIXEL_9 > PIXEL_0) then
                 sum_9 (0) <= '1';
             end if;
             if (PIXEL_9 > PIXEL_1) then  
                 sum_9 (1) <= '1';          
             end if;                    
             if (PIXEL_9 > PIXEL_2) then
                 sum_9 (2) <= '1';      
             end if;                    
             if (PIXEL_9 > PIXEL_3) then
                 sum_9 (3) <= '1';      
             end if;                    
             if (PIXEL_9 > PIXEL_4) then
                 sum_9 (4) <= '1';      
             end if;                    
             if (PIXEL_9 > PIXEL_5) then
                 sum_9 (5) <= '1';      
             end if;                    
             if (PIXEL_9 > PIXEL_6) then
                 sum_9 (6) <= '1';      
             end if;                    
             if (PIXEL_9 > PIXEL_7) then
                 sum_9 (7) <= '1';      
             end if;                    
             if (PIXEL_9 > PIXEL_8) then
                 sum_9 (8) <= '1';      
             end if;                    
             if (PIXEL_9 >= PIXEL_10) then
                 sum_9 (9) <= '1';      
             end if;                    
             if (PIXEL_9 >= PIXEL_11) then
                 sum_9 (10) <= '1';      
             end if;               
             if (PIXEL_9 >= PIXEL_12) then
                 sum_9 (11) <= '1';      
             end if;                    
             if (PIXEL_9 >= PIXEL_13) then
                 sum_9 (12) <= '1';      
             end if;                    
             if (PIXEL_9 >= PIXEL_14) then
                 sum_9 (13) <= '1';      
             end if;                    
             if (PIXEL_9 >= PIXEL_15) then
                 sum_9 (14) <= '1';      
             end if;
        
           when x"0A" =>
           sum_9 <= count_ones(sum_9);
             if (PIXEL_10 > PIXEL_0) then
                 sum_10 (0) <= '1';
             end if;
             if (PIXEL_10 > PIXEL_1) then  
                 sum_10 (1) <= '1';          
             end if;                    
             if (PIXEL_10 > PIXEL_2) then
                 sum_10 (2) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_3) then
                 sum_10 (3) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_4) then
                 sum_10 (4) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_5) then
                 sum_10 (5) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_6) then
                 sum_10 (6) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_7) then
                 sum_10 (7) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_8) then
                 sum_10 (8) <= '1';      
             end if;                    
             if (PIXEL_10 > PIXEL_9) then
                 sum_10 (9) <= '1';      
             end if;                    
             if (PIXEL_10 >= PIXEL_11) then
                 sum_10 (10) <= '1';      
             end if;               
             if (PIXEL_10 >= PIXEL_12) then
                 sum_10 (11) <= '1';      
             end if;                    
             if (PIXEL_10 >= PIXEL_13) then
                 sum_10 (12) <= '1';      
             end if;                    
             if (PIXEL_10 >= PIXEL_14) then
                 sum_10 (13) <= '1';      
             end if;                    
             if (PIXEL_10 >= PIXEL_15) then
                 sum_10 (14) <= '1';      
             end if;        
         
          when x"0B" =>
          sum_10 <= count_ones(sum_10);
             if (PIXEL_11 > PIXEL_0) then
                 sum_11 (0) <= '1';
             end if;
             if (PIXEL_11 > PIXEL_1) then  
                 sum_11 (1) <= '1';          
             end if;                    
             if (PIXEL_11 > PIXEL_2) then
                 sum_11 (2) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_3) then
                 sum_11 (3) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_4) then
                 sum_11 (4) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_5) then
                 sum_11 (5) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_6) then
                 sum_11 (6) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_7) then
                 sum_11 (7) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_8) then
                 sum_11 (8) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_9) then
                 sum_11 (9) <= '1';      
             end if;                    
             if (PIXEL_11 > PIXEL_10) then
                 sum_11 (10) <= '1';      
             end if;               
             if (PIXEL_11 >= PIXEL_12) then
                 sum_11 (11) <= '1';      
             end if;                    
             if (PIXEL_11 >= PIXEL_13) then
                 sum_11 (12) <= '1';      
             end if;                    
             if (PIXEL_11 >= PIXEL_14) then
                 sum_11 (13) <= '1';      
             end if;                    
             if (PIXEL_11 >= PIXEL_15) then
                 sum_11 (14) <= '1';      
             end if;            
            
            when x"0C" =>
            sum_11 <= count_ones(sum_11);
               if (PIXEL_12 > PIXEL_0) then
                   sum_12 (0) <= '1';
               end if;
               if (PIXEL_12 > PIXEL_1) then  
                   sum_12 (1) <= '1';          
               end if;                    
               if (PIXEL_12 > PIXEL_2) then
                   sum_12 (2) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_3) then
                   sum_12 (3) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_4) then
                   sum_12 (4) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_5) then
                   sum_12 (5) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_6) then
                   sum_12 (6) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_7) then
                   sum_12 (7) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_8) then
                   sum_12 (8) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_9) then
                   sum_12 (9) <= '1';      
               end if;                    
               if (PIXEL_12 > PIXEL_10) then
                   sum_12 (10) <= '1';      
               end if;               
               if (PIXEL_12 > PIXEL_11) then
                   sum_12 (11) <= '1';      
               end if;                    
               if (PIXEL_12 >= PIXEL_13) then
                   sum_12 (12) <= '1';      
               end if;                    
               if (PIXEL_12 >= PIXEL_14) then
                   sum_12 (13) <= '1';      
               end if;                    
               if (PIXEL_12 >= PIXEL_15) then
                   sum_12 (14) <= '1';      
               end if; 
             
             when x"0D" =>
             sum_12 <= count_ones(sum_12);
               if (PIXEL_13 > PIXEL_0) then
                   sum_13 (0) <= '1';
               end if;
               if (PIXEL_13 > PIXEL_1) then  
                   sum_13 (1) <= '1';          
               end if;                    
               if (PIXEL_13 > PIXEL_2) then
                   sum_13 (2) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_3) then
                   sum_13 (3) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_4) then
                   sum_13 (4) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_5) then
                   sum_13 (5) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_6) then
                   sum_13 (6) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_7) then
                   sum_13 (7) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_8) then
                   sum_13 (8) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_9) then
                   sum_13 (9) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_10) then
                   sum_13 (10) <= '1';      
               end if;               
               if (PIXEL_13 > PIXEL_11) then
                   sum_13 (11) <= '1';      
               end if;                    
               if (PIXEL_13 > PIXEL_12) then
                   sum_13 (12) <= '1';      
               end if;                    
               if (PIXEL_13 >= PIXEL_14) then
                   sum_13 (13) <= '1';      
               end if;                    
               if (PIXEL_13 >= PIXEL_15) then
                   sum_13 (14) <= '1';      
               end if; 
            
            when x"0E" =>
            sum_13 <= count_ones(sum_13);
               if (PIXEL_14 > PIXEL_0) then
                   sum_14 (0) <= '1';
               end if;
               if (PIXEL_14 > PIXEL_1) then  
                   sum_14 (1) <= '1';          
               end if;                    
               if (PIXEL_14 > PIXEL_2) then
                   sum_14 (2) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_3) then
                   sum_14 (3) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_4) then
                   sum_14 (4) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_5) then
                   sum_14 (5) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_6) then
                   sum_14 (6) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_7) then
                   sum_14 (7) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_8) then
                   sum_14 (8) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_9) then
                   sum_14 (9) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_10) then
                   sum_14 (10) <= '1';      
               end if;               
               if (PIXEL_14 > PIXEL_11) then
                   sum_14 (11) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_12) then
                   sum_14 (12) <= '1';      
               end if;                    
               if (PIXEL_14 > PIXEL_13) then
                   sum_14 (13) <= '1';      
               end if;                    
               if (PIXEL_14 >= PIXEL_15) then
                   sum_14 (14) <= '1';      
               end if; 
             when x"0F" =>
             sum_14 <= count_ones(sum_14);
               if (PIXEL_15 > PIXEL_0) then
                   sum_15 (0) <= '1';
               end if;
               if (PIXEL_15 > PIXEL_1) then  
                   sum_15 (1) <= '1';          
               end if;                    
               if (PIXEL_15 > PIXEL_2) then
                   sum_15 (2) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_3) then
                   sum_15 (3) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_4) then
                   sum_15 (4) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_5) then
                   sum_15 (5) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_6) then
                   sum_15 (6) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_7) then
                   sum_15 (7) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_8) then
                   sum_15 (8) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_9) then
                   sum_15 (9) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_10) then
                   sum_15 (10) <= '1';      
               end if;               
               if (PIXEL_15 > PIXEL_11) then
                   sum_15 (11) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_12) then
                   sum_15 (12) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_13) then
                   sum_15 (13) <= '1';      
               end if;                    
               if (PIXEL_15 > PIXEL_14) then
                   sum_15 (14) <= '1';      
               end if; 
               
            when x"10" =>
                sum_15 <= count_ones(sum_15);
                
                Global_state <= ADD;
                tick <= (others => '0');
                
            when others =>    
                
            end case; 
        
           when ADD =>
           tick <= tick + 1;
           
           case tick is
           
           when x"00" =>
            if (sum_0 = selected_position_reg) 
            then
                result <= result + pixel_0; 
            end if;
            
            when x"01" =>
            if (sum_1 = selected_position_reg) 
            then
                result <= result + pixel_1; 
            end if;
            
            when x"02" =>
            if (sum_2 = selected_position_reg) 
            then
                result <= result + pixel_2; 
            end if;
            
            when x"03" =>
            if (sum_3 = selected_position_reg) 
            then
                result <= result + pixel_3; 
            end if;
           when x"04" =>
           if (sum_4 = selected_position_reg) 
           then
               result <= result + pixel_4; 
           end if;
           
           when x"05" =>
           if (sum_5 = selected_position_reg) 
           then
               result <= result + pixel_5; 
           end if;
           
           when x"06" =>
           if (sum_6 = selected_position_reg) 
           then
               result <= result + pixel_6; 
           end if;
           
           when x"07" =>
           if (sum_7 = selected_position_reg) 
           then
               result <= result + pixel_7; 
           end if;
           when x"08" =>
           if (sum_8 = selected_position_reg) 
           then
               result <= result + pixel_8; 
           end if;
           
           when x"09" =>
           if (sum_9 = selected_position_reg) 
           then
               result <= result + pixel_9; 
           end if;
           
           when x"0a" =>
           if (sum_10 = selected_position_reg) 
           then
               result <= result + pixel_10; 
           end if;
           
           when x"0b" =>
           if (sum_11 = selected_position_reg) 
           then
               result <= result + pixel_11; 
           end if;
           when x"0c" =>
           if (sum_12 = selected_position_reg) 
           then
               result <= result + pixel_12; 
           end if;
           
           when x"0d" =>
           if (sum_13 = selected_position_reg) 
           then
               result <= result + pixel_13; 
           end if;
           
           when x"0e" =>
           if (sum_14 = selected_position_reg) 
           then
               result <= result + pixel_14; 
           end if;
           
           when x"0f" =>
           if (sum_15 = selected_position_reg) 
           then
               result <= result + pixel_15; 
           end if;
                                     
          when x"10" =>
            if (cnt_blocks >= 7) then
                      Global_state <= READY;
                      else    
                      cnt_blocks <= cnt_blocks + 1;
                      Global_state <= READ_PIXELS;
                      end if; 
          
          
           when others =>
           end case;
           
           
           
                
           when READY =>
           
           ap_done <= '1';
           DRIFT_Out <= result(18 downto 3);
           
           Global_state<= IDLE;
            
                 
            when others =>
                 
                 Global_state <= IDLE;        
           end case;            
        
    end if;
    
    end if;
    
    end process;
  
  
   
    
    end Behavioral;
    
 
    
    
