library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xmss_node_mux is
  Port ( 
        
        clock : in std_logic;
        reset : in std_logic;
        
        -- key_gen_inputs
        secret_seed_key_gen   : in std_logic_vector(255 downto 0);
        target_height_key_gen : in std_logic_vector(15 downto 0);
        target_index_key_gen  : in std_logic_vector(15 downto 0);
        valid_in_key_gen      : in std_logic;
    
        -- xmss_sign inputs
        secret_seed_xmss_sign   : in std_logic_vector(255 downto 0);
        target_height_xmss_sign : in std_logic_vector(15 downto 0);
        target_index_xmss_sign  : in std_logic_vector(15 downto 0);
        valid_in_xmss_sign      : in std_logic;
        
                
        -- outputs
        secret_seed : out std_logic_vector(255 downto 0);
        target_height : out std_logic_vector(15 downto 0);
        target_index  : out std_logic_vector(15 downto 0);
        valid_in     : out std_logic      

  );
end entity xmss_node_mux;

architecture Behavioral of xmss_node_mux is

begin
process(clock, reset)
begin

if reset = '1' then
    secret_seed <= (others => '0');
    target_height <= (others => '0');
    target_index <= (others => '0');
    valid_in <= '0';


elsif rising_edge(clock) then

    
    if valid_in_key_gen = '1' then
        
        --hash_reset         <= hash_reset_xmss_node;
        secret_seed <= secret_seed_key_gen;
        target_height <= target_height_key_gen;
        target_index <= target_index_key_gen;
        valid_in <= '1';
    

        
    elsif valid_in_xmss_sign = '1' then 
        secret_seed <= secret_seed_xmss_sign;
        target_height <= target_height_xmss_sign;
        target_index <= target_index_xmss_sign;
        valid_in <= '1';
        
    else 
        secret_seed <= (others => '0');
        target_height <= (others => '0');
        target_index <= (others => '0');
        valid_in <= '0';
    end if;
    
end if;
end process;


end Behavioral;
