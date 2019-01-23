//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  rtr.v
// Module name   :  rtr
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  data width trans(96 bits -> 24 bits), latency is 2 clock
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2012-05-29    :  create file
//*****************************************************************************

module rtr(
    input                 clk               ,
    input                 rst_n             ,
    input                 rd                ,
    output reg  [23:0]    data              ,
    output                trrd              ,
    input       [95:0]    trdata
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg     [1:0]                   rd_cnt                          ;
reg     [1:0]                   rd_cnt_d1                       ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign trrd = ((rd == 1'b1) && (rd_cnt == 2'b00));

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        rd_cnt <= 2'b00;
    end
    else
    begin
        if (rd == 1'b1)
        begin
            rd_cnt <= rd_cnt + 2'b01;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        rd_cnt_d1 <= 2'b00;
    end
    else
    begin
        rd_cnt_d1 <= rd_cnt;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        data <= 24'b0;
    end
    else
    begin
        case (rd_cnt_d1[1:0])
            2'b00:
            begin
                data <= {trdata[79:72], trdata[87:80], trdata[95:88]};
            end
            2'b01:
            begin
                data <= {trdata[55:48], trdata[63:56], trdata[71:64]};
            end
            2'b10:
            begin
                data <= {trdata[31:24], trdata[39:32], trdata[47:40]};
            end
            2'b11:
            begin
                data <= {trdata[7:0], trdata[15:8], trdata[23:16]};
            end
        endcase
    end
end

endmodule