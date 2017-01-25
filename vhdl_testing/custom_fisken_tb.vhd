library ieee ;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_textio.all;

use std.textio.all;

entity custom_fisken_tb is
end;

architecture custom_fisken_tb of custom_fisken_tb is

    signal   gpio0      : std_logic_vector(35 downto 0);
    signal   led_o      : std_logic_vector( 7 downto 0);
    signal   fisken_o   : std_logic_vector(31 downto 0);
    signal   fisken_i   : std_logic_vector(31 downto 0) := x"00000000";
    signal   btn_i      : std_logic_vector(3 downto 0) := "0011";
    signal   reset      : std_logic := '0';
    signal   clk        : std_logic := '0';
begin
    dut : entity work.custom_fisken
    port map (
       gpio0    => gpio0,
       led_o    => led_o,
       fisken_o => fisken_o,
       fisken_i => fisken_i,
       btn_i    => btn_i,
       reset    => reset,
       clk      => clk
    );

    clock : process
    begin
        wait for 20 ns; clk  <= not clk;
    end process clock;

    stimulus : process
    begin
        -- Release reset asynchronously
        reset           <= '1'; wait for 64 ns;
        reset           <= '0'; wait for 25 us;

        -- Button press
        wait until rising_edge(clk);
        btn_i(0) <= '0';
        wait until rising_edge(clk);
        btn_i(0) <= '1';
        wait for 10 us;

        -- Wait for trigger
        wait until rising_edge(led_o(4));
        wait for 10 us;

        -- Button press
        wait until rising_edge(clk);
        btn_i(0) <= '0';
        wait until rising_edge(clk);
        btn_i(0) <= '1';
        wait for 10 us;


        -- Button press
        wait until rising_edge(clk);
        btn_i(0) <= '0';
        wait until rising_edge(clk);
        btn_i(0) <= '1';
        wait for 10 us;

        -- Wait for trigger
        wait until rising_edge(led_o(4));
        wait for 10 us;


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
