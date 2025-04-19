library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity PipelineBuffer_tb is
end entity PipelineBuffer_tb;

architecture RTL of PipelineBuffer_tb is
    -- Clock signal period
    constant K_Period                         : time      := 20 ns;

    -- Zufallsverzögerungen
    constant K_WriteDelay                     : natural   := 40;
    constant K_ReadDelay                      : natural   := 60;

    -- Konstanten
    constant G_ResetActiveAt                  : std_logic := '1';
    constant G_Width                          : integer   := 32;

    -- Zufalls-Seed
    shared variable seed1                     : integer   := 42;
    shared variable seed2                     : integer   := 1337;

    -- Randomfunktion
    impure function rand_int(min_val, max_val : integer) return integer is
        variable r                                : real;
    begin
        uniform(seed1, seed2, r);
        return integer(round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
    end function;

    -- Signale
    signal I_CLK    : std_logic                              := '0';
    signal I_RST    : std_logic                              := '1';
    signal I_CE     : std_logic                              := '1';
    signal O_Enable : std_logic_vector(1 downto 0)           := (others => '0');
    signal I_Valid  : std_logic                              := '0';
    signal O_Ready  : std_logic                              := '0';
    signal O_Valid  : std_logic                              := '0';
    signal I_Ready  : std_logic                              := '0';

    signal I_Data   : std_logic_vector(G_Width - 1 downto 0) := (others => 'U');
    signal O_Data   : std_logic_vector(G_Width - 1 downto 0) := (others => 'U');

begin
    -- Clock
    Clocking : process
    begin
        while true loop
            I_CLK <= '0';
            wait for (K_Period / 2);
            I_CLK <= '1';
            wait for (K_Period / 2);
        end loop;
    end process;

    -- Reset
    I_RST <= G_ResetActiveAt, not G_ResetActiveAt after 100 ns;

    -- DUT: Controller
    i_PipelineBufferController : entity work.PipelineBufferController
        generic map(
            G_ResetActiveAt => G_ResetActiveAt
        )
        port map(
            I_CLK    => I_CLK,
            I_RST    => I_RST,
            I_CE     => I_CE,
            O_Enable => O_Enable,
            I_Valid  => I_Valid,
            O_Ready  => O_Ready,
            O_Valid  => O_Valid,
            I_Ready  => I_Ready
        );

    -- DUT: Register
    i_PipelineBuffer : entity work.PipelineBuffer
        generic map(
            G_Width => G_Width
        )
        port map(
            I_CLK    => I_CLK,
            I_Enable => O_Enable,
            I_Data   => I_Data,
            O_Data   => O_Data
        );

    -- Write Stimulus
    Stim_Write : process
        variable delay   : integer := 0;
        variable i       : integer := 1;
        variable pending : boolean := false;
    begin
        I_Valid <= '0';
        I_Data  <= (others => 'U');
        wait until I_RST = '0';

        while true loop
            wait until rising_edge(I_CLK);

            -- Neues Paket vorbereiten
            if not pending and delay = 0 then
                I_Data  <= std_logic_vector(to_unsigned(i, G_Width));
                I_Valid <= '1';
                pending := true;
                report "Sende Paket #" & integer'image(i) severity note;
            end if;

            -- Handshake erfolgt
            if O_Ready = '1' and I_Valid = '1' then
                I_Valid <= '0';
                i       := i + 1;
                delay   := rand_int(1, K_WriteDelay);
                pending := false;
            end if;

            -- Verzögerung herunterzählen
            if delay > 0 and not pending then
                delay := delay - 1;
            end if;
        end loop;
    end process;

    -- Read Stimulus (robust)
    Stim_Read : process
        variable delay       : integer := 0;
        variable expected    : integer := 1;
        variable received    : integer;
        variable consume_now : boolean := false;
    begin
        I_Ready <= '0';
        wait until I_RST = '0';

        while true loop
            wait until rising_edge(I_CLK);

            -- Wenn O_Valid vorhanden und kein Delay mehr: jetzt lesen
            if O_Valid = '1' and delay = 0 and not consume_now then
                I_Ready <= '1';
                consume_now := true; -- Warte auf nächste Gültigkeit
            end if;

            -- Sobald Handshake erfolgt (O_Valid & I_Ready), auswerten
            if O_Valid = '1' and I_Ready = '1' and consume_now then
                received := to_integer(unsigned(O_Data));
                if received = expected then
                    report "Empfange Paket #" & integer'image(expected) severity note;
                else
                    report "FEHLER bei Paket #" & integer'image(expected) &
                        ": erwartet " & integer'image(expected) &
                        ", empfangen " & integer'image(received) severity error;
                end if;

                expected    := expected + 1;
                delay       := rand_int(1, K_ReadDelay);
                consume_now := false;
                I_Ready <= '0';
            end if;

            -- Wartezeit herunterzählen
            if delay > 0 and not consume_now then
                delay := delay - 1;
            end if;
        end loop;
    end process;

end architecture RTL;
