module tb_Synchronous_FIFO;

parameter WIDTH = 32;
parameter DEPTH = 1024;
localparam ADDR_WIDTH = $clog2(DEPTH);

reg clk, rst_n, wr_en, rd_en;
reg [WIDTH-1:0] data_in;
wire [WIDTH-1:0] data_out;
wire full, empty;
integer tc;
reg [WIDTH-1:0] expected_data;

Synchronous_FIFO #(.WIDTH(WIDTH), .DEPTH(DEPTH)) fifo_inst (
    .clk(clk),
    .reset(rst_n),
    .d_in(data_in),
    .w_enb(wr_en),
    .r_enb(rd_en),
    .d_out(data_out),
    .full(full),
    .empty(empty)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_Synchronous_FIFO);
end

initial begin
    if (!$value$plusargs("tc=%d", tc)) begin
      $display("No test case used exiting progam.");
        $finish;
    end
    
    rst_n = 0; wr_en = 0; rd_en = 0;
    #20 rst_n = 1;
    
    case(tc)
        1: t_w_or_r();
        2: t_fc();
        3: t_ec();
        4: t_wrap();
        5: t_simulops();
        6: t_rst();
        7: t_over();
        8: t_under();
        9: t_dataint();
        default: $display("Invalid tc selected");
    endcase
    
    #100 $finish;
end

//side tasks
task transwrite(input [WIDTH-1:0] data);
begin
    @(negedge clk);
    wr_en = 1;
    data_in = data;
    @(negedge clk);
    wr_en = 0;
    $display("Write: 0x%h", data);
end
endtask

task transread(input [WIDTH-1:0] expected = 32'hx);
begin
    @(negedge clk);
    rd_en = 1;
    @(negedge clk);
    rd_en = 0;
    $display("Read:  0x%h", data_out);
    if(expected !== 32'hx && data_out !== expected)
      $error("Data mismatch exp 0x%h, got 0x%h", expected, data_out);
end
endtask

task checkf(input expected);
begin
    if(full !== expected)
      $error("Full flag mismatch exp %b, got %b", expected, full);
    else
      $display("Full check ok: %b", full);
end
endtask

task checke(input expected);
begin
    if(empty !== expected)
      $error("Empty flag mismatch exp %b, got %b", expected, empty);
    else
      $display("Empty check ok: %b", empty);
end
endtask

//main tasks
  task t_w_or_r(); //write or read
begin
    $display("\n Basic Write/Read Test ");
    transwrite(32'hAABBCCDD);
    transread(32'hAABBCCDD);
end
endtask

  task t_fc();  //full cond
begin
  $display("\n Full Condition Test ");
    repeat(DEPTH) transwrite($random);
    checkf(1);
    transwrite(32'hDEADBEEF);
    checkf(1);
end
endtask

  task t_ec();   //empty cond
begin
    $display("\n Empty Condition Test ");
    checke(1);
    transwrite(32'h12345678);
    transread(32'h12345678);
    checke(1);
end
endtask

  task t_wrap();  //wrap around
integer i;
begin
    $display("\n Wrap Around Test ");
    repeat(DEPTH) transwrite($random);
    repeat(DEPTH) transread();
    transwrite(32'hW0W0W0W0);
    transread(32'hW0W0W0W0);
    checke(1);
end
endtask

  task t_simulops();  //simultaneous operatiion
begin
  $display("\n Simultaneous Read/Write Test ");
    transwrite(32'h55555555);
    fork
        transwrite(32'hAAAAAAAA);
        transread(32'h55555555);
    join
    transread(32'hAAAAAAAA);
end
endtask

  task t_rst(); //reset
begin
    $display("\n Reset Test ");
    transwrite(32'h12345678);
    rst_n = 0;
    #20;
    checke(1);
    rst_n = 1;
end
endtask

  task t_over();    //overflow protection
begin
  $display("\n Overflow Protection Test ");
    repeat(DEPTH) transwrite($random);
    checkf(1);
    transwrite(32'hBAD0BAD0);
    checkf(1);
end
endtask

  task t_under();   //underflow proctection
begin
  $display("\n Underflow Protection Test ");
    checke(1);
    transread();
    checke(1);
end
endtask

  task t_dataint();  //data integrity
integer i;
begin
  $display("\n Data Integrity Test ");
    for(i=0; i<DEPTH; i=i+1)
        transwrite(i);
    for(i=0; i<DEPTH; i=i+1)
        transread(i);
end
endtask

endmodule
