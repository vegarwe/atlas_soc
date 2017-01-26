library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity custom_fisken is
    port(
        gpio0           : inout std_logic_vector(35 downto 0)   := (others => '0');
        led_o           : out   std_logic_vector( 7 downto 0)   := x"00";
        btn_i           : in    std_logic_vector( 3 downto 0);

        -- Avalon-MM Slave interface (memory mapped io)
        s0_address      : in    std_logic;
        s0_read         : in    std_logic;
        s0_write        : in    std_logic;
        s0_readdata     : out   std_logic_vector(31 downto 0)   := (others => '0');
        s0_writedata    : in    std_logic_vector(31 downto 0);

        reset           : in    std_logic;
        clk             : in    std_logic
    );
end entity custom_fisken;

architecture behaviour of custom_fisken is
    signal blink            : std_logic                         := '0';
    signal btn_out          : std_logic_vector( 1 downto 0)     := (others => '0');
    signal led              : std_logic_vector( 3 downto 0)     := (others => '0');

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

    signal timer_start      : std_logic                         := '0';
    signal timer_stop       : std_logic                         := '0';
    signal timer_reset      : std_logic                         := '0';
    signal timer_reset_comb : std_logic                         := '0';
begin
    gpio0(35 downto 33) <= "111";
    gpio0(32)           <= clk;
    gpio0(31 downto  0) <= x"55aa1100";

    led_o( 7)           <= blink;
    led_o( 6 downto  5) <= btn_out;
    led_o( 4)           <= interrupt_src(0);
    led_o( 3 downto  0) <= led;

    timer_reset_comb    <= reset or timer_reset;

    timer_0 : entity work.custom_timer
    generic map(
        DEF_PRESCALER   => 2500 -- 25000 -> 1ms pr tick
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

        start           => timer_start,
        stop            => timer_stop,
        reset           => timer_reset_comb,
        clk             => clk
    );


    p_blink : process (clk, reset) is
        variable cntr : integer    := 0;
    begin
        if (reset = '1') then
            blink <= '0';
            cntr  :=  0;
        elsif (rising_edge(clk)) then
            blink <= '0';
            cntr  := cntr + 1;

            if    (cntr > 100 * 10**6) then
                cntr := 0;
            elsif (cntr >  99 * 10**6) then
                blink <= '1';
            else
                blink <= '0';
            end if;
        end if;
    end process p_blink;

    p_button : process (clk, reset) is
    begin
        if (reset = '1') then
        elsif (rising_edge(clk)) then
            btn_out(0) <= not btn_i(0);
            btn_out(1) <= not btn_i(1);
        end if;
    end process p_button;

    -- Controler timer with button
    p_timer_start : process (clk, reset) is
        variable state : integer := 0;
    begin
        if (reset = '1') then
            state := 0;
        elsif (rising_edge(clk)) then
            cc_0_in     <= (others => '0');
            cc_0_latch  <= '0';
            timer_start <= '0';
            timer_reset <= '0';
            case state is
                when 0 =>
                    if btn_i(0) = '0' then
                        state       := state + 1;
                        cc_0_in     <= x"000036b0";
                        cc_0_latch  <= '1';
                    end if;
                when 1 =>
                    if btn_i(0) = '1' then
                        state       := state + 1;
                        timer_start <= '1';
                    end if;
                when 2 =>
                    if btn_i(0) = '0' then
                        state       := state + 1;
                        timer_reset <= '1';
                    end if;
                when 3 =>
                    if btn_i(0) = '1' then
                        state       := 0;
                    end if;
                when others =>
                    -- Do nothing
            end case;
        end if;
    end process p_timer_start;

    -- Read operations performed on the Avalon-MM Slave interface
    p_memory_read : process (clk, reset) is
        variable counter : natural := 0;
    begin
        s0_readdata <= (others => '0');

        if (reset = '1') then
            counter := 0;
        elsif (rising_edge(clk)) then
            if s0_read = '1' and s0_address = '1' then
                counter := counter + 1;
                s0_readdata <= std_logic_vector(to_unsigned(counter, s0_readdata'length));
                led(0)  <= not led(0);
            end if;
        end if;
    end process p_memory_read;

    -- Write operations performed on the Avalon-MM Slave interface
    p_memory_write : process (clk, reset) is
    begin
        if (reset = '1') then
            --
        elsif (rising_edge(clk)) then
            if s0_write = '1' and s0_address = '1' then
                led(1)  <= not led(1);
            end if;
        end if;
    end process p_memory_write;

end architecture behaviour;
