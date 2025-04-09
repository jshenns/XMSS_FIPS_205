library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use STD.textio.all;
--use ieee.std_logic_textio.all;

entity tb_control_system is
end entity tb_control_system;

architecture behavioral of tb_control_system is
    

  -- Signals for the DUT (Device Under Test)
    signal clock              : std_logic := '0';
    signal reset              : std_logic := '1';
    
    signal op_in              : std_logic_vector(1 downto 0) := (others => '0'); -- 00 nothing, 01 = pkGen, 10 = sign, 11 = pkFromSig
    signal secret_seed        : std_logic_vector(255 downto 0) := (others => '0');
    signal message_in         : std_logic_vector(255 downto 0) := (others => '0');
    signal target_index       : std_logic_vector(15 downto 0)  := (others => '0');
    signal target_height      : std_logic_vector(15 downto 0)  := (others => '0');
    signal valid_in           : std_logic := '0';
    signal sig_xmss_in        : std_logic_vector(1*256 + 0*256 -1 downto 0) := (others => '0');
    
    signal op_out             : std_logic_vector(1 downto 0) := (others => '0');
    signal pk_out             : std_logic_vector(255 downto 0) := (others => '0');
    signal pkFromSig_out      : std_logic_vector(255 downto 0) := (others => '0');
    signal sig_xmss_out       : std_logic_vector(256*0 + 1*256 -1 downto 0) := (others => '0');
    signal node_valid_out     : std_logic := '0';
    signal node_ready         : std_logic  := '0';
                      
  -- Clock proces
  constant clock_period : time := 10 ns;
  begin
    clock_process : process
    begin
      clock <= '0';
      wait for clock_period/2;
      clock <= '1';
      wait for clock_period/2;
    end process;

  -- Stimulus processE
  stim_proc: process

  --file test_vector : text open write_mode is "hardware_output.txt";
  --variable row     : line;


  begin

    --file_open(test_vector, "hardware_output.txt",read_mode);

    -- Reset the design
    wait for clock_period*1.5;
    reset <= '0';

    -- Apply a test input
--    wait for clock_period;
--    op_in <= "11"; -- xmss sign
--    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
--    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
--    sig_xmss_in <= (others => '1');
--    target_height <= "0000000000001000";
--    target_index  <= "0000000000000000";   -- Example index (0)   
--    valid_in <= '1';
--    wait for clock_period*74;
--    valid_in <= '0';    
    
    
    
    
    
    -- real inputs 1
    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    --wait for clock_period;
    
    
        -- real inputs 2
    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"ad455ab347788407014533134ec601d8c1fb185bda41c201fc5a6a11a071a3aa";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 3
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"767783421278cd0d1a48ae368575694899a64eb49d5bbd0c19845c32c5a146a9";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 4
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"9cba7f81791aee3dff7daf158a126287250a35279230d1df2f5c020a388071ff";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 5
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 6
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 7
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 8
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 9
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 10
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 11
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 12
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
--    wait for clock_period;

--    -- real inputs 13 
----    wait for clock_period;
--    op_in <= "11"; -- xmss sign
--    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
--    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
--    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
--    target_height <= "0000000000001000";
--    target_index  <= "0000000000000000";   -- Example index (0)   
--    valid_in <= '1';
    wait for clock_period;

    -- real inputs 14
--    wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
--    valid_in <= '1';
    wait for clock_period;

    -- real inputs 15
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 16
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 17
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 18
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 19
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 20
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 21
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 22
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 23
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 24
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 25
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 26
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 27
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 28
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 29
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 30
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 31
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 32
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 33
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 34
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 35
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 36
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 37
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 38
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 39
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 40
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;

    -- real inputs 41
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 42
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 43
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 44
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 45
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 46
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 47
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 48
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 49
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 50
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 51
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 52
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 53
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 54
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 55
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 56
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 57
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 58
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 59
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 60
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 61
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 62
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 63
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 64
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 65
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 66
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs 67
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"b70575ca84f11f0c8460a0aef8f9bdda92ea06820326e361043db2b4a26e8bc2";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs auth 1
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"8f922d2566ee329791bf4492b9d485f4c7a7083953d9f9a193e2518f9cb498cc";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs auth 2 
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"af53f70f2fcf1a0d373491f888bfe29f557a6979ba145f368daa09fbacb70f09";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"4ef1c786f0e15ead9f347ea2c1aa512c4200c83109051483df419a400054f673";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"fb179d4c0f7f5c2b9e350fdacec7120efb208c773117fe6fabbe79e19872d780";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"a92af2efd6fda75f2607154be50b982871a1b252beeb3a2d0f648f84a158f01e";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"d8cf3781fba84de2db6d8d192cc4ed9b276b60c9e5dd6d0c419f7b992564182b";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"8d7b4b9dc303bb1677c810fd0db1138df4c7a3f39107d860d087766d69701b4f";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period;
    -- real inputs
    --wait for clock_period;
    op_in <= "11"; -- xmss sign
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    sig_xmss_in <= x"8eacf2b89cd789e7d30016a09313fdaab52a3b6a84e3bf72fdbc2b90974739fb";
    target_height <= "0000000000001000";
    target_index  <= "0000000000000000";   -- Example index (0)   
    valid_in <= '1';
    wait for clock_period*2;
    valid_in <= '0';
















































    
    
    

--    if rising_edge(clock) then
--      if node_valid_out = '1' then

--        write(row, op_out, right, 15);
--        hwrite(row, pk_out, right, 15);
--        hwrite(row, pkFromSig_out, right, 15);
--        hwrite(row, sig_xmss_out, right,15);
--        writeline(test_vector, row);

--      end if;
--    end if;

--    file_close(test_vector);
    
    wait;

  end process;

  -- Instantiate the DUT
  dut : entity work.control_system
    port map (
      clock => clock,
      reset => reset,
      
      op_input             => op_in        ,
      node_secret_seed     => secret_seed  ,
      message_in           => message_in   ,
      node_target_height   => target_height ,
      node_target_index    => target_index,
      sig_in               => sig_xmss_in     ,
      node_valid_in        => valid_in  ,
      
      op_out             => op_out        ,
      pk_out             => pk_out        ,
      pkFromSig_out      => pkFromSig_out ,
      sig_xmss_out       => sig_xmss_out  ,
      node_valid_out     => node_valid_out,
      node_ready         => node_ready    
              
      
      
      
    );

end architecture behavioral;