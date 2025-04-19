library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compression_input_mux is
    Port (
        clock : in std_logic;
        reset : in std_logic;
    
        -- wots_pkGen inputs
        s_tdata_i_wots_pkGen  : in  std_logic_vector(511 downto 0);
        s_tlast_i_wots_pkGen  : in  std_logic;                     
        s_tvalid_i_wots_pkGen : in  std_logic;     
        wots_pkGen_reset      : in  std_logic;                
        
        -- wots_pkFromSig inputs
        s_tdata_i_wots_pkFromSig  : in  std_logic_vector(511 downto 0);
        s_tlast_i_wots_pkFromSig  : in  std_logic;                     
        s_tvalid_i_wots_pkFromSig : in  std_logic;      
        wots_pkFromSig_reset      : in std_logic;               
        
        -- outputs
        s_tdata_i  : out std_logic_vector(511 downto 0);
        s_tlast_i  : out std_logic;                     
        s_tvalid_i : out std_logic;
        hash_reset : out std_logic      
    );
end compression_input_mux;

architecture Behavioral of compression_input_mux is

begin

process(clock, reset)
begin

if reset = '1' then
    s_tdata_i  <= (others => '0');
    s_tlast_i  <= '0';
    s_tvalid_i <= '0';
    hash_reset <= '1';

elsif rising_edge(clock) then
    
    if s_tvalid_i_wots_pkGen = '1' then
        
        --hash_reset <= wots_pkGen_reset;
        s_tdata_i  <=  s_tdata_i_wots_pkGen     ;
        s_tlast_i  <=  s_tlast_i_wots_pkGen     ;
        s_tvalid_i <=  s_tvalid_i_wots_pkGen    ;


        
    elsif s_tvalid_i_wots_pkFromSig = '1' then              
                                                     
        --hash_reset         <= wots_pkFromSig_reset;
        s_tdata_i  <=  s_tdata_i_wots_pkFromSig     ;    
        s_tlast_i  <=  s_tlast_i_wots_pkFromSig     ;    
        s_tvalid_i <=  s_tvalid_i_wots_pkFromSig    ;  
    
    else 
       s_tdata_i  <= (others => '0');
       s_tlast_i  <= '0';            
       s_tvalid_i <= '0';            
       hash_reset <= '0'; 
       
    end if;
    
end if;
end process;

end Behavioral;