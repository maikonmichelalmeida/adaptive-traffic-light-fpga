module tick_generator #(
    parameter int unsigned CLOCK_HZ = 100_000_000,
    parameter int unsigned TICK_HZ  = 1
) (
    input  logic clk,
    input  logic rst_n,
    output logic tick
);

    localparam int unsigned CYCLES_PER_TICK = CLOCK_HZ / TICK_HZ;
    localparam int unsigned COUNTER_WIDTH =
        (CYCLES_PER_TICK <= 1) ? 1 : $clog2(CYCLES_PER_TICK);

    logic [COUNTER_WIDTH-1:0] counter;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            counter <= '0;
            tick    <= 1'b0;
        end else if (counter == CYCLES_PER_TICK - 1) begin
            counter <= '0;
            tick    <= 1'b1;
        end else begin
            counter <= counter + 1'b1;
            tick    <= 1'b0;
        end
    end

endmodule
