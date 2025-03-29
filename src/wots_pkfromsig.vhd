library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wots_pkFromSig is
    Port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        
        sig             : in  std_logic_vector(17151 downto 0);
        M               : in  std_logic_vector(255 downto 0);
        data_in_valid   : in  std_logic;
        
        ready           : out std_logic;
        pk_sig          : out std_logic_vector(255 downto 0);
        data_out_valid  : out std_logic;
        
        -- chain ports go here
        chain_reset     : out STD_LOGIC;                     
        chain_x         : out STD_LOGIC_VECTOR(255 downto 0);
        chain_i         : out STD_LOGIC_VECTOR(15 downto 0); 
        chain_s         : out STD_LOGIC_VECTOR(15 downto 0); 
        chain_valid_in  : out STD_LOGIC;                     
        chain_tmp       : in  STD_LOGIC_VECTOR(255 downto 0);
        chain_valid_out : in  STD_LOGIC;                     
        chain_ready     : in  STD_LOGIC;
        
        -- compression ports go here
        s_tdata_i       : out std_logic_vector(511 downto 0);
        s_tlast_i       : out std_logic;
        s_tvalid_i      : out std_logic;
        hash_reset      : out std_logic;
        s_tready_o      : in  std_logic;
        digest_o        : in  std_logic_vector(255 downto 0);
        digest_valid_o  : in  std_logic                   
    );
end wots_pkFromSig;

architecture Behavioral of wots_pkFromSig is

-- FSM stuff
type state_type is (Idle, Base_2b, Checksum, Shift_Checksum, toByte, Chain, Compress);
signal current_state: state_type;

-- internal signals go here
constant lgw: integer := 4;
constant w: integer := 16;
constant len1: integer := 64;
constant len2: integer := 3;
constant len: integer := 67;

signal sig_reg : std_logic_vector(17151 downto 0) := (others => '0');
signal M_reg   : std_logic_vector(255 downto 0) := (others => '0');

signal csum: std_logic_vector(15 downto 0) := (others => '0');
signal tmp: std_logic_vector(255 downto 0) := (others => '0');
signal pk_sig_reg: std_logic_vector(255 downto 0) := (others => '0');

-- for loop indices
signal i, j, k: integer := 0;

-- base_2b array
type message_array_type is array (0 to len1-1) of integer range 0 to 16;
signal message : message_array_type := (others => 0);

-- sig array
type sig_array_type is array (0 to len-1) of std_logic_vector(255 downto 0);
signal sig_array : sig_array_type := (others => (others => '0'));

-- tmp array
type tmp_array_type is array (0 to len-1) of std_logic_vector(255 downto 0);
signal tmp_array : tmp_array_type := (others => (others => '0'));

-- compression signals
signal stupid_count : integer := 0;
signal compression_count : integer := 0;
signal compression_rounds : integer := len;
signal loop_count : integer := 0;

---- toByte signals
--constant string_length : integer := (len2*lgw)/8;
--signal total : integer := 0;

--type toByte_array_type is array (0 to string_length-1) of std_logic_vector(7 downto 0);
--signal S : toByte_array_type := (others => "00000000");


begin

process(clock, reset)
begin

if reset='1' then

-- set all outputs to zero
pk_sig <= (others => '0');
data_out_valid <= '0';
ready <= '0';

chain_reset <= '1';     
chain_x <= (others => '0');        
chain_i <= (others => '0');        
chain_s <= (others => '0');        
chain_valid_in <= '0';

s_tdata_i <= (others => '0');
s_tlast_i <= '0';
s_tvalid_i <= '0';
hash_reset <= '0';

current_state <= Idle;
                    
elsif rising_edge(clock) then

case current_state is

    when Idle =>
        
        if data_in_valid <= '1' then
            ready <= '0';
            current_state <= Base_2b;
            
            sig_reg <= sig;          
            M_reg <= M;      

        else
            pk_sig <= (others => '0');
            data_out_valid <= '0';
            ready <= '1';
            current_state <= idle;
        end if;
    
    when Base_2b =>
        -- initialize checksum
        csum <= (others => '0');
        
        -- convert message to base w
        for i in 0 to len1-1 loop
                message(i) <= to_integer(unsigned(M_reg(i*lgw+lgw-1 downto i*lgw)));
        end loop;
        
        current_state <= Checksum;
        
    when Checksum => 
        -- compute checksum
        if (i < len1 - 1) then
            csum <= STD_LOGIC_VECTOR(to_unsigned((to_integer(signed(csum)) + w - 1 - message(i)),16));
            i <= i + 1;
        else
            current_state <= Shift_Checksum;
        end if;
        
            
    when Shift_Checksum =>
        -- left-shift checksum by 4
        csum <= std_logic_vector(shift_left(unsigned(csum), 4));
        -- current_state <= toByte;
        current_state <= Chain;
   
    -- currently not utilizing the toByte function, we are hard-coding our checksum but
    -- may need to change this once we begin editing our parameter values
--    when toByte =>
--        total <= to_integer(unsigned(csum));
--        if k < string_length-1 then
--            S(string_length-1-k) <= 
--            total <= shift_right(total, 8);
--            k <= k+1;
--        end if; 
        
    when Chain =>
        -- sig[i] <= chain(sk,0,msg[i])
        if j < len1-1 then
            if chain_ready = '1' then
                chain_x <= sig_reg(17151-j*256 downto 16896-j*256);
                chain_i <= STD_LOGIC_VECTOR(to_unsigned(message(j),16));
                chain_s <= STD_LOGIC_VECTOR(to_unsigned(w-1-message(j),16));
                chain_valid_in <= '1';
                
            elsif chain_valid_out = '1' then
                -- tmp(17151-j*256 downto 16896-j*256) <= chain_tmp;
                tmp_array(j) <= chain_tmp;
                j <= j + 1;
                current_state <= Compress;
            
            else 
                chain_x <= (others => '0');
                chain_i <= (others => '0');
                chain_s <= (others => '0');
                chain_valid_in <= '0';
            end if;
        end if;
    
    when Compress =>
        if s_tready_o = '1' and stupid_count = 0 and compression_count < compression_rounds  then
            stupid_count <= stupid_count + 1;
            s_tdata_i <= tmp_array(compression_count) & tmp_array(compression_count + 1); 
            s_tvalid_i <= '1';
            s_tlast_i <= '0';
            --compression_count <= compression_count + 1;
        
        elsif s_tready_o = '0' and stupid_count = 1 then
            stupid_count <= 0;
            s_tvalid_i <= '0';
        elsif digest_valid_o = '1' and compression_count = compression_rounds-1 then 
            
            pk_sig <= digest_o;
            data_out_valid <= '1';
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
    
end case;
end if;
end process;
end Behavioral;


