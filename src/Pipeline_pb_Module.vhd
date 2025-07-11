--@ Performance Benchmarking Environment
--@ This file is a wrapper for the module which is to be tested 
--@ and capsulates the module with flip-flops to create a synchronous
--@ interface for the module. This is necessary to test the synthesis
--@ results of the module.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Pipeline_pb_Module is
    generic (
        --@ Number of pipeline stages
        G_PipelineStages       : integer := 10;
        --@ Data width
        G_Width                : integer := 32;
        --@ Register balancing attribute<br>
        --@ - "no" : No register balancing <br>
        --@ - "yes": Register balancing in both directions <br>
        --@ - "forward": Moves a set of FFs at the inputs of a LUT to a single FF at its output. <br>
        --@ - "backward": Moves a single FF at the output of a LUT to a set of FFs at its inputs.
        G_RegisterBalancing    : string  := "no";
        --@ Enable pipeline buffer
        --@ - true  : Use pipeline buffer
        --@ - false : Direct connection (bypass)
        G_EnablePipelineBuffer : boolean := false
        );
    port (
        I_CLK   : in  std_logic;
        I_RST   : in  std_logic;
        I_CE    : in  std_logic;
        I_Data  : in  std_logic_vector(G_Width - 1 downto 0);
        I_Valid : in  std_logic;
        O_Ready : out std_logic;
        O_Data  : out std_logic_vector(G_Width - 1 downto 0);
        O_Valid : out std_logic;
        I_Ready : in  std_logic
        );
end entity Pipeline_pb_Module;

architecture RTL of Pipeline_pb_Module is
    signal C_Pipeline0Enable      : std_logic;
    signal C_PipelineBufferEnable : std_logic_vector(1 downto 0) := (others => '0');

    signal R_Valid : std_logic;
    signal R_Ready : std_logic;
    signal R_Data  : std_logic_vector(G_Width - 1 downto 0);
    signal C_Data  : std_logic_vector(G_Width - 1 downto 0);
begin
    PipelineControllerIn : entity work.PipelineController
        generic map(
            G_PipelineStages => G_PipelineStages,
            G_ResetActiveAt  => '1'
            )
        port map(
            I_CLK    => I_CLK,
            I_RST    => I_RST,
            I_CE     => I_CE,
            O_Enable => C_Pipeline0Enable,
            I_Valid  => I_Valid,
            O_Ready  => O_Ready,
            O_Valid  => R_Valid,
            I_Ready  => R_Ready
            );

    PipelineRegisterIn : entity work.PipelineRegister
        generic map(
            G_PipelineStages    => G_PipelineStages,
            G_Width             => G_Width,
            G_RegisterBalancing => G_RegisterBalancing
            )
        port map(
            I_CLK    => I_CLK,
            I_Enable => C_Pipeline0Enable,
            I_Data   => I_Data,
            O_Data   => R_Data
            );

    ---------

    C_Data <= std_logic_vector(unsigned(R_Data) + 3);  -- Example operation, can be replaced with actual logic

    ---------

    -- Pipeline Buffer Generation based on G_EnablePipelineBuffer
    gen_pipeline_buffer : if G_EnablePipelineBuffer generate
        PipelineBufferController : entity work.PipelineBufferController
            generic map(
                G_ResetActiveAt => '1'
                )
            port map(
                I_CLK    => I_CLK,
                I_RST    => I_RST,
                I_CE     => I_CE,
                O_Enable => C_PipelineBufferEnable,
                I_Valid  => R_Valid,
                O_Ready  => R_Ready,
                O_Valid  => O_Valid,
                I_Ready  => I_Ready
                );

        PipelineBuffer : entity work.PipelineBuffer
            generic map(
                G_Width => G_Width
                )
            port map(
                I_CLK    => I_CLK,
                I_Enable => C_PipelineBufferEnable,
                I_Data   => C_Data,
                O_Data   => O_Data
                );
    end generate gen_pipeline_buffer;

    -- Direct connection when pipeline buffer is disabled
    gen_direct_connection : if not G_EnablePipelineBuffer generate
        -- Direct signal connections (bypass pipeline buffer)
        O_Valid <= R_Valid;
        O_Data  <= R_Data;
        R_Ready <= I_Ready;
    end generate gen_direct_connection;

end architecture RTL;
