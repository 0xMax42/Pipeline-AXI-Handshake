library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Pipeline_tb is
    -- The testbench does not require any ports
end entity Pipeline_tb;

architecture behavior of Pipeline_tb is
    shared variable seed1                     : integer := 483;
    shared variable seed2                     : integer := 847;
    impure function rand_int(min_val, max_val : integer) return integer is
        variable r                                : real;
    begin
        uniform(seed1, seed2, r);
        return integer(
        round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
    end function;

    -- Clock signal period
    constant period : time := 20 ns;

    -- Adjustable wait times
    constant write_delay : natural := 10; -- Maximal wait time between write operations in clock cycles
    constant read_delay  : natural := 10; -- Maximal wait time between read operations in clock cycles

    -- Setting constants for the FIFO to be tested
    constant K_Width             : integer := 32;    -- Data width of the FIFO
    constant K_PipelineStages    : integer := 3;     -- Number of pipeline stages
    constant K_RegisterBalancing : string  := "yes"; -- Register balancing attribute

    -- Testbench signals
    signal CLK : std_logic := '0';
    signal RST : std_logic := '1';
    signal CE  : std_logic := '1';

    signal I_Data  : std_logic_vector(K_Width - 1 downto 0) := (others => 'U');
    signal I_Valid : std_logic                              := '0';
    signal O_Ready : std_logic;

    signal O_Data  : std_logic_vector(K_Width - 1 downto 0) := (others => 'U');
    signal O_Valid : std_logic;
    signal I_Ready : std_logic := '0';

    signal PipelineEnable : std_logic;
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
    Write : process (CLK)
        variable delay : integer := 0;
        variable i     : integer := 1;
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                I_Valid <= '0';
                delay := write_delay;
                i     := 1;
                I_Data <= (others => 'U');
            else
                if O_Ready = '1' and delay = 0 then
                    I_Data  <= std_logic_vector(to_unsigned(i, K_Width)); -- Data to be written
                    I_Valid <= '1';
                    i     := i + 1;
                    delay := rand_int(1, write_delay);
                elsif O_Ready = '1' and I_Valid = '1' then
                    I_Valid <= '0';
                end if;
                if delay /= 0 then
                    delay := delay - 1;
                end if;
            end if;
        end if;
    end process;

    -- Read process
    Read : process (CLK)
        variable delay : integer := 0;
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                I_Ready <= '0';
                delay := read_delay;
            else
                if O_Valid = '1' and delay = 0 then
                    I_Ready <= '1'; -- Signal readiness to read
                    delay := rand_int(1, read_delay);
                elsif O_Valid = '1' and I_Ready = '1' then
                    I_Ready <= '0';
                end if;
                if delay /= 0 then
                    delay := delay - 1;
                end if;
            end if;
        end if;
    end process;

end architecture behavior;
