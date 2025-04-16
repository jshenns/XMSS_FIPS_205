library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wrapper_fifo_mux is
  Port ( 
        
        clock : in std_logic;
        reset : in std_logic;
        
        -- acclerator input
        din_accelerator   : in std_logic_vector(255 downto 0);
        wr_en_accelerator : in std_logic;
        rd_en_accelerator : in std_logic;

        -- global input
        din_global   : in std_logic_vector(255 downto 0);
        wr_en_global : in std_logic;
        rd_en_global : in std_logic;

        -- signature fifo signals 
        din_fifo       : out std_logic_vector(255 downto 0);
        wr_en_fifo     : out std_logic;
        rd_en_fifo     : out std_logic

  );
end entity wrapper_fifo_mux;

architecture Behavioral of wrapper_fifo_mux is

begin
process(clock, reset)
begin

if reset = '1' then
    din_fifo <= (others => '0');
    wr_en_fifo <= '0';
    rd_en_fifo <= '0';


elsif rising_edge(clock) then

    
    if wr_en_accelerator = '1' or rd_en_accelerator = '1' then
        
        din_fifo   <= din_accelerator;
        wr_en_fifo <= wr_en_accelerator;
        rd_en_fifo <= rd_en_accelerator;
    
    elsif wr_en_global = '1' or rd_en_global = '1' then
        
        din_fifo <= din_global;
        wr_en_fifo <= wr_en_global;
        rd_en_fifo <= rd_en_global;
    
    else 
        din_fifo <= (others => '0');
        wr_en_fifo <= '0';
        rd_en_fifo <= '0';
    end if;
    
end if;
end process;
end Behavioral;