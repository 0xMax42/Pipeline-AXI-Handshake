library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PipelineBuffer is
    generic (
        --@ Data width
        G_Width : integer := 32
    );
    port (
        --@ Clock signal; (**Rising edge** triggered)
        I_CLK    : in  std_logic                              := '0';
        --@ Enable input from **Pipeline Buffer Controller**
        --@ [1]: If low, data is passed through, else data is registered
        --@ [0]: Enable for register
        I_Enable : in  std_logic_vector(1 downto 0)           := (others => '0');
        --@ Data input
        I_Data   : in  std_logic_vector(G_Width - 1 downto 0) := (others => '0');
        --@ Data output
        O_Data   : out std_logic_vector(G_Width - 1 downto 0) := (others => '0')
    );
end entity PipelineBuffer;

architecture RTL of PipelineBuffer is
    signal C_MUX    : std_logic                              := '0';
    signal C_Enable : std_logic                              := '0';

    signal R_Data   : std_logic_vector(G_Width - 1 downto 0) := (others => '0');
begin

    C_MUX    <= I_Enable(1);
    C_Enable <= I_Enable(0);

    P_MUX : process (C_MUX, I_Data, R_Data)
    begin
        if C_MUX = '0' then -- Passthrough mode
            O_Data <= I_Data;
        else -- Register mode
            O_Data <= R_Data;
        end if;
    end process;

    P_Register : process (I_CLK)
    begin
        if rising_edge(I_CLK) then
            if C_Enable = '1' then
                R_Data <= I_Data;
            end if;
        end if;
    end process;
end architecture;
