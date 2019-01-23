//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  smonitor.v
// Module name   :  smonitor
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  monitor using serial port
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2014-04-18    :  create file
//*****************************************************************************
module smonitor(
    input                 mon_clk           ,
    input                 mon_rst_n         ,
    input                 mon_vld           ,
    input       [31:0]    mon_data          ,
    input                 s_clk             ,
    input                 s_rst_n           ,
    output                txd
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//FSM
parameter       DIVBAUD                     = 16'd234           ;
parameter       BITNUM                      = 4'd10             ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg     [15:0]                  mon_data_cnt                    ;
reg                             sel_vld                         ;
reg     [31:0]                  sel_data                        ;

wire                            s_rdreq                         ;
reg                             s_rdreq_d1                      ;
wire    [31:0]                  s_rddata                        ;
wire                            s_rdempty                       ;
reg                             tx_busy                         ;

reg                             tx_req                          ;
reg     [31:0]                  tx_data                         ;
wire                            tx_ack                          ;

reg     [2:0]                   cnt_byte                        ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign s_rdreq = (tx_busy == 1'b0) && (s_rdempty == 1'b0);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
dcfifow32_mon u_dcfifow32_mon(
    .aclr                       ( ~ mon_rst_n                   ),
    .data                       ( sel_data                      ),
    .rdclk                      ( s_clk                         ),
    .rdreq                      ( s_rdreq                       ),
    .wrclk                      ( mon_clk                       ),
    .wrreq                      ( sel_vld                       ),
    .q                          ( s_rddata                      ),
    .rdempty                    ( s_rdempty                     )
);

stx #(
    .DIVBAUD                    ( DIVBAUD                       ),
    .BITNUM                     ( BITNUM                        )
) u_stx(
    .clk                        ( s_clk                         ),  //input                 
    .rst_n                      ( s_rst_n                       ),  //input                 
    .tx_req                     ( tx_req                        ),  //input                 
    .tx_data                    ( tx_data                       ),  //input       [7:0]     
    .tx_ack                     ( tx_ack                        ),  //output
    .txd                        ( txd                           )   //output reg
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//-----------------------------------------------------------------------------
// only capture first 256 data
//-----------------------------------------------------------------------------
always @(posedge mon_clk or negedge mon_rst_n)
begin
    if (mon_rst_n == 1'b0)
    begin
        mon_data_cnt <= 16'd0;
    end
    else
    begin
        if (mon_vld == 1'b1)
        begin
            if (mon_data_cnt == 16'd1023)
            begin
                mon_data_cnt <= 16'd1023;
            end
            else
            begin
                mon_data_cnt <= mon_data_cnt + 16'd1;
            end
        end
    end
end

always @(posedge mon_clk or negedge mon_rst_n)
begin
    if (mon_rst_n == 1'b0)
    begin
        sel_vld <= 1'b0;
        sel_data <= 32'b0;
    end
    else
    begin
        if (mon_data_cnt < 16'd1000)
        begin
            sel_vld <= mon_vld;
            sel_data <= mon_data;
//            case(mon_data_cnt[1:0])
//                2'b00:
//                begin
//                    sel_data <= {8'h11, 8'h22, 8'h33, 8'h44};
//                end
//                2'b01:
//                begin
//                    sel_data <= {8'h55, 8'h66, 8'h77, 8'h88};
//                end
//                2'b10:
//                begin
//                    sel_data <= {8'h99, 8'hAA, 8'hBB, 8'hCC};
//                end
//                2'b11:
//                begin
//                    sel_data <= {8'hDD, 8'hEE, 8'hFF, 8'h00};
//                end
//            endcase
        end
        else
        begin
            sel_vld <= 1'b0;
        end
    end
end

//32 bits need 4 transfer
//byte cunter for each 32 bits
always @(posedge s_clk or negedge s_rst_n)
begin
    if (s_rst_n == 1'b0)
    begin
        cnt_byte <= 3'd0;
    end
    else
    begin
        if (tx_ack == 1'b1)
        begin
            if (cnt_byte == 3'd3)
            begin
                cnt_byte <= 3'd0;
            end
            else
            begin
                cnt_byte <= cnt_byte + 3'd1;
            end
        end
    end
end

//s_rddata is 1 clock later than s_rdreq, sync with s_rdreq_d1
//s_rdreq ----> s_rdreq_d1
//              s_rddata
always @(posedge s_clk or negedge s_rst_n)
begin
    if (s_rst_n == 1'b0)
    begin
        s_rdreq_d1 <= 1'b0;
    end
    else
    begin
        s_rdreq_d1 <= s_rdreq;
    end
end

always @(posedge s_clk or negedge s_rst_n)
begin
    if (s_rst_n == 1'b0)
    begin
        tx_busy <= 1'b0;
    end
    else
    begin
        if ((tx_ack == 1'b1) && (cnt_byte == 3'd3))  //all 4 bytes has been transmitted
        begin
            tx_busy <= 1'b0;
        end
        else if ((tx_busy == 1'b0) && (s_rdempty == 1'b0))
        begin
            tx_busy <= 1'b1;
        end
    end
end

always @(posedge s_clk or negedge s_rst_n)
begin
    if (s_rst_n == 1'b0)
    begin
        tx_req <= 1'b0;
        tx_data <= 8'b0;
    end
    else
    begin
        if (s_rdreq_d1 == 1'b1)  //1st byte, after reading fifo
        begin
            tx_req <= 1'b1;
            tx_data <= s_rddata[31:24];
        end
        else if ((tx_ack == 1'b1) && (cnt_byte < 3'd3))  //1 bytes has been transmitted by rs232, there are bytes left to be transmitted
        begin
            tx_req <= 1'b1;
            case (cnt_byte)
                3'd0:
                begin
                    tx_data <= s_rddata[23:16];
                end
                3'd1:
                begin
                    tx_data <= s_rddata[15:8];
                end
                3'd2:
                begin
                    tx_data <= s_rddata[7:0];
                end
            endcase
        end
        else
        begin
            tx_req <= 1'b0;
        end
    end
end





endmodule