library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xmss_node is
  port (
    clock : in std_logic;
    reset : in std_logic;
    
    -- FSM ports
    secret_seed   : in std_logic_vector(255 downto 0);
    target_height : in std_logic_vector(15 downto 0);
    target_index  : in std_logic_vector(15 downto 0);
    valid_in      : in std_logic;
    
    node_out      : out std_logic_vector(255 downto 0);
    valid_out     : out std_logic;
    ready         : out std_logic;
    
    -- hash ports
    hash_reset         : out std_logic;
    hash_mode          : out std_logic;
    hash_data_in_0     : out std_logic_vector(255 downto 0);
    hash_data_in_1     : out std_logic_vector(255 downto 0);
    hash_data_in_2     : out std_logic_vector(255 downto 0);
    hash_data_in_3     : out std_logic_vector(255 downto 0);
    hash_data_in_valid : out std_logic;
    
    hash_out           : in std_logic_vector(255 downto 0);
    hash_valid         : in std_logic;
    hash_ready         : in std_logic;
    
    
    -- ram ports

    we_bram : out STD_LOGIC_VECTOR(0 DOWNTO 0);
    addr_bram : out STD_LOGIC_VECTOR(8 DOWNTO 0);
    din_bram : out STD_LOGIC_VECTOR(255 DOWNTO 0);
    dout_bram : in STD_LOGIC_VECTOR(255 DOWNTO 0);

    
    
    -- stack ports go here
--    push_e_stack : out std_logic;
--    pop_e_stack : out std_logic;
--    data_in_stack : out std_logic_vector(255 downto 0);
--    valid_in_stack : out std_logic;
    
--    data_out_stack : in std_logic_vector(255 downto 0);
--    valid_out_stack : in std_logic;
--    ready_stack : in std_logic;
--    full_stack : in std_logic;
    
    
    -- wots_pkGen ports
    sk_seed_wots_pkGen  : out  std_logic_vector(255 downto 0);
    valid_in_wots_pkGen : out  std_logic;
    
    pk_wots_pkGen        : in std_logic_vector(255 downto 0);
    valid_out_wots_pkGen : in std_logic;
    ready_wots_pkGen     : in std_logic
    

  );
end entity xmss_node;

architecture behavioral of xmss_node is

  -- FSM data type
  type state_type is (Idle, Leaves, Hash_0, Hash_1);
  signal current_state : state_type := Idle;
  
  -- internal signals
  signal t_h : natural:= 0; -- integer version of target height
  signal t_i : natural := 0; -- integer version of target index
  signal sk_seed : std_logic_vector(255 downto 0):= (others => '0'); -- the secret seed
  
  signal level_i : integer := 0; -- number of nodes in a level
  signal z : integer := 0; -- counter for height
  signal i : integer := 0; -- counter for index
  signal array_count : integer := 0; -- indexing the array which is used to store intermediate hash values
  
  constant array_max_depth : natural := 8; -- this is the maximum height that a tree can be in this calculation
  constant array_size : integer := 2**array_max_depth; -- maximum number of leaves
  type my_array_type is array (0 to array_size -1) of std_logic_vector(255 downto 0); -- array sized for max number of leaves
  --signal node : my_array_type := (others => (others => '0')); -- this array will store the nodes
  
  signal bram_count : integer := 0;
    
  signal hash_reg_0 : std_logic_vector(255 downto 0) := (others => '0');
  signal hash_reg_1 : std_logic_vector(255 downto 0) := (others => '0');
  signal hash_reg_2 : std_logic_vector(255 downto 0) := (others => '0');
  signal hash_reg_3 : std_logic_vector(255 downto 0) := (others => '0');
  
  
begin

  process (clock, reset)
  begin
    if reset = '1' then
      current_state <= Idle;
      valid_out <= '0';
      node_out <= (others => '0');  -- Initialize output
      hash_reset <= '1';
      ready <= '0';
      
      -- wots outputs
      sk_seed_wots_pkGen  <= (others => '0');
      valid_in_wots_pkGen <= '0';

        hash_reset         <= '0';
        hash_mode          <= '0';
        hash_data_in_0     <= (others => '0');
        hash_data_in_1     <= (others => '0');
        hash_data_in_2     <= (others => '0');
        hash_data_in_3     <= (others => '0');
        hash_data_in_valid <= '0';
        
        -- BRAM stuff
        we_bram  <= "0";
        addr_bram <= (others => '0');
        din_bram <= (others => '0');

      
    elsif rising_edge(clock) then
      case current_state is
      
        when Idle =>
          hash_reset <= '0';
          if valid_in = '1' then -- upon receiving the parameters, we will set the secret seed, and target height and index of the node to calculate
            t_h <= to_integer(unsigned(target_height)); 
            t_i <= to_integer(unsigned(target_index));
            sk_seed <= secret_seed;
            current_state <= Leaves; -- first step is to calculate the leaves
            ready <= '0';
          else
            node_out <= (others => '0');
            valid_out <= '0';
            ready <= '1';
          end if;
        

        when Leaves => -- leaves will be wots+ public keys in practice. For now i am just hashing the secret seed
            
            level_i <= (t_i + 1) * (2 ** (t_h - z)); -- this calculates the number of leaves 
            if level_i > 0 then
                if i < level_i and ready_wots_pkGen = '1' and i <= array_count  then -- load in data for hashing
                    --hash_mode <= '0'; -- set to only use one core because we're only doing leaves
                    sk_seed_wots_pkGen <= sk_seed; -- for mode = 0 we only need two inputs, the others are don't cares
                    --hash_data_in_1 <= sk_seed;
                    valid_in_wots_pkGen <= '1';
                    i <= i + 1; -- for leaves we only increment index by one
                elsif valid_out_wots_pkGen = '1' and array_count < level_i then -- when a hash is done, register it in the node array
                    -- BRAM STUFF
                    we_bram <= "1";
                    addr_bram <= std_logic_vector(TO_UNSIGNED(array_count, 9));
                    din_bram <= pk_wots_pkGen;
                    
                    
                    --node(array_count) <= pk_wots_pkGen;
                    array_count <= array_count + 1;
                    --hash_reset <= '1';
                elsif array_count = level_i then 
                
                    if t_h = 0 then -- if the target height was zero, we are done. Simply output the desired leaf.
                        -- BRAM stuff
                        if bram_count = 0 then
                            addr_bram <= std_logic_vector(TO_UNSIGNED(t_i, 9));
                            bram_count <= bram_count + 1;
                        elsif bram_count < 3 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 3 then
                            node_out <= dout_bram;
                            valid_out <= '1';
                            z <= 0;
                            bram_count <= 0;
                            current_state <= Idle;
                        end if;
                        
                        --node_out <= node(t_i);
                        --valid_out <= '1';
                        --z <= 0;
                        --current_state <= Idle;
                    elsif t_h >= 2 then
                        current_state <= Hash_1;
                        z <= z+2;
                    elsif t_h =1 then -- if the target height is less than two, we only need to use mode = 0 for one hash core.
                        current_state <= Hash_0;
                        z <= z+1; -- only increase height by one for mode = 0
                    else    
                        current_state <= Hash_1; -- if target height greater than or equal to two, we use mode = 1 for triangle.
                        z <= z+2; -- increment by two since ouput is two levels up in the tree
                    end if;
                    
                    -- reset all of the temporary signals
                    i <= 0;
                    array_count <= 0;
                    valid_in_wots_pkGen <= '0';
                    we_bram <= "0";
                    addr_bram <= (others => '0');
                    din_bram <= (others => '0');

                else
                    sk_seed_wots_pkGen <= (others => '0');
                    valid_in_wots_pkGen <= '0';
                    we_bram <= "0";
                    addr_bram <= (others => '0');
                    din_bram <= (others => '0');

                end if; 
             end if;

        when Hash_0 => -- only using one hash function
            level_i <= (2 ** (t_h - z)); -- this calculates the number of nodes to calculate
            if level_i > 0 then
                
            if array_count < level_i then
                if hash_ready = '1' then
                        if bram_count = 0 then
                            addr_bram <= std_logic_vector(TO_UNSIGNED(i, 9));
                            bram_count <= bram_count + 1;
                        elsif bram_count < 3 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 3 then
                            hash_reg_0 <= dout_bram;
                            addr_bram <= std_logic_vector(TO_UNSIGNED(i, 9));
                            bram_count <= bram_count + 1;
                        elsif bram_count < 6 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 6 then
                            hash_reg_1 <= dout_bram;
                            bram_count <= bram_count + 1;
                        else
                            hash_data_in_0 <= hash_reg_0;
                            hash_data_in_1 <= hash_reg_1;
                            hash_data_in_valid <= '1';
                            bram_count <= 0;
                            addr_bram <= (others => '0');
                        end if;

                    
                
                elsif hash_valid = '1' then
                    we_bram <= "1";
                    addr_bram <= std_logic_vector(TO_UNSIGNED(array_count, 9));
                    din_bram <= hash_out;
                    array_count <= array_count + 1;

                
                else
                    hash_data_in_0 <= (others => '0');
                    hash_data_in_1 <= (others => '0');
                    hash_data_in_valid <= '0';
                    
                    we_bram <= "0";
                    addr_bram <= (others => '0');
                    din_bram <= (others => '0');
                    bram_count <= 0;

                end if;
            
            elsif array_count = level_i and level_i > 0 then
                we_bram <= "0";
                if t_h = z then
                    if bram_count = 0 then
                        addr_bram <= std_logic_vector(TO_UNSIGNED(0, 9));
                        bram_count <= bram_count + 1;
                    elsif bram_count < 3 then
                        bram_count <= bram_count + 1;
                    elsif bram_count = 3 then
                        node_out <= dout_bram;
                        valid_out <= '1';
                        bram_count <= 0;
                        addr_bram <= (others => '0');
                        current_state <= idle;
                        array_count <= 0;
                        i <= 0;
                        z <= 0;

                    end if;

                elsif (t_h -z) >=2 then
                    current_state <= hash_1;
                    z <= z+2;
                    array_count <= 0;
                    i <= 0;
                    level_i <= 0;

                elsif t_h -z =1 then 
                    current_state <= hash_0;
                    z <= z+1;
                    array_count <= 0;
                    i <= 0;
                    level_i <= 0;

                end if;            
            end if;
            end if;
             
            
            
            
        when Hash_1 => -- using three hash functions in mode = 1
             level_i <= (2 ** (t_h - z)); -- this calculates the number of nodes to calculate
            if level_i > 0 then            
             if array_count < level_i then
             we_bram <= "0";
                if hash_ready = '1' then
                        if bram_count = 0 then
                            addr_bram <= std_logic_vector(TO_UNSIGNED(i, 9));
                            bram_count <= bram_count + 1;
                        elsif bram_count < 3 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 3 then
                            hash_reg_0 <= dout_bram;
                            addr_bram <= std_logic_vector(TO_UNSIGNED(i+1, 9));
                            bram_count <= bram_count + 1;
                        elsif bram_count < 6 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 6 then
                            hash_reg_1 <= dout_bram;
                            bram_count <= bram_count + 1;
                            addr_bram <= std_logic_vector(TO_UNSIGNED(i+2, 9));
                        elsif bram_count < 9 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 9 then
                            hash_reg_2 <= dout_bram;
                            bram_count <= bram_count + 1;
                            addr_bram <= std_logic_vector(TO_UNSIGNED(i+3, 9));
                        elsif bram_count < 12 then
                            bram_count <= bram_count + 1;
                        elsif bram_count = 12 then
                            hash_reg_3 <= dout_bram;
                            bram_count <= bram_count + 1;
                        else
                            hash_mode <= '1';
                            hash_data_in_0 <= hash_reg_0;
                            hash_data_in_1 <= hash_reg_1;                            
                            hash_data_in_2 <= hash_reg_2;
                            hash_data_in_3 <= hash_reg_3;
                            
                            hash_data_in_valid <= '1';
                            bram_count <= 0;
                            addr_bram <= (others => '0');
                            i <= i+4;
                        end if;

                    
                
                elsif hash_valid = '1' then
                    we_bram <= "1";
                    addr_bram <= std_logic_vector(TO_UNSIGNED(array_count, 9));
                    din_bram <= hash_out;
                    hash_mode <= '0';
                    array_count <= array_count + 1;

                
                else
                    hash_data_in_0 <= (others => '0');
                    hash_data_in_1 <= (others => '0');
                    hash_data_in_2 <= (others => '0');
                    hash_data_in_3 <= (others => '0');
                    hash_data_in_valid <= '0';
                    
                    we_bram <= "0";
                    addr_bram <= (others => '0');
                    din_bram <= (others => '0');
                    bram_count <= 0;

                end if;
            
            elsif array_count = level_i and level_i >0 then
                we_bram <= "0";
                if t_h = z then
                    if bram_count = 0 then
                        addr_bram <= std_logic_vector(TO_UNSIGNED(0, 9));
                        bram_count <= bram_count + 1;
                    elsif bram_count < 3 then
                        bram_count <= bram_count + 1;
                    elsif bram_count = 3 then
                        node_out <= dout_bram;
                        valid_out <= '1';
                        bram_count <= 0;
                        addr_bram <= (others => '0');
                        current_state <= idle;
                        
                        array_count <= 0;
                        i <= 0;
                        level_i <=0;
                        z <= 0;

                        
                    end if;

                elsif (t_h -z) >=2 then
                    current_state <= hash_1;
                    array_count <= 0;
                    i <= 0;
                    level_i <=0;
                    z <= z+2;
                elsif t_h -z =1 then 
                    current_state <= hash_0;
                    array_count <= 0;
                    i <= 0;
                    level_i <= 0;
                    z <= z+1;
                
                end if;

            end if;
            end if;
        when others => -- default state
          current_state <= Idle;
      end case;
    end if;
  end process;                           

end architecture behavioral;