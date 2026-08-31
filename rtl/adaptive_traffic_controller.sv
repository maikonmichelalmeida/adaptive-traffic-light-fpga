module adaptive_traffic_controller #(
    parameter int unsigned BASE_GREEN_SECONDS = 33,
    parameter int unsigned YELLOW_SECONDS     = 10,
    parameter int unsigned MIN_GREEN_SECONDS  = 15,
    parameter int unsigned MAX_GREEN_SECONDS  = 60
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tick_1hz,
    input  logic [4:0] demand_a,
    input  logic [4:0] demand_b,
    output logic [1:0] light_a,
    output logic [1:0] light_b,
    output logic [1:0] phase,
    output logic [6:0] seconds_remaining
);

    localparam logic [1:0] LIGHT_GREEN  = 2'b00;
    localparam logic [1:0] LIGHT_YELLOW = 2'b01;
    localparam logic [1:0] LIGHT_RED    = 2'b10;

    localparam logic [1:0] A_GREEN  = 2'd0;
    localparam logic [1:0] A_YELLOW = 2'd1;
    localparam logic [1:0] B_GREEN  = 2'd2;
    localparam logic [1:0] B_YELLOW = 2'd3;

    logic [6:0] phase_limit;
    logic [6:0] elapsed;
    logic [6:0] green_a_seconds;
    logic [6:0] green_b_seconds;
    integer signed difference;
    integer signed candidate_a;
    integer signed candidate_b;

    function automatic [6:0] clamp_green(input integer signed candidate);
        if (candidate < MIN_GREEN_SECONDS)
            clamp_green = MIN_GREEN_SECONDS[6:0];
        else if (candidate > MAX_GREEN_SECONDS)
            clamp_green = MAX_GREEN_SECONDS[6:0];
        else
            clamp_green = candidate[6:0];
    endfunction

    always_comb begin
        difference     = $signed({1'b0, demand_a}) - $signed({1'b0, demand_b});
        candidate_a    = BASE_GREEN_SECONDS + difference;
        candidate_b    = BASE_GREEN_SECONDS - difference;
        green_a_seconds = clamp_green(candidate_a);
        green_b_seconds = clamp_green(candidate_b);

        unique case (phase)
            A_GREEN:  phase_limit = green_a_seconds;
            A_YELLOW: phase_limit = YELLOW_SECONDS[6:0];
            B_GREEN:  phase_limit = green_b_seconds;
            default:  phase_limit = YELLOW_SECONDS[6:0];
        endcase

        if (elapsed < phase_limit)
            seconds_remaining = phase_limit - elapsed;
        else
            seconds_remaining = 7'd0;

        light_a = LIGHT_RED;
        light_b = LIGHT_RED;

        if (rst_n) begin
            unique case (phase)
                A_GREEN:  light_a = LIGHT_GREEN;
                A_YELLOW: light_a = LIGHT_YELLOW;
                B_GREEN:  light_b = LIGHT_GREEN;
                B_YELLOW: light_b = LIGHT_YELLOW;
                default: begin
                    light_a = LIGHT_RED;
                    light_b = LIGHT_RED;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            phase   <= A_GREEN;
            elapsed <= 7'd0;
        end else if (tick_1hz) begin
            if (elapsed + 1'b1 >= phase_limit) begin
                elapsed <= 7'd0;
                phase   <= phase + 1'b1;
            end else begin
                elapsed <= elapsed + 1'b1;
            end
        end
    end

endmodule
