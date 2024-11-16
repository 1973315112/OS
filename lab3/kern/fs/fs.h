#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512							// 扇区大小
#define PAGE_NSECT          (PGSIZE / SECTSIZE)			// 一个物理页占用的扇区数量


#define SWAP_DEV_NO         1

#endif /* !__KERN_FS_FS_H__ */

