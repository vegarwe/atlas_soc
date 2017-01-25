library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity custom_timer is
    generic(
        DEF_PRESCALER   : natural                               := 0
    );
    port(
        cc_0_out        : out   std_logic_vector(31 downto 0)   := (others => '0');
        cc_0_in         : in    std_logic_vector(31 downto 0);
        cc_0_latch      : in    std_logic;
        cc_0_int_clear  : in    std_logic;
        capture_0       : in    std_logic;

        cc_1_out        : out   std_logic_vector(31 downto 0)   := (others => '0');
        cc_1_in         : in    std_logic_vector(31 downto 0);
        cc_1_latch      : in    std_logic;
        cc_1_int_clear  : in    std_logic;
        capture_1       : in    std_logic;

        prescaler       : in    std_logic_vector(31 downto 0)   := (others => '0');
        prescaler_latch : in    std_logic;

        interrupt_src   : out   std_logic_vector( 1 downto 0)   := (others => '0');
        interrupt       : out   std_logic                       := '0';

        start           : in    std_logic;
        stop            : in    std_logic;
        reset           : in    std_logic;
        clk             : in    std_logic
    );
end entity custom_timer;

architecture behaviour of custom_timer is
    signal cc_0_int     : std_logic := '0';
    signal cc_0_src     : std_logic := '0';

    signal cc_1_int     : std_logic := '0';
    signal cc_1_src     : std_logic := '0';

    signal started      : std_logic := '0';
    signal prescaler_val: natural   :=  DEF_PRESCALER;
begin

    interrupt           <= cc_0_int or cc_1_int;
    interrupt_src(0)    <= cc_0_src;
    interrupt_src(1)    <= cc_1_src;

    p_cc0 : process (clk, reset) is
        variable counter    : natural    := 0;
        variable pre_counter: natural    := 0;
        variable int_value  : natural    := 0;
    begin
        if (reset = '1') then
            counter     := 0;
            pre_counter := 0;
            cc_0_int    <= '0';
            cc_0_src    <= '0';
            cc_0_out    <= (others => '0');
        elsif (rising_edge(clk)) then
            if cc_0_int_clear = '1' then
                cc_0_src <= '0';
            end if;

            if cc_0_latch = '1' then
                int_value := to_integer(unsigned(cc_0_in));
            end if;

            if capture_0 = '1' then
                cc_0_out <= std_logic_vector(to_unsigned(counter, cc_0_out'length));
            end if;

            if started = '1' then
                pre_counter := pre_counter + 1;

                if pre_counter >= prescaler_val then
                    counter     := counter + 1;
                    pre_counter := 0;
                end if;

                cc_0_int        <= '0';
                if int_value > 0 and counter = int_value then
                    cc_0_int    <= '1';
                    cc_0_src    <= '1';
                    counter     := 0;
                end if;
            end if;
        end if;
    end process p_cc0;

    p_cc1 : process (clk, reset) is
        variable counter    : natural    := 0;
        variable pre_counter: natural    := 0;
        variable int_value  : natural    := 0;
    begin
        if (reset = '1') then
            counter     := 0;
            pre_counter := 0;
            cc_1_int    <= '0';
            cc_1_src    <= '0';
            cc_1_out    <= (others => '0');
        elsif (rising_edge(clk)) then
            if cc_1_int_clear = '1' then
                cc_1_src <= '0';
            end if;

            if cc_1_latch = '1' then
                int_value := to_integer(unsigned(cc_1_in));
            end if;

            if capture_1 = '1' then
                cc_1_out <= std_logic_vector(to_unsigned(counter, cc_1_out'length));
            end if;

            if started = '1' then
                pre_counter := pre_counter + 1;

                if pre_counter >= prescaler_val then
                    counter     := counter + 1;
                    pre_counter := 0;
                end if;

                cc_1_int        <= '0';
                if int_value > 0 and counter = int_value then
                    cc_1_int    <= '1';
                    cc_1_src    <= '1';
                    counter     := 0;
                end if;
            end if;
        end if;
    end process p_cc1;

    p_command : process (clk, reset) is
    begin
        if (reset = '1') then
            started <= '0';
        elsif (rising_edge(clk)) then
            if start = '1' then
                started <= '1';
            end if;

            if prescaler_latch = '1' then
                prescaler_val <= to_integer(unsigned(prescaler));
            end if;
        end if;
    end process p_command;

end architecture behaviour;
