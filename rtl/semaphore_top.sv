module semaphore_top (
    input  logic        CLK100MHZ,
    input  logic        CPU_RESETN,
    input  logic        BTNC,
    input  logic [15:0] SW,
    output logic [3:0]  LED,
    output logic        LED17_R,
    output logic        LED17_G,
    output logic        LED17_B,
    output logic        LED16_R,
    output logic        LED16_G,
    output logic        LED16_B
);

    logic       tick_1hz;
    logic [4:0] demand_a;
    logic [4:0] demand_b;
    logic [1:0] light_a;
    logic [1:0] light_b;
    logic [1:0] phase;
    logic [6:0] seconds_remaining;

    tick_generator tick_source (
        .clk  (CLK100MHZ),
        .rst_n(CPU_RESETN),
        .tick (tick_1hz)
    );

    traffic_demand_capture demand_capture (
        .clk          (CLK100MHZ),
        .rst_n        (CPU_RESETN),
        .capture_async(BTNC),
        .switches     (SW),
        .demand_a     (demand_a),
        .demand_b     (demand_b)
    );

    adaptive_traffic_controller controller (
        .clk              (CLK100MHZ),
        .rst_n            (CPU_RESETN),
        .tick_1hz         (tick_1hz),
        .demand_a         (demand_a),
        .demand_b         (demand_b),
        .light_a          (light_a),
        .light_b          (light_b),
        .phase            (phase),
        .seconds_remaining(seconds_remaining)
    );

    traffic_light_decoder light_a_decoder (
        .light           (light_a),
        .car_red         (LED17_R),
        .car_green       (LED17_G),
        .car_yellow      (LED17_B),
        .pedestrian_red  (LED[1]),
        .pedestrian_green(LED[0])
    );

    traffic_light_decoder light_b_decoder (
        .light           (light_b),
        .car_red         (LED16_R),
        .car_green       (LED16_G),
        .car_yellow      (LED16_B),
        .pedestrian_red  (LED[3]),
        .pedestrian_green(LED[2])
    );

endmodule
