module stx(
    input                 clk               ,
    input                 rst_n             ,
    input                 tx_req            ,
    input       [7:0]     tx_data           ,
    output reg            tx_ack            ,
    output reg            txd
    
);

//*****************************************************************************
// parameters
//*****************************************************************************
parameter       DIVBAUD                     = 16'd234           ;
parameter       BITNUM                      = 4'd10             ;

//fsm
parameter       TXIDLE                      = 2'b00             ;
parameter       TXSTART                     = 2'b01             ;
parameter       TXDATA                      = 2'b10             ;
parameter       TXSTOP                      = 2'b11             ;


//*****************************************************************************
// variable declaration
//*****************************************************************************
reg                             pulse_baud                      ;
reg     [15:0]                  cnt_baud                        ;

reg                             tx_req_lat                      ;
reg     [7:0]                   tx_data_buf                     ;

reg     [1:0]                   ns_ctrl                         ;
reg     [1:0]                   cs_ctrl                         ;

reg     [3:0]                   cnt_tx                          ;


//*****************************************************************************
// continuous assignment
//*****************************************************************************

//*****************************************************************************
// block statement
//*****************************************************************************
//-----------------------------------------------------------------------------
// pulse signal for sampling serial data according to baud rate
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_baud <= 16'd0;
        pulse_baud <= 1'b0;
    end
    else
    begin
        if (cnt_baud == DIVBAUD - 16'd1)
        begin
            cnt_baud <= 16'd0;
            pulse_baud <= 1'b1;
        end
        else
        begin
            cnt_baud <= cnt_baud + 16'd1;
            pulse_baud <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        tx_req_lat <= 1'b0;
    end
    else
    begin
        if (pulse_baud == 1'b1)
        begin
            tx_req_lat <= 1'b0;
        end
        else if (tx_req == 1'b1)
        begin
            tx_req_lat <= 1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        tx_data_buf <= 8'b0;
    end
    else
    begin
        if (tx_req == 1'b1)
        begin
            tx_data_buf <= tx_data;
        end
    end
end

//-----------------------------------------------------------------------------
// transmit FSM
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cs_ctrl <= TXIDLE;
    end
    else
    begin
        if (pulse_baud == 1'b1)
        begin
            cs_ctrl <= ns_ctrl;
        end
    end
end

always @(*)
begin
    case (cs_ctrl)
        TXIDLE:
        begin
            if ((tx_req == 1'b1) || (tx_req_lat == 1'b1))
            begin
                ns_ctrl = TXSTART;
            end
            else
            begin
                ns_ctrl = TXIDLE;
            end
        end
        TXSTART:
        begin
             ns_ctrl = TXDATA;
        end
        TXDATA:
        begin
            if (cnt_tx == 4'd7)
            begin
                ns_ctrl = TXSTOP;
            end
            else
            begin
                ns_ctrl = TXDATA;
            end
        end
        TXSTOP:
        begin
            ns_ctrl = TXIDLE;
        end
    endcase
end

//-----------------------------------------------------------------------------
// counter for bits has been transmitted
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_tx <= 4'b0;
    end
    else
    begin
        if (cs_ctrl == TXDATA)
        begin
            if (pulse_baud == 1'b1)
            begin
                if (cnt_tx == 4'd7)
                begin
                    cnt_tx <= 4'd0;
                end
                else
                begin
                    cnt_tx <= cnt_tx + 4'd1;
                end
            end
        end
    end
end

//-----------------------------------------------------------------------------
// send serial bit
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        txd <= 1'b0;
    end
    else
    begin
        case(cs_ctrl)
            TXIDLE:
            begin
                txd <= 1'b1;
            end
            TXSTART:
            begin
                txd <= 1'b0;
            end
            TXDATA:
            begin
                txd <= tx_data_buf[cnt_tx];
            end
            TXSTOP:
            begin
                txd <= 1'b1;
            end
        endcase
    end
end

//-----------------------------------------------------------------------------
// send acknowledge signal
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        tx_ack <= 1'b0;
    end
    else
    begin
        if ((cs_ctrl == TXSTOP) && (pulse_baud == 1'b1))
        begin
            tx_ack <= 1'b1;
        end
        else
        begin
            tx_ack <= 1'b0;
        end
    end
end

endmodule