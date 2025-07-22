# Traffic Light Controller FSM (SystemVerilog)

This project implements a finite state machine (FSM)-based Traffic Light Controller using SystemVerilog. It manages traffic flow between a main road and a side road using timer-based and sensor-triggered logic.

---

## Features

- Four defined states: `MAIN_GREEN`, `MAIN_YELLOW`, `SIDE_GREEN`, `SIDE_YELLOW`
- Prioritized main road with minimum green hold time
- Sensor-triggered transitions with timing constraints
- Modular testbench with simulation logging
- FSM diagram and waveform visualization

---

## File Structure

```
traffic_light_fsm/
├── Design.sv # Main FSM logic
├── TB_Traffic_Light_Controller.sv # Testbench for simulation
```


---

## FSM Transition Summary

- `MAIN_GREEN → MAIN_YELLOW`  
  - When `side_road_sensor` is active **and** minimum hold time is met  
  - Or when `MAIN_GREEN_TIME` expires

- `MAIN_YELLOW → SIDE_GREEN`  
  - When `YELLOW_TIME` expires

- `SIDE_GREEN → SIDE_YELLOW`  
  - When `main_road_sensor` is active  
  - Or when `SIDE_GREEN_TIME` expires

- `SIDE_YELLOW → MAIN_GREEN`  
  - When `YELLOW_TIME` expires

---

## FSM Diagram

![FSM Diagram](https://github.com/Srikar109755/Traffic-Light-Controller/blob/main/Images/FSM.png)

---

## Simulation Waveform

![Simulation Waveform](https://github.com/Srikar109755/Traffic-Light-Controller/blob/main/Outputs/Waveform.png)

---

## How to Simulate

1. Add `Design.sv` and `TB_Traffic_Light_Controller.sv` to your simulator.
2. Compile and run the testbench module:
   ```bash
   vsim TB_Traffic_Light_Controller
