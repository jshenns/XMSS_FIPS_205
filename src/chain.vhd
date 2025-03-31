library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- Use this for numeric types, adjust if necessary
use IEEE.NUMERIC_STD.ALL;          -- It's recommended to use this for better type safety

entity chain is
    Port (
        clock       : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        x           : in  STD_LOGIC_VECTOR(255 downto 0);
        i           : in  STD_LOGIC_VECTOR(15 downto 0);
        s           : in  STD_LOGIC_VECTOR(15 downto 0);
        valid_in    : in  STD_LOGIC;
        tmp         : out STD_LOGIC_VECTOR(255 downto 0);
        valid_out   : out STD_LOGIC;
        ready       : out STD_LOGIC;
        
        -- triangle hash signals
        hash_reset         : out std_logic;
        hash_mode          : out std_logic;
        hash_last          : out std_logic;
        hash_data_in_0     : out std_logic_vector(255 downto 0);
        hash_data_in_1     : out std_logic_vector(255 downto 0);
        hash_data_in_2     : out std_logic_vector(255 downto 0);
        hash_data_in_3     : out std_logic_vector(255 downto 0);
        hash_data_in_valid : out std_logic;
        
        digest             : in std_logic_vector(255 downto 0);
        digest_valid       : in std_logic;
        hash_ready         : in std_logic
    );
end chain;

architecture Behavioral of chain is

    type state_type is (idle, hash);
    signal state, next_state: state_type;
    
    -- counters
    signal j_count : integer := 0;
    
    -- registers
     signal x_reg : std_logic_vector(255 downto 0) := (others => '0');
     signal i_reg : integer := 0;
     signal s_reg : integer := 0;
     
     --signal stupid_count : integer := 0;

begin    

    process(clock, reset)
    begin
        if reset = '1' then
            tmp <= (others => '0');
            valid_out <= '0';
            ready <= '0';
            
            hash_mode          <= '0';
            hash_last          <= '0';
            hash_data_in_0     <= (others => '0');
            hash_data_in_1     <= (others => '0');
            hash_data_in_2     <= (others => '0');
            hash_data_in_3     <= (others => '0');
            hash_data_in_valid <= '0';

            
            hash_reset <= '1';
--            hash_data_in_valid <= '1';
        elsif rising_edge(clock) then
            case state is
                when idle =>
                    tmp <= (others => '0');
                    valid_out <= '0';
                    
                    if valid_in = '1' then
                        
                        x_reg <= x;
                        j_count <= TO_INTEGER(unsigned(i));
                        i_reg <= TO_INTEGER(unsigned(i));
                        s_reg <= TO_INTEGER (unsigned(s));
                        
                        
                        ready <= '0';
                        state <= hash;
                    
                    else
                        ready <= '1';
                        hash_reset <= '0';
                        hash_data_in_valid <= '0';
                        state <= idle;
                    
                    end if;
                    
                when hash =>
                    if j_count < i_reg + s_reg -1 then
                        
                        if hash_ready = '1' then
                            
                            hash_data_in_0 <= x_reg;
                            hash_data_in_1 <= x_reg;
                            hash_last <= '1';
                            hash_data_in_valid <= '1';
                            
                        
                        elsif digest_valid = '1' then
                        
                            x_reg <= digest;
                            hash_reset <= '1';
                            j_count <= j_count + 1;
                            
                        else
                            hash_data_in_valid <= '0';
                            hash_last <= '0';
                            hash_reset <= '0';
                        end if;
                        
                    elsif j_count = i_reg + s_reg -1 then
                        
                        if hash_ready = '1' then
                            
                            hash_data_in_0 <= x_reg;
                            hash_data_in_1 <= x_reg;
                            hash_last <= '1';
                            hash_data_in_valid <= '1';
                            
                        elsif digest_valid = '1' then
                        
                            tmp <= digest;
                            j_count <= 0;
                            valid_out <= '1';
                            state <= idle;
                            hash_reset <= '1';
                            
                            
                        else
                            hash_last <= '0';
                            hash_reset <= '0';
                            hash_data_in_valid <= '0';
                        end if;
                    elsif s_reg = 0 then
                        
                            tmp <= x_reg;
                            valid_out <= '1';
                            state <= idle;
                            hash_reset <= '1';
                            j_count <= 0;

                    
                    end if;
                when others =>
                    
            end case;
        end if;
    end process;
end Behavioral;