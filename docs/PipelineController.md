
# Entity: PipelineController 
- **File**: PipelineController.vhd

## Diagram
![Diagram](PipelineController.svg "Diagram")
## Generics

| Generic name     | Type      | Value | Description               |
| ---------------- | --------- | ----- | ------------------------- |
| G_PipelineStages | integer   | 3     | Number of pipeline stages |
| G_ResetActiveAt  | std_logic | '1'   | Reset active at:          |

## Ports

| Port name            | Direction | Type        | Description                                                                                                                                                                |
| -------------------- | --------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| I_CLK                | in        | std_logic   | Clock signal; **Rising edge** triggered                                                                                                                                    |
| I_RST                | in        | std_logic   | Reset signal; Active at `G_ResetActiveAt`                                                                                                                                  |
| I_CE                 | in        | std_logic   | Chip enable; Active high                                                                                                                                                   |
| O_Enable             | out       | std_logic   | Pipeline enable; Active high when pipeline can accept data and `I_CE` is high. <br>  **Note:** Connect to `I_Enable` of the registers to be controlled by this controller. |
| Input-AXI-Handshake  | in        | Virtual bus | Input AXI like Handshake                                                                                                                                                   |
| Output-AXI-Handshake | out       | Virtual bus | Output AXI like Handshake                                                                                                                                                  |

### Virtual Buses

#### Input-AXI-Handshake

| Port name | Direction | Type      | Description                                                                               |
| --------- | --------- | --------- | ----------------------------------------------------------------------------------------- |
| I_Valid   | in        | std_logic | Valid data flag; indicates that the data on `I_Data` of the connected registers is valid. |
| O_Ready   | out       | std_logic | Ready flag; indicates that the connected registers is ready to accept data.               |
#### Output-AXI-Handshake

| Port name | Direction | Type      | Description                                                                               |
| --------- | --------- | --------- | ----------------------------------------------------------------------------------------- |
| O_Valid   | out       | std_logic | Valid data flag; indicates that the data on `O_Data` of the connected registers is valid. |
| I_Ready   | in        | std_logic | Ready flag; indicates that the external component is ready to accept data.                |

## Signals

| Name    | Type                                            | Description                                                                                                                             |
| ------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| R_Valid | std_logic_vector(G_PipelineStages - 1 downto 0) | Pipeline ready signal for each stage of the pipeline to indicate that the data in pipeline is valid                                     |
| C_Ready | std_logic                                       | Ready signal for the pipeline controller to indicate that the pipeline can accept data; <br>  mapped to `O_Enable` and `O_Ready` ports. |

## Processes
- P_Flags: ( R_Valid, I_Ready )
  - **Description**
  Produce the `C_Ready` signal for the pipeline controller, controlling the data flow in the pipeline.
- P_ValidPipeline: ( I_CLK )
  - **Description**
  Shift the pipeline stages with `R_Valid` signal as placeholder to control the pipeline stages.
