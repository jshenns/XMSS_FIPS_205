library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_control_system is
end entity tb_control_system;

architecture behavioral of tb_control_system is

  -- Signals for the DUT (Device Under Test)
    signal clock              : std_logic := '0';
    signal reset              : std_logic := '1';
    
    signal secret_seed   : std_logic_vector(255 downto 0) := (others => '0');
    signal message_in         : std_logic_vector(255 downto 0) := (others => '0');
    signal target_index  : std_logic_vector(15 downto 0)  := (others => '0');
    signal valid_in      : std_logic := '0';
    signal sig_xmss_in       : std_logic_vector(67*256 + 8*256 -1 downto 0) := (others => '0');
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
  begin
    -- Reset the design
    wait for clock_period*1.5;
    reset <= '0';

    -- Apply a test input
    wait for clock_period;
    secret_seed <= x"0000000000000000000000000000000000000000000000000000000000000001"; -- Example seed
    message_in <=  x"0000000000000000000000000000000000000000000000000000000000000001";
    target_index  <= "0000000000000000";   -- Example index (0)
    valid_in <= '1';
    wait for clock_period;
    valid_in <= '0'; wait;

  end process;

  -- Instantiate the DUT
  dut : entity work.control_system
    port map (
      clock => clock,
      reset => reset,
      
      node_secret_seed => secret_seed,
      message_in => message_in,
      node_target_index => target_index,
      node_valid_in => valid_in,
      sig_xmss_in => sig_xmss_in,
      node_valid_out => node_valid_out,
      node_ready => node_ready
    );

end architecture behavioral;