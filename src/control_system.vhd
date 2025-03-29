library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_system is
  Port (
    clock : in std_logic;
    reset : in std_logic;
    
    -- xmss_node & wots_sign ports
    --op_input           : in std_logic_vector(1 downto 0);
    node_secret_seed   : in std_logic_vector(255 downto 0);
    message_in         : in std_logic_vector(255 downto 0);
    --node_target_height : in std_logic_vector(15 downto 0);
    node_target_index  : in std_logic_vector(15 downto 0);
    node_valid_in      : in std_logic;
    
    
    
    
    --op_out             : out std_logic_vector(1 downto 0);
    --node_out           : out std_logic_vector(255 downto 0);
    sig_xmss_out       : out std_logic_vector(256*8 + 67*256 -1 downto 0);
    node_valid_out     : out std_logic;
    node_ready         : out std_logic                   
  );
end control_system;

architecture Behavioral of control_system is

component sha256_stream
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        mode      : in  std_logic;
        s_tdata_i : in  std_logic_vector(511 downto 0); -- Adjust data width as needed
        s_tlast_i : in  std_logic;
        s_tvalid_i: in  std_logic;
        s_tready_o     : out std_logic;
        digest_o       : out std_logic_vector(255 downto 0); -- Adjust digest width as needed
        digest_valid_o : out std_logic
    );
end component sha256_stream;

-- xmss_node to bram
signal we_bram_xmss : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
signal addr_bram_xmss : STD_LOGIC_VECTOR(8 DOWNTO 0) := (others => '0');
signal din_bram_xmss : STD_LOGIC_VECTOR(255 DOWNTO 0) := (others => '0');
signal dout_bram_xmss : STD_LOGIC_VECTOR(255 DOWNTO 0) := (others => '0');


-- HASH MUX SIGNALS 
-- xmss_node to mux
signal hash_reset_xmss_node         :  std_logic;
signal hash_mode_xmss_node          :  std_logic;
signal hash_data_in_0_xmss_node     :  std_logic_vector(255 downto 0);
signal hash_data_in_1_xmss_node     :  std_logic_vector(255 downto 0);
signal hash_data_in_2_xmss_node     :  std_logic_vector(255 downto 0);
signal hash_data_in_3_xmss_node     :  std_logic_vector(255 downto 0);
signal hash_data_in_valid_xmss_node :  std_logic;


-- chain to mux
signal hash_reset_chain         : std_logic;
signal hash_mode_chain          : std_logic;
signal hash_data_in_0_chain     : std_logic_vector(255 downto 0);
signal hash_data_in_1_chain     : std_logic_vector(255 downto 0);
signal hash_data_in_2_chain     : std_logic_vector(255 downto 0);
signal hash_data_in_3_chain     : std_logic_vector(255 downto 0);
signal hash_data_in_valid_chain : std_logic;

--wots_sign to mux
signal hash_reset_wots_sign         : std_logic;
signal hash_mode_wots_sign          : std_logic;
signal hash_data_in_0_wots_sign     : std_logic_vector(255 downto 0);
signal hash_data_in_1_wots_sign     : std_logic_vector(255 downto 0);
signal hash_data_in_2_wots_sign     : std_logic_vector(255 downto 0);
signal hash_data_in_3_wots_sign     : std_logic_vector(255 downto 0);
signal hash_data_in_valid_wots_sign : std_logic;

-- xmss_pkFromSig to mux    
signal hash_reset_xmss_pkFromSig         : std_logic;                            
signal hash_mode_xmss_pkFromSig          : std_logic;                     
signal hash_data_in_0_xmss_pkFromSig     : std_logic_vector(255 downto 0);
signal hash_data_in_1_xmss_pkFromSig     : std_logic_vector(255 downto 0);
signal hash_data_in_2_xmss_pkFromSig     : std_logic_vector(255 downto 0);
signal hash_data_in_3_xmss_pkFromSig     : std_logic_vector(255 downto 0);
signal hash_data_in_valid_xmss_pkFromSig : std_logic;                     
signal hash_out_xmss_pkFromSig           : std_logic_vector(255 downto 0);
signal hash_valid_xmss_pkFromSig         : std_logic;                     
signal hash_ready_xmss_pkFromSig         : std_logic;                     

-- mux to triangle hash wires
signal node_hash_reset : std_logic := '0';
signal node_hash_mode : std_logic := '0';
signal node_data_in_0 : std_logic_vector(255 downto 0) := (others => '0');
signal node_data_in_1 : std_logic_vector(255 downto 0) := (others => '0');
signal node_data_in_2 : std_logic_vector(255 downto 0) := (others => '0');
signal node_data_in_3 : std_logic_vector(255 downto 0) := (others => '0');
signal node_data_in_valid : std_logic := '0';
-- HASH MUX SIGNALS 

--WOTS SIGN SIGNALS

-- wots_sign to xmss_sign
signal message_wots_sign   : std_logic_vector(255 downto 0) := (others => '0');
signal sk_seed_wots_sign   : std_logic_vector(255 downto 0) := (others => '0');
signal valid_in_wots_sign  : std_logic := '0';
signal ready_wots_sign     : std_logic := '0';
signal sig_wots_sign       : std_logic_vector(17151 downto 0) := (others => '0');
signal sig_valid_wots_sign : std_logic := '0';

-- wots sign to chain mux        
signal chain_reset_wots_sign     : std_logic := '0';
signal x_wots_sign               :  STD_LOGIC_VECTOR(255 downto 0);
signal i_wots_sign               :  STD_LOGIC_VECTOR(15 downto 0); 
signal s_wots_sign               :  STD_LOGIC_VECTOR(15 downto 0); 
signal chain_valid_in_wots_sign  :  STD_LOGIC;                       


-- WOTS SIGN SIGNALS 

-- control output signals
signal node_hash_out : std_logic_vector(255 downto 0) := (others => '0');
signal node_hash_valid : std_logic := '0';
signal node_hash_ready : std_logic := '0';


-- WOTS PK GEN SIGNALS

-- xmss_node to wots_pkGen
signal sk_seed_wots_pkGen : std_logic_vector(255 downto 0) := (others => '0');
signal valid_in_wots_pkGen : std_logic := '0';

signal pk_wots_pkGen : std_logic_vector(255 downto 0) := (others => '0');
signal valid_out_wots_pkGen : std_logic := '0';
signal ready_wots_pkGen : std_logic := '0';


-- wots_pkGen to chain mux
signal x_wots_pkGen              : std_logic_vector(255 downto 0):= (others => '0');
signal i_wots_pkGen              : std_logic_vector(15 downto 0) := (others => '0');
signal s_wots_pkGen              : std_logic_vector(15 downto 0) := (others => '0');
signal chain_valid_in_wots_pkGen : std_logic := '0';
 
signal tmp_wots_chain : std_logic_vector(255 downto 0) := (others => '0');
signal valid_out_wots_chain : std_logic := '0';
signal ready_wots_chain : std_logic := '0';


-- _wots_pkGen to compression mux
signal s_tdata_i_wots_pkGen : std_logic_vector(511 downto 0) := (others => '0');
signal s_tlast_i_wots_pkGen : std_logic := '0';
signal s_tvalid_i_wots_pkGen : std_logic := '0';
signal hash_reset_wots_pkGen : std_logic := '0';

signal s_tready_o : std_logic := '0';
signal digest_o : std_logic_vector(255 downto 0) := (others => '0');
signal digest_valid_o : std_logic := '0';

-- wots_pkGen to chain mux

-- WOTS PK GEN SIGNALS 


-- chain mux outputs 
signal x_chain_mux           :  STD_LOGIC_VECTOR(255 downto 0) := (others => '0');
signal i_chain_mux           :  STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
signal s_chain_mux           :  STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
signal valid_in_chain_mux    :  STD_LOGIC := '0';

-- xmss_node inputs
signal sk_seed_xmss_node   : std_logic_vector(255 downto 0) := (others => '0');
signal k_xmss_node         : std_logic_vector(15 downto 0) := (others => '0');
signal j_xmss_node         : std_logic_vector(15 downto 0) := (others => '0');
signal valid_in_xmss_node  : std_logic := '0';

--xmss_node outputs 
signal xmss_node_hash_out   : std_logic_vector(255 downto 0) := (others => '0');
signal xmss_node_hash_valid : std_logic := '0';
signal xmss_node_hash_ready : std_logic := '0';

-- xmss_pkFromSig inputs
signal message  :  STD_LOGIC_VECTOR (255 downto 0);  
signal sig      :  STD_LOGIC_VECTOR (19199 downto 0);  
signal idx      :  STD_LOGIC_VECTOR (15 downto 0);   
signal valid_in :  STD_LOGIC;  

-- xmss_pkFromSig outputs
signal pk        : STD_LOGIC_VECTOR (255 downto 0);
signal valid_out : STD_LOGIC;                      
signal ready     : STD_LOGIC;      

-- xmss_pkFromSig to wots_pkFromSig signals
signal sig_wots_pkFromSig       : STD_LOGIC_VECTOR (17151 downto 0);
signal message_wots_pkFromSig   : STD_LOGIC_VECTOR (255 downto 0);  
signal valid_in_wots_pkFromSig  : STD_LOGIC;                        
signal pk_wots_pkFromSig        : STD_LOGIC_VECTOR (255 downto 0);  
signal valid_out_wots_pkFromSig : STD_LOGIC;                        
signal ready_wots_pkFromSig     : STD_LOGIC;                                                         
                                         
-- wots_pkFromSig to chain mux           
signal chain_x_wots_pkFromSig             : STD_LOGIC_VECTOR(255 downto 0); 
signal chain_i_wots_pkFromSig             : STD_LOGIC_VECTOR(15 downto 0);  
signal chain_s_wots_pkFromSig             : STD_LOGIC_VECTOR(15 downto 0);  
signal chain_data_in_valid_wots_pkFromSig : STD_LOGIC;                      

-- wots_pkFromSig to chain output                  
signal chain_ready_wots_pkFromSig          :  STD_LOGIC;                     
signal chain_tmp_wots_pkFromSig            :  STD_LOGIC_VECTOR(255 downto 0);
signal chain_data_out_valid_wots_pkFromSig :  STD_LOGIC;                     

-- wots_pkFromSig to compression mux
signal s_tdata_i_wots_pkFromSig  : std_logic_vector(511 downto 0);
signal s_tlast_i_wots_pkFromSig  : std_logic;                     
signal s_tvalid_i_wots_pkFromSig : std_logic;                     
signal hash_reset_wots_pkFromSig : std_logic;                     

-- compression output
signal node_s_tready_o     : std_logic;                     
signal node_digest_o       : std_logic_vector(255 downto 0);
signal node_digest_valid_o : std_logic;    

-- compression mux to compression core 
signal node_s_tdata_i  : std_logic_vector(511 downto 0);
signal node_s_tlast_i  : std_logic;                     
signal node_s_tvalid_i : std_logic;                                  

begin

my_compression_mux : entity work.compression_input_mux
    Port map (
        clock => clock,
        reset => reset,
        
        s_tdata_i_wots_pkGen  => s_tdata_i_wots_pkGen ,
        s_tlast_i_wots_pkGen  => s_tlast_i_wots_pkGen ,
        s_tvalid_i_wots_pkGen => s_tvalid_i_wots_pkGen,
        
        s_tdata_i_wots_pkFromSig  => s_tdata_i_wots_pkFromSig ,
        s_tlast_i_wots_pkFromSig  => s_tlast_i_wots_pkFromSig ,
        s_tvalid_i_wots_pkFromSig => s_tvalid_i_wots_pkFromSig,
        
        s_tdata_i  => node_s_tdata_i ,
        s_tlast_i  => node_s_tlast_i ,
        s_tvalid_i => node_s_tvalid_i
    );

compresion_core: sha256_stream
    port map (
        clk       => clock,
        rst       => reset,
        mode      => '1',
        
        s_tdata_i => node_s_tdata_i,
        s_tlast_i => node_s_tlast_i,
        s_tvalid_i => node_s_tvalid_i,
        
        s_tready_o => node_s_tready_o,
        digest_o   => node_digest_o,
        digest_valid_o => node_digest_valid_o
    );

my_bram_xmss_node : entity work.my_bram_xmss_node_2
port map(
    clka => clock,
    ena => '1',
    wea => we_bram_xmss,
    addra => addr_bram_xmss,
    dina => din_bram_xmss,
    douta => dout_bram_xmss
);



my_chain : entity work.chain

port map(

clock => clock,
reset => reset,

x        => x_chain_mux       ,
i        => i_chain_mux       ,
s        => s_chain_mux       ,
valid_in => valid_in_chain_mux,

tmp       => tmp_wots_chain,
valid_out => valid_out_wots_chain,
ready     => ready_wots_chain,

-- triangle hash signals
hash_reset =>          hash_reset_chain        ,
hash_mode =>           hash_mode_chain         ,
hash_data_in_0 =>      hash_data_in_0_chain    ,
hash_data_in_1 =>      hash_data_in_1_chain    ,
hash_data_in_2 =>      hash_data_in_2_chain    ,
hash_data_in_3 =>      hash_data_in_3_chain    ,
hash_data_in_valid  => hash_data_in_valid_chain,

digest  =>      node_hash_out,
digest_valid => node_hash_valid,
hash_ready =>   node_hash_ready
);

my_hash_mux : entity work.hash_input_mux
    port map (
        
        clock => clock,
        reset => reset,
        
        -- xmss_node inputs
        hash_reset_xmss_node     => hash_reset_xmss_node,
        hash_mode_xmss_node          => hash_mode_xmss_node,
        hash_data_in_0_xmss_node     => hash_data_in_0_xmss_node,
        hash_data_in_1_xmss_node     => hash_data_in_1_xmss_node,
        hash_data_in_2_xmss_node     =>  hash_data_in_2_xmss_node,
        hash_data_in_3_xmss_node     => hash_data_in_3_xmss_node,
        hash_data_in_valid_xmss_node => hash_data_in_valid_xmss_node,

        -- chain inputs
        hash_reset_chain         => hash_reset_chain        ,
        hash_mode_chain          => hash_mode_chain         ,
        hash_data_in_0_chain     => hash_data_in_0_chain    ,
        hash_data_in_1_chain     => hash_data_in_1_chain    ,
        hash_data_in_2_chain     => hash_data_in_2_chain    ,
        hash_data_in_3_chain     => hash_data_in_3_chain    ,
        hash_data_in_valid_chain => hash_data_in_valid_chain,
        
        --wots_sign inputs
        hash_reset_wots_sign         => hash_reset_wots_sign        ,
        hash_mode_wots_sign          => hash_mode_wots_sign         ,
        hash_data_in_0_wots_sign     => hash_data_in_0_wots_sign    ,
        hash_data_in_1_wots_sign     => hash_data_in_1_wots_sign    ,
        hash_data_in_2_wots_sign     => hash_data_in_2_wots_sign    ,
        hash_data_in_3_wots_sign     => hash_data_in_3_wots_sign    ,
        hash_data_in_valid_wots_sign => hash_data_in_valid_wots_sign,

        -- xmss_pkFromSig inputs
        hash_mode_xmss_pkFromSig          => hash_mode_xmss_pkFromSig         ,
        hash_data_in_0_xmss_pkFromSig     => hash_data_in_0_xmss_pkFromSig    ,
        hash_data_in_1_xmss_pkFromSig     => hash_data_in_1_xmss_pkFromSig    ,
        hash_data_in_2_xmss_pkFromSig     => hash_data_in_2_xmss_pkFromSig    ,
        hash_data_in_3_xmss_pkFromSig     => hash_data_in_3_xmss_pkFromSig    ,
        hash_data_in_valid_xmss_pkFromSig => hash_data_in_valid_xmss_pkFromSig,
        
        -- outputs
        hash_reset         => node_hash_reset,
        hash_mode          => node_hash_mode,
        hash_data_in_0     => node_data_in_0,
        hash_data_in_1     => node_data_in_1,
        hash_data_in_2     => node_data_in_2,
        hash_data_in_3     => node_data_in_3,
        hash_data_in_valid => node_data_in_valid
    );


my_hash_unit: entity work.triangle_hash_unit
  port map (
    clk => clock,
    reset => reset,
        
    mode => node_hash_mode,
    data_in_0 => node_data_in_0,
    data_in_1 => node_data_in_1,
    data_in_2 => node_data_in_2,
    data_in_3 => node_data_in_3,
        
    data_in_valid => node_data_in_valid,
        
    hash_out   => node_hash_out,
    hash_valid => node_hash_valid,
    ready      => node_hash_ready
  );
  
my_wots_pkGen : entity work.wots_pkGen
    port map(
    
    -- inputs 
    clk => clock,
    reset => reset,
    sk_seed => sk_seed_wots_pkGen,
    valid_in => valid_in_wots_pkGen,
        
    -- wots_chain signals 
    x_wots_chain => x_wots_pkGen,
    i_wots_chain => i_wots_pkGen,
    s_wots_chain => s_wots_pkGen,
    valid_in_wots_chain => chain_valid_in_wots_pkGen,
    
    
    -- chain 
    tmp_wots_chain => tmp_wots_chain,
    valid_out_wots_chain => valid_out_wots_chain,
    ready_wots_chain => ready_wots_chain,
    
    
    -- compression core signals
        
        s_tdata_i =>  s_tdata_i_wots_pkGen ,
        s_tlast_i =>  s_tlast_i_wots_pkGen ,
        s_tvalid_i => s_tvalid_i_wots_pkGen,
        
        s_tready_o => node_s_tready_o,
        digest_o   => node_digest_o,
        digest_valid_o => node_digest_valid_o,

        -- wots outputs connected to xmss_node
        pk       => pk_wots_pkGen,
        valid_out => valid_out_wots_pkGen,
        ready    => ready_wots_pkGen
    );


my_xmss_node: entity work.xmss_node(behavioral)
  port map (
    clock => clock,
    reset => reset,
    
    secret_seed   => sk_seed_xmss_node ,
    target_height => j_xmss_node       ,
    target_index  => k_xmss_node       ,
    valid_in      => valid_in_xmss_node,
    
    node_out =>  xmss_node_hash_out  ,
    valid_out => xmss_node_hash_valid,
    ready =>     xmss_node_hash_ready,
    
    -- ram ports
    we_bram => we_bram_xmss,
    addr_bram => addr_bram_xmss,
    din_bram => din_bram_xmss,
    dout_bram => dout_bram_xmss,

    
    -- hash unit ports
    hash_reset =>          hash_reset_xmss_node        ,
    hash_mode =>           hash_mode_xmss_node         ,
    hash_data_in_0 =>      hash_data_in_0_xmss_node    ,
    hash_data_in_1 =>      hash_data_in_1_xmss_node    ,
    hash_data_in_2 =>      hash_data_in_2_xmss_node    ,
    hash_data_in_3 =>      hash_data_in_3_xmss_node    ,
    hash_data_in_valid =>  hash_data_in_valid_xmss_node,
    
    -- wots_pkGen ports
    sk_seed_wots_pkGen  => sk_seed_wots_pkGen,
    valid_in_wots_pkGen => valid_in_wots_pkGen,
    
    pk_wots_pkGen        => pk_wots_pkGen,
    valid_out_wots_pkGen => valid_out_wots_pkGen,
    ready_wots_pkGen     => ready_wots_pkGen,
    
    
    
    hash_out   => node_hash_out,
    hash_valid => node_hash_valid,
    hash_ready => node_hash_ready
  );
  
  
  my_chain_mux : entity work.chain_input_mux(behavioral)
    port map(
        clock => clock,
        reset => reset,
        
        -- wots_sign inputs
        x_wots_sign           => x_wots_sign             ,
        i_wots_sign           => i_wots_sign             ,
        s_wots_sign           => s_wots_sign             ,
        valid_in_wots_sign    => chain_valid_in_wots_sign,

        -- wots_pkGen inputs
        x_wots_pkGen           => x_wots_pkGen             ,
        i_wots_pkGen           => i_wots_pkGen             ,
        s_wots_pkGen           => s_wots_pkGen             ,
        valid_in_wots_pkGen    => chain_valid_in_wots_pkGen,
          
        -- wots_pkFromSig inputs
        x_wots_pkFromSig        => chain_x_wots_pkFromSig       ,
        i_wots_pkFromSig        => chain_i_wots_pkFromSig       ,
        s_wots_pkFromSig        => chain_s_wots_pkFromSig       ,
        valid_in_wots_pkFromSig => chain_data_in_valid_wots_pkFromSig,      
                
        -- outputs
        x           => x_chain_mux        ,
        i           => i_chain_mux        ,
        s           => s_chain_mux        ,
        valid_in    => valid_in_chain_mux 
    );
  
  my_wots_sign : entity work.wots_sign(behavioral)
    port map(
        clock           => clock,
        reset           => reset,
        
        M               => message_wots_sign,
        SK_seed         => sk_seed_wots_sign,
        data_in_valid   => valid_in_wots_sign,
        
        ready           => ready_wots_sign,
        sig             => sig_wots_sign,
        sig_valid       => sig_valid_wots_sign,
        
        -- triangle hash signals
        hash_reset         => hash_reset_wots_sign        ,
        hash_mode          => hash_mode_wots_sign         ,
        hash_data_in_0     => hash_data_in_0_wots_sign    ,
        hash_data_in_1     => hash_data_in_1_wots_sign    ,
        hash_data_in_2     => hash_data_in_2_wots_sign    ,
        hash_data_in_3     => hash_data_in_3_wots_sign    ,
        hash_data_in_valid => hash_data_in_valid_wots_sign,
        
        digest           => node_hash_out,  
        digest_valid     => node_hash_valid,
        hash_ready       => node_hash_ready, 
        
        -- chain signals go here
        chain_reset     => chain_reset_wots_sign,                    
        chain_x         => x_wots_sign             ,
        chain_i         => i_wots_sign             ,
        chain_s         => s_wots_sign             ,
        chain_valid_in  => chain_valid_in_wots_sign,
        
        chain_tmp       => tmp_wots_chain,      
        chain_valid_out => valid_out_wots_chain,
        chain_ready     => ready_wots_chain  

    
    );

my_xmss_sign : entity work.xmss_sign(behavioral)
    port map(
           clk => clock,
           rst => reset,
           
           message => message_in,
           sk_seed => node_secret_seed,
           idx => node_target_index,
           valid_in => node_valid_in,
           
           -- xmss_node signals
           sk_seed_xmss_node  => sk_seed_xmss_node ,
           k_xmss_node        => k_xmss_node       ,
           j_xmss_node        => j_xmss_node       ,
           valid_in_xmss_node => valid_in_xmss_node,
           
           node_out_xmss_node  => xmss_node_hash_out  ,
           valid_out_xmss_node => xmss_node_hash_valid,
           ready_xmss_node     => xmss_node_hash_ready,
           
           -- wots_sign signals
           message_wots_sign   => message_wots_sign  ,
           sk_seed_wots_sign   => sk_seed_wots_sign   ,
           valid_in_wots_sign  => valid_in_wots_sign  ,
           sig_wots_sign       => sig_wots_sign     ,
           valid_out_wots_sign => sig_valid_wots_sign        ,
           ready_wots_sign     => ready_wots_sign  ,
           
           -- xmss_sign outputs
           sig_xmss => sig_xmss_out,
           valid_out => node_valid_out,
           ready => node_ready
    );
    
my_xmss_pkFromSig : entity work.xmss_pkFromSig
    Port map (
        clk => clock,
        reset => reset,
        
        message  => message ,
        sig      => sig     ,
        idx      => idx     ,
        valid_in => valid_in,
        
        pk        => node_hash_out,  
        valid_out => node_hash_valid,
        ready     => node_hash_ready, 
        
        -- wots_pkFromSig signals
        sig_wots_pkFromSig       => sig_wots_pkFromSig      ,
        message_wots_pkFromSig   => message_wots_pkFromSig  ,
        valid_in_wots_pkFromSig  => valid_in_wots_pkFromSig ,
        pk_wots_pkFromSig        => pk_wots_pkFromSig       ,
        valid_out_wots_pkFromSig => valid_out_wots_pkFromSig,
        ready_wots_pkFromSig     => ready_wots_pkFromSig    , 
        
        -- triangle hash signals
        hash_mode          => hash_mode_xmss_pkFromSig         ,
        hash_data_in_0     => hash_data_in_0_xmss_pkFromSig    ,
        hash_data_in_1     => hash_data_in_1_xmss_pkFromSig    ,
        hash_data_in_2     => hash_data_in_2_xmss_pkFromSig    ,
        hash_data_in_3     => hash_data_in_3_xmss_pkFromSig    ,
        hash_data_in_valid => hash_data_in_valid_xmss_pkFromSig,
        hash_out           => hash_out_xmss_pkFromSig          ,
        hash_valid         => hash_valid_xmss_pkFromSig        ,
        hash_ready         => hash_ready_xmss_pkFromSig        
    );
    
my_wots_pkFromSig : entity work.wots_pkFromSig
    Port map (
        clock          => clock,
        reset          => reset,
        
        ready          => ready_wots_pkFromSig          ,        
        sig            => sig_wots_pkFromSig            ,
        M              => message_wots_pkFromSig             ,
        data_in_valid  => valid_in_wots_pkFromSig ,
                          
        pk_sig         => pk_wots_pkFromSig        ,
        data_out_valid => valid_out_wots_pkFromSig,
        
        -- chain
        chain_x             => chain_x_wots_pkFromSig            ,
        chain_i             => chain_i_wots_pkFromSig            ,
        chain_s             => chain_s_wots_pkFromSig            ,
        chain_valid_in => chain_data_in_valid_wots_pkFromSig,
        
        chain_ready          => node_hash_ready  ,
        chain_tmp            => node_hash_out,
        chain_valid_out => node_hash_valid ,
        
        -- compression
        s_tdata_i      => s_tdata_i_wots_pkFromSig ,
        s_tlast_i      => s_tlast_i_wots_pkFromSig ,
        s_tvalid_i     => s_tvalid_i_wots_pkFromSig,
        hash_reset     => hash_reset_wots_pkFromSig,
                        
        s_tready_o     => node_s_tready_o    ,
        digest_o       => node_digest_o      ,
        digest_valid_o => node_digest_valid_o
    );
    
end Behavioral;


