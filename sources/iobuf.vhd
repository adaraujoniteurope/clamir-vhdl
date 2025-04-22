library ieee;
    use ieee.std_logic_1164.all;
library unisim;
   use unisim.vcomponents.all;

entity iobuf is
  port (
    o                                     : out std_logic;                                -- output (from buffer)
    io                                    : inout std_logic;                              -- port pin
    i                                     : in  std_logic;                                -- inuput (to buffer)
    t                                     : in  std_logic);                               -- tristate control
end iobuf;

architecture rtl of iobuf is

begin

  --io <= i when t = '0' else 'z';
  --o <= io;
obuft_inst : obuft

    port map (
                o => io, -- buffer output (connect directly to top-level port)
                i => i, -- buffer input
                t => t -- 3-state enable input
            );
ibuf_inst : ibuf
    port map (
                o => o, -- buffer output
                i => io -- buffer input (connect directly to top-level port)
            );


end rtl;

