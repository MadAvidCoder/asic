/*

`default_nettype none

module top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule */

module top (
    output logic [4:0] led,
    input  logic [1:0] button,
    input  wire        clk
);
    logic [28:0] clkb;
    wire b0 = button[0];
    wire b1 = button[1];
    reg b0c, b1c;

    debounce db0(.dirtyin(b0), .clk(clk), .cleanout(b0c));
    debounce db1(.dirtyin(b1), .clk(clk), .cleanout(b1c));

    reg enable = 0;
    reg bright = 0;

    always @(posedge b1c) bright <= !bright;
    always @(posedge b0c) enable <= !enable;

    always_ff @(posedge clk) begin
      if (enable) begin
        clkb <= clkb + 1'b1;
      end
      else begin
        clkb <= 0;
      end
    end

    always_ff @(negedge clk) begin
      if ((clkb[3:1] != 3'b111) && (bright))
        led <= 0;
      else
        led <= clkb[28:24];
    end

endmodule

module debounce(
  input dirtyin,
  input clk,
  output reg cleanout,
);
  reg fa, fb;
  reg [18:0] counter;

  always @(posedge clk) begin
    fa <= dirtyin;
    fb <= fa;

    if (fb == cleanout) begin
      counter <= '0;
    end else begin
      counter <= counter + 1'b1;
    end

    if (counter == 500000) begin
      cleanout <= fb;
      counter <= '0;
    end
  end


endmodule