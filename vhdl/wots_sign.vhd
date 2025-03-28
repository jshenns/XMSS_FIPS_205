library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wots_sign is
    Port ( 
        clock           : in STD_LOGIC;
        reset           : in STD_LOGIC;
        
        M               : in STD_LOGIC_VECTOR(255 downto 0);
        SK_seed         : in STD_LOGIC_VECTOR(255 downto 0);
        data_in_valid   : in STD_LOGIC;
        
        ready           : out STD_LOGIC;
        sig             : out STD_LOGIC_VECTOR(17151 downto 0);
        sig_valid       : out STD_LOGIC;
        
        -- triangle hash signals
        hash_reset         : out std_logic;
        hash_mode          : out std_logic;
        hash_data_in_0     : out std_logic_vector(255 downto 0);
        hash_data_in_1     : out std_logic_vector(255 downto 0);
        hash_data_in_2     : out std_logic_vector(255 downto 0);
        hash_data_in_3     : out std_logic_vector(255 downto 0);
        hash_data_in_valid : out std_logic;
        
        digest             : in std_logic_vector(255 downto 0);
        digest_valid       : in std_logic;
        hash_ready         : in std_logic;
        
        -- chain signals go here
        chain_reset     : out  STD_LOGIC;                     
        chain_x         : out  STD_LOGIC_VECTOR(255 downto 0);
        chain_i         : out  STD_LOGIC_VECTOR(15 downto 0); 
        chain_s         : out  STD_LOGIC_VECTOR(15 downto 0); 
        chain_valid_in  : out  STD_LOGIC;                     
        chain_tmp       : in STD_LOGIC_VECTOR(255 downto 0);
        chain_valid_out : in STD_LOGIC;                     
        chain_ready     : in STD_LOGIC                  
    );
end wots_sign;

architecture Behavioral of wots_sign is

-- FSM 
type state_type is (Idle, Base_2b, Hash, Checksum, Shift_Checksum, Base_2b2, sk_hash );
signal state, next_state: state_type;

-- internal signals
--signal csum : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal i, j : integer := 0;
constant lgw : integer := 4;
constant len : integer := 67; 
constant len1 : integer := 64; 
constant len2 : integer := 3;

-- internal signals
signal csum : integer range 0 to 65535 := 0;
signal csum_ready : std_logic := '0';

-- csum array
type csum_array_type is array (0 to len2-1) of std_logic_vector(3 downto 0);
signal csum_array : csum_array_type := (others => (others => '0'));

signal sk : STD_LOGIC_VECTOR(255 downto 0) := (others => '0');
signal sig_reg : std_logic_vector(17151 downto 0) := (others => '0');

-- base_2b array
type message_array_type is array (0 to len1-1) of integer range 0 to 16;
signal message : message_array_type := (others => 0);

-- base_2b2 array
type new_message_array_type is array (0 to len-1) of integer range 0 to 16;
signal new_message : new_message_array_type := (others => 0);


-- csum toByte registers
signal csum_reg : std_logic_vector(15 downto 0) := (others => '0');

begin

process(clock, reset)
begin

if reset = '1' then

    sig <= (others => '0');
    sig_valid <= '0';
    ready <= '0';
    
    hash_reset <= '0';        
    hash_mode <= '0';     
    hash_data_in_0 <= (others => '0');
    hash_data_in_1 <= (others => '0');    
    hash_data_in_2 <= (others => '0');    
    hash_data_in_3 <= (others => '0');    
    hash_data_in_valid <= '0';
    
    chain_reset <=  '0';
    chain_x <= (others => '0');        
    chain_i <= (others => '0');        
    chain_s <= (others => '0');        
    chain_valid_in <=  '0';    

elsif rising_edge(clock) then

    case state is
    
        when Idle =>
            sig <= (others => '0');
            sig_valid <= '0';
            
            if data_in_valid = '1' then
                ready <= '0';
                state <= Base_2b;
            else
                ready <= '1';
                hash_reset <= '0';
                hash_data_in_valid <= '0';
                state <= Idle;
                
                sig_valid <= '0';
                sig <= (others => '0');
            end if;
            
        when Base_2b =>
            
            csum <= 0;
        
            for x in 0 to len1-1 loop
                message(x) <= to_integer(unsigned(M(x*lgw+lgw-1 downto x*lgw)));
            end loop;
            state <= Checksum;
        when Checksum =>
        
            if i < len1 then
                csum <= csum + 15 - message(i);
                i <= i+1;
            else
                state <= Shift_Checksum;
                i <= 0;
            end  if;
        
        when Shift_Checksum =>
        
            csum_reg <= std_logic_vector(shift_left(TO_UNSIGNED(csum, 16),4));
            csum_ready <= '1';
            
            if csum_ready = '1' then
                csum_array(0) <= csum_reg(3 downto 0);
                
                csum_array(1) <= csum_reg(7 downto 4);
                csum_array(2) <= csum_reg(11 downto 8);
                state <= base_2b2;
                csum_ready <= '0';
            end if;
        when Base_2b2 =>
            
            for i in 0 to len-1 loop
                if(i < len2) then
                    new_message(i) <= to_integer(unsigned(csum_array(i)));
                else
                    new_message(i) <= message(i-len2);
                end if;
            end loop;
            
            state <= sk_hash;
        
        when sk_hash =>
        
                   if j <= len -1 then
                        
                        if chain_ready = '1' then
                            chain_x <= SK_seed;
                            chain_i <= (others => '0');
                            chain_s <= std_logic_vector(to_unsigned(1,16));
                            chain_valid_in <= '1';
                        elsif chain_valid_out = '1' then 
                            
                            sk <= chain_tmp;
                            state <= hash;
                        
                        else
                            chain_valid_in <= '0';
                        end if;
                    end if;

        
        
        
--            if j <= len-1 then
--                -- sk <= triangle_hash_unit(sk_seed)
--                if hash_ready = '1' then
--                    hash_data_in_0 <= SK_seed;
--                    hash_data_in_1 <= SK_seed;
--                    hash_data_in_valid <= '1';
                
--                elsif digest_valid = '1' then
--                    sk <= digest;
--                    state <= hash;
                
--                else
                    
--                    hash_data_in_0 <= (others => '0');
--                    hash_data_in_1 <= (others => '0');
--                    hash_data_in_valid <= '0';

                
--                end if;
--            else
--                state <= idle;
--            end if;
        
        when Hash =>
        
            if j <= len-1 then   
                -- sig[i] <= chain(sk,0,msg[i])
                if chain_ready = '1' then
                    chain_x <= sk;
                    chain_i <= (others => '0');
                    chain_s <= STD_LOGIC_VECTOR(to_unsigned(new_message(j),16));
                    chain_valid_in <= '1';
                
                elsif chain_valid_out = '1' then    
                    sig_reg(17151-j*256 downto 16896-j*256) <= chain_tmp;
                    j <= j + 1;
                    if j = len-1 then    
                        sig <= sig_reg;
                        sig_valid <= '1';
                        
                        j <= 0;
                        state <= idle;
                    else
                        state <= sk_hash;
                    end if;
                
                else 
                    chain_x <= (others => '0');
                    chain_i <= (others => '0');
                    chain_s <= (others => '0');
                    chain_valid_in <= '0';

                    
                end if;            
            end if;

        when others =>  
    end case;
end if;
end process;
end Behavioral;