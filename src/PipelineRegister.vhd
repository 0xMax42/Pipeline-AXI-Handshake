library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineRegister is
    generic (
        --@ Number of pipeline stages
        G_PipelineStages : integer := 3;
        --@ Data width
        G_Width : integer := 32;
        --@ Register balancing attribute<br>
        --@ - "no" : **Disable** register balancing, <br>
        --@ - "yes": **Enable** register balancing in both directions, <br>
        --@ - "forward": **Enable** and moves a set of FFs at the inputs of a LUT to a single FF at its output, <br>
        --@ - "backward": **Enable** and moves a single FF at the output of a LUT to a set of FFs at its inputs.
        G_RegisterBalancing : string := "yes"
    );
    port (
        --@ Clock signal; **Rising edge** triggered
        I_CLK : in std_logic;
        --@ Enable input from **Pipeline Controller**
        I_Enable : in std_logic;
        --@ Data input
        I_Data : in std_logic_vector(G_Width - 1 downto 0);
        --@ Data output
        O_Data : out std_logic_vector(G_Width - 1 downto 0) := (others => '0')
    );
end entity PipelineRegister;

architecture RTL of PipelineRegister is
    attribute register_balancing : string;

    --@ Pipeline register data type; organized as an array (Stages) of std_logic_vector (Data).
    type T_Data is array(0 to G_PipelineStages - 1) of std_logic_vector(G_Width - 1 downto 0);
    --@ Pipeline register data signal; `G_PipelineStages` stages of `G_Width` bits.
    signal R_Data : T_Data := (others => (others => '0'));
    --@ Pipeline register balancing attribute from generic
    attribute register_balancing of R_Data : signal is G_RegisterBalancing;
begin

    --@ Pipeline register I_Data -> R_Data(0) -> R_Data(1) -> ... -> R_Data(G_PipelineStages - 1) -> O_Data
    P_PipelineRegister : process (I_CLK)
    begin
        if rising_edge(I_CLK) then
            if I_Enable = '1' then
                for i in 0 to G_PipelineStages - 1 loop
                    if i = 0 then
                        R_Data(i) <= I_Data;
                    else
                        R_Data(i) <= R_Data(i - 1);
                    end if;
                end loop;
            end if;
        end if;
    end process;

    O_Data <= R_Data(G_PipelineStages - 1);

end architecture RTL;