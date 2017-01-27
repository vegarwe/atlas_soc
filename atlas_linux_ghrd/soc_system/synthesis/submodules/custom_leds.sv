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

fisken_top
(
        .gpio0          (gpio0),
        .led_o          (leds),
        .btn_i          (button_in_port),

        .s0_address     (avs_s0_address),
        .s0_read        (avs_s0_read),
        .s0_write       (avs_s0_write),
        .s0_readdata    (avs_s0_readdata),
        .s0_writedata   (avs_s0_writedata),

        .reset          (reset),
        .clk            (clk)
);

endmodule // custom_leds
