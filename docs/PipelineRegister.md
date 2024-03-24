
# Entity: PipelineRegister 
- **File**: PipelineRegister.vhd

## Diagram
![Diagram](PipelineRegister.svg "Diagram")
## Description

- Name:     **Pipeline Register**
- Version:  0.0.1
- Author:   _Maximilian Passarello ([Blog](mpassarello.de))_
- License:  [MIT](LICENSE)

The pipeline register provides a simple way to pipeline combinatorial logic using the **register rebalancing** of the synthesis.

### Core functions

- **Register rebalancing**: The generic `G_RegisterBalancing` can be used
to precisely configure how register rebalancing works.
- **Number of registers**: The pipeline register instantiates a number of FFs corresponding
to the generic `G_PipelineStages`.
- **Data width**: The data width of the registers
and the input/output vectors (std_logic_vector) is configured via the generic `G_Width`.

### Register rebalancing

The generic `G_RegisterBalancing` can be used to set the **Register Rebalancing** of the Xilinx ISE.
The possible variants are
- `no`: Deactivates the rebalancing register.
- `yes`: Activates the rebalancing register in both directions (forwards and backwards).
- `forward`: Activates the rebalancing register in the forward direction.
This causes the synthesis to shift and reduce a **multiple** of FFs at the inputs of a LUT
to a **single** FF forward at the output of a LUT.
- `backward`: Activates the rebalancing register in the backward direction.
This causes the synthesis to shift and duplicate a **single** FF at the output of a LUT
backwards to a **multiple** of FFs at the input of a LUT.

## History
- 0.0.1 (2024-03-24) Initial version

## Generics

| Generic name        | Type    | Value | Description                                                                                                                                                                                                                                                                                                                                                                                                        |
| ------------------- | ------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| G_PipelineStages    | integer | 3     | Number of pipeline stages (Correspondent to the number of registers in the pipeline)                                                                                                                                                                                                                                                                                                                               |
| G_Width             | integer | 32    | Data width                                                                                                                                                                                                                                                                                                                                                                                                         |
| G_RegisterBalancing | string  | "yes" | Register balancing attribute<br>  - `no` : **Disable** register balancing, <br>  - `yes`: **Enable** register balancing in both directions, <br>  - `forward`: **Enable** register balancing       and moves a set of FFs at the inputs of a LUT to a single FF at its output, <br>  - `backward`: **Enable** register balancing       and moves a single FF at the output of a LUT to a set of FFs at its inputs. |

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
  Pipeline register and connection of the data from the input port to the first stage of the pipeline register. <br> **I_Data -> R_Data(0) -> R_Data(1) -> ... -> R_Data(G_PipelineStages - 1)** -> O_Data
- P_ForwardData: ( R_Data )
  - **Description**
  Connect (combinatoric) data from the last stage of the pipeline register to the output port. <br> I_Data -> R_Data(0) -> R_Data(1) -> ... -> **R_Data(G_PipelineStages - 1) -> O_Data**
