// ----------------------------------------------------------------------
// Copyright 2023 TimingWalker
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------
// Create Date   : 2022-11-01 11:10:35
// Last Modified : 2023-09-27 10:05:13
// Description   : Top module of the DRCP core        
// ----------------------------------------------------------------------

module DRCP_TOP(
     input logic                            clk_i
    ,input logic                            rst_ni
    ,input logic [31:0]                     bootaddr_i
    ,input logic [31:0]                     hart_id_i
    // interupt 
    ,input logic                            irq_mei_i 
    ,input logic                            irq_mti_i 
    ,input logic                            irq_msi_i 
    // debug halt request
    ,input  logic                           dm_req_i
    // LSU
    ,output logic                           lsu_req_o
    ,output logic                           lsu_we_o
    ,output logic [31:0]                    lsu_addr_o
    ,output logic [31:0]                    lsu_wdata_o
    ,output logic [3:0]                     lsu_amo_o
    ,output logic [3:0]                     lsu_strb_o
    ,input  logic                           lsu_valid_i
    ,input  logic                           lsu_error_i
    ,input  logic [31:0]                    lsu_rdata_i

`ifdef DRCP_EEI_GPIO
    ,output logic [DRCP_PKG::FGPIO_NUM-1:0] gpio_dir
    ,input  logic [DRCP_PKG::FGPIO_NUM-1:0] gpio_in_val
    ,output logic [DRCP_PKG::FGPIO_NUM-1:0] gpio_out_val
`endif

);


    logic               clk_neg;
    logic               rst_n;
    logic [31:0]        lsu_rdata, l1_tcdm_rdata;
    logic               l1_ram_valid;
    logic               lsu_error;
    logic [3:0]         lsu_strb;
    logic [3:0]         lsu_amo;
    logic [31:0]        inst_addr;
    logic               inst_error;
    logic               iram_req;
    logic [31:0]        itcm_addr;
    logic [31:0]        itcm_rdata;
    logic               lsu_req;
    logic               lsu_we;
    logic [31:0]        lsu_addr;
    logic [31:0]        lsu_wdata;
    logic               lsu_ack;
    logic               is_l1_ram, is_l2_ram, is_io_region;


    // ----------------------------------------------------------------------
    //  clock and reset generator 
    // ----------------------------------------------------------------------
    rstgen u_rstgen
    (
        .clk_i       ( clk_i  ) ,
        .rst_ni      ( rst_ni ) ,
        .test_mode_i ( 1'b0   ) ,
        .rst_no      ( rst_n  ) ,
        .init_no     (        )
     );

    std_wrap_ckinv u_clk_inv 
    ( 
        .in_i ( clk_i   ) ,
        .zn_o ( clk_neg ) 
    );



    // ----------------------------------------------------------------------
    //  CUST
    // ----------------------------------------------------------------------

    `ifdef DRCP_EEI
        logic               eei_req;
        logic               eei_ext;
        logic [2:0]         eei_funct3;
        logic [6:0]         eei_funct7;
        logic [4:0]         eei_batch_start;
        logic [4:0]         eei_batch_len;
        logic [31:0]        eei_rs_val[DRCP_PKG::EEI_RS_MAX-1:0];
        logic               eei_ack;
        logic [1:0]         eei_rd_op;
        logic [4:0]         eei_rd_len;
        logic               eei_error;
        logic [31:0]        eei_rd_val[DRCP_PKG::EEI_RD_MAX-1:0];

        CUST U_CUST (
             .clk_i           ( clk_i           )
            ,.clk_neg_i       ( clk_neg         ) 
            ,.rst_ni          ( rst_ni          )

            ,.eei_req         ( eei_req         )
            ,.eei_ext         ( eei_ext         )
            ,.eei_funct3      ( eei_funct3      )
            ,.eei_funct7      ( eei_funct7      )
            ,.eei_batch_start ( eei_batch_start )
            ,.eei_batch_len   ( eei_batch_len   )
            ,.eei_rd_len      ( eei_rd_len      )
            ,.eei_rs_val      ( eei_rs_val      )
            ,.eei_ack         ( eei_ack         )
            ,.eei_rd_op       ( eei_rd_op       )
            ,.eei_error       ( eei_error       )
            ,.eei_rd_val      ( eei_rd_val      )

        `ifdef DRCP_EEI_GPIO
            ,.gpio_dir        ( gpio_dir        )
            ,.gpio_in_val     ( gpio_in_val     )
            ,.gpio_out_val    ( gpio_out_val    )
        `endif

        );

    `endif


    `ifdef DRCP_CLIC
        logic          clic_irq_req;
        logic          clic_irq_shv;
        logic [4:0]    clic_irq_id;
        logic [7:0]    clic_irq_level;
        logic          clic_irq_ack;
        logic [7:0]    clic_irq_intthresh;
        logic          clic_mnxti_clr;
        logic [4:0]    clic_mnxti_id;
    `endif

    // ----------------------------------------------------------------------
    //  DRCP core
    // ----------------------------------------------------------------------
    DRCP U_DRCP (
         .clk_i              ( clk_i           ) 
        ,.clk_neg_i          ( clk_neg         ) 
        ,.rst_ni             ( rst_n           ) 
        ,.bootaddr_i         ( bootaddr_i      ) 
        ,.hart_id_i          ( hart_id_i       ) 
        ,.inst_req_o         ( iram_req        ) 
        ,.inst_addr_o        ( inst_addr       ) 
        ,.inst_error_i       ( inst_error      ) 
        ,.inst_ack_i         ( 1'b1            ) 
        ,.inst_data_i        ( itcm_rdata      ) 
        ,.irq_mei            ( irq_mei_i       ) 
        ,.irq_mti            ( irq_mti_i       ) 
        ,.irq_msi            ( irq_msi_i       ) 
        ,.dm_req_i           ( dm_req_i        ) 
        ,.lsu_req_o          ( lsu_req         ) 
        ,.lsu_we_o           ( lsu_we          ) 
        ,.lsu_addr_o         ( lsu_addr        ) 
        ,.lsu_wdata_o        ( lsu_wdata       ) 
        ,.lsu_strb_o         ( lsu_strb        ) 
        ,.lsu_amo_o          ( lsu_amo         ) 
        ,.lsu_ack_i          ( lsu_ack         ) 
        ,.lsu_error_i        ( lsu_error       ) 
        ,.lsu_rdata_i        ( lsu_rdata       ) 

    `ifdef DRCP_EEI
        ,.eei_req            ( eei_req         ) 
        ,.eei_ext            ( eei_ext         ) 
        ,.eei_funct3         ( eei_funct3      ) 
        ,.eei_funct7         ( eei_funct7      ) 
        ,.eei_batch_start    ( eei_batch_start ) 
        ,.eei_batch_len      ( eei_batch_len   ) 
        ,.eei_rs_val         ( eei_rs_val      ) 
        ,.eei_ack            ( eei_ack         ) 
        ,.eei_rd_op          ( eei_rd_op       ) 
        ,.eei_rd_len         ( eei_rd_len      ) 
        ,.eei_error          ( eei_error       ) 
        ,.eei_rd_val         ( eei_rd_val      ) 
    `endif

    `ifdef DRCP_CLIC
        // CLIC interface
       ,.clic_irq_req        (clic_irq_req       ) 
       ,.clic_irq_shv        (clic_irq_shv       ) 
       ,.clic_irq_id         (clic_irq_id        ) 
       ,.clic_irq_level      (clic_irq_level     ) 
       ,.clic_irq_ack        (clic_irq_ack       ) 
       ,.clic_irq_intthresh  (clic_irq_intthresh )
    `endif

    );



    // ----------------------------------------------------------------------
    //  ITCM
    // ----------------------------------------------------------------------

    assign itcm_addr  = inst_addr - DRCP_PKG::ITCM_BASE;

    assign inst_error = ( (inst_addr>=DRCP_PKG::ITCM_BASE) && (inst_addr<=DRCP_PKG::ITCM_END) ) ? 1'b0 : 1'b1;

    //16K*32bit=64K
    TCM_WRAP 
    #(
        .DATA_WIDTH ( 32                            ) ,
        .DEPTH      ( DRCP_PKG::ITCM_SIZE / (32/8)  )   // in DATA_WIDTH
    )
    u_itcm
    (
        .clk_i   ( clk_i                                        ) ,
        .en_i    ( iram_req & ~inst_error                       ) ,
        .addr_i  ( itcm_addr[ $clog2(DRCP_PKG::ITCM_SIZE)-1:0]  ) , // in byte
        .wdata_i ( 32'd0                                        ) , 
        .we_i    ( 1'b0                                         ) ,
        .be_i    ( 4'd0                                         ) ,
        .rdata_o ( itcm_rdata                                   ) 
    );


    // ----------------------------------------------------------------------
    //  LSU demux
    // ----------------------------------------------------------------------

    assign lsu_we_o    = lsu_we;
    assign lsu_addr_o  = lsu_addr;
    assign lsu_wdata_o = lsu_wdata;
    assign lsu_amo_o   = lsu_amo;
    assign lsu_strb_o  = lsu_strb;

    assign lsu_req_o   = is_l1_ram | is_l2_ram | is_io_region;

    always_comb begin
        is_l1_ram    = 1'b0;
        is_l2_ram    = 1'b0;
        is_io_region = 1'b0;
        if ( lsu_req ) begin
            if      ( (lsu_addr[31:0]>=DRCP_PKG::L1RAM_BASE)   && (lsu_addr[31:0]<DRCP_PKG::L1RAM_END)   ) 
                is_l1_ram = 1'b1;
            else if ( (lsu_addr[31:0]>=DRCP_PKG::L2RAM_BASE)   && (lsu_addr[31:0]<DRCP_PKG::L2RAM_END)   )
                is_l2_ram = 1'b1;
            else if ( (lsu_addr[31:0]>=DRCP_PKG::IO_RANGE_BASE) && (lsu_addr[31:0]<DRCP_PKG::IO_RANGE_END) )
                is_io_region = 1'b1;
        end
    end

    always_comb begin
        // if lsu addr out of range, return with error=1(load access exception)
        lsu_ack   = 1'b0;
        lsu_error = 1'b0;    
        lsu_rdata = 32'd0;
        // return in 1 cycle
        if (is_l1_ram) begin
            lsu_ack   = lsu_req;
            lsu_error = 1'b0;
            lsu_rdata = l1_tcdm_rdata;
        end
        // return in several cycles
        else if (is_l2_ram|is_io_region) begin
            lsu_ack   = lsu_valid_i;
            lsu_error = lsu_error_i;
            lsu_rdata = lsu_rdata_i;
        end
        else if (lsu_req) begin
            lsu_ack   = lsu_req;
            lsu_error = 1'b1;    
            lsu_rdata = 32'd0;
        end
    end


    // -----------------------------------
    //  L1 DRAM
    // -----------------------------------
    //16K*32bit=64K
    TCM_WRAP 
    #(
        .DATA_WIDTH ( 32                             ),
        .DEPTH      ( DRCP_PKG::L1RAM_SIZE / (32/8)  )  // in DATA_WIDTH
    )
    u_dtcm
    (
        .clk_i   ( clk_neg                                      ) , // use negedge clock to make l1 dram access time = 1 cycle
        .en_i    ( is_l1_ram                                    ) ,
        .addr_i  ( lsu_addr[ $clog2(DRCP_PKG::L1RAM_SIZE)-1:0]  ) , // in byte
        .wdata_i ( lsu_wdata                                    ) ,
        .we_i    ( lsu_we                                       ) ,
        .be_i    ( lsu_strb                                     ) ,
        .rdata_o ( l1_tcdm_rdata                                ) 
    );


endmodule

