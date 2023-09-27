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
// Create Date   : 2022-11-03 15:20:49
// Last Modified : 2023-09-27 10:05:02
// Description   : Feature Configuration
// ----------------------------------------------------------------------

package DRCP_PKG;


    // ----------------------------------------------------------------------
    //  Feature define
    // ----------------------------------------------------------------------
    // `define DRCP_CLIC
    `define DRCP_EEI
    // `define DRCP_EEI_SREG
    // `define DRCP_EEI_GPIO

    localparam EEI_RS_MAX   = 32;
    localparam EEI_RD_MAX   = 32;
    localparam FGPIO_NUM    = 32;


    // ----------------------------------------------------------------------
    //  memory map
    // ----------------------------------------------------------------------
    localparam ITCM_BASE      = 32'h10000;
    localparam ITCM_END       = 32'h1ffff;

    localparam DM_HALT        = 32'h00800;
    localparam DM_EXCEPTION   = DM_HALT + 32'h8;

    localparam L1RAM_BASE     = 32'h0009_0000;
    localparam L1RAM_END      = 32'h0009_ffff;

    localparam L2RAM_BASE     = 32'd0010_0000;
    localparam L2RAM_END      = 32'h0017_ffff;

    localparam IO_RANGE_BASE  = 32'd0080_0000;
    localparam IO_RANGE_END   = 32'h0700_7fff;

    // Do Not change
    localparam ITCM_SIZE      = (ITCM_END-ITCM_BASE+1);
    localparam L1RAM_SIZE     = (L1RAM_END-L1RAM_BASE+1);


    // ----------------------------------------------------------------------
    //  Constant define
    // ----------------------------------------------------------------------

    // CSR address
    localparam CSR_MVENDORID    = 12'hF11;
    localparam CSR_MARCHID      = 12'hF12;
    localparam CSR_MIMPID       = 12'hF13;
    localparam CSR_MHARTID      = 12'hF14;
    localparam CSR_MSTATUS      = 12'h300;
    localparam CSR_MISA         = 12'h301;
    // medeleg/mideleg
    localparam CSR_MIE          = 12'h304;
    localparam CSR_MTVEC        = 12'h305;
    localparam CSR_MSCRATCH     = 12'h340;
    localparam CSR_MEPC         = 12'h341;
    localparam CSR_MCAUSE       = 12'h342;
    localparam CSR_MTVAL        = 12'h343;
    localparam CSR_MIP          = 12'h344;
    localparam CSR_MCYCLE       = 12'hb00;
    localparam CSR_MCYCLEH      = 12'hb80;
    localparam CSR_MINSTRET     = 12'hb02;
    localparam CSR_MINSTRETH    = 12'hb82;
    // CLIC CSR
    `ifdef DRCP_CLIC
        localparam CSR_MTVT         = 12'h307;
        localparam CSR_XNXTI        = 12'h345;
        localparam CSR_MINTSTATUS   = 12'h346;
        localparam CSR_MINTTHRESH   = 12'h347;
    `endif
    // debug mode CSR
    localparam CSR_DCSR         = 12'h7b0;
    localparam CSR_DPC          = 12'h7b1;
    localparam CSR_DSCRATCH0    = 12'h7b2;
    localparam CSR_DSCRATCH1    = 12'h7b3;
    localparam CSR_DSCRATCH2    = 12'h7b4;


    localparam BIT_MSI          = 3;
    localparam BIT_MTI          = 7;
    localparam BIT_MEI          = 11;


    // ----------------------------------------------------------------------
    //  structure define
    // ----------------------------------------------------------------------

    typedef struct packed {
        logic           req;
        logic [31:0]    addr;
    } inst_req_t;

    typedef struct packed {
        logic           ack;
        logic           error;
        logic [31:0]    data;
    } inst_ack_t;


endpackage

