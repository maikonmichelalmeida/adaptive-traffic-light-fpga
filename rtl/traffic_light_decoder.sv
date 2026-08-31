module traffic_light_decoder (
    input  logic [1:0] light,
    output logic       car_red,
    output logic       car_green,
    output logic       car_yellow,
    output logic       pedestrian_red,
    output logic       pedestrian_green
);

    always_comb begin
        car_red         = 1'b1;
        car_green       = 1'b0;
        car_yellow      = 1'b0;
        pedestrian_red  = 1'b1;
        pedestrian_green = 1'b0;

        unique case (light)
            2'b00: begin
                car_red   = 1'b0;
                car_green = 1'b1;
            end
            2'b01: begin
                car_red    = 1'b0;
                car_yellow = 1'b1;
            end
            default: begin
                pedestrian_red   = 1'b0;
                pedestrian_green = 1'b1;
            end
        endcase
    end

endmodule
