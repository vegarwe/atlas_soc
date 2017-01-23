
library ieee ;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_textio.all;

use std.textio.all;

entity custom_timer_tb is
end;

architecture custom_timer_tb of custom_timer_tb is
    signal cc_1             : std_logic_vector(31 downto 0)     := (others => '0');

    signal capture_1        : std_logic                         := '0';
    signal cc_1_latch       : std_logic                         := '0';

    signal prescaler        : std_logic_vector(31 downto 0)     := (others => '0');
    signal prescaler_latch  : std_logic                         := '0';

    signal int_src          : std_logic_vector( 3 downto 0);
    signal interrupt        : std_logic;

    signal start            : std_logic                         := '0';
    signal stop             : std_logic                         := '0';

    signal clk              : std_logic                         := '0';
    signal reset            : std_logic                         := '0';
begin
    dut : entity work.custom_timer
    port map (
        cc_1            => cc_1,

        capture_1       => capture_1,
        cc_1_latch      => cc_1_latch,

        prescaler       => prescaler,
        prescaler_latch => prescaler_latch,

        int_src         => int_src,
        interrupt       => interrupt,

        start           => start,
        stop            => stop,
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

        -- Set compare register
        wait until rising_edge(clk);
        cc_1            <= x"00000028"; -- 0x03e8 * 0x2710 * 40 == 0.4s, 0x12c * 0x1388 * 40 == 0.06s
        cc_1_latch      <= '1';
        wait until rising_edge(clk);
        cc_1            <= (others => '0');
        cc_1_latch      <= '0';
        wait for 25 us;

        -- Set prescaler
        wait until rising_edge(clk);
        prescaler       <= x"00000032"; -- 0x2710 == 400us pr counter tick
        prescaler_latch <= '1';
        wait until rising_edge(clk);
        prescaler       <= (others => '0');
        prescaler_latch <= '0';
        wait for 25 us;

        -- Start timer
        wait until rising_edge(clk);
        start           <= '1';
        wait until rising_edge(clk);
        start           <= '0';
        wait for 25 us;

        wait until rising_edge(interrupt);
        wait for 25 us;

        reset           <= '1'; wait for 64 ns;
        reset           <= '0'; wait for 25 us;

        wait for 200 us;
		std.env.stop(0); --! Gracefully stops the simulation
        wait;
    end process stimulus;

    monitor : process (clk)
    begin
        if rising_edge(clk) then
        end if;
    end process monitor;

end custom_timer_tb;
