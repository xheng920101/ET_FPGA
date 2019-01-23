// ****************************************************************************
// COPYRIGHT (c) 2014, Xiamen Tianma Microelectronics Co, Ltd
// All rights reserved.
//
// Author		:	xiaojing_zhan
// Email			:	xiaojing_zhan@tianma.cn
//
// File name	:	info_disp.v
// Version		:	V 1.0
// Abstract		:	Genrate and show information on the display 
// Called by	:	display_control
//
// ----------------------------------------------------------------------------
// Revison 
// 2014-07-04	:	Create file.
// ****************************************************************************

module info_gen(
	input						clk,

	input		[11:0]		hcnt,			//current hcnt number 
	input		[11:0]		vcnt,			//current vcnt number
	input		[7:0]			show_en,
	input    [11:0]      info_y_axis,

	input		[7:0]			dis_num,
	input		[7:0]			r_data_in,
	input		[7:0]			g_data_in,
	input		[7:0]			b_data_in,	//current pixcel value
	input		[7:0]			pat_gray1,	//background gray level
	input		[7:0]			pat_gray2,	//background gray level
	input		[7:0]			pat_gray3,	//background gray level
	input		[7:0]			otp_times1,
	input		[7:0]			otp_times2,

	input		[7:0]			info0,
	input		[7:0]			info1,
	input		[7:0]			info2,
	input		[7:0]			info3,
	input		[7:0]			info4,
	input		[7:0]			info5,
	input		[7:0]			info6,
	input		[7:0]			info7,
	input		[7:0]			info8,
	input		[7:0]			info9,
	input		[7:0]			info10,
	input		[7:0]			info11,
	input		[7:0]			info12,
	input		[7:0]			info13,
	input		[7:0]			info14,
	input		[7:0]			info15,
	input		[7:0]			info16,
	
	input		[7:0]			project0,
	input		[7:0]			project1,
	input		[7:0]			project2,
	input		[7:0]			project3,
	input		[7:0]			project4,
	input		[7:0]			project5,
	input		[7:0]			project6,
	input		[7:0]			project7,
	input		[7:0]			project8,
	input		[7:0]			project9,
	input		[7:0]			project10,
	input		[7:0]			project11,
	input		[7:0]			project12,
	input		[7:0]			project13,
	input		[7:0]			project14,
	input		[7:0]			project15,
	input		[7:0]			project16,
	input		[7:0]			project17,
	input		[7:0]			project18,
	input		[7:0]			project19,
	input		[7:0]			project20,
	input		[7:0]			project21,
	
	input		[7:0]			version0,
	input		[7:0]			version1,
	input		[7:0]			version2,
	input		[7:0]			version3,
	input		[7:0]			version4,
	input		[7:0]			version5,
	input		[7:0]			version6,
	input		[7:0]			version7,
	input		[7:0]			version8,
	input		[7:0]			version9,
	input		[7:0]			version10,
	input		[7:0]			version11,
	input		[7:0]			version12,
	
	output	reg[7:0]		r_data_out,
	output	reg[7:0]		g_data_out, 
	output	reg[7:0]		b_data_out
);

// ----------------------------------------------------------------------------
// Variable definition
// ----------------------------------------------------------------------------
parameter	SCALE	=	3'd4;		//4
parameter	XLEN	=	12'd704;	//8*4*22
parameter	YLEN	=	12'd64;	//16*4
parameter	X1		=	12'd5;   //5 
parameter	X2		=	12'd5;   //5
parameter	X0		=	12'd5;   //5

parameter FPGA_version = "V1P0";

reg	[7:0]	scale_h;
reg	[7:0]	scale_v;

reg	[7:0]	info_buf[0:22];
reg	[7:0]	char_dot_table[0:15];	//8*16 character dot array
reg	[2:0]	cnt8;							//8bit counter for the width of character dot array
reg	[3:0]	cnt16;						//16bit counter for the height of character dot array
reg	[4:0]	buf_index;					//index of the info_buf

wire	[11:0] Y1;	//first line coordinate
wire	[11:0] Y0;   //second line coordinate
wire	[11:0] Y2;	//third line coordinate

// ----------------------------------------------------------------------------
// Continuous assignment
// ----------------------------------------------------------------------------
assign Y1 = info_y_axis;
assign Y0 = info_y_axis + 12'd70;
assign Y2 = info_y_axis + 12'd140;

// ----------------------------------------------------------------------------
// Generate information
// ----------------------------------------------------------------------------
always @(posedge clk)
begin
	if ((vcnt == Y1) && (hcnt == X1))
	begin
		if (show_en[0] == 1'b1)
		begin
			// for example: "ET1_VXXPX"
			info_buf[0]	<=	info0;
			info_buf[1]	<=	info1;
			info_buf[2]	<=	info2;
			info_buf[3]	<=	info3;
			info_buf[4]	<=	info4;
			info_buf[5]	<=	info5;
			info_buf[6]	<=	info6;
			info_buf[7]	<=	info7;
			info_buf[8]	<=	info8;
			info_buf[9]		<=	info9;
			info_buf[10]	<=	info10;
			info_buf[11]	<=	info11;
			info_buf[12]	<=	info12;
			
			if (show_en[5] == 1'b1) //common code verison
			begin
				info_buf[13]	<=	"F";
				info_buf[14]	<=	"P";
				info_buf[15]	<=	"G";
				info_buf[16]	<=	"A";
				info_buf[17]	<=	"_";
				info_buf[18]	<=	"V";
				info_buf[19]	<=	"2";
				info_buf[20]	<=	"P";
				info_buf[21]	<=	"1";
				info_buf[22]	<=	8'd0;
			end
			else if (show_en[4] == 1'b1) //project code verison
			begin
				info_buf[13]	<=	"F";
				info_buf[14]	<=	"P";
				info_buf[15]	<=	"G";
				info_buf[16]	<=	"A";
				info_buf[17]	<=	"_";
				info_buf[18]	<=	FPGA_version[31:24];
				info_buf[19]	<=	FPGA_version[23:16];
				info_buf[20]	<=	FPGA_version[15:8];
				info_buf[21]	<=	FPGA_version[7:0];
				info_buf[22]	<=	8'd0;
			end
			else
			begin
				info_buf[13]	<=	info13;
				info_buf[14]	<=	info14;
				info_buf[15]	<=	info15;
				info_buf[16]	<=	info16;
				info_buf[17]	<=	8'd0;
				info_buf[18]	<=	8'd0;
				info_buf[19]	<=	8'd0;
				info_buf[20]	<=	8'd0;
				info_buf[21]	<=	8'd0;
				info_buf[22]	<=	8'd0;
			end
		end
		else
		begin
			info_buf[0]		<=	8'd0;
			info_buf[1]		<=	8'd0;
			info_buf[2]		<=	8'd0;
			info_buf[3]		<=	8'd0;
			info_buf[4]		<=	8'd0;
			info_buf[5]		<=	8'd0;
			info_buf[6]		<=	8'd0;
			info_buf[7]		<=	8'd0;
			info_buf[8]		<=	8'd0;
			info_buf[9]		<=	8'd0;
			info_buf[10]	<=	8'd0;
			info_buf[11]	<=	8'd0;
			info_buf[12]	<=	8'd0;
			info_buf[13]	<=	8'd0;
			info_buf[14]	<=	8'd0;
			info_buf[15]	<=	8'd0;
			info_buf[16]	<=	8'd0;
			info_buf[17]	<=	8'd0;
			info_buf[18]	<=	8'd0;
			info_buf[19]	<=	8'd0;
			info_buf[20]	<=	8'd0;
			info_buf[21]	<=	8'd0;
			info_buf[22]	<=	8'd0;
		end
	end
	else if ((vcnt == Y2) && (hcnt == X2))
	begin
		if (show_en[3] == 1'b1)
		begin
			info_buf[0]	<=	8'd0;
			info_buf[1]	<=	otp_times1;	
			info_buf[2]	<=	otp_times2;	
			info_buf[3]	<=	8'd0;
		end
		else
		begin
			info_buf[0]	<=	8'd0;
			info_buf[1]	<=	8'd0;
			info_buf[2]	<=	8'd0;
			info_buf[3]	<=	8'd0;
		end
		
		if (show_en[2] == 1'b1)
		begin
			info_buf[4]		<=	8'd0;
			info_buf[5]		<=	pat_gray1;	//(pat_gray) / 8'd100 + 8'd48;
			info_buf[6]		<=	pat_gray2;	//(pat_gray) % 8'd100 / 8'd10 + 8'd48;
			info_buf[7]		<=	pat_gray3;	//(pat_gray) % 8'd10 + 8'd48;
		end
		else
		begin
			info_buf[4]		<=	8'd0;
			info_buf[5]		<=	8'd0;
			info_buf[6]		<=	8'd0;
			info_buf[7]		<=	8'd0;
		end
		
		if  (show_en[0] == 1'b1 && show_en[4] == 1'b1)
		begin
			info_buf[8]		<=	8'd0;
			info_buf[9]		<=	version0;
			info_buf[10]	<=	version1;
			info_buf[11]	<=	version2;
			info_buf[12]	<=	version3;
			info_buf[13]	<=	version4;
			info_buf[14]	<=	version5;
			info_buf[15]	<=	version6;
			info_buf[16]	<=	version7;
			info_buf[17]	<=	version8;
			info_buf[18]	<=	version9;
			info_buf[19]	<=	version10;
			info_buf[20]	<=	version11;
			info_buf[21]	<=	version12;
			info_buf[22]	<=	8'd0;
		end
		else
		begin
			info_buf[8]		<=	8'd0;
			info_buf[9]		<=	8'd0;
			info_buf[10]	<=	8'd0;
			info_buf[11]	<=	8'd0;
			info_buf[12]	<=	8'd0;
			info_buf[13]	<=	8'd0;
			info_buf[14]	<=	8'd0;
			info_buf[15]	<=	8'd0;
			info_buf[16]	<=	8'd0;
			info_buf[17]	<=	8'd0;
			info_buf[18]	<=	8'd0;
			info_buf[19]	<=	8'd0;
			info_buf[20]	<=	8'd0;
			info_buf[21]	<=	8'd0;
			info_buf[22]	<=	8'd0;
		end
	end
	else if ((vcnt == Y0) && (hcnt == X0))
	begin
		if (show_en[6] == 1'b1)
		begin
			info_buf[0]	<=	project0;
			info_buf[1]	<=	project1;
			info_buf[2]	<=	project2;
			info_buf[3]	<=	project3;
			info_buf[4]	<=	project4;
			info_buf[5]	<=	project5;
			info_buf[6]	<=	project6;
			info_buf[7]	<=	project7;
			info_buf[8]	<=	project8;
			info_buf[9]	<=	project9;
			info_buf[10]	<=	project10;
			info_buf[11]	<=	project11;
			info_buf[12]	<=	project12;
			info_buf[13]	<=	project13;
			info_buf[14]	<=	project14;
			info_buf[15]	<=	project15;
			info_buf[16]	<=	project16;
			info_buf[17]	<=	project17;
			info_buf[18]	<=	project18;
			info_buf[19]	<=	project19;
			info_buf[20]	<=	project20;
			info_buf[21]	<=	project21;
			info_buf[22]	<=	8'd0;
		end
		else
		begin
			info_buf[0]		<=	8'd0;
			info_buf[1]		<=	8'd0;
			info_buf[2]		<=	8'd0;
			info_buf[3]		<=	8'd0;
			info_buf[4]		<=	8'd0;
			info_buf[5]		<=	8'd0;
			info_buf[6]		<=	8'd0;
			info_buf[7]		<=	8'd0;
			info_buf[8]		<=	8'd0;
			info_buf[9]		<=	8'd0;
			info_buf[10]	<=	8'd0;
			info_buf[11]	<=	8'd0;
			info_buf[12]	<=	8'd0;
			info_buf[13]	<=	8'd0;
			info_buf[14]	<=	8'd0;
			info_buf[15]	<=	8'd0;
			info_buf[16]	<=	8'd0;
			info_buf[17]	<=	8'd0;
			info_buf[18]	<=	8'd0;
			info_buf[19]	<=	8'd0;
			info_buf[20]	<=	8'd0;
			info_buf[21]	<=	8'd0;
			info_buf[22]	<=	8'd0;
		end
	end
end

always @(posedge clk)
begin
	case (info_buf[buf_index])
	"0":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h18;
			char_dot_table[4]		<=	8'h24;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h42;
			char_dot_table[8]		<=	8'h42;
			char_dot_table[9]		<=	8'h42;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h24;
			char_dot_table[13]	<=	8'h18;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"1":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h10;
			char_dot_table[4]		<=	8'h70;
			char_dot_table[5]		<=	8'h10;
			char_dot_table[6]		<=	8'h10;
			char_dot_table[7]		<=	8'h10;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h10;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h10;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h7C;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"2":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3C;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h04;
			char_dot_table[8]		<=	8'h04;
			char_dot_table[9]		<=	8'h08;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h20;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'h7E;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"3":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3C;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h04;
			char_dot_table[7]		<=	8'h18;
			char_dot_table[8]		<=	8'h04;
			char_dot_table[9]		<=	8'h02;
			char_dot_table[10]	<=	8'h02;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"4":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h04;
			char_dot_table[4]		<=	8'h0C;
			char_dot_table[5]		<=	8'h14;
			char_dot_table[6]		<=	8'h24;
			char_dot_table[7]		<=	8'h24;
			char_dot_table[8]		<=	8'h44;
			char_dot_table[9]		<=	8'h44;
			char_dot_table[10]	<=	8'h7E;
			char_dot_table[11]	<=	8'h04;
			char_dot_table[12]	<=	8'h04;
			char_dot_table[13]	<=	8'h1E;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"5":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h7E;
			char_dot_table[4]		<=	8'h40;
			char_dot_table[5]		<=	8'h40;
			char_dot_table[6]		<=	8'h40;
			char_dot_table[7]		<=	8'h58;
			char_dot_table[8]		<=	8'h64;
			char_dot_table[9]		<=	8'h02;
			char_dot_table[10]	<=	8'h02;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"6":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h1C;
			char_dot_table[4]		<=	8'h24;
			char_dot_table[5]		<=	8'h40;
			char_dot_table[6]		<=	8'h40;
			char_dot_table[7]		<=	8'h58;
			char_dot_table[8]		<=	8'h64;
			char_dot_table[9]		<=	8'h42;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h24;
			char_dot_table[13]	<=	8'h18;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"7":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h7E;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h44;
			char_dot_table[6]		<=	8'h08;
			char_dot_table[7]		<=	8'h08;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h10;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h10;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h10;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"8":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3C;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h24;
			char_dot_table[8]		<=	8'h18;
			char_dot_table[9]		<=	8'h24;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'h3C;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"9":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h18;
			char_dot_table[4]		<=	8'h24;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h42;
			char_dot_table[8]		<=	8'h26;
			char_dot_table[9]		<=	8'h1A;
			char_dot_table[10]	<=	8'h02;
			char_dot_table[11]	<=	8'h02;
			char_dot_table[12]	<=	8'h24;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"A":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h10;
			char_dot_table[4]		<=	8'h10;
			char_dot_table[5]		<=	8'h18;
			char_dot_table[6]		<=	8'h28;
			char_dot_table[7]		<=	8'h28;
			char_dot_table[8]		<=	8'h24;
			char_dot_table[9]		<=	8'h3C;
			char_dot_table[10]	<=	8'h44;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hE7;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"B":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hF8;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h44;
			char_dot_table[6]		<=	8'h44;
			char_dot_table[7]		<=	8'h78;
			char_dot_table[8]		<=	8'h44;
			char_dot_table[9]		<=	8'h42;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'hF8;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"C":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3E;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h80;
			char_dot_table[7]		<=	8'h80;
			char_dot_table[8]		<=	8'h80;
			char_dot_table[9]		<=	8'h80;
			char_dot_table[10]	<=	8'h80;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"D":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hF8;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h42;
			char_dot_table[8]		<=	8'h42;
			char_dot_table[9]		<=	8'h42;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hF8;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"E":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hFC;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h48;
			char_dot_table[6]		<=	8'h48;
			char_dot_table[7]		<=	8'h78;
			char_dot_table[8]		<=	8'h48;
			char_dot_table[9]		<=	8'h48;
			char_dot_table[10]	<=	8'h40;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hFC;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"F":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hFC;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h48;
			char_dot_table[6]		<=	8'h48;
			char_dot_table[7]		<=	8'h78;
			char_dot_table[8]		<=	8'h48;
			char_dot_table[9]		<=	8'h48;
			char_dot_table[10]	<=	8'h40;
			char_dot_table[11]	<=	8'h40;
			char_dot_table[12]	<=	8'h40;
			char_dot_table[13]	<=	8'hE0;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"G":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3C;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h44;
			char_dot_table[6]		<=	8'h80;
			char_dot_table[7]		<=	8'h80;
			char_dot_table[8]		<=	8'h80;
			char_dot_table[9]		<=	8'h8E;
			char_dot_table[10]	<=	8'h84;
			char_dot_table[11]	<=	8'h44;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"H":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hE7;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h42;
			char_dot_table[8]		<=	8'h7E;
			char_dot_table[9]		<=	8'h42;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hE7;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"I":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h7C;
			char_dot_table[4]		<=	8'h10;
			char_dot_table[5]		<=	8'h10;
			char_dot_table[6]		<=	8'h10;
			char_dot_table[7]		<=	8'h10;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h10;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h10;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h7C;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"J":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3E;
			char_dot_table[4]		<=	8'h08;
			char_dot_table[5]		<=	8'h08;
			char_dot_table[6]		<=	8'h08;
			char_dot_table[7]		<=	8'h08;
			char_dot_table[8]		<=	8'h08;
			char_dot_table[9]		<=	8'h08;
			char_dot_table[10]	<=	8'h08;
			char_dot_table[11]	<=	8'h08;
			char_dot_table[12]	<=	8'h08;
			char_dot_table[13]	<=	8'h08;
			char_dot_table[14]	<=	8'h88;
			char_dot_table[15]	<=	8'hF0;
		end
	"K":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hEE;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h48;
			char_dot_table[6]		<=	8'h50;
			char_dot_table[7]		<=	8'h70;
			char_dot_table[8]		<=	8'h50;
			char_dot_table[9]		<=	8'h48;
			char_dot_table[10]	<=	8'h48;
			char_dot_table[11]	<=	8'h44;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'hEE;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"L":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hE0;
			char_dot_table[4]		<=	8'h40;
			char_dot_table[5]		<=	8'h40;
			char_dot_table[6]		<=	8'h40;
			char_dot_table[7]		<=	8'h40;
			char_dot_table[8]		<=	8'h40;
			char_dot_table[9]		<=	8'h40;
			char_dot_table[10]	<=	8'h40;
			char_dot_table[11]	<=	8'h40;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hFE;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"M":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hEE;
			char_dot_table[4]		<=	8'h6C;
			char_dot_table[5]		<=	8'h6C;
			char_dot_table[6]		<=	8'h6C;
			char_dot_table[7]		<=	8'h6C;
			char_dot_table[8]		<=	8'h54;
			char_dot_table[9]		<=	8'h54;
			char_dot_table[10]	<=	8'h54;
			char_dot_table[11]	<=	8'h54;
			char_dot_table[12]	<=	8'h54;
			char_dot_table[13]	<=	8'hD6;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"N":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hC7;
			char_dot_table[4]		<=	8'h62;
			char_dot_table[5]		<=	8'h62;
			char_dot_table[6]		<=	8'h52;
			char_dot_table[7]		<=	8'h52;
			char_dot_table[8]		<=	8'h4A;
			char_dot_table[9]		<=	8'h4A;
			char_dot_table[10]	<=	8'h4A;
			char_dot_table[11]	<=	8'h46;
			char_dot_table[12]	<=	8'h46;
			char_dot_table[13]	<=	8'hE2;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"O":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h38;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h82;
			char_dot_table[6]		<=	8'h82;
			char_dot_table[7]		<=	8'h82;
			char_dot_table[8]		<=	8'h82;
			char_dot_table[9]		<=	8'h82;
			char_dot_table[10]	<=	8'h82;
			char_dot_table[11]	<=	8'h82;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"P":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hFC;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h42;
			char_dot_table[8]		<=	8'h7C;
			char_dot_table[9]		<=	8'h40;
			char_dot_table[10]	<=	8'h40;
			char_dot_table[11]	<=	8'h40;
			char_dot_table[12]	<=	8'h40;
			char_dot_table[13]	<=	8'hE0;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"Q":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h38;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h82;
			char_dot_table[6]		<=	8'h82;
			char_dot_table[7]		<=	8'h82;
			char_dot_table[8]		<=	8'h82;
			char_dot_table[9]		<=	8'h82;
			char_dot_table[10]	<=	8'hB2;
			char_dot_table[11]	<=	8'hCA;
			char_dot_table[12]	<=	8'h4C;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h06;
			char_dot_table[15]	<=	8'h00;
		end
	"R":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hFC;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h7C;
			char_dot_table[8]		<=	8'h48;
			char_dot_table[9]		<=	8'h48;
			char_dot_table[10]	<=	8'h44;
			char_dot_table[11]	<=	8'h44;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hE3;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"S":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h3E;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h40;
			char_dot_table[7]		<=	8'h20;
			char_dot_table[8]		<=	8'h18;
			char_dot_table[9]		<=	8'h04;
			char_dot_table[10]	<=	8'h02;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'h7C;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"T":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hFE;
			char_dot_table[4]		<=	8'h92;
			char_dot_table[5]		<=	8'h10;
			char_dot_table[6]		<=	8'h10;
			char_dot_table[7]		<=	8'h10;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h10;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h10;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"U":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hE7;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h42;
			char_dot_table[7]		<=	8'h42;
			char_dot_table[8]		<=	8'h42;
			char_dot_table[9]		<=	8'h42;
			char_dot_table[10]	<=	8'h42;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'h3C;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"V":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hE7;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h42;
			char_dot_table[6]		<=	8'h44;
			char_dot_table[7]		<=	8'h24;
			char_dot_table[8]		<=	8'h24;
			char_dot_table[9]		<=	8'h28;
			char_dot_table[10]	<=	8'h28;
			char_dot_table[11]	<=	8'h18;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h10;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"W":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hD6;
			char_dot_table[4]		<=	8'h92;
			char_dot_table[5]		<=	8'h92;
			char_dot_table[6]		<=	8'h92;
			char_dot_table[7]		<=	8'h92;
			char_dot_table[8]		<=	8'hAA;
			char_dot_table[9]		<=	8'hAA;
			char_dot_table[10]	<=	8'h6C;
			char_dot_table[11]	<=	8'h44;
			char_dot_table[12]	<=	8'h44;
			char_dot_table[13]	<=	8'h44;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"X":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hE7;
			char_dot_table[4]		<=	8'h42;
			char_dot_table[5]		<=	8'h24;
			char_dot_table[6]		<=	8'h24;
			char_dot_table[7]		<=	8'h18;
			char_dot_table[8]		<=	8'h18;
			char_dot_table[9]		<=	8'h18;
			char_dot_table[10]	<=	8'h24;
			char_dot_table[11]	<=	8'h24;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hE7;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"Y":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'hEE;
			char_dot_table[4]		<=	8'h44;
			char_dot_table[5]		<=	8'h44;
			char_dot_table[6]		<=	8'h28;
			char_dot_table[7]		<=	8'h28;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h10;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h10;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h38;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"Z":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h7E;
			char_dot_table[4]		<=	8'h84;
			char_dot_table[5]		<=	8'h04;
			char_dot_table[6]		<=	8'h08;
			char_dot_table[7]		<=	8'h08;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h20;
			char_dot_table[10]	<=	8'h20;
			char_dot_table[11]	<=	8'h42;
			char_dot_table[12]	<=	8'h42;
			char_dot_table[13]	<=	8'hFC;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"=":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'hFE;
			char_dot_table[7]		<=	8'h00;
			char_dot_table[8]		<=	8'h00;
			char_dot_table[9]		<=	8'h00;
			char_dot_table[10]	<=	8'hFE;
			char_dot_table[11]	<=	8'h00;
			char_dot_table[12]	<=	8'h00;
			char_dot_table[13]	<=	8'h00;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	";":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'h00;
			char_dot_table[7]		<=	8'h00;
			char_dot_table[8]		<=	8'h30;
			char_dot_table[9]		<=	8'h30;
			char_dot_table[10]	<=	8'h00;
			char_dot_table[11]	<=	8'h30;
			char_dot_table[12]	<=	8'h30;
			char_dot_table[13]	<=	8'h10;
			char_dot_table[14]	<=	8'h20;
			char_dot_table[15]	<=	8'h00;
		end
	".":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'h00;
			char_dot_table[7]		<=	8'h00;
			char_dot_table[8]		<=	8'h00;
			char_dot_table[9]		<=	8'h00;
			char_dot_table[10]	<=	8'h00;
			char_dot_table[11]	<=	8'h00;
			char_dot_table[12]	<=	8'h60;
			char_dot_table[13]	<=	8'h60;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"(":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h02;
			char_dot_table[2]		<=	8'h04;
			char_dot_table[3]		<=	8'h08;
			char_dot_table[4]		<=	8'h08;
			char_dot_table[5]		<=	8'h10;
			char_dot_table[6]		<=	8'h10;
			char_dot_table[7]		<=	8'h10;
			char_dot_table[8]		<=	8'h10;
			char_dot_table[9]		<=	8'h10;
			char_dot_table[10]	<=	8'h10;
			char_dot_table[11]	<=	8'h08;
			char_dot_table[12]	<=	8'h08;
			char_dot_table[13]	<=	8'h04;
			char_dot_table[14]	<=	8'h02;
			char_dot_table[15]	<=	8'h00;
		end
	")":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h40;
			char_dot_table[2]		<=	8'h20;
			char_dot_table[3]		<=	8'h10;
			char_dot_table[4]		<=	8'h10;
			char_dot_table[5]		<=	8'h08;
			char_dot_table[6]		<=	8'h08;
			char_dot_table[7]		<=	8'h08;
			char_dot_table[8]		<=	8'h08;
			char_dot_table[9]		<=	8'h08;
			char_dot_table[10]	<=	8'h08;
			char_dot_table[11]	<=	8'h10;
			char_dot_table[12]	<=	8'h10;
			char_dot_table[13]	<=	8'h20;
			char_dot_table[14]	<=	8'h40;
			char_dot_table[15]	<=	8'h00;
		end
	"_":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'h00;
			char_dot_table[7]		<=	8'h00;
			char_dot_table[8]		<=	8'h00;
			char_dot_table[9]		<=	8'h00;
			char_dot_table[10]	<=	8'h00;
			char_dot_table[11]	<=	8'h00;
			char_dot_table[12]	<=	8'h00;
			char_dot_table[13]	<=	8'h00;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'hFF;
		end
	":":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'h18;
			char_dot_table[7]		<=	8'h18;
			char_dot_table[8]		<=	8'h00;
			char_dot_table[9]		<=	8'h00;
			char_dot_table[10]	<=	8'h00;
			char_dot_table[11]	<=	8'h00;
			char_dot_table[12]	<=	8'h18;
			char_dot_table[13]	<=	8'h18;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	"-":
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'h00;
			char_dot_table[7]		<=	8'h00;
			char_dot_table[8]		<=	8'h7F;
			char_dot_table[9]		<=	8'h00;
			char_dot_table[10]	<=	8'h00;
			char_dot_table[11]	<=	8'h00;
			char_dot_table[12]	<=	8'h00;
			char_dot_table[13]	<=	8'h00;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	default:
		begin
			char_dot_table[0]		<=	8'h00;
			char_dot_table[1]		<=	8'h00;
			char_dot_table[2]		<=	8'h00;
			char_dot_table[3]		<=	8'h00;
			char_dot_table[4]		<=	8'h00;
			char_dot_table[5]		<=	8'h00;
			char_dot_table[6]		<=	8'h00;
			char_dot_table[7]		<=	8'h00;
			char_dot_table[8]		<=	8'h00;
			char_dot_table[9]		<=	8'h00;
			char_dot_table[10]	<=	8'h00;
			char_dot_table[11]	<=	8'h00;
			char_dot_table[12]	<=	8'h00;
			char_dot_table[13]	<=	8'h00;
			char_dot_table[14]	<=	8'h00;
			char_dot_table[15]	<=	8'h00;
		end
	endcase

	if ((((vcnt >= Y1) && (vcnt < Y1 + YLEN)) && ((hcnt >= X1) && (hcnt < X1 + XLEN)))
		|| (((vcnt >= Y2) && (vcnt < Y2 + YLEN)) && ((hcnt >= X2) && (hcnt < X2 + XLEN)))
		|| (((vcnt >= Y0) && (vcnt < Y0 + YLEN)) && ((hcnt >= X0) && (hcnt < X0 + XLEN))))
	begin
		if(char_dot_table[cnt16][7 - cnt8] == 1'b1)
		begin
			if(dis_num > 8'd0)
			begin
				r_data_out <= 8'd255;
				g_data_out <= 8'd0;
				b_data_out <= 8'd0;
			end	
			else
			begin
				r_data_out <= (r_data_in > 8'd128) ? 8'd0 : 8'd255;
				g_data_out <= (g_data_in > 8'd128) ? 8'd0 : 8'd255;
				b_data_out <= (b_data_in > 8'd128) ? 8'd0 : 8'd255;
			end
		end
		else
		begin
			r_data_out <= r_data_in;
			g_data_out <= g_data_in;
			b_data_out <= b_data_in;
		end
	end
	else
	begin
		r_data_out	<=	r_data_in;
		g_data_out	<=	g_data_in;
		b_data_out	<=	b_data_in;
	end
end

always @(posedge clk )
begin
	if (hcnt == X1 || hcnt == X2 || hcnt == X0)
	begin
		buf_index	<=	5'd0;
		cnt8			<=	3'd0;
		scale_h		<=	3'd0;
	end
	else if(scale_h == SCALE - 3'd1) 
	begin
		scale_h	<=	3'd0;
		if(cnt8 == 3'd7)
		begin
			cnt8			<=	3'd0;
			buf_index	<=	buf_index + 5'd1;
		end
		else
		begin
			cnt8	<=	cnt8 + 3'd1;
		end
	end
	else
	begin
		scale_h	<=	scale_h + 3'd1;
	end
end

always @(posedge clk )
begin
	if (vcnt == Y1 || vcnt == Y2 || vcnt == Y0)
	begin
		cnt16		<=	4'd0;
		scale_v	<=	8'd0;
	end
	else if (hcnt == 12'd1)
	begin
		if(scale_v == SCALE - 3'd1)
		begin
			scale_v	<=	8'd0;
			if(cnt16	== 4'd15)
			begin
				cnt16	<=	4'd0;
			end
			else
			begin
				cnt16	<=	cnt16 + 4'd1;
			end
		end
		else
		begin
			scale_v	<=	scale_v + 8'd1;
		end
	end
end

endmodule