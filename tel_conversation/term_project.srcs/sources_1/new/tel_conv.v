`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2021 03:01:22 PM
// Design Name: 
// Module Name: tel_conv
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


module tel_conv(

        input clk,
		input rst,
		input startCall, 
		input answerCall, 
		input endCall,
		input sendChar,
		input [7:0]charSent,
		output reg [63:0] statusMsg,
		output reg [63:0] sentMsg);

reg [2:0] cState; // Current State
reg [2:0] nState; // Next State
reg [3:0] counter;
reg [3:0] counter2;
reg [31:0] cost; //cost initialization-----1
parameter IDLE = 0;
parameter BUSY = 1;
parameter REJECTED = 2;
parameter RINGING = 3;
parameter CALL = 4;
parameter COST = 5;
always @(posedge clk or posedge rst)
begin
    if (rst)
        cState <= IDLE;
    else 
        cState <= nState;
end
// combinational part - next state definitions
always @(*)
begin
    case(cState)
        IDLE:
        begin
            if (startCall == 1) 
                nState = RINGING;
            else                   
                nState = IDLE;
        end
        RINGING:
        begin
			if (endCall == 1) nState = REJECTED;
			else if (answerCall == 1) nState = CALL;
            else if (counter == 9) nState = BUSY;
		    else nState = RINGING;	
        end
        CALL:
        begin
            if (endCall  == 1) nState = COST;
			else if (sendChar == 1 && charSent == 127) nState= COST;
			else nState = CALL;
        end
		BUSY:
		  begin
			if (counter2  == 9) nState = IDLE;
			else nState = BUSY;
		  end
        REJECTED:
        begin
            if (counter2 == 9) nState = IDLE;
			else nState = REJECTED;
        end
		COST:
		  begin
			if (counter == 4) nState = IDLE;
			else nState = COST;
		  end
		default: nState = IDLE;
    endcase
    
end
//sequential part - control registers________________________________________
always @ (posedge clk or posedge rst)
begin
	if(rst)
	begin
		counter       <= 0;
		counter2      <= 0;
		cost		  <= 0;
	end
	else
	begin
		case(cState)
		   IDLE:
			begin
					counter       <= 0;
					counter2      <= 0;
					cost		  <= 0; 
			end
			REJECTED:
				begin
					if(counter2 == 9) counter2 <= 0; 
					else counter2 <= counter2 + 1;
				end
			RINGING:
				begin
					if(counter == 9) counter <= 0; 
					else counter <= counter+1;
				end
			CALL:
				begin
                    counter <= 0;
                    if (sendChar == 1)
                    begin
                        if (32<=charSent && charSent<=127)
                        begin
                            if (48<=charSent && charSent<=57) 
                                cost <= cost+1; 
                            else 
                                cost<=cost+2;
                        end
                        else 
                            cost <= cost;	
                    end
				end
            BUSY:
                begin
                    if(counter2 == 9) counter2 <= 0; 
                    else counter2 <= counter2+1;
                end
                
			COST:
			 begin
					if(counter == 4) counter <= 0; 
					else counter <= counter + 1;
			 end
			default:
			begin 
                counter <= 0; 
                counter2 <= 0; 
                cost <= 0; 
            end
		endcase
	end 
end	

//sequential part- outputs____________________________________
always @(posedge clk or posedge rst) //for output 
begin
    if(rst) 
	 begin
		statusMsg <= {8{8'd32}};
		sentMsg  <= {8{8'd32}};
	 end
    else
    begin
        case (cState)
            IDLE:
              begin
                    statusMsg[63:32] <= {4{32}};
                    statusMsg[31:24]<= 73;
                    statusMsg[23:16]<= 68;
                    statusMsg[15:8]<= 76;
                    statusMsg[7:0]<= 69;
                    sentMsg <= {8{32}};
              end
            RINGING:
              begin
                    statusMsg[7:0]<=32;
                    statusMsg[15:8]<=71;
                    statusMsg[23:16]<=78;
                    statusMsg[31:24]<=73;
                    statusMsg[39:32]<=71;
                    statusMsg[47:40]<=78;
                    statusMsg[55:48]<=73;
                    statusMsg[63:56]<=82;
              end
            REJECTED:
              begin
                    statusMsg[7:0]<= 68;
                    statusMsg[15:8]<= 69;
                    statusMsg[23:16]<= 84;
                    statusMsg[31:24]<= 67;
                    statusMsg[39:32]<= 69;
                    statusMsg[47:40]<= 74;
                    statusMsg[55:48]<= 69;
                    statusMsg[63:56]<= 82;
              end
            BUSY:
              begin
                    statusMsg[63:32] <= {4{32}};
                    statusMsg[31:24]<= 66;
                    statusMsg[23:16]<= 85;
                    statusMsg[15:8]<= 83;
                    statusMsg[7:0]<= 89;
              end
            CALL:
              begin
                statusMsg[7:0]<=76;
                statusMsg[15:8]<=76;
                statusMsg[23:16]<=65;
                statusMsg[31:24]<=67;
                statusMsg[63:32] <= {4{32}};
                if (endCall == 0 && sendChar == 1)
                begin 
                    if (32<=charSent && charSent<127 && endCall == 0)
                      begin
                        sentMsg[7:0]<=charSent;
                        sentMsg[15:8]<=sentMsg[7:0];
                        sentMsg[23:16]<=sentMsg[15:8];
                        sentMsg[31:24]<=sentMsg[23:16];
                        sentMsg[39:32]<=sentMsg[31:24];
                        sentMsg[47:40]<=sentMsg[39:32];
                        sentMsg[55:48]<=sentMsg[47:40];
                        sentMsg[63:56]<=sentMsg[55:48];
                      end
                    else if (charSent == 127 || endCall == 1) 
                       sentMsg <= {8{32}};
                end
               end
            COST:
              begin
                statusMsg[63:32] <= {4{32}};
                statusMsg[31:24]<=67;
                statusMsg[23:16]<=79;
                statusMsg[15:8]<=83;
                statusMsg[7:0]<=87;

                if(cost[3:0] >= 0 && cost[3:0] <= 9) sentMsg[7:0] <= 48 + cost[3:0];
                else sentMsg[7:0] <= 55 + cost[3:0];
                
                if(cost[7:4] >= 0 && cost[7:4] <= 9) sentMsg[15:8] <= 48 + cost[7:4];
                else sentMsg[15:8] <= 55 + cost[7:4];

                if(cost[11:8] >= 0 && cost[11:8] <= 9) sentMsg[23:16] <= 48 + cost[11:8];
                else sentMsg[23:16] <= 55 + cost[11:8];                                       
                
                if(cost[15:12] >= 0 && cost[15:12] <= 9) sentMsg[31:24] <= 48 + cost[15:12];
                else sentMsg[31:24] <= 55 + cost[15:12];

                if(cost[19:16] >= 0 && cost[19:16] <= 9) sentMsg[39:32] <= 48 + cost[19:16];
                else sentMsg[39:32] <= 55 + cost[19:16];                                       

                if(cost[23:20] >= 0 && cost[23:20] <= 9) sentMsg[47:40] <= 48 + cost[23:20];
                else sentMsg[47:40] <= 55 + cost[23:20];
                
                if(cost[27:24] >= 0 && cost[27:24] <= 9) sentMsg[55:48] <= 48 + cost[27:24];
                else sentMsg[55:48] <= 55 + cost[27:24];                                
                
                if(cost[31:28] >= 0 && cost[31:28] <= 9) sentMsg[63:56] <= 48 + cost[31:28];
                else sentMsg[63:56] <= 55 + cost[31:28];

            end
            default: begin statusMsg <= {8{32}}; sentMsg <= {8{32}}; end                    
            endcase
    end
end

endmodule
