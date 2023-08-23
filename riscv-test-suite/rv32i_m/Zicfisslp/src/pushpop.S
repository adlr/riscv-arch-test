// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
// This assembly file tests the logic for xBCFIE.
//

#include "model_test.h"
#include "arch_test.h"

RVTEST_ISA("RV32I_Zicsr") #_Zicfisslp

# Test code region
.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN

#define CSR_SSP 0x050

#define REG_T0 5
#define REG_T1 6
#define REG_T2 7

#define SSLOAD_X1   .word 0b10000001110000000100000011110011
#define SSLOAD_X5   .word 0b10000001110000000100001011110011
#define SSLOAD_T0   SSLOAD_X5
#define SSPOPCHK_X1 .word 0b10000001110000001100000001110011
#define SSPOPCHK_X5 .word 0b10000001110000101100000001110011
#define SSPOPCHK_T0 SSPOPCHK_X5
#define SSPINC(imm) .word (0b10000001110100000100000001110011 | ((imm & 0x1f) << 15))
#define SSPUSH_X1   .word 0b10000010000100000100000001110011
#define SSPUSH_X5   .word 0b10000010010100000100000001110011
#define SSPUSH_T0   SSPUSH_X5
#define SSAMOSWAP(rd, rs1, rs2) \
  .word (0b10000010000000000100000001110011 | \
         (rs2 << 20) | (rs1 << 15 ) | (rd << 7) \
        )

.macro PUSH_RESULT reg
    sw      \reg, offset(x1)
    .set    offset, (offset + 4)
.endm

#ifdef TEST_CASE_1
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def rvtest_strap_routine=True; def TEST_CASE_1=True",ecall)

    # ---------------------------------------------------------------------------------------------
    LA(     x1,test_A_res)
    .set offset, 0
    csrwi CSR_SATP, 0
    RVTEST_GOTO_MMODE

    
    /* Enable CFIE */
    SET menvcfgh, (60 - 32) /* CFIE */, t0, t1

    /* Init SSP */
    LA(     t0,ssp_top)
    csrw CSR_SSP, t0
    
    /* Go to user mode and ensure that ops are no ops */
    RVTEST_GOTO_LOWER_MODE Umode
    li t0, 1
	SSPUSH_X5
	SSLOAD_X5
    PUSH_RESULT t0
	SSPINC(1)
    RVTEST_GOTO_MMODE
    csrr t0, CSR_SSP
    PUSH_RESULT t0
    RVTEST_GOTO_LOWER_MODE Umode
	li t0, 17
	SSPOPCHK_X5

    RVTEST_GOTO_MMODE
	/* Test in M Mode to ensure these ops perform as they should */
    li t0, 18
	SSPUSH_X5
	SSLOAD_X5
    PUSH_RESULT t0
	SSPINC(1)
	SSLOAD_X5
    PUSH_RESULT t0
    csrr t0, CSR_SSP
    addi t0, t0, (XLEN / -8)
    csrw CSR_SSP, t0
    li t0, 18
    SSPOPCHK_X5
	li t0, 19
    PUSH_RESULT t0
    SSPOPCHK_X5  /* Should fault */
	li t0, 0xdeaddead
    PUSH_RESULT t0

    RVMODEL_IO_WRITE_STR(x30, "# Test part A - test minstret\n");

    RVMODEL_IO_WRITE_STR(x30, "# Test End\n")

#endif

 # ---------------------------------------------------------------------------------------------
    # HALT

RVTEST_CODE_END
RVMODEL_HALT

RVTEST_DATA_BEGIN
# Input data section.
    .data
    .align 4
RVTEST_DATA_END

# Output data section.
RVMODEL_DATA_BEGIN
rvtest_sig_begin:
sig_begin_canary:
CANARY;
	
test_A_res:
    .fill 12, 4, 0xacc01ade

mtrap_sigptr:
    .fill 4, 4, 0xb01dface

ssp_area:
    .fill 10, 4, 0xcafe1123
ssp_top:
    .fill 1, 4, 0xcafe1124

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
