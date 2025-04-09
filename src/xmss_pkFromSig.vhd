----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2025 11:40:30 AM
-- Design Name: 
-- Module Name: xmss_pkFromSig - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xmss_pkFromSig is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           -- input signals
           message : in STD_LOGIC_VECTOR (255 downto 0);
           sig : in STD_LOGIC_VECTOR (255 downto 0);
           idx : in STD_LOGIC_VECTOR (15 downto 0);
           valid_in : in STD_LOGIC;
           
           -- wots_pkFromSig signals
           sig_wots_pkFromSig       : out STD_LOGIC_VECTOR (255 downto 0);
           message_wots_pkFromSig   : out STD_LOGIC_VECTOR (255 downto 0);
           valid_in_wots_pkFromSig  : out STD_LOGIC;
           pk_wots_pkFromSig        : in STD_LOGIC_VECTOR (255 downto 0);
           valid_out_wots_pkFromSig : in STD_LOGIC;
           ready_wots_pkFromSig     : in STD_LOGIC;
           
           -- triangle_hash_unit signals
           hash_mode          : out std_logic;
           hash_data_in_0     : out std_logic_vector(255 downto 0);
           hash_data_in_1     : out std_logic_vector(255 downto 0);
           hash_data_in_2     : out std_logic_vector(255 downto 0);
           hash_data_in_3     : out std_logic_vector(255 downto 0);
           hash_data_in_valid : out std_logic;
           hash_out           : in std_logic_vector(255 downto 0);
           hash_valid         : in std_logic;
           hash_ready         : in std_logic;               
           
--           -- BRAM signals 
--           we_bram   : out STD_LOGIC_VECTOR(0 DOWNTO 0);
--           addr_bram : out STD_LOGIC_VECTOR(8 DOWNTO 0);
--           din_bram  : out STD_LOGIC_VECTOR(255 DOWNTO 0);
--           dout_bram : in STD_LOGIC_VECTOR(255 DOWNTO 0);

        --signature fifo signals 
        din       : out std_logic_vector(255 downto 0);
        wr_en     : out std_logic;
        rd_en     : out std_logic;
        dout      : in std_logic_vector(255 downto 0);
        full      : in std_logic;
        empty     : in std_logic;

        
    
           
           -- output signals
           pk        : out STD_LOGIC_VECTOR (255 downto 0);
           valid_out : out STD_LOGIC;
           ready     : out STD_LOGIC);
end xmss_pkFromSig;

architecture Behavioral of xmss_pkFromSig is

-- loop signals
signal k : integer:= 0;
constant height : integer := 8;

-- intermediate values 
signal node_0 : std_logic_vector(255 downto 0) := (others => '0');
signal node_1 : std_logic_vector(255 downto 0) := (others => '0');

-- xmss_sig register
signal xmss_auth_reg : std_logic_vector(256*1 -1 downto 0) := (others => '0');

signal wots_sig_reg : std_logic_vector(255 downto 0) := (others => '0');

-- message reg
signal message_reg : std_logic_vector(255 downto 0) := (others => '0');

-- index
signal index_reg : integer := 0;

signal fifo_count : integer := 0;

---- BRAM signals for wots_sig
--signal bram_count : integer := 0;

-- intermediate value to see if even or odd
signal k_calc_reg : std_logic_vector(15 downto 0) := (others => '0');

-- states
type state_type is (idle, wots_pkFromSig, k_calc, grab_data_1, verify);  -- Define the state type
signal state : state_type := idle;       -- Declare the state signal, initialized to idle



begin

process(clk, reset)
begin 

if reset = '1' then
    sig_wots_pkFromSig            <= (others => '0') ;
    message_wots_pkFromSig        <= (others => '0') ;
    valid_in_wots_pkFromSig       <= '0'             ;

    din       <= (others => '0') ;
    wr_en     <= '0';
    rd_en     <= '0';


                                 
    hash_mode          <= '0';
    hash_data_in_0     <= (others => '0');
    hash_data_in_1     <= (others => '0');
    hash_data_in_2     <= (others => '0');
    hash_data_in_3     <= (others => '0');
    hash_data_in_valid <= '0';
    
--    we_bram   <= "0";
--    addr_bram <= (others => '0');
--    din_bram  <= (others => '0');   
        
    pk           <= (others => '0');
    valid_out    <= '0';
    ready <= '0';

elsif rising_edge(clk) then
    case state is
        when idle =>
            
            if valid_in = '1' then
                
                
                
                -- send the wots signature to the BRAM
--                we_bram <= "1";
--                addr_bram <= (others => '0');
                --wots_sig_reg <= sig;
                
                
                -- store xmss signature values in register
                --xmss_auth_reg <= sig;
                
                -- store message
                message_reg <= message;
                
                -- store index
                index_reg <= TO_INTEGER(unsigned(idx));
                
                ready <= '0';
                state <= wots_pkFromSig;
            
            else
                pk <= (others => '0');
                valid_out <= '0';
                ready <= '1';
            
            end if;
            
            
            
        when wots_pkFromSig =>
--            we_bram <= "0";
--            addr_bram <= (others => '0');
--            din_bram <= (others => '0');
            
            
            if ready_wots_pkFromSig = '1' then
                
                sig_wots_pkFromSig  <= (others => '0');   
                message_wots_pkFromSig <= message_reg;
                valid_in_wots_pkFromSig <= '1';

                --fifo_count <= fifo_count + 1;

                
            elsif valid_out_wots_pkFromSig = '1'  then
                
                node_0 <= pk_wots_pkFromSig;
                state <= k_calc;
            
            else
                sig_wots_pkFromSig  <= (others => '0'); 
                message_wots_pkFromSig <= (others => '0'); 
                valid_in_wots_pkFromSig <= '0';
                rd_en <= '0';
                sig_wots_pkFromSig <= (others => '0');
                
            end if;
            

        when k_calc =>
            
            k_calc_reg <= std_logic_vector(to_unsigned(index_reg/(2**k),16));
            if k < height -1 then
                state <= grab_data_1;
            else
                state <= grab_data_1;
            end if;
        
        when grab_data_1 =>
            if fifo_count < 1 then
                rd_en <= '1';
                fifo_count <= fifo_count + 1;
            else
                fifo_count <= 0;
                rd_en <= '0';
                xmss_auth_reg <= dout;
                state <= verify;
            end if;


        when verify => 
            if k < height then
                
                if k_calc_reg(0) = '0' then
                    
                    if hash_ready = '1' then
                        hash_data_in_0 <= node_0;
                        hash_data_in_1 <= xmss_auth_reg;
                        hash_data_in_valid <= '1';

                    
                    elsif hash_valid = '1' then
                        node_0 <= hash_out;
                        k <= k + 1;
                        state <= k_calc;
                
                    else 
                        hash_data_in_valid <= '0';
                    
                    end if;
                
                else
                    if hash_ready = '1' then
                        hash_data_in_1 <= node_0;
                        hash_data_in_0 <= xmss_auth_reg(255 + 256*k downto k*256);
                        hash_data_in_valid <= '1';

                    
                    elsif hash_valid = '1' then
                        node_0 <= hash_out;
                        k <= k + 1;
                        state <= k_calc;
                
                    else 
                        hash_data_in_valid <= '0';
                    
                    end if;

                end if;
            else
                    k <= 0;
                    pk <= node_0;
                    valid_out <= '1';
                    state <= idle;
            
            end if;
        
    end case;


end if;



end process;


end Behavioral;
