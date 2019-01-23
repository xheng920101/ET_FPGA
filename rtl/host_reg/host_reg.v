//*****************************************************************************
// COPYRIGHT (c) 2014, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  host_reg.v
// Module name   :  host_reg
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  control infomation (reg.) processing from host (ARM)
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2014-07-25    :  create file
//*****************************************************************************
module host_reg (
	input						clk,
	input						rst_n,

	input						arm_scs,
	input						arm_sck,
	input						arm_sdi,
	output wire				arm_sdo,

	output reg [15:0]		hact,
	output reg [15:0]		vact,
	output reg [7:0]		vpw,
	output reg [15:0]		vbp,
	output reg [15:0]		vfp,
	output reg [7:0]		hpw,
	output reg [15:0]		hbp,
	output reg [15:0]		hfp,

	output reg				pic_wr_en,
	output reg [4:0]		pic_wr_num,
	output reg [15:0]		pic_bst_num,
	output reg [4:0]		pic_size_rsv,
	output reg [9:0]		pic_last_bst_num,
	
	output reg				dis_mode,
	output reg [7:0]		dis_num,
	output reg				port_map,
	output reg [7:0]		port_main,
	output reg				init_end,
	output reg				te_detect_en,
	output reg				pic_mask_en,
	output reg [11:0]		info_y_axis,
	
	// add by xiaojing_zhan 20140728
	output reg [7:0]		r_data,
	output reg [7:0]		g_data,
	output reg [7:0]		b_data,
	output reg [7:0]		dot_r1,
	output reg [7:0]		dot_g1,
	output reg [7:0]		dot_b1,
	output reg [7:0]		dot_r2,
	output reg [7:0]		dot_g2,
	output reg [7:0]		dot_b2,
	output reg [7:0]		dot_r3,
	output reg [7:0]		dot_g3,
	output reg [7:0]		dot_b3,
	output reg [7:0]		bg_r,
	output reg [7:0]		bg_g,
	output reg [7:0]		bg_b,
	output reg [11:0]		rect_start_x,
	output reg [11:0]		rect_start_y,
	output reg [7:0]		rect_size_x,
	output reg [7:0]		rect_size_y,
	output reg [7:0]		graylvl1,
	output reg [7:0]		graylvl2,
	output reg [7:0]		graylvl3,
	 
	output reg [7:0]		otp_times1,
	output reg [7:0]		otp_times2,
	output reg [7:0]		info_show_en,
	output reg [7:0]		info0,
	output reg [7:0]		info1,
	output reg [7:0]		info2,
	output reg [7:0]		info3,
	output reg [7:0]		info4,
	output reg [7:0]		info5,
	output reg [7:0]		info6,
	output reg [7:0]		info7,
	output reg [7:0]		info8,
	output reg [7:0]		info9,
	output reg [7:0]		info10,
	output reg [7:0]		info11,
	output reg [7:0]		info12,
	output reg [7:0]		info13,
	 
	output reg [7:0]		project0,
	output reg [7:0]		project1,
	output reg [7:0]		project2,
	output reg [7:0]		project3,
	output reg [7:0]		project4,
	output reg [7:0]		project5,
	output reg [7:0]		project6,
	output reg [7:0]		project7,
	output reg [7:0]		project8,
	output reg [7:0]		project9,
	output reg [7:0]		project10,
	output reg [7:0]		project11,
	output reg [7:0]		project12,
	output reg [7:0]		project13,
	output reg [7:0]		project14,
	output reg [7:0]		project15,
	output reg [7:0]		project16,
	output reg [7:0]		project17,
	output reg [7:0]		project18,
	output reg [7:0]		project19,
	output reg [7:0]		project20,
	output reg [7:0]		project21,
	
	output reg [7:0]		version0,
	output reg [7:0]		version1,
	output reg [7:0]		version2,
	output reg [7:0]		version3,
	output reg [7:0]		version4,
	output reg [7:0]		version5,
	output reg [7:0]		version6,
	output reg [7:0]		version7,
	output reg [7:0]		version8,
	output reg [7:0]		version9,
	output reg [7:0]		version10,
	output reg [7:0]		version11,
	output reg [7:0]		version12,
	
	output reg [7:0]		op_type,
	output reg				ini_dcx,
	output reg [7:0]		ini_data,
	output reg				read_finish,
	output reg				next_step,
	input						clc_next,
	input			[7:0]		data_rd
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter 	    project		= "TL063FVMC02-01";

//control register address
//porch setting
parameter       ADDR_HACT_1         = 8'h10                     ;  //MSB
parameter       ADDR_HACT_2         = 8'h11                     ;  //LSB
parameter       ADDR_VACT_1         = 8'h12                     ;  //MSB
parameter       ADDR_VACT_2         = 8'h13                     ;  //LSB
parameter       ADDR_VPW            = 8'h14                     ;
parameter       ADDR_VBP_1          = 8'h15                     ;  //MSB
parameter       ADDR_VBP_2          = 8'h16                     ;  //LSB
parameter       ADDR_VFP_1          = 8'h17                     ;  //MSB
parameter       ADDR_VFP_2          = 8'h18                     ;  //LSB
parameter       ADDR_HPW            = 8'h19                     ;
parameter       ADDR_HBP_1          = 8'h1A                     ;  //MSB
parameter       ADDR_HBP_2          = 8'h1B                     ;  //LSB
parameter       ADDR_HFP_1          = 8'h1C                     ;  //MSB
parameter       ADDR_HFP_2          = 8'h1D                     ;  //LSB

//picture writting
parameter       ADDR_PIC_WR_EN      = 8'h20                     ;
parameter       ADDR_PIC_WR_NUM     = 8'h21                     ;
parameter       ADDR_PIC_BST_NUM_1  = 8'h22                     ;  //SDRAM burst numbers needed for 1 picture (for 1 SDRAM)
parameter       ADDR_PIC_BST_NUM_2  = 8'h23                     ;  //SDRAM burst numbers needed for 1 picture (for 1 SDRAM)
parameter       ADDR_PIC_SIZE_RSV   = 8'h24                     ;  //SDRAM size reserved for 1 picture (for 1 SDRAM)
parameter       ADDR_PIC_LAST_BST_NUM_1   = 8'h25               ;
parameter       ADDR_PIC_LAST_BST_NUM_2   = 8'h26               ;

//display control
parameter       ADDR_DIS_MODE       = 8'h30                     ;
parameter       ADDR_DIS_SN         = 8'h31                     ;
parameter       ADDR_PORT_MAP       = 8'h32                     ;
parameter       ADDR_PORT_MAIN      = 8'h33                     ;
parameter       ADDR_OTP_TIMES_1		= 8'h34                     ; //tens
parameter       ADDR_OTP_TIMES_2		= 8'h35                     ; //units  
parameter       ADDR_PAT_GRAY_1		= 8'h36                     ; //hundreds 
parameter       ADDR_PAT_GRAY_2		= 8'h37                     ; //tens 
parameter       ADDR_PAT_GRAY_3		= 8'h38                     ; //units 

//flag
parameter       ADDR_INIT_END       = 8'h40                     ;
parameter       ADDR_TE_DETECT      = 8'h41                     ;
parameter       ADDR_PIC_MASK       = 8'h42                     ;
parameter       ADDR_INFO_Y_1       = 8'h43                     ;
parameter       ADDR_INFO_Y_2       = 8'h44                     ;

//pattern setting 
parameter       ADDR_PAT_R         	= 8'h50                     ;
parameter       ADDR_PAT_G         	= 8'h51                     ;
parameter       ADDR_PAT_B         	= 8'h52                     ; // RGB value for pure color pattern
//parameter       ADDR_PAT_GRAY       = 8'h53                     ; // gray level as background
parameter       ADDR_PAT_R1         = 8'h54                     ;
parameter       ADDR_PAT_G1         = 8'h55                     ;
parameter       ADDR_PAT_B1         = 8'h56                     ; 
parameter       ADDR_PAT_R2         = 8'h57                     ;
parameter       ADDR_PAT_G2         = 8'h58                     ;
parameter       ADDR_PAT_B2         = 8'h59                     ;
parameter       ADDR_PAT_R3         = 8'h5A                     ;
parameter       ADDR_PAT_G3         = 8'h5B                     ;
parameter       ADDR_PAT_B3         = 8'h5C                     ;
parameter       ADDR_PAT_BG_R       = 8'h5D                     ;
parameter       ADDR_PAT_BG_G       = 8'h5E                     ;
parameter       ADDR_PAT_BG_B       = 8'h5F                     ;
parameter       ADDR_PAT_RECT_XY    = 8'h45                     ;
parameter       ADDR_PAT_RECT_X     = 8'h46                     ;
parameter       ADDR_PAT_RECT_Y     = 8'h47                     ;
parameter       ADDR_PAT_RECT_S_X   = 8'h48                     ;
parameter       ADDR_PAT_RECT_S_Y   = 8'h49                     ;

//information
//parameter		ADDR_OTP_TIMES    	= 8'h60                     ;
parameter		ADDR_INFO_SHOW_EN  	= 8'h61							 ;
parameter		ADDR_INFO_CHAR_0		= 8'h62							 ;
parameter		ADDR_INFO_CHAR_1		= 8'h63							 ;
parameter		ADDR_INFO_CHAR_2		= 8'h64							 ;
parameter		ADDR_INFO_CHAR_3		= 8'h65							 ;
parameter		ADDR_INFO_CHAR_4		= 8'h66							 ;
parameter		ADDR_INFO_CHAR_5		= 8'h67							 ;
parameter		ADDR_INFO_CHAR_6		= 8'h68							 ;
parameter		ADDR_INFO_CHAR_7		= 8'h69							 ;
parameter		ADDR_INFO_CHAR_8		= 8'h6A							 ;
parameter		ADDR_INFO_CHAR_9		= 8'h6B							 ;
parameter		ADDR_INFO_CHAR_10		= 8'h6C							 ;
parameter		ADDR_INFO_CHAR_11		= 8'h6D							 ;
parameter		ADDR_INFO_CHAR_12		= 8'h6E 							 ;
parameter		ADDR_INFO_CHAR_13		= 8'h6F							 ;

//project number
parameter		ADDR_PROJECT_CHAR_0 		= 8'h70;
parameter		ADDR_PROJECT_CHAR_1 		= 8'h71;
parameter		ADDR_PROJECT_CHAR_2 		= 8'h72;
parameter		ADDR_PROJECT_CHAR_3 		= 8'h73;
parameter		ADDR_PROJECT_CHAR_4 		= 8'h74;
parameter		ADDR_PROJECT_CHAR_5 		= 8'h75;
parameter		ADDR_PROJECT_CHAR_6 		= 8'h76;
parameter		ADDR_PROJECT_CHAR_7 		= 8'h77;
parameter		ADDR_PROJECT_CHAR_8 		= 8'h78;
parameter		ADDR_PROJECT_CHAR_9 		= 8'h79;
parameter		ADDR_PROJECT_CHAR_10 	= 8'h7A;
parameter		ADDR_PROJECT_CHAR_11 	= 8'h7B;
parameter		ADDR_PROJECT_CHAR_12 	= 8'h7C;
parameter		ADDR_PROJECT_CHAR_13 	= 8'h7D;
parameter		ADDR_PROJECT_CHAR_14 	= 8'h7E;
parameter		ADDR_PROJECT_CHAR_15 	= 8'h7F;
parameter		ADDR_PROJECT_CHAR_16 	= 8'h80;
parameter		ADDR_PROJECT_CHAR_17 	= 8'h81;
parameter		ADDR_PROJECT_CHAR_18 	= 8'h82;
parameter		ADDR_PROJECT_CHAR_19 	= 8'h83;
parameter		ADDR_PROJECT_CHAR_20 	= 8'h84;
parameter		ADDR_PROJECT_CHAR_21 	= 8'h85;

//version
parameter		ADDR_VERSION_CHAR_0		= 8'h86;
parameter		ADDR_VERSION_CHAR_1		= 8'h87;
parameter		ADDR_VERSION_CHAR_2		= 8'h88;
parameter		ADDR_VERSION_CHAR_3		= 8'h89;
parameter		ADDR_VERSION_CHAR_4		= 8'h8A;
parameter		ADDR_VERSION_CHAR_5		= 8'h8B;
parameter		ADDR_VERSION_CHAR_6		= 8'h8C;
parameter		ADDR_VERSION_CHAR_7		= 8'h8D;
parameter		ADDR_VERSION_CHAR_8		= 8'h8E;
parameter		ADDR_VERSION_CHAR_9		= 8'h8F;
parameter		ADDR_VERSION_CHAR_10		= 8'h90;
parameter		ADDR_VERSION_CHAR_11		= 8'h91;
parameter		ADDR_VERSION_CHAR_12		= 8'h92;

//comand mode use
parameter 	    ADDR_OP_TYPE			= 8'hBA;
parameter 	    ADDR_INI_DCX			= 8'hBB;
parameter 	    ADDR_INI_DATA			= 8'hBC;
parameter 	    ADDR_READ_FINISH		= 8'hBE;

//suggest:
//Set porch before INIT_END

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire                            rx_vld                          ;
wire    [7:0]                   rx_data                         ;
reg                             cnt_rx                          ;  //counter for bytes received from arm
reg     [7:0]                   rx_data_lat                     ;  //odd byte received from arm, treated as address
reg     [7:0]                   tx_data                         ;  

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
spi_intf u_spi_intf(
    .clk                        ( clk                           ),  //input
    .rst_n                      ( rst_n                         ),  //input
    .arm_scs                    ( arm_scs                       ),  //input
    .arm_sck                    ( arm_sck                       ),  //input
    .arm_sdi                    ( arm_sdi                       ),  //input
    .arm_sdo                    ( arm_sdo                       ),  //output
    .rx_vld                     ( rx_vld                        ),  //output reg
    .rx_data                    ( rx_data                       ),  //output reg  [7:0]
	 .tx_data						  ( tx_data								 )
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_rx <= 1'b0;
    end
    else
    begin
        if (rx_vld == 1'b1)
        begin
            cnt_rx <= cnt_rx + 1'b1;
            if (cnt_rx == 1'b0)
            begin
                rx_data_lat <= rx_data;
            end
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        hact         <= 16'd1080;
        vact         <= 16'd1920;
        vpw          <= 8'd2;
        vbp          <= 16'd4;
        vfp          <= 16'd6;
        hpw          <= 8'd20;
        hbp          <= 16'd20;
        hfp          <= 16'd40;
		  
        pic_wr_en    <= 1'b0;
        pic_wr_num   <= 5'd0;
        pic_bst_num  <= 16'd3038;
        pic_size_rsv <= 5'd6;
		  pic_last_bst_num <= 10'd256;	
		  
        dis_mode     <= 1'b0;
        dis_num      <= 8'd0;
        init_end     <= 1'b0;
		  te_detect_en <= 1'b0;
		  pic_mask_en	<= 1'b0;
		  info_y_axis  <= 12'd5;
		  
		  r_data 		<= 8'd0;
		  g_data 		<= 8'd0;
		  b_data 		<= 8'd0;
		  rect_start_x <= 12'd0;
		  rect_start_y <= 12'd0;
		  rect_size_x  <= 8'd0;
		  rect_size_y  <= 8'd0;
//		  graylvl 		<= 8'd127;
		  graylvl1 		<= "1";
		  graylvl2 		<= "2";
		  graylvl3 		<= "7";
		  
		  otp_times1	<= "0";
		  otp_times2	<= "0";
//		  otp_times    <= 8'd0;
		  info_show_en	<= 8'd0;
		  info0			<= 8'd0;
		  info1			<= 8'd0;
		  info2			<= 8'd0;
		  info3			<= 8'd0;
		  info4			<= 8'd0;
		  info5			<= 8'd0;
		  info6			<= 8'd0;
		  info7			<= 8'd0;
		  info8			<= 8'd0;
		  info9			<= 8'd0;
		  info10			<= 8'd0;
		  info11			<= 8'd0;
		  info12			<= 8'd0;
		  info13			<= 8'd0;
		  
		  project0		<= 8'd0;
		  project1		<= 8'd0;
		  project2		<= 8'd0;
		  project3		<= 8'd0;
		  project4		<= 8'd0;
		  project5		<= 8'd0;
		  project6		<= 8'd0;
		  project7		<= 8'd0;
		  project8		<= 8'd0;
		  project9		<= 8'd0;
		  project10		<= 8'd0;
		  project11		<= 8'd0;
		  project12		<= 8'd0;
		  project13		<= 8'd0;
		  project14		<= 8'd0;
		  project15		<= 8'd0;

		  version0		<= 8'd0;
		  version1		<= 8'd0;
		  version2		<= 8'd0;
		  version3		<= 8'd0;
		  version4		<= 8'd0;
		  version5		<= 8'd0;
		  version6		<= 8'd0;
		  version7		<= 8'd0;
		  version8		<= 8'd0;
		  version9		<= 8'd0;
		  version10		<= 8'd0;
		  version11		<= 8'd0;
		  version12		<= 8'd0;
		  
		  op_type		<= 8'd0;
		  ini_dcx		<= 1'b0;
		  ini_data		<= 8'd0;
		  next_step		<= 1'b0;
		  read_finish	<= 1'b0;
    end
    else
    begin
        if (rx_vld == 1'b1)
        begin
            if (cnt_rx == 1'b1)
            begin
                case (rx_data_lat[7:0])
                    ADDR_HACT_1:
                    begin
                        hact[15:8] <= rx_data;
                    end
                    ADDR_HACT_2:
                    begin
                        hact[7:0] <= rx_data;
                    end
                    ADDR_VACT_1:
                    begin
                        vact[15:8] <= rx_data;
                    end
                    ADDR_VACT_2:
                    begin
                        vact[7:0] <= rx_data;
                    end
                    ADDR_VPW:
                    begin
                        vpw[7:0] <= rx_data;
                    end
                    ADDR_VBP_1:
                    begin
                        vbp[15:8] <= rx_data;
                    end
                    ADDR_VBP_2:
                    begin
                        vbp[7:0] <= rx_data;
                    end
                    ADDR_VFP_1:
                    begin
                        vfp[15:8] <= rx_data;
                    end
                    ADDR_VFP_2:
                    begin
                        vfp[7:0] <= rx_data;
                    end
                    ADDR_HPW:
                    begin
                        hpw[7:0] <= rx_data;
                    end
                    ADDR_HBP_1:
                    begin
                        hbp[15:8] <= rx_data;
                    end
                    ADDR_HBP_2:
                    begin
                        hbp[7:0] <= rx_data;
                    end
                    ADDR_HFP_1:
                    begin
                        hfp[15:8] <= rx_data;
                    end
                    ADDR_HFP_2:
                    begin
                        hfp[7:0] <= rx_data;
                    end
                    ADDR_PIC_WR_EN:
                    begin
                        pic_wr_en <= rx_data[0];
                    end
                    ADDR_PIC_WR_NUM:
                    begin
                        pic_wr_num <= rx_data[4:0];
                    end
                    ADDR_PIC_BST_NUM_1:
                    begin
                        pic_bst_num[15:8] <= rx_data[7:0];
                    end
                    ADDR_PIC_BST_NUM_2:
                    begin
                        pic_bst_num[7:0] <= rx_data[7:0];
                    end
                    ADDR_PIC_SIZE_RSV:
                    begin
                        pic_size_rsv <= rx_data[4:0];
                    end
                    ADDR_PIC_LAST_BST_NUM_1:
                    begin
                        pic_last_bst_num[9:8] <= rx_data[1:0];
                    end
                    ADDR_PIC_LAST_BST_NUM_2:
                    begin
                        pic_last_bst_num[7:0] <= rx_data[7:0];
                    end
                    ADDR_DIS_MODE:
                    begin
                        dis_mode <= rx_data[0];
                    end
                    ADDR_DIS_SN:
                    begin
                        dis_num <= rx_data;
                    end
                    ADDR_PORT_MAP:
                    begin
                        port_map <= rx_data[0];
                    end
						  ADDR_PORT_MAIN:
                    begin
                        port_main <= rx_data;
                    end
                    ADDR_INIT_END:
                    begin
                        init_end <= rx_data[0];
                    end
						  ADDR_PAT_R:
						  begin
								r_data <= rx_data;
						  end
						  ADDR_PAT_G:
						  begin
								g_data <= rx_data;
						  end
						  ADDR_PAT_B:
						  begin
								b_data <= rx_data;
						  end
//						  ADDR_PAT_GRAY:
//						  begin
//								graylvl <= rx_data;
//						  end
						  ADDR_PAT_GRAY_1:
						  begin
								graylvl1 <= rx_data;
						  end
						  ADDR_PAT_GRAY_2:
						  begin
								graylvl2 <= rx_data;
						  end
						  ADDR_PAT_GRAY_3:
						  begin
								graylvl3 <= rx_data;
						  end
						  ADDR_OTP_TIMES_1:
						  begin
								otp_times1 <= rx_data;
						  end
						  ADDR_OTP_TIMES_2:
						  begin
								otp_times2 <= rx_data;
						  end
//						  ADDR_OTP_TIMES:
//						  begin
//								otp_times <= rx_data;
//						  end
						  ADDR_INFO_SHOW_EN:
						  begin
								info_show_en <= rx_data;
						  end
						  ADDR_INFO_CHAR_0:
						  begin
								info0 <= rx_data;
						  end
						  ADDR_INFO_CHAR_1:
						  begin
								info1 <= rx_data;
						  end
						  ADDR_INFO_CHAR_2:
						  begin
								info2 <= rx_data;
						  end
						  ADDR_INFO_CHAR_3:
						  begin
								info3 <= rx_data;
						  end
						  ADDR_INFO_CHAR_4:
						  begin
								info4 <= rx_data;
						  end
						  ADDR_INFO_CHAR_5:
						  begin
								info5 <= rx_data;
						  end
						  ADDR_INFO_CHAR_6:
						  begin
								info6 <= rx_data;
						  end
						  ADDR_INFO_CHAR_7:
						  begin
								info7 <= rx_data;
						  end
						  ADDR_INFO_CHAR_8:
						  begin
								info8 <= rx_data;
						  end
						  ADDR_INFO_CHAR_9:
						  begin
								info9 <= rx_data;
						  end
						  ADDR_INFO_CHAR_10:
						  begin
								info10 <= rx_data;
						  end
						  ADDR_INFO_CHAR_11:
						  begin
								info11 <= rx_data;
						  end
						  ADDR_INFO_CHAR_12:
						  begin
								info12 <= rx_data;
						  end
						  ADDR_INFO_CHAR_13:
						  begin
								info13 <= rx_data;
						  end
						  ADDR_PROJECT_CHAR_0:
						  begin
								project0 <= rx_data;
								tx_data <= project[135:128];
						  end
						  ADDR_PROJECT_CHAR_1:
						  begin
								project1 <= rx_data;
								tx_data <= project[127:120];
						  end
						  ADDR_PROJECT_CHAR_2:
						  begin
								project2 <= rx_data;
								tx_data <= project[119:112];
						  end
						  ADDR_PROJECT_CHAR_3:
						  begin
								project3 <= rx_data;
								tx_data <= project[111:104];
						  end
						  ADDR_PROJECT_CHAR_4:
						  begin
								project4 <= rx_data;
								tx_data <= project[103:96];
						  end
						  ADDR_PROJECT_CHAR_5:
						  begin
								project5 <= rx_data;
								tx_data <= project[95:88];
						  end
						  ADDR_PROJECT_CHAR_6:
						  begin
								project6 <= rx_data;
								tx_data <= project[87:80];
						  end
						  ADDR_PROJECT_CHAR_7:
						  begin
								project7 <= rx_data;
								tx_data <= project[79:72];
						  end
						  ADDR_PROJECT_CHAR_8:
						  begin
								project8 <= rx_data;
								tx_data <= project[71:64];
						  end
						  ADDR_PROJECT_CHAR_9:
						  begin
								project9 <= rx_data;
								tx_data <= project[63:56];
						  end
						  ADDR_PROJECT_CHAR_10:
						  begin
								project10 <= rx_data;
								tx_data <= project[55:48];;
						  end
						  ADDR_PROJECT_CHAR_11:
						  begin
								project11 <= rx_data;
								tx_data <= project[47:40];
						  end
						  ADDR_PROJECT_CHAR_12:
						  begin
								project12 <= rx_data;
								tx_data <= project[39:32];
						  end
						  ADDR_PROJECT_CHAR_13:
						  begin
								project13 <= rx_data;
								tx_data <= project[31:24];
						  end
						  ADDR_PROJECT_CHAR_14:
						  begin
								project14 <= rx_data;
								tx_data <= project[23:16];
						  end
						  ADDR_PROJECT_CHAR_15:
						  begin
								project15 <= rx_data;
								tx_data <= project[15:8];
						  end
						  ADDR_PROJECT_CHAR_16:
						  begin
								project16 <= rx_data;
								tx_data <= project[7:0];
						  end
						  ADDR_PROJECT_CHAR_17:
						  begin
								project17 <= rx_data;
								tx_data <= project[7:0];
						  end
						  ADDR_PROJECT_CHAR_18:
						  begin
								project18 <= rx_data;
								tx_data <= project[7:0];
						  end
						  ADDR_PROJECT_CHAR_19:
						  begin
								project19 <= rx_data;
								tx_data <= project[7:0];
						  end
						  ADDR_PROJECT_CHAR_20:
						  begin
								project20 <= rx_data;
								tx_data <= project[7:0];
						  end
						  ADDR_PROJECT_CHAR_21:
						  begin
								project21 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_0:
						  begin
								version0 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_1:
						  begin
								version1 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_2:
						  begin
								version2 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_3:
						  begin
								version3 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_4:
						  begin
								version4 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_5:
						  begin
								version5 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_6:
						  begin
								version6 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_7:
						  begin
								version7 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_8:
						  begin
								version8 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_9:
						  begin
								version9 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_10:
						  begin
								version10 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_11:
						  begin
								version11 <= rx_data;
						  end
						  ADDR_VERSION_CHAR_12:
						  begin
								version12 <= rx_data;
						  end
						  ADDR_TE_DETECT:
						  begin
								te_detect_en <= rx_data[0];
						  end
						  ADDR_PIC_MASK:
						  begin
								pic_mask_en <= rx_data[0];
						  end
						  ADDR_PAT_R1:
						  begin
								dot_r1 <= rx_data;
						  end
						  ADDR_PAT_G1:
						  begin
								dot_g1 <= rx_data;
						  end
						  ADDR_PAT_B1:
						  begin
								dot_b1 <= rx_data;
						  end
						  ADDR_PAT_R2:
						  begin
								dot_r2 <= rx_data;
						  end
						  ADDR_PAT_G2:
						  begin
								dot_g2 <= rx_data;
						  end
						  ADDR_PAT_B2:
						  begin
								dot_b2 <= rx_data;
						  end
						  ADDR_PAT_R3:
						  begin
								dot_r3 <= rx_data;
						  end
						  ADDR_PAT_G3:
						  begin
								dot_g3 <= rx_data;
						  end
						  ADDR_PAT_B3:
						  begin
								dot_b3 <= rx_data;
						  end
						  ADDR_PAT_BG_R:
						  begin
								bg_r <= rx_data;
						  end
						  ADDR_PAT_BG_G:
						  begin
								bg_g <= rx_data;
						  end
						  ADDR_PAT_BG_B:
						  begin
								bg_b <= rx_data;
						  end	
						  ADDR_PAT_RECT_XY:
						  begin
								rect_start_x[11:8] <= rx_data[7:4];
								rect_start_y[11:8] <= rx_data[3:0];
						  end
						  ADDR_PAT_RECT_X:
						  begin
								rect_start_x[7:0] <= rx_data;
						  end		
						  ADDR_PAT_RECT_Y:
						  begin
								rect_start_y[7:0] <= rx_data;
						  end	
						  ADDR_PAT_RECT_S_X:
						  begin
								rect_size_x[7:0] <= rx_data;
						  end		
						  ADDR_PAT_RECT_S_Y:
						  begin
								rect_size_y[7:0] <= rx_data;
						  end						  
						  ADDR_OP_TYPE:
						  begin
								op_type <= rx_data;
								tx_data <= data_rd;
						  end
						  ADDR_INI_DCX:
						  begin
								ini_dcx <= rx_data[0];
								next_step <= 1'b1;
								tx_data <= data_rd;
						  end
						  ADDR_INI_DATA:
						  begin
								ini_data <= rx_data;
								next_step <= 1'b1;
								tx_data <= data_rd;
						  end
						  ADDR_READ_FINISH:
						  begin
								read_finish <= rx_data[0];
								tx_data <= data_rd;
						  end
						  ADDR_INFO_Y_1:
						  begin
								info_y_axis[11:8] <= rx_data;
						  end
						  ADDR_INFO_Y_2:
						  begin
								info_y_axis[7:0] <= rx_data;
						  end
						  default:
						  begin
								tx_data <= data_rd;
						  end
                endcase
            end
        end
		  
		  if (clc_next == 1'b1) next_step <= 1'b0;
 
    end
end

endmodule