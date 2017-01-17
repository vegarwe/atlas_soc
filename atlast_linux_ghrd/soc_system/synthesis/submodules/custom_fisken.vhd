library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity custom_fisken is
    port(
        gpio0       : inout std_logic_vector(35 downto 0)   := (others => '0');
        led_o       : out   std_logic_vector( 7 downto 0)   := x"00";
        fisken_o    : out   std_logic_vector(31 downto 0)   := x"123abc99";
        fisken_i    : in    std_logic_vector(31 downto 0);
        btn_i       : in    std_logic_vector( 3 downto 0);
        reset       : in    std_logic;
        clk         : in    std_logic
    );
end entity custom_fisken;

architecture behaviour of custom_fisken is
    signal  clock   : std_logic                     := '0';
    signal  blink   : std_logic                     := '0';
    signal  btn_out : std_logic_vector( 1 downto 0) := (others => '0');
    signal  led     : std_logic_vector( 4 downto 0) := (others => '0');
    signal  mem_out : std_logic_vector(31 downto 0) := (others => '0');
begin
    led_o(7)            <= blink;
    led_o(6 downto 5)   <= btn_out;
    led_o(4 downto 0)   <= led;

    gpio0(35 downto 33) <= "111";
    gpio0(32 downto  1) <= mem_out;
    gpio0(0)            <= clock;

    fisken_o(0)         <= clock;

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
            elsif (fjas >  98 * 10**6) then
                blink <= '1';
            else
                blink <= '0';
            end if;
        end if;
    end process p_blink;

    p_fisk : process (clk, reset) is
    begin
        if (reset = '1') then
        elsif (rising_edge(clk)) then
            btn_out(0) <= not btn_i(0);
            btn_out(1) <= not btn_i(1);
        end if;
    end process p_fisk;

    p_memory : process (clk, reset) is
    begin
        if (reset = '1') then
            mem_out <= (others => '0');
            led     <= (others => '0');
        elsif (rising_edge(clk)) then
            mem_out <= fisken_i;

            led(0)  <= fisken_i(0);
            led(1)  <= fisken_i(1);
            led(2)  <= fisken_i(2);
            led(3)  <= fisken_i(3);
            led(4)  <= fisken_i(4);
        end if;
    end process p_memory;

end architecture behaviour;
