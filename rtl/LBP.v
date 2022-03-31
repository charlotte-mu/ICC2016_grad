/******************************************************************/
//MODULE:       LBP
//FILE NAME:    LBP.v
//VERSION:		1.0
//DATE:			March,2019
//AUTHOR: 		charlotte-mu
//CODE TYPE:	RTL
//DESCRIPTION:	2016 IC Design Contest Preliminary
//
//MODIFICATION HISTORY:
// VERSION Date Description
// 1.0 03/11/2019 test pattern all pass
/******************************************************************/
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output reg [13:0] 	gray_addr;
output  reg       	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  [13:0] 	lbp_addr;
output reg 	lbp_valid;
output  [7:0] 	lbp_data;
output reg  	finish;
//====================================================================
reg [6:0]x,y,x_next,y_next;
reg [3:0]fsm,fsm_next;
reg [7:0]data_in[7:0],data_out[7:0];
reg [7:0]data_in_central;
reg data_in_en,data_out_en,data_move_en,data_movein_en;
reg [3:0]conter,conter_next;

assign lbp_addr = {y,x};
assign lbp_data = (data_out[0]|data_out[1]|
						 data_out[2]|data_out[3]|
						 data_out[4]|data_out[5]|
						 data_out[6]|data_out[7]);

always@(posedge clk,posedge reset)
begin
	if(reset)
	begin
		x <= 7'd126;
		y <= 7'd0;
		fsm <= 4'd2;
		conter <= 4'd1;
		data_in[0] <= 8'd0;
		data_in[1] <= 8'd0;
		data_in[2] <= 8'd0;
		data_in[3] <= 8'd0;
		data_in_central <= 8'd0;
		data_in[4] <= 8'd0;
		data_in[5] <= 8'd0;
		data_in[6] <= 8'd0;
		data_in[7] <= 8'd0;
		data_out[0] <= 8'd0;
		data_out[1] <= 8'd0;
		data_out[2] <= 8'd0;
		data_out[3] <= 8'd0;
		data_out[4] <= 8'd0;
		data_out[5] <= 8'd0;
		data_out[6] <= 8'd0;
		data_out[7] <= 8'd0;
	end
	else
	begin
		x <= x_next;
		y <= y_next;
		fsm <= fsm_next;
		conter <= conter_next;
		if(data_in_en)
		begin
			data_in[0] <= data_in[1];
			data_in[1] <= data_in[2];
			data_in[2] <= data_in[3];
			data_in[3] <= data_in_central;
			data_in_central <= data_in[4];
			data_in[4] <= data_in[5];
			data_in[5] <= data_in[6];
			data_in[6] <= data_in[7];
			data_in[7] <= gray_data;
		end
		if(data_movein_en)
		begin
			data_in[2] <= data_in[4];
			data_in[4] <= data_in[7];
			data_in[7] <= gray_data;
		end
		if(data_out_en)
		begin
			data_out[0] <= (data_in_central <= data_in[0])? 8'd1 : 8'd0;
			data_out[1] <= (data_in_central <= data_in[1])? 8'd2 : 8'd0;
			data_out[2] <= (data_in_central <= data_in[2])? 8'd4 : 8'd0;
			data_out[3] <= (data_in_central <= data_in[3])? 8'd8 : 8'd0;
			data_out[4] <= (data_in_central <= data_in[4])? 8'd16 : 8'd0;
			data_out[5] <= (data_in_central <= data_in[5])? 8'd32 : 8'd0;
			data_out[6] <= (data_in_central <= data_in[6])? 8'd64 : 8'd0;
			data_out[7] <= (data_in_central <= data_in[7])? 8'd128 : 8'd0;
		end
		if(data_move_en)
		begin
			data_in[0] <= data_in[1];
			data_in[1] <= data_in[2];
			data_in[3] <= data_in_central;
			data_in[5] <= data_in[6];
			data_in[6] <= data_in[7];
			data_in_central <= data_in[4];
		end
		
	end
end

always@(*)
begin
	case(fsm)
		4'd0:
		begin
			finish = 1'b0;
			x_next = x;
			y_next = y;
			lbp_valid = 1'b0;
			data_move_en = 1'b0;
			data_movein_en = 1'b0;
			gray_req = 1'b1;
			data_in_en = 1'b1;
			data_out_en = 1'b0;
			if(conter == 4'd9)
			begin
				conter_next = 4'd1;
				fsm_next = 4'd1;
				//data_in_en = 1'b0;
				//gray_req = 1'b0;
				//data_out_en = 1'b1;
			end
			else
			begin
				//gray_req = 1'b1;
				//data_in_en = 1'b1;
				conter_next = conter + 4'd1;
				fsm_next = fsm;
				//data_out_en = 1'b0;
			end
		end
		4'd1:
		begin
			data_out_en = 1'b1;
			gray_req = 1'b0;
			data_in_en = 1'b0;
			conter_next = conter;
			lbp_valid = 1'b0;
			fsm_next = 4'd2;
			x_next = x;
			y_next = y;
			data_move_en = 1'b1;
			data_movein_en = 1'b0;
			finish = 1'b0;
		end
		4'd2:
		begin
			data_out_en = 1'b0;
			gray_req = 1'b0;
			data_movein_en = 1'b0;
			data_in_en = 1'b0;
			if(x == 7'd126 && y == 7'd126)
			begin
				x_next = x;
				y_next = y;
				fsm_next = 4'd4;
				finish = 1'b1;
				conter_next = 4'd1;
				//data_movein_en = 1'b0;
				//data_in_en = 1'b0;
				//gray_req = 1'b0;
			end
			else if(x == 7'd126)
			begin
				x_next = 7'd1;
				y_next = y + 7'd1;
				fsm_next = 4'd0;
				finish = 1'b0;
				conter_next = 4'd1;
				//data_movein_en = 1'b0;
				//data_in_en = 1'b1;
				//gray_req = 1'b1;
			end
			else
			begin
				x_next = x + 7'd1;
				y_next = y;
				fsm_next = 4'd3;
				finish = 1'b0;
				conter_next = 4'd10;
				//data_movein_en = 1'b1;
				//data_in_en = 1'b0;
				//gray_req = 1'b1;
			end
			lbp_valid = 1'b1;
			data_move_en = 1'b0;
		end
		4'd3:
		begin
			finish = 1'b0;
			x_next = x;
			y_next = y;
			lbp_valid = 1'b0;
			data_move_en = 1'b0;
			data_in_en = 1'b0;
			gray_req = 1'b1;
			data_movein_en = 1'b1;
			data_out_en = 1'b0;
			if(conter == 4'd12)
			begin
				conter_next = 4'd1;
				//data_movein_en = 1'b0;
				//gray_req = 1'b0;
				fsm_next = 4'd1;
				//data_out_en = 1'b1;
			end
			else
			begin
				//data_movein_en = 1'b1;
				//gray_req = 1'b1;
				conter_next = conter + 4'd1;
				fsm_next = fsm;
				//data_out_en = 1'b0;
			end
		end
		4'd4:
		begin
			finish = 1'b1;
			data_movein_en = 1'b0;
			data_move_en = 1'b0;
			data_out_en = 1'b0;
			gray_req = 1'b0;
			conter_next = 4'd1;
			fsm_next = fsm;
			data_in_en = 1'b0;
			x_next = x;
			y_next = y;
			lbp_valid = 1'b0;
		end
		default:
		begin
			finish = 1'b0;
			data_movein_en = 1'b0;
			data_move_en = 1'b0;
			data_out_en = 1'b0;
			gray_req = 1'b0;
			conter_next = 4'd1;
			fsm_next = 4'd0;
			data_in_en = 1'b0;
			x_next = x;
			y_next = y;
			lbp_valid = 1'b0;
		end
	endcase
end

always@(conter,x,y)
begin
	case(conter)
		4'd1:
		begin
			gray_addr = {y-7'd1,x-7'd1};
		end
		4'd2:
		begin
			gray_addr = {y-7'd1,x};
		end
		4'd3:
		begin
			gray_addr = {y-7'd1,x+7'd1};
		end
		4'd4:
		begin
			gray_addr = {y,x-7'd1};
		end
		4'd5:
		begin
			gray_addr = {y,x};
		end
		4'd6:
		begin
			gray_addr = {y,x+7'd1};
		end
		4'd7:
		begin
			gray_addr = {y+7'd1,x-7'd1};
		end
		4'd8:
		begin
			gray_addr = {y+7'd1,x};
		end
		4'd9:
		begin
			gray_addr = {y+7'd1,x+7'd1};
		end
		4'd10:
		begin
			gray_addr = {y-7'd1,x+7'd1};
		end
		4'd11:
		begin
			gray_addr = {y,x+7'd1};
		end
		4'd12:
		begin
			gray_addr = {y+7'd1,x+7'd1};
		end
		default:
		begin
			gray_addr = 14'd0;
		end
	endcase
end



//====================================================================
endmodule
