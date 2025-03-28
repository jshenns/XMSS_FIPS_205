----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 07:23:18 PM
-- Design Name: 
-- Module Name: chain_input_mux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
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

entity chain_input_mux is
  Port ( 
        
        clock : in std_logic;
        reset : in std_logic;
        
        -- wots_sign inputs
        x_wots_sign           : in  STD_LOGIC_VECTOR(255 downto 0);
        i_wots_sign           : in  STD_LOGIC_VECTOR(15 downto 0);
        s_wots_sign           : in  STD_LOGIC_VECTOR(15 downto 0);
        valid_in_wots_sign    : in  STD_LOGIC;

        -- wots_pkGen inputs
        x_wots_pkGen           : in  STD_LOGIC_VECTOR(255 downto 0);
        i_wots_pkGen           : in  STD_LOGIC_VECTOR(15 downto 0);
        s_wots_pkGen           : in  STD_LOGIC_VECTOR(15 downto 0);
        valid_in_wots_pkGen    : in  STD_LOGIC;
        
        -- wots_pkFromSig inputs
        x_wots_pkFromSig           : in  STD_LOGIC_VECTOR(255 downto 0);
        i_wots_pkFromSig           : in  STD_LOGIC_VECTOR(15 downto 0); 
        s_wots_pkFromSig           : in  STD_LOGIC_VECTOR(15 downto 0); 
        valid_in_wots_pkFromSig    : in  STD_LOGIC;                         
                
        -- outputs
        x           : out  STD_LOGIC_VECTOR(255 downto 0);
        i           : out  STD_LOGIC_VECTOR(15 downto 0);
        s           : out  STD_LOGIC_VECTOR(15 downto 0);
        valid_in    : out  STD_LOGIC
        

  );
end entity chain_input_mux;

architecture Behavioral of chain_input_mux is

begin
process(clock, reset)
begin

if reset = '1' then
    x <= (others => '0');
    i <= (others => '0');
    s <= (others => '0');
    valid_in <= '0';


elsif rising_edge(clock) then

    
    if valid_in_wots_sign = '1' then
        
        --hash_reset         <= hash_reset_xmss_node;
        x        <=  x_wots_sign           ;
        i        <=  i_wots_sign           ;
        s        <=  s_wots_sign           ;
        valid_in <=  valid_in_wots_sign    ;


        
    elsif valid_in_wots_pkGen = '1' then 
        x        <=  x_wots_pkGen           ;
        i        <=  i_wots_pkGen           ;
        s        <=  s_wots_pkGen           ;
        valid_in <=  valid_in_wots_pkGen    ;
        
    elsif valid_in_wots_pkFromSig = '1' then 
        x        <=  x_wots_pkFromSig           ;
        i        <=  i_wots_pkFromSig           ;
        s        <=  s_wots_pkFromSig           ;
        valid_in <=  valid_in_wots_pkFromSig    ;
    
    else 
       x <= (others => '0');
       i <= (others => '0');
       s <= (others => '0');
       valid_in <= '0';      
    end if;
    
end if;
end process;


end Behavioral;
