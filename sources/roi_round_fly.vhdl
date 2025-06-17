----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 20.02.2017 18:37:46
-- design name: 
-- module name: adc_temp_vu - behavioral
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

entity roi_round_fly is

port (
  --sys
      clk  : in std_logic;
      reset : in std_logic;
      
      address_in: in std_logic_vector (11 downto 0);
      data_in: in std_logic_vector(15 downto 0);
      write_in: in std_logic;
      
      
      --roi
      enable_roi: in std_logic;
      x1: in std_logic_vector (5 downto 0);
      x2: in std_logic_vector (5 downto 0);
      y1: in std_logic_vector (5 downto 0);
      y2: in std_logic_vector (5 downto 0);
      round: in std_logic_vector (1 downto 0);
      
      address_out: out std_logic_vector (11 downto 0);
      data_out: out std_logic_vector(15 downto 0);
      write_out: out std_logic;
      
      ap_start: in std_logic;
      ap_ready: out std_logic
                
     );
end roi_round_fly;

architecture behavioral of roi_round_fly is

signal data_in_reg: std_logic_vector (15 downto 0);
signal flag: std_logic:='0';

--segnales auxiliaes

signal x1p1: std_logic_vector (5 downto 0);
signal x1p2: std_logic_vector (5 downto 0);
signal x1p3: std_logic_vector (5 downto 0);
signal x1p4: std_logic_vector (5 downto 0);
signal x1p5: std_logic_vector (5 downto 0);
signal x1p6: std_logic_vector (5 downto 0);
signal x1p7: std_logic_vector (5 downto 0);
signal x1p8: std_logic_vector (5 downto 0);
signal x1p9: std_logic_vector (5 downto 0);
signal x1p10: std_logic_vector (5 downto 0);
signal x1p11: std_logic_vector (5 downto 0);

signal x2m1: std_logic_vector (5 downto 0);
signal x2m2: std_logic_vector (5 downto 0);
signal x2m3: std_logic_vector (5 downto 0);
signal x2m4: std_logic_vector (5 downto 0);
signal x2m5: std_logic_vector (5 downto 0);
signal x2m6: std_logic_vector (5 downto 0);
signal x2m7: std_logic_vector (5 downto 0);
signal x2m8: std_logic_vector (5 downto 0);
signal x2m9: std_logic_vector (5 downto 0);
signal x2m10: std_logic_vector (5 downto 0);
signal x2m11: std_logic_vector (5 downto 0);


signal y1p1: std_logic_vector (5 downto 0);
signal y1p2: std_logic_vector (5 downto 0);
signal y1p3: std_logic_vector (5 downto 0);
signal y1p4: std_logic_vector (5 downto 0);
signal y1p5: std_logic_vector (5 downto 0);
signal y1p6: std_logic_vector (5 downto 0);
signal y1p7: std_logic_vector (5 downto 0);
signal y1p8: std_logic_vector (5 downto 0);
signal y1p9: std_logic_vector (5 downto 0);
signal y1p10: std_logic_vector (5 downto 0);
signal y1p11: std_logic_vector (5 downto 0);


signal y2m1: std_logic_vector (5 downto 0);
signal y2m2: std_logic_vector (5 downto 0);
signal y2m3: std_logic_vector (5 downto 0);
signal y2m4: std_logic_vector (5 downto 0);
signal y2m5: std_logic_vector (5 downto 0);
signal y2m6: std_logic_vector (5 downto 0);
signal y2m7: std_logic_vector (5 downto 0);
signal y2m8: std_logic_vector (5 downto 0);
signal y2m9: std_logic_vector (5 downto 0);
signal y2m10: std_logic_vector (5 downto 0);
signal y2m11: std_logic_vector (5 downto 0);



begin



process (clk)
begin

if (clk'event and clk = '1') 
then
    if(reset ='1') 
    then
    address_out <= (others =>'0');
    data_out  <= (others =>'0');
    write_out <= '0'; 
    data_in_reg <= (others =>'0');      
    else
    
    if (write_in = '0') then
    
    x1p1 <= x1 + 1;
    x1p2 <= x1 + 2;
    x1p3 <= x1 + 3;
    x1p4 <= x1 + 4;
    x1p5 <= x1 + 5;
    x1p6 <= x1 + 6;
    x1p7 <= x1 + 7;
    x1p8 <= x1 + 8;
    x1p9 <= x1 + 9;
    x1p10 <= x1 + 10;
    x1p11 <= x1 + 11;
    
    y1p1 <= y1 + 1;
    y1p2 <= y1 + 2;
    y1p3 <= y1 + 3;
    y1p4 <= y1 + 4;
    y1p5 <= y1 + 5;
    y1p6 <= y1 + 6;
    y1p7 <= y1 + 7;
    y1p8 <= y1 + 8;
    y1p9 <= y1 + 9;
    y1p10 <= y1 + 10;
    y1p11 <= y1 + 11;
        
    x2m1 <= x2 - 1;
    x2m2 <= x2 - 2;
    x2m3 <= x2 - 3;
    x2m4 <= x2 - 4;
    x2m5 <= x2 - 5;
    x2m6 <= x2 - 6;
    x2m7 <= x2 - 7;
    x2m8 <= x2 - 8;
    x2m9 <= x2 - 9;
    x2m10 <= x2 - 10;
    x2m11 <= x2 - 11;
        
    
    y2m1 <= y2 - 1;
    y2m2 <= y2 - 2;
    y2m3 <= y2 - 3;
    y2m4 <= y2 - 4;
    y2m5 <= y2 - 5;
    y2m6 <= y2 - 6;
    y2m7 <= y2 - 7;
    y2m8 <= y2 - 8;
    y2m9 <= y2 - 9;
    y2m10 <= y2 - 10;
    y2m11 <= y2 - 11;
        
    
    end if;
    
    
    ap_ready <= ap_start;
    address_out<= address_in;
    write_out <= write_in;  
    
    --condiciones roi
    
    
    
    if (enable_roi = '0') then
        data_out <=  data_in;
    else
    
    if ((address_in (5 downto 0)>x1) and (address_in (5 downto 0)<x2) and (address_in (11 downto 6)>y1) and (address_in (11 downto 6)<y2)) 
   -- if ((address_in (5 downto 0)>=x1) and (address_in (5 downto 0)<x2) and (address_in (11 downto 6)>=y1) and (address_in (11 downto 6)<y2))
    then 
      data_out <=  data_in;
    else
      data_out <=  (others => '0');
    end if;
    
    if (round = "01") then
    
     if(((address_in (5 downto 0)=x1p1) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p5)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m5))))
              or
              ((address_in (5 downto 0)=x2m1) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p5)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m5))))
              or
              ((address_in (5 downto 0)=x1p2) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3))or ((address_in (11 downto 6)<=y2m1)and (address_in (11 downto 6)>=y2m3))))
              or
              ((address_in (5 downto 0)=x2m2) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3))or ((address_in (11 downto 6)<=y2m1)and (address_in (11 downto 6)>=y2m3))))
              or
              ((address_in (5 downto 0)=x1p3) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
              or
              ((address_in (5 downto 0)=x2m3) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
              or
              ((address_in (5 downto 0)=x1p4) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
              or
              ((address_in (5 downto 0)=x2m4) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
              or
              ((address_in (5 downto 0)=x1p5) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
              or
              ((address_in (5 downto 0)=x2m5) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))              
              )
              then
               data_out <=  (others => '0');
              end if;
    
    end if;
    
    if (round = "10") then
    
    if(     ((address_in (5 downto 0)=x1p1) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p7)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m7))))
            or
            ((address_in (5 downto 0)=x2m1) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p7)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m7))))
            or
            ((address_in (5 downto 0)=x1p2) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p5)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m5))))
            or
            ((address_in (5 downto 0)=x2m2) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p5)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m5))))
            or
            ((address_in (5 downto 0)=x1p3) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m3))))
            or
            ((address_in (5 downto 0)=x2m3) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m3))))
            or
            ((address_in (5 downto 0)=x1p4) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
            or
            ((address_in (5 downto 0)=x2m4) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
            or
            ((address_in (5 downto 0)=x1p5) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
            or
            ((address_in (5 downto 0)=x2m5) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
            or
            ((address_in (5 downto 0)=x1p6) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
            or
            ((address_in (5 downto 0)=x2m6) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
            or
            ((address_in (5 downto 0)=x1p7) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
            or
            ((address_in (5 downto 0)=x2m7) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))              
            )
            then
             data_out <=  (others => '0');
            end if;
    
    
    end if;  
    if (round = "11") then
        
        if(     ((address_in (5 downto 0)=x1p1) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p11)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m11))))
                or
                ((address_in (5 downto 0)=x2m1) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p11)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m11))))
                or
                ((address_in (5 downto 0)=x1p2) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p8)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m8))))
                or
                ((address_in (5 downto 0)=x2m2) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p8)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m8))))
                or
                ((address_in (5 downto 0)=x1p3) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p6)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m6))))
                or
                ((address_in (5 downto 0)=x2m3) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p6)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m6))))
                or
                ((address_in (5 downto 0)=x1p4) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p4)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m4))))
                or
                ((address_in (5 downto 0)=x2m4) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p4)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m4))))
                or
                ((address_in (5 downto 0)=x1p5) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m3))))
                or                            
                ((address_in (5 downto 0)=x2m5) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m3))))
                or
                ((address_in (5 downto 0)=x1p6) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m3))))
                or                            
                ((address_in (5 downto 0)=x2m6) and (((address_in (11 downto 6)>=y1p1) and (address_in (11 downto 6)<=y1p3)) or  ((address_in (11 downto 6)<=y2m1) and (address_in (11 downto 6)>=y2m3))))
                or
                ((address_in (5 downto 0)=x1p7) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
                or
                ((address_in (5 downto 0)=x2m7) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
                or
                ((address_in (5 downto 0)=x1p8) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
                or
                ((address_in (5 downto 0)=x2m8) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y1p2) or (address_in (11 downto 6)=y2m1)or (address_in (11 downto 6)=y2m2)))
                or
                ((address_in (5 downto 0)=x1p9) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
                or                           
                ((address_in (5 downto 0)=x2m9) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))   
                or
                ((address_in (5 downto 0)=x1p10) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
                or
                ((address_in (5 downto 0)=x2m10) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))   
                or
                ((address_in (5 downto 0)=x1p11) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))
                or
                ((address_in (5 downto 0)=x2m11) and ((address_in (11 downto 6)=y1p1) or (address_in (11 downto 6)=y2m1)))                
                )
                then
                 data_out <=  (others => '0');
                end if;
        
        
        end if;      
     
     
    
        
       
  end if;
  end if;
end if;

end process;

end behavioral;
