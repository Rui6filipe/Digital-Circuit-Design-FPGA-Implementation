`timescale 1ns / 1ps

// Control Part 
module MooreMachine(input logic clk,
                    input logic reset,
                    input logic go,
                    output logic sel,
                    output logic load,
                    output logic ok,
                    output logic clear);
                    
    typedef enum logic [2:0] {S0, S1, S2, S3, S4} statetype;
    statetype state, nextstate;
    
    // state register
    always_ff @(posedge clk, posedge reset)
     if (reset) state <= S0;
     else state <= nextstate;
     
    // next state logic
    always_comb
     case (state)
         S0: if (go) nextstate = S1;
            else nextstate = S0;
         S1: nextstate = S2;
         S2: nextstate = S3;
         S3: nextstate = S4;
         S4: if (go) nextstate = S4;
            else nextstate = S0;
         default: nextstate = S0;
     endcase
     
    // output logic
    assign clear = (state == S0);
    assign ok = (state == S4);
    assign load = (state == S1 | state == S2 | state == S3);
    assign sel = (state == S1);
    
endmodule



// Data Part
module mux(input logic [1:0] a0, a1, b0, b1, 
           input logic sel,
           output logic [1:0] s0, s1);
            
    assign s0 = sel ? a0 : b0;
    assign s1 = sel ? a1 : b1;
    
endmodule



module add4(input logic a0, a1,     
            input logic [2:0] b,    
            output logic [3:0] sum);

    logic [1:0] a;                  
    always_comb begin
        a = {a1, a0};                 
        sum = a + b;              
    end

endmodule





module register_4bit(input logic clk,    
                     input logic clear,  // Synchronous clear
                     input logic load,   
                     input logic [3:0] d,      
                     output logic [3:0] q);    

    always_ff @(posedge clk) begin
        if (clear)
            q <= 4'b0000;  // Clear the register
        else if (load)
            q <= d;        // Load new data
    end
endmodule




module comparator(input logic [3:0] c,
                  output logic gt5);
                 
    always_comb begin
        if (c > 4'b0101)
            gt5 = 1'b1;
        else
            gt5 = 1'b0;
    end 

endmodule




module f(input logic d,
         input logic ok,
         input logic clk,
         output logic alarm);

    always_ff @(posedge clk)
        if (ok) alarm <= d;
        
endmodule
    




module Project(input logic clk, reset, go,        // Inputs for the Control Part
               input logic [1:0] a0, a1, b0, b1,  // Inputs for the Data Part
               output logic alarm);               // Output of the system

    // Control Part Signals
    logic sel, load, ok, clear;

    // Data Part Signals
    logic [1:0] s0, s1; // MUX outputs
    logic [3:0] sum, q; // ADD4 and Register outputs
    logic gt5;          // Comparator output

    MooreMachine control(
        .clk(clk),
        .reset(reset),
        .go(go),
        .sel(sel),
        .load(load),
        .ok(ok),
        .clear(clear));

    mux mux_inst(
        .a0(a0), 
        .a1(a1), 
        .b0(b0), 
        .b1(b1),
        .sel(sel),
        .s0(s0), 
        .s1(s1));

    add4 add_inst(
        .a0(s0), 
        .a1(s1),
        .b(q[2:0]),  
        .sum(sum));

    register_4bit reg_inst(
        .clk(clk),
        .clear(clear),
        .load(load),
        .d(sum),
        .q(q));

    comparator comp_inst(
        .c(q),  
        .gt5(gt5));

    f f_inst(
        .d(gt5),
        .ok(ok),
        .clk(clk),
        .alarm(alarm));

endmodule

