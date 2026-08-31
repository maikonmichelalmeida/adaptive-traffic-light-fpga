`timescale 1ns/1ps

module tb_adaptive_traffic_controller;

    localparam logic [1:0] GREEN  = 2'b00;
    localparam logic [1:0] YELLOW = 2'b01;
    localparam logic [1:0] RED    = 2'b10;

    logic       clk;
    logic       rst_n;
    logic       tick_1hz;
    logic [4:0] demand_a;
    logic [4:0] demand_b;
    logic [1:0] light_a;
    logic [1:0] light_b;
    logic [1:0] phase;
    logic [6:0] seconds_remaining;
    int errors;

    adaptive_traffic_controller #(
        .BASE_GREEN_SECONDS(5),
        .YELLOW_SECONDS    (2),
        .MIN_GREEN_SECONDS (3),
        .MAX_GREEN_SECONDS (8)
    ) dut (.*);

    always #5ns clk = ~clk;

    task automatic pulse_tick;
        begin
            @(negedge clk);
            tick_1hz = 1'b1;
            @(negedge clk);
            tick_1hz = 1'b0;
            #1ns;
        end
    endtask

    task automatic expect_lights(
        input logic [1:0] expected_a,
        input logic [1:0] expected_b,
        input logic [1:0] expected_phase,
        input string      label
    );
        if ((light_a !== expected_a) ||
            (light_b !== expected_b) ||
            (phase   !== expected_phase)) begin
            $error("%s: A=%b B=%b phase=%0d", label, light_a, light_b, phase);
            errors++;
        end
    endtask

    task automatic advance_ticks(input int count);
        repeat (count) pulse_tick();
    endtask

    initial begin
        $dumpfile("adaptive_traffic_controller.vcd");
        $dumpvars(0, tb_adaptive_traffic_controller);

        clk       = 1'b0;
        rst_n     = 1'b0;
        tick_1hz  = 1'b0;
        demand_a  = 5'd10;
        demand_b  = 5'd2;
        errors    = 0;

        repeat (2) @(posedge clk);
        expect_lights(RED, RED, 2'd0, "safe reset");
        rst_n = 1'b1;
        #1ns;

        // Difference +8 clamps road A to 8 s and road B to 3 s.
        expect_lights(GREEN, RED, 2'd0, "A green");
        if (seconds_remaining !== 7'd8) begin
            $error("A limit should be 8, got %0d", seconds_remaining);
            errors++;
        end

        advance_ticks(8);
        expect_lights(YELLOW, RED, 2'd1, "A yellow");
        advance_ticks(2);
        expect_lights(RED, GREEN, 2'd2, "B green");
        if (seconds_remaining !== 7'd3) begin
            $error("B limit should be 3, got %0d", seconds_remaining);
            errors++;
        end

        advance_ticks(3);
        expect_lights(RED, YELLOW, 2'd3, "B yellow");
        advance_ticks(2);
        expect_lights(GREEN, RED, 2'd0, "cycle restart");

        if (errors != 0)
            $fatal(1, "ADAPTIVE TRAFFIC CONTROLLER FAIL: %0d error(s)", errors);

        $display("ADAPTIVE TRAFFIC CONTROLLER PASS");
        $finish;
    end

endmodule
