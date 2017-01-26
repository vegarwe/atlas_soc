library ieee ;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_textio.all;

use std.textio.all;

entity custom_fisken_tb is
end;

architecture custom_fisken_tb of custom_fisken_tb is
    signal   gpio0          : std_logic_vector(35 downto 0);
    signal   led_o          : std_logic_vector( 7 downto 0);
    signal   btn_i          : std_logic_vector( 3 downto 0)     := "0011";

    signal   s0_address     : std_logic                         := '0';
    signal   s0_read        : std_logic                         := '0';
    signal   s0_write       : std_logic                         := '0';
    signal   s0_readdata    : std_logic_vector(31 downto 0);
    signal   s0_writedata   : std_logic_vector(31 downto 0)     := (others => '0');

    signal   reset          : std_logic                         := '0';
    signal   clk            : std_logic                         := '0';
begin
    dut : entity work.custom_fisken
    port map (
        gpio0           => gpio0,
        led_o           => led_o,
        btn_i           => btn_i,

        s0_address      => s0_address,
        s0_read         => s0_read,
        s0_write        => s0_write,
        s0_readdata     => s0_readdata,
        s0_writedata    => s0_writedata,

        reset           => reset,
        clk             => clk
    );

    p_clock : process
    begin
        wait for 20 ns; clk  <= not clk;
    end process p_clock;

    stimulus : process
    begin
        -- Release reset asynchronously
        reset           <= '1'; wait for 64 ns;
        reset           <= '0'; wait for 25 us;

        -- Button press (start)
        wait until rising_edge(clk);
        btn_i(0) <= '0';
        wait until rising_edge(clk);
        btn_i(0) <= '1';
        wait for 10 us;

        -- Wait for trigger
        wait until rising_edge(led_o(4));
        wait for 10 us;

        -- Button press (stop)
        wait until rising_edge(clk);
        btn_i(0) <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        btn_i(0) <= '1';
        wait for 10 us;


        -- Button press (start)
        wait until rising_edge(clk);
        btn_i(0) <= '0';
        wait until rising_edge(clk);
        btn_i(0) <= '1';
        wait for 10 us;

        -- Button press (stop)
        wait until rising_edge(led_o(4));
        wait for 10 us;


        -- Read memory
        wait until rising_edge(clk);
        s0_read         <= '1';
        s0_address      <= '1';
        wait until rising_edge(clk);
        s0_read         <= '0';
        s0_address      <= '0';
        wait for  1 us;

        wait until rising_edge(clk);
        s0_read         <= '1';
        s0_address      <= '1';
        wait until rising_edge(clk);
        s0_read         <= '0';
        s0_address      <= '0';
        wait for  1 us;

        wait until rising_edge(clk);
        s0_read         <= '1';
        s0_address      <= '1';
        wait until rising_edge(clk);
        s0_read         <= '0';
        s0_address      <= '0';
        wait for  1 us;

        -- Write memory
        wait until rising_edge(clk);
        s0_write        <= '1';
        s0_address      <= '1';
        s0_writedata    <= x"12345678";
        wait until rising_edge(clk);
        s0_write        <= '0';
        s0_address      <= '0';
        s0_writedata    <= (others => '0');
        wait for  1 us;

        wait until rising_edge(clk);
        s0_write        <= '1';
        s0_address      <= '1';
        s0_writedata    <= x"00221133";
        wait until rising_edge(clk);
        s0_write        <= '0';
        s0_address      <= '0';
        s0_writedata    <= (others => '0');
        wait for  1 us;


        wait for 10 us;
		std.env.stop(0); --! Gracefully stops the simulation
        wait;
    end process stimulus;

    monitor : process (clk)
    begin
        if rising_edge(clk) then
        end if;
    end process monitor;

end custom_fisken_tb;
