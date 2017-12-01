
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 c6 10 80       	mov    $0x8010c630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 c1 38 10 80       	mov    $0x801038c1,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 f4 86 10 80       	push   $0x801086f4
80100042:	68 40 c6 10 80       	push   $0x8010c640
80100047:	e8 92 4f 00 00       	call   80104fde <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 8c 0d 11 80 3c 	movl   $0x80110d3c,0x80110d8c
80100056:	0d 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 90 0d 11 80 3c 	movl   $0x80110d3c,0x80110d90
80100060:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 74 c6 10 80 	movl   $0x8010c674,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 fb 86 10 80       	push   $0x801086fb
80100090:	50                   	push   %eax
80100091:	e8 eb 4d 00 00       	call   80104e81 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 90 0d 11 80       	mov    0x80110d90,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 90 0d 11 80       	mov    %eax,0x80110d90

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 3c 0d 11 80       	mov    $0x80110d3c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000bd:	90                   	nop
801000be:	c9                   	leave  
801000bf:	c3                   	ret    

801000c0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c0:	55                   	push   %ebp
801000c1:	89 e5                	mov    %esp,%ebp
801000c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c6:	83 ec 0c             	sub    $0xc,%esp
801000c9:	68 40 c6 10 80       	push   $0x8010c640
801000ce:	e8 2d 4f 00 00       	call   80105000 <acquire>
801000d3:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d6:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801000db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000de:	eb 58                	jmp    80100138 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e3:	8b 40 04             	mov    0x4(%eax),%eax
801000e6:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e9:	75 44                	jne    8010012f <bget+0x6f>
801000eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ee:	8b 40 08             	mov    0x8(%eax),%eax
801000f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000f4:	75 39                	jne    8010012f <bget+0x6f>
      b->refcnt++;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fc:	8d 50 01             	lea    0x1(%eax),%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 40 c6 10 80       	push   $0x8010c640
8010010d:	e8 5c 4f 00 00       	call   8010506e <release>
80100112:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	83 c0 0c             	add    $0xc,%eax
8010011b:	83 ec 0c             	sub    $0xc,%esp
8010011e:	50                   	push   %eax
8010011f:	e8 99 4d 00 00       	call   80104ebd <acquiresleep>
80100124:	83 c4 10             	add    $0x10,%esp
      return b;
80100127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012a:	e9 9d 00 00 00       	jmp    801001cc <bget+0x10c>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010012f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100132:	8b 40 54             	mov    0x54(%eax),%eax
80100135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100138:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
8010013f:	75 9f                	jne    801000e0 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 8c 0d 11 80       	mov    0x80110d8c,%eax
80100146:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100149:	eb 6b                	jmp    801001b6 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100151:	85 c0                	test   %eax,%eax
80100153:	75 58                	jne    801001ad <bget+0xed>
80100155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100158:	8b 00                	mov    (%eax),%eax
8010015a:	83 e0 04             	and    $0x4,%eax
8010015d:	85 c0                	test   %eax,%eax
8010015f:	75 4c                	jne    801001ad <bget+0xed>
      b->dev = dev;
80100161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100164:	8b 55 08             	mov    0x8(%ebp),%edx
80100167:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100170:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100186:	83 ec 0c             	sub    $0xc,%esp
80100189:	68 40 c6 10 80       	push   $0x8010c640
8010018e:	e8 db 4e 00 00       	call   8010506e <release>
80100193:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	83 c0 0c             	add    $0xc,%eax
8010019c:	83 ec 0c             	sub    $0xc,%esp
8010019f:	50                   	push   %eax
801001a0:	e8 18 4d 00 00       	call   80104ebd <acquiresleep>
801001a5:	83 c4 10             	add    $0x10,%esp
      return b;
801001a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ab:	eb 1f                	jmp    801001cc <bget+0x10c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b0:	8b 40 50             	mov    0x50(%eax),%eax
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801001bd:	75 8c                	jne    8010014b <bget+0x8b>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001bf:	83 ec 0c             	sub    $0xc,%esp
801001c2:	68 02 87 10 80       	push   $0x80108702
801001c7:	e8 d4 03 00 00       	call   801005a0 <panic>
}
801001cc:	c9                   	leave  
801001cd:	c3                   	ret    

801001ce <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001ce:	55                   	push   %ebp
801001cf:	89 e5                	mov    %esp,%ebp
801001d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d4:	83 ec 08             	sub    $0x8,%esp
801001d7:	ff 75 0c             	pushl  0xc(%ebp)
801001da:	ff 75 08             	pushl  0x8(%ebp)
801001dd:	e8 de fe ff ff       	call   801000c0 <bget>
801001e2:	83 c4 10             	add    $0x10,%esp
801001e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 00                	mov    (%eax),%eax
801001ed:	83 e0 02             	and    $0x2,%eax
801001f0:	85 c0                	test   %eax,%eax
801001f2:	75 0e                	jne    80100202 <bread+0x34>
    iderw(b);
801001f4:	83 ec 0c             	sub    $0xc,%esp
801001f7:	ff 75 f4             	pushl  -0xc(%ebp)
801001fa:	e8 c1 27 00 00       	call   801029c0 <iderw>
801001ff:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100202:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100205:	c9                   	leave  
80100206:	c3                   	ret    

80100207 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100207:	55                   	push   %ebp
80100208:	89 e5                	mov    %esp,%ebp
8010020a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020d:	8b 45 08             	mov    0x8(%ebp),%eax
80100210:	83 c0 0c             	add    $0xc,%eax
80100213:	83 ec 0c             	sub    $0xc,%esp
80100216:	50                   	push   %eax
80100217:	e8 53 4d 00 00       	call   80104f6f <holdingsleep>
8010021c:	83 c4 10             	add    $0x10,%esp
8010021f:	85 c0                	test   %eax,%eax
80100221:	75 0d                	jne    80100230 <bwrite+0x29>
    panic("bwrite");
80100223:	83 ec 0c             	sub    $0xc,%esp
80100226:	68 13 87 10 80       	push   $0x80108713
8010022b:	e8 70 03 00 00       	call   801005a0 <panic>
  b->flags |= B_DIRTY;
80100230:	8b 45 08             	mov    0x8(%ebp),%eax
80100233:	8b 00                	mov    (%eax),%eax
80100235:	83 c8 04             	or     $0x4,%eax
80100238:	89 c2                	mov    %eax,%edx
8010023a:	8b 45 08             	mov    0x8(%ebp),%eax
8010023d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010023f:	83 ec 0c             	sub    $0xc,%esp
80100242:	ff 75 08             	pushl  0x8(%ebp)
80100245:	e8 76 27 00 00       	call   801029c0 <iderw>
8010024a:	83 c4 10             	add    $0x10,%esp
}
8010024d:	90                   	nop
8010024e:	c9                   	leave  
8010024f:	c3                   	ret    

80100250 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100250:	55                   	push   %ebp
80100251:	89 e5                	mov    %esp,%ebp
80100253:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100256:	8b 45 08             	mov    0x8(%ebp),%eax
80100259:	83 c0 0c             	add    $0xc,%eax
8010025c:	83 ec 0c             	sub    $0xc,%esp
8010025f:	50                   	push   %eax
80100260:	e8 0a 4d 00 00       	call   80104f6f <holdingsleep>
80100265:	83 c4 10             	add    $0x10,%esp
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 0d                	jne    80100279 <brelse+0x29>
    panic("brelse");
8010026c:	83 ec 0c             	sub    $0xc,%esp
8010026f:	68 1a 87 10 80       	push   $0x8010871a
80100274:	e8 27 03 00 00       	call   801005a0 <panic>

  releasesleep(&b->lock);
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	83 c0 0c             	add    $0xc,%eax
8010027f:	83 ec 0c             	sub    $0xc,%esp
80100282:	50                   	push   %eax
80100283:	e8 99 4c 00 00       	call   80104f21 <releasesleep>
80100288:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028b:	83 ec 0c             	sub    $0xc,%esp
8010028e:	68 40 c6 10 80       	push   $0x8010c640
80100293:	e8 68 4d 00 00       	call   80105000 <acquire>
80100298:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029b:	8b 45 08             	mov    0x8(%ebp),%eax
8010029e:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a1:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002aa:	8b 45 08             	mov    0x8(%ebp),%eax
801002ad:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b0:	85 c0                	test   %eax,%eax
801002b2:	75 47                	jne    801002fb <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b4:	8b 45 08             	mov    0x8(%ebp),%eax
801002b7:	8b 40 54             	mov    0x54(%eax),%eax
801002ba:	8b 55 08             	mov    0x8(%ebp),%edx
801002bd:	8b 52 50             	mov    0x50(%edx),%edx
801002c0:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c3:	8b 45 08             	mov    0x8(%ebp),%eax
801002c6:	8b 40 50             	mov    0x50(%eax),%eax
801002c9:	8b 55 08             	mov    0x8(%ebp),%edx
801002cc:	8b 52 54             	mov    0x54(%edx),%edx
801002cf:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d2:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002e8:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	a3 90 0d 11 80       	mov    %eax,0x80110d90
  }
  
  release(&bcache.lock);
801002fb:	83 ec 0c             	sub    $0xc,%esp
801002fe:	68 40 c6 10 80       	push   $0x8010c640
80100303:	e8 66 4d 00 00       	call   8010506e <release>
80100308:	83 c4 10             	add    $0x10,%esp
}
8010030b:	90                   	nop
8010030c:	c9                   	leave  
8010030d:	c3                   	ret    

8010030e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030e:	55                   	push   %ebp
8010030f:	89 e5                	mov    %esp,%ebp
80100311:	83 ec 14             	sub    $0x14,%esp
80100314:	8b 45 08             	mov    0x8(%ebp),%eax
80100317:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010031f:	89 c2                	mov    %eax,%edx
80100321:	ec                   	in     (%dx),%al
80100322:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100325:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80100329:	c9                   	leave  
8010032a:	c3                   	ret    

8010032b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032b:	55                   	push   %ebp
8010032c:	89 e5                	mov    %esp,%ebp
8010032e:	83 ec 08             	sub    $0x8,%esp
80100331:	8b 55 08             	mov    0x8(%ebp),%edx
80100334:	8b 45 0c             	mov    0xc(%ebp),%eax
80100337:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010033b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010033e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100342:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100346:	ee                   	out    %al,(%dx)
}
80100347:	90                   	nop
80100348:	c9                   	leave  
80100349:	c3                   	ret    

8010034a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034a:	55                   	push   %ebp
8010034b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010034d:	fa                   	cli    
}
8010034e:	90                   	nop
8010034f:	5d                   	pop    %ebp
80100350:	c3                   	ret    

80100351 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100351:	55                   	push   %ebp
80100352:	89 e5                	mov    %esp,%ebp
80100354:	53                   	push   %ebx
80100355:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100358:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035c:	74 1c                	je     8010037a <printint+0x29>
8010035e:	8b 45 08             	mov    0x8(%ebp),%eax
80100361:	c1 e8 1f             	shr    $0x1f,%eax
80100364:	0f b6 c0             	movzbl %al,%eax
80100367:	89 45 10             	mov    %eax,0x10(%ebp)
8010036a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036e:	74 0a                	je     8010037a <printint+0x29>
    x = -xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	f7 d8                	neg    %eax
80100375:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100378:	eb 06                	jmp    80100380 <printint+0x2f>
  else
    x = xx;
8010037a:	8b 45 08             	mov    0x8(%ebp),%eax
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100387:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010038a:	8d 41 01             	lea    0x1(%ecx),%eax
8010038d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100396:	ba 00 00 00 00       	mov    $0x0,%edx
8010039b:	f7 f3                	div    %ebx
8010039d:	89 d0                	mov    %edx,%eax
8010039f:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
801003a6:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
801003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801003ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b0:	ba 00 00 00 00       	mov    $0x0,%edx
801003b5:	f7 f3                	div    %ebx
801003b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003be:	75 c7                	jne    80100387 <printint+0x36>

  if(sign)
801003c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c4:	74 2a                	je     801003f0 <printint+0x9f>
    buf[i++] = '-';
801003c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003c9:	8d 50 01             	lea    0x1(%eax),%edx
801003cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003cf:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d4:	eb 1a                	jmp    801003f0 <printint+0x9f>
    consputc(buf[i]);
801003d6:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003dc:	01 d0                	add    %edx,%eax
801003de:	0f b6 00             	movzbl (%eax),%eax
801003e1:	0f be c0             	movsbl %al,%eax
801003e4:	83 ec 0c             	sub    $0xc,%esp
801003e7:	50                   	push   %eax
801003e8:	e8 d8 03 00 00       	call   801007c5 <consputc>
801003ed:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003f8:	79 dc                	jns    801003d6 <printint+0x85>
    consputc(buf[i]);
}
801003fa:	90                   	nop
801003fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 d4 b5 10 80       	mov    0x8010b5d4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 a0 b5 10 80       	push   $0x8010b5a0
8010041c:	e8 df 4b 00 00       	call   80105000 <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 21 87 10 80       	push   $0x80108721
80100433:	e8 68 01 00 00       	call   801005a0 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 1a 01 00 00       	jmp    80100564 <cprintf+0x164>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	pushl  -0x1c(%ebp)
80100456:	e8 6a 03 00 00       	call   801007c5 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 fd 00 00 00       	jmp    80100560 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 ff 00 00 00    	je     80100586 <cprintf+0x186>
      break;
    switch(c){
80100487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010048a:	83 f8 70             	cmp    $0x70,%eax
8010048d:	74 47                	je     801004d6 <cprintf+0xd6>
8010048f:	83 f8 70             	cmp    $0x70,%eax
80100492:	7f 13                	jg     801004a7 <cprintf+0xa7>
80100494:	83 f8 25             	cmp    $0x25,%eax
80100497:	0f 84 98 00 00 00    	je     80100535 <cprintf+0x135>
8010049d:	83 f8 64             	cmp    $0x64,%eax
801004a0:	74 14                	je     801004b6 <cprintf+0xb6>
801004a2:	e9 9d 00 00 00       	jmp    80100544 <cprintf+0x144>
801004a7:	83 f8 73             	cmp    $0x73,%eax
801004aa:	74 47                	je     801004f3 <cprintf+0xf3>
801004ac:	83 f8 78             	cmp    $0x78,%eax
801004af:	74 25                	je     801004d6 <cprintf+0xd6>
801004b1:	e9 8e 00 00 00       	jmp    80100544 <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
801004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b9:	8d 50 04             	lea    0x4(%eax),%edx
801004bc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004bf:	8b 00                	mov    (%eax),%eax
801004c1:	83 ec 04             	sub    $0x4,%esp
801004c4:	6a 01                	push   $0x1
801004c6:	6a 0a                	push   $0xa
801004c8:	50                   	push   %eax
801004c9:	e8 83 fe ff ff       	call   80100351 <printint>
801004ce:	83 c4 10             	add    $0x10,%esp
      break;
801004d1:	e9 8a 00 00 00       	jmp    80100560 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004d9:	8d 50 04             	lea    0x4(%eax),%edx
801004dc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004df:	8b 00                	mov    (%eax),%eax
801004e1:	83 ec 04             	sub    $0x4,%esp
801004e4:	6a 00                	push   $0x0
801004e6:	6a 10                	push   $0x10
801004e8:	50                   	push   %eax
801004e9:	e8 63 fe ff ff       	call   80100351 <printint>
801004ee:	83 c4 10             	add    $0x10,%esp
      break;
801004f1:	eb 6d                	jmp    80100560 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004f6:	8d 50 04             	lea    0x4(%eax),%edx
801004f9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004fc:	8b 00                	mov    (%eax),%eax
801004fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100501:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100505:	75 22                	jne    80100529 <cprintf+0x129>
        s = "(null)";
80100507:	c7 45 ec 2a 87 10 80 	movl   $0x8010872a,-0x14(%ebp)
      for(; *s; s++)
8010050e:	eb 19                	jmp    80100529 <cprintf+0x129>
        consputc(*s);
80100510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100513:	0f b6 00             	movzbl (%eax),%eax
80100516:	0f be c0             	movsbl %al,%eax
80100519:	83 ec 0c             	sub    $0xc,%esp
8010051c:	50                   	push   %eax
8010051d:	e8 a3 02 00 00       	call   801007c5 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100525:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100529:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010052c:	0f b6 00             	movzbl (%eax),%eax
8010052f:	84 c0                	test   %al,%al
80100531:	75 dd                	jne    80100510 <cprintf+0x110>
        consputc(*s);
      break;
80100533:	eb 2b                	jmp    80100560 <cprintf+0x160>
    case '%':
      consputc('%');
80100535:	83 ec 0c             	sub    $0xc,%esp
80100538:	6a 25                	push   $0x25
8010053a:	e8 86 02 00 00       	call   801007c5 <consputc>
8010053f:	83 c4 10             	add    $0x10,%esp
      break;
80100542:	eb 1c                	jmp    80100560 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100544:	83 ec 0c             	sub    $0xc,%esp
80100547:	6a 25                	push   $0x25
80100549:	e8 77 02 00 00       	call   801007c5 <consputc>
8010054e:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100551:	83 ec 0c             	sub    $0xc,%esp
80100554:	ff 75 e4             	pushl  -0x1c(%ebp)
80100557:	e8 69 02 00 00       	call   801007c5 <consputc>
8010055c:	83 c4 10             	add    $0x10,%esp
      break;
8010055f:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100560:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100564:	8b 55 08             	mov    0x8(%ebp),%edx
80100567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010056a:	01 d0                	add    %edx,%eax
8010056c:	0f b6 00             	movzbl (%eax),%eax
8010056f:	0f be c0             	movsbl %al,%eax
80100572:	25 ff 00 00 00       	and    $0xff,%eax
80100577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010057a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010057e:	0f 85 c6 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100584:	eb 01                	jmp    80100587 <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100586:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100587:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010058b:	74 10                	je     8010059d <cprintf+0x19d>
    release(&cons.lock);
8010058d:	83 ec 0c             	sub    $0xc,%esp
80100590:	68 a0 b5 10 80       	push   $0x8010b5a0
80100595:	e8 d4 4a 00 00       	call   8010506e <release>
8010059a:	83 c4 10             	add    $0x10,%esp
}
8010059d:	90                   	nop
8010059e:	c9                   	leave  
8010059f:	c3                   	ret    

801005a0 <panic>:

void
panic(char *s)
{
801005a0:	55                   	push   %ebp
801005a1:	89 e5                	mov    %esp,%ebp
801005a3:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005a6:	e8 9f fd ff ff       	call   8010034a <cli>
  cons.locking = 0;
801005ab:	c7 05 d4 b5 10 80 00 	movl   $0x0,0x8010b5d4
801005b2:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005b5:	e8 95 2a 00 00       	call   8010304f <lapicid>
801005ba:	83 ec 08             	sub    $0x8,%esp
801005bd:	50                   	push   %eax
801005be:	68 31 87 10 80       	push   $0x80108731
801005c3:	e8 38 fe ff ff       	call   80100400 <cprintf>
801005c8:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005cb:	8b 45 08             	mov    0x8(%ebp),%eax
801005ce:	83 ec 0c             	sub    $0xc,%esp
801005d1:	50                   	push   %eax
801005d2:	e8 29 fe ff ff       	call   80100400 <cprintf>
801005d7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005da:	83 ec 0c             	sub    $0xc,%esp
801005dd:	68 45 87 10 80       	push   $0x80108745
801005e2:	e8 19 fe ff ff       	call   80100400 <cprintf>
801005e7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ea:	83 ec 08             	sub    $0x8,%esp
801005ed:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f0:	50                   	push   %eax
801005f1:	8d 45 08             	lea    0x8(%ebp),%eax
801005f4:	50                   	push   %eax
801005f5:	e8 c6 4a 00 00       	call   801050c0 <getcallerpcs>
801005fa:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100604:	eb 1c                	jmp    80100622 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100609:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060d:	83 ec 08             	sub    $0x8,%esp
80100610:	50                   	push   %eax
80100611:	68 47 87 10 80       	push   $0x80108747
80100616:	e8 e5 fd ff ff       	call   80100400 <cprintf>
8010061b:	83 c4 10             	add    $0x10,%esp
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
8010061e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100622:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100626:	7e de                	jle    80100606 <panic+0x66>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100628:	c7 05 80 b5 10 80 01 	movl   $0x1,0x8010b580
8010062f:	00 00 00 
  for(;;)
    ;
80100632:	eb fe                	jmp    80100632 <panic+0x92>

80100634 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100634:	55                   	push   %ebp
80100635:	89 e5                	mov    %esp,%ebp
80100637:	83 ec 18             	sub    $0x18,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010063a:	6a 0e                	push   $0xe
8010063c:	68 d4 03 00 00       	push   $0x3d4
80100641:	e8 e5 fc ff ff       	call   8010032b <outb>
80100646:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100649:	68 d5 03 00 00       	push   $0x3d5
8010064e:	e8 bb fc ff ff       	call   8010030e <inb>
80100653:	83 c4 04             	add    $0x4,%esp
80100656:	0f b6 c0             	movzbl %al,%eax
80100659:	c1 e0 08             	shl    $0x8,%eax
8010065c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010065f:	6a 0f                	push   $0xf
80100661:	68 d4 03 00 00       	push   $0x3d4
80100666:	e8 c0 fc ff ff       	call   8010032b <outb>
8010066b:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010066e:	68 d5 03 00 00       	push   $0x3d5
80100673:	e8 96 fc ff ff       	call   8010030e <inb>
80100678:	83 c4 04             	add    $0x4,%esp
8010067b:	0f b6 c0             	movzbl %al,%eax
8010067e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100681:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100685:	75 30                	jne    801006b7 <cgaputc+0x83>
    pos += 80 - pos%80;
80100687:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010068a:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010068f:	89 c8                	mov    %ecx,%eax
80100691:	f7 ea                	imul   %edx
80100693:	c1 fa 05             	sar    $0x5,%edx
80100696:	89 c8                	mov    %ecx,%eax
80100698:	c1 f8 1f             	sar    $0x1f,%eax
8010069b:	29 c2                	sub    %eax,%edx
8010069d:	89 d0                	mov    %edx,%eax
8010069f:	c1 e0 02             	shl    $0x2,%eax
801006a2:	01 d0                	add    %edx,%eax
801006a4:	c1 e0 04             	shl    $0x4,%eax
801006a7:	29 c1                	sub    %eax,%ecx
801006a9:	89 ca                	mov    %ecx,%edx
801006ab:	b8 50 00 00 00       	mov    $0x50,%eax
801006b0:	29 d0                	sub    %edx,%eax
801006b2:	01 45 f4             	add    %eax,-0xc(%ebp)
801006b5:	eb 34                	jmp    801006eb <cgaputc+0xb7>
  else if(c == BACKSPACE){
801006b7:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006be:	75 0c                	jne    801006cc <cgaputc+0x98>
    if(pos > 0) --pos;
801006c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006c4:	7e 25                	jle    801006eb <cgaputc+0xb7>
801006c6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ca:	eb 1f                	jmp    801006eb <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006cc:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006d5:	8d 50 01             	lea    0x1(%eax),%edx
801006d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006db:	01 c0                	add    %eax,%eax
801006dd:	01 c8                	add    %ecx,%eax
801006df:	8b 55 08             	mov    0x8(%ebp),%edx
801006e2:	0f b6 d2             	movzbl %dl,%edx
801006e5:	80 ce 07             	or     $0x7,%dh
801006e8:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ef:	78 09                	js     801006fa <cgaputc+0xc6>
801006f1:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006f8:	7e 0d                	jle    80100707 <cgaputc+0xd3>
    panic("pos under/overflow");
801006fa:	83 ec 0c             	sub    $0xc,%esp
801006fd:	68 4b 87 10 80       	push   $0x8010874b
80100702:	e8 99 fe ff ff       	call   801005a0 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100707:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070e:	7e 4c                	jle    8010075c <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100710:	a1 00 90 10 80       	mov    0x80109000,%eax
80100715:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010071b:	a1 00 90 10 80       	mov    0x80109000,%eax
80100720:	83 ec 04             	sub    $0x4,%esp
80100723:	68 60 0e 00 00       	push   $0xe60
80100728:	52                   	push   %edx
80100729:	50                   	push   %eax
8010072a:	e8 07 4c 00 00       	call   80105336 <memmove>
8010072f:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100732:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100736:	b8 80 07 00 00       	mov    $0x780,%eax
8010073b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073e:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100741:	a1 00 90 10 80       	mov    0x80109000,%eax
80100746:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100749:	01 c9                	add    %ecx,%ecx
8010074b:	01 c8                	add    %ecx,%eax
8010074d:	83 ec 04             	sub    $0x4,%esp
80100750:	52                   	push   %edx
80100751:	6a 00                	push   $0x0
80100753:	50                   	push   %eax
80100754:	e8 1e 4b 00 00       	call   80105277 <memset>
80100759:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010075c:	83 ec 08             	sub    $0x8,%esp
8010075f:	6a 0e                	push   $0xe
80100761:	68 d4 03 00 00       	push   $0x3d4
80100766:	e8 c0 fb ff ff       	call   8010032b <outb>
8010076b:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100771:	c1 f8 08             	sar    $0x8,%eax
80100774:	0f b6 c0             	movzbl %al,%eax
80100777:	83 ec 08             	sub    $0x8,%esp
8010077a:	50                   	push   %eax
8010077b:	68 d5 03 00 00       	push   $0x3d5
80100780:	e8 a6 fb ff ff       	call   8010032b <outb>
80100785:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100788:	83 ec 08             	sub    $0x8,%esp
8010078b:	6a 0f                	push   $0xf
8010078d:	68 d4 03 00 00       	push   $0x3d4
80100792:	e8 94 fb ff ff       	call   8010032b <outb>
80100797:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010079d:	0f b6 c0             	movzbl %al,%eax
801007a0:	83 ec 08             	sub    $0x8,%esp
801007a3:	50                   	push   %eax
801007a4:	68 d5 03 00 00       	push   $0x3d5
801007a9:	e8 7d fb ff ff       	call   8010032b <outb>
801007ae:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007b1:	a1 00 90 10 80       	mov    0x80109000,%eax
801007b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007b9:	01 d2                	add    %edx,%edx
801007bb:	01 d0                	add    %edx,%eax
801007bd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007c2:	90                   	nop
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <consputc>:

void
consputc(int c)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007cb:	a1 80 b5 10 80       	mov    0x8010b580,%eax
801007d0:	85 c0                	test   %eax,%eax
801007d2:	74 07                	je     801007db <consputc+0x16>
    cli();
801007d4:	e8 71 fb ff ff       	call   8010034a <cli>
    for(;;)
      ;
801007d9:	eb fe                	jmp    801007d9 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007db:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007e2:	75 29                	jne    8010080d <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007e4:	83 ec 0c             	sub    $0xc,%esp
801007e7:	6a 08                	push   $0x8
801007e9:	e8 e1 64 00 00       	call   80106ccf <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	6a 20                	push   $0x20
801007f6:	e8 d4 64 00 00       	call   80106ccf <uartputc>
801007fb:	83 c4 10             	add    $0x10,%esp
801007fe:	83 ec 0c             	sub    $0xc,%esp
80100801:	6a 08                	push   $0x8
80100803:	e8 c7 64 00 00       	call   80106ccf <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	eb 0e                	jmp    8010081b <consputc+0x56>
  } else
    uartputc(c);
8010080d:	83 ec 0c             	sub    $0xc,%esp
80100810:	ff 75 08             	pushl  0x8(%ebp)
80100813:	e8 b7 64 00 00       	call   80106ccf <uartputc>
80100818:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010081b:	83 ec 0c             	sub    $0xc,%esp
8010081e:	ff 75 08             	pushl  0x8(%ebp)
80100821:	e8 0e fe ff ff       	call   80100634 <cgaputc>
80100826:	83 c4 10             	add    $0x10,%esp
}
80100829:	90                   	nop
8010082a:	c9                   	leave  
8010082b:	c3                   	ret    

8010082c <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010082c:	55                   	push   %ebp
8010082d:	89 e5                	mov    %esp,%ebp
8010082f:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100832:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100839:	83 ec 0c             	sub    $0xc,%esp
8010083c:	68 a0 b5 10 80       	push   $0x8010b5a0
80100841:	e8 ba 47 00 00       	call   80105000 <acquire>
80100846:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100849:	e9 44 01 00 00       	jmp    80100992 <consoleintr+0x166>
    switch(c){
8010084e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100851:	83 f8 10             	cmp    $0x10,%eax
80100854:	74 1e                	je     80100874 <consoleintr+0x48>
80100856:	83 f8 10             	cmp    $0x10,%eax
80100859:	7f 0a                	jg     80100865 <consoleintr+0x39>
8010085b:	83 f8 08             	cmp    $0x8,%eax
8010085e:	74 6b                	je     801008cb <consoleintr+0x9f>
80100860:	e9 9b 00 00 00       	jmp    80100900 <consoleintr+0xd4>
80100865:	83 f8 15             	cmp    $0x15,%eax
80100868:	74 33                	je     8010089d <consoleintr+0x71>
8010086a:	83 f8 7f             	cmp    $0x7f,%eax
8010086d:	74 5c                	je     801008cb <consoleintr+0x9f>
8010086f:	e9 8c 00 00 00       	jmp    80100900 <consoleintr+0xd4>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100874:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010087b:	e9 12 01 00 00       	jmp    80100992 <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100880:	a1 28 10 11 80       	mov    0x80111028,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
8010088d:	83 ec 0c             	sub    $0xc,%esp
80100890:	68 00 01 00 00       	push   $0x100
80100895:	e8 2b ff ff ff       	call   801007c5 <consputc>
8010089a:	83 c4 10             	add    $0x10,%esp
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010089d:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008a3:	a1 24 10 11 80       	mov    0x80111024,%eax
801008a8:	39 c2                	cmp    %eax,%edx
801008aa:	0f 84 e2 00 00 00    	je     80100992 <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008b0:	a1 28 10 11 80       	mov    0x80111028,%eax
801008b5:	83 e8 01             	sub    $0x1,%eax
801008b8:	83 e0 7f             	and    $0x7f,%eax
801008bb:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008c2:	3c 0a                	cmp    $0xa,%al
801008c4:	75 ba                	jne    80100880 <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008c6:	e9 c7 00 00 00       	jmp    80100992 <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008cb:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008d1:	a1 24 10 11 80       	mov    0x80111024,%eax
801008d6:	39 c2                	cmp    %eax,%edx
801008d8:	0f 84 b4 00 00 00    	je     80100992 <consoleintr+0x166>
        input.e--;
801008de:	a1 28 10 11 80       	mov    0x80111028,%eax
801008e3:	83 e8 01             	sub    $0x1,%eax
801008e6:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
801008eb:	83 ec 0c             	sub    $0xc,%esp
801008ee:	68 00 01 00 00       	push   $0x100
801008f3:	e8 cd fe ff ff       	call   801007c5 <consputc>
801008f8:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008fb:	e9 92 00 00 00       	jmp    80100992 <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100904:	0f 84 87 00 00 00    	je     80100991 <consoleintr+0x165>
8010090a:	8b 15 28 10 11 80    	mov    0x80111028,%edx
80100910:	a1 20 10 11 80       	mov    0x80111020,%eax
80100915:	29 c2                	sub    %eax,%edx
80100917:	89 d0                	mov    %edx,%eax
80100919:	83 f8 7f             	cmp    $0x7f,%eax
8010091c:	77 73                	ja     80100991 <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
8010091e:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100922:	74 05                	je     80100929 <consoleintr+0xfd>
80100924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100927:	eb 05                	jmp    8010092e <consoleintr+0x102>
80100929:	b8 0a 00 00 00       	mov    $0xa,%eax
8010092e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100931:	a1 28 10 11 80       	mov    0x80111028,%eax
80100936:	8d 50 01             	lea    0x1(%eax),%edx
80100939:	89 15 28 10 11 80    	mov    %edx,0x80111028
8010093f:	83 e0 7f             	and    $0x7f,%eax
80100942:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100945:	88 90 a0 0f 11 80    	mov    %dl,-0x7feef060(%eax)
        consputc(c);
8010094b:	83 ec 0c             	sub    $0xc,%esp
8010094e:	ff 75 f0             	pushl  -0x10(%ebp)
80100951:	e8 6f fe ff ff       	call   801007c5 <consputc>
80100956:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100959:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010095d:	74 18                	je     80100977 <consoleintr+0x14b>
8010095f:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100963:	74 12                	je     80100977 <consoleintr+0x14b>
80100965:	a1 28 10 11 80       	mov    0x80111028,%eax
8010096a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100970:	83 ea 80             	sub    $0xffffff80,%edx
80100973:	39 d0                	cmp    %edx,%eax
80100975:	75 1a                	jne    80100991 <consoleintr+0x165>
          input.w = input.e;
80100977:	a1 28 10 11 80       	mov    0x80111028,%eax
8010097c:	a3 24 10 11 80       	mov    %eax,0x80111024
          wakeup(&input.r);
80100981:	83 ec 0c             	sub    $0xc,%esp
80100984:	68 20 10 11 80       	push   $0x80111020
80100989:	e8 39 43 00 00       	call   80104cc7 <wakeup>
8010098e:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100991:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100992:	8b 45 08             	mov    0x8(%ebp),%eax
80100995:	ff d0                	call   *%eax
80100997:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010099a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099e:	0f 89 aa fe ff ff    	jns    8010084e <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009a4:	83 ec 0c             	sub    $0xc,%esp
801009a7:	68 a0 b5 10 80       	push   $0x8010b5a0
801009ac:	e8 bd 46 00 00       	call   8010506e <release>
801009b1:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b8:	74 05                	je     801009bf <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
801009ba:	e8 c6 43 00 00       	call   80104d85 <procdump>
  }
}
801009bf:	90                   	nop
801009c0:	c9                   	leave  
801009c1:	c3                   	ret    

801009c2 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c2:	55                   	push   %ebp
801009c3:	89 e5                	mov    %esp,%ebp
801009c5:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	ff 75 08             	pushl  0x8(%ebp)
801009ce:	e8 b4 11 00 00       	call   80101b87 <iunlock>
801009d3:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009dc:	83 ec 0c             	sub    $0xc,%esp
801009df:	68 a0 b5 10 80       	push   $0x8010b5a0
801009e4:	e8 17 46 00 00       	call   80105000 <acquire>
801009e9:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ec:	e9 ab 00 00 00       	jmp    80100a9c <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009f1:	e8 fb 38 00 00       	call   801042f1 <myproc>
801009f6:	8b 40 24             	mov    0x24(%eax),%eax
801009f9:	85 c0                	test   %eax,%eax
801009fb:	74 28                	je     80100a25 <consoleread+0x63>
        release(&cons.lock);
801009fd:	83 ec 0c             	sub    $0xc,%esp
80100a00:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a05:	e8 64 46 00 00       	call   8010506e <release>
80100a0a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0d:	83 ec 0c             	sub    $0xc,%esp
80100a10:	ff 75 08             	pushl  0x8(%ebp)
80100a13:	e8 5c 10 00 00       	call   80101a74 <ilock>
80100a18:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a20:	e9 ab 00 00 00       	jmp    80100ad0 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
80100a25:	83 ec 08             	sub    $0x8,%esp
80100a28:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a2d:	68 20 10 11 80       	push   $0x80111020
80100a32:	e8 a7 41 00 00       	call   80104bde <sleep>
80100a37:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a3a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100a40:	a1 24 10 11 80       	mov    0x80111024,%eax
80100a45:	39 c2                	cmp    %eax,%edx
80100a47:	74 a8                	je     801009f1 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a49:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a4e:	8d 50 01             	lea    0x1(%eax),%edx
80100a51:	89 15 20 10 11 80    	mov    %edx,0x80111020
80100a57:	83 e0 7f             	and    $0x7f,%eax
80100a5a:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
80100a61:	0f be c0             	movsbl %al,%eax
80100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a67:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6b:	75 17                	jne    80100a84 <consoleread+0xc2>
      if(n < target){
80100a6d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a70:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a73:	73 2f                	jae    80100aa4 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a75:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a7a:	83 e8 01             	sub    $0x1,%eax
80100a7d:	a3 20 10 11 80       	mov    %eax,0x80111020
      }
      break;
80100a82:	eb 20                	jmp    80100aa4 <consoleread+0xe2>
    }
    *dst++ = c;
80100a84:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a87:	8d 50 01             	lea    0x1(%eax),%edx
80100a8a:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a90:	88 10                	mov    %dl,(%eax)
    --n;
80100a92:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a96:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a9a:	74 0b                	je     80100aa7 <consoleread+0xe5>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100aa0:	7f 98                	jg     80100a3a <consoleread+0x78>
80100aa2:	eb 04                	jmp    80100aa8 <consoleread+0xe6>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100aa4:	90                   	nop
80100aa5:	eb 01                	jmp    80100aa8 <consoleread+0xe6>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100aa7:	90                   	nop
  }
  release(&cons.lock);
80100aa8:	83 ec 0c             	sub    $0xc,%esp
80100aab:	68 a0 b5 10 80       	push   $0x8010b5a0
80100ab0:	e8 b9 45 00 00       	call   8010506e <release>
80100ab5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab8:	83 ec 0c             	sub    $0xc,%esp
80100abb:	ff 75 08             	pushl  0x8(%ebp)
80100abe:	e8 b1 0f 00 00       	call   80101a74 <ilock>
80100ac3:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac6:	8b 45 10             	mov    0x10(%ebp),%eax
80100ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acc:	29 c2                	sub    %eax,%edx
80100ace:	89 d0                	mov    %edx,%eax
}
80100ad0:	c9                   	leave  
80100ad1:	c3                   	ret    

80100ad2 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad2:	55                   	push   %ebp
80100ad3:	89 e5                	mov    %esp,%ebp
80100ad5:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad8:	83 ec 0c             	sub    $0xc,%esp
80100adb:	ff 75 08             	pushl  0x8(%ebp)
80100ade:	e8 a4 10 00 00       	call   80101b87 <iunlock>
80100ae3:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 a0 b5 10 80       	push   $0x8010b5a0
80100aee:	e8 0d 45 00 00       	call   80105000 <acquire>
80100af3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100afd:	eb 21                	jmp    80100b20 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100aff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b05:	01 d0                	add    %edx,%eax
80100b07:	0f b6 00             	movzbl (%eax),%eax
80100b0a:	0f be c0             	movsbl %al,%eax
80100b0d:	0f b6 c0             	movzbl %al,%eax
80100b10:	83 ec 0c             	sub    $0xc,%esp
80100b13:	50                   	push   %eax
80100b14:	e8 ac fc ff ff       	call   801007c5 <consputc>
80100b19:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b23:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b26:	7c d7                	jl     80100aff <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b28:	83 ec 0c             	sub    $0xc,%esp
80100b2b:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b30:	e8 39 45 00 00       	call   8010506e <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 31 0f 00 00       	call   80101a74 <ilock>
80100b43:	83 c4 10             	add    $0x10,%esp

  return n;
80100b46:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b49:	c9                   	leave  
80100b4a:	c3                   	ret    

80100b4b <consoleinit>:

void
consoleinit(void)
{
80100b4b:	55                   	push   %ebp
80100b4c:	89 e5                	mov    %esp,%ebp
80100b4e:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b51:	83 ec 08             	sub    $0x8,%esp
80100b54:	68 5e 87 10 80       	push   $0x8010875e
80100b59:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b5e:	e8 7b 44 00 00       	call   80104fde <initlock>
80100b63:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b66:	c7 05 ec 19 11 80 d2 	movl   $0x80100ad2,0x801119ec
80100b6d:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b70:	c7 05 e8 19 11 80 c2 	movl   $0x801009c2,0x801119e8
80100b77:	09 10 80 
  cons.locking = 1;
80100b7a:	c7 05 d4 b5 10 80 01 	movl   $0x1,0x8010b5d4
80100b81:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b84:	83 ec 08             	sub    $0x8,%esp
80100b87:	6a 00                	push   $0x0
80100b89:	6a 01                	push   $0x1
80100b8b:	e8 f8 1f 00 00       	call   80102b88 <ioapicenable>
80100b90:	83 c4 10             	add    $0x10,%esp
}
80100b93:	90                   	nop
80100b94:	c9                   	leave  
80100b95:	c3                   	ret    

80100b96 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b96:	55                   	push   %ebp
80100b97:	89 e5                	mov    %esp,%ebp
80100b99:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b9f:	e8 4d 37 00 00       	call   801042f1 <myproc>
80100ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba7:	e8 ed 29 00 00       	call   80103599 <begin_op>

  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 fd 19 00 00       	call   801025b4 <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 1f                	jne    80100be2 <exec+0x4c>
    end_op();
80100bc3:	e8 5d 2a 00 00       	call   80103625 <end_op>
    cprintf("exec: fail\n");
80100bc8:	83 ec 0c             	sub    $0xc,%esp
80100bcb:	68 66 87 10 80       	push   $0x80108766
80100bd0:	e8 2b f8 ff ff       	call   80100400 <cprintf>
80100bd5:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdd:	e9 55 04 00 00       	jmp    80101037 <exec+0x4a1>
  }
  ilock(ip);
80100be2:	83 ec 0c             	sub    $0xc,%esp
80100be5:	ff 75 d8             	pushl  -0x28(%ebp)
80100be8:	e8 87 0e 00 00       	call   80101a74 <ilock>
80100bed:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bf0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bf7:	6a 34                	push   $0x34
80100bf9:	6a 00                	push   $0x0
80100bfb:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c01:	50                   	push   %eax
80100c02:	ff 75 d8             	pushl  -0x28(%ebp)
80100c05:	e8 5b 13 00 00       	call   80101f65 <readi>
80100c0a:	83 c4 10             	add    $0x10,%esp
80100c0d:	83 f8 34             	cmp    $0x34,%eax
80100c10:	0f 85 ca 03 00 00    	jne    80100fe0 <exec+0x44a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c21:	0f 85 bc 03 00 00    	jne    80100fe3 <exec+0x44d>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c27:	e8 b2 70 00 00       	call   80107cde <setupkvm>
80100c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c33:	0f 84 ad 03 00 00    	je     80100fe6 <exec+0x450>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c39:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c40:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c47:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c50:	e9 de 00 00 00       	jmp    80100d33 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c58:	6a 20                	push   $0x20
80100c5a:	50                   	push   %eax
80100c5b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c61:	50                   	push   %eax
80100c62:	ff 75 d8             	pushl  -0x28(%ebp)
80100c65:	e8 fb 12 00 00       	call   80101f65 <readi>
80100c6a:	83 c4 10             	add    $0x10,%esp
80100c6d:	83 f8 20             	cmp    $0x20,%eax
80100c70:	0f 85 73 03 00 00    	jne    80100fe9 <exec+0x453>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c76:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c7c:	83 f8 01             	cmp    $0x1,%eax
80100c7f:	0f 85 a0 00 00 00    	jne    80100d25 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c91:	39 c2                	cmp    %eax,%edx
80100c93:	0f 82 53 03 00 00    	jb     80100fec <exec+0x456>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c99:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c9f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca5:	01 c2                	add    %eax,%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	39 c2                	cmp    %eax,%edx
80100caf:	0f 82 3a 03 00 00    	jb     80100fef <exec+0x459>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc1:	01 d0                	add    %edx,%eax
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 e0             	pushl  -0x20(%ebp)
80100cca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccd:	e8 b1 73 00 00       	call   80108083 <allocuvm>
80100cd2:	83 c4 10             	add    $0x10,%esp
80100cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdc:	0f 84 10 03 00 00    	je     80100ff2 <exec+0x45c>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ce8:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	0f 85 00 03 00 00    	jne    80100ff5 <exec+0x45f>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cf5:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cfb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d01:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	52                   	push   %edx
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 d8             	pushl  -0x28(%ebp)
80100d0f:	51                   	push   %ecx
80100d10:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d13:	e8 9e 72 00 00       	call   80107fb6 <loaduvm>
80100d18:	83 c4 20             	add    $0x20,%esp
80100d1b:	85 c0                	test   %eax,%eax
80100d1d:	0f 88 d5 02 00 00    	js     80100ff8 <exec+0x462>
80100d23:	eb 01                	jmp    80100d26 <exec+0x190>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d25:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d26:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d2d:	83 c0 20             	add    $0x20,%eax
80100d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d33:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d3a:	0f b7 c0             	movzwl %ax,%eax
80100d3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d40:	0f 8f 0f ff ff ff    	jg     80100c55 <exec+0xbf>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d46:	83 ec 0c             	sub    $0xc,%esp
80100d49:	ff 75 d8             	pushl  -0x28(%ebp)
80100d4c:	e8 54 0f 00 00       	call   80101ca5 <iunlockput>
80100d51:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d54:	e8 cc 28 00 00       	call   80103625 <end_op>
  ip = 0;
80100d59:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d63:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d73:	05 00 10 00 00       	add    $0x1000,%eax
80100d78:	83 ec 04             	sub    $0x4,%esp
80100d7b:	50                   	push   %eax
80100d7c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d7f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d82:	e8 fc 72 00 00       	call   80108083 <allocuvm>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d91:	0f 84 64 02 00 00    	je     80100ffb <exec+0x465>
    goto bad;
  clearpteu(pgdir, (char*)(sz - PGSIZE));
80100d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9a:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d9f:	83 ec 08             	sub    $0x8,%esp
80100da2:	50                   	push   %eax
80100da3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da6:	e8 60 75 00 00       	call   8010830b <clearpteu>
80100dab:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)

   //cprintf("KERNBASE: %x\n", KERNBASE);
   //cprintf("PGSIZE: %d\n", PGSIZE);

   curproc->stackTop = allocuvm(pgdir, KERNBASE - PGSIZE, KERNBASE - 4);
80100db4:	83 ec 04             	sub    $0x4,%esp
80100db7:	68 fc ff ff 7f       	push   $0x7ffffffc
80100dbc:	68 00 f0 ff 7f       	push   $0x7ffff000
80100dc1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc4:	e8 ba 72 00 00       	call   80108083 <allocuvm>
80100dc9:	83 c4 10             	add    $0x10,%esp
80100dcc:	89 c2                	mov    %eax,%edx
80100dce:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dd1:	89 50 7c             	mov    %edx,0x7c(%eax)
   curproc->pageNum = 1;
80100dd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dd7:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
80100dde:	00 00 00 
  
   cprintf("stackTop: %x\n", curproc->stackTop);
80100de1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100de4:	8b 40 7c             	mov    0x7c(%eax),%eax
80100de7:	83 ec 08             	sub    $0x8,%esp
80100dea:	50                   	push   %eax
80100deb:	68 72 87 10 80       	push   $0x80108772
80100df0:	e8 0b f6 ff ff       	call   80100400 <cprintf>
80100df5:	83 c4 10             	add    $0x10,%esp
   cprintf("pageNum: %x\n", curproc->pageNum);
80100df8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dfb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80100e01:	83 ec 08             	sub    $0x8,%esp
80100e04:	50                   	push   %eax
80100e05:	68 80 87 10 80       	push   $0x80108780
80100e0a:	e8 f1 f5 ff ff       	call   80100400 <cprintf>
80100e0f:	83 c4 10             	add    $0x10,%esp

   sp = curproc->stackTop;
80100e12:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e15:	8b 40 7c             	mov    0x7c(%eax),%eax
80100e18:	89 45 dc             	mov    %eax,-0x24(%ebp)
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e1b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e22:	e9 93 00 00 00       	jmp    80100eba <exec+0x324>
    if(argc >= MAXARG)
80100e27:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e2b:	0f 87 cd 01 00 00    	ja     80100ffe <exec+0x468>
      goto bad;
    sp = (sp - (strlen(argv[argc]) )) & ~3;
80100e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e3e:	01 d0                	add    %edx,%eax
80100e40:	8b 00                	mov    (%eax),%eax
80100e42:	83 ec 0c             	sub    $0xc,%esp
80100e45:	50                   	push   %eax
80100e46:	e8 79 46 00 00       	call   801054c4 <strlen>
80100e4b:	83 c4 10             	add    $0x10,%esp
80100e4e:	89 c2                	mov    %eax,%edx
80100e50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e53:	29 d0                	sub    %edx,%eax
80100e55:	83 e0 fc             	and    $0xfffffffc,%eax
80100e58:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e65:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e68:	01 d0                	add    %edx,%eax
80100e6a:	8b 00                	mov    (%eax),%eax
80100e6c:	83 ec 0c             	sub    $0xc,%esp
80100e6f:	50                   	push   %eax
80100e70:	e8 4f 46 00 00       	call   801054c4 <strlen>
80100e75:	83 c4 10             	add    $0x10,%esp
80100e78:	83 c0 01             	add    $0x1,%eax
80100e7b:	89 c1                	mov    %eax,%ecx
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e87:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8a:	01 d0                	add    %edx,%eax
80100e8c:	8b 00                	mov    (%eax),%eax
80100e8e:	51                   	push   %ecx
80100e8f:	50                   	push   %eax
80100e90:	ff 75 dc             	pushl  -0x24(%ebp)
80100e93:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e96:	e8 10 77 00 00       	call   801085ab <copyout>
80100e9b:	83 c4 10             	add    $0x10,%esp
80100e9e:	85 c0                	test   %eax,%eax
80100ea0:	0f 88 5b 01 00 00    	js     80101001 <exec+0x46b>
      goto bad;
    ustack[3+argc] = sp;
80100ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea9:	8d 50 03             	lea    0x3(%eax),%edx
80100eac:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eaf:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
   cprintf("pageNum: %x\n", curproc->pageNum);

   sp = curproc->stackTop;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100eb6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec7:	01 d0                	add    %edx,%eax
80100ec9:	8b 00                	mov    (%eax),%eax
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	0f 85 54 ff ff ff    	jne    80100e27 <exec+0x291>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed6:	83 c0 03             	add    $0x3,%eax
80100ed9:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ee0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ee4:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eeb:	ff ff ff 
  ustack[1] = argc;
80100eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef1:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efa:	83 c0 01             	add    $0x1,%eax
80100efd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f07:	29 d0                	sub    %edx,%eax
80100f09:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f12:	83 c0 04             	add    $0x4,%eax
80100f15:	c1 e0 02             	shl    $0x2,%eax
80100f18:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f1e:	83 c0 04             	add    $0x4,%eax
80100f21:	c1 e0 02             	shl    $0x2,%eax
80100f24:	50                   	push   %eax
80100f25:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f2b:	50                   	push   %eax
80100f2c:	ff 75 dc             	pushl  -0x24(%ebp)
80100f2f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f32:	e8 74 76 00 00       	call   801085ab <copyout>
80100f37:	83 c4 10             	add    $0x10,%esp
80100f3a:	85 c0                	test   %eax,%eax
80100f3c:	0f 88 c2 00 00 00    	js     80101004 <exec+0x46e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f42:	8b 45 08             	mov    0x8(%ebp),%eax
80100f45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f4e:	eb 17                	jmp    80100f67 <exec+0x3d1>
    if(*s == '/')
80100f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f53:	0f b6 00             	movzbl (%eax),%eax
80100f56:	3c 2f                	cmp    $0x2f,%al
80100f58:	75 09                	jne    80100f63 <exec+0x3cd>
      last = s+1;
80100f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5d:	83 c0 01             	add    $0x1,%eax
80100f60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f6a:	0f b6 00             	movzbl (%eax),%eax
80100f6d:	84 c0                	test   %al,%al
80100f6f:	75 df                	jne    80100f50 <exec+0x3ba>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f74:	83 c0 6c             	add    $0x6c,%eax
80100f77:	83 ec 04             	sub    $0x4,%esp
80100f7a:	6a 10                	push   $0x10
80100f7c:	ff 75 f0             	pushl  -0x10(%ebp)
80100f7f:	50                   	push   %eax
80100f80:	e8 f5 44 00 00       	call   8010547a <safestrcpy>
80100f85:	83 c4 10             	add    $0x10,%esp
 
 
  // Commit to the user image.
//  cprintf("SP: %x\n", sp);
//  cprintf("DIFFERENCE: %d\n", curproc->last_page-sp);
  oldpgdir = curproc->pgdir;
80100f88:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f8b:	8b 40 04             	mov    0x4(%eax),%eax
80100f8e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f91:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f94:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f97:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f9d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fa0:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fa2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa5:	8b 40 18             	mov    0x18(%eax),%eax
80100fa8:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fae:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100fb1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb4:	8b 40 18             	mov    0x18(%eax),%eax
80100fb7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fba:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fbd:	83 ec 0c             	sub    $0xc,%esp
80100fc0:	ff 75 d0             	pushl  -0x30(%ebp)
80100fc3:	e8 e0 6d 00 00       	call   80107da8 <switchuvm>
80100fc8:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fcb:	83 ec 0c             	sub    $0xc,%esp
80100fce:	ff 75 cc             	pushl  -0x34(%ebp)
80100fd1:	e8 9c 72 00 00       	call   80108272 <freevm>
80100fd6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fd9:	b8 00 00 00 00       	mov    $0x0,%eax
80100fde:	eb 57                	jmp    80101037 <exec+0x4a1>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
80100fe0:	90                   	nop
80100fe1:	eb 22                	jmp    80101005 <exec+0x46f>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fe3:	90                   	nop
80100fe4:	eb 1f                	jmp    80101005 <exec+0x46f>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fe6:	90                   	nop
80100fe7:	eb 1c                	jmp    80101005 <exec+0x46f>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fe9:	90                   	nop
80100fea:	eb 19                	jmp    80101005 <exec+0x46f>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fec:	90                   	nop
80100fed:	eb 16                	jmp    80101005 <exec+0x46f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
80100fef:	90                   	nop
80100ff0:	eb 13                	jmp    80101005 <exec+0x46f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ff2:	90                   	nop
80100ff3:	eb 10                	jmp    80101005 <exec+0x46f>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
80100ff5:	90                   	nop
80100ff6:	eb 0d                	jmp    80101005 <exec+0x46f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ff8:	90                   	nop
80100ff9:	eb 0a                	jmp    80101005 <exec+0x46f>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;
80100ffb:	90                   	nop
80100ffc:	eb 07                	jmp    80101005 <exec+0x46f>
   sp = curproc->stackTop;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ffe:	90                   	nop
80100fff:	eb 04                	jmp    80101005 <exec+0x46f>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101001:	90                   	nop
80101002:	eb 01                	jmp    80101005 <exec+0x46f>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101004:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101005:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101009:	74 0e                	je     80101019 <exec+0x483>
    freevm(pgdir);
8010100b:	83 ec 0c             	sub    $0xc,%esp
8010100e:	ff 75 d4             	pushl  -0x2c(%ebp)
80101011:	e8 5c 72 00 00       	call   80108272 <freevm>
80101016:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101019:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010101d:	74 13                	je     80101032 <exec+0x49c>
    iunlockput(ip);
8010101f:	83 ec 0c             	sub    $0xc,%esp
80101022:	ff 75 d8             	pushl  -0x28(%ebp)
80101025:	e8 7b 0c 00 00       	call   80101ca5 <iunlockput>
8010102a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010102d:	e8 f3 25 00 00       	call   80103625 <end_op>
  }
  return -1;
80101032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101037:	c9                   	leave  
80101038:	c3                   	ret    

80101039 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101039:	55                   	push   %ebp
8010103a:	89 e5                	mov    %esp,%ebp
8010103c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010103f:	83 ec 08             	sub    $0x8,%esp
80101042:	68 8d 87 10 80       	push   $0x8010878d
80101047:	68 40 10 11 80       	push   $0x80111040
8010104c:	e8 8d 3f 00 00       	call   80104fde <initlock>
80101051:	83 c4 10             	add    $0x10,%esp
}
80101054:	90                   	nop
80101055:	c9                   	leave  
80101056:	c3                   	ret    

80101057 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101057:	55                   	push   %ebp
80101058:	89 e5                	mov    %esp,%ebp
8010105a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010105d:	83 ec 0c             	sub    $0xc,%esp
80101060:	68 40 10 11 80       	push   $0x80111040
80101065:	e8 96 3f 00 00       	call   80105000 <acquire>
8010106a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106d:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
80101074:	eb 2d                	jmp    801010a3 <filealloc+0x4c>
    if(f->ref == 0){
80101076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101079:	8b 40 04             	mov    0x4(%eax),%eax
8010107c:	85 c0                	test   %eax,%eax
8010107e:	75 1f                	jne    8010109f <filealloc+0x48>
      f->ref = 1;
80101080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101083:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010108a:	83 ec 0c             	sub    $0xc,%esp
8010108d:	68 40 10 11 80       	push   $0x80111040
80101092:	e8 d7 3f 00 00       	call   8010506e <release>
80101097:	83 c4 10             	add    $0x10,%esp
      return f;
8010109a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010109d:	eb 23                	jmp    801010c2 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010109f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010a3:	b8 d4 19 11 80       	mov    $0x801119d4,%eax
801010a8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010ab:	72 c9                	jb     80101076 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	68 40 10 11 80       	push   $0x80111040
801010b5:	e8 b4 3f 00 00       	call   8010506e <release>
801010ba:	83 c4 10             	add    $0x10,%esp
  return 0;
801010bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010c2:	c9                   	leave  
801010c3:	c3                   	ret    

801010c4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010c4:	55                   	push   %ebp
801010c5:	89 e5                	mov    %esp,%ebp
801010c7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 40 10 11 80       	push   $0x80111040
801010d2:	e8 29 3f 00 00       	call   80105000 <acquire>
801010d7:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010da:	8b 45 08             	mov    0x8(%ebp),%eax
801010dd:	8b 40 04             	mov    0x4(%eax),%eax
801010e0:	85 c0                	test   %eax,%eax
801010e2:	7f 0d                	jg     801010f1 <filedup+0x2d>
    panic("filedup");
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 94 87 10 80       	push   $0x80108794
801010ec:	e8 af f4 ff ff       	call   801005a0 <panic>
  f->ref++;
801010f1:	8b 45 08             	mov    0x8(%ebp),%eax
801010f4:	8b 40 04             	mov    0x4(%eax),%eax
801010f7:	8d 50 01             	lea    0x1(%eax),%edx
801010fa:	8b 45 08             	mov    0x8(%ebp),%eax
801010fd:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101100:	83 ec 0c             	sub    $0xc,%esp
80101103:	68 40 10 11 80       	push   $0x80111040
80101108:	e8 61 3f 00 00       	call   8010506e <release>
8010110d:	83 c4 10             	add    $0x10,%esp
  return f;
80101110:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101113:	c9                   	leave  
80101114:	c3                   	ret    

80101115 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101115:	55                   	push   %ebp
80101116:	89 e5                	mov    %esp,%ebp
80101118:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010111b:	83 ec 0c             	sub    $0xc,%esp
8010111e:	68 40 10 11 80       	push   $0x80111040
80101123:	e8 d8 3e 00 00       	call   80105000 <acquire>
80101128:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010112b:	8b 45 08             	mov    0x8(%ebp),%eax
8010112e:	8b 40 04             	mov    0x4(%eax),%eax
80101131:	85 c0                	test   %eax,%eax
80101133:	7f 0d                	jg     80101142 <fileclose+0x2d>
    panic("fileclose");
80101135:	83 ec 0c             	sub    $0xc,%esp
80101138:	68 9c 87 10 80       	push   $0x8010879c
8010113d:	e8 5e f4 ff ff       	call   801005a0 <panic>
  if(--f->ref > 0){
80101142:	8b 45 08             	mov    0x8(%ebp),%eax
80101145:	8b 40 04             	mov    0x4(%eax),%eax
80101148:	8d 50 ff             	lea    -0x1(%eax),%edx
8010114b:	8b 45 08             	mov    0x8(%ebp),%eax
8010114e:	89 50 04             	mov    %edx,0x4(%eax)
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 40 04             	mov    0x4(%eax),%eax
80101157:	85 c0                	test   %eax,%eax
80101159:	7e 15                	jle    80101170 <fileclose+0x5b>
    release(&ftable.lock);
8010115b:	83 ec 0c             	sub    $0xc,%esp
8010115e:	68 40 10 11 80       	push   $0x80111040
80101163:	e8 06 3f 00 00       	call   8010506e <release>
80101168:	83 c4 10             	add    $0x10,%esp
8010116b:	e9 8b 00 00 00       	jmp    801011fb <fileclose+0xe6>
    return;
  }
  ff = *f;
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 10                	mov    (%eax),%edx
80101175:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101178:	8b 50 04             	mov    0x4(%eax),%edx
8010117b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010117e:	8b 50 08             	mov    0x8(%eax),%edx
80101181:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101184:	8b 50 0c             	mov    0xc(%eax),%edx
80101187:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010118a:	8b 50 10             	mov    0x10(%eax),%edx
8010118d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101190:	8b 40 14             	mov    0x14(%eax),%eax
80101193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011a9:	83 ec 0c             	sub    $0xc,%esp
801011ac:	68 40 10 11 80       	push   $0x80111040
801011b1:	e8 b8 3e 00 00       	call   8010506e <release>
801011b6:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011bc:	83 f8 01             	cmp    $0x1,%eax
801011bf:	75 19                	jne    801011da <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011c1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011c5:	0f be d0             	movsbl %al,%edx
801011c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011cb:	83 ec 08             	sub    $0x8,%esp
801011ce:	52                   	push   %edx
801011cf:	50                   	push   %eax
801011d0:	e8 a6 2d 00 00       	call   80103f7b <pipeclose>
801011d5:	83 c4 10             	add    $0x10,%esp
801011d8:	eb 21                	jmp    801011fb <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011dd:	83 f8 02             	cmp    $0x2,%eax
801011e0:	75 19                	jne    801011fb <fileclose+0xe6>
    begin_op();
801011e2:	e8 b2 23 00 00       	call   80103599 <begin_op>
    iput(ff.ip);
801011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	50                   	push   %eax
801011ee:	e8 e2 09 00 00       	call   80101bd5 <iput>
801011f3:	83 c4 10             	add    $0x10,%esp
    end_op();
801011f6:	e8 2a 24 00 00       	call   80103625 <end_op>
  }
}
801011fb:	c9                   	leave  
801011fc:	c3                   	ret    

801011fd <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011fd:	55                   	push   %ebp
801011fe:	89 e5                	mov    %esp,%ebp
80101200:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101203:	8b 45 08             	mov    0x8(%ebp),%eax
80101206:	8b 00                	mov    (%eax),%eax
80101208:	83 f8 02             	cmp    $0x2,%eax
8010120b:	75 40                	jne    8010124d <filestat+0x50>
    ilock(f->ip);
8010120d:	8b 45 08             	mov    0x8(%ebp),%eax
80101210:	8b 40 10             	mov    0x10(%eax),%eax
80101213:	83 ec 0c             	sub    $0xc,%esp
80101216:	50                   	push   %eax
80101217:	e8 58 08 00 00       	call   80101a74 <ilock>
8010121c:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010121f:	8b 45 08             	mov    0x8(%ebp),%eax
80101222:	8b 40 10             	mov    0x10(%eax),%eax
80101225:	83 ec 08             	sub    $0x8,%esp
80101228:	ff 75 0c             	pushl  0xc(%ebp)
8010122b:	50                   	push   %eax
8010122c:	e8 ee 0c 00 00       	call   80101f1f <stati>
80101231:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 40 10             	mov    0x10(%eax),%eax
8010123a:	83 ec 0c             	sub    $0xc,%esp
8010123d:	50                   	push   %eax
8010123e:	e8 44 09 00 00       	call   80101b87 <iunlock>
80101243:	83 c4 10             	add    $0x10,%esp
    return 0;
80101246:	b8 00 00 00 00       	mov    $0x0,%eax
8010124b:	eb 05                	jmp    80101252 <filestat+0x55>
  }
  return -1;
8010124d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101252:	c9                   	leave  
80101253:	c3                   	ret    

80101254 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101254:	55                   	push   %ebp
80101255:	89 e5                	mov    %esp,%ebp
80101257:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010125a:	8b 45 08             	mov    0x8(%ebp),%eax
8010125d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101261:	84 c0                	test   %al,%al
80101263:	75 0a                	jne    8010126f <fileread+0x1b>
    return -1;
80101265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010126a:	e9 9b 00 00 00       	jmp    8010130a <fileread+0xb6>
  if(f->type == FD_PIPE)
8010126f:	8b 45 08             	mov    0x8(%ebp),%eax
80101272:	8b 00                	mov    (%eax),%eax
80101274:	83 f8 01             	cmp    $0x1,%eax
80101277:	75 1a                	jne    80101293 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 40 0c             	mov    0xc(%eax),%eax
8010127f:	83 ec 04             	sub    $0x4,%esp
80101282:	ff 75 10             	pushl  0x10(%ebp)
80101285:	ff 75 0c             	pushl  0xc(%ebp)
80101288:	50                   	push   %eax
80101289:	e8 94 2e 00 00       	call   80104122 <piperead>
8010128e:	83 c4 10             	add    $0x10,%esp
80101291:	eb 77                	jmp    8010130a <fileread+0xb6>
  if(f->type == FD_INODE){
80101293:	8b 45 08             	mov    0x8(%ebp),%eax
80101296:	8b 00                	mov    (%eax),%eax
80101298:	83 f8 02             	cmp    $0x2,%eax
8010129b:	75 60                	jne    801012fd <fileread+0xa9>
    ilock(f->ip);
8010129d:	8b 45 08             	mov    0x8(%ebp),%eax
801012a0:	8b 40 10             	mov    0x10(%eax),%eax
801012a3:	83 ec 0c             	sub    $0xc,%esp
801012a6:	50                   	push   %eax
801012a7:	e8 c8 07 00 00       	call   80101a74 <ilock>
801012ac:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012af:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 50 14             	mov    0x14(%eax),%edx
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 10             	mov    0x10(%eax),%eax
801012be:	51                   	push   %ecx
801012bf:	52                   	push   %edx
801012c0:	ff 75 0c             	pushl  0xc(%ebp)
801012c3:	50                   	push   %eax
801012c4:	e8 9c 0c 00 00       	call   80101f65 <readi>
801012c9:	83 c4 10             	add    $0x10,%esp
801012cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012d3:	7e 11                	jle    801012e6 <fileread+0x92>
      f->off += r;
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 50 14             	mov    0x14(%eax),%edx
801012db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012de:	01 c2                	add    %eax,%edx
801012e0:	8b 45 08             	mov    0x8(%ebp),%eax
801012e3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012e6:	8b 45 08             	mov    0x8(%ebp),%eax
801012e9:	8b 40 10             	mov    0x10(%eax),%eax
801012ec:	83 ec 0c             	sub    $0xc,%esp
801012ef:	50                   	push   %eax
801012f0:	e8 92 08 00 00       	call   80101b87 <iunlock>
801012f5:	83 c4 10             	add    $0x10,%esp
    return r;
801012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012fb:	eb 0d                	jmp    8010130a <fileread+0xb6>
  }
  panic("fileread");
801012fd:	83 ec 0c             	sub    $0xc,%esp
80101300:	68 a6 87 10 80       	push   $0x801087a6
80101305:	e8 96 f2 ff ff       	call   801005a0 <panic>
}
8010130a:	c9                   	leave  
8010130b:	c3                   	ret    

8010130c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010130c:	55                   	push   %ebp
8010130d:	89 e5                	mov    %esp,%ebp
8010130f:	53                   	push   %ebx
80101310:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
80101316:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010131a:	84 c0                	test   %al,%al
8010131c:	75 0a                	jne    80101328 <filewrite+0x1c>
    return -1;
8010131e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101323:	e9 1b 01 00 00       	jmp    80101443 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101328:	8b 45 08             	mov    0x8(%ebp),%eax
8010132b:	8b 00                	mov    (%eax),%eax
8010132d:	83 f8 01             	cmp    $0x1,%eax
80101330:	75 1d                	jne    8010134f <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101332:	8b 45 08             	mov    0x8(%ebp),%eax
80101335:	8b 40 0c             	mov    0xc(%eax),%eax
80101338:	83 ec 04             	sub    $0x4,%esp
8010133b:	ff 75 10             	pushl  0x10(%ebp)
8010133e:	ff 75 0c             	pushl  0xc(%ebp)
80101341:	50                   	push   %eax
80101342:	e8 de 2c 00 00       	call   80104025 <pipewrite>
80101347:	83 c4 10             	add    $0x10,%esp
8010134a:	e9 f4 00 00 00       	jmp    80101443 <filewrite+0x137>
  if(f->type == FD_INODE){
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	8b 00                	mov    (%eax),%eax
80101354:	83 f8 02             	cmp    $0x2,%eax
80101357:	0f 85 d9 00 00 00    	jne    80101436 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010135d:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101364:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010136b:	e9 a3 00 00 00       	jmp    80101413 <filewrite+0x107>
      int n1 = n - i;
80101370:	8b 45 10             	mov    0x10(%ebp),%eax
80101373:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101376:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010137c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010137f:	7e 06                	jle    80101387 <filewrite+0x7b>
        n1 = max;
80101381:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101384:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101387:	e8 0d 22 00 00       	call   80103599 <begin_op>
      ilock(f->ip);
8010138c:	8b 45 08             	mov    0x8(%ebp),%eax
8010138f:	8b 40 10             	mov    0x10(%eax),%eax
80101392:	83 ec 0c             	sub    $0xc,%esp
80101395:	50                   	push   %eax
80101396:	e8 d9 06 00 00       	call   80101a74 <ilock>
8010139b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010139e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013a1:	8b 45 08             	mov    0x8(%ebp),%eax
801013a4:	8b 50 14             	mov    0x14(%eax),%edx
801013a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801013ad:	01 c3                	add    %eax,%ebx
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	8b 40 10             	mov    0x10(%eax),%eax
801013b5:	51                   	push   %ecx
801013b6:	52                   	push   %edx
801013b7:	53                   	push   %ebx
801013b8:	50                   	push   %eax
801013b9:	e8 fe 0c 00 00       	call   801020bc <writei>
801013be:	83 c4 10             	add    $0x10,%esp
801013c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013c8:	7e 11                	jle    801013db <filewrite+0xcf>
        f->off += r;
801013ca:	8b 45 08             	mov    0x8(%ebp),%eax
801013cd:	8b 50 14             	mov    0x14(%eax),%edx
801013d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d3:	01 c2                	add    %eax,%edx
801013d5:	8b 45 08             	mov    0x8(%ebp),%eax
801013d8:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013db:	8b 45 08             	mov    0x8(%ebp),%eax
801013de:	8b 40 10             	mov    0x10(%eax),%eax
801013e1:	83 ec 0c             	sub    $0xc,%esp
801013e4:	50                   	push   %eax
801013e5:	e8 9d 07 00 00       	call   80101b87 <iunlock>
801013ea:	83 c4 10             	add    $0x10,%esp
      end_op();
801013ed:	e8 33 22 00 00       	call   80103625 <end_op>

      if(r < 0)
801013f2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013f6:	78 29                	js     80101421 <filewrite+0x115>
        break;
      if(r != n1)
801013f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013fe:	74 0d                	je     8010140d <filewrite+0x101>
        panic("short filewrite");
80101400:	83 ec 0c             	sub    $0xc,%esp
80101403:	68 af 87 10 80       	push   $0x801087af
80101408:	e8 93 f1 ff ff       	call   801005a0 <panic>
      i += r;
8010140d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101410:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101416:	3b 45 10             	cmp    0x10(%ebp),%eax
80101419:	0f 8c 51 ff ff ff    	jl     80101370 <filewrite+0x64>
8010141f:	eb 01                	jmp    80101422 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101421:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101425:	3b 45 10             	cmp    0x10(%ebp),%eax
80101428:	75 05                	jne    8010142f <filewrite+0x123>
8010142a:	8b 45 10             	mov    0x10(%ebp),%eax
8010142d:	eb 14                	jmp    80101443 <filewrite+0x137>
8010142f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101434:	eb 0d                	jmp    80101443 <filewrite+0x137>
  }
  panic("filewrite");
80101436:	83 ec 0c             	sub    $0xc,%esp
80101439:	68 bf 87 10 80       	push   $0x801087bf
8010143e:	e8 5d f1 ff ff       	call   801005a0 <panic>
}
80101443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101446:	c9                   	leave  
80101447:	c3                   	ret    

80101448 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101448:	55                   	push   %ebp
80101449:	89 e5                	mov    %esp,%ebp
8010144b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010144e:	8b 45 08             	mov    0x8(%ebp),%eax
80101451:	83 ec 08             	sub    $0x8,%esp
80101454:	6a 01                	push   $0x1
80101456:	50                   	push   %eax
80101457:	e8 72 ed ff ff       	call   801001ce <bread>
8010145c:	83 c4 10             	add    $0x10,%esp
8010145f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101465:	83 c0 5c             	add    $0x5c,%eax
80101468:	83 ec 04             	sub    $0x4,%esp
8010146b:	6a 1c                	push   $0x1c
8010146d:	50                   	push   %eax
8010146e:	ff 75 0c             	pushl  0xc(%ebp)
80101471:	e8 c0 3e 00 00       	call   80105336 <memmove>
80101476:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101479:	83 ec 0c             	sub    $0xc,%esp
8010147c:	ff 75 f4             	pushl  -0xc(%ebp)
8010147f:	e8 cc ed ff ff       	call   80100250 <brelse>
80101484:	83 c4 10             	add    $0x10,%esp
}
80101487:	90                   	nop
80101488:	c9                   	leave  
80101489:	c3                   	ret    

8010148a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010148a:	55                   	push   %ebp
8010148b:	89 e5                	mov    %esp,%ebp
8010148d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101490:	8b 55 0c             	mov    0xc(%ebp),%edx
80101493:	8b 45 08             	mov    0x8(%ebp),%eax
80101496:	83 ec 08             	sub    $0x8,%esp
80101499:	52                   	push   %edx
8010149a:	50                   	push   %eax
8010149b:	e8 2e ed ff ff       	call   801001ce <bread>
801014a0:	83 c4 10             	add    $0x10,%esp
801014a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a9:	83 c0 5c             	add    $0x5c,%eax
801014ac:	83 ec 04             	sub    $0x4,%esp
801014af:	68 00 02 00 00       	push   $0x200
801014b4:	6a 00                	push   $0x0
801014b6:	50                   	push   %eax
801014b7:	e8 bb 3d 00 00       	call   80105277 <memset>
801014bc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014bf:	83 ec 0c             	sub    $0xc,%esp
801014c2:	ff 75 f4             	pushl  -0xc(%ebp)
801014c5:	e8 07 23 00 00       	call   801037d1 <log_write>
801014ca:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014cd:	83 ec 0c             	sub    $0xc,%esp
801014d0:	ff 75 f4             	pushl  -0xc(%ebp)
801014d3:	e8 78 ed ff ff       	call   80100250 <brelse>
801014d8:	83 c4 10             	add    $0x10,%esp
}
801014db:	90                   	nop
801014dc:	c9                   	leave  
801014dd:	c3                   	ret    

801014de <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014de:	55                   	push   %ebp
801014df:	89 e5                	mov    %esp,%ebp
801014e1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014f2:	e9 13 01 00 00       	jmp    8010160a <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fa:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101500:	85 c0                	test   %eax,%eax
80101502:	0f 48 c2             	cmovs  %edx,%eax
80101505:	c1 f8 0c             	sar    $0xc,%eax
80101508:	89 c2                	mov    %eax,%edx
8010150a:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010150f:	01 d0                	add    %edx,%eax
80101511:	83 ec 08             	sub    $0x8,%esp
80101514:	50                   	push   %eax
80101515:	ff 75 08             	pushl  0x8(%ebp)
80101518:	e8 b1 ec ff ff       	call   801001ce <bread>
8010151d:	83 c4 10             	add    $0x10,%esp
80101520:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101523:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010152a:	e9 a6 00 00 00       	jmp    801015d5 <balloc+0xf7>
      m = 1 << (bi % 8);
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	99                   	cltd   
80101533:	c1 ea 1d             	shr    $0x1d,%edx
80101536:	01 d0                	add    %edx,%eax
80101538:	83 e0 07             	and    $0x7,%eax
8010153b:	29 d0                	sub    %edx,%eax
8010153d:	ba 01 00 00 00       	mov    $0x1,%edx
80101542:	89 c1                	mov    %eax,%ecx
80101544:	d3 e2                	shl    %cl,%edx
80101546:	89 d0                	mov    %edx,%eax
80101548:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154e:	8d 50 07             	lea    0x7(%eax),%edx
80101551:	85 c0                	test   %eax,%eax
80101553:	0f 48 c2             	cmovs  %edx,%eax
80101556:	c1 f8 03             	sar    $0x3,%eax
80101559:	89 c2                	mov    %eax,%edx
8010155b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010155e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101563:	0f b6 c0             	movzbl %al,%eax
80101566:	23 45 e8             	and    -0x18(%ebp),%eax
80101569:	85 c0                	test   %eax,%eax
8010156b:	75 64                	jne    801015d1 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101570:	8d 50 07             	lea    0x7(%eax),%edx
80101573:	85 c0                	test   %eax,%eax
80101575:	0f 48 c2             	cmovs  %edx,%eax
80101578:	c1 f8 03             	sar    $0x3,%eax
8010157b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101588:	09 ca                	or     %ecx,%edx
8010158a:	89 d1                	mov    %edx,%ecx
8010158c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010158f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	ff 75 ec             	pushl  -0x14(%ebp)
80101599:	e8 33 22 00 00       	call   801037d1 <log_write>
8010159e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015a1:	83 ec 0c             	sub    $0xc,%esp
801015a4:	ff 75 ec             	pushl  -0x14(%ebp)
801015a7:	e8 a4 ec ff ff       	call   80100250 <brelse>
801015ac:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b5:	01 c2                	add    %eax,%edx
801015b7:	8b 45 08             	mov    0x8(%ebp),%eax
801015ba:	83 ec 08             	sub    $0x8,%esp
801015bd:	52                   	push   %edx
801015be:	50                   	push   %eax
801015bf:	e8 c6 fe ff ff       	call   8010148a <bzero>
801015c4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cd:	01 d0                	add    %edx,%eax
801015cf:	eb 57                	jmp    80101628 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015d5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015dc:	7f 17                	jg     801015f5 <balloc+0x117>
801015de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e4:	01 d0                	add    %edx,%eax
801015e6:	89 c2                	mov    %eax,%edx
801015e8:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801015ed:	39 c2                	cmp    %eax,%edx
801015ef:	0f 82 3a ff ff ff    	jb     8010152f <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015f5:	83 ec 0c             	sub    $0xc,%esp
801015f8:	ff 75 ec             	pushl  -0x14(%ebp)
801015fb:	e8 50 ec ff ff       	call   80100250 <brelse>
80101600:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101603:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010160a:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
80101610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101613:	39 c2                	cmp    %eax,%edx
80101615:	0f 87 dc fe ff ff    	ja     801014f7 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010161b:	83 ec 0c             	sub    $0xc,%esp
8010161e:	68 cc 87 10 80       	push   $0x801087cc
80101623:	e8 78 ef ff ff       	call   801005a0 <panic>
}
80101628:	c9                   	leave  
80101629:	c3                   	ret    

8010162a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010162a:	55                   	push   %ebp
8010162b:	89 e5                	mov    %esp,%ebp
8010162d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101630:	83 ec 08             	sub    $0x8,%esp
80101633:	68 40 1a 11 80       	push   $0x80111a40
80101638:	ff 75 08             	pushl  0x8(%ebp)
8010163b:	e8 08 fe ff ff       	call   80101448 <readsb>
80101640:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101643:	8b 45 0c             	mov    0xc(%ebp),%eax
80101646:	c1 e8 0c             	shr    $0xc,%eax
80101649:	89 c2                	mov    %eax,%edx
8010164b:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101650:	01 c2                	add    %eax,%edx
80101652:	8b 45 08             	mov    0x8(%ebp),%eax
80101655:	83 ec 08             	sub    $0x8,%esp
80101658:	52                   	push   %edx
80101659:	50                   	push   %eax
8010165a:	e8 6f eb ff ff       	call   801001ce <bread>
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101665:	8b 45 0c             	mov    0xc(%ebp),%eax
80101668:	25 ff 0f 00 00       	and    $0xfff,%eax
8010166d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	99                   	cltd   
80101674:	c1 ea 1d             	shr    $0x1d,%edx
80101677:	01 d0                	add    %edx,%eax
80101679:	83 e0 07             	and    $0x7,%eax
8010167c:	29 d0                	sub    %edx,%eax
8010167e:	ba 01 00 00 00       	mov    $0x1,%edx
80101683:	89 c1                	mov    %eax,%ecx
80101685:	d3 e2                	shl    %cl,%edx
80101687:	89 d0                	mov    %edx,%eax
80101689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168f:	8d 50 07             	lea    0x7(%eax),%edx
80101692:	85 c0                	test   %eax,%eax
80101694:	0f 48 c2             	cmovs  %edx,%eax
80101697:	c1 f8 03             	sar    $0x3,%eax
8010169a:	89 c2                	mov    %eax,%edx
8010169c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010169f:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016a4:	0f b6 c0             	movzbl %al,%eax
801016a7:	23 45 ec             	and    -0x14(%ebp),%eax
801016aa:	85 c0                	test   %eax,%eax
801016ac:	75 0d                	jne    801016bb <bfree+0x91>
    panic("freeing free block");
801016ae:	83 ec 0c             	sub    $0xc,%esp
801016b1:	68 e2 87 10 80       	push   $0x801087e2
801016b6:	e8 e5 ee ff ff       	call   801005a0 <panic>
  bp->data[bi/8] &= ~m;
801016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016be:	8d 50 07             	lea    0x7(%eax),%edx
801016c1:	85 c0                	test   %eax,%eax
801016c3:	0f 48 c2             	cmovs  %edx,%eax
801016c6:	c1 f8 03             	sar    $0x3,%eax
801016c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016cc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016d1:	89 d1                	mov    %edx,%ecx
801016d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016d6:	f7 d2                	not    %edx
801016d8:	21 ca                	and    %ecx,%edx
801016da:	89 d1                	mov    %edx,%ecx
801016dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016df:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016e3:	83 ec 0c             	sub    $0xc,%esp
801016e6:	ff 75 f4             	pushl  -0xc(%ebp)
801016e9:	e8 e3 20 00 00       	call   801037d1 <log_write>
801016ee:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016f1:	83 ec 0c             	sub    $0xc,%esp
801016f4:	ff 75 f4             	pushl  -0xc(%ebp)
801016f7:	e8 54 eb ff ff       	call   80100250 <brelse>
801016fc:	83 c4 10             	add    $0x10,%esp
}
801016ff:	90                   	nop
80101700:	c9                   	leave  
80101701:	c3                   	ret    

80101702 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101702:	55                   	push   %ebp
80101703:	89 e5                	mov    %esp,%ebp
80101705:	57                   	push   %edi
80101706:	56                   	push   %esi
80101707:	53                   	push   %ebx
80101708:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010170b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101712:	83 ec 08             	sub    $0x8,%esp
80101715:	68 f5 87 10 80       	push   $0x801087f5
8010171a:	68 60 1a 11 80       	push   $0x80111a60
8010171f:	e8 ba 38 00 00       	call   80104fde <initlock>
80101724:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101727:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010172e:	eb 2d                	jmp    8010175d <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101730:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101733:	89 d0                	mov    %edx,%eax
80101735:	c1 e0 03             	shl    $0x3,%eax
80101738:	01 d0                	add    %edx,%eax
8010173a:	c1 e0 04             	shl    $0x4,%eax
8010173d:	83 c0 30             	add    $0x30,%eax
80101740:	05 60 1a 11 80       	add    $0x80111a60,%eax
80101745:	83 c0 10             	add    $0x10,%eax
80101748:	83 ec 08             	sub    $0x8,%esp
8010174b:	68 fc 87 10 80       	push   $0x801087fc
80101750:	50                   	push   %eax
80101751:	e8 2b 37 00 00       	call   80104e81 <initsleeplock>
80101756:	83 c4 10             	add    $0x10,%esp
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101759:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010175d:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101761:	7e cd                	jle    80101730 <iinit+0x2e>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101763:	83 ec 08             	sub    $0x8,%esp
80101766:	68 40 1a 11 80       	push   $0x80111a40
8010176b:	ff 75 08             	pushl  0x8(%ebp)
8010176e:	e8 d5 fc ff ff       	call   80101448 <readsb>
80101773:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101776:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010177b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010177e:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
80101784:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
8010178a:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
80101790:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
80101796:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
8010179c:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801017a1:	ff 75 d4             	pushl  -0x2c(%ebp)
801017a4:	57                   	push   %edi
801017a5:	56                   	push   %esi
801017a6:	53                   	push   %ebx
801017a7:	51                   	push   %ecx
801017a8:	52                   	push   %edx
801017a9:	50                   	push   %eax
801017aa:	68 04 88 10 80       	push   $0x80108804
801017af:	e8 4c ec ff ff       	call   80100400 <cprintf>
801017b4:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017b7:	90                   	nop
801017b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017bb:	5b                   	pop    %ebx
801017bc:	5e                   	pop    %esi
801017bd:	5f                   	pop    %edi
801017be:	5d                   	pop    %ebp
801017bf:	c3                   	ret    

801017c0 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017c0:	55                   	push   %ebp
801017c1:	89 e5                	mov    %esp,%ebp
801017c3:	83 ec 28             	sub    $0x28,%esp
801017c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c9:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017cd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017d4:	e9 9e 00 00 00       	jmp    80101877 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801017d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017dc:	c1 e8 03             	shr    $0x3,%eax
801017df:	89 c2                	mov    %eax,%edx
801017e1:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801017e6:	01 d0                	add    %edx,%eax
801017e8:	83 ec 08             	sub    $0x8,%esp
801017eb:	50                   	push   %eax
801017ec:	ff 75 08             	pushl  0x8(%ebp)
801017ef:	e8 da e9 ff ff       	call   801001ce <bread>
801017f4:	83 c4 10             	add    $0x10,%esp
801017f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	8d 50 5c             	lea    0x5c(%eax),%edx
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	83 e0 07             	and    $0x7,%eax
80101806:	c1 e0 06             	shl    $0x6,%eax
80101809:	01 d0                	add    %edx,%eax
8010180b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010180e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101811:	0f b7 00             	movzwl (%eax),%eax
80101814:	66 85 c0             	test   %ax,%ax
80101817:	75 4c                	jne    80101865 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101819:	83 ec 04             	sub    $0x4,%esp
8010181c:	6a 40                	push   $0x40
8010181e:	6a 00                	push   $0x0
80101820:	ff 75 ec             	pushl  -0x14(%ebp)
80101823:	e8 4f 3a 00 00       	call   80105277 <memset>
80101828:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010182b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182e:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101832:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101835:	83 ec 0c             	sub    $0xc,%esp
80101838:	ff 75 f0             	pushl  -0x10(%ebp)
8010183b:	e8 91 1f 00 00       	call   801037d1 <log_write>
80101840:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101843:	83 ec 0c             	sub    $0xc,%esp
80101846:	ff 75 f0             	pushl  -0x10(%ebp)
80101849:	e8 02 ea ff ff       	call   80100250 <brelse>
8010184e:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101854:	83 ec 08             	sub    $0x8,%esp
80101857:	50                   	push   %eax
80101858:	ff 75 08             	pushl  0x8(%ebp)
8010185b:	e8 f8 00 00 00       	call   80101958 <iget>
80101860:	83 c4 10             	add    $0x10,%esp
80101863:	eb 30                	jmp    80101895 <ialloc+0xd5>
    }
    brelse(bp);
80101865:	83 ec 0c             	sub    $0xc,%esp
80101868:	ff 75 f0             	pushl  -0x10(%ebp)
8010186b:	e8 e0 e9 ff ff       	call   80100250 <brelse>
80101870:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101873:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101877:	8b 15 48 1a 11 80    	mov    0x80111a48,%edx
8010187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101880:	39 c2                	cmp    %eax,%edx
80101882:	0f 87 51 ff ff ff    	ja     801017d9 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101888:	83 ec 0c             	sub    $0xc,%esp
8010188b:	68 57 88 10 80       	push   $0x80108857
80101890:	e8 0b ed ff ff       	call   801005a0 <panic>
}
80101895:	c9                   	leave  
80101896:	c3                   	ret    

80101897 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101897:	55                   	push   %ebp
80101898:	89 e5                	mov    %esp,%ebp
8010189a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 40 04             	mov    0x4(%eax),%eax
801018a3:	c1 e8 03             	shr    $0x3,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	8b 00                	mov    (%eax),%eax
801018b4:	83 ec 08             	sub    $0x8,%esp
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 10 e9 ff ff       	call   801001ce <bread>
801018be:	83 c4 10             	add    $0x10,%esp
801018c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 04             	mov    0x4(%eax),%eax
801018d0:	83 e0 07             	and    $0x7,%eax
801018d3:	c1 e0 06             	shl    $0x6,%eax
801018d6:	01 d0                	add    %edx,%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	8b 50 58             	mov    0x58(%eax),%edx
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8d 50 5c             	lea    0x5c(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	83 c0 0c             	add    $0xc,%eax
8010192a:	83 ec 04             	sub    $0x4,%esp
8010192d:	6a 34                	push   $0x34
8010192f:	52                   	push   %edx
80101930:	50                   	push   %eax
80101931:	e8 00 3a 00 00       	call   80105336 <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 8d 1e 00 00       	call   801037d1 <log_write>
80101944:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	ff 75 f4             	pushl  -0xc(%ebp)
8010194d:	e8 fe e8 ff ff       	call   80100250 <brelse>
80101952:	83 c4 10             	add    $0x10,%esp
}
80101955:	90                   	nop
80101956:	c9                   	leave  
80101957:	c3                   	ret    

80101958 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101958:	55                   	push   %ebp
80101959:	89 e5                	mov    %esp,%ebp
8010195b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010195e:	83 ec 0c             	sub    $0xc,%esp
80101961:	68 60 1a 11 80       	push   $0x80111a60
80101966:	e8 95 36 00 00       	call   80105000 <acquire>
8010196b:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010196e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101975:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
8010197c:	eb 60                	jmp    801019de <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 40 08             	mov    0x8(%eax),%eax
80101984:	85 c0                	test   %eax,%eax
80101986:	7e 39                	jle    801019c1 <iget+0x69>
80101988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198b:	8b 00                	mov    (%eax),%eax
8010198d:	3b 45 08             	cmp    0x8(%ebp),%eax
80101990:	75 2f                	jne    801019c1 <iget+0x69>
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	8b 40 04             	mov    0x4(%eax),%eax
80101998:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010199b:	75 24                	jne    801019c1 <iget+0x69>
      ip->ref++;
8010199d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a0:	8b 40 08             	mov    0x8(%eax),%eax
801019a3:	8d 50 01             	lea    0x1(%eax),%edx
801019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a9:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019ac:	83 ec 0c             	sub    $0xc,%esp
801019af:	68 60 1a 11 80       	push   $0x80111a60
801019b4:	e8 b5 36 00 00       	call   8010506e <release>
801019b9:	83 c4 10             	add    $0x10,%esp
      return ip;
801019bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bf:	eb 77                	jmp    80101a38 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c5:	75 10                	jne    801019d7 <iget+0x7f>
801019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ca:	8b 40 08             	mov    0x8(%eax),%eax
801019cd:	85 c0                	test   %eax,%eax
801019cf:	75 06                	jne    801019d7 <iget+0x7f>
      empty = ip;
801019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019d7:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019de:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
801019e5:	72 97                	jb     8010197e <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019eb:	75 0d                	jne    801019fa <iget+0xa2>
    panic("iget: no inodes");
801019ed:	83 ec 0c             	sub    $0xc,%esp
801019f0:	68 69 88 10 80       	push   $0x80108869
801019f5:	e8 a6 eb ff ff       	call   801005a0 <panic>

  ip = empty;
801019fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a03:	8b 55 08             	mov    0x8(%ebp),%edx
80101a06:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a0e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a14:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a25:	83 ec 0c             	sub    $0xc,%esp
80101a28:	68 60 1a 11 80       	push   $0x80111a60
80101a2d:	e8 3c 36 00 00       	call   8010506e <release>
80101a32:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a38:	c9                   	leave  
80101a39:	c3                   	ret    

80101a3a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a3a:	55                   	push   %ebp
80101a3b:	89 e5                	mov    %esp,%ebp
80101a3d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a40:	83 ec 0c             	sub    $0xc,%esp
80101a43:	68 60 1a 11 80       	push   $0x80111a60
80101a48:	e8 b3 35 00 00       	call   80105000 <acquire>
80101a4d:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a50:	8b 45 08             	mov    0x8(%ebp),%eax
80101a53:	8b 40 08             	mov    0x8(%eax),%eax
80101a56:	8d 50 01             	lea    0x1(%eax),%edx
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a5f:	83 ec 0c             	sub    $0xc,%esp
80101a62:	68 60 1a 11 80       	push   $0x80111a60
80101a67:	e8 02 36 00 00       	call   8010506e <release>
80101a6c:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a72:	c9                   	leave  
80101a73:	c3                   	ret    

80101a74 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a74:	55                   	push   %ebp
80101a75:	89 e5                	mov    %esp,%ebp
80101a77:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a7a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a7e:	74 0a                	je     80101a8a <ilock+0x16>
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	8b 40 08             	mov    0x8(%eax),%eax
80101a86:	85 c0                	test   %eax,%eax
80101a88:	7f 0d                	jg     80101a97 <ilock+0x23>
    panic("ilock");
80101a8a:	83 ec 0c             	sub    $0xc,%esp
80101a8d:	68 79 88 10 80       	push   $0x80108879
80101a92:	e8 09 eb ff ff       	call   801005a0 <panic>

  acquiresleep(&ip->lock);
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	83 c0 0c             	add    $0xc,%eax
80101a9d:	83 ec 0c             	sub    $0xc,%esp
80101aa0:	50                   	push   %eax
80101aa1:	e8 17 34 00 00       	call   80104ebd <acquiresleep>
80101aa6:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aac:	8b 40 4c             	mov    0x4c(%eax),%eax
80101aaf:	85 c0                	test   %eax,%eax
80101ab1:	0f 85 cd 00 00 00    	jne    80101b84 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	8b 40 04             	mov    0x4(%eax),%eax
80101abd:	c1 e8 03             	shr    $0x3,%eax
80101ac0:	89 c2                	mov    %eax,%edx
80101ac2:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101ac7:	01 c2                	add    %eax,%edx
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	8b 00                	mov    (%eax),%eax
80101ace:	83 ec 08             	sub    $0x8,%esp
80101ad1:	52                   	push   %edx
80101ad2:	50                   	push   %eax
80101ad3:	e8 f6 e6 ff ff       	call   801001ce <bread>
80101ad8:	83 c4 10             	add    $0x10,%esp
80101adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae1:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 04             	mov    0x4(%eax),%eax
80101aea:	83 e0 07             	and    $0x7,%eax
80101aed:	c1 e0 06             	shl    $0x6,%eax
80101af0:	01 d0                	add    %edx,%eax
80101af2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af8:	0f b7 10             	movzwl (%eax),%edx
80101afb:	8b 45 08             	mov    0x8(%ebp),%eax
80101afe:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b05:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b13:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b21:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b25:	8b 45 08             	mov    0x8(%ebp),%eax
80101b28:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2f:	8b 50 08             	mov    0x8(%eax),%edx
80101b32:	8b 45 08             	mov    0x8(%ebp),%eax
80101b35:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	8d 50 0c             	lea    0xc(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 5c             	add    $0x5c,%eax
80101b44:	83 ec 04             	sub    $0x4,%esp
80101b47:	6a 34                	push   $0x34
80101b49:	52                   	push   %edx
80101b4a:	50                   	push   %eax
80101b4b:	e8 e6 37 00 00       	call   80105336 <memmove>
80101b50:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b53:	83 ec 0c             	sub    $0xc,%esp
80101b56:	ff 75 f4             	pushl  -0xc(%ebp)
80101b59:	e8 f2 e6 ff ff       	call   80100250 <brelse>
80101b5e:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b72:	66 85 c0             	test   %ax,%ax
80101b75:	75 0d                	jne    80101b84 <ilock+0x110>
      panic("ilock: no type");
80101b77:	83 ec 0c             	sub    $0xc,%esp
80101b7a:	68 7f 88 10 80       	push   $0x8010887f
80101b7f:	e8 1c ea ff ff       	call   801005a0 <panic>
  }
}
80101b84:	90                   	nop
80101b85:	c9                   	leave  
80101b86:	c3                   	ret    

80101b87 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b87:	55                   	push   %ebp
80101b88:	89 e5                	mov    %esp,%ebp
80101b8a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b8d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b91:	74 20                	je     80101bb3 <iunlock+0x2c>
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	83 c0 0c             	add    $0xc,%eax
80101b99:	83 ec 0c             	sub    $0xc,%esp
80101b9c:	50                   	push   %eax
80101b9d:	e8 cd 33 00 00       	call   80104f6f <holdingsleep>
80101ba2:	83 c4 10             	add    $0x10,%esp
80101ba5:	85 c0                	test   %eax,%eax
80101ba7:	74 0a                	je     80101bb3 <iunlock+0x2c>
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	8b 40 08             	mov    0x8(%eax),%eax
80101baf:	85 c0                	test   %eax,%eax
80101bb1:	7f 0d                	jg     80101bc0 <iunlock+0x39>
    panic("iunlock");
80101bb3:	83 ec 0c             	sub    $0xc,%esp
80101bb6:	68 8e 88 10 80       	push   $0x8010888e
80101bbb:	e8 e0 e9 ff ff       	call   801005a0 <panic>

  releasesleep(&ip->lock);
80101bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc3:	83 c0 0c             	add    $0xc,%eax
80101bc6:	83 ec 0c             	sub    $0xc,%esp
80101bc9:	50                   	push   %eax
80101bca:	e8 52 33 00 00       	call   80104f21 <releasesleep>
80101bcf:	83 c4 10             	add    $0x10,%esp
}
80101bd2:	90                   	nop
80101bd3:	c9                   	leave  
80101bd4:	c3                   	ret    

80101bd5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bd5:	55                   	push   %ebp
80101bd6:	89 e5                	mov    %esp,%ebp
80101bd8:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	83 c0 0c             	add    $0xc,%eax
80101be1:	83 ec 0c             	sub    $0xc,%esp
80101be4:	50                   	push   %eax
80101be5:	e8 d3 32 00 00       	call   80104ebd <acquiresleep>
80101bea:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101bed:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bf3:	85 c0                	test   %eax,%eax
80101bf5:	74 6a                	je     80101c61 <iput+0x8c>
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101bfe:	66 85 c0             	test   %ax,%ax
80101c01:	75 5e                	jne    80101c61 <iput+0x8c>
    acquire(&icache.lock);
80101c03:	83 ec 0c             	sub    $0xc,%esp
80101c06:	68 60 1a 11 80       	push   $0x80111a60
80101c0b:	e8 f0 33 00 00       	call   80105000 <acquire>
80101c10:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	8b 40 08             	mov    0x8(%eax),%eax
80101c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	68 60 1a 11 80       	push   $0x80111a60
80101c24:	e8 45 34 00 00       	call   8010506e <release>
80101c29:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c2c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c30:	75 2f                	jne    80101c61 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c32:	83 ec 0c             	sub    $0xc,%esp
80101c35:	ff 75 08             	pushl  0x8(%ebp)
80101c38:	e8 b2 01 00 00       	call   80101def <itrunc>
80101c3d:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c49:	83 ec 0c             	sub    $0xc,%esp
80101c4c:	ff 75 08             	pushl  0x8(%ebp)
80101c4f:	e8 43 fc ff ff       	call   80101897 <iupdate>
80101c54:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c61:	8b 45 08             	mov    0x8(%ebp),%eax
80101c64:	83 c0 0c             	add    $0xc,%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 b1 32 00 00       	call   80104f21 <releasesleep>
80101c70:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c73:	83 ec 0c             	sub    $0xc,%esp
80101c76:	68 60 1a 11 80       	push   $0x80111a60
80101c7b:	e8 80 33 00 00       	call   80105000 <acquire>
80101c80:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c83:	8b 45 08             	mov    0x8(%ebp),%eax
80101c86:	8b 40 08             	mov    0x8(%eax),%eax
80101c89:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c92:	83 ec 0c             	sub    $0xc,%esp
80101c95:	68 60 1a 11 80       	push   $0x80111a60
80101c9a:	e8 cf 33 00 00       	call   8010506e <release>
80101c9f:	83 c4 10             	add    $0x10,%esp
}
80101ca2:	90                   	nop
80101ca3:	c9                   	leave  
80101ca4:	c3                   	ret    

80101ca5 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ca5:	55                   	push   %ebp
80101ca6:	89 e5                	mov    %esp,%ebp
80101ca8:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cab:	83 ec 0c             	sub    $0xc,%esp
80101cae:	ff 75 08             	pushl  0x8(%ebp)
80101cb1:	e8 d1 fe ff ff       	call   80101b87 <iunlock>
80101cb6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cb9:	83 ec 0c             	sub    $0xc,%esp
80101cbc:	ff 75 08             	pushl  0x8(%ebp)
80101cbf:	e8 11 ff ff ff       	call   80101bd5 <iput>
80101cc4:	83 c4 10             	add    $0x10,%esp
}
80101cc7:	90                   	nop
80101cc8:	c9                   	leave  
80101cc9:	c3                   	ret    

80101cca <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cca:	55                   	push   %ebp
80101ccb:	89 e5                	mov    %esp,%ebp
80101ccd:	53                   	push   %ebx
80101cce:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cd1:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cd5:	77 42                	ja     80101d19 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cda:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cdd:	83 c2 14             	add    $0x14,%edx
80101ce0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ce7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ceb:	75 24                	jne    80101d11 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 00                	mov    (%eax),%eax
80101cf2:	83 ec 0c             	sub    $0xc,%esp
80101cf5:	50                   	push   %eax
80101cf6:	e8 e3 f7 ff ff       	call   801014de <balloc>
80101cfb:	83 c4 10             	add    $0x10,%esp
80101cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d07:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d0d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d14:	e9 d1 00 00 00       	jmp    80101dea <bmap+0x120>
  }
  bn -= NDIRECT;
80101d19:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d1d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d21:	0f 87 b6 00 00 00    	ja     80101ddd <bmap+0x113>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d37:	75 20                	jne    80101d59 <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d39:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3c:	8b 00                	mov    (%eax),%eax
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	50                   	push   %eax
80101d42:	e8 97 f7 ff ff       	call   801014de <balloc>
80101d47:	83 c4 10             	add    $0x10,%esp
80101d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d53:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	8b 00                	mov    (%eax),%eax
80101d5e:	83 ec 08             	sub    $0x8,%esp
80101d61:	ff 75 f4             	pushl  -0xc(%ebp)
80101d64:	50                   	push   %eax
80101d65:	e8 64 e4 ff ff       	call   801001ce <bread>
80101d6a:	83 c4 10             	add    $0x10,%esp
80101d6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d73:	83 c0 5c             	add    $0x5c,%eax
80101d76:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d86:	01 d0                	add    %edx,%eax
80101d88:	8b 00                	mov    (%eax),%eax
80101d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d91:	75 37                	jne    80101dca <bmap+0x100>
      a[bn] = addr = balloc(ip->dev);
80101d93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101da3:	8b 45 08             	mov    0x8(%ebp),%eax
80101da6:	8b 00                	mov    (%eax),%eax
80101da8:	83 ec 0c             	sub    $0xc,%esp
80101dab:	50                   	push   %eax
80101dac:	e8 2d f7 ff ff       	call   801014de <balloc>
80101db1:	83 c4 10             	add    $0x10,%esp
80101db4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dba:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101dbc:	83 ec 0c             	sub    $0xc,%esp
80101dbf:	ff 75 f0             	pushl  -0x10(%ebp)
80101dc2:	e8 0a 1a 00 00       	call   801037d1 <log_write>
80101dc7:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101dca:	83 ec 0c             	sub    $0xc,%esp
80101dcd:	ff 75 f0             	pushl  -0x10(%ebp)
80101dd0:	e8 7b e4 ff ff       	call   80100250 <brelse>
80101dd5:	83 c4 10             	add    $0x10,%esp
    return addr;
80101dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ddb:	eb 0d                	jmp    80101dea <bmap+0x120>
  }

  panic("bmap: out of range");
80101ddd:	83 ec 0c             	sub    $0xc,%esp
80101de0:	68 96 88 10 80       	push   $0x80108896
80101de5:	e8 b6 e7 ff ff       	call   801005a0 <panic>
}
80101dea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ded:	c9                   	leave  
80101dee:	c3                   	ret    

80101def <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101def:	55                   	push   %ebp
80101df0:	89 e5                	mov    %esp,%ebp
80101df2:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101df5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101dfc:	eb 45                	jmp    80101e43 <itrunc+0x54>
    if(ip->addrs[i]){
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e04:	83 c2 14             	add    $0x14,%edx
80101e07:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e0b:	85 c0                	test   %eax,%eax
80101e0d:	74 30                	je     80101e3f <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e15:	83 c2 14             	add    $0x14,%edx
80101e18:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e1c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e1f:	8b 12                	mov    (%edx),%edx
80101e21:	83 ec 08             	sub    $0x8,%esp
80101e24:	50                   	push   %eax
80101e25:	52                   	push   %edx
80101e26:	e8 ff f7 ff ff       	call   8010162a <bfree>
80101e2b:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e34:	83 c2 14             	add    $0x14,%edx
80101e37:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e3e:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e43:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e47:	7e b5                	jle    80101dfe <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e52:	85 c0                	test   %eax,%eax
80101e54:	0f 84 aa 00 00 00    	je     80101f04 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e63:	8b 45 08             	mov    0x8(%ebp),%eax
80101e66:	8b 00                	mov    (%eax),%eax
80101e68:	83 ec 08             	sub    $0x8,%esp
80101e6b:	52                   	push   %edx
80101e6c:	50                   	push   %eax
80101e6d:	e8 5c e3 ff ff       	call   801001ce <bread>
80101e72:	83 c4 10             	add    $0x10,%esp
80101e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e7b:	83 c0 5c             	add    $0x5c,%eax
80101e7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e88:	eb 3c                	jmp    80101ec6 <itrunc+0xd7>
      if(a[j])
80101e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e97:	01 d0                	add    %edx,%eax
80101e99:	8b 00                	mov    (%eax),%eax
80101e9b:	85 c0                	test   %eax,%eax
80101e9d:	74 23                	je     80101ec2 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eac:	01 d0                	add    %edx,%eax
80101eae:	8b 00                	mov    (%eax),%eax
80101eb0:	8b 55 08             	mov    0x8(%ebp),%edx
80101eb3:	8b 12                	mov    (%edx),%edx
80101eb5:	83 ec 08             	sub    $0x8,%esp
80101eb8:	50                   	push   %eax
80101eb9:	52                   	push   %edx
80101eba:	e8 6b f7 ff ff       	call   8010162a <bfree>
80101ebf:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ec2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec9:	83 f8 7f             	cmp    $0x7f,%eax
80101ecc:	76 bc                	jbe    80101e8a <itrunc+0x9b>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ece:	83 ec 0c             	sub    $0xc,%esp
80101ed1:	ff 75 ec             	pushl  -0x14(%ebp)
80101ed4:	e8 77 e3 ff ff       	call   80100250 <brelse>
80101ed9:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ee5:	8b 55 08             	mov    0x8(%ebp),%edx
80101ee8:	8b 12                	mov    (%edx),%edx
80101eea:	83 ec 08             	sub    $0x8,%esp
80101eed:	50                   	push   %eax
80101eee:	52                   	push   %edx
80101eef:	e8 36 f7 ff ff       	call   8010162a <bfree>
80101ef4:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f01:	00 00 00 
  }

  ip->size = 0;
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f0e:	83 ec 0c             	sub    $0xc,%esp
80101f11:	ff 75 08             	pushl  0x8(%ebp)
80101f14:	e8 7e f9 ff ff       	call   80101897 <iupdate>
80101f19:	83 c4 10             	add    $0x10,%esp
}
80101f1c:	90                   	nop
80101f1d:	c9                   	leave  
80101f1e:	c3                   	ret    

80101f1f <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f1f:	55                   	push   %ebp
80101f20:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	8b 00                	mov    (%eax),%eax
80101f27:	89 c2                	mov    %eax,%edx
80101f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2c:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f32:	8b 50 04             	mov    0x4(%eax),%edx
80101f35:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f38:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f42:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f45:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f48:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4b:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f52:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	8b 50 58             	mov    0x58(%eax),%edx
80101f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5f:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f62:	90                   	nop
80101f63:	5d                   	pop    %ebp
80101f64:	c3                   	ret    

80101f65 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f65:	55                   	push   %ebp
80101f66:	89 e5                	mov    %esp,%ebp
80101f68:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f72:	66 83 f8 03          	cmp    $0x3,%ax
80101f76:	75 5c                	jne    80101fd4 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f78:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f7f:	66 85 c0             	test   %ax,%ax
80101f82:	78 20                	js     80101fa4 <readi+0x3f>
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f8b:	66 83 f8 09          	cmp    $0x9,%ax
80101f8f:	7f 13                	jg     80101fa4 <readi+0x3f>
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f98:	98                   	cwtl   
80101f99:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101fa0:	85 c0                	test   %eax,%eax
80101fa2:	75 0a                	jne    80101fae <readi+0x49>
      return -1;
80101fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fa9:	e9 0c 01 00 00       	jmp    801020ba <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fae:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fb5:	98                   	cwtl   
80101fb6:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101fbd:	8b 55 14             	mov    0x14(%ebp),%edx
80101fc0:	83 ec 04             	sub    $0x4,%esp
80101fc3:	52                   	push   %edx
80101fc4:	ff 75 0c             	pushl  0xc(%ebp)
80101fc7:	ff 75 08             	pushl  0x8(%ebp)
80101fca:	ff d0                	call   *%eax
80101fcc:	83 c4 10             	add    $0x10,%esp
80101fcf:	e9 e6 00 00 00       	jmp    801020ba <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd7:	8b 40 58             	mov    0x58(%eax),%eax
80101fda:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fdd:	72 0d                	jb     80101fec <readi+0x87>
80101fdf:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe5:	01 d0                	add    %edx,%eax
80101fe7:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fea:	73 0a                	jae    80101ff6 <readi+0x91>
    return -1;
80101fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff1:	e9 c4 00 00 00       	jmp    801020ba <readi+0x155>
  if(off + n > ip->size)
80101ff6:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff9:	8b 45 14             	mov    0x14(%ebp),%eax
80101ffc:	01 c2                	add    %eax,%edx
80101ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80102001:	8b 40 58             	mov    0x58(%eax),%eax
80102004:	39 c2                	cmp    %eax,%edx
80102006:	76 0c                	jbe    80102014 <readi+0xaf>
    n = ip->size - off;
80102008:	8b 45 08             	mov    0x8(%ebp),%eax
8010200b:	8b 40 58             	mov    0x58(%eax),%eax
8010200e:	2b 45 10             	sub    0x10(%ebp),%eax
80102011:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102014:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010201b:	e9 8b 00 00 00       	jmp    801020ab <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102020:	8b 45 10             	mov    0x10(%ebp),%eax
80102023:	c1 e8 09             	shr    $0x9,%eax
80102026:	83 ec 08             	sub    $0x8,%esp
80102029:	50                   	push   %eax
8010202a:	ff 75 08             	pushl  0x8(%ebp)
8010202d:	e8 98 fc ff ff       	call   80101cca <bmap>
80102032:	83 c4 10             	add    $0x10,%esp
80102035:	89 c2                	mov    %eax,%edx
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 00                	mov    (%eax),%eax
8010203c:	83 ec 08             	sub    $0x8,%esp
8010203f:	52                   	push   %edx
80102040:	50                   	push   %eax
80102041:	e8 88 e1 ff ff       	call   801001ce <bread>
80102046:	83 c4 10             	add    $0x10,%esp
80102049:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010204c:	8b 45 10             	mov    0x10(%ebp),%eax
8010204f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102054:	ba 00 02 00 00       	mov    $0x200,%edx
80102059:	29 c2                	sub    %eax,%edx
8010205b:	8b 45 14             	mov    0x14(%ebp),%eax
8010205e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102061:	39 c2                	cmp    %eax,%edx
80102063:	0f 46 c2             	cmovbe %edx,%eax
80102066:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102069:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010206c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010206f:	8b 45 10             	mov    0x10(%ebp),%eax
80102072:	25 ff 01 00 00       	and    $0x1ff,%eax
80102077:	01 d0                	add    %edx,%eax
80102079:	83 ec 04             	sub    $0x4,%esp
8010207c:	ff 75 ec             	pushl  -0x14(%ebp)
8010207f:	50                   	push   %eax
80102080:	ff 75 0c             	pushl  0xc(%ebp)
80102083:	e8 ae 32 00 00       	call   80105336 <memmove>
80102088:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010208b:	83 ec 0c             	sub    $0xc,%esp
8010208e:	ff 75 f0             	pushl  -0x10(%ebp)
80102091:	e8 ba e1 ff ff       	call   80100250 <brelse>
80102096:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102099:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010209f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a2:	01 45 10             	add    %eax,0x10(%ebp)
801020a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a8:	01 45 0c             	add    %eax,0xc(%ebp)
801020ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ae:	3b 45 14             	cmp    0x14(%ebp),%eax
801020b1:	0f 82 69 ff ff ff    	jb     80102020 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020b7:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020ba:	c9                   	leave  
801020bb:	c3                   	ret    

801020bc <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020bc:	55                   	push   %ebp
801020bd:	89 e5                	mov    %esp,%ebp
801020bf:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020c9:	66 83 f8 03          	cmp    $0x3,%ax
801020cd:	75 5c                	jne    8010212b <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020cf:	8b 45 08             	mov    0x8(%ebp),%eax
801020d2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020d6:	66 85 c0             	test   %ax,%ax
801020d9:	78 20                	js     801020fb <writei+0x3f>
801020db:	8b 45 08             	mov    0x8(%ebp),%eax
801020de:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020e2:	66 83 f8 09          	cmp    $0x9,%ax
801020e6:	7f 13                	jg     801020fb <writei+0x3f>
801020e8:	8b 45 08             	mov    0x8(%ebp),%eax
801020eb:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ef:	98                   	cwtl   
801020f0:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
801020f7:	85 c0                	test   %eax,%eax
801020f9:	75 0a                	jne    80102105 <writei+0x49>
      return -1;
801020fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102100:	e9 3d 01 00 00       	jmp    80102242 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102105:	8b 45 08             	mov    0x8(%ebp),%eax
80102108:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010210c:	98                   	cwtl   
8010210d:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80102114:	8b 55 14             	mov    0x14(%ebp),%edx
80102117:	83 ec 04             	sub    $0x4,%esp
8010211a:	52                   	push   %edx
8010211b:	ff 75 0c             	pushl  0xc(%ebp)
8010211e:	ff 75 08             	pushl  0x8(%ebp)
80102121:	ff d0                	call   *%eax
80102123:	83 c4 10             	add    $0x10,%esp
80102126:	e9 17 01 00 00       	jmp    80102242 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010212b:	8b 45 08             	mov    0x8(%ebp),%eax
8010212e:	8b 40 58             	mov    0x58(%eax),%eax
80102131:	3b 45 10             	cmp    0x10(%ebp),%eax
80102134:	72 0d                	jb     80102143 <writei+0x87>
80102136:	8b 55 10             	mov    0x10(%ebp),%edx
80102139:	8b 45 14             	mov    0x14(%ebp),%eax
8010213c:	01 d0                	add    %edx,%eax
8010213e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102141:	73 0a                	jae    8010214d <writei+0x91>
    return -1;
80102143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102148:	e9 f5 00 00 00       	jmp    80102242 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010214d:	8b 55 10             	mov    0x10(%ebp),%edx
80102150:	8b 45 14             	mov    0x14(%ebp),%eax
80102153:	01 d0                	add    %edx,%eax
80102155:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010215a:	76 0a                	jbe    80102166 <writei+0xaa>
    return -1;
8010215c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102161:	e9 dc 00 00 00       	jmp    80102242 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010216d:	e9 99 00 00 00       	jmp    8010220b <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102172:	8b 45 10             	mov    0x10(%ebp),%eax
80102175:	c1 e8 09             	shr    $0x9,%eax
80102178:	83 ec 08             	sub    $0x8,%esp
8010217b:	50                   	push   %eax
8010217c:	ff 75 08             	pushl  0x8(%ebp)
8010217f:	e8 46 fb ff ff       	call   80101cca <bmap>
80102184:	83 c4 10             	add    $0x10,%esp
80102187:	89 c2                	mov    %eax,%edx
80102189:	8b 45 08             	mov    0x8(%ebp),%eax
8010218c:	8b 00                	mov    (%eax),%eax
8010218e:	83 ec 08             	sub    $0x8,%esp
80102191:	52                   	push   %edx
80102192:	50                   	push   %eax
80102193:	e8 36 e0 ff ff       	call   801001ce <bread>
80102198:	83 c4 10             	add    $0x10,%esp
8010219b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010219e:	8b 45 10             	mov    0x10(%ebp),%eax
801021a1:	25 ff 01 00 00       	and    $0x1ff,%eax
801021a6:	ba 00 02 00 00       	mov    $0x200,%edx
801021ab:	29 c2                	sub    %eax,%edx
801021ad:	8b 45 14             	mov    0x14(%ebp),%eax
801021b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021b3:	39 c2                	cmp    %eax,%edx
801021b5:	0f 46 c2             	cmovbe %edx,%eax
801021b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021be:	8d 50 5c             	lea    0x5c(%eax),%edx
801021c1:	8b 45 10             	mov    0x10(%ebp),%eax
801021c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c9:	01 d0                	add    %edx,%eax
801021cb:	83 ec 04             	sub    $0x4,%esp
801021ce:	ff 75 ec             	pushl  -0x14(%ebp)
801021d1:	ff 75 0c             	pushl  0xc(%ebp)
801021d4:	50                   	push   %eax
801021d5:	e8 5c 31 00 00       	call   80105336 <memmove>
801021da:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021dd:	83 ec 0c             	sub    $0xc,%esp
801021e0:	ff 75 f0             	pushl  -0x10(%ebp)
801021e3:	e8 e9 15 00 00       	call   801037d1 <log_write>
801021e8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021eb:	83 ec 0c             	sub    $0xc,%esp
801021ee:	ff 75 f0             	pushl  -0x10(%ebp)
801021f1:	e8 5a e0 ff ff       	call   80100250 <brelse>
801021f6:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021fc:	01 45 f4             	add    %eax,-0xc(%ebp)
801021ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102202:	01 45 10             	add    %eax,0x10(%ebp)
80102205:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102208:	01 45 0c             	add    %eax,0xc(%ebp)
8010220b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102211:	0f 82 5b ff ff ff    	jb     80102172 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102217:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010221b:	74 22                	je     8010223f <writei+0x183>
8010221d:	8b 45 08             	mov    0x8(%ebp),%eax
80102220:	8b 40 58             	mov    0x58(%eax),%eax
80102223:	3b 45 10             	cmp    0x10(%ebp),%eax
80102226:	73 17                	jae    8010223f <writei+0x183>
    ip->size = off;
80102228:	8b 45 08             	mov    0x8(%ebp),%eax
8010222b:	8b 55 10             	mov    0x10(%ebp),%edx
8010222e:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102231:	83 ec 0c             	sub    $0xc,%esp
80102234:	ff 75 08             	pushl  0x8(%ebp)
80102237:	e8 5b f6 ff ff       	call   80101897 <iupdate>
8010223c:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010223f:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102242:	c9                   	leave  
80102243:	c3                   	ret    

80102244 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102244:	55                   	push   %ebp
80102245:	89 e5                	mov    %esp,%ebp
80102247:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010224a:	83 ec 04             	sub    $0x4,%esp
8010224d:	6a 0e                	push   $0xe
8010224f:	ff 75 0c             	pushl  0xc(%ebp)
80102252:	ff 75 08             	pushl  0x8(%ebp)
80102255:	e8 72 31 00 00       	call   801053cc <strncmp>
8010225a:	83 c4 10             	add    $0x10,%esp
}
8010225d:	c9                   	leave  
8010225e:	c3                   	ret    

8010225f <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010225f:	55                   	push   %ebp
80102260:	89 e5                	mov    %esp,%ebp
80102262:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102265:	8b 45 08             	mov    0x8(%ebp),%eax
80102268:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010226c:	66 83 f8 01          	cmp    $0x1,%ax
80102270:	74 0d                	je     8010227f <dirlookup+0x20>
    panic("dirlookup not DIR");
80102272:	83 ec 0c             	sub    $0xc,%esp
80102275:	68 a9 88 10 80       	push   $0x801088a9
8010227a:	e8 21 e3 ff ff       	call   801005a0 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010227f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102286:	eb 7b                	jmp    80102303 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102288:	6a 10                	push   $0x10
8010228a:	ff 75 f4             	pushl  -0xc(%ebp)
8010228d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102290:	50                   	push   %eax
80102291:	ff 75 08             	pushl  0x8(%ebp)
80102294:	e8 cc fc ff ff       	call   80101f65 <readi>
80102299:	83 c4 10             	add    $0x10,%esp
8010229c:	83 f8 10             	cmp    $0x10,%eax
8010229f:	74 0d                	je     801022ae <dirlookup+0x4f>
      panic("dirlookup read");
801022a1:	83 ec 0c             	sub    $0xc,%esp
801022a4:	68 bb 88 10 80       	push   $0x801088bb
801022a9:	e8 f2 e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
801022ae:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022b2:	66 85 c0             	test   %ax,%ax
801022b5:	74 47                	je     801022fe <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022b7:	83 ec 08             	sub    $0x8,%esp
801022ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bd:	83 c0 02             	add    $0x2,%eax
801022c0:	50                   	push   %eax
801022c1:	ff 75 0c             	pushl  0xc(%ebp)
801022c4:	e8 7b ff ff ff       	call   80102244 <namecmp>
801022c9:	83 c4 10             	add    $0x10,%esp
801022cc:	85 c0                	test   %eax,%eax
801022ce:	75 2f                	jne    801022ff <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022d4:	74 08                	je     801022de <dirlookup+0x7f>
        *poff = off;
801022d6:	8b 45 10             	mov    0x10(%ebp),%eax
801022d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022dc:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022de:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022e2:	0f b7 c0             	movzwl %ax,%eax
801022e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022e8:	8b 45 08             	mov    0x8(%ebp),%eax
801022eb:	8b 00                	mov    (%eax),%eax
801022ed:	83 ec 08             	sub    $0x8,%esp
801022f0:	ff 75 f0             	pushl  -0x10(%ebp)
801022f3:	50                   	push   %eax
801022f4:	e8 5f f6 ff ff       	call   80101958 <iget>
801022f9:	83 c4 10             	add    $0x10,%esp
801022fc:	eb 19                	jmp    80102317 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
801022fe:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801022ff:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	8b 40 58             	mov    0x58(%eax),%eax
80102309:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010230c:	0f 87 76 ff ff ff    	ja     80102288 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102312:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102317:	c9                   	leave  
80102318:	c3                   	ret    

80102319 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102319:	55                   	push   %ebp
8010231a:	89 e5                	mov    %esp,%ebp
8010231c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010231f:	83 ec 04             	sub    $0x4,%esp
80102322:	6a 00                	push   $0x0
80102324:	ff 75 0c             	pushl  0xc(%ebp)
80102327:	ff 75 08             	pushl  0x8(%ebp)
8010232a:	e8 30 ff ff ff       	call   8010225f <dirlookup>
8010232f:	83 c4 10             	add    $0x10,%esp
80102332:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102335:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102339:	74 18                	je     80102353 <dirlink+0x3a>
    iput(ip);
8010233b:	83 ec 0c             	sub    $0xc,%esp
8010233e:	ff 75 f0             	pushl  -0x10(%ebp)
80102341:	e8 8f f8 ff ff       	call   80101bd5 <iput>
80102346:	83 c4 10             	add    $0x10,%esp
    return -1;
80102349:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010234e:	e9 9c 00 00 00       	jmp    801023ef <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010235a:	eb 39                	jmp    80102395 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010235c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235f:	6a 10                	push   $0x10
80102361:	50                   	push   %eax
80102362:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102365:	50                   	push   %eax
80102366:	ff 75 08             	pushl  0x8(%ebp)
80102369:	e8 f7 fb ff ff       	call   80101f65 <readi>
8010236e:	83 c4 10             	add    $0x10,%esp
80102371:	83 f8 10             	cmp    $0x10,%eax
80102374:	74 0d                	je     80102383 <dirlink+0x6a>
      panic("dirlink read");
80102376:	83 ec 0c             	sub    $0xc,%esp
80102379:	68 ca 88 10 80       	push   $0x801088ca
8010237e:	e8 1d e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
80102383:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102387:	66 85 c0             	test   %ax,%ax
8010238a:	74 18                	je     801023a4 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010238c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238f:	83 c0 10             	add    $0x10,%eax
80102392:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102395:	8b 45 08             	mov    0x8(%ebp),%eax
80102398:	8b 50 58             	mov    0x58(%eax),%edx
8010239b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239e:	39 c2                	cmp    %eax,%edx
801023a0:	77 ba                	ja     8010235c <dirlink+0x43>
801023a2:	eb 01                	jmp    801023a5 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023a4:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023a5:	83 ec 04             	sub    $0x4,%esp
801023a8:	6a 0e                	push   $0xe
801023aa:	ff 75 0c             	pushl  0xc(%ebp)
801023ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023b0:	83 c0 02             	add    $0x2,%eax
801023b3:	50                   	push   %eax
801023b4:	e8 69 30 00 00       	call   80105422 <strncpy>
801023b9:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023bc:	8b 45 10             	mov    0x10(%ebp),%eax
801023bf:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c6:	6a 10                	push   $0x10
801023c8:	50                   	push   %eax
801023c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cc:	50                   	push   %eax
801023cd:	ff 75 08             	pushl  0x8(%ebp)
801023d0:	e8 e7 fc ff ff       	call   801020bc <writei>
801023d5:	83 c4 10             	add    $0x10,%esp
801023d8:	83 f8 10             	cmp    $0x10,%eax
801023db:	74 0d                	je     801023ea <dirlink+0xd1>
    panic("dirlink");
801023dd:	83 ec 0c             	sub    $0xc,%esp
801023e0:	68 d7 88 10 80       	push   $0x801088d7
801023e5:	e8 b6 e1 ff ff       	call   801005a0 <panic>

  return 0;
801023ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023ef:	c9                   	leave  
801023f0:	c3                   	ret    

801023f1 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023f1:	55                   	push   %ebp
801023f2:	89 e5                	mov    %esp,%ebp
801023f4:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023f7:	eb 04                	jmp    801023fd <skipelem+0xc>
    path++;
801023f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102400:	0f b6 00             	movzbl (%eax),%eax
80102403:	3c 2f                	cmp    $0x2f,%al
80102405:	74 f2                	je     801023f9 <skipelem+0x8>
    path++;
  if(*path == 0)
80102407:	8b 45 08             	mov    0x8(%ebp),%eax
8010240a:	0f b6 00             	movzbl (%eax),%eax
8010240d:	84 c0                	test   %al,%al
8010240f:	75 07                	jne    80102418 <skipelem+0x27>
    return 0;
80102411:	b8 00 00 00 00       	mov    $0x0,%eax
80102416:	eb 7b                	jmp    80102493 <skipelem+0xa2>
  s = path;
80102418:	8b 45 08             	mov    0x8(%ebp),%eax
8010241b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010241e:	eb 04                	jmp    80102424 <skipelem+0x33>
    path++;
80102420:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102424:	8b 45 08             	mov    0x8(%ebp),%eax
80102427:	0f b6 00             	movzbl (%eax),%eax
8010242a:	3c 2f                	cmp    $0x2f,%al
8010242c:	74 0a                	je     80102438 <skipelem+0x47>
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	0f b6 00             	movzbl (%eax),%eax
80102434:	84 c0                	test   %al,%al
80102436:	75 e8                	jne    80102420 <skipelem+0x2f>
    path++;
  len = path - s;
80102438:	8b 55 08             	mov    0x8(%ebp),%edx
8010243b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243e:	29 c2                	sub    %eax,%edx
80102440:	89 d0                	mov    %edx,%eax
80102442:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102445:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102449:	7e 15                	jle    80102460 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010244b:	83 ec 04             	sub    $0x4,%esp
8010244e:	6a 0e                	push   $0xe
80102450:	ff 75 f4             	pushl  -0xc(%ebp)
80102453:	ff 75 0c             	pushl  0xc(%ebp)
80102456:	e8 db 2e 00 00       	call   80105336 <memmove>
8010245b:	83 c4 10             	add    $0x10,%esp
8010245e:	eb 26                	jmp    80102486 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102460:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102463:	83 ec 04             	sub    $0x4,%esp
80102466:	50                   	push   %eax
80102467:	ff 75 f4             	pushl  -0xc(%ebp)
8010246a:	ff 75 0c             	pushl  0xc(%ebp)
8010246d:	e8 c4 2e 00 00       	call   80105336 <memmove>
80102472:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102475:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102478:	8b 45 0c             	mov    0xc(%ebp),%eax
8010247b:	01 d0                	add    %edx,%eax
8010247d:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102480:	eb 04                	jmp    80102486 <skipelem+0x95>
    path++;
80102482:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102486:	8b 45 08             	mov    0x8(%ebp),%eax
80102489:	0f b6 00             	movzbl (%eax),%eax
8010248c:	3c 2f                	cmp    $0x2f,%al
8010248e:	74 f2                	je     80102482 <skipelem+0x91>
    path++;
  return path;
80102490:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102493:	c9                   	leave  
80102494:	c3                   	ret    

80102495 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102495:	55                   	push   %ebp
80102496:	89 e5                	mov    %esp,%ebp
80102498:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010249b:	8b 45 08             	mov    0x8(%ebp),%eax
8010249e:	0f b6 00             	movzbl (%eax),%eax
801024a1:	3c 2f                	cmp    $0x2f,%al
801024a3:	75 17                	jne    801024bc <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024a5:	83 ec 08             	sub    $0x8,%esp
801024a8:	6a 01                	push   $0x1
801024aa:	6a 01                	push   $0x1
801024ac:	e8 a7 f4 ff ff       	call   80101958 <iget>
801024b1:	83 c4 10             	add    $0x10,%esp
801024b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024b7:	e9 ba 00 00 00       	jmp    80102576 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
801024bc:	e8 30 1e 00 00       	call   801042f1 <myproc>
801024c1:	8b 40 68             	mov    0x68(%eax),%eax
801024c4:	83 ec 0c             	sub    $0xc,%esp
801024c7:	50                   	push   %eax
801024c8:	e8 6d f5 ff ff       	call   80101a3a <idup>
801024cd:	83 c4 10             	add    $0x10,%esp
801024d0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024d3:	e9 9e 00 00 00       	jmp    80102576 <namex+0xe1>
    ilock(ip);
801024d8:	83 ec 0c             	sub    $0xc,%esp
801024db:	ff 75 f4             	pushl  -0xc(%ebp)
801024de:	e8 91 f5 ff ff       	call   80101a74 <ilock>
801024e3:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801024ed:	66 83 f8 01          	cmp    $0x1,%ax
801024f1:	74 18                	je     8010250b <namex+0x76>
      iunlockput(ip);
801024f3:	83 ec 0c             	sub    $0xc,%esp
801024f6:	ff 75 f4             	pushl  -0xc(%ebp)
801024f9:	e8 a7 f7 ff ff       	call   80101ca5 <iunlockput>
801024fe:	83 c4 10             	add    $0x10,%esp
      return 0;
80102501:	b8 00 00 00 00       	mov    $0x0,%eax
80102506:	e9 a7 00 00 00       	jmp    801025b2 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010250b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250f:	74 20                	je     80102531 <namex+0x9c>
80102511:	8b 45 08             	mov    0x8(%ebp),%eax
80102514:	0f b6 00             	movzbl (%eax),%eax
80102517:	84 c0                	test   %al,%al
80102519:	75 16                	jne    80102531 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010251b:	83 ec 0c             	sub    $0xc,%esp
8010251e:	ff 75 f4             	pushl  -0xc(%ebp)
80102521:	e8 61 f6 ff ff       	call   80101b87 <iunlock>
80102526:	83 c4 10             	add    $0x10,%esp
      return ip;
80102529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252c:	e9 81 00 00 00       	jmp    801025b2 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102531:	83 ec 04             	sub    $0x4,%esp
80102534:	6a 00                	push   $0x0
80102536:	ff 75 10             	pushl  0x10(%ebp)
80102539:	ff 75 f4             	pushl  -0xc(%ebp)
8010253c:	e8 1e fd ff ff       	call   8010225f <dirlookup>
80102541:	83 c4 10             	add    $0x10,%esp
80102544:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102547:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010254b:	75 15                	jne    80102562 <namex+0xcd>
      iunlockput(ip);
8010254d:	83 ec 0c             	sub    $0xc,%esp
80102550:	ff 75 f4             	pushl  -0xc(%ebp)
80102553:	e8 4d f7 ff ff       	call   80101ca5 <iunlockput>
80102558:	83 c4 10             	add    $0x10,%esp
      return 0;
8010255b:	b8 00 00 00 00       	mov    $0x0,%eax
80102560:	eb 50                	jmp    801025b2 <namex+0x11d>
    }
    iunlockput(ip);
80102562:	83 ec 0c             	sub    $0xc,%esp
80102565:	ff 75 f4             	pushl  -0xc(%ebp)
80102568:	e8 38 f7 ff ff       	call   80101ca5 <iunlockput>
8010256d:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102573:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102576:	83 ec 08             	sub    $0x8,%esp
80102579:	ff 75 10             	pushl  0x10(%ebp)
8010257c:	ff 75 08             	pushl  0x8(%ebp)
8010257f:	e8 6d fe ff ff       	call   801023f1 <skipelem>
80102584:	83 c4 10             	add    $0x10,%esp
80102587:	89 45 08             	mov    %eax,0x8(%ebp)
8010258a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010258e:	0f 85 44 ff ff ff    	jne    801024d8 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102594:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102598:	74 15                	je     801025af <namex+0x11a>
    iput(ip);
8010259a:	83 ec 0c             	sub    $0xc,%esp
8010259d:	ff 75 f4             	pushl  -0xc(%ebp)
801025a0:	e8 30 f6 ff ff       	call   80101bd5 <iput>
801025a5:	83 c4 10             	add    $0x10,%esp
    return 0;
801025a8:	b8 00 00 00 00       	mov    $0x0,%eax
801025ad:	eb 03                	jmp    801025b2 <namex+0x11d>
  }
  return ip;
801025af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025b2:	c9                   	leave  
801025b3:	c3                   	ret    

801025b4 <namei>:

struct inode*
namei(char *path)
{
801025b4:	55                   	push   %ebp
801025b5:	89 e5                	mov    %esp,%ebp
801025b7:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025ba:	83 ec 04             	sub    $0x4,%esp
801025bd:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025c0:	50                   	push   %eax
801025c1:	6a 00                	push   $0x0
801025c3:	ff 75 08             	pushl  0x8(%ebp)
801025c6:	e8 ca fe ff ff       	call   80102495 <namex>
801025cb:	83 c4 10             	add    $0x10,%esp
}
801025ce:	c9                   	leave  
801025cf:	c3                   	ret    

801025d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
801025d3:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025d6:	83 ec 04             	sub    $0x4,%esp
801025d9:	ff 75 0c             	pushl  0xc(%ebp)
801025dc:	6a 01                	push   $0x1
801025de:	ff 75 08             	pushl  0x8(%ebp)
801025e1:	e8 af fe ff ff       	call   80102495 <namex>
801025e6:	83 c4 10             	add    $0x10,%esp
}
801025e9:	c9                   	leave  
801025ea:	c3                   	ret    

801025eb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 14             	sub    $0x14,%esp
801025f1:	8b 45 08             	mov    0x8(%ebp),%eax
801025f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801025fc:	89 c2                	mov    %eax,%edx
801025fe:	ec                   	in     (%dx),%al
801025ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102602:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102606:	c9                   	leave  
80102607:	c3                   	ret    

80102608 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102608:	55                   	push   %ebp
80102609:	89 e5                	mov    %esp,%ebp
8010260b:	57                   	push   %edi
8010260c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010260d:	8b 55 08             	mov    0x8(%ebp),%edx
80102610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102613:	8b 45 10             	mov    0x10(%ebp),%eax
80102616:	89 cb                	mov    %ecx,%ebx
80102618:	89 df                	mov    %ebx,%edi
8010261a:	89 c1                	mov    %eax,%ecx
8010261c:	fc                   	cld    
8010261d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010261f:	89 c8                	mov    %ecx,%eax
80102621:	89 fb                	mov    %edi,%ebx
80102623:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102626:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102629:	90                   	nop
8010262a:	5b                   	pop    %ebx
8010262b:	5f                   	pop    %edi
8010262c:	5d                   	pop    %ebp
8010262d:	c3                   	ret    

8010262e <outb>:

static inline void
outb(ushort port, uchar data)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
80102631:	83 ec 08             	sub    $0x8,%esp
80102634:	8b 55 08             	mov    0x8(%ebp),%edx
80102637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010263a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010263e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102641:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102645:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102649:	ee                   	out    %al,(%dx)
}
8010264a:	90                   	nop
8010264b:	c9                   	leave  
8010264c:	c3                   	ret    

8010264d <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010264d:	55                   	push   %ebp
8010264e:	89 e5                	mov    %esp,%ebp
80102650:	56                   	push   %esi
80102651:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102652:	8b 55 08             	mov    0x8(%ebp),%edx
80102655:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102658:	8b 45 10             	mov    0x10(%ebp),%eax
8010265b:	89 cb                	mov    %ecx,%ebx
8010265d:	89 de                	mov    %ebx,%esi
8010265f:	89 c1                	mov    %eax,%ecx
80102661:	fc                   	cld    
80102662:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102664:	89 c8                	mov    %ecx,%eax
80102666:	89 f3                	mov    %esi,%ebx
80102668:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010266b:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010266e:	90                   	nop
8010266f:	5b                   	pop    %ebx
80102670:	5e                   	pop    %esi
80102671:	5d                   	pop    %ebp
80102672:	c3                   	ret    

80102673 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102679:	90                   	nop
8010267a:	68 f7 01 00 00       	push   $0x1f7
8010267f:	e8 67 ff ff ff       	call   801025eb <inb>
80102684:	83 c4 04             	add    $0x4,%esp
80102687:	0f b6 c0             	movzbl %al,%eax
8010268a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010268d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102690:	25 c0 00 00 00       	and    $0xc0,%eax
80102695:	83 f8 40             	cmp    $0x40,%eax
80102698:	75 e0                	jne    8010267a <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010269a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010269e:	74 11                	je     801026b1 <idewait+0x3e>
801026a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026a3:	83 e0 21             	and    $0x21,%eax
801026a6:	85 c0                	test   %eax,%eax
801026a8:	74 07                	je     801026b1 <idewait+0x3e>
    return -1;
801026aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026af:	eb 05                	jmp    801026b6 <idewait+0x43>
  return 0;
801026b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026b6:	c9                   	leave  
801026b7:	c3                   	ret    

801026b8 <ideinit>:

void
ideinit(void)
{
801026b8:	55                   	push   %ebp
801026b9:	89 e5                	mov    %esp,%ebp
801026bb:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026be:	83 ec 08             	sub    $0x8,%esp
801026c1:	68 df 88 10 80       	push   $0x801088df
801026c6:	68 e0 b5 10 80       	push   $0x8010b5e0
801026cb:	e8 0e 29 00 00       	call   80104fde <initlock>
801026d0:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026d3:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801026d8:	83 e8 01             	sub    $0x1,%eax
801026db:	83 ec 08             	sub    $0x8,%esp
801026de:	50                   	push   %eax
801026df:	6a 0e                	push   $0xe
801026e1:	e8 a2 04 00 00       	call   80102b88 <ioapicenable>
801026e6:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801026e9:	83 ec 0c             	sub    $0xc,%esp
801026ec:	6a 00                	push   $0x0
801026ee:	e8 80 ff ff ff       	call   80102673 <idewait>
801026f3:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801026f6:	83 ec 08             	sub    $0x8,%esp
801026f9:	68 f0 00 00 00       	push   $0xf0
801026fe:	68 f6 01 00 00       	push   $0x1f6
80102703:	e8 26 ff ff ff       	call   8010262e <outb>
80102708:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010270b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102712:	eb 24                	jmp    80102738 <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102714:	83 ec 0c             	sub    $0xc,%esp
80102717:	68 f7 01 00 00       	push   $0x1f7
8010271c:	e8 ca fe ff ff       	call   801025eb <inb>
80102721:	83 c4 10             	add    $0x10,%esp
80102724:	84 c0                	test   %al,%al
80102726:	74 0c                	je     80102734 <ideinit+0x7c>
      havedisk1 = 1;
80102728:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
8010272f:	00 00 00 
      break;
80102732:	eb 0d                	jmp    80102741 <ideinit+0x89>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102734:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102738:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010273f:	7e d3                	jle    80102714 <ideinit+0x5c>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102741:	83 ec 08             	sub    $0x8,%esp
80102744:	68 e0 00 00 00       	push   $0xe0
80102749:	68 f6 01 00 00       	push   $0x1f6
8010274e:	e8 db fe ff ff       	call   8010262e <outb>
80102753:	83 c4 10             	add    $0x10,%esp
}
80102756:	90                   	nop
80102757:	c9                   	leave  
80102758:	c3                   	ret    

80102759 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102759:	55                   	push   %ebp
8010275a:	89 e5                	mov    %esp,%ebp
8010275c:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010275f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102763:	75 0d                	jne    80102772 <idestart+0x19>
    panic("idestart");
80102765:	83 ec 0c             	sub    $0xc,%esp
80102768:	68 e3 88 10 80       	push   $0x801088e3
8010276d:	e8 2e de ff ff       	call   801005a0 <panic>
  if(b->blockno >= FSSIZE)
80102772:	8b 45 08             	mov    0x8(%ebp),%eax
80102775:	8b 40 08             	mov    0x8(%eax),%eax
80102778:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010277d:	76 0d                	jbe    8010278c <idestart+0x33>
    panic("incorrect blockno");
8010277f:	83 ec 0c             	sub    $0xc,%esp
80102782:	68 ec 88 10 80       	push   $0x801088ec
80102787:	e8 14 de ff ff       	call   801005a0 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010278c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102793:	8b 45 08             	mov    0x8(%ebp),%eax
80102796:	8b 50 08             	mov    0x8(%eax),%edx
80102799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279c:	0f af c2             	imul   %edx,%eax
8010279f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027a2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027a6:	75 07                	jne    801027af <idestart+0x56>
801027a8:	b8 20 00 00 00       	mov    $0x20,%eax
801027ad:	eb 05                	jmp    801027b4 <idestart+0x5b>
801027af:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027b7:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027bb:	75 07                	jne    801027c4 <idestart+0x6b>
801027bd:	b8 30 00 00 00       	mov    $0x30,%eax
801027c2:	eb 05                	jmp    801027c9 <idestart+0x70>
801027c4:	b8 c5 00 00 00       	mov    $0xc5,%eax
801027c9:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027cc:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027d0:	7e 0d                	jle    801027df <idestart+0x86>
801027d2:	83 ec 0c             	sub    $0xc,%esp
801027d5:	68 e3 88 10 80       	push   $0x801088e3
801027da:	e8 c1 dd ff ff       	call   801005a0 <panic>

  idewait(0);
801027df:	83 ec 0c             	sub    $0xc,%esp
801027e2:	6a 00                	push   $0x0
801027e4:	e8 8a fe ff ff       	call   80102673 <idewait>
801027e9:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027ec:	83 ec 08             	sub    $0x8,%esp
801027ef:	6a 00                	push   $0x0
801027f1:	68 f6 03 00 00       	push   $0x3f6
801027f6:	e8 33 fe ff ff       	call   8010262e <outb>
801027fb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102801:	0f b6 c0             	movzbl %al,%eax
80102804:	83 ec 08             	sub    $0x8,%esp
80102807:	50                   	push   %eax
80102808:	68 f2 01 00 00       	push   $0x1f2
8010280d:	e8 1c fe ff ff       	call   8010262e <outb>
80102812:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102818:	0f b6 c0             	movzbl %al,%eax
8010281b:	83 ec 08             	sub    $0x8,%esp
8010281e:	50                   	push   %eax
8010281f:	68 f3 01 00 00       	push   $0x1f3
80102824:	e8 05 fe ff ff       	call   8010262e <outb>
80102829:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010282c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010282f:	c1 f8 08             	sar    $0x8,%eax
80102832:	0f b6 c0             	movzbl %al,%eax
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	50                   	push   %eax
80102839:	68 f4 01 00 00       	push   $0x1f4
8010283e:	e8 eb fd ff ff       	call   8010262e <outb>
80102843:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102846:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102849:	c1 f8 10             	sar    $0x10,%eax
8010284c:	0f b6 c0             	movzbl %al,%eax
8010284f:	83 ec 08             	sub    $0x8,%esp
80102852:	50                   	push   %eax
80102853:	68 f5 01 00 00       	push   $0x1f5
80102858:	e8 d1 fd ff ff       	call   8010262e <outb>
8010285d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102860:	8b 45 08             	mov    0x8(%ebp),%eax
80102863:	8b 40 04             	mov    0x4(%eax),%eax
80102866:	83 e0 01             	and    $0x1,%eax
80102869:	c1 e0 04             	shl    $0x4,%eax
8010286c:	89 c2                	mov    %eax,%edx
8010286e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102871:	c1 f8 18             	sar    $0x18,%eax
80102874:	83 e0 0f             	and    $0xf,%eax
80102877:	09 d0                	or     %edx,%eax
80102879:	83 c8 e0             	or     $0xffffffe0,%eax
8010287c:	0f b6 c0             	movzbl %al,%eax
8010287f:	83 ec 08             	sub    $0x8,%esp
80102882:	50                   	push   %eax
80102883:	68 f6 01 00 00       	push   $0x1f6
80102888:	e8 a1 fd ff ff       	call   8010262e <outb>
8010288d:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102890:	8b 45 08             	mov    0x8(%ebp),%eax
80102893:	8b 00                	mov    (%eax),%eax
80102895:	83 e0 04             	and    $0x4,%eax
80102898:	85 c0                	test   %eax,%eax
8010289a:	74 35                	je     801028d1 <idestart+0x178>
    outb(0x1f7, write_cmd);
8010289c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010289f:	0f b6 c0             	movzbl %al,%eax
801028a2:	83 ec 08             	sub    $0x8,%esp
801028a5:	50                   	push   %eax
801028a6:	68 f7 01 00 00       	push   $0x1f7
801028ab:	e8 7e fd ff ff       	call   8010262e <outb>
801028b0:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028b3:	8b 45 08             	mov    0x8(%ebp),%eax
801028b6:	83 c0 5c             	add    $0x5c,%eax
801028b9:	83 ec 04             	sub    $0x4,%esp
801028bc:	68 80 00 00 00       	push   $0x80
801028c1:	50                   	push   %eax
801028c2:	68 f0 01 00 00       	push   $0x1f0
801028c7:	e8 81 fd ff ff       	call   8010264d <outsl>
801028cc:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801028cf:	eb 17                	jmp    801028e8 <idestart+0x18f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
801028d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028d4:	0f b6 c0             	movzbl %al,%eax
801028d7:	83 ec 08             	sub    $0x8,%esp
801028da:	50                   	push   %eax
801028db:	68 f7 01 00 00       	push   $0x1f7
801028e0:	e8 49 fd ff ff       	call   8010262e <outb>
801028e5:	83 c4 10             	add    $0x10,%esp
  }
}
801028e8:	90                   	nop
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028f1:	83 ec 0c             	sub    $0xc,%esp
801028f4:	68 e0 b5 10 80       	push   $0x8010b5e0
801028f9:	e8 02 27 00 00       	call   80105000 <acquire>
801028fe:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102901:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102906:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102909:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010290d:	75 15                	jne    80102924 <ideintr+0x39>
    release(&idelock);
8010290f:	83 ec 0c             	sub    $0xc,%esp
80102912:	68 e0 b5 10 80       	push   $0x8010b5e0
80102917:	e8 52 27 00 00       	call   8010506e <release>
8010291c:	83 c4 10             	add    $0x10,%esp
    return;
8010291f:	e9 9a 00 00 00       	jmp    801029be <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102927:	8b 40 58             	mov    0x58(%eax),%eax
8010292a:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010292f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102932:	8b 00                	mov    (%eax),%eax
80102934:	83 e0 04             	and    $0x4,%eax
80102937:	85 c0                	test   %eax,%eax
80102939:	75 2d                	jne    80102968 <ideintr+0x7d>
8010293b:	83 ec 0c             	sub    $0xc,%esp
8010293e:	6a 01                	push   $0x1
80102940:	e8 2e fd ff ff       	call   80102673 <idewait>
80102945:	83 c4 10             	add    $0x10,%esp
80102948:	85 c0                	test   %eax,%eax
8010294a:	78 1c                	js     80102968 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010294c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294f:	83 c0 5c             	add    $0x5c,%eax
80102952:	83 ec 04             	sub    $0x4,%esp
80102955:	68 80 00 00 00       	push   $0x80
8010295a:	50                   	push   %eax
8010295b:	68 f0 01 00 00       	push   $0x1f0
80102960:	e8 a3 fc ff ff       	call   80102608 <insl>
80102965:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296b:	8b 00                	mov    (%eax),%eax
8010296d:	83 c8 02             	or     $0x2,%eax
80102970:	89 c2                	mov    %eax,%edx
80102972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102975:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297a:	8b 00                	mov    (%eax),%eax
8010297c:	83 e0 fb             	and    $0xfffffffb,%eax
8010297f:	89 c2                	mov    %eax,%edx
80102981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102984:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102986:	83 ec 0c             	sub    $0xc,%esp
80102989:	ff 75 f4             	pushl  -0xc(%ebp)
8010298c:	e8 36 23 00 00       	call   80104cc7 <wakeup>
80102991:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102994:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102999:	85 c0                	test   %eax,%eax
8010299b:	74 11                	je     801029ae <ideintr+0xc3>
    idestart(idequeue);
8010299d:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029a2:	83 ec 0c             	sub    $0xc,%esp
801029a5:	50                   	push   %eax
801029a6:	e8 ae fd ff ff       	call   80102759 <idestart>
801029ab:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029ae:	83 ec 0c             	sub    $0xc,%esp
801029b1:	68 e0 b5 10 80       	push   $0x8010b5e0
801029b6:	e8 b3 26 00 00       	call   8010506e <release>
801029bb:	83 c4 10             	add    $0x10,%esp
}
801029be:	c9                   	leave  
801029bf:	c3                   	ret    

801029c0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029c0:	55                   	push   %ebp
801029c1:	89 e5                	mov    %esp,%ebp
801029c3:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801029c6:	8b 45 08             	mov    0x8(%ebp),%eax
801029c9:	83 c0 0c             	add    $0xc,%eax
801029cc:	83 ec 0c             	sub    $0xc,%esp
801029cf:	50                   	push   %eax
801029d0:	e8 9a 25 00 00       	call   80104f6f <holdingsleep>
801029d5:	83 c4 10             	add    $0x10,%esp
801029d8:	85 c0                	test   %eax,%eax
801029da:	75 0d                	jne    801029e9 <iderw+0x29>
    panic("iderw: buf not locked");
801029dc:	83 ec 0c             	sub    $0xc,%esp
801029df:	68 fe 88 10 80       	push   $0x801088fe
801029e4:	e8 b7 db ff ff       	call   801005a0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029e9:	8b 45 08             	mov    0x8(%ebp),%eax
801029ec:	8b 00                	mov    (%eax),%eax
801029ee:	83 e0 06             	and    $0x6,%eax
801029f1:	83 f8 02             	cmp    $0x2,%eax
801029f4:	75 0d                	jne    80102a03 <iderw+0x43>
    panic("iderw: nothing to do");
801029f6:	83 ec 0c             	sub    $0xc,%esp
801029f9:	68 14 89 10 80       	push   $0x80108914
801029fe:	e8 9d db ff ff       	call   801005a0 <panic>
  if(b->dev != 0 && !havedisk1)
80102a03:	8b 45 08             	mov    0x8(%ebp),%eax
80102a06:	8b 40 04             	mov    0x4(%eax),%eax
80102a09:	85 c0                	test   %eax,%eax
80102a0b:	74 16                	je     80102a23 <iderw+0x63>
80102a0d:	a1 18 b6 10 80       	mov    0x8010b618,%eax
80102a12:	85 c0                	test   %eax,%eax
80102a14:	75 0d                	jne    80102a23 <iderw+0x63>
    panic("iderw: ide disk 1 not present");
80102a16:	83 ec 0c             	sub    $0xc,%esp
80102a19:	68 29 89 10 80       	push   $0x80108929
80102a1e:	e8 7d db ff ff       	call   801005a0 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a23:	83 ec 0c             	sub    $0xc,%esp
80102a26:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a2b:	e8 d0 25 00 00       	call   80105000 <acquire>
80102a30:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a33:	8b 45 08             	mov    0x8(%ebp),%eax
80102a36:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a3d:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
80102a44:	eb 0b                	jmp    80102a51 <iderw+0x91>
80102a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a49:	8b 00                	mov    (%eax),%eax
80102a4b:	83 c0 58             	add    $0x58,%eax
80102a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a54:	8b 00                	mov    (%eax),%eax
80102a56:	85 c0                	test   %eax,%eax
80102a58:	75 ec                	jne    80102a46 <iderw+0x86>
    ;
  *pp = b;
80102a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80102a60:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a62:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102a67:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a6a:	75 23                	jne    80102a8f <iderw+0xcf>
    idestart(b);
80102a6c:	83 ec 0c             	sub    $0xc,%esp
80102a6f:	ff 75 08             	pushl  0x8(%ebp)
80102a72:	e8 e2 fc ff ff       	call   80102759 <idestart>
80102a77:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a7a:	eb 13                	jmp    80102a8f <iderw+0xcf>
    sleep(b, &idelock);
80102a7c:	83 ec 08             	sub    $0x8,%esp
80102a7f:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a84:	ff 75 08             	pushl  0x8(%ebp)
80102a87:	e8 52 21 00 00       	call   80104bde <sleep>
80102a8c:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a92:	8b 00                	mov    (%eax),%eax
80102a94:	83 e0 06             	and    $0x6,%eax
80102a97:	83 f8 02             	cmp    $0x2,%eax
80102a9a:	75 e0                	jne    80102a7c <iderw+0xbc>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a9c:	83 ec 0c             	sub    $0xc,%esp
80102a9f:	68 e0 b5 10 80       	push   $0x8010b5e0
80102aa4:	e8 c5 25 00 00       	call   8010506e <release>
80102aa9:	83 c4 10             	add    $0x10,%esp
}
80102aac:	90                   	nop
80102aad:	c9                   	leave  
80102aae:	c3                   	ret    

80102aaf <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102aaf:	55                   	push   %ebp
80102ab0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ab2:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ab7:	8b 55 08             	mov    0x8(%ebp),%edx
80102aba:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102abc:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ac1:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ac4:	5d                   	pop    %ebp
80102ac5:	c3                   	ret    

80102ac6 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ac9:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ace:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad1:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ad3:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
80102adb:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ade:	90                   	nop
80102adf:	5d                   	pop    %ebp
80102ae0:	c3                   	ret    

80102ae1 <ioapicinit>:

void
ioapicinit(void)
{
80102ae1:	55                   	push   %ebp
80102ae2:	89 e5                	mov    %esp,%ebp
80102ae4:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ae7:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
80102aee:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102af1:	6a 01                	push   $0x1
80102af3:	e8 b7 ff ff ff       	call   80102aaf <ioapicread>
80102af8:	83 c4 04             	add    $0x4,%esp
80102afb:	c1 e8 10             	shr    $0x10,%eax
80102afe:	25 ff 00 00 00       	and    $0xff,%eax
80102b03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b06:	6a 00                	push   $0x0
80102b08:	e8 a2 ff ff ff       	call   80102aaf <ioapicread>
80102b0d:	83 c4 04             	add    $0x4,%esp
80102b10:	c1 e8 18             	shr    $0x18,%eax
80102b13:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b16:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
80102b1d:	0f b6 c0             	movzbl %al,%eax
80102b20:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b23:	74 10                	je     80102b35 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b25:	83 ec 0c             	sub    $0xc,%esp
80102b28:	68 48 89 10 80       	push   $0x80108948
80102b2d:	e8 ce d8 ff ff       	call   80100400 <cprintf>
80102b32:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b3c:	eb 3f                	jmp    80102b7d <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b41:	83 c0 20             	add    $0x20,%eax
80102b44:	0d 00 00 01 00       	or     $0x10000,%eax
80102b49:	89 c2                	mov    %eax,%edx
80102b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4e:	83 c0 08             	add    $0x8,%eax
80102b51:	01 c0                	add    %eax,%eax
80102b53:	83 ec 08             	sub    $0x8,%esp
80102b56:	52                   	push   %edx
80102b57:	50                   	push   %eax
80102b58:	e8 69 ff ff ff       	call   80102ac6 <ioapicwrite>
80102b5d:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b63:	83 c0 08             	add    $0x8,%eax
80102b66:	01 c0                	add    %eax,%eax
80102b68:	83 c0 01             	add    $0x1,%eax
80102b6b:	83 ec 08             	sub    $0x8,%esp
80102b6e:	6a 00                	push   $0x0
80102b70:	50                   	push   %eax
80102b71:	e8 50 ff ff ff       	call   80102ac6 <ioapicwrite>
80102b76:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b80:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b83:	7e b9                	jle    80102b3e <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b85:	90                   	nop
80102b86:	c9                   	leave  
80102b87:	c3                   	ret    

80102b88 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b88:	55                   	push   %ebp
80102b89:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8e:	83 c0 20             	add    $0x20,%eax
80102b91:	89 c2                	mov    %eax,%edx
80102b93:	8b 45 08             	mov    0x8(%ebp),%eax
80102b96:	83 c0 08             	add    $0x8,%eax
80102b99:	01 c0                	add    %eax,%eax
80102b9b:	52                   	push   %edx
80102b9c:	50                   	push   %eax
80102b9d:	e8 24 ff ff ff       	call   80102ac6 <ioapicwrite>
80102ba2:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ba8:	c1 e0 18             	shl    $0x18,%eax
80102bab:	89 c2                	mov    %eax,%edx
80102bad:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb0:	83 c0 08             	add    $0x8,%eax
80102bb3:	01 c0                	add    %eax,%eax
80102bb5:	83 c0 01             	add    $0x1,%eax
80102bb8:	52                   	push   %edx
80102bb9:	50                   	push   %eax
80102bba:	e8 07 ff ff ff       	call   80102ac6 <ioapicwrite>
80102bbf:	83 c4 08             	add    $0x8,%esp
}
80102bc2:	90                   	nop
80102bc3:	c9                   	leave  
80102bc4:	c3                   	ret    

80102bc5 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bc5:	55                   	push   %ebp
80102bc6:	89 e5                	mov    %esp,%ebp
80102bc8:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bcb:	83 ec 08             	sub    $0x8,%esp
80102bce:	68 7a 89 10 80       	push   $0x8010897a
80102bd3:	68 c0 36 11 80       	push   $0x801136c0
80102bd8:	e8 01 24 00 00       	call   80104fde <initlock>
80102bdd:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102be0:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102be7:	00 00 00 
  freerange(vstart, vend);
80102bea:	83 ec 08             	sub    $0x8,%esp
80102bed:	ff 75 0c             	pushl  0xc(%ebp)
80102bf0:	ff 75 08             	pushl  0x8(%ebp)
80102bf3:	e8 2a 00 00 00       	call   80102c22 <freerange>
80102bf8:	83 c4 10             	add    $0x10,%esp
}
80102bfb:	90                   	nop
80102bfc:	c9                   	leave  
80102bfd:	c3                   	ret    

80102bfe <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bfe:	55                   	push   %ebp
80102bff:	89 e5                	mov    %esp,%ebp
80102c01:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c04:	83 ec 08             	sub    $0x8,%esp
80102c07:	ff 75 0c             	pushl  0xc(%ebp)
80102c0a:	ff 75 08             	pushl  0x8(%ebp)
80102c0d:	e8 10 00 00 00       	call   80102c22 <freerange>
80102c12:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c15:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102c1c:	00 00 00 
}
80102c1f:	90                   	nop
80102c20:	c9                   	leave  
80102c21:	c3                   	ret    

80102c22 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c22:	55                   	push   %ebp
80102c23:	89 e5                	mov    %esp,%ebp
80102c25:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c28:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2b:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c38:	eb 15                	jmp    80102c4f <freerange+0x2d>
    kfree(p);
80102c3a:	83 ec 0c             	sub    $0xc,%esp
80102c3d:	ff 75 f4             	pushl  -0xc(%ebp)
80102c40:	e8 1a 00 00 00       	call   80102c5f <kfree>
80102c45:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c48:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c52:	05 00 10 00 00       	add    $0x1000,%eax
80102c57:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c5a:	76 de                	jbe    80102c3a <freerange+0x18>
    kfree(p);
}
80102c5c:	90                   	nop
80102c5d:	c9                   	leave  
80102c5e:	c3                   	ret    

80102c5f <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c5f:	55                   	push   %ebp
80102c60:	89 e5                	mov    %esp,%ebp
80102c62:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c65:	8b 45 08             	mov    0x8(%ebp),%eax
80102c68:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	75 18                	jne    80102c89 <kfree+0x2a>
80102c71:	81 7d 08 74 6a 11 80 	cmpl   $0x80116a74,0x8(%ebp)
80102c78:	72 0f                	jb     80102c89 <kfree+0x2a>
80102c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7d:	05 00 00 00 80       	add    $0x80000000,%eax
80102c82:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c87:	76 0d                	jbe    80102c96 <kfree+0x37>
    panic("kfree");
80102c89:	83 ec 0c             	sub    $0xc,%esp
80102c8c:	68 7f 89 10 80       	push   $0x8010897f
80102c91:	e8 0a d9 ff ff       	call   801005a0 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c96:	83 ec 04             	sub    $0x4,%esp
80102c99:	68 00 10 00 00       	push   $0x1000
80102c9e:	6a 01                	push   $0x1
80102ca0:	ff 75 08             	pushl  0x8(%ebp)
80102ca3:	e8 cf 25 00 00       	call   80105277 <memset>
80102ca8:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cab:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102cb0:	85 c0                	test   %eax,%eax
80102cb2:	74 10                	je     80102cc4 <kfree+0x65>
    acquire(&kmem.lock);
80102cb4:	83 ec 0c             	sub    $0xc,%esp
80102cb7:	68 c0 36 11 80       	push   $0x801136c0
80102cbc:	e8 3f 23 00 00       	call   80105000 <acquire>
80102cc1:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cca:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd3:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd8:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102cdd:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102ce2:	85 c0                	test   %eax,%eax
80102ce4:	74 10                	je     80102cf6 <kfree+0x97>
    release(&kmem.lock);
80102ce6:	83 ec 0c             	sub    $0xc,%esp
80102ce9:	68 c0 36 11 80       	push   $0x801136c0
80102cee:	e8 7b 23 00 00       	call   8010506e <release>
80102cf3:	83 c4 10             	add    $0x10,%esp
}
80102cf6:	90                   	nop
80102cf7:	c9                   	leave  
80102cf8:	c3                   	ret    

80102cf9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cf9:	55                   	push   %ebp
80102cfa:	89 e5                	mov    %esp,%ebp
80102cfc:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102cff:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d04:	85 c0                	test   %eax,%eax
80102d06:	74 10                	je     80102d18 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d08:	83 ec 0c             	sub    $0xc,%esp
80102d0b:	68 c0 36 11 80       	push   $0x801136c0
80102d10:	e8 eb 22 00 00       	call   80105000 <acquire>
80102d15:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d18:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102d1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d24:	74 0a                	je     80102d30 <kalloc+0x37>
    kmem.freelist = r->next;
80102d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d29:	8b 00                	mov    (%eax),%eax
80102d2b:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102d30:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d35:	85 c0                	test   %eax,%eax
80102d37:	74 10                	je     80102d49 <kalloc+0x50>
    release(&kmem.lock);
80102d39:	83 ec 0c             	sub    $0xc,%esp
80102d3c:	68 c0 36 11 80       	push   $0x801136c0
80102d41:	e8 28 23 00 00       	call   8010506e <release>
80102d46:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d4c:	c9                   	leave  
80102d4d:	c3                   	ret    

80102d4e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d4e:	55                   	push   %ebp
80102d4f:	89 e5                	mov    %esp,%ebp
80102d51:	83 ec 14             	sub    $0x14,%esp
80102d54:	8b 45 08             	mov    0x8(%ebp),%eax
80102d57:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d5b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d5f:	89 c2                	mov    %eax,%edx
80102d61:	ec                   	in     (%dx),%al
80102d62:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d65:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d69:	c9                   	leave  
80102d6a:	c3                   	ret    

80102d6b <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d6b:	55                   	push   %ebp
80102d6c:	89 e5                	mov    %esp,%ebp
80102d6e:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d71:	6a 64                	push   $0x64
80102d73:	e8 d6 ff ff ff       	call   80102d4e <inb>
80102d78:	83 c4 04             	add    $0x4,%esp
80102d7b:	0f b6 c0             	movzbl %al,%eax
80102d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d84:	83 e0 01             	and    $0x1,%eax
80102d87:	85 c0                	test   %eax,%eax
80102d89:	75 0a                	jne    80102d95 <kbdgetc+0x2a>
    return -1;
80102d8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d90:	e9 23 01 00 00       	jmp    80102eb8 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d95:	6a 60                	push   $0x60
80102d97:	e8 b2 ff ff ff       	call   80102d4e <inb>
80102d9c:	83 c4 04             	add    $0x4,%esp
80102d9f:	0f b6 c0             	movzbl %al,%eax
80102da2:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102da5:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dac:	75 17                	jne    80102dc5 <kbdgetc+0x5a>
    shift |= E0ESC;
80102dae:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102db3:	83 c8 40             	or     $0x40,%eax
80102db6:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102dbb:	b8 00 00 00 00       	mov    $0x0,%eax
80102dc0:	e9 f3 00 00 00       	jmp    80102eb8 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102dc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc8:	25 80 00 00 00       	and    $0x80,%eax
80102dcd:	85 c0                	test   %eax,%eax
80102dcf:	74 45                	je     80102e16 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102dd1:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dd6:	83 e0 40             	and    $0x40,%eax
80102dd9:	85 c0                	test   %eax,%eax
80102ddb:	75 08                	jne    80102de5 <kbdgetc+0x7a>
80102ddd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de0:	83 e0 7f             	and    $0x7f,%eax
80102de3:	eb 03                	jmp    80102de8 <kbdgetc+0x7d>
80102de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102deb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dee:	05 20 90 10 80       	add    $0x80109020,%eax
80102df3:	0f b6 00             	movzbl (%eax),%eax
80102df6:	83 c8 40             	or     $0x40,%eax
80102df9:	0f b6 c0             	movzbl %al,%eax
80102dfc:	f7 d0                	not    %eax
80102dfe:	89 c2                	mov    %eax,%edx
80102e00:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e05:	21 d0                	and    %edx,%eax
80102e07:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102e0c:	b8 00 00 00 00       	mov    $0x0,%eax
80102e11:	e9 a2 00 00 00       	jmp    80102eb8 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e16:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e1b:	83 e0 40             	and    $0x40,%eax
80102e1e:	85 c0                	test   %eax,%eax
80102e20:	74 14                	je     80102e36 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e22:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e29:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e2e:	83 e0 bf             	and    $0xffffffbf,%eax
80102e31:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e39:	05 20 90 10 80       	add    $0x80109020,%eax
80102e3e:	0f b6 00             	movzbl (%eax),%eax
80102e41:	0f b6 d0             	movzbl %al,%edx
80102e44:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e49:	09 d0                	or     %edx,%eax
80102e4b:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102e50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e53:	05 20 91 10 80       	add    $0x80109120,%eax
80102e58:	0f b6 00             	movzbl (%eax),%eax
80102e5b:	0f b6 d0             	movzbl %al,%edx
80102e5e:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e63:	31 d0                	xor    %edx,%eax
80102e65:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e6a:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e6f:	83 e0 03             	and    $0x3,%eax
80102e72:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e7c:	01 d0                	add    %edx,%eax
80102e7e:	0f b6 00             	movzbl (%eax),%eax
80102e81:	0f b6 c0             	movzbl %al,%eax
80102e84:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e87:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e8c:	83 e0 08             	and    $0x8,%eax
80102e8f:	85 c0                	test   %eax,%eax
80102e91:	74 22                	je     80102eb5 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e93:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e97:	76 0c                	jbe    80102ea5 <kbdgetc+0x13a>
80102e99:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e9d:	77 06                	ja     80102ea5 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e9f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ea3:	eb 10                	jmp    80102eb5 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ea5:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ea9:	76 0a                	jbe    80102eb5 <kbdgetc+0x14a>
80102eab:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102eaf:	77 04                	ja     80102eb5 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102eb1:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102eb5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102eb8:	c9                   	leave  
80102eb9:	c3                   	ret    

80102eba <kbdintr>:

void
kbdintr(void)
{
80102eba:	55                   	push   %ebp
80102ebb:	89 e5                	mov    %esp,%ebp
80102ebd:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ec0:	83 ec 0c             	sub    $0xc,%esp
80102ec3:	68 6b 2d 10 80       	push   $0x80102d6b
80102ec8:	e8 5f d9 ff ff       	call   8010082c <consoleintr>
80102ecd:	83 c4 10             	add    $0x10,%esp
}
80102ed0:	90                   	nop
80102ed1:	c9                   	leave  
80102ed2:	c3                   	ret    

80102ed3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ed3:	55                   	push   %ebp
80102ed4:	89 e5                	mov    %esp,%ebp
80102ed6:	83 ec 14             	sub    $0x14,%esp
80102ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80102edc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ee0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ee4:	89 c2                	mov    %eax,%edx
80102ee6:	ec                   	in     (%dx),%al
80102ee7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102eea:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102eee:	c9                   	leave  
80102eef:	c3                   	ret    

80102ef0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ef0:	55                   	push   %ebp
80102ef1:	89 e5                	mov    %esp,%ebp
80102ef3:	83 ec 08             	sub    $0x8,%esp
80102ef6:	8b 55 08             	mov    0x8(%ebp),%edx
80102ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102efc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f00:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f03:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f07:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f0b:	ee                   	out    %al,(%dx)
}
80102f0c:	90                   	nop
80102f0d:	c9                   	leave  
80102f0e:	c3                   	ret    

80102f0f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f0f:	55                   	push   %ebp
80102f10:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f12:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f17:	8b 55 08             	mov    0x8(%ebp),%edx
80102f1a:	c1 e2 02             	shl    $0x2,%edx
80102f1d:	01 c2                	add    %eax,%edx
80102f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f22:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f24:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f29:	83 c0 20             	add    $0x20,%eax
80102f2c:	8b 00                	mov    (%eax),%eax
}
80102f2e:	90                   	nop
80102f2f:	5d                   	pop    %ebp
80102f30:	c3                   	ret    

80102f31 <lapicinit>:

void
lapicinit(void)
{
80102f31:	55                   	push   %ebp
80102f32:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102f34:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f39:	85 c0                	test   %eax,%eax
80102f3b:	0f 84 0b 01 00 00    	je     8010304c <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f41:	68 3f 01 00 00       	push   $0x13f
80102f46:	6a 3c                	push   $0x3c
80102f48:	e8 c2 ff ff ff       	call   80102f0f <lapicw>
80102f4d:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f50:	6a 0b                	push   $0xb
80102f52:	68 f8 00 00 00       	push   $0xf8
80102f57:	e8 b3 ff ff ff       	call   80102f0f <lapicw>
80102f5c:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f5f:	68 20 00 02 00       	push   $0x20020
80102f64:	68 c8 00 00 00       	push   $0xc8
80102f69:	e8 a1 ff ff ff       	call   80102f0f <lapicw>
80102f6e:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f71:	68 80 96 98 00       	push   $0x989680
80102f76:	68 e0 00 00 00       	push   $0xe0
80102f7b:	e8 8f ff ff ff       	call   80102f0f <lapicw>
80102f80:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f83:	68 00 00 01 00       	push   $0x10000
80102f88:	68 d4 00 00 00       	push   $0xd4
80102f8d:	e8 7d ff ff ff       	call   80102f0f <lapicw>
80102f92:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f95:	68 00 00 01 00       	push   $0x10000
80102f9a:	68 d8 00 00 00       	push   $0xd8
80102f9f:	e8 6b ff ff ff       	call   80102f0f <lapicw>
80102fa4:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fa7:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fac:	83 c0 30             	add    $0x30,%eax
80102faf:	8b 00                	mov    (%eax),%eax
80102fb1:	c1 e8 10             	shr    $0x10,%eax
80102fb4:	0f b6 c0             	movzbl %al,%eax
80102fb7:	83 f8 03             	cmp    $0x3,%eax
80102fba:	76 12                	jbe    80102fce <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102fbc:	68 00 00 01 00       	push   $0x10000
80102fc1:	68 d0 00 00 00       	push   $0xd0
80102fc6:	e8 44 ff ff ff       	call   80102f0f <lapicw>
80102fcb:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fce:	6a 33                	push   $0x33
80102fd0:	68 dc 00 00 00       	push   $0xdc
80102fd5:	e8 35 ff ff ff       	call   80102f0f <lapicw>
80102fda:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fdd:	6a 00                	push   $0x0
80102fdf:	68 a0 00 00 00       	push   $0xa0
80102fe4:	e8 26 ff ff ff       	call   80102f0f <lapicw>
80102fe9:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102fec:	6a 00                	push   $0x0
80102fee:	68 a0 00 00 00       	push   $0xa0
80102ff3:	e8 17 ff ff ff       	call   80102f0f <lapicw>
80102ff8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ffb:	6a 00                	push   $0x0
80102ffd:	6a 2c                	push   $0x2c
80102fff:	e8 0b ff ff ff       	call   80102f0f <lapicw>
80103004:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103007:	6a 00                	push   $0x0
80103009:	68 c4 00 00 00       	push   $0xc4
8010300e:	e8 fc fe ff ff       	call   80102f0f <lapicw>
80103013:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103016:	68 00 85 08 00       	push   $0x88500
8010301b:	68 c0 00 00 00       	push   $0xc0
80103020:	e8 ea fe ff ff       	call   80102f0f <lapicw>
80103025:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103028:	90                   	nop
80103029:	a1 fc 36 11 80       	mov    0x801136fc,%eax
8010302e:	05 00 03 00 00       	add    $0x300,%eax
80103033:	8b 00                	mov    (%eax),%eax
80103035:	25 00 10 00 00       	and    $0x1000,%eax
8010303a:	85 c0                	test   %eax,%eax
8010303c:	75 eb                	jne    80103029 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010303e:	6a 00                	push   $0x0
80103040:	6a 20                	push   $0x20
80103042:	e8 c8 fe ff ff       	call   80102f0f <lapicw>
80103047:	83 c4 08             	add    $0x8,%esp
8010304a:	eb 01                	jmp    8010304d <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic)
    return;
8010304c:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010304d:	c9                   	leave  
8010304e:	c3                   	ret    

8010304f <lapicid>:

int
lapicid(void)
{
8010304f:	55                   	push   %ebp
80103050:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103052:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	75 07                	jne    80103062 <lapicid+0x13>
    return 0;
8010305b:	b8 00 00 00 00       	mov    $0x0,%eax
80103060:	eb 0d                	jmp    8010306f <lapicid+0x20>
  return lapic[ID] >> 24;
80103062:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103067:	83 c0 20             	add    $0x20,%eax
8010306a:	8b 00                	mov    (%eax),%eax
8010306c:	c1 e8 18             	shr    $0x18,%eax
}
8010306f:	5d                   	pop    %ebp
80103070:	c3                   	ret    

80103071 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103071:	55                   	push   %ebp
80103072:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103074:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103079:	85 c0                	test   %eax,%eax
8010307b:	74 0c                	je     80103089 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010307d:	6a 00                	push   $0x0
8010307f:	6a 2c                	push   $0x2c
80103081:	e8 89 fe ff ff       	call   80102f0f <lapicw>
80103086:	83 c4 08             	add    $0x8,%esp
}
80103089:	90                   	nop
8010308a:	c9                   	leave  
8010308b:	c3                   	ret    

8010308c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010308c:	55                   	push   %ebp
8010308d:	89 e5                	mov    %esp,%ebp
}
8010308f:	90                   	nop
80103090:	5d                   	pop    %ebp
80103091:	c3                   	ret    

80103092 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103092:	55                   	push   %ebp
80103093:	89 e5                	mov    %esp,%ebp
80103095:	83 ec 14             	sub    $0x14,%esp
80103098:	8b 45 08             	mov    0x8(%ebp),%eax
8010309b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010309e:	6a 0f                	push   $0xf
801030a0:	6a 70                	push   $0x70
801030a2:	e8 49 fe ff ff       	call   80102ef0 <outb>
801030a7:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801030aa:	6a 0a                	push   $0xa
801030ac:	6a 71                	push   $0x71
801030ae:	e8 3d fe ff ff       	call   80102ef0 <outb>
801030b3:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030b6:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030c0:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030c8:	83 c0 02             	add    $0x2,%eax
801030cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801030ce:	c1 ea 04             	shr    $0x4,%edx
801030d1:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030d4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030d8:	c1 e0 18             	shl    $0x18,%eax
801030db:	50                   	push   %eax
801030dc:	68 c4 00 00 00       	push   $0xc4
801030e1:	e8 29 fe ff ff       	call   80102f0f <lapicw>
801030e6:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030e9:	68 00 c5 00 00       	push   $0xc500
801030ee:	68 c0 00 00 00       	push   $0xc0
801030f3:	e8 17 fe ff ff       	call   80102f0f <lapicw>
801030f8:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030fb:	68 c8 00 00 00       	push   $0xc8
80103100:	e8 87 ff ff ff       	call   8010308c <microdelay>
80103105:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103108:	68 00 85 00 00       	push   $0x8500
8010310d:	68 c0 00 00 00       	push   $0xc0
80103112:	e8 f8 fd ff ff       	call   80102f0f <lapicw>
80103117:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010311a:	6a 64                	push   $0x64
8010311c:	e8 6b ff ff ff       	call   8010308c <microdelay>
80103121:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103124:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010312b:	eb 3d                	jmp    8010316a <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010312d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103131:	c1 e0 18             	shl    $0x18,%eax
80103134:	50                   	push   %eax
80103135:	68 c4 00 00 00       	push   $0xc4
8010313a:	e8 d0 fd ff ff       	call   80102f0f <lapicw>
8010313f:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103142:	8b 45 0c             	mov    0xc(%ebp),%eax
80103145:	c1 e8 0c             	shr    $0xc,%eax
80103148:	80 cc 06             	or     $0x6,%ah
8010314b:	50                   	push   %eax
8010314c:	68 c0 00 00 00       	push   $0xc0
80103151:	e8 b9 fd ff ff       	call   80102f0f <lapicw>
80103156:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103159:	68 c8 00 00 00       	push   $0xc8
8010315e:	e8 29 ff ff ff       	call   8010308c <microdelay>
80103163:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103166:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010316a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010316e:	7e bd                	jle    8010312d <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103170:	90                   	nop
80103171:	c9                   	leave  
80103172:	c3                   	ret    

80103173 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103173:	55                   	push   %ebp
80103174:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103176:	8b 45 08             	mov    0x8(%ebp),%eax
80103179:	0f b6 c0             	movzbl %al,%eax
8010317c:	50                   	push   %eax
8010317d:	6a 70                	push   $0x70
8010317f:	e8 6c fd ff ff       	call   80102ef0 <outb>
80103184:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103187:	68 c8 00 00 00       	push   $0xc8
8010318c:	e8 fb fe ff ff       	call   8010308c <microdelay>
80103191:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103194:	6a 71                	push   $0x71
80103196:	e8 38 fd ff ff       	call   80102ed3 <inb>
8010319b:	83 c4 04             	add    $0x4,%esp
8010319e:	0f b6 c0             	movzbl %al,%eax
}
801031a1:	c9                   	leave  
801031a2:	c3                   	ret    

801031a3 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031a3:	55                   	push   %ebp
801031a4:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801031a6:	6a 00                	push   $0x0
801031a8:	e8 c6 ff ff ff       	call   80103173 <cmos_read>
801031ad:	83 c4 04             	add    $0x4,%esp
801031b0:	89 c2                	mov    %eax,%edx
801031b2:	8b 45 08             	mov    0x8(%ebp),%eax
801031b5:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801031b7:	6a 02                	push   $0x2
801031b9:	e8 b5 ff ff ff       	call   80103173 <cmos_read>
801031be:	83 c4 04             	add    $0x4,%esp
801031c1:	89 c2                	mov    %eax,%edx
801031c3:	8b 45 08             	mov    0x8(%ebp),%eax
801031c6:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801031c9:	6a 04                	push   $0x4
801031cb:	e8 a3 ff ff ff       	call   80103173 <cmos_read>
801031d0:	83 c4 04             	add    $0x4,%esp
801031d3:	89 c2                	mov    %eax,%edx
801031d5:	8b 45 08             	mov    0x8(%ebp),%eax
801031d8:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801031db:	6a 07                	push   $0x7
801031dd:	e8 91 ff ff ff       	call   80103173 <cmos_read>
801031e2:	83 c4 04             	add    $0x4,%esp
801031e5:	89 c2                	mov    %eax,%edx
801031e7:	8b 45 08             	mov    0x8(%ebp),%eax
801031ea:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031ed:	6a 08                	push   $0x8
801031ef:	e8 7f ff ff ff       	call   80103173 <cmos_read>
801031f4:	83 c4 04             	add    $0x4,%esp
801031f7:	89 c2                	mov    %eax,%edx
801031f9:	8b 45 08             	mov    0x8(%ebp),%eax
801031fc:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031ff:	6a 09                	push   $0x9
80103201:	e8 6d ff ff ff       	call   80103173 <cmos_read>
80103206:	83 c4 04             	add    $0x4,%esp
80103209:	89 c2                	mov    %eax,%edx
8010320b:	8b 45 08             	mov    0x8(%ebp),%eax
8010320e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103211:	90                   	nop
80103212:	c9                   	leave  
80103213:	c3                   	ret    

80103214 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103214:	55                   	push   %ebp
80103215:	89 e5                	mov    %esp,%ebp
80103217:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010321a:	6a 0b                	push   $0xb
8010321c:	e8 52 ff ff ff       	call   80103173 <cmos_read>
80103221:	83 c4 04             	add    $0x4,%esp
80103224:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010322a:	83 e0 04             	and    $0x4,%eax
8010322d:	85 c0                	test   %eax,%eax
8010322f:	0f 94 c0             	sete   %al
80103232:	0f b6 c0             	movzbl %al,%eax
80103235:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103238:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010323b:	50                   	push   %eax
8010323c:	e8 62 ff ff ff       	call   801031a3 <fill_rtcdate>
80103241:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103244:	6a 0a                	push   $0xa
80103246:	e8 28 ff ff ff       	call   80103173 <cmos_read>
8010324b:	83 c4 04             	add    $0x4,%esp
8010324e:	25 80 00 00 00       	and    $0x80,%eax
80103253:	85 c0                	test   %eax,%eax
80103255:	75 27                	jne    8010327e <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103257:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010325a:	50                   	push   %eax
8010325b:	e8 43 ff ff ff       	call   801031a3 <fill_rtcdate>
80103260:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103263:	83 ec 04             	sub    $0x4,%esp
80103266:	6a 18                	push   $0x18
80103268:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010326b:	50                   	push   %eax
8010326c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010326f:	50                   	push   %eax
80103270:	e8 69 20 00 00       	call   801052de <memcmp>
80103275:	83 c4 10             	add    $0x10,%esp
80103278:	85 c0                	test   %eax,%eax
8010327a:	74 05                	je     80103281 <cmostime+0x6d>
8010327c:	eb ba                	jmp    80103238 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010327e:	90                   	nop
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010327f:	eb b7                	jmp    80103238 <cmostime+0x24>
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103281:	90                   	nop
  }

  // convert
  if(bcd) {
80103282:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103286:	0f 84 b4 00 00 00    	je     80103340 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010328c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010328f:	c1 e8 04             	shr    $0x4,%eax
80103292:	89 c2                	mov    %eax,%edx
80103294:	89 d0                	mov    %edx,%eax
80103296:	c1 e0 02             	shl    $0x2,%eax
80103299:	01 d0                	add    %edx,%eax
8010329b:	01 c0                	add    %eax,%eax
8010329d:	89 c2                	mov    %eax,%edx
8010329f:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032a2:	83 e0 0f             	and    $0xf,%eax
801032a5:	01 d0                	add    %edx,%eax
801032a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801032aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032ad:	c1 e8 04             	shr    $0x4,%eax
801032b0:	89 c2                	mov    %eax,%edx
801032b2:	89 d0                	mov    %edx,%eax
801032b4:	c1 e0 02             	shl    $0x2,%eax
801032b7:	01 d0                	add    %edx,%eax
801032b9:	01 c0                	add    %eax,%eax
801032bb:	89 c2                	mov    %eax,%edx
801032bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032c0:	83 e0 0f             	and    $0xf,%eax
801032c3:	01 d0                	add    %edx,%eax
801032c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032cb:	c1 e8 04             	shr    $0x4,%eax
801032ce:	89 c2                	mov    %eax,%edx
801032d0:	89 d0                	mov    %edx,%eax
801032d2:	c1 e0 02             	shl    $0x2,%eax
801032d5:	01 d0                	add    %edx,%eax
801032d7:	01 c0                	add    %eax,%eax
801032d9:	89 c2                	mov    %eax,%edx
801032db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032de:	83 e0 0f             	and    $0xf,%eax
801032e1:	01 d0                	add    %edx,%eax
801032e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032e9:	c1 e8 04             	shr    $0x4,%eax
801032ec:	89 c2                	mov    %eax,%edx
801032ee:	89 d0                	mov    %edx,%eax
801032f0:	c1 e0 02             	shl    $0x2,%eax
801032f3:	01 d0                	add    %edx,%eax
801032f5:	01 c0                	add    %eax,%eax
801032f7:	89 c2                	mov    %eax,%edx
801032f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032fc:	83 e0 0f             	and    $0xf,%eax
801032ff:	01 d0                	add    %edx,%eax
80103301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103304:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103307:	c1 e8 04             	shr    $0x4,%eax
8010330a:	89 c2                	mov    %eax,%edx
8010330c:	89 d0                	mov    %edx,%eax
8010330e:	c1 e0 02             	shl    $0x2,%eax
80103311:	01 d0                	add    %edx,%eax
80103313:	01 c0                	add    %eax,%eax
80103315:	89 c2                	mov    %eax,%edx
80103317:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010331a:	83 e0 0f             	and    $0xf,%eax
8010331d:	01 d0                	add    %edx,%eax
8010331f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103322:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103325:	c1 e8 04             	shr    $0x4,%eax
80103328:	89 c2                	mov    %eax,%edx
8010332a:	89 d0                	mov    %edx,%eax
8010332c:	c1 e0 02             	shl    $0x2,%eax
8010332f:	01 d0                	add    %edx,%eax
80103331:	01 c0                	add    %eax,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103338:	83 e0 0f             	and    $0xf,%eax
8010333b:	01 d0                	add    %edx,%eax
8010333d:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103340:	8b 45 08             	mov    0x8(%ebp),%eax
80103343:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103346:	89 10                	mov    %edx,(%eax)
80103348:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010334b:	89 50 04             	mov    %edx,0x4(%eax)
8010334e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103351:	89 50 08             	mov    %edx,0x8(%eax)
80103354:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103357:	89 50 0c             	mov    %edx,0xc(%eax)
8010335a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010335d:	89 50 10             	mov    %edx,0x10(%eax)
80103360:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103363:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103366:	8b 45 08             	mov    0x8(%ebp),%eax
80103369:	8b 40 14             	mov    0x14(%eax),%eax
8010336c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103372:	8b 45 08             	mov    0x8(%ebp),%eax
80103375:	89 50 14             	mov    %edx,0x14(%eax)
}
80103378:	90                   	nop
80103379:	c9                   	leave  
8010337a:	c3                   	ret    

8010337b <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010337b:	55                   	push   %ebp
8010337c:	89 e5                	mov    %esp,%ebp
8010337e:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103381:	83 ec 08             	sub    $0x8,%esp
80103384:	68 85 89 10 80       	push   $0x80108985
80103389:	68 00 37 11 80       	push   $0x80113700
8010338e:	e8 4b 1c 00 00       	call   80104fde <initlock>
80103393:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103396:	83 ec 08             	sub    $0x8,%esp
80103399:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010339c:	50                   	push   %eax
8010339d:	ff 75 08             	pushl  0x8(%ebp)
801033a0:	e8 a3 e0 ff ff       	call   80101448 <readsb>
801033a5:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ab:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
801033b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033b3:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
801033b8:	8b 45 08             	mov    0x8(%ebp),%eax
801033bb:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
801033c0:	e8 b2 01 00 00       	call   80103577 <recover_from_log>
}
801033c5:	90                   	nop
801033c6:	c9                   	leave  
801033c7:	c3                   	ret    

801033c8 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801033c8:	55                   	push   %ebp
801033c9:	89 e5                	mov    %esp,%ebp
801033cb:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033d5:	e9 95 00 00 00       	jmp    8010346f <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033da:	8b 15 34 37 11 80    	mov    0x80113734,%edx
801033e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033e3:	01 d0                	add    %edx,%eax
801033e5:	83 c0 01             	add    $0x1,%eax
801033e8:	89 c2                	mov    %eax,%edx
801033ea:	a1 44 37 11 80       	mov    0x80113744,%eax
801033ef:	83 ec 08             	sub    $0x8,%esp
801033f2:	52                   	push   %edx
801033f3:	50                   	push   %eax
801033f4:	e8 d5 cd ff ff       	call   801001ce <bread>
801033f9:	83 c4 10             	add    $0x10,%esp
801033fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103402:	83 c0 10             	add    $0x10,%eax
80103405:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010340c:	89 c2                	mov    %eax,%edx
8010340e:	a1 44 37 11 80       	mov    0x80113744,%eax
80103413:	83 ec 08             	sub    $0x8,%esp
80103416:	52                   	push   %edx
80103417:	50                   	push   %eax
80103418:	e8 b1 cd ff ff       	call   801001ce <bread>
8010341d:	83 c4 10             	add    $0x10,%esp
80103420:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103426:	8d 50 5c             	lea    0x5c(%eax),%edx
80103429:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	83 ec 04             	sub    $0x4,%esp
80103432:	68 00 02 00 00       	push   $0x200
80103437:	52                   	push   %edx
80103438:	50                   	push   %eax
80103439:	e8 f8 1e 00 00       	call   80105336 <memmove>
8010343e:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103441:	83 ec 0c             	sub    $0xc,%esp
80103444:	ff 75 ec             	pushl  -0x14(%ebp)
80103447:	e8 bb cd ff ff       	call   80100207 <bwrite>
8010344c:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010344f:	83 ec 0c             	sub    $0xc,%esp
80103452:	ff 75 f0             	pushl  -0x10(%ebp)
80103455:	e8 f6 cd ff ff       	call   80100250 <brelse>
8010345a:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010345d:	83 ec 0c             	sub    $0xc,%esp
80103460:	ff 75 ec             	pushl  -0x14(%ebp)
80103463:	e8 e8 cd ff ff       	call   80100250 <brelse>
80103468:	83 c4 10             	add    $0x10,%esp
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010346b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010346f:	a1 48 37 11 80       	mov    0x80113748,%eax
80103474:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103477:	0f 8f 5d ff ff ff    	jg     801033da <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
8010347d:	90                   	nop
8010347e:	c9                   	leave  
8010347f:	c3                   	ret    

80103480 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103480:	55                   	push   %ebp
80103481:	89 e5                	mov    %esp,%ebp
80103483:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103486:	a1 34 37 11 80       	mov    0x80113734,%eax
8010348b:	89 c2                	mov    %eax,%edx
8010348d:	a1 44 37 11 80       	mov    0x80113744,%eax
80103492:	83 ec 08             	sub    $0x8,%esp
80103495:	52                   	push   %edx
80103496:	50                   	push   %eax
80103497:	e8 32 cd ff ff       	call   801001ce <bread>
8010349c:	83 c4 10             	add    $0x10,%esp
8010349f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a5:	83 c0 5c             	add    $0x5c,%eax
801034a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ae:	8b 00                	mov    (%eax),%eax
801034b0:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
801034b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034bc:	eb 1b                	jmp    801034d9 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
801034be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c4:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cb:	83 c2 10             	add    $0x10,%edx
801034ce:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d9:	a1 48 37 11 80       	mov    0x80113748,%eax
801034de:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034e1:	7f db                	jg     801034be <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801034e3:	83 ec 0c             	sub    $0xc,%esp
801034e6:	ff 75 f0             	pushl  -0x10(%ebp)
801034e9:	e8 62 cd ff ff       	call   80100250 <brelse>
801034ee:	83 c4 10             	add    $0x10,%esp
}
801034f1:	90                   	nop
801034f2:	c9                   	leave  
801034f3:	c3                   	ret    

801034f4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034f4:	55                   	push   %ebp
801034f5:	89 e5                	mov    %esp,%ebp
801034f7:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034fa:	a1 34 37 11 80       	mov    0x80113734,%eax
801034ff:	89 c2                	mov    %eax,%edx
80103501:	a1 44 37 11 80       	mov    0x80113744,%eax
80103506:	83 ec 08             	sub    $0x8,%esp
80103509:	52                   	push   %edx
8010350a:	50                   	push   %eax
8010350b:	e8 be cc ff ff       	call   801001ce <bread>
80103510:	83 c4 10             	add    $0x10,%esp
80103513:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103519:	83 c0 5c             	add    $0x5c,%eax
8010351c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010351f:	8b 15 48 37 11 80    	mov    0x80113748,%edx
80103525:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103528:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010352a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103531:	eb 1b                	jmp    8010354e <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103536:	83 c0 10             	add    $0x10,%eax
80103539:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
80103540:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103543:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103546:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010354a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010354e:	a1 48 37 11 80       	mov    0x80113748,%eax
80103553:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103556:	7f db                	jg     80103533 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103558:	83 ec 0c             	sub    $0xc,%esp
8010355b:	ff 75 f0             	pushl  -0x10(%ebp)
8010355e:	e8 a4 cc ff ff       	call   80100207 <bwrite>
80103563:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103566:	83 ec 0c             	sub    $0xc,%esp
80103569:	ff 75 f0             	pushl  -0x10(%ebp)
8010356c:	e8 df cc ff ff       	call   80100250 <brelse>
80103571:	83 c4 10             	add    $0x10,%esp
}
80103574:	90                   	nop
80103575:	c9                   	leave  
80103576:	c3                   	ret    

80103577 <recover_from_log>:

static void
recover_from_log(void)
{
80103577:	55                   	push   %ebp
80103578:	89 e5                	mov    %esp,%ebp
8010357a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010357d:	e8 fe fe ff ff       	call   80103480 <read_head>
  install_trans(); // if committed, copy from log to disk
80103582:	e8 41 fe ff ff       	call   801033c8 <install_trans>
  log.lh.n = 0;
80103587:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
8010358e:	00 00 00 
  write_head(); // clear the log
80103591:	e8 5e ff ff ff       	call   801034f4 <write_head>
}
80103596:	90                   	nop
80103597:	c9                   	leave  
80103598:	c3                   	ret    

80103599 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103599:	55                   	push   %ebp
8010359a:	89 e5                	mov    %esp,%ebp
8010359c:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010359f:	83 ec 0c             	sub    $0xc,%esp
801035a2:	68 00 37 11 80       	push   $0x80113700
801035a7:	e8 54 1a 00 00       	call   80105000 <acquire>
801035ac:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801035af:	a1 40 37 11 80       	mov    0x80113740,%eax
801035b4:	85 c0                	test   %eax,%eax
801035b6:	74 17                	je     801035cf <begin_op+0x36>
      sleep(&log, &log.lock);
801035b8:	83 ec 08             	sub    $0x8,%esp
801035bb:	68 00 37 11 80       	push   $0x80113700
801035c0:	68 00 37 11 80       	push   $0x80113700
801035c5:	e8 14 16 00 00       	call   80104bde <sleep>
801035ca:	83 c4 10             	add    $0x10,%esp
801035cd:	eb e0                	jmp    801035af <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035cf:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
801035d5:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801035da:	8d 50 01             	lea    0x1(%eax),%edx
801035dd:	89 d0                	mov    %edx,%eax
801035df:	c1 e0 02             	shl    $0x2,%eax
801035e2:	01 d0                	add    %edx,%eax
801035e4:	01 c0                	add    %eax,%eax
801035e6:	01 c8                	add    %ecx,%eax
801035e8:	83 f8 1e             	cmp    $0x1e,%eax
801035eb:	7e 17                	jle    80103604 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035ed:	83 ec 08             	sub    $0x8,%esp
801035f0:	68 00 37 11 80       	push   $0x80113700
801035f5:	68 00 37 11 80       	push   $0x80113700
801035fa:	e8 df 15 00 00       	call   80104bde <sleep>
801035ff:	83 c4 10             	add    $0x10,%esp
80103602:	eb ab                	jmp    801035af <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103604:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103609:	83 c0 01             	add    $0x1,%eax
8010360c:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
80103611:	83 ec 0c             	sub    $0xc,%esp
80103614:	68 00 37 11 80       	push   $0x80113700
80103619:	e8 50 1a 00 00       	call   8010506e <release>
8010361e:	83 c4 10             	add    $0x10,%esp
      break;
80103621:	90                   	nop
    }
  }
}
80103622:	90                   	nop
80103623:	c9                   	leave  
80103624:	c3                   	ret    

80103625 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103625:	55                   	push   %ebp
80103626:	89 e5                	mov    %esp,%ebp
80103628:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010362b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103632:	83 ec 0c             	sub    $0xc,%esp
80103635:	68 00 37 11 80       	push   $0x80113700
8010363a:	e8 c1 19 00 00       	call   80105000 <acquire>
8010363f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103642:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103647:	83 e8 01             	sub    $0x1,%eax
8010364a:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
8010364f:	a1 40 37 11 80       	mov    0x80113740,%eax
80103654:	85 c0                	test   %eax,%eax
80103656:	74 0d                	je     80103665 <end_op+0x40>
    panic("log.committing");
80103658:	83 ec 0c             	sub    $0xc,%esp
8010365b:	68 89 89 10 80       	push   $0x80108989
80103660:	e8 3b cf ff ff       	call   801005a0 <panic>
  if(log.outstanding == 0){
80103665:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010366a:	85 c0                	test   %eax,%eax
8010366c:	75 13                	jne    80103681 <end_op+0x5c>
    do_commit = 1;
8010366e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103675:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
8010367c:	00 00 00 
8010367f:	eb 10                	jmp    80103691 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103681:	83 ec 0c             	sub    $0xc,%esp
80103684:	68 00 37 11 80       	push   $0x80113700
80103689:	e8 39 16 00 00       	call   80104cc7 <wakeup>
8010368e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103691:	83 ec 0c             	sub    $0xc,%esp
80103694:	68 00 37 11 80       	push   $0x80113700
80103699:	e8 d0 19 00 00       	call   8010506e <release>
8010369e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036a5:	74 3f                	je     801036e6 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036a7:	e8 f5 00 00 00       	call   801037a1 <commit>
    acquire(&log.lock);
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	68 00 37 11 80       	push   $0x80113700
801036b4:	e8 47 19 00 00       	call   80105000 <acquire>
801036b9:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801036bc:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
801036c3:	00 00 00 
    wakeup(&log);
801036c6:	83 ec 0c             	sub    $0xc,%esp
801036c9:	68 00 37 11 80       	push   $0x80113700
801036ce:	e8 f4 15 00 00       	call   80104cc7 <wakeup>
801036d3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036d6:	83 ec 0c             	sub    $0xc,%esp
801036d9:	68 00 37 11 80       	push   $0x80113700
801036de:	e8 8b 19 00 00       	call   8010506e <release>
801036e3:	83 c4 10             	add    $0x10,%esp
  }
}
801036e6:	90                   	nop
801036e7:	c9                   	leave  
801036e8:	c3                   	ret    

801036e9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801036e9:	55                   	push   %ebp
801036ea:	89 e5                	mov    %esp,%ebp
801036ec:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036f6:	e9 95 00 00 00       	jmp    80103790 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036fb:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103704:	01 d0                	add    %edx,%eax
80103706:	83 c0 01             	add    $0x1,%eax
80103709:	89 c2                	mov    %eax,%edx
8010370b:	a1 44 37 11 80       	mov    0x80113744,%eax
80103710:	83 ec 08             	sub    $0x8,%esp
80103713:	52                   	push   %edx
80103714:	50                   	push   %eax
80103715:	e8 b4 ca ff ff       	call   801001ce <bread>
8010371a:	83 c4 10             	add    $0x10,%esp
8010371d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103723:	83 c0 10             	add    $0x10,%eax
80103726:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010372d:	89 c2                	mov    %eax,%edx
8010372f:	a1 44 37 11 80       	mov    0x80113744,%eax
80103734:	83 ec 08             	sub    $0x8,%esp
80103737:	52                   	push   %edx
80103738:	50                   	push   %eax
80103739:	e8 90 ca ff ff       	call   801001ce <bread>
8010373e:	83 c4 10             	add    $0x10,%esp
80103741:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103744:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103747:	8d 50 5c             	lea    0x5c(%eax),%edx
8010374a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010374d:	83 c0 5c             	add    $0x5c,%eax
80103750:	83 ec 04             	sub    $0x4,%esp
80103753:	68 00 02 00 00       	push   $0x200
80103758:	52                   	push   %edx
80103759:	50                   	push   %eax
8010375a:	e8 d7 1b 00 00       	call   80105336 <memmove>
8010375f:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103762:	83 ec 0c             	sub    $0xc,%esp
80103765:	ff 75 f0             	pushl  -0x10(%ebp)
80103768:	e8 9a ca ff ff       	call   80100207 <bwrite>
8010376d:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103770:	83 ec 0c             	sub    $0xc,%esp
80103773:	ff 75 ec             	pushl  -0x14(%ebp)
80103776:	e8 d5 ca ff ff       	call   80100250 <brelse>
8010377b:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010377e:	83 ec 0c             	sub    $0xc,%esp
80103781:	ff 75 f0             	pushl  -0x10(%ebp)
80103784:	e8 c7 ca ff ff       	call   80100250 <brelse>
80103789:	83 c4 10             	add    $0x10,%esp
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010378c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103790:	a1 48 37 11 80       	mov    0x80113748,%eax
80103795:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103798:	0f 8f 5d ff ff ff    	jg     801036fb <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
8010379e:	90                   	nop
8010379f:	c9                   	leave  
801037a0:	c3                   	ret    

801037a1 <commit>:

static void
commit()
{
801037a1:	55                   	push   %ebp
801037a2:	89 e5                	mov    %esp,%ebp
801037a4:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037a7:	a1 48 37 11 80       	mov    0x80113748,%eax
801037ac:	85 c0                	test   %eax,%eax
801037ae:	7e 1e                	jle    801037ce <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037b0:	e8 34 ff ff ff       	call   801036e9 <write_log>
    write_head();    // Write header to disk -- the real commit
801037b5:	e8 3a fd ff ff       	call   801034f4 <write_head>
    install_trans(); // Now install writes to home locations
801037ba:	e8 09 fc ff ff       	call   801033c8 <install_trans>
    log.lh.n = 0;
801037bf:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
801037c6:	00 00 00 
    write_head();    // Erase the transaction from the log
801037c9:	e8 26 fd ff ff       	call   801034f4 <write_head>
  }
}
801037ce:	90                   	nop
801037cf:	c9                   	leave  
801037d0:	c3                   	ret    

801037d1 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037d1:	55                   	push   %ebp
801037d2:	89 e5                	mov    %esp,%ebp
801037d4:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037d7:	a1 48 37 11 80       	mov    0x80113748,%eax
801037dc:	83 f8 1d             	cmp    $0x1d,%eax
801037df:	7f 12                	jg     801037f3 <log_write+0x22>
801037e1:	a1 48 37 11 80       	mov    0x80113748,%eax
801037e6:	8b 15 38 37 11 80    	mov    0x80113738,%edx
801037ec:	83 ea 01             	sub    $0x1,%edx
801037ef:	39 d0                	cmp    %edx,%eax
801037f1:	7c 0d                	jl     80103800 <log_write+0x2f>
    panic("too big a transaction");
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	68 98 89 10 80       	push   $0x80108998
801037fb:	e8 a0 cd ff ff       	call   801005a0 <panic>
  if (log.outstanding < 1)
80103800:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103805:	85 c0                	test   %eax,%eax
80103807:	7f 0d                	jg     80103816 <log_write+0x45>
    panic("log_write outside of trans");
80103809:	83 ec 0c             	sub    $0xc,%esp
8010380c:	68 ae 89 10 80       	push   $0x801089ae
80103811:	e8 8a cd ff ff       	call   801005a0 <panic>

  acquire(&log.lock);
80103816:	83 ec 0c             	sub    $0xc,%esp
80103819:	68 00 37 11 80       	push   $0x80113700
8010381e:	e8 dd 17 00 00       	call   80105000 <acquire>
80103823:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103826:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010382d:	eb 1d                	jmp    8010384c <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010382f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103832:	83 c0 10             	add    $0x10,%eax
80103835:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010383c:	89 c2                	mov    %eax,%edx
8010383e:	8b 45 08             	mov    0x8(%ebp),%eax
80103841:	8b 40 08             	mov    0x8(%eax),%eax
80103844:	39 c2                	cmp    %eax,%edx
80103846:	74 10                	je     80103858 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103848:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010384c:	a1 48 37 11 80       	mov    0x80113748,%eax
80103851:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103854:	7f d9                	jg     8010382f <log_write+0x5e>
80103856:	eb 01                	jmp    80103859 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103858:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103859:	8b 45 08             	mov    0x8(%ebp),%eax
8010385c:	8b 40 08             	mov    0x8(%eax),%eax
8010385f:	89 c2                	mov    %eax,%edx
80103861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103864:	83 c0 10             	add    $0x10,%eax
80103867:	89 14 85 0c 37 11 80 	mov    %edx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
8010386e:	a1 48 37 11 80       	mov    0x80113748,%eax
80103873:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103876:	75 0d                	jne    80103885 <log_write+0xb4>
    log.lh.n++;
80103878:	a1 48 37 11 80       	mov    0x80113748,%eax
8010387d:	83 c0 01             	add    $0x1,%eax
80103880:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
80103885:	8b 45 08             	mov    0x8(%ebp),%eax
80103888:	8b 00                	mov    (%eax),%eax
8010388a:	83 c8 04             	or     $0x4,%eax
8010388d:	89 c2                	mov    %eax,%edx
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103894:	83 ec 0c             	sub    $0xc,%esp
80103897:	68 00 37 11 80       	push   $0x80113700
8010389c:	e8 cd 17 00 00       	call   8010506e <release>
801038a1:	83 c4 10             	add    $0x10,%esp
}
801038a4:	90                   	nop
801038a5:	c9                   	leave  
801038a6:	c3                   	ret    

801038a7 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038a7:	55                   	push   %ebp
801038a8:	89 e5                	mov    %esp,%ebp
801038aa:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038ad:	8b 55 08             	mov    0x8(%ebp),%edx
801038b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801038b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038b6:	f0 87 02             	lock xchg %eax,(%edx)
801038b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038bf:	c9                   	leave  
801038c0:	c3                   	ret    

801038c1 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038c1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038c5:	83 e4 f0             	and    $0xfffffff0,%esp
801038c8:	ff 71 fc             	pushl  -0x4(%ecx)
801038cb:	55                   	push   %ebp
801038cc:	89 e5                	mov    %esp,%ebp
801038ce:	51                   	push   %ecx
801038cf:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038d2:	83 ec 08             	sub    $0x8,%esp
801038d5:	68 00 00 40 80       	push   $0x80400000
801038da:	68 74 6a 11 80       	push   $0x80116a74
801038df:	e8 e1 f2 ff ff       	call   80102bc5 <kinit1>
801038e4:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038e7:	e8 8b 44 00 00       	call   80107d77 <kvmalloc>
  mpinit();        // detect other processors
801038ec:	e8 bf 03 00 00       	call   80103cb0 <mpinit>
  lapicinit();     // interrupt controller
801038f1:	e8 3b f6 ff ff       	call   80102f31 <lapicinit>
  seginit();       // segment descriptors
801038f6:	e8 54 3f 00 00       	call   8010784f <seginit>
  picinit();       // disable pic
801038fb:	e8 01 05 00 00       	call   80103e01 <picinit>
  ioapicinit();    // another interrupt controller
80103900:	e8 dc f1 ff ff       	call   80102ae1 <ioapicinit>
  consoleinit();   // console hardware
80103905:	e8 41 d2 ff ff       	call   80100b4b <consoleinit>
  uartinit();      // serial port
8010390a:	e8 d9 32 00 00       	call   80106be8 <uartinit>
  pinit();         // process table
8010390f:	e8 26 09 00 00       	call   8010423a <pinit>
  shminit();       // shared memory
80103914:	e8 30 4d 00 00       	call   80108649 <shminit>
  tvinit();        // trap vectors
80103919:	e8 91 2d 00 00       	call   801066af <tvinit>
  binit();         // buffer cache
8010391e:	e8 11 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103923:	e8 11 d7 ff ff       	call   80101039 <fileinit>
  ideinit();       // disk 
80103928:	e8 8b ed ff ff       	call   801026b8 <ideinit>
  startothers();   // start other processors
8010392d:	e8 80 00 00 00       	call   801039b2 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103932:	83 ec 08             	sub    $0x8,%esp
80103935:	68 00 00 00 8e       	push   $0x8e000000
8010393a:	68 00 00 40 80       	push   $0x80400000
8010393f:	e8 ba f2 ff ff       	call   80102bfe <kinit2>
80103944:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103947:	e8 d7 0a 00 00       	call   80104423 <userinit>
  mpmain();        // finish this processor's setup
8010394c:	e8 1a 00 00 00       	call   8010396b <mpmain>

80103951 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103951:	55                   	push   %ebp
80103952:	89 e5                	mov    %esp,%ebp
80103954:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103957:	e8 33 44 00 00       	call   80107d8f <switchkvm>
  seginit();
8010395c:	e8 ee 3e 00 00       	call   8010784f <seginit>
  lapicinit();
80103961:	e8 cb f5 ff ff       	call   80102f31 <lapicinit>
  mpmain();
80103966:	e8 00 00 00 00       	call   8010396b <mpmain>

8010396b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010396b:	55                   	push   %ebp
8010396c:	89 e5                	mov    %esp,%ebp
8010396e:	53                   	push   %ebx
8010396f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103972:	e8 e1 08 00 00       	call   80104258 <cpuid>
80103977:	89 c3                	mov    %eax,%ebx
80103979:	e8 da 08 00 00       	call   80104258 <cpuid>
8010397e:	83 ec 04             	sub    $0x4,%esp
80103981:	53                   	push   %ebx
80103982:	50                   	push   %eax
80103983:	68 c9 89 10 80       	push   $0x801089c9
80103988:	e8 73 ca ff ff       	call   80100400 <cprintf>
8010398d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103990:	e8 90 2e 00 00       	call   80106825 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103995:	e8 df 08 00 00       	call   80104279 <mycpu>
8010399a:	05 a0 00 00 00       	add    $0xa0,%eax
8010399f:	83 ec 08             	sub    $0x8,%esp
801039a2:	6a 01                	push   $0x1
801039a4:	50                   	push   %eax
801039a5:	e8 fd fe ff ff       	call   801038a7 <xchg>
801039aa:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039ad:	e8 36 10 00 00       	call   801049e8 <scheduler>

801039b2 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039b2:	55                   	push   %ebp
801039b3:	89 e5                	mov    %esp,%ebp
801039b5:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801039b8:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039bf:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039c4:	83 ec 04             	sub    $0x4,%esp
801039c7:	50                   	push   %eax
801039c8:	68 ec b4 10 80       	push   $0x8010b4ec
801039cd:	ff 75 f0             	pushl  -0x10(%ebp)
801039d0:	e8 61 19 00 00       	call   80105336 <memmove>
801039d5:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039d8:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
801039df:	eb 79                	jmp    80103a5a <startothers+0xa8>
    if(c == mycpu())  // We've started already.
801039e1:	e8 93 08 00 00       	call   80104279 <mycpu>
801039e6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039e9:	74 67                	je     80103a52 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039eb:	e8 09 f3 ff ff       	call   80102cf9 <kalloc>
801039f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f6:	83 e8 04             	sub    $0x4,%eax
801039f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039fc:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a02:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a07:	83 e8 08             	sub    $0x8,%eax
80103a0a:	c7 00 51 39 10 80    	movl   $0x80103951,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a13:	83 e8 0c             	sub    $0xc,%eax
80103a16:	ba 00 a0 10 80       	mov    $0x8010a000,%edx
80103a1b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80103a21:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a26:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2f:	0f b6 00             	movzbl (%eax),%eax
80103a32:	0f b6 c0             	movzbl %al,%eax
80103a35:	83 ec 08             	sub    $0x8,%esp
80103a38:	52                   	push   %edx
80103a39:	50                   	push   %eax
80103a3a:	e8 53 f6 ff ff       	call   80103092 <lapicstartap>
80103a3f:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a42:	90                   	nop
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a4c:	85 c0                	test   %eax,%eax
80103a4e:	74 f3                	je     80103a43 <startothers+0x91>
80103a50:	eb 01                	jmp    80103a53 <startothers+0xa1>
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == mycpu())  // We've started already.
      continue;
80103a52:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a53:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a5a:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103a5f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a65:	05 00 38 11 80       	add    $0x80113800,%eax
80103a6a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a6d:	0f 87 6e ff ff ff    	ja     801039e1 <startothers+0x2f>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a73:	90                   	nop
80103a74:	c9                   	leave  
80103a75:	c3                   	ret    

80103a76 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a76:	55                   	push   %ebp
80103a77:	89 e5                	mov    %esp,%ebp
80103a79:	83 ec 14             	sub    $0x14,%esp
80103a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a83:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a87:	89 c2                	mov    %eax,%edx
80103a89:	ec                   	in     (%dx),%al
80103a8a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a8d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a91:	c9                   	leave  
80103a92:	c3                   	ret    

80103a93 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a93:	55                   	push   %ebp
80103a94:	89 e5                	mov    %esp,%ebp
80103a96:	83 ec 08             	sub    $0x8,%esp
80103a99:	8b 55 08             	mov    0x8(%ebp),%edx
80103a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a9f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aa3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103aa6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103aaa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103aae:	ee                   	out    %al,(%dx)
}
80103aaf:	90                   	nop
80103ab0:	c9                   	leave  
80103ab1:	c3                   	ret    

80103ab2 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103ab2:	55                   	push   %ebp
80103ab3:	89 e5                	mov    %esp,%ebp
80103ab5:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103ab8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103abf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103ac6:	eb 15                	jmp    80103add <sum+0x2b>
    sum += addr[i];
80103ac8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103acb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ace:	01 d0                	add    %edx,%eax
80103ad0:	0f b6 00             	movzbl (%eax),%eax
80103ad3:	0f b6 c0             	movzbl %al,%eax
80103ad6:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103ad9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103add:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103ae0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ae3:	7c e3                	jl     80103ac8 <sum+0x16>
    sum += addr[i];
  return sum;
80103ae5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ae8:	c9                   	leave  
80103ae9:	c3                   	ret    

80103aea <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103aea:	55                   	push   %ebp
80103aeb:	89 e5                	mov    %esp,%ebp
80103aed:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103af0:	8b 45 08             	mov    0x8(%ebp),%eax
80103af3:	05 00 00 00 80       	add    $0x80000000,%eax
80103af8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103afb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b01:	01 d0                	add    %edx,%eax
80103b03:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b0c:	eb 36                	jmp    80103b44 <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b0e:	83 ec 04             	sub    $0x4,%esp
80103b11:	6a 04                	push   $0x4
80103b13:	68 e0 89 10 80       	push   $0x801089e0
80103b18:	ff 75 f4             	pushl  -0xc(%ebp)
80103b1b:	e8 be 17 00 00       	call   801052de <memcmp>
80103b20:	83 c4 10             	add    $0x10,%esp
80103b23:	85 c0                	test   %eax,%eax
80103b25:	75 19                	jne    80103b40 <mpsearch1+0x56>
80103b27:	83 ec 08             	sub    $0x8,%esp
80103b2a:	6a 10                	push   $0x10
80103b2c:	ff 75 f4             	pushl  -0xc(%ebp)
80103b2f:	e8 7e ff ff ff       	call   80103ab2 <sum>
80103b34:	83 c4 10             	add    $0x10,%esp
80103b37:	84 c0                	test   %al,%al
80103b39:	75 05                	jne    80103b40 <mpsearch1+0x56>
      return (struct mp*)p;
80103b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3e:	eb 11                	jmp    80103b51 <mpsearch1+0x67>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b40:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b47:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b4a:	72 c2                	jb     80103b0e <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b51:	c9                   	leave  
80103b52:	c3                   	ret    

80103b53 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b53:	55                   	push   %ebp
80103b54:	89 e5                	mov    %esp,%ebp
80103b56:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b59:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	83 c0 0f             	add    $0xf,%eax
80103b66:	0f b6 00             	movzbl (%eax),%eax
80103b69:	0f b6 c0             	movzbl %al,%eax
80103b6c:	c1 e0 08             	shl    $0x8,%eax
80103b6f:	89 c2                	mov    %eax,%edx
80103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b74:	83 c0 0e             	add    $0xe,%eax
80103b77:	0f b6 00             	movzbl (%eax),%eax
80103b7a:	0f b6 c0             	movzbl %al,%eax
80103b7d:	09 d0                	or     %edx,%eax
80103b7f:	c1 e0 04             	shl    $0x4,%eax
80103b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b85:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b89:	74 21                	je     80103bac <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b8b:	83 ec 08             	sub    $0x8,%esp
80103b8e:	68 00 04 00 00       	push   $0x400
80103b93:	ff 75 f0             	pushl  -0x10(%ebp)
80103b96:	e8 4f ff ff ff       	call   80103aea <mpsearch1>
80103b9b:	83 c4 10             	add    $0x10,%esp
80103b9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ba1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ba5:	74 51                	je     80103bf8 <mpsearch+0xa5>
      return mp;
80103ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103baa:	eb 61                	jmp    80103c0d <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baf:	83 c0 14             	add    $0x14,%eax
80103bb2:	0f b6 00             	movzbl (%eax),%eax
80103bb5:	0f b6 c0             	movzbl %al,%eax
80103bb8:	c1 e0 08             	shl    $0x8,%eax
80103bbb:	89 c2                	mov    %eax,%edx
80103bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc0:	83 c0 13             	add    $0x13,%eax
80103bc3:	0f b6 00             	movzbl (%eax),%eax
80103bc6:	0f b6 c0             	movzbl %al,%eax
80103bc9:	09 d0                	or     %edx,%eax
80103bcb:	c1 e0 0a             	shl    $0xa,%eax
80103bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd4:	2d 00 04 00 00       	sub    $0x400,%eax
80103bd9:	83 ec 08             	sub    $0x8,%esp
80103bdc:	68 00 04 00 00       	push   $0x400
80103be1:	50                   	push   %eax
80103be2:	e8 03 ff ff ff       	call   80103aea <mpsearch1>
80103be7:	83 c4 10             	add    $0x10,%esp
80103bea:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bf1:	74 05                	je     80103bf8 <mpsearch+0xa5>
      return mp;
80103bf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf6:	eb 15                	jmp    80103c0d <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bf8:	83 ec 08             	sub    $0x8,%esp
80103bfb:	68 00 00 01 00       	push   $0x10000
80103c00:	68 00 00 0f 00       	push   $0xf0000
80103c05:	e8 e0 fe ff ff       	call   80103aea <mpsearch1>
80103c0a:	83 c4 10             	add    $0x10,%esp
}
80103c0d:	c9                   	leave  
80103c0e:	c3                   	ret    

80103c0f <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c0f:	55                   	push   %ebp
80103c10:	89 e5                	mov    %esp,%ebp
80103c12:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c15:	e8 39 ff ff ff       	call   80103b53 <mpsearch>
80103c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c21:	74 0a                	je     80103c2d <mpconfig+0x1e>
80103c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c26:	8b 40 04             	mov    0x4(%eax),%eax
80103c29:	85 c0                	test   %eax,%eax
80103c2b:	75 07                	jne    80103c34 <mpconfig+0x25>
    return 0;
80103c2d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c32:	eb 7a                	jmp    80103cae <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c37:	8b 40 04             	mov    0x4(%eax),%eax
80103c3a:	05 00 00 00 80       	add    $0x80000000,%eax
80103c3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c42:	83 ec 04             	sub    $0x4,%esp
80103c45:	6a 04                	push   $0x4
80103c47:	68 e5 89 10 80       	push   $0x801089e5
80103c4c:	ff 75 f0             	pushl  -0x10(%ebp)
80103c4f:	e8 8a 16 00 00       	call   801052de <memcmp>
80103c54:	83 c4 10             	add    $0x10,%esp
80103c57:	85 c0                	test   %eax,%eax
80103c59:	74 07                	je     80103c62 <mpconfig+0x53>
    return 0;
80103c5b:	b8 00 00 00 00       	mov    $0x0,%eax
80103c60:	eb 4c                	jmp    80103cae <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c65:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c69:	3c 01                	cmp    $0x1,%al
80103c6b:	74 12                	je     80103c7f <mpconfig+0x70>
80103c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c70:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c74:	3c 04                	cmp    $0x4,%al
80103c76:	74 07                	je     80103c7f <mpconfig+0x70>
    return 0;
80103c78:	b8 00 00 00 00       	mov    $0x0,%eax
80103c7d:	eb 2f                	jmp    80103cae <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c82:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c86:	0f b7 c0             	movzwl %ax,%eax
80103c89:	83 ec 08             	sub    $0x8,%esp
80103c8c:	50                   	push   %eax
80103c8d:	ff 75 f0             	pushl  -0x10(%ebp)
80103c90:	e8 1d fe ff ff       	call   80103ab2 <sum>
80103c95:	83 c4 10             	add    $0x10,%esp
80103c98:	84 c0                	test   %al,%al
80103c9a:	74 07                	je     80103ca3 <mpconfig+0x94>
    return 0;
80103c9c:	b8 00 00 00 00       	mov    $0x0,%eax
80103ca1:	eb 0b                	jmp    80103cae <mpconfig+0x9f>
  *pmp = mp;
80103ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ca9:	89 10                	mov    %edx,(%eax)
  return conf;
80103cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103cae:	c9                   	leave  
80103caf:	c3                   	ret    

80103cb0 <mpinit>:

void
mpinit(void)
{
80103cb0:	55                   	push   %ebp
80103cb1:	89 e5                	mov    %esp,%ebp
80103cb3:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103cb6:	83 ec 0c             	sub    $0xc,%esp
80103cb9:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103cbc:	50                   	push   %eax
80103cbd:	e8 4d ff ff ff       	call   80103c0f <mpconfig>
80103cc2:	83 c4 10             	add    $0x10,%esp
80103cc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cc8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ccc:	75 0d                	jne    80103cdb <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103cce:	83 ec 0c             	sub    $0xc,%esp
80103cd1:	68 ea 89 10 80       	push   $0x801089ea
80103cd6:	e8 c5 c8 ff ff       	call   801005a0 <panic>
  ismp = 1;
80103cdb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ce5:	8b 40 24             	mov    0x24(%eax),%eax
80103ce8:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ced:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cf0:	83 c0 2c             	add    $0x2c,%eax
80103cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cf9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cfd:	0f b7 d0             	movzwl %ax,%edx
80103d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d03:	01 d0                	add    %edx,%eax
80103d05:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d08:	eb 7b                	jmp    80103d85 <mpinit+0xd5>
    switch(*p){
80103d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0d:	0f b6 00             	movzbl (%eax),%eax
80103d10:	0f b6 c0             	movzbl %al,%eax
80103d13:	83 f8 04             	cmp    $0x4,%eax
80103d16:	77 65                	ja     80103d7d <mpinit+0xcd>
80103d18:	8b 04 85 24 8a 10 80 	mov    -0x7fef75dc(,%eax,4),%eax
80103d1f:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d27:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103d2c:	83 f8 07             	cmp    $0x7,%eax
80103d2f:	7f 28                	jg     80103d59 <mpinit+0xa9>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d31:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d3a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d3e:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103d44:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103d4a:	88 02                	mov    %al,(%edx)
        ncpu++;
80103d4c:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103d51:	83 c0 01             	add    $0x1,%eax
80103d54:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103d59:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d5d:	eb 26                	jmp    80103d85 <mpinit+0xd5>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d62:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d68:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d6c:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103d71:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d75:	eb 0e                	jmp    80103d85 <mpinit+0xd5>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d77:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d7b:	eb 08                	jmp    80103d85 <mpinit+0xd5>
    default:
      ismp = 0;
80103d7d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d84:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d88:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d8b:	0f 82 79 ff ff ff    	jb     80103d0a <mpinit+0x5a>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103d91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d95:	75 0d                	jne    80103da4 <mpinit+0xf4>
    panic("Didn't find a suitable machine");
80103d97:	83 ec 0c             	sub    $0xc,%esp
80103d9a:	68 04 8a 10 80       	push   $0x80108a04
80103d9f:	e8 fc c7 ff ff       	call   801005a0 <panic>

  if(mp->imcrp){
80103da4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dab:	84 c0                	test   %al,%al
80103dad:	74 30                	je     80103ddf <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103daf:	83 ec 08             	sub    $0x8,%esp
80103db2:	6a 70                	push   $0x70
80103db4:	6a 22                	push   $0x22
80103db6:	e8 d8 fc ff ff       	call   80103a93 <outb>
80103dbb:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103dbe:	83 ec 0c             	sub    $0xc,%esp
80103dc1:	6a 23                	push   $0x23
80103dc3:	e8 ae fc ff ff       	call   80103a76 <inb>
80103dc8:	83 c4 10             	add    $0x10,%esp
80103dcb:	83 c8 01             	or     $0x1,%eax
80103dce:	0f b6 c0             	movzbl %al,%eax
80103dd1:	83 ec 08             	sub    $0x8,%esp
80103dd4:	50                   	push   %eax
80103dd5:	6a 23                	push   $0x23
80103dd7:	e8 b7 fc ff ff       	call   80103a93 <outb>
80103ddc:	83 c4 10             	add    $0x10,%esp
  }
}
80103ddf:	90                   	nop
80103de0:	c9                   	leave  
80103de1:	c3                   	ret    

80103de2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103de2:	55                   	push   %ebp
80103de3:	89 e5                	mov    %esp,%ebp
80103de5:	83 ec 08             	sub    $0x8,%esp
80103de8:	8b 55 08             	mov    0x8(%ebp),%edx
80103deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dee:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103df2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103df5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103df9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dfd:	ee                   	out    %al,(%dx)
}
80103dfe:	90                   	nop
80103dff:	c9                   	leave  
80103e00:	c3                   	ret    

80103e01 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e01:	55                   	push   %ebp
80103e02:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e04:	68 ff 00 00 00       	push   $0xff
80103e09:	6a 21                	push   $0x21
80103e0b:	e8 d2 ff ff ff       	call   80103de2 <outb>
80103e10:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103e13:	68 ff 00 00 00       	push   $0xff
80103e18:	68 a1 00 00 00       	push   $0xa1
80103e1d:	e8 c0 ff ff ff       	call   80103de2 <outb>
80103e22:	83 c4 08             	add    $0x8,%esp
}
80103e25:	90                   	nop
80103e26:	c9                   	leave  
80103e27:	c3                   	ret    

80103e28 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e28:	55                   	push   %ebp
80103e29:	89 e5                	mov    %esp,%ebp
80103e2b:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103e2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e41:	8b 10                	mov    (%eax),%edx
80103e43:	8b 45 08             	mov    0x8(%ebp),%eax
80103e46:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e48:	e8 0a d2 ff ff       	call   80101057 <filealloc>
80103e4d:	89 c2                	mov    %eax,%edx
80103e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e52:	89 10                	mov    %edx,(%eax)
80103e54:	8b 45 08             	mov    0x8(%ebp),%eax
80103e57:	8b 00                	mov    (%eax),%eax
80103e59:	85 c0                	test   %eax,%eax
80103e5b:	0f 84 cb 00 00 00    	je     80103f2c <pipealloc+0x104>
80103e61:	e8 f1 d1 ff ff       	call   80101057 <filealloc>
80103e66:	89 c2                	mov    %eax,%edx
80103e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e6b:	89 10                	mov    %edx,(%eax)
80103e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e70:	8b 00                	mov    (%eax),%eax
80103e72:	85 c0                	test   %eax,%eax
80103e74:	0f 84 b2 00 00 00    	je     80103f2c <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e7a:	e8 7a ee ff ff       	call   80102cf9 <kalloc>
80103e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e86:	0f 84 9f 00 00 00    	je     80103f2b <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e96:	00 00 00 
  p->writeopen = 1;
80103e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ea3:	00 00 00 
  p->nwrite = 0;
80103ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103eb0:	00 00 00 
  p->nread = 0;
80103eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb6:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ebd:	00 00 00 
  initlock(&p->lock, "pipe");
80103ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec3:	83 ec 08             	sub    $0x8,%esp
80103ec6:	68 38 8a 10 80       	push   $0x80108a38
80103ecb:	50                   	push   %eax
80103ecc:	e8 0d 11 00 00       	call   80104fde <initlock>
80103ed1:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed7:	8b 00                	mov    (%eax),%eax
80103ed9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103edf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee2:	8b 00                	mov    (%eax),%eax
80103ee4:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80103eeb:	8b 00                	mov    (%eax),%eax
80103eed:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef4:	8b 00                	mov    (%eax),%eax
80103ef6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ef9:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103efc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eff:	8b 00                	mov    (%eax),%eax
80103f01:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f0a:	8b 00                	mov    (%eax),%eax
80103f0c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f13:	8b 00                	mov    (%eax),%eax
80103f15:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f19:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f1c:	8b 00                	mov    (%eax),%eax
80103f1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f21:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f24:	b8 00 00 00 00       	mov    $0x0,%eax
80103f29:	eb 4e                	jmp    80103f79 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103f2b:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103f2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f30:	74 0e                	je     80103f40 <pipealloc+0x118>
    kfree((char*)p);
80103f32:	83 ec 0c             	sub    $0xc,%esp
80103f35:	ff 75 f4             	pushl  -0xc(%ebp)
80103f38:	e8 22 ed ff ff       	call   80102c5f <kfree>
80103f3d:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103f40:	8b 45 08             	mov    0x8(%ebp),%eax
80103f43:	8b 00                	mov    (%eax),%eax
80103f45:	85 c0                	test   %eax,%eax
80103f47:	74 11                	je     80103f5a <pipealloc+0x132>
    fileclose(*f0);
80103f49:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4c:	8b 00                	mov    (%eax),%eax
80103f4e:	83 ec 0c             	sub    $0xc,%esp
80103f51:	50                   	push   %eax
80103f52:	e8 be d1 ff ff       	call   80101115 <fileclose>
80103f57:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f5d:	8b 00                	mov    (%eax),%eax
80103f5f:	85 c0                	test   %eax,%eax
80103f61:	74 11                	je     80103f74 <pipealloc+0x14c>
    fileclose(*f1);
80103f63:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f66:	8b 00                	mov    (%eax),%eax
80103f68:	83 ec 0c             	sub    $0xc,%esp
80103f6b:	50                   	push   %eax
80103f6c:	e8 a4 d1 ff ff       	call   80101115 <fileclose>
80103f71:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f79:	c9                   	leave  
80103f7a:	c3                   	ret    

80103f7b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f7b:	55                   	push   %ebp
80103f7c:	89 e5                	mov    %esp,%ebp
80103f7e:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f81:	8b 45 08             	mov    0x8(%ebp),%eax
80103f84:	83 ec 0c             	sub    $0xc,%esp
80103f87:	50                   	push   %eax
80103f88:	e8 73 10 00 00       	call   80105000 <acquire>
80103f8d:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f94:	74 23                	je     80103fb9 <pipeclose+0x3e>
    p->writeopen = 0;
80103f96:	8b 45 08             	mov    0x8(%ebp),%eax
80103f99:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fa0:	00 00 00 
    wakeup(&p->nread);
80103fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa6:	05 34 02 00 00       	add    $0x234,%eax
80103fab:	83 ec 0c             	sub    $0xc,%esp
80103fae:	50                   	push   %eax
80103faf:	e8 13 0d 00 00       	call   80104cc7 <wakeup>
80103fb4:	83 c4 10             	add    $0x10,%esp
80103fb7:	eb 21                	jmp    80103fda <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbc:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103fc3:	00 00 00 
    wakeup(&p->nwrite);
80103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc9:	05 38 02 00 00       	add    $0x238,%eax
80103fce:	83 ec 0c             	sub    $0xc,%esp
80103fd1:	50                   	push   %eax
80103fd2:	e8 f0 0c 00 00       	call   80104cc7 <wakeup>
80103fd7:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103fda:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdd:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fe3:	85 c0                	test   %eax,%eax
80103fe5:	75 2c                	jne    80104013 <pipeclose+0x98>
80103fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fea:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103ff0:	85 c0                	test   %eax,%eax
80103ff2:	75 1f                	jne    80104013 <pipeclose+0x98>
    release(&p->lock);
80103ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff7:	83 ec 0c             	sub    $0xc,%esp
80103ffa:	50                   	push   %eax
80103ffb:	e8 6e 10 00 00       	call   8010506e <release>
80104000:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104003:	83 ec 0c             	sub    $0xc,%esp
80104006:	ff 75 08             	pushl  0x8(%ebp)
80104009:	e8 51 ec ff ff       	call   80102c5f <kfree>
8010400e:	83 c4 10             	add    $0x10,%esp
80104011:	eb 0f                	jmp    80104022 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104013:	8b 45 08             	mov    0x8(%ebp),%eax
80104016:	83 ec 0c             	sub    $0xc,%esp
80104019:	50                   	push   %eax
8010401a:	e8 4f 10 00 00       	call   8010506e <release>
8010401f:	83 c4 10             	add    $0x10,%esp
}
80104022:	90                   	nop
80104023:	c9                   	leave  
80104024:	c3                   	ret    

80104025 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104025:	55                   	push   %ebp
80104026:	89 e5                	mov    %esp,%ebp
80104028:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010402b:	8b 45 08             	mov    0x8(%ebp),%eax
8010402e:	83 ec 0c             	sub    $0xc,%esp
80104031:	50                   	push   %eax
80104032:	e8 c9 0f 00 00       	call   80105000 <acquire>
80104037:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010403a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104041:	e9 ac 00 00 00       	jmp    801040f2 <pipewrite+0xcd>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104046:	8b 45 08             	mov    0x8(%ebp),%eax
80104049:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010404f:	85 c0                	test   %eax,%eax
80104051:	74 0c                	je     8010405f <pipewrite+0x3a>
80104053:	e8 99 02 00 00       	call   801042f1 <myproc>
80104058:	8b 40 24             	mov    0x24(%eax),%eax
8010405b:	85 c0                	test   %eax,%eax
8010405d:	74 19                	je     80104078 <pipewrite+0x53>
        release(&p->lock);
8010405f:	8b 45 08             	mov    0x8(%ebp),%eax
80104062:	83 ec 0c             	sub    $0xc,%esp
80104065:	50                   	push   %eax
80104066:	e8 03 10 00 00       	call   8010506e <release>
8010406b:	83 c4 10             	add    $0x10,%esp
        return -1;
8010406e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104073:	e9 a8 00 00 00       	jmp    80104120 <pipewrite+0xfb>
      }
      wakeup(&p->nread);
80104078:	8b 45 08             	mov    0x8(%ebp),%eax
8010407b:	05 34 02 00 00       	add    $0x234,%eax
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	50                   	push   %eax
80104084:	e8 3e 0c 00 00       	call   80104cc7 <wakeup>
80104089:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010408c:	8b 45 08             	mov    0x8(%ebp),%eax
8010408f:	8b 55 08             	mov    0x8(%ebp),%edx
80104092:	81 c2 38 02 00 00    	add    $0x238,%edx
80104098:	83 ec 08             	sub    $0x8,%esp
8010409b:	50                   	push   %eax
8010409c:	52                   	push   %edx
8010409d:	e8 3c 0b 00 00       	call   80104bde <sleep>
801040a2:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040a5:	8b 45 08             	mov    0x8(%ebp),%eax
801040a8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040ae:	8b 45 08             	mov    0x8(%ebp),%eax
801040b1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040b7:	05 00 02 00 00       	add    $0x200,%eax
801040bc:	39 c2                	cmp    %eax,%edx
801040be:	74 86                	je     80104046 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040c0:	8b 45 08             	mov    0x8(%ebp),%eax
801040c3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040c9:	8d 48 01             	lea    0x1(%eax),%ecx
801040cc:	8b 55 08             	mov    0x8(%ebp),%edx
801040cf:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801040d5:	25 ff 01 00 00       	and    $0x1ff,%eax
801040da:	89 c1                	mov    %eax,%ecx
801040dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040df:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e2:	01 d0                	add    %edx,%eax
801040e4:	0f b6 10             	movzbl (%eax),%edx
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801040ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801040f8:	7c ab                	jl     801040a5 <pipewrite+0x80>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801040fa:	8b 45 08             	mov    0x8(%ebp),%eax
801040fd:	05 34 02 00 00       	add    $0x234,%eax
80104102:	83 ec 0c             	sub    $0xc,%esp
80104105:	50                   	push   %eax
80104106:	e8 bc 0b 00 00       	call   80104cc7 <wakeup>
8010410b:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	83 ec 0c             	sub    $0xc,%esp
80104114:	50                   	push   %eax
80104115:	e8 54 0f 00 00       	call   8010506e <release>
8010411a:	83 c4 10             	add    $0x10,%esp
  return n;
8010411d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104120:	c9                   	leave  
80104121:	c3                   	ret    

80104122 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104122:	55                   	push   %ebp
80104123:	89 e5                	mov    %esp,%ebp
80104125:	53                   	push   %ebx
80104126:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	83 ec 0c             	sub    $0xc,%esp
8010412f:	50                   	push   %eax
80104130:	e8 cb 0e 00 00       	call   80105000 <acquire>
80104135:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104138:	eb 3e                	jmp    80104178 <piperead+0x56>
    if(myproc()->killed){
8010413a:	e8 b2 01 00 00       	call   801042f1 <myproc>
8010413f:	8b 40 24             	mov    0x24(%eax),%eax
80104142:	85 c0                	test   %eax,%eax
80104144:	74 19                	je     8010415f <piperead+0x3d>
      release(&p->lock);
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	50                   	push   %eax
8010414d:	e8 1c 0f 00 00       	call   8010506e <release>
80104152:	83 c4 10             	add    $0x10,%esp
      return -1;
80104155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010415a:	e9 bf 00 00 00       	jmp    8010421e <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010415f:	8b 45 08             	mov    0x8(%ebp),%eax
80104162:	8b 55 08             	mov    0x8(%ebp),%edx
80104165:	81 c2 34 02 00 00    	add    $0x234,%edx
8010416b:	83 ec 08             	sub    $0x8,%esp
8010416e:	50                   	push   %eax
8010416f:	52                   	push   %edx
80104170:	e8 69 0a 00 00       	call   80104bde <sleep>
80104175:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104181:	8b 45 08             	mov    0x8(%ebp),%eax
80104184:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010418a:	39 c2                	cmp    %eax,%edx
8010418c:	75 0d                	jne    8010419b <piperead+0x79>
8010418e:	8b 45 08             	mov    0x8(%ebp),%eax
80104191:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104197:	85 c0                	test   %eax,%eax
80104199:	75 9f                	jne    8010413a <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010419b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041a2:	eb 49                	jmp    801041ed <piperead+0xcb>
    if(p->nread == p->nwrite)
801041a4:	8b 45 08             	mov    0x8(%ebp),%eax
801041a7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041ad:	8b 45 08             	mov    0x8(%ebp),%eax
801041b0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041b6:	39 c2                	cmp    %eax,%edx
801041b8:	74 3d                	je     801041f7 <piperead+0xd5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041c3:	8b 45 08             	mov    0x8(%ebp),%eax
801041c6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041cc:	8d 48 01             	lea    0x1(%eax),%ecx
801041cf:	8b 55 08             	mov    0x8(%ebp),%edx
801041d2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041d8:	25 ff 01 00 00       	and    $0x1ff,%eax
801041dd:	89 c2                	mov    %eax,%edx
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801041e7:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f0:	3b 45 10             	cmp    0x10(%ebp),%eax
801041f3:	7c af                	jl     801041a4 <piperead+0x82>
801041f5:	eb 01                	jmp    801041f8 <piperead+0xd6>
    if(p->nread == p->nwrite)
      break;
801041f7:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	05 38 02 00 00       	add    $0x238,%eax
80104200:	83 ec 0c             	sub    $0xc,%esp
80104203:	50                   	push   %eax
80104204:	e8 be 0a 00 00       	call   80104cc7 <wakeup>
80104209:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	83 ec 0c             	sub    $0xc,%esp
80104212:	50                   	push   %eax
80104213:	e8 56 0e 00 00       	call   8010506e <release>
80104218:	83 c4 10             	add    $0x10,%esp
  return i;
8010421b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010421e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104221:	c9                   	leave  
80104222:	c3                   	ret    

80104223 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104223:	55                   	push   %ebp
80104224:	89 e5                	mov    %esp,%ebp
80104226:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104229:	9c                   	pushf  
8010422a:	58                   	pop    %eax
8010422b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010422e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104231:	c9                   	leave  
80104232:	c3                   	ret    

80104233 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104233:	55                   	push   %ebp
80104234:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104236:	fb                   	sti    
}
80104237:	90                   	nop
80104238:	5d                   	pop    %ebp
80104239:	c3                   	ret    

8010423a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010423a:	55                   	push   %ebp
8010423b:	89 e5                	mov    %esp,%ebp
8010423d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104240:	83 ec 08             	sub    $0x8,%esp
80104243:	68 40 8a 10 80       	push   $0x80108a40
80104248:	68 a0 3d 11 80       	push   $0x80113da0
8010424d:	e8 8c 0d 00 00       	call   80104fde <initlock>
80104252:	83 c4 10             	add    $0x10,%esp
}
80104255:	90                   	nop
80104256:	c9                   	leave  
80104257:	c3                   	ret    

80104258 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104258:	55                   	push   %ebp
80104259:	89 e5                	mov    %esp,%ebp
8010425b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010425e:	e8 16 00 00 00       	call   80104279 <mycpu>
80104263:	89 c2                	mov    %eax,%edx
80104265:	b8 00 38 11 80       	mov    $0x80113800,%eax
8010426a:	29 c2                	sub    %eax,%edx
8010426c:	89 d0                	mov    %edx,%eax
8010426e:	c1 f8 04             	sar    $0x4,%eax
80104271:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104277:	c9                   	leave  
80104278:	c3                   	ret    

80104279 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104279:	55                   	push   %ebp
8010427a:	89 e5                	mov    %esp,%ebp
8010427c:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010427f:	e8 9f ff ff ff       	call   80104223 <readeflags>
80104284:	25 00 02 00 00       	and    $0x200,%eax
80104289:	85 c0                	test   %eax,%eax
8010428b:	74 0d                	je     8010429a <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
8010428d:	83 ec 0c             	sub    $0xc,%esp
80104290:	68 48 8a 10 80       	push   $0x80108a48
80104295:	e8 06 c3 ff ff       	call   801005a0 <panic>
  
  apicid = lapicid();
8010429a:	e8 b0 ed ff ff       	call   8010304f <lapicid>
8010429f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042a9:	eb 2d                	jmp    801042d8 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
801042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ae:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042b4:	05 00 38 11 80       	add    $0x80113800,%eax
801042b9:	0f b6 00             	movzbl (%eax),%eax
801042bc:	0f b6 c0             	movzbl %al,%eax
801042bf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801042c2:	75 10                	jne    801042d4 <mycpu+0x5b>
      return &cpus[i];
801042c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042cd:	05 00 38 11 80       	add    $0x80113800,%eax
801042d2:	eb 1b                	jmp    801042ef <mycpu+0x76>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042d8:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801042dd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042e0:	7c c9                	jl     801042ab <mycpu+0x32>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801042e2:	83 ec 0c             	sub    $0xc,%esp
801042e5:	68 6e 8a 10 80       	push   $0x80108a6e
801042ea:	e8 b1 c2 ff ff       	call   801005a0 <panic>
}
801042ef:	c9                   	leave  
801042f0:	c3                   	ret    

801042f1 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801042f1:	55                   	push   %ebp
801042f2:	89 e5                	mov    %esp,%ebp
801042f4:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801042f7:	e8 6f 0e 00 00       	call   8010516b <pushcli>
  c = mycpu();
801042fc:	e8 78 ff ff ff       	call   80104279 <mycpu>
80104301:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104307:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010430d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104310:	e8 a4 0e 00 00       	call   801051b9 <popcli>
  return p;
80104315:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104318:	c9                   	leave  
80104319:	c3                   	ret    

8010431a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010431a:	55                   	push   %ebp
8010431b:	89 e5                	mov    %esp,%ebp
8010431d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	68 a0 3d 11 80       	push   $0x80113da0
80104328:	e8 d3 0c 00 00       	call   80105000 <acquire>
8010432d:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104330:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104337:	eb 11                	jmp    8010434a <allocproc+0x30>
    if(p->state == UNUSED)
80104339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433c:	8b 40 0c             	mov    0xc(%eax),%eax
8010433f:	85 c0                	test   %eax,%eax
80104341:	74 2a                	je     8010436d <allocproc+0x53>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104343:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010434a:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104351:	72 e6                	jb     80104339 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104353:	83 ec 0c             	sub    $0xc,%esp
80104356:	68 a0 3d 11 80       	push   $0x80113da0
8010435b:	e8 0e 0d 00 00       	call   8010506e <release>
80104360:	83 c4 10             	add    $0x10,%esp
  return 0;
80104363:	b8 00 00 00 00       	mov    $0x0,%eax
80104368:	e9 b4 00 00 00       	jmp    80104421 <allocproc+0x107>

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010436d:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010436e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104371:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104378:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010437d:	8d 50 01             	lea    0x1(%eax),%edx
80104380:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
80104386:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104389:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010438c:	83 ec 0c             	sub    $0xc,%esp
8010438f:	68 a0 3d 11 80       	push   $0x80113da0
80104394:	e8 d5 0c 00 00       	call   8010506e <release>
80104399:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010439c:	e8 58 e9 ff ff       	call   80102cf9 <kalloc>
801043a1:	89 c2                	mov    %eax,%edx
801043a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a6:	89 50 08             	mov    %edx,0x8(%eax)
801043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ac:	8b 40 08             	mov    0x8(%eax),%eax
801043af:	85 c0                	test   %eax,%eax
801043b1:	75 11                	jne    801043c4 <allocproc+0xaa>
    p->state = UNUSED;
801043b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043bd:	b8 00 00 00 00       	mov    $0x0,%eax
801043c2:	eb 5d                	jmp    80104421 <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
801043c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c7:	8b 40 08             	mov    0x8(%eax),%eax
801043ca:	05 00 10 00 00       	add    $0x1000,%eax
801043cf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043d2:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043dc:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043df:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043e3:	ba 69 66 10 80       	mov    $0x80106669,%edx
801043e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043eb:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043ed:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043f7:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104400:	83 ec 04             	sub    $0x4,%esp
80104403:	6a 14                	push   $0x14
80104405:	6a 00                	push   $0x0
80104407:	50                   	push   %eax
80104408:	e8 6a 0e 00 00       	call   80105277 <memset>
8010440d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 40 1c             	mov    0x1c(%eax),%eax
80104416:	ba 98 4b 10 80       	mov    $0x80104b98,%edx
8010441b:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010441e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104421:	c9                   	leave  
80104422:	c3                   	ret    

80104423 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104423:	55                   	push   %ebp
80104424:	89 e5                	mov    %esp,%ebp
80104426:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104429:	e8 ec fe ff ff       	call   8010431a <allocproc>
8010442e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  //cprintf("USERINIT");
  

  initproc = p;
80104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104434:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
80104439:	e8 a0 38 00 00       	call   80107cde <setupkvm>
8010443e:	89 c2                	mov    %eax,%edx
80104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104443:	89 50 04             	mov    %edx,0x4(%eax)
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 40 04             	mov    0x4(%eax),%eax
8010444c:	85 c0                	test   %eax,%eax
8010444e:	75 0d                	jne    8010445d <userinit+0x3a>
    panic("userinit: out of memory?");
80104450:	83 ec 0c             	sub    $0xc,%esp
80104453:	68 7e 8a 10 80       	push   $0x80108a7e
80104458:	e8 43 c1 ff ff       	call   801005a0 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010445d:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	8b 40 04             	mov    0x4(%eax),%eax
80104468:	83 ec 04             	sub    $0x4,%esp
8010446b:	52                   	push   %edx
8010446c:	68 c0 b4 10 80       	push   $0x8010b4c0
80104471:	50                   	push   %eax
80104472:	e8 cf 3a 00 00       	call   80107f46 <inituvm>
80104477:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010447a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104486:	8b 40 18             	mov    0x18(%eax),%eax
80104489:	83 ec 04             	sub    $0x4,%esp
8010448c:	6a 4c                	push   $0x4c
8010448e:	6a 00                	push   $0x0
80104490:	50                   	push   %eax
80104491:	e8 e1 0d 00 00       	call   80105277 <memset>
80104496:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	8b 40 18             	mov    0x18(%eax),%eax
8010449f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a8:	8b 40 18             	mov    0x18(%eax),%eax
801044ab:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b4:	8b 40 18             	mov    0x18(%eax),%eax
801044b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ba:	8b 52 18             	mov    0x18(%edx),%edx
801044bd:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044c1:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c8:	8b 40 18             	mov    0x18(%eax),%eax
801044cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ce:	8b 52 18             	mov    0x18(%edx),%edx
801044d1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044d5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	8b 40 18             	mov    0x18(%eax),%eax
801044df:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e9:	8b 40 18             	mov    0x18(%eax),%eax
801044ec:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f6:	8b 40 18             	mov    0x18(%eax),%eax
801044f9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	83 c0 6c             	add    $0x6c,%eax
80104506:	83 ec 04             	sub    $0x4,%esp
80104509:	6a 10                	push   $0x10
8010450b:	68 97 8a 10 80       	push   $0x80108a97
80104510:	50                   	push   %eax
80104511:	e8 64 0f 00 00       	call   8010547a <safestrcpy>
80104516:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104519:	83 ec 0c             	sub    $0xc,%esp
8010451c:	68 a0 8a 10 80       	push   $0x80108aa0
80104521:	e8 8e e0 ff ff       	call   801025b4 <namei>
80104526:	83 c4 10             	add    $0x10,%esp
80104529:	89 c2                	mov    %eax,%edx
8010452b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452e:	89 50 68             	mov    %edx,0x68(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104531:	83 ec 0c             	sub    $0xc,%esp
80104534:	68 a0 3d 11 80       	push   $0x80113da0
80104539:	e8 c2 0a 00 00       	call   80105000 <acquire>
8010453e:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010454b:	83 ec 0c             	sub    $0xc,%esp
8010454e:	68 a0 3d 11 80       	push   $0x80113da0
80104553:	e8 16 0b 00 00       	call   8010506e <release>
80104558:	83 c4 10             	add    $0x10,%esp
}
8010455b:	90                   	nop
8010455c:	c9                   	leave  
8010455d:	c3                   	ret    

8010455e <growproc>:
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
// Changed for cs 153
int
growproc(int n)
{
8010455e:	55                   	push   %ebp
8010455f:	89 e5                	mov    %esp,%ebp
80104561:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104564:	e8 88 fd ff ff       	call   801042f1 <myproc>
80104569:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
//  cprintf("GROWPROC");

  sz = curproc->sz;
8010456c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010456f:	8b 00                	mov    (%eax),%eax
80104571:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  sz = curproc->last_page;
  if(n > 0){
80104574:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104578:	7e 2e                	jle    801045a8 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010457a:	8b 55 08             	mov    0x8(%ebp),%edx
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	01 c2                	add    %eax,%edx
80104582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104585:	8b 40 04             	mov    0x4(%eax),%eax
80104588:	83 ec 04             	sub    $0x4,%esp
8010458b:	52                   	push   %edx
8010458c:	ff 75 f4             	pushl  -0xc(%ebp)
8010458f:	50                   	push   %eax
80104590:	e8 ee 3a 00 00       	call   80108083 <allocuvm>
80104595:	83 c4 10             	add    $0x10,%esp
80104598:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010459b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010459f:	75 3b                	jne    801045dc <growproc+0x7e>
      return -1;
801045a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a6:	eb 4f                	jmp    801045f7 <growproc+0x99>
  } else if(n < 0){
801045a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045ac:	79 2e                	jns    801045dc <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045ae:	8b 55 08             	mov    0x8(%ebp),%edx
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b4:	01 c2                	add    %eax,%edx
801045b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045b9:	8b 40 04             	mov    0x4(%eax),%eax
801045bc:	83 ec 04             	sub    $0x4,%esp
801045bf:	52                   	push   %edx
801045c0:	ff 75 f4             	pushl  -0xc(%ebp)
801045c3:	50                   	push   %eax
801045c4:	e8 e5 3b 00 00       	call   801081ae <deallocuvm>
801045c9:	83 c4 10             	add    $0x10,%esp
801045cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045d3:	75 07                	jne    801045dc <growproc+0x7e>
      return -1;
801045d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045da:	eb 1b                	jmp    801045f7 <growproc+0x99>
  }
  curproc->sz = sz;
801045dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e2:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801045e4:	83 ec 0c             	sub    $0xc,%esp
801045e7:	ff 75 f0             	pushl  -0x10(%ebp)
801045ea:	e8 b9 37 00 00       	call   80107da8 <switchuvm>
801045ef:	83 c4 10             	add    $0x10,%esp
  return 0;
801045f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045f7:	c9                   	leave  
801045f8:	c3                   	ret    

801045f9 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045f9:	55                   	push   %ebp
801045fa:	89 e5                	mov    %esp,%ebp
801045fc:	57                   	push   %edi
801045fd:	56                   	push   %esi
801045fe:	53                   	push   %ebx
801045ff:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104602:	e8 ea fc ff ff       	call   801042f1 <myproc>
80104607:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010460a:	e8 0b fd ff ff       	call   8010431a <allocproc>
8010460f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104616:	75 0a                	jne    80104622 <fork+0x29>
    return -1;
80104618:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010461d:	e9 78 01 00 00       	jmp    8010479a <fork+0x1a1>

  // cprintf("SP2: %x\n", curproc->tf->esp);


  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->stackTop, curproc->pageNum)) == 0){
80104622:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104625:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
8010462b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010462e:	8b 48 7c             	mov    0x7c(%eax),%ecx
80104631:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104634:	8b 10                	mov    (%eax),%edx
80104636:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104639:	8b 40 04             	mov    0x4(%eax),%eax
8010463c:	53                   	push   %ebx
8010463d:	51                   	push   %ecx
8010463e:	52                   	push   %edx
8010463f:	50                   	push   %eax
80104640:	e8 07 3d 00 00       	call   8010834c <copyuvm>
80104645:	83 c4 10             	add    $0x10,%esp
80104648:	89 c2                	mov    %eax,%edx
8010464a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010464d:	89 50 04             	mov    %edx,0x4(%eax)
80104650:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104653:	8b 40 04             	mov    0x4(%eax),%eax
80104656:	85 c0                	test   %eax,%eax
80104658:	75 30                	jne    8010468a <fork+0x91>
    kfree(np->kstack);
8010465a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010465d:	8b 40 08             	mov    0x8(%eax),%eax
80104660:	83 ec 0c             	sub    $0xc,%esp
80104663:	50                   	push   %eax
80104664:	e8 f6 e5 ff ff       	call   80102c5f <kfree>
80104669:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010466c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010466f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104676:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104679:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104685:	e9 10 01 00 00       	jmp    8010479a <fork+0x1a1>
  }
  np->sz = curproc->sz;
8010468a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468d:	8b 10                	mov    (%eax),%edx
8010468f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104692:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104694:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104697:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010469a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010469d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a0:	8b 50 18             	mov    0x18(%eax),%edx
801046a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a6:	8b 40 18             	mov    0x18(%eax),%eax
801046a9:	89 c3                	mov    %eax,%ebx
801046ab:	b8 13 00 00 00       	mov    $0x13,%eax
801046b0:	89 d7                	mov    %edx,%edi
801046b2:	89 de                	mov    %ebx,%esi
801046b4:	89 c1                	mov    %eax,%ecx
801046b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->stackTop = curproc->stackTop;
801046b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bb:	8b 50 7c             	mov    0x7c(%eax),%edx
801046be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046c1:	89 50 7c             	mov    %edx,0x7c(%eax)
  np->pageNum = curproc->pageNum;
801046c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c7:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801046cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d0:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d9:	8b 40 18             	mov    0x18(%eax),%eax
801046dc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046ea:	eb 3d                	jmp    80104729 <fork+0x130>
    if(curproc->ofile[i])
801046ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046f2:	83 c2 08             	add    $0x8,%edx
801046f5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f9:	85 c0                	test   %eax,%eax
801046fb:	74 28                	je     80104725 <fork+0x12c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104700:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104703:	83 c2 08             	add    $0x8,%edx
80104706:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010470a:	83 ec 0c             	sub    $0xc,%esp
8010470d:	50                   	push   %eax
8010470e:	e8 b1 c9 ff ff       	call   801010c4 <filedup>
80104713:	83 c4 10             	add    $0x10,%esp
80104716:	89 c1                	mov    %eax,%ecx
80104718:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010471b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471e:	83 c2 08             	add    $0x8,%edx
80104721:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->stackTop = curproc->stackTop;
  np->pageNum = curproc->pageNum;
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104725:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104729:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010472d:	7e bd                	jle    801046ec <fork+0xf3>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
8010472f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104732:	8b 40 68             	mov    0x68(%eax),%eax
80104735:	83 ec 0c             	sub    $0xc,%esp
80104738:	50                   	push   %eax
80104739:	e8 fc d2 ff ff       	call   80101a3a <idup>
8010473e:	83 c4 10             	add    $0x10,%esp
80104741:	89 c2                	mov    %eax,%edx
80104743:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104746:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104749:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010474c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010474f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104752:	83 c0 6c             	add    $0x6c,%eax
80104755:	83 ec 04             	sub    $0x4,%esp
80104758:	6a 10                	push   $0x10
8010475a:	52                   	push   %edx
8010475b:	50                   	push   %eax
8010475c:	e8 19 0d 00 00       	call   8010547a <safestrcpy>
80104761:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104764:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104767:	8b 40 10             	mov    0x10(%eax),%eax
8010476a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010476d:	83 ec 0c             	sub    $0xc,%esp
80104770:	68 a0 3d 11 80       	push   $0x80113da0
80104775:	e8 86 08 00 00       	call   80105000 <acquire>
8010477a:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010477d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104780:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104787:	83 ec 0c             	sub    $0xc,%esp
8010478a:	68 a0 3d 11 80       	push   $0x80113da0
8010478f:	e8 da 08 00 00       	call   8010506e <release>
80104794:	83 c4 10             	add    $0x10,%esp

  return pid;
80104797:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010479a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010479d:	5b                   	pop    %ebx
8010479e:	5e                   	pop    %esi
8010479f:	5f                   	pop    %edi
801047a0:	5d                   	pop    %ebp
801047a1:	c3                   	ret    

801047a2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047a2:	55                   	push   %ebp
801047a3:	89 e5                	mov    %esp,%ebp
801047a5:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801047a8:	e8 44 fb ff ff       	call   801042f1 <myproc>
801047ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801047b0:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801047b5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047b8:	75 0d                	jne    801047c7 <exit+0x25>
    panic("init exiting");
801047ba:	83 ec 0c             	sub    $0xc,%esp
801047bd:	68 a2 8a 10 80       	push   $0x80108aa2
801047c2:	e8 d9 bd ff ff       	call   801005a0 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047ce:	eb 3f                	jmp    8010480f <exit+0x6d>
    if(curproc->ofile[fd]){
801047d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047d6:	83 c2 08             	add    $0x8,%edx
801047d9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047dd:	85 c0                	test   %eax,%eax
801047df:	74 2a                	je     8010480b <exit+0x69>
      fileclose(curproc->ofile[fd]);
801047e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047e7:	83 c2 08             	add    $0x8,%edx
801047ea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047ee:	83 ec 0c             	sub    $0xc,%esp
801047f1:	50                   	push   %eax
801047f2:	e8 1e c9 ff ff       	call   80101115 <fileclose>
801047f7:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801047fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104800:	83 c2 08             	add    $0x8,%edx
80104803:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010480a:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010480b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010480f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104813:	7e bb                	jle    801047d0 <exit+0x2e>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104815:	e8 7f ed ff ff       	call   80103599 <begin_op>
  iput(curproc->cwd);
8010481a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010481d:	8b 40 68             	mov    0x68(%eax),%eax
80104820:	83 ec 0c             	sub    $0xc,%esp
80104823:	50                   	push   %eax
80104824:	e8 ac d3 ff ff       	call   80101bd5 <iput>
80104829:	83 c4 10             	add    $0x10,%esp
  end_op();
8010482c:	e8 f4 ed ff ff       	call   80103625 <end_op>
  curproc->cwd = 0;
80104831:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104834:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010483b:	83 ec 0c             	sub    $0xc,%esp
8010483e:	68 a0 3d 11 80       	push   $0x80113da0
80104843:	e8 b8 07 00 00       	call   80105000 <acquire>
80104848:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010484b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010484e:	8b 40 14             	mov    0x14(%eax),%eax
80104851:	83 ec 0c             	sub    $0xc,%esp
80104854:	50                   	push   %eax
80104855:	e8 2b 04 00 00       	call   80104c85 <wakeup1>
8010485a:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010485d:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104864:	eb 3a                	jmp    801048a0 <exit+0xfe>
    if(p->parent == curproc){
80104866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104869:	8b 40 14             	mov    0x14(%eax),%eax
8010486c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010486f:	75 28                	jne    80104899 <exit+0xf7>
      p->parent = initproc;
80104871:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
80104877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010487d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104880:	8b 40 0c             	mov    0xc(%eax),%eax
80104883:	83 f8 05             	cmp    $0x5,%eax
80104886:	75 11                	jne    80104899 <exit+0xf7>
        wakeup1(initproc);
80104888:	a1 20 b6 10 80       	mov    0x8010b620,%eax
8010488d:	83 ec 0c             	sub    $0xc,%esp
80104890:	50                   	push   %eax
80104891:	e8 ef 03 00 00       	call   80104c85 <wakeup1>
80104896:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104899:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048a0:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801048a7:	72 bd                	jb     80104866 <exit+0xc4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801048a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048ac:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048b3:	e8 eb 01 00 00       	call   80104aa3 <sched>
  panic("zombie exit");
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	68 af 8a 10 80       	push   $0x80108aaf
801048c0:	e8 db bc ff ff       	call   801005a0 <panic>

801048c5 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048c5:	55                   	push   %ebp
801048c6:	89 e5                	mov    %esp,%ebp
801048c8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048cb:	e8 21 fa ff ff       	call   801042f1 <myproc>
801048d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801048d3:	83 ec 0c             	sub    $0xc,%esp
801048d6:	68 a0 3d 11 80       	push   $0x80113da0
801048db:	e8 20 07 00 00       	call   80105000 <acquire>
801048e0:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801048e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ea:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801048f1:	e9 a4 00 00 00       	jmp    8010499a <wait+0xd5>
      if(p->parent != curproc)
801048f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f9:	8b 40 14             	mov    0x14(%eax),%eax
801048fc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048ff:	0f 85 8d 00 00 00    	jne    80104992 <wait+0xcd>
        continue;
      havekids = 1;
80104905:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490f:	8b 40 0c             	mov    0xc(%eax),%eax
80104912:	83 f8 05             	cmp    $0x5,%eax
80104915:	75 7c                	jne    80104993 <wait+0xce>
        // Found one.
        pid = p->pid;
80104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491a:	8b 40 10             	mov    0x10(%eax),%eax
8010491d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104923:	8b 40 08             	mov    0x8(%eax),%eax
80104926:	83 ec 0c             	sub    $0xc,%esp
80104929:	50                   	push   %eax
8010492a:	e8 30 e3 ff ff       	call   80102c5f <kfree>
8010492f:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104935:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 40 04             	mov    0x4(%eax),%eax
80104942:	83 ec 0c             	sub    $0xc,%esp
80104945:	50                   	push   %eax
80104946:	e8 27 39 00 00       	call   80108272 <freevm>
8010494b:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010494e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104951:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104965:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104976:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010497d:	83 ec 0c             	sub    $0xc,%esp
80104980:	68 a0 3d 11 80       	push   $0x80113da0
80104985:	e8 e4 06 00 00       	call   8010506e <release>
8010498a:	83 c4 10             	add    $0x10,%esp
        return pid;
8010498d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104990:	eb 54                	jmp    801049e6 <wait+0x121>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
80104992:	90                   	nop
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104993:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010499a:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801049a1:	0f 82 4f ff ff ff    	jb     801048f6 <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049ab:	74 0a                	je     801049b7 <wait+0xf2>
801049ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b0:	8b 40 24             	mov    0x24(%eax),%eax
801049b3:	85 c0                	test   %eax,%eax
801049b5:	74 17                	je     801049ce <wait+0x109>
      release(&ptable.lock);
801049b7:	83 ec 0c             	sub    $0xc,%esp
801049ba:	68 a0 3d 11 80       	push   $0x80113da0
801049bf:	e8 aa 06 00 00       	call   8010506e <release>
801049c4:	83 c4 10             	add    $0x10,%esp
      return -1;
801049c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049cc:	eb 18                	jmp    801049e6 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801049ce:	83 ec 08             	sub    $0x8,%esp
801049d1:	68 a0 3d 11 80       	push   $0x80113da0
801049d6:	ff 75 ec             	pushl  -0x14(%ebp)
801049d9:	e8 00 02 00 00       	call   80104bde <sleep>
801049de:	83 c4 10             	add    $0x10,%esp
  }
801049e1:	e9 fd fe ff ff       	jmp    801048e3 <wait+0x1e>
}
801049e6:	c9                   	leave  
801049e7:	c3                   	ret    

801049e8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801049e8:	55                   	push   %ebp
801049e9:	89 e5                	mov    %esp,%ebp
801049eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801049ee:	e8 86 f8 ff ff       	call   80104279 <mycpu>
801049f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801049f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049f9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a00:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a03:	e8 2b f8 ff ff       	call   80104233 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a08:	83 ec 0c             	sub    $0xc,%esp
80104a0b:	68 a0 3d 11 80       	push   $0x80113da0
80104a10:	e8 eb 05 00 00       	call   80105000 <acquire>
80104a15:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a18:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104a1f:	eb 64                	jmp    80104a85 <scheduler+0x9d>
      if(p->state != RUNNABLE)
80104a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a24:	8b 40 0c             	mov    0xc(%eax),%eax
80104a27:	83 f8 03             	cmp    $0x3,%eax
80104a2a:	75 51                	jne    80104a7d <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a32:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	ff 75 f4             	pushl  -0xc(%ebp)
80104a3e:	e8 65 33 00 00       	call   80107da8 <switchuvm>
80104a43:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a49:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a53:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a59:	83 c2 04             	add    $0x4,%edx
80104a5c:	83 ec 08             	sub    $0x8,%esp
80104a5f:	50                   	push   %eax
80104a60:	52                   	push   %edx
80104a61:	e8 85 0a 00 00       	call   801054eb <swtch>
80104a66:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104a69:	e8 21 33 00 00       	call   80107d8f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a71:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a78:	00 00 00 
80104a7b:	eb 01                	jmp    80104a7e <scheduler+0x96>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104a7d:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a7e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a85:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104a8c:	72 93                	jb     80104a21 <scheduler+0x39>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104a8e:	83 ec 0c             	sub    $0xc,%esp
80104a91:	68 a0 3d 11 80       	push   $0x80113da0
80104a96:	e8 d3 05 00 00       	call   8010506e <release>
80104a9b:	83 c4 10             	add    $0x10,%esp

  }
80104a9e:	e9 60 ff ff ff       	jmp    80104a03 <scheduler+0x1b>

80104aa3 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104aa3:	55                   	push   %ebp
80104aa4:	89 e5                	mov    %esp,%ebp
80104aa6:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104aa9:	e8 43 f8 ff ff       	call   801042f1 <myproc>
80104aae:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104ab1:	83 ec 0c             	sub    $0xc,%esp
80104ab4:	68 a0 3d 11 80       	push   $0x80113da0
80104ab9:	e8 7c 06 00 00       	call   8010513a <holding>
80104abe:	83 c4 10             	add    $0x10,%esp
80104ac1:	85 c0                	test   %eax,%eax
80104ac3:	75 0d                	jne    80104ad2 <sched+0x2f>
    panic("sched ptable.lock");
80104ac5:	83 ec 0c             	sub    $0xc,%esp
80104ac8:	68 bb 8a 10 80       	push   $0x80108abb
80104acd:	e8 ce ba ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli != 1)
80104ad2:	e8 a2 f7 ff ff       	call   80104279 <mycpu>
80104ad7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104add:	83 f8 01             	cmp    $0x1,%eax
80104ae0:	74 0d                	je     80104aef <sched+0x4c>
    panic("sched locks");
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	68 cd 8a 10 80       	push   $0x80108acd
80104aea:	e8 b1 ba ff ff       	call   801005a0 <panic>
  if(p->state == RUNNING)
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	8b 40 0c             	mov    0xc(%eax),%eax
80104af5:	83 f8 04             	cmp    $0x4,%eax
80104af8:	75 0d                	jne    80104b07 <sched+0x64>
    panic("sched running");
80104afa:	83 ec 0c             	sub    $0xc,%esp
80104afd:	68 d9 8a 10 80       	push   $0x80108ad9
80104b02:	e8 99 ba ff ff       	call   801005a0 <panic>
  if(readeflags()&FL_IF)
80104b07:	e8 17 f7 ff ff       	call   80104223 <readeflags>
80104b0c:	25 00 02 00 00       	and    $0x200,%eax
80104b11:	85 c0                	test   %eax,%eax
80104b13:	74 0d                	je     80104b22 <sched+0x7f>
    panic("sched interruptible");
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	68 e7 8a 10 80       	push   $0x80108ae7
80104b1d:	e8 7e ba ff ff       	call   801005a0 <panic>
  intena = mycpu()->intena;
80104b22:	e8 52 f7 ff ff       	call   80104279 <mycpu>
80104b27:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b30:	e8 44 f7 ff ff       	call   80104279 <mycpu>
80104b35:	8b 40 04             	mov    0x4(%eax),%eax
80104b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b3b:	83 c2 1c             	add    $0x1c,%edx
80104b3e:	83 ec 08             	sub    $0x8,%esp
80104b41:	50                   	push   %eax
80104b42:	52                   	push   %edx
80104b43:	e8 a3 09 00 00       	call   801054eb <swtch>
80104b48:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b4b:	e8 29 f7 ff ff       	call   80104279 <mycpu>
80104b50:	89 c2                	mov    %eax,%edx
80104b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b55:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
}
80104b5b:	90                   	nop
80104b5c:	c9                   	leave  
80104b5d:	c3                   	ret    

80104b5e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b5e:	55                   	push   %ebp
80104b5f:	89 e5                	mov    %esp,%ebp
80104b61:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b64:	83 ec 0c             	sub    $0xc,%esp
80104b67:	68 a0 3d 11 80       	push   $0x80113da0
80104b6c:	e8 8f 04 00 00       	call   80105000 <acquire>
80104b71:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104b74:	e8 78 f7 ff ff       	call   801042f1 <myproc>
80104b79:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b80:	e8 1e ff ff ff       	call   80104aa3 <sched>
  release(&ptable.lock);
80104b85:	83 ec 0c             	sub    $0xc,%esp
80104b88:	68 a0 3d 11 80       	push   $0x80113da0
80104b8d:	e8 dc 04 00 00       	call   8010506e <release>
80104b92:	83 c4 10             	add    $0x10,%esp
}
80104b95:	90                   	nop
80104b96:	c9                   	leave  
80104b97:	c3                   	ret    

80104b98 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b98:	55                   	push   %ebp
80104b99:	89 e5                	mov    %esp,%ebp
80104b9b:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b9e:	83 ec 0c             	sub    $0xc,%esp
80104ba1:	68 a0 3d 11 80       	push   $0x80113da0
80104ba6:	e8 c3 04 00 00       	call   8010506e <release>
80104bab:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bae:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104bb3:	85 c0                	test   %eax,%eax
80104bb5:	74 24                	je     80104bdb <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bb7:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104bbe:	00 00 00 
    iinit(ROOTDEV);
80104bc1:	83 ec 0c             	sub    $0xc,%esp
80104bc4:	6a 01                	push   $0x1
80104bc6:	e8 37 cb ff ff       	call   80101702 <iinit>
80104bcb:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104bce:	83 ec 0c             	sub    $0xc,%esp
80104bd1:	6a 01                	push   $0x1
80104bd3:	e8 a3 e7 ff ff       	call   8010337b <initlog>
80104bd8:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104bdb:	90                   	nop
80104bdc:	c9                   	leave  
80104bdd:	c3                   	ret    

80104bde <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bde:	55                   	push   %ebp
80104bdf:	89 e5                	mov    %esp,%ebp
80104be1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104be4:	e8 08 f7 ff ff       	call   801042f1 <myproc>
80104be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104bec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bf0:	75 0d                	jne    80104bff <sleep+0x21>
    panic("sleep");
80104bf2:	83 ec 0c             	sub    $0xc,%esp
80104bf5:	68 fb 8a 10 80       	push   $0x80108afb
80104bfa:	e8 a1 b9 ff ff       	call   801005a0 <panic>

  if(lk == 0)
80104bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c03:	75 0d                	jne    80104c12 <sleep+0x34>
    panic("sleep without lk");
80104c05:	83 ec 0c             	sub    $0xc,%esp
80104c08:	68 01 8b 10 80       	push   $0x80108b01
80104c0d:	e8 8e b9 ff ff       	call   801005a0 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c12:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104c19:	74 1e                	je     80104c39 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c1b:	83 ec 0c             	sub    $0xc,%esp
80104c1e:	68 a0 3d 11 80       	push   $0x80113da0
80104c23:	e8 d8 03 00 00       	call   80105000 <acquire>
80104c28:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c2b:	83 ec 0c             	sub    $0xc,%esp
80104c2e:	ff 75 0c             	pushl  0xc(%ebp)
80104c31:	e8 38 04 00 00       	call   8010506e <release>
80104c36:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3c:	8b 55 08             	mov    0x8(%ebp),%edx
80104c3f:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c45:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c4c:	e8 52 fe ff ff       	call   80104aa3 <sched>

  // Tidy up.
  p->chan = 0;
80104c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c54:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c5b:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104c62:	74 1e                	je     80104c82 <sleep+0xa4>
    release(&ptable.lock);
80104c64:	83 ec 0c             	sub    $0xc,%esp
80104c67:	68 a0 3d 11 80       	push   $0x80113da0
80104c6c:	e8 fd 03 00 00       	call   8010506e <release>
80104c71:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104c74:	83 ec 0c             	sub    $0xc,%esp
80104c77:	ff 75 0c             	pushl  0xc(%ebp)
80104c7a:	e8 81 03 00 00       	call   80105000 <acquire>
80104c7f:	83 c4 10             	add    $0x10,%esp
  }
}
80104c82:	90                   	nop
80104c83:	c9                   	leave  
80104c84:	c3                   	ret    

80104c85 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c85:	55                   	push   %ebp
80104c86:	89 e5                	mov    %esp,%ebp
80104c88:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c8b:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104c92:	eb 27                	jmp    80104cbb <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c97:	8b 40 0c             	mov    0xc(%eax),%eax
80104c9a:	83 f8 02             	cmp    $0x2,%eax
80104c9d:	75 15                	jne    80104cb4 <wakeup1+0x2f>
80104c9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca2:	8b 40 20             	mov    0x20(%eax),%eax
80104ca5:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ca8:	75 0a                	jne    80104cb4 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104caa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cad:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cb4:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104cbb:	81 7d fc d4 5e 11 80 	cmpl   $0x80115ed4,-0x4(%ebp)
80104cc2:	72 d0                	jb     80104c94 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104cc4:	90                   	nop
80104cc5:	c9                   	leave  
80104cc6:	c3                   	ret    

80104cc7 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cc7:	55                   	push   %ebp
80104cc8:	89 e5                	mov    %esp,%ebp
80104cca:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104ccd:	83 ec 0c             	sub    $0xc,%esp
80104cd0:	68 a0 3d 11 80       	push   $0x80113da0
80104cd5:	e8 26 03 00 00       	call   80105000 <acquire>
80104cda:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104cdd:	83 ec 0c             	sub    $0xc,%esp
80104ce0:	ff 75 08             	pushl  0x8(%ebp)
80104ce3:	e8 9d ff ff ff       	call   80104c85 <wakeup1>
80104ce8:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104ceb:	83 ec 0c             	sub    $0xc,%esp
80104cee:	68 a0 3d 11 80       	push   $0x80113da0
80104cf3:	e8 76 03 00 00       	call   8010506e <release>
80104cf8:	83 c4 10             	add    $0x10,%esp
}
80104cfb:	90                   	nop
80104cfc:	c9                   	leave  
80104cfd:	c3                   	ret    

80104cfe <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cfe:	55                   	push   %ebp
80104cff:	89 e5                	mov    %esp,%ebp
80104d01:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d04:	83 ec 0c             	sub    $0xc,%esp
80104d07:	68 a0 3d 11 80       	push   $0x80113da0
80104d0c:	e8 ef 02 00 00       	call   80105000 <acquire>
80104d11:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d14:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104d1b:	eb 48                	jmp    80104d65 <kill+0x67>
    if(p->pid == pid){
80104d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d20:	8b 40 10             	mov    0x10(%eax),%eax
80104d23:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d26:	75 36                	jne    80104d5e <kill+0x60>
      p->killed = 1;
80104d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d35:	8b 40 0c             	mov    0xc(%eax),%eax
80104d38:	83 f8 02             	cmp    $0x2,%eax
80104d3b:	75 0a                	jne    80104d47 <kill+0x49>
        p->state = RUNNABLE;
80104d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d40:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d47:	83 ec 0c             	sub    $0xc,%esp
80104d4a:	68 a0 3d 11 80       	push   $0x80113da0
80104d4f:	e8 1a 03 00 00       	call   8010506e <release>
80104d54:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d57:	b8 00 00 00 00       	mov    $0x0,%eax
80104d5c:	eb 25                	jmp    80104d83 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d5e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d65:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104d6c:	72 af                	jb     80104d1d <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d6e:	83 ec 0c             	sub    $0xc,%esp
80104d71:	68 a0 3d 11 80       	push   $0x80113da0
80104d76:	e8 f3 02 00 00       	call   8010506e <release>
80104d7b:	83 c4 10             	add    $0x10,%esp
  return -1;
80104d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d83:	c9                   	leave  
80104d84:	c3                   	ret    

80104d85 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d85:	55                   	push   %ebp
80104d86:	89 e5                	mov    %esp,%ebp
80104d88:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d8b:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104d92:	e9 da 00 00 00       	jmp    80104e71 <procdump+0xec>
    if(p->state == UNUSED)
80104d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9a:	8b 40 0c             	mov    0xc(%eax),%eax
80104d9d:	85 c0                	test   %eax,%eax
80104d9f:	0f 84 c4 00 00 00    	je     80104e69 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da8:	8b 40 0c             	mov    0xc(%eax),%eax
80104dab:	83 f8 05             	cmp    $0x5,%eax
80104dae:	77 23                	ja     80104dd3 <procdump+0x4e>
80104db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db3:	8b 40 0c             	mov    0xc(%eax),%eax
80104db6:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104dbd:	85 c0                	test   %eax,%eax
80104dbf:	74 12                	je     80104dd3 <procdump+0x4e>
      state = states[p->state];
80104dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc4:	8b 40 0c             	mov    0xc(%eax),%eax
80104dc7:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104dd1:	eb 07                	jmp    80104dda <procdump+0x55>
    else
      state = "???";
80104dd3:	c7 45 ec 12 8b 10 80 	movl   $0x80108b12,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ddd:	8d 50 6c             	lea    0x6c(%eax),%edx
80104de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de3:	8b 40 10             	mov    0x10(%eax),%eax
80104de6:	52                   	push   %edx
80104de7:	ff 75 ec             	pushl  -0x14(%ebp)
80104dea:	50                   	push   %eax
80104deb:	68 16 8b 10 80       	push   $0x80108b16
80104df0:	e8 0b b6 ff ff       	call   80100400 <cprintf>
80104df5:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfb:	8b 40 0c             	mov    0xc(%eax),%eax
80104dfe:	83 f8 02             	cmp    $0x2,%eax
80104e01:	75 54                	jne    80104e57 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e06:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e09:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0c:	83 c0 08             	add    $0x8,%eax
80104e0f:	89 c2                	mov    %eax,%edx
80104e11:	83 ec 08             	sub    $0x8,%esp
80104e14:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e17:	50                   	push   %eax
80104e18:	52                   	push   %edx
80104e19:	e8 a2 02 00 00       	call   801050c0 <getcallerpcs>
80104e1e:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e28:	eb 1c                	jmp    80104e46 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e31:	83 ec 08             	sub    $0x8,%esp
80104e34:	50                   	push   %eax
80104e35:	68 1f 8b 10 80       	push   $0x80108b1f
80104e3a:	e8 c1 b5 ff ff       	call   80100400 <cprintf>
80104e3f:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e46:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e4a:	7f 0b                	jg     80104e57 <procdump+0xd2>
80104e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e53:	85 c0                	test   %eax,%eax
80104e55:	75 d3                	jne    80104e2a <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e57:	83 ec 0c             	sub    $0xc,%esp
80104e5a:	68 23 8b 10 80       	push   $0x80108b23
80104e5f:	e8 9c b5 ff ff       	call   80100400 <cprintf>
80104e64:	83 c4 10             	add    $0x10,%esp
80104e67:	eb 01                	jmp    80104e6a <procdump+0xe5>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104e69:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e6a:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e71:	81 7d f0 d4 5e 11 80 	cmpl   $0x80115ed4,-0x10(%ebp)
80104e78:	0f 82 19 ff ff ff    	jb     80104d97 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e7e:	90                   	nop
80104e7f:	c9                   	leave  
80104e80:	c3                   	ret    

80104e81 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104e81:	55                   	push   %ebp
80104e82:	89 e5                	mov    %esp,%ebp
80104e84:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104e87:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8a:	83 c0 04             	add    $0x4,%eax
80104e8d:	83 ec 08             	sub    $0x8,%esp
80104e90:	68 4f 8b 10 80       	push   $0x80108b4f
80104e95:	50                   	push   %eax
80104e96:	e8 43 01 00 00       	call   80104fde <initlock>
80104e9b:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ea4:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eaa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb3:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104eba:	90                   	nop
80104ebb:	c9                   	leave  
80104ebc:	c3                   	ret    

80104ebd <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ebd:	55                   	push   %ebp
80104ebe:	89 e5                	mov    %esp,%ebp
80104ec0:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec6:	83 c0 04             	add    $0x4,%eax
80104ec9:	83 ec 0c             	sub    $0xc,%esp
80104ecc:	50                   	push   %eax
80104ecd:	e8 2e 01 00 00       	call   80105000 <acquire>
80104ed2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ed5:	eb 15                	jmp    80104eec <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eda:	83 c0 04             	add    $0x4,%eax
80104edd:	83 ec 08             	sub    $0x8,%esp
80104ee0:	50                   	push   %eax
80104ee1:	ff 75 08             	pushl  0x8(%ebp)
80104ee4:	e8 f5 fc ff ff       	call   80104bde <sleep>
80104ee9:	83 c4 10             	add    $0x10,%esp

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104eec:	8b 45 08             	mov    0x8(%ebp),%eax
80104eef:	8b 00                	mov    (%eax),%eax
80104ef1:	85 c0                	test   %eax,%eax
80104ef3:	75 e2                	jne    80104ed7 <acquiresleep+0x1a>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104efe:	e8 ee f3 ff ff       	call   801042f1 <myproc>
80104f03:	8b 50 10             	mov    0x10(%eax),%edx
80104f06:	8b 45 08             	mov    0x8(%ebp),%eax
80104f09:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0f:	83 c0 04             	add    $0x4,%eax
80104f12:	83 ec 0c             	sub    $0xc,%esp
80104f15:	50                   	push   %eax
80104f16:	e8 53 01 00 00       	call   8010506e <release>
80104f1b:	83 c4 10             	add    $0x10,%esp
}
80104f1e:	90                   	nop
80104f1f:	c9                   	leave  
80104f20:	c3                   	ret    

80104f21 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f21:	55                   	push   %ebp
80104f22:	89 e5                	mov    %esp,%ebp
80104f24:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f27:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2a:	83 c0 04             	add    $0x4,%eax
80104f2d:	83 ec 0c             	sub    $0xc,%esp
80104f30:	50                   	push   %eax
80104f31:	e8 ca 00 00 00       	call   80105000 <acquire>
80104f36:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f39:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f42:	8b 45 08             	mov    0x8(%ebp),%eax
80104f45:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f4c:	83 ec 0c             	sub    $0xc,%esp
80104f4f:	ff 75 08             	pushl  0x8(%ebp)
80104f52:	e8 70 fd ff ff       	call   80104cc7 <wakeup>
80104f57:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5d:	83 c0 04             	add    $0x4,%eax
80104f60:	83 ec 0c             	sub    $0xc,%esp
80104f63:	50                   	push   %eax
80104f64:	e8 05 01 00 00       	call   8010506e <release>
80104f69:	83 c4 10             	add    $0x10,%esp
}
80104f6c:	90                   	nop
80104f6d:	c9                   	leave  
80104f6e:	c3                   	ret    

80104f6f <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
80104f72:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104f75:	8b 45 08             	mov    0x8(%ebp),%eax
80104f78:	83 c0 04             	add    $0x4,%eax
80104f7b:	83 ec 0c             	sub    $0xc,%esp
80104f7e:	50                   	push   %eax
80104f7f:	e8 7c 00 00 00       	call   80105000 <acquire>
80104f84:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104f87:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8a:	8b 00                	mov    (%eax),%eax
80104f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f92:	83 c0 04             	add    $0x4,%eax
80104f95:	83 ec 0c             	sub    $0xc,%esp
80104f98:	50                   	push   %eax
80104f99:	e8 d0 00 00 00       	call   8010506e <release>
80104f9e:	83 c4 10             	add    $0x10,%esp
  return r;
80104fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fa4:	c9                   	leave  
80104fa5:	c3                   	ret    

80104fa6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fa6:	55                   	push   %ebp
80104fa7:	89 e5                	mov    %esp,%ebp
80104fa9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fac:	9c                   	pushf  
80104fad:	58                   	pop    %eax
80104fae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fb4:	c9                   	leave  
80104fb5:	c3                   	ret    

80104fb6 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fb6:	55                   	push   %ebp
80104fb7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fb9:	fa                   	cli    
}
80104fba:	90                   	nop
80104fbb:	5d                   	pop    %ebp
80104fbc:	c3                   	ret    

80104fbd <sti>:

static inline void
sti(void)
{
80104fbd:	55                   	push   %ebp
80104fbe:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fc0:	fb                   	sti    
}
80104fc1:	90                   	nop
80104fc2:	5d                   	pop    %ebp
80104fc3:	c3                   	ret    

80104fc4 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fc4:	55                   	push   %ebp
80104fc5:	89 e5                	mov    %esp,%ebp
80104fc7:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fca:	8b 55 08             	mov    0x8(%ebp),%edx
80104fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fd3:	f0 87 02             	lock xchg %eax,(%edx)
80104fd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104fd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fdc:	c9                   	leave  
80104fdd:	c3                   	ret    

80104fde <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104fde:	55                   	push   %ebp
80104fdf:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fe7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104fea:	8b 45 08             	mov    0x8(%ebp),%eax
80104fed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ffd:	90                   	nop
80104ffe:	5d                   	pop    %ebp
80104fff:	c3                   	ret    

80105000 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105000:	55                   	push   %ebp
80105001:	89 e5                	mov    %esp,%ebp
80105003:	53                   	push   %ebx
80105004:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105007:	e8 5f 01 00 00       	call   8010516b <pushcli>
  if(holding(lk))
8010500c:	8b 45 08             	mov    0x8(%ebp),%eax
8010500f:	83 ec 0c             	sub    $0xc,%esp
80105012:	50                   	push   %eax
80105013:	e8 22 01 00 00       	call   8010513a <holding>
80105018:	83 c4 10             	add    $0x10,%esp
8010501b:	85 c0                	test   %eax,%eax
8010501d:	74 0d                	je     8010502c <acquire+0x2c>
    panic("acquire");
8010501f:	83 ec 0c             	sub    $0xc,%esp
80105022:	68 5a 8b 10 80       	push   $0x80108b5a
80105027:	e8 74 b5 ff ff       	call   801005a0 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010502c:	90                   	nop
8010502d:	8b 45 08             	mov    0x8(%ebp),%eax
80105030:	83 ec 08             	sub    $0x8,%esp
80105033:	6a 01                	push   $0x1
80105035:	50                   	push   %eax
80105036:	e8 89 ff ff ff       	call   80104fc4 <xchg>
8010503b:	83 c4 10             	add    $0x10,%esp
8010503e:	85 c0                	test   %eax,%eax
80105040:	75 eb                	jne    8010502d <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105042:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105047:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010504a:	e8 2a f2 ff ff       	call   80104279 <mycpu>
8010504f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105052:	8b 45 08             	mov    0x8(%ebp),%eax
80105055:	83 c0 0c             	add    $0xc,%eax
80105058:	83 ec 08             	sub    $0x8,%esp
8010505b:	50                   	push   %eax
8010505c:	8d 45 08             	lea    0x8(%ebp),%eax
8010505f:	50                   	push   %eax
80105060:	e8 5b 00 00 00       	call   801050c0 <getcallerpcs>
80105065:	83 c4 10             	add    $0x10,%esp
}
80105068:	90                   	nop
80105069:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010506c:	c9                   	leave  
8010506d:	c3                   	ret    

8010506e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010506e:	55                   	push   %ebp
8010506f:	89 e5                	mov    %esp,%ebp
80105071:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105074:	83 ec 0c             	sub    $0xc,%esp
80105077:	ff 75 08             	pushl  0x8(%ebp)
8010507a:	e8 bb 00 00 00       	call   8010513a <holding>
8010507f:	83 c4 10             	add    $0x10,%esp
80105082:	85 c0                	test   %eax,%eax
80105084:	75 0d                	jne    80105093 <release+0x25>
    panic("release");
80105086:	83 ec 0c             	sub    $0xc,%esp
80105089:	68 62 8b 10 80       	push   $0x80108b62
8010508e:	e8 0d b5 ff ff       	call   801005a0 <panic>

  lk->pcs[0] = 0;
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010509d:	8b 45 08             	mov    0x8(%ebp),%eax
801050a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801050a7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801050ac:	8b 45 08             	mov    0x8(%ebp),%eax
801050af:	8b 55 08             	mov    0x8(%ebp),%edx
801050b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801050b8:	e8 fc 00 00 00       	call   801051b9 <popcli>
}
801050bd:	90                   	nop
801050be:	c9                   	leave  
801050bf:	c3                   	ret    

801050c0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050c0:	55                   	push   %ebp
801050c1:	89 e5                	mov    %esp,%ebp
801050c3:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801050c6:	8b 45 08             	mov    0x8(%ebp),%eax
801050c9:	83 e8 08             	sub    $0x8,%eax
801050cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050cf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050d6:	eb 38                	jmp    80105110 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050d8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050dc:	74 53                	je     80105131 <getcallerpcs+0x71>
801050de:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050e5:	76 4a                	jbe    80105131 <getcallerpcs+0x71>
801050e7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050eb:	74 44                	je     80105131 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fa:	01 c2                	add    %eax,%edx
801050fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ff:	8b 40 04             	mov    0x4(%eax),%eax
80105102:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105104:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105107:	8b 00                	mov    (%eax),%eax
80105109:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010510c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105110:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105114:	7e c2                	jle    801050d8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105116:	eb 19                	jmp    80105131 <getcallerpcs+0x71>
    pcs[i] = 0;
80105118:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010511b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105122:	8b 45 0c             	mov    0xc(%ebp),%eax
80105125:	01 d0                	add    %edx,%eax
80105127:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010512d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105131:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105135:	7e e1                	jle    80105118 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105137:	90                   	nop
80105138:	c9                   	leave  
80105139:	c3                   	ret    

8010513a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010513a:	55                   	push   %ebp
8010513b:	89 e5                	mov    %esp,%ebp
8010513d:	53                   	push   %ebx
8010513e:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105141:	8b 45 08             	mov    0x8(%ebp),%eax
80105144:	8b 00                	mov    (%eax),%eax
80105146:	85 c0                	test   %eax,%eax
80105148:	74 16                	je     80105160 <holding+0x26>
8010514a:	8b 45 08             	mov    0x8(%ebp),%eax
8010514d:	8b 58 08             	mov    0x8(%eax),%ebx
80105150:	e8 24 f1 ff ff       	call   80104279 <mycpu>
80105155:	39 c3                	cmp    %eax,%ebx
80105157:	75 07                	jne    80105160 <holding+0x26>
80105159:	b8 01 00 00 00       	mov    $0x1,%eax
8010515e:	eb 05                	jmp    80105165 <holding+0x2b>
80105160:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105165:	83 c4 04             	add    $0x4,%esp
80105168:	5b                   	pop    %ebx
80105169:	5d                   	pop    %ebp
8010516a:	c3                   	ret    

8010516b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010516b:	55                   	push   %ebp
8010516c:	89 e5                	mov    %esp,%ebp
8010516e:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105171:	e8 30 fe ff ff       	call   80104fa6 <readeflags>
80105176:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105179:	e8 38 fe ff ff       	call   80104fb6 <cli>
  if(mycpu()->ncli == 0)
8010517e:	e8 f6 f0 ff ff       	call   80104279 <mycpu>
80105183:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105189:	85 c0                	test   %eax,%eax
8010518b:	75 15                	jne    801051a2 <pushcli+0x37>
    mycpu()->intena = eflags & FL_IF;
8010518d:	e8 e7 f0 ff ff       	call   80104279 <mycpu>
80105192:	89 c2                	mov    %eax,%edx
80105194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105197:	25 00 02 00 00       	and    $0x200,%eax
8010519c:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
  mycpu()->ncli += 1;
801051a2:	e8 d2 f0 ff ff       	call   80104279 <mycpu>
801051a7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051ad:	83 c2 01             	add    $0x1,%edx
801051b0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801051b6:	90                   	nop
801051b7:	c9                   	leave  
801051b8:	c3                   	ret    

801051b9 <popcli>:

void
popcli(void)
{
801051b9:	55                   	push   %ebp
801051ba:	89 e5                	mov    %esp,%ebp
801051bc:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801051bf:	e8 e2 fd ff ff       	call   80104fa6 <readeflags>
801051c4:	25 00 02 00 00       	and    $0x200,%eax
801051c9:	85 c0                	test   %eax,%eax
801051cb:	74 0d                	je     801051da <popcli+0x21>
    panic("popcli - interruptible");
801051cd:	83 ec 0c             	sub    $0xc,%esp
801051d0:	68 6a 8b 10 80       	push   $0x80108b6a
801051d5:	e8 c6 b3 ff ff       	call   801005a0 <panic>
  if(--mycpu()->ncli < 0)
801051da:	e8 9a f0 ff ff       	call   80104279 <mycpu>
801051df:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051e5:	83 ea 01             	sub    $0x1,%edx
801051e8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801051ee:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051f4:	85 c0                	test   %eax,%eax
801051f6:	79 0d                	jns    80105205 <popcli+0x4c>
    panic("popcli");
801051f8:	83 ec 0c             	sub    $0xc,%esp
801051fb:	68 81 8b 10 80       	push   $0x80108b81
80105200:	e8 9b b3 ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105205:	e8 6f f0 ff ff       	call   80104279 <mycpu>
8010520a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105210:	85 c0                	test   %eax,%eax
80105212:	75 14                	jne    80105228 <popcli+0x6f>
80105214:	e8 60 f0 ff ff       	call   80104279 <mycpu>
80105219:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010521f:	85 c0                	test   %eax,%eax
80105221:	74 05                	je     80105228 <popcli+0x6f>
    sti();
80105223:	e8 95 fd ff ff       	call   80104fbd <sti>
}
80105228:	90                   	nop
80105229:	c9                   	leave  
8010522a:	c3                   	ret    

8010522b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010522b:	55                   	push   %ebp
8010522c:	89 e5                	mov    %esp,%ebp
8010522e:	57                   	push   %edi
8010522f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105230:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105233:	8b 55 10             	mov    0x10(%ebp),%edx
80105236:	8b 45 0c             	mov    0xc(%ebp),%eax
80105239:	89 cb                	mov    %ecx,%ebx
8010523b:	89 df                	mov    %ebx,%edi
8010523d:	89 d1                	mov    %edx,%ecx
8010523f:	fc                   	cld    
80105240:	f3 aa                	rep stos %al,%es:(%edi)
80105242:	89 ca                	mov    %ecx,%edx
80105244:	89 fb                	mov    %edi,%ebx
80105246:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105249:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010524c:	90                   	nop
8010524d:	5b                   	pop    %ebx
8010524e:	5f                   	pop    %edi
8010524f:	5d                   	pop    %ebp
80105250:	c3                   	ret    

80105251 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105251:	55                   	push   %ebp
80105252:	89 e5                	mov    %esp,%ebp
80105254:	57                   	push   %edi
80105255:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105256:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105259:	8b 55 10             	mov    0x10(%ebp),%edx
8010525c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525f:	89 cb                	mov    %ecx,%ebx
80105261:	89 df                	mov    %ebx,%edi
80105263:	89 d1                	mov    %edx,%ecx
80105265:	fc                   	cld    
80105266:	f3 ab                	rep stos %eax,%es:(%edi)
80105268:	89 ca                	mov    %ecx,%edx
8010526a:	89 fb                	mov    %edi,%ebx
8010526c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010526f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105272:	90                   	nop
80105273:	5b                   	pop    %ebx
80105274:	5f                   	pop    %edi
80105275:	5d                   	pop    %ebp
80105276:	c3                   	ret    

80105277 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105277:	55                   	push   %ebp
80105278:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010527a:	8b 45 08             	mov    0x8(%ebp),%eax
8010527d:	83 e0 03             	and    $0x3,%eax
80105280:	85 c0                	test   %eax,%eax
80105282:	75 43                	jne    801052c7 <memset+0x50>
80105284:	8b 45 10             	mov    0x10(%ebp),%eax
80105287:	83 e0 03             	and    $0x3,%eax
8010528a:	85 c0                	test   %eax,%eax
8010528c:	75 39                	jne    801052c7 <memset+0x50>
    c &= 0xFF;
8010528e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105295:	8b 45 10             	mov    0x10(%ebp),%eax
80105298:	c1 e8 02             	shr    $0x2,%eax
8010529b:	89 c1                	mov    %eax,%ecx
8010529d:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a0:	c1 e0 18             	shl    $0x18,%eax
801052a3:	89 c2                	mov    %eax,%edx
801052a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a8:	c1 e0 10             	shl    $0x10,%eax
801052ab:	09 c2                	or     %eax,%edx
801052ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b0:	c1 e0 08             	shl    $0x8,%eax
801052b3:	09 d0                	or     %edx,%eax
801052b5:	0b 45 0c             	or     0xc(%ebp),%eax
801052b8:	51                   	push   %ecx
801052b9:	50                   	push   %eax
801052ba:	ff 75 08             	pushl  0x8(%ebp)
801052bd:	e8 8f ff ff ff       	call   80105251 <stosl>
801052c2:	83 c4 0c             	add    $0xc,%esp
801052c5:	eb 12                	jmp    801052d9 <memset+0x62>
  } else
    stosb(dst, c, n);
801052c7:	8b 45 10             	mov    0x10(%ebp),%eax
801052ca:	50                   	push   %eax
801052cb:	ff 75 0c             	pushl  0xc(%ebp)
801052ce:	ff 75 08             	pushl  0x8(%ebp)
801052d1:	e8 55 ff ff ff       	call   8010522b <stosb>
801052d6:	83 c4 0c             	add    $0xc,%esp
  return dst;
801052d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052dc:	c9                   	leave  
801052dd:	c3                   	ret    

801052de <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052de:	55                   	push   %ebp
801052df:	89 e5                	mov    %esp,%ebp
801052e1:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801052e4:	8b 45 08             	mov    0x8(%ebp),%eax
801052e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052f0:	eb 30                	jmp    80105322 <memcmp+0x44>
    if(*s1 != *s2)
801052f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f5:	0f b6 10             	movzbl (%eax),%edx
801052f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052fb:	0f b6 00             	movzbl (%eax),%eax
801052fe:	38 c2                	cmp    %al,%dl
80105300:	74 18                	je     8010531a <memcmp+0x3c>
      return *s1 - *s2;
80105302:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105305:	0f b6 00             	movzbl (%eax),%eax
80105308:	0f b6 d0             	movzbl %al,%edx
8010530b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010530e:	0f b6 00             	movzbl (%eax),%eax
80105311:	0f b6 c0             	movzbl %al,%eax
80105314:	29 c2                	sub    %eax,%edx
80105316:	89 d0                	mov    %edx,%eax
80105318:	eb 1a                	jmp    80105334 <memcmp+0x56>
    s1++, s2++;
8010531a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010531e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105322:	8b 45 10             	mov    0x10(%ebp),%eax
80105325:	8d 50 ff             	lea    -0x1(%eax),%edx
80105328:	89 55 10             	mov    %edx,0x10(%ebp)
8010532b:	85 c0                	test   %eax,%eax
8010532d:	75 c3                	jne    801052f2 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010532f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105334:	c9                   	leave  
80105335:	c3                   	ret    

80105336 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105336:	55                   	push   %ebp
80105337:	89 e5                	mov    %esp,%ebp
80105339:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010533c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105342:	8b 45 08             	mov    0x8(%ebp),%eax
80105345:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105348:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010534e:	73 54                	jae    801053a4 <memmove+0x6e>
80105350:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105353:	8b 45 10             	mov    0x10(%ebp),%eax
80105356:	01 d0                	add    %edx,%eax
80105358:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010535b:	76 47                	jbe    801053a4 <memmove+0x6e>
    s += n;
8010535d:	8b 45 10             	mov    0x10(%ebp),%eax
80105360:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105363:	8b 45 10             	mov    0x10(%ebp),%eax
80105366:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105369:	eb 13                	jmp    8010537e <memmove+0x48>
      *--d = *--s;
8010536b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010536f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105373:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105376:	0f b6 10             	movzbl (%eax),%edx
80105379:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537c:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010537e:	8b 45 10             	mov    0x10(%ebp),%eax
80105381:	8d 50 ff             	lea    -0x1(%eax),%edx
80105384:	89 55 10             	mov    %edx,0x10(%ebp)
80105387:	85 c0                	test   %eax,%eax
80105389:	75 e0                	jne    8010536b <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010538b:	eb 24                	jmp    801053b1 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010538d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105390:	8d 50 01             	lea    0x1(%eax),%edx
80105393:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105396:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105399:	8d 4a 01             	lea    0x1(%edx),%ecx
8010539c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010539f:	0f b6 12             	movzbl (%edx),%edx
801053a2:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053a4:	8b 45 10             	mov    0x10(%ebp),%eax
801053a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801053aa:	89 55 10             	mov    %edx,0x10(%ebp)
801053ad:	85 c0                	test   %eax,%eax
801053af:	75 dc                	jne    8010538d <memmove+0x57>
      *d++ = *s++;

  return dst;
801053b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053b4:	c9                   	leave  
801053b5:	c3                   	ret    

801053b6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053b6:	55                   	push   %ebp
801053b7:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801053b9:	ff 75 10             	pushl  0x10(%ebp)
801053bc:	ff 75 0c             	pushl  0xc(%ebp)
801053bf:	ff 75 08             	pushl  0x8(%ebp)
801053c2:	e8 6f ff ff ff       	call   80105336 <memmove>
801053c7:	83 c4 0c             	add    $0xc,%esp
}
801053ca:	c9                   	leave  
801053cb:	c3                   	ret    

801053cc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053cc:	55                   	push   %ebp
801053cd:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053cf:	eb 0c                	jmp    801053dd <strncmp+0x11>
    n--, p++, q++;
801053d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053d9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053e1:	74 1a                	je     801053fd <strncmp+0x31>
801053e3:	8b 45 08             	mov    0x8(%ebp),%eax
801053e6:	0f b6 00             	movzbl (%eax),%eax
801053e9:	84 c0                	test   %al,%al
801053eb:	74 10                	je     801053fd <strncmp+0x31>
801053ed:	8b 45 08             	mov    0x8(%ebp),%eax
801053f0:	0f b6 10             	movzbl (%eax),%edx
801053f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f6:	0f b6 00             	movzbl (%eax),%eax
801053f9:	38 c2                	cmp    %al,%dl
801053fb:	74 d4                	je     801053d1 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801053fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105401:	75 07                	jne    8010540a <strncmp+0x3e>
    return 0;
80105403:	b8 00 00 00 00       	mov    $0x0,%eax
80105408:	eb 16                	jmp    80105420 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010540a:	8b 45 08             	mov    0x8(%ebp),%eax
8010540d:	0f b6 00             	movzbl (%eax),%eax
80105410:	0f b6 d0             	movzbl %al,%edx
80105413:	8b 45 0c             	mov    0xc(%ebp),%eax
80105416:	0f b6 00             	movzbl (%eax),%eax
80105419:	0f b6 c0             	movzbl %al,%eax
8010541c:	29 c2                	sub    %eax,%edx
8010541e:	89 d0                	mov    %edx,%eax
}
80105420:	5d                   	pop    %ebp
80105421:	c3                   	ret    

80105422 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
80105425:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105428:	8b 45 08             	mov    0x8(%ebp),%eax
8010542b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010542e:	90                   	nop
8010542f:	8b 45 10             	mov    0x10(%ebp),%eax
80105432:	8d 50 ff             	lea    -0x1(%eax),%edx
80105435:	89 55 10             	mov    %edx,0x10(%ebp)
80105438:	85 c0                	test   %eax,%eax
8010543a:	7e 2c                	jle    80105468 <strncpy+0x46>
8010543c:	8b 45 08             	mov    0x8(%ebp),%eax
8010543f:	8d 50 01             	lea    0x1(%eax),%edx
80105442:	89 55 08             	mov    %edx,0x8(%ebp)
80105445:	8b 55 0c             	mov    0xc(%ebp),%edx
80105448:	8d 4a 01             	lea    0x1(%edx),%ecx
8010544b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010544e:	0f b6 12             	movzbl (%edx),%edx
80105451:	88 10                	mov    %dl,(%eax)
80105453:	0f b6 00             	movzbl (%eax),%eax
80105456:	84 c0                	test   %al,%al
80105458:	75 d5                	jne    8010542f <strncpy+0xd>
    ;
  while(n-- > 0)
8010545a:	eb 0c                	jmp    80105468 <strncpy+0x46>
    *s++ = 0;
8010545c:	8b 45 08             	mov    0x8(%ebp),%eax
8010545f:	8d 50 01             	lea    0x1(%eax),%edx
80105462:	89 55 08             	mov    %edx,0x8(%ebp)
80105465:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105468:	8b 45 10             	mov    0x10(%ebp),%eax
8010546b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010546e:	89 55 10             	mov    %edx,0x10(%ebp)
80105471:	85 c0                	test   %eax,%eax
80105473:	7f e7                	jg     8010545c <strncpy+0x3a>
    *s++ = 0;
  return os;
80105475:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105478:	c9                   	leave  
80105479:	c3                   	ret    

8010547a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010547a:	55                   	push   %ebp
8010547b:	89 e5                	mov    %esp,%ebp
8010547d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105480:	8b 45 08             	mov    0x8(%ebp),%eax
80105483:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105486:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010548a:	7f 05                	jg     80105491 <safestrcpy+0x17>
    return os;
8010548c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010548f:	eb 31                	jmp    801054c2 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105491:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105495:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105499:	7e 1e                	jle    801054b9 <safestrcpy+0x3f>
8010549b:	8b 45 08             	mov    0x8(%ebp),%eax
8010549e:	8d 50 01             	lea    0x1(%eax),%edx
801054a1:	89 55 08             	mov    %edx,0x8(%ebp)
801054a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801054a7:	8d 4a 01             	lea    0x1(%edx),%ecx
801054aa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054ad:	0f b6 12             	movzbl (%edx),%edx
801054b0:	88 10                	mov    %dl,(%eax)
801054b2:	0f b6 00             	movzbl (%eax),%eax
801054b5:	84 c0                	test   %al,%al
801054b7:	75 d8                	jne    80105491 <safestrcpy+0x17>
    ;
  *s = 0;
801054b9:	8b 45 08             	mov    0x8(%ebp),%eax
801054bc:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054c2:	c9                   	leave  
801054c3:	c3                   	ret    

801054c4 <strlen>:

int
strlen(const char *s)
{
801054c4:	55                   	push   %ebp
801054c5:	89 e5                	mov    %esp,%ebp
801054c7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054d1:	eb 04                	jmp    801054d7 <strlen+0x13>
801054d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054d7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054da:	8b 45 08             	mov    0x8(%ebp),%eax
801054dd:	01 d0                	add    %edx,%eax
801054df:	0f b6 00             	movzbl (%eax),%eax
801054e2:	84 c0                	test   %al,%al
801054e4:	75 ed                	jne    801054d3 <strlen+0xf>
    ;
  return n;
801054e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054e9:	c9                   	leave  
801054ea:	c3                   	ret    

801054eb <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801054eb:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801054ef:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801054f3:	55                   	push   %ebp
  pushl %ebx
801054f4:	53                   	push   %ebx
  pushl %esi
801054f5:	56                   	push   %esi
  pushl %edi
801054f6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801054f7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801054f9:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801054fb:	5f                   	pop    %edi
  popl %esi
801054fc:	5e                   	pop    %esi
  popl %ebx
801054fd:	5b                   	pop    %ebx
  popl %ebp
801054fe:	5d                   	pop    %ebp
  ret
801054ff:	c3                   	ret    

80105500 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105500:	55                   	push   %ebp
80105501:	89 e5                	mov    %esp,%ebp
//  struct proc *curproc = myproc();

//  cprintf("FETCHINT: %x\n", curproc->sz);
 

  if(addr >= USER_TOP|| addr+4 > USER_TOP)
80105503:	81 7d 08 fb ff ff 7f 	cmpl   $0x7ffffffb,0x8(%ebp)
8010550a:	77 0d                	ja     80105519 <fetchint+0x19>
8010550c:	8b 45 08             	mov    0x8(%ebp),%eax
8010550f:	83 c0 04             	add    $0x4,%eax
80105512:	3d fc ff ff 7f       	cmp    $0x7ffffffc,%eax
80105517:	76 07                	jbe    80105520 <fetchint+0x20>
    return -1;
80105519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551e:	eb 0f                	jmp    8010552f <fetchint+0x2f>
  *ip = *(int*)(addr);
80105520:	8b 45 08             	mov    0x8(%ebp),%eax
80105523:	8b 10                	mov    (%eax),%edx
80105525:	8b 45 0c             	mov    0xc(%ebp),%eax
80105528:	89 10                	mov    %edx,(%eax)
  return 0;
8010552a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010552f:	5d                   	pop    %ebp
80105530:	c3                   	ret    

80105531 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
80105534:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

//  cprintf("FETCHSTR: %x\n", USER_TOP);

  if(addr >= USER_TOP)
80105537:	81 7d 08 fb ff ff 7f 	cmpl   $0x7ffffffb,0x8(%ebp)
8010553e:	76 07                	jbe    80105547 <fetchstr+0x16>
    return -1;
80105540:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105545:	eb 42                	jmp    80105589 <fetchstr+0x58>
  *pp = (char*)addr;
80105547:	8b 55 08             	mov    0x8(%ebp),%edx
8010554a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010554d:	89 10                	mov    %edx,(%eax)
  ep = (char*)USER_TOP;
8010554f:	c7 45 f8 fc ff ff 7f 	movl   $0x7ffffffc,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80105556:	8b 45 0c             	mov    0xc(%ebp),%eax
80105559:	8b 00                	mov    (%eax),%eax
8010555b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010555e:	eb 1c                	jmp    8010557c <fetchstr+0x4b>
    if(*s == 0)
80105560:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105563:	0f b6 00             	movzbl (%eax),%eax
80105566:	84 c0                	test   %al,%al
80105568:	75 0e                	jne    80105578 <fetchstr+0x47>
      return s - *pp;
8010556a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010556d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105570:	8b 00                	mov    (%eax),%eax
80105572:	29 c2                	sub    %eax,%edx
80105574:	89 d0                	mov    %edx,%eax
80105576:	eb 11                	jmp    80105589 <fetchstr+0x58>

  if(addr >= USER_TOP)
    return -1;
  *pp = (char*)addr;
  ep = (char*)USER_TOP;
  for(s = *pp; s < ep; s++){
80105578:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010557c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010557f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105582:	72 dc                	jb     80105560 <fetchstr+0x2f>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105589:	c9                   	leave  
8010558a:	c3                   	ret    

8010558b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010558b:	55                   	push   %ebp
8010558c:	89 e5                	mov    %esp,%ebp
8010558e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105591:	e8 5b ed ff ff       	call   801042f1 <myproc>
80105596:	8b 40 18             	mov    0x18(%eax),%eax
80105599:	8b 40 44             	mov    0x44(%eax),%eax
8010559c:	8b 55 08             	mov    0x8(%ebp),%edx
8010559f:	c1 e2 02             	shl    $0x2,%edx
801055a2:	01 d0                	add    %edx,%eax
801055a4:	83 c0 04             	add    $0x4,%eax
801055a7:	83 ec 08             	sub    $0x8,%esp
801055aa:	ff 75 0c             	pushl  0xc(%ebp)
801055ad:	50                   	push   %eax
801055ae:	e8 4d ff ff ff       	call   80105500 <fetchint>
801055b3:	83 c4 10             	add    $0x10,%esp
}
801055b6:	c9                   	leave  
801055b7:	c3                   	ret    

801055b8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055b8:	55                   	push   %ebp
801055b9:	89 e5                	mov    %esp,%ebp
801055bb:	83 ec 18             	sub    $0x18,%esp
  int i;
//  struct proc *curproc = myproc();

//  cprintf("ARGPTR: %x\n", curproc->sz);
 
  if(argint(n, &i) < 0)
801055be:	83 ec 08             	sub    $0x8,%esp
801055c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055c4:	50                   	push   %eax
801055c5:	ff 75 08             	pushl  0x8(%ebp)
801055c8:	e8 be ff ff ff       	call   8010558b <argint>
801055cd:	83 c4 10             	add    $0x10,%esp
801055d0:	85 c0                	test   %eax,%eax
801055d2:	79 07                	jns    801055db <argptr+0x23>
    return -1;
801055d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d9:	eb 37                	jmp    80105612 <argptr+0x5a>
  if(size < 0 || (uint)i >= USER_TOP|| (uint)i+size > USER_TOP)
801055db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055df:	78 1b                	js     801055fc <argptr+0x44>
801055e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e4:	3d fb ff ff 7f       	cmp    $0x7ffffffb,%eax
801055e9:	77 11                	ja     801055fc <argptr+0x44>
801055eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ee:	89 c2                	mov    %eax,%edx
801055f0:	8b 45 10             	mov    0x10(%ebp),%eax
801055f3:	01 d0                	add    %edx,%eax
801055f5:	3d fc ff ff 7f       	cmp    $0x7ffffffc,%eax
801055fa:	76 07                	jbe    80105603 <argptr+0x4b>
    return -1;
801055fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105601:	eb 0f                	jmp    80105612 <argptr+0x5a>
  *pp = (char*)i;
80105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105606:	89 c2                	mov    %eax,%edx
80105608:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560b:	89 10                	mov    %edx,(%eax)
  return 0;
8010560d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105612:	c9                   	leave  
80105613:	c3                   	ret    

80105614 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105614:	55                   	push   %ebp
80105615:	89 e5                	mov    %esp,%ebp
80105617:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010561a:	83 ec 08             	sub    $0x8,%esp
8010561d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105620:	50                   	push   %eax
80105621:	ff 75 08             	pushl  0x8(%ebp)
80105624:	e8 62 ff ff ff       	call   8010558b <argint>
80105629:	83 c4 10             	add    $0x10,%esp
8010562c:	85 c0                	test   %eax,%eax
8010562e:	79 07                	jns    80105637 <argstr+0x23>
    return -1;
80105630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105635:	eb 12                	jmp    80105649 <argstr+0x35>
  return fetchstr(addr, pp);
80105637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563a:	83 ec 08             	sub    $0x8,%esp
8010563d:	ff 75 0c             	pushl  0xc(%ebp)
80105640:	50                   	push   %eax
80105641:	e8 eb fe ff ff       	call   80105531 <fetchstr>
80105646:	83 c4 10             	add    $0x10,%esp
}
80105649:	c9                   	leave  
8010564a:	c3                   	ret    

8010564b <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
8010564b:	55                   	push   %ebp
8010564c:	89 e5                	mov    %esp,%ebp
8010564e:	53                   	push   %ebx
8010564f:	83 ec 14             	sub    $0x14,%esp
  int num;
  struct proc *curproc = myproc();
80105652:	e8 9a ec ff ff       	call   801042f1 <myproc>
80105657:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010565a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565d:	8b 40 18             	mov    0x18(%eax),%eax
80105660:	8b 40 1c             	mov    0x1c(%eax),%eax
80105663:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105666:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010566a:	7e 2d                	jle    80105699 <syscall+0x4e>
8010566c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010566f:	83 f8 17             	cmp    $0x17,%eax
80105672:	77 25                	ja     80105699 <syscall+0x4e>
80105674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105677:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010567e:	85 c0                	test   %eax,%eax
80105680:	74 17                	je     80105699 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105685:	8b 58 18             	mov    0x18(%eax),%ebx
80105688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568b:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105692:	ff d0                	call   *%eax
80105694:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105697:	eb 2b                	jmp    801056c4 <syscall+0x79>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569c:	8d 50 6c             	lea    0x6c(%eax),%edx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010569f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a2:	8b 40 10             	mov    0x10(%eax),%eax
801056a5:	ff 75 f0             	pushl  -0x10(%ebp)
801056a8:	52                   	push   %edx
801056a9:	50                   	push   %eax
801056aa:	68 88 8b 10 80       	push   $0x80108b88
801056af:	e8 4c ad ff ff       	call   80100400 <cprintf>
801056b4:	83 c4 10             	add    $0x10,%esp
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
801056b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ba:	8b 40 18             	mov    0x18(%eax),%eax
801056bd:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801056c4:	90                   	nop
801056c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056c8:	c9                   	leave  
801056c9:	c3                   	ret    

801056ca <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801056ca:	55                   	push   %ebp
801056cb:	89 e5                	mov    %esp,%ebp
801056cd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801056d0:	83 ec 08             	sub    $0x8,%esp
801056d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056d6:	50                   	push   %eax
801056d7:	ff 75 08             	pushl  0x8(%ebp)
801056da:	e8 ac fe ff ff       	call   8010558b <argint>
801056df:	83 c4 10             	add    $0x10,%esp
801056e2:	85 c0                	test   %eax,%eax
801056e4:	79 07                	jns    801056ed <argfd+0x23>
    return -1;
801056e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056eb:	eb 51                	jmp    8010573e <argfd+0x74>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801056ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f0:	85 c0                	test   %eax,%eax
801056f2:	78 22                	js     80105716 <argfd+0x4c>
801056f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f7:	83 f8 0f             	cmp    $0xf,%eax
801056fa:	7f 1a                	jg     80105716 <argfd+0x4c>
801056fc:	e8 f0 eb ff ff       	call   801042f1 <myproc>
80105701:	89 c2                	mov    %eax,%edx
80105703:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105706:	83 c0 08             	add    $0x8,%eax
80105709:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
8010570d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105710:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105714:	75 07                	jne    8010571d <argfd+0x53>
    return -1;
80105716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571b:	eb 21                	jmp    8010573e <argfd+0x74>
  if(pfd)
8010571d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105721:	74 08                	je     8010572b <argfd+0x61>
    *pfd = fd;
80105723:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105726:	8b 45 0c             	mov    0xc(%ebp),%eax
80105729:	89 10                	mov    %edx,(%eax)
  if(pf)
8010572b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010572f:	74 08                	je     80105739 <argfd+0x6f>
    *pf = f;
80105731:	8b 45 10             	mov    0x10(%ebp),%eax
80105734:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105737:	89 10                	mov    %edx,(%eax)
  return 0;
80105739:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010573e:	c9                   	leave  
8010573f:	c3                   	ret    

80105740 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105740:	55                   	push   %ebp
80105741:	89 e5                	mov    %esp,%ebp
80105743:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105746:	e8 a6 eb ff ff       	call   801042f1 <myproc>
8010574b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010574e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105755:	eb 2a                	jmp    80105781 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010575d:	83 c2 08             	add    $0x8,%edx
80105760:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105764:	85 c0                	test   %eax,%eax
80105766:	75 15                	jne    8010577d <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010576e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105771:	8b 55 08             	mov    0x8(%ebp),%edx
80105774:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577b:	eb 0f                	jmp    8010578c <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
8010577d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105781:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105785:	7e d0                	jle    80105757 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010578c:	c9                   	leave  
8010578d:	c3                   	ret    

8010578e <sys_dup>:

int
sys_dup(void)
{
8010578e:	55                   	push   %ebp
8010578f:	89 e5                	mov    %esp,%ebp
80105791:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105794:	83 ec 04             	sub    $0x4,%esp
80105797:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010579a:	50                   	push   %eax
8010579b:	6a 00                	push   $0x0
8010579d:	6a 00                	push   $0x0
8010579f:	e8 26 ff ff ff       	call   801056ca <argfd>
801057a4:	83 c4 10             	add    $0x10,%esp
801057a7:	85 c0                	test   %eax,%eax
801057a9:	79 07                	jns    801057b2 <sys_dup+0x24>
    return -1;
801057ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b0:	eb 31                	jmp    801057e3 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801057b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b5:	83 ec 0c             	sub    $0xc,%esp
801057b8:	50                   	push   %eax
801057b9:	e8 82 ff ff ff       	call   80105740 <fdalloc>
801057be:	83 c4 10             	add    $0x10,%esp
801057c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057c8:	79 07                	jns    801057d1 <sys_dup+0x43>
    return -1;
801057ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057cf:	eb 12                	jmp    801057e3 <sys_dup+0x55>
  filedup(f);
801057d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d4:	83 ec 0c             	sub    $0xc,%esp
801057d7:	50                   	push   %eax
801057d8:	e8 e7 b8 ff ff       	call   801010c4 <filedup>
801057dd:	83 c4 10             	add    $0x10,%esp
  return fd;
801057e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057e3:	c9                   	leave  
801057e4:	c3                   	ret    

801057e5 <sys_read>:

int
sys_read(void)
{
801057e5:	55                   	push   %ebp
801057e6:	89 e5                	mov    %esp,%ebp
801057e8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057eb:	83 ec 04             	sub    $0x4,%esp
801057ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057f1:	50                   	push   %eax
801057f2:	6a 00                	push   $0x0
801057f4:	6a 00                	push   $0x0
801057f6:	e8 cf fe ff ff       	call   801056ca <argfd>
801057fb:	83 c4 10             	add    $0x10,%esp
801057fe:	85 c0                	test   %eax,%eax
80105800:	78 2e                	js     80105830 <sys_read+0x4b>
80105802:	83 ec 08             	sub    $0x8,%esp
80105805:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105808:	50                   	push   %eax
80105809:	6a 02                	push   $0x2
8010580b:	e8 7b fd ff ff       	call   8010558b <argint>
80105810:	83 c4 10             	add    $0x10,%esp
80105813:	85 c0                	test   %eax,%eax
80105815:	78 19                	js     80105830 <sys_read+0x4b>
80105817:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581a:	83 ec 04             	sub    $0x4,%esp
8010581d:	50                   	push   %eax
8010581e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105821:	50                   	push   %eax
80105822:	6a 01                	push   $0x1
80105824:	e8 8f fd ff ff       	call   801055b8 <argptr>
80105829:	83 c4 10             	add    $0x10,%esp
8010582c:	85 c0                	test   %eax,%eax
8010582e:	79 07                	jns    80105837 <sys_read+0x52>
    return -1;
80105830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105835:	eb 17                	jmp    8010584e <sys_read+0x69>
  return fileread(f, p, n);
80105837:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010583a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010583d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105840:	83 ec 04             	sub    $0x4,%esp
80105843:	51                   	push   %ecx
80105844:	52                   	push   %edx
80105845:	50                   	push   %eax
80105846:	e8 09 ba ff ff       	call   80101254 <fileread>
8010584b:	83 c4 10             	add    $0x10,%esp
}
8010584e:	c9                   	leave  
8010584f:	c3                   	ret    

80105850 <sys_write>:

int
sys_write(void)
{
80105850:	55                   	push   %ebp
80105851:	89 e5                	mov    %esp,%ebp
80105853:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105856:	83 ec 04             	sub    $0x4,%esp
80105859:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010585c:	50                   	push   %eax
8010585d:	6a 00                	push   $0x0
8010585f:	6a 00                	push   $0x0
80105861:	e8 64 fe ff ff       	call   801056ca <argfd>
80105866:	83 c4 10             	add    $0x10,%esp
80105869:	85 c0                	test   %eax,%eax
8010586b:	78 2e                	js     8010589b <sys_write+0x4b>
8010586d:	83 ec 08             	sub    $0x8,%esp
80105870:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105873:	50                   	push   %eax
80105874:	6a 02                	push   $0x2
80105876:	e8 10 fd ff ff       	call   8010558b <argint>
8010587b:	83 c4 10             	add    $0x10,%esp
8010587e:	85 c0                	test   %eax,%eax
80105880:	78 19                	js     8010589b <sys_write+0x4b>
80105882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105885:	83 ec 04             	sub    $0x4,%esp
80105888:	50                   	push   %eax
80105889:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010588c:	50                   	push   %eax
8010588d:	6a 01                	push   $0x1
8010588f:	e8 24 fd ff ff       	call   801055b8 <argptr>
80105894:	83 c4 10             	add    $0x10,%esp
80105897:	85 c0                	test   %eax,%eax
80105899:	79 07                	jns    801058a2 <sys_write+0x52>
    return -1;
8010589b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a0:	eb 17                	jmp    801058b9 <sys_write+0x69>
  return filewrite(f, p, n);
801058a2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058a5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ab:	83 ec 04             	sub    $0x4,%esp
801058ae:	51                   	push   %ecx
801058af:	52                   	push   %edx
801058b0:	50                   	push   %eax
801058b1:	e8 56 ba ff ff       	call   8010130c <filewrite>
801058b6:	83 c4 10             	add    $0x10,%esp
}
801058b9:	c9                   	leave  
801058ba:	c3                   	ret    

801058bb <sys_close>:

int
sys_close(void)
{
801058bb:	55                   	push   %ebp
801058bc:	89 e5                	mov    %esp,%ebp
801058be:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801058c1:	83 ec 04             	sub    $0x4,%esp
801058c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058c7:	50                   	push   %eax
801058c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058cb:	50                   	push   %eax
801058cc:	6a 00                	push   $0x0
801058ce:	e8 f7 fd ff ff       	call   801056ca <argfd>
801058d3:	83 c4 10             	add    $0x10,%esp
801058d6:	85 c0                	test   %eax,%eax
801058d8:	79 07                	jns    801058e1 <sys_close+0x26>
    return -1;
801058da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058df:	eb 29                	jmp    8010590a <sys_close+0x4f>
  myproc()->ofile[fd] = 0;
801058e1:	e8 0b ea ff ff       	call   801042f1 <myproc>
801058e6:	89 c2                	mov    %eax,%edx
801058e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058eb:	83 c0 08             	add    $0x8,%eax
801058ee:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
801058f5:	00 
  fileclose(f);
801058f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f9:	83 ec 0c             	sub    $0xc,%esp
801058fc:	50                   	push   %eax
801058fd:	e8 13 b8 ff ff       	call   80101115 <fileclose>
80105902:	83 c4 10             	add    $0x10,%esp
  return 0;
80105905:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010590a:	c9                   	leave  
8010590b:	c3                   	ret    

8010590c <sys_fstat>:

int
sys_fstat(void)
{
8010590c:	55                   	push   %ebp
8010590d:	89 e5                	mov    %esp,%ebp
8010590f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105912:	83 ec 04             	sub    $0x4,%esp
80105915:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105918:	50                   	push   %eax
80105919:	6a 00                	push   $0x0
8010591b:	6a 00                	push   $0x0
8010591d:	e8 a8 fd ff ff       	call   801056ca <argfd>
80105922:	83 c4 10             	add    $0x10,%esp
80105925:	85 c0                	test   %eax,%eax
80105927:	78 17                	js     80105940 <sys_fstat+0x34>
80105929:	83 ec 04             	sub    $0x4,%esp
8010592c:	6a 14                	push   $0x14
8010592e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105931:	50                   	push   %eax
80105932:	6a 01                	push   $0x1
80105934:	e8 7f fc ff ff       	call   801055b8 <argptr>
80105939:	83 c4 10             	add    $0x10,%esp
8010593c:	85 c0                	test   %eax,%eax
8010593e:	79 07                	jns    80105947 <sys_fstat+0x3b>
    return -1;
80105940:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105945:	eb 13                	jmp    8010595a <sys_fstat+0x4e>
  return filestat(f, st);
80105947:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010594a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594d:	83 ec 08             	sub    $0x8,%esp
80105950:	52                   	push   %edx
80105951:	50                   	push   %eax
80105952:	e8 a6 b8 ff ff       	call   801011fd <filestat>
80105957:	83 c4 10             	add    $0x10,%esp
}
8010595a:	c9                   	leave  
8010595b:	c3                   	ret    

8010595c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010595c:	55                   	push   %ebp
8010595d:	89 e5                	mov    %esp,%ebp
8010595f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105962:	83 ec 08             	sub    $0x8,%esp
80105965:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105968:	50                   	push   %eax
80105969:	6a 00                	push   $0x0
8010596b:	e8 a4 fc ff ff       	call   80105614 <argstr>
80105970:	83 c4 10             	add    $0x10,%esp
80105973:	85 c0                	test   %eax,%eax
80105975:	78 15                	js     8010598c <sys_link+0x30>
80105977:	83 ec 08             	sub    $0x8,%esp
8010597a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010597d:	50                   	push   %eax
8010597e:	6a 01                	push   $0x1
80105980:	e8 8f fc ff ff       	call   80105614 <argstr>
80105985:	83 c4 10             	add    $0x10,%esp
80105988:	85 c0                	test   %eax,%eax
8010598a:	79 0a                	jns    80105996 <sys_link+0x3a>
    return -1;
8010598c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105991:	e9 68 01 00 00       	jmp    80105afe <sys_link+0x1a2>

  begin_op();
80105996:	e8 fe db ff ff       	call   80103599 <begin_op>
  if((ip = namei(old)) == 0){
8010599b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010599e:	83 ec 0c             	sub    $0xc,%esp
801059a1:	50                   	push   %eax
801059a2:	e8 0d cc ff ff       	call   801025b4 <namei>
801059a7:	83 c4 10             	add    $0x10,%esp
801059aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059b1:	75 0f                	jne    801059c2 <sys_link+0x66>
    end_op();
801059b3:	e8 6d dc ff ff       	call   80103625 <end_op>
    return -1;
801059b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059bd:	e9 3c 01 00 00       	jmp    80105afe <sys_link+0x1a2>
  }

  ilock(ip);
801059c2:	83 ec 0c             	sub    $0xc,%esp
801059c5:	ff 75 f4             	pushl  -0xc(%ebp)
801059c8:	e8 a7 c0 ff ff       	call   80101a74 <ilock>
801059cd:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801059d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059d7:	66 83 f8 01          	cmp    $0x1,%ax
801059db:	75 1d                	jne    801059fa <sys_link+0x9e>
    iunlockput(ip);
801059dd:	83 ec 0c             	sub    $0xc,%esp
801059e0:	ff 75 f4             	pushl  -0xc(%ebp)
801059e3:	e8 bd c2 ff ff       	call   80101ca5 <iunlockput>
801059e8:	83 c4 10             	add    $0x10,%esp
    end_op();
801059eb:	e8 35 dc ff ff       	call   80103625 <end_op>
    return -1;
801059f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f5:	e9 04 01 00 00       	jmp    80105afe <sys_link+0x1a2>
  }

  ip->nlink++;
801059fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a01:	83 c0 01             	add    $0x1,%eax
80105a04:	89 c2                	mov    %eax,%edx
80105a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a09:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a0d:	83 ec 0c             	sub    $0xc,%esp
80105a10:	ff 75 f4             	pushl  -0xc(%ebp)
80105a13:	e8 7f be ff ff       	call   80101897 <iupdate>
80105a18:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a1b:	83 ec 0c             	sub    $0xc,%esp
80105a1e:	ff 75 f4             	pushl  -0xc(%ebp)
80105a21:	e8 61 c1 ff ff       	call   80101b87 <iunlock>
80105a26:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a2c:	83 ec 08             	sub    $0x8,%esp
80105a2f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a32:	52                   	push   %edx
80105a33:	50                   	push   %eax
80105a34:	e8 97 cb ff ff       	call   801025d0 <nameiparent>
80105a39:	83 c4 10             	add    $0x10,%esp
80105a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a43:	74 71                	je     80105ab6 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a45:	83 ec 0c             	sub    $0xc,%esp
80105a48:	ff 75 f0             	pushl  -0x10(%ebp)
80105a4b:	e8 24 c0 ff ff       	call   80101a74 <ilock>
80105a50:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a56:	8b 10                	mov    (%eax),%edx
80105a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5b:	8b 00                	mov    (%eax),%eax
80105a5d:	39 c2                	cmp    %eax,%edx
80105a5f:	75 1d                	jne    80105a7e <sys_link+0x122>
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	8b 40 04             	mov    0x4(%eax),%eax
80105a67:	83 ec 04             	sub    $0x4,%esp
80105a6a:	50                   	push   %eax
80105a6b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a6e:	50                   	push   %eax
80105a6f:	ff 75 f0             	pushl  -0x10(%ebp)
80105a72:	e8 a2 c8 ff ff       	call   80102319 <dirlink>
80105a77:	83 c4 10             	add    $0x10,%esp
80105a7a:	85 c0                	test   %eax,%eax
80105a7c:	79 10                	jns    80105a8e <sys_link+0x132>
    iunlockput(dp);
80105a7e:	83 ec 0c             	sub    $0xc,%esp
80105a81:	ff 75 f0             	pushl  -0x10(%ebp)
80105a84:	e8 1c c2 ff ff       	call   80101ca5 <iunlockput>
80105a89:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a8c:	eb 29                	jmp    80105ab7 <sys_link+0x15b>
  }
  iunlockput(dp);
80105a8e:	83 ec 0c             	sub    $0xc,%esp
80105a91:	ff 75 f0             	pushl  -0x10(%ebp)
80105a94:	e8 0c c2 ff ff       	call   80101ca5 <iunlockput>
80105a99:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105a9c:	83 ec 0c             	sub    $0xc,%esp
80105a9f:	ff 75 f4             	pushl  -0xc(%ebp)
80105aa2:	e8 2e c1 ff ff       	call   80101bd5 <iput>
80105aa7:	83 c4 10             	add    $0x10,%esp

  end_op();
80105aaa:	e8 76 db ff ff       	call   80103625 <end_op>

  return 0;
80105aaf:	b8 00 00 00 00       	mov    $0x0,%eax
80105ab4:	eb 48                	jmp    80105afe <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105ab6:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105ab7:	83 ec 0c             	sub    $0xc,%esp
80105aba:	ff 75 f4             	pushl  -0xc(%ebp)
80105abd:	e8 b2 bf ff ff       	call   80101a74 <ilock>
80105ac2:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105acc:	83 e8 01             	sub    $0x1,%eax
80105acf:	89 c2                	mov    %eax,%edx
80105ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad4:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105ad8:	83 ec 0c             	sub    $0xc,%esp
80105adb:	ff 75 f4             	pushl  -0xc(%ebp)
80105ade:	e8 b4 bd ff ff       	call   80101897 <iupdate>
80105ae3:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ae6:	83 ec 0c             	sub    $0xc,%esp
80105ae9:	ff 75 f4             	pushl  -0xc(%ebp)
80105aec:	e8 b4 c1 ff ff       	call   80101ca5 <iunlockput>
80105af1:	83 c4 10             	add    $0x10,%esp
  end_op();
80105af4:	e8 2c db ff ff       	call   80103625 <end_op>
  return -1;
80105af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105afe:	c9                   	leave  
80105aff:	c3                   	ret    

80105b00 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b00:	55                   	push   %ebp
80105b01:	89 e5                	mov    %esp,%ebp
80105b03:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b06:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b0d:	eb 40                	jmp    80105b4f <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b12:	6a 10                	push   $0x10
80105b14:	50                   	push   %eax
80105b15:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b18:	50                   	push   %eax
80105b19:	ff 75 08             	pushl  0x8(%ebp)
80105b1c:	e8 44 c4 ff ff       	call   80101f65 <readi>
80105b21:	83 c4 10             	add    $0x10,%esp
80105b24:	83 f8 10             	cmp    $0x10,%eax
80105b27:	74 0d                	je     80105b36 <isdirempty+0x36>
      panic("isdirempty: readi");
80105b29:	83 ec 0c             	sub    $0xc,%esp
80105b2c:	68 a4 8b 10 80       	push   $0x80108ba4
80105b31:	e8 6a aa ff ff       	call   801005a0 <panic>
    if(de.inum != 0)
80105b36:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b3a:	66 85 c0             	test   %ax,%ax
80105b3d:	74 07                	je     80105b46 <isdirempty+0x46>
      return 0;
80105b3f:	b8 00 00 00 00       	mov    $0x0,%eax
80105b44:	eb 1b                	jmp    80105b61 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b49:	83 c0 10             	add    $0x10,%eax
80105b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105b52:	8b 50 58             	mov    0x58(%eax),%edx
80105b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b58:	39 c2                	cmp    %eax,%edx
80105b5a:	77 b3                	ja     80105b0f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105b5c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b61:	c9                   	leave  
80105b62:	c3                   	ret    

80105b63 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b63:	55                   	push   %ebp
80105b64:	89 e5                	mov    %esp,%ebp
80105b66:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105b69:	83 ec 08             	sub    $0x8,%esp
80105b6c:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b6f:	50                   	push   %eax
80105b70:	6a 00                	push   $0x0
80105b72:	e8 9d fa ff ff       	call   80105614 <argstr>
80105b77:	83 c4 10             	add    $0x10,%esp
80105b7a:	85 c0                	test   %eax,%eax
80105b7c:	79 0a                	jns    80105b88 <sys_unlink+0x25>
    return -1;
80105b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b83:	e9 bc 01 00 00       	jmp    80105d44 <sys_unlink+0x1e1>

  begin_op();
80105b88:	e8 0c da ff ff       	call   80103599 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105b8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105b90:	83 ec 08             	sub    $0x8,%esp
80105b93:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105b96:	52                   	push   %edx
80105b97:	50                   	push   %eax
80105b98:	e8 33 ca ff ff       	call   801025d0 <nameiparent>
80105b9d:	83 c4 10             	add    $0x10,%esp
80105ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba7:	75 0f                	jne    80105bb8 <sys_unlink+0x55>
    end_op();
80105ba9:	e8 77 da ff ff       	call   80103625 <end_op>
    return -1;
80105bae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb3:	e9 8c 01 00 00       	jmp    80105d44 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105bb8:	83 ec 0c             	sub    $0xc,%esp
80105bbb:	ff 75 f4             	pushl  -0xc(%ebp)
80105bbe:	e8 b1 be ff ff       	call   80101a74 <ilock>
80105bc3:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105bc6:	83 ec 08             	sub    $0x8,%esp
80105bc9:	68 b6 8b 10 80       	push   $0x80108bb6
80105bce:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bd1:	50                   	push   %eax
80105bd2:	e8 6d c6 ff ff       	call   80102244 <namecmp>
80105bd7:	83 c4 10             	add    $0x10,%esp
80105bda:	85 c0                	test   %eax,%eax
80105bdc:	0f 84 4a 01 00 00    	je     80105d2c <sys_unlink+0x1c9>
80105be2:	83 ec 08             	sub    $0x8,%esp
80105be5:	68 b8 8b 10 80       	push   $0x80108bb8
80105bea:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bed:	50                   	push   %eax
80105bee:	e8 51 c6 ff ff       	call   80102244 <namecmp>
80105bf3:	83 c4 10             	add    $0x10,%esp
80105bf6:	85 c0                	test   %eax,%eax
80105bf8:	0f 84 2e 01 00 00    	je     80105d2c <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105bfe:	83 ec 04             	sub    $0x4,%esp
80105c01:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c04:	50                   	push   %eax
80105c05:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c08:	50                   	push   %eax
80105c09:	ff 75 f4             	pushl  -0xc(%ebp)
80105c0c:	e8 4e c6 ff ff       	call   8010225f <dirlookup>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c1b:	0f 84 0a 01 00 00    	je     80105d2b <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105c21:	83 ec 0c             	sub    $0xc,%esp
80105c24:	ff 75 f0             	pushl  -0x10(%ebp)
80105c27:	e8 48 be ff ff       	call   80101a74 <ilock>
80105c2c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c32:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c36:	66 85 c0             	test   %ax,%ax
80105c39:	7f 0d                	jg     80105c48 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c3b:	83 ec 0c             	sub    $0xc,%esp
80105c3e:	68 bb 8b 10 80       	push   $0x80108bbb
80105c43:	e8 58 a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c4f:	66 83 f8 01          	cmp    $0x1,%ax
80105c53:	75 25                	jne    80105c7a <sys_unlink+0x117>
80105c55:	83 ec 0c             	sub    $0xc,%esp
80105c58:	ff 75 f0             	pushl  -0x10(%ebp)
80105c5b:	e8 a0 fe ff ff       	call   80105b00 <isdirempty>
80105c60:	83 c4 10             	add    $0x10,%esp
80105c63:	85 c0                	test   %eax,%eax
80105c65:	75 13                	jne    80105c7a <sys_unlink+0x117>
    iunlockput(ip);
80105c67:	83 ec 0c             	sub    $0xc,%esp
80105c6a:	ff 75 f0             	pushl  -0x10(%ebp)
80105c6d:	e8 33 c0 ff ff       	call   80101ca5 <iunlockput>
80105c72:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c75:	e9 b2 00 00 00       	jmp    80105d2c <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105c7a:	83 ec 04             	sub    $0x4,%esp
80105c7d:	6a 10                	push   $0x10
80105c7f:	6a 00                	push   $0x0
80105c81:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c84:	50                   	push   %eax
80105c85:	e8 ed f5 ff ff       	call   80105277 <memset>
80105c8a:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c8d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105c90:	6a 10                	push   $0x10
80105c92:	50                   	push   %eax
80105c93:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c96:	50                   	push   %eax
80105c97:	ff 75 f4             	pushl  -0xc(%ebp)
80105c9a:	e8 1d c4 ff ff       	call   801020bc <writei>
80105c9f:	83 c4 10             	add    $0x10,%esp
80105ca2:	83 f8 10             	cmp    $0x10,%eax
80105ca5:	74 0d                	je     80105cb4 <sys_unlink+0x151>
    panic("unlink: writei");
80105ca7:	83 ec 0c             	sub    $0xc,%esp
80105caa:	68 cd 8b 10 80       	push   $0x80108bcd
80105caf:	e8 ec a8 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR){
80105cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cbb:	66 83 f8 01          	cmp    $0x1,%ax
80105cbf:	75 21                	jne    80105ce2 <sys_unlink+0x17f>
    dp->nlink--;
80105cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cc8:	83 e8 01             	sub    $0x1,%eax
80105ccb:	89 c2                	mov    %eax,%edx
80105ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd0:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105cd4:	83 ec 0c             	sub    $0xc,%esp
80105cd7:	ff 75 f4             	pushl  -0xc(%ebp)
80105cda:	e8 b8 bb ff ff       	call   80101897 <iupdate>
80105cdf:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105ce2:	83 ec 0c             	sub    $0xc,%esp
80105ce5:	ff 75 f4             	pushl  -0xc(%ebp)
80105ce8:	e8 b8 bf ff ff       	call   80101ca5 <iunlockput>
80105ced:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105cf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cf7:	83 e8 01             	sub    $0x1,%eax
80105cfa:	89 c2                	mov    %eax,%edx
80105cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cff:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d03:	83 ec 0c             	sub    $0xc,%esp
80105d06:	ff 75 f0             	pushl  -0x10(%ebp)
80105d09:	e8 89 bb ff ff       	call   80101897 <iupdate>
80105d0e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d11:	83 ec 0c             	sub    $0xc,%esp
80105d14:	ff 75 f0             	pushl  -0x10(%ebp)
80105d17:	e8 89 bf ff ff       	call   80101ca5 <iunlockput>
80105d1c:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d1f:	e8 01 d9 ff ff       	call   80103625 <end_op>

  return 0;
80105d24:	b8 00 00 00 00       	mov    $0x0,%eax
80105d29:	eb 19                	jmp    80105d44 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d2b:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d2c:	83 ec 0c             	sub    $0xc,%esp
80105d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d32:	e8 6e bf ff ff       	call   80101ca5 <iunlockput>
80105d37:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d3a:	e8 e6 d8 ff ff       	call   80103625 <end_op>
  return -1;
80105d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d44:	c9                   	leave  
80105d45:	c3                   	ret    

80105d46 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d46:	55                   	push   %ebp
80105d47:	89 e5                	mov    %esp,%ebp
80105d49:	83 ec 38             	sub    $0x38,%esp
80105d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d4f:	8b 55 10             	mov    0x10(%ebp),%edx
80105d52:	8b 45 14             	mov    0x14(%ebp),%eax
80105d55:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d59:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d5d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d61:	83 ec 08             	sub    $0x8,%esp
80105d64:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d67:	50                   	push   %eax
80105d68:	ff 75 08             	pushl  0x8(%ebp)
80105d6b:	e8 60 c8 ff ff       	call   801025d0 <nameiparent>
80105d70:	83 c4 10             	add    $0x10,%esp
80105d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d7a:	75 0a                	jne    80105d86 <create+0x40>
    return 0;
80105d7c:	b8 00 00 00 00       	mov    $0x0,%eax
80105d81:	e9 90 01 00 00       	jmp    80105f16 <create+0x1d0>
  ilock(dp);
80105d86:	83 ec 0c             	sub    $0xc,%esp
80105d89:	ff 75 f4             	pushl  -0xc(%ebp)
80105d8c:	e8 e3 bc ff ff       	call   80101a74 <ilock>
80105d91:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105d94:	83 ec 04             	sub    $0x4,%esp
80105d97:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d9a:	50                   	push   %eax
80105d9b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d9e:	50                   	push   %eax
80105d9f:	ff 75 f4             	pushl  -0xc(%ebp)
80105da2:	e8 b8 c4 ff ff       	call   8010225f <dirlookup>
80105da7:	83 c4 10             	add    $0x10,%esp
80105daa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db1:	74 50                	je     80105e03 <create+0xbd>
    iunlockput(dp);
80105db3:	83 ec 0c             	sub    $0xc,%esp
80105db6:	ff 75 f4             	pushl  -0xc(%ebp)
80105db9:	e8 e7 be ff ff       	call   80101ca5 <iunlockput>
80105dbe:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105dc1:	83 ec 0c             	sub    $0xc,%esp
80105dc4:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc7:	e8 a8 bc ff ff       	call   80101a74 <ilock>
80105dcc:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105dcf:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105dd4:	75 15                	jne    80105deb <create+0xa5>
80105dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ddd:	66 83 f8 02          	cmp    $0x2,%ax
80105de1:	75 08                	jne    80105deb <create+0xa5>
      return ip;
80105de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de6:	e9 2b 01 00 00       	jmp    80105f16 <create+0x1d0>
    iunlockput(ip);
80105deb:	83 ec 0c             	sub    $0xc,%esp
80105dee:	ff 75 f0             	pushl  -0x10(%ebp)
80105df1:	e8 af be ff ff       	call   80101ca5 <iunlockput>
80105df6:	83 c4 10             	add    $0x10,%esp
    return 0;
80105df9:	b8 00 00 00 00       	mov    $0x0,%eax
80105dfe:	e9 13 01 00 00       	jmp    80105f16 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e03:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0a:	8b 00                	mov    (%eax),%eax
80105e0c:	83 ec 08             	sub    $0x8,%esp
80105e0f:	52                   	push   %edx
80105e10:	50                   	push   %eax
80105e11:	e8 aa b9 ff ff       	call   801017c0 <ialloc>
80105e16:	83 c4 10             	add    $0x10,%esp
80105e19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e20:	75 0d                	jne    80105e2f <create+0xe9>
    panic("create: ialloc");
80105e22:	83 ec 0c             	sub    $0xc,%esp
80105e25:	68 dc 8b 10 80       	push   $0x80108bdc
80105e2a:	e8 71 a7 ff ff       	call   801005a0 <panic>

  ilock(ip);
80105e2f:	83 ec 0c             	sub    $0xc,%esp
80105e32:	ff 75 f0             	pushl  -0x10(%ebp)
80105e35:	e8 3a bc ff ff       	call   80101a74 <ilock>
80105e3a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e40:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e44:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e4f:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e56:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105e5c:	83 ec 0c             	sub    $0xc,%esp
80105e5f:	ff 75 f0             	pushl  -0x10(%ebp)
80105e62:	e8 30 ba ff ff       	call   80101897 <iupdate>
80105e67:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105e6a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e6f:	75 6a                	jne    80105edb <create+0x195>
    dp->nlink++;  // for ".."
80105e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e74:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e78:	83 c0 01             	add    $0x1,%eax
80105e7b:	89 c2                	mov    %eax,%edx
80105e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e80:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105e84:	83 ec 0c             	sub    $0xc,%esp
80105e87:	ff 75 f4             	pushl  -0xc(%ebp)
80105e8a:	e8 08 ba ff ff       	call   80101897 <iupdate>
80105e8f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e95:	8b 40 04             	mov    0x4(%eax),%eax
80105e98:	83 ec 04             	sub    $0x4,%esp
80105e9b:	50                   	push   %eax
80105e9c:	68 b6 8b 10 80       	push   $0x80108bb6
80105ea1:	ff 75 f0             	pushl  -0x10(%ebp)
80105ea4:	e8 70 c4 ff ff       	call   80102319 <dirlink>
80105ea9:	83 c4 10             	add    $0x10,%esp
80105eac:	85 c0                	test   %eax,%eax
80105eae:	78 1e                	js     80105ece <create+0x188>
80105eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb3:	8b 40 04             	mov    0x4(%eax),%eax
80105eb6:	83 ec 04             	sub    $0x4,%esp
80105eb9:	50                   	push   %eax
80105eba:	68 b8 8b 10 80       	push   $0x80108bb8
80105ebf:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec2:	e8 52 c4 ff ff       	call   80102319 <dirlink>
80105ec7:	83 c4 10             	add    $0x10,%esp
80105eca:	85 c0                	test   %eax,%eax
80105ecc:	79 0d                	jns    80105edb <create+0x195>
      panic("create dots");
80105ece:	83 ec 0c             	sub    $0xc,%esp
80105ed1:	68 eb 8b 10 80       	push   $0x80108beb
80105ed6:	e8 c5 a6 ff ff       	call   801005a0 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ede:	8b 40 04             	mov    0x4(%eax),%eax
80105ee1:	83 ec 04             	sub    $0x4,%esp
80105ee4:	50                   	push   %eax
80105ee5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ee8:	50                   	push   %eax
80105ee9:	ff 75 f4             	pushl  -0xc(%ebp)
80105eec:	e8 28 c4 ff ff       	call   80102319 <dirlink>
80105ef1:	83 c4 10             	add    $0x10,%esp
80105ef4:	85 c0                	test   %eax,%eax
80105ef6:	79 0d                	jns    80105f05 <create+0x1bf>
    panic("create: dirlink");
80105ef8:	83 ec 0c             	sub    $0xc,%esp
80105efb:	68 f7 8b 10 80       	push   $0x80108bf7
80105f00:	e8 9b a6 ff ff       	call   801005a0 <panic>

  iunlockput(dp);
80105f05:	83 ec 0c             	sub    $0xc,%esp
80105f08:	ff 75 f4             	pushl  -0xc(%ebp)
80105f0b:	e8 95 bd ff ff       	call   80101ca5 <iunlockput>
80105f10:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f16:	c9                   	leave  
80105f17:	c3                   	ret    

80105f18 <sys_open>:

int
sys_open(void)
{
80105f18:	55                   	push   %ebp
80105f19:	89 e5                	mov    %esp,%ebp
80105f1b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f1e:	83 ec 08             	sub    $0x8,%esp
80105f21:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f24:	50                   	push   %eax
80105f25:	6a 00                	push   $0x0
80105f27:	e8 e8 f6 ff ff       	call   80105614 <argstr>
80105f2c:	83 c4 10             	add    $0x10,%esp
80105f2f:	85 c0                	test   %eax,%eax
80105f31:	78 15                	js     80105f48 <sys_open+0x30>
80105f33:	83 ec 08             	sub    $0x8,%esp
80105f36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f39:	50                   	push   %eax
80105f3a:	6a 01                	push   $0x1
80105f3c:	e8 4a f6 ff ff       	call   8010558b <argint>
80105f41:	83 c4 10             	add    $0x10,%esp
80105f44:	85 c0                	test   %eax,%eax
80105f46:	79 0a                	jns    80105f52 <sys_open+0x3a>
    return -1;
80105f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f4d:	e9 61 01 00 00       	jmp    801060b3 <sys_open+0x19b>

  begin_op();
80105f52:	e8 42 d6 ff ff       	call   80103599 <begin_op>

  if(omode & O_CREATE){
80105f57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f5a:	25 00 02 00 00       	and    $0x200,%eax
80105f5f:	85 c0                	test   %eax,%eax
80105f61:	74 2a                	je     80105f8d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105f63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f66:	6a 00                	push   $0x0
80105f68:	6a 00                	push   $0x0
80105f6a:	6a 02                	push   $0x2
80105f6c:	50                   	push   %eax
80105f6d:	e8 d4 fd ff ff       	call   80105d46 <create>
80105f72:	83 c4 10             	add    $0x10,%esp
80105f75:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105f78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f7c:	75 75                	jne    80105ff3 <sys_open+0xdb>
      end_op();
80105f7e:	e8 a2 d6 ff ff       	call   80103625 <end_op>
      return -1;
80105f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f88:	e9 26 01 00 00       	jmp    801060b3 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105f8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f90:	83 ec 0c             	sub    $0xc,%esp
80105f93:	50                   	push   %eax
80105f94:	e8 1b c6 ff ff       	call   801025b4 <namei>
80105f99:	83 c4 10             	add    $0x10,%esp
80105f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fa3:	75 0f                	jne    80105fb4 <sys_open+0x9c>
      end_op();
80105fa5:	e8 7b d6 ff ff       	call   80103625 <end_op>
      return -1;
80105faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105faf:	e9 ff 00 00 00       	jmp    801060b3 <sys_open+0x19b>
    }
    ilock(ip);
80105fb4:	83 ec 0c             	sub    $0xc,%esp
80105fb7:	ff 75 f4             	pushl  -0xc(%ebp)
80105fba:	e8 b5 ba ff ff       	call   80101a74 <ilock>
80105fbf:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fc9:	66 83 f8 01          	cmp    $0x1,%ax
80105fcd:	75 24                	jne    80105ff3 <sys_open+0xdb>
80105fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd2:	85 c0                	test   %eax,%eax
80105fd4:	74 1d                	je     80105ff3 <sys_open+0xdb>
      iunlockput(ip);
80105fd6:	83 ec 0c             	sub    $0xc,%esp
80105fd9:	ff 75 f4             	pushl  -0xc(%ebp)
80105fdc:	e8 c4 bc ff ff       	call   80101ca5 <iunlockput>
80105fe1:	83 c4 10             	add    $0x10,%esp
      end_op();
80105fe4:	e8 3c d6 ff ff       	call   80103625 <end_op>
      return -1;
80105fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fee:	e9 c0 00 00 00       	jmp    801060b3 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105ff3:	e8 5f b0 ff ff       	call   80101057 <filealloc>
80105ff8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ffb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fff:	74 17                	je     80106018 <sys_open+0x100>
80106001:	83 ec 0c             	sub    $0xc,%esp
80106004:	ff 75 f0             	pushl  -0x10(%ebp)
80106007:	e8 34 f7 ff ff       	call   80105740 <fdalloc>
8010600c:	83 c4 10             	add    $0x10,%esp
8010600f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106012:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106016:	79 2e                	jns    80106046 <sys_open+0x12e>
    if(f)
80106018:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010601c:	74 0e                	je     8010602c <sys_open+0x114>
      fileclose(f);
8010601e:	83 ec 0c             	sub    $0xc,%esp
80106021:	ff 75 f0             	pushl  -0x10(%ebp)
80106024:	e8 ec b0 ff ff       	call   80101115 <fileclose>
80106029:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010602c:	83 ec 0c             	sub    $0xc,%esp
8010602f:	ff 75 f4             	pushl  -0xc(%ebp)
80106032:	e8 6e bc ff ff       	call   80101ca5 <iunlockput>
80106037:	83 c4 10             	add    $0x10,%esp
    end_op();
8010603a:	e8 e6 d5 ff ff       	call   80103625 <end_op>
    return -1;
8010603f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106044:	eb 6d                	jmp    801060b3 <sys_open+0x19b>
  }
  iunlock(ip);
80106046:	83 ec 0c             	sub    $0xc,%esp
80106049:	ff 75 f4             	pushl  -0xc(%ebp)
8010604c:	e8 36 bb ff ff       	call   80101b87 <iunlock>
80106051:	83 c4 10             	add    $0x10,%esp
  end_op();
80106054:	e8 cc d5 ff ff       	call   80103625 <end_op>

  f->type = FD_INODE;
80106059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106065:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106068:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010606b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106078:	83 e0 01             	and    $0x1,%eax
8010607b:	85 c0                	test   %eax,%eax
8010607d:	0f 94 c0             	sete   %al
80106080:	89 c2                	mov    %eax,%edx
80106082:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106085:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010608b:	83 e0 01             	and    $0x1,%eax
8010608e:	85 c0                	test   %eax,%eax
80106090:	75 0a                	jne    8010609c <sys_open+0x184>
80106092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106095:	83 e0 02             	and    $0x2,%eax
80106098:	85 c0                	test   %eax,%eax
8010609a:	74 07                	je     801060a3 <sys_open+0x18b>
8010609c:	b8 01 00 00 00       	mov    $0x1,%eax
801060a1:	eb 05                	jmp    801060a8 <sys_open+0x190>
801060a3:	b8 00 00 00 00       	mov    $0x0,%eax
801060a8:	89 c2                	mov    %eax,%edx
801060aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ad:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060b3:	c9                   	leave  
801060b4:	c3                   	ret    

801060b5 <sys_mkdir>:

int
sys_mkdir(void)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060bb:	e8 d9 d4 ff ff       	call   80103599 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060c0:	83 ec 08             	sub    $0x8,%esp
801060c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c6:	50                   	push   %eax
801060c7:	6a 00                	push   $0x0
801060c9:	e8 46 f5 ff ff       	call   80105614 <argstr>
801060ce:	83 c4 10             	add    $0x10,%esp
801060d1:	85 c0                	test   %eax,%eax
801060d3:	78 1b                	js     801060f0 <sys_mkdir+0x3b>
801060d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d8:	6a 00                	push   $0x0
801060da:	6a 00                	push   $0x0
801060dc:	6a 01                	push   $0x1
801060de:	50                   	push   %eax
801060df:	e8 62 fc ff ff       	call   80105d46 <create>
801060e4:	83 c4 10             	add    $0x10,%esp
801060e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ee:	75 0c                	jne    801060fc <sys_mkdir+0x47>
    end_op();
801060f0:	e8 30 d5 ff ff       	call   80103625 <end_op>
    return -1;
801060f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060fa:	eb 18                	jmp    80106114 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801060fc:	83 ec 0c             	sub    $0xc,%esp
801060ff:	ff 75 f4             	pushl  -0xc(%ebp)
80106102:	e8 9e bb ff ff       	call   80101ca5 <iunlockput>
80106107:	83 c4 10             	add    $0x10,%esp
  end_op();
8010610a:	e8 16 d5 ff ff       	call   80103625 <end_op>
  return 0;
8010610f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106114:	c9                   	leave  
80106115:	c3                   	ret    

80106116 <sys_mknod>:

int
sys_mknod(void)
{
80106116:	55                   	push   %ebp
80106117:	89 e5                	mov    %esp,%ebp
80106119:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010611c:	e8 78 d4 ff ff       	call   80103599 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106121:	83 ec 08             	sub    $0x8,%esp
80106124:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106127:	50                   	push   %eax
80106128:	6a 00                	push   $0x0
8010612a:	e8 e5 f4 ff ff       	call   80105614 <argstr>
8010612f:	83 c4 10             	add    $0x10,%esp
80106132:	85 c0                	test   %eax,%eax
80106134:	78 4f                	js     80106185 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106136:	83 ec 08             	sub    $0x8,%esp
80106139:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010613c:	50                   	push   %eax
8010613d:	6a 01                	push   $0x1
8010613f:	e8 47 f4 ff ff       	call   8010558b <argint>
80106144:	83 c4 10             	add    $0x10,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106147:	85 c0                	test   %eax,%eax
80106149:	78 3a                	js     80106185 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010614b:	83 ec 08             	sub    $0x8,%esp
8010614e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106151:	50                   	push   %eax
80106152:	6a 02                	push   $0x2
80106154:	e8 32 f4 ff ff       	call   8010558b <argint>
80106159:	83 c4 10             	add    $0x10,%esp
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010615c:	85 c0                	test   %eax,%eax
8010615e:	78 25                	js     80106185 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106160:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106163:	0f bf c8             	movswl %ax,%ecx
80106166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106169:	0f bf d0             	movswl %ax,%edx
8010616c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010616f:	51                   	push   %ecx
80106170:	52                   	push   %edx
80106171:	6a 03                	push   $0x3
80106173:	50                   	push   %eax
80106174:	e8 cd fb ff ff       	call   80105d46 <create>
80106179:	83 c4 10             	add    $0x10,%esp
8010617c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010617f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106183:	75 0c                	jne    80106191 <sys_mknod+0x7b>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106185:	e8 9b d4 ff ff       	call   80103625 <end_op>
    return -1;
8010618a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618f:	eb 18                	jmp    801061a9 <sys_mknod+0x93>
  }
  iunlockput(ip);
80106191:	83 ec 0c             	sub    $0xc,%esp
80106194:	ff 75 f4             	pushl  -0xc(%ebp)
80106197:	e8 09 bb ff ff       	call   80101ca5 <iunlockput>
8010619c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010619f:	e8 81 d4 ff ff       	call   80103625 <end_op>
  return 0;
801061a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061a9:	c9                   	leave  
801061aa:	c3                   	ret    

801061ab <sys_chdir>:

int
sys_chdir(void)
{
801061ab:	55                   	push   %ebp
801061ac:	89 e5                	mov    %esp,%ebp
801061ae:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801061b1:	e8 3b e1 ff ff       	call   801042f1 <myproc>
801061b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801061b9:	e8 db d3 ff ff       	call   80103599 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801061be:	83 ec 08             	sub    $0x8,%esp
801061c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061c4:	50                   	push   %eax
801061c5:	6a 00                	push   $0x0
801061c7:	e8 48 f4 ff ff       	call   80105614 <argstr>
801061cc:	83 c4 10             	add    $0x10,%esp
801061cf:	85 c0                	test   %eax,%eax
801061d1:	78 18                	js     801061eb <sys_chdir+0x40>
801061d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061d6:	83 ec 0c             	sub    $0xc,%esp
801061d9:	50                   	push   %eax
801061da:	e8 d5 c3 ff ff       	call   801025b4 <namei>
801061df:	83 c4 10             	add    $0x10,%esp
801061e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e9:	75 0c                	jne    801061f7 <sys_chdir+0x4c>
    end_op();
801061eb:	e8 35 d4 ff ff       	call   80103625 <end_op>
    return -1;
801061f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f5:	eb 68                	jmp    8010625f <sys_chdir+0xb4>
  }
  ilock(ip);
801061f7:	83 ec 0c             	sub    $0xc,%esp
801061fa:	ff 75 f0             	pushl  -0x10(%ebp)
801061fd:	e8 72 b8 ff ff       	call   80101a74 <ilock>
80106202:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106205:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106208:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010620c:	66 83 f8 01          	cmp    $0x1,%ax
80106210:	74 1a                	je     8010622c <sys_chdir+0x81>
    iunlockput(ip);
80106212:	83 ec 0c             	sub    $0xc,%esp
80106215:	ff 75 f0             	pushl  -0x10(%ebp)
80106218:	e8 88 ba ff ff       	call   80101ca5 <iunlockput>
8010621d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106220:	e8 00 d4 ff ff       	call   80103625 <end_op>
    return -1;
80106225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622a:	eb 33                	jmp    8010625f <sys_chdir+0xb4>
  }
  iunlock(ip);
8010622c:	83 ec 0c             	sub    $0xc,%esp
8010622f:	ff 75 f0             	pushl  -0x10(%ebp)
80106232:	e8 50 b9 ff ff       	call   80101b87 <iunlock>
80106237:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010623a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623d:	8b 40 68             	mov    0x68(%eax),%eax
80106240:	83 ec 0c             	sub    $0xc,%esp
80106243:	50                   	push   %eax
80106244:	e8 8c b9 ff ff       	call   80101bd5 <iput>
80106249:	83 c4 10             	add    $0x10,%esp
  end_op();
8010624c:	e8 d4 d3 ff ff       	call   80103625 <end_op>
  curproc->cwd = ip;
80106251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106254:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106257:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010625a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010625f:	c9                   	leave  
80106260:	c3                   	ret    

80106261 <sys_exec>:

int
sys_exec(void)
{
80106261:	55                   	push   %ebp
80106262:	89 e5                	mov    %esp,%ebp
80106264:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010626a:	83 ec 08             	sub    $0x8,%esp
8010626d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106270:	50                   	push   %eax
80106271:	6a 00                	push   $0x0
80106273:	e8 9c f3 ff ff       	call   80105614 <argstr>
80106278:	83 c4 10             	add    $0x10,%esp
8010627b:	85 c0                	test   %eax,%eax
8010627d:	78 18                	js     80106297 <sys_exec+0x36>
8010627f:	83 ec 08             	sub    $0x8,%esp
80106282:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106288:	50                   	push   %eax
80106289:	6a 01                	push   $0x1
8010628b:	e8 fb f2 ff ff       	call   8010558b <argint>
80106290:	83 c4 10             	add    $0x10,%esp
80106293:	85 c0                	test   %eax,%eax
80106295:	79 0a                	jns    801062a1 <sys_exec+0x40>
    return -1;
80106297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629c:	e9 c6 00 00 00       	jmp    80106367 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801062a1:	83 ec 04             	sub    $0x4,%esp
801062a4:	68 80 00 00 00       	push   $0x80
801062a9:	6a 00                	push   $0x0
801062ab:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062b1:	50                   	push   %eax
801062b2:	e8 c0 ef ff ff       	call   80105277 <memset>
801062b7:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801062ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801062c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c4:	83 f8 1f             	cmp    $0x1f,%eax
801062c7:	76 0a                	jbe    801062d3 <sys_exec+0x72>
      return -1;
801062c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ce:	e9 94 00 00 00       	jmp    80106367 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d6:	c1 e0 02             	shl    $0x2,%eax
801062d9:	89 c2                	mov    %eax,%edx
801062db:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801062e1:	01 c2                	add    %eax,%edx
801062e3:	83 ec 08             	sub    $0x8,%esp
801062e6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801062ec:	50                   	push   %eax
801062ed:	52                   	push   %edx
801062ee:	e8 0d f2 ff ff       	call   80105500 <fetchint>
801062f3:	83 c4 10             	add    $0x10,%esp
801062f6:	85 c0                	test   %eax,%eax
801062f8:	79 07                	jns    80106301 <sys_exec+0xa0>
      return -1;
801062fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ff:	eb 66                	jmp    80106367 <sys_exec+0x106>
    if(uarg == 0){
80106301:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106307:	85 c0                	test   %eax,%eax
80106309:	75 27                	jne    80106332 <sys_exec+0xd1>
      argv[i] = 0;
8010630b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106315:	00 00 00 00 
      break;
80106319:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010631a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631d:	83 ec 08             	sub    $0x8,%esp
80106320:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106326:	52                   	push   %edx
80106327:	50                   	push   %eax
80106328:	e8 69 a8 ff ff       	call   80100b96 <exec>
8010632d:	83 c4 10             	add    $0x10,%esp
80106330:	eb 35                	jmp    80106367 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106332:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106338:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010633b:	c1 e2 02             	shl    $0x2,%edx
8010633e:	01 c2                	add    %eax,%edx
80106340:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106346:	83 ec 08             	sub    $0x8,%esp
80106349:	52                   	push   %edx
8010634a:	50                   	push   %eax
8010634b:	e8 e1 f1 ff ff       	call   80105531 <fetchstr>
80106350:	83 c4 10             	add    $0x10,%esp
80106353:	85 c0                	test   %eax,%eax
80106355:	79 07                	jns    8010635e <sys_exec+0xfd>
      return -1;
80106357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635c:	eb 09                	jmp    80106367 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010635e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106362:	e9 5a ff ff ff       	jmp    801062c1 <sys_exec+0x60>
  return exec(path, argv);
}
80106367:	c9                   	leave  
80106368:	c3                   	ret    

80106369 <sys_pipe>:

int
sys_pipe(void)
{
80106369:	55                   	push   %ebp
8010636a:	89 e5                	mov    %esp,%ebp
8010636c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010636f:	83 ec 04             	sub    $0x4,%esp
80106372:	6a 08                	push   $0x8
80106374:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106377:	50                   	push   %eax
80106378:	6a 00                	push   $0x0
8010637a:	e8 39 f2 ff ff       	call   801055b8 <argptr>
8010637f:	83 c4 10             	add    $0x10,%esp
80106382:	85 c0                	test   %eax,%eax
80106384:	79 0a                	jns    80106390 <sys_pipe+0x27>
    return -1;
80106386:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638b:	e9 b0 00 00 00       	jmp    80106440 <sys_pipe+0xd7>
  if(pipealloc(&rf, &wf) < 0)
80106390:	83 ec 08             	sub    $0x8,%esp
80106393:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106396:	50                   	push   %eax
80106397:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010639a:	50                   	push   %eax
8010639b:	e8 88 da ff ff       	call   80103e28 <pipealloc>
801063a0:	83 c4 10             	add    $0x10,%esp
801063a3:	85 c0                	test   %eax,%eax
801063a5:	79 0a                	jns    801063b1 <sys_pipe+0x48>
    return -1;
801063a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ac:	e9 8f 00 00 00       	jmp    80106440 <sys_pipe+0xd7>
  fd0 = -1;
801063b1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801063b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063bb:	83 ec 0c             	sub    $0xc,%esp
801063be:	50                   	push   %eax
801063bf:	e8 7c f3 ff ff       	call   80105740 <fdalloc>
801063c4:	83 c4 10             	add    $0x10,%esp
801063c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ce:	78 18                	js     801063e8 <sys_pipe+0x7f>
801063d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063d3:	83 ec 0c             	sub    $0xc,%esp
801063d6:	50                   	push   %eax
801063d7:	e8 64 f3 ff ff       	call   80105740 <fdalloc>
801063dc:	83 c4 10             	add    $0x10,%esp
801063df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e6:	79 40                	jns    80106428 <sys_pipe+0xbf>
    if(fd0 >= 0)
801063e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ec:	78 15                	js     80106403 <sys_pipe+0x9a>
      myproc()->ofile[fd0] = 0;
801063ee:	e8 fe de ff ff       	call   801042f1 <myproc>
801063f3:	89 c2                	mov    %eax,%edx
801063f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f8:	83 c0 08             	add    $0x8,%eax
801063fb:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
80106402:	00 
    fileclose(rf);
80106403:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106406:	83 ec 0c             	sub    $0xc,%esp
80106409:	50                   	push   %eax
8010640a:	e8 06 ad ff ff       	call   80101115 <fileclose>
8010640f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106415:	83 ec 0c             	sub    $0xc,%esp
80106418:	50                   	push   %eax
80106419:	e8 f7 ac ff ff       	call   80101115 <fileclose>
8010641e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106421:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106426:	eb 18                	jmp    80106440 <sys_pipe+0xd7>
  }
  fd[0] = fd0;
80106428:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010642b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010642e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106430:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106433:	8d 50 04             	lea    0x4(%eax),%edx
80106436:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106439:	89 02                	mov    %eax,(%edx)
  return 0;
8010643b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106440:	c9                   	leave  
80106441:	c3                   	ret    

80106442 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
80106442:	55                   	push   %ebp
80106443:	89 e5                	mov    %esp,%ebp
80106445:	83 ec 18             	sub    $0x18,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
80106448:	83 ec 08             	sub    $0x8,%esp
8010644b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010644e:	50                   	push   %eax
8010644f:	6a 00                	push   $0x0
80106451:	e8 35 f1 ff ff       	call   8010558b <argint>
80106456:	83 c4 10             	add    $0x10,%esp
80106459:	85 c0                	test   %eax,%eax
8010645b:	79 07                	jns    80106464 <sys_shm_open+0x22>
    return -1;
8010645d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106462:	eb 31                	jmp    80106495 <sys_shm_open+0x53>

  if(argptr(1, (char **) (&pointer),4)<0)
80106464:	83 ec 04             	sub    $0x4,%esp
80106467:	6a 04                	push   $0x4
80106469:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646c:	50                   	push   %eax
8010646d:	6a 01                	push   $0x1
8010646f:	e8 44 f1 ff ff       	call   801055b8 <argptr>
80106474:	83 c4 10             	add    $0x10,%esp
80106477:	85 c0                	test   %eax,%eax
80106479:	79 07                	jns    80106482 <sys_shm_open+0x40>
    return -1;
8010647b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106480:	eb 13                	jmp    80106495 <sys_shm_open+0x53>
  return shm_open(id, pointer);
80106482:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106488:	83 ec 08             	sub    $0x8,%esp
8010648b:	52                   	push   %edx
8010648c:	50                   	push   %eax
8010648d:	e8 4d 22 00 00       	call   801086df <shm_open>
80106492:	83 c4 10             	add    $0x10,%esp
}
80106495:	c9                   	leave  
80106496:	c3                   	ret    

80106497 <sys_shm_close>:

int sys_shm_close(void) {
80106497:	55                   	push   %ebp
80106498:	89 e5                	mov    %esp,%ebp
8010649a:	83 ec 18             	sub    $0x18,%esp
  int id;

  if(argint(0, &id) < 0)
8010649d:	83 ec 08             	sub    $0x8,%esp
801064a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064a3:	50                   	push   %eax
801064a4:	6a 00                	push   $0x0
801064a6:	e8 e0 f0 ff ff       	call   8010558b <argint>
801064ab:	83 c4 10             	add    $0x10,%esp
801064ae:	85 c0                	test   %eax,%eax
801064b0:	79 07                	jns    801064b9 <sys_shm_close+0x22>
    return -1;
801064b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b7:	eb 0f                	jmp    801064c8 <sys_shm_close+0x31>

  
  return shm_close(id);
801064b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bc:	83 ec 0c             	sub    $0xc,%esp
801064bf:	50                   	push   %eax
801064c0:	e8 24 22 00 00       	call   801086e9 <shm_close>
801064c5:	83 c4 10             	add    $0x10,%esp
}
801064c8:	c9                   	leave  
801064c9:	c3                   	ret    

801064ca <sys_fork>:

int
sys_fork(void)
{
801064ca:	55                   	push   %ebp
801064cb:	89 e5                	mov    %esp,%ebp
801064cd:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064d0:	e8 24 e1 ff ff       	call   801045f9 <fork>
}
801064d5:	c9                   	leave  
801064d6:	c3                   	ret    

801064d7 <sys_exit>:

int
sys_exit(void)
{
801064d7:	55                   	push   %ebp
801064d8:	89 e5                	mov    %esp,%ebp
801064da:	83 ec 08             	sub    $0x8,%esp
  exit();
801064dd:	e8 c0 e2 ff ff       	call   801047a2 <exit>
  return 0;  // not reached
801064e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e7:	c9                   	leave  
801064e8:	c3                   	ret    

801064e9 <sys_wait>:

int
sys_wait(void)
{
801064e9:	55                   	push   %ebp
801064ea:	89 e5                	mov    %esp,%ebp
801064ec:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064ef:	e8 d1 e3 ff ff       	call   801048c5 <wait>
}
801064f4:	c9                   	leave  
801064f5:	c3                   	ret    

801064f6 <sys_kill>:

int
sys_kill(void)
{
801064f6:	55                   	push   %ebp
801064f7:	89 e5                	mov    %esp,%ebp
801064f9:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064fc:	83 ec 08             	sub    $0x8,%esp
801064ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106502:	50                   	push   %eax
80106503:	6a 00                	push   $0x0
80106505:	e8 81 f0 ff ff       	call   8010558b <argint>
8010650a:	83 c4 10             	add    $0x10,%esp
8010650d:	85 c0                	test   %eax,%eax
8010650f:	79 07                	jns    80106518 <sys_kill+0x22>
    return -1;
80106511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106516:	eb 0f                	jmp    80106527 <sys_kill+0x31>
  return kill(pid);
80106518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651b:	83 ec 0c             	sub    $0xc,%esp
8010651e:	50                   	push   %eax
8010651f:	e8 da e7 ff ff       	call   80104cfe <kill>
80106524:	83 c4 10             	add    $0x10,%esp
}
80106527:	c9                   	leave  
80106528:	c3                   	ret    

80106529 <sys_getpid>:

int
sys_getpid(void)
{
80106529:	55                   	push   %ebp
8010652a:	89 e5                	mov    %esp,%ebp
8010652c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010652f:	e8 bd dd ff ff       	call   801042f1 <myproc>
80106534:	8b 40 10             	mov    0x10(%eax),%eax
}
80106537:	c9                   	leave  
80106538:	c3                   	ret    

80106539 <sys_sbrk>:

int
sys_sbrk(void)
{
80106539:	55                   	push   %ebp
8010653a:	89 e5                	mov    %esp,%ebp
8010653c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010653f:	83 ec 08             	sub    $0x8,%esp
80106542:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106545:	50                   	push   %eax
80106546:	6a 00                	push   $0x0
80106548:	e8 3e f0 ff ff       	call   8010558b <argint>
8010654d:	83 c4 10             	add    $0x10,%esp
80106550:	85 c0                	test   %eax,%eax
80106552:	79 07                	jns    8010655b <sys_sbrk+0x22>
    return -1;
80106554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106559:	eb 27                	jmp    80106582 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010655b:	e8 91 dd ff ff       	call   801042f1 <myproc>
80106560:	8b 00                	mov    (%eax),%eax
80106562:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106568:	83 ec 0c             	sub    $0xc,%esp
8010656b:	50                   	push   %eax
8010656c:	e8 ed df ff ff       	call   8010455e <growproc>
80106571:	83 c4 10             	add    $0x10,%esp
80106574:	85 c0                	test   %eax,%eax
80106576:	79 07                	jns    8010657f <sys_sbrk+0x46>
    return -1;
80106578:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657d:	eb 03                	jmp    80106582 <sys_sbrk+0x49>
  return addr;
8010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106582:	c9                   	leave  
80106583:	c3                   	ret    

80106584 <sys_sleep>:

int
sys_sleep(void)
{
80106584:	55                   	push   %ebp
80106585:	89 e5                	mov    %esp,%ebp
80106587:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010658a:	83 ec 08             	sub    $0x8,%esp
8010658d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106590:	50                   	push   %eax
80106591:	6a 00                	push   $0x0
80106593:	e8 f3 ef ff ff       	call   8010558b <argint>
80106598:	83 c4 10             	add    $0x10,%esp
8010659b:	85 c0                	test   %eax,%eax
8010659d:	79 07                	jns    801065a6 <sys_sleep+0x22>
    return -1;
8010659f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a4:	eb 76                	jmp    8010661c <sys_sleep+0x98>
  acquire(&tickslock);
801065a6:	83 ec 0c             	sub    $0xc,%esp
801065a9:	68 e0 5e 11 80       	push   $0x80115ee0
801065ae:	e8 4d ea ff ff       	call   80105000 <acquire>
801065b3:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065b6:	a1 20 67 11 80       	mov    0x80116720,%eax
801065bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065be:	eb 38                	jmp    801065f8 <sys_sleep+0x74>
    if(myproc()->killed){
801065c0:	e8 2c dd ff ff       	call   801042f1 <myproc>
801065c5:	8b 40 24             	mov    0x24(%eax),%eax
801065c8:	85 c0                	test   %eax,%eax
801065ca:	74 17                	je     801065e3 <sys_sleep+0x5f>
      release(&tickslock);
801065cc:	83 ec 0c             	sub    $0xc,%esp
801065cf:	68 e0 5e 11 80       	push   $0x80115ee0
801065d4:	e8 95 ea ff ff       	call   8010506e <release>
801065d9:	83 c4 10             	add    $0x10,%esp
      return -1;
801065dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e1:	eb 39                	jmp    8010661c <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801065e3:	83 ec 08             	sub    $0x8,%esp
801065e6:	68 e0 5e 11 80       	push   $0x80115ee0
801065eb:	68 20 67 11 80       	push   $0x80116720
801065f0:	e8 e9 e5 ff ff       	call   80104bde <sleep>
801065f5:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801065f8:	a1 20 67 11 80       	mov    0x80116720,%eax
801065fd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106600:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106603:	39 d0                	cmp    %edx,%eax
80106605:	72 b9                	jb     801065c0 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106607:	83 ec 0c             	sub    $0xc,%esp
8010660a:	68 e0 5e 11 80       	push   $0x80115ee0
8010660f:	e8 5a ea ff ff       	call   8010506e <release>
80106614:	83 c4 10             	add    $0x10,%esp
  return 0;
80106617:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010661c:	c9                   	leave  
8010661d:	c3                   	ret    

8010661e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010661e:	55                   	push   %ebp
8010661f:	89 e5                	mov    %esp,%ebp
80106621:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106624:	83 ec 0c             	sub    $0xc,%esp
80106627:	68 e0 5e 11 80       	push   $0x80115ee0
8010662c:	e8 cf e9 ff ff       	call   80105000 <acquire>
80106631:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106634:	a1 20 67 11 80       	mov    0x80116720,%eax
80106639:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010663c:	83 ec 0c             	sub    $0xc,%esp
8010663f:	68 e0 5e 11 80       	push   $0x80115ee0
80106644:	e8 25 ea ff ff       	call   8010506e <release>
80106649:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010664c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010664f:	c9                   	leave  
80106650:	c3                   	ret    

80106651 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106651:	1e                   	push   %ds
  pushl %es
80106652:	06                   	push   %es
  pushl %fs
80106653:	0f a0                	push   %fs
  pushl %gs
80106655:	0f a8                	push   %gs
  pushal
80106657:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106658:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010665c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010665e:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106660:	54                   	push   %esp
  call trap
80106661:	e8 d7 01 00 00       	call   8010683d <trap>
  addl $4, %esp
80106666:	83 c4 04             	add    $0x4,%esp

80106669 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106669:	61                   	popa   
  popl %gs
8010666a:	0f a9                	pop    %gs
  popl %fs
8010666c:	0f a1                	pop    %fs
  popl %es
8010666e:	07                   	pop    %es
  popl %ds
8010666f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106670:	83 c4 08             	add    $0x8,%esp
  iret
80106673:	cf                   	iret   

80106674 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106674:	55                   	push   %ebp
80106675:	89 e5                	mov    %esp,%ebp
80106677:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010667a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010667d:	83 e8 01             	sub    $0x1,%eax
80106680:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106684:	8b 45 08             	mov    0x8(%ebp),%eax
80106687:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010668b:	8b 45 08             	mov    0x8(%ebp),%eax
8010668e:	c1 e8 10             	shr    $0x10,%eax
80106691:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106695:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106698:	0f 01 18             	lidtl  (%eax)
}
8010669b:	90                   	nop
8010669c:	c9                   	leave  
8010669d:	c3                   	ret    

8010669e <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010669e:	55                   	push   %ebp
8010669f:	89 e5                	mov    %esp,%ebp
801066a1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066a4:	0f 20 d0             	mov    %cr2,%eax
801066a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066ad:	c9                   	leave  
801066ae:	c3                   	ret    

801066af <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066af:	55                   	push   %ebp
801066b0:	89 e5                	mov    %esp,%ebp
801066b2:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801066b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066bc:	e9 c3 00 00 00       	jmp    80106784 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c4:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801066cb:	89 c2                	mov    %eax,%edx
801066cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d0:	66 89 14 c5 20 5f 11 	mov    %dx,-0x7feea0e0(,%eax,8)
801066d7:	80 
801066d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066db:	66 c7 04 c5 22 5f 11 	movw   $0x8,-0x7feea0de(,%eax,8)
801066e2:	80 08 00 
801066e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e8:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
801066ef:	80 
801066f0:	83 e2 e0             	and    $0xffffffe0,%edx
801066f3:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
801066fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fd:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
80106704:	80 
80106705:	83 e2 1f             	and    $0x1f,%edx
80106708:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
8010670f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106712:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106719:	80 
8010671a:	83 e2 f0             	and    $0xfffffff0,%edx
8010671d:	83 ca 0e             	or     $0xe,%edx
80106720:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
80106727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672a:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106731:	80 
80106732:	83 e2 ef             	and    $0xffffffef,%edx
80106735:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
8010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673f:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106746:	80 
80106747:	83 e2 9f             	and    $0xffffff9f,%edx
8010674a:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
80106751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106754:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
8010675b:	80 
8010675c:	83 ca 80             	or     $0xffffff80,%edx
8010675f:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
80106766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106769:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106770:	c1 e8 10             	shr    $0x10,%eax
80106773:	89 c2                	mov    %eax,%edx
80106775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106778:	66 89 14 c5 26 5f 11 	mov    %dx,-0x7feea0da(,%eax,8)
8010677f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106780:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106784:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010678b:	0f 8e 30 ff ff ff    	jle    801066c1 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106791:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106796:	66 a3 20 61 11 80    	mov    %ax,0x80116120
8010679c:	66 c7 05 22 61 11 80 	movw   $0x8,0x80116122
801067a3:	08 00 
801067a5:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
801067ac:	83 e0 e0             	and    $0xffffffe0,%eax
801067af:	a2 24 61 11 80       	mov    %al,0x80116124
801067b4:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
801067bb:	83 e0 1f             	and    $0x1f,%eax
801067be:	a2 24 61 11 80       	mov    %al,0x80116124
801067c3:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
801067ca:	83 c8 0f             	or     $0xf,%eax
801067cd:	a2 25 61 11 80       	mov    %al,0x80116125
801067d2:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
801067d9:	83 e0 ef             	and    $0xffffffef,%eax
801067dc:	a2 25 61 11 80       	mov    %al,0x80116125
801067e1:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
801067e8:	83 c8 60             	or     $0x60,%eax
801067eb:	a2 25 61 11 80       	mov    %al,0x80116125
801067f0:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
801067f7:	83 c8 80             	or     $0xffffff80,%eax
801067fa:	a2 25 61 11 80       	mov    %al,0x80116125
801067ff:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106804:	c1 e8 10             	shr    $0x10,%eax
80106807:	66 a3 26 61 11 80    	mov    %ax,0x80116126

  initlock(&tickslock, "time");
8010680d:	83 ec 08             	sub    $0x8,%esp
80106810:	68 08 8c 10 80       	push   $0x80108c08
80106815:	68 e0 5e 11 80       	push   $0x80115ee0
8010681a:	e8 bf e7 ff ff       	call   80104fde <initlock>
8010681f:	83 c4 10             	add    $0x10,%esp
}
80106822:	90                   	nop
80106823:	c9                   	leave  
80106824:	c3                   	ret    

80106825 <idtinit>:

void
idtinit(void)
{
80106825:	55                   	push   %ebp
80106826:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106828:	68 00 08 00 00       	push   $0x800
8010682d:	68 20 5f 11 80       	push   $0x80115f20
80106832:	e8 3d fe ff ff       	call   80106674 <lidt>
80106837:	83 c4 08             	add    $0x8,%esp
}
8010683a:	90                   	nop
8010683b:	c9                   	leave  
8010683c:	c3                   	ret    

8010683d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010683d:	55                   	push   %ebp
8010683e:	89 e5                	mov    %esp,%ebp
80106840:	57                   	push   %edi
80106841:	56                   	push   %esi
80106842:	53                   	push   %ebx
80106843:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106846:	8b 45 08             	mov    0x8(%ebp),%eax
80106849:	8b 40 30             	mov    0x30(%eax),%eax
8010684c:	83 f8 40             	cmp    $0x40,%eax
8010684f:	75 3d                	jne    8010688e <trap+0x51>
    if(myproc()->killed)
80106851:	e8 9b da ff ff       	call   801042f1 <myproc>
80106856:	8b 40 24             	mov    0x24(%eax),%eax
80106859:	85 c0                	test   %eax,%eax
8010685b:	74 05                	je     80106862 <trap+0x25>
      exit();
8010685d:	e8 40 df ff ff       	call   801047a2 <exit>
    myproc()->tf = tf;
80106862:	e8 8a da ff ff       	call   801042f1 <myproc>
80106867:	89 c2                	mov    %eax,%edx
80106869:	8b 45 08             	mov    0x8(%ebp),%eax
8010686c:	89 42 18             	mov    %eax,0x18(%edx)
    syscall();
8010686f:	e8 d7 ed ff ff       	call   8010564b <syscall>
    if(myproc()->killed)
80106874:	e8 78 da ff ff       	call   801042f1 <myproc>
80106879:	8b 40 24             	mov    0x24(%eax),%eax
8010687c:	85 c0                	test   %eax,%eax
8010687e:	0f 84 1f 03 00 00    	je     80106ba3 <trap+0x366>
      exit();
80106884:	e8 19 df ff ff       	call   801047a2 <exit>
    return;
80106889:	e9 15 03 00 00       	jmp    80106ba3 <trap+0x366>
  }

  switch(tf->trapno){
8010688e:	8b 45 08             	mov    0x8(%ebp),%eax
80106891:	8b 40 30             	mov    0x30(%eax),%eax
80106894:	83 e8 20             	sub    $0x20,%eax
80106897:	83 f8 1f             	cmp    $0x1f,%eax
8010689a:	0f 87 b5 00 00 00    	ja     80106955 <trap+0x118>
801068a0:	8b 04 85 ec 8c 10 80 	mov    -0x7fef7314(,%eax,4),%eax
801068a7:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801068a9:	e8 aa d9 ff ff       	call   80104258 <cpuid>
801068ae:	85 c0                	test   %eax,%eax
801068b0:	75 3d                	jne    801068ef <trap+0xb2>
      acquire(&tickslock);
801068b2:	83 ec 0c             	sub    $0xc,%esp
801068b5:	68 e0 5e 11 80       	push   $0x80115ee0
801068ba:	e8 41 e7 ff ff       	call   80105000 <acquire>
801068bf:	83 c4 10             	add    $0x10,%esp
      ticks++;
801068c2:	a1 20 67 11 80       	mov    0x80116720,%eax
801068c7:	83 c0 01             	add    $0x1,%eax
801068ca:	a3 20 67 11 80       	mov    %eax,0x80116720
      wakeup(&ticks);
801068cf:	83 ec 0c             	sub    $0xc,%esp
801068d2:	68 20 67 11 80       	push   $0x80116720
801068d7:	e8 eb e3 ff ff       	call   80104cc7 <wakeup>
801068dc:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801068df:	83 ec 0c             	sub    $0xc,%esp
801068e2:	68 e0 5e 11 80       	push   $0x80115ee0
801068e7:	e8 82 e7 ff ff       	call   8010506e <release>
801068ec:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801068ef:	e8 7d c7 ff ff       	call   80103071 <lapiceoi>
    break;
801068f4:	e9 2a 02 00 00       	jmp    80106b23 <trap+0x2e6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801068f9:	e8 ed bf ff ff       	call   801028eb <ideintr>
    lapiceoi();
801068fe:	e8 6e c7 ff ff       	call   80103071 <lapiceoi>
    break;
80106903:	e9 1b 02 00 00       	jmp    80106b23 <trap+0x2e6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106908:	e8 ad c5 ff ff       	call   80102eba <kbdintr>
    lapiceoi();
8010690d:	e8 5f c7 ff ff       	call   80103071 <lapiceoi>
    break;
80106912:	e9 0c 02 00 00       	jmp    80106b23 <trap+0x2e6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106917:	e8 5b 04 00 00       	call   80106d77 <uartintr>
    lapiceoi();
8010691c:	e8 50 c7 ff ff       	call   80103071 <lapiceoi>
    break;
80106921:	e9 fd 01 00 00       	jmp    80106b23 <trap+0x2e6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106926:	8b 45 08             	mov    0x8(%ebp),%eax
80106929:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010692c:	8b 45 08             	mov    0x8(%ebp),%eax
8010692f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106933:	0f b7 d8             	movzwl %ax,%ebx
80106936:	e8 1d d9 ff ff       	call   80104258 <cpuid>
8010693b:	56                   	push   %esi
8010693c:	53                   	push   %ebx
8010693d:	50                   	push   %eax
8010693e:	68 10 8c 10 80       	push   $0x80108c10
80106943:	e8 b8 9a ff ff       	call   80100400 <cprintf>
80106948:	83 c4 10             	add    $0x10,%esp
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
8010694b:	e8 21 c7 ff ff       	call   80103071 <lapiceoi>
    break;
80106950:	e9 ce 01 00 00       	jmp    80106b23 <trap+0x2e6>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106955:	e8 97 d9 ff ff       	call   801042f1 <myproc>
8010695a:	85 c0                	test   %eax,%eax
8010695c:	74 11                	je     8010696f <trap+0x132>
8010695e:	8b 45 08             	mov    0x8(%ebp),%eax
80106961:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106965:	0f b7 c0             	movzwl %ax,%eax
80106968:	83 e0 03             	and    $0x3,%eax
8010696b:	85 c0                	test   %eax,%eax
8010696d:	75 3b                	jne    801069aa <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010696f:	e8 2a fd ff ff       	call   8010669e <rcr2>
80106974:	89 c6                	mov    %eax,%esi
80106976:	8b 45 08             	mov    0x8(%ebp),%eax
80106979:	8b 58 38             	mov    0x38(%eax),%ebx
8010697c:	e8 d7 d8 ff ff       	call   80104258 <cpuid>
80106981:	89 c2                	mov    %eax,%edx
80106983:	8b 45 08             	mov    0x8(%ebp),%eax
80106986:	8b 40 30             	mov    0x30(%eax),%eax
80106989:	83 ec 0c             	sub    $0xc,%esp
8010698c:	56                   	push   %esi
8010698d:	53                   	push   %ebx
8010698e:	52                   	push   %edx
8010698f:	50                   	push   %eax
80106990:	68 34 8c 10 80       	push   $0x80108c34
80106995:	e8 66 9a ff ff       	call   80100400 <cprintf>
8010699a:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010699d:	83 ec 0c             	sub    $0xc,%esp
801069a0:	68 66 8c 10 80       	push   $0x80108c66
801069a5:	e8 f6 9b ff ff       	call   801005a0 <panic>
    }
    if (tf->trapno == T_PGFLT)
801069aa:	8b 45 08             	mov    0x8(%ebp),%eax
801069ad:	8b 40 30             	mov    0x30(%eax),%eax
801069b0:	83 f8 0e             	cmp    $0xe,%eax
801069b3:	0f 85 0c 01 00 00    	jne    80106ac5 <trap+0x288>
    {
	if (myproc()->tf->esp < myproc()->stackTop)
801069b9:	e8 33 d9 ff ff       	call   801042f1 <myproc>
801069be:	8b 40 18             	mov    0x18(%eax),%eax
801069c1:	8b 58 44             	mov    0x44(%eax),%ebx
801069c4:	e8 28 d9 ff ff       	call   801042f1 <myproc>
801069c9:	8b 40 7c             	mov    0x7c(%eax),%eax
801069cc:	39 c3                	cmp    %eax,%ebx
801069ce:	0f 83 f1 00 00 00    	jae    80106ac5 <trap+0x288>
	{
	    myproc()->pageNum += 1;
801069d4:	e8 18 d9 ff ff       	call   801042f1 <myproc>
801069d9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801069df:	83 c2 01             	add    $0x1,%edx
801069e2:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	    cprintf("TOP: %x\n", myproc()->stackTop);
801069e8:	e8 04 d9 ff ff       	call   801042f1 <myproc>
801069ed:	8b 40 7c             	mov    0x7c(%eax),%eax
801069f0:	83 ec 08             	sub    $0x8,%esp
801069f3:	50                   	push   %eax
801069f4:	68 6b 8c 10 80       	push   $0x80108c6b
801069f9:	e8 02 9a ff ff       	call   80100400 <cprintf>
801069fe:	83 c4 10             	add    $0x10,%esp
	    cprintf("NUM_PAGES: %d\n", myproc()->pageNum);
80106a01:	e8 eb d8 ff ff       	call   801042f1 <myproc>
80106a06:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a0c:	83 ec 08             	sub    $0x8,%esp
80106a0f:	50                   	push   %eax
80106a10:	68 74 8c 10 80       	push   $0x80108c74
80106a15:	e8 e6 99 ff ff       	call   80100400 <cprintf>
80106a1a:	83 c4 10             	add    $0x10,%esp
	    cprintf("TOP_NEWPAGE: %x\n", myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE));
80106a1d:	e8 cf d8 ff ff       	call   801042f1 <myproc>
80106a22:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a25:	e8 c7 d8 ff ff       	call   801042f1 <myproc>
80106a2a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a30:	05 ff ff 0f 00       	add    $0xfffff,%eax
80106a35:	c1 e0 0c             	shl    $0xc,%eax
80106a38:	29 c3                	sub    %eax,%ebx
80106a3a:	89 d8                	mov    %ebx,%eax
80106a3c:	83 ec 08             	sub    $0x8,%esp
80106a3f:	50                   	push   %eax
80106a40:	68 83 8c 10 80       	push   $0x80108c83
80106a45:	e8 b6 99 ff ff       	call   80100400 <cprintf>
80106a4a:	83 c4 10             	add    $0x10,%esp
	    cprintf("BOTTOM_NEWPAGE: %x\n", myproc()->stackTop - ((myproc()->pageNum)*PGSIZE));
80106a4d:	e8 9f d8 ff ff       	call   801042f1 <myproc>
80106a52:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a55:	e8 97 d8 ff ff       	call   801042f1 <myproc>
80106a5a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a60:	c1 e0 0c             	shl    $0xc,%eax
80106a63:	29 c3                	sub    %eax,%ebx
80106a65:	89 d8                	mov    %ebx,%eax
80106a67:	83 ec 08             	sub    $0x8,%esp
80106a6a:	50                   	push   %eax
80106a6b:	68 94 8c 10 80       	push   $0x80108c94
80106a70:	e8 8b 99 ff ff       	call   80100400 <cprintf>
80106a75:	83 c4 10             	add    $0x10,%esp

            allocuvm(myproc()->pgdir, myproc()->stackTop - (myproc()->pageNum*PGSIZE), myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE)); 
80106a78:	e8 74 d8 ff ff       	call   801042f1 <myproc>
80106a7d:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a80:	e8 6c d8 ff ff       	call   801042f1 <myproc>
80106a85:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a8b:	05 ff ff 0f 00       	add    $0xfffff,%eax
80106a90:	c1 e0 0c             	shl    $0xc,%eax
80106a93:	89 de                	mov    %ebx,%esi
80106a95:	29 c6                	sub    %eax,%esi
80106a97:	e8 55 d8 ff ff       	call   801042f1 <myproc>
80106a9c:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a9f:	e8 4d d8 ff ff       	call   801042f1 <myproc>
80106aa4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106aaa:	c1 e0 0c             	shl    $0xc,%eax
80106aad:	29 c3                	sub    %eax,%ebx
80106aaf:	e8 3d d8 ff ff       	call   801042f1 <myproc>
80106ab4:	8b 40 04             	mov    0x4(%eax),%eax
80106ab7:	83 ec 04             	sub    $0x4,%esp
80106aba:	56                   	push   %esi
80106abb:	53                   	push   %ebx
80106abc:	50                   	push   %eax
80106abd:	e8 c1 15 00 00       	call   80108083 <allocuvm>
80106ac2:	83 c4 10             	add    $0x10,%esp
	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ac5:	e8 d4 fb ff ff       	call   8010669e <rcr2>
80106aca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106acd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad0:	8b 78 38             	mov    0x38(%eax),%edi
80106ad3:	e8 80 d7 ff ff       	call   80104258 <cpuid>
80106ad8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106adb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ade:	8b 70 34             	mov    0x34(%eax),%esi
80106ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae4:	8b 58 30             	mov    0x30(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ae7:	e8 05 d8 ff ff       	call   801042f1 <myproc>
80106aec:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106aef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106af2:	e8 fa d7 ff ff       	call   801042f1 <myproc>

            allocuvm(myproc()->pgdir, myproc()->stackTop - (myproc()->pageNum*PGSIZE), myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE)); 
	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106af7:	8b 40 10             	mov    0x10(%eax),%eax
80106afa:	ff 75 e4             	pushl  -0x1c(%ebp)
80106afd:	57                   	push   %edi
80106afe:	ff 75 e0             	pushl  -0x20(%ebp)
80106b01:	56                   	push   %esi
80106b02:	53                   	push   %ebx
80106b03:	ff 75 dc             	pushl  -0x24(%ebp)
80106b06:	50                   	push   %eax
80106b07:	68 a8 8c 10 80       	push   $0x80108ca8
80106b0c:	e8 ef 98 ff ff       	call   80100400 <cprintf>
80106b11:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106b14:	e8 d8 d7 ff ff       	call   801042f1 <myproc>
80106b19:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b20:	eb 01                	jmp    80106b23 <trap+0x2e6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b22:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b23:	e8 c9 d7 ff ff       	call   801042f1 <myproc>
80106b28:	85 c0                	test   %eax,%eax
80106b2a:	74 23                	je     80106b4f <trap+0x312>
80106b2c:	e8 c0 d7 ff ff       	call   801042f1 <myproc>
80106b31:	8b 40 24             	mov    0x24(%eax),%eax
80106b34:	85 c0                	test   %eax,%eax
80106b36:	74 17                	je     80106b4f <trap+0x312>
80106b38:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b3f:	0f b7 c0             	movzwl %ax,%eax
80106b42:	83 e0 03             	and    $0x3,%eax
80106b45:	83 f8 03             	cmp    $0x3,%eax
80106b48:	75 05                	jne    80106b4f <trap+0x312>
    exit();
80106b4a:	e8 53 dc ff ff       	call   801047a2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b4f:	e8 9d d7 ff ff       	call   801042f1 <myproc>
80106b54:	85 c0                	test   %eax,%eax
80106b56:	74 1d                	je     80106b75 <trap+0x338>
80106b58:	e8 94 d7 ff ff       	call   801042f1 <myproc>
80106b5d:	8b 40 0c             	mov    0xc(%eax),%eax
80106b60:	83 f8 04             	cmp    $0x4,%eax
80106b63:	75 10                	jne    80106b75 <trap+0x338>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b65:	8b 45 08             	mov    0x8(%ebp),%eax
80106b68:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b6b:	83 f8 20             	cmp    $0x20,%eax
80106b6e:	75 05                	jne    80106b75 <trap+0x338>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106b70:	e8 e9 df ff ff       	call   80104b5e <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b75:	e8 77 d7 ff ff       	call   801042f1 <myproc>
80106b7a:	85 c0                	test   %eax,%eax
80106b7c:	74 26                	je     80106ba4 <trap+0x367>
80106b7e:	e8 6e d7 ff ff       	call   801042f1 <myproc>
80106b83:	8b 40 24             	mov    0x24(%eax),%eax
80106b86:	85 c0                	test   %eax,%eax
80106b88:	74 1a                	je     80106ba4 <trap+0x367>
80106b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b91:	0f b7 c0             	movzwl %ax,%eax
80106b94:	83 e0 03             	and    $0x3,%eax
80106b97:	83 f8 03             	cmp    $0x3,%eax
80106b9a:	75 08                	jne    80106ba4 <trap+0x367>
    exit();
80106b9c:	e8 01 dc ff ff       	call   801047a2 <exit>
80106ba1:	eb 01                	jmp    80106ba4 <trap+0x367>
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
80106ba3:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ba7:	5b                   	pop    %ebx
80106ba8:	5e                   	pop    %esi
80106ba9:	5f                   	pop    %edi
80106baa:	5d                   	pop    %ebp
80106bab:	c3                   	ret    

80106bac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bac:	55                   	push   %ebp
80106bad:	89 e5                	mov    %esp,%ebp
80106baf:	83 ec 14             	sub    $0x14,%esp
80106bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106bb9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106bbd:	89 c2                	mov    %eax,%edx
80106bbf:	ec                   	in     (%dx),%al
80106bc0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106bc3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106bc7:	c9                   	leave  
80106bc8:	c3                   	ret    

80106bc9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106bc9:	55                   	push   %ebp
80106bca:	89 e5                	mov    %esp,%ebp
80106bcc:	83 ec 08             	sub    $0x8,%esp
80106bcf:	8b 55 08             	mov    0x8(%ebp),%edx
80106bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bd5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106bd9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106bdc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106be0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106be4:	ee                   	out    %al,(%dx)
}
80106be5:	90                   	nop
80106be6:	c9                   	leave  
80106be7:	c3                   	ret    

80106be8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106be8:	55                   	push   %ebp
80106be9:	89 e5                	mov    %esp,%ebp
80106beb:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106bee:	6a 00                	push   $0x0
80106bf0:	68 fa 03 00 00       	push   $0x3fa
80106bf5:	e8 cf ff ff ff       	call   80106bc9 <outb>
80106bfa:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bfd:	68 80 00 00 00       	push   $0x80
80106c02:	68 fb 03 00 00       	push   $0x3fb
80106c07:	e8 bd ff ff ff       	call   80106bc9 <outb>
80106c0c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106c0f:	6a 0c                	push   $0xc
80106c11:	68 f8 03 00 00       	push   $0x3f8
80106c16:	e8 ae ff ff ff       	call   80106bc9 <outb>
80106c1b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106c1e:	6a 00                	push   $0x0
80106c20:	68 f9 03 00 00       	push   $0x3f9
80106c25:	e8 9f ff ff ff       	call   80106bc9 <outb>
80106c2a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c2d:	6a 03                	push   $0x3
80106c2f:	68 fb 03 00 00       	push   $0x3fb
80106c34:	e8 90 ff ff ff       	call   80106bc9 <outb>
80106c39:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106c3c:	6a 00                	push   $0x0
80106c3e:	68 fc 03 00 00       	push   $0x3fc
80106c43:	e8 81 ff ff ff       	call   80106bc9 <outb>
80106c48:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c4b:	6a 01                	push   $0x1
80106c4d:	68 f9 03 00 00       	push   $0x3f9
80106c52:	e8 72 ff ff ff       	call   80106bc9 <outb>
80106c57:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c5a:	68 fd 03 00 00       	push   $0x3fd
80106c5f:	e8 48 ff ff ff       	call   80106bac <inb>
80106c64:	83 c4 04             	add    $0x4,%esp
80106c67:	3c ff                	cmp    $0xff,%al
80106c69:	74 61                	je     80106ccc <uartinit+0xe4>
    return;
  uart = 1;
80106c6b:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
80106c72:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c75:	68 fa 03 00 00       	push   $0x3fa
80106c7a:	e8 2d ff ff ff       	call   80106bac <inb>
80106c7f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c82:	68 f8 03 00 00       	push   $0x3f8
80106c87:	e8 20 ff ff ff       	call   80106bac <inb>
80106c8c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106c8f:	83 ec 08             	sub    $0x8,%esp
80106c92:	6a 00                	push   $0x0
80106c94:	6a 04                	push   $0x4
80106c96:	e8 ed be ff ff       	call   80102b88 <ioapicenable>
80106c9b:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c9e:	c7 45 f4 6c 8d 10 80 	movl   $0x80108d6c,-0xc(%ebp)
80106ca5:	eb 19                	jmp    80106cc0 <uartinit+0xd8>
    uartputc(*p);
80106ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106caa:	0f b6 00             	movzbl (%eax),%eax
80106cad:	0f be c0             	movsbl %al,%eax
80106cb0:	83 ec 0c             	sub    $0xc,%esp
80106cb3:	50                   	push   %eax
80106cb4:	e8 16 00 00 00       	call   80106ccf <uartputc>
80106cb9:	83 c4 10             	add    $0x10,%esp
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cc3:	0f b6 00             	movzbl (%eax),%eax
80106cc6:	84 c0                	test   %al,%al
80106cc8:	75 dd                	jne    80106ca7 <uartinit+0xbf>
80106cca:	eb 01                	jmp    80106ccd <uartinit+0xe5>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106ccc:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106ccd:	c9                   	leave  
80106cce:	c3                   	ret    

80106ccf <uartputc>:

void
uartputc(int c)
{
80106ccf:	55                   	push   %ebp
80106cd0:	89 e5                	mov    %esp,%ebp
80106cd2:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106cd5:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106cda:	85 c0                	test   %eax,%eax
80106cdc:	74 53                	je     80106d31 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ce5:	eb 11                	jmp    80106cf8 <uartputc+0x29>
    microdelay(10);
80106ce7:	83 ec 0c             	sub    $0xc,%esp
80106cea:	6a 0a                	push   $0xa
80106cec:	e8 9b c3 ff ff       	call   8010308c <microdelay>
80106cf1:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cf8:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106cfc:	7f 1a                	jg     80106d18 <uartputc+0x49>
80106cfe:	83 ec 0c             	sub    $0xc,%esp
80106d01:	68 fd 03 00 00       	push   $0x3fd
80106d06:	e8 a1 fe ff ff       	call   80106bac <inb>
80106d0b:	83 c4 10             	add    $0x10,%esp
80106d0e:	0f b6 c0             	movzbl %al,%eax
80106d11:	83 e0 20             	and    $0x20,%eax
80106d14:	85 c0                	test   %eax,%eax
80106d16:	74 cf                	je     80106ce7 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106d18:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1b:	0f b6 c0             	movzbl %al,%eax
80106d1e:	83 ec 08             	sub    $0x8,%esp
80106d21:	50                   	push   %eax
80106d22:	68 f8 03 00 00       	push   $0x3f8
80106d27:	e8 9d fe ff ff       	call   80106bc9 <outb>
80106d2c:	83 c4 10             	add    $0x10,%esp
80106d2f:	eb 01                	jmp    80106d32 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106d31:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106d32:	c9                   	leave  
80106d33:	c3                   	ret    

80106d34 <uartgetc>:

static int
uartgetc(void)
{
80106d34:	55                   	push   %ebp
80106d35:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106d37:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106d3c:	85 c0                	test   %eax,%eax
80106d3e:	75 07                	jne    80106d47 <uartgetc+0x13>
    return -1;
80106d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d45:	eb 2e                	jmp    80106d75 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d47:	68 fd 03 00 00       	push   $0x3fd
80106d4c:	e8 5b fe ff ff       	call   80106bac <inb>
80106d51:	83 c4 04             	add    $0x4,%esp
80106d54:	0f b6 c0             	movzbl %al,%eax
80106d57:	83 e0 01             	and    $0x1,%eax
80106d5a:	85 c0                	test   %eax,%eax
80106d5c:	75 07                	jne    80106d65 <uartgetc+0x31>
    return -1;
80106d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d63:	eb 10                	jmp    80106d75 <uartgetc+0x41>
  return inb(COM1+0);
80106d65:	68 f8 03 00 00       	push   $0x3f8
80106d6a:	e8 3d fe ff ff       	call   80106bac <inb>
80106d6f:	83 c4 04             	add    $0x4,%esp
80106d72:	0f b6 c0             	movzbl %al,%eax
}
80106d75:	c9                   	leave  
80106d76:	c3                   	ret    

80106d77 <uartintr>:

void
uartintr(void)
{
80106d77:	55                   	push   %ebp
80106d78:	89 e5                	mov    %esp,%ebp
80106d7a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d7d:	83 ec 0c             	sub    $0xc,%esp
80106d80:	68 34 6d 10 80       	push   $0x80106d34
80106d85:	e8 a2 9a ff ff       	call   8010082c <consoleintr>
80106d8a:	83 c4 10             	add    $0x10,%esp
}
80106d8d:	90                   	nop
80106d8e:	c9                   	leave  
80106d8f:	c3                   	ret    

80106d90 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $0
80106d92:	6a 00                	push   $0x0
  jmp alltraps
80106d94:	e9 b8 f8 ff ff       	jmp    80106651 <alltraps>

80106d99 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $1
80106d9b:	6a 01                	push   $0x1
  jmp alltraps
80106d9d:	e9 af f8 ff ff       	jmp    80106651 <alltraps>

80106da2 <vector2>:
.globl vector2
vector2:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $2
80106da4:	6a 02                	push   $0x2
  jmp alltraps
80106da6:	e9 a6 f8 ff ff       	jmp    80106651 <alltraps>

80106dab <vector3>:
.globl vector3
vector3:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $3
80106dad:	6a 03                	push   $0x3
  jmp alltraps
80106daf:	e9 9d f8 ff ff       	jmp    80106651 <alltraps>

80106db4 <vector4>:
.globl vector4
vector4:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $4
80106db6:	6a 04                	push   $0x4
  jmp alltraps
80106db8:	e9 94 f8 ff ff       	jmp    80106651 <alltraps>

80106dbd <vector5>:
.globl vector5
vector5:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $5
80106dbf:	6a 05                	push   $0x5
  jmp alltraps
80106dc1:	e9 8b f8 ff ff       	jmp    80106651 <alltraps>

80106dc6 <vector6>:
.globl vector6
vector6:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $6
80106dc8:	6a 06                	push   $0x6
  jmp alltraps
80106dca:	e9 82 f8 ff ff       	jmp    80106651 <alltraps>

80106dcf <vector7>:
.globl vector7
vector7:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $7
80106dd1:	6a 07                	push   $0x7
  jmp alltraps
80106dd3:	e9 79 f8 ff ff       	jmp    80106651 <alltraps>

80106dd8 <vector8>:
.globl vector8
vector8:
  pushl $8
80106dd8:	6a 08                	push   $0x8
  jmp alltraps
80106dda:	e9 72 f8 ff ff       	jmp    80106651 <alltraps>

80106ddf <vector9>:
.globl vector9
vector9:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $9
80106de1:	6a 09                	push   $0x9
  jmp alltraps
80106de3:	e9 69 f8 ff ff       	jmp    80106651 <alltraps>

80106de8 <vector10>:
.globl vector10
vector10:
  pushl $10
80106de8:	6a 0a                	push   $0xa
  jmp alltraps
80106dea:	e9 62 f8 ff ff       	jmp    80106651 <alltraps>

80106def <vector11>:
.globl vector11
vector11:
  pushl $11
80106def:	6a 0b                	push   $0xb
  jmp alltraps
80106df1:	e9 5b f8 ff ff       	jmp    80106651 <alltraps>

80106df6 <vector12>:
.globl vector12
vector12:
  pushl $12
80106df6:	6a 0c                	push   $0xc
  jmp alltraps
80106df8:	e9 54 f8 ff ff       	jmp    80106651 <alltraps>

80106dfd <vector13>:
.globl vector13
vector13:
  pushl $13
80106dfd:	6a 0d                	push   $0xd
  jmp alltraps
80106dff:	e9 4d f8 ff ff       	jmp    80106651 <alltraps>

80106e04 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e04:	6a 0e                	push   $0xe
  jmp alltraps
80106e06:	e9 46 f8 ff ff       	jmp    80106651 <alltraps>

80106e0b <vector15>:
.globl vector15
vector15:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $15
80106e0d:	6a 0f                	push   $0xf
  jmp alltraps
80106e0f:	e9 3d f8 ff ff       	jmp    80106651 <alltraps>

80106e14 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $16
80106e16:	6a 10                	push   $0x10
  jmp alltraps
80106e18:	e9 34 f8 ff ff       	jmp    80106651 <alltraps>

80106e1d <vector17>:
.globl vector17
vector17:
  pushl $17
80106e1d:	6a 11                	push   $0x11
  jmp alltraps
80106e1f:	e9 2d f8 ff ff       	jmp    80106651 <alltraps>

80106e24 <vector18>:
.globl vector18
vector18:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $18
80106e26:	6a 12                	push   $0x12
  jmp alltraps
80106e28:	e9 24 f8 ff ff       	jmp    80106651 <alltraps>

80106e2d <vector19>:
.globl vector19
vector19:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $19
80106e2f:	6a 13                	push   $0x13
  jmp alltraps
80106e31:	e9 1b f8 ff ff       	jmp    80106651 <alltraps>

80106e36 <vector20>:
.globl vector20
vector20:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $20
80106e38:	6a 14                	push   $0x14
  jmp alltraps
80106e3a:	e9 12 f8 ff ff       	jmp    80106651 <alltraps>

80106e3f <vector21>:
.globl vector21
vector21:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $21
80106e41:	6a 15                	push   $0x15
  jmp alltraps
80106e43:	e9 09 f8 ff ff       	jmp    80106651 <alltraps>

80106e48 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $22
80106e4a:	6a 16                	push   $0x16
  jmp alltraps
80106e4c:	e9 00 f8 ff ff       	jmp    80106651 <alltraps>

80106e51 <vector23>:
.globl vector23
vector23:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $23
80106e53:	6a 17                	push   $0x17
  jmp alltraps
80106e55:	e9 f7 f7 ff ff       	jmp    80106651 <alltraps>

80106e5a <vector24>:
.globl vector24
vector24:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $24
80106e5c:	6a 18                	push   $0x18
  jmp alltraps
80106e5e:	e9 ee f7 ff ff       	jmp    80106651 <alltraps>

80106e63 <vector25>:
.globl vector25
vector25:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $25
80106e65:	6a 19                	push   $0x19
  jmp alltraps
80106e67:	e9 e5 f7 ff ff       	jmp    80106651 <alltraps>

80106e6c <vector26>:
.globl vector26
vector26:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $26
80106e6e:	6a 1a                	push   $0x1a
  jmp alltraps
80106e70:	e9 dc f7 ff ff       	jmp    80106651 <alltraps>

80106e75 <vector27>:
.globl vector27
vector27:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $27
80106e77:	6a 1b                	push   $0x1b
  jmp alltraps
80106e79:	e9 d3 f7 ff ff       	jmp    80106651 <alltraps>

80106e7e <vector28>:
.globl vector28
vector28:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $28
80106e80:	6a 1c                	push   $0x1c
  jmp alltraps
80106e82:	e9 ca f7 ff ff       	jmp    80106651 <alltraps>

80106e87 <vector29>:
.globl vector29
vector29:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $29
80106e89:	6a 1d                	push   $0x1d
  jmp alltraps
80106e8b:	e9 c1 f7 ff ff       	jmp    80106651 <alltraps>

80106e90 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $30
80106e92:	6a 1e                	push   $0x1e
  jmp alltraps
80106e94:	e9 b8 f7 ff ff       	jmp    80106651 <alltraps>

80106e99 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $31
80106e9b:	6a 1f                	push   $0x1f
  jmp alltraps
80106e9d:	e9 af f7 ff ff       	jmp    80106651 <alltraps>

80106ea2 <vector32>:
.globl vector32
vector32:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $32
80106ea4:	6a 20                	push   $0x20
  jmp alltraps
80106ea6:	e9 a6 f7 ff ff       	jmp    80106651 <alltraps>

80106eab <vector33>:
.globl vector33
vector33:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $33
80106ead:	6a 21                	push   $0x21
  jmp alltraps
80106eaf:	e9 9d f7 ff ff       	jmp    80106651 <alltraps>

80106eb4 <vector34>:
.globl vector34
vector34:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $34
80106eb6:	6a 22                	push   $0x22
  jmp alltraps
80106eb8:	e9 94 f7 ff ff       	jmp    80106651 <alltraps>

80106ebd <vector35>:
.globl vector35
vector35:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $35
80106ebf:	6a 23                	push   $0x23
  jmp alltraps
80106ec1:	e9 8b f7 ff ff       	jmp    80106651 <alltraps>

80106ec6 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $36
80106ec8:	6a 24                	push   $0x24
  jmp alltraps
80106eca:	e9 82 f7 ff ff       	jmp    80106651 <alltraps>

80106ecf <vector37>:
.globl vector37
vector37:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $37
80106ed1:	6a 25                	push   $0x25
  jmp alltraps
80106ed3:	e9 79 f7 ff ff       	jmp    80106651 <alltraps>

80106ed8 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $38
80106eda:	6a 26                	push   $0x26
  jmp alltraps
80106edc:	e9 70 f7 ff ff       	jmp    80106651 <alltraps>

80106ee1 <vector39>:
.globl vector39
vector39:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $39
80106ee3:	6a 27                	push   $0x27
  jmp alltraps
80106ee5:	e9 67 f7 ff ff       	jmp    80106651 <alltraps>

80106eea <vector40>:
.globl vector40
vector40:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $40
80106eec:	6a 28                	push   $0x28
  jmp alltraps
80106eee:	e9 5e f7 ff ff       	jmp    80106651 <alltraps>

80106ef3 <vector41>:
.globl vector41
vector41:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $41
80106ef5:	6a 29                	push   $0x29
  jmp alltraps
80106ef7:	e9 55 f7 ff ff       	jmp    80106651 <alltraps>

80106efc <vector42>:
.globl vector42
vector42:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $42
80106efe:	6a 2a                	push   $0x2a
  jmp alltraps
80106f00:	e9 4c f7 ff ff       	jmp    80106651 <alltraps>

80106f05 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $43
80106f07:	6a 2b                	push   $0x2b
  jmp alltraps
80106f09:	e9 43 f7 ff ff       	jmp    80106651 <alltraps>

80106f0e <vector44>:
.globl vector44
vector44:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $44
80106f10:	6a 2c                	push   $0x2c
  jmp alltraps
80106f12:	e9 3a f7 ff ff       	jmp    80106651 <alltraps>

80106f17 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $45
80106f19:	6a 2d                	push   $0x2d
  jmp alltraps
80106f1b:	e9 31 f7 ff ff       	jmp    80106651 <alltraps>

80106f20 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $46
80106f22:	6a 2e                	push   $0x2e
  jmp alltraps
80106f24:	e9 28 f7 ff ff       	jmp    80106651 <alltraps>

80106f29 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $47
80106f2b:	6a 2f                	push   $0x2f
  jmp alltraps
80106f2d:	e9 1f f7 ff ff       	jmp    80106651 <alltraps>

80106f32 <vector48>:
.globl vector48
vector48:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $48
80106f34:	6a 30                	push   $0x30
  jmp alltraps
80106f36:	e9 16 f7 ff ff       	jmp    80106651 <alltraps>

80106f3b <vector49>:
.globl vector49
vector49:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $49
80106f3d:	6a 31                	push   $0x31
  jmp alltraps
80106f3f:	e9 0d f7 ff ff       	jmp    80106651 <alltraps>

80106f44 <vector50>:
.globl vector50
vector50:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $50
80106f46:	6a 32                	push   $0x32
  jmp alltraps
80106f48:	e9 04 f7 ff ff       	jmp    80106651 <alltraps>

80106f4d <vector51>:
.globl vector51
vector51:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $51
80106f4f:	6a 33                	push   $0x33
  jmp alltraps
80106f51:	e9 fb f6 ff ff       	jmp    80106651 <alltraps>

80106f56 <vector52>:
.globl vector52
vector52:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $52
80106f58:	6a 34                	push   $0x34
  jmp alltraps
80106f5a:	e9 f2 f6 ff ff       	jmp    80106651 <alltraps>

80106f5f <vector53>:
.globl vector53
vector53:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $53
80106f61:	6a 35                	push   $0x35
  jmp alltraps
80106f63:	e9 e9 f6 ff ff       	jmp    80106651 <alltraps>

80106f68 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $54
80106f6a:	6a 36                	push   $0x36
  jmp alltraps
80106f6c:	e9 e0 f6 ff ff       	jmp    80106651 <alltraps>

80106f71 <vector55>:
.globl vector55
vector55:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $55
80106f73:	6a 37                	push   $0x37
  jmp alltraps
80106f75:	e9 d7 f6 ff ff       	jmp    80106651 <alltraps>

80106f7a <vector56>:
.globl vector56
vector56:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $56
80106f7c:	6a 38                	push   $0x38
  jmp alltraps
80106f7e:	e9 ce f6 ff ff       	jmp    80106651 <alltraps>

80106f83 <vector57>:
.globl vector57
vector57:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $57
80106f85:	6a 39                	push   $0x39
  jmp alltraps
80106f87:	e9 c5 f6 ff ff       	jmp    80106651 <alltraps>

80106f8c <vector58>:
.globl vector58
vector58:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $58
80106f8e:	6a 3a                	push   $0x3a
  jmp alltraps
80106f90:	e9 bc f6 ff ff       	jmp    80106651 <alltraps>

80106f95 <vector59>:
.globl vector59
vector59:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $59
80106f97:	6a 3b                	push   $0x3b
  jmp alltraps
80106f99:	e9 b3 f6 ff ff       	jmp    80106651 <alltraps>

80106f9e <vector60>:
.globl vector60
vector60:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $60
80106fa0:	6a 3c                	push   $0x3c
  jmp alltraps
80106fa2:	e9 aa f6 ff ff       	jmp    80106651 <alltraps>

80106fa7 <vector61>:
.globl vector61
vector61:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $61
80106fa9:	6a 3d                	push   $0x3d
  jmp alltraps
80106fab:	e9 a1 f6 ff ff       	jmp    80106651 <alltraps>

80106fb0 <vector62>:
.globl vector62
vector62:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $62
80106fb2:	6a 3e                	push   $0x3e
  jmp alltraps
80106fb4:	e9 98 f6 ff ff       	jmp    80106651 <alltraps>

80106fb9 <vector63>:
.globl vector63
vector63:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $63
80106fbb:	6a 3f                	push   $0x3f
  jmp alltraps
80106fbd:	e9 8f f6 ff ff       	jmp    80106651 <alltraps>

80106fc2 <vector64>:
.globl vector64
vector64:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $64
80106fc4:	6a 40                	push   $0x40
  jmp alltraps
80106fc6:	e9 86 f6 ff ff       	jmp    80106651 <alltraps>

80106fcb <vector65>:
.globl vector65
vector65:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $65
80106fcd:	6a 41                	push   $0x41
  jmp alltraps
80106fcf:	e9 7d f6 ff ff       	jmp    80106651 <alltraps>

80106fd4 <vector66>:
.globl vector66
vector66:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $66
80106fd6:	6a 42                	push   $0x42
  jmp alltraps
80106fd8:	e9 74 f6 ff ff       	jmp    80106651 <alltraps>

80106fdd <vector67>:
.globl vector67
vector67:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $67
80106fdf:	6a 43                	push   $0x43
  jmp alltraps
80106fe1:	e9 6b f6 ff ff       	jmp    80106651 <alltraps>

80106fe6 <vector68>:
.globl vector68
vector68:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $68
80106fe8:	6a 44                	push   $0x44
  jmp alltraps
80106fea:	e9 62 f6 ff ff       	jmp    80106651 <alltraps>

80106fef <vector69>:
.globl vector69
vector69:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $69
80106ff1:	6a 45                	push   $0x45
  jmp alltraps
80106ff3:	e9 59 f6 ff ff       	jmp    80106651 <alltraps>

80106ff8 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $70
80106ffa:	6a 46                	push   $0x46
  jmp alltraps
80106ffc:	e9 50 f6 ff ff       	jmp    80106651 <alltraps>

80107001 <vector71>:
.globl vector71
vector71:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $71
80107003:	6a 47                	push   $0x47
  jmp alltraps
80107005:	e9 47 f6 ff ff       	jmp    80106651 <alltraps>

8010700a <vector72>:
.globl vector72
vector72:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $72
8010700c:	6a 48                	push   $0x48
  jmp alltraps
8010700e:	e9 3e f6 ff ff       	jmp    80106651 <alltraps>

80107013 <vector73>:
.globl vector73
vector73:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $73
80107015:	6a 49                	push   $0x49
  jmp alltraps
80107017:	e9 35 f6 ff ff       	jmp    80106651 <alltraps>

8010701c <vector74>:
.globl vector74
vector74:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $74
8010701e:	6a 4a                	push   $0x4a
  jmp alltraps
80107020:	e9 2c f6 ff ff       	jmp    80106651 <alltraps>

80107025 <vector75>:
.globl vector75
vector75:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $75
80107027:	6a 4b                	push   $0x4b
  jmp alltraps
80107029:	e9 23 f6 ff ff       	jmp    80106651 <alltraps>

8010702e <vector76>:
.globl vector76
vector76:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $76
80107030:	6a 4c                	push   $0x4c
  jmp alltraps
80107032:	e9 1a f6 ff ff       	jmp    80106651 <alltraps>

80107037 <vector77>:
.globl vector77
vector77:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $77
80107039:	6a 4d                	push   $0x4d
  jmp alltraps
8010703b:	e9 11 f6 ff ff       	jmp    80106651 <alltraps>

80107040 <vector78>:
.globl vector78
vector78:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $78
80107042:	6a 4e                	push   $0x4e
  jmp alltraps
80107044:	e9 08 f6 ff ff       	jmp    80106651 <alltraps>

80107049 <vector79>:
.globl vector79
vector79:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $79
8010704b:	6a 4f                	push   $0x4f
  jmp alltraps
8010704d:	e9 ff f5 ff ff       	jmp    80106651 <alltraps>

80107052 <vector80>:
.globl vector80
vector80:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $80
80107054:	6a 50                	push   $0x50
  jmp alltraps
80107056:	e9 f6 f5 ff ff       	jmp    80106651 <alltraps>

8010705b <vector81>:
.globl vector81
vector81:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $81
8010705d:	6a 51                	push   $0x51
  jmp alltraps
8010705f:	e9 ed f5 ff ff       	jmp    80106651 <alltraps>

80107064 <vector82>:
.globl vector82
vector82:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $82
80107066:	6a 52                	push   $0x52
  jmp alltraps
80107068:	e9 e4 f5 ff ff       	jmp    80106651 <alltraps>

8010706d <vector83>:
.globl vector83
vector83:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $83
8010706f:	6a 53                	push   $0x53
  jmp alltraps
80107071:	e9 db f5 ff ff       	jmp    80106651 <alltraps>

80107076 <vector84>:
.globl vector84
vector84:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $84
80107078:	6a 54                	push   $0x54
  jmp alltraps
8010707a:	e9 d2 f5 ff ff       	jmp    80106651 <alltraps>

8010707f <vector85>:
.globl vector85
vector85:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $85
80107081:	6a 55                	push   $0x55
  jmp alltraps
80107083:	e9 c9 f5 ff ff       	jmp    80106651 <alltraps>

80107088 <vector86>:
.globl vector86
vector86:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $86
8010708a:	6a 56                	push   $0x56
  jmp alltraps
8010708c:	e9 c0 f5 ff ff       	jmp    80106651 <alltraps>

80107091 <vector87>:
.globl vector87
vector87:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $87
80107093:	6a 57                	push   $0x57
  jmp alltraps
80107095:	e9 b7 f5 ff ff       	jmp    80106651 <alltraps>

8010709a <vector88>:
.globl vector88
vector88:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $88
8010709c:	6a 58                	push   $0x58
  jmp alltraps
8010709e:	e9 ae f5 ff ff       	jmp    80106651 <alltraps>

801070a3 <vector89>:
.globl vector89
vector89:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $89
801070a5:	6a 59                	push   $0x59
  jmp alltraps
801070a7:	e9 a5 f5 ff ff       	jmp    80106651 <alltraps>

801070ac <vector90>:
.globl vector90
vector90:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $90
801070ae:	6a 5a                	push   $0x5a
  jmp alltraps
801070b0:	e9 9c f5 ff ff       	jmp    80106651 <alltraps>

801070b5 <vector91>:
.globl vector91
vector91:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $91
801070b7:	6a 5b                	push   $0x5b
  jmp alltraps
801070b9:	e9 93 f5 ff ff       	jmp    80106651 <alltraps>

801070be <vector92>:
.globl vector92
vector92:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $92
801070c0:	6a 5c                	push   $0x5c
  jmp alltraps
801070c2:	e9 8a f5 ff ff       	jmp    80106651 <alltraps>

801070c7 <vector93>:
.globl vector93
vector93:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $93
801070c9:	6a 5d                	push   $0x5d
  jmp alltraps
801070cb:	e9 81 f5 ff ff       	jmp    80106651 <alltraps>

801070d0 <vector94>:
.globl vector94
vector94:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $94
801070d2:	6a 5e                	push   $0x5e
  jmp alltraps
801070d4:	e9 78 f5 ff ff       	jmp    80106651 <alltraps>

801070d9 <vector95>:
.globl vector95
vector95:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $95
801070db:	6a 5f                	push   $0x5f
  jmp alltraps
801070dd:	e9 6f f5 ff ff       	jmp    80106651 <alltraps>

801070e2 <vector96>:
.globl vector96
vector96:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $96
801070e4:	6a 60                	push   $0x60
  jmp alltraps
801070e6:	e9 66 f5 ff ff       	jmp    80106651 <alltraps>

801070eb <vector97>:
.globl vector97
vector97:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $97
801070ed:	6a 61                	push   $0x61
  jmp alltraps
801070ef:	e9 5d f5 ff ff       	jmp    80106651 <alltraps>

801070f4 <vector98>:
.globl vector98
vector98:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $98
801070f6:	6a 62                	push   $0x62
  jmp alltraps
801070f8:	e9 54 f5 ff ff       	jmp    80106651 <alltraps>

801070fd <vector99>:
.globl vector99
vector99:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $99
801070ff:	6a 63                	push   $0x63
  jmp alltraps
80107101:	e9 4b f5 ff ff       	jmp    80106651 <alltraps>

80107106 <vector100>:
.globl vector100
vector100:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $100
80107108:	6a 64                	push   $0x64
  jmp alltraps
8010710a:	e9 42 f5 ff ff       	jmp    80106651 <alltraps>

8010710f <vector101>:
.globl vector101
vector101:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $101
80107111:	6a 65                	push   $0x65
  jmp alltraps
80107113:	e9 39 f5 ff ff       	jmp    80106651 <alltraps>

80107118 <vector102>:
.globl vector102
vector102:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $102
8010711a:	6a 66                	push   $0x66
  jmp alltraps
8010711c:	e9 30 f5 ff ff       	jmp    80106651 <alltraps>

80107121 <vector103>:
.globl vector103
vector103:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $103
80107123:	6a 67                	push   $0x67
  jmp alltraps
80107125:	e9 27 f5 ff ff       	jmp    80106651 <alltraps>

8010712a <vector104>:
.globl vector104
vector104:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $104
8010712c:	6a 68                	push   $0x68
  jmp alltraps
8010712e:	e9 1e f5 ff ff       	jmp    80106651 <alltraps>

80107133 <vector105>:
.globl vector105
vector105:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $105
80107135:	6a 69                	push   $0x69
  jmp alltraps
80107137:	e9 15 f5 ff ff       	jmp    80106651 <alltraps>

8010713c <vector106>:
.globl vector106
vector106:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $106
8010713e:	6a 6a                	push   $0x6a
  jmp alltraps
80107140:	e9 0c f5 ff ff       	jmp    80106651 <alltraps>

80107145 <vector107>:
.globl vector107
vector107:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $107
80107147:	6a 6b                	push   $0x6b
  jmp alltraps
80107149:	e9 03 f5 ff ff       	jmp    80106651 <alltraps>

8010714e <vector108>:
.globl vector108
vector108:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $108
80107150:	6a 6c                	push   $0x6c
  jmp alltraps
80107152:	e9 fa f4 ff ff       	jmp    80106651 <alltraps>

80107157 <vector109>:
.globl vector109
vector109:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $109
80107159:	6a 6d                	push   $0x6d
  jmp alltraps
8010715b:	e9 f1 f4 ff ff       	jmp    80106651 <alltraps>

80107160 <vector110>:
.globl vector110
vector110:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $110
80107162:	6a 6e                	push   $0x6e
  jmp alltraps
80107164:	e9 e8 f4 ff ff       	jmp    80106651 <alltraps>

80107169 <vector111>:
.globl vector111
vector111:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $111
8010716b:	6a 6f                	push   $0x6f
  jmp alltraps
8010716d:	e9 df f4 ff ff       	jmp    80106651 <alltraps>

80107172 <vector112>:
.globl vector112
vector112:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $112
80107174:	6a 70                	push   $0x70
  jmp alltraps
80107176:	e9 d6 f4 ff ff       	jmp    80106651 <alltraps>

8010717b <vector113>:
.globl vector113
vector113:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $113
8010717d:	6a 71                	push   $0x71
  jmp alltraps
8010717f:	e9 cd f4 ff ff       	jmp    80106651 <alltraps>

80107184 <vector114>:
.globl vector114
vector114:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $114
80107186:	6a 72                	push   $0x72
  jmp alltraps
80107188:	e9 c4 f4 ff ff       	jmp    80106651 <alltraps>

8010718d <vector115>:
.globl vector115
vector115:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $115
8010718f:	6a 73                	push   $0x73
  jmp alltraps
80107191:	e9 bb f4 ff ff       	jmp    80106651 <alltraps>

80107196 <vector116>:
.globl vector116
vector116:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $116
80107198:	6a 74                	push   $0x74
  jmp alltraps
8010719a:	e9 b2 f4 ff ff       	jmp    80106651 <alltraps>

8010719f <vector117>:
.globl vector117
vector117:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $117
801071a1:	6a 75                	push   $0x75
  jmp alltraps
801071a3:	e9 a9 f4 ff ff       	jmp    80106651 <alltraps>

801071a8 <vector118>:
.globl vector118
vector118:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $118
801071aa:	6a 76                	push   $0x76
  jmp alltraps
801071ac:	e9 a0 f4 ff ff       	jmp    80106651 <alltraps>

801071b1 <vector119>:
.globl vector119
vector119:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $119
801071b3:	6a 77                	push   $0x77
  jmp alltraps
801071b5:	e9 97 f4 ff ff       	jmp    80106651 <alltraps>

801071ba <vector120>:
.globl vector120
vector120:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $120
801071bc:	6a 78                	push   $0x78
  jmp alltraps
801071be:	e9 8e f4 ff ff       	jmp    80106651 <alltraps>

801071c3 <vector121>:
.globl vector121
vector121:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $121
801071c5:	6a 79                	push   $0x79
  jmp alltraps
801071c7:	e9 85 f4 ff ff       	jmp    80106651 <alltraps>

801071cc <vector122>:
.globl vector122
vector122:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $122
801071ce:	6a 7a                	push   $0x7a
  jmp alltraps
801071d0:	e9 7c f4 ff ff       	jmp    80106651 <alltraps>

801071d5 <vector123>:
.globl vector123
vector123:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $123
801071d7:	6a 7b                	push   $0x7b
  jmp alltraps
801071d9:	e9 73 f4 ff ff       	jmp    80106651 <alltraps>

801071de <vector124>:
.globl vector124
vector124:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $124
801071e0:	6a 7c                	push   $0x7c
  jmp alltraps
801071e2:	e9 6a f4 ff ff       	jmp    80106651 <alltraps>

801071e7 <vector125>:
.globl vector125
vector125:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $125
801071e9:	6a 7d                	push   $0x7d
  jmp alltraps
801071eb:	e9 61 f4 ff ff       	jmp    80106651 <alltraps>

801071f0 <vector126>:
.globl vector126
vector126:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $126
801071f2:	6a 7e                	push   $0x7e
  jmp alltraps
801071f4:	e9 58 f4 ff ff       	jmp    80106651 <alltraps>

801071f9 <vector127>:
.globl vector127
vector127:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $127
801071fb:	6a 7f                	push   $0x7f
  jmp alltraps
801071fd:	e9 4f f4 ff ff       	jmp    80106651 <alltraps>

80107202 <vector128>:
.globl vector128
vector128:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $128
80107204:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107209:	e9 43 f4 ff ff       	jmp    80106651 <alltraps>

8010720e <vector129>:
.globl vector129
vector129:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $129
80107210:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107215:	e9 37 f4 ff ff       	jmp    80106651 <alltraps>

8010721a <vector130>:
.globl vector130
vector130:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $130
8010721c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107221:	e9 2b f4 ff ff       	jmp    80106651 <alltraps>

80107226 <vector131>:
.globl vector131
vector131:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $131
80107228:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010722d:	e9 1f f4 ff ff       	jmp    80106651 <alltraps>

80107232 <vector132>:
.globl vector132
vector132:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $132
80107234:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107239:	e9 13 f4 ff ff       	jmp    80106651 <alltraps>

8010723e <vector133>:
.globl vector133
vector133:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $133
80107240:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107245:	e9 07 f4 ff ff       	jmp    80106651 <alltraps>

8010724a <vector134>:
.globl vector134
vector134:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $134
8010724c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107251:	e9 fb f3 ff ff       	jmp    80106651 <alltraps>

80107256 <vector135>:
.globl vector135
vector135:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $135
80107258:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010725d:	e9 ef f3 ff ff       	jmp    80106651 <alltraps>

80107262 <vector136>:
.globl vector136
vector136:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $136
80107264:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107269:	e9 e3 f3 ff ff       	jmp    80106651 <alltraps>

8010726e <vector137>:
.globl vector137
vector137:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $137
80107270:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107275:	e9 d7 f3 ff ff       	jmp    80106651 <alltraps>

8010727a <vector138>:
.globl vector138
vector138:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $138
8010727c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107281:	e9 cb f3 ff ff       	jmp    80106651 <alltraps>

80107286 <vector139>:
.globl vector139
vector139:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $139
80107288:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010728d:	e9 bf f3 ff ff       	jmp    80106651 <alltraps>

80107292 <vector140>:
.globl vector140
vector140:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $140
80107294:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107299:	e9 b3 f3 ff ff       	jmp    80106651 <alltraps>

8010729e <vector141>:
.globl vector141
vector141:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $141
801072a0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801072a5:	e9 a7 f3 ff ff       	jmp    80106651 <alltraps>

801072aa <vector142>:
.globl vector142
vector142:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $142
801072ac:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801072b1:	e9 9b f3 ff ff       	jmp    80106651 <alltraps>

801072b6 <vector143>:
.globl vector143
vector143:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $143
801072b8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801072bd:	e9 8f f3 ff ff       	jmp    80106651 <alltraps>

801072c2 <vector144>:
.globl vector144
vector144:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $144
801072c4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801072c9:	e9 83 f3 ff ff       	jmp    80106651 <alltraps>

801072ce <vector145>:
.globl vector145
vector145:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $145
801072d0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801072d5:	e9 77 f3 ff ff       	jmp    80106651 <alltraps>

801072da <vector146>:
.globl vector146
vector146:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $146
801072dc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072e1:	e9 6b f3 ff ff       	jmp    80106651 <alltraps>

801072e6 <vector147>:
.globl vector147
vector147:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $147
801072e8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072ed:	e9 5f f3 ff ff       	jmp    80106651 <alltraps>

801072f2 <vector148>:
.globl vector148
vector148:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $148
801072f4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072f9:	e9 53 f3 ff ff       	jmp    80106651 <alltraps>

801072fe <vector149>:
.globl vector149
vector149:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $149
80107300:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107305:	e9 47 f3 ff ff       	jmp    80106651 <alltraps>

8010730a <vector150>:
.globl vector150
vector150:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $150
8010730c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107311:	e9 3b f3 ff ff       	jmp    80106651 <alltraps>

80107316 <vector151>:
.globl vector151
vector151:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $151
80107318:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010731d:	e9 2f f3 ff ff       	jmp    80106651 <alltraps>

80107322 <vector152>:
.globl vector152
vector152:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $152
80107324:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107329:	e9 23 f3 ff ff       	jmp    80106651 <alltraps>

8010732e <vector153>:
.globl vector153
vector153:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $153
80107330:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107335:	e9 17 f3 ff ff       	jmp    80106651 <alltraps>

8010733a <vector154>:
.globl vector154
vector154:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $154
8010733c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107341:	e9 0b f3 ff ff       	jmp    80106651 <alltraps>

80107346 <vector155>:
.globl vector155
vector155:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $155
80107348:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010734d:	e9 ff f2 ff ff       	jmp    80106651 <alltraps>

80107352 <vector156>:
.globl vector156
vector156:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $156
80107354:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107359:	e9 f3 f2 ff ff       	jmp    80106651 <alltraps>

8010735e <vector157>:
.globl vector157
vector157:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $157
80107360:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107365:	e9 e7 f2 ff ff       	jmp    80106651 <alltraps>

8010736a <vector158>:
.globl vector158
vector158:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $158
8010736c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107371:	e9 db f2 ff ff       	jmp    80106651 <alltraps>

80107376 <vector159>:
.globl vector159
vector159:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $159
80107378:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010737d:	e9 cf f2 ff ff       	jmp    80106651 <alltraps>

80107382 <vector160>:
.globl vector160
vector160:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $160
80107384:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107389:	e9 c3 f2 ff ff       	jmp    80106651 <alltraps>

8010738e <vector161>:
.globl vector161
vector161:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $161
80107390:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107395:	e9 b7 f2 ff ff       	jmp    80106651 <alltraps>

8010739a <vector162>:
.globl vector162
vector162:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $162
8010739c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801073a1:	e9 ab f2 ff ff       	jmp    80106651 <alltraps>

801073a6 <vector163>:
.globl vector163
vector163:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $163
801073a8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801073ad:	e9 9f f2 ff ff       	jmp    80106651 <alltraps>

801073b2 <vector164>:
.globl vector164
vector164:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $164
801073b4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801073b9:	e9 93 f2 ff ff       	jmp    80106651 <alltraps>

801073be <vector165>:
.globl vector165
vector165:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $165
801073c0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801073c5:	e9 87 f2 ff ff       	jmp    80106651 <alltraps>

801073ca <vector166>:
.globl vector166
vector166:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $166
801073cc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801073d1:	e9 7b f2 ff ff       	jmp    80106651 <alltraps>

801073d6 <vector167>:
.globl vector167
vector167:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $167
801073d8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073dd:	e9 6f f2 ff ff       	jmp    80106651 <alltraps>

801073e2 <vector168>:
.globl vector168
vector168:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $168
801073e4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073e9:	e9 63 f2 ff ff       	jmp    80106651 <alltraps>

801073ee <vector169>:
.globl vector169
vector169:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $169
801073f0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073f5:	e9 57 f2 ff ff       	jmp    80106651 <alltraps>

801073fa <vector170>:
.globl vector170
vector170:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $170
801073fc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107401:	e9 4b f2 ff ff       	jmp    80106651 <alltraps>

80107406 <vector171>:
.globl vector171
vector171:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $171
80107408:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010740d:	e9 3f f2 ff ff       	jmp    80106651 <alltraps>

80107412 <vector172>:
.globl vector172
vector172:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $172
80107414:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107419:	e9 33 f2 ff ff       	jmp    80106651 <alltraps>

8010741e <vector173>:
.globl vector173
vector173:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $173
80107420:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107425:	e9 27 f2 ff ff       	jmp    80106651 <alltraps>

8010742a <vector174>:
.globl vector174
vector174:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $174
8010742c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107431:	e9 1b f2 ff ff       	jmp    80106651 <alltraps>

80107436 <vector175>:
.globl vector175
vector175:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $175
80107438:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010743d:	e9 0f f2 ff ff       	jmp    80106651 <alltraps>

80107442 <vector176>:
.globl vector176
vector176:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $176
80107444:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107449:	e9 03 f2 ff ff       	jmp    80106651 <alltraps>

8010744e <vector177>:
.globl vector177
vector177:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $177
80107450:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107455:	e9 f7 f1 ff ff       	jmp    80106651 <alltraps>

8010745a <vector178>:
.globl vector178
vector178:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $178
8010745c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107461:	e9 eb f1 ff ff       	jmp    80106651 <alltraps>

80107466 <vector179>:
.globl vector179
vector179:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $179
80107468:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010746d:	e9 df f1 ff ff       	jmp    80106651 <alltraps>

80107472 <vector180>:
.globl vector180
vector180:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $180
80107474:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107479:	e9 d3 f1 ff ff       	jmp    80106651 <alltraps>

8010747e <vector181>:
.globl vector181
vector181:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $181
80107480:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107485:	e9 c7 f1 ff ff       	jmp    80106651 <alltraps>

8010748a <vector182>:
.globl vector182
vector182:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $182
8010748c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107491:	e9 bb f1 ff ff       	jmp    80106651 <alltraps>

80107496 <vector183>:
.globl vector183
vector183:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $183
80107498:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010749d:	e9 af f1 ff ff       	jmp    80106651 <alltraps>

801074a2 <vector184>:
.globl vector184
vector184:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $184
801074a4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801074a9:	e9 a3 f1 ff ff       	jmp    80106651 <alltraps>

801074ae <vector185>:
.globl vector185
vector185:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $185
801074b0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801074b5:	e9 97 f1 ff ff       	jmp    80106651 <alltraps>

801074ba <vector186>:
.globl vector186
vector186:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $186
801074bc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801074c1:	e9 8b f1 ff ff       	jmp    80106651 <alltraps>

801074c6 <vector187>:
.globl vector187
vector187:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $187
801074c8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801074cd:	e9 7f f1 ff ff       	jmp    80106651 <alltraps>

801074d2 <vector188>:
.globl vector188
vector188:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $188
801074d4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801074d9:	e9 73 f1 ff ff       	jmp    80106651 <alltraps>

801074de <vector189>:
.globl vector189
vector189:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $189
801074e0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074e5:	e9 67 f1 ff ff       	jmp    80106651 <alltraps>

801074ea <vector190>:
.globl vector190
vector190:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $190
801074ec:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074f1:	e9 5b f1 ff ff       	jmp    80106651 <alltraps>

801074f6 <vector191>:
.globl vector191
vector191:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $191
801074f8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074fd:	e9 4f f1 ff ff       	jmp    80106651 <alltraps>

80107502 <vector192>:
.globl vector192
vector192:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $192
80107504:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107509:	e9 43 f1 ff ff       	jmp    80106651 <alltraps>

8010750e <vector193>:
.globl vector193
vector193:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $193
80107510:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107515:	e9 37 f1 ff ff       	jmp    80106651 <alltraps>

8010751a <vector194>:
.globl vector194
vector194:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $194
8010751c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107521:	e9 2b f1 ff ff       	jmp    80106651 <alltraps>

80107526 <vector195>:
.globl vector195
vector195:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $195
80107528:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010752d:	e9 1f f1 ff ff       	jmp    80106651 <alltraps>

80107532 <vector196>:
.globl vector196
vector196:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $196
80107534:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107539:	e9 13 f1 ff ff       	jmp    80106651 <alltraps>

8010753e <vector197>:
.globl vector197
vector197:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $197
80107540:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107545:	e9 07 f1 ff ff       	jmp    80106651 <alltraps>

8010754a <vector198>:
.globl vector198
vector198:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $198
8010754c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107551:	e9 fb f0 ff ff       	jmp    80106651 <alltraps>

80107556 <vector199>:
.globl vector199
vector199:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $199
80107558:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010755d:	e9 ef f0 ff ff       	jmp    80106651 <alltraps>

80107562 <vector200>:
.globl vector200
vector200:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $200
80107564:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107569:	e9 e3 f0 ff ff       	jmp    80106651 <alltraps>

8010756e <vector201>:
.globl vector201
vector201:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $201
80107570:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107575:	e9 d7 f0 ff ff       	jmp    80106651 <alltraps>

8010757a <vector202>:
.globl vector202
vector202:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $202
8010757c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107581:	e9 cb f0 ff ff       	jmp    80106651 <alltraps>

80107586 <vector203>:
.globl vector203
vector203:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $203
80107588:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010758d:	e9 bf f0 ff ff       	jmp    80106651 <alltraps>

80107592 <vector204>:
.globl vector204
vector204:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $204
80107594:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107599:	e9 b3 f0 ff ff       	jmp    80106651 <alltraps>

8010759e <vector205>:
.globl vector205
vector205:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $205
801075a0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801075a5:	e9 a7 f0 ff ff       	jmp    80106651 <alltraps>

801075aa <vector206>:
.globl vector206
vector206:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $206
801075ac:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801075b1:	e9 9b f0 ff ff       	jmp    80106651 <alltraps>

801075b6 <vector207>:
.globl vector207
vector207:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $207
801075b8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801075bd:	e9 8f f0 ff ff       	jmp    80106651 <alltraps>

801075c2 <vector208>:
.globl vector208
vector208:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $208
801075c4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801075c9:	e9 83 f0 ff ff       	jmp    80106651 <alltraps>

801075ce <vector209>:
.globl vector209
vector209:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $209
801075d0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801075d5:	e9 77 f0 ff ff       	jmp    80106651 <alltraps>

801075da <vector210>:
.globl vector210
vector210:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $210
801075dc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075e1:	e9 6b f0 ff ff       	jmp    80106651 <alltraps>

801075e6 <vector211>:
.globl vector211
vector211:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $211
801075e8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075ed:	e9 5f f0 ff ff       	jmp    80106651 <alltraps>

801075f2 <vector212>:
.globl vector212
vector212:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $212
801075f4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075f9:	e9 53 f0 ff ff       	jmp    80106651 <alltraps>

801075fe <vector213>:
.globl vector213
vector213:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $213
80107600:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107605:	e9 47 f0 ff ff       	jmp    80106651 <alltraps>

8010760a <vector214>:
.globl vector214
vector214:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $214
8010760c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107611:	e9 3b f0 ff ff       	jmp    80106651 <alltraps>

80107616 <vector215>:
.globl vector215
vector215:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $215
80107618:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010761d:	e9 2f f0 ff ff       	jmp    80106651 <alltraps>

80107622 <vector216>:
.globl vector216
vector216:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $216
80107624:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107629:	e9 23 f0 ff ff       	jmp    80106651 <alltraps>

8010762e <vector217>:
.globl vector217
vector217:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $217
80107630:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107635:	e9 17 f0 ff ff       	jmp    80106651 <alltraps>

8010763a <vector218>:
.globl vector218
vector218:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $218
8010763c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107641:	e9 0b f0 ff ff       	jmp    80106651 <alltraps>

80107646 <vector219>:
.globl vector219
vector219:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $219
80107648:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010764d:	e9 ff ef ff ff       	jmp    80106651 <alltraps>

80107652 <vector220>:
.globl vector220
vector220:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $220
80107654:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107659:	e9 f3 ef ff ff       	jmp    80106651 <alltraps>

8010765e <vector221>:
.globl vector221
vector221:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $221
80107660:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107665:	e9 e7 ef ff ff       	jmp    80106651 <alltraps>

8010766a <vector222>:
.globl vector222
vector222:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $222
8010766c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107671:	e9 db ef ff ff       	jmp    80106651 <alltraps>

80107676 <vector223>:
.globl vector223
vector223:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $223
80107678:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010767d:	e9 cf ef ff ff       	jmp    80106651 <alltraps>

80107682 <vector224>:
.globl vector224
vector224:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $224
80107684:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107689:	e9 c3 ef ff ff       	jmp    80106651 <alltraps>

8010768e <vector225>:
.globl vector225
vector225:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $225
80107690:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107695:	e9 b7 ef ff ff       	jmp    80106651 <alltraps>

8010769a <vector226>:
.globl vector226
vector226:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $226
8010769c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801076a1:	e9 ab ef ff ff       	jmp    80106651 <alltraps>

801076a6 <vector227>:
.globl vector227
vector227:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $227
801076a8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801076ad:	e9 9f ef ff ff       	jmp    80106651 <alltraps>

801076b2 <vector228>:
.globl vector228
vector228:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $228
801076b4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801076b9:	e9 93 ef ff ff       	jmp    80106651 <alltraps>

801076be <vector229>:
.globl vector229
vector229:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $229
801076c0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801076c5:	e9 87 ef ff ff       	jmp    80106651 <alltraps>

801076ca <vector230>:
.globl vector230
vector230:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $230
801076cc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801076d1:	e9 7b ef ff ff       	jmp    80106651 <alltraps>

801076d6 <vector231>:
.globl vector231
vector231:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $231
801076d8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076dd:	e9 6f ef ff ff       	jmp    80106651 <alltraps>

801076e2 <vector232>:
.globl vector232
vector232:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $232
801076e4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076e9:	e9 63 ef ff ff       	jmp    80106651 <alltraps>

801076ee <vector233>:
.globl vector233
vector233:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $233
801076f0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076f5:	e9 57 ef ff ff       	jmp    80106651 <alltraps>

801076fa <vector234>:
.globl vector234
vector234:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $234
801076fc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107701:	e9 4b ef ff ff       	jmp    80106651 <alltraps>

80107706 <vector235>:
.globl vector235
vector235:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $235
80107708:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010770d:	e9 3f ef ff ff       	jmp    80106651 <alltraps>

80107712 <vector236>:
.globl vector236
vector236:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $236
80107714:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107719:	e9 33 ef ff ff       	jmp    80106651 <alltraps>

8010771e <vector237>:
.globl vector237
vector237:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $237
80107720:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107725:	e9 27 ef ff ff       	jmp    80106651 <alltraps>

8010772a <vector238>:
.globl vector238
vector238:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $238
8010772c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107731:	e9 1b ef ff ff       	jmp    80106651 <alltraps>

80107736 <vector239>:
.globl vector239
vector239:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $239
80107738:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010773d:	e9 0f ef ff ff       	jmp    80106651 <alltraps>

80107742 <vector240>:
.globl vector240
vector240:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $240
80107744:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107749:	e9 03 ef ff ff       	jmp    80106651 <alltraps>

8010774e <vector241>:
.globl vector241
vector241:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $241
80107750:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107755:	e9 f7 ee ff ff       	jmp    80106651 <alltraps>

8010775a <vector242>:
.globl vector242
vector242:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $242
8010775c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107761:	e9 eb ee ff ff       	jmp    80106651 <alltraps>

80107766 <vector243>:
.globl vector243
vector243:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $243
80107768:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010776d:	e9 df ee ff ff       	jmp    80106651 <alltraps>

80107772 <vector244>:
.globl vector244
vector244:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $244
80107774:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107779:	e9 d3 ee ff ff       	jmp    80106651 <alltraps>

8010777e <vector245>:
.globl vector245
vector245:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $245
80107780:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107785:	e9 c7 ee ff ff       	jmp    80106651 <alltraps>

8010778a <vector246>:
.globl vector246
vector246:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $246
8010778c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107791:	e9 bb ee ff ff       	jmp    80106651 <alltraps>

80107796 <vector247>:
.globl vector247
vector247:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $247
80107798:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010779d:	e9 af ee ff ff       	jmp    80106651 <alltraps>

801077a2 <vector248>:
.globl vector248
vector248:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $248
801077a4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801077a9:	e9 a3 ee ff ff       	jmp    80106651 <alltraps>

801077ae <vector249>:
.globl vector249
vector249:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $249
801077b0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801077b5:	e9 97 ee ff ff       	jmp    80106651 <alltraps>

801077ba <vector250>:
.globl vector250
vector250:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $250
801077bc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801077c1:	e9 8b ee ff ff       	jmp    80106651 <alltraps>

801077c6 <vector251>:
.globl vector251
vector251:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $251
801077c8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801077cd:	e9 7f ee ff ff       	jmp    80106651 <alltraps>

801077d2 <vector252>:
.globl vector252
vector252:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $252
801077d4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801077d9:	e9 73 ee ff ff       	jmp    80106651 <alltraps>

801077de <vector253>:
.globl vector253
vector253:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $253
801077e0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077e5:	e9 67 ee ff ff       	jmp    80106651 <alltraps>

801077ea <vector254>:
.globl vector254
vector254:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $254
801077ec:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077f1:	e9 5b ee ff ff       	jmp    80106651 <alltraps>

801077f6 <vector255>:
.globl vector255
vector255:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $255
801077f8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077fd:	e9 4f ee ff ff       	jmp    80106651 <alltraps>

80107802 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107802:	55                   	push   %ebp
80107803:	89 e5                	mov    %esp,%ebp
80107805:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010780b:	83 e8 01             	sub    $0x1,%eax
8010780e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107812:	8b 45 08             	mov    0x8(%ebp),%eax
80107815:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107819:	8b 45 08             	mov    0x8(%ebp),%eax
8010781c:	c1 e8 10             	shr    $0x10,%eax
8010781f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107823:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107826:	0f 01 10             	lgdtl  (%eax)
}
80107829:	90                   	nop
8010782a:	c9                   	leave  
8010782b:	c3                   	ret    

8010782c <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010782c:	55                   	push   %ebp
8010782d:	89 e5                	mov    %esp,%ebp
8010782f:	83 ec 04             	sub    $0x4,%esp
80107832:	8b 45 08             	mov    0x8(%ebp),%eax
80107835:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107839:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010783d:	0f 00 d8             	ltr    %ax
}
80107840:	90                   	nop
80107841:	c9                   	leave  
80107842:	c3                   	ret    

80107843 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107843:	55                   	push   %ebp
80107844:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107846:	8b 45 08             	mov    0x8(%ebp),%eax
80107849:	0f 22 d8             	mov    %eax,%cr3
}
8010784c:	90                   	nop
8010784d:	5d                   	pop    %ebp
8010784e:	c3                   	ret    

8010784f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010784f:	55                   	push   %ebp
80107850:	89 e5                	mov    %esp,%ebp
80107852:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107855:	e8 fe c9 ff ff       	call   80104258 <cpuid>
8010785a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107860:	05 00 38 11 80       	add    $0x80113800,%eax
80107865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107874:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010787a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107884:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107888:	83 e2 f0             	and    $0xfffffff0,%edx
8010788b:	83 ca 0a             	or     $0xa,%edx
8010788e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107891:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107894:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107898:	83 ca 10             	or     $0x10,%edx
8010789b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010789e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078a5:	83 e2 9f             	and    $0xffffff9f,%edx
801078a8:	88 50 7d             	mov    %dl,0x7d(%eax)
801078ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ae:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078b2:	83 ca 80             	or     $0xffffff80,%edx
801078b5:	88 50 7d             	mov    %dl,0x7d(%eax)
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078bf:	83 ca 0f             	or     $0xf,%edx
801078c2:	88 50 7e             	mov    %dl,0x7e(%eax)
801078c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078cc:	83 e2 ef             	and    $0xffffffef,%edx
801078cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801078d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078d9:	83 e2 df             	and    $0xffffffdf,%edx
801078dc:	88 50 7e             	mov    %dl,0x7e(%eax)
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078e6:	83 ca 40             	or     $0x40,%edx
801078e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801078ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078f3:	83 ca 80             	or     $0xffffff80,%edx
801078f6:	88 50 7e             	mov    %dl,0x7e(%eax)
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107903:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010790a:	ff ff 
8010790c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107916:	00 00 
80107918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107925:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010792c:	83 e2 f0             	and    $0xfffffff0,%edx
8010792f:	83 ca 02             	or     $0x2,%edx
80107932:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107942:	83 ca 10             	or     $0x10,%edx
80107945:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010794b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107955:	83 e2 9f             	and    $0xffffff9f,%edx
80107958:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010795e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107961:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107968:	83 ca 80             	or     $0xffffff80,%edx
8010796b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010797b:	83 ca 0f             	or     $0xf,%edx
8010797e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010798e:	83 e2 ef             	and    $0xffffffef,%edx
80107991:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079a1:	83 e2 df             	and    $0xffffffdf,%edx
801079a4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079b4:	83 ca 40             	or     $0x40,%edx
801079b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079c7:	83 ca 80             	or     $0xffffff80,%edx
801079ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801079e4:	ff ff 
801079e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e9:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801079f0:	00 00 
801079f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f5:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801079fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ff:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a06:	83 e2 f0             	and    $0xfffffff0,%edx
80107a09:	83 ca 0a             	or     $0xa,%edx
80107a0c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a1c:	83 ca 10             	or     $0x10,%edx
80107a1f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a28:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a2f:	83 ca 60             	or     $0x60,%edx
80107a32:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a42:	83 ca 80             	or     $0xffffff80,%edx
80107a45:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a55:	83 ca 0f             	or     $0xf,%edx
80107a58:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a61:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a68:	83 e2 ef             	and    $0xffffffef,%edx
80107a6b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a74:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a7b:	83 e2 df             	and    $0xffffffdf,%edx
80107a7e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a8e:	83 ca 40             	or     $0x40,%edx
80107a91:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107aa1:	83 ca 80             	or     $0xffffff80,%edx
80107aa4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aad:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107abe:	ff ff 
80107ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107aca:	00 00 
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ae0:	83 e2 f0             	and    $0xfffffff0,%edx
80107ae3:	83 ca 02             	or     $0x2,%edx
80107ae6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107af6:	83 ca 10             	or     $0x10,%edx
80107af9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b02:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b09:	83 ca 60             	or     $0x60,%edx
80107b0c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b15:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b1c:	83 ca 80             	or     $0xffffff80,%edx
80107b1f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b28:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b2f:	83 ca 0f             	or     $0xf,%edx
80107b32:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b42:	83 e2 ef             	and    $0xffffffef,%edx
80107b45:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b55:	83 e2 df             	and    $0xffffffdf,%edx
80107b58:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b61:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b68:	83 ca 40             	or     $0x40,%edx
80107b6b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b74:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b7b:	83 ca 80             	or     $0xffffff80,%edx
80107b7e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b87:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	83 c0 70             	add    $0x70,%eax
80107b94:	83 ec 08             	sub    $0x8,%esp
80107b97:	6a 30                	push   $0x30
80107b99:	50                   	push   %eax
80107b9a:	e8 63 fc ff ff       	call   80107802 <lgdt>
80107b9f:	83 c4 10             	add    $0x10,%esp
}
80107ba2:	90                   	nop
80107ba3:	c9                   	leave  
80107ba4:	c3                   	ret    

80107ba5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107ba5:	55                   	push   %ebp
80107ba6:	89 e5                	mov    %esp,%ebp
80107ba8:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107bab:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bae:	c1 e8 16             	shr    $0x16,%eax
80107bb1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80107bbb:	01 d0                	add    %edx,%eax
80107bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bc3:	8b 00                	mov    (%eax),%eax
80107bc5:	83 e0 01             	and    $0x1,%eax
80107bc8:	85 c0                	test   %eax,%eax
80107bca:	74 14                	je     80107be0 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bcf:	8b 00                	mov    (%eax),%eax
80107bd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bd6:	05 00 00 00 80       	add    $0x80000000,%eax
80107bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bde:	eb 42                	jmp    80107c22 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107be0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107be4:	74 0e                	je     80107bf4 <walkpgdir+0x4f>
80107be6:	e8 0e b1 ff ff       	call   80102cf9 <kalloc>
80107beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bf2:	75 07                	jne    80107bfb <walkpgdir+0x56>
      return 0;
80107bf4:	b8 00 00 00 00       	mov    $0x0,%eax
80107bf9:	eb 3e                	jmp    80107c39 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107bfb:	83 ec 04             	sub    $0x4,%esp
80107bfe:	68 00 10 00 00       	push   $0x1000
80107c03:	6a 00                	push   $0x0
80107c05:	ff 75 f4             	pushl  -0xc(%ebp)
80107c08:	e8 6a d6 ff ff       	call   80105277 <memset>
80107c0d:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	05 00 00 00 80       	add    $0x80000000,%eax
80107c18:	83 c8 07             	or     $0x7,%eax
80107c1b:	89 c2                	mov    %eax,%edx
80107c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c20:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c25:	c1 e8 0c             	shr    $0xc,%eax
80107c28:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c37:	01 d0                	add    %edx,%eax
}
80107c39:	c9                   	leave  
80107c3a:	c3                   	ret    

80107c3b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c3b:	55                   	push   %ebp
80107c3c:	89 e5                	mov    %esp,%ebp
80107c3e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
 
  cprintf("SIZE: %x\n", size);
80107c41:	83 ec 08             	sub    $0x8,%esp
80107c44:	ff 75 10             	pushl  0x10(%ebp)
80107c47:	68 74 8d 10 80       	push   $0x80108d74
80107c4c:	e8 af 87 ff ff       	call   80100400 <cprintf>
80107c51:	83 c4 10             	add    $0x10,%esp
  a = (char*)PGROUNDDOWN((uint)va);
80107c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c62:	8b 45 10             	mov    0x10(%ebp),%eax
80107c65:	01 d0                	add    %edx,%eax
80107c67:	83 e8 01             	sub    $0x1,%eax
80107c6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c72:	83 ec 04             	sub    $0x4,%esp
80107c75:	6a 01                	push   $0x1
80107c77:	ff 75 f4             	pushl  -0xc(%ebp)
80107c7a:	ff 75 08             	pushl  0x8(%ebp)
80107c7d:	e8 23 ff ff ff       	call   80107ba5 <walkpgdir>
80107c82:	83 c4 10             	add    $0x10,%esp
80107c85:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c8c:	75 07                	jne    80107c95 <mappages+0x5a>
      return -1;
80107c8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c93:	eb 47                	jmp    80107cdc <mappages+0xa1>
    if(*pte & PTE_P)
80107c95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c98:	8b 00                	mov    (%eax),%eax
80107c9a:	83 e0 01             	and    $0x1,%eax
80107c9d:	85 c0                	test   %eax,%eax
80107c9f:	74 0d                	je     80107cae <mappages+0x73>
      panic("remap");
80107ca1:	83 ec 0c             	sub    $0xc,%esp
80107ca4:	68 7e 8d 10 80       	push   $0x80108d7e
80107ca9:	e8 f2 88 ff ff       	call   801005a0 <panic>
    *pte = pa | perm | PTE_P;
80107cae:	8b 45 18             	mov    0x18(%ebp),%eax
80107cb1:	0b 45 14             	or     0x14(%ebp),%eax
80107cb4:	83 c8 01             	or     $0x1,%eax
80107cb7:	89 c2                	mov    %eax,%edx
80107cb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cbc:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107cc4:	74 10                	je     80107cd6 <mappages+0x9b>
      break;
    a += PGSIZE;
80107cc6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ccd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107cd4:	eb 9c                	jmp    80107c72 <mappages+0x37>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107cd6:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cdc:	c9                   	leave  
80107cdd:	c3                   	ret    

80107cde <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107cde:	55                   	push   %ebp
80107cdf:	89 e5                	mov    %esp,%ebp
80107ce1:	53                   	push   %ebx
80107ce2:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ce5:	e8 0f b0 ff ff       	call   80102cf9 <kalloc>
80107cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ced:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf1:	75 07                	jne    80107cfa <setupkvm+0x1c>
    return 0;
80107cf3:	b8 00 00 00 00       	mov    $0x0,%eax
80107cf8:	eb 78                	jmp    80107d72 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107cfa:	83 ec 04             	sub    $0x4,%esp
80107cfd:	68 00 10 00 00       	push   $0x1000
80107d02:	6a 00                	push   $0x0
80107d04:	ff 75 f0             	pushl  -0x10(%ebp)
80107d07:	e8 6b d5 ff ff       	call   80105277 <memset>
80107d0c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d0f:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107d16:	eb 4e                	jmp    80107d66 <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d27:	8b 58 08             	mov    0x8(%eax),%ebx
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	8b 40 04             	mov    0x4(%eax),%eax
80107d30:	29 c3                	sub    %eax,%ebx
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	8b 00                	mov    (%eax),%eax
80107d37:	83 ec 0c             	sub    $0xc,%esp
80107d3a:	51                   	push   %ecx
80107d3b:	52                   	push   %edx
80107d3c:	53                   	push   %ebx
80107d3d:	50                   	push   %eax
80107d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80107d41:	e8 f5 fe ff ff       	call   80107c3b <mappages>
80107d46:	83 c4 20             	add    $0x20,%esp
80107d49:	85 c0                	test   %eax,%eax
80107d4b:	79 15                	jns    80107d62 <setupkvm+0x84>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107d4d:	83 ec 0c             	sub    $0xc,%esp
80107d50:	ff 75 f0             	pushl  -0x10(%ebp)
80107d53:	e8 1a 05 00 00       	call   80108272 <freevm>
80107d58:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d5b:	b8 00 00 00 00       	mov    $0x0,%eax
80107d60:	eb 10                	jmp    80107d72 <setupkvm+0x94>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d62:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d66:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107d6d:	72 a9                	jb     80107d18 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d75:	c9                   	leave  
80107d76:	c3                   	ret    

80107d77 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d77:	55                   	push   %ebp
80107d78:	89 e5                	mov    %esp,%ebp
80107d7a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d7d:	e8 5c ff ff ff       	call   80107cde <setupkvm>
80107d82:	a3 24 67 11 80       	mov    %eax,0x80116724
  switchkvm();
80107d87:	e8 03 00 00 00       	call   80107d8f <switchkvm>
}
80107d8c:	90                   	nop
80107d8d:	c9                   	leave  
80107d8e:	c3                   	ret    

80107d8f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d8f:	55                   	push   %ebp
80107d90:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d92:	a1 24 67 11 80       	mov    0x80116724,%eax
80107d97:	05 00 00 00 80       	add    $0x80000000,%eax
80107d9c:	50                   	push   %eax
80107d9d:	e8 a1 fa ff ff       	call   80107843 <lcr3>
80107da2:	83 c4 04             	add    $0x4,%esp
}
80107da5:	90                   	nop
80107da6:	c9                   	leave  
80107da7:	c3                   	ret    

80107da8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107da8:	55                   	push   %ebp
80107da9:	89 e5                	mov    %esp,%ebp
80107dab:	56                   	push   %esi
80107dac:	53                   	push   %ebx
80107dad:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107db0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107db4:	75 0d                	jne    80107dc3 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107db6:	83 ec 0c             	sub    $0xc,%esp
80107db9:	68 84 8d 10 80       	push   $0x80108d84
80107dbe:	e8 dd 87 ff ff       	call   801005a0 <panic>
  if(p->kstack == 0)
80107dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc6:	8b 40 08             	mov    0x8(%eax),%eax
80107dc9:	85 c0                	test   %eax,%eax
80107dcb:	75 0d                	jne    80107dda <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107dcd:	83 ec 0c             	sub    $0xc,%esp
80107dd0:	68 9a 8d 10 80       	push   $0x80108d9a
80107dd5:	e8 c6 87 ff ff       	call   801005a0 <panic>
  if(p->pgdir == 0)
80107dda:	8b 45 08             	mov    0x8(%ebp),%eax
80107ddd:	8b 40 04             	mov    0x4(%eax),%eax
80107de0:	85 c0                	test   %eax,%eax
80107de2:	75 0d                	jne    80107df1 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107de4:	83 ec 0c             	sub    $0xc,%esp
80107de7:	68 af 8d 10 80       	push   $0x80108daf
80107dec:	e8 af 87 ff ff       	call   801005a0 <panic>

  pushcli();
80107df1:	e8 75 d3 ff ff       	call   8010516b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107df6:	e8 7e c4 ff ff       	call   80104279 <mycpu>
80107dfb:	89 c3                	mov    %eax,%ebx
80107dfd:	e8 77 c4 ff ff       	call   80104279 <mycpu>
80107e02:	83 c0 08             	add    $0x8,%eax
80107e05:	89 c6                	mov    %eax,%esi
80107e07:	e8 6d c4 ff ff       	call   80104279 <mycpu>
80107e0c:	83 c0 08             	add    $0x8,%eax
80107e0f:	c1 e8 10             	shr    $0x10,%eax
80107e12:	88 45 f7             	mov    %al,-0x9(%ebp)
80107e15:	e8 5f c4 ff ff       	call   80104279 <mycpu>
80107e1a:	83 c0 08             	add    $0x8,%eax
80107e1d:	c1 e8 18             	shr    $0x18,%eax
80107e20:	89 c2                	mov    %eax,%edx
80107e22:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107e29:	67 00 
80107e2b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107e32:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107e36:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107e3c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e43:	83 e0 f0             	and    $0xfffffff0,%eax
80107e46:	83 c8 09             	or     $0x9,%eax
80107e49:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e4f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e56:	83 c8 10             	or     $0x10,%eax
80107e59:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e5f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e66:	83 e0 9f             	and    $0xffffff9f,%eax
80107e69:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e6f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e76:	83 c8 80             	or     $0xffffff80,%eax
80107e79:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e7f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e86:	83 e0 f0             	and    $0xfffffff0,%eax
80107e89:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e8f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e96:	83 e0 ef             	and    $0xffffffef,%eax
80107e99:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e9f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ea6:	83 e0 df             	and    $0xffffffdf,%eax
80107ea9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107eaf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107eb6:	83 c8 40             	or     $0x40,%eax
80107eb9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ebf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ec6:	83 e0 7f             	and    $0x7f,%eax
80107ec9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ecf:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107ed5:	e8 9f c3 ff ff       	call   80104279 <mycpu>
80107eda:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ee1:	83 e2 ef             	and    $0xffffffef,%edx
80107ee4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107eea:	e8 8a c3 ff ff       	call   80104279 <mycpu>
80107eef:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107ef5:	e8 7f c3 ff ff       	call   80104279 <mycpu>
80107efa:	89 c2                	mov    %eax,%edx
80107efc:	8b 45 08             	mov    0x8(%ebp),%eax
80107eff:	8b 40 08             	mov    0x8(%eax),%eax
80107f02:	05 00 10 00 00       	add    $0x1000,%eax
80107f07:	89 42 0c             	mov    %eax,0xc(%edx)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107f0a:	e8 6a c3 ff ff       	call   80104279 <mycpu>
80107f0f:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107f15:	83 ec 0c             	sub    $0xc,%esp
80107f18:	6a 28                	push   $0x28
80107f1a:	e8 0d f9 ff ff       	call   8010782c <ltr>
80107f1f:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107f22:	8b 45 08             	mov    0x8(%ebp),%eax
80107f25:	8b 40 04             	mov    0x4(%eax),%eax
80107f28:	05 00 00 00 80       	add    $0x80000000,%eax
80107f2d:	83 ec 0c             	sub    $0xc,%esp
80107f30:	50                   	push   %eax
80107f31:	e8 0d f9 ff ff       	call   80107843 <lcr3>
80107f36:	83 c4 10             	add    $0x10,%esp
  popcli();
80107f39:	e8 7b d2 ff ff       	call   801051b9 <popcli>
}
80107f3e:	90                   	nop
80107f3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107f42:	5b                   	pop    %ebx
80107f43:	5e                   	pop    %esi
80107f44:	5d                   	pop    %ebp
80107f45:	c3                   	ret    

80107f46 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107f46:	55                   	push   %ebp
80107f47:	89 e5                	mov    %esp,%ebp
80107f49:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107f4c:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f53:	76 0d                	jbe    80107f62 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107f55:	83 ec 0c             	sub    $0xc,%esp
80107f58:	68 c3 8d 10 80       	push   $0x80108dc3
80107f5d:	e8 3e 86 ff ff       	call   801005a0 <panic>
  mem = kalloc();
80107f62:	e8 92 ad ff ff       	call   80102cf9 <kalloc>
80107f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f6a:	83 ec 04             	sub    $0x4,%esp
80107f6d:	68 00 10 00 00       	push   $0x1000
80107f72:	6a 00                	push   $0x0
80107f74:	ff 75 f4             	pushl  -0xc(%ebp)
80107f77:	e8 fb d2 ff ff       	call   80105277 <memset>
80107f7c:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f82:	05 00 00 00 80       	add    $0x80000000,%eax
80107f87:	83 ec 0c             	sub    $0xc,%esp
80107f8a:	6a 06                	push   $0x6
80107f8c:	50                   	push   %eax
80107f8d:	68 00 10 00 00       	push   $0x1000
80107f92:	6a 00                	push   $0x0
80107f94:	ff 75 08             	pushl  0x8(%ebp)
80107f97:	e8 9f fc ff ff       	call   80107c3b <mappages>
80107f9c:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f9f:	83 ec 04             	sub    $0x4,%esp
80107fa2:	ff 75 10             	pushl  0x10(%ebp)
80107fa5:	ff 75 0c             	pushl  0xc(%ebp)
80107fa8:	ff 75 f4             	pushl  -0xc(%ebp)
80107fab:	e8 86 d3 ff ff       	call   80105336 <memmove>
80107fb0:	83 c4 10             	add    $0x10,%esp
}
80107fb3:	90                   	nop
80107fb4:	c9                   	leave  
80107fb5:	c3                   	ret    

80107fb6 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107fb6:	55                   	push   %ebp
80107fb7:	89 e5                	mov    %esp,%ebp
80107fb9:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fbf:	25 ff 0f 00 00       	and    $0xfff,%eax
80107fc4:	85 c0                	test   %eax,%eax
80107fc6:	74 0d                	je     80107fd5 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107fc8:	83 ec 0c             	sub    $0xc,%esp
80107fcb:	68 e0 8d 10 80       	push   $0x80108de0
80107fd0:	e8 cb 85 ff ff       	call   801005a0 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107fd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fdc:	e9 8f 00 00 00       	jmp    80108070 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107fe1:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe7:	01 d0                	add    %edx,%eax
80107fe9:	83 ec 04             	sub    $0x4,%esp
80107fec:	6a 00                	push   $0x0
80107fee:	50                   	push   %eax
80107fef:	ff 75 08             	pushl  0x8(%ebp)
80107ff2:	e8 ae fb ff ff       	call   80107ba5 <walkpgdir>
80107ff7:	83 c4 10             	add    $0x10,%esp
80107ffa:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ffd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108001:	75 0d                	jne    80108010 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108003:	83 ec 0c             	sub    $0xc,%esp
80108006:	68 03 8e 10 80       	push   $0x80108e03
8010800b:	e8 90 85 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108013:	8b 00                	mov    (%eax),%eax
80108015:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010801d:	8b 45 18             	mov    0x18(%ebp),%eax
80108020:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108023:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108028:	77 0b                	ja     80108035 <loaduvm+0x7f>
      n = sz - i;
8010802a:	8b 45 18             	mov    0x18(%ebp),%eax
8010802d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108030:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108033:	eb 07                	jmp    8010803c <loaduvm+0x86>
    else
      n = PGSIZE;
80108035:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010803c:	8b 55 14             	mov    0x14(%ebp),%edx
8010803f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108042:	01 d0                	add    %edx,%eax
80108044:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108047:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010804d:	ff 75 f0             	pushl  -0x10(%ebp)
80108050:	50                   	push   %eax
80108051:	52                   	push   %edx
80108052:	ff 75 10             	pushl  0x10(%ebp)
80108055:	e8 0b 9f ff ff       	call   80101f65 <readi>
8010805a:	83 c4 10             	add    $0x10,%esp
8010805d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108060:	74 07                	je     80108069 <loaduvm+0xb3>
      return -1;
80108062:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108067:	eb 18                	jmp    80108081 <loaduvm+0xcb>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108069:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108073:	3b 45 18             	cmp    0x18(%ebp),%eax
80108076:	0f 82 65 ff ff ff    	jb     80107fe1 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010807c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108081:	c9                   	leave  
80108082:	c3                   	ret    

80108083 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108083:	55                   	push   %ebp
80108084:	89 e5                	mov    %esp,%ebp
80108086:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108089:	8b 45 10             	mov    0x10(%ebp),%eax
8010808c:	85 c0                	test   %eax,%eax
8010808e:	79 0a                	jns    8010809a <allocuvm+0x17>
    return 0;
80108090:	b8 00 00 00 00       	mov    $0x0,%eax
80108095:	e9 12 01 00 00       	jmp    801081ac <allocuvm+0x129>
  if(newsz < oldsz)
8010809a:	8b 45 10             	mov    0x10(%ebp),%eax
8010809d:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080a0:	73 08                	jae    801080aa <allocuvm+0x27>
    return oldsz;
801080a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a5:	e9 02 01 00 00       	jmp    801081ac <allocuvm+0x129>

  a = PGROUNDUP(oldsz);
801080aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ad:	05 ff 0f 00 00       	add    $0xfff,%eax
801080b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  a = oldsz;
  cprintf("ALLOC TOP: %x\n", newsz);
801080ba:	83 ec 08             	sub    $0x8,%esp
801080bd:	ff 75 10             	pushl  0x10(%ebp)
801080c0:	68 21 8e 10 80       	push   $0x80108e21
801080c5:	e8 36 83 ff ff       	call   80100400 <cprintf>
801080ca:	83 c4 10             	add    $0x10,%esp
  cprintf("ALLOC BOTTOM: %x\n", a);
801080cd:	83 ec 08             	sub    $0x8,%esp
801080d0:	ff 75 f4             	pushl  -0xc(%ebp)
801080d3:	68 30 8e 10 80       	push   $0x80108e30
801080d8:	e8 23 83 ff ff       	call   80100400 <cprintf>
801080dd:	83 c4 10             	add    $0x10,%esp
  for(; a < newsz; a += PGSIZE){
801080e0:	e9 b8 00 00 00       	jmp    8010819d <allocuvm+0x11a>
    mem = kalloc();
801080e5:	e8 0f ac ff ff       	call   80102cf9 <kalloc>
801080ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801080ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080f1:	75 2e                	jne    80108121 <allocuvm+0x9e>
      cprintf("allocuvm out of memory\n");
801080f3:	83 ec 0c             	sub    $0xc,%esp
801080f6:	68 42 8e 10 80       	push   $0x80108e42
801080fb:	e8 00 83 ff ff       	call   80100400 <cprintf>
80108100:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108103:	83 ec 04             	sub    $0x4,%esp
80108106:	ff 75 0c             	pushl  0xc(%ebp)
80108109:	ff 75 10             	pushl  0x10(%ebp)
8010810c:	ff 75 08             	pushl  0x8(%ebp)
8010810f:	e8 9a 00 00 00       	call   801081ae <deallocuvm>
80108114:	83 c4 10             	add    $0x10,%esp
      return 0;
80108117:	b8 00 00 00 00       	mov    $0x0,%eax
8010811c:	e9 8b 00 00 00       	jmp    801081ac <allocuvm+0x129>
    }
//   cprintf("MEM: %x\n", mem);
    memset(mem, 0, PGSIZE);
80108121:	83 ec 04             	sub    $0x4,%esp
80108124:	68 00 10 00 00       	push   $0x1000
80108129:	6a 00                	push   $0x0
8010812b:	ff 75 f0             	pushl  -0x10(%ebp)
8010812e:	e8 44 d1 ff ff       	call   80105277 <memset>
80108133:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108139:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108142:	83 ec 0c             	sub    $0xc,%esp
80108145:	6a 06                	push   $0x6
80108147:	52                   	push   %edx
80108148:	68 00 10 00 00       	push   $0x1000
8010814d:	50                   	push   %eax
8010814e:	ff 75 08             	pushl  0x8(%ebp)
80108151:	e8 e5 fa ff ff       	call   80107c3b <mappages>
80108156:	83 c4 20             	add    $0x20,%esp
80108159:	85 c0                	test   %eax,%eax
8010815b:	79 39                	jns    80108196 <allocuvm+0x113>
      cprintf("allocuvm out of memory (2)\n");
8010815d:	83 ec 0c             	sub    $0xc,%esp
80108160:	68 5a 8e 10 80       	push   $0x80108e5a
80108165:	e8 96 82 ff ff       	call   80100400 <cprintf>
8010816a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010816d:	83 ec 04             	sub    $0x4,%esp
80108170:	ff 75 0c             	pushl  0xc(%ebp)
80108173:	ff 75 10             	pushl  0x10(%ebp)
80108176:	ff 75 08             	pushl  0x8(%ebp)
80108179:	e8 30 00 00 00       	call   801081ae <deallocuvm>
8010817e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108181:	83 ec 0c             	sub    $0xc,%esp
80108184:	ff 75 f0             	pushl  -0x10(%ebp)
80108187:	e8 d3 aa ff ff       	call   80102c5f <kfree>
8010818c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010818f:	b8 00 00 00 00       	mov    $0x0,%eax
80108194:	eb 16                	jmp    801081ac <allocuvm+0x129>

  a = PGROUNDUP(oldsz);
//  a = oldsz;
  cprintf("ALLOC TOP: %x\n", newsz);
  cprintf("ALLOC BOTTOM: %x\n", a);
  for(; a < newsz; a += PGSIZE){
80108196:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010819d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a0:	3b 45 10             	cmp    0x10(%ebp),%eax
801081a3:	0f 82 3c ff ff ff    	jb     801080e5 <allocuvm+0x62>
      kfree(mem);
      return 0;
    }
  }
//  cprintf("TOPPAGE: %x\n", newsz);
  return newsz;
801081a9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081ac:	c9                   	leave  
801081ad:	c3                   	ret    

801081ae <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081ae:	55                   	push   %ebp
801081af:	89 e5                	mov    %esp,%ebp
801081b1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801081b4:	8b 45 10             	mov    0x10(%ebp),%eax
801081b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081ba:	72 08                	jb     801081c4 <deallocuvm+0x16>
    return oldsz;
801081bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801081bf:	e9 ac 00 00 00       	jmp    80108270 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801081c4:	8b 45 10             	mov    0x10(%ebp),%eax
801081c7:	05 ff 0f 00 00       	add    $0xfff,%eax
801081cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081d4:	e9 88 00 00 00       	jmp    80108261 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801081d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dc:	83 ec 04             	sub    $0x4,%esp
801081df:	6a 00                	push   $0x0
801081e1:	50                   	push   %eax
801081e2:	ff 75 08             	pushl  0x8(%ebp)
801081e5:	e8 bb f9 ff ff       	call   80107ba5 <walkpgdir>
801081ea:	83 c4 10             	add    $0x10,%esp
801081ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081f4:	75 16                	jne    8010820c <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801081f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f9:	c1 e8 16             	shr    $0x16,%eax
801081fc:	83 c0 01             	add    $0x1,%eax
801081ff:	c1 e0 16             	shl    $0x16,%eax
80108202:	2d 00 10 00 00       	sub    $0x1000,%eax
80108207:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010820a:	eb 4e                	jmp    8010825a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010820c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010820f:	8b 00                	mov    (%eax),%eax
80108211:	83 e0 01             	and    $0x1,%eax
80108214:	85 c0                	test   %eax,%eax
80108216:	74 42                	je     8010825a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010821b:	8b 00                	mov    (%eax),%eax
8010821d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108222:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108225:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108229:	75 0d                	jne    80108238 <deallocuvm+0x8a>
        panic("kfree");
8010822b:	83 ec 0c             	sub    $0xc,%esp
8010822e:	68 76 8e 10 80       	push   $0x80108e76
80108233:	e8 68 83 ff ff       	call   801005a0 <panic>
      char *v = P2V(pa);
80108238:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010823b:	05 00 00 00 80       	add    $0x80000000,%eax
80108240:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108243:	83 ec 0c             	sub    $0xc,%esp
80108246:	ff 75 e8             	pushl  -0x18(%ebp)
80108249:	e8 11 aa ff ff       	call   80102c5f <kfree>
8010824e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108254:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010825a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108264:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108267:	0f 82 6c ff ff ff    	jb     801081d9 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010826d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108270:	c9                   	leave  
80108271:	c3                   	ret    

80108272 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108272:	55                   	push   %ebp
80108273:	89 e5                	mov    %esp,%ebp
80108275:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108278:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010827c:	75 0d                	jne    8010828b <freevm+0x19>
    panic("freevm: no pgdir");
8010827e:	83 ec 0c             	sub    $0xc,%esp
80108281:	68 7c 8e 10 80       	push   $0x80108e7c
80108286:	e8 15 83 ff ff       	call   801005a0 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010828b:	83 ec 04             	sub    $0x4,%esp
8010828e:	6a 00                	push   $0x0
80108290:	68 00 00 00 80       	push   $0x80000000
80108295:	ff 75 08             	pushl  0x8(%ebp)
80108298:	e8 11 ff ff ff       	call   801081ae <deallocuvm>
8010829d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082a7:	eb 48                	jmp    801082f1 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801082a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082b3:	8b 45 08             	mov    0x8(%ebp),%eax
801082b6:	01 d0                	add    %edx,%eax
801082b8:	8b 00                	mov    (%eax),%eax
801082ba:	83 e0 01             	and    $0x1,%eax
801082bd:	85 c0                	test   %eax,%eax
801082bf:	74 2c                	je     801082ed <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801082c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082cb:	8b 45 08             	mov    0x8(%ebp),%eax
801082ce:	01 d0                	add    %edx,%eax
801082d0:	8b 00                	mov    (%eax),%eax
801082d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082d7:	05 00 00 00 80       	add    $0x80000000,%eax
801082dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801082df:	83 ec 0c             	sub    $0xc,%esp
801082e2:	ff 75 f0             	pushl  -0x10(%ebp)
801082e5:	e8 75 a9 ff ff       	call   80102c5f <kfree>
801082ea:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801082ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082f1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082f8:	76 af                	jbe    801082a9 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801082fa:	83 ec 0c             	sub    $0xc,%esp
801082fd:	ff 75 08             	pushl  0x8(%ebp)
80108300:	e8 5a a9 ff ff       	call   80102c5f <kfree>
80108305:	83 c4 10             	add    $0x10,%esp
}
80108308:	90                   	nop
80108309:	c9                   	leave  
8010830a:	c3                   	ret    

8010830b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010830b:	55                   	push   %ebp
8010830c:	89 e5                	mov    %esp,%ebp
8010830e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108311:	83 ec 04             	sub    $0x4,%esp
80108314:	6a 00                	push   $0x0
80108316:	ff 75 0c             	pushl  0xc(%ebp)
80108319:	ff 75 08             	pushl  0x8(%ebp)
8010831c:	e8 84 f8 ff ff       	call   80107ba5 <walkpgdir>
80108321:	83 c4 10             	add    $0x10,%esp
80108324:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108327:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010832b:	75 0d                	jne    8010833a <clearpteu+0x2f>
    panic("clearpteu");
8010832d:	83 ec 0c             	sub    $0xc,%esp
80108330:	68 8d 8e 10 80       	push   $0x80108e8d
80108335:	e8 66 82 ff ff       	call   801005a0 <panic>
  *pte &= ~PTE_U;
8010833a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833d:	8b 00                	mov    (%eax),%eax
8010833f:	83 e0 fb             	and    $0xfffffffb,%eax
80108342:	89 c2                	mov    %eax,%edx
80108344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108347:	89 10                	mov    %edx,(%eax)
}
80108349:	90                   	nop
8010834a:	c9                   	leave  
8010834b:	c3                   	ret    

8010834c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, uint lp, uint pn)
{
8010834c:	55                   	push   %ebp
8010834d:	89 e5                	mov    %esp,%ebp
8010834f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108352:	e8 87 f9 ff ff       	call   80107cde <setupkvm>
80108357:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010835a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010835e:	75 0a                	jne    8010836a <copyuvm+0x1e>
    return 0;
80108360:	b8 00 00 00 00       	mov    $0x0,%eax
80108365:	e9 ec 01 00 00       	jmp    80108556 <copyuvm+0x20a>
  for(i = 0; i < sz; i += PGSIZE){
8010836a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108371:	e9 bf 00 00 00       	jmp    80108435 <copyuvm+0xe9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108379:	83 ec 04             	sub    $0x4,%esp
8010837c:	6a 00                	push   $0x0
8010837e:	50                   	push   %eax
8010837f:	ff 75 08             	pushl  0x8(%ebp)
80108382:	e8 1e f8 ff ff       	call   80107ba5 <walkpgdir>
80108387:	83 c4 10             	add    $0x10,%esp
8010838a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010838d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108391:	75 0d                	jne    801083a0 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108393:	83 ec 0c             	sub    $0xc,%esp
80108396:	68 97 8e 10 80       	push   $0x80108e97
8010839b:	e8 00 82 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
801083a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a3:	8b 00                	mov    (%eax),%eax
801083a5:	83 e0 01             	and    $0x1,%eax
801083a8:	85 c0                	test   %eax,%eax
801083aa:	75 0d                	jne    801083b9 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801083ac:	83 ec 0c             	sub    $0xc,%esp
801083af:	68 b1 8e 10 80       	push   $0x80108eb1
801083b4:	e8 e7 81 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
801083b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083bc:	8b 00                	mov    (%eax),%eax
801083be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c9:	8b 00                	mov    (%eax),%eax
801083cb:	25 ff 0f 00 00       	and    $0xfff,%eax
801083d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083d3:	e8 21 a9 ff ff       	call   80102cf9 <kalloc>
801083d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801083db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801083df:	0f 84 54 01 00 00    	je     80108539 <copyuvm+0x1ed>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801083e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083e8:	05 00 00 00 80       	add    $0x80000000,%eax
801083ed:	83 ec 04             	sub    $0x4,%esp
801083f0:	68 00 10 00 00       	push   $0x1000
801083f5:	50                   	push   %eax
801083f6:	ff 75 e0             	pushl  -0x20(%ebp)
801083f9:	e8 38 cf ff ff       	call   80105336 <memmove>
801083fe:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108404:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108407:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	83 ec 0c             	sub    $0xc,%esp
80108413:	52                   	push   %edx
80108414:	51                   	push   %ecx
80108415:	68 00 10 00 00       	push   $0x1000
8010841a:	50                   	push   %eax
8010841b:	ff 75 f0             	pushl  -0x10(%ebp)
8010841e:	e8 18 f8 ff ff       	call   80107c3b <mappages>
80108423:	83 c4 20             	add    $0x20,%esp
80108426:	85 c0                	test   %eax,%eax
80108428:	0f 88 0e 01 00 00    	js     8010853c <copyuvm+0x1f0>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010842e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108438:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010843b:	0f 82 35 ff ff ff    	jb     80108376 <copyuvm+0x2a>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }


 cprintf("COPUVM SP2 : %x\n", lp-pn*PGSIZE);
80108441:	8b 45 14             	mov    0x14(%ebp),%eax
80108444:	c1 e0 0c             	shl    $0xc,%eax
80108447:	89 c2                	mov    %eax,%edx
80108449:	8b 45 10             	mov    0x10(%ebp),%eax
8010844c:	29 d0                	sub    %edx,%eax
8010844e:	83 ec 08             	sub    $0x8,%esp
80108451:	50                   	push   %eax
80108452:	68 cb 8e 10 80       	push   $0x80108ecb
80108457:	e8 a4 7f ff ff       	call   80100400 <cprintf>
8010845c:	83 c4 10             	add    $0x10,%esp
 for(i = PGROUNDDOWN(lp-1); i < KERNBASE; i += PGSIZE){
8010845f:	8b 45 10             	mov    0x10(%ebp),%eax
80108462:	83 e8 01             	sub    $0x1,%eax
80108465:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010846a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010846d:	e9 b7 00 00 00       	jmp    80108529 <copyuvm+0x1dd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108475:	83 ec 04             	sub    $0x4,%esp
80108478:	6a 00                	push   $0x0
8010847a:	50                   	push   %eax
8010847b:	ff 75 08             	pushl  0x8(%ebp)
8010847e:	e8 22 f7 ff ff       	call   80107ba5 <walkpgdir>
80108483:	83 c4 10             	add    $0x10,%esp
80108486:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108489:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010848d:	75 0d                	jne    8010849c <copyuvm+0x150>
      panic("copyuvm: pte should exist");
8010848f:	83 ec 0c             	sub    $0xc,%esp
80108492:	68 97 8e 10 80       	push   $0x80108e97
80108497:	e8 04 81 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010849c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010849f:	8b 00                	mov    (%eax),%eax
801084a1:	83 e0 01             	and    $0x1,%eax
801084a4:	85 c0                	test   %eax,%eax
801084a6:	75 0d                	jne    801084b5 <copyuvm+0x169>
      panic("copyuvm: page not present");
801084a8:	83 ec 0c             	sub    $0xc,%esp
801084ab:	68 b1 8e 10 80       	push   $0x80108eb1
801084b0:	e8 eb 80 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
801084b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084b8:	8b 00                	mov    (%eax),%eax
801084ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801084c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c5:	8b 00                	mov    (%eax),%eax
801084c7:	25 ff 0f 00 00       	and    $0xfff,%eax
801084cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801084cf:	e8 25 a8 ff ff       	call   80102cf9 <kalloc>
801084d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801084d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801084db:	74 62                	je     8010853f <copyuvm+0x1f3>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801084dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084e0:	05 00 00 00 80       	add    $0x80000000,%eax
801084e5:	83 ec 04             	sub    $0x4,%esp
801084e8:	68 00 10 00 00       	push   $0x1000
801084ed:	50                   	push   %eax
801084ee:	ff 75 e0             	pushl  -0x20(%ebp)
801084f1:	e8 40 ce ff ff       	call   80105336 <memmove>
801084f6:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801084f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801084fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084ff:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108508:	83 ec 0c             	sub    $0xc,%esp
8010850b:	52                   	push   %edx
8010850c:	51                   	push   %ecx
8010850d:	68 00 10 00 00       	push   $0x1000
80108512:	50                   	push   %eax
80108513:	ff 75 f0             	pushl  -0x10(%ebp)
80108516:	e8 20 f7 ff ff       	call   80107c3b <mappages>
8010851b:	83 c4 20             	add    $0x20,%esp
8010851e:	85 c0                	test   %eax,%eax
80108520:	78 20                	js     80108542 <copyuvm+0x1f6>
      goto bad;
  }


 cprintf("COPUVM SP2 : %x\n", lp-pn*PGSIZE);
 for(i = PGROUNDDOWN(lp-1); i < KERNBASE; i += PGSIZE){
80108522:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852c:	85 c0                	test   %eax,%eax
8010852e:	0f 89 3e ff ff ff    	jns    80108472 <copyuvm+0x126>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  return d;
80108534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108537:	eb 1d                	jmp    80108556 <copyuvm+0x20a>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108539:	90                   	nop
8010853a:	eb 07                	jmp    80108543 <copyuvm+0x1f7>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
8010853c:	90                   	nop
8010853d:	eb 04                	jmp    80108543 <copyuvm+0x1f7>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010853f:	90                   	nop
80108540:	eb 01                	jmp    80108543 <copyuvm+0x1f7>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
80108542:	90                   	nop
  }

  return d;

bad:
  freevm(d);
80108543:	83 ec 0c             	sub    $0xc,%esp
80108546:	ff 75 f0             	pushl  -0x10(%ebp)
80108549:	e8 24 fd ff ff       	call   80108272 <freevm>
8010854e:	83 c4 10             	add    $0x10,%esp
  return 0;
80108551:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108556:	c9                   	leave  
80108557:	c3                   	ret    

80108558 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108558:	55                   	push   %ebp
80108559:	89 e5                	mov    %esp,%ebp
8010855b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010855e:	83 ec 04             	sub    $0x4,%esp
80108561:	6a 00                	push   $0x0
80108563:	ff 75 0c             	pushl  0xc(%ebp)
80108566:	ff 75 08             	pushl  0x8(%ebp)
80108569:	e8 37 f6 ff ff       	call   80107ba5 <walkpgdir>
8010856e:	83 c4 10             	add    $0x10,%esp
80108571:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	8b 00                	mov    (%eax),%eax
80108579:	83 e0 01             	and    $0x1,%eax
8010857c:	85 c0                	test   %eax,%eax
8010857e:	75 07                	jne    80108587 <uva2ka+0x2f>
    return 0;
80108580:	b8 00 00 00 00       	mov    $0x0,%eax
80108585:	eb 22                	jmp    801085a9 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858a:	8b 00                	mov    (%eax),%eax
8010858c:	83 e0 04             	and    $0x4,%eax
8010858f:	85 c0                	test   %eax,%eax
80108591:	75 07                	jne    8010859a <uva2ka+0x42>
    return 0;
80108593:	b8 00 00 00 00       	mov    $0x0,%eax
80108598:	eb 0f                	jmp    801085a9 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010859a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859d:	8b 00                	mov    (%eax),%eax
8010859f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a4:	05 00 00 00 80       	add    $0x80000000,%eax
}
801085a9:	c9                   	leave  
801085aa:	c3                   	ret    

801085ab <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801085ab:	55                   	push   %ebp
801085ac:	89 e5                	mov    %esp,%ebp
801085ae:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801085b1:	8b 45 10             	mov    0x10(%ebp),%eax
801085b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801085b7:	eb 7f                	jmp    80108638 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801085b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801085c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085c7:	83 ec 08             	sub    $0x8,%esp
801085ca:	50                   	push   %eax
801085cb:	ff 75 08             	pushl  0x8(%ebp)
801085ce:	e8 85 ff ff ff       	call   80108558 <uva2ka>
801085d3:	83 c4 10             	add    $0x10,%esp
801085d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801085d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801085dd:	75 07                	jne    801085e6 <copyout+0x3b>
      return -1;
801085df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085e4:	eb 61                	jmp    80108647 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801085e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e9:	2b 45 0c             	sub    0xc(%ebp),%eax
801085ec:	05 00 10 00 00       	add    $0x1000,%eax
801085f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f7:	3b 45 14             	cmp    0x14(%ebp),%eax
801085fa:	76 06                	jbe    80108602 <copyout+0x57>
      n = len;
801085fc:	8b 45 14             	mov    0x14(%ebp),%eax
801085ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108602:	8b 45 0c             	mov    0xc(%ebp),%eax
80108605:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108608:	89 c2                	mov    %eax,%edx
8010860a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010860d:	01 d0                	add    %edx,%eax
8010860f:	83 ec 04             	sub    $0x4,%esp
80108612:	ff 75 f0             	pushl  -0x10(%ebp)
80108615:	ff 75 f4             	pushl  -0xc(%ebp)
80108618:	50                   	push   %eax
80108619:	e8 18 cd ff ff       	call   80105336 <memmove>
8010861e:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108624:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010862a:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010862d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108630:	05 00 10 00 00       	add    $0x1000,%eax
80108635:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108638:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010863c:	0f 85 77 ff ff ff    	jne    801085b9 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108642:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108647:	c9                   	leave  
80108648:	c3                   	ret    

80108649 <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
80108649:	55                   	push   %ebp
8010864a:	89 e5                	mov    %esp,%ebp
8010864c:	83 ec 18             	sub    $0x18,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
8010864f:	83 ec 08             	sub    $0x8,%esp
80108652:	68 dc 8e 10 80       	push   $0x80108edc
80108657:	68 40 67 11 80       	push   $0x80116740
8010865c:	e8 7d c9 ff ff       	call   80104fde <initlock>
80108661:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
80108664:	83 ec 0c             	sub    $0xc,%esp
80108667:	68 40 67 11 80       	push   $0x80116740
8010866c:	e8 8f c9 ff ff       	call   80105000 <acquire>
80108671:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i< 64; i++) {
80108674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010867b:	eb 49                	jmp    801086c6 <shminit+0x7d>
    shm_table.shm_pages[i].id =0;
8010867d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108680:	89 d0                	mov    %edx,%eax
80108682:	01 c0                	add    %eax,%eax
80108684:	01 d0                	add    %edx,%eax
80108686:	c1 e0 02             	shl    $0x2,%eax
80108689:	05 74 67 11 80       	add    $0x80116774,%eax
8010868e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80108694:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108697:	89 d0                	mov    %edx,%eax
80108699:	01 c0                	add    %eax,%eax
8010869b:	01 d0                	add    %edx,%eax
8010869d:	c1 e0 02             	shl    $0x2,%eax
801086a0:	05 78 67 11 80       	add    $0x80116778,%eax
801086a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
801086ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ae:	89 d0                	mov    %edx,%eax
801086b0:	01 c0                	add    %eax,%eax
801086b2:	01 d0                	add    %edx,%eax
801086b4:	c1 e0 02             	shl    $0x2,%eax
801086b7:	05 7c 67 11 80       	add    $0x8011677c,%eax
801086bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
801086c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086c6:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801086ca:	7e b1                	jle    8010867d <shminit+0x34>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
801086cc:	83 ec 0c             	sub    $0xc,%esp
801086cf:	68 40 67 11 80       	push   $0x80116740
801086d4:	e8 95 c9 ff ff       	call   8010506e <release>
801086d9:	83 c4 10             	add    $0x10,%esp
}
801086dc:	90                   	nop
801086dd:	c9                   	leave  
801086de:	c3                   	ret    

801086df <shm_open>:

int shm_open(int id, char **pointer) {
801086df:	55                   	push   %ebp
801086e0:	89 e5                	mov    %esp,%ebp
//you write this




return 0; //added to remove compiler warning -- you should decide what to return
801086e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086e7:	5d                   	pop    %ebp
801086e8:	c3                   	ret    

801086e9 <shm_close>:


int shm_close(int id) {
801086e9:	55                   	push   %ebp
801086ea:	89 e5                	mov    %esp,%ebp
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
801086ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086f1:	5d                   	pop    %ebp
801086f2:	c3                   	ret    
