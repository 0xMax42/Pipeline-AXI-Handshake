library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity Pipeline_tb is
    -- The testbench does not require any ports
end entity Pipeline_tb;

architecture behavior of Pipeline_tb is
    -- Random number generator
    --@ Select a random number for `seed1` to generate random numbers
    shared variable seed1                     : integer := 467;
    --@ Select a random number for `seed2` to generate random numbers
    shared variable seed2                     : integer := 623;
    --@ Generate a random number between `min_val` and `max_val`
    --@ You must provide the `shared variable seed1` and `shared variable seed2` to generate random numbers.
    --@ You need `use ieee.math_real.all;` to use this function.
    impure function rand_int(min_val, max_val : integer) return integer is
        variable r                                : real;
    begin
        uniform(seed1, seed2, r);
        return integer(
        round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
    end function;

    -- Clock signal period
    constant period              : time                                   := 20 ns;

    -- Adjustable wait times
    constant write_delay         : natural                                := 40; -- Maximal wait time between write operations in clock cycles
    constant read_delay          : natural                                := 60; -- Maximal wait time between read operations in clock cycles

    -- Setting constants for the FIFO to be tested
    constant K_Width             : integer                                := 32; -- Data width of the FIFO
    constant K_PipelineStages    : integer                                := 5; -- Number of pipeline stages
    constant K_RegisterBalancing : string                                 := "yes"; -- Register balancing attribute

    -- Testbench signals
    signal CLK                   : std_logic                              := '0';
    signal RST                   : std_logic                              := '1';
    signal CE                    : std_logic                              := '1';

    signal I_Data                : std_logic_vector(K_Width - 1 downto 0) := (others => 'U');
    signal I_Valid               : std_logic                              := '0';
    signal O_Ready               : std_logic;

    signal O_Data                : std_logic_vector(K_Width - 1 downto 0) := (others => 'U');
    signal O_Valid               : std_logic;
    signal I_Ready               : std_logic := '0';

    signal PipelineEnable        : std_logic;
begin

    uut0 : entity work.PipelineController
        generic map(
            G_PipelineStages => K_PipelineStages,
            G_ResetActiveAt  => '1'
        )
        port map(
            I_CLK    => CLK,
            I_RST    => RST,
            I_CE     => CE,
            O_Enable => PipelineEnable,
            I_Valid  => I_Valid,
            O_Ready  => O_Ready,
            O_Valid  => O_Valid,
            I_Ready  => I_Ready
        );

    uut1 : entity work.PipelineRegister
        generic map(
            G_PipelineStages    => K_PipelineStages,
            G_Width             => K_Width,
            G_RegisterBalancing => K_RegisterBalancing
        )
        port map(
            I_CLK    => CLK,
            I_Enable => PipelineEnable,
            I_Data   => I_Data,
            O_Data   => O_Data
        );

    -- Clock process
    Clocking : process
    begin
        while true loop
            CLK <= '0';
            wait for (period / 2);
            CLK <= '1';
            wait for (period / 2);
        end loop;
    end process;

    -- Clock enable process
    -- This process is used to enable the clock signal for a certain amount of time
    -- and only for the Pipeline Controller to check if the dataflow is working correctly.
    -- ClockEnable : process
    -- begin
    --     while true loop
    --         CE <= '1';
    --         wait for 1000 ns;
    --         CE <= '0';
    --         wait for 500 ns;
    --     end loop;
    -- end process;

    -- 100 ns Reset
    RST <= '1', '0' after 100 ns;

    -- Write process
    Write : process
        variable delay : integer := 0;
        variable i     : integer := 1;
    begin
        I_Valid <= '0';
        I_Data  <= (others => 'U');
        wait until RST = '0'; -- auf Reset-Ende warten

        while true loop
            wait until rising_edge(CLK);

            if O_Ready = '1' and delay = 0 then
                I_Data  <= std_logic_vector(to_unsigned(i, K_Width));
                I_Valid <= '1';
                report "Sende Paket #" & integer'image(i) severity note;
                i     := i + 1;
                delay := rand_int(1, write_delay);
            elsif O_Ready = '1' and I_Valid = '1' then
                I_Valid <= '0';
            end if;

            if delay /= 0 then
                delay := delay - 1;
            end if;
        end loop;
    end process;

    -- Read process
    Read : process
        variable delay    : integer := 0;
        variable expected : integer := 1;
        variable received : integer;
    begin
        I_Ready <= '0';
        wait until RST = '0'; -- auf Reset-Ende warten

        while true loop
            wait until rising_edge(CLK);
            wait for 1 ns;

            if O_Valid = '1' and delay = 0 then
                I_Ready <= '1';

                received := to_integer(unsigned(O_Data));
                if received = expected then
                    report "Empfange Paket #" & integer'image(expected) severity note;
                else
                    report "Fehler bei Paket #" & integer'image(expected) &
                        ": erwartet " & integer'image(expected) &
                        ", empfangen " & integer'image(received) severity error;
                    stop(0);
                end if;

                expected := expected + 1;
                delay    := rand_int(1, read_delay);
            elsif O_Valid = '1' and I_Ready = '1' then
                I_Ready <= '0';
            end if;

            if delay /= 0 then
                delay := delay - 1;
            end if;
        end loop;
    end process;

end architecture behavior;
