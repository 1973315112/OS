#include <default_pmm.h>
#include <defs.h>
#include <error.h>
#include <kmalloc.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

bool shared_read_state(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,bool share);
int privated_write_state(struct mm_struct *mm, uint_t error_code, uintptr_t addr);
