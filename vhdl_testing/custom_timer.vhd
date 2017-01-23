library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

entity custom_timer is
    port(
        cc_1            : inout std_logic_vector(31 downto 0)   := (others => '0');

        capture_1       : in    std_logic;
        cc_1_latch      : in    std_logic;

        prescaler       : in    std_logic_vector(31 downto 0)   := (others => '0');
        prescaler_latch : in    std_logic;

        int_src         : out   std_logic_vector( 3 downto 0)   := (others => '0');
        interrupt       : out   std_logic                       := '0';

        start           : in    std_logic;
        stop            : in    std_logic;
        reset           : in    std_logic;
        clk             : in    std_logic
    );
end entity custom_timer;

architecture behaviour of custom_timer is
    signal started      : std_logic := '0';
    signal cc_1_int     : std_logic := '0';
    signal cc_1_val     : integer   := 0;
    signal prescaler_val: integer   := 0;
begin

    p_int_src : process (clk, reset) is
    begin
        if (reset = '1') then
            int_src         <= "0000";
            interrupt       <= '0';
        elsif (rising_edge(clk)) then
            interrupt       <= cc_1_int;
            if cc_1_int = '1' then
                int_src(0)  <= '1';
            end if;
        end if;
    end process p_int_src;

    p_cc1 : process (clk, reset) is
        variable counter    : integer    := 0;
        variable pre_counter: integer    := 0;
    begin
        if (reset = '1') then
            counter     := 0;
            pre_counter := 0;
            cc_1_int    <= '0';
        elsif (rising_edge(clk)) then
            if started = '1' then
                pre_counter := pre_counter + 1;

                if pre_counter = prescaler_val then
                    counter     := counter + 1;
                    pre_counter := 0;
                end if;

                if cc_1_int = '1' then
                    cc_1_int    <= '0';
                elsif counter = cc_1_val then
                    cc_1_int    <= '1';
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

            if cc_1_latch = '1' then
                cc_1_val <= to_integer(unsigned(cc_1));
            end if;

            if prescaler_latch = '1' then
                prescaler_val <= to_integer(unsigned(prescaler));
            end if;
        end if;
    end process p_command;

end architecture behaviour;
