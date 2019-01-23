// ****************************************************************************
// COPYRIGHT (c) 2014, Xiamen Tianma Microelectronics Co, Ltd
// All rights reserved.
//
// Author		:	xiaojing_zhan
// Email			:	xiaojing_zhan@tianma.cn
//
// File name	:	rgb_intf.v
// Version		:	V 1.0
// Abstract		:	Generate RGB interface timing
// Called by	:	FPGA_DEMO
//
// ----------------------------------------------------------------------------
// Revison 
// 2014-07-04	:	Create file.
// 2014-07-28  :  Change module name to rgb_intf, and changer protecal between FPGA and ARM
// ****************************************************************************
module rgb_intf(
	input						clk,
	input						rst_n,

	input						te_detect,
	input						te_detect_en,
	
	input		[15:0]		hact,
	input		[15:0]		vact,
	input		[7:0]			vpw,
	input		[15:0]		vbp,
	input		[15:0]		vfp,
	input		[7:0]			hpw,
	input		[15:0]		hbp,
	input		[15:0]		hfp,

	input						dis_mode,
	input		[7:0]			dis_num,
	input						port_map,
	input						init_end,
	input						pic_mask_en,
	input    [11:0]      info_y_axis,
	
	input		[7:0]			r_data,
	input		[7:0]			g_data,
	input		[7:0]			b_data,
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
	input		[7:0]			graylvl1,
	input		[7:0]			graylvl2,
	input		[7:0]			graylvl3,
	
	input		[7:0]			otp_times1,
	input		[7:0]			otp_times2,
	input		[7:0]			info_show_en,
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
	
	input		[47:0]		pic_data,
	input						pic_rdy,
	output	reg			pic_fifo_rd,

	output	reg			rgb_hs,
	output	reg			rgb_vs,
	output	reg			rgb_en,
	output	reg[47:0]	rgb_data
);

// ----------------------------------------------------------------------------
// Parameters definition
// ----------------------------------------------------------------------------
parameter FPGA_version = "V1P0";

// ----------------------------------------------------------------------------
// Variable definition
// ----------------------------------------------------------------------------
// resolution
reg	[11:0]	hsum;
reg	[11:0]	vsum;

// porch
reg	[15:0]	h_blank;
reg	[15:0]	v_blank;
reg	[15:0]	h_blank_de;
reg	[15:0]	v_blank_de;
reg	[15:0]	h_total;
reg	[15:0]	v_total;

// timing
reg	[11:0]	hcnt;
reg	[11:0]	vcnt;
reg	[15:0]	line_cnt;
reg	[15:0]	pixcel_cnt;
reg				hsync_buf, vsync_buf, den_buf;
reg				hsync_buf1, vsync_buf1, den_buf1;
reg				hsync_buf2, vsync_buf2, den_buf2;
reg				hsync_buf3, vsync_buf3, den_buf3;
reg				hsync_buf4, vsync_buf4, den_buf4;
wire	[47:0]	pat_data;

// rgb data before add information
reg				pic_rdy_buf;
reg				dis_mode_buf;
reg	[7:0]		dis_num_buf;
reg	[7:0]		r_data_buf;
reg	[7:0]		g_data_buf;
reg	[7:0]		b_data_buf;
reg	[7:0]		graylvl_buf;
reg	[47:0]	data_buf;
reg	[23:0]	data_buf1;

// rgb data after add information 
wire	[7:0]		r_data_out;
wire	[7:0]		g_data_out;
wire	[7:0]		b_data_out;
wire				if_digital;

// ----------------------------------------------------------------------------
// Continuous assignment
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// TE detect
// ----------------------------------------------------------------------------
reg te_ng;
reg te_buf1, te_buf2;
reg [11:0] te_cnt;

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		te_ng	<= 1'b0;
	end 
	else if (line_cnt == (v_total >> 1))
	begin
		if (te_cnt < (vact >> 1))
		begin
			te_ng	<= 1'b1;
		end
		else
		begin
			te_ng	<= 1'b0;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		te_buf1	<= 1'b0;
		te_buf2	<=	1'b0;
		te_cnt <= 12'd0;
	end  
	else if (rgb_vs == 1'b1)
	begin
		te_buf1	<= te_detect;
		te_buf2	<=	te_buf1;
		if (te_buf1 == 1'b1 && te_buf2 == 1'b0)
		begin
			te_cnt <= te_cnt + 12'd1;
		end
	end
	else
	begin
		te_cnt <= 12'd0;
	end
end

// ----------------------------------------------------------------------------
// Main timing
// ----------------------------------------------------------------------------
always @(posedge clk)
begin
	h_blank		<=	hpw + hbp;
	v_blank		<=	vpw + vbp;
	h_blank_de	<=	hpw + hbp + hact;
	v_blank_de	<=	vpw + vbp + vact;
	h_total		<=	hpw + hbp + hact + hfp;
	v_total		<=	vpw + vbp + vact + vfp;
	
	hsum			<=	hact[11:0];
	vsum			<=	vact[11:0];
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		line_cnt		<=	16'd0;
		pixcel_cnt	<=	16'd0;
	end  
	else if (init_end == 1'b0)
	begin
		line_cnt		<=	16'd0;
		pixcel_cnt	<=	16'd0;
	end
	else
	begin
		if ((line_cnt == (v_total - 16'd1)) && (pixcel_cnt == (h_total - 16'd1)))
		begin
			line_cnt		<=	16'd0;
			pixcel_cnt	<=	16'd0;
		end
		else if (pixcel_cnt == (h_total - 16'd1))
		begin
			line_cnt		<=	line_cnt + 16'd1;
			pixcel_cnt	<=	16'd0;
		end
		else
		begin
			pixcel_cnt	<=	pixcel_cnt + 16'd1;
		end
	end
end

// ----------------------------------------------------------------------------
// Active area timing
// ----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		vcnt	<=	12'd0;
		hcnt	<=	12'd0;
	end
	else
	begin
		if ((pixcel_cnt >= h_blank) && (pixcel_cnt < h_blank_de)) 
		begin
			hcnt	<=	pixcel_cnt[11:0] - h_blank[11:0];
		end
		else
		begin
			hcnt	<=	12'd0;
		end
		
		if ((line_cnt >= v_blank) && (line_cnt < v_blank_de))
		begin
			vcnt	<=	line_cnt[11:0] - v_blank[11:0];
		end
		else 
		begin
			vcnt	<=	12'd0;
		end
	end
end

// ----------------------------------------------------------------------------
// Generate sync signal
// ----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		rgb_hs	<=	1'b1;
		rgb_vs	<=	1'b1;
		rgb_en	<=	1'b0;
	end
	else
	begin
		rgb_hs	<=	hsync_buf4;
		rgb_vs	<=	vsync_buf4;
		rgb_en	<=	den_buf4;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsync_buf4	<=	1'b1;
		vsync_buf4	<=	1'b1;
		den_buf4		<=	1'b0;
	end
	else
	begin
		hsync_buf4	<=	hsync_buf3;
		vsync_buf4	<=	vsync_buf3;
		den_buf4		<=	den_buf3;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsync_buf3	<=	1'b1;
		vsync_buf3	<=	1'b1;
		den_buf3		<=	1'b0;
	end
	else
	begin
		hsync_buf3	<=	hsync_buf2;
		vsync_buf3	<=	vsync_buf2;
		den_buf3		<=	den_buf2;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsync_buf2	<=	1'b1;
		vsync_buf2	<=	1'b1;
		den_buf2		<=	1'b0;
	end
	else
	begin
		hsync_buf2	<=	hsync_buf1;
		vsync_buf2	<=	vsync_buf1;
		den_buf2		<=	den_buf1;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsync_buf1	<=	1'b1;
		vsync_buf1	<=	1'b1;
		den_buf1		<=	1'b0;
	end
	else
	begin
		hsync_buf1	<=	hsync_buf;
		vsync_buf1	<=	vsync_buf;
		den_buf1		<=	den_buf;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		hsync_buf	<=	1'b1;
	end
	else if (init_end == 1'b0)
	begin
		hsync_buf	<=	'b1;
	end
	else
	begin
		if (pixcel_cnt < hpw)
		begin
			hsync_buf	<=	1'b0;
		end
		else
		begin
			hsync_buf	<=	1'b1;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		vsync_buf	<=	'b1;
	end
	else if (init_end == 1'b0)
	begin
		vsync_buf	<=	'b1;
	end
	else
	begin
		if (line_cnt < vpw)
		begin
			vsync_buf	<=	1'b0;
		end
		else
		begin
			vsync_buf	<=	1'b1;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		den_buf	<=	1'b0;
	end
	else if (init_end == 1'b0)
	begin
		den_buf	<=	1'b0;
	end
	else
	begin
		if ((line_cnt >= v_blank) && (line_cnt < v_blank_de) && (pixcel_cnt >= h_blank) && (pixcel_cnt < h_blank_de))
		begin
			den_buf	<=	1'b1;
		end
		else
		begin
			den_buf	<=	1'b0;
		end
	end
end

// ----------------------------------------------------------------------------
// Picture fifo read
// ----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pic_fifo_rd	<=	1'b0;
	end
	else if (pic_rdy_buf == 1'b0)
	begin
		pic_fifo_rd	<=	1'b0;
	end
	else
	begin
		if ((line_cnt >= v_blank) && (line_cnt < v_blank_de) && (pixcel_cnt >= h_blank + 12'd1) && (pixcel_cnt < h_blank_de + 12'd1))
		begin
			pic_fifo_rd	<=	1'b1;
		end
		else
		begin
			pic_fifo_rd	<=	1'b0;
		end
	end
end

// ----------------------------------------------------------------------------
// RGB output
// ----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		pic_rdy_buf		<=	1'b0;
		dis_mode_buf	<=	1'b0;
		dis_num_buf		<=	8'd0;
		r_data_buf		<= 8'd0;
		g_data_buf		<= 8'd0;
		b_data_buf		<= 8'd0;
	end
	else 
	begin
		if ((line_cnt == 16'b1) && (pixcel_cnt == 16'b1))	// change at the begin of new frame
		begin
			if (te_detect_en == 1'b1 && te_ng == 1'b1)
			begin
				pic_rdy_buf		<=	pic_rdy;
				dis_mode_buf	<=	1'b0;
				dis_num_buf		<=	8'd85;
				r_data_buf		<= 8'd0;
				g_data_buf		<= 8'd0;
				b_data_buf		<= 8'd0;
			end
			else
			begin
				pic_rdy_buf		<=	pic_rdy;
				dis_mode_buf	<=	dis_mode;
				dis_num_buf		<=	dis_num;
				r_data_buf		<= r_data;
				g_data_buf		<= g_data;
				b_data_buf		<= b_data;
			end
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if	(rst_n == 1'b0)
	begin
		data_buf		<=	{24'h0000FF, 24'h0000FF};
	end
	else //if (pic_mask_en == 1'b0)
	begin
		if (dis_mode_buf == 1'b0)
		begin
			data_buf	<=	pat_data;
		end
		else
		begin
			if (pic_rdy_buf == 1'b0)
			begin
				data_buf <=	{24'h0000FF, 24'h0000FF};
			end
			else
			begin
				data_buf	<=	pic_data;
			end
		end
	end
//	else
//	begin
//		if (pic_data[47:24] == 24'h000000)
//		begin
//			data_buf[47:24]	<=	pat_data[47:24];
//		end
//		else
//		begin
//			data_buf[47:24]	<=	pic_data[47:24];
//		end
//		
//		if (pic_data[23:0] == 24'h000000)
//		begin
//			data_buf[23:0]	<=	pat_data[23:0];
//		end
//		else
//		begin
//			data_buf[23:0]	<=	pic_data[23:0];
//		end
//	end
end

always @(negedge clk or negedge rst_n)
begin
	if	(rst_n == 1'b0)
	begin
		rgb_data	<=	{24'h000000, 24'h000000};
	end
	else if (init_end == 1'b0)
	begin
		rgb_data	<=	{24'h000000, 24'h000000};
	end
	else if (port_map == 1'b1)
	begin
		rgb_data	<=	{r_data_out, g_data_out, b_data_out, data_buf1};
	end
	else
	begin
		rgb_data	<=	{data_buf1, r_data_out, g_data_out, b_data_out};
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		data_buf1	<=	24'h000000;
	end
	else
	begin
		data_buf1	<=	data_buf[47:24];
	end
end

// ----------------------------------------------------------------------------
// Module instantiation
// ----------------------------------------------------------------------------
info_gen #(.FPGA_version(FPGA_version)) u_info_gen(
	.clk				(clk),

	.vcnt				(vcnt),
	.hcnt				(hcnt),
	
	.show_en			(info_show_en),
	.info_y_axis   (info_y_axis),
		
	.dis_num			(dis_num_buf),
	.r_data_in		(data_buf[23:16]),
	.g_data_in		(data_buf[15:8]),
	.b_data_in		(data_buf[7:0]),
	.pat_gray1		(graylvl1),
	.pat_gray2		(graylvl2),
	.pat_gray3		(graylvl3),
	.otp_times1		(otp_times1),
	.otp_times2		(otp_times2),
	
	.info0			(info0),
	.info1			(info1),
	.info2			(info2),
	.info3			(info3),
	.info4			(info4),
	.info5			(info5),
	.info6			(info6),
	.info7			(info7),
	.info8			(info8),
	.info9			(info9),
	.info10			(info10),
	.info11			(info11),
	.info12			(info12),
	.info13			(info13),
	.info14			(8'd0),
	.info15			(8'd0),
	.info16			(8'd0),
	
	.project0		(project0),
	.project1		(project1),
	.project2		(project2),
	.project3		(project3),
	.project4		(project4),
	.project5		(project5),
	.project6		(project6),
	.project7		(project7),
	.project8		(project8),
	.project9		(project9),
	.project10		(project10),
	.project11		(project11),
	.project12		(project12),
	.project13		(project13),
	.project14		(project14),
	.project15		(project15),
	.project16		(project16),
	.project17		(project17),
	.project18		(project18),
	.project19		(project19),
	.project20		(project20),
	.project21		(project21),

	.version0		(version0),
	.version1		(version1),
	.version2		(version2),
	.version3		(version3),
	.version4		(version4),
	.version5		(version5),
	.version6		(version6),
	.version7		(version7),
	.version8		(version8),
	.version9		(version9),
	.version10		(version10),
	.version11		(version11),
	.version12		(version12),
	
	.r_data_out		(r_data_out),
	.g_data_out		(g_data_out),
	.b_data_out		(b_data_out)
);

pat_gen u_pat_gen(
	.clk				(clk),
	.rst_n			(rst_n),	
	.vsum				(vsum),
	.hsum				(hsum),
	
	.vcnt				(vcnt),
	.hcnt				(hcnt),
	
	.pat_num			(dis_num_buf),


	.pat_rval		(r_data_buf),
	.pat_gval		(g_data_buf),
	.pat_bval		(b_data_buf),
	.dot_r1			(dot_r1),
	.dot_g1			(dot_g1),
	.dot_b1			(dot_b1),
	.dot_r2			(dot_r2),
	.dot_g2			(dot_g2),
	.dot_b2			(dot_b2),
	.dot_r3			(dot_r3),
	.dot_g3			(dot_g3),
	.dot_b3			(dot_b3),
	.bg_r				(bg_r),
	.bg_g				(bg_g),
	.bg_b				(bg_b),
	.rect_start_x	(rect_start_x),
	.rect_start_y	(rect_start_y),
	.rect_size_x	(rect_size_x),
	.rect_size_y	(rect_size_y),
	
	.pat_data		(pat_data)
);

endmodule