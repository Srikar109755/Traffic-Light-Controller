`timescale 1ns / 1ps


module Design (
    input  logic clk,
    input  logic reset_n,
    input  logic main_road_sensor,
    input  logic side_road_sensor,
    output logic [1:0] main_road_light, // 00: Red, 01: Yellow, 11: Green
    output logic [1:0] side_road_light  // 00: Red, 01: Yellow, 11: Green
);


    localparam [1:0] RED    = 2'b00,
                     YELLOW = 2'b01,
                     GREEN  = 2'b11;


    typedef enum logic [1:0] {
        MAIN_GREEN,
        MAIN_YELLOW,
        SIDE_GREEN,
        SIDE_YELLOW
    } state_t;

    state_t current_state, next_state;


    // Timer durations in clock cycles
    localparam MAIN_GREEN_TIME          = 100;
    localparam YELLOW_TIME              = 20;
    localparam SIDE_GREEN_TIME          = 50;
    localparam MIN_MAIN_GREEN_HOLD_TIME = 30;

    logic [31:0] timer_count;
    logic timer_done;


    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= MAIN_GREEN;
            timer_count   <= 0;
        end else begin
            current_state <= next_state;

            if (timer_done)
                timer_count <= 0;
            else
                timer_count <= timer_count + 1;
        end
    end


    always_comb begin
        timer_done = 1'b0;
        case (current_state)
            MAIN_GREEN:  timer_done = (timer_count >= MAIN_GREEN_TIME - 1);
            MAIN_YELLOW: timer_done = (timer_count >= YELLOW_TIME - 1);
            SIDE_GREEN:  timer_done = (timer_count >= SIDE_GREEN_TIME - 1);
            SIDE_YELLOW: timer_done = (timer_count >= YELLOW_TIME - 1);
            default:     timer_done = 1'b1; 
        endcase
    end


    // Next state
    always_comb begin
        next_state = current_state; // Default to stay in the same state
        case (current_state)
            MAIN_GREEN:
                // Transition if side sensor is active (after min time) OR if timer expires
                if ((timer_count >= MIN_MAIN_GREEN_HOLD_TIME - 1 && side_road_sensor) || timer_done)
                    next_state = MAIN_YELLOW;
            MAIN_YELLOW:
                if (timer_done)
                    next_state = SIDE_GREEN;
            SIDE_GREEN:
                // Transition if main sensor is active OR if timer expires
                if (main_road_sensor || timer_done)
                    next_state = SIDE_YELLOW;
            SIDE_YELLOW:
                if (timer_done)
                    next_state = MAIN_GREEN;
            default:
                next_state = MAIN_GREEN; // Default to a safe state
        endcase
    end


    // Output
    always_comb begin
        main_road_light = RED; 
        side_road_light = RED;
        case (current_state)
            MAIN_GREEN: begin
                main_road_light = GREEN;
                side_road_light = RED;
            end
            MAIN_YELLOW: begin
                main_road_light = YELLOW;
                side_road_light = RED;
            end
            SIDE_GREEN: begin
                main_road_light = RED;
                side_road_light = GREEN;
            end
            SIDE_YELLOW: begin
                main_road_light = RED;
                side_road_light = YELLOW;
            end
            default: begin
                main_road_light = RED;
                side_road_light = RED;
            end
        endcase
    end

endmodule 