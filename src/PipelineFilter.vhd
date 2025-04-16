library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineFilter is
    generic (
        --@ Width of the comparison input and mask.
        G_MaskWidth : integer          := 4;

        --@ Bit mask to be compared against `I_Match` input.
        G_Mask      : std_logic_vector := "1010";

        --@ Comparison mode that defines the filter behavior.
        --@ Available modes:
        --@ - `"none"`: Disables filtering; always passes data.
        --@ - `"or"`:     Filters if **any** bit in `I_Match` matches a bit set in `G_Mask`.
        --@ - `"and"`:    Filters if **all** bits set in `G_Mask` are also set in `I_Match`.
        --@ - `"xor"`:    Filters if **any** bit differs between `I_Match` and `G_Mask`.
        --@ - `"equal"`:  Filters if `I_Match` is **bitwise equal** to `G_Mask`.
        --@ - `"not_equal"`: Filters if `I_Match` is **not equal** to `G_Mask`.
        G_MaskMode  : string           := "equal"
    );
    port (
        I_Match : in  std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');

        --@ @virtualbus AXI-Flags-In @dir In Input interface for AXI-like handshake
        --@ AXI like valid; (**Synchronous**, **Active high**)
        I_Valid : in  std_logic                                  := '0';
        --@ AXI like ready; (**Synchronous**, **Active high**)
        O_Ready : out std_logic                                  := '0';
        --@ @end

        --@ @virtualbus AXI-Flags-Out @dir Out Output interface for AXI-like handshake
        --@ AXI like valid; (**Synchronous**, **Active high**)
        O_Valid : out std_logic                                  := '0';
        --@ AXI like ready; (**Synchronous**, **Active high**)
        I_Ready : in  std_logic                                  := '0'
        --@ @end
    );
end entity PipelineFilter;

architecture RTL of PipelineFilter is
    function strings_equal(A, B : string) return boolean is
    begin
        if A'length /= B'length then
            return false;
        end if;

        for i in A'range loop
            if A(i) /= B(i) then
                return false;
            end if;
        end loop;

        return true;
    end function;

    constant K_Mode_None     : string    := "none";
    constant K_Mode_OR       : string    := "or";
    constant K_Mode_XOR      : string    := "xor";
    constant K_Mode_AND      : string    := "and";
    constant K_Mode_Equal    : string    := "equal";
    constant K_Mode_NotEqual : string    := "not_equal";

    signal C_ShouldFiltered  : std_logic := '0';
begin
    assert G_Mask'length = G_MaskWidth
    report "G_Mask length does not match G_MaskWidth" severity failure;

    process (I_Match)
    begin
        if strings_equal(G_MaskMode, K_Mode_None) then
            --@ No filtering: Always pass the data through.
            C_ShouldFiltered <= '0';

        elsif strings_equal(G_MaskMode, K_Mode_OR) then
            --@ Filter if **any** bit in I_Match matches a bit set in G_Mask.
            --@ Equivalent to: (I_Match AND G_Mask) /= 0
            if (I_Match and G_Mask) /= (G_MaskWidth - 1 downto 0 => '0') then
                C_ShouldFiltered <= '1';
            else
                C_ShouldFiltered <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_XOR) then
            --@ Filter if **any** bit differs between I_Match and G_Mask.
            --@ This checks if the vectors are **not bitwise equal**.
            if (I_Match xor G_Mask) /= (G_MaskWidth - 1 downto 0 => '0') then
                C_ShouldFiltered <= '1';
            else
                C_ShouldFiltered <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_AND) then
            --@ Filter if **all bits** set in G_Mask are also set in I_Match.
            --@ In other words, I_Match must contain the full mask.
            if (I_Match and G_Mask) = G_Mask then
                C_ShouldFiltered <= '1';
            else
                C_ShouldFiltered <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_Equal) then
            --@ Filter if I_Match is **exactly equal** to G_Mask.
            if I_Match = G_Mask then
                C_ShouldFiltered <= '1';
            else
                C_ShouldFiltered <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_NotEqual) then
            --@ Filter if I_Match is **not equal** to G_Mask.
            if I_Match /= G_Mask then
                C_ShouldFiltered <= '1';
            else
                C_ShouldFiltered <= '0';
            end if;

        else
            --@ Unknown mode: fallback to no filtering.
            C_ShouldFiltered <= '0';
        end if;
    end process;

    process (I_Valid, I_Ready, C_ShouldFiltered)
    begin
        if C_ShouldFiltered = '1' then
            --@ Data is filtered: do not pass it through.
            O_Valid <= '0';
            --@ Assert O_Ready to indicate that the input is ready to accept data.
            O_Ready <= '1';
        else
            --@ Data is not filtered: pass it through.
            O_Valid <= I_Valid;
            O_Ready <= I_Ready;
        end if;
    end process;

end architecture;
