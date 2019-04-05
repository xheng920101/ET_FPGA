// ****************************************************************************
// COPYRIGHT (c) 2014, Xiamen Tianma Microelectronics Co, Ltd
// All rights reserved.
//
// Author		:	xiaojing_zhan
// Email			:	xiaojing_zhan@tianma.cn
//
// File name	:	pat_gen.v
// Version		:	V 1.0
// Abstract		:	Generate basic test pattern
// Called by	:	display_control
//
// ----------------------------------------------------------------------------
// Revison 
// 2014-07-07	:	Create file.
// ****************************************************************************

module pat_gen(
	input						clk,
	input						rst_n,
	
	input		[11:0]		vsum,
	input		[11:0]		hsum,			//resolution 
	
	input		[11:0]		vcnt,			//row counter without blank
	input		[11:0]		hcnt,			//column counter without blank
	
	input		[7:0]			pat_num,		//pattern number
	input		[7:0]			pat_rval,	//red
	input		[7:0]			pat_gval,	//green
	input		[7:0]			pat_bval,	//blue
	input    [7:0]     	dot_r1,
	input    [7:0]     	dot_g1,
	input    [7:0]     	dot_b1,
	input    [7:0]     	dot_r2,
	input    [7:0]     	dot_g2,
	input    [7:0]     	dot_b2,
	input    [7:0]     	dot_r3,
	input    [7:0]     	dot_g3,
	input    [7:0]     	dot_b3,	
	input    [7:0]     	bg_r,
	input    [7:0]     	bg_g,
	input    [7:0]     	bg_b,
	input    [11:0]     	rect_start_x,
	input    [11:0]     	rect_start_y,
	input    [7:0]     	rect_size_x,
	input    [7:0]     	rect_size_y,
	
	output	[47:0]		pat_data
);

// ----------------------------------------------------------------------------
// Variable definition
// ----------------------------------------------------------------------------
reg	[7:0]		rbuf;
reg	[7:0]		gbuf;
reg	[7:0]		bbuf;

reg	[11:0]	vcnt1;
reg	[11:0]	hcnt1;	

// for pattern colorbar, graybar, chessboard, ect.
reg	[7:0]		h_div256_gry;
reg	[3:0]		h_div256_cnt;	//max 1080 / 256 = 4.21875, need 3 bits
reg	[7:0]		v_div256_gry;
reg	[3:0]		v_div256_cnt;	//max 1920 / 256 = 7.5, need 3 bits

// for pattern crosstalk
reg				h_sec2;
reg				h_sec3;
reg				h_sec4;
reg				h_sec6;
reg				h_sec12;
reg				v_sec2;
reg				v_sec3;
reg				v_sec4;

// --------------------------start: pattern------------------------//
// horizontal gray bar
reg	[7:0]		pat_gbar256_h;
reg	[7:0]		pat_gbar64_h;
reg	[7:0]		pat_gbar32_h;
reg	[7:0]		pat_gbar16_h;
reg	[7:0]		pat_gbar8_h;
reg	[7:0]		pat_gbar256_h1;
reg	[7:0]		pat_gbar64_h1;
reg	[7:0]		pat_gbar32_h1;
reg	[7:0]		pat_gbar16_h1;
reg	[7:0]		pat_gbar8_h1;

// vertical gray bar
reg	[7:0]		pat_gbar256_v;
reg	[7:0]		pat_gbar64_v;
reg	[7:0]		pat_gbar32_v;
reg	[7:0]		pat_gbar16_v;
reg	[7:0]		pat_gbar8_v;
reg	[7:0]		pat_gbar256_v1;
reg	[7:0]		pat_gbar64_v1;
reg	[7:0]		pat_gbar32_v1;
reg	[7:0]		pat_gbar16_v1;
reg	[7:0]		pat_gbar8_v1;

// diagonal gray bar
reg	[7:0]		pat_gbar256_diag;

// horizontal color bar
reg	[23:0]	pat_cbar_h;
reg	[23:0]	pat_cbar_h1;

// vertical color bar
reg	[23:0]	pat_cbar_v;
reg	[23:0]	pat_cbar_v1;

// htc specific color bar
reg	[23:0]	pat_cbar_htc;

// asus specific color bar
reg	[23:0]	pat_cbar_asus;

// lenovo specific color bar
reg	[23:0]	pat_cbar_lenovo;

//chess board
reg	[7:0]		pat_cesb64;		//64*64
reg	[7:0]		pat_cesb32;		//32*32
reg	[7:0]		pat_cesb16;		//16*16
reg	[7:0]		pat_cesb8;		//8*8
reg	[7:0]		pat_cesb4;		//4*4
reg	[7:0]		pat_cesb6;		//6*8
reg	[7:0]		pat_cesb12;		//12*20
reg	[7:0]		pat_cesb64_r;	//revese
reg	[7:0]		pat_cesb32_r;
reg	[7:0]		pat_cesb16_r;
reg	[7:0]		pat_cesb8_r;
reg	[7:0]		pat_cesb4_r;
reg	[7:0]		pat_cesb6_r;

//moto specific crosstalk
reg	[7:0]		pat_crst_moto1;		//v 1/4	h 1/3	corner black
reg	[7:0]		pat_crst_moto2;		//v 1/4	h 1/3	corner white
reg	[7:0]		pat_crst_moto3;		//v 1/4	h 1/6	up & down black
reg	[7:0]		pat_crst_moto4;		//v 1/4	h 1/6	up & down white
reg	[7:0]		pat_crst_moto5;		//v 1/4	h 1/3	left & right black
reg	[7:0]		pat_crst_moto6;		//v 1/4	h 1/3	left & right white

// samsung specific crosstalk
reg	[7:0]		pat_crst_samsung1;	//v 1/4	h 1/3	up & down black
reg	[7:0]		pat_crst_samsung2;	//v 1/4	h 1/3	up & down white
reg	[7:0]		pat_crst_samsung3;	//v 1/3	h 1/3	left & right black
reg	[7:0]		pat_crst_samsung4;	//v 1/3	h 1/3	left & right white
reg	[7:0]		pat_crst_samsung5;	//v 1/3	h 1/3	left & right 
reg	[7:0]		pat_crst_samsung6;	//v 1/3	h 1/3	up & down 

// haiwei specific crosstalk
reg	[7:0]		pat_crst_hw1;		//v 1/3	h 1/3	center black
reg	[7:0]		pat_crst_hw2;		//v 1/3	h 1/3	center white

// asus specific crosstalk
reg	[7:0]		pat_crst_asus1;		//v 1/4	h 1/4	center
reg	[7:0]		pat_crst_asus2;		//v 1/4	h 1/4	up & down
reg	[7:0]		pat_crst_asus3;		//v 1/4	h 1/4	left & right

// meizu specific crosstalk
reg	[7:0]		pat_crst_meizu1;		//left & right
reg	[7:0]		pat_crst_meizu2;		//left & right
reg	[7:0]		pat_crst_meizu3;		//left & right
reg	[7:0]		pat_crst_meizu4;		//up & down 
reg	[7:0]		pat_crst_meizu5;		//up & down 
reg	[7:0]		pat_crst_meizu6;		//up & down 

// sony specific crosstalk
reg	[7:0]		pat_crst_sony1;		//v 3/8	h 1/3	left & right
reg	[7:0]		pat_crst_sony2;		//v 2/8	h 1/3	up & down

// flicker crosstalk
reg	[23:0]	pat_crst_dot;
reg	[23:0]	pat_crst_pixel;
reg	[23:0]	pat_crst_column;
reg	[23:0]	pat_crst_pcolumn;

// dot flicker
reg	[23:0]	pat_flk_1dot;
reg	[23:0]	pat_flk_2dot;
reg	[23:0]	pat_flk_4dot;
reg	[23:0]	pat_flk_cln;

// pixcel flicker
reg	[23:0]	pat_flk_1pixel;
reg	[23:0]	pat_flk_2pixel;
reg	[23:0]	pat_flk_4pixel;
reg	[23:0]	pat_flk_pcln;

// red  dot flicker
reg	[23:0]	pat_flk_1dot_r;
reg	[23:0]	pat_flk_2dot_r;
reg	[23:0]	pat_flk_4dot_r;
reg	[23:0]	pat_flk_cln_r;

// green dot flicker
reg	[23:0]	pat_flk_1dot_g;
reg	[23:0]	pat_flk_2dot_g;
reg	[23:0]	pat_flk_4dot_g;
reg	[23:0]	pat_flk_cln_g;

// blue dot flicker
reg	[23:0]	pat_flk_1dot_b;
reg	[23:0]	pat_flk_2dot_b;
reg	[23:0]	pat_flk_4dot_b;
reg	[23:0]	pat_flk_cln_b;

// 1x1 bar
reg	[23:0]	pat_1x1_bar;
reg	[23:0]	pat_1x1_bar1;
reg	[23:0]	pat_1x1_bar2;
reg	[23:0]	pat_1x1_bar3;
reg	[23:0]	pat_1x1_dotbar;	//1x1 bar with dot flicker
reg	[23:0]	pat_1x1_dotbar1;

// outline detect
reg	[23:0]	pat_oln_det;		
reg	[23:0]	pat_oln_det1;		
reg	[23:0]	pat_oln_det2;		
reg	[23:0]	pat_oln_det3;		
reg	[23:0]	pat_oln_det4;	

// colorbar + graybar
reg	[23:0]	pat_cbar_gry;
reg	[23:0]	pat_cbar_gry256;

// crosstalk board
reg	[7:0]		pat_crs_brd;

// full screen character
reg	[23:0]	pat_character;

// htc specific bright dot
reg	[23:0]	bright_dot;
reg	[23:0]	black_dot;

// center black with waku
reg	[23:0]	pat_crst_waku;

// OTP check warning
reg	[23:0]	pat_otp_check;

// OTP NG warning
reg	[23:0]	pat_otp_NG;

// message
reg	[23:0]	pat_message;

// cross at center
reg	[7:0]		pat_cross_black;
reg	[7:0]		pat_cross_white;

// mark
reg	[7:0]		pat_mark;

// gray RGB bar
reg	[23:0]	pat_gcbar;

// gray bar
reg	[7:0]		pat_gbar;

// RGB bar
reg	[23:0]	pat_RGBbar;
reg	[23:0]	pat_GBbar;

// crosstalk
reg	[23:0]	pat_crst_hw_new;
reg	[23:0]	pat_crst_hw_new1;
reg	[23:0]	pat_crst_hw_new2;
reg	[23:0]	pat_crst_hw_snake1;
reg	[23:0]	pat_crst_hw_snake2;
reg   [23:0]   pat_crst_hw_gradients;

// center rect
reg	[23:0]	pat_center_rect;

// gray bar
reg	[7:0]		pat_wb;

// RGBW
reg	[23:0]	pat_JDI_pixel_white;
reg	[23:0]	pat_JDI_RGB_white;
// --------------------------end: pattern------------------------//

// ----------------------------------------------------------------------------
// Continuous assignment
// ----------------------------------------------------------------------------
assign	pat_data	=	{rbuf, gbuf, bbuf, rbuf, gbuf, bbuf};

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		vcnt1	<= 1'b0;
		hcnt1	<=	1'b0;
	end
	else
	begin
		vcnt1	<= vcnt;
		hcnt1	<=	hcnt;
	end
end

//-----------------------------------------------------------------------------
// For pattern crosstalk
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		h_sec2	<= 1'b0;
		h_sec3	<=	1'b0;
		h_sec4	<=	1'b0;
		h_sec6	<=	1'b0;
		h_sec12	<=	1'b0;
	end
	else
	begin
		case (hsum)
		12'd360:
			begin
				h_sec2	<=	(hcnt >= 0) && (hcnt < 180);		//area: 0 ~ 1/2*360
				h_sec3	<=	(hcnt >= 120) && (hcnt < 240);	//area: 1/3*360 ~ 2/3*360
				h_sec4	<=	(hcnt >= 90) && (hcnt < 270);		//area: 1/4*360 ~ 3/4*360 
				h_sec6	<=	(hcnt >= 60) && (hcnt < 300);		//area: 1/6*360 ~ 5/6*360
				h_sec12	<=	(hcnt >= 150) && (hcnt < 210);	//area: 5/12*360 ~ 7/12*360
			end
		12'd720:
			begin
				h_sec2	<=	(hcnt >= 0) && (hcnt < 360);		//area: 0 ~ 1/2*720
				h_sec3	<=	(hcnt >= 240) && (hcnt < 480);	//area: 1/3*720 ~ 2/3*720
				h_sec4	<=	(hcnt >= 180) && (hcnt < 540);	//area: 1/4*720 ~ 3/4*720 
				h_sec6	<=	(hcnt >= 120) && (hcnt < 600);	//area: 1/6*720 ~ 5/6*720
				h_sec12	<=	(hcnt >= 300) && (hcnt < 420);	//area: 5/12*720 ~ 7/12*720
			end
		12'd1080:
			begin
				h_sec2	<=	(hcnt >= 0) && (hcnt < 540);		//area: 0 ~ 1/2*1080
				h_sec3	<=	(hcnt >= 360) && (hcnt < 720);	//area: 1/3*1080 ~ 2/3*1080
				h_sec4	<=	(hcnt >= 270) && (hcnt < 810);	//area: 1/4*1080 ~ 3/4*1080
				h_sec6	<=	(hcnt >= 180) && (hcnt < 900);	//area: 1/6*1080 ~ 5/6*1080
				h_sec12	<=	(hcnt >= 450) && (hcnt < 630);	//area: 5/12*1080 ~ 7/12*1080
			end
		default:
			begin
				h_sec2	<=	1'b0;
				h_sec3	<=	1'b0;
				h_sec4	<=	1'b0;
				h_sec6	<=	1'b0;
				h_sec12	<=	1'b0;
			end
		endcase		
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		v_sec2	<=	1'b0;
		v_sec3	<=	1'b0;
		v_sec4	<=	1'b0;
	end
	else
	begin
		case (vsum)
		12'd326:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 163);		//area: 0 ~ 1/2 326
				v_sec3	<=	(vcnt >= 109) && (vcnt < 217);	//area: 1/3 326 ~ 2/3 326
				v_sec4	<=	(vcnt >= 82) && (vcnt < 244);	//area: 1/4 326 ~ 3/4 326
			end
		12'd1280:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 640);		//area: 0 ~ 1/2 1280
				v_sec3	<=	(vcnt >= 426) && (vcnt < 853);	//area: 1/3 1280 ~ 2/3 1280
				v_sec4	<=	(vcnt >= 320) && (vcnt < 960);	//area: 1/4 1280 ~ 3/4 1280
			end
		12'd1920:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 960);		//area: 0 ~ 1/2 1920
				v_sec3	<=	(vcnt >= 640) && (vcnt < 1280);	//area: 1/3 1920 ~ 2/3 1920
				v_sec4	<=	(vcnt >= 480) && (vcnt < 1440);	//area: 1/4 1920 ~ 3/4 1920
			end
		12'd2160:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1080);		//area: 0 ~ 1/2 2160
				v_sec3	<=	(vcnt >= 720) && (vcnt < 1440);	//area: 1/3 2160 ~ 2/3 2160
				v_sec4	<=	(vcnt >= 540) && (vcnt < 1620);	//area: 1/4 2160 ~ 3/4 2160
			end
		12'd2100:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1050);		//area: 0 ~ 1/2 2100
				v_sec3	<=	(vcnt >= 700) && (vcnt < 1400);	//area: 1/3 2100 ~ 2/3 2100
				v_sec4	<=	(vcnt >= 525) && (vcnt < 1575);	//area: 1/4 2100 ~ 3/4 2100
			end
		12'd2244:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1122);		//area: 0 ~ 1/2 2244
				v_sec3	<=	(vcnt >= 748) && (vcnt < 1496);	//area: 1/3 2244 ~ 2/3 2244
				v_sec4	<=	(vcnt >= 561) && (vcnt < 1683);	//area: 1/4 2244 ~ 3/4 2244
			end
		12'd2400:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1200);		//area: 0 ~ 1/2 2400
				v_sec3	<=	(vcnt >= 800) && (vcnt < 1600);	//area: 1/3 2400 ~ 2/3 2400
				v_sec4	<=	(vcnt >= 600) && (vcnt < 1800);	//area: 1/4 2400 ~ 3/4 2400
			end
		12'd2266:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1133);		//area: 0 ~ 1/2 2266
				v_sec3	<=	(vcnt >= 755) && (vcnt < 1511);	//area: 1/3 2266 ~ 2/3 2266
				v_sec4	<=	(vcnt >= 566) && (vcnt < 1700);	//area: 1/4 2266 ~ 3/4 2266
			end
		12'd2280:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1140);		//area: 0 ~ 1/2 2280
				v_sec3	<=	(vcnt >= 760) && (vcnt < 1520);	//area: 1/3 2280 ~ 2/3 2280
				v_sec4	<=	(vcnt >= 570) && (vcnt < 1710);	//area: 1/4 2280 ~ 3/4 2280
			end
		12'd1520:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 760);		//area: 0 ~ 1/2 1520
				v_sec3	<=	(vcnt >= 507) && (vcnt < 1013);	//area: 1/3 1520 ~ 2/3 1520
				v_sec4	<=	(vcnt >= 380) && (vcnt < 1140);	//area: 1/4 1520 ~ 3/4 1520
			end
		12'd2340:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1170);		//area: 0 ~ 1/2 2340
				v_sec3	<=	(vcnt >= 780) && (vcnt < 1560);	//area: 1/3 2340 ~ 2/3 2340
				v_sec4	<=	(vcnt >= 585) && (vcnt < 1755);	//area: 1/4 2340 ~ 3/4 2340
			end
		12'd2246:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1123);		//area: 0 ~ 1/2 2246
				v_sec3	<=	(vcnt >= 749) && (vcnt < 1497);	//area: 1/3 2246 ~ 2/3 2246
				v_sec4	<=	(vcnt >= 562) && (vcnt < 1684);	//area: 1/4 2246 ~ 3/4 2246
			end
		12'd2310:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1155);		//area: 0 ~ 1/2 2310
				v_sec3	<=	(vcnt >= 770) && (vcnt < 1540);	//area: 1/3 2310 ~ 2/3 2310
				v_sec4	<=	(vcnt >= 577) && (vcnt < 1733);	//area: 1/4 2310 ~ 3/4 2310
			end
		12'd2312:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1156);		//area: 0 ~ 1/2 2312
				v_sec3	<=	(vcnt >= 771) && (vcnt < 1541);	//area: 1/3 2312 ~ 2/3 2312
				v_sec4	<=	(vcnt >= 578) && (vcnt < 1734);	//area: 1/4 2312 ~ 3/4 2312
			end			
		12'd2520:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1260);		//area: 0 ~ 1/2 2520
				v_sec3	<=	(vcnt >= 840) && (vcnt < 1680);	//area: 1/3 2520 ~ 2/3 2520
				v_sec4	<=	(vcnt >= 630) && (vcnt < 1890);	//area: 1/4 2520 ~ 3/4 2520
			end
		12'd2270:
			begin
				v_sec2	<=	(vcnt >= 0) && (vcnt < 1135);		//area: 0 ~ 1/2 2270
				v_sec3	<=	(vcnt >= 756) && (vcnt < 1514);	//area: 1/3 2270 ~ 2/3 2270
				v_sec4	<=	(vcnt >= 567) && (vcnt < 1703);	//area: 1/4 2270 ~ 3/4 2270
			end
		default:
			begin
				v_sec2	<=	1'b0;
				v_sec3	<=	1'b0;
				v_sec4	<=	1'b0;
			end
		endcase
	end
end

//-----------------------------------------------------------------------------
// For pattern colorbar, graybar, chessboard, ect.
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		h_div256_gry	<=	8'd0;
		h_div256_cnt	<=	4'd0;
	end
	else if (hcnt > 12'd0)
	begin
		case (hsum)
		12'd360:
		// 360 / 256 = 1.40625
		// 13 / 0.40625 = 32
		// 256 * 13 / 32 = 104
		// 2 x 104 + 1 x 152 = 360
			begin
				if (h_div256_gry < 8'd24 || h_div256_gry >= 8'd232)  
				begin
					h_div256_gry	<=	h_div256_gry + 8'd1;
				end
				else
				begin
					if (h_div256_cnt == 3'd1)
					begin
						h_div256_gry	<=	h_div256_gry + 8'd1;
						h_div256_cnt	<=	{2'd0, h_div256_gry[0]};
					end
					else
					begin
						h_div256_gry	<=	h_div256_gry;
						h_div256_cnt	<=	h_div256_cnt + 3'd1;
					end
				end
			end
		12'd720:
		// 720 / 256 = 2.8125
		// 3 / 0.1875 = 16
		// 256 * 3 / 16 = 48
		// 3 x 208 + 2 x 48 = 720
			begin
				if (h_div256_gry < 8'd80 || h_div256_gry >= 8'd176)  
				begin
					if (h_div256_cnt == 3'd2)
					begin
						h_div256_gry	<=	h_div256_gry + 8'd1;
						h_div256_cnt	<=	3'd0;
					end
					else
					begin
						h_div256_gry	<=	h_div256_gry;
						h_div256_cnt	<=	h_div256_cnt + 3'd1;
					end
				end
				else
				begin
					if (h_div256_cnt == 3'd2)
					begin
						h_div256_gry	<=	h_div256_gry + 8'd1;
						h_div256_cnt	<=	{2'd0, h_div256_gry[0]};
					end
					else
					begin
						h_div256_gry	<=	h_div256_gry;
						h_div256_cnt	<=	h_div256_cnt + 3'd1;
					end
				end
			end
		12'd1080:
		// 1080 / 256 = 4.21875
		// 7 / 0.21875 = 32
		// 256 * 7 / 32 = 56
		// 4 x 200 + 5 x 56 = 1080
			begin
				if (h_div256_gry < 8'd72 || h_div256_gry >= 8'd184)  
				begin
					if (h_div256_cnt == 3'd3)
					begin
						h_div256_gry	<=	h_div256_gry + 8'd1;
						h_div256_cnt	<=	3'd0;
					end
					else
					begin
						h_div256_gry	<=	h_div256_gry;
						h_div256_cnt	<=	h_div256_cnt + 3'd1;
					end
				end
				else
				begin
					if (h_div256_cnt == 3'd4)
					begin
						h_div256_gry	<=	h_div256_gry + 8'd1;
						h_div256_cnt	<=	{2'd0, h_div256_gry[0]};
					end
					else
					begin
						h_div256_gry	<=	h_div256_gry;
						h_div256_cnt	<=	h_div256_cnt + 3'd1;
					end
				end
			end
		default:
			begin
				h_div256_gry	<=	8'd0;
				h_div256_cnt	<=	4'd0;
			end
		endcase
	end
	else
	begin
		h_div256_gry	<=	8'd0;
		h_div256_cnt	<=	4'd0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		v_div256_gry	<=	8'd0;
		v_div256_cnt	<=	4'd0;
	end
	else if (vcnt > 12'd0)
	begin
		if (hcnt1 == hsum - 12'd1)
		begin
			case (vsum)
			12'd326:
			// 326 / 256 = 1.2734375
			// 35 / 0.2734375 = 128
			// 256 * 35 / 128 = 70
			// 2 * 70 + 1 * 186 = 326
				begin
					if (v_div256_gry < 8'd58 || v_div256_gry >= 8'd198)  
					begin
						v_div256_gry	<=	v_div256_gry + 8'd1;
					end
					else
					begin
						if (v_div256_cnt == 3'd1)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{2'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 3'd1;
						end
					end
				end
			12'd1280:
			// 1280 / 256 = 5.
				begin
					if (v_div256_cnt == 3'd4)
					begin
						v_div256_gry	<=	v_div256_gry + 8'd1;
						v_div256_cnt	<=	3'd0;
					end
					else
					begin
						v_div256_gry	<=	v_div256_gry;
						v_div256_cnt	<=	v_div256_cnt + 3'd1;
					end
				end
			12'd1920:
			// 1920 / 256 = 7.5
			// 7*128 + 8*128 = 1920
				begin
					if (v_div256_cnt == 3'd7)
					begin
						v_div256_gry	<=	v_div256_gry + 8'd1;
						v_div256_cnt	<=	{2'd0, v_div256_gry[0]};
					end
					else
					begin
						v_div256_gry	<=	v_div256_gry;
						v_div256_cnt	<=	v_div256_cnt + 3'd1;
					end
				end
			12'd2160:
			// 2160 / 256 = 8.4375
			// 7 / 0.4375 = 16
			// 256 / 16 * 7 = 112
			// 9 * 112 + 8 * 144 = 2160
				begin
					if (v_div256_gry < 8'd32)  
					begin
						if (v_div256_cnt == 4'd7)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2100:
			// 2100 / 256 = 8.203125
			// 13 / 0.203125 = 64
			// 256 / 64 * 13 = 52
			// 9 * 52 + 8 * 204 = 2100
				begin
					if (v_div256_gry < 8'd152)  
					begin
						if (v_div256_cnt == 4'd7)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2244:
			// 2244 / 256 = 8.765625
			// 49 / 0.765625 = 64
			// 256 / 64 * 49 = 196
			// 9 * 196 + 8 * 60 = 2244
				begin
					if (v_div256_gry < 8'd136)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2400:
			// 2400 / 256 = 9.375
			// 3 / 0.375 = 8
			// 256 / 8 * 3 = 96
			// 10 * 96 + 9 * 160 = 2400
				begin
					if (v_div256_gry < 8'd64)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd9)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2266:
			// 2266 / 256 = 8.8515625
			// 109 / 0.8515625 = 128
			// 256 / 128 * 109 = 218
			// 9 * 218 + 8* 38 = 2266
				begin
					if (v_div256_gry < 8'd180)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2280:
			// 2280 / 256 = 8.90625
			// 29 / 0.90625 = 32
			// 256 / 32 * 29 = 232
			// 9 * 232 + 8 * 24 = 2280
				begin
					if (v_div256_gry < 8'd208)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd1520:
			// 1520 / 256 = 5.9375
			// 15 / 0.9375 = 16
			// 256 / 16 * 15 = 240
			// 6 * 240 + 5 * 16 = 1520
				begin
					if (v_div256_gry < 8'd224)  
					begin
						if (v_div256_cnt == 4'd5)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd5)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2340:
			// 2340 / 256 = 9.140625
			// 9 / 0.140625 = 64
			// 256 / 64 * 9 = 36
			// 10 * 36 + 9 * 220 = 2340
				begin
					if (v_div256_gry < 8'd184)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd9)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2246:
			// 2246 / 256 = 8.7734375
			// 99 / 0.7734375 = 128
			// 256 / 128 * 99 = 198
			// 9 * 198 + 8 * 58 = 2246
				begin
					if (v_div256_gry < 8'd140)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2310:
			// 2310 / 256 = 9.0234375
			// 3 / 0.0234375 = 128
			// 256 / 128 * 3 = 6
			// 9 * 250 + 10 * 6 = 2310
				begin
					if (v_div256_gry < 8'd244)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd9)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2312:
			// 2312 / 256 = 9.03125
			// 1 / 0.03125 = 32
			// 256 / 32 * 1 = 8
			// 9 * 248 + 10 * 8 = 2312
				begin
					if (v_div256_gry < 8'd240)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd9)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2520:
			// 2520 / 256 = 9.84375
			// 27 / 0.84375 = 32
			// 256 / 32 * 27 = 216
			// 10 * 216 + 9 * 40 = 2520
				begin
					if (v_div256_gry < 8'd176)  
					begin
						if (v_div256_cnt == 4'd9)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd9)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			12'd2270:
			// 2270 / 256 = 8.8671875
			// 111 / 0.8671875 = 128
			// 256 / 128 * 111 = 222
			// 9 * 222 + 8 * 34 = 2270
				begin
					if (v_div256_gry < 8'd188)  
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	4'd0;
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
					else
					begin
						if (v_div256_cnt == 4'd8)
						begin
							v_div256_gry	<=	v_div256_gry + 8'd1;
							v_div256_cnt	<=	{3'd0, v_div256_gry[0]};
						end
						else
						begin
							v_div256_gry	<=	v_div256_gry;
							v_div256_cnt	<=	v_div256_cnt + 4'd1;
						end
					end
				end
			default:
				begin
					v_div256_gry	<=	8'd0;
					v_div256_cnt	<=	4'd1;
				end
			endcase
		end
	end
	else 
	begin
		v_div256_gry	<=	8'd0;
		v_div256_cnt	<=	4'd1;
	end
end

//-----------------------------------------------------------------------------
// Various pattern generation
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Pattern: horizontal gray bar (256 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar256_h	<=	8'd0;
		pat_gbar256_h1	<=	8'd0;
	end
	else
	begin
		pat_gbar256_h	<=	v_div256_gry;
		pat_gbar256_h1	<=	8'd255 - v_div256_gry;
	end
end

//-----------------------------------------------------------------------------
// Pattern: horizontal gray bar (64 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar64_h	<=	8'd0;
		pat_gbar64_h1	<=	8'd0;
	end
	else
	begin
		pat_gbar64_h	<=	{v_div256_gry[7:2], 2'b0};
		pat_gbar64_h1	<=	8'd255 - {v_div256_gry[7:2], 2'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: horizontal gray bar (32 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar32_h	<=	8'd0;
		pat_gbar32_h1	<=	8'd0;
	end
	else
	begin
		pat_gbar32_h	<=	{v_div256_gry[7:3], 3'b0};
		pat_gbar32_h1	<=	8'd255 - {v_div256_gry[7:3], 3'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: horizontal gray bar (16 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar16_h	<=	8'd0;
		pat_gbar16_h1	<=	8'd0;
	end
	else
	begin
		pat_gbar16_h	<=	{v_div256_gry[7:4], 4'b0};
		pat_gbar16_h1	<=	8'd255 - {v_div256_gry[7:4], 4'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: horizontal gray bar (8 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar8_h		<=	8'd0;
		pat_gbar8_h1	<=	8'd0;
	end
	else
	begin
		pat_gbar8_h		<=	{v_div256_gry[7:5], 5'b0};
		pat_gbar8_h1	<=	8'd255 - {v_div256_gry[7:5], 5'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical gray bar (256 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar256_v	<=	8'd0;
		pat_gbar256_v1	<=	8'd0;
	end
	else
	begin
		pat_gbar256_v	<=	h_div256_gry;
		pat_gbar256_v1	<=	8'd255 - h_div256_gry;
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical gray bar (64 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar64_v	<=	8'd0;
		pat_gbar64_v1	<=	8'd0;
	end
	else
	begin
		pat_gbar64_v	<=	{h_div256_gry[7:2], 2'b0};
		pat_gbar64_v1	<=	8'd255 - {h_div256_gry[7:2], 2'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical gray bar (32 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar32_v	<=	8'd0;
		pat_gbar32_v1	<=	8'd0;
	end
	else
	begin
		pat_gbar32_v	<=	{h_div256_gry[7:3], 3'b0};
		pat_gbar32_v1	<=	8'd255 - {h_div256_gry[7:3], 3'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical gray bar (16 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar16_v	<=	8'd0;
		pat_gbar16_v1	<=	8'd0;
	end
	else
	begin
		pat_gbar16_v	<=	{h_div256_gry[7:4], 4'b0};
		pat_gbar16_v1	<=	8'd255 - {h_div256_gry[7:4], 4'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical gray bar (8 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar8_v		<= 8'd0;
		pat_gbar8_v1	<= 8'd0;
	end
	else
	begin
		pat_gbar8_v		<=	{h_div256_gry[7:5], 5'b0};
		pat_gbar8_v1	<=	8'd255 - {h_div256_gry[7:5], 5'b0};
	end
end

//-----------------------------------------------------------------------------
// Pattern: horizontal color bar (64 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_h	<=	24'h000000;
		pat_cbar_h1	<=	24'h000000;
	end
	else
	begin
		pat_cbar_h	<=	{{8{v_div256_gry[7]}}, {8{v_div256_gry[6]}}, {8{v_div256_gry[5]}}};
		pat_cbar_h1	<=	{{8{~v_div256_gry[7]}}, {8{~v_div256_gry[6]}}, {8{~v_div256_gry[5]}}};
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical color bar (64 level)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_v	<= 24'h000000;
		pat_cbar_v1	<= 24'h000000;
	end
	else
	begin
		pat_cbar_v	<=	{{8{h_div256_gry[7]}}, {8{h_div256_gry[6]}}, {8{h_div256_gry[5]}}};
		pat_cbar_v1	<=	{{8{~h_div256_gry[7]}}, {8{~h_div256_gry[6]}}, {8{~h_div256_gry[5]}}};
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (64 x 64)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb64		<=	8'd0;
		pat_cesb64_r	<=	8'd0;
	end
	else
	begin
		if (h_div256_gry[2] == v_div256_gry[2])
		begin
			pat_cesb64		<=	8'd255;
			pat_cesb64_r	<=	8'd0;
		end
		else
		begin
			pat_cesb64		<=	8'd0;
			pat_cesb64_r	<=	8'd255;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (32 x 32)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb32		<=	8'd0;
		pat_cesb32_r	<=	8'd0;
	end
	else
	begin
		if (h_div256_gry[3] == v_div256_gry[3])
		begin
			pat_cesb32		<=	8'd255;
			pat_cesb32_r	<=	8'd0;
		end
		else
		begin
			pat_cesb32		<=	8'd0;
			pat_cesb32_r	<=	8'd255;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (16 x 16)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb16		<=	8'd0;
		pat_cesb16_r	<=	8'd0;
	end
	else
	begin
		if (h_div256_gry[4] == v_div256_gry[4])
		begin
			pat_cesb16		<=	8'd255;
			pat_cesb16_r	<=	8'd0;
		end
		else
		begin
			pat_cesb16		<=	8'd0;
			pat_cesb16_r	<=	8'd255;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (8 x 8)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb8	<=	8'd0;
		pat_cesb8_r	<=	8'd0;
	end
	else
	begin
		if (h_div256_gry[5] == v_div256_gry[5])
		begin
			pat_cesb8	<=	8'd255;
			pat_cesb8_r	<=	8'd0;
		end
		else
		begin
			pat_cesb8	<=	8'd0;
			pat_cesb8_r	<=	8'd255;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (4 x 4)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb4	<=	8'd0;
		pat_cesb4_r	<=	8'd0;
	end
	else
	begin
		if (h_div256_gry[6] == v_div256_gry[6])
		begin
			pat_cesb4	<=	8'd255;
			pat_cesb4_r	<=	8'd0;
		end
		else
		begin
			pat_cesb4	<=	8'd0;
			pat_cesb4_r	<=	8'd255;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (6 x 8)
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb6	<=	8'd0;
		pat_cesb6_r	<=	8'd0;
	end
	else
	begin
		if (v_div256_gry[5] == 1'b1)
		begin
			if ((h_sec6 ^ h_sec3) == h_sec2)
			begin
				pat_cesb6	<=	8'd255;
				pat_cesb6_r	<=	8'd0;
			end
			else
			begin
				pat_cesb6	<=	8'd0;
				pat_cesb6_r	<=	8'd255;
			end
		end
		else
		begin
			if ((h_sec6 ^ h_sec3) == h_sec2)
			begin
				pat_cesb6	<=	8'd0;
				pat_cesb6_r	<=	8'd255;
			end
			else
			begin
				pat_cesb6 <= 8'd255;
				pat_cesb6_r <= 8'd0;
			end
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: chess borad (12 x 20)
//-----------------------------------------------------------------------------
reg[7:0] hsec;
reg[7:0] hsec_cnt;
reg[7:0] hsec_size;
reg[7:0] vsec;
reg[7:0] vsec_cnt;
reg[7:0] vsec_size;
wire[7:0] HS;
wire[7:0] VS;

assign HS = (pat_num == 8'd93) ? hsec_size : pat_gval;
assign VS = (pat_num == 8'd93) ? vsec_size : pat_bval;

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsec_size <= 8'd0;
	end
	else
	begin
		case (hsum)
		12'd360:
			begin
				hsec_size <= 8'd29;
			end
		12'd720:
			begin
				hsec_size <= 8'd59;
			end
		12'd1080:
			begin
				hsec_size <= 8'd89;
			end
		default:
			begin
				hsec_size <= 8'd59;
			end
		endcase	
	end	
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		vsec_size <= 8'd0;
	end
	else
	begin
		case (vsum)
		12'd326:
			begin
				vsec_size <= 8'd15;
			end
		12'd1280:
			begin
				vsec_size <= 8'd63;
			end
		12'd1920:
			begin
				vsec_size <= 8'd95;
			end
		12'd2160:
			begin
				vsec_size <= 8'd107;
			end
		12'd2100:
			begin
				vsec_size <= 8'd104;
			end
		12'd2244:
			begin
				vsec_size <= 8'd111;
			end
		12'd2400:
			begin
				vsec_size <= 8'd119;
			end
		12'd2266:
			begin
				vsec_size <= 8'd112;
			end
		12'd2280:
			begin
				vsec_size <= 8'd113;
			end
		12'd1520:
			begin
				vsec_size <= 8'd75;
			end
		12'd2340:
			begin
				vsec_size <= 8'd116;
			end
		12'd2246:
			begin
				vsec_size <= 8'd111;
			end
		12'd2310:
			begin
				vsec_size <= 8'd114;
			end
		12'd2312:
			begin
				vsec_size <= 8'd114;
			end
		12'd2520:
			begin
				vsec_size <= 8'd125;
			end
		12'd2270:
			begin
				vsec_size <= 8'd112;
			end
		default:
			begin
				vsec_size <= 8'd63;
			end
		endcase	
	end	
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsec	<=	8'd0;
		hsec_cnt <= 8'd0;
	end
	else if (hcnt > 12'd0)
	begin
		if (hsec_cnt == HS)
		begin
			if (hsum - hcnt > (HS >> 1'b1))
			begin
				hsec	<=	hsec + 8'd1;
			end
			hsec_cnt <= 8'd0;
		end
		else
		begin
			hsec_cnt <= hsec_cnt + 8'd1;
		end
	end
	else
	begin
		hsec	<=	8'd0;
		hsec_cnt <= 8'd0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		vsec	<=	8'd0;
		vsec_cnt <= 8'd0;
	end
	else if (vcnt > 12'd0)
	begin
		if (hcnt == hsum - 11'd1)
		begin
			if (vsec_cnt == VS)
			begin
				if (vsum - vcnt > (VS >> 1'b1))
				begin
					vsec	<=	vsec + 8'd1;
				end			
				vsec_cnt <= 8'd0;	
			end
			else
			begin
				vsec_cnt <= vsec_cnt + 8'd1;
			end
		end
	end
	else
	begin
		vsec	<=	8'd0;
		vsec_cnt <= 8'd0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cesb12	<=	8'd0;
	end
	else
	begin
		if ((vsec[0] ^ hsec[0]) == 1'b0)
		begin
			pat_cesb12	<=	pat_rval;
		end
		else
		begin
			pat_cesb12	<=	~pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - moto spec, four corner area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_moto1	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_sec4 == 1'b0))
		begin
			pat_crst_moto1	<=	8'd0;
		end
		else
		begin
			pat_crst_moto1	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - moto spec, four corner area white
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_moto2	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_sec4 == 1'b0))
		begin
			pat_crst_moto2	<=	8'd255;
		end
		else
		begin
			pat_crst_moto2	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - moto spec, up & down area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_moto3	<=	8'd0;
	end
	else
	begin
		if ((h_sec6 == 1'b1) && (v_sec4 == 1'b0))
		begin
			pat_crst_moto3	<=	8'd0;
		end
		else
		begin
			pat_crst_moto3	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - moto spec, up & down area white
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_moto4 <= 8'd0;
	end
	else
	begin
		if ((h_sec6 == 1'b1) && (v_sec4 == 1'b0))
		begin
			pat_crst_moto4 <= 8'd255;
		end
		else
		begin
			pat_crst_moto4 <= pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - moto spec, left & right area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_moto5	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_sec4 == 1'b1))
		begin
			pat_crst_moto5	<=	8'd0;
		end
		else
		begin
			pat_crst_moto5	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - moto spec, left & right area white
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_moto6	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_sec4 == 1'b1))
		begin
			pat_crst_moto6	<=	8'd255;
		end
		else
		begin
			pat_crst_moto6	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - samsung spec, up & down area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_samsung1	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec4 == 1'b0))
		begin
			pat_crst_samsung1	<=	8'd0;
		end
		else
		begin
			pat_crst_samsung1	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - samsung spec, up & down area white
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_samsung2	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec4 == 1'b0))
		begin
			pat_crst_samsung2	<=	8'd255;
		end
		else
		begin
			pat_crst_samsung2	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - samsung spec, left & right area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_samsung3	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_sec3 == 1'b1))
		begin
			pat_crst_samsung3	<=	8'd0;
		end
		else
		begin
			pat_crst_samsung3	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - samsung spec, left & right area white
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_samsung4	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_sec3 == 1'b1))
		begin
			pat_crst_samsung4	<=	8'd255;
		end
		else
		begin
			pat_crst_samsung4	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - huawei spec, middle area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw1	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_hw1	<=	8'd0;
		end
		else
		begin
			pat_crst_hw1	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - huawei spec, middle area white
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw2	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_hw2	<=	8'd255;
		end
		else
		begin
			pat_crst_hw2	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - asus spec, middle area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_asus1	<=	8'd0;
	end
	else
	begin
		if ((h_sec4 == 1'b1) && (v_sec4 == 1'b1))
		begin
			pat_crst_asus1	<=	pat_gval;
		end
		else
		begin
			pat_crst_asus1	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - asus spec, left & right area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_asus2	<=	8'd0;
	end
	else
	begin
		if ((h_sec4 == 1'b0) && (v_sec4 == 1'b1))
		begin
			pat_crst_asus2	<=	pat_gval;
		end
		else
		begin
			pat_crst_asus2	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - asus spec, up & down area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_asus3	<=	8'd0;
	end
	else
	begin
		if ((h_sec4 == 1'b1) && (v_sec4 == 1'b0))
		begin
			pat_crst_asus3	<=	pat_gval;
		end
		else
		begin
			pat_crst_asus3	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - meizu spec, left & right area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_meizu1	<=	8'd0;
	end
	else
	begin
		if ((vcnt >= (vsum >> 1) - {pat_gval[3:0], pat_bval}) && (vcnt < (vsum >> 1) + {pat_gval[3:0], pat_bval})
		&& ((hcnt < (hsum >> 1) - {pat_gval[3:0], pat_bval}) || (hcnt >= (hsum >> 1) + {pat_gval[3:0], pat_bval})))
		begin
			pat_crst_meizu1	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_meizu1	<=	pat_rval;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_meizu2	<=	8'd0;
	end
	else
	begin
		if ((vcnt >= (vsum >> 1) - {pat_gval[3:0], pat_bval}) && (vcnt < (vsum >> 1) + {pat_gval[3:0], pat_bval})
		&& ((hcnt < (hsum >> 2) - {pat_gval[3:0], pat_bval}) || (hcnt >= (hsum >> 2) + {pat_gval[3:0], pat_bval})))
		begin
			pat_crst_meizu2	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_meizu2	<=	pat_rval;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_meizu3	<=	8'd0;
	end
	else
	begin
		if ((vcnt >= (vsum >> 1) - {pat_gval[3:0], pat_bval}) && (vcnt < (vsum >> 1) + {pat_gval[3:0], pat_bval})
		&& ((hcnt < (hsum >> 1) + (hsum >> 2) - {pat_gval[3:0], pat_bval}) || (hcnt >= (hsum >> 1) + (hsum >> 2) + {pat_gval[3:0], pat_bval})))
		begin
			pat_crst_meizu3	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_meizu3	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - meizu spec, up & down area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_meizu4	<=	8'd0;
	end
	else
	begin
		if ((hcnt >= (hsum >> 1) - {pat_gval[3:0], pat_bval}) && (hcnt < (hsum >> 1) + {pat_gval[3:0], pat_bval})
		&& ((vcnt < (vsum >> 1) - {pat_gval[3:0], pat_bval}) || (vcnt >= (vsum >> 1) + {pat_gval[3:0], pat_bval})))
		begin
			pat_crst_meizu4	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_meizu4	<=	pat_rval;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_meizu5	<=	8'd0;
	end
	else
	begin
		if ((hcnt >= (hsum >> 1) - {pat_gval[3:0], pat_bval}) && (hcnt < (hsum >> 1) + {pat_gval[3:0], pat_bval})
		&& ((vcnt < (vsum >> 2) - {pat_gval[3:0], pat_bval}) || (vcnt >= (vsum >> 2) + {pat_gval[3:0], pat_bval})))
		begin
			pat_crst_meizu5	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_meizu5	<=	pat_rval;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_meizu6	<=	8'd0;
	end
	else
	begin
		if ((hcnt >= (hsum >> 1) - {pat_gval[3:0], pat_bval}) && (hcnt < (hsum >> 1) + {pat_gval[3:0], pat_bval})
		&& ((vcnt < (vsum >> 1) + (vsum >> 2) - {pat_gval[3:0], pat_bval}) || (vcnt >= (vsum >> 1) + (vsum >> 2) + {pat_gval[3:0], pat_bval})))
		begin
			pat_crst_meizu6	<= {8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_meizu6	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - sony spec, left & right area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_sony1	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b0) && (v_div256_gry[7:5] == 3'd3 || v_div256_gry[7:5] == 3'd4))
		begin
			pat_crst_sony1	<=	pat_gval;
		end
		else
		begin
			pat_crst_sony1	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - sony spec, up & down area 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_sony2	<=	8'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_div256_gry[7:5] < 3'd3 || v_div256_gry[7:5] > 3'd4))
		begin
			pat_crst_sony2	<=	pat_gval;
		end
		else
		begin
			pat_crst_sony2	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - 1 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_1dot	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[0] == hcnt1[0])
		begin
			pat_flk_1dot	<=	{pat_rval, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_1dot	<=	{8'd0, pat_rval, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - 2 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_2dot	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[1] == hcnt1[0])
		begin
			pat_flk_2dot	<=	{pat_rval, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_2dot	<=	{8'd0, pat_rval, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - 4 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_4dot	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[2] == hcnt1[0])
		begin
			pat_flk_4dot	<=	{pat_rval, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_4dot	<=	{8'd0, pat_rval, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - column inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_cln	<=	24'h000000;
	end
	else
	begin
		if (hcnt1[0] == 1'b0)
		begin
			pat_flk_cln	<=	{pat_rval, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_cln	<=	{8'd0, pat_rval, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - R 1 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_1dot_r	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[0] == hcnt1[0])
		begin
			pat_flk_1dot_r	<=	{pat_rval, 8'd0, 8'd0};
		end
		else
		begin
			pat_flk_1dot_r	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - R 2 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_2dot_r	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[1] == hcnt1[0])
		begin
			pat_flk_2dot_r	<=	{pat_rval, 8'd0, 8'd0};
		end
		else
		begin
			pat_flk_2dot_r	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - R 4 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_4dot_r	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[2] == hcnt1[0])
		begin
			pat_flk_4dot_r	<=	{pat_rval, 8'd0, 8'd0};
		end
		else
		begin
			pat_flk_4dot_r	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - R column inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_cln_r	<=	24'h000000;
	end
	else
	begin
		if (hcnt1[0] == 1'b0)
		begin
			pat_flk_cln_r	<=	{pat_rval, 8'd0, 8'd0};
		end
		else
		begin
			pat_flk_cln_r	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - G 1 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_1dot_g	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[0] == hcnt1[0])
		begin
			pat_flk_1dot_g	<=	{8'd0, pat_rval, 8'd0};
		end
		else
		begin
			pat_flk_1dot_g	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - G 2 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_2dot_g	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[1] == hcnt1[0])
		begin
			pat_flk_2dot_g	<=	{8'd0, pat_rval, 8'd0};
		end
		else
		begin
			pat_flk_2dot_g	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - G 4 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_4dot_g	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[2] == hcnt1[0])
		begin
			pat_flk_4dot_g	<=	{8'd0, pat_rval, 8'd0};
		end
		else
		begin
			pat_flk_4dot_g	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - G column inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_cln_g	<=	24'h000000;
	end
	else
	begin
		if (hcnt1[0] == 1'b0)
		begin
			pat_flk_cln_g	<=	{8'd0, pat_rval, 8'd0};
		end
		else
		begin
			pat_flk_cln_g	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - B 1 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_1dot_b	<=	24'h000000;
		pat_JDI_pixel_white	<=	24'h000000;
		pat_JDI_RGB_white	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[0] == hcnt1[0])
		begin
			pat_flk_1dot_b	<=	{8'd0, 8'd0, pat_rval};
			pat_JDI_pixel_white	<=	{8'd0, 8'd0, 8'd0};
			pat_JDI_RGB_white	<=	{pat_rval, pat_gval, pat_bval};
		end
		else
		begin
			pat_flk_1dot_b	<=	{8'd0, 8'd0, 8'd0};
			pat_JDI_pixel_white <= {pat_rval, pat_gval, pat_bval};
			pat_JDI_RGB_white	<=	{pat_rval, pat_gval,  8'd0};			
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - B 2 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_2dot_b	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[1] == hcnt1[0])
		begin
			pat_flk_2dot_b	<=	{8'd0, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_2dot_b	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - B 4 dot inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_4dot_b	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[2] == hcnt1[0])
		begin
			pat_flk_4dot_b	<=	{8'd0, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_4dot_b	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - B column inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_cln_b	<=	24'h000000;
	end
	else
	begin
		if (hcnt1[0] == 1'b0)
		begin
			pat_flk_cln_b	<=	{8'd0, 8'd0, pat_rval};
		end
		else
		begin
			pat_flk_cln_b	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - 1 pixel inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_1pixel	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[0] == hcnt1[0])
		begin
			pat_flk_1pixel	<=	24'b0;
		end
		else
		begin
			pat_flk_1pixel	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - 2 pixel inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_2pixel	<=	24'h000000;
	end
	else
	begin
		if (vcnt1[1] == hcnt1[0])
		begin
			pat_flk_2pixel	<=	24'h000000;
		end
		else
		begin
			pat_flk_2pixel	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - 4 pixel inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_4pixel	<=	24'h000000;;
	end
	else
	begin
		if (vcnt1[2] == hcnt1[0])
		begin
			pat_flk_4pixel	<=	24'h000000;
		end
		else
		begin
			pat_flk_4pixel	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: flicker - pixcel column inversion
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_flk_pcln	<=	24'h000000;
	end
	else
	begin
		if (hcnt1[0] == 1'b0)
		begin
			pat_flk_pcln	<=	24'h000000;
		end
		else
		begin
			pat_flk_pcln	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: 1x1 bar
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_1x1_bar		<=	{8'd0, 8'd0, 8'd0};
		pat_1x1_bar1	<=	{8'd0, 8'd0, 8'd0};
		pat_1x1_bar2	<=	{8'd0, 8'd0, 8'd0};
		pat_1x1_bar3	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if (vcnt1[0] == 1'b0)
		begin
			pat_1x1_bar		<=	{8'd0, 8'd0, 8'd0};
			pat_1x1_bar1	<=	{pat_rval, pat_rval, pat_rval};
			pat_1x1_bar2	<=	{8'd0, 8'd0, 8'd0};
			pat_1x1_bar3	<=	{pat_rval, pat_gval, pat_bval};
		end
		else
		begin
			pat_1x1_bar		<=	{pat_rval, pat_rval, pat_rval};
			pat_1x1_bar1	<=	{pat_gval, pat_gval, pat_gval};
			pat_1x1_bar2	<=	{pat_rval, pat_gval, pat_bval};
			pat_1x1_bar3	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: 1x1 dotbar 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_1x1_dotbar		<=	{8'd0, 8'd0, 8'd0};
		pat_1x1_dotbar1	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if (vcnt1[0] == 1'b0)
		begin
			pat_1x1_dotbar	<=	{8'd0, 8'd0, 8'd0};
			if (hcnt[0] == vcnt[0])
			begin
				pat_1x1_dotbar1	<=	{pat_rval, 8'd0, pat_rval};
			end
			else
			begin
				pat_1x1_dotbar1	<=	{8'd0, pat_rval, 8'd0};
			end
		end
		else
		begin
			if (hcnt1[0] == vcnt1[0])
			begin
				pat_1x1_dotbar	<=	{pat_rval, 8'd0, pat_rval};
			end
			else
			begin
				pat_1x1_dotbar	<=	{8'd0, pat_rval, 8'd0};
			end
			pat_1x1_dotbar1	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: outline detection
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_oln_det	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if ((vcnt1 == 12'd0) ||(vcnt1 == vsum - 12'd1))
		begin
			pat_oln_det	<=	{8'd255, 8'd255, 8'd255};
		end
		else if (hcnt1 == 12'd0)
		begin
			pat_oln_det	<=	{8'd255, 8'd0, 8'd0};
		end
		else if (hcnt1 == hsum - 12'd1)
		begin
			pat_oln_det	<=	{8'd0, 8'd0, 8'd255};
		end
		else if ((hcnt1 == hsum >> 1'b1) || (vcnt1 == vsum >> 1'b1))
		begin
			pat_oln_det	<=	{8'd0, 8'd255, 8'd0};
		end
		else
		begin
			pat_oln_det	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_oln_det1	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if (vcnt1 == 12'd0)
		begin
			pat_oln_det1	<=	{{8{pat_gval[6]}}, {8{pat_gval[5]}}, {8{pat_gval[4]}}};
		end
		else if (vcnt1 == vsum - 12'd1) 
		begin
			pat_oln_det1	<=	{{8{pat_gval[2]}}, {8{pat_gval[1]}}, {8{pat_gval[0]}}};
		end
		else if (hcnt1 == 12'd0)
		begin
			pat_oln_det1	<=	{{8{pat_bval[6]}}, {8{pat_bval[5]}}, {8{pat_bval[4]}}};
		end
		else if (hcnt1 == hsum - 12'd1) 
		begin
			pat_oln_det1	<=	{{8{pat_bval[2]}}, {8{pat_bval[1]}}, {8{pat_bval[0]}}};
		end
		else
		begin
			pat_oln_det1	<=	pat_otp_check;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_oln_det2	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if ((vcnt1 == 12'd0) || (hcnt1 == 12'd0))
		begin
			pat_oln_det2	<=	{8'd255, 8'd0, 8'd0};
		end
		else if ((vcnt1 == vsum - 12'd1) || (hcnt1 == hsum - 12'd1)) 
		begin
			pat_oln_det2	<=	{8'd0, 8'd0, 8'd255};
		end
		else
		begin
			pat_oln_det2	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_oln_det3	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if (vcnt1 == 12'd0)
		begin
			pat_oln_det3	<=	{{8{pat_gval[6]}}, {8{pat_gval[5]}}, {8{pat_gval[4]}}};
		end
		else if (vcnt1 == vsum - 12'd1) 
		begin
			pat_oln_det3	<=	{{8{pat_gval[2]}}, {8{pat_gval[1]}}, {8{pat_gval[0]}}};
		end
		else if (hcnt1 == 12'd0)
		begin
			pat_oln_det3	<=	{{8{pat_bval[6]}}, {8{pat_bval[5]}}, {8{pat_bval[4]}}};
		end
		else if (hcnt1 == hsum - 12'd1) 
		begin
			pat_oln_det3	<=	{{8{pat_bval[2]}}, {8{pat_bval[1]}}, {8{pat_bval[0]}}};
		end
		else if ((vcnt1 == (rect_start_y - 12'd1) || vcnt1 == (rect_start_y + rect_size_y - 12'd2)) && hcnt1 >= (rect_start_x - 12'd1) && hcnt1 < (rect_start_x + rect_size_x - 12'd1))
		begin
			pat_oln_det3	<=	{8'd255, 8'd255, 8'd255}; //up and down
		end
		else if ((hcnt1 == (rect_start_x - 12'd1)) && vcnt1 >= (rect_start_y - 12'd1) && vcnt1 < (rect_start_y + rect_size_y - 12'd1))
		begin
			pat_oln_det3	<=	{8'd0, 8'd0, 8'd255}; //left
		end
		else if ((hcnt1 == (rect_start_x + rect_size_x  - 12'd2)) && vcnt1 >= (rect_start_y - 12'd1) && vcnt1 < (rect_start_y + rect_size_y - 12'd1))
		begin
			pat_oln_det3	<=	{8'd255, 8'd0, 8'd0}; //right
		end
		else 
		begin
			pat_oln_det3	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_oln_det4	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if (vcnt1 == 12'd0)
		begin
			pat_oln_det4	<=	{{8{pat_gval[6]}}, {8{pat_gval[5]}}, {8{pat_gval[4]}}};
		end
		else if (vcnt1 == vsum - 11'd1) 
		begin
			pat_oln_det4	<=	{{8{pat_gval[2]}}, {8{pat_gval[1]}}, {8{pat_gval[0]}}};
		end
		else if (hcnt1 == 12'd0)
		begin
			pat_oln_det4	<=	{{8{pat_bval[6]}}, {8{pat_bval[5]}}, {8{pat_bval[4]}}};
		end
		else if (hcnt1 == hsum - 12'd1)
		begin
			pat_oln_det4	<=	{{8{pat_bval[2]}}, {8{pat_bval[1]}}, {8{pat_bval[0]}}};
		end
		else if ((hcnt1 >= (hsum >> 1'b1) - 12'd1 && hcnt1 < (hsum >> 1'b1) + 12'd1) 
			|| (vcnt1 >= (vsum >> 1'b1) - 12'd1 && vcnt1 < (vsum >> 1'b1) + 12'd1))
		begin
			pat_oln_det4	<=	{8'd255, 8'd255, 8'd255};
		end
		else
		begin
			pat_oln_det4	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: color bar with gray change
//-----------------------------------------------------------------------------
// arrow indicates gray decrease direction: 255 -> 0
//         hcnt
//    0     1/3HSUM - 1     HSUM-1
//    +--------+-----------+ 0
// v  | white  | blue----> |
// c  |   |    +-----------+ 1/3VSUM - 1
// n  |   |    | green---> |
// t  |   |    +-----------+ 2/3VSUM -1 
//    |   V    | red-----> |
//    +--------+-----------+ VSUM -1
// Note:
// R G B contains 32 gray levels
// white contains 32 gray levels
// Gray level contorl for red, green, blue section
reg[7:0]	cbar_gry_c;
reg[4:0]	cbar_gry_c_cnt;
reg[4:0]	cbar_gry_c_cnt_max;

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		cbar_gry_c_cnt_max	<=	5'd0;
	end
	else
	begin 
		case (hsum)
		12'd360:		//360*326
			begin
				cbar_gry_c_cnt_max	<=	5'd7;	//31*7 + 23 = 240
			end
		12'd720:		//720*1280
			begin
				cbar_gry_c_cnt_max	<=	5'd14;	//32*15 = 480
			end
		12'd1080:	//1080*1920
			begin
				cbar_gry_c_cnt_max	<=	5'd22;	//31*23 + 7 = 720
			end
		default:
			begin
				cbar_gry_c_cnt_max	<=	5'd0;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		cbar_gry_c_cnt	<=	5'd0;
		cbar_gry_c		<=	8'd255;
	end
	else
	begin
		if (h_sec2 == 1'b0 || h_sec3 == 1'b1)
		begin
			if (cbar_gry_c_cnt == cbar_gry_c_cnt_max)
			begin
				cbar_gry_c_cnt	<=	5'd0;
				cbar_gry_c		<=	cbar_gry_c - 8'd8;
			end
			else
			begin
				cbar_gry_c_cnt	<=	cbar_gry_c_cnt + 5'd1;
				cbar_gry_c		<=	cbar_gry_c;
			end
		end
		else
		begin
			cbar_gry_c_cnt	<=	5'd0;
			cbar_gry_c		<=	8'd255;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_gry	<=	24'h000000;
	end
	else
	begin
		if (h_sec3 == 1'b0 && h_sec2 == 1'b1)
		begin
			pat_cbar_gry	<=	{3{8'd255 - {v_div256_gry[7:3], 3'b0}}};
		end
		else 
		begin
			if (v_sec3 == 1'b1)
			begin
				pat_cbar_gry	<=	{8'd0, cbar_gry_c, 8'd0};
			end
			else
			begin
				if (v_sec2 == 1'b1)
				begin
					pat_cbar_gry	<=	{8'd0, 8'd0, cbar_gry_c};
				end
				else
				begin
					pat_cbar_gry	<=	{cbar_gry_c, 8'd0, 8'd0};
				end
			end
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: color bar with gray change
//-----------------------------------------------------------------------------
// arrow indicates gray decrease direction: 255 -> 0
//         hcnt
//    0     1/3HSUM - 1     HSUM-1
//    +--------+-----------+ 0
// v  | white  | blue----> |
// c  |   |    +-----------+ 1/3VSUM - 1
// n  |   |    | green---> |
// t  |   |    +-----------+ 2/3VSUM -1 
//    |   V    | red-----> |
//    +--------+-----------+ VSUM -1
// Note:
// R G B contains 256 gray levels
// white contains 256 gray levels
// Gray level contorl for red, green, blue section
reg[10:0]	cbar_gry256_part;
reg[7:0]		cbar_gry256_c;
reg[2:0]		cbar_gry256_c_cnt;
reg[2:0]		cbar_gry256_c_cnt_max;

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		cbar_gry256_part			<=	11'd0;
		cbar_gry256_c_cnt_max	<=	3'd0;
	end
	else
	begin 
		case (hsum)
		12'd360:		//360*326
			begin
				cbar_gry256_part			<=	11'd104;	//320-256 = 104
				cbar_gry256_c_cnt_max	<=	3'd0;	//256*1 = 256
			end
		12'd720:		//720*1280
			begin
				cbar_gry256_part			<=	11'd208;	//720-512 = 208
				cbar_gry256_c_cnt_max	<=	3'd1;	//256*2 = 512
			end
		12'd1080:	//1080*1920
			begin
				cbar_gry256_part			<=	11'd312;	//1080-768 = 312
				cbar_gry256_c_cnt_max	<=	3'd2;	//256*3 = 768
			end
		default:
			begin
				cbar_gry256_part			<=	11'd0;
				cbar_gry256_c_cnt_max	<=	3'd0;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		cbar_gry256_c_cnt	<=	3'd0;
		cbar_gry256_c		<=	8'd255;
	end
	else
	begin
		if (hcnt1 >= cbar_gry256_part)
		begin
			if (cbar_gry256_c_cnt == cbar_gry256_c_cnt_max)
			begin
				cbar_gry256_c_cnt	<=	3'd0;
				cbar_gry256_c		<=	cbar_gry256_c - 8'd1;
			end
			else
			begin
				cbar_gry256_c_cnt	<=	cbar_gry256_c_cnt + 3'd1;
				cbar_gry256_c		<=	cbar_gry256_c;
			end
		end
		else
		begin
			cbar_gry256_c_cnt	<=	3'd0;
			cbar_gry256_c		<=	8'd255;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_gry256	<=	24'h000000;
	end
	else
	begin
		if (hcnt1 < cbar_gry256_part)
		begin
			pat_cbar_gry256	<=	{3{8'd255 - v_div256_gry}};
		end
		else 
		begin
			if (v_sec3 == 1'b1)
			begin
				pat_cbar_gry256	<=	{8'd0, cbar_gry256_c, 8'd0};
			end
			else
			begin
				if (v_sec2 == 1'b1)
				begin
					pat_cbar_gry256	<=	{8'd0, 8'd0, cbar_gry256_c};
				end
				else
				begin
					pat_cbar_gry256	<=	{cbar_gry256_c, 8'd0, 8'd0};
				end
			end
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crossboard
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crs_brd	<=	8'd0;
	end
	else
	begin
		if (h_sec4 == 1'b1)
		begin		
			if (h_sec12 == 1'b1 && v_sec3 == 1'b1)
			begin
				pat_crs_brd	<=	8'd0;
			end
			else
			begin
				pat_crs_brd	<=	pat_rval;
			end
		end
		else
		begin
			if (v_sec4 ^ v_sec2 == h_sec2)
			begin  
				pat_crs_brd	<=	8'd0;
			end
			else
			begin
				pat_crs_brd	<=	8'd255;
			end
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: colorbar for HTC spec
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_htc	<=	24'h000000;
	end
	else
	begin
		case (v_div256_gry[7:5])
		3'd0:
			begin
				pat_cbar_htc	<=	{8'd0, 8'd0, h_div256_gry};
			end
		3'd1:
			begin
				pat_cbar_htc	<=	{8'd0, 8'd0, ~h_div256_gry};
			end
		3'd2:
			begin
				pat_cbar_htc	<=	{8'd0, h_div256_gry, 8'd0};
			end
		3'd3:
			begin
				pat_cbar_htc	<=	{8'd0, ~h_div256_gry, 8'd0};
			end
		3'd4:
			begin
				pat_cbar_htc	<=	{h_div256_gry, 8'd0, 8'd0};
			end
		3'd5:
			begin
				pat_cbar_htc	<=	{~h_div256_gry, 8'd0, 8'd0};
			end
		3'd6:
			begin
				pat_cbar_htc	<=	{3{h_div256_gry}};
			end
		3'd7:
			begin
				pat_cbar_htc	<=	{3{~h_div256_gry}};
			end
		default:
			begin
				pat_cbar_htc	<=	24'h000000;
			end
		endcase
	end
end

//-----------------------------------------------------------------------------
// Pattern: colorbar for ASUS spec
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_asus	<=	24'h000000;
	end
	else
	begin
		case (v_div256_gry[7:6])
		2'd0:
			begin
				pat_cbar_asus	<=	{3{~h_div256_gry}};
			end
		2'd1:
			begin
				pat_cbar_asus	<=	{8'd0, 8'd0, ~h_div256_gry};
			end
		2'd2:
			begin
				pat_cbar_asus	<=	{8'd0, ~h_div256_gry, 8'd0};
			end
		2'd3:
			begin
				pat_cbar_asus	<=	{~h_div256_gry, 8'd0, 8'd0};
			end
		default:
			begin
				pat_cbar_asus	<=	24'h000000;
			end
		endcase
	end
end

//-----------------------------------------------------------------------------
// Pattern: colorbar for LENOVO spec
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cbar_lenovo	<=	24'h000000;
	end
	else
	begin
		case (v_div256_gry[7:6])
		2'd0:
			begin
				pat_cbar_lenovo	<=	{3{{h_div256_gry[7:2], 2'b0}}};
			end
		2'd1:
			begin
				pat_cbar_lenovo	<=	{{h_div256_gry[7:2], 2'b0}, 8'd0, 8'd0};
			end
		2'd2:
			begin
				pat_cbar_lenovo	<=	{8'd0, {h_div256_gry[7:2], 2'b0}, 8'd0};
			end
		2'd3:
			begin
				pat_cbar_lenovo	<=	{8'd0, 8'd0, {h_div256_gry[7:2], 2'b0}};
			end
		default:
			begin
				pat_cbar_lenovo	<=	24'h000000;
			end
		endcase
	end
end

//-----------------------------------------------------------------------------
// Pattern: diagonal graybar for HTC spec
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar256_diag	<=	8'd0;
	end
	else
	begin
		pat_gbar256_diag	<=	8'd255 - (h_div256_gry + v_div256_gry);
	end
end

//-----------------------------------------------------------------------------
// pattern: bright dot test for HTC spec
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		bright_dot	<=	24'h000000;
	end
	else if (vcnt == 12'd0)
	begin
		//bright_dot	<=	{8'd255, 8'd255, 8'd255};
		bright_dot	<=	{{8{pat_gval[6]}}, {8{pat_gval[5]}}, {8{pat_gval[4]}}};
	end
	else if (vcnt == (vsum >> 2'd2))//TOP
	begin
		if (hcnt == hsum >> 2'd2)
		begin
			bright_dot	<=	{8'd0, 8'd0, dot_b1};
		end
		else if (hcnt == (hsum >> 2'd1))
		begin
			bright_dot	<=	{8'd0, dot_g1, 8'd0};
		end
		else if (hcnt == ((hsum >> 2'd2) + (hsum >> 2'd1)))
		begin
			bright_dot	<=	{dot_r1, 8'd0, 8'd0};
		end
		else
		begin
			bright_dot	<=	24'h000000;
		end
	end
	else if (vcnt == (vsum >> 2'd1))//middle
	begin
		if (hcnt == hsum >> 2'd2)
		begin
			bright_dot	<=	{8'd0, 8'd0, dot_b2};
		end
		else if (hcnt == (hsum >> 2'd1))
		begin
			bright_dot	<=	{pat_rval, (dot_g2 + pat_gval), pat_bval};
		end
		else if (hcnt == ((hsum >> 2'd2) + (hsum >> 2'd1)))
		begin
			bright_dot	<=	{dot_r2, 8'd0, 8'd0};
		end
		else
		begin
			bright_dot	<=	24'h000000;
		end
	end
	else if (vcnt == ((vsum >> 2'd2) + (vsum >> 2'd1)))//bottom
	begin
		if (hcnt == hsum >> 2'd2)//left
		begin
			bright_dot	<=	{8'd0, 8'd0, dot_b3};		
		end
		else if (hcnt == (hsum >> 2'd1))//middle
		begin
			bright_dot	<=	{8'd0, dot_g3, 8'd0};		
		end
		else if (hcnt == ((hsum >> 2'd2) + (hsum >> 2'd1)))//right
		begin
			bright_dot	<=	{dot_r3, 8'd0, 8'd0};
		end
		else
		begin
			bright_dot	<=	24'h000000;
		end
	end
	else if(vcnt == vsum - 12'd1) 
	begin
		//bright_dot	<=	{8'd255, 8'd255, 8'd255};
		bright_dot	<=	{{8{pat_gval[2]}}, {8{pat_gval[1]}}, {8{pat_gval[0]}}};
	end
	else
	begin
		if(hcnt == 12'd1)
		begin
			//bright_dot	<={8'd255, 8'd0, 8'd0};
			bright_dot	<=	{{8{pat_bval[6]}}, {8{pat_bval[5]}}, {8{pat_bval[4]}}};
		end
		else if(hcnt == hsum - 12'd1)
		begin
			//bright_dot	<={8'd0, 8'd0, 8'd255};
			bright_dot	<=	{{8{pat_bval[2]}}, {8{pat_bval[1]}}, {8{pat_bval[0]}}};
		end
		else
		begin
			bright_dot	<=	24'h000000;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		black_dot	<=	24'h000000;
	end
	else if (vcnt == (vsum >> 2'd1) && (hcnt == (hsum >> 2'd1)))
	begin
		black_dot	<= {pat_rval, pat_gval, pat_bval};	
	end
	else
	begin
		black_dot	<=	24'hFFFFFF;
	end
end

//-----------------------------------------------------------------------------
// Pattern: character for HTC spec
//-----------------------------------------------------------------------------
reg[15:0]	character[15:0];
reg[3:0]		hcnt16;
reg[3:0]		vcnt16;
reg			index;
reg[7:0]		scale_h;
reg[7:0]		scale_v;
wire[7:0]	SH;
wire[7:0]	SV;

assign SH = (pat_num == 8'd110) ? (pat_gval - 8'd1) : 8'd3;
assign SV = (pat_num == 8'd110) ? (pat_bval - 8'd1) : 8'd3;

always @(posedge clk)
begin
	// character: S
	character[0]	<=	16'h0000;
	character[1]	<=	16'h0000;
	character[2]	<=	16'h0000;
	character[3]	<=	16'h003E;
	character[4]	<=	16'h0042;
	character[5]	<=	16'h0042;
	character[6]	<=	16'h0040;
	character[7]	<=	16'h0020;
	character[8]	<=	16'h0018;
	character[9]	<=	16'h0004;
	character[10]	<=	16'h0002;
	character[11]	<=	16'h0042;
	character[12]	<=	16'h0042;
	character[13]	<=	16'h007C;
	character[14]	<=	16'h0000;
	character[15]	<=	16'h0000;
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_character	<=	24'h000000;
		vcnt16			<=	4'd0;
		hcnt16			<=	4'd0;
		index				<=	1'd0;
		scale_h			<=	8'd0;
		scale_v			<=	8'd0;
	end
	else if (vcnt > 12'd0)
	begin
		if (hcnt > 12'd0)
		begin
			if (character[vcnt16][4'd15 - hcnt16] == 1'b1)
			begin
				pat_character	<=	{8'd255, 8'd255, 8'd255};
			end
			else
			begin
				pat_character	<=	{pat_rval, pat_rval, pat_rval};
			end

			if (scale_h == SH)
			begin
				scale_h	<=	8'd0;
				if (hcnt16 == 4'd15)
				begin
					hcnt16	<=	4'd0;
				end
				else
				begin
					hcnt16	<=	hcnt16 + 3'd1;
				end
			end
			else
			begin
				scale_h	<=	scale_h + 8'd1;
			end

			if (hcnt == hsum - 12'd1)
			begin
				if (scale_v == SV)
				begin
					scale_v	<=	8'd0;
					if (vcnt16 == 4'd15)
					begin
						vcnt16	<=	4'd0;
						index		<=	~index;
					end
					else
					begin
						vcnt16	<=	vcnt16 + 4'd1;
					end
				end	
				else
				begin
					scale_v	<=	scale_v + 8'd1;
				end
			end
		end
		else
		begin
			if (index == 1'd0)
			begin
				hcnt16	<=	4'd8;
			end
			else
			begin
				hcnt16	<=	4'd0;
			end
			pat_character	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
	else
	begin
		pat_character	<=	{pat_rval, pat_rval, pat_rval};
		vcnt16			<=	4'd0;
		hcnt16			<=	4'd0;
		index				<=	1'd0;
		scale_h			<=	8'd1;
		scale_v			<=	8'd1;
	end
end

//-----------------------------------------------------------------------------
// pattern: crosstalk + waku - middle area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_waku	<=	{8'd0, 8'd0, 8'd0};
	end
	else
	begin
		if ((vcnt1 == 12'd0) || (vcnt1 == vsum - 12'd1))
		begin
			pat_crst_waku	<=	{8'd255, 8'd255, 8'd255};
		end
		else if (hcnt1 == hsum - 12'd1)
		begin
			pat_crst_waku	<=	{8'd0, 8'd0, 8'd255};
		end
		else if (hcnt1 == 12'd0)
		begin
			pat_crst_waku	<=	{8'd255, 8'd0, 8'd0};
		end
		else if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			if (pat_num == 8'd83)
			begin
				pat_crst_waku	<=	{8'd0, 8'd0, 8'd0};
			end
			else 
			begin
				pat_crst_waku	<=	{8'd255, 8'd255, 8'd255};
			end
		end
		else
		begin
			pat_crst_waku	<=	{pat_rval, pat_rval, pat_rval}; 
		end
	end
end

//-----------------------------------------------------------------------------
// pattern: warning for OTP check
//-----------------------------------------------------------------------------
reg[48:0]	otp_character[16:0];
reg[5:0]		otp_hcnt48;
reg[4:0]		otp_vcnt16;
reg[4:0]		otp_scale_h;
reg[4:0]		otp_scale_v;
reg[4:0]		otp_scale;

always @(posedge clk)
begin	
	if (pat_num == 8'd84)
	begin
		//											鏈				O		T		P
		otp_character[0]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[1]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[2]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[3]	<=	{4'h0, 8'h3F, 8'hF8, 4'h0, 8'h38, 8'hFE, 8'hFC, 1'b0};
		otp_character[4]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h44, 8'h92, 8'h42, 1'b0};
		otp_character[5]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h82, 8'h10, 8'h42, 1'b0};
		otp_character[6]	<=	{4'h0, 8'hFF, 8'hFE, 4'h0, 8'h82, 8'h10, 8'h42, 1'b0};
		otp_character[7]	<=	{4'h0, 8'h03, 8'h00, 4'h0, 8'h82, 8'h10, 8'h42, 1'b0};
		otp_character[8]	<=	{4'h0, 8'h03, 8'h80, 4'h0, 8'h82, 8'h10, 8'h7C, 1'b0};
		otp_character[9]	<=	{4'h0, 8'h05, 8'h40, 4'h0, 8'h82, 8'h10, 8'h40, 1'b0};
		otp_character[10]	<=	{4'h0, 8'h05, 8'h20, 4'h0, 8'h82, 8'h10, 8'h40, 1'b0};
		otp_character[11]	<=	{4'h0, 8'h09, 8'h18, 4'h0, 8'h82, 8'h10, 8'h40, 1'b0};
		otp_character[12]	<=	{4'h0, 8'h31, 8'h0E, 4'h0, 8'h44, 8'h10, 8'h40, 1'b0};
		otp_character[13]	<=	{4'h0, 8'hC1, 8'h04, 4'h0, 8'h38, 8'h38, 8'hE0, 1'b0};
		otp_character[14]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[15]	<=	{4'h0, 8'h01, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[16]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 1'b0};
	end
	else if (pat_num == 8'd79)
	begin
		//										W			A		K		U
		otp_character[0]	<=	{8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[1]	<=	{8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[2]	<=	{8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[3]	<=	{8'h00, 8'hD6, 8'h10, 8'hEE, 8'hE7, 8'h00, 1'b0};
		otp_character[4]	<=	{8'h00, 8'h92, 8'h10, 8'h44, 8'h42, 8'h00, 1'b0};
		otp_character[5]	<=	{8'h00, 8'h92, 8'h18, 8'h48, 8'h42, 8'h00, 1'b0};
		otp_character[6]	<=	{8'h00, 8'h92, 8'h28, 8'h50, 8'h42, 8'h00, 1'b0};
		otp_character[7]	<=	{8'h00, 8'h92, 8'h28, 8'h70, 8'h42, 8'h00, 1'b0};
		otp_character[8]	<=	{8'h00, 8'hAA, 8'h24, 8'h50, 8'h42, 8'h00, 1'b0};
		otp_character[9]	<=	{8'h00, 8'hAA, 8'h3C, 8'h48, 8'h42, 8'h00, 1'b0};
		otp_character[10]	<=	{8'h00, 8'h6C, 8'h44, 8'h48, 8'h42, 8'h00, 1'b0};
		otp_character[11]	<=	{8'h00, 8'h44, 8'h42, 8'h44, 8'h42, 8'h00, 1'b0};
		otp_character[12]	<=	{8'h00, 8'h44, 8'h42, 8'h44, 8'h42, 8'h00, 1'b0};
		otp_character[13]	<=	{8'h00, 8'h44, 8'hE7, 8'hEE, 8'h3C, 8'h00, 1'b0};
		otp_character[14]	<=	{8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[15]	<=	{8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[16]	<=	{8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
	end
	else if (pat_num == 8'd116)
	begin
		//										宕						瑙
		otp_character[0]	<=	{4'h00, 8'h01, 8'h00, 4'h00, 8'h08, 8'h00, 8'h00, 1'b0};
		otp_character[1]	<=	{4'h00, 8'h21, 8'h08, 4'h00, 8'h08, 8'h00, 8'h00, 1'b0};
		otp_character[2]	<=	{4'h00, 8'h21, 8'h08, 4'h00, 8'h1F, 8'hE0, 8'h00, 1'b0};
		otp_character[3]	<=	{4'h00, 8'h3F, 8'hF8, 4'h00, 8'h20, 8'h20, 8'h00, 1'b0};
		otp_character[4]	<=	{4'h00, 8'h00, 8'h00, 4'h00, 8'h40, 8'h40, 8'h00, 1'b0};
		otp_character[5]	<=	{4'h00, 8'h3E, 8'h7C, 4'h00, 8'hBF, 8'hF8, 8'h00, 1'b0};
		otp_character[6]	<=	{4'h00, 8'h22, 8'h44, 4'h00, 8'h21, 8'h08, 8'h00, 1'b0};
		otp_character[7]	<=	{4'h00, 8'h22, 8'h44, 4'h00, 8'h21, 8'h08, 8'h00, 1'b0};
		otp_character[8]	<=	{4'h00, 8'h3E, 8'h7C, 4'h00, 8'h3F, 8'hF8, 8'h00, 1'b0};
		otp_character[9]	<=	{4'h00, 8'h22, 8'h44, 4'h00, 8'h21, 8'h08, 8'h00, 1'b0};
		otp_character[10]	<=	{4'h00, 8'h22, 8'h44, 4'h00, 8'h21, 8'h08, 8'h00, 1'b0};
		otp_character[11]	<=	{4'h00, 8'h3E, 8'h7C, 4'h00, 8'h3F, 8'hF8, 8'h00, 1'b0};
		otp_character[12]	<=	{4'h00, 8'h22, 8'h44, 4'h00, 8'h21, 8'h08, 8'h00, 1'b0};
		otp_character[13]	<=	{4'h00, 8'h22, 8'h44, 4'h00, 8'h41, 8'h08, 8'h00, 1'b0};
		otp_character[14]	<=	{4'h00, 8'h4A, 8'h94, 4'h00, 8'h41, 8'h28, 8'h00, 1'b0};
		otp_character[15]	<=	{4'h00, 8'h85, 8'h08, 4'h00, 8'h80, 8'h10, 8'h00, 1'b0};
		otp_character[16]	<=	{4'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 1'b0};
	end
	else if (pat_num == 8'd139)
	begin
		//										寮€							鐩
		otp_character[0]	<=	{4'h00, 8'h00, 8'h00, 4'h00, 8'h08, 8'h20, 8'h00, 1'b0};
		otp_character[1]	<=	{4'h00, 8'h7F, 8'hFC, 4'h00, 8'h04, 8'h40, 8'h00, 1'b0};
		otp_character[2]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h7F, 8'hFC, 8'h00, 1'b0};
		otp_character[3]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h01, 8'h00, 8'h00, 1'b0};
		otp_character[4]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h01, 8'h00, 8'h00, 1'b0};
		otp_character[5]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h3F, 8'hF8, 8'h00, 1'b0};
		otp_character[6]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h01, 8'h00, 8'h00, 1'b0};
		otp_character[7]	<=	{4'h00, 8'hFF, 8'hFE, 4'h00, 8'h01, 8'h00, 8'h00, 1'b0};
		otp_character[8]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'hFF, 8'hFE, 8'h00, 1'b0};
		otp_character[9]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[10]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		otp_character[11]	<=	{4'h00, 8'h08, 8'h20, 4'h00, 8'h3F, 8'hF8, 8'h00, 1'b0};
		otp_character[12]	<=	{4'h00, 8'h10, 8'h20, 4'h00, 8'h24, 8'h48, 8'h00, 1'b0};
		otp_character[13]	<=	{4'h00, 8'h10, 8'h20, 4'h00, 8'h24, 8'h48, 8'h00, 1'b0};
		otp_character[14]	<=	{4'h00, 8'h20, 8'h20, 4'h00, 8'h24, 8'h48, 8'h00, 1'b0};
		otp_character[15]	<=	{4'h00, 8'h40, 8'h20, 4'h00, 8'hFF, 8'hFE, 8'h00, 1'b0};
		otp_character[16]	<=	{4'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 1'b0};
	end
end 

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		otp_scale	<=	5'd14;
	end
	else
	begin
		case (hsum)
		12'd360:		//360*326
			begin
				otp_scale	<=	5'd6;	//48*7 + 24 = 360
			end
		12'd720:		//720*1280
			begin
				otp_scale	<=	5'd14;	//48*15 = 720
			end
		12'd1080:	//1080*1920
			begin
				otp_scale	<=	5'd21;	//48*22 + 24 = 1080
			end
		default:
			begin
				otp_scale	<=	5'd14;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_otp_check	<=	{8'd0, 8'd0, 8'd0};
		otp_hcnt48		<=	6'd0;
		otp_vcnt16		<=	5'd0;
		otp_scale_h		<=	5'd0;
		otp_scale_v		<=	5'd0;
	end
	else if (v_sec3 == 1'b1)
	begin
		if (hcnt > 12'd0)
		begin
			if (otp_character[otp_vcnt16][6'd48 - otp_hcnt48] == 1'b1)
			begin
				pat_otp_check	<=	{8'd255, 8'd0, 8'd0};
			end
			else
			begin
				pat_otp_check	<=	{pat_rval, pat_rval, pat_rval};
			end

			if (otp_scale_h == otp_scale)
			begin
				otp_scale_h	<=	5'd0;
				if (otp_hcnt48 >= 6'd47)
				begin
					otp_hcnt48	<=	6'd48;
				end
				else
				begin
					otp_hcnt48	<=	otp_hcnt48 + 6'd1;
				end
			end
			else
			begin
				otp_scale_h <= otp_scale_h + 5'd1;
			end

			if (hcnt == hsum - 12'd1)
			begin
				if (otp_scale_v == otp_scale)
				begin
					otp_scale_v	<=	5'd0;
					if (otp_vcnt16 >= 5'd15)
					begin
						otp_vcnt16	<=	5'd16;
					end
					else
					begin
						otp_vcnt16	<=	otp_vcnt16 + 5'd1;
					end
				end
				else
				begin
					otp_scale_v	<=	otp_scale_v + 5'd1;
				end
				otp_hcnt48	<=	6'd0;
				otp_scale_h	<=	5'd0;
			end
		end
		else
		begin
			otp_hcnt48	<=	6'd0;
			otp_scale_h	<=	5'd0;
		end
	end
	else
	begin
		pat_otp_check	<=	{pat_rval, pat_rval, pat_rval};
		otp_hcnt48		<=	5'd0;
		otp_vcnt16		<=	5'd0;
		otp_scale_h		<=	5'd0;
		otp_scale_v		<=	5'd0;
	end
end

//-----------------------------------------------------------------------------
// pattern: warning for OTP NG
//-----------------------------------------------------------------------------
reg[23:0]	otp_NG[16:0];
reg[4:0]		NG_hcnt24;
reg[4:0]		NG_vcnt16;
reg[5:0]		NG_scale_h;
reg[5:0]		NG_scale_v;
reg[5:0]		NG_scale;

always @(posedge clk)
begin	
	//								N				G					
	otp_NG[0]	<=	{2'h0, 8'h00, 4'h0, 8'h00, 2'h0};
	otp_NG[1]	<=	{2'h0, 8'h00, 4'h0, 8'h00, 2'h0};
	otp_NG[2]	<=	{2'h0, 8'h00, 4'h0, 8'h00, 2'h0};
	otp_NG[3]	<=	{2'h0, 8'hC7, 4'h0, 8'h3C, 2'h0};
	otp_NG[4]	<=	{2'h0, 8'h62, 4'h0, 8'h44, 2'h0};
	otp_NG[5]	<=	{2'h0, 8'h62, 4'h0, 8'h44, 2'h0};
	otp_NG[6]	<=	{2'h0, 8'h52, 4'h0, 8'h80, 2'h0};
	otp_NG[7]	<=	{2'h0, 8'h52, 4'h0, 8'h80, 2'h0};
	otp_NG[8]	<=	{2'h0, 8'h4A, 4'h0, 8'h80, 2'h0};
	otp_NG[9]	<=	{2'h0, 8'h4A, 4'h0, 8'h8E, 2'h0};
	otp_NG[10]	<=	{2'h0, 8'h4A, 4'h0, 8'h84, 2'h0};
	otp_NG[11]	<=	{2'h0, 8'h46, 4'h0, 8'h44, 2'h0};
	otp_NG[12]	<=	{2'h0, 8'h46, 4'h0, 8'h44, 2'h0};
	otp_NG[13]	<=	{2'h0, 8'hE2, 4'h0, 8'h38, 2'h0};
	otp_NG[14]	<=	{2'h0, 8'h00, 4'h0, 8'h00, 2'h0};
	otp_NG[15]	<=	{2'h0, 8'h00, 4'h0, 8'h00, 2'h0};
	otp_NG[16]	<=	{2'h0, 8'h00, 4'h0, 8'h00, 2'h0};
end 

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		NG_scale	<=	6'd29;
	end
	else
	begin
		case (hsum)
		12'd360:		//360*326
			begin
				NG_scale	<=	6'd5;	//17*6 + 6 = 326 / 3 = 108
			end
		12'd720:		//720*1280
			begin
				NG_scale	<=	6'd29;	//24*30 = 720
			end
		12'd1080:	//1080*1920
			begin
				NG_scale	<=	6'd44;	//24*45 = 1080
			end
		default:
			begin
				NG_scale	<=	6'd29;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_otp_NG	<=	{8'd0, 8'd0, 8'd0};
		NG_hcnt24		<=	5'd0;
		NG_vcnt16		<=	5'd0;
		NG_scale_h		<=	6'd0;
		NG_scale_v		<=	6'd0;
	end
	else if ((pat_num == 8'd85 && v_sec2 == 1'b1 && vcnt > 12'b0) 
	 || (pat_num == 8'd113 && v_sec2 == 1'b0 && v_sec3 == 1'b0)
	 || (pat_num == 8'd114 && v_sec3 == 1'b1))
	begin
		if (hcnt > 12'd0)
		begin
			if (otp_NG[NG_vcnt16][5'd23 - NG_hcnt24] == 1'b1)
			begin
				pat_otp_NG	<=	{8'd255, 8'd0, 8'd0};
			end
			else
			begin
				pat_otp_NG	<=	{pat_rval, pat_rval, pat_rval};
			end

			if (NG_scale_h == NG_scale)
			begin
				NG_scale_h	<=	6'd0;
				if (NG_hcnt24 >= 5'd22)
				begin
					NG_hcnt24	<=	5'd23;
				end
				else
				begin
					NG_hcnt24	<=	NG_hcnt24 + 5'd1;
				end
			end
			else
			begin
				NG_scale_h <= NG_scale_h + 6'd1;
			end

			if (hcnt == hsum - 12'd1)
			begin
				if (NG_scale_v == NG_scale)
				begin
					NG_scale_v	<=	6'd0;
					if (NG_vcnt16 >= 5'd15)
					begin
						NG_vcnt16	<=	5'd16;
					end
					else
					begin
						NG_vcnt16	<=	NG_vcnt16 + 5'd1;
					end
				end
				else
				begin
					NG_scale_v	<=	NG_scale_v + 6'd1;
				end
				NG_hcnt24	<=	5'd0;
				NG_scale_h	<=	6'd0;
			end
		end
		else
		begin
			NG_hcnt24	<=	5'd0;
			NG_scale_h	<=	6'd0;
		end
	end
	else
	begin
		pat_otp_NG	<=	{pat_rval, pat_rval, pat_rval};
		NG_hcnt24		<=	5'd0;
		NG_vcnt16		<=	5'd0;
		NG_scale_h		<=	6'd0;
		NG_scale_v		<=	6'd0;
	end
end

//-----------------------------------------------------------------------------
// pattern: warning for ID ERROR
//-----------------------------------------------------------------------------
reg[64:0]	message[16:0];
reg[6:0]		message_hcnt64;
reg[4:0]		message_vcnt16;
reg[4:0]		message_scale_h;
reg[4:0]		message_scale_v;
reg[4:0]		message_scale;

always @(posedge clk)
begin	
	if (pat_num == 8'd86)
	begin
		//								I		D					E		R		R			O		R
		message[0]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[1]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[2]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[3]	<=	{4'h0, 8'h7C, 8'hF8, 4'h0, 8'hFC, 8'hFC, 8'hFC, 8'h38, 8'hFC, 1'b0};
		message[4]	<=	{4'h0, 8'h10, 8'h44, 4'h0, 8'h42, 8'h42, 8'h42, 8'h44, 8'h42, 1'b0};
		message[5]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h48, 8'h42, 8'h42, 8'h82, 8'h42, 1'b0};
		message[6]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h48, 8'h42, 8'h42, 8'h82, 8'h42, 1'b0};
		message[7]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h78, 8'h7C, 8'h7C, 8'h82, 8'h7C, 1'b0};
		message[8]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h48, 8'h48, 8'h48, 8'h82, 8'h48, 1'b0};
		message[9]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h48, 8'h48, 8'h48, 8'h82, 8'h48, 1'b0};
		message[10]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h40, 8'h44, 8'h44, 8'h82, 8'h44, 1'b0};
		message[11]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h42, 8'h44, 8'h44, 8'h82, 8'h44, 1'b0};
		message[12]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h42, 8'h42, 8'h42, 8'h44, 8'h42, 1'b0};
		message[13]	<=	{4'h0, 8'h7C, 8'hF8, 4'h0, 8'hFC, 8'hE3, 8'hE3, 8'h38, 8'hE3, 1'b0};
		message[14]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[15]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[16]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
	end
	else if (pat_num == 8'd87)
	begin
		//								I		D					R		E		S			E		T
		message[0]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[1]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[2]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[3]	<=	{4'h0, 8'h7C, 8'hF8, 4'h0, 8'hFC, 8'hFC, 8'h3E, 8'hFC, 8'hFE, 1'b0};
		message[4]	<=	{4'h0, 8'h10, 8'h44, 4'h0, 8'h42, 8'h42, 8'h42, 8'h42, 8'h92, 1'b0};
		message[5]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h42, 8'h48, 8'h42, 8'h48, 8'h10, 1'b0};
		message[6]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h42, 8'h48, 8'h40, 8'h48, 8'h10, 1'b0};
		message[7]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h7C, 8'h78, 8'h20, 8'h78, 8'h10, 1'b0};
		message[8]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h48, 8'h48, 8'h18, 8'h48, 8'h10, 1'b0};
		message[9]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h48, 8'h48, 8'h04, 8'h48, 8'h10, 1'b0};
		message[10]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h44, 8'h40, 8'h02, 8'h40, 8'h10, 1'b0};
		message[11]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h44, 8'h42, 8'h42, 8'h42, 8'h10, 1'b0};
		message[12]	<=	{4'h0, 8'h10, 8'h42, 4'h0, 8'h42, 8'h42, 8'h42, 8'h42, 8'h10, 1'b0};
		message[13]	<=	{4'h0, 8'h7C, 8'hF8, 4'h0, 8'hE3, 8'hFC, 8'h7C, 8'hFC, 8'h38, 1'b0};
		message[14]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[15]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[16]	<=	{4'h0, 8'h00, 8'h00, 4'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
	end
	else if (pat_num == 8'd97)
	begin
		//								V		S			N				V			S		P
		message[0]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[1]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[2]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[3]	<=	{8'h0, 8'hE7, 8'h3E, 8'hC7, 4'h00, 8'hE7, 8'h3E, 8'hFC, 4'h00, 1'b0};
		message[4]	<=	{8'h0, 8'h42, 8'h42, 8'h62, 4'h00, 8'h42, 8'h42, 8'h42, 4'h00, 1'b0};
		message[5]	<=	{8'h0, 8'h42, 8'h42, 8'h62, 4'h00, 8'h42, 8'h42, 8'h42, 4'h00, 1'b0};
		message[6]	<=	{8'h0, 8'h44, 8'h40, 8'h52, 4'h00, 8'h44, 8'h40, 8'h42, 4'h00, 1'b0};
		message[7]	<=	{8'h0, 8'h24, 8'h20, 8'h52, 4'h00, 8'h24, 8'h20, 8'h42, 4'h00, 1'b0};
		message[8]	<=	{8'h0, 8'h24, 8'h18, 8'h4A, 4'h00, 8'h24, 8'h18, 8'h7C, 4'h00, 1'b0};
		message[9]	<=	{8'h0, 8'h28, 8'h04, 8'h4A, 4'h00, 8'h28, 8'h04, 8'h40, 4'h00, 1'b0};
		message[10]	<=	{8'h0, 8'h28, 8'h02, 8'h4A, 4'h00, 8'h28, 8'h02, 8'h40, 4'h00, 1'b0};
		message[11]	<=	{8'h0, 8'h18, 8'h42, 8'h46, 4'h00, 8'h18, 8'h42, 8'h40, 4'h00, 1'b0};
		message[12]	<=	{8'h0, 8'h10, 8'h42, 8'h46, 4'h00, 8'h10, 8'h42, 8'h40, 4'h00, 1'b0};
		message[13]	<=	{8'h0, 8'h10, 8'h7C, 8'hE2, 4'h00, 8'h10, 8'h7C, 8'hE0, 4'h00, 1'b0};
		message[14]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[15]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[16]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
	end
	else if (pat_num == 8'd98)
	begin
		//								V		S			N
		message[0]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[1]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[2]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[3]	<=	{8'h0, 8'hE7, 8'h3E, 8'hC7, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[4]	<=	{8'h0, 8'h42, 8'h42, 8'h62, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[5]	<=	{8'h0, 8'h42, 8'h42, 8'h62, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[6]	<=	{8'h0, 8'h44, 8'h40, 8'h52, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[7]	<=	{8'h0, 8'h24, 8'h20, 8'h52, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[8]	<=	{8'h0, 8'h24, 8'h18, 8'h4A, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[9]	<=	{8'h0, 8'h28, 8'h04, 8'h4A, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[10]	<=	{8'h0, 8'h28, 8'h02, 8'h4A, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[11]	<=	{8'h0, 8'h18, 8'h42, 8'h46, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[12]	<=	{8'h0, 8'h10, 8'h42, 8'h46, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[13]	<=	{8'h0, 8'h10, 8'h7C, 8'hE2, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[14]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[15]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[16]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
	end
	else if (pat_num == 8'd99)
	begin
		//																	V			S		P
		message[0]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[1]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[2]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[3]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'hE7, 8'h3E, 8'hFC, 4'h00, 1'b0};
		message[4]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h42, 8'h42, 8'h42, 4'h00, 1'b0};
		message[5]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h42, 8'h42, 8'h42, 4'h00, 1'b0};
		message[6]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h44, 8'h40, 8'h42, 4'h00, 1'b0};
		message[7]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h24, 8'h20, 8'h42, 4'h00, 1'b0};
		message[8]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h24, 8'h18, 8'h7C, 4'h00, 1'b0};
		message[9]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h28, 8'h04, 8'h40, 4'h00, 1'b0};
		message[10]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h28, 8'h02, 8'h40, 4'h00, 1'b0};
		message[11]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h18, 8'h42, 8'h40, 4'h00, 1'b0};
		message[12]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h10, 8'h42, 8'h40, 4'h00, 1'b0};
		message[13]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h10, 8'h7C, 8'hE0, 4'h00, 1'b0};
		message[14]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[15]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[16]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
	end
	else if (pat_num == 8'd123)
	begin
		//										I		O		  V			C		C
		message[0]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[1]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[2]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[3]	<=	{8'h0, 8'h00, 8'h7C, 8'h38, 8'hE7, 8'h3E, 8'h3E, 8'h00, 1'b0};
		message[4]	<=	{8'h0, 8'h00, 8'h10, 8'h44, 8'h42, 8'h42, 8'h42, 8'h00, 1'b0};
		message[5]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h42, 8'h42, 8'h42, 8'h00, 1'b0};
		message[6]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h44, 8'h80, 8'h80, 8'h00, 1'b0};
		message[7]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h24, 8'h80, 8'h80, 8'h00, 1'b0};
		message[8]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h24, 8'h80, 8'h80, 8'h00, 1'b0};
		message[9]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h28, 8'h80, 8'h80, 8'h00, 1'b0};
		message[10]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h28, 8'h80, 8'h80, 8'h00, 1'b0};
		message[11]	<=	{8'h0, 8'h00, 8'h10, 8'h82, 8'h18, 8'h42, 8'h42, 8'h00, 1'b0};
		message[12]	<=	{8'h0, 8'h00, 8'h10, 8'h44, 8'h10, 8'h44, 8'h44, 8'h00, 1'b0};
		message[13]	<=	{8'h0, 8'h00, 8'h7C, 8'h38, 8'h10, 8'h38, 8'h38, 8'h00, 1'b0};
		message[14]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[15]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
		message[16]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0};
	end
	else if (pat_num == 8'd124)
	begin
		//								V		C			I
		message[0]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[1]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[2]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[3]	<=	{8'h0, 8'hE7, 8'h3E, 8'h7C, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[4]	<=	{8'h0, 8'h42, 8'h42, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[5]	<=	{8'h0, 8'h42, 8'h42, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[6]	<=	{8'h0, 8'h44, 8'h80, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[7]	<=	{8'h0, 8'h24, 8'h80, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[8]	<=	{8'h0, 8'h24, 8'h80, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[9]	<=	{8'h0, 8'h28, 8'h80, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[10]	<=	{8'h0, 8'h28, 8'h80, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[11]	<=	{8'h0, 8'h18, 8'h42, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[12]	<=	{8'h0, 8'h10, 8'h44, 8'h10, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[13]	<=	{8'h0, 8'h10, 8'h38, 8'h7C, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[14]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[15]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
		message[16]	<=	{8'h0, 8'h00, 8'h00, 8'h00, 4'h00, 8'h00, 8'h00, 8'h00, 4'h00, 1'b0};
	end
end 

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		message_scale	<=	5'd10;
	end
	else
	begin
		case (hsum)
		12'd360:		//360*326
			begin
				message_scale	<=	5'd4;	//64*5 + 40 = 360
			end
		12'd720:		//720*1280
			begin
				message_scale	<=	5'd10;	//64*11 + 16 = 720
			end
		12'd1080:	//1080*1920
			begin
				message_scale	<=	5'd15;	//64*16 + 56 = 1080
			end
		default:
			begin
				message_scale	<=	5'd10;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_message	<=	{8'd0, 8'd0, 8'd0};
		message_hcnt64		<=	7'd0;
		message_vcnt16		<=	5'd0;
		message_scale_h		<=	5'd0;
		message_scale_v		<=	5'd0;
	end
	else if (v_sec3 == 1'b1)
	begin
		if (hcnt > 12'd0)
		begin
			if (message[message_vcnt16][7'd64 - message_hcnt64] == 1'b1)
			begin
				pat_message	<=	{8'd255, 8'd0, 8'd0};
			end
			else
			begin
				pat_message	<=	{pat_rval, pat_rval, pat_rval};
			end

			if (message_scale_h == message_scale)
			begin
				message_scale_h	<=	5'd0;
				if (message_hcnt64 >= 7'd63)
				begin
					message_hcnt64	<=	7'd64;
				end
				else
				begin
					message_hcnt64	<=	message_hcnt64 + 7'd1;
				end
			end
			else
			begin
				message_scale_h <= message_scale_h + 5'd1;
			end

			if (hcnt == hsum - 12'd1)
			begin
				if (message_scale_v == message_scale)
				begin
					message_scale_v	<=	5'd0;
					if (message_vcnt16 >= 5'd15)
					begin
						message_vcnt16	<=	5'd16;
					end
					else
					begin
						message_vcnt16	<=	message_vcnt16 + 5'd1;
					end
				end
				else
				begin
					message_scale_v	<=	message_scale_v + 5'd1;
				end
				message_hcnt64	<=	7'd0;
				message_scale_h	<=	5'd0;
			end
		end
		else
		begin
			message_hcnt64	<=	7'd0;
			message_scale_h	<=	5'd0;
		end
	end
	else
	begin
		pat_message	<=	{pat_rval, pat_rval, pat_rval};
		message_hcnt64		<=	7'd0;
		message_vcnt16		<=	5'd0;
		message_scale_h		<=	5'd0;
		message_scale_v		<=	5'd0;
	end
end

//-----------------------------------------------------------------------------
// pattern: black cross at center
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cross_black <= 8'd0;
	end
	else if ((vcnt == vsum >> 1'b1) || (hcnt == hsum >> 1'b1))
	begin
		pat_cross_black <= 8'd0;
	end
	else
	begin
		pat_cross_black <= pat_rval;
	end
end

//-----------------------------------------------------------------------------
// pattern: white cross at center
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_cross_white <= 8'd0;
	end
	else if ((vcnt == vsum >> 1'b1) || (hcnt == hsum >> 1'b1))
	begin
		pat_cross_white <= 8'd255;
	end
	else
	begin
		pat_cross_white <= pat_rval;
	end
end

//-----------------------------------------------------------------------------
// pattern: middle area crosstalk @ dot flicker  
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_dot	<=	24'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_dot	<=	{pat_gval, pat_gval, pat_gval};
		end
		else if (vcnt1[0] == hcnt1[0])
		begin
			pat_crst_dot	<=	{pat_rval, 8'd0, pat_rval};
		end
		else
		begin
			pat_crst_dot	<=	{8'd0, pat_rval, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// pattern: middle area crosstalk @ pixel flicker  
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_pixel	<=	24'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_pixel	<=	{pat_gval, pat_gval, pat_gval};
		end
		else if (vcnt1[0] == hcnt1[0])
		begin
			pat_crst_pixel	<=	{pat_rval, pat_rval, pat_rval};
		end
		else
		begin
			pat_crst_pixel	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// pattern: middle area crosstalk @ column flicker  
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_column	<=	24'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_column	<=	{pat_gval, pat_gval, pat_gval};
		end
		else if (hcnt1[0] == 1'b0)
		begin
			pat_crst_column	<=	{pat_rval, 8'd0, pat_rval};
		end
		else
		begin
			pat_crst_column	<=	{8'd0, pat_rval, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// pattern: middle area crosstalk @ pixel column flicker  
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_pcolumn	<=	24'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_pcolumn	<=	{pat_gval, pat_gval, pat_gval};
		end
		else if (hcnt1[0] == 1'b0)
		begin
			pat_crst_pcolumn	<=	{pat_rval, pat_rval, pat_rval};
		end
		else
		begin
			pat_crst_pcolumn	<=	{8'd0, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - samsung spec
//-----------------------------------------------------------------------------
wire[11:0] offset;
reg[11:0] h_block_size;
reg[11:0] v_block_size;

assign offset = {pat_gval[2:0], pat_bval[7:0]};

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		h_block_size	<=	11'd0;
	end
	else
	begin
		case (hsum)
		12'd360:
			begin
				h_block_size	<=	11'd120;
			end
		12'd720:
			begin
				h_block_size	<=	11'd240;
			end
		12'd1080:
			begin
				h_block_size	<=	11'd360;
			end
		default:
			begin
				h_block_size	<=	11'd0;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		v_block_size	<=	11'd0;
	end
	else
	begin
		case (vsum)
		12'd326:
			begin
				v_block_size	<=	11'd108;
			end
		12'd1280:
			begin
				v_block_size	<=	11'd426;
			end
		12'd1920:
			begin
				v_block_size	<=	11'd640;
			end
		12'd2160:
			begin
				v_block_size	<=	11'd720;
			end
		12'd2100:
			begin
				v_block_size	<=	11'd700;
			end
		12'd2244:
			begin
				v_block_size	<=	11'd748;
			end
		12'd2400:
			begin
				v_block_size	<=	11'd800;
			end
		12'd2266:
			begin
				v_block_size	<=	11'd755;
			end
		12'd2280:
			begin
				v_block_size	<=	11'd760;
			end
		12'd1520:
			begin
				v_block_size	<=	11'd506;
			end
		12'd2340:
			begin
				v_block_size	<=	11'd780;
			end
		12'd2246:
			begin
				v_block_size	<=	11'd748;
			end
		12'd2310:
			begin
				v_block_size	<=	11'd770;
			end
		12'd2312:
			begin
				v_block_size	<=	11'd770;
			end
		12'd2520:
			begin
				v_block_size	<=	11'd840;
			end
		12'd2270:
			begin
				v_block_size	<=	11'd756;
			end
		default:
			begin
				v_block_size	<=	11'd0;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_samsung5	<=	8'd0;
	end
	else if (hcnt > 12'd0)
	begin
		if ((h_sec3 == 1'b0) && (vcnt >= offset) && (vcnt < offset + v_block_size))
		begin
			pat_crst_samsung5	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_samsung5	<=	pat_rval;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_samsung6	<=	8'd0;
	end
	else if (hcnt > 12'd0)
	begin 
		if ((v_sec3 == 1'b0) && (hcnt >= offset) && (hcnt < offset + h_block_size))
		begin
			pat_crst_samsung6	<=	{8{pat_gval[7]}};
		end
		else
		begin
			pat_crst_samsung6	<=	pat_rval;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: mark
//-----------------------------------------------------------------------------
reg[7:0] mark_gray_h;
reg[7:0] mark_gray_v;
reg[11:0] mark_cnt_h;
reg[11:0] mark_cnt_v;
reg[8:0] mark_block_h;
reg[8:0] mark_block_v;

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		mark_block_h	<=	8'd0;
	end
	else if (hsum == 12'd720)
	begin
		mark_block_h	<=	8'd100;
	end
	else if (hsum == 12'd1080)
	begin
		if ((hcnt >= (12'd540 - 12'd18)) && (hcnt < (12'd540 + 12'd18)))
		begin
			mark_block_h	<=	8'd36;
		end
		else
		begin
			mark_block_h	<=	8'd128;
		end		
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		mark_block_v	<=	8'd0;
	end
	else if (vsum == 12'd1280)
	begin
		if ((vcnt >= (12'd640 - 12'd30)) && (vcnt < (12'd640 + 12'd30)))
		begin
			mark_block_v	<=	8'd60;
		end
		else
		begin
			mark_block_v	<=	8'd100;
		end
	end
	else if (vsum == 12'd1920)
	begin
		if ((vcnt >= (12'd960 - 12'd54)) && (vcnt < (12'd960 + 12'd54)))
		begin
			mark_block_v	<=	8'd108;
		end
		else
		begin
			mark_block_v	<=	8'd128;
		end		
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		mark_gray_h	<=	8'd0;
		mark_cnt_h <= 12'd0;
	end
	else if (hcnt >= 12'd10)
	begin
		if (mark_cnt_h == (mark_block_h - 8'd1))
		begin
			mark_cnt_h <= 8'd0;
			mark_gray_h <= mark_gray_h + 8'd1;
		end
		else
		begin
			mark_cnt_h <= mark_cnt_h + 8'd1;
		end
	end
	else
	begin
		mark_gray_h	<=	8'd0;
		mark_cnt_h <= 12'd0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		mark_gray_v	<=	8'd0;
		mark_cnt_v <= 12'd0;
	end
	else if (vcnt >= 12'd10)
	begin
		if (hcnt == hsum - 12'd1)
		begin
			if (mark_cnt_v == (mark_block_v - 12'd1))
			begin
				mark_gray_v <= mark_gray_v + 8'd1;
				mark_cnt_v <= 12'd0;
			end
			else
			begin
				mark_cnt_v <= mark_cnt_v + 12'd1;
			end
		end
	end
	else
	begin
		mark_gray_v	<=	8'd0;
		mark_cnt_v <= 12'd0;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_mark	<=	8'd0;
	end
	else
	begin
		if ((hcnt < 12'd10) || (hcnt >= (hsum - 12'd10)) || (vcnt < 12'd10) || (vcnt >= (vsum - 12'd10)))
		begin
			pat_mark	<=	8'd255;
		end
		else if (mark_gray_h[0] == mark_gray_v[0])
		begin
			pat_mark	<=	8'd0;
		end
		else
		begin
			pat_mark	<=	8'd255;
		end		
	end
end

//-----------------------------------------------------------------------------
// Pattern: gray RGB bar
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gcbar	<=	24'h000000;
	end
	else
	begin
		if (h_sec2 == 1'b1)
		begin
			if (h_sec4 == 1'b1)
			begin
				pat_gcbar	<=	{8'd0, 8'd0, v_div256_gry};
			end
			else
			begin
				pat_gcbar	<=	{v_div256_gry, v_div256_gry, v_div256_gry};
			end
		end
		else
		begin
			if (h_sec4 == 1'b1)
			begin
				pat_gcbar	<=	{8'd0, v_div256_gry, 8'd0};
			end
			else
			begin
				pat_gcbar	<=	{v_div256_gry, 8'd0, 8'd0};
			end
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: graybar
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_gbar	<=	8'h00;
	end
	else
	begin
		if (v_sec3 == 1'b1)
		begin
			pat_gbar	<=	pat_gval;
		end
		else
		begin
			if (v_sec2 == 1'b1)
			begin
				pat_gbar	<=	pat_rval;
			end
			else
			begin
				pat_gbar	<=	pat_bval;
			end
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: RGBbar
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_RGBbar	<=	24'h000000;
	end
	else
	begin
		if (v_sec3 == 1'b1)
		begin
			pat_RGBbar	<=	{8'd0, pat_gval, 8'd0};
		end
		else
		begin
			if (v_sec2 == 1'b1)
			begin
				pat_RGBbar	<=	{pat_rval, 8'd0, 8'd0};;
			end
			else
			begin
				pat_RGBbar	<=	{8'd0, 8'd0, pat_bval};;
			end
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_GBbar	<=	24'h000000;
	end
	else
	begin
		if (v_sec2 == 1'b1)
		begin
			pat_GBbar	<=	{8'd0, pat_gval, 8'd0};
		end
		else
		begin
			pat_GBbar	<=	{8'd0, 8'd0, pat_bval};;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: crosstalk - huawei new spec, middle area black
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw_new	<=	24'd0;
	end
	else
	begin
		if ((h_sec3 == 1'b1) && (v_sec3 == 1'b1))
		begin
			pat_crst_hw_new	<=	{pat_rval, pat_gval, pat_bval};
		end
		else
		begin
			pat_crst_hw_new	<=	{bg_r, bg_g, bg_b};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: center red rectangular for CA310 alignment
//-----------------------------------------------------------------------------
wire[9:0] half_length;
assign half_length = {1'b0, pat_gval[1:0], pat_bval[7:1]};
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_center_rect	<=	24'd0;
	end
	else
	begin 
		if ((((vcnt == (vsum >> 1'b1) - half_length) || (vcnt == (vsum >> 1'b1) + half_length))
		&& ((hcnt > (hsum >> 1'b1) - half_length) && (hcnt < (hsum >> 1'b1) + half_length)))
		|| (((hcnt == (hsum >> 1'b1) - half_length) || (hcnt == (hsum >> 1'b1) + half_length))
		&& ((vcnt > (vsum >> 1'b1) - half_length) && (vcnt < (vsum >> 1'b1) + half_length))))		
		begin
			pat_center_rect	<=	{8'd255, 8'd0, 8'd0};
		end
		else
		begin
			pat_center_rect	<=	{pat_rval, pat_rval, pat_rval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_wb	<=	8'd0;
	end
	else
	begin
	if (hcnt1 < (hsum >> 1'b1))
		begin
			pat_wb	<=	8'd0;
		end
		else
		begin
			pat_wb	<=	8'd255;
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: 
//-----------------------------------------------------------------------------
wire[9:0] outline_width;
assign outline_width = {pat_gval[1:0], pat_bval[7:0]};
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw_new1	<=	24'd0;
	end
	else
	begin 
		if ((vcnt1 >= outline_width) && (vcnt1 < (vsum - outline_width))
		&& (hcnt1 >= outline_width) && (hcnt1 < (hsum - outline_width)))	
		begin
			pat_crst_hw_new1	<=	{pat_rval, pat_rval, pat_rval};
		end
		else
		begin
			pat_crst_hw_new1	<=	{8'd255, 8'd0, 8'd0};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: 
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw_new2	<=	24'd0;
	end
	else
	begin 
		if ((h_sec3 == 1'b0) && (v_sec3 == 1'b0))
		begin
			pat_crst_hw_new2	<=	{bg_r, bg_g, bg_b};
		end
		else
		begin
			pat_crst_hw_new2	<=	{pat_rval, pat_gval, pat_bval};
		end
	end
end

//-----------------------------------------------------------------------------
// Pattern: hw crosstalk - snake type
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw_snake1	<=	24'd0;
	end
	else
	begin 
		if (v_div256_gry <= 21)
			pat_crst_hw_snake1   <=     {8'd0, 8'd0, 8'd0};
		else  if ((v_div256_gry >= 63) && (v_div256_gry <= 85) && (h_div256_gry <= 192))
			pat_crst_hw_snake1   <=     {8'd0, 8'd0, 8'd0};
		else  if ((v_div256_gry >= 126) && (v_div256_gry <= 150) && (h_div256_gry >= 65))
			pat_crst_hw_snake1   <=     {8'd0, 8'd0, 8'd0};
		else  if ((v_div256_gry >= 189) && (v_div256_gry <= 210) && (h_div256_gry <= 192))
			pat_crst_hw_snake1   <=     {8'd0, 8'd0, 8'd0};
		else 
			pat_crst_hw_snake1   <=     {8'd255, 8'd255, 8'd255};
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw_snake2	<= 24'h000000;
	end
	else
	begin
		if ((v_div256_gry >= 39) && (v_div256_gry <= 62) && (h_div256_gry <= 192))
			pat_crst_hw_snake2   <=     {8'd0, 8'd0, 8'd0};
		else  if ((v_div256_gry >= 105) && (v_div256_gry <= 126) && (h_div256_gry >= 65))
			pat_crst_hw_snake2   <=     {8'd0, 8'd0, 8'd0};
		else  if ((v_div256_gry >= 168) && (v_div256_gry <= 189) && (h_div256_gry <= 192))
			pat_crst_hw_snake2   <=     {8'd0, 8'd0, 8'd0};
		else if (v_div256_gry >= 230)
			pat_crst_hw_snake2   <=     {8'd0, 8'd0, 8'd0};
		else 
			pat_crst_hw_snake2   <=     {8'd255, 8'd255, 8'd255};
	end
end

//-----------------------------------------------------------------------------
// Pattern: vertical color bar for Huawei(0~255 level)
//-----------------------------------------------------------------------------

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pat_crst_hw_gradients	<=	24'h000000;
	end
	else
	begin
		case (~h_div256_gry[7:5])
		3'd0:
			begin
				pat_crst_hw_gradients	<=	{3{v_div256_gry}};
			end
		3'd1:
			begin
				pat_crst_hw_gradients	<=	{8'd0, 8'd0, v_div256_gry};
			end
		3'd2:
			begin
				pat_crst_hw_gradients	<=	{8'd0, v_div256_gry, 8'd0};
			end
		3'd3:
			begin
				pat_crst_hw_gradients	<=	{8'd0, v_div256_gry, v_div256_gry};
			end
		3'd4:
			begin
				pat_crst_hw_gradients	<=	{v_div256_gry, 8'd0, 8'd0};
			end
		3'd5:
			begin
				pat_crst_hw_gradients	<=	{v_div256_gry, 8'd0, v_div256_gry};
			end
		3'd6:
			begin
				pat_crst_hw_gradients	<=	{v_div256_gry, v_div256_gry, 8'd0};
			end
		3'd7:
			begin
				pat_crst_hw_gradients	<=	{3{v_div256_gry}};
			end
		default:
			begin
				pat_crst_hw_gradients	<=	24'h000000;
			end
		endcase
	end
end

//add new pattern here

//-----------------------------------------------------------------------------
// Pattern selection
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		{rbuf, gbuf, bbuf} <= {8'd0, 8'd0, 8'd0};
	end
	else
	begin
		case (pat_num)
		8'd0:	//pure color pattern
			begin
				{rbuf, gbuf, bbuf} <= {pat_rval, pat_gval, pat_bval};
			end
		8'd1:	//crosstalk - huawei spec, middle area black
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_hw1}};
			end
		8'd2:	//crosstalk - samsung spec, up & down area black
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_samsung1}};
			end
		8'd3:	//crosstalk - moto spec, up & down area black
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_moto3}};
			end
		8'd4:	//crosstalk - samsung spec, left & right area black
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_samsung3}};
			end
		8'd5:	//crosstalk - moto spec, left & right area black
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_moto5}};
			end
		8'd6:	//crosstalk - moto spec, four corner area black
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_moto1}};
			end
		8'd7:	//crosstalk - huawei spec, middle area white
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_hw2}};
			end
		8'd8:	//crosstalk - samsung spec, up & down area white
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_samsung2}};
			end
		8'd9:	//crosstalk - moto spec, up & down area white
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_moto4}};
			end
		8'd10:	//crosstalk - samsung spec, left & right area white
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_samsung4}};
			end
		8'd11:	//crosstalk - moto spec, left & right area white
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_moto6}};
			end
		8'd12:	//crosstalk - moto spec, four corner area white
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_moto2}};
			end
		8'd13:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_v;
			end
		8'd14:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_h;
			end
		8'd15:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar16_v}};
			end
		8'd16:	//graybar 16 level
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar16_h}};
			end
		8'd17:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar256_v}};
			end
		8'd18:	//graybar 256 level
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar256_h}};
			end
		8'd19:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb64}};
			end
		8'd20:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb8}};
			end
		8'd21:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_pcln;
			end
		8'd22:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_cln;
			end
		8'd23:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_1pixel;
			end
		8'd24:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_1dot;
			end
		8'd25:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_2pixel;
			end
		8'd26:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_2dot;
			end
		8'd27:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_4pixel;
			end
		8'd28:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_4dot;
			end
		8'd29:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_gry;
			end
		8'd30:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crs_brd}};
			end
		8'd31:
			begin
				{rbuf, gbuf, bbuf} <= pat_oln_det;
			end
		8'd32:
			begin
				{rbuf, gbuf, bbuf} <= pat_1x1_bar;
			end
		8'd33:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar16_v1}};
			end
		8'd34:	//graybar 16 level (reverse order)
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar16_h1}};
			end
		8'd35:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar256_v1}};
			end
		8'd36:	//graybar 256 level (reverse order)
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar256_h1}};
			end
		8'd37:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar8_v}};
			end 
		8'd38:	//graybar 8 level 
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar8_h}};
			end
		8'd39:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar8_v1}};
			end
		8'd40:	//graybar 8 level (reverse order)
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar8_h1}};
			end
		8'd41:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar32_v}};
			end
		8'd42:	//graybar 32 level 
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar32_h}};
			end
		8'd43:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar32_v1}};
			end
		8'd44:	//graybar 32 level (reverse order)
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar32_h1}};
			end
		8'd45:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar64_v}};
			end
		8'd46:	//graybar 64 level 
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar64_h}};
			end
		8'd47:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar64_v1}};
			end
		8'd48:	//graybar 64 level (reverse order)
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar64_h1}};
			end
		8'd49:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_v1;
			end
		8'd50:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_h1;
			end
		8'd51:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb8_r}};
			end
		8'd52:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb64_r}};
			end
		8'd53:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb16}};
			end
		8'd54:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb16_r}};
			end
		8'd55:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb32}};
			end
		8'd56:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb32_r}};
			end
		8'd57:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_1dot_r;
			end
		8'd58:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_2dot_r;
			end
		8'd59:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_4dot_r;
			end
		8'd60:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_cln_r;
			end
		8'd61:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_1dot_g;
			end
		8'd62:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_2dot_g;
			end
		8'd63:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_4dot_g;
			end
		8'd64:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_cln_g;
			end
		8'd65:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_1dot_b;
			end
		8'd66:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_2dot_b;
			end
		8'd67:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_4dot_b;
			end
		8'd68:
			begin
				{rbuf, gbuf, bbuf} <= pat_flk_cln_b;
			end
		8'd69:
			begin
				{rbuf, gbuf, bbuf} <= pat_1x1_bar1;
			end
		8'd70:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb4}};
			end
		8'd71:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb4_r}};
			end
		8'd72:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_htc;
			end
		8'd73:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_gbar256_diag}};
			end
		8'd74:
			begin
				{rbuf, gbuf, bbuf} <= pat_character;
			end
		8'd75:
			begin
				{rbuf, gbuf, bbuf} <= pat_1x1_dotbar;
			end
		8'd76:
			begin
				{rbuf, gbuf, bbuf} <= pat_1x1_dotbar1;
			end
		8'd77:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb6}};
			end
		8'd78:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb6_r}};
			end
		8'd79:
			begin
				{rbuf, gbuf, bbuf} <= pat_oln_det1;
			end
		8'd80:
			begin
				{rbuf, gbuf, bbuf} <= pat_oln_det2;
			end
		8'd81:
			begin
				{rbuf, gbuf, bbuf} <= pat_oln_det3;
			end
		8'd82:
			begin
				{rbuf, gbuf, bbuf} <= bright_dot;
			end
		8'd83:
			begin
				{rbuf, gbuf, bbuf} <= pat_crst_waku;
			end
		8'd84:
			begin
				{rbuf, gbuf, bbuf} <= pat_otp_check;
			end
		8'd85:
			begin
				{rbuf, gbuf, bbuf} <= pat_otp_NG;
			end
		8'd86:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end
		8'd87:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end
		8'd88:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cross_black}};
			end
		8'd89:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cross_white}};
			end
		8'd90:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_gry256;
			end
		8'd91:
			begin
				{rbuf, gbuf, bbuf} <= pat_crst_waku;
			end
		8'd92:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_asus;
			end
		8'd93:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb12}};
			end
		8'd94:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_asus1}};
			end
		8'd95:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_asus2}};
			end
		8'd96:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_asus3}};
			end
		8'd97:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end
		8'd98:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end
		8'd99:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end	
		8'd100:
			begin
				{rbuf, gbuf, bbuf} <= pat_crst_dot;
			end
		8'd101:
			begin
				{rbuf, gbuf, bbuf} <= pat_crst_pixel;
			end
		8'd102:
			begin
				{rbuf, gbuf, bbuf} <= pat_crst_column;
			end
		8'd103:
			begin
				{rbuf, gbuf, bbuf} <= pat_crst_pcolumn;
			end
		8'd104:
			begin
				{rbuf, gbuf, bbuf} <= pat_1x1_bar2;
			end	
		8'd105:
			begin
				{rbuf, gbuf, bbuf} <= pat_1x1_bar3;
			end	
		8'd106:
			begin
				{rbuf, gbuf, bbuf} <= pat_cbar_lenovo;
			end
		8'd107:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_samsung5}};
			end
		8'd108:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_samsung6}};
			end
		8'd109:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_mark}};
			end
		8'd110:
			begin
				{rbuf, gbuf, bbuf} <= pat_character;
			end
		8'd111:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb12}};
			end
		8'd112:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_cesb12}};
			end
		8'd113:
			begin
				{rbuf, gbuf, bbuf} <= pat_otp_NG;
			end
		8'd114:
			begin
				{rbuf, gbuf, bbuf} <= pat_otp_NG;
			end
		8'd115:
			begin
				{rbuf, gbuf, bbuf} <= pat_oln_det4;
			end
		8'd116:
			begin
				{rbuf, gbuf, bbuf} <= pat_otp_check;
			end
		8'd117:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_meizu1}};
			end		
		8'd118:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_meizu2}};
			end
		8'd119:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_meizu3}};
			end
		8'd120:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_meizu4}};
			end
		8'd121:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_meizu5}};
			end
		8'd122:
			begin
				{rbuf, gbuf, bbuf} <= {3{pat_crst_meizu6}};
			end
		8'd123:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end
		8'd124:
			begin
				{rbuf, gbuf, bbuf} <= pat_message;
			end
		8'd125:
		begin
			 {rbuf, gbuf, bbuf} <= pat_gcbar;
		end
		8'd126:
		begin
			 {rbuf, gbuf, bbuf} <= {3{pat_gbar}};
		end
		8'd127:
		begin
			 {rbuf, gbuf, bbuf} <=  pat_RGBbar;
		end
		8'd128:
		begin
			 {rbuf, gbuf, bbuf} <=  pat_crst_hw_new;
		end
		8'd129:
		begin
			 {rbuf, gbuf, bbuf} <=  pat_center_rect;
		end
		8'd130:
		begin
			 {rbuf, gbuf, bbuf} <= {3{pat_wb}};
		end
		8'd131:
		begin
			 {rbuf, gbuf, bbuf} <= {3{~pat_wb}};
		end
		8'd132:
		begin
			 {rbuf, gbuf, bbuf} <=  pat_crst_hw_new1;
		end
		8'd133:
		begin
			 {rbuf, gbuf, bbuf} <=  pat_crst_hw_new2;
		end
		8'd134:	
		begin
			{rbuf, gbuf, bbuf} <= {3{pat_crst_sony1}};
		end
		8'd135:	
		begin
			{rbuf, gbuf, bbuf} <= {3{pat_crst_sony2}};
		end
		8'd136:	
		begin
			{rbuf, gbuf, bbuf} <= pat_crst_hw_snake1;
		end
		8'd137:	
		begin
			{rbuf, gbuf, bbuf} <= pat_crst_hw_snake2;
		end
		8'd138:
		begin
			{rbuf, gbuf, bbuf} <= pat_crst_hw_gradients;
		end
		8'd139:
		begin
			{rbuf, gbuf, bbuf} <= pat_otp_check;
		end	
		8'd140:
		begin
			{rbuf, gbuf, bbuf} <= pat_JDI_pixel_white;
		end
		8'd141:
		begin
			{rbuf, gbuf, bbuf} <= pat_JDI_RGB_white;
		end
		8'd142:
		begin
			{rbuf, gbuf, bbuf} <= pat_GBbar;
		end
		8'd143:
		begin
			{rbuf, gbuf, bbuf} <= black_dot;
		end
		default:
			begin
				{rbuf, gbuf, bbuf} <= {8'd0, 8'd0, 8'd255};
			end
		endcase
	end
end

endmodule