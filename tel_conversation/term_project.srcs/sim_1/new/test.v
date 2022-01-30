`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2021 16:50:14
// Design Name: 
// Module Name: sim_tel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_tel();

    reg clk, rst, startCall, answerCall, endCall, sendChar;
    reg[7:0] charSent;
    wire[63:0] statusMsg;
    wire[63:0] sentMsg;
    
    always #5 clk = ~clk;
    
    tel_conv UUT(
        .clk(clk),
        .rst(rst),
        .startCall(startCall),
        .answerCall(answerCall),
        .endCall(endCall),
        .sendChar(sendChar),
        .charSent(charSent),
        .statusMsg(statusMsg),
        .sentMsg(sentMsg)   
    );
    
    initial begin
        // INITIAL STATE
        clk = 0; rst = 0; startCall = 0; answerCall = 0;  endCall = 0; charSent = " ";
	    #10; 
        // SYN. RESET
        rst=1; 
        #10; // WAIT FOR CYCLE
        rst=0; 
        #10; 
        rst=0;              // reset
        // BUSY STATE TEST
        startCall=1; // START THE CALL
        #10; 
        startCall=0; 
        #150;          // RING THE PHONE 10 CYCLES, WAIT FOR BUSY STATE                      
        // REJECTED STATE TEST
        startCall=1; // START THE CALL
        #10; 
        startCall=0; 
        #40;         
        endCall=1; 
        #10; 
        endCall=0; 
        #40;
        
        
        startCall=1; // Start call
        #10; 
        startCall=0; 
        #10; // RING         
        endCall=1; 
        #10; 
        endCall=0; 
        #150; // REJECT THE CALL --> STATE REJECTION
        
        startCall=1; // START CALL
        #10; // MAKE SURE WE SEE A POSITIVE EDGE
        startCall=0;              
        #10;                 
        answerCall=1; // GO TO CALL STATE
        #10; 
        answerCall=0;            
        #10;                                        
        // SEND CHARS
        sendChar=1; charSent="S"; #10; // cost 2 msg  --> S
        sendChar=1; charSent="A"; #10; // cost 2 msg, cost becomes 4 --> SA
        sendChar=1; charSent="D"; #10; // cost 2 msg, cost becomes 6 --> SAD
        sendChar=1; charSent="I"; #10; // cost 2 msg, cost becomes 8 --> SADI
        sendChar=1; charSent=" "; #10; // cost 2 msg, cost becomes 10 --> "SADI "
        sendChar=1; charSent="A"; #10; // cost 2 msg, cost becomes 12 --> SADI A
        sendChar=1; charSent="K"; #10; // cost 2 msg, cost becomes 14 --> SADI AK
        sendChar=1; charSent="I"; #10; // cost 2 msg, cost becomes 16 --> SADI AKI
        sendChar=1; charSent= 31; #10; // Invalid char, cost and msg does not change --> SADI AKI
        sendChar=1; charSent="F"; #10; // cost 2 msg, cost becomes 18 --> ADI AKIF
        sendChar=1; charSent="1"; #10; sendChar = 0; // cost 1 msg, cost becomes 19 --> DI AKIF1
        #30;
        sendChar=1; charSent=127; #10; sendChar=0; charSent = 1; #10; // Finish call with char127, cost is 21
        #80; 
        
        #50;
        startCall=1; // START CALL
        #10; // MAKE SURE WE SEE A POSITIVE EDGE
        startCall=0;              
        #10;          // RING RING RING  
        answerCall=1; // GO TO CALL STATE
        #10; 
        answerCall=0;            
        #50; 
        endCall = 1;
        #10;
        endCall = 0;
        #30;  
        
        
    end
    
    
endmodule
