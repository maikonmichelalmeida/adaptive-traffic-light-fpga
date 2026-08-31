module traffic_demand_capture (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        capture_async,
    input  logic [15:0] switches,
    output logic [4:0]  demand_a,
    output logic [4:0]  demand_b
);

    logic capture_meta;
    logic capture_sync;
    logic capture_previous;
    logic capture_pulse;

    assign capture_pulse = capture_sync & ~capture_previous;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            capture_meta     <= 1'b0;
            capture_sync     <= 1'b0;
            capture_previous <= 1'b0;
            demand_a         <= 5'd0;
            demand_b         <= 5'd0;
        end else begin
            capture_meta     <= capture_async;
            capture_sync     <= capture_meta;
            capture_previous <= capture_sync;

            if (capture_pulse) begin
                demand_a <= {1'b0, switches[3:0]} + {1'b0, switches[7:4]};
                demand_b <= {1'b0, switches[11:8]} + {1'b0, switches[15:12]};
            end
        end
    end

endmodule
