#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct shm_page {
    uint id;
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
}

int shm_open(int id, char **pointer) {

//you write this
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  char *mem;

  for (int i = 0; i < 64; i++)
  {
      if (shm_table.shm_pages[i].id == id)
      {
	  shm_table.shm_pages[i].refcnt++;
 	  memset((char*)pointer, 0, PGSIZE);
          if (mappages(myproc()->pgdir, (char*)myproc()->sz, PGSIZE, V2P(shm_table.shm_pages[i].frame), PTE_W|PTE_U) < 0)
	  {
	      cprintf("allocuvm out of memory (2)\n");
//              deallocuvm(myproc()->pgdir, myproc()->sz+PGSIZE, myproc()->sz);
//              kfree(mem);
              return 0;
	  }
	  *pointer = (char*)myproc()->sz;
	  myproc()->sz += PGSIZE;

 	  release(&(shm_table.lock));
  	  return 1;
      }
  }



  for (int i = 0; i < 64; i++)
  {
    if (shm_table.shm_pages[i].id == 0)
    {
	  mem = kalloc();
          if(mem == 0)
          {
      	     //cprintf("SP: %x\n", myproc()->tf->esp);
      	     cprintf("allocuvm out of memory\n");
       	     deallocuvm(myproc()->pgdir, myproc()->sz+PGSIZE, 0);
      	     return 0;
          }
          //cprintf("MEM: %x\n", mem);
          memset(mem, 0, PGSIZE);
          if(mappages(myproc()->pgdir, (char*)myproc()->sz, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0)
          {
              cprintf("allocuvm out of memory (2)\n");
              deallocuvm(myproc()->pgdir, myproc()->sz+PGSIZE, myproc()->sz);
              kfree(mem);
              return 0;
          }
	  *pointer = (char*)myproc()->sz;
	  myproc()->sz += PGSIZE;
     
      shm_table.shm_pages[i].refcnt++;
      shm_table.shm_pages[i].id = id;
      shm_table.shm_pages[i].frame = mem;
      release(&(shm_table.lock));
      return 1;
    }
  }


//  allocuvm(myproc()->pgdir, (uint)pointer + PGSIZE, (uint)pointer);

  
  release(&(shm_table.lock));
  
  return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
//you write this too!

  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (int i = 0; i< 64; i++) {
	if (shm_table.shm_pages[i].id == id)
	{
	  shm_table.shm_pages[i].refcnt -= 1;
	  if (shm_table.shm_pages[i].refcnt == 0)
	  {
	    cprintf("CLEARING ENTRY WITH ID %d\n", id);
	    shm_table.shm_pages[i].id = 0;
	  }
	break;
	}
  }
  release(&(shm_table.lock));



return 0; //added to remove compiler warning -- you should decide what to return
}
