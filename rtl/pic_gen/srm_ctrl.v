//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  srm_ctrl.v
// Module name   :  srm_ctrl
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  SDRAM read/write control
// Called by     :  pic_gen
//
// ----------------------------------------------------------------------------
// Revison
// 2013-12-3    :  create file
//*****************************************************************************
module srm_ctrl (
    input                 clk               ,
    input                 rst_n             ,
    input       [4:0]     pic_wr_num        ,
    input       [15:0]    pic_bst_num       ,
    input       [4:0]     pic_size_rsv      ,
    input       [4:0]     pic_num           ,  //display picture number
    input                 pic_fifo_aempty   ,  //almost empty of NAND Flash output buffer fifo
    input                 dis_fifo_afull    ,  //almost full of display fifo (stroe RGB data)
    output reg            srm_op_req        ,  //SDRAM operation request
    input                 srm_op_ack        ,  //SDRAM operation acknowledge
    output reg            srm_op            ,  //SDRAM operation: 1'b1 - write; 1'b0 - read
    output reg  [23:0]    srm_op_addr       ,  //start address of SDRAM operation. Format: {bank[1:0], row[12:0], column[8:0]}
    output reg            srm_op_eof           //current burst corresponds to end of frame
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter       OP_IDLE             = 2'b00                     ;
parameter       OP_WR               = 2'b01                     ;
parameter       OP_RD               = 2'b10                     ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg     [4:0]                   srm_wr_pic_cnt                  ;  //counter for pictures that has been written into SDRAM
reg                             srm_wr_end                      ;  //all picture data has been written into SDRAM
reg     [14:0]                  srm_rd_saddr                    ;  //start address for reading SDRAM
reg     [14:0]                  srm_rd_saddr_lat                ;  //latched strat address for reading SDRAM
reg     [14:0]                  srm_wr_saddr                    ;  //start address for writing SDRAM

reg     [1:0]                   cs_srm_ctrl                     ;  //FSM current state
reg     [1:0]                   ns_srm_ctrl                     ;  //FSM next state
reg     [14:0]                  srm_rd_addr                     ;
reg     [14:0]                  srm_wr_addr                     ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//-----------------------------------------------------------------------------
// SDRAM: (2 ^ 13) rows * (2 ^ 9) columns * 4 banks * 16 bits = 256Mbits = 32M Bytes
// Pictures are stored in 2 SDRAM chips.
// 6MBytes is reserved for each picture, each SDRAM stores 3MBytes.
// Full page burst: read all columns, contains (512 * 16) = 1024 Bytes
//
// generate start adress according to the picture number.
// srm_rd_saddr = pic_size_rsv * (picture number)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        srm_rd_saddr <= 15'b0;
    end
    else
    begin
        if (pic_num >= pic_wr_num)
        begin
            srm_rd_saddr <= 15'b0;
        end  
		  else
		  begin
			  srm_rd_saddr <= pic_num * pic_bst_num;
		  end
    end
end

//-----------------------------------------------------------------------------
//FSM
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        cs_srm_ctrl <= OP_IDLE;
    end
    else
    begin
        cs_srm_ctrl <= ns_srm_ctrl;
    end
end

always @(*)
begin
    case(cs_srm_ctrl)
        OP_IDLE:
        begin
            if (srm_op_ack == 1'b0)
            begin
                ns_srm_ctrl = OP_IDLE;
            end
            else if ((srm_wr_end == 1'b0) && (pic_fifo_aempty == 1'b0))
            begin
                ns_srm_ctrl = OP_WR;
            end
            else if ((srm_wr_end == 1'b1) && (dis_fifo_afull == 1'b0))
            begin
                ns_srm_ctrl = OP_RD;
            end
            else
            begin
                ns_srm_ctrl = OP_IDLE;
            end
        end
        OP_WR:
        begin
            if (srm_op_ack == 1'b0)
            begin
                ns_srm_ctrl = OP_IDLE;
            end
            else
            begin
                ns_srm_ctrl = OP_WR;
            end
        end
        OP_RD:
        begin
            if (srm_op_ack == 1'b0)
            begin
                ns_srm_ctrl = OP_IDLE;
            end
            else
            begin
                ns_srm_ctrl = OP_RD;
            end
        end
        default:
        begin
            ns_srm_ctrl = OP_IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        srm_op_req       <= 1'b0;
        srm_op           <= 1'b0;
        srm_op_addr      <= 24'b0;
        srm_rd_saddr_lat <= 15'b0;
        srm_rd_addr      <= 15'b0;
        srm_wr_saddr     <= 15'b0;
        srm_wr_addr      <= 15'b0;

        srm_wr_pic_cnt   <= 5'b0;
        srm_wr_end       <= 1'b0;
        srm_op_eof       <= 1'b1;
    end
    else
    begin
        case(cs_srm_ctrl)
            OP_IDLE:
            begin
                srm_op_req    <= 1'b0;
                srm_op        <= 1'b0;
                srm_op_addr   <= srm_op_addr;
                if (srm_op_eof == 1'b1)
                begin
                    srm_rd_addr      <= srm_rd_saddr_lat;
                    srm_rd_saddr_lat <= srm_rd_saddr;
                end
            end
            OP_WR:
            begin
                srm_op_req   <= 1'b1;
                srm_op       <= 1'b1;
                srm_op_addr  <= {srm_wr_addr[14:0], 9'b0};
                if (srm_op_ack == 1'b0)
                begin
                    if (srm_wr_addr == (srm_wr_saddr + pic_bst_num - 15'd1))
                    begin
								srm_wr_addr <= srm_wr_saddr + pic_bst_num;  //jump to start address of next picture
                        srm_wr_saddr <= srm_wr_saddr + pic_bst_num;
                        srm_wr_pic_cnt <= srm_wr_pic_cnt + 5'b1;
                        if (srm_wr_pic_cnt == pic_wr_num - 5'd1)
                        begin
                            srm_wr_end <= 1'b1;
                        end
                    end
                    else
                    begin
                        srm_wr_addr <= srm_wr_addr + 15'b1;
                    end
                end
            end
            OP_RD:
            begin
                srm_op_req   <= 1'b1;
                srm_op       <= 1'b0;
                srm_op_addr  <= {srm_rd_addr[14:0], 9'b0};
                if (srm_op_ack == 1'b0)
                begin
                    if ((srm_rd_addr == (srm_rd_saddr_lat + pic_bst_num - 15'b1)))
                    begin
                        srm_op_eof <= 1'b1;
                    end
                    else
                    begin
                        srm_rd_addr <= srm_rd_addr + 15'b1;
                        srm_op_eof  <= 1'b0;
                    end
                end
            end
            default:
            begin
                srm_op_req  <= 1'b0;
                srm_op      <= 1'b0;
                srm_op_addr <= 24'b0;
                srm_rd_addr <= 15'b0;
                srm_wr_addr <= 15'b0;
            end
        endcase
    end
end

endmodule