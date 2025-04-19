library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineSwitch is
    generic (
        --@ Width of the comparison input and mask.
        --@ This defines the bit width of `I_Match` and `G_Mask`.
        G_MaskWidth : integer          := 4;

        --@ Comparison mask or reference value used to control routing.
        --@ Its width must match `G_MaskWidth`.
        G_Mask      : std_logic_vector := "1010";

        --@ Comparison mode that determines to which output the data is routed.
        --@ Available modes:
        --@ - `"none"`:        Always route to `Default`.
        --@ - `"or"`:          Route to `Selected` if **any** bit in `I_Match` matches a set bit in `G_Mask`.
        --@ - `"and"`:         Route to `Selected` if **all** bits set in `G_Mask` are also set in `I_Match`.
        --@ - `"xor"`:         Route to `Selected` if **any** bit differs between `I_Match` and `G_Mask`.
        --@ - `"equal"`:       Route to `Selected` if `I_Match` is **bitwise equal** to `G_Mask`.
        --@ - `"not_equal"`:   Route to `Selected` if `I_Match` is **not equal** to `G_Mask`.
        --@ - `"gt"`:          Route to `Selected` if `I_Match` **>** `G_Mask` (unsigned).
        --@ - `"ge"`:          Route to `Selected` if `I_Match` **≥** `G_Mask`.
        --@ - `"lt"`:          Route to `Selected` if `I_Match` **<** `G_Mask`.
        --@ - `"le"`:          Route to `Selected` if `I_Match` **≤** `G_Mask`.
        G_MaskMode  : string           := "equal"
    );

    port (
        --@ Input value to be compared against `G_Mask` to determine routing.
        I_Match          : in  std_logic_vector(G_MaskWidth - 1 downto 0) := (others => '0');

        --@ @virtualbus AXI-Flags-In @dir In Input interface for AXI-like handshake
        --@ AXI-like valid; (**Synchronous**, **Active high**)
        I_Valid          : in  std_logic                                  := '0';
        --@ AXI-like ready; (**Synchronous**, **Active high**)
        O_Ready          : out std_logic                                  := '0';
        --@ @end

        --@ @virtualbus AXI-Flags-Out @dir Out Output interface for unmatched routing
        --@ Activated when the comparison **fails**.
        --@ AXI-like valid; (**Synchronous**, **Active high**)
        O_Default_Valid  : out std_logic                                  := '0';
        --@ AXI-like ready; (**Synchronous**, **Active high**)
        I_Default_Ready  : in  std_logic                                  := '0';
        --@ @end

        --@ @virtualbus AXI-Flags-Out @dir Out Output interface for matched routing
        --@ Activated when the comparison **succeeds**.
        --@ AXI-like valid; (**Synchronous**, **Active high**)
        O_Selected_Valid : out std_logic                                  := '0';
        --@ AXI-like ready; (**Synchronous**, **Active high**)
        I_Selected_Ready : in  std_logic                                  := '0'
        --@ @end
    );

end entity PipelineSwitch;

architecture RTL of PipelineSwitch is
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

    constant K_Mode_None           : string    := "none";
    constant K_Mode_OR             : string    := "or";
    constant K_Mode_XOR            : string    := "xor";
    constant K_Mode_AND            : string    := "and";
    constant K_Mode_Equal          : string    := "equal";
    constant K_Mode_NotEqual       : string    := "not_equal";
    constant K_Mode_GT             : string    := "gt";
    constant K_Mode_GE             : string    := "ge";
    constant K_Mode_LT             : string    := "lt";
    constant K_Mode_LE             : string    := "le";

    signal C_ShouldRouteToSelected : std_logic := '0';
begin
    assert G_Mask'length = G_MaskWidth
    report "G_Mask length does not match G_MaskWidth" severity failure;

    process (I_Match)
    begin
        if strings_equal(G_MaskMode, K_Mode_None) then
            --@ No condition: Always route to Default
            C_ShouldRouteToSelected <= '0';

        elsif strings_equal(G_MaskMode, K_Mode_OR) then
            --@ Route to Selected if any bit in I_Match is also set in G_Mask
            if (I_Match and G_Mask) /= (G_MaskWidth - 1 downto 0 => '0') then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_XOR) then
            --@ Route to Selected if any bit differs between I_Match and G_Mask
            if (I_Match xor G_Mask) /= (G_MaskWidth - 1 downto 0 => '0') then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_AND) then
            --@ Route to Selected if all bits set in G_Mask are also set in I_Match
            if (I_Match and G_Mask) = G_Mask then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_Equal) then
            --@ Route to Selected if I_Match is exactly equal to G_Mask
            if I_Match = G_Mask then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_NotEqual) then
            --@ Route to Selected if I_Match is not equal to G_Mask
            if I_Match /= G_Mask then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_GT) then
            --@ Route to Selected if I_Match > G_Mask (interpreted as unsigned)
            if unsigned(I_Match) > unsigned(G_Mask) then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_GE) then
            --@ Route to Selected if I_Match >= G_Mask (unsigned)
            if unsigned(I_Match) >= unsigned(G_Mask) then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_LT) then
            --@ Route to Selected if I_Match < G_Mask (unsigned)
            if unsigned(I_Match) < unsigned(G_Mask) then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        elsif strings_equal(G_MaskMode, K_Mode_LE) then
            --@ Route to Selected if I_Match <= G_Mask (unsigned)
            if unsigned(I_Match)    <= unsigned(G_Mask) then
                C_ShouldRouteToSelected <= '1';
            else
                C_ShouldRouteToSelected <= '0';
            end if;

        else
            --@ Unknown comparison mode: fallback to Default
            C_ShouldRouteToSelected <= '0';
        end if;
    end process;

    process (I_Valid, I_Default_Ready, I_Selected_Ready, C_ShouldRouteToSelected)
    begin
        if C_ShouldRouteToSelected = '1' then
            -- Route to Selected
            O_Selected_Valid <= I_Valid;
            O_Default_Valid  <= '0';
            O_Ready          <= I_Selected_Ready;
        else
            -- Route to Default
            O_Selected_Valid <= '0';
            O_Default_Valid  <= I_Valid;
            O_Ready          <= I_Default_Ready;
        end if;
    end process;

end architecture;
