// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
// This assembly file tests the ssp CSR.
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

	/* Access ssp from M-mode */
	li t0, 1
    csrw ssp, t0
	
	/* check this is read-only zero */
	SET sstatus, 24 /* UBCFIE */, t0, t1
    csrr t0, sstatus
    PUSH_RESULT t0
    
	SET menvcfgh, (60 - 32) /* CFIE */, t0, t1
	SET sstatus, 24 /* UBCFIE */, t0, t1
    RVTEST_GOTO_LOWER_MODE Umode
	li t0, 1
    csrw ssp, t0
    RVTEST_GOTO_MMODE
    
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
    .fill 25, 4, 0xacc01ade

mtrap_sigptr:
    .fill 4, 4, 0xb01dface

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
