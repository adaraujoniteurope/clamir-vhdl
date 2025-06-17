----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 01.03.2017 17:26:41
-- design name: 
-- module name: procc_offset - behavioral
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;

entity median is

generic(
      SYS_CLK         : integer := 100_000_000; --system clock frequency in hz
      IMG_BITS        : integer := 16;    
      ADDR_BITS : integer := 12);          
  port ( 
  
      clk  : in std_logic;
      reset : in std_logic;
  
  --img_memory
      img_data_in : in std_logic_vector (IMG_BITS -1 downto 0);
      img_address_in : out std_logic_vector (ADDR_BITS-1 downto 0);
     
      img_address_out: out std_logic_vector (ADDR_BITS downto 0);
      img_data_out : out std_logic_vector (IMG_BITS -1 downto 0);
      img_web_out : out std_logic;
      
      hist_address_out: out std_logic_vector (14-1 downto 0); --bits per pixel
      hist_data_out : out std_logic_vector (12 -1 downto 0); -- number of pixels 4096
      hist_data_in : in std_logic_vector (12 -1 downto 0);
      hist_web_out : out std_logic;
       
      --metadata
       threshold :  in std_logic_vector (13 downto 0);
       median_out: out std_logic_vector (31 downto 0);
              
      --ap_ctrl_chain last block
      ap_start : in std_logic;
      ap_ready : out std_logic;  
      ap_done: out std_logic  
          
  
  );
  
  attribute dont_touch : string;
    attribute dont_touch of median : entity is "true";
end median;

architecture behavioral of median is

constant ts_span : natural := 1e8/1e4;

type tipo_global_state is (STATE_IDLE, STATE_COMPUTE_MEDIAN,STATE_LAST_PIXEL,STATE_COMPUTE_MEDIAN_CENTER, STATE_COMPUTE_MEDIAN_VALUE, STATE_METADATA, STATE_READY);
  signal global_state: tipo_global_state;
 attribute dont_touch of global_state : signal is "true";  

signal address_counter: std_logic_vector (ADDR_BITS-1 downto 0);
signal hist_address_counter: std_logic_vector (14-1 downto 0);

signal img_address_out_reg: std_logic_vector (ADDR_BITS-1 downto 0):=(others =>'0'); 
signal img_web_out_reg: std_logic:='0';

signal sys_ts_reg: std_logic_vector (31 downto 0);
signal ticks: std_logic_vector (31 downto 0);
signal sys_fn_reg: std_logic_vector (31 downto 0);

signal tick: std_logic_vector (1 downto 0);
signal sum: std_logic_vector (12 downto 0);
signal median_result: std_logic_vector (13 downto 0);
signal median_result_reg: std_logic_vector (13 downto 0);
signal median_center: std_logic_vector (11 downto 0);

attribute dont_touch of sum : signal is "true";
attribute dont_touch of median_result : signal is "true";
attribute dont_touch of median_result_reg : signal is "true";
attribute dont_touch of median_center : signal is "true";

signal threshold_reg: std_logic_vector (13 downto 0);
signal flag_done: std_logic;
signal signal_skip_sum: std_logic;



--signal frame_max_reg: std_logic_vector (15 downto 0):=(others =>'0');
signal frame_max_reg: signed (15 downto 0):=(others =>'0');
attribute dont_touch of frame_max_reg : signal is "true";  

begin

 
process (hist_data_in, global_state)
begin
if((global_state = STATE_COMPUTE_MEDIAN) or (global_state = STATE_LAST_PIXEL)) then
    hist_data_out <= hist_data_in +1;
 else
    hist_data_out <= (others =>'0');
 end if;

end process;
    

process (clk)
begin



if (clk'event and clk = '1') then

    if(reset ='1') then
    
     ap_ready <= '0';
     global_state <= STATE_IDLE;     
     img_address_in<= (others => '0');
     img_data_out <= (others => '0');
          
     img_address_out <= (others => '0' );
     img_data_out <= (others => '0' );
     img_web_out <= '0';
     hist_address_out<= (others => '0' );
     --hist_data_out <= (others => '0' );
     hist_web_out <= '0';
     tick <= (others => '0');
     sum<= (others => '0');
     hist_address_counter <= (others => '0');
      median_result <= (others => '0');
      median_result_reg <= (others => '0');
     
     address_counter<= (others => '0');
     signal_skip_sum <='0';
    else
    

        case global_state is
            
         when STATE_IDLE =>

              ap_done <=  '0';  
              ap_ready <= '1';
              img_web_out<= '0';
              hist_web_out <= '0';
              sum<= (others => '0');
              img_address_in <= (others => '0');
              address_counter <= (others => '0');
              flag_done <= '0';
              --threshold_reg<=threshold;
              threshold_reg<="00" & threshold(13 downto 2) ;
              median_result_reg <= (others => '0');
              median_result  <= (others => '0');
              if (ap_start ='1') 
                then
                   ap_ready <=  '0';
                   global_state<= STATE_COMPUTE_MEDIAN;
                   --img_address_in <= conv_std_logic_vector (0, 12);
                   --address_counter <= conv_std_logic_vector (0, 12);
                   --img_web_out<= '1';
                   img_data_out<=img_data_in;
                   img_address_out_reg <= (others => '0');
                    tick <= (others => '0');
                   frame_max_reg <= (others => '0');
                   
                 else
                      global_state <= STATE_IDLE;     
                            
              end if;
        
       
         
        
        when STATE_COMPUTE_MEDIAN =>
                    tick <= tick +1;
                    -- copiado de la imagen a siguiente bloque
                    --hist_data_out <= hist_data_in +1;
                    
                    case tick is
                    when "00" =>
                    img_address_in <=address_counter+1;
                    img_data_out<=img_data_in;
                    address_counter <=address_counter+1;
                    --img_address_out<= '0' & img_address_out_reg;
                    --img_address_out_reg <= address_counter;
                    img_address_out<= '0' & address_counter; --mnirar porque address out estaba en 12 bits en el proyecto clamir
                    img_web_out<= '1';
                    hist_web_out <='0';
                    --hist_address_out <= img_data_in (13 downto 0);
                    hist_address_out <= img_data_in (15 downto 2);
                    
                    when "01" =>
                    img_web_out<= '0';
                    hist_web_out <='1';
                     tick <= "00";
                    when "10" =>
                    when "11" =>
                    when others =>
                    end case;
                    

                    --frame max
                    if (frame_max_reg > signed(img_data_in))
                    then
                        frame_max_reg <= frame_max_reg;
                    else
                        frame_max_reg  <= signed(img_data_in);
                    end if;
                    
                    if (address_counter = 4095)
                    then
                         global_state<= STATE_LAST_PIXEL;
                    else
                       global_state<= STATE_COMPUTE_MEDIAN;
                    end if;
                
                when STATE_LAST_PIXEL =>
                tick <= tick +1;
                case tick is
                 when "00" =>
                      
                      img_data_out<=img_data_in;
                      img_web_out<= '1';
                      img_address_out<= '0' & address_counter; --mnirar porque address out estaba en 12 bits en el proyecto clamir
                      hist_address_out <= img_data_in (15 downto 2);
                      hist_web_out <='0';
                      when "01" =>
                        img_web_out<= '0';
                        hist_web_out <='1';
                        hist_address_counter  <=(others => '0');
                        
                        when "10" =>
                        hist_web_out <='0';
                        hist_address_out <=(others => '0');
                        
                        hist_address_counter  <= conv_std_logic_vector(1,14);
                        when "11" =>
                         global_state<= STATE_COMPUTE_MEDIAN_CENTER;
                         tick <= "00";
                         median_center<=(others => '0');
                         signal_skip_sum <= '1';
                         --hist_address_counter <= hist_address_counter+1;
                         hist_web_out <='1';
                         --hist_address_out <= hist_address_counter; 
                        when others =>
                        end case;
                 
                 when STATE_COMPUTE_MEDIAN_CENTER =>
                     --tick <= tick +1;
                     case tick is
                     when "00" =>
                      img_web_out<= '0';
                       global_state<= STATE_COMPUTE_MEDIAN_CENTER;
                       hist_address_counter <= hist_address_counter+1;
                       hist_web_out <='1';
                       hist_address_out <= hist_address_counter;
                       
                       if (signal_skip_sum = '0') then
                            sum <= sum +  hist_data_in;
                       else
                            signal_skip_sum <= '0';
                       end if;     
                       if (hist_address_counter >= threshold_reg)
                       then
                        tick <= tick + 1;
                       end if;
                                              
--                          hist_address_out <= hist_address_counter;
--                                              --calcular median center
--                          median_center<=(4095-hist_data_in);
                          when "01" =>
                          tick <= tick + 1;
                          sum <= '0' & hist_data_in;
                         median_center<= (conv_std_logic_vector(2048,12)-('0' & sum(11 downto 1)));
                         median_result_reg<=median_result;
                        median_result <= hist_address_counter;                                
                          when "10" =>
                          sum <= sum +  hist_data_in;
                          tick <= tick + 1;
                           --median_center<=('0' & median_center(11 downto 1));-- -1;
                            median_result_reg<=median_result;
                            median_result <= hist_address_counter;
                          
                          when "11" =>
                           global_state<= STATE_COMPUTE_MEDIAN_VALUE;
                          tick <= "00";
                          
                           when others =>
                            end case;       
                      
                 when STATE_COMPUTE_MEDIAN_VALUE =>
                       img_web_out<= '0';
                       global_state<= STATE_COMPUTE_MEDIAN_VALUE;
                       hist_address_counter <= hist_address_counter+1;
                       hist_web_out <='1';
                       hist_address_out <= hist_address_counter;
                       
                       sum <= sum +  hist_data_in;
                       if ( sum < median_center) then
                        median_result_reg<=median_result;
                        median_result <= hist_address_counter;
                       else
                         if (flag_done = '0')then   
                            ap_done <= '1';
                             median_out <= x"0000" &  std_logic_vector(median_result_reg)& "00";
                            flag_done <='1';
                         else
                            ap_done <= '0';
                         end if;      
                         end if; 
                       if (hist_address_counter >= 16383) then
                        global_state<= STATE_READY;
                        end if;
                
            
                        

                when STATE_READY =>
                
                ap_done <= '0';
                img_address_out_reg<=(others => '0');
                img_address_out<='0' & img_address_out_reg;
                address_counter<=(others => '0');
                img_data_out<=img_data_in;
                img_web_out<= '0';
                global_state<= STATE_IDLE;
                 
                      
                 when others =>
                      
                      global_state <= STATE_IDLE;        
                end case;            
        
    end if;
    
    end if;
    
    end process;
    
    
    end behavioral;
    
    
    
    
