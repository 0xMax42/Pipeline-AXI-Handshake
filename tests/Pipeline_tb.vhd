library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pipeline_tb is
    -- The testbench does not require any ports
end entity Pipeline_tb;

architecture behavior of Pipeline_tb is
    -- Clock signal period
    constant period : time := 20 ns;

    -- Adjustable wait times
    constant write_delay : natural := 0; -- Wait time between write operations in clock cycles
    constant read_delay  : natural := 0; -- Wait time between read operations in clock cycles

    -- Adjustable number of data values to be written
    constant writes : natural := 100;

    -- Setting constants for the FIFO to be tested
    constant K_Width             : integer := 32;    -- Data width of the FIFO
    constant K_PipelineStages    : integer := 3;     -- Number of pipeline stages
    constant K_RegisterBalancing : string  := "yes"; -- Register balancing attribute

    -- Testbench signals
    signal CLK : std_logic := '0';
    signal RST : std_logic := '1';

    signal I_WriteCE : std_logic                              := '0';
    signal I_Data    : std_logic_vector(K_Width - 1 downto 0) := (others => 'U');
    signal I_Valid   : std_logic                              := '0';
    signal O_Ready   : std_logic;

    signal I_ReadCE : std_logic := '0';
    signal O_Data   : std_logic_vector(K_Width - 1 downto 0);
    signal O_Valid  : std_logic;
    signal I_Ready  : std_logic := '0';

    signal CE : std_logic := '1';

    signal PipelineEnable : std_logic;
begin
    CE <= I_WriteCE or I_ReadCE;

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
    clocking : process
    begin
        while true loop
            CLK <= '0';
            wait for period / 2;
            CLK <= '1';
            wait for period / 2;
        end loop;
    end process;

    -- Write process adapted for the falling edge of the clock signal
    write_process : process
    begin
        wait for 100 ns; -- Initial wait time for reset and FIFO initialization
        RST <= '0';
        wait for period; -- Wait an additional clock cycle after reset
        I_WriteCE <= '1';
        wait until falling_edge(CLK);
        for i in 0 to writes loop -- Writing loop for data values
            if O_Ready = '0' then
                wait on O_Ready until O_Ready = '1';
                wait until falling_edge(CLK);
            end if;

            I_Data  <= std_logic_vector(to_unsigned(i, K_Width)); -- Data to be written
            I_Valid <= '1';
            wait until falling_edge(CLK);
            I_Valid <= '0'; -- Reset 'valid' after writing
            for j in 1 to write_delay loop
                wait until falling_edge(CLK); -- Wait based on the set wait time
            end loop;
        end loop;
        I_WriteCE <= '0'; -- Deactivate write signal after writing
        wait;
    end process;

    -- Read process adapted for the falling edge of the clock signal
    read_process : process
    begin
        wait for 110 ns; -- Delay to start writing
        I_ReadCE <= '1';
        while true loop
            if O_Valid = '1' and I_Ready = '0' then
                I_Ready <= '1'; -- Signal readiness to read
                wait until falling_edge(CLK);
                if read_delay /= 0 then
                    I_Ready <= '0'; -- Reset the signal after reading
                end if;
                for j in 1 to read_delay loop
                    wait until falling_edge(CLK); -- Wait based on the set wait time
                end loop;
            else
                wait until falling_edge(CLK); -- Synchronize with the clock when not ready to read
            end if;
        end loop;
    end process;

end architecture behavior;
