library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wots_pkFromSig is
Port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    ready           : out std_logic;
    
    sig             : in  std_logic_vector(255 downto 0);
    M               : in  std_logic_vector(255 downto 0);
    data_in_valid   : in  std_logic;
    
    pk_sig          : out std_logic_vector(255 downto 0);
    data_out_valid  : out std_logic;
    
    -- chain ports
    chain_x              : out STD_LOGIC_VECTOR(255 downto 0);
    chain_i              : out STD_LOGIC_VECTOR(15 downto 0); 
    chain_s              : out STD_LOGIC_VECTOR(15 downto 0); 
    chain_data_in_valid  : out STD_LOGIC;                     
    
    chain_ready          :  in STD_LOGIC;
    chain_tmp            :  in STD_LOGIC_VECTOR(255 downto 0);
    chain_data_out_valid :  in STD_LOGIC;
    
    -- compression core signals
    s_tdata_i      : out std_logic_vector(511 downto 0);
    s_tlast_i      : out std_logic;
    s_tvalid_i     : out std_logic;
    hash_reset     : out std_logic;
    
    s_tready_o     : in std_logic;
    digest_o       : in std_logic_vector(255 downto 0);
    digest_valid_o : in std_logic
);
end wots_pkFromSig;

architecture Behavioral of wots_pkFromSig is

-- FSM 
type state_type is (Idle, Base_2b, Checksum, Shift_Checksum, toByte, Concatenate, Sig_To_Array, Chain, Compress);
signal current_state: state_type;

-- constants
constant len1 : integer := 64;
constant len2 : integer := 3;
constant len  : integer := 67;
constant lgw  : integer := 4;
constant w    : integer := 16;

-- for loop indices
signal i : integer := 0;

-- input registers
signal sig_reg : std_logic_vector(255 downto 0) := (others => '0');
signal M_reg : std_logic_vector(255 downto 0) := (others => '0');

-- internal signals
signal csum : integer range 0 to 65535 := 0;
signal csum_ready : std_logic := '0';
signal big_arrays_init : std_logic := '0';

-- csum array
type csum_array_type is array (0 to len2-1) of std_logic_vector(3 downto 0);
signal csum_array : csum_array_type := (others => (others => '0'));

-- csum toByte registers
signal csum_reg : std_logic_vector(15 downto 0) := (others => '0');

-- message array
type message_array_type is array (0 to len1-1) of integer range 0 to 15;
signal message_array : message_array_type := (others => 0);

type con_message_array_type is array (0 to len-1) of integer range 0 to 15;
signal con_message_array : con_message_array_type := (others => 0);

-- big arrays (need to use BRAM here for synthesis)
type big_array_type is array (0 to len-1) of std_logic_vector(255 downto 0);
signal tmp_array : big_array_type := (others => (others => '0'));
signal sig_array : big_array_type := (others => (others => '0'));

-- compression signals
signal stupid_count : integer := 0;
signal compression_count : integer := 0;
signal compression_rounds : integer := len;

begin

process(clock, reset)
begin

if reset='1' then

pk_sig <= (others => '0');
data_out_valid <= '0';

current_state <= Idle;
ready <= '1';

elsif rising_edge(clock) then

    case current_state is
    
        when Idle =>
            if data_in_valid = '1' then
                ready <= '0';
                sig_reg <= sig;
                M_reg <= M;
                current_state <= Base_2b;
                   
            else
                pk_sig <= (others => '0');
                data_out_valid <= '0';
                
                current_state <= Idle;
                ready <= '1';
            
            end if;
        
        when Base_2b =>
            -- initialize checksum
            csum <= 0;
            -- convert 1024-bit message to array of 64 16-bit chunks
            for i in 0 to len1-1 loop
                message_array(i) <= to_integer(unsigned(M_reg(i*lgw+lgw-1 downto i*lgw)));
            end loop;
            current_state <= Checksum;
        
        when Checksum =>
            if i < len1 then
                csum <= csum + 15 - message_array(i);
                i <= i + 1;
            else
                current_state <= Shift_Checksum;
                i <= 0;
            end if;
        
        when Shift_Checksum =>
            csum <= to_integer(shift_left(to_unsigned(csum,16),4));
            current_state <= toByte;
        
        when toByte =>
            csum_reg <= std_logic_vector(to_unsigned(csum,16));
            csum_ready <= '1';
            if (csum_ready='1') then
                csum_array(0) <= csum_reg(3 downto 0);
                csum_array(1) <= csum_reg(7 downto 4);
                csum_array(2) <= csum_reg(11 downto 8);
                current_state <= Concatenate;
                csum_ready <= '0';
            end if;
            
        when Concatenate =>
            for i in 0 to len-1 loop
                if (i < len2) then
                    con_message_array(i) <= to_integer(unsigned(csum_array(i)));
                else    
                    con_message_array(i) <= message_array(i-3);
                end if;    
            end loop;
            current_state <= Sig_To_Array;
        
        when Sig_To_Array =>
            for i in 0 to len-1 loop
                sig_array(i) <= sig_reg;
            end loop;
            current_state <= Chain;
        
        when Chain =>
            if i < len-1 then
                if chain_ready = '1' then
                    chain_x <= sig_array(i);
                    chain_i <= std_logic_vector(to_unsigned(con_message_array(i),16));
                    chain_s <= std_logic_vector(to_unsigned(w-1-con_message_array(i),16));
                    chain_data_in_valid <= '1';
                elsif chain_data_out_valid = '1' then
                    tmp_array(i) <= chain_tmp;
                    i <= i + 1;
                else
                    chain_x <= (others => '0');
                    chain_i <= (others => '0');
                    chain_s <= (others => '0');
                    chain_data_in_valid <= '0';
                end if;
            else
                i <= 0;
                current_state <= Compress;
            end if;
        
        when Compress =>
            if s_tready_o = '1' and stupid_count = 0 and compression_count*2 < compression_rounds-1  then
                stupid_count <= stupid_count + 1;
                s_tdata_i <= tmp_array(compression_count*2) & tmp_array(compression_count*2 + 1);
                s_tvalid_i <= '1';
                s_tlast_i <= '0';
                --compression_count <= compression_count + 1;

            elsif s_tready_o = '0' and stupid_count = 1 then
                stupid_count <= 0;
                s_tvalid_i <= '0';
                
            elsif digest_valid_o = '1' and compression_count*2 = compression_rounds-1 then 
                
                pk_sig <= digest_o;
                data_out_valid <= '1';
                s_tvalid_i <= '0';
                compression_count <= 0;
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

