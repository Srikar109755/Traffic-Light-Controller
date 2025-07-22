`timescale 1ns / 1ps


module TB_Traffic_Light_Controller;

    parameter CLK_PERIOD = 10;

    logic clk;
    logic reset_n;
    logic main_road_sensor;
    logic side_road_sensor;
    logic [1:0] main_road_light;
    logic [1:0] side_road_light;


    Design dut (
        .clk(clk),
        .reset_n(reset_n),
        .main_road_sensor(main_road_sensor),
        .side_road_sensor(side_road_sensor),
        .main_road_light(main_road_light),
        .side_road_light(side_road_light)
    );


    always #(CLK_PERIOD / 2) clk = ~clk;


    function string decode_light(input [1:0] light);
        case (light)
            2'b00:   return "RED   ";
            2'b01:   return "YELLOW";
            2'b11:   return "GREEN ";
            default: return "INVALID";
        endcase
    endfunction


    initial begin
        $display("Simulation Starts");
        $monitor("Time: %4t ns | Main: %s | Side: %s | MainSensor: %b | SideSensor: %b | State: %s",
                 $time,
                 decode_light(main_road_light),
                 decode_light(side_road_light),
                 main_road_sensor,
                 side_road_sensor,
                 dut.current_state.name());


        clk = 0;
        reset_n = 0;
        main_road_sensor = 0;
        side_road_sensor = 0;
        #20;
        reset_n = 1;
        @(posedge clk);
        $display("\n[TEST] Reset released. Initial state should be MAIN_GREEN.");
        
        
        // Waiting for minimum green time, then trigger side sensor.
        $display("\n[TEST] Wait for MIN_MAIN_GREEN_HOLD_TIME and trigger side sensor...");
        repeat (dut.MIN_MAIN_GREEN_HOLD_TIME) @(posedge clk);
        side_road_sensor = 1;
        @(posedge clk);
        side_road_sensor = 0; // a Pulse
        
        
        // Waiting until side road gets a green light.
        $display("\n[TEST] Waiting for side road to turn GREEN.");
        wait (side_road_light == dut.GREEN);
        

        // Side road is green, trigger main sensor to switch back early.
        $display("\n[TEST] Side road is GREEN. Triggering main sensor to switch back.");
        main_road_sensor = 1;
        @(posedge clk);
        main_road_sensor = 0;


        // Waiting for Main road to be green again
        $display("\n[TEST] Waiting for main road to turn GREEN again.");
        wait (main_road_light == dut.GREEN);


        // Let main green timer expire naturally
        $display("\n[TEST] Main is GREEN. Let full timer expire without sensor input.");
        repeat (dut.MAIN_GREEN_TIME + 5) @(posedge clk);
        
        // Finish
        repeat (50) @(posedge clk);
        $display("\nSimulation Complete");
        $finish;
    end

endmodule