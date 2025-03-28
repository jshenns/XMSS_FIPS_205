----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2025 04:26:20 PM
-- Design Name: 
-- Module Name: hash_input_mux - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hash_input_mux is
  Port ( 
        
        clock : in std_logic;
        reset : in std_logic;
        
        -- xmss_node inputs
        hash_reset_xmss_node         : in std_logic;
        hash_mode_xmss_node          : in std_logic;
        hash_data_in_0_xmss_node     : in std_logic_vector(255 downto 0);
        hash_data_in_1_xmss_node     : in std_logic_vector(255 downto 0);
        hash_data_in_2_xmss_node     : in std_logic_vector(255 downto 0);
        hash_data_in_3_xmss_node     : in std_logic_vector(255 downto 0);
        hash_data_in_valid_xmss_node : in std_logic;

        -- chain inputs
        hash_reset_chain         : in std_logic;
        hash_mode_chain          : in std_logic;
        hash_data_in_0_chain     : in std_logic_vector(255 downto 0);
        hash_data_in_1_chain     : in std_logic_vector(255 downto 0);
        hash_data_in_2_chain     : in std_logic_vector(255 downto 0);
        hash_data_in_3_chain     : in std_logic_vector(255 downto 0);
        hash_data_in_valid_chain : in std_logic;
        
        --wots_sign inputs
        hash_reset_wots_sign         : in std_logic;
        hash_mode_wots_sign          : in std_logic;
        hash_data_in_0_wots_sign     : in std_logic_vector(255 downto 0);
        hash_data_in_1_wots_sign     : in std_logic_vector(255 downto 0);
        hash_data_in_2_wots_sign     : in std_logic_vector(255 downto 0);
        hash_data_in_3_wots_sign     : in std_logic_vector(255 downto 0);
        hash_data_in_valid_wots_sign : in std_logic;
        
        -- xmss_pkFromSig inputs                    
        hash_mode_xmss_pkFromSig          : in std_logic;                     
        hash_data_in_0_xmss_pkFromSig     : in std_logic_vector(255 downto 0);       
        hash_data_in_1_xmss_pkFromSig     : in std_logic_vector(255 downto 0);
        hash_data_in_2_xmss_pkFromSig     : in std_logic_vector(255 downto 0);
        hash_data_in_3_xmss_pkFromSig     : in std_logic_vector(255 downto 0);
        hash_data_in_valid_xmss_pkFromSig : in std_logic;                     
        
        -- outputs
        hash_reset         : out std_logic;
        hash_mode          : out std_logic;
        hash_data_in_0     : out std_logic_vector(255 downto 0);
        hash_data_in_1     : out std_logic_vector(255 downto 0);
        hash_data_in_2     : out std_logic_vector(255 downto 0);
        hash_data_in_3     : out std_logic_vector(255 downto 0);
        hash_data_in_valid : out std_logic
        

  );
end entity hash_input_mux;

architecture Behavioral of hash_input_mux is

begin
process(clock, reset)
begin

if reset = '1' then
        hash_reset         <= '1';
        hash_mode          <= '0';
        hash_data_in_0     <=  (others => '0');
        hash_data_in_1     <=  (others => '0');
        hash_data_in_2     <=  (others => '0');
        hash_data_in_3     <=  (others => '0');
        hash_data_in_valid <=  '0';


elsif rising_edge(clock) then

    hash_reset <= hash_reset_xmss_node or hash_reset_chain;

    
    if hash_data_in_valid_xmss_node = '1' then
        
        --hash_reset         <= hash_reset_xmss_node;
        hash_mode          <=  hash_mode_xmss_node         ;
        hash_data_in_0     <=  hash_data_in_0_xmss_node    ;
        hash_data_in_1     <=  hash_data_in_1_xmss_node    ;
        hash_data_in_2     <=  hash_data_in_2_xmss_node    ;
        hash_data_in_3     <=  hash_data_in_3_xmss_node    ;
        hash_data_in_valid <=  hash_data_in_valid_xmss_node;

        
    elsif hash_data_in_valid_chain = '1' then 
        --hash_reset         <= hash_reset_chain;
        hash_mode          <=  hash_mode_chain;
        hash_data_in_0     <=  hash_data_in_0_chain    ;
        hash_data_in_1     <=  hash_data_in_1_chain    ;
        hash_data_in_2     <=  hash_data_in_2_chain    ;
        hash_data_in_3     <=  hash_data_in_3_chain    ;
        hash_data_in_valid <=  hash_data_in_valid_chain;
    
    elsif hash_data_in_valid_wots_sign = '1' then
        
        hash_mode          <=  hash_mode_wots_sign;
        hash_data_in_0     <=  hash_data_in_0_wots_sign    ;
        hash_data_in_1     <=  hash_data_in_1_wots_sign    ;
        hash_data_in_2     <=  hash_data_in_2_wots_sign    ;
        hash_data_in_3     <=  hash_data_in_3_wots_sign    ;
        hash_data_in_valid <=  hash_data_in_valid_wots_sign;
        
    elsif hash_data_in_valid_xmss_pkFromSig = '1' then           
                                                        
        hash_mode          <=  hash_mode_xmss_pkFromSig;         
        hash_data_in_0     <=  hash_data_in_0_xmss_pkFromSig    ;
        hash_data_in_1     <=  hash_data_in_1_xmss_pkFromSig    ;
        hash_data_in_2     <=  hash_data_in_2_xmss_pkFromSig    ;
        hash_data_in_3     <=  hash_data_in_3_xmss_pkFromSig    ;
        hash_data_in_valid <=  hash_data_in_valid_xmss_pkFromSig;
    
    else 
        --hash_reset         <= '0';
        hash_mode          <= '0';
        hash_data_in_0     <=  (others => '0');
        hash_data_in_1     <=  (others => '0');
        hash_data_in_2     <=  (others => '0');
        hash_data_in_3     <=  (others => '0');
        hash_data_in_valid <=  '0';
    
    end if;
end if;
end process;


end Behavioral;