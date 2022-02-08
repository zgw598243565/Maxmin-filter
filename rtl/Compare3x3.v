module Compare3x3 #(
    parameter LINE_NUM = 3,
    parameter PIXEL_WIDTH = 14,
    parameter KX_WIDTH =3,
    parameter IMAGE_WIDTH = 128
)(clk,arstn,data_in,din_valid,data_out,dout_valid,mode);

function integer clogb2(input integer bit_depth);
    begin
        for(clogb2 = 0; bit_depth >0;clogb2 = clogb2 +1)
            bit_depth = bit_depth >> 1;
    end
endfunction

localparam CNT_WIDTH = clogb2(IMAGE_WIDTH-1);
localparam DATA_WIDTH = PIXEL_WIDTH*LINE_NUM;

input clk;
input arstn;
input [DATA_WIDTH-1:0]data_in;
input din_valid;
input mode;
output [PIXEL_WIDTH-1:0]data_out;
output dout_valid;

reg [PIXEL_WIDTH-1:0]k00_reg;
reg [PIXEL_WIDTH-1:0]k01_reg;
reg [PIXEL_WIDTH-1:0]k02_reg;
reg [PIXEL_WIDTH-1:0]k10_reg;
reg [PIXEL_WIDTH-1:0]k11_reg;
reg [PIXEL_WIDTH-1:0]k12_reg;
reg [PIXEL_WIDTH-1:0]k20_reg;
reg [PIXEL_WIDTH-1:0]k21_reg;
reg [PIXEL_WIDTH-1:0]k22_reg;
reg [CNT_WIDTH:0]cnt_reg;
reg [CNT_WIDTH:0]cnt;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                k00_reg <= 0;
                k01_reg <= 0;
                k02_reg <= 0;
            end
        else
            begin
                if(din_valid)
                    begin
                        k00_reg <= data_in[PIXEL_WIDTH-1:0];
                        k01_reg <= data_in[2*PIXEL_WIDTH-1:PIXEL_WIDTH];
                        k02_reg <= data_in[3*PIXEL_WIDTH-1:2*PIXEL_WIDTH];
                    end
            end
    end

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                k10_reg <= 0;
                k11_reg <= 0;
                k12_reg <= 0;
            end
       else
            begin
                k10_reg <= k00_reg;
                k11_reg <= k01_reg;
                k12_reg <= k02_reg;
            end
    end

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                k20_reg <= 0;
                k21_reg <= 0;
                k22_reg <= 0;
            end
         else
            begin
                k20_reg <= k10_reg;
                k21_reg <= k11_reg;
                k22_reg <= k12_reg;
            end
    end
    
 /* The first compare pipe */
reg [PIXEL_WIDTH-1:0]comp_delay_00;
reg [PIXEL_WIDTH-1:0]comp_delay_01;
reg [PIXEL_WIDTH-1:0]comp_delay_02;
reg [PIXEL_WIDTH-1:0]comp_delay_03;
reg [PIXEL_WIDTH-1:0]comp_delay_04;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                comp_delay_00 <= 0;
                comp_delay_01 <= 0;
                comp_delay_02 <= 0;
                comp_delay_03 <= 0;
                comp_delay_04 <= 0;
            end
        else
            begin
               if(mode == 1'b1)
                    begin
                        if(k00_reg > k01_reg)
                            comp_delay_00 <= k00_reg;
                        else
                            comp_delay_00 <= k01_reg;
                        if(k02_reg > k10_reg)
                            comp_delay_01 <= k02_reg;
                        else
                            comp_delay_01 <= k10_reg;
                        if(k11_reg > k12_reg)
                            comp_delay_02 <= k11_reg;
                        else
                            comp_delay_02 <= k12_reg;
                        if(k20_reg > k21_reg)
                            comp_delay_03 <= k20_reg;
                        else
                            comp_delay_03 <= k21_reg;
                        comp_delay_04 <= k22_reg;    
                    end
               else
                    begin
                        if(k00_reg > k01_reg)
                             comp_delay_00 <= k01_reg;
                        else
                            comp_delay_00 <= k00_reg;
                        if(k02_reg > k10_reg)
                            comp_delay_01 <= k10_reg;
                        else
                            comp_delay_01 <= k02_reg;
                        if(k11_reg > k12_reg)
                            comp_delay_02 <= k12_reg;
                        else
                            comp_delay_02 <= k11_reg;
                        if(k20_reg > k21_reg)
                            comp_delay_03 <= k21_reg;
                        else
                            comp_delay_03 <= k20_reg;
                        comp_delay_04 <= k22_reg;                    
                    end
            end
    end
    
/* The second compare pipe */
reg [PIXEL_WIDTH-1:0]comp_delay_10;
reg [PIXEL_WIDTH-1:0]comp_delay_11;
reg [PIXEL_WIDTH-1:0]comp_delay_12;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                comp_delay_10 <= 0;
                comp_delay_11 <= 0;
                comp_delay_12 <= 0;
            end
        else
            begin
                if(mode == 1'b1)
                    begin
                        if(comp_delay_00 > comp_delay_01)
                            comp_delay_10 <= comp_delay_00;
                        else
                            comp_delay_10 <= comp_delay_01;
                        
                        if(comp_delay_02 > comp_delay_03)
                            comp_delay_11 <= comp_delay_02;
                        else
                            comp_delay_11 <= comp_delay_03;
                        comp_delay_12 <= comp_delay_04;
                    end
                else
                    begin
                         if(comp_delay_00 > comp_delay_01)
                            comp_delay_10 <= comp_delay_01;
                         else
                            comp_delay_10 <= comp_delay_00;
                    
                         if(comp_delay_02 > comp_delay_03)
                            comp_delay_11 <= comp_delay_03;
                         else
                            comp_delay_11 <= comp_delay_02;
                         comp_delay_12 <= comp_delay_04;                   
                    end
            end
    end

/* The Third compare pipe */
reg [PIXEL_WIDTH-1:0]comp_delay_20;
reg [PIXEL_WIDTH-1:0]comp_delay_21;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                comp_delay_20 <= 0;
                comp_delay_21 <= 0;
            end
        else
            begin
                if(mode == 1'b1)
                    begin
                        if(comp_delay_10 > comp_delay_11)
                           comp_delay_20 <= comp_delay_10;
                        else
                            comp_delay_20 <= comp_delay_11;
                        comp_delay_21 <= comp_delay_12;
                    end
                else
                    begin
                        if(comp_delay_10 > comp_delay_11)
                            comp_delay_20 <= comp_delay_11;
                        else
                            comp_delay_20 <= comp_delay_10;
                        comp_delay_21 <= comp_delay_12;
                    end
            end
    end

/* The Fourth compare pipe */
reg [PIXEL_WIDTH-1:0]comp_delay_30;            
always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            comp_delay_30 <= 0;
        else
            begin
                if(mode == 1'b1)
                    begin
                        if(comp_delay_20 > comp_delay_21)
                            comp_delay_30 <= comp_delay_20;
                        else
                            comp_delay_30 <= comp_delay_21;
                    end
                else
                    begin
                        if(comp_delay_20 > comp_delay_21)
                            comp_delay_30 <= comp_delay_21;
                        else
                            comp_delay_30 <= comp_delay_20;
                    end
            end
    end

assign data_out = comp_delay_30;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            cnt_reg <= 0;
        else
            cnt_reg <= cnt;
    end

always@(*)
    begin
        if(din_valid)
            begin 
                if(cnt_reg == IMAGE_WIDTH - 1)
                    cnt = 0;
                else
                    cnt = cnt_reg + 1'b1;  
            end
        else
            cnt = cnt_reg;
    end   

/* dout_valid pipe*/
reg tvalid;
reg tvalid_delay_0;
reg tvalid_delay_1;
reg tvalid_delay_2;
reg tvalid_delay_3;
always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
           tvalid <= 0;
        else 
            begin
                if(cnt == KX_WIDTH)
                    tvalid <= 1'b1;
                else if(cnt_reg == IMAGE_WIDTH - 1)
                    tvalid <= 1'b0;
                else
                    tvalid <= tvalid;
            end  
    end

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                tvalid_delay_0 <= 0;
                tvalid_delay_1 <= 0;
                tvalid_delay_2 <= 0;
                tvalid_delay_3 <= 0;
            end
        else
            begin
                tvalid_delay_0 <= tvalid;
                tvalid_delay_1 <= tvalid_delay_0;
                tvalid_delay_2 <= tvalid_delay_1;
                tvalid_delay_3 <= tvalid_delay_2;
            end
    end
assign dout_valid = tvalid_delay_3;











endmodule















