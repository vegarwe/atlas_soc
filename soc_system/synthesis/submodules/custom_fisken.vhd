library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity custom_fisken is
    port(
        gpio0       : inout std_logic_vector(35 downto 0)   := (others => '0');
        led_o       : out   std_logic_vector( 7 downto 0)   := x"00";
        fisken_o    : out   std_logic_vector(31 downto 0)   := x"00000000";
        fisken_i    : in    std_logic_vector(31 downto 0);
        btn_i       : in    std_logic_vector( 3 downto 0);
        reset       : in    std_logic;
        clk         : in    std_logic
    );
end entity custom_fisken;

architecture behaviour of custom_fisken is
    signal  clock   : std_logic                     := '0';
    signal  blink   : std_logic                     := '0';
    signal  led     : std_logic_vector(6 downto 0)  := (others => '0');
begin
    led_o(7) <= blink;
    led_o(6 downto 0) <= led;

    gpio0(35 downto 1) <= "00000000000000000000000000001111000";
    gpio0(0) <= clock;

    p_blink : process (clk, reset) is
        variable fjas    : integer    := 0;
    begin
        if (reset = '1') then
            blink <= '0';
            fjas  := 0;
        elsif (rising_edge(clk)) then
            clock <= not clock;
            blink <= '0';
            fjas  := fjas + 1;

            if    (fjas > 100 * 10**6) then
                fjas := 0;
            elsif (fjas >  90 * 10**6) then
                blink <= '1';
            else
                blink <= '0';
            end if;
        end if;
    end process p_blink;

    p_fisk : process (clk, reset) is
    begin
        if (reset = '1') then
            led <= (others => '0');
        elsif (rising_edge(clk)) then
            led <= "0000000";
            led(0) <= btn_i(0);
            led(1) <= btn_i(1);
            led(2) <= btn_i(2);
            led(3) <= btn_i(3);

            --if    fisken_i = x"00000030" then
            --    led <= "0000001";
            --elsif fisken_i = x"00000031" then
            --    led <= "0000010";
            --elsif fisken_i = x"00000032" then
            --    led <= "0000011";
            --else
            --    led <= "0000000";
            --end if;
        end if;
    end process p_fisk;

end architecture behaviour;
