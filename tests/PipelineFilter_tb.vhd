library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineFilter_tb is
end entity PipelineFilter_tb;

architecture RTL of PipelineFilter_tb is
    -- Konstanten
    constant G_MaskWidth : integer                                    := 4;
    constant G_Mask      : std_logic_vector(G_MaskWidth - 1 downto 0) := "1101";

    -- Signale für Modus "none"
    signal I_Match_none  : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_none  : std_logic                                  := '0';
    signal O_Ready_none  : std_logic;
    signal O_Valid_none  : std_logic;
    signal I_Ready_none  : std_logic                                  := '0';

    -- Signale für Modus "or"
    signal I_Match_or    : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_or    : std_logic                                  := '0';
    signal O_Ready_or    : std_logic;
    signal O_Valid_or    : std_logic;
    signal I_Ready_or    : std_logic                                  := '0';

    -- Signale für Modus "and"
    signal I_Match_and   : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_and   : std_logic                                  := '0';
    signal O_Ready_and   : std_logic;
    signal O_Valid_and   : std_logic;
    signal I_Ready_and   : std_logic                                  := '0';

    -- Signale für Modus "xor"
    signal I_Match_xor   : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_xor   : std_logic                                  := '0';
    signal O_Ready_xor   : std_logic;
    signal O_Valid_xor   : std_logic;
    signal I_Ready_xor   : std_logic                                  := '0';

    -- Signale für Modus "equal"
    signal I_Match_equal : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_equal : std_logic                                  := '0';
    signal O_Ready_equal : std_logic;
    signal O_Valid_equal : std_logic;
    signal I_Ready_equal : std_logic                                  := '0';

    -- Signale für Modus "not_equal"
    signal I_Match_neq   : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_neq   : std_logic                                  := '0';
    signal O_Ready_neq   : std_logic;
    signal O_Valid_neq   : std_logic;
    signal I_Ready_neq   : std_logic := '0';

begin

    -- Instanz für Modus "none"
    UUT_none : entity work.PipelineFilter
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "none"
        )
        port map(
            I_Match => I_Match_none,
            I_Valid => I_Valid_none,
            O_Ready => O_Ready_none,
            O_Valid => O_Valid_none,
            I_Ready => I_Ready_none
        );

    -- Instanz für Modus "or"
    UUT_or : entity work.PipelineFilter
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "or"
        )
        port map(
            I_Match => I_Match_or,
            I_Valid => I_Valid_or,
            O_Ready => O_Ready_or,
            O_Valid => O_Valid_or,
            I_Ready => I_Ready_or
        );

    -- Instanz für Modus "and"
    UUT_and : entity work.PipelineFilter
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "and"
        )
        port map(
            I_Match => I_Match_and,
            I_Valid => I_Valid_and,
            O_Ready => O_Ready_and,
            O_Valid => O_Valid_and,
            I_Ready => I_Ready_and
        );

    -- Instanz für Modus "xor"
    UUT_xor : entity work.PipelineFilter
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "xor"
        )
        port map(
            I_Match => I_Match_xor,
            I_Valid => I_Valid_xor,
            O_Ready => O_Ready_xor,
            O_Valid => O_Valid_xor,
            I_Ready => I_Ready_xor
        );

    -- Instanz für Modus "equal"
    UUT_equal : entity work.PipelineFilter
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "equal"
        )
        port map(
            I_Match => I_Match_equal,
            I_Valid => I_Valid_equal,
            O_Ready => O_Ready_equal,
            O_Valid => O_Valid_equal,
            I_Ready => I_Ready_equal
        );

    -- Instanz für Modus "not_equal"
    UUT_neq : entity work.PipelineFilter
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "not_equal"
        )
        port map(
            I_Match => I_Match_neq,
            I_Valid => I_Valid_neq,
            O_Ready => O_Ready_neq,
            O_Valid => O_Valid_neq,
            I_Ready => I_Ready_neq
        );

    stimulus : process
    begin
        wait for 10 ns;
        ----------------------------------------------------------------
        -- Test: Modus "none" (es darf nie gefiltert werden)
        ----------------------------------------------------------------
        report "Testmodus: none";
        I_Ready_none <= '1';
        I_Match_none <= "1101"; -- Irgendein Wert
        I_Valid_none <= '1';
        wait for 10 ns;
        assert O_Valid_none = '1'
        report "Fehler: Modus 'none' hat Paket gefiltert" severity error;
        I_Valid_none <= '0';
        I_Ready_none <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test: Modus "or" (filtert, wenn irgendein gesetztes Bit aus Maske auch in Match ist)
        ----------------------------------------------------------------
        report "Testmodus: or";
        I_Ready_or <= '1';
        I_Match_or <= "0000"; -- sollte durchgelassen werden
        I_Valid_or <= '1';
        wait for 10 ns;
        assert O_Valid_or = '1'
        report "Fehler: Paket mit 0000 wurde faelschlich gefiltert (or)" severity error;

        I_Match_or <= "0100"; -- sollte gefiltert werden
        wait for 10 ns;
        assert O_Valid_or = '0'
        report "Fehler: Paket mit 0100 wurde nicht gefiltert (or)" severity error;

        I_Valid_or <= '0';
        I_Ready_or <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test: Modus "and" (filtert, wenn alle gesetzten Maskenbits auch in Match sind)
        ----------------------------------------------------------------
        report "Testmodus: and";
        I_Ready_and <= '1';
        I_Match_and <= "1101"; -- erfüllt Maske → filtern
        I_Valid_and <= '1';
        wait for 10 ns;
        assert O_Valid_and = '0'
        report "Fehler: Paket mit 1101 wurde nicht gefiltert (and)" severity error;

        I_Match_and <= "1001"; -- fehlt Bit 2 → durchlassen
        wait for 10 ns;
        assert O_Valid_and = '1'
        report "Fehler: Paket mit 1001 wurde faelschlich gefiltert (and)" severity error;

        I_Valid_and <= '0';
        I_Ready_and <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test: Modus "xor" (filtert, wenn sich mindestens 1 Bit unterscheidet)
        ----------------------------------------------------------------
        report "Testmodus: xor";
        I_Ready_xor <= '1';
        I_Match_xor <= "1101"; -- identisch → durchlassen
        I_Valid_xor <= '1';
        wait for 10 ns;
        assert O_Valid_xor = '1'
        report "Fehler: Paket mit 1101 wurde faelschlich gefiltert (xor)" severity error;

        I_Match_xor <= "1111"; -- Unterschied → filtern
        wait for 10 ns;
        assert O_Valid_xor = '0'
        report "Fehler: Paket mit 1111 wurde nicht gefiltert (xor)" severity error;

        I_Valid_xor <= '0';
        I_Ready_xor <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test: Modus "equal" (filtert, wenn genau gleich)
        ----------------------------------------------------------------
        report "Testmodus: equal";
        I_Ready_equal <= '1';
        I_Match_equal <= "1101"; -- genau gleich → filtern
        I_Valid_equal <= '1';
        wait for 10 ns;
        assert O_Valid_equal = '0'
        report "Fehler: Paket mit 1101 wurde nicht gefiltert (equal)" severity error;

        I_Match_equal <= "1111"; -- ungleich → durchlassen
        wait for 10 ns;
        assert O_Valid_equal = '1'
        report "Fehler: Paket mit 1111 wurde faelschlich gefiltert (equal)" severity error;

        I_Valid_equal <= '0';
        I_Ready_equal <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test: Modus "not_equal" (filtert, wenn ungleich)
        ----------------------------------------------------------------
        report "Testmodus: not_equal";
        I_Ready_neq <= '1';
        I_Match_neq <= "1101"; -- gleich → durchlassen
        I_Valid_neq <= '1';
        wait for 10 ns;
        assert O_Valid_neq = '1'
        report "Fehler: Paket mit 1101 wurde faelschlich gefiltert (not_equal)" severity error;

        I_Match_neq <= "1111"; -- ungleich → filtern
        wait for 10 ns;
        assert O_Valid_neq = '0'
        report "Fehler: Paket mit 1111 wurde nicht gefiltert (not_equal)" severity error;

        I_Valid_neq <= '0';
        I_Ready_neq <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Abschluss
        ----------------------------------------------------------------
        report "Alle Tests abgeschlossen." severity note;
        wait;
    end process;

end architecture RTL;
