module custom_leds
(
    input  logic        clk,            // clock.clk
    input  logic        reset,          // reset.reset

    // Memory mapped read/write slave interface
    input  logic        avs_s0_address,   // avs_s0.address
    input  logic        avs_s0_read,      // .read
    input  logic        avs_s0_write,     // .write
    output logic [31:0] avs_s0_readdata,  // .readdata
    input  logic [31:0] avs_s0_writedata,	// .writedata

    // To top level
    input  logic [3:0]  button_in_port,
    inout  logic [35:0] gpio0,

    // The LED outputs
    output logic [7:0] leds
);

logic [31:0] out_data;
logic [31:0] in_data;

custom_fisken(
        .gpio0      (gpio0),
        .led_o      (leds),
        .fisken_o   (out_data),
        .fisken_i   (in_data),
        .btn_i      (button_in_port),
        .reset      (reset),
        .clk        (clk)
);

// Read operations performed on the Avalon-MM Slave interface
always_comb begin
    if(avs_s0_read) begin
        case(avs_s0_address)
            1'b0    : avs_s0_readdata = out_data;
            default : avs_s0_readdata = 'x;
        endcase
    end else begin
        avs_s0_readdata = 'x;
    end
end

// Write operations performed on the Avalon-MM Slave interface
always_ff @(posedge clk) begin
    if(reset) begin
        in_data <= '0;
    end else if (avs_s0_write) begin
        case(avs_s0_address)
            1'b0    : in_data <= avs_s0_writedata;
            default : in_data <= in_data;
        endcase
    end
end

endmodule // custom_leds
