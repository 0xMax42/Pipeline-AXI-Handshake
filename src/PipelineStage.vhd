library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineStage is
    generic (
        --@ Number of pipeline stages (FFs in the pipeline including I/O FFs)
        G_PipelineStages    : integer   := 3;
        --@ Data width
        G_D0_Width          : integer   := 1;
        --@ Data width
        G_D1_Width          : integer   := 0;
        --@ Data width
        G_D2_Width          : integer   := 0;
        --@ Data width
        G_D3_Width          : integer   := 0;
        --@ Reset active at this level
        G_ResetActiveAt     : std_logic := '1';
        --@ Register balancing attribute  
        --@ - `no` : **Disable** register balancing,
        --@ - `yes`: **Enable** register balancing in both directions,
        --@ - `forward`: **Enable** register balancing  
        --@     and moves a set of FFs at the inputs of a LUT to a single FF at its output,
        --@ - `backward`: **Enable** register balancing  
        --@     and moves a single FF at the output of a LUT to a set of FFs at its inputs.
        G_RegisterBalancing : string    := "yes"
    );
    port (
        --@ Clock; (**Rising edge** triggered)
        I_CLK            : in  std_logic                                 := '0';
        --@ Clock Enable; (**Synchronous**, **Active high**)
        I_CE             : in  std_logic                                 := '1';
        --@ Reset; (**Synchronous**, **Active high**)
        I_RST            : in  std_logic                                 := '0';

        --@ Pipeline enable for additional stages; (**Synchronous**, **Active high**) 
        O_PipelineEnable : out std_logic                                 := '0';

        --@ @virtualbus AXI-Data-In @dir In Input interface with AXI-like handshake
        --@ AXI like valid; (**Synchronous**, **Active high**)
        I_Valid          : in  std_logic                                 := '0';
        --@ AXI like ready; (**Synchronous**, **Active high**)
        O_Ready          : out std_logic                                 := '0';
        --@ Data input 0
        I_Data_0         : in  std_logic_vector(G_D0_Width - 1 downto 0) := (others => '-');
        --@ Data input 1
        I_Data_1         : in  std_logic_vector(G_D1_Width - 1 downto 0) := (others => '-');
        --@ Data input 2
        I_Data_2         : in  std_logic_vector(G_D2_Width - 1 downto 0) := (others => '-');
        --@ Data input 3
        I_Data_3         : in  std_logic_vector(G_D3_Width - 1 downto 0) := (others => '-');
        --@ @end

        --@ @virtualbus AXI-Data-Out @dir Out Output interface with AXI-like handshake
        --@ AXI like valid; (**Synchronous**, **Active high**)
        O_Valid          : out std_logic                                 := '0';
        --@ AXI like ready; (**Synchronous**, **Active high**)
        I_Ready          : in  std_logic                                 := '0';
        --@ Data output 0
        O_Data_0         : out std_logic_vector(G_D0_Width - 1 downto 0) := (others => '-');
        --@ Data output 1
        O_Data_1         : out std_logic_vector(G_D1_Width - 1 downto 0) := (others => '-');
        --@ Data output 2
        O_Data_2         : out std_logic_vector(G_D2_Width - 1 downto 0) := (others => '-');
        --@ Data output 3
        O_Data_3         : out std_logic_vector(G_D3_Width - 1 downto 0) := (others => '-')
        --@ @end
    );
end entity PipelineStage;

architecture Rtl of PipelineStage is
    signal S_PipelineEnable : std_logic := '0';
begin
    --@ Forwarding the pipeline enable signal to the output port.
    --@ This signal is used to control the pipeline enable signal  
    --@ of additional external stages.
    O_PipelineEnable <= S_PipelineEnable;

    --@ Pipeline controller
    I_PipelineCtrl : entity work.PipelineController
        generic map(
            G_PipelineStages => G_PipelineStages,
            G_ResetActiveAt  => G_ResetActiveAt
        )
        port map(
            I_CLK    => I_CLK,
            I_CE     => I_CE,
            I_RST    => I_RST,
            O_Enable => S_PipelineEnable,
            I_Valid  => I_Valid,
            O_Ready  => O_Ready,
            O_Valid  => O_Valid,
            I_Ready  => I_Ready
        );

    GEN_PipelineRegister_D0 : if G_D0_Width > 0 generate
        --@ Pipeline register Data 0
        I_PielineRegister_D0 : entity work.PipelineRegister
            generic map(
                G_PipelineStages    => G_PipelineStages,
                G_Width             => G_D0_Width,
                G_RegisterBalancing => G_RegisterBalancing
            )
            port map(
                I_CLK    => I_CLK,
                I_Enable => S_PipelineEnable,
                I_Data   => I_Data_0,
                O_Data   => O_Data_0
            );
    end generate;

    GEN_PipelineRegister_D1 : if G_D1_Width > 0 generate
        --@ Pipeline register Data 1
        I_PielineRegister_D1 : entity work.PipelineRegister
            generic map(
                G_PipelineStages    => G_PipelineStages,
                G_Width             => G_D1_Width,
                G_RegisterBalancing => G_RegisterBalancing
            )
            port map(
                I_CLK    => I_CLK,
                I_Enable => S_PipelineEnable,
                I_Data   => I_Data_1,
                O_Data   => O_Data_1
            );
    end generate;

    GEN_PipelineRegister_D2 : if G_D2_Width > 0 generate
        --@ Pipeline register Data 2
        I_PielineRegister_D2 : entity work.PipelineRegister
            generic map(
                G_PipelineStages    => G_PipelineStages,
                G_Width             => G_D2_Width,
                G_RegisterBalancing => G_RegisterBalancing
            )
            port map(
                I_CLK    => I_CLK,
                I_Enable => S_PipelineEnable,
                I_Data   => I_Data_2,
                O_Data   => O_Data_2
            );
    end generate;

    GEN_PipelineRegister_D3 : if G_D3_Width > 0 generate
        --@ Pipeline register Data 3
        I_PielineRegister_D3 : entity work.PipelineRegister
            generic map(
                G_PipelineStages    => G_PipelineStages,
                G_Width             => G_D3_Width,
                G_RegisterBalancing => G_RegisterBalancing
            )
            port map(
                I_CLK    => I_CLK,
                I_Enable => S_PipelineEnable,
                I_Data   => I_Data_3,
                O_Data   => O_Data_3
            );
    end generate;

end architecture;
