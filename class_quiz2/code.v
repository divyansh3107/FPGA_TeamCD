`timescale 1ns / 1ps

 
//////////////////////////////////////////////////////////////////////////////////


module main(  
        input  clock_100Mhz,
//        input [1:0] sel,
       // 100 Mhz clock source on Basys 3 FPGA
    input reset, // reset
    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out//
        
    );
         wire [17: 0] a;
        wire [17: 0] b;
        wire [17: 0] c;
       reg [47: 0] p;
       reg carryin;
       reg [35:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
    reg [15:0] displayed_number; // counting number to be displayed
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
    reg [2:0] addra;
        //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

blk_mem_gen_0 a_mem (
  .clka(clock_100Mhz),    // input wire clka
  .addra(addra),  // input wire [2 : 0] addra
  .douta(a)  // output wire [17 : 0] douta
);
blk_mem_gen_0 b_mem (
  .clka(clock_100Mhz),    // input wire clka
  .addra(addra),  // input wire [2 : 0] addra
  .douta(b)  // output wire [17 : 0] douta
);
blk_mem_gen_0 c_mem (
  .clka(clock_100Mhz),    // input wire clka
  .addra(addra),  // input wire [2 : 0] addra
  .douta(c)  // output wire [17 : 0] douta
);
//blk_mem_gen_1 c_mem (
//  .clka(clock_100Mhz),    // input wire clka
//  .addra(addra),  // input wire [2 : 0] addra
//  .douta(c)  // output wire [47 : 0] douta
//);
//dsp_macro_0 dsp (
//  .CLK(clock_100Mhz),          // input wire CLK
//  .SEL(sel),          // input wire [1 : 0] SEL
//  .CARRYIN(carryin),  // input wire CARRYIN
//  .A(a),              // input wire [17 : 0] A
//  .B(b),              // input wire [17 : 0] B
//  .C(c),              // input wire [47 : 0] C
//  .D(d),              // input wire [17 : 0] D
//  .P(p)              // output wire [47 : 0] P
//);
initial begin
addra=0;
carryin=1;
end
always@(posedge  clock_100Mhz) begin
 //p<= a*b+c;
p<=a+c;
end
  always @(posedge clock_100Mhz or posedge reset)
    begin
        if(reset==1)
            one_second_counter <= 0;
        else begin
            if(one_second_counter>=999999999) 
                 one_second_counter <= 0;
            else begin
                one_second_counter <= one_second_counter + 1;
               
            end
        end
    end 
    assign one_second_enable = (one_second_counter==999999999)?1:0;
    always @(posedge clock_100Mhz or posedge reset)
    begin
        if(reset==1)
            displayed_number <= 0;
        else if(one_second_enable==1)begin
        
            displayed_number <= p;
            addra<=addra+1;
            end
    end
    
    always @(posedge clock_100Mhz or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19:18];
    // anode activating signals for 4 LEDs, digit period of 2.6ms
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = displayed_number/1000;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = (displayed_number % 1000)/100;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = ((displayed_number % 1000)%100)/10;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = ((displayed_number % 1000)%100)%10;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b0000001; // "0"     
        4'b0001: LED_out = 7'b1001111; // "1" 
        4'b0010: LED_out = 7'b0010010; // "2" 
        4'b0011: LED_out = 7'b0000110; // "3" 
        4'b0100: LED_out = 7'b1001100; // "4" 
        4'b0101: LED_out = 7'b0100100; // "5" 
        4'b0110: LED_out = 7'b0100000; // "6" 
        4'b0111: LED_out = 7'b0001111; // "7" 
        4'b1000: LED_out = 7'b0000000; // "8"     
        4'b1001: LED_out = 7'b0000100; // "9" 
        default: LED_out = 7'b0000001; // "0"
        endcase
    end  
endmodule





