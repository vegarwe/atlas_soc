library ieee ;
    use ieee.std_logic_1164.all;
--    use ieee.std_logic_unsigned.all;
--    use ieee.std_logic_textio.all;

--use std.textio.all;

entity custom_fisken_tb is
end;

architecture custom_fisken_tb of custom_fisken_tb is

    signal   clk        : std_logic := '0';
    signal   reset      : std_logic := '0';
    signal   btn_i      : std_logic_vector(3 downto 0) := "0011";
    signal   fisken_i   : std_logic_vector(31 downto 0) := x"00000000";
    signal   fisken_o   : std_logic_vector(31 downto 0);
    signal   led_o      : std_logic_vector( 7 downto 0);
    signal   gpio0      : std_logic_vector(35 downto 0);

begin
    --dut : entity work.custom_fisken
    --port map (
    --   gpio0    => gpio0,
    --   led_o    => led_o,
    --   fisken_o => fisken_o,
    --   fisken_i => fisken_i,
    --   btn_i    => btn_i,
    --   reset    => reset,
    --   clk      => clk
    --);

    clock : process
    begin
        wait for 20 ns; clk  <= not clk;
    end process clock;

    stimulus : process
    begin
        wait for 5 ns; reset  <= '1';
        wait for 4 ns; reset  <= '0';

        wait for 200 us;
        fisken_i <= x"0000007e";
        wait for 200 us;
        fisken_i <= x"00000061";
        wait for 200 us;
        fisken_i <= x"00000030";
        wait for 200 us;
        fisken_i <= x"00000031";
        wait for 200 us;
        fisken_i <= x"00000000";

        wait for 200 us;
		std.env.stop(1); --! Gracefully stops the simulation
        wait;
    end process stimulus;

    monitor : process (clk)
    begin
        if rising_edge(clk) then
        end if;
    end process monitor;

end custom_fisken_tb;
