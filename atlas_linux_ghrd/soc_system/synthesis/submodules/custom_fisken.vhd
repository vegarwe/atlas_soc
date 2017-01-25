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
    signal clock            : std_logic                         := '0';
    signal blink            : std_logic                         := '0';
    signal btn_out          : std_logic_vector( 1 downto 0)     := (others => '0');
    signal led              : std_logic_vector( 3 downto 0)     := (others => '0');
    signal mem_out          : std_logic_vector(31 downto 0)     := (others => '0');

    -- Timer0
    signal cc_0_out         : std_logic_vector(31 downto 0);
    signal cc_0_in          : std_logic_vector(31 downto 0)     := (others => '0');
    signal cc_0_latch       : std_logic                         := '0';
    signal cc_0_int_clear   : std_logic                         := '0';
    signal capture_0        : std_logic                         := '0';

    signal cc_1_out         : std_logic_vector(31 downto 0);
    signal cc_1_in          : std_logic_vector(31 downto 0)     := (others => '0');
    signal cc_1_latch       : std_logic                         := '0';
    signal cc_1_int_clear   : std_logic                         := '0';
    signal capture_1        : std_logic                         := '0';

    signal prescaler        : std_logic_vector(31 downto 0)     := (others => '0');
    signal prescaler_latch  : std_logic                         := '0';

    signal interrupt_src    : std_logic_vector( 1 downto 0);
    signal interrupt        : std_logic;

    signal start            : std_logic                         := '0';
    signal stop             : std_logic                         := '0';

begin
    led_o(7)            <= blink;
    led_o(6 downto 5)   <= btn_out;
    led_o(4)            <= interrupt_src(0);
    led_o(3 downto 0)   <= led;

    gpio0(35 downto 33) <= "111";
    gpio0(32)           <= clock;
    gpio0(31 downto  0) <= mem_out;


    fisken_o(0)         <= clock;

    dut : entity work.custom_timer
    generic map(
        DEF_PRESCALER   => 25000 -- 1s pr tick(?)
    )
    port map (
        cc_0_out        => cc_0_out,
        cc_0_in         => cc_0_in,
        cc_0_latch      => cc_0_latch,
        cc_0_int_clear  => cc_0_int_clear,
        capture_0       => capture_0,

        cc_1_out        => cc_1_out,
        cc_1_in         => cc_1_in,
        cc_1_latch      => cc_1_latch,
        cc_1_int_clear  => cc_1_int_clear,
        capture_1       => capture_1,

        prescaler       => prescaler,
        prescaler_latch => prescaler_latch,

        interrupt_src   => interrupt_src,
        interrupt       => interrupt,

        start           => start,
        stop            => stop,
        reset           => reset,
        clk             => clk
    );


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

    p_timer_start : process (clk, reset) is
        variable state : integer := 0;
    begin
        if (reset = '1') then
            state := 0;
        elsif (rising_edge(clk)) then
            cc_0_in    <= (others => '0');
            cc_0_latch <= '0';
            case state is
                when 0 =>
                    if btn_i(0) = '1' then
                        state      := state + 1;
                        cc_0_in    <= x"00000005";
                        cc_0_latch <= '1';
                    end if;
                when 1 =>
                    if btn_i(0) = '0' then
                        state      := 0;
                        start      <= '1';
                    end if;
                when others =>
                -- Do nothing
            end case;
        end if;
    end process p_timer_start;

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
        end if;
    end process p_memory;

end architecture behaviour;
