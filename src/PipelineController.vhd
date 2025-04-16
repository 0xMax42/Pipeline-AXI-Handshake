----------------------------------------------------------------------------------
--@ - Name:     **Pipeline Controller**
--@ - Version:  0.0.2
--@ - Author:   _Maximilian Passarello ([Blog](mpassarello.de))_
--@ - License:  [MIT](LICENSE)
--@             
--@ The Pipeline Controller provides an easy way to construct a pipeline 
--@ with AXI-Like handshaking at the input and output of the pipeline.
--@ 
--@ ### Core functions
--@ 
--@ - **Data flow control**: Data flow control is implemented via handshaking at the input and output ports.
--@ - **Validity control**: The controller keeps the validity of the data in the individual pipeline stages under control.
--@ - **Adjustability**: The pipeline controller can be customized via the generics.
--@ 
--@ ### Generics
--@ 
--@ Use the generic `G_PipelineStages` to set how deep the pipeline is. 
--@ This depth contains all the registers associated with the pipeline. 
--@ For example, for an _I_FF ⇨ Combinatorics ⇨ O_FF_ construction, the generic must be set to **2**.
--@ 
--@ The active level of the reset input can also be set.
--@ 
--@ ### Clock Enable
--@ 
--@ The `I_CE` port is active high and, when deactivated, 
--@ effectively switches on the acceptance or output of data via handshaking in addition to the pipeline.
--@ 
--@ ### Reset
--@ 
--@ A reset is explicitly **not** necessary on the pipeline registers. 
--@ The validity of the data is kept under control via the pipeline controller 
--@ and only this requires a dedicated reset if necessary.
--@ 
--@ ### Pipeline control
--@ 
--@ You must connect the `O_Enable` port to the CE input of the corresponding pipeline registers. 
--@ This is used to activate or deactivate the pipeline in full or via CE deactivated state.
--@ 
--@ ### AXI like Handshaking
--@ 
--@ - **Input**: The `O_Ready` (active high) port is used to signal to the data-supplying component that data should be accepted. 
--@ If it switches on `I_Valid` (active high), this in turn signals that data is ready to be accepted at its output. 
--@ If both ports are active at the same time, the transfer is executed. 
--@ - **Output**: The process runs analogously at the pipeline output.
--@ 
--@ ## History
--@ - 0.0.1 (2024-03-24) Initial version
--@ - 0.0.2 (2024-04-13) Enhanced the validity update logic to correctly handle configurations with a single pipeline stage
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineController is
    generic (
        --@ Number of pipeline stages (FFs in the pipeline including I/O FFs)
        G_PipelineStages : integer   := 3;
        --@ Reset active at this level
        G_ResetActiveAt  : std_logic := '1'
    );
    port (
        --@ Clock signal; **Rising edge** triggered
        I_CLK    : in  std_logic := '0';
        --@ Reset signal; Active at `G_ResetActiveAt`
        I_RST    : in  std_logic := '0';
        --@ Chip enable; Active high
        I_CE     : in  std_logic := '1';

        --@ Pipeline enable; Active high when pipeline can accept data and `I_CE` is high. <br>
        --@ **Note:** Connect `CE` of the registers to be controlled by this controller to `O_Enable`.
        O_Enable : out std_logic := '0';

        --@ @virtualbus Input-AXI-Handshake @dir in Input AXI like Handshake
        --@ Valid data flag; indicates that the data on `I_Data` of the connected registers is valid.
        I_Valid  : in  std_logic := '0';
        --@ Ready flag; indicates that the connected registers is ready to accept data.
        O_Ready  : out std_logic := '0';
        --@ @end

        --@ @virtualbus Output-AXI-Handshake @dir out Output AXI like Handshake
        --@ Valid data flag; indicates that the data on `O_Data` of the connected registers is valid.
        O_Valid  : out std_logic := '0';
        --@ Ready flag; indicates that the external component is ready to accept data.
        I_Ready  : in  std_logic := '0'
        --@ @end
    );
end entity PipelineController;

architecture RTL of PipelineController is
    --@ Pipeline ready signal for each stage of the pipeline to indicate that the data in pipeline is valid
    signal R_Valid : std_logic_vector(G_PipelineStages - 1 downto 0) := (others => '0');
    --@ Ready signal for the pipeline controller to indicate that the pipeline can accept data; <br>
    --@ mapped to `O_Enable` and `O_Ready` ports.
    signal C_Ready : std_logic                                       := '1';
begin

    GEN_ForwardExternalFlags : if G_PipelineStages = 0 generate
        --@ If no pipeline stages are defined, the flags are directly connected to the input and output ports.
        P_ExternalFlags : process (I_CE, I_Valid, I_Ready)
        begin
            O_Valid  <= I_Valid;
            O_Enable <= I_Ready and I_CE;
            O_Ready  <= I_Ready and I_CE;
        end process;
    end generate;

    GEN_ExternalFlags : if G_PipelineStages > 0 generate
        --@ Produce the `O_Valid`, `O_Enable`, and `O_Ready` signals for the pipeline controller. <br>
        --@ - `O_Enable`, and `O_Ready` are **and** combined from the `C_Ready` and `I_CE` signals. <br>
        --@ - `O_Valid` is the last bit of the `R_Valid` signal 
        --@ and represents the validity of the data in the last stage of the pipeline.
        P_ExternalFlags : process (R_Valid, C_Ready, I_CE)
        begin
            O_Valid  <= R_Valid(R_Valid'high);

            O_Enable <= C_Ready and I_CE;
            O_Ready  <= C_Ready and I_CE;
        end process;
    end generate;

    GEN_InternalFlags : if G_PipelineStages > 0 generate
        --@ Produce the `C_Ready` signal for the pipeline controller,
        --@ controlling the data flow in the pipeline. <br>
        --@ `C_Ready` is asserted when the data is available in the last stage of the pipeline
        --@ **and** the external component is ready to accept data
        --@ **or** when no data is available in the last stage of the pipeline.
        P_InternalFlags : process (R_Valid, I_Ready)
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
    end generate;

    GEN_ValidPipe : if G_PipelineStages > 0 generate
        --@ Shift the pipeline stages with `R_Valid` signal as placeholder to control 
        --@ the validity of the data in the individual pipeline stages.
        P_ValidPipeline : process (I_CLK)
        begin
            if rising_edge(I_CLK) then
                if I_RST = G_ResetActiveAt then
                    R_Valid <= (others => '0');
                elsif I_CE = '1' then
                    if C_Ready = '1' then
                        if G_PipelineStages = 1 then
                            R_Valid(0) <= I_Valid;
                        else
                            R_Valid <= R_Valid(R_Valid'high - 1 downto R_Valid'low) & I_Valid;
                        end if;
                    end if;
                end if;
            end if;
        end process;
    end generate;
end architecture RTL;
