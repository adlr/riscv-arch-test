// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
// This assembly file tests the logic for xBCFIE.
//

#include "model_test.h"
#include "arch_test.h"

RVTEST_ISA("RV32I_Zicfisslp_Zicsr")

# Test code region
.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN

.macro SET csr_num, index, reg, reg2
    li \reg, 1
    slli \reg, \reg, \index
    csrr \reg2, \csr_num
    or \reg2, \reg2, \reg
    csrw \csr_num, \reg2
.endm    

.macro CLEAR csr_num, index, reg, reg2
    li \reg, 1
    slli \reg, \reg, \index
	not \reg, \reg
    csrr \reg2, \csr_num
    and \reg2, \reg2, \reg
    csrw \csr_num, \reg2
.endm    

.macro ASSIGN_BIT csr_num, index, imm, reg, reg2
    .if ( \imm == 1 )
    SET \csr_num, \index, \reg, \reg2
    .else
    CLEAR \csr_num, \index, \reg, \reg2
    .endif
.endm

.macro PUSH_RESULT reg
    sw      \reg, offset(x1)
    .set    offset, (offset + 4)
.endm

.macro GOTO_MODE mode
    .if ( \mode == M )
        RVTEST_GOTO_MMODE
    .else
        RVTEST_GOTO_LOWER_MODE \mode
    .endif
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
    csrw ssp, t0
    
	li t0, 3
    li t1, 4
    ssprr t2
    ssamoswap t0, t2, t1
    PUSH_RESULT t1
    li t0, 5
    sspinc 1
    ssamoswap t0, t2, t0
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

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
