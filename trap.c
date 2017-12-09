#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    //Added case to handle page faults CS153
    if (tf->trapno == T_PGFLT)
    {
	//Added a check to determine when the stack has run out of space using kalloc() CS153
	if (kalloc() == 0)
	{
	    cprintf("OUT OF STACK SPACE\n");
	    cprintf("STOPPED AT %x\n", (myproc()->tf->esp));
	    cprintf("TOP OF CODE + BUFFER: %x\n", myproc()->sz);
	    cprintf("NUM PAGES %d\n", myproc()->pageNum);
	    myproc()->killed = 1;
	    exit();
	
	}

	//Check to make sure the stack is properly allocated CS153
	if (myproc()->tf->esp < myproc()->stackTop)
	{
	    myproc()->pageNum += 1;
//	    cprintf("TOP: %x\n", myproc()->stackTop);
//	    cprintf("NUM_PAGES: %d\n", myproc()->pageNum);
//	    cprintf("TOP_NEWPAGE: %x\n", myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE));
//	    cprintf("BOTTOM_NEWPAGE: %x\n", myproc()->stackTop - ((myproc()->pageNum)*PGSIZE));
//	    cprintf("SP: %x\n", myproc()->tf->esp);
	   
 // 	    cprintf("TRAP DIFFERENCE: %d\n", myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE) -  myproc()->stackTop - ((myproc()->pageNum)*PGSIZE));

            allocuvm(myproc()->pgdir, myproc()->stackTop - (myproc()->pageNum*PGSIZE), myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE));
	    return;	
	    cprintf("DONE?"); 
	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
