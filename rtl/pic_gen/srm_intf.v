//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  srm_intf.v
// Module name   :  srm_intf
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  SDRAM interfacing control
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2012-05-29    :  create file
//*****************************************************************************
module srm_intf (
    input                 clk               ,
    input                 rst_n             ,

    input                 srm_op_req        ,
    output                srm_op_ack        ,
    input                 srm_op            ,
    input       [23:0]    srm_op_addr       ,
    input                 srm_op_eof        ,

    output      [2:0]     srm_cs_n          ,
    output                srm_cke           ,
    output                srm_cas_n         ,
    output                srm_ras_n         ,
    output                srm_we_n          ,
    output      [1:0]     srm_ba            ,
    output      [12:0]    srm_addr          ,
    input       [15:0]    srm_din_a         ,
    input       [15:0]    srm_din_b         ,
    input       [15:0]    srm_din_c         ,
    output      [15:0]    srm_dout_a        ,
    output      [15:0]    srm_dout_b        ,
    output      [15:0]    srm_dout_c        ,
    output                srm_dir           ,

    output                pic_fifo_rd       ,
    input       [47:0]    pic_fifo_rdata    ,
    output reg            dis_fifo_wr       ,
    output reg  [47:0]    dis_fifo_wdata	  ,
	 input       [9:0]     pic_last_bst_num      
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// sdram operation related
parameter       OPCODE              = 8'b0                      ;	 //write mode = burst read and burst write
parameter       CAS                 = 3'b011                    ;  //CAS lantency = 3
parameter       BT                  = 1'b0                      ;  //burst type = sequential
parameter       BURSTLEN            = 3'b111                    ;  //burst length. 3'b111 - full page
parameter       NOP                 = 4'b1111                   ;
parameter       BSTSTOP             = 4'b1110                   ;

parameter       INITDELAY200u       = 4'b0000                   ;
parameter       INITPRECHARGE       = 4'b0001                   ;
parameter       INITREFRESH         = 4'b0010                   ;
parameter       INITSETMRS          = 4'b0100                   ;
parameter       INITIDLE            = 4'b1000                   ;


parameter       IDLE                = 10'b00_0000_0000          ;
parameter       REFRESHDELAY        = 10'b00_0000_0001          ;
parameter       ROWACTIVE           = 10'b00_0000_0010          ;
parameter       ROWACTIVEDELAY      = 10'b00_0000_0100          ;
parameter       READ                = 10'b00_0000_1000          ;
parameter       WRITE               = 10'b00_0001_0000          ;
parameter       READDELAY           = 10'b00_0010_0000          ;
parameter       WRITEDELAY          = 10'b00_0100_0000          ;
parameter       PRECHARGE           = 10'b00_1000_0000          ;
parameter       PRECHARGEDELAY      = 10'b01_0000_0000          ;
parameter       REFRESH             = 10'b10_0000_0000          ;

parameter       RD_LAG              = 10'd4                     ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire                            trig_op_dly                     ;
wire                            trig_init_dly                   ;
wire                            trig_init_pch                   ;
wire                            trig_init_ref                   ;

reg     [1:0]                   init_cs                         ;
reg                             init_cke                        ;
reg                             init_cas_n                      ;
reg                             init_ras_n                      ;
reg                             init_we_n                       ;
reg     [1:0]                   init_ba                         ;
reg     [12:0]                  init_addr                       ;

reg     [2:0]                   op_cs                           ;
reg                             op_cke                          ;
reg                             op_cas_n                        ;
reg                             op_ras_n                        ;
reg                             op_we_n                         ;
reg     [1:0]                   op_ba                           ;
reg     [12:0]                  op_addr                         ;

reg     [3:0]                   cs_init                         ;
reg     [3:0]                   ns_init                         ;
reg     [15:0]                  cnt_init_dly                    ;
reg                             end_init_dly                    ;
reg     [2:0]                   cnt_init_pch                    ;
reg                             end_init_pch                    ;
reg     [6:0]                   cnt_init_ref                    ;
reg                             end_init_ref                    ;
reg                             end_srm_init                    ;
reg     [1:0]                   cnt_init_mrs_dly                ;

//(* syn_encoding = "safe" *) reg [9:0]  cs_op,ns_op;
reg     [9:0]                   cs_op                           ;
reg     [9:0]                   ns_op                           ;
reg     [23:0]                  srm_op_addr_lat                 ;
reg                             srm_op_lat                      ;
reg     [9:0]                   cnt_op_dly                      ;
reg                             srm_op_eob_lat                  ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign trig_init_dly = (cs_init == INITDELAY200u )? 1'b1 :1'b0;
assign trig_init_pch = (cs_init == INITPRECHARGE )? 1'b1 :1'b0;
assign trig_init_ref = (cs_init == INITREFRESH   )? 1'b1 :1'b0;

assign trig_op_dly = (cs_op == REFRESHDELAY) || (cs_op == ROWACTIVEDELAY)
    || (cs_op==WRITEDELAY) || (cs_op == READDELAY) || (cs_op == PRECHARGEDELAY);

assign srm_op_ack = (end_srm_init == 1'b1) && ((cs_op == IDLE)
    || (cs_op == REFRESH) || (cs_op == REFRESHDELAY) || (cs_op == PRECHARGEDELAY));

assign {srm_cs_n, srm_cke, srm_cas_n, srm_ras_n, srm_we_n, srm_ba, srm_addr}
    = end_srm_init ? {op_cs, op_cke, op_cas_n, op_ras_n, op_we_n, op_ba, op_addr}
    : {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n, init_ba, init_addr};

assign {srm_dout_a, srm_dout_b, srm_dout_c} = (end_srm_init == 1'b1) ? pic_fifo_rdata : 48'hffffffff;
assign srm_dir = (cs_op == WRITE) || (cs_op == WRITEDELAY);
assign pic_fifo_rd = (ns_op == WRITEDELAY) && (cnt_op_dly <= 10'd510);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//init FSM
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cs_init <= INITDELAY200u;
    end
    else
    begin
        cs_init <= ns_init;
    end
end

always @(*)
begin
    case(cs_init)
        INITDELAY200u:
        begin
            if (end_init_dly == 1'b1)
            begin
                ns_init = INITPRECHARGE;
            end
            else
            begin
                ns_init = INITDELAY200u;
            end
        end
        INITPRECHARGE:  //wDelay tRp
        begin
            if (end_init_pch == 1'b1)
            begin
                ns_init = INITREFRESH;
            end
            else
            begin
                ns_init = INITPRECHARGE;
            end
        end

        INITREFRESH:  //wDelay tRc
        begin
            if (end_init_ref == 1'b1)
            begin
                ns_init = INITSETMRS;
            end
            else
            begin
                ns_init = INITREFRESH;
            end
        end
        INITSETMRS:
        begin
            ns_init = INITIDLE;
        end
        INITIDLE:
        begin
            ns_init = INITIDLE;
        end
        default:
        begin
            ns_init = INITDELAY200u;
        end
    endcase
end

always @(posedge clk or negedge rst_n)  //delay at least 200us
begin
    if(rst_n == 1'b0)
    begin
        cnt_init_dly <= 16'b0;
        end_init_dly <= 1'b0;
    end
    else if (trig_init_dly == 1'b1)
    begin
        if (cnt_init_dly[15] == 1'b1)
        begin
            cnt_init_dly <= cnt_init_dly;
            end_init_dly <= 1'b1;
        end
        else
        begin
            cnt_init_dly <= cnt_init_dly + 16'b1;
            end_init_dly <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)  //Precharge
begin
    if (rst_n == 1'b0)
    begin
        cnt_init_pch <= 3'b0;
        end_init_pch <= 1'b0;
    end
    else if (trig_init_pch == 1'b1)
    begin
        if(cnt_init_pch[2] == 1'b1)	//tRP = 5clk	:Row Precharge command Period锛岃棰勫厖鐢垫湁鏁堝懆鏈
        begin
            cnt_init_pch <= cnt_init_pch;
            end_init_pch <= 1'b1;
        end
        else
        begin
            cnt_init_pch <= cnt_init_pch + 3'b1;
            end_init_pch <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) //8锟斤拷刷锟斤拷锟斤拷锟斤拷 tRc=9(为锟斤拷锟斤拷FPGA锟斤拷取锟斤拷锟斤拷16)  8*9
begin
    if(rst_n == 1'b0)
    begin
        cnt_init_ref <= 0;
        end_init_ref <= 0;
    end
    else if (trig_init_ref == 1'b1)
    begin
        if(cnt_init_ref == 7'h7f)	//tRC = 128clk 	:RAS cycle time
        begin
            cnt_init_ref <= cnt_init_ref;
            end_init_ref <= 1'b1;
        end
        else
        begin
            cnt_init_ref <= cnt_init_ref + 7'b1;
            end_init_ref <= 1'b0;
        end
    end
    else
    begin
        cnt_init_ref <= 0;
        end_init_ref <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n} 
            <= {2'b11, 1'b1, 1'b1, 1'b1, 1'b1};	//Device deselect
    end
    else
    begin
        case (cs_init[3:0])
            INITDELAY200u:
            begin
                {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                    <={2'b0, 1'b1, 1'b1, 1'b1, 1'b1};	//NOP
            end
            INITPRECHARGE:
            begin
                if (cnt_init_pch == 3'b0)
                begin
                    {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                        <={2'b0, 1'b1, 1'b1, 1'b0, 1'b0};	//Precharge All Bank
                end
                else
                begin
                    {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                        <={2'b0, 1'b1, 1'b1, 1'b1, 1'b1};	//NOP
                end
            end
            INITREFRESH:
            begin
                if (cnt_init_ref[3:0] == 4'b0)
                begin
                    {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                        <={2'b0, 1'b1, 1'b0, 1'b0, 1'b1};	//Auto Refresh
                end
                else
                begin
                    {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                        <={2'b0, 1'b1, 1'b1, 1'b1, 1'b1};	//NOP
                end
            end
            INITSETMRS:
            begin
                {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                    <={2'b0,1'b1,1'b0,1'b0,1'b0};	//Mode Register Set
            end
            INITIDLE:
            begin
                {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                    <={2'b0, 1'b1, 1'b1, 1'b1, 1'b1};	//NOP
            end
            default:
            begin
                {init_cs, init_cke, init_cas_n, init_ras_n, init_we_n}
                    <= {2'b11, 1'b1, 1'b1, 1'b1, 1'b1};
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        {init_ba, init_addr} <= 15'h7fff;
    end
    else if (cs_init == INITSETMRS)	//Mode Register Set
    begin
        {init_ba, init_addr} <= {OPCODE, CAS, BT, BURSTLEN};
    end
    else
    begin
        {init_ba, init_addr} <= 15'h7fff;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        end_srm_init     <= 1'b0;
        cnt_init_mrs_dly <= 2'b0;
    end
    else if (cs_init == INITIDLE)
    begin
        if(cnt_init_mrs_dly[1] == 1'b1)	//tMRS = 3clk	:MRS to new command
        begin
            end_srm_init <= 1'b1;
        end
        else
        begin
            cnt_init_mrs_dly  <= cnt_init_mrs_dly + 2'b1;
        end
    end
end

//operation FSM
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cs_op <= IDLE;
    end
    else
    begin
        cs_op <= ns_op;
    end
end

always @(*)
begin
    case (cs_op[9:0])
        IDLE: //锟斤拷停锟斤拷刷锟斤拷锟斤拷锟斤拷
        begin
            ns_op = REFRESH;
        end
        REFRESH:
        begin
            ns_op = REFRESHDELAY;
        end
        REFRESHDELAY:
        begin
            if(srm_op_req == 1'b0)	//no SDRAM operation request
            begin
                if (cnt_op_dly == 10'd8) //tRC=9 cnt_op_dly==4'h8
                begin
                    ns_op = REFRESH;
                end
                else
                begin
                    ns_op = REFRESHDELAY;
                end
            end
            else	//SDRAM operation request
            begin
                if (cnt_op_dly == 10'd8) //tRC=9
                begin
                    ns_op = ROWACTIVE;
                end
                else
                begin
                    ns_op = REFRESHDELAY;
                end
            end
        end
        ROWACTIVE:
        begin
            ns_op = ROWACTIVEDELAY;
        end
        ROWACTIVEDELAY:
        begin
            if (cnt_op_dly == 10'd1) //tRCD=3
            begin
                if (srm_op_lat == 1'b0)
                begin
                    ns_op = READ;
                end
                else
                begin
                    ns_op = WRITE;
                end
            end
            else
            begin
                ns_op = ROWACTIVEDELAY;
            end
        end
        READ:
        begin
            ns_op = READDELAY;
        end
        WRITE:
        begin
            ns_op = WRITEDELAY;
        end
        READDELAY:
        begin
           if (((srm_op_eob_lat == 1'b1) && (cnt_op_dly == (pic_last_bst_num - 10'd1 + RD_LAG)))  
			  || (cnt_op_dly == (10'd511 + RD_LAG)))
            begin
                ns_op = PRECHARGE;
            end
            else
            begin
                ns_op = READDELAY;
            end
        end
        WRITEDELAY:
        begin
            if (cnt_op_dly == 10'd511) //BURSTLEN=8+Precharge锟斤拷锟斤拷锟斤拷一锟斤拷 cnt_op_dly==4'h7
            begin
                ns_op = PRECHARGE;
            end
            else
            begin
                ns_op = WRITEDELAY;
            end
        end
        PRECHARGE:
        begin
            ns_op = PRECHARGEDELAY;
        end
        PRECHARGEDELAY:
        begin
            if (cnt_op_dly == 10'd2) //tRP=3
            begin
                ns_op = REFRESH;
            end
            else
            begin
                ns_op = PRECHARGEDELAY;
            end
        end
        default:
        begin
            ns_op = IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        {op_cke, op_ras_n, op_cas_n, op_we_n, op_ba} <= {NOP, 2'b11};
        op_cs           <= 3'b111;
        op_addr         <= 13'b0;
        srm_op_lat      <= 1'b0;
        srm_op_addr_lat <= 23'b0;
        srm_op_eob_lat  <= 1'b0;
    end
    else
    begin
        case (cs_op[9:0])
            IDLE:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n, op_ba} <= {NOP, 2'b0};
                op_cs           <= 3'b111;
                op_addr         <= 13'b0;
                srm_op_lat      <= srm_op;
                srm_op_addr_lat <= srm_op_addr[23:0];
            end
            REFRESH:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n} <= {1'b1, 1'b0, 1'b0, 1'b1};
                op_cs <= 3'b000;
            end
            REFRESHDELAY:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n, op_ba} <= {NOP, 2'b0};
                srm_op_lat      <= srm_op;
                srm_op_addr_lat <= srm_op_addr[23:0];
            end
            ROWACTIVE:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n, op_ba}
                    <={1'b1, 1'b0, 1'b1, 1'b1, srm_op_addr_lat[23:22]};
                op_addr <= srm_op_addr_lat[21:9];
            end
            ROWACTIVEDELAY:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n} <= NOP;
						srm_op_eob_lat <= srm_op_eof;	
            end
            READ:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n} <= {1'b1, 1'b1, 1'b0, 1'b1};
                op_addr[10]  <= 1'b0;
                op_addr[8:0] <= srm_op_addr_lat[8:0];
            end
            WRITE:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n} <= {1'b1, 1'b1, 1'b0, 1'b0};
                op_addr[10]  <= 1'b0;
                op_addr[8:0] <= srm_op_addr_lat[8:0];
            end
            READDELAY:
            begin
               if (((srm_op_eob_lat == 1'b1) && (cnt_op_dly == (pic_last_bst_num - 10'd1 + RD_LAG - 10'd2))) 
					|| (cnt_op_dly == (10'd511 + RD_LAG - 10'd2)))    
           		 begin
                    {op_cke, op_ras_n, op_cas_n, op_we_n} <= BSTSTOP;
                end
                else
                begin
                    {op_cke, op_ras_n, op_cas_n, op_we_n} <= NOP;
                end
            end
            WRITEDELAY:
            begin
                if (cnt_op_dly == 10'd511)
                begin
                    {op_cke, op_ras_n, op_cas_n, op_we_n} <= BSTSTOP;
                end
                else
                begin
                    {op_cke, op_ras_n, op_cas_n, op_we_n} <= NOP;
                end
            end
            PRECHARGE:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n} <= {1'b1, 1'b0, 1'b1, 1'b0};
                op_addr[10] <= 1'b1;
            end
            PRECHARGEDELAY:
            begin
                {op_cke, op_ras_n, op_cas_n, op_we_n, op_ba} <= {NOP, 2'b0};
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_op_dly <= 10'b0;
    end
    else if (trig_op_dly == 1'b1)
    begin
        cnt_op_dly <= cnt_op_dly + 10'b1;
    end
    else
    begin
        cnt_op_dly <= 10'b0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        dis_fifo_wr    <= 1'b0;
        dis_fifo_wdata <= 48'b0;
    end
    else if (cs_op == READDELAY)
    begin
        if (srm_op_eob_lat == 1'b1)
        begin
            if ((cnt_op_dly >= RD_LAG) && (cnt_op_dly <= (pic_last_bst_num - 10'd1 + RD_LAG)))
            begin
                dis_fifo_wr <= 1'b1;
            end
            else
            begin
                dis_fifo_wr <= 1'b0;
            end
        end
        else
        begin
            if ((cnt_op_dly >= RD_LAG) && (cnt_op_dly <= (10'd511 + RD_LAG)))
            begin
                dis_fifo_wr <= 1'b1;
            end
            else
            begin
                dis_fifo_wr <= 1'b0;
            end
        end
        dis_fifo_wdata  <= {srm_din_a, srm_din_b, srm_din_c};
    end
    else
    begin
        dis_fifo_wr    <= 1'b0;
        dis_fifo_wdata <= 48'b0;
    end
end
   
endmodule