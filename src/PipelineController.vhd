library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineController is
    generic (
        --@ Number of pipeline stages
        G_PipelineStages : integer := 3;
        --@ Reset active at:
        G_ResetActiveAt : std_logic := '1'
    );
    port (
        --@ Clock signal; **Rising edge** triggered
        I_CLK : in std_logic;
        --@ Reset signal; Active at `G_ResetActiveAt`
        I_RST : in std_logic;
        --@ Chip enable; Active high
        I_CE : in std_logic;
        --@ Pipeline enable; Active high when pipeline can accept data and `I_CE` is high. <br>
        --@ **Note:** Connect to `I_Enable` of the registers to be controlled by this controller.
        O_Enable : out std_logic;
        --@ @virtualbus Input-AXI-Handshake @dir in Input AXI like Handshake
        --@ Valid data flag; indicates that the data on `I_Data` of the connected registers is valid.
        I_Valid : in std_logic;
        --@ Ready flag; indicates that the connected registers is ready to accept data.
        O_Ready : out std_logic;
        --@ @end
        --@ @virtualbus Output-AXI-Handshake @dir out Output AXI like Handshake
        --@ Valid data flag; indicates that the data on `O_Data` of the connected registers is valid.
        O_Valid : out std_logic;
        --@ Ready flag; indicates that the external component is ready to accept data.
        I_Ready : in std_logic
        --@ @end
    );
end entity PipelineController;

architecture RTL of PipelineController is
    --@ Pipeline ready signal for each stage of the pipeline to indicate that the data in pipeline is valid
    signal R_Valid : std_logic_vector(G_PipelineStages - 1 downto 0) := (others => '0');
    --@ Ready signal for the pipeline controller to indicate that the pipeline can accept data; <br>
    --@ mapped to `O_Enable` and `O_Ready` ports.
    signal C_Ready : std_logic := '1';
begin

    O_Valid <= R_Valid(R_Valid'high);

    O_Enable <= C_Ready and I_CE;
    O_Ready  <= C_Ready and I_CE;

    --@ Produce the `C_Ready` signal for the pipeline controller,
    --@ controlling the data flow in the pipeline.
    P_Flags : process (R_Valid, I_Ready)
    begin
        if R_Valid(R_Valid'high) = '1' then
            -- Data is available in the last stage of the pipeline.
            if I_Ready = '1' then
                -- O_Data is accepted from the external component.
                C_Ready <= '1';
            else
                -- O_Data is not accepted from the external component.
                C_Ready <= '0';
            end if;
        else
            -- No data available in the last stage of the pipeline.
            C_Ready <= '1';
        end if;
    end process;

    --@ Shift the pipeline stages with `R_Valid` signal as placeholder to control the pipeline stages.
    P_ValidPipeline : process (I_CLK)
    begin
        if rising_edge(I_CLK) then
            if I_RST = G_ResetActiveAt then
                R_Valid <= (others => '0');
            elsif I_CE = '1' then
                if C_Ready = '1' then
                    R_Valid <= R_Valid(R_Valid'high - 1 downto R_Valid'low) & I_Valid;
                end if;
            end if;
        end if;
    end process;
end architecture RTL;