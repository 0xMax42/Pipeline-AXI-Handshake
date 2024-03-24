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
        --@ Number of pipeline stages
        G_PipelineStages : integer := 3;
        --@ Data width
        G_Width : integer := 32;
        --@ Register balancing attribute<br>
        --@ - "no" : No register balancing <br>
        --@ - "yes": Register balancing in both directions <br>
        --@ - "forward": Moves a set of FFs at the inputs of a LUT to a single FF at its output. <br>
        --@ - "backward": Moves a single FF at the output of a LUT to a set of FFs at its inputs.
        G_RegisterBalancing : string := "yes"
    );
    port (
        I_CLK   : in std_logic;
        I_RST   : in std_logic;
        I_CE    : in std_logic;
        I_Data  : in std_logic_vector(G_Width - 1 downto 0);
        I_Valid : in std_logic;
        O_Ready : out std_logic;
        O_Data  : out std_logic_vector(G_Width - 1 downto 0);
        O_Valid : out std_logic;
        I_Ready : in std_logic
    );
end entity Pipeline_pb;

architecture RTL of Pipeline_pb is
    -- Keep attribute: Prevents the synthesis tool from removing the entity if is "true".
    attribute keep : string;
    -- IOB attribute: Attaches the FF to the IOB if is "true".
    attribute IOB : string;

    -- General Interace
    signal R_RST : std_logic;
    signal R_CE  : std_logic;
    -- Attribute
    attribute keep of R_RST, R_CE : signal is "true";
    attribute IOB of R_RST, R_CE  : signal is "false";

    -- Input Interface
    signal R_DataIn   : std_logic_vector(G_Width - 1 downto 0);
    signal R_ValidIn  : std_logic;
    signal R_ReadyOut : std_logic;
    -- Attribute
    attribute keep of R_DataIn, R_ValidIn, R_ReadyOut : signal is "true";
    attribute IOB of R_DataIn, R_ValidIn, R_ReadyOut  : signal is "false";

    -- Output Interface
    signal R_DataOut  : std_logic_vector(G_Width - 1 downto 0);
    signal R_ValidOut : std_logic;
    signal R_ReadyIn  : std_logic;
    -- Attribute
    attribute keep of R_DataOut, R_ValidOut, R_ReadyIn : signal is "true";
    attribute IOB of R_DataOut, R_ValidOut, R_ReadyIn  : signal is "false";

    signal C_PipelineEnable : std_logic;
begin

    BenchmarkEnvironmentFFs : process (I_CLK)
    begin
        if rising_edge(I_CLK) then
            -- General Interace
            R_RST <= I_RST;
            R_CE  <= I_CE;

            -- Input Interface
            R_DataIn  <= I_Data;
            R_ValidIn <= I_Valid;
            O_Ready   <= R_ReadyOut;

            -- Output Interface
            O_Data    <= R_DataOut;
            O_Valid   <= R_ValidOut;
            R_ReadyIn <= I_Ready;
        end if;
    end process;

    PipelineController : entity work.PipelineController
        generic map(
            G_PipelineStages => G_PipelineStages,
            G_ResetActiveAt  => '1'
        )
        port map(
            I_CLK    => I_CLK,
            I_RST    => R_RST,
            I_CE     => R_CE,
            O_Enable => C_PipelineEnable,
            I_Valid  => R_ValidIn,
            O_Ready  => R_ReadyOut,
            O_Valid  => R_ValidOut,
            I_Ready  => R_ReadyIn
        );

    PipelineRegister : entity work.PipelineRegister
        generic map(
            G_PipelineStages    => G_PipelineStages,
            G_Width             => G_Width,
            G_RegisterBalancing => G_RegisterBalancing
        )
        port map(
            I_CLK    => I_CLK,
            I_Enable => C_PipelineEnable,
            I_Data   => R_DataIn,
            O_Data   => R_DataOut
        );

end architecture RTL;