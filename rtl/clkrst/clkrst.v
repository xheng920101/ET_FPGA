//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  clkrst.v
// Module name   :  clkrst
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  clock and system reset generation
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2012-05-29    :  create file
//*****************************************************************************
module clkrst (
    input                 clk_in            ,
	 input                 rst_n             ,
    output                clk_sys           ,
    output                clk_intf          ,
    output                clk_sdram         ,
    output reg            rst_n_sys         ,
    output reg            rst_n_intf
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg                             rst_n_sys_p1                    ;
reg                             rst_n_intf_p1                   ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
pll u_pll(
    .inclk0                     ( clk_in                        ),
    .c0                         ( clk_sys                       ),
    .c1                         ( clk_intf                      ),
    .c2                         ( clk_sdram                     )
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
always @(posedge clk_sys or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        rst_n_sys_p1 <= 1'b0;
        rst_n_sys    <= 1'b0;
    end
    else
    begin
        rst_n_sys_p1 <= 1'b1;
        rst_n_sys    <= rst_n_sys_p1;
    end
end

always @(posedge clk_intf or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        rst_n_intf_p1 <= 1'b0;
        rst_n_intf    <= 1'b0;
    end
    else
    begin
        rst_n_intf_p1 <= 1'b1;
        rst_n_intf    <= rst_n_intf_p1;
    end
end

endmodule