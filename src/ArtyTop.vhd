

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity Top is
    Port ( 
        CLK100MHZ       : in STD_LOGIC;
        sw0             : in STD_LOGIC;
        -- Ethernet MII  DP83848J
        eth_ref_clk     : out std_logic;                    -- Reference Clock X1
            
        eth_mdc         : out std_logic;
        eth_mdio        : inout std_logic;
        eth_rstn        : out std_logic;                    -- Reset Phy
    
        eth_rx_clk      : in  std_logic;                     -- Rx Clock
        eth_rx_dv       : in  std_logic;                     -- Rx Data Valid
        eth_rxd         : in  std_logic_vector(3 downto 0);  -- RxData
            
        eth_rxerr       : in  std_logic;                     -- Receive Error
        eth_col         : in  std_logic;                     -- Ethernet Collision
        eth_crs         : in  std_logic;                     -- Ethernet Carrier Sense
                    
        eth_tx_clk      : in  std_logic;                     -- Tx Clock
        eth_tx_en       : out std_logic;                     -- Transmit Enable
        eth_txd         : out std_logic_vector(3 downto 0);  -- Transmit Data
        
        -- SPI Flash Mem
        qspi_cs         : out std_logic;        
        qspi_dq         : inout std_logic_vector(3 downto 0);   -- dg(0) is MOSI, dq(1) MISO
        
        --RGB LEDs  
        led0_b          : out std_logic;
        --led0_g          : out std_logic;
        led0_r          : out std_logic
        --led1_b          : out std_logic;
        --led1_g          : out std_logic;
        --led1_r          : out std_logic;
        --led2_b          : out std_logic;
        --led2_g          : out std_logic;
        --led2_r          : out std_logic;
        --led3_b          : out std_logic;
        --led3_g          : out std_logic;
        --led3_r          : out std_logic

        --Chip kit
        --ck_io           : out std_logic_vector(5 downto 0);

        -- USB UART
        --uart_rxd_out    : out std_logic; 
        --uart_txd_in     : in  std_logic
            
    );
end Top;

architecture IMPL of Top is
    component cllk_75 is
    port(
        clk_in1  : in std_logic;
        reset    : in std_logic;
        locked   : out std_logic;
        CLK75MHZ : out std_logic

    
    );
    end component cllk_75;
    
    component FC1002_MII is    
    port (
        Clk             : in  std_logic;    -- 100MHz
        Reset           : in  std_logic;    -- Active high

        ----------------------------------------------------------------
        -- System Setup
        ----------------------------------------------------------------
        UseDHCP         : in  std_logic;
        IP_Addr         : in  std_logic_vector(8*4-1 downto 0); -- If UseDHCP = '0'
        
        ----------------------------------------------------------------
        -- System Status
        ----------------------------------------------------------------
        IP_Ok           : out std_logic;
        
        ----------------------------------------------------------------
        -- SPI Flash Boot Control
        ----------------------------------------------------------------
        SPI_CSn         : out std_logic;
        SPI_SCK         : out std_logic;
        SPI_MOSI        : out std_logic;
        SPI_MISO        : in  std_logic;
        
        ----------------------------------------------------------------
        -- TCP0 Basic Server With Service Exposer
        ----------------------------------------------------------------
        -- Setup 
        TCP0_Service    : in  std_logic_vector(15 downto 0);        
        TCP0_ServerPort : in  std_logic_vector(15 downto 0);
        
        -- Status
        TCP0_Connected  : out std_logic;
        TCP0_AllAcked   : out std_logic;
        TCP0_nTxFree    : out unsigned(15 downto 0);
        TCP0_nRxData    : out unsigned(15 downto 0);
        
        -- AXI4 Stream Slave
        TCP0_TxData     : in  std_logic_vector(7 downto 0);
        TCP0_TxValid    : in  std_logic;
        TCP0_TxReady    : out std_logic;
        
        -- AXI4 Stream Master        
        TCP0_RxData     : out std_logic_vector(7 downto 0);
        TCP0_RxValid    : out std_logic;
        TCP0_RxReady    : in  std_logic;
        
        ----------------------------------------------------------------
        -- Logic Analyzer
        ----------------------------------------------------------------
        LA0_TrigIn      : in  std_logic;
        LA0_Clk         : in  std_logic;
        LA0_TrigOut     : out std_logic;
        LA0_Signals     : in  std_logic_vector(31 downto 0);
        LA0_SampleEn    : in  std_logic;
        
        ----------------------------
        -- MII Interface
        ----------------------------
        MII_REF_CLK_25M : out std_logic;    -- 25MHz 
        MII_RST_N       : out std_logic;     
        MII_COL         : in  std_logic;    -- Ethernet Collision
        MII_CRS         : in  std_logic;    -- Ethernet Carrier Sense        
        MII_RX_CLK      : in  std_logic;     -- 25MHz or 2.5MHz
        MII_CRS_DV      : in  std_logic; 
        MII_RXD         : in  std_logic_vector(3 downto 0); 
        MII_RXERR       : in  std_logic;     
        MII_TX_CLK      : in  std_logic;     -- 25MHz or 2.5MHz
        MII_TXEN        : out std_logic; 
        MII_TXD         : out std_logic_vector(3 downto 0)
                
    );
    end component FC1002_MII;
    
    signal CLK75MHZ         : std_logic;
    
    signal IP_Ok            : std_logic := '0';
     
    signal TCP0_Connected   : std_logic;
    signal TCP0_AllAcked    : std_logic;
            
    signal TCP0_TxData      : std_logic_vector(7 downto 0);  
    signal TCP0_TxValid     : std_logic;
    signal TCP0_TxReady     : std_logic;
        
    signal TCP0_RxData      : std_logic_vector(7 downto 0);
    signal TCP0_RxValid     : std_logic;
    signal TCP0_RxReady     : std_logic;
        
    signal LA0_TrigIn       : std_logic;
    signal LA0_Clk          : std_logic;
    signal LA0_TrigOut      : std_logic;
    signal LA0_Signals      : std_logic_vector(31 downto 0);
    signal LA0_SampleEn     : std_logic;
    
    signal fifo_RxData  : std_logic_vector(7 downto 0);
    signal fifo_RxReady : std_logic;
    signal fifo_RxValid : std_logic;
    signal fifo_tx_tuser   : std_logic_vector(3 downto 0);
    signal fifo_rx_tuser   : std_logic_vector(3 downto 0);
    
    


    signal fifo_TxData  : std_logic_vector(7 downto 0);
    signal fifo_TxReady : std_logic;
    signal fifo_TxValid : std_logic;

    
    
    
    
   
begin

    led0_b <= sw0;
    led0_r <= sw0;
    
    my_clk_fifo_rx : entity work.clock_fifo
    port map(
        m_aclk => CLK75MHZ,
        s_aclk => CLK100MHZ,
        
        s_aresetn => sw0,
        
        -- slave, from the ethernet
        s_axis_tdata =>  TCP0_RxData,
        s_axis_tready => TCP0_RxReady,
        s_axis_tuser =>  (others => '0'),
        s_axis_tvalid => TCP0_RxValid,
        
        -- master, to the accelerator interface
        m_axis_tdata =>  fifo_RxData,
        m_axis_tready => fifo_RxReady,
        m_axis_tuser =>  fifo_rx_tuser,
        m_axis_tvalid => fifo_RxValid
    
    );
    
    my_clk_fifo_tx : entity work.clock_fifo
    port map(
        m_aclk => CLK100MHZ,
        s_aclk => CLK75MHZ,
        
        s_aresetn => sw0,
        
        -- slave, from the accelerator interface
        s_axis_tdata =>  fifo_TxData,
        s_axis_tready => fifo_TxReady,
        s_axis_tuser =>  (others => '0'),
        s_axis_tvalid => fifo_TxValid,
        
        -- master, to the ethernet
        m_axis_tdata =>  TCP0_TxData,
        m_axis_tready => TCP0_TxReady,
        m_axis_tuser =>  fifo_tx_tuser,
        m_axis_tvalid => TCP0_TxValid
    
    );

    
    my_clk_wiz : cllk_75
    port map(clk_in1 => CLK100MHZ, reset => sw0, CLK75MHZ => CLK75MHZ);
    
    my_axi_accelerator : entity work.accelerator_ethernet_axi_wrapper(Behavioral)
    port map(
        clk => CLK75MHZ,
        rst => sw0,
     
     
        -- out to the ethernet core
        tx_data => fifo_TxData,
        tx_valid => fifo_TxValid,
        tx_ready => fifo_TxReady,
        
        -- in from the ethernet core
        rx_data => fifo_RxData,
        rx_valid => fifo_RxValid,
        rx_ready => fifo_RxReady
    );
    
    i_FC_1002_MII : FC1002_MII
    port map (
        Clk             => CLK100MHZ,       -- 100 MHz
        Reset           => sw0,             -- Active high

        ----------------------------------------------------------------
        -- System Setup
        ----------------------------------------------------------------
        UseDHCP         => '0',
        IP_Addr         => x"a9fe01c8",
        
        ----------------------------------------------------------------
        -- System Status
        ----------------------------------------------------------------
        IP_Ok           => IP_Ok,           -- '1' when DHCP has solved IP
        
        ----------------------------------------------------------------
        -- SPI Flash Boot Control
        ----------------------------------------------------------------
        SPI_CSn         => qspi_cs,
        SPI_SCK         => open, --??qspi_sck,
        SPI_MOSI        => qspi_dq(0),
        SPI_MISO        => qspi_dq(1),
        
        ----------------------------------------------------------------
        -- TCP0 Basic Server With Service Exposer
        ----------------------------------------------------------------
        -- Setup 
        TCP0_Service    => x"0112",
        TCP0_ServerPort => x"E001",
        
        -- Status
        TCP0_Connected  => TCP0_Connected,
        TCP0_AllAcked   => TCP0_AllAcked, 
        TCP0_nTxFree    => open,
        TCP0_nRxData    => open,
        
        -- AXI4 Stream Slave
        TCP0_TxData     => TCP0_TxData,  
        TCP0_TxValid    => TCP0_TxValid, 
        TCP0_TxReady    => TCP0_TxReady, 
        
        -- AXI4 Stream Master        
        TCP0_RxData     => TCP0_RxData, 
        TCP0_RxValid    => TCP0_RxValid,
        TCP0_RxReady    => TCP0_RxReady,
        
        ----------------------------------------------------------------
        -- Logic Analyzer
        ----------------------------------------------------------------
        LA0_TrigIn      => LA0_TrigIn,   
        LA0_Clk         => LA0_Clk,      
        LA0_TrigOut     => LA0_TrigOut,  
        LA0_Signals     => LA0_Signals,  
        LA0_SampleEn    => LA0_SampleEn, 
        
        ----------------------------
        -- MII Interface
        ----------------------------
        MII_REF_CLK_25M => eth_ref_clk,
        MII_RST_N       => eth_rstn,
        MII_COL         => eth_col,
        MII_CRS         => eth_crs, 
        MII_RX_CLK      => eth_rx_clk,
        MII_CRS_DV      => eth_rx_dv,
        MII_RXD         => eth_rxd,
        MII_RXERR       => eth_rxerr,   
        MII_TX_CLK      => eth_tx_clk,
        MII_TXEN        => eth_tx_en,
        MII_TXD         => eth_txd         
    );
    
    
end IMPL;
