----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2025 08:10:53 PM
-- Design Name: 
-- Module Name: xmss_sign - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xmss_sign is
    Port ( -- xmss_sign inputs
           clk : in std_logic;
           rst : in std_logic;
           message : in STD_LOGIC_VECTOR (255 downto 0);
           sk_seed : in STD_LOGIC_VECTOR (255 downto 0);
           idx : in STD_LOGIC_VECTOR (15 downto 0);
           valid_in : in STD_LOGIC;
           
           -- xmss_node signals
           sk_seed_xmss_node : out STD_LOGIC_VECTOR (255 downto 0);
           k_xmss_node : out STD_LOGIC_VECTOR (15 downto 0);
           j_xmss_node : out STD_LOGIC_VECTOR (15 downto 0);
           valid_in_xmss_node : out STD_LOGIC;
           node_out_xmss_node : in STD_LOGIC_VECTOR (255 downto 0);
           valid_out_xmss_node : in STD_LOGIC;
           ready_xmss_node : in STD_LOGIC;
           
           -- wots_sign signals
           message_wots_sign : out STD_LOGIC_VECTOR (255 downto 0);
           sk_seed_wots_sign : out STD_LOGIC_VECTOR (255 downto 0);
           valid_in_wots_sign : out STD_LOGIC;
           sig_wots_sign : in STD_LOGIC_VECTOR (17151 downto 0);
           valid_out_wots_sign : in STD_LOGIC;
           ready_wots_sign : in STD_LOGIC;
           
           -- xmss_sign outputs
           sig_xmss : out STD_LOGIC_VECTOR (67*256 +8*256-1 downto 0);
           valid_out : out STD_LOGIC;
           ready : out STD_LOGIC);
end xmss_sign;

architecture Behavioral of xmss_sign is

-- state machine signals
type state_type is (idle, k_calc, auth_calc, wots_sign, sig_out);
signal state : state_type := idle;

constant height : integer := 8; -- the height of the merkle tree, from the parameters
signal j_count : integer := 0;

signal message_reg : std_logic_vector(255 downto 0) := (others => '0');
signal sk_seed_reg : std_logic_vector(255 downto 0) := (others => '0');
signal idx_reg : std_logic_vector(15 downto 0) := (others => '0');

signal k : std_logic_vector(15 downto 0) := (others => '0');


-- store the xmss_node output
--type array_type is array (0 to height -1) of std_logic_vector(255 downto 0);
signal auth : std_logic_vector(height*256-1 downto 0) := (others => '0');

-- store the wots_signature
signal sig_wots_sign_reg : std_logic_vector(67*256 - 1 downto 0) := (others => '0');


begin


process(clk, rst) is 
begin
    if rst = '1' then
        state <= idle;
        
           -- xmss_node signals
           sk_seed_xmss_node <= (others => '0');
           k_xmss_node <= (others => '0');
           j_xmss_node <= (others => '0');
           valid_in_xmss_node <= '0';
           
           -- wots_sign signals
           message_wots_sign <= (others => '0');
           sk_seed_wots_sign <= (others => '0');
           valid_in_wots_sign <= '0';

           -- xmss_sign inputs
           sig_xmss <= (others => '0');
           valid_out <= '0';
           ready <= '0';

        
    
    elsif rising_edge(clk) then
        
        case state is
        
        
            when idle =>
                if valid_in = '1' then
                    message_reg <= message;
                    sk_seed_reg <= sk_seed;
                    idx_reg <= idx;
                    ready <= '0';
                    state <= k_calc;
                else
                    valid_out <= '0';
                    ready <= '1';
                    state <= idle;
                    
                end if;
            
            when k_calc =>
                if j_count < height then
                    k <= std_logic_vector(TO_UNSIGNED(to_integer(unsigned(idx_reg))/(2**j_count) ,  16)) xor "0000000000000001";
                    state <= auth_calc;
                else
                    state <= wots_sign;
                end if;
            when auth_calc =>
                if j_count < height then
                    
                    if ready_xmss_node = '1' then 
                        
                        k_xmss_node <= (others => '0');
                        j_xmss_node <= std_logic_vector(to_unsigned(j_count, 16));
                        sk_seed_xmss_node <= sk_seed_reg;
                        valid_in_xmss_node <= '1';
                        state <= auth_calc;
                       
                    elsif valid_out_xmss_node = '1' then
                        
                        auth(255 + 256*j_count downto j_count*256) <= node_out_xmss_node;
                        j_count <= j_count + 1;
                        state <= k_calc;
                        
                    else
                        valid_in_xmss_node <= '0';
                        state <= auth_calc;
                    end if;

                else
                    state <= wots_sign;
                    
                end if;
            
            when wots_sign =>
                
                if ready_wots_sign = '1' then
                    
                    message_wots_sign <= message_reg;
                    sk_seed_wots_sign <= sk_seed_reg;
                    valid_in_wots_sign <= '1';
                elsif valid_out_wots_sign = '1' then
                
                    sig_wots_sign_reg <= sig_wots_sign;
                    state <= sig_out;
                else 
                
                    valid_in_wots_sign <= '0';
                end if;
            
            when sig_out =>
                
                sig_xmss <= sig_wots_sign_reg & auth;
                valid_out <= '1';
                state <= idle;
            
        end case; 
        
        
        
    
    end if;
    end process;
end Behavioral;
