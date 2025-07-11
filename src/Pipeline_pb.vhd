--@ Performance Benchmarking Environment
--@ This file is a wrapper for the module which is to be tested 
--@ and capsulates the module with flip-flops to create a synchronous
--@ interface for the module. This is necessary to test the synthesis
--@ results of the module.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Pipeline_pb is
    generic (
        --@ Number of pipeline stages inside each module
        G_PipelineStages       : integer := 2;
        --@ Data width
        G_Width                : integer := 8;
        --@ Register balancing attribute<br>
        --@ - "no" : No register balancing <br>
        --@ - "yes": Register balancing in both directions <br>
        --@ - "forward": Moves a set of FFs at the inputs of a LUT to a single FF at its output. <br>
        --@ - "backward": Moves a single FF at the output of a LUT to a set of FFs at its inputs.
        G_RegisterBalancing    : string  := "yes";
        --@ Enable pipeline buffer
        --@ - true  : Use pipeline buffer
        --@ - false : Direct connection (bypass)
        G_EnablePipelineBuffer : boolean := true;
        --@ How many Pipeline modules shall be chained?
        G_PipelineModules      : integer := 20;
        --@ Enable chip enable signal
        G_Enable_CE            : boolean := false;
        --@ Enable reset signal
        G_Enable_RST           : boolean := false
        );
    port (
        I_CLK   : in  std_logic;
        I_RST   : in  std_logic;
        I_CE    : in  std_logic;
        ---
        I_Data  : in  std_logic_vector(G_Width - 1 downto 0);
        I_Valid : in  std_logic;
        O_Ready : out std_logic;
        ---
        O_Data  : out std_logic_vector(G_Width - 1 downto 0);
        O_Valid : out std_logic;
        I_Ready : in  std_logic
        );
end entity Pipeline_pb;

architecture RTL of Pipeline_pb is
    ---------------------------------------------------------------------------
    -- Attribute helpers
    ---------------------------------------------------------------------------
    attribute keep : string;
    attribute IOB  : string;

    ---------------------------------------------------------------------------
    -- Bench‐wrapper FFs (synchronous IO)
    ---------------------------------------------------------------------------
    signal R_RST                  : std_logic := '0';
    signal R_CE                   : std_logic := '1';
    attribute keep of R_RST, R_CE : signal is "true";
    attribute IOB of R_RST, R_CE  : signal is "false";

    signal R_DataIn                       : std_logic_vector(G_Width-1 downto 0);
    signal R_ValidIn                      : std_logic;
    attribute keep of R_DataIn, R_ValidIn : signal is "true";
    attribute IOB of R_DataIn, R_ValidIn  : signal is "false";

    signal R_DataOut                                   : std_logic_vector(G_Width-1 downto 0);
    signal R_ValidOut                                  : std_logic;
    signal R_ReadyIn                                   : std_logic;
    attribute keep of R_DataOut, R_ValidOut, R_ReadyIn : signal is "true";
    attribute IOB of R_DataOut, R_ValidOut, R_ReadyIn  : signal is "false";

    ---------------------------------------------------------------------------
    -- Chaining arrays (sentinel element @0 and @G_PipelineModules)
    ---------------------------------------------------------------------------
    type T_DataArray is array(0 to G_PipelineModules) of std_logic_vector(G_Width-1 downto 0);

    signal S_Data  : T_DataArray;
    signal S_Valid : std_logic_vector(0 to G_PipelineModules);
    signal S_Ready : std_logic_vector(0 to G_PipelineModules);

begin
    GEN_Enable_CE : if G_Enable_CE = true generate
        process(I_CLK)
        begin
            if rising_edge(I_CLK) then
                R_CE <= I_CE;
            end if;
        end process;
    end generate GEN_Enable_CE;

    GEN_Enable_RST : if G_Enable_RST = true generate
        process(I_CLK)
        begin
            if rising_edge(I_CLK) then
                R_RST <= I_RST;
            end if;
        end process;
    end generate GEN_Enable_RST;

    -----------------------------------------------------------------------
    -- Wrapper FFs: register all top‑level ports once for fair timing
    -----------------------------------------------------------------------
    BenchFF : process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            --- Register inputs
            R_DataIn   <= I_Data;
            R_ValidIn  <= I_Valid;
            O_Ready    <= S_Ready(0);
            --- Register outputs
            R_DataOut  <= S_Data (G_PipelineModules);
            R_ValidOut <= S_Valid(G_PipelineModules);
            R_ReadyIn  <= I_Ready;
        end if;
    end process;

    O_Data  <= R_DataOut;
    O_Valid <= R_ValidOut;

    -----------------------------------------------------------------------
    -- Bind sentinel 0 with registered inputs
    -----------------------------------------------------------------------
    S_Data (0) <= R_DataIn;
    S_Valid(0) <= R_ValidIn;

    -----------------------------------------------------------------------
    -- Bind last sentinel with registered outputs
    -----------------------------------------------------------------------
    S_Ready(G_PipelineModules) <= R_ReadyIn;

    -----------------------------------------------------------------------
    -- Generate N pipeline modules in series
    -----------------------------------------------------------------------
    gen_modules : for i in 0 to G_PipelineModules-1 generate

        P_MOD : entity work.Pipeline_pb_Module
            generic map(
                G_PipelineStages       => G_PipelineStages,
                G_Width                => G_Width,
                G_RegisterBalancing    => G_RegisterBalancing,
                G_EnablePipelineBuffer => G_EnablePipelineBuffer
                )
            port map(
                I_CLK   => I_CLK,
                I_RST   => R_RST,
                I_CE    => R_CE,
                -- Up‑stream side
                I_Data  => S_Data (i),
                I_Valid => S_Valid(i),
                O_Ready => S_Ready(i),
                -- Down‑stream side
                O_Data  => S_Data (i+1),
                O_Valid => S_Valid(i+1),
                I_Ready => S_Ready(i+1)
                );

    end generate gen_modules;

end architecture RTL;
