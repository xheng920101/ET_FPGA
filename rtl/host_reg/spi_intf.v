//*****************************************************************************
// COPYRIGHT (c) 2014, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  spi_intf.v
// Module name   :  spi_intf
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  SPI rx interface (as slave)
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2014-07-25    :  create file
//*****************************************************************************
module spi_intf (
    input                 clk               ,
    input                 rst_n             ,
    input                 arm_scs           ,
    input                 arm_sck           ,
    input                 arm_sdi           ,
    output reg		        arm_sdo           ,
    output reg            rx_vld            ,
    output reg  [7:0]     rx_data			  ,
	 input		 [7:0]	  tx_data
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg                             arm_scs_d1                      ;
reg                             arm_scs_d2                      ;
reg                             arm_sck_d1                      ;
reg                             arm_sck_d2                      ;
reg                             arm_sck_d3                      ;
reg                             arm_sdi_d1                      ;
reg                             arm_sdi_d2                      ;

wire                            rflag_arm_sck                   ;

reg     [2:0]                   cnt_rx_bit                      ;
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign rflag_arm_sck = (arm_sck_d2 == 1'b1) && (arm_sck_d3 == 1'b0);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
always @(posedge clk)
begin
    arm_scs_d1 <= arm_scs;
    arm_scs_d2 <= arm_scs_d1;
    arm_sck_d1 <= arm_sck;
    arm_sck_d2 <= arm_sck_d1;
    arm_sck_d3 <= arm_sck_d2;
    arm_sdi_d1 <= arm_sdi;
    arm_sdi_d2 <= arm_sdi_d1;
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        rx_vld <= 1'b0;
        rx_data <= 8'b0;
        cnt_rx_bit <= 3'b0;
		  arm_sdo <= 1'b0;
    end
    else
    begin
        if (arm_scs_d2 == 1'b0)
        begin
            if (rflag_arm_sck == 1'b1)  //sample data at rising edge of arm_sck
            begin
                rx_data <= {rx_data[6:0], arm_sdi_d2};
					 arm_sdo <= tx_data[3'd7 - cnt_rx_bit];
                if (cnt_rx_bit == 3'b111)  //has received 8 bits
                begin
                    rx_vld <= 1'b1;
                    cnt_rx_bit <= 3'b0;
                end
                else
                begin
                    rx_vld <= 1'b0;
                    cnt_rx_bit <= cnt_rx_bit + 3'b1;
                end
            end
            else
            begin
                rx_vld <= 1'b0;
            end
        end
        else
        begin
            rx_vld <= 1'b0;
            cnt_rx_bit <= 3'b0;
        end
    end
end

endmodule