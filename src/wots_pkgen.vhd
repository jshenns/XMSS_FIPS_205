library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wots_pkGen is
    generic (
        w : integer := 16;  
        len : integer := 67  
    );
    port (
        
        -- inputs
        clk      : in  std_logic;
        reset    : in  std_logic;
        sk_seed  : in  std_logic_vector(255 downto 0);
        valid_in : in  std_logic;
        
        
        -- wots_chain signals
        x_wots_chain : out std_logic_vector(255 downto 0);
        i_wots_chain : out std_logic_vector(15 downto 0);
        s_wots_chain : out std_logic_vector(15 downto 0);
        valid_in_wots_chain : out std_logic;
        
        tmp_wots_chain : in std_logic_vector(255 downto 0);
        valid_out_wots_chain : in std_logic;
        ready_wots_chain : std_logic;
        
        
--        -- triangle_hash_unit signals
--        mode_triangle_hash_unit : out std_logic;
--        data_in_0_triangle_hash_unit : out std_logic_vector(255 downto 0);
--        data_in_1_triangle_hash_unit : out std_logic_vector(255 downto 0);
--        data_in_2_triangle_hash_unit : out std_logic_vector(255 downto 0);
--        data_in_3_triangle_hash_unit : out std_logic_vector(255 downto 0);
--        data_in_valid_triangle_hash_unit : out std_logic;
        
--        hash_out_triangle_hash_unit : in std_logic_vector(255 downto 0);
--        hash_valid_triangle_hash_unit : in std_logic;
--        ready_triangle_hash_unit : in std_logic;
        
        
        -- compression core signals
        s_tdata_i : out std_logic_vector(511 downto 0);
        s_tlast_i : out std_logic;
        s_tvalid_i : out std_logic;
        hash_reset : out std_logic;
       
        s_tready_o : in std_logic;
        digest_o : in std_logic_vector(255 downto 0);
        digest_valid_o : in std_logic;
        
    
        
         
        -- outputs
        pk       : out std_logic_vector(255 downto 0);
        valid_out: out std_logic;
        ready    : out std_logic
    );
end entity wots_pkGen;

architecture behavioral of wots_pkGen is

    -- state array
    type state_type is (idle, sk_gen, hash_chain, compress);
    signal current_state : state_type := idle;
    
    -- compression signals
    signal stupid_count : integer := 0;
    signal compression_count : integer := 0;
    signal compression_rounds : integer := len;
    
    -- array for holding tmp values 
    type tmp_array_type is array (0 to len-1) of std_logic_vector(255 downto 0);
    signal tmp : tmp_array_type:= (others => (others => '0')); 
    
    -- counter signal
    signal loop_count : integer := 0;
    
    -- registers
    signal sk_reg : std_logic_vector(255 downto 0) := (others => '0');
    signal sk_seed_reg : std_logic_vector(255 downto 0) := (others => '0');
    
begin


     
    process (clk, reset)
    begin
        if reset = '1' then
            pk <= (others => '0');
            valid_out <= '0';
            ready <= '0';
            hash_reset <= '1';
            
            x_wots_chain <= (others => '0');
            i_wots_chain <= (others => '0');
            s_wots_chain <= (others => '0');
            valid_in_wots_chain <= '0';
            
            s_tdata_i <= (others => '0');
            s_tlast_i <= '0';
            s_tvalid_i <= '0';
            --hash_reset <= '0';
            
--            mode_triangle_hash_unit <= '0';
--            data_in_0_triangle_hash_unit <= (others => '0');
--            data_in_1_triangle_hash_unit <= (others => '0');
--            data_in_2_triangle_hash_unit <= (others => '0');
--            data_in_3_triangle_hash_unit <= (others => '0');
--            data_in_valid_triangle_hash_unit <= '0';


        elsif rising_edge(clk) then
            case current_state is
                when idle =>
                    hash_reset <= '0';
                    valid_out <= '0';
                    pk <= (others => '0');
                    
                    if valid_in = '1' then
                        sk_seed_reg <= sk_seed;
                        ready <= '0';
                        current_state <= sk_gen;
                        
                    else
                        ready <= '1';
                        hash_reset <= '0';
                        current_state <= idle;
                    end if;

                when sk_gen =>

                    if loop_count <= len -1 then
                        
                        if ready_wots_chain = '1' then
                            x_wots_chain <= sk_seed_reg;
                            i_wots_chain <= (others => '0');
                            s_wots_chain <= std_logic_vector(to_unsigned(1,16));
                            valid_in_wots_chain <= '1';
                        elsif valid_out_wots_chain = '1' then 
                            
                            sk_reg <= tmp_wots_chain;
                            current_state <= hash_chain;
                        
                        else
                            valid_in_wots_chain <= '0';
                        end if;
                    end if;
                        
                    when hash_chain =>
                     if loop_count <= len -1 then
                        
                        if ready_wots_chain = '1' then
                            x_wots_chain <= sk_reg;
                            i_wots_chain <= (others => '0');
                            s_wots_chain <= std_logic_vector(to_unsigned(w-1, 16));
                            valid_in_wots_chain <= '1';
                        elsif valid_out_wots_chain = '1' then 
                            
                            tmp(loop_count) <= tmp_wots_chain;
                            loop_count <= loop_count + 1;
                            
                            if loop_count = len-1 then
                                current_state <= compress;
                                
                            else
                                current_state <= sk_gen;
                            end if;
                        else
                            valid_in_wots_chain <= '0';    
                       end if;
                    end if;
                    


                when compress =>

                    if s_tready_o = '1' and stupid_count = 0 and compression_count*2 < compression_rounds-1  then
                        stupid_count <= stupid_count + 1;
                        s_tdata_i <= tmp(compression_count*2) & tmp(compression_count*2 + 1);
                        s_tvalid_i <= '1';
                        s_tlast_i <= '0';
                        --compression_count <= compression_count + 1;

                    elsif s_tready_o = '0' and stupid_count = 1 then
                        stupid_count <= 0;
                        s_tvalid_i <= '0';
                        
                    elsif digest_valid_o = '1' and compression_count*2 = compression_rounds-1 then 
                        
                        pk <= digest_o;
                        valid_out <= '1';
                        s_tvalid_i <= '0';
                        compression_count <= 0;
                        loop_count <= 0;
                        hash_reset <= '1';
                        stupid_count <= 0;
                        current_state <= idle;
                    else
                        s_tvalid_i <= '0';
                        s_tvalid_i <= '0';
                    end if;
                    
                    if digest_valid_o = '1' and stupid_count = 0 then
                        compression_count <= compression_count + 1;    
                    end if;
                when others =>
                    current_state <= idle;
            end case;
        end if;
    end process;

end architecture behavioral;
