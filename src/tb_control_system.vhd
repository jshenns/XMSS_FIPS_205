library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_accelerator_ethernet_axi_wrapper is
end tb_accelerator_ethernet_axi_wrapper;

architecture behavior of tb_accelerator_ethernet_axi_wrapper is

    -- Component Declaration for the Unit Under Test (UUT)
    component accelerator_ethernet_axi_wrapper
    Port (
        clk : in std_logic;
        rst : in std_logic;
        
        tx_data : out STD_LOGIC_VECTOR (7 downto 0);
        tx_valid : out STD_LOGIC;
        tx_ready : in STD_LOGIC;

        rx_data : in STD_LOGIC_VECTOR (7 downto 0);
        rx_valid : in STD_LOGIC;
        rx_ready : out STD_LOGIC
    );
    end component;

    -- Signals for the testbench to drive the inputs to the UUT
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal tx_data : STD_LOGIC_VECTOR (7 downto 0);
    signal tx_valid : STD_LOGIC;
    signal tx_ready : STD_LOGIC := '1';

    signal rx_data : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal rx_valid : STD_LOGIC := '0';
    signal rx_ready : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: accelerator_ethernet_axi_wrapper
    Port map (
        clk => clk,
        rst => rst,
        tx_data => tx_data,
        tx_valid => tx_valid,
        tx_ready => tx_ready,
        rx_data => rx_data,
        rx_valid => rx_valid,
        rx_ready => rx_ready
    );

    -- Clock process to generate clock signal
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the UUT
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        -- Test different inputs for the module
        rx_valid <= '1';
        rx_data <= "00000011";  -- Check pk_gen state transition
        wait for clk_period;
        rx_valid <= '0';
        
        
        -- message input
        rx_data <= x"01";
        rx_valid <= '1';
        wait for clk_period;
        rx_data <= x"00";
        rx_valid <= '1';
        wait for clk_period*31;
        
        -- target index
        rx_data <= x"00";
        rx_valid <= '1';
        wait for clk_period;
        rx_data <= x"00";
        rx_valid <= '1';
        wait for clk_period;


        -- sig input
        rx_data <= x"FF";
        rx_valid <= '1';
        wait for clk_period*2400;


        rx_data <= x"00";
        rx_valid <= '0';

        
        


        -- Stop the simulation
        wait;
    end process;

end behavior;