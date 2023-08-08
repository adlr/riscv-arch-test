// Copyright (c) 2023. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
// This assembly file tests the vwsll.vi instruction.

// Define special purpose registers before including test_macros_vector.h
#define DATA_BASE x3
#define SIG_BASE x4
#define VLENB_CACHE x5
#define HELPER_GPR x6

#include "test_macros_vector.h"

RVTEST_ISA("RV32IV_Zicsr_Zvkb,RV64IV_Zicsr_Zvkb")

.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT

RVTEST_CODE_BEGIN

#ifdef TEST_CASE_1

RVTEST_CASE(0,"//check ISA:=regex(.*I.*V.*Zicsr.*Zvkb);def TEST_CASE_1=True;",vwsll.vx)

RVTEST_V_ENABLE()
RVTEST_VALBASEUPD(DATA_BASE, dataset_tc1)
RVTEST_SIGBASE(SIG_BASE, signature_tc1)

// VWSLL.VX has the following inputs and outputs:
// - input VS1: Shift amount
// - input VS2: Data
// - input VM: Mask encoding (<nothing> or v0.t)
// - output VD: Shifted data

#define VINST vwsll.vx

inst_1x8:
// This test will define v0, which will later be used as mask register
TEST_CASE_VVR_W(1, 8, 16, VINST, v0, v0, 0*8, 5)

inst_2x8:
TEST_CASE_VVR(2, 8, 16, VINST, v1, v2, 0*8, 7)

inst_3x8:
TEST_CASE_VVR(3, 8, 16, VINST, v4, v3, 0*8, 9)

inst_4x8:
TEST_CASE_VVR(4, 8, 16, VINST, v5, v6, 0*8, 11)

inst_8x8:
TEST_CASE_VVR_M(8, 8, 16, VINST, v8, v7, 0*8, 13)

inst_16x8:
TEST_CASE_VVR(16, 8, 16, VINST, v9, v10, 0*8, 15)

inst_31x8:
TEST_CASE_VVR(31, 8, 16, VINST, v12, v11, 0*8, 17)


inst_1x16:
TEST_CASE_VVR_M(1, 16, 32, VINST, v13, v14, 0*8, 19)

inst_2x16:
TEST_CASE_VVR(2, 16, 32, VINST, v16, v15, 0*8, 21)

inst_4x16:
TEST_CASE_VVR(4, 16, 32, VINST, v17, v18, 0*8, 23)

inst_8x16:
TEST_CASE_VVR(8, 16, 32, VINST, v20, v19, 0*8, 25)

inst_16x16:
TEST_CASE_VVR_M(16, 16, 32, VINST, v21, v22, 0*8, 27)

inst_31x16:
TEST_CASE_VVR(31, 16, 32, VINST, v24, v23, 0*8, 29)


inst_1x32:
TEST_CASE_VVR(1, 32, 64, VINST, v25, v26, 0*8, 31)

inst_2x32:
TEST_CASE_VVR(2, 32, 64, VINST, v28, v27, 0*8, 0)

inst_4x32:
TEST_CASE_VVR(4, 32, 64, VINST, v29, v30, 0*8, 2)

inst_8x32:
TEST_CASE_VVR_M(8, 32, 64, VINST, v1, v31, 0*8, 4)

inst_16x32:
TEST_CASE_VVR(16, 32, 64, VINST, v31, v31, 0*8, 6)

#endif // TEST_CASE_1

RVTEST_CODE_END

RVMODEL_HALT

RVTEST_DATA_BEGIN
.word 0xbabecafe // trapreg_sv
.word 0xabecafeb // tramptbl_sv
.word 0xbecafeba // mtvec_save
.word 0xecafebab // mscratch_save

    .p2align 6
dataset_tc1:
TEST_CASE_BLOCK_256B_0
RVTEST_DATA_END

RVMODEL_DATA_BEGIN
rvtest_sig_begin:
sig_begin_canary:
CANARY;

signature_tc1:
    //sig[0*8..127*8]
    .fill 128, 8, 0xdeadbeefdeadbeef

#ifdef rvtest_mtrap_routine

tsig_begin_canary:
CANARY;
tsig_begin_canary:
CANARY;
mtrap_sigptr:
    .fill 64*(XLEN/32),4,0xdeadbeef
tsig_end_canary:
CANARY;
tsig_end_canary:
CANARY;

#endif // rvtest_mtrap_routine

#ifdef rvtest_gpr_save

gpr_save:
    .fill 32*XLEN/32,4,0xdeadbeef

#endif // rvtest_gpr_save

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
