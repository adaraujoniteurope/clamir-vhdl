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

entity procc_BPC is

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
      IMG_Address : out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
      IMG_out_web : out STD_LOGIC;
      BPC_Data_In :  in STD_LOGIC_VECTOR (15 downto 0);
      BPC_Adress :  out STD_LOGIC_VECTOR (7 downto 0);
      IMG_dump_address: out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
      IMG_dump_Data_Out : out STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      IMG_out_dump_web : out STD_LOGIC;
            
      BPC_enable: in std_logic;
      BPC_identifier: in std_logic;
      
      --ap_ctrl_chain last block
      ap_start : in STD_logic;
      ap_ready : out STD_logic;  
      ap_idle: out STD_logic;  
          
      --configuration registers    
      ENA: in std_logic
  
  );
  
  attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of procc_BPC : entity is "true";
end procc_BPC;

architecture Behavioral of procc_BPC is

type TIPO_GLOBAL_STATE is (IDLE,GENERATE_ADDRESS, READ_PIXELS,MEDIAN, WRITE_PIXELS, MEMORY_DUMP, READY);
  signal GLOBAL_STATE: TIPO_GLOBAL_STATE;
 attribute dont_touch of GLOBAL_STATE : signal is "true";  
  

-- 20|21|22
-- 10|11|12
-- 00|01|02

signal PIXEL00: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL00 : signal is "true"; 
signal PIXEL01: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL01 : signal is "true"; 
signal PIXEL02: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL02 : signal is "true"; 
signal PIXEL10: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL10 : signal is "true"; 
signal PIXEL11: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL11 : signal is "true"; 
signal PIXEL12: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL12 : signal is "true"; 
signal PIXEL20: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL20 : signal is "true"; 
signal PIXEL21: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL21 : signal is "true"; 
signal PIXEL22: std_logic_vector (15 downto 0);
 attribute dont_touch of PIXEL22 : signal is "true"; 

signal column0: std_logic_vector (5 downto 0);
 attribute dont_touch of column0 : signal is "true";  
signal column1: std_logic_vector (5 downto 0); 
 attribute dont_touch of column1 : signal is "true";  
signal column2: std_logic_vector (5 downto 0); 
 attribute dont_touch of column2 : signal is "true";  
signal row0: std_logic_vector (5 downto 0);  
 attribute dont_touch of row0 : signal is "true";  
signal row1: std_logic_vector (5 downto 0);  
 attribute dont_touch of row1 : signal is "true";  
signal row2: std_logic_vector (5 downto 0); 
 attribute dont_touch of row2 : signal is "true";  

signal tick: std_logic_vector (3 downto 0);
 attribute dont_touch of tick : signal is "true";  

signal p00_addr: std_logic_vector (11 downto 0);
signal p01_addr: std_logic_vector (11 downto 0);
signal p02_addr: std_logic_vector (11 downto 0);
signal p10_addr: std_logic_vector (11 downto 0);
signal p11_addr: std_logic_vector (11 downto 0);
signal p12_addr: std_logic_vector (11 downto 0);
signal p20_addr: std_logic_vector (11 downto 0);
signal p21_addr: std_logic_vector (11 downto 0);
signal p22_addr: std_logic_vector (11 downto 0);

signal BPC_Adress_reg: std_logic_vector (7 downto 0);
signal Address_counter: std_logic_vector (ADDR_bits-1 downto 0);

signal IMG_dump_Address_reg: std_logic_vector (ADDR_bits-1 downto 0):=(others =>'0'); 
signal IMG_out_dump_web_reg: std_logic:='0';

begin

--Address_in<=Address_signal(ADDR_bits-1 downto 0);


process (CLK)
begin


IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') then
    
     ap_ready <= '0';
     ap_idle <=  '0';
     Global_state <= IDLE;     
     IMG_Address<= (others => '0');
     IMG_Data_Out <= (others => '0');
     PIXEL00 <=(others => '0');
     PIXEL01 <=(others => '0');
     PIXEL02 <=(others => '0');
     PIXEL10 <=(others => '0');
     PIXEL11 <=(others => '0');
     PIXEL12 <=(others => '0');
     PIXEL20 <=(others => '0');
     PIXEL21 <=(others => '0');
     PIXEL22 <=(others => '0');
     
     p00_addr <=(others => '0');
     p01_addr <= (others => '0');
     p02_addr <= (others => '0');
     p10_addr <= (others => '0');
     p11_addr <= (others => '0');
     p12_addr <= (others => '0');
     p20_addr <= (others => '0');
     p21_addr <= (others => '0');
     p22_addr <= (others => '0');

     column0 <= (others => '0');
     column1 <= (others => '0');
     column2 <= (others => '0');
     row0 <=(others => '0');
     row1 <= (others => '0');
     row2 <=(others => '0');             
                 
     BPC_Adress_reg<= (others => '0');
     BPC_Adress<= (others => '0');
     tick <= (others => '0');
     
     IMG_dump_address <= (others => '0' );
     IMG_dump_data_out <= (others => '0' );
     IMG_out_web <= '0';
     
     Address_counter<= (others => '0');
    else
    
--  Address_out<=Address_signal_reg(ADDR_bits-1 downto 0);
        case Global_state is
            
         when IDLE =>

              ap_idle <=  '1';  
              ap_ready <= '0';
              BPC_Adress<= BPC_Adress_reg;
              IMG_out_dump_web<= '0';
              tick<=(others =>'0');
              if (ENA = '1')
              then
                  if (ap_start ='1') 
                  then
                       ap_idle <=  '0';
                       if (BPC_enable ='0') then
                            Global_state<= MEMORY_DUMP;
                            IMG_Address <= (others => '0');
                            Address_counter <= (others => '0');
                       else
                            Global_state <= GENERATE_ADDRESS;     
                       end if;
                  end if;
              else
              
              end if;
        
       
         when GENERATE_ADDRESS =>
                   
               -- 20|21|22
               -- 10|11|12
               -- 00|01|02
               tick <= tick + 1;
                   case tick is
                   
                    when x"0" =>   
                       
                    when x"1" =>
                    if(BPC_Data_In(15 downto 14) = "11")
                    then
                        BPC_Adress_reg<= BPC_Adress_reg +1;
                        BPC_Adress<= BPC_Adress_reg +1;
                        if (BPC_Adress_reg >= 127) then
                           Global_state<= MEMORY_DUMP;
                           BPC_Adress_reg<= (others => '0');
                           IMG_Address <= (others => '0');
                           Address_counter <= (others => '0');
                        else    
                           Global_state<= GENERATE_ADDRESS; 
                           tick <=(others=>'0');
                        end if;   
                    else 
                    
                    --standard_case
                    -- 20|21|22
                    -- 10|11|12
                    -- 00|01|02
                    
                   column0 <= BPC_Data_In (5 downto 0)-1;
                   column1 <= BPC_Data_In (5 downto 0);
                   column2 <= BPC_Data_In (5 downto 0)+1;
                   row0 <= BPC_Data_In (13 downto 8)-1;
                   row1 <= BPC_Data_In (13 downto 8);
                   row2 <= BPC_Data_In (13 downto 8)+1;
                   end if;
                   
                   when x"2" =>
                   
                   if (column1 = 0) then --left border
                      if (row1 = 0) then -- topleft corner
                          p00_addr <= row2 & column2;
                          p01_addr <= row2 & column1;
                          p02_addr <= row1 & column2;
                          p10_addr <= row1 & column2;
                          p11_addr <= row1 & column1;
                          p12_addr <= row1 & column2;
                          p20_addr <= row2 & column1;
                          p21_addr <= row2 & column1;
                          p22_addr <= row2 & column2;
                      elsif(row1 = 63) then -- botleft corner
                          p00_addr <= row0 & column1;
                          p01_addr <= row0 & column1;
                          p02_addr <= row0 & column2;
                          p10_addr <= row1 & column2;
                          p11_addr <= row1 & column1;
                          p12_addr <= row1 & column2;
                          p20_addr <= row0 & column2;
                          p21_addr <= row0 & column1;
                          p22_addr <= row1 & column2;
                      else
                          p00_addr <= row0 & column1;
                          p01_addr <= row0 & column1;
                          p02_addr <= row0 & column2;
                          p10_addr <= row1 & column2;
                          p11_addr <= row1 & column1;
                          p12_addr <= row1 & column2;
                          p20_addr <= row2 & column1;
                          p21_addr <= row2 & column1;
                          p22_addr <= row2 & column2;
                      
                      end if;
                   elsif (column1 = 63) then --left border
                       if (row1 = 0) then -- topright corner
                          p00_addr <= row1 & column0;
                          p01_addr <= row2 & column1;
                          p02_addr <= row2 & column0;
                          p10_addr <= row1 & column0;
                          p11_addr <= row1 & column1;
                          p12_addr <= row1 & column0;
                          p20_addr <= row2 & column0;
                          p21_addr <= row2 & column1;
                          p22_addr <= row2 & column1;
                       elsif(row1 = 63) then -- botright corner
                          p00_addr <= row0 & column0;
                          p01_addr <= row0 & column1;
                          p02_addr <= row0 & column1;
                          p10_addr <= row1 & column0;
                          p11_addr <= row1 & column1;
                          p12_addr <= row1 & column0;
                          p20_addr <= row1 & column0;
                          p21_addr <= row0 & column1;
                          p22_addr <= row0 & column0;
                       else
                          p00_addr <= row0 & column0;
                          p01_addr <= row0 & column1;
                          p02_addr <= row0 & column1;
                          p10_addr <= row1 & column0;
                          p11_addr <= row1 & column1;
                          p12_addr <= row1 & column0;
                          p20_addr <= row2 & column0;
                          p21_addr <= row2 & column1;
                          p22_addr <= row2 & column1;
                       
                       end if;  
                   elsif (row1 = 0) then --left border
                                       
                      p00_addr <= row1 & column0;
                      p01_addr <= row2 & column1;
                      p02_addr <= row1 & column2;
                      p10_addr <= row1 & column0;
                      p11_addr <= row1 & column1;
                      p12_addr <= row1 & column2;
                      p20_addr <= row2 & column0;
                      p21_addr <= row2 & column1;
                      p22_addr <= row2 & column2;
                               
                   elsif (row1 = 63) then --left border
                                                               
                      p00_addr <= row0 & column0;
                      p01_addr <= row0 & column1;
                      p02_addr <= row0 & column2;
                      p10_addr <= row1 & column0;
                      p11_addr <= row1 & column1;
                      p12_addr <= row1 & column2;
                      p20_addr <= row1 & column0;
                      p21_addr <= row0 & column1;
                      p22_addr <= row1 & column2;                    
                                           
                       
                   else   
                   --standard case
                   p00_addr <= row0 & column0;
                   p01_addr <= row0 & column1;
                   p02_addr <= row0 & column2;
                   p10_addr <= row1 & column0;
                   p11_addr <= row1 & column1;
                   p12_addr <= row1 & column2;
                   p20_addr <= row2 & column0;
                   p21_addr <= row2 & column1;
                   p22_addr <= row2 & column2;
                   end if;
                          
                    when x"3" =>
                       IMG_Address <= p00_addr;
                   when x"4" =>
                       tick<=(others =>'0');
                       Global_state <= READ_PIXELS;
                       IMG_Address <= p01_addr;
                   
                   when others =>
                   
                   
                   end case; 
        when READ_PIXELS =>
        
        --memory organization
        --CLAMIR has 1 pixel per address memory organization
               
        tick <= tick + 1;
        case tick is
            
            when x"0" =>
                PIXEL00<=IMG_DATA_in;
                IMG_Address <= p02_addr;
            when x"1" =>
                PIXEL01<=IMG_DATA_in;
                IMG_Address <= p10_addr;
            when x"2" =>
                PIXEL02<=IMG_DATA_in;
                IMG_Address <= p11_addr;
            when x"3" =>
               PIXEL10<=IMG_DATA_in;
               IMG_Address <= p12_addr;
            when x"4" =>
               PIXEL11<=IMG_DATA_in;
               IMG_Address <= p20_addr;
            when x"5" =>
               PIXEL12<=IMG_DATA_in;
               IMG_Address <= p21_addr;
            when x"6" =>
                PIXEL20<=IMG_DATA_in;
                IMG_Address <= p22_addr;
            when x"7" =>
                PIXEL21<=IMG_DATA_in;
                IMG_Address <= p11_addr;    
            when x"8" =>
                PIXEL22<=IMG_DATA_in;
                                             
            when x"A" =>    
                Global_state <= MEDIAN;   
                        tick<=(others=>'0');
            when others =>
            
            end case;                                                                                                                                                                 
          
                  
        when MEDIAN =>
        tick <= tick + 1;
        
        --frist tick
        case tick is
        
        when x"0" =>
            if(PIXEL00>PIXEL10)
            then
                PIXEL00<=PIXEL10;
                PIXEL10<=PIXEL00;
            end if;
                    
            
            if(PIXEL01>PIXEL11)
              then
                  PIXEL01<=PIXEL11;
                  PIXEL11<=PIXEL01;
              end if;
            
        if(PIXEL02>PIXEL12)
              then
                  PIXEL02<=PIXEL12;
                  PIXEL12<=PIXEL02;
              end if;
            
            --second tick
        when x"1" =>
         if(PIXEL10>PIXEL20)
            then
                PIXEL10<=PIXEL20;
                PIXEL20<=PIXEL10;
            end if; 
         
         if(PIXEL11>PIXEL21)
            then
                PIXEL11<=PIXEL21;
                PIXEL21<=PIXEL11;
            end if; 
                        
         if(PIXEL12>PIXEL22)
            then
                PIXEL12<=PIXEL22;
                PIXEL22<=PIXEL12;
            end if;                   
            
       --third tick
       when x"2" =>
                        
            if(PIXEL00>PIXEL10)
                then
                    PIXEL00<=PIXEL10;
                    PIXEL10<=PIXEL00;
                end if; 
                
            if(PIXEL01>PIXEL11)
               then
                   PIXEL01<=PIXEL11;
                   PIXEL11<=PIXEL01;
               end if;     
             
             if(PIXEL02>PIXEL12)
                then
                    PIXEL02<=PIXEL12;
                    PIXEL12<=PIXEL02;
                end if; 
        when x"3" =>
           if(PIXEL00>PIXEL01)
           then
               PIXEL00<=PIXEL01;
               PIXEL01<=PIXEL00;
           end if;
                   
           
           if(PIXEL10>PIXEL11)
             then
                 PIXEL10<=PIXEL11;
                 PIXEL11<=PIXEL10;
             end if;
           
           if(PIXEL20>PIXEL21)
             then
                 PIXEL20<=PIXEL21;
                 PIXEL21<=PIXEL20;
             end if;
           
           --second tick
        when x"4" =>
             if(PIXEL01>PIXEL02)
                then
                    PIXEL01<=PIXEL02;
                    PIXEL02<=PIXEL01;
                end if; 
             
             if(PIXEL11>PIXEL12)
                then
                    PIXEL11<=PIXEL12;
                    PIXEL12<=PIXEL11;
                end if; 
                            
             if(PIXEL21>PIXEL22)
                then
                    PIXEL21<=PIXEL22;
                    PIXEL22<=PIXEL21;
                end if;                   
                
           --third tick
        when x"5" =>
           
           
           if(PIXEL00>PIXEL01)
               then
                   PIXEL00<=PIXEL01;
                   PIXEL01<=PIXEL00;
               end if; 
               
           if(PIXEL10>PIXEL11)
              then
                  PIXEL10<=PIXEL11;
                  PIXEL11<=PIXEL10;
              end if;     
            
            if(PIXEL20>PIXEL21)
               then
                   PIXEL20<=PIXEL21;
                   PIXEL21<=PIXEL20;
               end if;   
           
         when x"6" =>
            if(PIXEL02>PIXEL11)
            then
                PIXEL02<=PIXEL11;
                PIXEL11<=PIXEL02;
            end if;
                     
                           
            --second tick
         when x"7" =>
             if(PIXEL11>PIXEL20)
                then
                    PIXEL11<=PIXEL20;
                    PIXEL20<=PIXEL11;
                end if; 
             
           --third tick
         when x"8" =>
           
            tick<=(others =>'0');
            Global_state<= WRITE_PIXELS;
            IMG_DATA_out<=IMG_DATA_in;
            if(PIXEL02>PIXEL11)
               then
                   PIXEL02<=PIXEL11;
                   PIXEL11<=PIXEL02;
               end if; 
               when others =>
          
        end case;       
        
        when WRITE_PIXELS =>
        
        tick <= tick + 1;
                
                --frist tick
        case tick is
        
        when x"0" =>
        

      if (BPC_identifier = '0') then  
        IMG_DATA_out <= PIXEL11;
      else
        IMG_DATA_out <= '1' & not(BPC_Adress_reg( 6 downto 0)) & x"ff" ;
      end if;      
        
        when x"1" =>
        IMG_out_web<= '1';
        when x"2" =>
        IMG_out_web<= '0';
        BPC_Adress_reg<= BPC_Adress_reg +1;
        BPC_Adress<= BPC_Adress_reg +1;
            if (BPC_Adress_reg >= 127) then
               Global_state<= MEMORY_DUMP;
               BPC_Adress_reg<= (others => '0');
               IMG_Address <= (others => '0');
               IMG_dump_Address_reg<=(others =>'0');
               Address_counter <= (others => '0');
               IMG_out_dump_web_reg<='0';
               
            else    
               Global_state<= GENERATE_ADDRESS; 
               tick <=(others=>'0');
            end if; 
            
        when others=>    
        
        end case;     
        
        when MEMORY_DUMP =>
                    
                    IMG_Address <=Address_counter+1;
                    IMG_dump_Data_Out<=IMG_data_in;
                    Address_counter <=Address_counter+1;
                    IMG_dump_Address<=IMG_dump_Address_reg;
                    IMG_dump_Address_reg <= Address_counter;
                    IMG_out_dump_web<= IMG_out_dump_web_reg;
                    IMG_out_dump_web_reg<= '1';
                    
                    if (Address_counter = 4095)
                    then
                         Global_state<= READY;
                    else
                       Global_state<= MEMORY_DUMP;
                    end if;
                
                when READY =>
                
                ap_ready <= '1';
                IMG_dump_Address_reg<=(others => '0');
                IMG_dump_Address<=IMG_dump_Address_reg;
                IMG_dump_Data_Out<=IMG_data_in;
                IMG_out_dump_web_reg<= '0';
                Global_state<= IDLE;
                 
                      
                 when others =>
                      
                      Global_state <= IDLE;        
                end case;            
        
    end if;
    
    end if;
    
    end process;
    
    
    end Behavioral;
    
    
    
    
