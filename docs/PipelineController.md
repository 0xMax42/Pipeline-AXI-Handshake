
# Entity: PipelineController 
- **File**: PipelineController.vhd

## Diagram
![Diagram](PipelineController.svg "Diagram")
## Description

- Name:     **Pipeline Controller**
- Version:  0.0.1
- Author:   _Maximilian Passarello ([Blog](mpassarello.de))_
- License:  [MIT](LICENSE)

The Pipeline Controller provides an easy way to construct a pipeline
with AXI-Like handshaking at the input and output of the pipeline.

### Core functions

- **Data flow control**: Data flow control is implemented via handshaking at the input and output ports.
- **Validity control**: The controller keeps the validity of the data in the individual pipeline stages under control.
- **Adjustability**: The pipeline controller can be customized via the generics.

### Generics

Use the generic `G_PipelineStages` to set how deep the pipeline is.
This depth contains all the registers associated with the pipeline.
For example, for an _I_FF ⇨ Combinatorics ⇨ O_FF_ construction, the generic must be set to **2**.

The active level of the reset input can also be set.

### Clock Enable

The `I_CE` port is active high and, when deactivated,
effectively switches on the acceptance or output of data via handshaking in addition to the pipeline.

### Reset

A reset is explicitly **not** necessary on the pipeline registers.
The validity of the data is kept under control via the pipeline controller
and only this requires a dedicated reset if necessary.

### Pipeline control

You must connect the `O_Enable` port to the CE input of the corresponding pipeline registers.
This is used to activate or deactivate the pipeline in full or via CE deactivated state.

### AXI like Handshaking

- **Input**: The `O_Ready` (active high) port is used to signal to the data-supplying component that data should be accepted.
If it switches on `I_Valid` (active high), this in turn signals that data is ready to be accepted at its output.
If both ports are active at the same time, the transfer is executed.
- **Output**: The process runs analogously at the pipeline output.

## History
- 0.0.1 (2024-03-24) Initial version

## Generics

| Generic name     | Type      | Value | Description                                                       |
| ---------------- | --------- | ----- | ----------------------------------------------------------------- |
| G_PipelineStages | integer   | 3     | Number of pipeline stages (FFs in the pipeline including I/O FFs) |
| G_ResetActiveAt  | std_logic | '1'   | Reset active at this level                                        |

## Ports

| Port name            | Direction | Type        | Description                                                                                                                                                                     |
| -------------------- | --------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| I_CLK                | in        | std_logic   | Clock signal; **Rising edge** triggered                                                                                                                                         |
| I_RST                | in        | std_logic   | Reset signal; Active at `G_ResetActiveAt`                                                                                                                                       |
| I_CE                 | in        | std_logic   | Chip enable; Active high                                                                                                                                                        |
| O_Enable             | out       | std_logic   | Pipeline enable; Active high when pipeline can accept data and `I_CE` is high. <br>  **Note:** Connect `CE` of the registers to be controlled by this controller to `O_Enable`. |
| Input-AXI-Handshake  | in        | Virtual bus | Input AXI like Handshake                                                                                                                                                        |
| Output-AXI-Handshake | out       | Virtual bus | Output AXI like Handshake                                                                                                                                                       |

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
- P_ExternalFlags: ( R_Valid, C_Ready, I_CE )
  - **Description**
  Produce the `O_Valid`, `O_Enable`, and `O_Ready` signals for the pipeline controller. <br> - `O_Enable`, and `O_Ready` are **and** combined from the `C_Ready` and `I_CE` signals. <br> - `O_Valid` is the last bit of the `R_Valid` signal  and represents the validity of the data in the last stage of the pipeline.
- P_InternalFlags: ( R_Valid, I_Ready )
  - **Description**
  Produce the `C_Ready` signal for the pipeline controller, controlling the data flow in the pipeline. <br> `C_Ready` is asserted when the data is available in the last stage of the pipeline **and** the external component is ready to accept data **or** when no data is available in the last stage of the pipeline.
- P_ValidPipeline: ( I_CLK )
  - **Description**
  Shift the pipeline stages with `R_Valid` signal as placeholder to control  the validity of the data in the individual pipeline stages.
