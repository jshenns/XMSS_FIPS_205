library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity triangle_hash_unit is
    port (
        clk          : in  std_logic;                   -- Clock input
        reset        : in  std_logic;                   -- Synchronous reset input
        
        mode         : in  std_logic; -- Mode input
        data_in_0    : in  std_logic_vector(255 downto 0); -- First 256-bit input vector
        data_in_1    : in  std_logic_vector(255 downto 0); -- Second 256-bit input vector
        data_in_2    : in  std_logic_vector(255 downto 0); -- Third 256-bit input vector
        data_in_3    : in  std_logic_vector(255 downto 0); -- Fourth 256-bit input vector
        
        data_in_valid : in std_logic;
        
        hash_out     : out std_logic_vector(255 downto 0); -- 256-bit hash output
        hash_valid   : out std_logic;                   -- Indicates when hash_out is valid
        ready        : out std_logic                    -- Indicates readiness to receive data
    );
end entity triangle_hash_unit;

architecture Behavioral of triangle_hash_unit is

    -- le inputs reg
    signal data_reg_0 : std_logic_vector(255 downto 0) := (others => '0');
    signal data_reg_1 : std_logic_vector(255 downto 0) := (others => '0');
    signal data_reg_2 : std_logic_vector(255 downto 0) := (others => '0');
    signal data_reg_3 : std_logic_vector(255 downto 0) := (others => '0');

    -- le pipeline reg
    signal hash_0_reg : std_logic_vector(255 downto 0) := (others => '0');
    signal hash_1_reg : std_logic_vector(255 downto 0) := (others => '0');
--    signal hash_2_reg : std_logic_vector(255 downto 0) := (others => '0');
    
    
-- SHA2-256 connection signals for instance 0
    signal s_tdata_i_0    : std_logic_vector(511 downto 0) := (others => '0');
    signal s_tlast_i_0    : std_logic := '0';
    signal s_tvalid_i_0    : std_logic := '0';
    signal s_tready_o_0    : std_logic := '0';
    signal digest_o_0      : std_logic_vector(255 downto 0) := (others => '0');
    signal digest_valid_o_0 : std_logic := '0';

    -- SHA2-256 connection signals for instance 1
    signal s_tdata_i_1    : std_logic_vector(511 downto 0) := (others => '0');
    signal s_tlast_i_1    : std_logic := '0';
    signal s_tvalid_i_1    : std_logic := '0';
    signal s_tready_o_1    : std_logic := '0';
    signal digest_o_1      : std_logic_vector(255 downto 0) := (others => '0');
    signal digest_valid_o_1 : std_logic := '0';

    -- SHA2-256 connection signals for instance 2
    signal s_tdata_i_2    : std_logic_vector(511 downto 0) := (others => '0');
    signal s_tlast_i_2    : std_logic := '0';
    signal s_tvalid_i_2    : std_logic := '0';
    signal s_tready_o_2    : std_logic := '0';
    signal digest_o_2      : std_logic_vector(255 downto 0) := (others => '0');
    signal digest_valid_o_2 : std_logic := '0';
    
    -- state machine stuff
    type state_type is (idle, hash_01, hash_2);  -- Define the state type
    signal state : state_type := idle;       -- Declare the state signal, initialized to idle
    signal next_state : state_type;          -- Declare a signal to hold the next state


    -- reset the hash cores
    signal hash_core_reset : std_logic := '0';
    
    -- register the mode
    signal mode_reg : std_logic := '0';
        
component sha256_stream
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        mode      : in  std_logic;
        s_tdata_i : in  std_logic_vector(511 downto 0); -- Adjust data width as needed
        s_tlast_i : in  std_logic;
        s_tvalid_i: in  std_logic;
        s_tready_o: out std_logic;
        digest_o  : out std_logic_vector(255 downto 0); -- Adjust digest width as needed
        digest_valid_o: out std_logic
    );
end component sha256_stream;


begin


-- SHA256 Stream Instance 0
sha256_stream_inst0: sha256_stream
    port map (
        clk       => clk,
        rst       => hash_core_reset,
        mode      => '1',
        s_tdata_i => s_tdata_i_0,
        s_tlast_i => s_tlast_i_0,
        s_tvalid_i => s_tvalid_i_0,
        s_tready_o => s_tready_o_0,
        digest_o   => digest_o_0,
        digest_valid_o => digest_valid_o_0
    );

-- SHA256 Stream Instance 1
sha256_stream_inst1: sha256_stream
    port map (
        clk       => clk,
        rst       => hash_core_reset,
        mode      => '1',
        s_tdata_i => s_tdata_i_1,
        s_tlast_i => s_tlast_i_1,
        s_tvalid_i => s_tvalid_i_1,
        s_tready_o => s_tready_o_1,
        digest_o   => digest_o_1,
        digest_valid_o => digest_valid_o_1
    );

-- SHA256 Stream Instance 2
sha256_stream_inst2: sha256_stream
    port map (
        clk       => clk,
        rst       => hash_core_reset,
        mode      => '1',
        s_tdata_i => s_tdata_i_2,
        s_tlast_i => s_tlast_i_2,
        s_tvalid_i => s_tvalid_i_2,
        s_tready_o => s_tready_o_2,
        digest_o   => digest_o_2,
        digest_valid_o => digest_valid_o_2
    );
    
    
    
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset logic
            hash_out   <= (others => '0');
            hash_valid <= '0';
            ready      <= '0';
            hash_core_reset <= '1';

        elsif rising_edge(clk) then
                 case state is
            when idle =>
                    
                    s_tvalid_i_0 <= '0';
                    s_tlast_i_0 <= '0';
                    
                    s_tvalid_i_1 <= '0';
                    s_tlast_i_1 <= '0';
                    
                    s_tlast_i_2 <= '0';
                    s_tvalid_i_2 <= '0';
                
                if data_in_valid = '1' then 

                    ready <= '0';
                    data_reg_0 <= data_in_0;
                    data_reg_1 <= data_in_1;
                    data_reg_2 <= data_in_2;
                    data_reg_3 <= data_in_3;
                    mode_reg <= mode;
                    
                    
                    if mode = '1'  then
                        state <= hash_01;
                    else
                        state <= hash_2; -- Transition to hash_2 if mode is not 1
                    end if;
                else
                    state <= idle;
                    ready <= '1';

                    hash_valid <= '0';
                    hash_out <= (others => '0');
                    
                    
                end if;
                hash_valid <= '0';
                hash_core_reset <= '0';
            when hash_01 =>
                -- Actions for hash_01 state
               
                                
                if s_tready_o_0 = '1' and s_tready_o_1 = '1' and digest_valid_o_0 = '0' and digest_valid_o_1 = '0' then
                
                    -- hash unit 0
                    s_tdata_i_0 <= data_reg_0 & data_reg_1;
                    s_tvalid_i_0 <= '1';
                    s_tlast_i_0 <= '1';
                    
                    -- hash unit 1
                    s_tdata_i_1 <= data_reg_2 & data_reg_3;
                    s_tvalid_i_1 <= '1';
                    s_tlast_i_1 <= '1';
                    
                elsif digest_valid_o_0 = '1' and digest_valid_o_1 = '1' then
                    hash_0_reg <= digest_o_0;
                    hash_1_reg <= digest_o_1;
                    state <= hash_2;
                    hash_core_reset <= '1';
                
                else
                    state <= hash_01;
                    s_tvalid_i_0 <= '0';
                    s_tlast_i_0 <= '0';
                    s_tdata_i_0 <= (others => '0');
                    
                    s_tvalid_i_1 <= '0';
                    s_tlast_i_1 <= '0';
                    s_tdata_i_1 <= (others => '0');
           
                end if;

            when hash_2 =>



                if mode_reg = '0' then
                    
                    if s_tready_o_2 = '1' and digest_valid_o_2 = '0' then
                        s_tdata_i_2 <= data_reg_0 & data_reg_1;
                        s_tlast_i_2 <= '1';
                        s_tvalid_i_2 <= '1';
                        state <= hash_2;
                    elsif digest_valid_o_2 = '1' then
                        hash_out <= digest_o_2;
                        hash_valid <= '1';
                        state <= idle;
                        hash_core_reset <= '1';
                    else
                        s_tlast_i_2 <= '0';
                        s_tvalid_i_2 <= '0';
                        s_tdata_i_2 <= (others => '0');
                        state <= hash_2;
                    end if;
                    
                elsif mode_reg = '1' then
                    hash_core_reset <= '0';
                    if s_tready_o_2 = '1' and digest_valid_o_2 = '0' then
                        s_tdata_i_2 <= hash_0_reg & hash_1_reg;
                        s_tlast_i_2 <= '1';
                        s_tvalid_i_2 <= '1';
                        state <= hash_2;
                   elsif digest_valid_o_2 = '1' then
                        
                        hash_out <= digest_o_2;
                        hash_valid <= '1';
                        hash_core_reset <= '1';
                        state <= idle;
                   else
                        s_tlast_i_2 <= '0';
                        s_tvalid_i_2 <= '0';
                        s_tdata_i_2 <= (others => '0');
                        state <= hash_2;
                   end if;
                end if;
                
--            when others =>
--                next_state <= idle;
--                ready <= '0';
--                hash_core_reset <= '0';
--                -- hash_valid <= '0';
        end case;
        
--            hash_out <= digest_o_2;
--            hash_valid <= digest_valid_o_2;
--            state <= next_state;
            
            --ready <= s_tready_o_0 and s_tready_o_1 and s_tready_o_2;
            
        end if;
    end process;

end architecture Behavioral;