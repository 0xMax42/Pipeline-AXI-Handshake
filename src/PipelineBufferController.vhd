library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineBufferController is
    generic (
        --@ Reset active at this level
        G_ResetActiveAt : std_logic := '1'
    );
    port (
        --@ Clock signal; (**Rising edge** triggered)
        I_CLK    : in  std_logic                    := '0';
        --@ Reset; (**Synchronous**, **Active at `G_ResetActiveAt`**)
        I_RST    : in  std_logic                    := '0';
        --@ Chip enable; (**Synchronous**, **Active high**)
        I_CE     : in  std_logic                    := '1';

        --@ [1]: If low, data is passed through, else data is registered
        --@ [0]: Enable for register
        O_Enable : out std_logic_vector(1 downto 0) := (others => '0');

        --@ @virtualbus AXI-Flags-In @dir In Input interface for AXI-like handshake
        --@ AXI like valid; (**Synchronous**, **Active high**)
        I_Valid  : in  std_logic                    := '0';
        --@ AXI like ready; (**Synchronous**, **Active high**)
        O_Ready  : out std_logic                    := '0';
        --@ @end

        --@ @virtualbus AXI-Flags-Out @dir Out Output interface for AXI-like handshake
        --@ AXI like valid; (**Synchronous**, **Active high**)
        O_Valid  : out std_logic                    := '0';
        --@ AXI like ready; (**Synchronous**, **Active high**)
        I_Ready  : in  std_logic                    := '0'
        --@ @end
    );
end entity PipelineBufferController;

architecture RTL of PipelineBufferController is
    signal C_MUX        : std_logic := '0';
    signal C_Enable     : std_logic := '0';

    signal R_IsBuffered : std_logic := '0';
begin

    --@ Set mux to buffered mode if data is available in the buffer.
    C_MUX    <= R_IsBuffered;
    --@ Enable the buffer register if not buffered and chip enable is high.
    C_Enable <= I_CE and not R_IsBuffered;
    --@ Set the ready signal to high if not buffered.
    O_Ready  <= not R_IsBuffered;
    --@ Set the valid signal to high if data is available in the buffer or if data is valid.
    O_Valid  <= R_IsBuffered or I_Valid;

    process (I_CLK)
    begin
        if rising_edge(I_CLK) then
            if I_RST = G_ResetActiveAt then
                R_IsBuffered <= '0';
            elsif I_CE = '1' then
                if R_IsBuffered = '0' and I_Valid = '1' then
                    R_IsBuffered <= '1';
                elsif I_Ready = '1' and (R_IsBuffered or I_Valid) = '1' then
                    R_IsBuffered <= '0';
                end if;
            end if;
        end if;
    end process;

    O_Enable(1) <= C_MUX;
    O_Enable(0) <= C_Enable;

end architecture;
