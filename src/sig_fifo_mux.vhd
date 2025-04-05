library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sig_fifo_mux is
  Port ( 
        
        clock : in std_logic;
        reset : in std_logic;
        
        -- pk from sig input
        din_xmss_pk_from_sig   : in std_logic_vector(255 downto 0);
        wr_en_xmss_pk_from_sig : in std_logic;
        rd_en_xmss_pk_from_sig : in std_logic;

        -- xmss sig input 
        din_xmss_sig   : in std_logic_vector(255 downto 0);
        wr_en_xmss_sig : in std_logic;
        rd_en_xmss_sig : in std_logic;

        -- global input
        din_global   : in std_logic_vector(255 downto 0);
        wr_en_global : in std_logic;
        rd_en_global : in std_logic;

        -- signature fifo signals 
        din_fifo       : out std_logic_vector(255 downto 0);
        wr_en_fifo     : out std_logic;
        rd_en_fifo     : out std_logic

  );
end entity sig_fifo_mux;

architecture Behavioral of sig_fifo_mux is

begin
process(clock, reset)
begin

if reset = '1' then
    din_fifo <= (others => '0');
    wr_en_fifo <= '0';
    rd_en_fifo <= '0';


elsif rising_edge(clock) then

    
    if wr_en_xmss_pk_from_sig = '1' or rd_en_xmss_pk_from_sig = '1' then
        
        din_fifo   <= din_xmss_pk_from_sig;
        wr_en_fifo <= wr_en_xmss_pk_from_sig;
        rd_en_fifo <= rd_en_xmss_pk_from_sig;

        
    elsif wr_en_xmss_sig = '1' or rd_en_xmss_sig = '1' then
        
        din_fifo   <= din_xmss_sig;
        wr_en_fifo <= wr_en_xmss_sig;
        rd_en_fifo <= rd_en_xmss_sig;

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