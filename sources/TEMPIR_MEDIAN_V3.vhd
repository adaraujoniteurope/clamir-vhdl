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

entity MEDIAN is

GENERIC(
      sys_clk         : INTEGER := 100_000_000; --system clock frequency in Hz
      IMG_bits        : INTEGER := 16;    
      ADDR_bits : INTEGER := 12);          
  Port ( 
  
      CLK  : in std_logic;
      RESET : in std_logic;
  
  --IMG_Memory
      IMG_Data_In : in STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      IMG_Address_in : out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
     
      IMG_address_out: out STD_LOGIC_VECTOR (ADDR_bits downto 0);
      IMG_Data_Out : out STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      IMG_web_out : out STD_LOGIC;
      
      HIST_address_out: out STD_LOGIC_VECTOR (14-1 downto 0); --bits per pixel
      HIST_Data_Out : out STD_LOGIC_VECTOR (12 -1 downto 0); -- number of pixels 4096
      HIST_Data_in : in STD_LOGIC_VECTOR (12 -1 downto 0);
      HIST_web_out : out STD_LOGIC;
       
      --Metadata
       threshold :  in STD_LOGIC_VECTOR (13 downto 0);
       Median_out: out std_logic_vector (31 downto 0);
              
      --ap_ctrl_chain last block
      ap_start : in STD_logic;
      ap_ready : out STD_logic;  
      ap_done: out STD_logic  
          
  
  );
  
  attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of MEDIAN : entity is "true";
end MEDIAN;

architecture Behavioral of MEDIAN is

constant TS_SPAN : natural := 1e8/1e4;

type TIPO_GLOBAL_STATE is (IDLE, MEDIAN,LAST_pixel,Median_center_calc, MEDIAN_VALUE, METADATA, READY);
  signal GLOBAL_STATE: TIPO_GLOBAL_STATE;
 attribute dont_touch of GLOBAL_STATE : signal is "true";  

signal Address_counter: std_logic_vector (ADDR_bits-1 downto 0);
signal HIST_Address_counter: std_logic_vector (14-1 downto 0);

signal IMG_address_out_reg: std_logic_vector (ADDR_bits-1 downto 0):=(others =>'0'); 
signal IMG_web_out_reg: std_logic:='0';

signal sys_ts_reg: std_logic_vector (31 downto 0);
signal ticks: std_logic_vector (31 downto 0);
signal sys_fn_reg: std_logic_vector (31 downto 0);

signal tick: std_logic_vector (1 downto 0);
signal sum: std_logic_vector (12 downto 0);
signal median_result: std_logic_vector (13 downto 0);
signal median_result_reg: std_logic_vector (13 downto 0);
signal median_center: std_logic_vector (11 downto 0);

attribute DONT_TOUCH of sum : signal is "true";
attribute DONT_TOUCH of median_result : signal is "true";
attribute DONT_TOUCH of median_result_reg : signal is "true";
attribute DONT_TOUCH of median_center : signal is "true";

signal threshold_reg: std_logic_vector (13 downto 0);
signal flag_done: std_logic;
signal signal_skip_sum: std_logic;



--signal Frame_max_reg: std_logic_vector (15 downto 0):=(others =>'0');
signal Frame_max_reg: signed (15 downto 0):=(others =>'0');
attribute dont_touch of Frame_max_reg : signal is "true";  

begin

 
process (HIST_data_in, Global_state)
begin
if((Global_state = MEDIAN) or (Global_state = LAST_pixel)) then
    HIST_data_out <= HIST_data_in +1;
 else
    HIST_data_out <= (others =>'0');
 end if;

end process;
    

process (CLK)
begin



IF (CLK'EVENT AND CLK = '1') THEN

    if(RESET ='1') then
    
     ap_ready <= '0';
     Global_state <= IDLE;     
     IMG_Address_in<= (others => '0');
     IMG_Data_Out <= (others => '0');
          
     IMG_address_out <= (others => '0' );
     IMG_Data_Out <= (others => '0' );
     IMG_web_out <= '0';
     HIST_address_out<= (others => '0' );
     --HIST_Data_Out <= (others => '0' );
     HIST_web_out <= '0';
     Tick <= (others => '0');
     sum<= (others => '0');
     HIST_Address_counter <= (others => '0');
      median_result <= (others => '0');
      median_result_reg <= (others => '0');
     
     Address_counter<= (others => '0');
     signal_skip_sum <='0';
    else
    

        case Global_state is
            
         when IDLE =>

              ap_done <=  '0';  
              ap_ready <= '1';
              IMG_web_out<= '0';
              HIST_web_out <= '0';
              sum<= (others => '0');
              IMG_Address_in <= (others => '0');
              Address_counter <= (others => '0');
              flag_done <= '0';
              --threshold_reg<=threshold;
              threshold_reg<="00" & threshold(13 downto 2) ;
              median_result_reg <= (others => '0');
              median_result  <= (others => '0');
              if (ap_start ='1') 
                then
                   ap_ready <=  '0';
                   Global_state<= MEDIAN;
                   --IMG_Address_in <= conv_std_logic_vector (0, 12);
                   --Address_counter <= conv_std_logic_vector (0, 12);
                   --IMG_web_out<= '1';
                   IMG_Data_Out<=IMG_data_in;
                   IMG_address_out_reg <= (others => '0');
                    Tick <= (others => '0');
                   frame_max_reg <= (others => '0');
                   
                 else
                      Global_state <= IDLE;     
                            
              end if;
        
       
         
        
        when MEDIAN =>
                    tick <= tick +1;
                    -- copiado de la imagen a siguiente bloque
                    --HIST_data_out <= HIST_data_in +1;
                    
                    case tick is
                    when "00" =>
                    IMG_Address_in <=Address_counter+1;
                    IMG_Data_Out<=IMG_data_in;
                    Address_counter <=Address_counter+1;
                    --IMG_address_out<= '0' & IMG_address_out_reg;
                    --IMG_address_out_reg <= Address_counter;
                    IMG_address_out<= '0' & Address_counter; --mnirar porque address out estaba en 12 bits en el proyecto clamir
                    IMG_web_out<= '1';
                    HIST_web_out <='0';
                    --HIST_address_out <= IMG_data_in (13 downto 0);
                    HIST_address_out <= IMG_data_in (15 downto 2);
                    
                    when "01" =>
                    IMG_web_out<= '0';
                    HIST_web_out <='1';
                     tick <= "00";
                    when "10" =>
                    when "11" =>
                    when others =>
                    end case;
                    

                    --frame max
                    if (frame_max_reg > signed(IMG_data_in))
                    then
                        frame_max_reg <= frame_max_reg;
                    else
                        frame_max_reg  <= signed(IMG_data_in);
                    end if;
                    
                    if (Address_counter = 4095)
                    then
                         Global_state<= LAST_pixel;
                    else
                       Global_state<= MEDIAN;
                    end if;
                
                when LAST_pixel =>
                tick <= tick +1;
                case tick is
                 when "00" =>
                      
                      IMG_Data_Out<=IMG_data_in;
                      IMG_web_out<= '1';
                      IMG_address_out<= '0' & Address_counter; --mnirar porque address out estaba en 12 bits en el proyecto clamir
                      HIST_address_out <= IMG_data_in (15 downto 2);
                      HIST_web_out <='0';
                      when "01" =>
                        IMG_web_out<= '0';
                        HIST_web_out <='1';
                        HIST_Address_counter  <=(others => '0');
                        
                        when "10" =>
                        HIST_web_out <='0';
                        HIST_address_out <=(others => '0');
                        
                        HIST_Address_counter  <= conv_std_logic_vector(1,14);
                        when "11" =>
                         Global_state<= Median_center_calc;
                         tick <= "00";
                         median_center<=(others => '0');
                         signal_skip_sum <= '1';
                         --HIST_Address_counter <= HIST_Address_counter+1;
                         HIST_web_out <='1';
                         --HIST_address_out <= HIST_Address_counter; 
                        when others =>
                        end case;
                 
                 when Median_center_calc =>
                     --tick <= tick +1;
                     case tick is
                     when "00" =>
                      IMG_web_out<= '0';
                       Global_state<= Median_center_calc;
                       HIST_Address_counter <= HIST_Address_counter+1;
                       HIST_web_out <='1';
                       HIST_address_out <= HIST_Address_counter;
                       
                       if (signal_skip_sum = '0') then
                            SUM <= SUM +  HIST_data_in;
                       else
                            signal_skip_sum <= '0';
                       end if;     
                       if (HIST_Address_counter >= threshold_reg)
                       then
                        tick <= tick + 1;
                       end if;
                                              
--                          HIST_address_out <= HIST_Address_counter;
--                                              --calcular median center
--                          median_center<=(4095-HIST_data_in);
                          when "01" =>
                          tick <= tick + 1;
                          SUM <= '0' & HIST_data_in;
                         median_center<= (conv_std_logic_vector(2048,12)-('0' & SUM(11 downto 1)));
                         median_result_reg<=median_result;
                        median_result <= HIST_Address_counter;                                
                          when "10" =>
                          SUM <= SUM +  HIST_data_in;
                          tick <= tick + 1;
                           --median_center<=('0' & median_center(11 downto 1));-- -1;
                            median_result_reg<=median_result;
                            median_result <= HIST_Address_counter;
                          
                          when "11" =>
                           Global_state<= MEDIAN_VALUE;
                          tick <= "00";
                          
                           when others =>
                            end case;       
                      
                 when MEDIAN_VALUE =>
                       IMG_web_out<= '0';
                       Global_state<= MEDIAN_VALUE;
                       HIST_Address_counter <= HIST_Address_counter+1;
                       HIST_web_out <='1';
                       HIST_address_out <= HIST_Address_counter;
                       
                       SUM <= SUM +  HIST_data_in;
                       if ( sum < median_center) then
                        median_result_reg<=median_result;
                        median_result <= HIST_Address_counter;
                       else
                         if (flag_done = '0')then   
                            ap_done <= '1';
                             Median_out <= x"0000" &  std_logic_vector(median_result_reg)& "00";
                            flag_done <='1';
                         else
                            ap_done <= '0';
                         end if;      
                         end if; 
                       if (HIST_address_counter >= 16383) then
                        Global_state<= READY;
                        end if;
                
            
                        

                when READY =>
                
                ap_done <= '0';
                IMG_address_out_reg<=(others => '0');
                IMG_address_out<='0' & IMG_address_out_reg;
                Address_counter<=(others => '0');
                IMG_Data_Out<=IMG_data_in;
                IMG_web_out<= '0';
                Global_state<= IDLE;
                 
                      
                 when others =>
                      
                      Global_state <= IDLE;        
                end case;            
        
    end if;
    
    end if;
    
    end process;
    
    
    end Behavioral;
    
    
    
    
