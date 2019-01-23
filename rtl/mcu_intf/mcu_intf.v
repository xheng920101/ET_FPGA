// ****************************************************************************
// COPYRIGHT (c) 2014, Xiamen Tianma Microelectronics Co, Ltd
// All rights reserved.
//
// Author		:	xiaojing_zhan
// Email			:	xiaojing_zhan@tianma.cn
//
// File name	:	mcu_intf.v
// Version		:	V 1.0
// Abstract		:	Generate MCU interface timing
// Called by	:	FPGA_DEMO
//
// ----------------------------------------------------------------------------
// Revison 
// 2014-12-16	:	Create file.
// ****************************************************************************
module mcu_intf(
	input						clk,
	input						rst_n,

	input		[15:0]		hact,
	input		[15:0]		vact,

	input						dis_mode,
	input		[7:0]			dis_num,
	input						port_map,
	input		[7:0]			port_main,
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
	
	input		[7:0]			op_type,
	input						ini_dcx,
	input		[7:0]			ini_data,
	input						read_finish,
	input		    			next_step,	
	output	reg			clc_next,
	
	input		[47:0]		pic_data,
	input						pic_rdy,
	output					pic_fifo_rd,
	output					pic_rd_clk,

	output					mcu_csx,
	output					mcu_rdx,
	output					mcu_wrx,
	output					mcu_dcx,
	inout		[47:0]		mcu_data,	
	output	reg[7:0]		data_rd
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

// MCU timing
reg				pclk;
reg	[11:0]	hcnt;
reg	[11:0]	vcnt;
reg	[2:0]		delay;

reg	[7:0] 	curr_disNum;	
reg				curr_disMode;			
reg	[7:0]		curr_rdata;
reg	[7:0]		curr_gdata;
reg	[7:0]		curr_bdata;
reg	[47:0]	rgb_data;

// pattern generator output
wire	[47:0]	pat_data;

// rgb data before add information
reg	[47:0]	data_buf;
reg	[23:0]	data_buf1;

// rgb data after add information 
wire	[7:0]		r_data_out;
wire	[7:0]		g_data_out;
wire	[7:0]		b_data_out;

// mcu interface
reg	[7:0]		ini_mstep, ini_sstep;
reg	csx_ini, rdx_ini, wrx_ini, dcx_ini;
reg	[47:0]   data_ini;
reg	data_dir;
wire	[7:0]		read_port;
reg[2:0] DATA_DELAY;
reg[2:0] pic_ini_dly;

// ----------------------------------------------------------------------------
// Continuous assignment
// ----------------------------------------------------------------------------
assign pic_rd_clk = pclk;//clk;//
assign pic_fifo_rd = ((dis_mode == 1'b1) && (pic_rdy == 1'b1));
assign mcu_csx = csx_ini;
assign mcu_rdx = rdx_ini;
assign mcu_wrx = wrx_ini;
assign mcu_dcx = dcx_ini;
assign mcu_data = (data_dir == 1'b0) ? data_ini : 48'bz;
assign read_port = (port_main == 8'b1) ? mcu_data[7:0] : mcu_data[31:24];

// ----------------------------------------------------------------------------
// Active area timing
// ----------------------------------------------------------------------------
always @(*)
begin	
	hsum	<=	hact[11:0];
	vsum	<=	vact[11:0];
end

// ----------------------------------------------------------------------------
// generate RGB data 
// ----------------------------------------------------------------------------
always @(posedge pclk or negedge rst_n)
begin
	if	(rst_n == 1'b0)
	begin
		data_buf		<=	{24'h0000FF, 24'h0000FF};
	end
	else if (pic_mask_en == 1'b0)
	begin
		if(dis_mode == 1'b0)
		begin
			data_buf	<=	pat_data;
		end
		else
		begin
			if(pic_rdy == 1'b0)
			begin
				data_buf <=	{24'h0000FF, 24'h0000FF};
			end
			else
			begin
				data_buf	<=	pic_data;
			end
		end
	end
	else
	begin
		if (pic_data[47:24] == 24'h000000)
		begin
			data_buf[47:24]	<=	pat_data[47:24];
		end
		else
		begin
			data_buf[47:24]	<=	pic_data[47:24];
		end
		
		if (pic_data[23:0] == 24'h000000)
		begin
			data_buf[23:0]	<=	pat_data[23:0];
		end
		else
		begin
			data_buf[23:0]	<=	pic_data[23:0];
		end
	end
end

always @(negedge pclk or negedge rst_n)
begin
	if	(rst_n == 1'b0)
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

always @(posedge pclk or negedge rst_n)
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
// MCU output
// ----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if	(rst_n == 1'b0)
	begin
		data_ini	<=	{24'h000000, 24'h000000};
		csx_ini <= 1'b1;
		dcx_ini <= 1'b1;
		rdx_ini <= 1'b1;
		wrx_ini <= 1'b1;				
		ini_mstep <= 8'd0;
		ini_sstep <= 8'd0;
		clc_next <= 1'b0;
		data_dir <= 1'b0;
		
		pclk <= 1'b1;
		vcnt <= 12'd0;
		hcnt <= 12'd0;

		curr_disMode <= 1'b0;
		curr_disNum <= 8'd0;
		curr_rdata <= 8'd0;
		curr_gdata <= 8'd0;
		curr_bdata <= 8'd0;
		
		pic_ini_dly <= 3'd4; //FHD->4	WQ->3
		DATA_DELAY <= 3'd6;
	end
	else if (op_type == 8'hAA)	//write
	begin
		case (ini_mstep)
		8'd0:
			begin
				data_ini	<=	{24'h000000, 24'h000000};
				dcx_ini <= 1'b1;
				rdx_ini <= 1'b1;
				wrx_ini <= 1'b1;								
				
				if (next_step == 1'b1)
				begin
					csx_ini <= 1'b0;
					ini_mstep <= 8'd1;
					clc_next <= 1'b1;
				end
			end
		8'd1:
			begin
				dcx_ini <= ini_dcx;
				ini_mstep <= 8'd2;
				clc_next <= 1'b0;
			end
		8'd2:
			begin
				wrx_ini <= 1'b0;
				ini_mstep <= 8'd3;
			end
		8'd3:
			begin				
				if (next_step == 1'b1)
				begin
					ini_mstep <= 8'd4;
					clc_next <= 1'b1;
				end
				else
				begin
					ini_mstep <= 8'd3;
				end
			end
		8'd4:
			begin
				data_ini	<=	{6{ini_data}};
				ini_mstep <= 8'd5;
				clc_next <= 1'b0;
			end
		8'd5:
			begin
				wrx_ini <= 1'b1;
				ini_mstep <= 8'd6;
			end
		8'd6:
			begin
				csx_ini <= 1'b1;
				ini_mstep <= 8'd0;
			end
		default:
			begin
				ini_mstep <= 8'd0;;
			end
		endcase
	end
	else if (op_type == 8'hBB)	//read
	begin
		case (ini_mstep)
		8'd0:
			begin
				data_ini	<=	{24'h000000, 24'h000000};
				dcx_ini <= 1'b1;
				rdx_ini <= 1'b1;
				wrx_ini <= 1'b1;	
				data_dir <= 1'b0;
				ini_mstep <= 8'd1;
				csx_ini <= 1'b0;
			end
		8'd1:
			begin
				data_dir <= 1'b1;
				ini_mstep <= 8'd2;
			end
		8'd2:
			begin
				rdx_ini <= 1'b0;
				ini_mstep <= 8'd3;
			end
		8'd3:
			begin
				ini_mstep <= 8'd4;
			end
		8'd4:
			begin
				rdx_ini <= 1'b1;
				ini_mstep <= 8'd5;
			end
		8'd5:
			begin
				data_rd <= read_port;
				ini_mstep <= 8'd6;
			end
		8'd6:
			begin
				csx_ini <= 1'b1;
				if (read_finish == 1'b1)
				begin
					ini_mstep <= 8'd7;
				end
			end
		8'd7:
			begin
				if (read_finish == 1'b0)
				begin
					ini_mstep <= 8'd2;
				end
			end
		default:
			begin
				ini_mstep <= 8'd0;
			end
		endcase
	end
	else if (op_type == 8'hDD) //display
	begin
		case (ini_mstep)
		8'd0:
			begin
				pclk <= 1'b1;
				vcnt <= 12'd0;
				hcnt <= 12'd0;
				
				curr_disMode <= dis_mode;
				curr_disNum <= dis_num;
				curr_rdata <= r_data;
				curr_gdata <= g_data;
				curr_bdata <= b_data;
				
				dcx_ini <= 1'b1;
				rdx_ini <= 1'b1;
				wrx_ini <= 1'b1;				
				ini_sstep <= 8'b0;		
				
				if (curr_disMode != dis_mode ||
					curr_disNum != dis_num ||
					curr_rdata != r_data ||
					curr_gdata != g_data ||
					curr_bdata != b_data)
				begin		
					csx_ini <= 1'b0;
					ini_mstep <= 8'd1;
				end	
			end
		8'd1:
			begin
				case (ini_sstep)
				8'd0:
					begin
						hcnt <= 12'd0;
						vcnt <= 12'd0;
						pclk <= 1'b1;
						if (dis_mode == 1'b1)
						begin							
							delay <= pic_ini_dly;
							pic_ini_dly <= 3'd0;
							ini_sstep <= 8'd4;
						end
						else
						begin
							delay <= DATA_DELAY;
							ini_sstep <= 8'd1;
						end
					end
				8'd1:
					begin
						pclk <= 1'b0;
						ini_sstep <= 8'd2;
					end
				8'd2:
					begin
						pclk <= 1'b1;
						ini_sstep <= 8'd3;
					end
				8'd3:
					begin
						if (delay > 3'd1)
						begin
							delay <= delay - 3'd1;		
							hcnt <= hcnt + 12'd1;						
							ini_sstep <= 8'd1;
						end
						else
						begin
							delay <= DATA_DELAY;
							ini_sstep <= 8'd0;
							ini_mstep <= 8'd2;
						end
					end
				8'd4:
					begin
						pclk <= 1'b0;
						ini_sstep <= 8'd5;
					end
				8'd5:
					begin
						pclk <= 1'b1;		
						ini_sstep <= 8'd6;
					end
				8'd6:
					begin
						if (delay > 3'd0)
						begin
							delay <= delay - 3'd1;							
							ini_sstep <= 8'd4;
						end
						else
						begin
							ini_sstep <= 8'd0;
							ini_mstep <= 8'd2;
						end
					end				
				default:
					begin
						pclk <= 1'b1;
						ini_sstep <= 8'd0;
						ini_mstep <= 8'd0;
					end
				endcase
			end
		8'd2:
			begin
				case (ini_sstep)
				8'd0:
					begin
						wrx_ini <= 1'b0;
						ini_sstep <= 8'd1;
					end
				8'd1:
					begin
						data_ini <= {{rgb_data[47:40], rgb_data[47:40], rgb_data[47:40]}, {rgb_data[23:16], rgb_data[23:16], rgb_data[23:16]}};
						ini_sstep <= 8'd2;
					end
				8'd2:
					begin
						wrx_ini <= 1'b1;
						ini_sstep <= 8'd3;
					end
				8'd3:
					begin
						wrx_ini <= 1'b0;
						ini_sstep <= 8'd4;
					end
				8'd4:
					begin
						data_ini <= {{rgb_data[39:32], rgb_data[39:32], rgb_data[39:32]}, {rgb_data[15:8], rgb_data[15:8], rgb_data[15:8]}};
						ini_sstep <= 8'd5;
					end
				8'd5:
					begin
						wrx_ini <= 1'b1;
						ini_sstep <= 8'd6;
					end
				8'd6:
					begin
						wrx_ini <= 1'b0;
						ini_sstep <= 8'd7;
					end
				8'd7:
					begin
						data_ini <= {{rgb_data[31:24], rgb_data[31:24], rgb_data[31:24]}, {rgb_data[7:0], rgb_data[7:0], rgb_data[7:0]}};
						ini_sstep <= 8'd8;
					end
				8'd8:
					begin	
						wrx_ini <= 1'b1;		
						ini_sstep <= 8'd0;
						ini_mstep <= 8'd3;
					end
				default:
					begin
						ini_sstep <= 8'd0;
						ini_mstep <= 8'd0;
					end
				endcase
			end
		8'd3:
			begin
				case (ini_sstep)
				8'd0:
					begin
						if (hcnt >= (hsum - 12'd1))
						begin
							hcnt <= 12'd0;
							vcnt <= vcnt + 12'd1;								
						end
						else
						begin
							hcnt <= hcnt + 12'd1;	
						end
						ini_sstep <= 8'd1;
					end
				8'd1:
					begin
						if (vcnt >= (vsum))
						begin
							if (delay > 3'd0)
							begin
								delay <= delay - 3'd1;
								ini_sstep <= 8'd2;
								vcnt <= vsum;
								hcnt <= 12'd0;
							end
							else
							begin
								ini_sstep <= 8'd0;
								ini_mstep <= 8'd4;
								vcnt <= 12'd0;
								hcnt <= 12'd0;
							end
						end
						else
						begin
							ini_sstep <= 8'd2;
						end		
					end
				8'd2:
					begin
						pclk <= 1'b0;
						ini_sstep <= 8'd3;
					end
				8'd3:
					begin
						pclk <= 1'b1;		
						ini_sstep <= 8'd4;
					end	
				8'd4:
					begin	
						ini_sstep <= 8'd0;
						ini_mstep <= 8'd2;
					end
				default:
					begin
						ini_sstep <= 8'd0;
						ini_mstep <= 8'd0;
					end
				endcase
			end				
		8'd4:
			begin
				csx_ini <= 1'b1;
				ini_sstep <= 8'd0;
				ini_mstep <= 8'd0;
			end
		default:
			begin
				ini_sstep <= 8'd0;
				ini_mstep <= 8'd0;
			end
		endcase
	end
	else
	begin
		data_ini	<=	{24'h000000, 24'h000000};
		csx_ini <= 1'b1;
		dcx_ini <= 1'b1;
		rdx_ini <= 1'b1;
		wrx_ini <= 1'b1;				
		ini_mstep <= 8'd0;
		ini_sstep <= 8'd0;
		clc_next <= 1'b0;
		data_dir <= 1'b0;
		
		pclk <= 1'b1;
		vcnt <= 12'd0;
		hcnt <= 12'd0;
	end
end

// ----------------------------------------------------------------------------
// Module instantiation
// ----------------------------------------------------------------------------
info_gen #(.FPGA_version(FPGA_version)) u_info_gen(
	.clk				(pclk),
	 
	.vcnt				({1'b0, vcnt}),
	.hcnt				({1'b0, hcnt}),
	
	.show_en			(info_show_en),
	.info_y_axis   (info_y_axis),
	
	.dis_num			(dis_num),
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
	.clk				(pclk),
	.rst_n			(rst_n),

	.vsum				(vsum),
	.hsum				(hsum),
	
	.vcnt				(vcnt),
	.hcnt				(hcnt),
	
	.pat_num			(dis_num),
	.pat_rval		(r_data),
	.pat_gval		(g_data),
	.pat_bval		(b_data),
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