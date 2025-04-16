library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity accelerator_ethernet_axi_wrapper is
    Port ( 
           clk : in std_logic;
           rst : in std_logic;
        
        
           -- out to the ethernet core
           tx_data : out STD_LOGIC_VECTOR (7 downto 0);
           tx_valid : out STD_LOGIC;
           tx_ready : in STD_LOGIC;
           
           -- in from the ethernet core
           rx_data : in STD_LOGIC_VECTOR (7 downto 0);
           rx_valid : in STD_LOGIC;
           rx_ready : out STD_LOGIC);
        
end accelerator_ethernet_axi_wrapper;

architecture Behavioral of accelerator_ethernet_axi_wrapper is

signal op_input : std_logic_vector(1 downto 0);
signal node_secret_seed : std_logic_vector(255 downto 0);
signal message_in : std_logic_vector(255 downto 0);
signal node_target_height : std_logic_vector(15 downto 0);
signal node_target_index : std_logic_vector(15 downto 0);
signal sig_in : std_logic_vector(255 downto 0);
signal node_valid_in : std_logic;


signal op_out             : std_logic_vector(1 downto 0);
signal pk_out             : std_logic_vector(255 downto 0);
signal pkFromSig_out      : std_logic_vector(255 downto 0);
signal sig_xmss_out       : std_logic_vector(256*0 + 1*256 -1 downto 0);
signal node_valid_out     : std_logic;
signal node_ready         : std_logic;

--fifo signals
signal sig_fifo_din   : std_logic_vector(255 downto 0);
signal sig_fifo_wr_en : std_logic;
signal sig_fifo_rd_en : std_logic;

signal sig_fifo_dout  : std_logic_vector(255 downto 0);
signal sig_fifo_full  : std_logic;
signal sig_fifo_empty : std_logic;

type state_type is (idle, pk_gen, pk_gen_out, sig_gen, pk_fromSig, fifo_dump, fifo_load);
signal state: state_type := idle;

signal rx_data_reg : std_logic_vector(7 downto 0);

signal din_accelerator : std_logic_vector(255 downto 0);
signal wr_en_accelerator : std_logic;
signal rd_en_accelerator : std_logic;

signal din_global : std_logic_vector(255 downto 0);
signal wr_en_global : std_logic;
signal rd_en_global : std_logic;


-- stuff for loading

signal packet_count : integer;
signal sk_reg : std_logic_vector(255 downto 0);

signal target_height_reg : std_logic_vector(15 downto 0);
signal target_index_reg : std_logic_vector(15 downto 0);

signal pk_reg : std_logic_vector(255 downto 0);
signal message_reg : std_logic_vector(255 downto 0);

signal sig_reg : std_logic_vector(255 downto 0);
signal fifo_count : integer;






begin

my_control_system : entity work.control_system(Behavioral)
    port map (
        clock => clk,
        reset => rst,
        
        op_input => op_input,
        node_secret_seed => node_secret_seed,
        message_in => message_in,
        node_target_height => node_target_height,
        node_target_index => node_target_index,
        sig_in => sig_in,
        node_valid_in => node_valid_in,
        
        op_out => op_out,
        pk_out        => pk_out        ,
        pkFromSig_out => pkFromSig_out ,
        sig_xmss_out  => sig_xmss_out  ,
        node_valid_out=> node_valid_out,
        node_ready    => node_ready,
                                     
        sig_fifo_din   => din_accelerator  ,                 
        sig_fifo_wr_en => wr_en_accelerator,                 
        sig_fifo_rd_en => rd_en_accelerator,                 
                                                               
        sig_fifo_dout  =>  sig_fifo_dout   ,                      
        sig_fifo_full  =>  sig_fifo_full   ,                      
        sig_fifo_empty =>  sig_fifo_empty                        
       
    
    );
    
    
my_sig_fifo : entity work.sig_fifo
    port map(
        clk => clk,
        srst => rst,
    
        din   => sig_fifo_din  ,
        wr_en => sig_fifo_wr_en,
        rd_en => sig_fifo_rd_en,
        
        dout  => sig_fifo_dout ,
        full  => sig_fifo_full ,
        empty => sig_fifo_empty
    );

my_wrapper_fifo_mux : entity work.wrapper_fifo_mux(Behavioral)
    port map(
        clock => clk,
        reset => rst,
        
        -- acclerator input
        din_accelerator   => din_accelerator,
        wr_en_accelerator => wr_en_accelerator,
        rd_en_accelerator => rd_en_accelerator,

        -- global input
        din_global   => din_global,
        wr_en_global => wr_en_global,
        rd_en_global => rd_en_global,

        -- signature fifo signals 
        din_fifo       => sig_fifo_din,
        wr_en_fifo     => sig_fifo_wr_en,
        rd_en_fifo     => sig_fifo_rd_en


    );


    process(rst, clk) 
    begin
        if rising_edge(clk) then
        if rst = '1' then
            tx_data <= (others => '0');
            tx_valid <= '0';
            
            -- in from the ethernet core
            rx_ready <= '0';
            state <= idle;
            
            -- reset internal stuff
            packet_count <= 0;
            sk_reg <= (others => '0');
            target_height_reg <= (others => '0');
            target_index_reg <= (others => '0');
            message_reg <= (others => '0');
            sig_reg <= (others => '0');
            fifo_count <= 0;

                           

            din_global <= (others => '0');
            wr_en_global <= '0';
            rd_en_global <= '0';


        else
            case state is
                when idle =>


                    if rx_valid = '1' then
                        
                        if rx_data = "00000001" then
                            state <= pk_gen;
                            
                        elsif rx_data = "00000010" then
                            state <= sig_gen;
                        elsif rx_data = "00000011" then
                            state <= pk_fromSig;
                        else 
                            state <= idle;
                        end if;
                    else
                        state <= idle;
                        rx_ready <= '1';
                    end if;

                when pk_gen =>
                        if packet_count < 32 and rx_valid = '1' then
                            sk_reg(packet_count*8+7 downto packet_count*8) <= rx_data;
                            packet_count <= packet_count + 1;
                        elsif packet_count < 34 and rx_valid = '1' then
                            target_height_reg((packet_count -32)*8 + 7 downto (packet_count-32)*8) <= rx_data;
                            packet_count <= packet_count + 1;
                        
                        elsif packet_count < 36 and rx_valid = '1' then
                            target_index_reg((packet_count -34)*8 + 7 downto (packet_count-34)*8) <= rx_data;
                            packet_count <= packet_count + 1;

                        elsif packet_count = 36 then
                            node_secret_seed <= sk_reg;
                            node_target_height <= target_height_reg;
                            node_target_index <= target_index_reg;
                            op_input <= "01";
                            node_valid_in <= '1';
                            rx_ready <= '0';
                            packet_count <= packet_count + 1;

                        elsif packet_count = 37 then
                            node_secret_seed <= (others => '0');
                            node_target_height <= (others => '0');
                            node_target_index <= (others => '0');
                            op_input <= "00";
                            node_valid_in <= '0';

                            if node_valid_out = '1' then
                                state <= pk_gen_out;
                                pk_reg <= pk_out;
                                packet_count <= 0;
                            end if;
                            
                        end if;

                when sig_gen =>
                    if packet_count < 32 and rx_valid = '1' then
                        sk_reg(packet_count*8+7 downto packet_count*8) <= rx_data;
                        packet_count <= packet_count + 1;
                    elsif packet_count < 64 and rx_valid = '1' then
                        message_reg((packet_count -32)*8 + 7 downto (packet_count-32)*8) <= rx_data;
                        packet_count <= packet_count + 1;
                    
                    elsif packet_count < 66 and rx_valid = '1' then
                        target_index_reg((packet_count -64)*8 + 7 downto (packet_count-64)*8) <= rx_data;
                        packet_count <= packet_count + 1;

                    elsif packet_count = 66 then
                        node_secret_seed <= sk_reg;
                        message_in <= message_reg;
                        node_target_index <= target_index_reg;
                        op_input <= "10";
                        node_valid_in <= '1';
                        rx_ready <= '0';
                        packet_count <= packet_count + 1;

                    elsif packet_count = 67 then
                        node_secret_seed <= (others => '0');
                        message_in <= (others => '0');
                        node_target_index <= (others => '0');
                        op_input <= "00";
                        node_valid_in <= '0';

                        if node_valid_out = '1' then
                            state <= fifo_dump;
                            packet_count <= 0;
                        end if;
                        
                    end if;
                when pk_fromSig =>
                    state <= idle;
                    rx_ready <= '0';
                when fifo_load =>
                    state <= idle;  
                    rx_ready <= '0';
                when fifo_dump =>
                    if tx_ready = '1' then
                        if packet_count = 0 then
                            tx_data <= x"02";
                            tx_valid <= '1';
                            packet_count <= packet_count + 1;
                        
                        elsif packet_count < 2401 and fifo_count = 0 then
                            rd_en_global <= '1';
                            fifo_count <= fifo_count + 1;
                            tx_valid <= '0';
                            tx_data <= x"00";

                        elsif packet_count < 2401 and fifo_count = 1 then
                            rd_en_global <= '0';
                            sig_reg <= sig_fifo_dout;
                            fifo_count <= fifo_count + 1;
                            tx_valid <= '0';
                            tx_data <= x"00";

                        elsif packet_count < 2401 and fifo_count <34  then

                            tx_data <= sig_reg((fifo_count-2)*8 + 7 downto (fifo_count-2)*8);
                            tx_valid <= '1';
                            fifo_count <= fifo_count + 1;
                            packet_count <= packet_count + 1;
                        elsif packet_count < 2401 and fifo_count = 34  then

                            tx_data <= (others => '0');
                            tx_valid <= '0';

                            fifo_count <= 0;

                        elsif packet_count = 2401 then
                            state <= idle;
                            tx_data <= (others => '0');
                            tx_valid <= '0';
                            packet_count <= 0;
                        else
                            tx_data <= (others => '0');
                            tx_valid <= '0';

                        end if;
                    else
                        tx_data <= (others => '0');
                        tx_valid <= '0';
                    end if;


                when pk_gen_out =>

                    if packet_count = 0 and tx_ready <= '1' then
                        tx_data <= x"01";
                        tx_valid <= '1';
                        packet_count <= packet_count + 1;
                    elsif packet_count < 33 and tx_ready <= '1' then
                        tx_data <= pk_reg((packet_count-1)*8+7 downto (packet_count-1)*8);
                        tx_valid <= '1';
                        packet_count <= packet_count + 1;
                    elsif packet_count = 33 then
                        state <= idle;
                        tx_data <= (others => '0');
                        tx_valid <= '0';
                        packet_count <= 0;

                    else
                        tx_data <= (others => '0');
                        tx_valid <= '0';
                    end if;

                    when others =>
                        state <= idle;

            end case;
        end if;
    end if;


    end process;

end Behavioral;
