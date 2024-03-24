
# Entity: PipelineRegister 
- **File**: PipelineRegister.vhd

## Diagram
![Diagram](PipelineRegister.svg "Diagram")
## Generics

| Generic name        | Type    | Value | Description                                                                                                                                                                                                                                                                                                                                                      |
| ------------------- | ------- | ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| G_PipelineStages    | integer | 3     | Number of pipeline stages                                                                                                                                                                                                                                                                                                                                        |
| G_Width             | integer | 32    | Data width                                                                                                                                                                                                                                                                                                                                                       |
| G_RegisterBalancing | string  | "yes" | Register balancing attribute<br>  - "no" : **Disable** register balancing, <br>  - "yes": **Enable** register balancing in both directions, <br>  - "forward": **Enable** and moves a set of FFs at the inputs of a LUT to a single FF at its output, <br>  - "backward": **Enable** and moves a single FF at the output of a LUT to a set of FFs at its inputs. |

## Ports

| Port name | Direction | Type                                   | Description                               |
| --------- | --------- | -------------------------------------- | ----------------------------------------- |
| I_CLK     | in        | std_logic                              | Clock signal; **Rising edge** triggered   |
| I_Enable  | in        | std_logic                              | Enable input from **Pipeline Controller** |
| I_Data    | in        | std_logic_vector(G_Width - 1 downto 0) | Data input                                |
| O_Data    | out       | std_logic_vector(G_Width - 1 downto 0) | Data output                               |

## Signals

| Name   | Type   | Description                                                                 |
| ------ | ------ | --------------------------------------------------------------------------- |
| R_Data | T_Data | Pipeline register data signal; `G_PipelineStages` stages of `G_Width` bits. |

## Types

| Name   | Type | Description                                                                             |
| ------ | ---- | --------------------------------------------------------------------------------------- |
| T_Data |      | Pipeline register data type; organized as an array (Stages) of std_logic_vector (Data). |

## Processes
- P_PipelineRegister: ( I_CLK )
  - **Description**
  Pipeline register I_Data -> R_Data(0) -> R_Data(1) -> ... -> R_Data(G_PipelineStages - 1) -> O_Data
