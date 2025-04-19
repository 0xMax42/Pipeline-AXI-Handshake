library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineSwitch_tb is
end entity PipelineSwitch_tb;

architecture RTL of PipelineSwitch_tb is
    constant G_MaskWidth         : integer                                    := 4;
    constant G_Mask              : std_logic_vector(G_MaskWidth - 1 downto 0) := "1101";

    -- === Signals for mode "none" ===
    signal I_Match_none          : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_none          : std_logic                                  := '0';
    signal O_Ready_none          : std_logic;
    signal O_Default_Valid_none  : std_logic;
    signal I_Default_Ready_none  : std_logic := '0';
    signal O_Selected_Valid_none : std_logic;
    signal I_Selected_Ready_none : std_logic                                  := '0';

    -- === Signals for mode "or" ===
    signal I_Match_or            : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_or            : std_logic                                  := '0';
    signal O_Ready_or            : std_logic;
    signal O_Default_Valid_or    : std_logic;
    signal I_Default_Ready_or    : std_logic := '0';
    signal O_Selected_Valid_or   : std_logic;
    signal I_Selected_Ready_or   : std_logic                                  := '0';

    -- === Signals for mode "and" ===
    signal I_Match_and           : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_and           : std_logic                                  := '0';
    signal O_Ready_and           : std_logic;
    signal O_Default_Valid_and   : std_logic;
    signal I_Default_Ready_and   : std_logic := '0';
    signal O_Selected_Valid_and  : std_logic;
    signal I_Selected_Ready_and  : std_logic                                  := '0';

    -- === Signals for mode "xor" ===
    signal I_Match_xor           : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_xor           : std_logic                                  := '0';
    signal O_Ready_xor           : std_logic;
    signal O_Default_Valid_xor   : std_logic;
    signal I_Default_Ready_xor   : std_logic := '0';
    signal O_Selected_Valid_xor  : std_logic;
    signal I_Selected_Ready_xor  : std_logic                                  := '0';

    -- === Signals for mode "equal" ===
    signal I_Match_eq            : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_eq            : std_logic                                  := '0';
    signal O_Ready_eq            : std_logic;
    signal O_Default_Valid_eq    : std_logic;
    signal I_Default_Ready_eq    : std_logic := '0';
    signal O_Selected_Valid_eq   : std_logic;
    signal I_Selected_Ready_eq   : std_logic                                  := '0';

    -- === Signals for mode "not_eq" ===
    signal I_Match_neq           : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_neq           : std_logic                                  := '0';
    signal O_Ready_neq           : std_logic;
    signal O_Default_Valid_neq   : std_logic;
    signal I_Default_Ready_neq   : std_logic := '0';
    signal O_Selected_Valid_neq  : std_logic;
    signal I_Selected_Ready_neq  : std_logic                                  := '0';

    -- === Signals for mode "gt" ===
    signal I_Match_gt            : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_gt            : std_logic                                  := '0';
    signal O_Ready_gt            : std_logic;
    signal O_Default_Valid_gt    : std_logic;
    signal I_Default_Ready_gt    : std_logic := '0';
    signal O_Selected_Valid_gt   : std_logic;
    signal I_Selected_Ready_gt   : std_logic                                  := '0';

    -- === Signals for mode "ge" ===
    signal I_Match_ge            : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_ge            : std_logic                                  := '0';
    signal O_Ready_ge            : std_logic;
    signal O_Default_Valid_ge    : std_logic;
    signal I_Default_Ready_ge    : std_logic := '0';
    signal O_Selected_Valid_ge   : std_logic;
    signal I_Selected_Ready_ge   : std_logic                                  := '0';

    -- === Signals for mode "lt" ===
    signal I_Match_lt            : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_lt            : std_logic                                  := '0';
    signal O_Ready_lt            : std_logic;
    signal O_Default_Valid_lt    : std_logic;
    signal I_Default_Ready_lt    : std_logic := '0';
    signal O_Selected_Valid_lt   : std_logic;
    signal I_Selected_Ready_lt   : std_logic                                  := '0';

    -- === Signals for mode "le" ===
    signal I_Match_le            : std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');
    signal I_Valid_le            : std_logic                                  := '0';
    signal O_Ready_le            : std_logic;
    signal O_Default_Valid_le    : std_logic;
    signal I_Default_Ready_le    : std_logic := '0';
    signal O_Selected_Valid_le   : std_logic;
    signal I_Selected_Ready_le   : std_logic := '0';

begin

    -- === Instanz: "none" ===
    UUT_none : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "none"
        )
        port map(
            I_Match          => I_Match_none,
            I_Valid          => I_Valid_none,
            O_Ready          => O_Ready_none,
            O_Default_Valid  => O_Default_Valid_none,
            I_Default_Ready  => I_Default_Ready_none,
            O_Selected_Valid => O_Selected_Valid_none,
            I_Selected_Ready => I_Selected_Ready_none
        );

    -- === Instanz: "or" ===
    UUT_or : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "or"
        )
        port map(
            I_Match          => I_Match_or,
            I_Valid          => I_Valid_or,
            O_Ready          => O_Ready_or,
            O_Default_Valid  => O_Default_Valid_or,
            I_Default_Ready  => I_Default_Ready_or,
            O_Selected_Valid => O_Selected_Valid_or,
            I_Selected_Ready => I_Selected_Ready_or
        );

    -- === Instanz: "and" ===
    UUT_and : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "and"
        )
        port map(
            I_Match          => I_Match_and,
            I_Valid          => I_Valid_and,
            O_Ready          => O_Ready_and,
            O_Default_Valid  => O_Default_Valid_and,
            I_Default_Ready  => I_Default_Ready_and,
            O_Selected_Valid => O_Selected_Valid_and,
            I_Selected_Ready => I_Selected_Ready_and
        );

    -- === Instanz: "xor" ===
    UUT_xor : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "xor"
        )
        port map(
            I_Match          => I_Match_xor,
            I_Valid          => I_Valid_xor,
            O_Ready          => O_Ready_xor,
            O_Default_Valid  => O_Default_Valid_xor,
            I_Default_Ready  => I_Default_Ready_xor,
            O_Selected_Valid => O_Selected_Valid_xor,
            I_Selected_Ready => I_Selected_Ready_xor
        );

    -- === Instanz: "equal" ===
    UUT_eq : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "equal"
        )
        port map(
            I_Match          => I_Match_eq,
            I_Valid          => I_Valid_eq,
            O_Ready          => O_Ready_eq,
            O_Default_Valid  => O_Default_Valid_eq,
            I_Default_Ready  => I_Default_Ready_eq,
            O_Selected_Valid => O_Selected_Valid_eq,
            I_Selected_Ready => I_Selected_Ready_eq
        );

    -- === Instanz: "not_eq" ===
    UUT_neq : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "not_equal"
        )
        port map(
            I_Match          => I_Match_neq,
            I_Valid          => I_Valid_neq,
            O_Ready          => O_Ready_neq,
            O_Default_Valid  => O_Default_Valid_neq,
            I_Default_Ready  => I_Default_Ready_neq,
            O_Selected_Valid => O_Selected_Valid_neq,
            I_Selected_Ready => I_Selected_Ready_neq
        );

    -- === Instanz: "gt" ===
    UUT_gt : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "gt"
        )
        port map(
            I_Match          => I_Match_gt,
            I_Valid          => I_Valid_gt,
            O_Ready          => O_Ready_gt,
            O_Default_Valid  => O_Default_Valid_gt,
            I_Default_Ready  => I_Default_Ready_gt,
            O_Selected_Valid => O_Selected_Valid_gt,
            I_Selected_Ready => I_Selected_Ready_gt
        );

    -- === Instanz: "ge" ===
    UUT_ge : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "ge"
        )
        port map(
            I_Match          => I_Match_ge,
            I_Valid          => I_Valid_ge,
            O_Ready          => O_Ready_ge,
            O_Default_Valid  => O_Default_Valid_ge,
            I_Default_Ready  => I_Default_Ready_ge,
            O_Selected_Valid => O_Selected_Valid_ge,
            I_Selected_Ready => I_Selected_Ready_ge
        );

    -- === Instanz: "lt" ===
    UUT_lt : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "lt"
        )
        port map(
            I_Match          => I_Match_lt,
            I_Valid          => I_Valid_lt,
            O_Ready          => O_Ready_lt,
            O_Default_Valid  => O_Default_Valid_lt,
            I_Default_Ready  => I_Default_Ready_lt,
            O_Selected_Valid => O_Selected_Valid_lt,
            I_Selected_Ready => I_Selected_Ready_lt
        );

    -- === Instanz: "le" ===
    UUT_le : entity work.PipelineSwitch
        generic map(
            G_MaskWidth => G_MaskWidth,
            G_Mask      => G_Mask,
            G_MaskMode  => "le"
        )
        port map(
            I_Match          => I_Match_le,
            I_Valid          => I_Valid_le,
            O_Ready          => O_Ready_le,
            O_Default_Valid  => O_Default_Valid_le,
            I_Default_Ready  => I_Default_Ready_le,
            O_Selected_Valid => O_Selected_Valid_le,
            I_Selected_Ready => I_Selected_Ready_le
        );

    stimulus : process
    begin
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "none"
        ----------------------------------------------------------------
        report "Testmodus: none";
        I_Default_Ready_none <= '1';
        I_Match_none         <= "0000";
        I_Valid_none         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_none = '1' and O_Selected_Valid_none = '0'
        report "Fehler im Modus 'none'" severity error;
        I_Valid_none         <= '0';
        I_Default_Ready_none <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "or"
        ----------------------------------------------------------------
        report "Testmodus: or";
        I_Selected_Ready_or <= '1';
        I_Match_or          <= "0100"; -- bit 2 matches mask
        I_Valid_or          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_or = '1' and O_Default_Valid_or = '0'
        report "Fehler im Modus 'or' (Match-Fall)" severity error;
        I_Selected_Ready_or <= '0';
        I_Valid_or          <= '0';
        wait for 10 ns;

        I_Default_Ready_or <= '1';
        I_Match_or         <= "0010"; -- no bit matches mask
        I_Valid_or         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_or = '1' and O_Selected_Valid_or = '0'
        report "Fehler im Modus 'or' (No-Match-Fall)" severity error;
        I_Default_Ready_or <= '0';
        I_Valid_or         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "and"
        ----------------------------------------------------------------
        report "Testmodus: and";
        I_Selected_Ready_and <= '1';
        I_Match_and          <= "1101";
        I_Valid_and          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_and = '1' and O_Default_Valid_and = '0'
        report "Fehler im Modus 'and' (Match-Fall)" severity error;
        I_Selected_Ready_and <= '0';
        I_Valid_and          <= '0';
        wait for 10 ns;

        I_Default_Ready_and <= '1';
        I_Match_and         <= "1001"; -- bit 2 missing
        I_Valid_and         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_and = '1' and O_Selected_Valid_and = '0'
        report "Fehler im Modus 'and' (No-Match-Fall)" severity error;
        I_Default_Ready_and <= '0';
        I_Valid_and         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "xor"
        ----------------------------------------------------------------
        report "Testmodus: xor";
        I_Selected_Ready_xor <= '1';
        I_Match_xor          <= "1001"; -- differs at bit 2
        I_Valid_xor          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_xor = '1' and O_Default_Valid_xor = '0'
        report "Fehler im Modus 'xor' (Match-Fall)" severity error;
        I_Selected_Ready_xor <= '0';
        I_Valid_xor          <= '0';
        wait for 10 ns;

        I_Default_Ready_xor <= '1';
        I_Match_xor         <= "1101";
        I_Valid_xor         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_xor = '1' and O_Selected_Valid_xor = '0'
        report "Fehler im Modus 'xor' (No-Match-Fall)" severity error;
        I_Default_Ready_xor <= '0';
        I_Valid_xor         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "equal"
        ----------------------------------------------------------------
        report "Testmodus: equal";
        I_Selected_Ready_eq <= '1';
        I_Match_eq          <= "1101";
        I_Valid_eq          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_eq = '1' and O_Default_Valid_eq = '0'
        report "Fehler im Modus 'equal' (Match-Fall)" severity error;
        I_Selected_Ready_eq <= '0';
        I_Valid_eq          <= '0';
        wait for 10 ns;

        I_Default_Ready_eq <= '1';
        I_Match_eq         <= "1111";
        I_Valid_eq         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_eq = '1' and O_Selected_Valid_eq = '0'
        report "Fehler im Modus 'equal' (No-Match-Fall)" severity error;
        I_Default_Ready_eq <= '0';
        I_Valid_eq         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "not_equal"
        ----------------------------------------------------------------
        report "Testmodus: not_equal";
        I_Selected_Ready_neq <= '1';
        I_Match_neq          <= "1111"; -- not equal
        I_Valid_neq          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_neq = '1' and O_Default_Valid_neq = '0'
        report "Fehler im Modus 'not_equal' (Match-Fall)" severity error;
        I_Selected_Ready_neq <= '0';
        I_Valid_neq          <= '0';
        wait for 10 ns;

        I_Default_Ready_neq <= '1';
        I_Match_neq         <= "1101";
        I_Valid_neq         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_neq = '1' and O_Selected_Valid_neq = '0'
        report "Fehler im Modus 'not_equal' (No-Match-Fall)" severity error;
        I_Default_Ready_neq <= '0';
        I_Valid_neq         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "gt"
        ----------------------------------------------------------------
        report "Testmodus: gt";
        I_Selected_Ready_gt <= '1';
        I_Match_gt          <= "1110"; -- > 1101
        I_Valid_gt          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_gt = '1' and O_Default_Valid_gt = '0'
        report "Fehler im Modus 'gt' (Match-Fall)" severity error;
        I_Selected_Ready_gt <= '0';
        I_Valid_gt          <= '0';
        wait for 10 ns;

        I_Default_Ready_gt <= '1';
        I_Match_gt         <= "1010"; -- < 1101
        I_Valid_gt         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_gt = '1' and O_Selected_Valid_gt = '0'
        report "Fehler im Modus 'gt' (No-Match-Fall)" severity error;
        I_Default_Ready_gt <= '0';
        I_Valid_gt         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "ge"
        ----------------------------------------------------------------
        report "Testmodus: ge";
        I_Selected_Ready_ge <= '1';
        I_Match_ge          <= "1101"; -- == 1101
        I_Valid_ge          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_ge = '1' and O_Default_Valid_ge = '0'
        report "Fehler im Modus 'ge' (Match-Fall ==)" severity error;
        I_Selected_Ready_ge <= '0';
        I_Valid_ge          <= '0';
        wait for 10 ns;

        I_Default_Ready_ge <= '1';
        I_Match_ge         <= "0101"; -- < 1101
        I_Valid_ge         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_ge = '1' and O_Selected_Valid_ge = '0'
        report "Fehler im Modus 'ge' (No-Match-Fall)" severity error;
        I_Default_Ready_ge <= '0';
        I_Valid_ge         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "lt"
        ----------------------------------------------------------------
        report "Testmodus: lt";
        I_Selected_Ready_lt <= '1';
        I_Match_lt          <= "0101"; -- < 1101
        I_Valid_lt          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_lt = '1' and O_Default_Valid_lt = '0'
        report "Fehler im Modus 'lt' (Match-Fall)" severity error;
        I_Selected_Ready_lt <= '0';
        I_Valid_lt          <= '0';
        wait for 10 ns;

        I_Default_Ready_lt <= '1';
        I_Match_lt         <= "1111"; -- > 1101
        I_Valid_lt         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_lt = '1' and O_Selected_Valid_lt = '0'
        report "Fehler im Modus 'lt' (No-Match-Fall)" severity error;
        I_Default_Ready_lt <= '0';
        I_Valid_lt         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Mode: "le"
        ----------------------------------------------------------------
        report "Testmodus: le";
        I_Selected_Ready_le <= '1';
        I_Match_le          <= "1101"; -- == 1101
        I_Valid_le          <= '1';
        wait for 10 ns;
        assert O_Selected_Valid_le = '1' and O_Default_Valid_le = '0'
        report "Fehler im Modus 'le' (Match-Fall ==)" severity error;
        I_Selected_Ready_le <= '0';
        I_Valid_le          <= '0';
        wait for 10 ns;

        I_Default_Ready_le <= '1';
        I_Match_le         <= "1111"; -- > 1101
        I_Valid_le         <= '1';
        wait for 10 ns;
        assert O_Default_Valid_le = '1' and O_Selected_Valid_le = '0'
        report "Fehler im Modus 'le' (No-Match-Fall)" severity error;
        I_Default_Ready_le <= '0';
        I_Valid_le         <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Done!
        ----------------------------------------------------------------
        report "Alle Tests abgeschlossen!" severity note;
        wait;
    end process;

end architecture RTL;
