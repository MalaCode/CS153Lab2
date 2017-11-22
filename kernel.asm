
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
8010002d:	b8 f0 38 10 80       	mov    $0x801038f0,%eax
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
8010003d:	68 a4 86 10 80       	push   $0x801086a4
80100042:	68 40 c6 10 80       	push   $0x8010c640
80100047:	e8 d5 4f 00 00       	call   80105021 <initlock>
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
8010008b:	68 ab 86 10 80       	push   $0x801086ab
80100090:	50                   	push   %eax
80100091:	e8 2e 4e 00 00       	call   80104ec4 <initsleeplock>
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
801000ce:	e8 70 4f 00 00       	call   80105043 <acquire>
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
8010010d:	e8 9f 4f 00 00       	call   801050b1 <release>
80100112:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	83 c0 0c             	add    $0xc,%eax
8010011b:	83 ec 0c             	sub    $0xc,%esp
8010011e:	50                   	push   %eax
8010011f:	e8 dc 4d 00 00       	call   80104f00 <acquiresleep>
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
8010018e:	e8 1e 4f 00 00       	call   801050b1 <release>
80100193:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	83 c0 0c             	add    $0xc,%eax
8010019c:	83 ec 0c             	sub    $0xc,%esp
8010019f:	50                   	push   %eax
801001a0:	e8 5b 4d 00 00       	call   80104f00 <acquiresleep>
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
801001c2:	68 b2 86 10 80       	push   $0x801086b2
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
801001fa:	e8 f0 27 00 00       	call   801029ef <iderw>
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
80100217:	e8 96 4d 00 00       	call   80104fb2 <holdingsleep>
8010021c:	83 c4 10             	add    $0x10,%esp
8010021f:	85 c0                	test   %eax,%eax
80100221:	75 0d                	jne    80100230 <bwrite+0x29>
    panic("bwrite");
80100223:	83 ec 0c             	sub    $0xc,%esp
80100226:	68 c3 86 10 80       	push   $0x801086c3
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
80100245:	e8 a5 27 00 00       	call   801029ef <iderw>
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
80100260:	e8 4d 4d 00 00       	call   80104fb2 <holdingsleep>
80100265:	83 c4 10             	add    $0x10,%esp
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 0d                	jne    80100279 <brelse+0x29>
    panic("brelse");
8010026c:	83 ec 0c             	sub    $0xc,%esp
8010026f:	68 ca 86 10 80       	push   $0x801086ca
80100274:	e8 27 03 00 00       	call   801005a0 <panic>

  releasesleep(&b->lock);
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	83 c0 0c             	add    $0xc,%eax
8010027f:	83 ec 0c             	sub    $0xc,%esp
80100282:	50                   	push   %eax
80100283:	e8 dc 4c 00 00       	call   80104f64 <releasesleep>
80100288:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028b:	83 ec 0c             	sub    $0xc,%esp
8010028e:	68 40 c6 10 80       	push   $0x8010c640
80100293:	e8 ab 4d 00 00       	call   80105043 <acquire>
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
80100303:	e8 a9 4d 00 00       	call   801050b1 <release>
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
8010041c:	e8 22 4c 00 00       	call   80105043 <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 d1 86 10 80       	push   $0x801086d1
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
80100507:	c7 45 ec da 86 10 80 	movl   $0x801086da,-0x14(%ebp)
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
80100595:	e8 17 4b 00 00       	call   801050b1 <release>
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
801005b5:	e8 c4 2a 00 00       	call   8010307e <lapicid>
801005ba:	83 ec 08             	sub    $0x8,%esp
801005bd:	50                   	push   %eax
801005be:	68 e1 86 10 80       	push   $0x801086e1
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
801005dd:	68 f5 86 10 80       	push   $0x801086f5
801005e2:	e8 19 fe ff ff       	call   80100400 <cprintf>
801005e7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ea:	83 ec 08             	sub    $0x8,%esp
801005ed:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f0:	50                   	push   %eax
801005f1:	8d 45 08             	lea    0x8(%ebp),%eax
801005f4:	50                   	push   %eax
801005f5:	e8 09 4b 00 00       	call   80105103 <getcallerpcs>
801005fa:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100604:	eb 1c                	jmp    80100622 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100609:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060d:	83 ec 08             	sub    $0x8,%esp
80100610:	50                   	push   %eax
80100611:	68 f7 86 10 80       	push   $0x801086f7
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
801006fd:	68 fb 86 10 80       	push   $0x801086fb
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
8010072a:	e8 4a 4c 00 00       	call   80105379 <memmove>
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
80100754:	e8 61 4b 00 00       	call   801052ba <memset>
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
801007e9:	e8 9c 64 00 00       	call   80106c8a <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	6a 20                	push   $0x20
801007f6:	e8 8f 64 00 00       	call   80106c8a <uartputc>
801007fb:	83 c4 10             	add    $0x10,%esp
801007fe:	83 ec 0c             	sub    $0xc,%esp
80100801:	6a 08                	push   $0x8
80100803:	e8 82 64 00 00       	call   80106c8a <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	eb 0e                	jmp    8010081b <consputc+0x56>
  } else
    uartputc(c);
8010080d:	83 ec 0c             	sub    $0xc,%esp
80100810:	ff 75 08             	pushl  0x8(%ebp)
80100813:	e8 72 64 00 00       	call   80106c8a <uartputc>
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
80100841:	e8 fd 47 00 00       	call   80105043 <acquire>
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
80100989:	e8 7c 43 00 00       	call   80104d0a <wakeup>
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
801009ac:	e8 00 47 00 00       	call   801050b1 <release>
801009b1:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b8:	74 05                	je     801009bf <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
801009ba:	e8 09 44 00 00       	call   80104dc8 <procdump>
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
801009ce:	e8 e3 11 00 00       	call   80101bb6 <iunlock>
801009d3:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009dc:	83 ec 0c             	sub    $0xc,%esp
801009df:	68 a0 b5 10 80       	push   $0x8010b5a0
801009e4:	e8 5a 46 00 00       	call   80105043 <acquire>
801009e9:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ec:	e9 ab 00 00 00       	jmp    80100a9c <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009f1:	e8 2a 39 00 00       	call   80104320 <myproc>
801009f6:	8b 40 24             	mov    0x24(%eax),%eax
801009f9:	85 c0                	test   %eax,%eax
801009fb:	74 28                	je     80100a25 <consoleread+0x63>
        release(&cons.lock);
801009fd:	83 ec 0c             	sub    $0xc,%esp
80100a00:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a05:	e8 a7 46 00 00       	call   801050b1 <release>
80100a0a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0d:	83 ec 0c             	sub    $0xc,%esp
80100a10:	ff 75 08             	pushl  0x8(%ebp)
80100a13:	e8 8b 10 00 00       	call   80101aa3 <ilock>
80100a18:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a20:	e9 ab 00 00 00       	jmp    80100ad0 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
80100a25:	83 ec 08             	sub    $0x8,%esp
80100a28:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a2d:	68 20 10 11 80       	push   $0x80111020
80100a32:	e8 ea 41 00 00       	call   80104c21 <sleep>
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
80100ab0:	e8 fc 45 00 00       	call   801050b1 <release>
80100ab5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab8:	83 ec 0c             	sub    $0xc,%esp
80100abb:	ff 75 08             	pushl  0x8(%ebp)
80100abe:	e8 e0 0f 00 00       	call   80101aa3 <ilock>
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
80100ade:	e8 d3 10 00 00       	call   80101bb6 <iunlock>
80100ae3:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 a0 b5 10 80       	push   $0x8010b5a0
80100aee:	e8 50 45 00 00       	call   80105043 <acquire>
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
80100b30:	e8 7c 45 00 00       	call   801050b1 <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 60 0f 00 00       	call   80101aa3 <ilock>
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
80100b54:	68 0e 87 10 80       	push   $0x8010870e
80100b59:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b5e:	e8 be 44 00 00       	call   80105021 <initlock>
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
80100b8b:	e8 27 20 00 00       	call   80102bb7 <ioapicenable>
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
80100b9f:	e8 7c 37 00 00       	call   80104320 <myproc>
80100ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba7:	e8 1c 2a 00 00       	call   801035c8 <begin_op>

  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 2c 1a 00 00       	call   801025e3 <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 1f                	jne    80100be2 <exec+0x4c>
    end_op();
80100bc3:	e8 8c 2a 00 00       	call   80103654 <end_op>
    cprintf("exec: fail\n");
80100bc8:	83 ec 0c             	sub    $0xc,%esp
80100bcb:	68 16 87 10 80       	push   $0x80108716
80100bd0:	e8 2b f8 ff ff       	call   80100400 <cprintf>
80100bd5:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdd:	e9 84 04 00 00       	jmp    80101066 <exec+0x4d0>
  }
  ilock(ip);
80100be2:	83 ec 0c             	sub    $0xc,%esp
80100be5:	ff 75 d8             	pushl  -0x28(%ebp)
80100be8:	e8 b6 0e 00 00       	call   80101aa3 <ilock>
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
80100c05:	e8 8a 13 00 00       	call   80101f94 <readi>
80100c0a:	83 c4 10             	add    $0x10,%esp
80100c0d:	83 f8 34             	cmp    $0x34,%eax
80100c10:	0f 85 f9 03 00 00    	jne    8010100f <exec+0x479>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c21:	0f 85 eb 03 00 00    	jne    80101012 <exec+0x47c>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c27:	e8 5a 70 00 00       	call   80107c86 <setupkvm>
80100c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c33:	0f 84 dc 03 00 00    	je     80101015 <exec+0x47f>
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
80100c65:	e8 2a 13 00 00       	call   80101f94 <readi>
80100c6a:	83 c4 10             	add    $0x10,%esp
80100c6d:	83 f8 20             	cmp    $0x20,%eax
80100c70:	0f 85 a2 03 00 00    	jne    80101018 <exec+0x482>
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
80100c93:	0f 82 82 03 00 00    	jb     8010101b <exec+0x485>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c99:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c9f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca5:	01 c2                	add    %eax,%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	39 c2                	cmp    %eax,%edx
80100caf:	0f 82 69 03 00 00    	jb     8010101e <exec+0x488>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc1:	01 d0                	add    %edx,%eax
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 e0             	pushl  -0x20(%ebp)
80100cca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccd:	e8 59 73 00 00       	call   8010802b <allocuvm>
80100cd2:	83 c4 10             	add    $0x10,%esp
80100cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdc:	0f 84 3f 03 00 00    	je     80101021 <exec+0x48b>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ce8:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	0f 85 2f 03 00 00    	jne    80101024 <exec+0x48e>
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
80100d13:	e8 46 72 00 00       	call   80107f5e <loaduvm>
80100d18:	83 c4 20             	add    $0x20,%esp
80100d1b:	85 c0                	test   %eax,%eax
80100d1d:	0f 88 04 03 00 00    	js     80101027 <exec+0x491>
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
80100d4c:	e8 83 0f 00 00       	call   80101cd4 <iunlockput>
80100d51:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d54:	e8 fb 28 00 00       	call   80103654 <end_op>
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
80100d82:	e8 a4 72 00 00       	call   8010802b <allocuvm>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d91:	0f 84 93 02 00 00    	je     8010102a <exec+0x494>
    goto bad;
  clearpteu(pgdir, (char*)(sz - PGSIZE));
80100d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9a:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d9f:	83 ec 08             	sub    $0x8,%esp
80100da2:	50                   	push   %eax
80100da3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da6:	e8 1b 75 00 00       	call   801082c6 <clearpteu>
80100dab:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)

   cprintf("KERNBASE: %x\n", KERNBASE);
80100db4:	83 ec 08             	sub    $0x8,%esp
80100db7:	68 00 00 00 80       	push   $0x80000000
80100dbc:	68 22 87 10 80       	push   $0x80108722
80100dc1:	e8 3a f6 ff ff       	call   80100400 <cprintf>
80100dc6:	83 c4 10             	add    $0x10,%esp
   //cprintf("PGSIZE: %d\n", PGSIZE);

   curproc->last_page = allocuvm(pgdir, KERNBASE - PGSIZE , KERNBASE-4);
80100dc9:	83 ec 04             	sub    $0x4,%esp
80100dcc:	68 fc ff ff 7f       	push   $0x7ffffffc
80100dd1:	68 00 f0 ff 7f       	push   $0x7ffff000
80100dd6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd9:	e8 4d 72 00 00       	call   8010802b <allocuvm>
80100dde:	83 c4 10             	add    $0x10,%esp
80100de1:	89 c2                	mov    %eax,%edx
80100de3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100de6:	89 50 7c             	mov    %edx,0x7c(%eax)
   curproc->bottom_page = curproc->last_page ;
80100de9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dec:	8b 50 7c             	mov    0x7c(%eax),%edx
80100def:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100df2:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  
   cprintf("LAST_PAGE: %x\n", curproc->last_page);
80100df8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dfb:	8b 40 7c             	mov    0x7c(%eax),%eax
80100dfe:	83 ec 08             	sub    $0x8,%esp
80100e01:	50                   	push   %eax
80100e02:	68 30 87 10 80       	push   $0x80108730
80100e07:	e8 f4 f5 ff ff       	call   80100400 <cprintf>
80100e0c:	83 c4 10             	add    $0x10,%esp
   cprintf("BOTTOM_PAGE: %x\n", curproc->bottom_page - PGSIZE);
80100e0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e12:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80100e18:	2d 00 10 00 00       	sub    $0x1000,%eax
80100e1d:	83 ec 08             	sub    $0x8,%esp
80100e20:	50                   	push   %eax
80100e21:	68 3f 87 10 80       	push   $0x8010873f
80100e26:	e8 d5 f5 ff ff       	call   80100400 <cprintf>
80100e2b:	83 c4 10             	add    $0x10,%esp

   sp = curproc->last_page;
80100e2e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e31:	8b 40 7c             	mov    0x7c(%eax),%eax
80100e34:	89 45 dc             	mov    %eax,-0x24(%ebp)
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e37:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e3e:	e9 93 00 00 00       	jmp    80100ed6 <exec+0x340>
    if(argc >= MAXARG)
80100e43:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e47:	0f 87 e0 01 00 00    	ja     8010102d <exec+0x497>
      goto bad;
    sp = (sp - (strlen(argv[argc]) )) & ~3;
80100e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e5a:	01 d0                	add    %edx,%eax
80100e5c:	8b 00                	mov    (%eax),%eax
80100e5e:	83 ec 0c             	sub    $0xc,%esp
80100e61:	50                   	push   %eax
80100e62:	e8 a0 46 00 00       	call   80105507 <strlen>
80100e67:	83 c4 10             	add    $0x10,%esp
80100e6a:	89 c2                	mov    %eax,%edx
80100e6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e6f:	29 d0                	sub    %edx,%eax
80100e71:	83 e0 fc             	and    $0xfffffffc,%eax
80100e74:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e84:	01 d0                	add    %edx,%eax
80100e86:	8b 00                	mov    (%eax),%eax
80100e88:	83 ec 0c             	sub    $0xc,%esp
80100e8b:	50                   	push   %eax
80100e8c:	e8 76 46 00 00       	call   80105507 <strlen>
80100e91:	83 c4 10             	add    $0x10,%esp
80100e94:	83 c0 01             	add    $0x1,%eax
80100e97:	89 c1                	mov    %eax,%ecx
80100e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea6:	01 d0                	add    %edx,%eax
80100ea8:	8b 00                	mov    (%eax),%eax
80100eaa:	51                   	push   %ecx
80100eab:	50                   	push   %eax
80100eac:	ff 75 dc             	pushl  -0x24(%ebp)
80100eaf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eb2:	e8 a4 76 00 00       	call   8010855b <copyout>
80100eb7:	83 c4 10             	add    $0x10,%esp
80100eba:	85 c0                	test   %eax,%eax
80100ebc:	0f 88 6e 01 00 00    	js     80101030 <exec+0x49a>
      goto bad;
    ustack[3+argc] = sp;
80100ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec5:	8d 50 03             	lea    0x3(%eax),%edx
80100ec8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecb:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
   cprintf("BOTTOM_PAGE: %x\n", curproc->bottom_page - PGSIZE);

   sp = curproc->last_page;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ed2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ee3:	01 d0                	add    %edx,%eax
80100ee5:	8b 00                	mov    (%eax),%eax
80100ee7:	85 c0                	test   %eax,%eax
80100ee9:	0f 85 54 ff ff ff    	jne    80100e43 <exec+0x2ad>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef2:	83 c0 03             	add    $0x3,%eax
80100ef5:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100efc:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f00:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f07:	ff ff ff 
  ustack[1] = argc;
80100f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f0d:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f16:	83 c0 01             	add    $0x1,%eax
80100f19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f23:	29 d0                	sub    %edx,%eax
80100f25:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2e:	83 c0 04             	add    $0x4,%eax
80100f31:	c1 e0 02             	shl    $0x2,%eax
80100f34:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f3a:	83 c0 04             	add    $0x4,%eax
80100f3d:	c1 e0 02             	shl    $0x2,%eax
80100f40:	50                   	push   %eax
80100f41:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f47:	50                   	push   %eax
80100f48:	ff 75 dc             	pushl  -0x24(%ebp)
80100f4b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4e:	e8 08 76 00 00       	call   8010855b <copyout>
80100f53:	83 c4 10             	add    $0x10,%esp
80100f56:	85 c0                	test   %eax,%eax
80100f58:	0f 88 d5 00 00 00    	js     80101033 <exec+0x49d>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80100f61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f67:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f6a:	eb 17                	jmp    80100f83 <exec+0x3ed>
    if(*s == '/')
80100f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f6f:	0f b6 00             	movzbl (%eax),%eax
80100f72:	3c 2f                	cmp    $0x2f,%al
80100f74:	75 09                	jne    80100f7f <exec+0x3e9>
      last = s+1;
80100f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f79:	83 c0 01             	add    $0x1,%eax
80100f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f86:	0f b6 00             	movzbl (%eax),%eax
80100f89:	84 c0                	test   %al,%al
80100f8b:	75 df                	jne    80100f6c <exec+0x3d6>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f90:	83 c0 6c             	add    $0x6c,%eax
80100f93:	83 ec 04             	sub    $0x4,%esp
80100f96:	6a 10                	push   $0x10
80100f98:	ff 75 f0             	pushl  -0x10(%ebp)
80100f9b:	50                   	push   %eax
80100f9c:	e8 1c 45 00 00       	call   801054bd <safestrcpy>
80100fa1:	83 c4 10             	add    $0x10,%esp

 
 
  // Commit to the user image.
  cprintf("SP: %x\n", sp);
80100fa4:	83 ec 08             	sub    $0x8,%esp
80100fa7:	ff 75 dc             	pushl  -0x24(%ebp)
80100faa:	68 50 87 10 80       	push   $0x80108750
80100faf:	e8 4c f4 ff ff       	call   80100400 <cprintf>
80100fb4:	83 c4 10             	add    $0x10,%esp
//  cprintf("DIFFERENCE: %d\n", curproc->last_page-sp);
  oldpgdir = curproc->pgdir;
80100fb7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fba:	8b 40 04             	mov    0x4(%eax),%eax
80100fbd:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100fc0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fc3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fc6:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fc9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fcf:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fd4:	8b 40 18             	mov    0x18(%eax),%eax
80100fd7:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fdd:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100fe0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe3:	8b 40 18             	mov    0x18(%eax),%eax
80100fe6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fe9:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fec:	83 ec 0c             	sub    $0xc,%esp
80100fef:	ff 75 d0             	pushl  -0x30(%ebp)
80100ff2:	e8 59 6d 00 00       	call   80107d50 <switchuvm>
80100ff7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ffa:	83 ec 0c             	sub    $0xc,%esp
80100ffd:	ff 75 cc             	pushl  -0x34(%ebp)
80101000:	e8 28 72 00 00       	call   8010822d <freevm>
80101005:	83 c4 10             	add    $0x10,%esp
  return 0;
80101008:	b8 00 00 00 00       	mov    $0x0,%eax
8010100d:	eb 57                	jmp    80101066 <exec+0x4d0>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
8010100f:	90                   	nop
80101010:	eb 22                	jmp    80101034 <exec+0x49e>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101012:	90                   	nop
80101013:	eb 1f                	jmp    80101034 <exec+0x49e>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80101015:	90                   	nop
80101016:	eb 1c                	jmp    80101034 <exec+0x49e>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101018:	90                   	nop
80101019:	eb 19                	jmp    80101034 <exec+0x49e>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010101b:	90                   	nop
8010101c:	eb 16                	jmp    80101034 <exec+0x49e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
8010101e:	90                   	nop
8010101f:	eb 13                	jmp    80101034 <exec+0x49e>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101021:	90                   	nop
80101022:	eb 10                	jmp    80101034 <exec+0x49e>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
80101024:	90                   	nop
80101025:	eb 0d                	jmp    80101034 <exec+0x49e>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101027:	90                   	nop
80101028:	eb 0a                	jmp    80101034 <exec+0x49e>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;
8010102a:	90                   	nop
8010102b:	eb 07                	jmp    80101034 <exec+0x49e>
   sp = curproc->last_page;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
8010102d:	90                   	nop
8010102e:	eb 04                	jmp    80101034 <exec+0x49e>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101030:	90                   	nop
80101031:	eb 01                	jmp    80101034 <exec+0x49e>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101033:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101034:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101038:	74 0e                	je     80101048 <exec+0x4b2>
    freevm(pgdir);
8010103a:	83 ec 0c             	sub    $0xc,%esp
8010103d:	ff 75 d4             	pushl  -0x2c(%ebp)
80101040:	e8 e8 71 00 00       	call   8010822d <freevm>
80101045:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101048:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010104c:	74 13                	je     80101061 <exec+0x4cb>
    iunlockput(ip);
8010104e:	83 ec 0c             	sub    $0xc,%esp
80101051:	ff 75 d8             	pushl  -0x28(%ebp)
80101054:	e8 7b 0c 00 00       	call   80101cd4 <iunlockput>
80101059:	83 c4 10             	add    $0x10,%esp
    end_op();
8010105c:	e8 f3 25 00 00       	call   80103654 <end_op>
  }
  return -1;
80101061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101066:	c9                   	leave  
80101067:	c3                   	ret    

80101068 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101068:	55                   	push   %ebp
80101069:	89 e5                	mov    %esp,%ebp
8010106b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010106e:	83 ec 08             	sub    $0x8,%esp
80101071:	68 58 87 10 80       	push   $0x80108758
80101076:	68 40 10 11 80       	push   $0x80111040
8010107b:	e8 a1 3f 00 00       	call   80105021 <initlock>
80101080:	83 c4 10             	add    $0x10,%esp
}
80101083:	90                   	nop
80101084:	c9                   	leave  
80101085:	c3                   	ret    

80101086 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101086:	55                   	push   %ebp
80101087:	89 e5                	mov    %esp,%ebp
80101089:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010108c:	83 ec 0c             	sub    $0xc,%esp
8010108f:	68 40 10 11 80       	push   $0x80111040
80101094:	e8 aa 3f 00 00       	call   80105043 <acquire>
80101099:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010109c:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
801010a3:	eb 2d                	jmp    801010d2 <filealloc+0x4c>
    if(f->ref == 0){
801010a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a8:	8b 40 04             	mov    0x4(%eax),%eax
801010ab:	85 c0                	test   %eax,%eax
801010ad:	75 1f                	jne    801010ce <filealloc+0x48>
      f->ref = 1;
801010af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010b2:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010b9:	83 ec 0c             	sub    $0xc,%esp
801010bc:	68 40 10 11 80       	push   $0x80111040
801010c1:	e8 eb 3f 00 00       	call   801050b1 <release>
801010c6:	83 c4 10             	add    $0x10,%esp
      return f;
801010c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010cc:	eb 23                	jmp    801010f1 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010ce:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010d2:	b8 d4 19 11 80       	mov    $0x801119d4,%eax
801010d7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010da:	72 c9                	jb     801010a5 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801010dc:	83 ec 0c             	sub    $0xc,%esp
801010df:	68 40 10 11 80       	push   $0x80111040
801010e4:	e8 c8 3f 00 00       	call   801050b1 <release>
801010e9:	83 c4 10             	add    $0x10,%esp
  return 0;
801010ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010f3:	55                   	push   %ebp
801010f4:	89 e5                	mov    %esp,%ebp
801010f6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010f9:	83 ec 0c             	sub    $0xc,%esp
801010fc:	68 40 10 11 80       	push   $0x80111040
80101101:	e8 3d 3f 00 00       	call   80105043 <acquire>
80101106:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	8b 40 04             	mov    0x4(%eax),%eax
8010110f:	85 c0                	test   %eax,%eax
80101111:	7f 0d                	jg     80101120 <filedup+0x2d>
    panic("filedup");
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	68 5f 87 10 80       	push   $0x8010875f
8010111b:	e8 80 f4 ff ff       	call   801005a0 <panic>
  f->ref++;
80101120:	8b 45 08             	mov    0x8(%ebp),%eax
80101123:	8b 40 04             	mov    0x4(%eax),%eax
80101126:	8d 50 01             	lea    0x1(%eax),%edx
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 40 10 11 80       	push   $0x80111040
80101137:	e8 75 3f 00 00       	call   801050b1 <release>
8010113c:	83 c4 10             	add    $0x10,%esp
  return f;
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101142:	c9                   	leave  
80101143:	c3                   	ret    

80101144 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101144:	55                   	push   %ebp
80101145:	89 e5                	mov    %esp,%ebp
80101147:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010114a:	83 ec 0c             	sub    $0xc,%esp
8010114d:	68 40 10 11 80       	push   $0x80111040
80101152:	e8 ec 3e 00 00       	call   80105043 <acquire>
80101157:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010115a:	8b 45 08             	mov    0x8(%ebp),%eax
8010115d:	8b 40 04             	mov    0x4(%eax),%eax
80101160:	85 c0                	test   %eax,%eax
80101162:	7f 0d                	jg     80101171 <fileclose+0x2d>
    panic("fileclose");
80101164:	83 ec 0c             	sub    $0xc,%esp
80101167:	68 67 87 10 80       	push   $0x80108767
8010116c:	e8 2f f4 ff ff       	call   801005a0 <panic>
  if(--f->ref > 0){
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 40 04             	mov    0x4(%eax),%eax
80101177:	8d 50 ff             	lea    -0x1(%eax),%edx
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	89 50 04             	mov    %edx,0x4(%eax)
80101180:	8b 45 08             	mov    0x8(%ebp),%eax
80101183:	8b 40 04             	mov    0x4(%eax),%eax
80101186:	85 c0                	test   %eax,%eax
80101188:	7e 15                	jle    8010119f <fileclose+0x5b>
    release(&ftable.lock);
8010118a:	83 ec 0c             	sub    $0xc,%esp
8010118d:	68 40 10 11 80       	push   $0x80111040
80101192:	e8 1a 3f 00 00       	call   801050b1 <release>
80101197:	83 c4 10             	add    $0x10,%esp
8010119a:	e9 8b 00 00 00       	jmp    8010122a <fileclose+0xe6>
    return;
  }
  ff = *f;
8010119f:	8b 45 08             	mov    0x8(%ebp),%eax
801011a2:	8b 10                	mov    (%eax),%edx
801011a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011a7:	8b 50 04             	mov    0x4(%eax),%edx
801011aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011ad:	8b 50 08             	mov    0x8(%eax),%edx
801011b0:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011b3:	8b 50 0c             	mov    0xc(%eax),%edx
801011b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011b9:	8b 50 10             	mov    0x10(%eax),%edx
801011bc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011bf:	8b 40 14             	mov    0x14(%eax),%eax
801011c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011c5:	8b 45 08             	mov    0x8(%ebp),%eax
801011c8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011cf:	8b 45 08             	mov    0x8(%ebp),%eax
801011d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011d8:	83 ec 0c             	sub    $0xc,%esp
801011db:	68 40 10 11 80       	push   $0x80111040
801011e0:	e8 cc 3e 00 00       	call   801050b1 <release>
801011e5:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011eb:	83 f8 01             	cmp    $0x1,%eax
801011ee:	75 19                	jne    80101209 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011f0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011f4:	0f be d0             	movsbl %al,%edx
801011f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011fa:	83 ec 08             	sub    $0x8,%esp
801011fd:	52                   	push   %edx
801011fe:	50                   	push   %eax
801011ff:	e8 a6 2d 00 00       	call   80103faa <pipeclose>
80101204:	83 c4 10             	add    $0x10,%esp
80101207:	eb 21                	jmp    8010122a <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101209:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010120c:	83 f8 02             	cmp    $0x2,%eax
8010120f:	75 19                	jne    8010122a <fileclose+0xe6>
    begin_op();
80101211:	e8 b2 23 00 00       	call   801035c8 <begin_op>
    iput(ff.ip);
80101216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101219:	83 ec 0c             	sub    $0xc,%esp
8010121c:	50                   	push   %eax
8010121d:	e8 e2 09 00 00       	call   80101c04 <iput>
80101222:	83 c4 10             	add    $0x10,%esp
    end_op();
80101225:	e8 2a 24 00 00       	call   80103654 <end_op>
  }
}
8010122a:	c9                   	leave  
8010122b:	c3                   	ret    

8010122c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010122c:	55                   	push   %ebp
8010122d:	89 e5                	mov    %esp,%ebp
8010122f:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101232:	8b 45 08             	mov    0x8(%ebp),%eax
80101235:	8b 00                	mov    (%eax),%eax
80101237:	83 f8 02             	cmp    $0x2,%eax
8010123a:	75 40                	jne    8010127c <filestat+0x50>
    ilock(f->ip);
8010123c:	8b 45 08             	mov    0x8(%ebp),%eax
8010123f:	8b 40 10             	mov    0x10(%eax),%eax
80101242:	83 ec 0c             	sub    $0xc,%esp
80101245:	50                   	push   %eax
80101246:	e8 58 08 00 00       	call   80101aa3 <ilock>
8010124b:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	8b 40 10             	mov    0x10(%eax),%eax
80101254:	83 ec 08             	sub    $0x8,%esp
80101257:	ff 75 0c             	pushl  0xc(%ebp)
8010125a:	50                   	push   %eax
8010125b:	e8 ee 0c 00 00       	call   80101f4e <stati>
80101260:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 40 10             	mov    0x10(%eax),%eax
80101269:	83 ec 0c             	sub    $0xc,%esp
8010126c:	50                   	push   %eax
8010126d:	e8 44 09 00 00       	call   80101bb6 <iunlock>
80101272:	83 c4 10             	add    $0x10,%esp
    return 0;
80101275:	b8 00 00 00 00       	mov    $0x0,%eax
8010127a:	eb 05                	jmp    80101281 <filestat+0x55>
  }
  return -1;
8010127c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101281:	c9                   	leave  
80101282:	c3                   	ret    

80101283 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101283:	55                   	push   %ebp
80101284:	89 e5                	mov    %esp,%ebp
80101286:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101289:	8b 45 08             	mov    0x8(%ebp),%eax
8010128c:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101290:	84 c0                	test   %al,%al
80101292:	75 0a                	jne    8010129e <fileread+0x1b>
    return -1;
80101294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101299:	e9 9b 00 00 00       	jmp    80101339 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010129e:	8b 45 08             	mov    0x8(%ebp),%eax
801012a1:	8b 00                	mov    (%eax),%eax
801012a3:	83 f8 01             	cmp    $0x1,%eax
801012a6:	75 1a                	jne    801012c2 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 40 0c             	mov    0xc(%eax),%eax
801012ae:	83 ec 04             	sub    $0x4,%esp
801012b1:	ff 75 10             	pushl  0x10(%ebp)
801012b4:	ff 75 0c             	pushl  0xc(%ebp)
801012b7:	50                   	push   %eax
801012b8:	e8 94 2e 00 00       	call   80104151 <piperead>
801012bd:	83 c4 10             	add    $0x10,%esp
801012c0:	eb 77                	jmp    80101339 <fileread+0xb6>
  if(f->type == FD_INODE){
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 00                	mov    (%eax),%eax
801012c7:	83 f8 02             	cmp    $0x2,%eax
801012ca:	75 60                	jne    8010132c <fileread+0xa9>
    ilock(f->ip);
801012cc:	8b 45 08             	mov    0x8(%ebp),%eax
801012cf:	8b 40 10             	mov    0x10(%eax),%eax
801012d2:	83 ec 0c             	sub    $0xc,%esp
801012d5:	50                   	push   %eax
801012d6:	e8 c8 07 00 00       	call   80101aa3 <ilock>
801012db:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012de:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012e1:	8b 45 08             	mov    0x8(%ebp),%eax
801012e4:	8b 50 14             	mov    0x14(%eax),%edx
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8b 40 10             	mov    0x10(%eax),%eax
801012ed:	51                   	push   %ecx
801012ee:	52                   	push   %edx
801012ef:	ff 75 0c             	pushl  0xc(%ebp)
801012f2:	50                   	push   %eax
801012f3:	e8 9c 0c 00 00       	call   80101f94 <readi>
801012f8:	83 c4 10             	add    $0x10,%esp
801012fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101302:	7e 11                	jle    80101315 <fileread+0x92>
      f->off += r;
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	8b 50 14             	mov    0x14(%eax),%edx
8010130a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010130d:	01 c2                	add    %eax,%edx
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101315:	8b 45 08             	mov    0x8(%ebp),%eax
80101318:	8b 40 10             	mov    0x10(%eax),%eax
8010131b:	83 ec 0c             	sub    $0xc,%esp
8010131e:	50                   	push   %eax
8010131f:	e8 92 08 00 00       	call   80101bb6 <iunlock>
80101324:	83 c4 10             	add    $0x10,%esp
    return r;
80101327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132a:	eb 0d                	jmp    80101339 <fileread+0xb6>
  }
  panic("fileread");
8010132c:	83 ec 0c             	sub    $0xc,%esp
8010132f:	68 71 87 10 80       	push   $0x80108771
80101334:	e8 67 f2 ff ff       	call   801005a0 <panic>
}
80101339:	c9                   	leave  
8010133a:	c3                   	ret    

8010133b <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010133b:	55                   	push   %ebp
8010133c:	89 e5                	mov    %esp,%ebp
8010133e:	53                   	push   %ebx
8010133f:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101349:	84 c0                	test   %al,%al
8010134b:	75 0a                	jne    80101357 <filewrite+0x1c>
    return -1;
8010134d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101352:	e9 1b 01 00 00       	jmp    80101472 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	8b 00                	mov    (%eax),%eax
8010135c:	83 f8 01             	cmp    $0x1,%eax
8010135f:	75 1d                	jne    8010137e <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 0c             	mov    0xc(%eax),%eax
80101367:	83 ec 04             	sub    $0x4,%esp
8010136a:	ff 75 10             	pushl  0x10(%ebp)
8010136d:	ff 75 0c             	pushl  0xc(%ebp)
80101370:	50                   	push   %eax
80101371:	e8 de 2c 00 00       	call   80104054 <pipewrite>
80101376:	83 c4 10             	add    $0x10,%esp
80101379:	e9 f4 00 00 00       	jmp    80101472 <filewrite+0x137>
  if(f->type == FD_INODE){
8010137e:	8b 45 08             	mov    0x8(%ebp),%eax
80101381:	8b 00                	mov    (%eax),%eax
80101383:	83 f8 02             	cmp    $0x2,%eax
80101386:	0f 85 d9 00 00 00    	jne    80101465 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010138c:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101393:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010139a:	e9 a3 00 00 00       	jmp    80101442 <filewrite+0x107>
      int n1 = n - i;
8010139f:	8b 45 10             	mov    0x10(%ebp),%eax
801013a2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013ae:	7e 06                	jle    801013b6 <filewrite+0x7b>
        n1 = max;
801013b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013b3:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013b6:	e8 0d 22 00 00       	call   801035c8 <begin_op>
      ilock(f->ip);
801013bb:	8b 45 08             	mov    0x8(%ebp),%eax
801013be:	8b 40 10             	mov    0x10(%eax),%eax
801013c1:	83 ec 0c             	sub    $0xc,%esp
801013c4:	50                   	push   %eax
801013c5:	e8 d9 06 00 00       	call   80101aa3 <ilock>
801013ca:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013cd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013d0:	8b 45 08             	mov    0x8(%ebp),%eax
801013d3:	8b 50 14             	mov    0x14(%eax),%edx
801013d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801013dc:	01 c3                	add    %eax,%ebx
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	8b 40 10             	mov    0x10(%eax),%eax
801013e4:	51                   	push   %ecx
801013e5:	52                   	push   %edx
801013e6:	53                   	push   %ebx
801013e7:	50                   	push   %eax
801013e8:	e8 fe 0c 00 00       	call   801020eb <writei>
801013ed:	83 c4 10             	add    $0x10,%esp
801013f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013f7:	7e 11                	jle    8010140a <filewrite+0xcf>
        f->off += r;
801013f9:	8b 45 08             	mov    0x8(%ebp),%eax
801013fc:	8b 50 14             	mov    0x14(%eax),%edx
801013ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101402:	01 c2                	add    %eax,%edx
80101404:	8b 45 08             	mov    0x8(%ebp),%eax
80101407:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010140a:	8b 45 08             	mov    0x8(%ebp),%eax
8010140d:	8b 40 10             	mov    0x10(%eax),%eax
80101410:	83 ec 0c             	sub    $0xc,%esp
80101413:	50                   	push   %eax
80101414:	e8 9d 07 00 00       	call   80101bb6 <iunlock>
80101419:	83 c4 10             	add    $0x10,%esp
      end_op();
8010141c:	e8 33 22 00 00       	call   80103654 <end_op>

      if(r < 0)
80101421:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101425:	78 29                	js     80101450 <filewrite+0x115>
        break;
      if(r != n1)
80101427:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010142a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010142d:	74 0d                	je     8010143c <filewrite+0x101>
        panic("short filewrite");
8010142f:	83 ec 0c             	sub    $0xc,%esp
80101432:	68 7a 87 10 80       	push   $0x8010877a
80101437:	e8 64 f1 ff ff       	call   801005a0 <panic>
      i += r;
8010143c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010143f:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101445:	3b 45 10             	cmp    0x10(%ebp),%eax
80101448:	0f 8c 51 ff ff ff    	jl     8010139f <filewrite+0x64>
8010144e:	eb 01                	jmp    80101451 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101450:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101454:	3b 45 10             	cmp    0x10(%ebp),%eax
80101457:	75 05                	jne    8010145e <filewrite+0x123>
80101459:	8b 45 10             	mov    0x10(%ebp),%eax
8010145c:	eb 14                	jmp    80101472 <filewrite+0x137>
8010145e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101463:	eb 0d                	jmp    80101472 <filewrite+0x137>
  }
  panic("filewrite");
80101465:	83 ec 0c             	sub    $0xc,%esp
80101468:	68 8a 87 10 80       	push   $0x8010878a
8010146d:	e8 2e f1 ff ff       	call   801005a0 <panic>
}
80101472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101475:	c9                   	leave  
80101476:	c3                   	ret    

80101477 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101477:	55                   	push   %ebp
80101478:	89 e5                	mov    %esp,%ebp
8010147a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010147d:	8b 45 08             	mov    0x8(%ebp),%eax
80101480:	83 ec 08             	sub    $0x8,%esp
80101483:	6a 01                	push   $0x1
80101485:	50                   	push   %eax
80101486:	e8 43 ed ff ff       	call   801001ce <bread>
8010148b:	83 c4 10             	add    $0x10,%esp
8010148e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101494:	83 c0 5c             	add    $0x5c,%eax
80101497:	83 ec 04             	sub    $0x4,%esp
8010149a:	6a 1c                	push   $0x1c
8010149c:	50                   	push   %eax
8010149d:	ff 75 0c             	pushl  0xc(%ebp)
801014a0:	e8 d4 3e 00 00       	call   80105379 <memmove>
801014a5:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014a8:	83 ec 0c             	sub    $0xc,%esp
801014ab:	ff 75 f4             	pushl  -0xc(%ebp)
801014ae:	e8 9d ed ff ff       	call   80100250 <brelse>
801014b3:	83 c4 10             	add    $0x10,%esp
}
801014b6:	90                   	nop
801014b7:	c9                   	leave  
801014b8:	c3                   	ret    

801014b9 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014b9:	55                   	push   %ebp
801014ba:	89 e5                	mov    %esp,%ebp
801014bc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801014c2:	8b 45 08             	mov    0x8(%ebp),%eax
801014c5:	83 ec 08             	sub    $0x8,%esp
801014c8:	52                   	push   %edx
801014c9:	50                   	push   %eax
801014ca:	e8 ff ec ff ff       	call   801001ce <bread>
801014cf:	83 c4 10             	add    $0x10,%esp
801014d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d8:	83 c0 5c             	add    $0x5c,%eax
801014db:	83 ec 04             	sub    $0x4,%esp
801014de:	68 00 02 00 00       	push   $0x200
801014e3:	6a 00                	push   $0x0
801014e5:	50                   	push   %eax
801014e6:	e8 cf 3d 00 00       	call   801052ba <memset>
801014eb:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ee:	83 ec 0c             	sub    $0xc,%esp
801014f1:	ff 75 f4             	pushl  -0xc(%ebp)
801014f4:	e8 07 23 00 00       	call   80103800 <log_write>
801014f9:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014fc:	83 ec 0c             	sub    $0xc,%esp
801014ff:	ff 75 f4             	pushl  -0xc(%ebp)
80101502:	e8 49 ed ff ff       	call   80100250 <brelse>
80101507:	83 c4 10             	add    $0x10,%esp
}
8010150a:	90                   	nop
8010150b:	c9                   	leave  
8010150c:	c3                   	ret    

8010150d <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010150d:	55                   	push   %ebp
8010150e:	89 e5                	mov    %esp,%ebp
80101510:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101513:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010151a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101521:	e9 13 01 00 00       	jmp    80101639 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101529:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010152f:	85 c0                	test   %eax,%eax
80101531:	0f 48 c2             	cmovs  %edx,%eax
80101534:	c1 f8 0c             	sar    $0xc,%eax
80101537:	89 c2                	mov    %eax,%edx
80101539:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010153e:	01 d0                	add    %edx,%eax
80101540:	83 ec 08             	sub    $0x8,%esp
80101543:	50                   	push   %eax
80101544:	ff 75 08             	pushl  0x8(%ebp)
80101547:	e8 82 ec ff ff       	call   801001ce <bread>
8010154c:	83 c4 10             	add    $0x10,%esp
8010154f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101552:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101559:	e9 a6 00 00 00       	jmp    80101604 <balloc+0xf7>
      m = 1 << (bi % 8);
8010155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101561:	99                   	cltd   
80101562:	c1 ea 1d             	shr    $0x1d,%edx
80101565:	01 d0                	add    %edx,%eax
80101567:	83 e0 07             	and    $0x7,%eax
8010156a:	29 d0                	sub    %edx,%eax
8010156c:	ba 01 00 00 00       	mov    $0x1,%edx
80101571:	89 c1                	mov    %eax,%ecx
80101573:	d3 e2                	shl    %cl,%edx
80101575:	89 d0                	mov    %edx,%eax
80101577:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157d:	8d 50 07             	lea    0x7(%eax),%edx
80101580:	85 c0                	test   %eax,%eax
80101582:	0f 48 c2             	cmovs  %edx,%eax
80101585:	c1 f8 03             	sar    $0x3,%eax
80101588:	89 c2                	mov    %eax,%edx
8010158a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010158d:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101592:	0f b6 c0             	movzbl %al,%eax
80101595:	23 45 e8             	and    -0x18(%ebp),%eax
80101598:	85 c0                	test   %eax,%eax
8010159a:	75 64                	jne    80101600 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159f:	8d 50 07             	lea    0x7(%eax),%edx
801015a2:	85 c0                	test   %eax,%eax
801015a4:	0f 48 c2             	cmovs  %edx,%eax
801015a7:	c1 f8 03             	sar    $0x3,%eax
801015aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ad:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015b2:	89 d1                	mov    %edx,%ecx
801015b4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015b7:	09 ca                	or     %ecx,%edx
801015b9:	89 d1                	mov    %edx,%ecx
801015bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015be:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015c2:	83 ec 0c             	sub    $0xc,%esp
801015c5:	ff 75 ec             	pushl  -0x14(%ebp)
801015c8:	e8 33 22 00 00       	call   80103800 <log_write>
801015cd:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015d0:	83 ec 0c             	sub    $0xc,%esp
801015d3:	ff 75 ec             	pushl  -0x14(%ebp)
801015d6:	e8 75 ec ff ff       	call   80100250 <brelse>
801015db:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e4:	01 c2                	add    %eax,%edx
801015e6:	8b 45 08             	mov    0x8(%ebp),%eax
801015e9:	83 ec 08             	sub    $0x8,%esp
801015ec:	52                   	push   %edx
801015ed:	50                   	push   %eax
801015ee:	e8 c6 fe ff ff       	call   801014b9 <bzero>
801015f3:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fc:	01 d0                	add    %edx,%eax
801015fe:	eb 57                	jmp    80101657 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101600:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101604:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010160b:	7f 17                	jg     80101624 <balloc+0x117>
8010160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	01 d0                	add    %edx,%eax
80101615:	89 c2                	mov    %eax,%edx
80101617:	a1 40 1a 11 80       	mov    0x80111a40,%eax
8010161c:	39 c2                	cmp    %eax,%edx
8010161e:	0f 82 3a ff ff ff    	jb     8010155e <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	ff 75 ec             	pushl  -0x14(%ebp)
8010162a:	e8 21 ec ff ff       	call   80100250 <brelse>
8010162f:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101632:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101639:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
8010163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101642:	39 c2                	cmp    %eax,%edx
80101644:	0f 87 dc fe ff ff    	ja     80101526 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010164a:	83 ec 0c             	sub    $0xc,%esp
8010164d:	68 94 87 10 80       	push   $0x80108794
80101652:	e8 49 ef ff ff       	call   801005a0 <panic>
}
80101657:	c9                   	leave  
80101658:	c3                   	ret    

80101659 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101659:	55                   	push   %ebp
8010165a:	89 e5                	mov    %esp,%ebp
8010165c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010165f:	83 ec 08             	sub    $0x8,%esp
80101662:	68 40 1a 11 80       	push   $0x80111a40
80101667:	ff 75 08             	pushl  0x8(%ebp)
8010166a:	e8 08 fe ff ff       	call   80101477 <readsb>
8010166f:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101672:	8b 45 0c             	mov    0xc(%ebp),%eax
80101675:	c1 e8 0c             	shr    $0xc,%eax
80101678:	89 c2                	mov    %eax,%edx
8010167a:	a1 58 1a 11 80       	mov    0x80111a58,%eax
8010167f:	01 c2                	add    %eax,%edx
80101681:	8b 45 08             	mov    0x8(%ebp),%eax
80101684:	83 ec 08             	sub    $0x8,%esp
80101687:	52                   	push   %edx
80101688:	50                   	push   %eax
80101689:	e8 40 eb ff ff       	call   801001ce <bread>
8010168e:	83 c4 10             	add    $0x10,%esp
80101691:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101694:	8b 45 0c             	mov    0xc(%ebp),%eax
80101697:	25 ff 0f 00 00       	and    $0xfff,%eax
8010169c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a2:	99                   	cltd   
801016a3:	c1 ea 1d             	shr    $0x1d,%edx
801016a6:	01 d0                	add    %edx,%eax
801016a8:	83 e0 07             	and    $0x7,%eax
801016ab:	29 d0                	sub    %edx,%eax
801016ad:	ba 01 00 00 00       	mov    $0x1,%edx
801016b2:	89 c1                	mov    %eax,%ecx
801016b4:	d3 e2                	shl    %cl,%edx
801016b6:	89 d0                	mov    %edx,%eax
801016b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016be:	8d 50 07             	lea    0x7(%eax),%edx
801016c1:	85 c0                	test   %eax,%eax
801016c3:	0f 48 c2             	cmovs  %edx,%eax
801016c6:	c1 f8 03             	sar    $0x3,%eax
801016c9:	89 c2                	mov    %eax,%edx
801016cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ce:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016d3:	0f b6 c0             	movzbl %al,%eax
801016d6:	23 45 ec             	and    -0x14(%ebp),%eax
801016d9:	85 c0                	test   %eax,%eax
801016db:	75 0d                	jne    801016ea <bfree+0x91>
    panic("freeing free block");
801016dd:	83 ec 0c             	sub    $0xc,%esp
801016e0:	68 aa 87 10 80       	push   $0x801087aa
801016e5:	e8 b6 ee ff ff       	call   801005a0 <panic>
  bp->data[bi/8] &= ~m;
801016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ed:	8d 50 07             	lea    0x7(%eax),%edx
801016f0:	85 c0                	test   %eax,%eax
801016f2:	0f 48 c2             	cmovs  %edx,%eax
801016f5:	c1 f8 03             	sar    $0x3,%eax
801016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016fb:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101700:	89 d1                	mov    %edx,%ecx
80101702:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101705:	f7 d2                	not    %edx
80101707:	21 ca                	and    %ecx,%edx
80101709:	89 d1                	mov    %edx,%ecx
8010170b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010170e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101712:	83 ec 0c             	sub    $0xc,%esp
80101715:	ff 75 f4             	pushl  -0xc(%ebp)
80101718:	e8 e3 20 00 00       	call   80103800 <log_write>
8010171d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101720:	83 ec 0c             	sub    $0xc,%esp
80101723:	ff 75 f4             	pushl  -0xc(%ebp)
80101726:	e8 25 eb ff ff       	call   80100250 <brelse>
8010172b:	83 c4 10             	add    $0x10,%esp
}
8010172e:	90                   	nop
8010172f:	c9                   	leave  
80101730:	c3                   	ret    

80101731 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101731:	55                   	push   %ebp
80101732:	89 e5                	mov    %esp,%ebp
80101734:	57                   	push   %edi
80101735:	56                   	push   %esi
80101736:	53                   	push   %ebx
80101737:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010173a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101741:	83 ec 08             	sub    $0x8,%esp
80101744:	68 bd 87 10 80       	push   $0x801087bd
80101749:	68 60 1a 11 80       	push   $0x80111a60
8010174e:	e8 ce 38 00 00       	call   80105021 <initlock>
80101753:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101756:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010175d:	eb 2d                	jmp    8010178c <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
8010175f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101762:	89 d0                	mov    %edx,%eax
80101764:	c1 e0 03             	shl    $0x3,%eax
80101767:	01 d0                	add    %edx,%eax
80101769:	c1 e0 04             	shl    $0x4,%eax
8010176c:	83 c0 30             	add    $0x30,%eax
8010176f:	05 60 1a 11 80       	add    $0x80111a60,%eax
80101774:	83 c0 10             	add    $0x10,%eax
80101777:	83 ec 08             	sub    $0x8,%esp
8010177a:	68 c4 87 10 80       	push   $0x801087c4
8010177f:	50                   	push   %eax
80101780:	e8 3f 37 00 00       	call   80104ec4 <initsleeplock>
80101785:	83 c4 10             	add    $0x10,%esp
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101788:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010178c:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101790:	7e cd                	jle    8010175f <iinit+0x2e>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101792:	83 ec 08             	sub    $0x8,%esp
80101795:	68 40 1a 11 80       	push   $0x80111a40
8010179a:	ff 75 08             	pushl  0x8(%ebp)
8010179d:	e8 d5 fc ff ff       	call   80101477 <readsb>
801017a2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017a5:	a1 58 1a 11 80       	mov    0x80111a58,%eax
801017aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017ad:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
801017b3:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
801017b9:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
801017bf:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
801017c5:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
801017cb:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801017d0:	ff 75 d4             	pushl  -0x2c(%ebp)
801017d3:	57                   	push   %edi
801017d4:	56                   	push   %esi
801017d5:	53                   	push   %ebx
801017d6:	51                   	push   %ecx
801017d7:	52                   	push   %edx
801017d8:	50                   	push   %eax
801017d9:	68 cc 87 10 80       	push   $0x801087cc
801017de:	e8 1d ec ff ff       	call   80100400 <cprintf>
801017e3:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017e6:	90                   	nop
801017e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017ea:	5b                   	pop    %ebx
801017eb:	5e                   	pop    %esi
801017ec:	5f                   	pop    %edi
801017ed:	5d                   	pop    %ebp
801017ee:	c3                   	ret    

801017ef <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017ef:	55                   	push   %ebp
801017f0:	89 e5                	mov    %esp,%ebp
801017f2:	83 ec 28             	sub    $0x28,%esp
801017f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801017f8:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017fc:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101803:	e9 9e 00 00 00       	jmp    801018a6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	c1 e8 03             	shr    $0x3,%eax
8010180e:	89 c2                	mov    %eax,%edx
80101810:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101815:	01 d0                	add    %edx,%eax
80101817:	83 ec 08             	sub    $0x8,%esp
8010181a:	50                   	push   %eax
8010181b:	ff 75 08             	pushl  0x8(%ebp)
8010181e:	e8 ab e9 ff ff       	call   801001ce <bread>
80101823:	83 c4 10             	add    $0x10,%esp
80101826:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010182c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101832:	83 e0 07             	and    $0x7,%eax
80101835:	c1 e0 06             	shl    $0x6,%eax
80101838:	01 d0                	add    %edx,%eax
8010183a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010183d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101840:	0f b7 00             	movzwl (%eax),%eax
80101843:	66 85 c0             	test   %ax,%ax
80101846:	75 4c                	jne    80101894 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101848:	83 ec 04             	sub    $0x4,%esp
8010184b:	6a 40                	push   $0x40
8010184d:	6a 00                	push   $0x0
8010184f:	ff 75 ec             	pushl  -0x14(%ebp)
80101852:	e8 63 3a 00 00       	call   801052ba <memset>
80101857:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010185a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010185d:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101861:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101864:	83 ec 0c             	sub    $0xc,%esp
80101867:	ff 75 f0             	pushl  -0x10(%ebp)
8010186a:	e8 91 1f 00 00       	call   80103800 <log_write>
8010186f:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101872:	83 ec 0c             	sub    $0xc,%esp
80101875:	ff 75 f0             	pushl  -0x10(%ebp)
80101878:	e8 d3 e9 ff ff       	call   80100250 <brelse>
8010187d:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101883:	83 ec 08             	sub    $0x8,%esp
80101886:	50                   	push   %eax
80101887:	ff 75 08             	pushl  0x8(%ebp)
8010188a:	e8 f8 00 00 00       	call   80101987 <iget>
8010188f:	83 c4 10             	add    $0x10,%esp
80101892:	eb 30                	jmp    801018c4 <ialloc+0xd5>
    }
    brelse(bp);
80101894:	83 ec 0c             	sub    $0xc,%esp
80101897:	ff 75 f0             	pushl  -0x10(%ebp)
8010189a:	e8 b1 e9 ff ff       	call   80100250 <brelse>
8010189f:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018a6:	8b 15 48 1a 11 80    	mov    0x80111a48,%edx
801018ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018af:	39 c2                	cmp    %eax,%edx
801018b1:	0f 87 51 ff ff ff    	ja     80101808 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	68 1f 88 10 80       	push   $0x8010881f
801018bf:	e8 dc ec ff ff       	call   801005a0 <panic>
}
801018c4:	c9                   	leave  
801018c5:	c3                   	ret    

801018c6 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018c6:	55                   	push   %ebp
801018c7:	89 e5                	mov    %esp,%ebp
801018c9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018cc:	8b 45 08             	mov    0x8(%ebp),%eax
801018cf:	8b 40 04             	mov    0x4(%eax),%eax
801018d2:	c1 e8 03             	shr    $0x3,%eax
801018d5:	89 c2                	mov    %eax,%edx
801018d7:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801018dc:	01 c2                	add    %eax,%edx
801018de:	8b 45 08             	mov    0x8(%ebp),%eax
801018e1:	8b 00                	mov    (%eax),%eax
801018e3:	83 ec 08             	sub    $0x8,%esp
801018e6:	52                   	push   %edx
801018e7:	50                   	push   %eax
801018e8:	e8 e1 e8 ff ff       	call   801001ce <bread>
801018ed:	83 c4 10             	add    $0x10,%esp
801018f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f6:	8d 50 5c             	lea    0x5c(%eax),%edx
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8b 40 04             	mov    0x4(%eax),%eax
801018ff:	83 e0 07             	and    $0x7,%eax
80101902:	c1 e0 06             	shl    $0x6,%eax
80101905:	01 d0                	add    %edx,%eax
80101907:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010190a:	8b 45 08             	mov    0x8(%ebp),%eax
8010190d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101914:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101921:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101925:	8b 45 08             	mov    0x8(%ebp),%eax
80101928:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010192c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192f:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101933:	8b 45 08             	mov    0x8(%ebp),%eax
80101936:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193d:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	8b 50 58             	mov    0x58(%eax),%edx
80101947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194a:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	8d 50 5c             	lea    0x5c(%eax),%edx
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	83 c0 0c             	add    $0xc,%eax
80101959:	83 ec 04             	sub    $0x4,%esp
8010195c:	6a 34                	push   $0x34
8010195e:	52                   	push   %edx
8010195f:	50                   	push   %eax
80101960:	e8 14 3a 00 00       	call   80105379 <memmove>
80101965:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101968:	83 ec 0c             	sub    $0xc,%esp
8010196b:	ff 75 f4             	pushl  -0xc(%ebp)
8010196e:	e8 8d 1e 00 00       	call   80103800 <log_write>
80101973:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101976:	83 ec 0c             	sub    $0xc,%esp
80101979:	ff 75 f4             	pushl  -0xc(%ebp)
8010197c:	e8 cf e8 ff ff       	call   80100250 <brelse>
80101981:	83 c4 10             	add    $0x10,%esp
}
80101984:	90                   	nop
80101985:	c9                   	leave  
80101986:	c3                   	ret    

80101987 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101987:	55                   	push   %ebp
80101988:	89 e5                	mov    %esp,%ebp
8010198a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010198d:	83 ec 0c             	sub    $0xc,%esp
80101990:	68 60 1a 11 80       	push   $0x80111a60
80101995:	e8 a9 36 00 00       	call   80105043 <acquire>
8010199a:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010199d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019a4:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
801019ab:	eb 60                	jmp    80101a0d <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b0:	8b 40 08             	mov    0x8(%eax),%eax
801019b3:	85 c0                	test   %eax,%eax
801019b5:	7e 39                	jle    801019f0 <iget+0x69>
801019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ba:	8b 00                	mov    (%eax),%eax
801019bc:	3b 45 08             	cmp    0x8(%ebp),%eax
801019bf:	75 2f                	jne    801019f0 <iget+0x69>
801019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c4:	8b 40 04             	mov    0x4(%eax),%eax
801019c7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801019ca:	75 24                	jne    801019f0 <iget+0x69>
      ip->ref++;
801019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cf:	8b 40 08             	mov    0x8(%eax),%eax
801019d2:	8d 50 01             	lea    0x1(%eax),%edx
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019db:	83 ec 0c             	sub    $0xc,%esp
801019de:	68 60 1a 11 80       	push   $0x80111a60
801019e3:	e8 c9 36 00 00       	call   801050b1 <release>
801019e8:	83 c4 10             	add    $0x10,%esp
      return ip;
801019eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ee:	eb 77                	jmp    80101a67 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019f4:	75 10                	jne    80101a06 <iget+0x7f>
801019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	75 06                	jne    80101a06 <iget+0x7f>
      empty = ip;
80101a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a03:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a06:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a0d:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
80101a14:	72 97                	jb     801019ad <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a1a:	75 0d                	jne    80101a29 <iget+0xa2>
    panic("iget: no inodes");
80101a1c:	83 ec 0c             	sub    $0xc,%esp
80101a1f:	68 31 88 10 80       	push   $0x80108831
80101a24:	e8 77 eb ff ff       	call   801005a0 <panic>

  ip = empty;
80101a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a32:	8b 55 08             	mov    0x8(%ebp),%edx
80101a35:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a3d:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a43:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4d:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a54:	83 ec 0c             	sub    $0xc,%esp
80101a57:	68 60 1a 11 80       	push   $0x80111a60
80101a5c:	e8 50 36 00 00       	call   801050b1 <release>
80101a61:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a67:	c9                   	leave  
80101a68:	c3                   	ret    

80101a69 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a69:	55                   	push   %ebp
80101a6a:	89 e5                	mov    %esp,%ebp
80101a6c:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a6f:	83 ec 0c             	sub    $0xc,%esp
80101a72:	68 60 1a 11 80       	push   $0x80111a60
80101a77:	e8 c7 35 00 00       	call   80105043 <acquire>
80101a7c:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	8b 40 08             	mov    0x8(%eax),%eax
80101a85:	8d 50 01             	lea    0x1(%eax),%edx
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a8e:	83 ec 0c             	sub    $0xc,%esp
80101a91:	68 60 1a 11 80       	push   $0x80111a60
80101a96:	e8 16 36 00 00       	call   801050b1 <release>
80101a9b:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101aa1:	c9                   	leave  
80101aa2:	c3                   	ret    

80101aa3 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101aa3:	55                   	push   %ebp
80101aa4:	89 e5                	mov    %esp,%ebp
80101aa6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101aa9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aad:	74 0a                	je     80101ab9 <ilock+0x16>
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	8b 40 08             	mov    0x8(%eax),%eax
80101ab5:	85 c0                	test   %eax,%eax
80101ab7:	7f 0d                	jg     80101ac6 <ilock+0x23>
    panic("ilock");
80101ab9:	83 ec 0c             	sub    $0xc,%esp
80101abc:	68 41 88 10 80       	push   $0x80108841
80101ac1:	e8 da ea ff ff       	call   801005a0 <panic>

  acquiresleep(&ip->lock);
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	83 c0 0c             	add    $0xc,%eax
80101acc:	83 ec 0c             	sub    $0xc,%esp
80101acf:	50                   	push   %eax
80101ad0:	e8 2b 34 00 00       	call   80104f00 <acquiresleep>
80101ad5:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ade:	85 c0                	test   %eax,%eax
80101ae0:	0f 85 cd 00 00 00    	jne    80101bb3 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae9:	8b 40 04             	mov    0x4(%eax),%eax
80101aec:	c1 e8 03             	shr    $0x3,%eax
80101aef:	89 c2                	mov    %eax,%edx
80101af1:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101af6:	01 c2                	add    %eax,%edx
80101af8:	8b 45 08             	mov    0x8(%ebp),%eax
80101afb:	8b 00                	mov    (%eax),%eax
80101afd:	83 ec 08             	sub    $0x8,%esp
80101b00:	52                   	push   %edx
80101b01:	50                   	push   %eax
80101b02:	e8 c7 e6 ff ff       	call   801001ce <bread>
80101b07:	83 c4 10             	add    $0x10,%esp
80101b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b10:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	8b 40 04             	mov    0x4(%eax),%eax
80101b19:	83 e0 07             	and    $0x7,%eax
80101b1c:	c1 e0 06             	shl    $0x6,%eax
80101b1f:	01 d0                	add    %edx,%eax
80101b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b27:	0f b7 10             	movzwl (%eax),%edx
80101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2d:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b34:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b38:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3b:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b42:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b46:	8b 45 08             	mov    0x8(%ebp),%eax
80101b49:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b50:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b54:	8b 45 08             	mov    0x8(%ebp),%eax
80101b57:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5e:	8b 50 08             	mov    0x8(%eax),%edx
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b6a:	8d 50 0c             	lea    0xc(%eax),%edx
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	83 c0 5c             	add    $0x5c,%eax
80101b73:	83 ec 04             	sub    $0x4,%esp
80101b76:	6a 34                	push   $0x34
80101b78:	52                   	push   %edx
80101b79:	50                   	push   %eax
80101b7a:	e8 fa 37 00 00       	call   80105379 <memmove>
80101b7f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b82:	83 ec 0c             	sub    $0xc,%esp
80101b85:	ff 75 f4             	pushl  -0xc(%ebp)
80101b88:	e8 c3 e6 ff ff       	call   80100250 <brelse>
80101b8d:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b90:	8b 45 08             	mov    0x8(%ebp),%eax
80101b93:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ba1:	66 85 c0             	test   %ax,%ax
80101ba4:	75 0d                	jne    80101bb3 <ilock+0x110>
      panic("ilock: no type");
80101ba6:	83 ec 0c             	sub    $0xc,%esp
80101ba9:	68 47 88 10 80       	push   $0x80108847
80101bae:	e8 ed e9 ff ff       	call   801005a0 <panic>
  }
}
80101bb3:	90                   	nop
80101bb4:	c9                   	leave  
80101bb5:	c3                   	ret    

80101bb6 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bb6:	55                   	push   %ebp
80101bb7:	89 e5                	mov    %esp,%ebp
80101bb9:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bbc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bc0:	74 20                	je     80101be2 <iunlock+0x2c>
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	83 c0 0c             	add    $0xc,%eax
80101bc8:	83 ec 0c             	sub    $0xc,%esp
80101bcb:	50                   	push   %eax
80101bcc:	e8 e1 33 00 00       	call   80104fb2 <holdingsleep>
80101bd1:	83 c4 10             	add    $0x10,%esp
80101bd4:	85 c0                	test   %eax,%eax
80101bd6:	74 0a                	je     80101be2 <iunlock+0x2c>
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	8b 40 08             	mov    0x8(%eax),%eax
80101bde:	85 c0                	test   %eax,%eax
80101be0:	7f 0d                	jg     80101bef <iunlock+0x39>
    panic("iunlock");
80101be2:	83 ec 0c             	sub    $0xc,%esp
80101be5:	68 56 88 10 80       	push   $0x80108856
80101bea:	e8 b1 e9 ff ff       	call   801005a0 <panic>

  releasesleep(&ip->lock);
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	83 c0 0c             	add    $0xc,%eax
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	50                   	push   %eax
80101bf9:	e8 66 33 00 00       	call   80104f64 <releasesleep>
80101bfe:	83 c4 10             	add    $0x10,%esp
}
80101c01:	90                   	nop
80101c02:	c9                   	leave  
80101c03:	c3                   	ret    

80101c04 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c04:	55                   	push   %ebp
80101c05:	89 e5                	mov    %esp,%ebp
80101c07:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	83 c0 0c             	add    $0xc,%eax
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	50                   	push   %eax
80101c14:	e8 e7 32 00 00       	call   80104f00 <acquiresleep>
80101c19:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1f:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c22:	85 c0                	test   %eax,%eax
80101c24:	74 6a                	je     80101c90 <iput+0x8c>
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c2d:	66 85 c0             	test   %ax,%ax
80101c30:	75 5e                	jne    80101c90 <iput+0x8c>
    acquire(&icache.lock);
80101c32:	83 ec 0c             	sub    $0xc,%esp
80101c35:	68 60 1a 11 80       	push   $0x80111a60
80101c3a:	e8 04 34 00 00       	call   80105043 <acquire>
80101c3f:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 40 08             	mov    0x8(%eax),%eax
80101c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4b:	83 ec 0c             	sub    $0xc,%esp
80101c4e:	68 60 1a 11 80       	push   $0x80111a60
80101c53:	e8 59 34 00 00       	call   801050b1 <release>
80101c58:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c5b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c5f:	75 2f                	jne    80101c90 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c61:	83 ec 0c             	sub    $0xc,%esp
80101c64:	ff 75 08             	pushl  0x8(%ebp)
80101c67:	e8 b2 01 00 00       	call   80101e1e <itrunc>
80101c6c:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c72:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c78:	83 ec 0c             	sub    $0xc,%esp
80101c7b:	ff 75 08             	pushl  0x8(%ebp)
80101c7e:	e8 43 fc ff ff       	call   801018c6 <iupdate>
80101c83:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	83 c0 0c             	add    $0xc,%eax
80101c96:	83 ec 0c             	sub    $0xc,%esp
80101c99:	50                   	push   %eax
80101c9a:	e8 c5 32 00 00       	call   80104f64 <releasesleep>
80101c9f:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101ca2:	83 ec 0c             	sub    $0xc,%esp
80101ca5:	68 60 1a 11 80       	push   $0x80111a60
80101caa:	e8 94 33 00 00       	call   80105043 <acquire>
80101caf:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	8b 40 08             	mov    0x8(%eax),%eax
80101cb8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cc1:	83 ec 0c             	sub    $0xc,%esp
80101cc4:	68 60 1a 11 80       	push   $0x80111a60
80101cc9:	e8 e3 33 00 00       	call   801050b1 <release>
80101cce:	83 c4 10             	add    $0x10,%esp
}
80101cd1:	90                   	nop
80101cd2:	c9                   	leave  
80101cd3:	c3                   	ret    

80101cd4 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cd4:	55                   	push   %ebp
80101cd5:	89 e5                	mov    %esp,%ebp
80101cd7:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cda:	83 ec 0c             	sub    $0xc,%esp
80101cdd:	ff 75 08             	pushl  0x8(%ebp)
80101ce0:	e8 d1 fe ff ff       	call   80101bb6 <iunlock>
80101ce5:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ce8:	83 ec 0c             	sub    $0xc,%esp
80101ceb:	ff 75 08             	pushl  0x8(%ebp)
80101cee:	e8 11 ff ff ff       	call   80101c04 <iput>
80101cf3:	83 c4 10             	add    $0x10,%esp
}
80101cf6:	90                   	nop
80101cf7:	c9                   	leave  
80101cf8:	c3                   	ret    

80101cf9 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cf9:	55                   	push   %ebp
80101cfa:	89 e5                	mov    %esp,%ebp
80101cfc:	53                   	push   %ebx
80101cfd:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d00:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d04:	77 42                	ja     80101d48 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d0c:	83 c2 14             	add    $0x14,%edx
80101d0f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d1a:	75 24                	jne    80101d40 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 00                	mov    (%eax),%eax
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	50                   	push   %eax
80101d25:	e8 e3 f7 ff ff       	call   8010150d <balloc>
80101d2a:	83 c4 10             	add    $0x10,%esp
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d36:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d43:	e9 d1 00 00 00       	jmp    80101e19 <bmap+0x120>
  }
  bn -= NDIRECT;
80101d48:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d50:	0f 87 b6 00 00 00    	ja     80101e0c <bmap+0x113>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d66:	75 20                	jne    80101d88 <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 00                	mov    (%eax),%eax
80101d6d:	83 ec 0c             	sub    $0xc,%esp
80101d70:	50                   	push   %eax
80101d71:	e8 97 f7 ff ff       	call   8010150d <balloc>
80101d76:	83 c4 10             	add    $0x10,%esp
80101d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d82:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 00                	mov    (%eax),%eax
80101d8d:	83 ec 08             	sub    $0x8,%esp
80101d90:	ff 75 f4             	pushl  -0xc(%ebp)
80101d93:	50                   	push   %eax
80101d94:	e8 35 e4 ff ff       	call   801001ce <bread>
80101d99:	83 c4 10             	add    $0x10,%esp
80101d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da2:	83 c0 5c             	add    $0x5c,%eax
80101da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101da8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101db2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101db5:	01 d0                	add    %edx,%eax
80101db7:	8b 00                	mov    (%eax),%eax
80101db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dc0:	75 37                	jne    80101df9 <bmap+0x100>
      a[bn] = addr = balloc(ip->dev);
80101dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcf:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 00                	mov    (%eax),%eax
80101dd7:	83 ec 0c             	sub    $0xc,%esp
80101dda:	50                   	push   %eax
80101ddb:	e8 2d f7 ff ff       	call   8010150d <balloc>
80101de0:	83 c4 10             	add    $0x10,%esp
80101de3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de9:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101deb:	83 ec 0c             	sub    $0xc,%esp
80101dee:	ff 75 f0             	pushl  -0x10(%ebp)
80101df1:	e8 0a 1a 00 00       	call   80103800 <log_write>
80101df6:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101df9:	83 ec 0c             	sub    $0xc,%esp
80101dfc:	ff 75 f0             	pushl  -0x10(%ebp)
80101dff:	e8 4c e4 ff ff       	call   80100250 <brelse>
80101e04:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e0a:	eb 0d                	jmp    80101e19 <bmap+0x120>
  }

  panic("bmap: out of range");
80101e0c:	83 ec 0c             	sub    $0xc,%esp
80101e0f:	68 5e 88 10 80       	push   $0x8010885e
80101e14:	e8 87 e7 ff ff       	call   801005a0 <panic>
}
80101e19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e1c:	c9                   	leave  
80101e1d:	c3                   	ret    

80101e1e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e1e:	55                   	push   %ebp
80101e1f:	89 e5                	mov    %esp,%ebp
80101e21:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e2b:	eb 45                	jmp    80101e72 <itrunc+0x54>
    if(ip->addrs[i]){
80101e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e30:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e33:	83 c2 14             	add    $0x14,%edx
80101e36:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e3a:	85 c0                	test   %eax,%eax
80101e3c:	74 30                	je     80101e6e <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e44:	83 c2 14             	add    $0x14,%edx
80101e47:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e4b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4e:	8b 12                	mov    (%edx),%edx
80101e50:	83 ec 08             	sub    $0x8,%esp
80101e53:	50                   	push   %eax
80101e54:	52                   	push   %edx
80101e55:	e8 ff f7 ff ff       	call   80101659 <bfree>
80101e5a:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e63:	83 c2 14             	add    $0x14,%edx
80101e66:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e6d:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e72:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e76:	7e b5                	jle    80101e2d <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e78:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e81:	85 c0                	test   %eax,%eax
80101e83:	0f 84 aa 00 00 00    	je     80101f33 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e89:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8c:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e92:	8b 45 08             	mov    0x8(%ebp),%eax
80101e95:	8b 00                	mov    (%eax),%eax
80101e97:	83 ec 08             	sub    $0x8,%esp
80101e9a:	52                   	push   %edx
80101e9b:	50                   	push   %eax
80101e9c:	e8 2d e3 ff ff       	call   801001ce <bread>
80101ea1:	83 c4 10             	add    $0x10,%esp
80101ea4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ea7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eaa:	83 c0 5c             	add    $0x5c,%eax
80101ead:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101eb0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eb7:	eb 3c                	jmp    80101ef5 <itrunc+0xd7>
      if(a[j])
80101eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec6:	01 d0                	add    %edx,%eax
80101ec8:	8b 00                	mov    (%eax),%eax
80101eca:	85 c0                	test   %eax,%eax
80101ecc:	74 23                	je     80101ef1 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101edb:	01 d0                	add    %edx,%eax
80101edd:	8b 00                	mov    (%eax),%eax
80101edf:	8b 55 08             	mov    0x8(%ebp),%edx
80101ee2:	8b 12                	mov    (%edx),%edx
80101ee4:	83 ec 08             	sub    $0x8,%esp
80101ee7:	50                   	push   %eax
80101ee8:	52                   	push   %edx
80101ee9:	e8 6b f7 ff ff       	call   80101659 <bfree>
80101eee:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ef1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef8:	83 f8 7f             	cmp    $0x7f,%eax
80101efb:	76 bc                	jbe    80101eb9 <itrunc+0x9b>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101efd:	83 ec 0c             	sub    $0xc,%esp
80101f00:	ff 75 ec             	pushl  -0x14(%ebp)
80101f03:	e8 48 e3 ff ff       	call   80100250 <brelse>
80101f08:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f14:	8b 55 08             	mov    0x8(%ebp),%edx
80101f17:	8b 12                	mov    (%edx),%edx
80101f19:	83 ec 08             	sub    $0x8,%esp
80101f1c:	50                   	push   %eax
80101f1d:	52                   	push   %edx
80101f1e:	e8 36 f7 ff ff       	call   80101659 <bfree>
80101f23:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f26:	8b 45 08             	mov    0x8(%ebp),%eax
80101f29:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f30:	00 00 00 
  }

  ip->size = 0;
80101f33:	8b 45 08             	mov    0x8(%ebp),%eax
80101f36:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f3d:	83 ec 0c             	sub    $0xc,%esp
80101f40:	ff 75 08             	pushl  0x8(%ebp)
80101f43:	e8 7e f9 ff ff       	call   801018c6 <iupdate>
80101f48:	83 c4 10             	add    $0x10,%esp
}
80101f4b:	90                   	nop
80101f4c:	c9                   	leave  
80101f4d:	c3                   	ret    

80101f4e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f4e:	55                   	push   %ebp
80101f4f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	8b 00                	mov    (%eax),%eax
80101f56:	89 c2                	mov    %eax,%edx
80101f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	8b 50 04             	mov    0x4(%eax),%edx
80101f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f67:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f71:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f74:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f81:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f85:	8b 45 08             	mov    0x8(%ebp),%eax
80101f88:	8b 50 58             	mov    0x58(%eax),%edx
80101f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f8e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f91:	90                   	nop
80101f92:	5d                   	pop    %ebp
80101f93:	c3                   	ret    

80101f94 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f94:	55                   	push   %ebp
80101f95:	89 e5                	mov    %esp,%ebp
80101f97:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101fa1:	66 83 f8 03          	cmp    $0x3,%ax
80101fa5:	75 5c                	jne    80102003 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	66 85 c0             	test   %ax,%ax
80101fb1:	78 20                	js     80101fd3 <readi+0x3f>
80101fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fba:	66 83 f8 09          	cmp    $0x9,%ax
80101fbe:	7f 13                	jg     80101fd3 <readi+0x3f>
80101fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fc7:	98                   	cwtl   
80101fc8:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101fcf:	85 c0                	test   %eax,%eax
80101fd1:	75 0a                	jne    80101fdd <readi+0x49>
      return -1;
80101fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fd8:	e9 0c 01 00 00       	jmp    801020e9 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fe4:	98                   	cwtl   
80101fe5:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101fec:	8b 55 14             	mov    0x14(%ebp),%edx
80101fef:	83 ec 04             	sub    $0x4,%esp
80101ff2:	52                   	push   %edx
80101ff3:	ff 75 0c             	pushl  0xc(%ebp)
80101ff6:	ff 75 08             	pushl  0x8(%ebp)
80101ff9:	ff d0                	call   *%eax
80101ffb:	83 c4 10             	add    $0x10,%esp
80101ffe:	e9 e6 00 00 00       	jmp    801020e9 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102003:	8b 45 08             	mov    0x8(%ebp),%eax
80102006:	8b 40 58             	mov    0x58(%eax),%eax
80102009:	3b 45 10             	cmp    0x10(%ebp),%eax
8010200c:	72 0d                	jb     8010201b <readi+0x87>
8010200e:	8b 55 10             	mov    0x10(%ebp),%edx
80102011:	8b 45 14             	mov    0x14(%ebp),%eax
80102014:	01 d0                	add    %edx,%eax
80102016:	3b 45 10             	cmp    0x10(%ebp),%eax
80102019:	73 0a                	jae    80102025 <readi+0x91>
    return -1;
8010201b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102020:	e9 c4 00 00 00       	jmp    801020e9 <readi+0x155>
  if(off + n > ip->size)
80102025:	8b 55 10             	mov    0x10(%ebp),%edx
80102028:	8b 45 14             	mov    0x14(%ebp),%eax
8010202b:	01 c2                	add    %eax,%edx
8010202d:	8b 45 08             	mov    0x8(%ebp),%eax
80102030:	8b 40 58             	mov    0x58(%eax),%eax
80102033:	39 c2                	cmp    %eax,%edx
80102035:	76 0c                	jbe    80102043 <readi+0xaf>
    n = ip->size - off;
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 58             	mov    0x58(%eax),%eax
8010203d:	2b 45 10             	sub    0x10(%ebp),%eax
80102040:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102043:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010204a:	e9 8b 00 00 00       	jmp    801020da <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010204f:	8b 45 10             	mov    0x10(%ebp),%eax
80102052:	c1 e8 09             	shr    $0x9,%eax
80102055:	83 ec 08             	sub    $0x8,%esp
80102058:	50                   	push   %eax
80102059:	ff 75 08             	pushl  0x8(%ebp)
8010205c:	e8 98 fc ff ff       	call   80101cf9 <bmap>
80102061:	83 c4 10             	add    $0x10,%esp
80102064:	89 c2                	mov    %eax,%edx
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	8b 00                	mov    (%eax),%eax
8010206b:	83 ec 08             	sub    $0x8,%esp
8010206e:	52                   	push   %edx
8010206f:	50                   	push   %eax
80102070:	e8 59 e1 ff ff       	call   801001ce <bread>
80102075:	83 c4 10             	add    $0x10,%esp
80102078:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010207b:	8b 45 10             	mov    0x10(%ebp),%eax
8010207e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102083:	ba 00 02 00 00       	mov    $0x200,%edx
80102088:	29 c2                	sub    %eax,%edx
8010208a:	8b 45 14             	mov    0x14(%ebp),%eax
8010208d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102090:	39 c2                	cmp    %eax,%edx
80102092:	0f 46 c2             	cmovbe %edx,%eax
80102095:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010209b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010209e:	8b 45 10             	mov    0x10(%ebp),%eax
801020a1:	25 ff 01 00 00       	and    $0x1ff,%eax
801020a6:	01 d0                	add    %edx,%eax
801020a8:	83 ec 04             	sub    $0x4,%esp
801020ab:	ff 75 ec             	pushl  -0x14(%ebp)
801020ae:	50                   	push   %eax
801020af:	ff 75 0c             	pushl  0xc(%ebp)
801020b2:	e8 c2 32 00 00       	call   80105379 <memmove>
801020b7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ba:	83 ec 0c             	sub    $0xc,%esp
801020bd:	ff 75 f0             	pushl  -0x10(%ebp)
801020c0:	e8 8b e1 ff ff       	call   80100250 <brelse>
801020c5:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020cb:	01 45 f4             	add    %eax,-0xc(%ebp)
801020ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d1:	01 45 10             	add    %eax,0x10(%ebp)
801020d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d7:	01 45 0c             	add    %eax,0xc(%ebp)
801020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020dd:	3b 45 14             	cmp    0x14(%ebp),%eax
801020e0:	0f 82 69 ff ff ff    	jb     8010204f <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020e6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020e9:	c9                   	leave  
801020ea:	c3                   	ret    

801020eb <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020eb:	55                   	push   %ebp
801020ec:	89 e5                	mov    %esp,%ebp
801020ee:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020f1:	8b 45 08             	mov    0x8(%ebp),%eax
801020f4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020f8:	66 83 f8 03          	cmp    $0x3,%ax
801020fc:	75 5c                	jne    8010215a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102101:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102105:	66 85 c0             	test   %ax,%ax
80102108:	78 20                	js     8010212a <writei+0x3f>
8010210a:	8b 45 08             	mov    0x8(%ebp),%eax
8010210d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102111:	66 83 f8 09          	cmp    $0x9,%ax
80102115:	7f 13                	jg     8010212a <writei+0x3f>
80102117:	8b 45 08             	mov    0x8(%ebp),%eax
8010211a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010211e:	98                   	cwtl   
8010211f:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80102126:	85 c0                	test   %eax,%eax
80102128:	75 0a                	jne    80102134 <writei+0x49>
      return -1;
8010212a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010212f:	e9 3d 01 00 00       	jmp    80102271 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102134:	8b 45 08             	mov    0x8(%ebp),%eax
80102137:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010213b:	98                   	cwtl   
8010213c:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80102143:	8b 55 14             	mov    0x14(%ebp),%edx
80102146:	83 ec 04             	sub    $0x4,%esp
80102149:	52                   	push   %edx
8010214a:	ff 75 0c             	pushl  0xc(%ebp)
8010214d:	ff 75 08             	pushl  0x8(%ebp)
80102150:	ff d0                	call   *%eax
80102152:	83 c4 10             	add    $0x10,%esp
80102155:	e9 17 01 00 00       	jmp    80102271 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010215a:	8b 45 08             	mov    0x8(%ebp),%eax
8010215d:	8b 40 58             	mov    0x58(%eax),%eax
80102160:	3b 45 10             	cmp    0x10(%ebp),%eax
80102163:	72 0d                	jb     80102172 <writei+0x87>
80102165:	8b 55 10             	mov    0x10(%ebp),%edx
80102168:	8b 45 14             	mov    0x14(%ebp),%eax
8010216b:	01 d0                	add    %edx,%eax
8010216d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102170:	73 0a                	jae    8010217c <writei+0x91>
    return -1;
80102172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102177:	e9 f5 00 00 00       	jmp    80102271 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010217c:	8b 55 10             	mov    0x10(%ebp),%edx
8010217f:	8b 45 14             	mov    0x14(%ebp),%eax
80102182:	01 d0                	add    %edx,%eax
80102184:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102189:	76 0a                	jbe    80102195 <writei+0xaa>
    return -1;
8010218b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102190:	e9 dc 00 00 00       	jmp    80102271 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010219c:	e9 99 00 00 00       	jmp    8010223a <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021a1:	8b 45 10             	mov    0x10(%ebp),%eax
801021a4:	c1 e8 09             	shr    $0x9,%eax
801021a7:	83 ec 08             	sub    $0x8,%esp
801021aa:	50                   	push   %eax
801021ab:	ff 75 08             	pushl  0x8(%ebp)
801021ae:	e8 46 fb ff ff       	call   80101cf9 <bmap>
801021b3:	83 c4 10             	add    $0x10,%esp
801021b6:	89 c2                	mov    %eax,%edx
801021b8:	8b 45 08             	mov    0x8(%ebp),%eax
801021bb:	8b 00                	mov    (%eax),%eax
801021bd:	83 ec 08             	sub    $0x8,%esp
801021c0:	52                   	push   %edx
801021c1:	50                   	push   %eax
801021c2:	e8 07 e0 ff ff       	call   801001ce <bread>
801021c7:	83 c4 10             	add    $0x10,%esp
801021ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021cd:	8b 45 10             	mov    0x10(%ebp),%eax
801021d0:	25 ff 01 00 00       	and    $0x1ff,%eax
801021d5:	ba 00 02 00 00       	mov    $0x200,%edx
801021da:	29 c2                	sub    %eax,%edx
801021dc:	8b 45 14             	mov    0x14(%ebp),%eax
801021df:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021e2:	39 c2                	cmp    %eax,%edx
801021e4:	0f 46 c2             	cmovbe %edx,%eax
801021e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ed:	8d 50 5c             	lea    0x5c(%eax),%edx
801021f0:	8b 45 10             	mov    0x10(%ebp),%eax
801021f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801021f8:	01 d0                	add    %edx,%eax
801021fa:	83 ec 04             	sub    $0x4,%esp
801021fd:	ff 75 ec             	pushl  -0x14(%ebp)
80102200:	ff 75 0c             	pushl  0xc(%ebp)
80102203:	50                   	push   %eax
80102204:	e8 70 31 00 00       	call   80105379 <memmove>
80102209:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010220c:	83 ec 0c             	sub    $0xc,%esp
8010220f:	ff 75 f0             	pushl  -0x10(%ebp)
80102212:	e8 e9 15 00 00       	call   80103800 <log_write>
80102217:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010221a:	83 ec 0c             	sub    $0xc,%esp
8010221d:	ff 75 f0             	pushl  -0x10(%ebp)
80102220:	e8 2b e0 ff ff       	call   80100250 <brelse>
80102225:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102228:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010222e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102231:	01 45 10             	add    %eax,0x10(%ebp)
80102234:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102237:	01 45 0c             	add    %eax,0xc(%ebp)
8010223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010223d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102240:	0f 82 5b ff ff ff    	jb     801021a1 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102246:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010224a:	74 22                	je     8010226e <writei+0x183>
8010224c:	8b 45 08             	mov    0x8(%ebp),%eax
8010224f:	8b 40 58             	mov    0x58(%eax),%eax
80102252:	3b 45 10             	cmp    0x10(%ebp),%eax
80102255:	73 17                	jae    8010226e <writei+0x183>
    ip->size = off;
80102257:	8b 45 08             	mov    0x8(%ebp),%eax
8010225a:	8b 55 10             	mov    0x10(%ebp),%edx
8010225d:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102260:	83 ec 0c             	sub    $0xc,%esp
80102263:	ff 75 08             	pushl  0x8(%ebp)
80102266:	e8 5b f6 ff ff       	call   801018c6 <iupdate>
8010226b:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010226e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102271:	c9                   	leave  
80102272:	c3                   	ret    

80102273 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102273:	55                   	push   %ebp
80102274:	89 e5                	mov    %esp,%ebp
80102276:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102279:	83 ec 04             	sub    $0x4,%esp
8010227c:	6a 0e                	push   $0xe
8010227e:	ff 75 0c             	pushl  0xc(%ebp)
80102281:	ff 75 08             	pushl  0x8(%ebp)
80102284:	e8 86 31 00 00       	call   8010540f <strncmp>
80102289:	83 c4 10             	add    $0x10,%esp
}
8010228c:	c9                   	leave  
8010228d:	c3                   	ret    

8010228e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102294:	8b 45 08             	mov    0x8(%ebp),%eax
80102297:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010229b:	66 83 f8 01          	cmp    $0x1,%ax
8010229f:	74 0d                	je     801022ae <dirlookup+0x20>
    panic("dirlookup not DIR");
801022a1:	83 ec 0c             	sub    $0xc,%esp
801022a4:	68 71 88 10 80       	push   $0x80108871
801022a9:	e8 f2 e2 ff ff       	call   801005a0 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b5:	eb 7b                	jmp    80102332 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b7:	6a 10                	push   $0x10
801022b9:	ff 75 f4             	pushl  -0xc(%ebp)
801022bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bf:	50                   	push   %eax
801022c0:	ff 75 08             	pushl  0x8(%ebp)
801022c3:	e8 cc fc ff ff       	call   80101f94 <readi>
801022c8:	83 c4 10             	add    $0x10,%esp
801022cb:	83 f8 10             	cmp    $0x10,%eax
801022ce:	74 0d                	je     801022dd <dirlookup+0x4f>
      panic("dirlookup read");
801022d0:	83 ec 0c             	sub    $0xc,%esp
801022d3:	68 83 88 10 80       	push   $0x80108883
801022d8:	e8 c3 e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
801022dd:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022e1:	66 85 c0             	test   %ax,%ax
801022e4:	74 47                	je     8010232d <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022e6:	83 ec 08             	sub    $0x8,%esp
801022e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ec:	83 c0 02             	add    $0x2,%eax
801022ef:	50                   	push   %eax
801022f0:	ff 75 0c             	pushl  0xc(%ebp)
801022f3:	e8 7b ff ff ff       	call   80102273 <namecmp>
801022f8:	83 c4 10             	add    $0x10,%esp
801022fb:	85 c0                	test   %eax,%eax
801022fd:	75 2f                	jne    8010232e <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102303:	74 08                	je     8010230d <dirlookup+0x7f>
        *poff = off;
80102305:	8b 45 10             	mov    0x10(%ebp),%eax
80102308:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010230b:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010230d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102311:	0f b7 c0             	movzwl %ax,%eax
80102314:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102317:	8b 45 08             	mov    0x8(%ebp),%eax
8010231a:	8b 00                	mov    (%eax),%eax
8010231c:	83 ec 08             	sub    $0x8,%esp
8010231f:	ff 75 f0             	pushl  -0x10(%ebp)
80102322:	50                   	push   %eax
80102323:	e8 5f f6 ff ff       	call   80101987 <iget>
80102328:	83 c4 10             	add    $0x10,%esp
8010232b:	eb 19                	jmp    80102346 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
8010232d:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010232e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102332:	8b 45 08             	mov    0x8(%ebp),%eax
80102335:	8b 40 58             	mov    0x58(%eax),%eax
80102338:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010233b:	0f 87 76 ff ff ff    	ja     801022b7 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102341:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102346:	c9                   	leave  
80102347:	c3                   	ret    

80102348 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 00                	push   $0x0
80102353:	ff 75 0c             	pushl  0xc(%ebp)
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 30 ff ff ff       	call   8010228e <dirlookup>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102368:	74 18                	je     80102382 <dirlink+0x3a>
    iput(ip);
8010236a:	83 ec 0c             	sub    $0xc,%esp
8010236d:	ff 75 f0             	pushl  -0x10(%ebp)
80102370:	e8 8f f8 ff ff       	call   80101c04 <iput>
80102375:	83 c4 10             	add    $0x10,%esp
    return -1;
80102378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237d:	e9 9c 00 00 00       	jmp    8010241e <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102389:	eb 39                	jmp    801023c4 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	6a 10                	push   $0x10
80102390:	50                   	push   %eax
80102391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102394:	50                   	push   %eax
80102395:	ff 75 08             	pushl  0x8(%ebp)
80102398:	e8 f7 fb ff ff       	call   80101f94 <readi>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	83 f8 10             	cmp    $0x10,%eax
801023a3:	74 0d                	je     801023b2 <dirlink+0x6a>
      panic("dirlink read");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 92 88 10 80       	push   $0x80108892
801023ad:	e8 ee e1 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
801023b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b6:	66 85 c0             	test   %ax,%ax
801023b9:	74 18                	je     801023d3 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	83 c0 10             	add    $0x10,%eax
801023c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 50 58             	mov    0x58(%eax),%edx
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	39 c2                	cmp    %eax,%edx
801023cf:	77 ba                	ja     8010238b <dirlink+0x43>
801023d1:	eb 01                	jmp    801023d4 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 0c             	pushl  0xc(%ebp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	50                   	push   %eax
801023e3:	e8 7d 30 00 00       	call   80105465 <strncpy>
801023e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023eb:	8b 45 10             	mov    0x10(%ebp),%eax
801023ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	6a 10                	push   $0x10
801023f7:	50                   	push   %eax
801023f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fb:	50                   	push   %eax
801023fc:	ff 75 08             	pushl  0x8(%ebp)
801023ff:	e8 e7 fc ff ff       	call   801020eb <writei>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	83 f8 10             	cmp    $0x10,%eax
8010240a:	74 0d                	je     80102419 <dirlink+0xd1>
    panic("dirlink");
8010240c:	83 ec 0c             	sub    $0xc,%esp
8010240f:	68 9f 88 10 80       	push   $0x8010889f
80102414:	e8 87 e1 ff ff       	call   801005a0 <panic>

  return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241e:	c9                   	leave  
8010241f:	c3                   	ret    

80102420 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102420:	55                   	push   %ebp
80102421:	89 e5                	mov    %esp,%ebp
80102423:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102426:	eb 04                	jmp    8010242c <skipelem+0xc>
    path++;
80102428:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010242c:	8b 45 08             	mov    0x8(%ebp),%eax
8010242f:	0f b6 00             	movzbl (%eax),%eax
80102432:	3c 2f                	cmp    $0x2f,%al
80102434:	74 f2                	je     80102428 <skipelem+0x8>
    path++;
  if(*path == 0)
80102436:	8b 45 08             	mov    0x8(%ebp),%eax
80102439:	0f b6 00             	movzbl (%eax),%eax
8010243c:	84 c0                	test   %al,%al
8010243e:	75 07                	jne    80102447 <skipelem+0x27>
    return 0;
80102440:	b8 00 00 00 00       	mov    $0x0,%eax
80102445:	eb 7b                	jmp    801024c2 <skipelem+0xa2>
  s = path;
80102447:	8b 45 08             	mov    0x8(%ebp),%eax
8010244a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010244d:	eb 04                	jmp    80102453 <skipelem+0x33>
    path++;
8010244f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	0f b6 00             	movzbl (%eax),%eax
80102459:	3c 2f                	cmp    $0x2f,%al
8010245b:	74 0a                	je     80102467 <skipelem+0x47>
8010245d:	8b 45 08             	mov    0x8(%ebp),%eax
80102460:	0f b6 00             	movzbl (%eax),%eax
80102463:	84 c0                	test   %al,%al
80102465:	75 e8                	jne    8010244f <skipelem+0x2f>
    path++;
  len = path - s;
80102467:	8b 55 08             	mov    0x8(%ebp),%edx
8010246a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246d:	29 c2                	sub    %eax,%edx
8010246f:	89 d0                	mov    %edx,%eax
80102471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102474:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102478:	7e 15                	jle    8010248f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	ff 75 0c             	pushl  0xc(%ebp)
80102485:	e8 ef 2e 00 00       	call   80105379 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 d8 2e 00 00       	call   80105379 <memmove>
801024a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024aa:	01 d0                	add    %edx,%eax
801024ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024af:	eb 04                	jmp    801024b5 <skipelem+0x95>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 f2                	je     801024b1 <skipelem+0x91>
    path++;
  return path;
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c2:	c9                   	leave  
801024c3:	c3                   	ret    

801024c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c4:	55                   	push   %ebp
801024c5:	89 e5                	mov    %esp,%ebp
801024c7:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ca:	8b 45 08             	mov    0x8(%ebp),%eax
801024cd:	0f b6 00             	movzbl (%eax),%eax
801024d0:	3c 2f                	cmp    $0x2f,%al
801024d2:	75 17                	jne    801024eb <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024d4:	83 ec 08             	sub    $0x8,%esp
801024d7:	6a 01                	push   $0x1
801024d9:	6a 01                	push   $0x1
801024db:	e8 a7 f4 ff ff       	call   80101987 <iget>
801024e0:	83 c4 10             	add    $0x10,%esp
801024e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024e6:	e9 ba 00 00 00       	jmp    801025a5 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
801024eb:	e8 30 1e 00 00       	call   80104320 <myproc>
801024f0:	8b 40 68             	mov    0x68(%eax),%eax
801024f3:	83 ec 0c             	sub    $0xc,%esp
801024f6:	50                   	push   %eax
801024f7:	e8 6d f5 ff ff       	call   80101a69 <idup>
801024fc:	83 c4 10             	add    $0x10,%esp
801024ff:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102502:	e9 9e 00 00 00       	jmp    801025a5 <namex+0xe1>
    ilock(ip);
80102507:	83 ec 0c             	sub    $0xc,%esp
8010250a:	ff 75 f4             	pushl  -0xc(%ebp)
8010250d:	e8 91 f5 ff ff       	call   80101aa3 <ilock>
80102512:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102518:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010251c:	66 83 f8 01          	cmp    $0x1,%ax
80102520:	74 18                	je     8010253a <namex+0x76>
      iunlockput(ip);
80102522:	83 ec 0c             	sub    $0xc,%esp
80102525:	ff 75 f4             	pushl  -0xc(%ebp)
80102528:	e8 a7 f7 ff ff       	call   80101cd4 <iunlockput>
8010252d:	83 c4 10             	add    $0x10,%esp
      return 0;
80102530:	b8 00 00 00 00       	mov    $0x0,%eax
80102535:	e9 a7 00 00 00       	jmp    801025e1 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010253a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010253e:	74 20                	je     80102560 <namex+0x9c>
80102540:	8b 45 08             	mov    0x8(%ebp),%eax
80102543:	0f b6 00             	movzbl (%eax),%eax
80102546:	84 c0                	test   %al,%al
80102548:	75 16                	jne    80102560 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010254a:	83 ec 0c             	sub    $0xc,%esp
8010254d:	ff 75 f4             	pushl  -0xc(%ebp)
80102550:	e8 61 f6 ff ff       	call   80101bb6 <iunlock>
80102555:	83 c4 10             	add    $0x10,%esp
      return ip;
80102558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255b:	e9 81 00 00 00       	jmp    801025e1 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102560:	83 ec 04             	sub    $0x4,%esp
80102563:	6a 00                	push   $0x0
80102565:	ff 75 10             	pushl  0x10(%ebp)
80102568:	ff 75 f4             	pushl  -0xc(%ebp)
8010256b:	e8 1e fd ff ff       	call   8010228e <dirlookup>
80102570:	83 c4 10             	add    $0x10,%esp
80102573:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102576:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257a:	75 15                	jne    80102591 <namex+0xcd>
      iunlockput(ip);
8010257c:	83 ec 0c             	sub    $0xc,%esp
8010257f:	ff 75 f4             	pushl  -0xc(%ebp)
80102582:	e8 4d f7 ff ff       	call   80101cd4 <iunlockput>
80102587:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258a:	b8 00 00 00 00       	mov    $0x0,%eax
8010258f:	eb 50                	jmp    801025e1 <namex+0x11d>
    }
    iunlockput(ip);
80102591:	83 ec 0c             	sub    $0xc,%esp
80102594:	ff 75 f4             	pushl  -0xc(%ebp)
80102597:	e8 38 f7 ff ff       	call   80101cd4 <iunlockput>
8010259c:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010259f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801025a5:	83 ec 08             	sub    $0x8,%esp
801025a8:	ff 75 10             	pushl  0x10(%ebp)
801025ab:	ff 75 08             	pushl  0x8(%ebp)
801025ae:	e8 6d fe ff ff       	call   80102420 <skipelem>
801025b3:	83 c4 10             	add    $0x10,%esp
801025b6:	89 45 08             	mov    %eax,0x8(%ebp)
801025b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025bd:	0f 85 44 ff ff ff    	jne    80102507 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025c7:	74 15                	je     801025de <namex+0x11a>
    iput(ip);
801025c9:	83 ec 0c             	sub    $0xc,%esp
801025cc:	ff 75 f4             	pushl  -0xc(%ebp)
801025cf:	e8 30 f6 ff ff       	call   80101c04 <iput>
801025d4:	83 c4 10             	add    $0x10,%esp
    return 0;
801025d7:	b8 00 00 00 00       	mov    $0x0,%eax
801025dc:	eb 03                	jmp    801025e1 <namex+0x11d>
  }
  return ip;
801025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e1:	c9                   	leave  
801025e2:	c3                   	ret    

801025e3 <namei>:

struct inode*
namei(char *path)
{
801025e3:	55                   	push   %ebp
801025e4:	89 e5                	mov    %esp,%ebp
801025e6:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025e9:	83 ec 04             	sub    $0x4,%esp
801025ec:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025ef:	50                   	push   %eax
801025f0:	6a 00                	push   $0x0
801025f2:	ff 75 08             	pushl  0x8(%ebp)
801025f5:	e8 ca fe ff ff       	call   801024c4 <namex>
801025fa:	83 c4 10             	add    $0x10,%esp
}
801025fd:	c9                   	leave  
801025fe:	c3                   	ret    

801025ff <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025ff:	55                   	push   %ebp
80102600:	89 e5                	mov    %esp,%ebp
80102602:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102605:	83 ec 04             	sub    $0x4,%esp
80102608:	ff 75 0c             	pushl  0xc(%ebp)
8010260b:	6a 01                	push   $0x1
8010260d:	ff 75 08             	pushl  0x8(%ebp)
80102610:	e8 af fe ff ff       	call   801024c4 <namex>
80102615:	83 c4 10             	add    $0x10,%esp
}
80102618:	c9                   	leave  
80102619:	c3                   	ret    

8010261a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010261a:	55                   	push   %ebp
8010261b:	89 e5                	mov    %esp,%ebp
8010261d:	83 ec 14             	sub    $0x14,%esp
80102620:	8b 45 08             	mov    0x8(%ebp),%eax
80102623:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102627:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010262b:	89 c2                	mov    %eax,%edx
8010262d:	ec                   	in     (%dx),%al
8010262e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102631:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102635:	c9                   	leave  
80102636:	c3                   	ret    

80102637 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102637:	55                   	push   %ebp
80102638:	89 e5                	mov    %esp,%ebp
8010263a:	57                   	push   %edi
8010263b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010263c:	8b 55 08             	mov    0x8(%ebp),%edx
8010263f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102642:	8b 45 10             	mov    0x10(%ebp),%eax
80102645:	89 cb                	mov    %ecx,%ebx
80102647:	89 df                	mov    %ebx,%edi
80102649:	89 c1                	mov    %eax,%ecx
8010264b:	fc                   	cld    
8010264c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010264e:	89 c8                	mov    %ecx,%eax
80102650:	89 fb                	mov    %edi,%ebx
80102652:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102655:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102658:	90                   	nop
80102659:	5b                   	pop    %ebx
8010265a:	5f                   	pop    %edi
8010265b:	5d                   	pop    %ebp
8010265c:	c3                   	ret    

8010265d <outb>:

static inline void
outb(ushort port, uchar data)
{
8010265d:	55                   	push   %ebp
8010265e:	89 e5                	mov    %esp,%ebp
80102660:	83 ec 08             	sub    $0x8,%esp
80102663:	8b 55 08             	mov    0x8(%ebp),%edx
80102666:	8b 45 0c             	mov    0xc(%ebp),%eax
80102669:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010266d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102670:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102674:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102678:	ee                   	out    %al,(%dx)
}
80102679:	90                   	nop
8010267a:	c9                   	leave  
8010267b:	c3                   	ret    

8010267c <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010267c:	55                   	push   %ebp
8010267d:	89 e5                	mov    %esp,%ebp
8010267f:	56                   	push   %esi
80102680:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102681:	8b 55 08             	mov    0x8(%ebp),%edx
80102684:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102687:	8b 45 10             	mov    0x10(%ebp),%eax
8010268a:	89 cb                	mov    %ecx,%ebx
8010268c:	89 de                	mov    %ebx,%esi
8010268e:	89 c1                	mov    %eax,%ecx
80102690:	fc                   	cld    
80102691:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102693:	89 c8                	mov    %ecx,%eax
80102695:	89 f3                	mov    %esi,%ebx
80102697:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010269a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010269d:	90                   	nop
8010269e:	5b                   	pop    %ebx
8010269f:	5e                   	pop    %esi
801026a0:	5d                   	pop    %ebp
801026a1:	c3                   	ret    

801026a2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026a2:	55                   	push   %ebp
801026a3:	89 e5                	mov    %esp,%ebp
801026a5:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026a8:	90                   	nop
801026a9:	68 f7 01 00 00       	push   $0x1f7
801026ae:	e8 67 ff ff ff       	call   8010261a <inb>
801026b3:	83 c4 04             	add    $0x4,%esp
801026b6:	0f b6 c0             	movzbl %al,%eax
801026b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026bf:	25 c0 00 00 00       	and    $0xc0,%eax
801026c4:	83 f8 40             	cmp    $0x40,%eax
801026c7:	75 e0                	jne    801026a9 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026cd:	74 11                	je     801026e0 <idewait+0x3e>
801026cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d2:	83 e0 21             	and    $0x21,%eax
801026d5:	85 c0                	test   %eax,%eax
801026d7:	74 07                	je     801026e0 <idewait+0x3e>
    return -1;
801026d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026de:	eb 05                	jmp    801026e5 <idewait+0x43>
  return 0;
801026e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026e5:	c9                   	leave  
801026e6:	c3                   	ret    

801026e7 <ideinit>:

void
ideinit(void)
{
801026e7:	55                   	push   %ebp
801026e8:	89 e5                	mov    %esp,%ebp
801026ea:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026ed:	83 ec 08             	sub    $0x8,%esp
801026f0:	68 a7 88 10 80       	push   $0x801088a7
801026f5:	68 e0 b5 10 80       	push   $0x8010b5e0
801026fa:	e8 22 29 00 00       	call   80105021 <initlock>
801026ff:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102702:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80102707:	83 e8 01             	sub    $0x1,%eax
8010270a:	83 ec 08             	sub    $0x8,%esp
8010270d:	50                   	push   %eax
8010270e:	6a 0e                	push   $0xe
80102710:	e8 a2 04 00 00       	call   80102bb7 <ioapicenable>
80102715:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102718:	83 ec 0c             	sub    $0xc,%esp
8010271b:	6a 00                	push   $0x0
8010271d:	e8 80 ff ff ff       	call   801026a2 <idewait>
80102722:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102725:	83 ec 08             	sub    $0x8,%esp
80102728:	68 f0 00 00 00       	push   $0xf0
8010272d:	68 f6 01 00 00       	push   $0x1f6
80102732:	e8 26 ff ff ff       	call   8010265d <outb>
80102737:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010273a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102741:	eb 24                	jmp    80102767 <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102743:	83 ec 0c             	sub    $0xc,%esp
80102746:	68 f7 01 00 00       	push   $0x1f7
8010274b:	e8 ca fe ff ff       	call   8010261a <inb>
80102750:	83 c4 10             	add    $0x10,%esp
80102753:	84 c0                	test   %al,%al
80102755:	74 0c                	je     80102763 <ideinit+0x7c>
      havedisk1 = 1;
80102757:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
8010275e:	00 00 00 
      break;
80102761:	eb 0d                	jmp    80102770 <ideinit+0x89>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102763:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102767:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010276e:	7e d3                	jle    80102743 <ideinit+0x5c>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102770:	83 ec 08             	sub    $0x8,%esp
80102773:	68 e0 00 00 00       	push   $0xe0
80102778:	68 f6 01 00 00       	push   $0x1f6
8010277d:	e8 db fe ff ff       	call   8010265d <outb>
80102782:	83 c4 10             	add    $0x10,%esp
}
80102785:	90                   	nop
80102786:	c9                   	leave  
80102787:	c3                   	ret    

80102788 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102788:	55                   	push   %ebp
80102789:	89 e5                	mov    %esp,%ebp
8010278b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010278e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102792:	75 0d                	jne    801027a1 <idestart+0x19>
    panic("idestart");
80102794:	83 ec 0c             	sub    $0xc,%esp
80102797:	68 ab 88 10 80       	push   $0x801088ab
8010279c:	e8 ff dd ff ff       	call   801005a0 <panic>
  if(b->blockno >= FSSIZE)
801027a1:	8b 45 08             	mov    0x8(%ebp),%eax
801027a4:	8b 40 08             	mov    0x8(%eax),%eax
801027a7:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027ac:	76 0d                	jbe    801027bb <idestart+0x33>
    panic("incorrect blockno");
801027ae:	83 ec 0c             	sub    $0xc,%esp
801027b1:	68 b4 88 10 80       	push   $0x801088b4
801027b6:	e8 e5 dd ff ff       	call   801005a0 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027bb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027c2:	8b 45 08             	mov    0x8(%ebp),%eax
801027c5:	8b 50 08             	mov    0x8(%eax),%edx
801027c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cb:	0f af c2             	imul   %edx,%eax
801027ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027d1:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027d5:	75 07                	jne    801027de <idestart+0x56>
801027d7:	b8 20 00 00 00       	mov    $0x20,%eax
801027dc:	eb 05                	jmp    801027e3 <idestart+0x5b>
801027de:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027e6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027ea:	75 07                	jne    801027f3 <idestart+0x6b>
801027ec:	b8 30 00 00 00       	mov    $0x30,%eax
801027f1:	eb 05                	jmp    801027f8 <idestart+0x70>
801027f3:	b8 c5 00 00 00       	mov    $0xc5,%eax
801027f8:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027fb:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027ff:	7e 0d                	jle    8010280e <idestart+0x86>
80102801:	83 ec 0c             	sub    $0xc,%esp
80102804:	68 ab 88 10 80       	push   $0x801088ab
80102809:	e8 92 dd ff ff       	call   801005a0 <panic>

  idewait(0);
8010280e:	83 ec 0c             	sub    $0xc,%esp
80102811:	6a 00                	push   $0x0
80102813:	e8 8a fe ff ff       	call   801026a2 <idewait>
80102818:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010281b:	83 ec 08             	sub    $0x8,%esp
8010281e:	6a 00                	push   $0x0
80102820:	68 f6 03 00 00       	push   $0x3f6
80102825:	e8 33 fe ff ff       	call   8010265d <outb>
8010282a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010282d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102830:	0f b6 c0             	movzbl %al,%eax
80102833:	83 ec 08             	sub    $0x8,%esp
80102836:	50                   	push   %eax
80102837:	68 f2 01 00 00       	push   $0x1f2
8010283c:	e8 1c fe ff ff       	call   8010265d <outb>
80102841:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102847:	0f b6 c0             	movzbl %al,%eax
8010284a:	83 ec 08             	sub    $0x8,%esp
8010284d:	50                   	push   %eax
8010284e:	68 f3 01 00 00       	push   $0x1f3
80102853:	e8 05 fe ff ff       	call   8010265d <outb>
80102858:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010285b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010285e:	c1 f8 08             	sar    $0x8,%eax
80102861:	0f b6 c0             	movzbl %al,%eax
80102864:	83 ec 08             	sub    $0x8,%esp
80102867:	50                   	push   %eax
80102868:	68 f4 01 00 00       	push   $0x1f4
8010286d:	e8 eb fd ff ff       	call   8010265d <outb>
80102872:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102878:	c1 f8 10             	sar    $0x10,%eax
8010287b:	0f b6 c0             	movzbl %al,%eax
8010287e:	83 ec 08             	sub    $0x8,%esp
80102881:	50                   	push   %eax
80102882:	68 f5 01 00 00       	push   $0x1f5
80102887:	e8 d1 fd ff ff       	call   8010265d <outb>
8010288c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010288f:	8b 45 08             	mov    0x8(%ebp),%eax
80102892:	8b 40 04             	mov    0x4(%eax),%eax
80102895:	83 e0 01             	and    $0x1,%eax
80102898:	c1 e0 04             	shl    $0x4,%eax
8010289b:	89 c2                	mov    %eax,%edx
8010289d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028a0:	c1 f8 18             	sar    $0x18,%eax
801028a3:	83 e0 0f             	and    $0xf,%eax
801028a6:	09 d0                	or     %edx,%eax
801028a8:	83 c8 e0             	or     $0xffffffe0,%eax
801028ab:	0f b6 c0             	movzbl %al,%eax
801028ae:	83 ec 08             	sub    $0x8,%esp
801028b1:	50                   	push   %eax
801028b2:	68 f6 01 00 00       	push   $0x1f6
801028b7:	e8 a1 fd ff ff       	call   8010265d <outb>
801028bc:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028bf:	8b 45 08             	mov    0x8(%ebp),%eax
801028c2:	8b 00                	mov    (%eax),%eax
801028c4:	83 e0 04             	and    $0x4,%eax
801028c7:	85 c0                	test   %eax,%eax
801028c9:	74 35                	je     80102900 <idestart+0x178>
    outb(0x1f7, write_cmd);
801028cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028ce:	0f b6 c0             	movzbl %al,%eax
801028d1:	83 ec 08             	sub    $0x8,%esp
801028d4:	50                   	push   %eax
801028d5:	68 f7 01 00 00       	push   $0x1f7
801028da:	e8 7e fd ff ff       	call   8010265d <outb>
801028df:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028e2:	8b 45 08             	mov    0x8(%ebp),%eax
801028e5:	83 c0 5c             	add    $0x5c,%eax
801028e8:	83 ec 04             	sub    $0x4,%esp
801028eb:	68 80 00 00 00       	push   $0x80
801028f0:	50                   	push   %eax
801028f1:	68 f0 01 00 00       	push   $0x1f0
801028f6:	e8 81 fd ff ff       	call   8010267c <outsl>
801028fb:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801028fe:	eb 17                	jmp    80102917 <idestart+0x18f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
80102900:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102903:	0f b6 c0             	movzbl %al,%eax
80102906:	83 ec 08             	sub    $0x8,%esp
80102909:	50                   	push   %eax
8010290a:	68 f7 01 00 00       	push   $0x1f7
8010290f:	e8 49 fd ff ff       	call   8010265d <outb>
80102914:	83 c4 10             	add    $0x10,%esp
  }
}
80102917:	90                   	nop
80102918:	c9                   	leave  
80102919:	c3                   	ret    

8010291a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010291a:	55                   	push   %ebp
8010291b:	89 e5                	mov    %esp,%ebp
8010291d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102920:	83 ec 0c             	sub    $0xc,%esp
80102923:	68 e0 b5 10 80       	push   $0x8010b5e0
80102928:	e8 16 27 00 00       	call   80105043 <acquire>
8010292d:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102930:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102935:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102938:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010293c:	75 15                	jne    80102953 <ideintr+0x39>
    release(&idelock);
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 e0 b5 10 80       	push   $0x8010b5e0
80102946:	e8 66 27 00 00       	call   801050b1 <release>
8010294b:	83 c4 10             	add    $0x10,%esp
    return;
8010294e:	e9 9a 00 00 00       	jmp    801029ed <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	8b 40 58             	mov    0x58(%eax),%eax
80102959:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010295e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102961:	8b 00                	mov    (%eax),%eax
80102963:	83 e0 04             	and    $0x4,%eax
80102966:	85 c0                	test   %eax,%eax
80102968:	75 2d                	jne    80102997 <ideintr+0x7d>
8010296a:	83 ec 0c             	sub    $0xc,%esp
8010296d:	6a 01                	push   $0x1
8010296f:	e8 2e fd ff ff       	call   801026a2 <idewait>
80102974:	83 c4 10             	add    $0x10,%esp
80102977:	85 c0                	test   %eax,%eax
80102979:	78 1c                	js     80102997 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010297b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297e:	83 c0 5c             	add    $0x5c,%eax
80102981:	83 ec 04             	sub    $0x4,%esp
80102984:	68 80 00 00 00       	push   $0x80
80102989:	50                   	push   %eax
8010298a:	68 f0 01 00 00       	push   $0x1f0
8010298f:	e8 a3 fc ff ff       	call   80102637 <insl>
80102994:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299a:	8b 00                	mov    (%eax),%eax
8010299c:	83 c8 02             	or     $0x2,%eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	8b 00                	mov    (%eax),%eax
801029ab:	83 e0 fb             	and    $0xfffffffb,%eax
801029ae:	89 c2                	mov    %eax,%edx
801029b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029b5:	83 ec 0c             	sub    $0xc,%esp
801029b8:	ff 75 f4             	pushl  -0xc(%ebp)
801029bb:	e8 4a 23 00 00       	call   80104d0a <wakeup>
801029c0:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029c3:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029c8:	85 c0                	test   %eax,%eax
801029ca:	74 11                	je     801029dd <ideintr+0xc3>
    idestart(idequeue);
801029cc:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029d1:	83 ec 0c             	sub    $0xc,%esp
801029d4:	50                   	push   %eax
801029d5:	e8 ae fd ff ff       	call   80102788 <idestart>
801029da:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029dd:	83 ec 0c             	sub    $0xc,%esp
801029e0:	68 e0 b5 10 80       	push   $0x8010b5e0
801029e5:	e8 c7 26 00 00       	call   801050b1 <release>
801029ea:	83 c4 10             	add    $0x10,%esp
}
801029ed:	c9                   	leave  
801029ee:	c3                   	ret    

801029ef <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029ef:	55                   	push   %ebp
801029f0:	89 e5                	mov    %esp,%ebp
801029f2:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801029f5:	8b 45 08             	mov    0x8(%ebp),%eax
801029f8:	83 c0 0c             	add    $0xc,%eax
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	50                   	push   %eax
801029ff:	e8 ae 25 00 00       	call   80104fb2 <holdingsleep>
80102a04:	83 c4 10             	add    $0x10,%esp
80102a07:	85 c0                	test   %eax,%eax
80102a09:	75 0d                	jne    80102a18 <iderw+0x29>
    panic("iderw: buf not locked");
80102a0b:	83 ec 0c             	sub    $0xc,%esp
80102a0e:	68 c6 88 10 80       	push   $0x801088c6
80102a13:	e8 88 db ff ff       	call   801005a0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	8b 00                	mov    (%eax),%eax
80102a1d:	83 e0 06             	and    $0x6,%eax
80102a20:	83 f8 02             	cmp    $0x2,%eax
80102a23:	75 0d                	jne    80102a32 <iderw+0x43>
    panic("iderw: nothing to do");
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 dc 88 10 80       	push   $0x801088dc
80102a2d:	e8 6e db ff ff       	call   801005a0 <panic>
  if(b->dev != 0 && !havedisk1)
80102a32:	8b 45 08             	mov    0x8(%ebp),%eax
80102a35:	8b 40 04             	mov    0x4(%eax),%eax
80102a38:	85 c0                	test   %eax,%eax
80102a3a:	74 16                	je     80102a52 <iderw+0x63>
80102a3c:	a1 18 b6 10 80       	mov    0x8010b618,%eax
80102a41:	85 c0                	test   %eax,%eax
80102a43:	75 0d                	jne    80102a52 <iderw+0x63>
    panic("iderw: ide disk 1 not present");
80102a45:	83 ec 0c             	sub    $0xc,%esp
80102a48:	68 f1 88 10 80       	push   $0x801088f1
80102a4d:	e8 4e db ff ff       	call   801005a0 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a52:	83 ec 0c             	sub    $0xc,%esp
80102a55:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a5a:	e8 e4 25 00 00       	call   80105043 <acquire>
80102a5f:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a62:	8b 45 08             	mov    0x8(%ebp),%eax
80102a65:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a6c:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
80102a73:	eb 0b                	jmp    80102a80 <iderw+0x91>
80102a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a78:	8b 00                	mov    (%eax),%eax
80102a7a:	83 c0 58             	add    $0x58,%eax
80102a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a83:	8b 00                	mov    (%eax),%eax
80102a85:	85 c0                	test   %eax,%eax
80102a87:	75 ec                	jne    80102a75 <iderw+0x86>
    ;
  *pp = b;
80102a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a8f:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a91:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102a96:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a99:	75 23                	jne    80102abe <iderw+0xcf>
    idestart(b);
80102a9b:	83 ec 0c             	sub    $0xc,%esp
80102a9e:	ff 75 08             	pushl  0x8(%ebp)
80102aa1:	e8 e2 fc ff ff       	call   80102788 <idestart>
80102aa6:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102aa9:	eb 13                	jmp    80102abe <iderw+0xcf>
    sleep(b, &idelock);
80102aab:	83 ec 08             	sub    $0x8,%esp
80102aae:	68 e0 b5 10 80       	push   $0x8010b5e0
80102ab3:	ff 75 08             	pushl  0x8(%ebp)
80102ab6:	e8 66 21 00 00       	call   80104c21 <sleep>
80102abb:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102abe:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac1:	8b 00                	mov    (%eax),%eax
80102ac3:	83 e0 06             	and    $0x6,%eax
80102ac6:	83 f8 02             	cmp    $0x2,%eax
80102ac9:	75 e0                	jne    80102aab <iderw+0xbc>
    sleep(b, &idelock);
  }


  release(&idelock);
80102acb:	83 ec 0c             	sub    $0xc,%esp
80102ace:	68 e0 b5 10 80       	push   $0x8010b5e0
80102ad3:	e8 d9 25 00 00       	call   801050b1 <release>
80102ad8:	83 c4 10             	add    $0x10,%esp
}
80102adb:	90                   	nop
80102adc:	c9                   	leave  
80102add:	c3                   	ret    

80102ade <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ade:	55                   	push   %ebp
80102adf:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ae1:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ae6:	8b 55 08             	mov    0x8(%ebp),%edx
80102ae9:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102aeb:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102af0:	8b 40 10             	mov    0x10(%eax),%eax
}
80102af3:	5d                   	pop    %ebp
80102af4:	c3                   	ret    

80102af5 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102af5:	55                   	push   %ebp
80102af6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102af8:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102afd:	8b 55 08             	mov    0x8(%ebp),%edx
80102b00:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b02:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102b07:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b0a:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b0d:	90                   	nop
80102b0e:	5d                   	pop    %ebp
80102b0f:	c3                   	ret    

80102b10 <ioapicinit>:

void
ioapicinit(void)
{
80102b10:	55                   	push   %ebp
80102b11:	89 e5                	mov    %esp,%ebp
80102b13:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b16:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
80102b1d:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b20:	6a 01                	push   $0x1
80102b22:	e8 b7 ff ff ff       	call   80102ade <ioapicread>
80102b27:	83 c4 04             	add    $0x4,%esp
80102b2a:	c1 e8 10             	shr    $0x10,%eax
80102b2d:	25 ff 00 00 00       	and    $0xff,%eax
80102b32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b35:	6a 00                	push   $0x0
80102b37:	e8 a2 ff ff ff       	call   80102ade <ioapicread>
80102b3c:	83 c4 04             	add    $0x4,%esp
80102b3f:	c1 e8 18             	shr    $0x18,%eax
80102b42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b45:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
80102b4c:	0f b6 c0             	movzbl %al,%eax
80102b4f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b52:	74 10                	je     80102b64 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b54:	83 ec 0c             	sub    $0xc,%esp
80102b57:	68 10 89 10 80       	push   $0x80108910
80102b5c:	e8 9f d8 ff ff       	call   80100400 <cprintf>
80102b61:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b6b:	eb 3f                	jmp    80102bac <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b70:	83 c0 20             	add    $0x20,%eax
80102b73:	0d 00 00 01 00       	or     $0x10000,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7d:	83 c0 08             	add    $0x8,%eax
80102b80:	01 c0                	add    %eax,%eax
80102b82:	83 ec 08             	sub    $0x8,%esp
80102b85:	52                   	push   %edx
80102b86:	50                   	push   %eax
80102b87:	e8 69 ff ff ff       	call   80102af5 <ioapicwrite>
80102b8c:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b92:	83 c0 08             	add    $0x8,%eax
80102b95:	01 c0                	add    %eax,%eax
80102b97:	83 c0 01             	add    $0x1,%eax
80102b9a:	83 ec 08             	sub    $0x8,%esp
80102b9d:	6a 00                	push   $0x0
80102b9f:	50                   	push   %eax
80102ba0:	e8 50 ff ff ff       	call   80102af5 <ioapicwrite>
80102ba5:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ba8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102baf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bb2:	7e b9                	jle    80102b6d <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102bb4:	90                   	nop
80102bb5:	c9                   	leave  
80102bb6:	c3                   	ret    

80102bb7 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102bb7:	55                   	push   %ebp
80102bb8:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102bba:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbd:	83 c0 20             	add    $0x20,%eax
80102bc0:	89 c2                	mov    %eax,%edx
80102bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc5:	83 c0 08             	add    $0x8,%eax
80102bc8:	01 c0                	add    %eax,%eax
80102bca:	52                   	push   %edx
80102bcb:	50                   	push   %eax
80102bcc:	e8 24 ff ff ff       	call   80102af5 <ioapicwrite>
80102bd1:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bd7:	c1 e0 18             	shl    $0x18,%eax
80102bda:	89 c2                	mov    %eax,%edx
80102bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdf:	83 c0 08             	add    $0x8,%eax
80102be2:	01 c0                	add    %eax,%eax
80102be4:	83 c0 01             	add    $0x1,%eax
80102be7:	52                   	push   %edx
80102be8:	50                   	push   %eax
80102be9:	e8 07 ff ff ff       	call   80102af5 <ioapicwrite>
80102bee:	83 c4 08             	add    $0x8,%esp
}
80102bf1:	90                   	nop
80102bf2:	c9                   	leave  
80102bf3:	c3                   	ret    

80102bf4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bf4:	55                   	push   %ebp
80102bf5:	89 e5                	mov    %esp,%ebp
80102bf7:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bfa:	83 ec 08             	sub    $0x8,%esp
80102bfd:	68 42 89 10 80       	push   $0x80108942
80102c02:	68 c0 36 11 80       	push   $0x801136c0
80102c07:	e8 15 24 00 00       	call   80105021 <initlock>
80102c0c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c0f:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102c16:	00 00 00 
  freerange(vstart, vend);
80102c19:	83 ec 08             	sub    $0x8,%esp
80102c1c:	ff 75 0c             	pushl  0xc(%ebp)
80102c1f:	ff 75 08             	pushl  0x8(%ebp)
80102c22:	e8 2a 00 00 00       	call   80102c51 <freerange>
80102c27:	83 c4 10             	add    $0x10,%esp
}
80102c2a:	90                   	nop
80102c2b:	c9                   	leave  
80102c2c:	c3                   	ret    

80102c2d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c2d:	55                   	push   %ebp
80102c2e:	89 e5                	mov    %esp,%ebp
80102c30:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c33:	83 ec 08             	sub    $0x8,%esp
80102c36:	ff 75 0c             	pushl  0xc(%ebp)
80102c39:	ff 75 08             	pushl  0x8(%ebp)
80102c3c:	e8 10 00 00 00       	call   80102c51 <freerange>
80102c41:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c44:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102c4b:	00 00 00 
}
80102c4e:	90                   	nop
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
80102c54:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c57:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c67:	eb 15                	jmp    80102c7e <freerange+0x2d>
    kfree(p);
80102c69:	83 ec 0c             	sub    $0xc,%esp
80102c6c:	ff 75 f4             	pushl  -0xc(%ebp)
80102c6f:	e8 1a 00 00 00       	call   80102c8e <kfree>
80102c74:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c77:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c81:	05 00 10 00 00       	add    $0x1000,%eax
80102c86:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c89:	76 de                	jbe    80102c69 <freerange+0x18>
    kfree(p);
}
80102c8b:	90                   	nop
80102c8c:	c9                   	leave  
80102c8d:	c3                   	ret    

80102c8e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c8e:	55                   	push   %ebp
80102c8f:	89 e5                	mov    %esp,%ebp
80102c91:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c94:	8b 45 08             	mov    0x8(%ebp),%eax
80102c97:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c9c:	85 c0                	test   %eax,%eax
80102c9e:	75 18                	jne    80102cb8 <kfree+0x2a>
80102ca0:	81 7d 08 74 6a 11 80 	cmpl   $0x80116a74,0x8(%ebp)
80102ca7:	72 0f                	jb     80102cb8 <kfree+0x2a>
80102ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cac:	05 00 00 00 80       	add    $0x80000000,%eax
80102cb1:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102cb6:	76 0d                	jbe    80102cc5 <kfree+0x37>
    panic("kfree");
80102cb8:	83 ec 0c             	sub    $0xc,%esp
80102cbb:	68 47 89 10 80       	push   $0x80108947
80102cc0:	e8 db d8 ff ff       	call   801005a0 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cc5:	83 ec 04             	sub    $0x4,%esp
80102cc8:	68 00 10 00 00       	push   $0x1000
80102ccd:	6a 01                	push   $0x1
80102ccf:	ff 75 08             	pushl  0x8(%ebp)
80102cd2:	e8 e3 25 00 00       	call   801052ba <memset>
80102cd7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cda:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102cdf:	85 c0                	test   %eax,%eax
80102ce1:	74 10                	je     80102cf3 <kfree+0x65>
    acquire(&kmem.lock);
80102ce3:	83 ec 0c             	sub    $0xc,%esp
80102ce6:	68 c0 36 11 80       	push   $0x801136c0
80102ceb:	e8 53 23 00 00       	call   80105043 <acquire>
80102cf0:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cf9:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d02:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d07:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102d0c:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d11:	85 c0                	test   %eax,%eax
80102d13:	74 10                	je     80102d25 <kfree+0x97>
    release(&kmem.lock);
80102d15:	83 ec 0c             	sub    $0xc,%esp
80102d18:	68 c0 36 11 80       	push   $0x801136c0
80102d1d:	e8 8f 23 00 00       	call   801050b1 <release>
80102d22:	83 c4 10             	add    $0x10,%esp
}
80102d25:	90                   	nop
80102d26:	c9                   	leave  
80102d27:	c3                   	ret    

80102d28 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d28:	55                   	push   %ebp
80102d29:	89 e5                	mov    %esp,%ebp
80102d2b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d2e:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d33:	85 c0                	test   %eax,%eax
80102d35:	74 10                	je     80102d47 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d37:	83 ec 0c             	sub    $0xc,%esp
80102d3a:	68 c0 36 11 80       	push   $0x801136c0
80102d3f:	e8 ff 22 00 00       	call   80105043 <acquire>
80102d44:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d47:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d53:	74 0a                	je     80102d5f <kalloc+0x37>
    kmem.freelist = r->next;
80102d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d58:	8b 00                	mov    (%eax),%eax
80102d5a:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102d5f:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d64:	85 c0                	test   %eax,%eax
80102d66:	74 10                	je     80102d78 <kalloc+0x50>
    release(&kmem.lock);
80102d68:	83 ec 0c             	sub    $0xc,%esp
80102d6b:	68 c0 36 11 80       	push   $0x801136c0
80102d70:	e8 3c 23 00 00       	call   801050b1 <release>
80102d75:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d7b:	c9                   	leave  
80102d7c:	c3                   	ret    

80102d7d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d7d:	55                   	push   %ebp
80102d7e:	89 e5                	mov    %esp,%ebp
80102d80:	83 ec 14             	sub    $0x14,%esp
80102d83:	8b 45 08             	mov    0x8(%ebp),%eax
80102d86:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d8a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	ec                   	in     (%dx),%al
80102d91:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d94:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d98:	c9                   	leave  
80102d99:	c3                   	ret    

80102d9a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d9a:	55                   	push   %ebp
80102d9b:	89 e5                	mov    %esp,%ebp
80102d9d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102da0:	6a 64                	push   $0x64
80102da2:	e8 d6 ff ff ff       	call   80102d7d <inb>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	0f b6 c0             	movzbl %al,%eax
80102dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db3:	83 e0 01             	and    $0x1,%eax
80102db6:	85 c0                	test   %eax,%eax
80102db8:	75 0a                	jne    80102dc4 <kbdgetc+0x2a>
    return -1;
80102dba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dbf:	e9 23 01 00 00       	jmp    80102ee7 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102dc4:	6a 60                	push   $0x60
80102dc6:	e8 b2 ff ff ff       	call   80102d7d <inb>
80102dcb:	83 c4 04             	add    $0x4,%esp
80102dce:	0f b6 c0             	movzbl %al,%eax
80102dd1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102dd4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ddb:	75 17                	jne    80102df4 <kbdgetc+0x5a>
    shift |= E0ESC;
80102ddd:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102de2:	83 c8 40             	or     $0x40,%eax
80102de5:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102dea:	b8 00 00 00 00       	mov    $0x0,%eax
80102def:	e9 f3 00 00 00       	jmp    80102ee7 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df7:	25 80 00 00 00       	and    $0x80,%eax
80102dfc:	85 c0                	test   %eax,%eax
80102dfe:	74 45                	je     80102e45 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e00:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e05:	83 e0 40             	and    $0x40,%eax
80102e08:	85 c0                	test   %eax,%eax
80102e0a:	75 08                	jne    80102e14 <kbdgetc+0x7a>
80102e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0f:	83 e0 7f             	and    $0x7f,%eax
80102e12:	eb 03                	jmp    80102e17 <kbdgetc+0x7d>
80102e14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e17:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e1d:	05 20 90 10 80       	add    $0x80109020,%eax
80102e22:	0f b6 00             	movzbl (%eax),%eax
80102e25:	83 c8 40             	or     $0x40,%eax
80102e28:	0f b6 c0             	movzbl %al,%eax
80102e2b:	f7 d0                	not    %eax
80102e2d:	89 c2                	mov    %eax,%edx
80102e2f:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e34:	21 d0                	and    %edx,%eax
80102e36:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102e3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102e40:	e9 a2 00 00 00       	jmp    80102ee7 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e45:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e4a:	83 e0 40             	and    $0x40,%eax
80102e4d:	85 c0                	test   %eax,%eax
80102e4f:	74 14                	je     80102e65 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e51:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e58:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e5d:	83 e0 bf             	and    $0xffffffbf,%eax
80102e60:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e68:	05 20 90 10 80       	add    $0x80109020,%eax
80102e6d:	0f b6 00             	movzbl (%eax),%eax
80102e70:	0f b6 d0             	movzbl %al,%edx
80102e73:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e78:	09 d0                	or     %edx,%eax
80102e7a:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102e7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e82:	05 20 91 10 80       	add    $0x80109120,%eax
80102e87:	0f b6 00             	movzbl (%eax),%eax
80102e8a:	0f b6 d0             	movzbl %al,%edx
80102e8d:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e92:	31 d0                	xor    %edx,%eax
80102e94:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e99:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e9e:	83 e0 03             	and    $0x3,%eax
80102ea1:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102ea8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eab:	01 d0                	add    %edx,%eax
80102ead:	0f b6 00             	movzbl (%eax),%eax
80102eb0:	0f b6 c0             	movzbl %al,%eax
80102eb3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102eb6:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102ebb:	83 e0 08             	and    $0x8,%eax
80102ebe:	85 c0                	test   %eax,%eax
80102ec0:	74 22                	je     80102ee4 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102ec2:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ec6:	76 0c                	jbe    80102ed4 <kbdgetc+0x13a>
80102ec8:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ecc:	77 06                	ja     80102ed4 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102ece:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ed2:	eb 10                	jmp    80102ee4 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ed4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ed8:	76 0a                	jbe    80102ee4 <kbdgetc+0x14a>
80102eda:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ede:	77 04                	ja     80102ee4 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ee0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ee4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ee7:	c9                   	leave  
80102ee8:	c3                   	ret    

80102ee9 <kbdintr>:

void
kbdintr(void)
{
80102ee9:	55                   	push   %ebp
80102eea:	89 e5                	mov    %esp,%ebp
80102eec:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102eef:	83 ec 0c             	sub    $0xc,%esp
80102ef2:	68 9a 2d 10 80       	push   $0x80102d9a
80102ef7:	e8 30 d9 ff ff       	call   8010082c <consoleintr>
80102efc:	83 c4 10             	add    $0x10,%esp
}
80102eff:	90                   	nop
80102f00:	c9                   	leave  
80102f01:	c3                   	ret    

80102f02 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f02:	55                   	push   %ebp
80102f03:	89 e5                	mov    %esp,%ebp
80102f05:	83 ec 14             	sub    $0x14,%esp
80102f08:	8b 45 08             	mov    0x8(%ebp),%eax
80102f0b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f0f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f13:	89 c2                	mov    %eax,%edx
80102f15:	ec                   	in     (%dx),%al
80102f16:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f19:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f1d:	c9                   	leave  
80102f1e:	c3                   	ret    

80102f1f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f1f:	55                   	push   %ebp
80102f20:	89 e5                	mov    %esp,%ebp
80102f22:	83 ec 08             	sub    $0x8,%esp
80102f25:	8b 55 08             	mov    0x8(%ebp),%edx
80102f28:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f2b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f2f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f32:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f36:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f3a:	ee                   	out    %al,(%dx)
}
80102f3b:	90                   	nop
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f3e:	55                   	push   %ebp
80102f3f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f41:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f46:	8b 55 08             	mov    0x8(%ebp),%edx
80102f49:	c1 e2 02             	shl    $0x2,%edx
80102f4c:	01 c2                	add    %eax,%edx
80102f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f51:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f53:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f58:	83 c0 20             	add    $0x20,%eax
80102f5b:	8b 00                	mov    (%eax),%eax
}
80102f5d:	90                   	nop
80102f5e:	5d                   	pop    %ebp
80102f5f:	c3                   	ret    

80102f60 <lapicinit>:

void
lapicinit(void)
{
80102f60:	55                   	push   %ebp
80102f61:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102f63:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f68:	85 c0                	test   %eax,%eax
80102f6a:	0f 84 0b 01 00 00    	je     8010307b <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f70:	68 3f 01 00 00       	push   $0x13f
80102f75:	6a 3c                	push   $0x3c
80102f77:	e8 c2 ff ff ff       	call   80102f3e <lapicw>
80102f7c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f7f:	6a 0b                	push   $0xb
80102f81:	68 f8 00 00 00       	push   $0xf8
80102f86:	e8 b3 ff ff ff       	call   80102f3e <lapicw>
80102f8b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f8e:	68 20 00 02 00       	push   $0x20020
80102f93:	68 c8 00 00 00       	push   $0xc8
80102f98:	e8 a1 ff ff ff       	call   80102f3e <lapicw>
80102f9d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102fa0:	68 80 96 98 00       	push   $0x989680
80102fa5:	68 e0 00 00 00       	push   $0xe0
80102faa:	e8 8f ff ff ff       	call   80102f3e <lapicw>
80102faf:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102fb2:	68 00 00 01 00       	push   $0x10000
80102fb7:	68 d4 00 00 00       	push   $0xd4
80102fbc:	e8 7d ff ff ff       	call   80102f3e <lapicw>
80102fc1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fc4:	68 00 00 01 00       	push   $0x10000
80102fc9:	68 d8 00 00 00       	push   $0xd8
80102fce:	e8 6b ff ff ff       	call   80102f3e <lapicw>
80102fd3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fd6:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fdb:	83 c0 30             	add    $0x30,%eax
80102fde:	8b 00                	mov    (%eax),%eax
80102fe0:	c1 e8 10             	shr    $0x10,%eax
80102fe3:	0f b6 c0             	movzbl %al,%eax
80102fe6:	83 f8 03             	cmp    $0x3,%eax
80102fe9:	76 12                	jbe    80102ffd <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102feb:	68 00 00 01 00       	push   $0x10000
80102ff0:	68 d0 00 00 00       	push   $0xd0
80102ff5:	e8 44 ff ff ff       	call   80102f3e <lapicw>
80102ffa:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ffd:	6a 33                	push   $0x33
80102fff:	68 dc 00 00 00       	push   $0xdc
80103004:	e8 35 ff ff ff       	call   80102f3e <lapicw>
80103009:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	68 a0 00 00 00       	push   $0xa0
80103013:	e8 26 ff ff ff       	call   80102f3e <lapicw>
80103018:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010301b:	6a 00                	push   $0x0
8010301d:	68 a0 00 00 00       	push   $0xa0
80103022:	e8 17 ff ff ff       	call   80102f3e <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010302a:	6a 00                	push   $0x0
8010302c:	6a 2c                	push   $0x2c
8010302e:	e8 0b ff ff ff       	call   80102f3e <lapicw>
80103033:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103036:	6a 00                	push   $0x0
80103038:	68 c4 00 00 00       	push   $0xc4
8010303d:	e8 fc fe ff ff       	call   80102f3e <lapicw>
80103042:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103045:	68 00 85 08 00       	push   $0x88500
8010304a:	68 c0 00 00 00       	push   $0xc0
8010304f:	e8 ea fe ff ff       	call   80102f3e <lapicw>
80103054:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103057:	90                   	nop
80103058:	a1 fc 36 11 80       	mov    0x801136fc,%eax
8010305d:	05 00 03 00 00       	add    $0x300,%eax
80103062:	8b 00                	mov    (%eax),%eax
80103064:	25 00 10 00 00       	and    $0x1000,%eax
80103069:	85 c0                	test   %eax,%eax
8010306b:	75 eb                	jne    80103058 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010306d:	6a 00                	push   $0x0
8010306f:	6a 20                	push   $0x20
80103071:	e8 c8 fe ff ff       	call   80102f3e <lapicw>
80103076:	83 c4 08             	add    $0x8,%esp
80103079:	eb 01                	jmp    8010307c <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic)
    return;
8010307b:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010307c:	c9                   	leave  
8010307d:	c3                   	ret    

8010307e <lapicid>:

int
lapicid(void)
{
8010307e:	55                   	push   %ebp
8010307f:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103081:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103086:	85 c0                	test   %eax,%eax
80103088:	75 07                	jne    80103091 <lapicid+0x13>
    return 0;
8010308a:	b8 00 00 00 00       	mov    $0x0,%eax
8010308f:	eb 0d                	jmp    8010309e <lapicid+0x20>
  return lapic[ID] >> 24;
80103091:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103096:	83 c0 20             	add    $0x20,%eax
80103099:	8b 00                	mov    (%eax),%eax
8010309b:	c1 e8 18             	shr    $0x18,%eax
}
8010309e:	5d                   	pop    %ebp
8010309f:	c3                   	ret    

801030a0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030a3:	a1 fc 36 11 80       	mov    0x801136fc,%eax
801030a8:	85 c0                	test   %eax,%eax
801030aa:	74 0c                	je     801030b8 <lapiceoi+0x18>
    lapicw(EOI, 0);
801030ac:	6a 00                	push   $0x0
801030ae:	6a 2c                	push   $0x2c
801030b0:	e8 89 fe ff ff       	call   80102f3e <lapicw>
801030b5:	83 c4 08             	add    $0x8,%esp
}
801030b8:	90                   	nop
801030b9:	c9                   	leave  
801030ba:	c3                   	ret    

801030bb <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030bb:	55                   	push   %ebp
801030bc:	89 e5                	mov    %esp,%ebp
}
801030be:	90                   	nop
801030bf:	5d                   	pop    %ebp
801030c0:	c3                   	ret    

801030c1 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030c1:	55                   	push   %ebp
801030c2:	89 e5                	mov    %esp,%ebp
801030c4:	83 ec 14             	sub    $0x14,%esp
801030c7:	8b 45 08             	mov    0x8(%ebp),%eax
801030ca:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030cd:	6a 0f                	push   $0xf
801030cf:	6a 70                	push   $0x70
801030d1:	e8 49 fe ff ff       	call   80102f1f <outb>
801030d6:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801030d9:	6a 0a                	push   $0xa
801030db:	6a 71                	push   $0x71
801030dd:	e8 3d fe ff ff       	call   80102f1f <outb>
801030e2:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030e5:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030ef:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030f7:	83 c0 02             	add    $0x2,%eax
801030fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801030fd:	c1 ea 04             	shr    $0x4,%edx
80103100:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103103:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103107:	c1 e0 18             	shl    $0x18,%eax
8010310a:	50                   	push   %eax
8010310b:	68 c4 00 00 00       	push   $0xc4
80103110:	e8 29 fe ff ff       	call   80102f3e <lapicw>
80103115:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103118:	68 00 c5 00 00       	push   $0xc500
8010311d:	68 c0 00 00 00       	push   $0xc0
80103122:	e8 17 fe ff ff       	call   80102f3e <lapicw>
80103127:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010312a:	68 c8 00 00 00       	push   $0xc8
8010312f:	e8 87 ff ff ff       	call   801030bb <microdelay>
80103134:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103137:	68 00 85 00 00       	push   $0x8500
8010313c:	68 c0 00 00 00       	push   $0xc0
80103141:	e8 f8 fd ff ff       	call   80102f3e <lapicw>
80103146:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103149:	6a 64                	push   $0x64
8010314b:	e8 6b ff ff ff       	call   801030bb <microdelay>
80103150:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103153:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010315a:	eb 3d                	jmp    80103199 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
8010315c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103160:	c1 e0 18             	shl    $0x18,%eax
80103163:	50                   	push   %eax
80103164:	68 c4 00 00 00       	push   $0xc4
80103169:	e8 d0 fd ff ff       	call   80102f3e <lapicw>
8010316e:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103171:	8b 45 0c             	mov    0xc(%ebp),%eax
80103174:	c1 e8 0c             	shr    $0xc,%eax
80103177:	80 cc 06             	or     $0x6,%ah
8010317a:	50                   	push   %eax
8010317b:	68 c0 00 00 00       	push   $0xc0
80103180:	e8 b9 fd ff ff       	call   80102f3e <lapicw>
80103185:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103188:	68 c8 00 00 00       	push   $0xc8
8010318d:	e8 29 ff ff ff       	call   801030bb <microdelay>
80103192:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103195:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103199:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010319d:	7e bd                	jle    8010315c <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010319f:	90                   	nop
801031a0:	c9                   	leave  
801031a1:	c3                   	ret    

801031a2 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031a2:	55                   	push   %ebp
801031a3:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031a5:	8b 45 08             	mov    0x8(%ebp),%eax
801031a8:	0f b6 c0             	movzbl %al,%eax
801031ab:	50                   	push   %eax
801031ac:	6a 70                	push   $0x70
801031ae:	e8 6c fd ff ff       	call   80102f1f <outb>
801031b3:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031b6:	68 c8 00 00 00       	push   $0xc8
801031bb:	e8 fb fe ff ff       	call   801030bb <microdelay>
801031c0:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031c3:	6a 71                	push   $0x71
801031c5:	e8 38 fd ff ff       	call   80102f02 <inb>
801031ca:	83 c4 04             	add    $0x4,%esp
801031cd:	0f b6 c0             	movzbl %al,%eax
}
801031d0:	c9                   	leave  
801031d1:	c3                   	ret    

801031d2 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031d2:	55                   	push   %ebp
801031d3:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801031d5:	6a 00                	push   $0x0
801031d7:	e8 c6 ff ff ff       	call   801031a2 <cmos_read>
801031dc:	83 c4 04             	add    $0x4,%esp
801031df:	89 c2                	mov    %eax,%edx
801031e1:	8b 45 08             	mov    0x8(%ebp),%eax
801031e4:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801031e6:	6a 02                	push   $0x2
801031e8:	e8 b5 ff ff ff       	call   801031a2 <cmos_read>
801031ed:	83 c4 04             	add    $0x4,%esp
801031f0:	89 c2                	mov    %eax,%edx
801031f2:	8b 45 08             	mov    0x8(%ebp),%eax
801031f5:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801031f8:	6a 04                	push   $0x4
801031fa:	e8 a3 ff ff ff       	call   801031a2 <cmos_read>
801031ff:	83 c4 04             	add    $0x4,%esp
80103202:	89 c2                	mov    %eax,%edx
80103204:	8b 45 08             	mov    0x8(%ebp),%eax
80103207:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010320a:	6a 07                	push   $0x7
8010320c:	e8 91 ff ff ff       	call   801031a2 <cmos_read>
80103211:	83 c4 04             	add    $0x4,%esp
80103214:	89 c2                	mov    %eax,%edx
80103216:	8b 45 08             	mov    0x8(%ebp),%eax
80103219:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
8010321c:	6a 08                	push   $0x8
8010321e:	e8 7f ff ff ff       	call   801031a2 <cmos_read>
80103223:	83 c4 04             	add    $0x4,%esp
80103226:	89 c2                	mov    %eax,%edx
80103228:	8b 45 08             	mov    0x8(%ebp),%eax
8010322b:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
8010322e:	6a 09                	push   $0x9
80103230:	e8 6d ff ff ff       	call   801031a2 <cmos_read>
80103235:	83 c4 04             	add    $0x4,%esp
80103238:	89 c2                	mov    %eax,%edx
8010323a:	8b 45 08             	mov    0x8(%ebp),%eax
8010323d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103240:	90                   	nop
80103241:	c9                   	leave  
80103242:	c3                   	ret    

80103243 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103243:	55                   	push   %ebp
80103244:	89 e5                	mov    %esp,%ebp
80103246:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103249:	6a 0b                	push   $0xb
8010324b:	e8 52 ff ff ff       	call   801031a2 <cmos_read>
80103250:	83 c4 04             	add    $0x4,%esp
80103253:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103259:	83 e0 04             	and    $0x4,%eax
8010325c:	85 c0                	test   %eax,%eax
8010325e:	0f 94 c0             	sete   %al
80103261:	0f b6 c0             	movzbl %al,%eax
80103264:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103267:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010326a:	50                   	push   %eax
8010326b:	e8 62 ff ff ff       	call   801031d2 <fill_rtcdate>
80103270:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103273:	6a 0a                	push   $0xa
80103275:	e8 28 ff ff ff       	call   801031a2 <cmos_read>
8010327a:	83 c4 04             	add    $0x4,%esp
8010327d:	25 80 00 00 00       	and    $0x80,%eax
80103282:	85 c0                	test   %eax,%eax
80103284:	75 27                	jne    801032ad <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103286:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103289:	50                   	push   %eax
8010328a:	e8 43 ff ff ff       	call   801031d2 <fill_rtcdate>
8010328f:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103292:	83 ec 04             	sub    $0x4,%esp
80103295:	6a 18                	push   $0x18
80103297:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010329a:	50                   	push   %eax
8010329b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010329e:	50                   	push   %eax
8010329f:	e8 7d 20 00 00       	call   80105321 <memcmp>
801032a4:	83 c4 10             	add    $0x10,%esp
801032a7:	85 c0                	test   %eax,%eax
801032a9:	74 05                	je     801032b0 <cmostime+0x6d>
801032ab:	eb ba                	jmp    80103267 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032ad:	90                   	nop
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032ae:	eb b7                	jmp    80103267 <cmostime+0x24>
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032b0:	90                   	nop
  }

  // convert
  if(bcd) {
801032b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032b5:	0f 84 b4 00 00 00    	je     8010336f <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032be:	c1 e8 04             	shr    $0x4,%eax
801032c1:	89 c2                	mov    %eax,%edx
801032c3:	89 d0                	mov    %edx,%eax
801032c5:	c1 e0 02             	shl    $0x2,%eax
801032c8:	01 d0                	add    %edx,%eax
801032ca:	01 c0                	add    %eax,%eax
801032cc:	89 c2                	mov    %eax,%edx
801032ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032d1:	83 e0 0f             	and    $0xf,%eax
801032d4:	01 d0                	add    %edx,%eax
801032d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801032d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032dc:	c1 e8 04             	shr    $0x4,%eax
801032df:	89 c2                	mov    %eax,%edx
801032e1:	89 d0                	mov    %edx,%eax
801032e3:	c1 e0 02             	shl    $0x2,%eax
801032e6:	01 d0                	add    %edx,%eax
801032e8:	01 c0                	add    %eax,%eax
801032ea:	89 c2                	mov    %eax,%edx
801032ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032ef:	83 e0 0f             	and    $0xf,%eax
801032f2:	01 d0                	add    %edx,%eax
801032f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032fa:	c1 e8 04             	shr    $0x4,%eax
801032fd:	89 c2                	mov    %eax,%edx
801032ff:	89 d0                	mov    %edx,%eax
80103301:	c1 e0 02             	shl    $0x2,%eax
80103304:	01 d0                	add    %edx,%eax
80103306:	01 c0                	add    %eax,%eax
80103308:	89 c2                	mov    %eax,%edx
8010330a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010330d:	83 e0 0f             	and    $0xf,%eax
80103310:	01 d0                	add    %edx,%eax
80103312:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103315:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103318:	c1 e8 04             	shr    $0x4,%eax
8010331b:	89 c2                	mov    %eax,%edx
8010331d:	89 d0                	mov    %edx,%eax
8010331f:	c1 e0 02             	shl    $0x2,%eax
80103322:	01 d0                	add    %edx,%eax
80103324:	01 c0                	add    %eax,%eax
80103326:	89 c2                	mov    %eax,%edx
80103328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010332b:	83 e0 0f             	and    $0xf,%eax
8010332e:	01 d0                	add    %edx,%eax
80103330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103333:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103336:	c1 e8 04             	shr    $0x4,%eax
80103339:	89 c2                	mov    %eax,%edx
8010333b:	89 d0                	mov    %edx,%eax
8010333d:	c1 e0 02             	shl    $0x2,%eax
80103340:	01 d0                	add    %edx,%eax
80103342:	01 c0                	add    %eax,%eax
80103344:	89 c2                	mov    %eax,%edx
80103346:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103349:	83 e0 0f             	and    $0xf,%eax
8010334c:	01 d0                	add    %edx,%eax
8010334e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103351:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103354:	c1 e8 04             	shr    $0x4,%eax
80103357:	89 c2                	mov    %eax,%edx
80103359:	89 d0                	mov    %edx,%eax
8010335b:	c1 e0 02             	shl    $0x2,%eax
8010335e:	01 d0                	add    %edx,%eax
80103360:	01 c0                	add    %eax,%eax
80103362:	89 c2                	mov    %eax,%edx
80103364:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103367:	83 e0 0f             	and    $0xf,%eax
8010336a:	01 d0                	add    %edx,%eax
8010336c:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010336f:	8b 45 08             	mov    0x8(%ebp),%eax
80103372:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103375:	89 10                	mov    %edx,(%eax)
80103377:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010337a:	89 50 04             	mov    %edx,0x4(%eax)
8010337d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103380:	89 50 08             	mov    %edx,0x8(%eax)
80103383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103386:	89 50 0c             	mov    %edx,0xc(%eax)
80103389:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010338c:	89 50 10             	mov    %edx,0x10(%eax)
8010338f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103392:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103395:	8b 45 08             	mov    0x8(%ebp),%eax
80103398:	8b 40 14             	mov    0x14(%eax),%eax
8010339b:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033a1:	8b 45 08             	mov    0x8(%ebp),%eax
801033a4:	89 50 14             	mov    %edx,0x14(%eax)
}
801033a7:	90                   	nop
801033a8:	c9                   	leave  
801033a9:	c3                   	ret    

801033aa <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033aa:	55                   	push   %ebp
801033ab:	89 e5                	mov    %esp,%ebp
801033ad:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033b0:	83 ec 08             	sub    $0x8,%esp
801033b3:	68 4d 89 10 80       	push   $0x8010894d
801033b8:	68 00 37 11 80       	push   $0x80113700
801033bd:	e8 5f 1c 00 00       	call   80105021 <initlock>
801033c2:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033c5:	83 ec 08             	sub    $0x8,%esp
801033c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033cb:	50                   	push   %eax
801033cc:	ff 75 08             	pushl  0x8(%ebp)
801033cf:	e8 a3 e0 ff ff       	call   80101477 <readsb>
801033d4:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033da:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
801033df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033e2:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
801033e7:	8b 45 08             	mov    0x8(%ebp),%eax
801033ea:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
801033ef:	e8 b2 01 00 00       	call   801035a6 <recover_from_log>
}
801033f4:	90                   	nop
801033f5:	c9                   	leave  
801033f6:	c3                   	ret    

801033f7 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801033f7:	55                   	push   %ebp
801033f8:	89 e5                	mov    %esp,%ebp
801033fa:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103404:	e9 95 00 00 00       	jmp    8010349e <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103409:	8b 15 34 37 11 80    	mov    0x80113734,%edx
8010340f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103412:	01 d0                	add    %edx,%eax
80103414:	83 c0 01             	add    $0x1,%eax
80103417:	89 c2                	mov    %eax,%edx
80103419:	a1 44 37 11 80       	mov    0x80113744,%eax
8010341e:	83 ec 08             	sub    $0x8,%esp
80103421:	52                   	push   %edx
80103422:	50                   	push   %eax
80103423:	e8 a6 cd ff ff       	call   801001ce <bread>
80103428:	83 c4 10             	add    $0x10,%esp
8010342b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103431:	83 c0 10             	add    $0x10,%eax
80103434:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010343b:	89 c2                	mov    %eax,%edx
8010343d:	a1 44 37 11 80       	mov    0x80113744,%eax
80103442:	83 ec 08             	sub    $0x8,%esp
80103445:	52                   	push   %edx
80103446:	50                   	push   %eax
80103447:	e8 82 cd ff ff       	call   801001ce <bread>
8010344c:	83 c4 10             	add    $0x10,%esp
8010344f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103452:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103455:	8d 50 5c             	lea    0x5c(%eax),%edx
80103458:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345b:	83 c0 5c             	add    $0x5c,%eax
8010345e:	83 ec 04             	sub    $0x4,%esp
80103461:	68 00 02 00 00       	push   $0x200
80103466:	52                   	push   %edx
80103467:	50                   	push   %eax
80103468:	e8 0c 1f 00 00       	call   80105379 <memmove>
8010346d:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103470:	83 ec 0c             	sub    $0xc,%esp
80103473:	ff 75 ec             	pushl  -0x14(%ebp)
80103476:	e8 8c cd ff ff       	call   80100207 <bwrite>
8010347b:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010347e:	83 ec 0c             	sub    $0xc,%esp
80103481:	ff 75 f0             	pushl  -0x10(%ebp)
80103484:	e8 c7 cd ff ff       	call   80100250 <brelse>
80103489:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010348c:	83 ec 0c             	sub    $0xc,%esp
8010348f:	ff 75 ec             	pushl  -0x14(%ebp)
80103492:	e8 b9 cd ff ff       	call   80100250 <brelse>
80103497:	83 c4 10             	add    $0x10,%esp
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010349a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010349e:	a1 48 37 11 80       	mov    0x80113748,%eax
801034a3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034a6:	0f 8f 5d ff ff ff    	jg     80103409 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801034ac:	90                   	nop
801034ad:	c9                   	leave  
801034ae:	c3                   	ret    

801034af <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034af:	55                   	push   %ebp
801034b0:	89 e5                	mov    %esp,%ebp
801034b2:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034b5:	a1 34 37 11 80       	mov    0x80113734,%eax
801034ba:	89 c2                	mov    %eax,%edx
801034bc:	a1 44 37 11 80       	mov    0x80113744,%eax
801034c1:	83 ec 08             	sub    $0x8,%esp
801034c4:	52                   	push   %edx
801034c5:	50                   	push   %eax
801034c6:	e8 03 cd ff ff       	call   801001ce <bread>
801034cb:	83 c4 10             	add    $0x10,%esp
801034ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	83 c0 5c             	add    $0x5c,%eax
801034d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dd:	8b 00                	mov    (%eax),%eax
801034df:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
801034e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034eb:	eb 1b                	jmp    80103508 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
801034ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034f3:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fa:	83 c2 10             	add    $0x10,%edx
801034fd:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103504:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103508:	a1 48 37 11 80       	mov    0x80113748,%eax
8010350d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103510:	7f db                	jg     801034ed <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103512:	83 ec 0c             	sub    $0xc,%esp
80103515:	ff 75 f0             	pushl  -0x10(%ebp)
80103518:	e8 33 cd ff ff       	call   80100250 <brelse>
8010351d:	83 c4 10             	add    $0x10,%esp
}
80103520:	90                   	nop
80103521:	c9                   	leave  
80103522:	c3                   	ret    

80103523 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103523:	55                   	push   %ebp
80103524:	89 e5                	mov    %esp,%ebp
80103526:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103529:	a1 34 37 11 80       	mov    0x80113734,%eax
8010352e:	89 c2                	mov    %eax,%edx
80103530:	a1 44 37 11 80       	mov    0x80113744,%eax
80103535:	83 ec 08             	sub    $0x8,%esp
80103538:	52                   	push   %edx
80103539:	50                   	push   %eax
8010353a:	e8 8f cc ff ff       	call   801001ce <bread>
8010353f:	83 c4 10             	add    $0x10,%esp
80103542:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103548:	83 c0 5c             	add    $0x5c,%eax
8010354b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010354e:	8b 15 48 37 11 80    	mov    0x80113748,%edx
80103554:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103557:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103559:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103560:	eb 1b                	jmp    8010357d <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103565:	83 c0 10             	add    $0x10,%eax
80103568:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
8010356f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103572:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103575:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103579:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010357d:	a1 48 37 11 80       	mov    0x80113748,%eax
80103582:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103585:	7f db                	jg     80103562 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103587:	83 ec 0c             	sub    $0xc,%esp
8010358a:	ff 75 f0             	pushl  -0x10(%ebp)
8010358d:	e8 75 cc ff ff       	call   80100207 <bwrite>
80103592:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103595:	83 ec 0c             	sub    $0xc,%esp
80103598:	ff 75 f0             	pushl  -0x10(%ebp)
8010359b:	e8 b0 cc ff ff       	call   80100250 <brelse>
801035a0:	83 c4 10             	add    $0x10,%esp
}
801035a3:	90                   	nop
801035a4:	c9                   	leave  
801035a5:	c3                   	ret    

801035a6 <recover_from_log>:

static void
recover_from_log(void)
{
801035a6:	55                   	push   %ebp
801035a7:	89 e5                	mov    %esp,%ebp
801035a9:	83 ec 08             	sub    $0x8,%esp
  read_head();
801035ac:	e8 fe fe ff ff       	call   801034af <read_head>
  install_trans(); // if committed, copy from log to disk
801035b1:	e8 41 fe ff ff       	call   801033f7 <install_trans>
  log.lh.n = 0;
801035b6:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
801035bd:	00 00 00 
  write_head(); // clear the log
801035c0:	e8 5e ff ff ff       	call   80103523 <write_head>
}
801035c5:	90                   	nop
801035c6:	c9                   	leave  
801035c7:	c3                   	ret    

801035c8 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035c8:	55                   	push   %ebp
801035c9:	89 e5                	mov    %esp,%ebp
801035cb:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035ce:	83 ec 0c             	sub    $0xc,%esp
801035d1:	68 00 37 11 80       	push   $0x80113700
801035d6:	e8 68 1a 00 00       	call   80105043 <acquire>
801035db:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801035de:	a1 40 37 11 80       	mov    0x80113740,%eax
801035e3:	85 c0                	test   %eax,%eax
801035e5:	74 17                	je     801035fe <begin_op+0x36>
      sleep(&log, &log.lock);
801035e7:	83 ec 08             	sub    $0x8,%esp
801035ea:	68 00 37 11 80       	push   $0x80113700
801035ef:	68 00 37 11 80       	push   $0x80113700
801035f4:	e8 28 16 00 00       	call   80104c21 <sleep>
801035f9:	83 c4 10             	add    $0x10,%esp
801035fc:	eb e0                	jmp    801035de <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035fe:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
80103604:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103609:	8d 50 01             	lea    0x1(%eax),%edx
8010360c:	89 d0                	mov    %edx,%eax
8010360e:	c1 e0 02             	shl    $0x2,%eax
80103611:	01 d0                	add    %edx,%eax
80103613:	01 c0                	add    %eax,%eax
80103615:	01 c8                	add    %ecx,%eax
80103617:	83 f8 1e             	cmp    $0x1e,%eax
8010361a:	7e 17                	jle    80103633 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010361c:	83 ec 08             	sub    $0x8,%esp
8010361f:	68 00 37 11 80       	push   $0x80113700
80103624:	68 00 37 11 80       	push   $0x80113700
80103629:	e8 f3 15 00 00       	call   80104c21 <sleep>
8010362e:	83 c4 10             	add    $0x10,%esp
80103631:	eb ab                	jmp    801035de <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103633:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103638:	83 c0 01             	add    $0x1,%eax
8010363b:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
80103640:	83 ec 0c             	sub    $0xc,%esp
80103643:	68 00 37 11 80       	push   $0x80113700
80103648:	e8 64 1a 00 00       	call   801050b1 <release>
8010364d:	83 c4 10             	add    $0x10,%esp
      break;
80103650:	90                   	nop
    }
  }
}
80103651:	90                   	nop
80103652:	c9                   	leave  
80103653:	c3                   	ret    

80103654 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103654:	55                   	push   %ebp
80103655:	89 e5                	mov    %esp,%ebp
80103657:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010365a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103661:	83 ec 0c             	sub    $0xc,%esp
80103664:	68 00 37 11 80       	push   $0x80113700
80103669:	e8 d5 19 00 00       	call   80105043 <acquire>
8010366e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103671:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103676:	83 e8 01             	sub    $0x1,%eax
80103679:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
8010367e:	a1 40 37 11 80       	mov    0x80113740,%eax
80103683:	85 c0                	test   %eax,%eax
80103685:	74 0d                	je     80103694 <end_op+0x40>
    panic("log.committing");
80103687:	83 ec 0c             	sub    $0xc,%esp
8010368a:	68 51 89 10 80       	push   $0x80108951
8010368f:	e8 0c cf ff ff       	call   801005a0 <panic>
  if(log.outstanding == 0){
80103694:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	75 13                	jne    801036b0 <end_op+0x5c>
    do_commit = 1;
8010369d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036a4:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
801036ab:	00 00 00 
801036ae:	eb 10                	jmp    801036c0 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	68 00 37 11 80       	push   $0x80113700
801036b8:	e8 4d 16 00 00       	call   80104d0a <wakeup>
801036bd:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036c0:	83 ec 0c             	sub    $0xc,%esp
801036c3:	68 00 37 11 80       	push   $0x80113700
801036c8:	e8 e4 19 00 00       	call   801050b1 <release>
801036cd:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036d4:	74 3f                	je     80103715 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036d6:	e8 f5 00 00 00       	call   801037d0 <commit>
    acquire(&log.lock);
801036db:	83 ec 0c             	sub    $0xc,%esp
801036de:	68 00 37 11 80       	push   $0x80113700
801036e3:	e8 5b 19 00 00       	call   80105043 <acquire>
801036e8:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801036eb:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
801036f2:	00 00 00 
    wakeup(&log);
801036f5:	83 ec 0c             	sub    $0xc,%esp
801036f8:	68 00 37 11 80       	push   $0x80113700
801036fd:	e8 08 16 00 00       	call   80104d0a <wakeup>
80103702:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	68 00 37 11 80       	push   $0x80113700
8010370d:	e8 9f 19 00 00       	call   801050b1 <release>
80103712:	83 c4 10             	add    $0x10,%esp
  }
}
80103715:	90                   	nop
80103716:	c9                   	leave  
80103717:	c3                   	ret    

80103718 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103718:	55                   	push   %ebp
80103719:	89 e5                	mov    %esp,%ebp
8010371b:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010371e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103725:	e9 95 00 00 00       	jmp    801037bf <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010372a:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103733:	01 d0                	add    %edx,%eax
80103735:	83 c0 01             	add    $0x1,%eax
80103738:	89 c2                	mov    %eax,%edx
8010373a:	a1 44 37 11 80       	mov    0x80113744,%eax
8010373f:	83 ec 08             	sub    $0x8,%esp
80103742:	52                   	push   %edx
80103743:	50                   	push   %eax
80103744:	e8 85 ca ff ff       	call   801001ce <bread>
80103749:	83 c4 10             	add    $0x10,%esp
8010374c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010374f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103752:	83 c0 10             	add    $0x10,%eax
80103755:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010375c:	89 c2                	mov    %eax,%edx
8010375e:	a1 44 37 11 80       	mov    0x80113744,%eax
80103763:	83 ec 08             	sub    $0x8,%esp
80103766:	52                   	push   %edx
80103767:	50                   	push   %eax
80103768:	e8 61 ca ff ff       	call   801001ce <bread>
8010376d:	83 c4 10             	add    $0x10,%esp
80103770:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103773:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103776:	8d 50 5c             	lea    0x5c(%eax),%edx
80103779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010377c:	83 c0 5c             	add    $0x5c,%eax
8010377f:	83 ec 04             	sub    $0x4,%esp
80103782:	68 00 02 00 00       	push   $0x200
80103787:	52                   	push   %edx
80103788:	50                   	push   %eax
80103789:	e8 eb 1b 00 00       	call   80105379 <memmove>
8010378e:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	ff 75 f0             	pushl  -0x10(%ebp)
80103797:	e8 6b ca ff ff       	call   80100207 <bwrite>
8010379c:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010379f:	83 ec 0c             	sub    $0xc,%esp
801037a2:	ff 75 ec             	pushl  -0x14(%ebp)
801037a5:	e8 a6 ca ff ff       	call   80100250 <brelse>
801037aa:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037ad:	83 ec 0c             	sub    $0xc,%esp
801037b0:	ff 75 f0             	pushl  -0x10(%ebp)
801037b3:	e8 98 ca ff ff       	call   80100250 <brelse>
801037b8:	83 c4 10             	add    $0x10,%esp
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037bf:	a1 48 37 11 80       	mov    0x80113748,%eax
801037c4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037c7:	0f 8f 5d ff ff ff    	jg     8010372a <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801037cd:	90                   	nop
801037ce:	c9                   	leave  
801037cf:	c3                   	ret    

801037d0 <commit>:

static void
commit()
{
801037d0:	55                   	push   %ebp
801037d1:	89 e5                	mov    %esp,%ebp
801037d3:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037d6:	a1 48 37 11 80       	mov    0x80113748,%eax
801037db:	85 c0                	test   %eax,%eax
801037dd:	7e 1e                	jle    801037fd <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037df:	e8 34 ff ff ff       	call   80103718 <write_log>
    write_head();    // Write header to disk -- the real commit
801037e4:	e8 3a fd ff ff       	call   80103523 <write_head>
    install_trans(); // Now install writes to home locations
801037e9:	e8 09 fc ff ff       	call   801033f7 <install_trans>
    log.lh.n = 0;
801037ee:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
801037f5:	00 00 00 
    write_head();    // Erase the transaction from the log
801037f8:	e8 26 fd ff ff       	call   80103523 <write_head>
  }
}
801037fd:	90                   	nop
801037fe:	c9                   	leave  
801037ff:	c3                   	ret    

80103800 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103800:	55                   	push   %ebp
80103801:	89 e5                	mov    %esp,%ebp
80103803:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103806:	a1 48 37 11 80       	mov    0x80113748,%eax
8010380b:	83 f8 1d             	cmp    $0x1d,%eax
8010380e:	7f 12                	jg     80103822 <log_write+0x22>
80103810:	a1 48 37 11 80       	mov    0x80113748,%eax
80103815:	8b 15 38 37 11 80    	mov    0x80113738,%edx
8010381b:	83 ea 01             	sub    $0x1,%edx
8010381e:	39 d0                	cmp    %edx,%eax
80103820:	7c 0d                	jl     8010382f <log_write+0x2f>
    panic("too big a transaction");
80103822:	83 ec 0c             	sub    $0xc,%esp
80103825:	68 60 89 10 80       	push   $0x80108960
8010382a:	e8 71 cd ff ff       	call   801005a0 <panic>
  if (log.outstanding < 1)
8010382f:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103834:	85 c0                	test   %eax,%eax
80103836:	7f 0d                	jg     80103845 <log_write+0x45>
    panic("log_write outside of trans");
80103838:	83 ec 0c             	sub    $0xc,%esp
8010383b:	68 76 89 10 80       	push   $0x80108976
80103840:	e8 5b cd ff ff       	call   801005a0 <panic>

  acquire(&log.lock);
80103845:	83 ec 0c             	sub    $0xc,%esp
80103848:	68 00 37 11 80       	push   $0x80113700
8010384d:	e8 f1 17 00 00       	call   80105043 <acquire>
80103852:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010385c:	eb 1d                	jmp    8010387b <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010385e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103861:	83 c0 10             	add    $0x10,%eax
80103864:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
8010386b:	89 c2                	mov    %eax,%edx
8010386d:	8b 45 08             	mov    0x8(%ebp),%eax
80103870:	8b 40 08             	mov    0x8(%eax),%eax
80103873:	39 c2                	cmp    %eax,%edx
80103875:	74 10                	je     80103887 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103877:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010387b:	a1 48 37 11 80       	mov    0x80113748,%eax
80103880:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103883:	7f d9                	jg     8010385e <log_write+0x5e>
80103885:	eb 01                	jmp    80103888 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103887:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103888:	8b 45 08             	mov    0x8(%ebp),%eax
8010388b:	8b 40 08             	mov    0x8(%eax),%eax
8010388e:	89 c2                	mov    %eax,%edx
80103890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103893:	83 c0 10             	add    $0x10,%eax
80103896:	89 14 85 0c 37 11 80 	mov    %edx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
8010389d:	a1 48 37 11 80       	mov    0x80113748,%eax
801038a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038a5:	75 0d                	jne    801038b4 <log_write+0xb4>
    log.lh.n++;
801038a7:	a1 48 37 11 80       	mov    0x80113748,%eax
801038ac:	83 c0 01             	add    $0x1,%eax
801038af:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
801038b4:	8b 45 08             	mov    0x8(%ebp),%eax
801038b7:	8b 00                	mov    (%eax),%eax
801038b9:	83 c8 04             	or     $0x4,%eax
801038bc:	89 c2                	mov    %eax,%edx
801038be:	8b 45 08             	mov    0x8(%ebp),%eax
801038c1:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038c3:	83 ec 0c             	sub    $0xc,%esp
801038c6:	68 00 37 11 80       	push   $0x80113700
801038cb:	e8 e1 17 00 00       	call   801050b1 <release>
801038d0:	83 c4 10             	add    $0x10,%esp
}
801038d3:	90                   	nop
801038d4:	c9                   	leave  
801038d5:	c3                   	ret    

801038d6 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038d6:	55                   	push   %ebp
801038d7:	89 e5                	mov    %esp,%ebp
801038d9:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038dc:	8b 55 08             	mov    0x8(%ebp),%edx
801038df:	8b 45 0c             	mov    0xc(%ebp),%eax
801038e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038e5:	f0 87 02             	lock xchg %eax,(%edx)
801038e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038ee:	c9                   	leave  
801038ef:	c3                   	ret    

801038f0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038f0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038f4:	83 e4 f0             	and    $0xfffffff0,%esp
801038f7:	ff 71 fc             	pushl  -0x4(%ecx)
801038fa:	55                   	push   %ebp
801038fb:	89 e5                	mov    %esp,%ebp
801038fd:	51                   	push   %ecx
801038fe:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103901:	83 ec 08             	sub    $0x8,%esp
80103904:	68 00 00 40 80       	push   $0x80400000
80103909:	68 74 6a 11 80       	push   $0x80116a74
8010390e:	e8 e1 f2 ff ff       	call   80102bf4 <kinit1>
80103913:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103916:	e8 04 44 00 00       	call   80107d1f <kvmalloc>
  mpinit();        // detect other processors
8010391b:	e8 bf 03 00 00       	call   80103cdf <mpinit>
  lapicinit();     // interrupt controller
80103920:	e8 3b f6 ff ff       	call   80102f60 <lapicinit>
  seginit();       // segment descriptors
80103925:	e8 e0 3e 00 00       	call   8010780a <seginit>
  picinit();       // disable pic
8010392a:	e8 01 05 00 00       	call   80103e30 <picinit>
  ioapicinit();    // another interrupt controller
8010392f:	e8 dc f1 ff ff       	call   80102b10 <ioapicinit>
  consoleinit();   // console hardware
80103934:	e8 12 d2 ff ff       	call   80100b4b <consoleinit>
  uartinit();      // serial port
80103939:	e8 65 32 00 00       	call   80106ba3 <uartinit>
  pinit();         // process table
8010393e:	e8 26 09 00 00       	call   80104269 <pinit>
  shminit();       // shared memory
80103943:	e8 b1 4c 00 00       	call   801085f9 <shminit>
  tvinit();        // trap vectors
80103948:	e8 c9 2d 00 00       	call   80106716 <tvinit>
  binit();         // buffer cache
8010394d:	e8 e2 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103952:	e8 11 d7 ff ff       	call   80101068 <fileinit>
  ideinit();       // disk 
80103957:	e8 8b ed ff ff       	call   801026e7 <ideinit>
  startothers();   // start other processors
8010395c:	e8 80 00 00 00       	call   801039e1 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103961:	83 ec 08             	sub    $0x8,%esp
80103964:	68 00 00 00 8e       	push   $0x8e000000
80103969:	68 00 00 40 80       	push   $0x80400000
8010396e:	e8 ba f2 ff ff       	call   80102c2d <kinit2>
80103973:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103976:	e8 d7 0a 00 00       	call   80104452 <userinit>
  mpmain();        // finish this processor's setup
8010397b:	e8 1a 00 00 00       	call   8010399a <mpmain>

80103980 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103980:	55                   	push   %ebp
80103981:	89 e5                	mov    %esp,%ebp
80103983:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103986:	e8 ac 43 00 00       	call   80107d37 <switchkvm>
  seginit();
8010398b:	e8 7a 3e 00 00       	call   8010780a <seginit>
  lapicinit();
80103990:	e8 cb f5 ff ff       	call   80102f60 <lapicinit>
  mpmain();
80103995:	e8 00 00 00 00       	call   8010399a <mpmain>

8010399a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010399a:	55                   	push   %ebp
8010399b:	89 e5                	mov    %esp,%ebp
8010399d:	53                   	push   %ebx
8010399e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801039a1:	e8 e1 08 00 00       	call   80104287 <cpuid>
801039a6:	89 c3                	mov    %eax,%ebx
801039a8:	e8 da 08 00 00       	call   80104287 <cpuid>
801039ad:	83 ec 04             	sub    $0x4,%esp
801039b0:	53                   	push   %ebx
801039b1:	50                   	push   %eax
801039b2:	68 91 89 10 80       	push   $0x80108991
801039b7:	e8 44 ca ff ff       	call   80100400 <cprintf>
801039bc:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039bf:	e8 c8 2e 00 00       	call   8010688c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039c4:	e8 df 08 00 00       	call   801042a8 <mycpu>
801039c9:	05 a0 00 00 00       	add    $0xa0,%eax
801039ce:	83 ec 08             	sub    $0x8,%esp
801039d1:	6a 01                	push   $0x1
801039d3:	50                   	push   %eax
801039d4:	e8 fd fe ff ff       	call   801038d6 <xchg>
801039d9:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039dc:	e8 4a 10 00 00       	call   80104a2b <scheduler>

801039e1 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039e1:	55                   	push   %ebp
801039e2:	89 e5                	mov    %esp,%ebp
801039e4:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801039e7:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039ee:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039f3:	83 ec 04             	sub    $0x4,%esp
801039f6:	50                   	push   %eax
801039f7:	68 ec b4 10 80       	push   $0x8010b4ec
801039fc:	ff 75 f0             	pushl  -0x10(%ebp)
801039ff:	e8 75 19 00 00       	call   80105379 <memmove>
80103a04:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a07:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
80103a0e:	eb 79                	jmp    80103a89 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103a10:	e8 93 08 00 00       	call   801042a8 <mycpu>
80103a15:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a18:	74 67                	je     80103a81 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a1a:	e8 09 f3 ff ff       	call   80102d28 <kalloc>
80103a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a25:	83 e8 04             	sub    $0x4,%eax
80103a28:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a31:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a36:	83 e8 08             	sub    $0x8,%eax
80103a39:	c7 00 80 39 10 80    	movl   $0x80103980,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a42:	83 e8 0c             	sub    $0xc,%eax
80103a45:	ba 00 a0 10 80       	mov    $0x8010a000,%edx
80103a4a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80103a50:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a55:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	0f b6 00             	movzbl (%eax),%eax
80103a61:	0f b6 c0             	movzbl %al,%eax
80103a64:	83 ec 08             	sub    $0x8,%esp
80103a67:	52                   	push   %edx
80103a68:	50                   	push   %eax
80103a69:	e8 53 f6 ff ff       	call   801030c1 <lapicstartap>
80103a6e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a71:	90                   	nop
80103a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a75:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a7b:	85 c0                	test   %eax,%eax
80103a7d:	74 f3                	je     80103a72 <startothers+0x91>
80103a7f:	eb 01                	jmp    80103a82 <startothers+0xa1>
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == mycpu())  // We've started already.
      continue;
80103a81:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a82:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a89:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103a8e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a94:	05 00 38 11 80       	add    $0x80113800,%eax
80103a99:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a9c:	0f 87 6e ff ff ff    	ja     80103a10 <startothers+0x2f>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103aa2:	90                   	nop
80103aa3:	c9                   	leave  
80103aa4:	c3                   	ret    

80103aa5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103aa5:	55                   	push   %ebp
80103aa6:	89 e5                	mov    %esp,%ebp
80103aa8:	83 ec 14             	sub    $0x14,%esp
80103aab:	8b 45 08             	mov    0x8(%ebp),%eax
80103aae:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ab2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ab6:	89 c2                	mov    %eax,%edx
80103ab8:	ec                   	in     (%dx),%al
80103ab9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103abc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ac0:	c9                   	leave  
80103ac1:	c3                   	ret    

80103ac2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ac2:	55                   	push   %ebp
80103ac3:	89 e5                	mov    %esp,%ebp
80103ac5:	83 ec 08             	sub    $0x8,%esp
80103ac8:	8b 55 08             	mov    0x8(%ebp),%edx
80103acb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ace:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ad2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ad5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103add:	ee                   	out    %al,(%dx)
}
80103ade:	90                   	nop
80103adf:	c9                   	leave  
80103ae0:	c3                   	ret    

80103ae1 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103ae1:	55                   	push   %ebp
80103ae2:	89 e5                	mov    %esp,%ebp
80103ae4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103ae7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103aee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103af5:	eb 15                	jmp    80103b0c <sum+0x2b>
    sum += addr[i];
80103af7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103afa:	8b 45 08             	mov    0x8(%ebp),%eax
80103afd:	01 d0                	add    %edx,%eax
80103aff:	0f b6 00             	movzbl (%eax),%eax
80103b02:	0f b6 c0             	movzbl %al,%eax
80103b05:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b08:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b0f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b12:	7c e3                	jl     80103af7 <sum+0x16>
    sum += addr[i];
  return sum;
80103b14:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b17:	c9                   	leave  
80103b18:	c3                   	ret    

80103b19 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b19:	55                   	push   %ebp
80103b1a:	89 e5                	mov    %esp,%ebp
80103b1c:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b22:	05 00 00 00 80       	add    $0x80000000,%eax
80103b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	01 d0                	add    %edx,%eax
80103b32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b3b:	eb 36                	jmp    80103b73 <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b3d:	83 ec 04             	sub    $0x4,%esp
80103b40:	6a 04                	push   $0x4
80103b42:	68 a8 89 10 80       	push   $0x801089a8
80103b47:	ff 75 f4             	pushl  -0xc(%ebp)
80103b4a:	e8 d2 17 00 00       	call   80105321 <memcmp>
80103b4f:	83 c4 10             	add    $0x10,%esp
80103b52:	85 c0                	test   %eax,%eax
80103b54:	75 19                	jne    80103b6f <mpsearch1+0x56>
80103b56:	83 ec 08             	sub    $0x8,%esp
80103b59:	6a 10                	push   $0x10
80103b5b:	ff 75 f4             	pushl  -0xc(%ebp)
80103b5e:	e8 7e ff ff ff       	call   80103ae1 <sum>
80103b63:	83 c4 10             	add    $0x10,%esp
80103b66:	84 c0                	test   %al,%al
80103b68:	75 05                	jne    80103b6f <mpsearch1+0x56>
      return (struct mp*)p;
80103b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6d:	eb 11                	jmp    80103b80 <mpsearch1+0x67>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b6f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b79:	72 c2                	jb     80103b3d <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b80:	c9                   	leave  
80103b81:	c3                   	ret    

80103b82 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b82:	55                   	push   %ebp
80103b83:	89 e5                	mov    %esp,%ebp
80103b85:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b88:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b92:	83 c0 0f             	add    $0xf,%eax
80103b95:	0f b6 00             	movzbl (%eax),%eax
80103b98:	0f b6 c0             	movzbl %al,%eax
80103b9b:	c1 e0 08             	shl    $0x8,%eax
80103b9e:	89 c2                	mov    %eax,%edx
80103ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba3:	83 c0 0e             	add    $0xe,%eax
80103ba6:	0f b6 00             	movzbl (%eax),%eax
80103ba9:	0f b6 c0             	movzbl %al,%eax
80103bac:	09 d0                	or     %edx,%eax
80103bae:	c1 e0 04             	shl    $0x4,%eax
80103bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb8:	74 21                	je     80103bdb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bba:	83 ec 08             	sub    $0x8,%esp
80103bbd:	68 00 04 00 00       	push   $0x400
80103bc2:	ff 75 f0             	pushl  -0x10(%ebp)
80103bc5:	e8 4f ff ff ff       	call   80103b19 <mpsearch1>
80103bca:	83 c4 10             	add    $0x10,%esp
80103bcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bd0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bd4:	74 51                	je     80103c27 <mpsearch+0xa5>
      return mp;
80103bd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd9:	eb 61                	jmp    80103c3c <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bde:	83 c0 14             	add    $0x14,%eax
80103be1:	0f b6 00             	movzbl (%eax),%eax
80103be4:	0f b6 c0             	movzbl %al,%eax
80103be7:	c1 e0 08             	shl    $0x8,%eax
80103bea:	89 c2                	mov    %eax,%edx
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	83 c0 13             	add    $0x13,%eax
80103bf2:	0f b6 00             	movzbl (%eax),%eax
80103bf5:	0f b6 c0             	movzbl %al,%eax
80103bf8:	09 d0                	or     %edx,%eax
80103bfa:	c1 e0 0a             	shl    $0xa,%eax
80103bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c03:	2d 00 04 00 00       	sub    $0x400,%eax
80103c08:	83 ec 08             	sub    $0x8,%esp
80103c0b:	68 00 04 00 00       	push   $0x400
80103c10:	50                   	push   %eax
80103c11:	e8 03 ff ff ff       	call   80103b19 <mpsearch1>
80103c16:	83 c4 10             	add    $0x10,%esp
80103c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c20:	74 05                	je     80103c27 <mpsearch+0xa5>
      return mp;
80103c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c25:	eb 15                	jmp    80103c3c <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c27:	83 ec 08             	sub    $0x8,%esp
80103c2a:	68 00 00 01 00       	push   $0x10000
80103c2f:	68 00 00 0f 00       	push   $0xf0000
80103c34:	e8 e0 fe ff ff       	call   80103b19 <mpsearch1>
80103c39:	83 c4 10             	add    $0x10,%esp
}
80103c3c:	c9                   	leave  
80103c3d:	c3                   	ret    

80103c3e <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c3e:	55                   	push   %ebp
80103c3f:	89 e5                	mov    %esp,%ebp
80103c41:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c44:	e8 39 ff ff ff       	call   80103b82 <mpsearch>
80103c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c50:	74 0a                	je     80103c5c <mpconfig+0x1e>
80103c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c55:	8b 40 04             	mov    0x4(%eax),%eax
80103c58:	85 c0                	test   %eax,%eax
80103c5a:	75 07                	jne    80103c63 <mpconfig+0x25>
    return 0;
80103c5c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c61:	eb 7a                	jmp    80103cdd <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c66:	8b 40 04             	mov    0x4(%eax),%eax
80103c69:	05 00 00 00 80       	add    $0x80000000,%eax
80103c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c71:	83 ec 04             	sub    $0x4,%esp
80103c74:	6a 04                	push   $0x4
80103c76:	68 ad 89 10 80       	push   $0x801089ad
80103c7b:	ff 75 f0             	pushl  -0x10(%ebp)
80103c7e:	e8 9e 16 00 00       	call   80105321 <memcmp>
80103c83:	83 c4 10             	add    $0x10,%esp
80103c86:	85 c0                	test   %eax,%eax
80103c88:	74 07                	je     80103c91 <mpconfig+0x53>
    return 0;
80103c8a:	b8 00 00 00 00       	mov    $0x0,%eax
80103c8f:	eb 4c                	jmp    80103cdd <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c94:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c98:	3c 01                	cmp    $0x1,%al
80103c9a:	74 12                	je     80103cae <mpconfig+0x70>
80103c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9f:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ca3:	3c 04                	cmp    $0x4,%al
80103ca5:	74 07                	je     80103cae <mpconfig+0x70>
    return 0;
80103ca7:	b8 00 00 00 00       	mov    $0x0,%eax
80103cac:	eb 2f                	jmp    80103cdd <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cb5:	0f b7 c0             	movzwl %ax,%eax
80103cb8:	83 ec 08             	sub    $0x8,%esp
80103cbb:	50                   	push   %eax
80103cbc:	ff 75 f0             	pushl  -0x10(%ebp)
80103cbf:	e8 1d fe ff ff       	call   80103ae1 <sum>
80103cc4:	83 c4 10             	add    $0x10,%esp
80103cc7:	84 c0                	test   %al,%al
80103cc9:	74 07                	je     80103cd2 <mpconfig+0x94>
    return 0;
80103ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd0:	eb 0b                	jmp    80103cdd <mpconfig+0x9f>
  *pmp = mp;
80103cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd8:	89 10                	mov    %edx,(%eax)
  return conf;
80103cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103cdd:	c9                   	leave  
80103cde:	c3                   	ret    

80103cdf <mpinit>:

void
mpinit(void)
{
80103cdf:	55                   	push   %ebp
80103ce0:	89 e5                	mov    %esp,%ebp
80103ce2:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ce5:	83 ec 0c             	sub    $0xc,%esp
80103ce8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103ceb:	50                   	push   %eax
80103cec:	e8 4d ff ff ff       	call   80103c3e <mpconfig>
80103cf1:	83 c4 10             	add    $0x10,%esp
80103cf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cf7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cfb:	75 0d                	jne    80103d0a <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103cfd:	83 ec 0c             	sub    $0xc,%esp
80103d00:	68 b2 89 10 80       	push   $0x801089b2
80103d05:	e8 96 c8 ff ff       	call   801005a0 <panic>
  ismp = 1;
80103d0a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d14:	8b 40 24             	mov    0x24(%eax),%eax
80103d17:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d1f:	83 c0 2c             	add    $0x2c,%eax
80103d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d28:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d2c:	0f b7 d0             	movzwl %ax,%edx
80103d2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d32:	01 d0                	add    %edx,%eax
80103d34:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d37:	eb 7b                	jmp    80103db4 <mpinit+0xd5>
    switch(*p){
80103d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3c:	0f b6 00             	movzbl (%eax),%eax
80103d3f:	0f b6 c0             	movzbl %al,%eax
80103d42:	83 f8 04             	cmp    $0x4,%eax
80103d45:	77 65                	ja     80103dac <mpinit+0xcd>
80103d47:	8b 04 85 ec 89 10 80 	mov    -0x7fef7614(,%eax,4),%eax
80103d4e:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d56:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103d5b:	83 f8 07             	cmp    $0x7,%eax
80103d5e:	7f 28                	jg     80103d88 <mpinit+0xa9>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d60:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103d66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d69:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d6d:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103d73:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103d79:	88 02                	mov    %al,(%edx)
        ncpu++;
80103d7b:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103d80:	83 c0 01             	add    $0x1,%eax
80103d83:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103d88:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d8c:	eb 26                	jmp    80103db4 <mpinit+0xd5>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d91:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d97:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d9b:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103da0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da4:	eb 0e                	jmp    80103db4 <mpinit+0xd5>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103da6:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103daa:	eb 08                	jmp    80103db4 <mpinit+0xd5>
    default:
      ismp = 0;
80103dac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103db3:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db7:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103dba:	0f 82 79 ff ff ff    	jb     80103d39 <mpinit+0x5a>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103dc0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dc4:	75 0d                	jne    80103dd3 <mpinit+0xf4>
    panic("Didn't find a suitable machine");
80103dc6:	83 ec 0c             	sub    $0xc,%esp
80103dc9:	68 cc 89 10 80       	push   $0x801089cc
80103dce:	e8 cd c7 ff ff       	call   801005a0 <panic>

  if(mp->imcrp){
80103dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dda:	84 c0                	test   %al,%al
80103ddc:	74 30                	je     80103e0e <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dde:	83 ec 08             	sub    $0x8,%esp
80103de1:	6a 70                	push   $0x70
80103de3:	6a 22                	push   $0x22
80103de5:	e8 d8 fc ff ff       	call   80103ac2 <outb>
80103dea:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ded:	83 ec 0c             	sub    $0xc,%esp
80103df0:	6a 23                	push   $0x23
80103df2:	e8 ae fc ff ff       	call   80103aa5 <inb>
80103df7:	83 c4 10             	add    $0x10,%esp
80103dfa:	83 c8 01             	or     $0x1,%eax
80103dfd:	0f b6 c0             	movzbl %al,%eax
80103e00:	83 ec 08             	sub    $0x8,%esp
80103e03:	50                   	push   %eax
80103e04:	6a 23                	push   $0x23
80103e06:	e8 b7 fc ff ff       	call   80103ac2 <outb>
80103e0b:	83 c4 10             	add    $0x10,%esp
  }
}
80103e0e:	90                   	nop
80103e0f:	c9                   	leave  
80103e10:	c3                   	ret    

80103e11 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e11:	55                   	push   %ebp
80103e12:	89 e5                	mov    %esp,%ebp
80103e14:	83 ec 08             	sub    $0x8,%esp
80103e17:	8b 55 08             	mov    0x8(%ebp),%edx
80103e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e1d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e21:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e24:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e28:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e2c:	ee                   	out    %al,(%dx)
}
80103e2d:	90                   	nop
80103e2e:	c9                   	leave  
80103e2f:	c3                   	ret    

80103e30 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e33:	68 ff 00 00 00       	push   $0xff
80103e38:	6a 21                	push   $0x21
80103e3a:	e8 d2 ff ff ff       	call   80103e11 <outb>
80103e3f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103e42:	68 ff 00 00 00       	push   $0xff
80103e47:	68 a1 00 00 00       	push   $0xa1
80103e4c:	e8 c0 ff ff ff       	call   80103e11 <outb>
80103e51:	83 c4 08             	add    $0x8,%esp
}
80103e54:	90                   	nop
80103e55:	c9                   	leave  
80103e56:	c3                   	ret    

80103e57 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e57:	55                   	push   %ebp
80103e58:	89 e5                	mov    %esp,%ebp
80103e5a:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e64:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e70:	8b 10                	mov    (%eax),%edx
80103e72:	8b 45 08             	mov    0x8(%ebp),%eax
80103e75:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e77:	e8 0a d2 ff ff       	call   80101086 <filealloc>
80103e7c:	89 c2                	mov    %eax,%edx
80103e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e81:	89 10                	mov    %edx,(%eax)
80103e83:	8b 45 08             	mov    0x8(%ebp),%eax
80103e86:	8b 00                	mov    (%eax),%eax
80103e88:	85 c0                	test   %eax,%eax
80103e8a:	0f 84 cb 00 00 00    	je     80103f5b <pipealloc+0x104>
80103e90:	e8 f1 d1 ff ff       	call   80101086 <filealloc>
80103e95:	89 c2                	mov    %eax,%edx
80103e97:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9a:	89 10                	mov    %edx,(%eax)
80103e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9f:	8b 00                	mov    (%eax),%eax
80103ea1:	85 c0                	test   %eax,%eax
80103ea3:	0f 84 b2 00 00 00    	je     80103f5b <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ea9:	e8 7a ee ff ff       	call   80102d28 <kalloc>
80103eae:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eb5:	0f 84 9f 00 00 00    	je     80103f5a <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ebe:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ec5:	00 00 00 
  p->writeopen = 1;
80103ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ecb:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ed2:	00 00 00 
  p->nwrite = 0;
80103ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103edf:	00 00 00 
  p->nread = 0;
80103ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103eec:	00 00 00 
  initlock(&p->lock, "pipe");
80103eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef2:	83 ec 08             	sub    $0x8,%esp
80103ef5:	68 00 8a 10 80       	push   $0x80108a00
80103efa:	50                   	push   %eax
80103efb:	e8 21 11 00 00       	call   80105021 <initlock>
80103f00:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103f03:	8b 45 08             	mov    0x8(%ebp),%eax
80103f06:	8b 00                	mov    (%eax),%eax
80103f08:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f11:	8b 00                	mov    (%eax),%eax
80103f13:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f17:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1a:	8b 00                	mov    (%eax),%eax
80103f1c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f20:	8b 45 08             	mov    0x8(%ebp),%eax
80103f23:	8b 00                	mov    (%eax),%eax
80103f25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f28:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2e:	8b 00                	mov    (%eax),%eax
80103f30:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f36:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f39:	8b 00                	mov    (%eax),%eax
80103f3b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f42:	8b 00                	mov    (%eax),%eax
80103f44:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4b:	8b 00                	mov    (%eax),%eax
80103f4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f50:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f53:	b8 00 00 00 00       	mov    $0x0,%eax
80103f58:	eb 4e                	jmp    80103fa8 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103f5a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103f5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f5f:	74 0e                	je     80103f6f <pipealloc+0x118>
    kfree((char*)p);
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	ff 75 f4             	pushl  -0xc(%ebp)
80103f67:	e8 22 ed ff ff       	call   80102c8e <kfree>
80103f6c:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f72:	8b 00                	mov    (%eax),%eax
80103f74:	85 c0                	test   %eax,%eax
80103f76:	74 11                	je     80103f89 <pipealloc+0x132>
    fileclose(*f0);
80103f78:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7b:	8b 00                	mov    (%eax),%eax
80103f7d:	83 ec 0c             	sub    $0xc,%esp
80103f80:	50                   	push   %eax
80103f81:	e8 be d1 ff ff       	call   80101144 <fileclose>
80103f86:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8c:	8b 00                	mov    (%eax),%eax
80103f8e:	85 c0                	test   %eax,%eax
80103f90:	74 11                	je     80103fa3 <pipealloc+0x14c>
    fileclose(*f1);
80103f92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f95:	8b 00                	mov    (%eax),%eax
80103f97:	83 ec 0c             	sub    $0xc,%esp
80103f9a:	50                   	push   %eax
80103f9b:	e8 a4 d1 ff ff       	call   80101144 <fileclose>
80103fa0:	83 c4 10             	add    $0x10,%esp
  return -1;
80103fa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fa8:	c9                   	leave  
80103fa9:	c3                   	ret    

80103faa <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103faa:	55                   	push   %ebp
80103fab:	89 e5                	mov    %esp,%ebp
80103fad:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb3:	83 ec 0c             	sub    $0xc,%esp
80103fb6:	50                   	push   %eax
80103fb7:	e8 87 10 00 00       	call   80105043 <acquire>
80103fbc:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103fbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fc3:	74 23                	je     80103fe8 <pipeclose+0x3e>
    p->writeopen = 0;
80103fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc8:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fcf:	00 00 00 
    wakeup(&p->nread);
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	05 34 02 00 00       	add    $0x234,%eax
80103fda:	83 ec 0c             	sub    $0xc,%esp
80103fdd:	50                   	push   %eax
80103fde:	e8 27 0d 00 00       	call   80104d0a <wakeup>
80103fe3:	83 c4 10             	add    $0x10,%esp
80103fe6:	eb 21                	jmp    80104009 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80103feb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103ff2:	00 00 00 
    wakeup(&p->nwrite);
80103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff8:	05 38 02 00 00       	add    $0x238,%eax
80103ffd:	83 ec 0c             	sub    $0xc,%esp
80104000:	50                   	push   %eax
80104001:	e8 04 0d 00 00       	call   80104d0a <wakeup>
80104006:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104009:	8b 45 08             	mov    0x8(%ebp),%eax
8010400c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104012:	85 c0                	test   %eax,%eax
80104014:	75 2c                	jne    80104042 <pipeclose+0x98>
80104016:	8b 45 08             	mov    0x8(%ebp),%eax
80104019:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010401f:	85 c0                	test   %eax,%eax
80104021:	75 1f                	jne    80104042 <pipeclose+0x98>
    release(&p->lock);
80104023:	8b 45 08             	mov    0x8(%ebp),%eax
80104026:	83 ec 0c             	sub    $0xc,%esp
80104029:	50                   	push   %eax
8010402a:	e8 82 10 00 00       	call   801050b1 <release>
8010402f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104032:	83 ec 0c             	sub    $0xc,%esp
80104035:	ff 75 08             	pushl  0x8(%ebp)
80104038:	e8 51 ec ff ff       	call   80102c8e <kfree>
8010403d:	83 c4 10             	add    $0x10,%esp
80104040:	eb 0f                	jmp    80104051 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	83 ec 0c             	sub    $0xc,%esp
80104048:	50                   	push   %eax
80104049:	e8 63 10 00 00       	call   801050b1 <release>
8010404e:	83 c4 10             	add    $0x10,%esp
}
80104051:	90                   	nop
80104052:	c9                   	leave  
80104053:	c3                   	ret    

80104054 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104054:	55                   	push   %ebp
80104055:	89 e5                	mov    %esp,%ebp
80104057:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010405a:	8b 45 08             	mov    0x8(%ebp),%eax
8010405d:	83 ec 0c             	sub    $0xc,%esp
80104060:	50                   	push   %eax
80104061:	e8 dd 0f 00 00       	call   80105043 <acquire>
80104066:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104069:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104070:	e9 ac 00 00 00       	jmp    80104121 <pipewrite+0xcd>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104075:	8b 45 08             	mov    0x8(%ebp),%eax
80104078:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010407e:	85 c0                	test   %eax,%eax
80104080:	74 0c                	je     8010408e <pipewrite+0x3a>
80104082:	e8 99 02 00 00       	call   80104320 <myproc>
80104087:	8b 40 24             	mov    0x24(%eax),%eax
8010408a:	85 c0                	test   %eax,%eax
8010408c:	74 19                	je     801040a7 <pipewrite+0x53>
        release(&p->lock);
8010408e:	8b 45 08             	mov    0x8(%ebp),%eax
80104091:	83 ec 0c             	sub    $0xc,%esp
80104094:	50                   	push   %eax
80104095:	e8 17 10 00 00       	call   801050b1 <release>
8010409a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010409d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a2:	e9 a8 00 00 00       	jmp    8010414f <pipewrite+0xfb>
      }
      wakeup(&p->nread);
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	05 34 02 00 00       	add    $0x234,%eax
801040af:	83 ec 0c             	sub    $0xc,%esp
801040b2:	50                   	push   %eax
801040b3:	e8 52 0c 00 00       	call   80104d0a <wakeup>
801040b8:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801040bb:	8b 45 08             	mov    0x8(%ebp),%eax
801040be:	8b 55 08             	mov    0x8(%ebp),%edx
801040c1:	81 c2 38 02 00 00    	add    $0x238,%edx
801040c7:	83 ec 08             	sub    $0x8,%esp
801040ca:	50                   	push   %eax
801040cb:	52                   	push   %edx
801040cc:	e8 50 0b 00 00       	call   80104c21 <sleep>
801040d1:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040d4:	8b 45 08             	mov    0x8(%ebp),%eax
801040d7:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040dd:	8b 45 08             	mov    0x8(%ebp),%eax
801040e0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040e6:	05 00 02 00 00       	add    $0x200,%eax
801040eb:	39 c2                	cmp    %eax,%edx
801040ed:	74 86                	je     80104075 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040f8:	8d 48 01             	lea    0x1(%eax),%ecx
801040fb:	8b 55 08             	mov    0x8(%ebp),%edx
801040fe:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104104:	25 ff 01 00 00       	and    $0x1ff,%eax
80104109:	89 c1                	mov    %eax,%ecx
8010410b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010410e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104111:	01 d0                	add    %edx,%eax
80104113:	0f b6 10             	movzbl (%eax),%edx
80104116:	8b 45 08             	mov    0x8(%ebp),%eax
80104119:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010411d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	3b 45 10             	cmp    0x10(%ebp),%eax
80104127:	7c ab                	jl     801040d4 <pipewrite+0x80>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	05 34 02 00 00       	add    $0x234,%eax
80104131:	83 ec 0c             	sub    $0xc,%esp
80104134:	50                   	push   %eax
80104135:	e8 d0 0b 00 00       	call   80104d0a <wakeup>
8010413a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010413d:	8b 45 08             	mov    0x8(%ebp),%eax
80104140:	83 ec 0c             	sub    $0xc,%esp
80104143:	50                   	push   %eax
80104144:	e8 68 0f 00 00       	call   801050b1 <release>
80104149:	83 c4 10             	add    $0x10,%esp
  return n;
8010414c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010414f:	c9                   	leave  
80104150:	c3                   	ret    

80104151 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104151:	55                   	push   %ebp
80104152:	89 e5                	mov    %esp,%ebp
80104154:	53                   	push   %ebx
80104155:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	83 ec 0c             	sub    $0xc,%esp
8010415e:	50                   	push   %eax
8010415f:	e8 df 0e 00 00       	call   80105043 <acquire>
80104164:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104167:	eb 3e                	jmp    801041a7 <piperead+0x56>
    if(myproc()->killed){
80104169:	e8 b2 01 00 00       	call   80104320 <myproc>
8010416e:	8b 40 24             	mov    0x24(%eax),%eax
80104171:	85 c0                	test   %eax,%eax
80104173:	74 19                	je     8010418e <piperead+0x3d>
      release(&p->lock);
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	83 ec 0c             	sub    $0xc,%esp
8010417b:	50                   	push   %eax
8010417c:	e8 30 0f 00 00       	call   801050b1 <release>
80104181:	83 c4 10             	add    $0x10,%esp
      return -1;
80104184:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104189:	e9 bf 00 00 00       	jmp    8010424d <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010418e:	8b 45 08             	mov    0x8(%ebp),%eax
80104191:	8b 55 08             	mov    0x8(%ebp),%edx
80104194:	81 c2 34 02 00 00    	add    $0x234,%edx
8010419a:	83 ec 08             	sub    $0x8,%esp
8010419d:	50                   	push   %eax
8010419e:	52                   	push   %edx
8010419f:	e8 7d 0a 00 00       	call   80104c21 <sleep>
801041a4:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041a7:	8b 45 08             	mov    0x8(%ebp),%eax
801041aa:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041b0:	8b 45 08             	mov    0x8(%ebp),%eax
801041b3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041b9:	39 c2                	cmp    %eax,%edx
801041bb:	75 0d                	jne    801041ca <piperead+0x79>
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041c6:	85 c0                	test   %eax,%eax
801041c8:	75 9f                	jne    80104169 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041d1:	eb 49                	jmp    8010421c <piperead+0xcb>
    if(p->nread == p->nwrite)
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041dc:	8b 45 08             	mov    0x8(%ebp),%eax
801041df:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041e5:	39 c2                	cmp    %eax,%edx
801041e7:	74 3d                	je     80104226 <piperead+0xd5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ef:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041f2:	8b 45 08             	mov    0x8(%ebp),%eax
801041f5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041fb:	8d 48 01             	lea    0x1(%eax),%ecx
801041fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104201:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104207:	25 ff 01 00 00       	and    $0x1ff,%eax
8010420c:	89 c2                	mov    %eax,%edx
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104216:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104218:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010421c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104222:	7c af                	jl     801041d3 <piperead+0x82>
80104224:	eb 01                	jmp    80104227 <piperead+0xd6>
    if(p->nread == p->nwrite)
      break;
80104226:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104227:	8b 45 08             	mov    0x8(%ebp),%eax
8010422a:	05 38 02 00 00       	add    $0x238,%eax
8010422f:	83 ec 0c             	sub    $0xc,%esp
80104232:	50                   	push   %eax
80104233:	e8 d2 0a 00 00       	call   80104d0a <wakeup>
80104238:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010423b:	8b 45 08             	mov    0x8(%ebp),%eax
8010423e:	83 ec 0c             	sub    $0xc,%esp
80104241:	50                   	push   %eax
80104242:	e8 6a 0e 00 00       	call   801050b1 <release>
80104247:	83 c4 10             	add    $0x10,%esp
  return i;
8010424a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010424d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104250:	c9                   	leave  
80104251:	c3                   	ret    

80104252 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104252:	55                   	push   %ebp
80104253:	89 e5                	mov    %esp,%ebp
80104255:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104258:	9c                   	pushf  
80104259:	58                   	pop    %eax
8010425a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010425d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104260:	c9                   	leave  
80104261:	c3                   	ret    

80104262 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104262:	55                   	push   %ebp
80104263:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104265:	fb                   	sti    
}
80104266:	90                   	nop
80104267:	5d                   	pop    %ebp
80104268:	c3                   	ret    

80104269 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104269:	55                   	push   %ebp
8010426a:	89 e5                	mov    %esp,%ebp
8010426c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010426f:	83 ec 08             	sub    $0x8,%esp
80104272:	68 08 8a 10 80       	push   $0x80108a08
80104277:	68 a0 3d 11 80       	push   $0x80113da0
8010427c:	e8 a0 0d 00 00       	call   80105021 <initlock>
80104281:	83 c4 10             	add    $0x10,%esp
}
80104284:	90                   	nop
80104285:	c9                   	leave  
80104286:	c3                   	ret    

80104287 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104287:	55                   	push   %ebp
80104288:	89 e5                	mov    %esp,%ebp
8010428a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010428d:	e8 16 00 00 00       	call   801042a8 <mycpu>
80104292:	89 c2                	mov    %eax,%edx
80104294:	b8 00 38 11 80       	mov    $0x80113800,%eax
80104299:	29 c2                	sub    %eax,%edx
8010429b:	89 d0                	mov    %edx,%eax
8010429d:	c1 f8 04             	sar    $0x4,%eax
801042a0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801042a6:	c9                   	leave  
801042a7:	c3                   	ret    

801042a8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801042a8:	55                   	push   %ebp
801042a9:	89 e5                	mov    %esp,%ebp
801042ab:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801042ae:	e8 9f ff ff ff       	call   80104252 <readeflags>
801042b3:	25 00 02 00 00       	and    $0x200,%eax
801042b8:	85 c0                	test   %eax,%eax
801042ba:	74 0d                	je     801042c9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801042bc:	83 ec 0c             	sub    $0xc,%esp
801042bf:	68 10 8a 10 80       	push   $0x80108a10
801042c4:	e8 d7 c2 ff ff       	call   801005a0 <panic>
  
  apicid = lapicid();
801042c9:	e8 b0 ed ff ff       	call   8010307e <lapicid>
801042ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042d8:	eb 2d                	jmp    80104307 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
801042da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042dd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042e3:	05 00 38 11 80       	add    $0x80113800,%eax
801042e8:	0f b6 00             	movzbl (%eax),%eax
801042eb:	0f b6 c0             	movzbl %al,%eax
801042ee:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801042f1:	75 10                	jne    80104303 <mycpu+0x5b>
      return &cpus[i];
801042f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042fc:	05 00 38 11 80       	add    $0x80113800,%eax
80104301:	eb 1b                	jmp    8010431e <mycpu+0x76>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104303:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104307:	a1 80 3d 11 80       	mov    0x80113d80,%eax
8010430c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010430f:	7c c9                	jl     801042da <mycpu+0x32>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104311:	83 ec 0c             	sub    $0xc,%esp
80104314:	68 36 8a 10 80       	push   $0x80108a36
80104319:	e8 82 c2 ff ff       	call   801005a0 <panic>
}
8010431e:	c9                   	leave  
8010431f:	c3                   	ret    

80104320 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104320:	55                   	push   %ebp
80104321:	89 e5                	mov    %esp,%ebp
80104323:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104326:	e8 83 0e 00 00       	call   801051ae <pushcli>
  c = mycpu();
8010432b:	e8 78 ff ff ff       	call   801042a8 <mycpu>
80104330:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104336:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010433c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010433f:	e8 b8 0e 00 00       	call   801051fc <popcli>
  return p;
80104344:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104347:	c9                   	leave  
80104348:	c3                   	ret    

80104349 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104349:	55                   	push   %ebp
8010434a:	89 e5                	mov    %esp,%ebp
8010434c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010434f:	83 ec 0c             	sub    $0xc,%esp
80104352:	68 a0 3d 11 80       	push   $0x80113da0
80104357:	e8 e7 0c 00 00       	call   80105043 <acquire>
8010435c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010435f:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104366:	eb 11                	jmp    80104379 <allocproc+0x30>
    if(p->state == UNUSED)
80104368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436b:	8b 40 0c             	mov    0xc(%eax),%eax
8010436e:	85 c0                	test   %eax,%eax
80104370:	74 2a                	je     8010439c <allocproc+0x53>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104372:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104379:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104380:	72 e6                	jb     80104368 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104382:	83 ec 0c             	sub    $0xc,%esp
80104385:	68 a0 3d 11 80       	push   $0x80113da0
8010438a:	e8 22 0d 00 00       	call   801050b1 <release>
8010438f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104392:	b8 00 00 00 00       	mov    $0x0,%eax
80104397:	e9 b4 00 00 00       	jmp    80104450 <allocproc+0x107>

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010439c:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010439d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043a7:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801043ac:	8d 50 01             	lea    0x1(%eax),%edx
801043af:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
801043b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801043bb:	83 ec 0c             	sub    $0xc,%esp
801043be:	68 a0 3d 11 80       	push   $0x80113da0
801043c3:	e8 e9 0c 00 00       	call   801050b1 <release>
801043c8:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043cb:	e8 58 e9 ff ff       	call   80102d28 <kalloc>
801043d0:	89 c2                	mov    %eax,%edx
801043d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d5:	89 50 08             	mov    %edx,0x8(%eax)
801043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043db:	8b 40 08             	mov    0x8(%eax),%eax
801043de:	85 c0                	test   %eax,%eax
801043e0:	75 11                	jne    801043f3 <allocproc+0xaa>
    p->state = UNUSED;
801043e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043ec:	b8 00 00 00 00       	mov    $0x0,%eax
801043f1:	eb 5d                	jmp    80104450 <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
801043f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f6:	8b 40 08             	mov    0x8(%eax),%eax
801043f9:	05 00 10 00 00       	add    $0x1000,%eax
801043fe:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104401:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104408:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010440b:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010440e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104412:	ba d0 66 10 80       	mov    $0x801066d0,%edx
80104417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010441c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104423:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104426:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010442f:	83 ec 04             	sub    $0x4,%esp
80104432:	6a 14                	push   $0x14
80104434:	6a 00                	push   $0x0
80104436:	50                   	push   %eax
80104437:	e8 7e 0e 00 00       	call   801052ba <memset>
8010443c:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104442:	8b 40 1c             	mov    0x1c(%eax),%eax
80104445:	ba db 4b 10 80       	mov    $0x80104bdb,%edx
8010444a:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104450:	c9                   	leave  
80104451:	c3                   	ret    

80104452 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104452:	55                   	push   %ebp
80104453:	89 e5                	mov    %esp,%ebp
80104455:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104458:	e8 ec fe ff ff       	call   80104349 <allocproc>
8010445d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104463:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
80104468:	e8 19 38 00 00       	call   80107c86 <setupkvm>
8010446d:	89 c2                	mov    %eax,%edx
8010446f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104472:	89 50 04             	mov    %edx,0x4(%eax)
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	8b 40 04             	mov    0x4(%eax),%eax
8010447b:	85 c0                	test   %eax,%eax
8010447d:	75 0d                	jne    8010448c <userinit+0x3a>
    panic("userinit: out of memory?");
8010447f:	83 ec 0c             	sub    $0xc,%esp
80104482:	68 46 8a 10 80       	push   $0x80108a46
80104487:	e8 14 c1 ff ff       	call   801005a0 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010448c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104494:	8b 40 04             	mov    0x4(%eax),%eax
80104497:	83 ec 04             	sub    $0x4,%esp
8010449a:	52                   	push   %edx
8010449b:	68 c0 b4 10 80       	push   $0x8010b4c0
801044a0:	50                   	push   %eax
801044a1:	e8 48 3a 00 00       	call   80107eee <inituvm>
801044a6:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801044a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ac:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b5:	8b 40 18             	mov    0x18(%eax),%eax
801044b8:	83 ec 04             	sub    $0x4,%esp
801044bb:	6a 4c                	push   $0x4c
801044bd:	6a 00                	push   $0x0
801044bf:	50                   	push   %eax
801044c0:	e8 f5 0d 00 00       	call   801052ba <memset>
801044c5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cb:	8b 40 18             	mov    0x18(%eax),%eax
801044ce:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	8b 40 18             	mov    0x18(%eax),%eax
801044da:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e3:	8b 40 18             	mov    0x18(%eax),%eax
801044e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e9:	8b 52 18             	mov    0x18(%edx),%edx
801044ec:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044f0:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	8b 40 18             	mov    0x18(%eax),%eax
801044fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044fd:	8b 52 18             	mov    0x18(%edx),%edx
80104500:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104504:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 18             	mov    0x18(%eax),%eax
8010450e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104525:	8b 40 18             	mov    0x18(%eax),%eax
80104528:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	83 c0 6c             	add    $0x6c,%eax
80104535:	83 ec 04             	sub    $0x4,%esp
80104538:	6a 10                	push   $0x10
8010453a:	68 5f 8a 10 80       	push   $0x80108a5f
8010453f:	50                   	push   %eax
80104540:	e8 78 0f 00 00       	call   801054bd <safestrcpy>
80104545:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	68 68 8a 10 80       	push   $0x80108a68
80104550:	e8 8e e0 ff ff       	call   801025e3 <namei>
80104555:	83 c4 10             	add    $0x10,%esp
80104558:	89 c2                	mov    %eax,%edx
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	89 50 68             	mov    %edx,0x68(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104560:	83 ec 0c             	sub    $0xc,%esp
80104563:	68 a0 3d 11 80       	push   $0x80113da0
80104568:	e8 d6 0a 00 00       	call   80105043 <acquire>
8010456d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104573:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010457a:	83 ec 0c             	sub    $0xc,%esp
8010457d:	68 a0 3d 11 80       	push   $0x80113da0
80104582:	e8 2a 0b 00 00       	call   801050b1 <release>
80104587:	83 c4 10             	add    $0x10,%esp
}
8010458a:	90                   	nop
8010458b:	c9                   	leave  
8010458c:	c3                   	ret    

8010458d <growproc>:
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
// Changed for cs 153
int
growproc(int n)
{
8010458d:	55                   	push   %ebp
8010458e:	89 e5                	mov    %esp,%ebp
80104590:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104593:	e8 88 fd ff ff       	call   80104320 <myproc>
80104598:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
  cprintf("GROWPROC");
8010459b:	83 ec 0c             	sub    $0xc,%esp
8010459e:	68 6a 8a 10 80       	push   $0x80108a6a
801045a3:	e8 58 be ff ff       	call   80100400 <cprintf>
801045a8:	83 c4 10             	add    $0x10,%esp

  sz = curproc->sz;
801045ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ae:	8b 00                	mov    (%eax),%eax
801045b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  sz = curproc->last_page;
  if(n > 0){
801045b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045b7:	7e 2e                	jle    801045e7 <growproc+0x5a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045b9:	8b 55 08             	mov    0x8(%ebp),%edx
801045bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bf:	01 c2                	add    %eax,%edx
801045c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c4:	8b 40 04             	mov    0x4(%eax),%eax
801045c7:	83 ec 04             	sub    $0x4,%esp
801045ca:	52                   	push   %edx
801045cb:	ff 75 f4             	pushl  -0xc(%ebp)
801045ce:	50                   	push   %eax
801045cf:	e8 57 3a 00 00       	call   8010802b <allocuvm>
801045d4:	83 c4 10             	add    $0x10,%esp
801045d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045de:	75 3b                	jne    8010461b <growproc+0x8e>
      return -1;
801045e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e5:	eb 4f                	jmp    80104636 <growproc+0xa9>
  } else if(n < 0){
801045e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045eb:	79 2e                	jns    8010461b <growproc+0x8e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045ed:	8b 55 08             	mov    0x8(%ebp),%edx
801045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f3:	01 c2                	add    %eax,%edx
801045f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045f8:	8b 40 04             	mov    0x4(%eax),%eax
801045fb:	83 ec 04             	sub    $0x4,%esp
801045fe:	52                   	push   %edx
801045ff:	ff 75 f4             	pushl  -0xc(%ebp)
80104602:	50                   	push   %eax
80104603:	e8 61 3b 00 00       	call   80108169 <deallocuvm>
80104608:	83 c4 10             	add    $0x10,%esp
8010460b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010460e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104612:	75 07                	jne    8010461b <growproc+0x8e>
      return -1;
80104614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104619:	eb 1b                	jmp    80104636 <growproc+0xa9>
  }
  curproc->sz = sz;
8010461b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010461e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104621:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104623:	83 ec 0c             	sub    $0xc,%esp
80104626:	ff 75 f0             	pushl  -0x10(%ebp)
80104629:	e8 22 37 00 00       	call   80107d50 <switchuvm>
8010462e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104631:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104636:	c9                   	leave  
80104637:	c3                   	ret    

80104638 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104638:	55                   	push   %ebp
80104639:	89 e5                	mov    %esp,%ebp
8010463b:	57                   	push   %edi
8010463c:	56                   	push   %esi
8010463d:	53                   	push   %ebx
8010463e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104641:	e8 da fc ff ff       	call   80104320 <myproc>
80104646:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104649:	e8 fb fc ff ff       	call   80104349 <allocproc>
8010464e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104651:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104655:	75 0a                	jne    80104661 <fork+0x29>
    return -1;
80104657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010465c:	e9 7c 01 00 00       	jmp    801047dd <fork+0x1a5>
  }


  cprintf("SP2: %x\n", curproc->tf->esp);
80104661:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104664:	8b 40 18             	mov    0x18(%eax),%eax
80104667:	8b 40 44             	mov    0x44(%eax),%eax
8010466a:	83 ec 08             	sub    $0x8,%esp
8010466d:	50                   	push   %eax
8010466e:	68 73 8a 10 80       	push   $0x80108a73
80104673:	e8 88 bd ff ff       	call   80100400 <cprintf>
80104678:	83 c4 10             	add    $0x10,%esp


  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->tf->esp)) == 0){
8010467b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467e:	8b 40 18             	mov    0x18(%eax),%eax
80104681:	8b 48 44             	mov    0x44(%eax),%ecx
80104684:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104687:	8b 10                	mov    (%eax),%edx
80104689:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468c:	8b 40 04             	mov    0x4(%eax),%eax
8010468f:	83 ec 04             	sub    $0x4,%esp
80104692:	51                   	push   %ecx
80104693:	52                   	push   %edx
80104694:	50                   	push   %eax
80104695:	e8 6d 3c 00 00       	call   80108307 <copyuvm>
8010469a:	83 c4 10             	add    $0x10,%esp
8010469d:	89 c2                	mov    %eax,%edx
8010469f:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a2:	89 50 04             	mov    %edx,0x4(%eax)
801046a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a8:	8b 40 04             	mov    0x4(%eax),%eax
801046ab:	85 c0                	test   %eax,%eax
801046ad:	75 30                	jne    801046df <fork+0xa7>
    kfree(np->kstack);
801046af:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b2:	8b 40 08             	mov    0x8(%eax),%eax
801046b5:	83 ec 0c             	sub    $0xc,%esp
801046b8:	50                   	push   %eax
801046b9:	e8 d0 e5 ff ff       	call   80102c8e <kfree>
801046be:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801046c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046da:	e9 fe 00 00 00       	jmp    801047dd <fork+0x1a5>
  }
  np->sz = curproc->sz;
801046df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e2:	8b 10                	mov    (%eax),%edx
801046e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046e7:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801046e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046ef:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f5:	8b 50 18             	mov    0x18(%eax),%edx
801046f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fb:	8b 40 18             	mov    0x18(%eax),%eax
801046fe:	89 c3                	mov    %eax,%ebx
80104700:	b8 13 00 00 00       	mov    $0x13,%eax
80104705:	89 d7                	mov    %edx,%edi
80104707:	89 de                	mov    %ebx,%esi
80104709:	89 c1                	mov    %eax,%ecx
8010470b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->last_page = curproc->last_page;
8010470d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104710:	8b 50 7c             	mov    0x7c(%eax),%edx
80104713:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104716:	89 50 7c             	mov    %edx,0x7c(%eax)
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104719:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010471c:	8b 40 18             	mov    0x18(%eax),%eax
8010471f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104726:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010472d:	eb 3d                	jmp    8010476c <fork+0x134>
    if(curproc->ofile[i])
8010472f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104732:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104735:	83 c2 08             	add    $0x8,%edx
80104738:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010473c:	85 c0                	test   %eax,%eax
8010473e:	74 28                	je     80104768 <fork+0x130>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104740:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104743:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104746:	83 c2 08             	add    $0x8,%edx
80104749:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010474d:	83 ec 0c             	sub    $0xc,%esp
80104750:	50                   	push   %eax
80104751:	e8 9d c9 ff ff       	call   801010f3 <filedup>
80104756:	83 c4 10             	add    $0x10,%esp
80104759:	89 c1                	mov    %eax,%ecx
8010475b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010475e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104761:	83 c2 08             	add    $0x8,%edx
80104764:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *curproc->tf;
  np->last_page = curproc->last_page;
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104768:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010476c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104770:	7e bd                	jle    8010472f <fork+0xf7>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104772:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104775:	8b 40 68             	mov    0x68(%eax),%eax
80104778:	83 ec 0c             	sub    $0xc,%esp
8010477b:	50                   	push   %eax
8010477c:	e8 e8 d2 ff ff       	call   80101a69 <idup>
80104781:	83 c4 10             	add    $0x10,%esp
80104784:	89 c2                	mov    %eax,%edx
80104786:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104789:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010478c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104792:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104795:	83 c0 6c             	add    $0x6c,%eax
80104798:	83 ec 04             	sub    $0x4,%esp
8010479b:	6a 10                	push   $0x10
8010479d:	52                   	push   %edx
8010479e:	50                   	push   %eax
8010479f:	e8 19 0d 00 00       	call   801054bd <safestrcpy>
801047a4:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801047a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047aa:	8b 40 10             	mov    0x10(%eax),%eax
801047ad:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801047b0:	83 ec 0c             	sub    $0xc,%esp
801047b3:	68 a0 3d 11 80       	push   $0x80113da0
801047b8:	e8 86 08 00 00       	call   80105043 <acquire>
801047bd:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801047c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047c3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047ca:	83 ec 0c             	sub    $0xc,%esp
801047cd:	68 a0 3d 11 80       	push   $0x80113da0
801047d2:	e8 da 08 00 00       	call   801050b1 <release>
801047d7:	83 c4 10             	add    $0x10,%esp

  return pid;
801047da:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801047dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047e0:	5b                   	pop    %ebx
801047e1:	5e                   	pop    %esi
801047e2:	5f                   	pop    %edi
801047e3:	5d                   	pop    %ebp
801047e4:	c3                   	ret    

801047e5 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047e5:	55                   	push   %ebp
801047e6:	89 e5                	mov    %esp,%ebp
801047e8:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801047eb:	e8 30 fb ff ff       	call   80104320 <myproc>
801047f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801047f3:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801047f8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047fb:	75 0d                	jne    8010480a <exit+0x25>
    panic("init exiting");
801047fd:	83 ec 0c             	sub    $0xc,%esp
80104800:	68 7c 8a 10 80       	push   $0x80108a7c
80104805:	e8 96 bd ff ff       	call   801005a0 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010480a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104811:	eb 3f                	jmp    80104852 <exit+0x6d>
    if(curproc->ofile[fd]){
80104813:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104816:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104819:	83 c2 08             	add    $0x8,%edx
8010481c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104820:	85 c0                	test   %eax,%eax
80104822:	74 2a                	je     8010484e <exit+0x69>
      fileclose(curproc->ofile[fd]);
80104824:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104827:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010482a:	83 c2 08             	add    $0x8,%edx
8010482d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104831:	83 ec 0c             	sub    $0xc,%esp
80104834:	50                   	push   %eax
80104835:	e8 0a c9 ff ff       	call   80101144 <fileclose>
8010483a:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010483d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104840:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104843:	83 c2 08             	add    $0x8,%edx
80104846:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010484d:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010484e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104852:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104856:	7e bb                	jle    80104813 <exit+0x2e>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104858:	e8 6b ed ff ff       	call   801035c8 <begin_op>
  iput(curproc->cwd);
8010485d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104860:	8b 40 68             	mov    0x68(%eax),%eax
80104863:	83 ec 0c             	sub    $0xc,%esp
80104866:	50                   	push   %eax
80104867:	e8 98 d3 ff ff       	call   80101c04 <iput>
8010486c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010486f:	e8 e0 ed ff ff       	call   80103654 <end_op>
  curproc->cwd = 0;
80104874:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104877:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010487e:	83 ec 0c             	sub    $0xc,%esp
80104881:	68 a0 3d 11 80       	push   $0x80113da0
80104886:	e8 b8 07 00 00       	call   80105043 <acquire>
8010488b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010488e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104891:	8b 40 14             	mov    0x14(%eax),%eax
80104894:	83 ec 0c             	sub    $0xc,%esp
80104897:	50                   	push   %eax
80104898:	e8 2b 04 00 00       	call   80104cc8 <wakeup1>
8010489d:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a0:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801048a7:	eb 3a                	jmp    801048e3 <exit+0xfe>
    if(p->parent == curproc){
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	8b 40 14             	mov    0x14(%eax),%eax
801048af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048b2:	75 28                	jne    801048dc <exit+0xf7>
      p->parent = initproc;
801048b4:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
801048ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bd:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c3:	8b 40 0c             	mov    0xc(%eax),%eax
801048c6:	83 f8 05             	cmp    $0x5,%eax
801048c9:	75 11                	jne    801048dc <exit+0xf7>
        wakeup1(initproc);
801048cb:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801048d0:	83 ec 0c             	sub    $0xc,%esp
801048d3:	50                   	push   %eax
801048d4:	e8 ef 03 00 00       	call   80104cc8 <wakeup1>
801048d9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048dc:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048e3:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801048ea:	72 bd                	jb     801048a9 <exit+0xc4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801048ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048ef:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048f6:	e8 eb 01 00 00       	call   80104ae6 <sched>
  panic("zombie exit");
801048fb:	83 ec 0c             	sub    $0xc,%esp
801048fe:	68 89 8a 10 80       	push   $0x80108a89
80104903:	e8 98 bc ff ff       	call   801005a0 <panic>

80104908 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104908:	55                   	push   %ebp
80104909:	89 e5                	mov    %esp,%ebp
8010490b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010490e:	e8 0d fa ff ff       	call   80104320 <myproc>
80104913:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104916:	83 ec 0c             	sub    $0xc,%esp
80104919:	68 a0 3d 11 80       	push   $0x80113da0
8010491e:	e8 20 07 00 00       	call   80105043 <acquire>
80104923:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104926:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010492d:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104934:	e9 a4 00 00 00       	jmp    801049dd <wait+0xd5>
      if(p->parent != curproc)
80104939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493c:	8b 40 14             	mov    0x14(%eax),%eax
8010493f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104942:	0f 85 8d 00 00 00    	jne    801049d5 <wait+0xcd>
        continue;
      havekids = 1;
80104948:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104952:	8b 40 0c             	mov    0xc(%eax),%eax
80104955:	83 f8 05             	cmp    $0x5,%eax
80104958:	75 7c                	jne    801049d6 <wait+0xce>
        // Found one.
        pid = p->pid;
8010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495d:	8b 40 10             	mov    0x10(%eax),%eax
80104960:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104966:	8b 40 08             	mov    0x8(%eax),%eax
80104969:	83 ec 0c             	sub    $0xc,%esp
8010496c:	50                   	push   %eax
8010496d:	e8 1c e3 ff ff       	call   80102c8e <kfree>
80104972:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104978:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104982:	8b 40 04             	mov    0x4(%eax),%eax
80104985:	83 ec 0c             	sub    $0xc,%esp
80104988:	50                   	push   %eax
80104989:	e8 9f 38 00 00       	call   8010822d <freevm>
8010498e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104994:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010499b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049af:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801049b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049c0:	83 ec 0c             	sub    $0xc,%esp
801049c3:	68 a0 3d 11 80       	push   $0x80113da0
801049c8:	e8 e4 06 00 00       	call   801050b1 <release>
801049cd:	83 c4 10             	add    $0x10,%esp
        return pid;
801049d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049d3:	eb 54                	jmp    80104a29 <wait+0x121>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
801049d5:	90                   	nop
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d6:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049dd:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801049e4:	0f 82 4f ff ff ff    	jb     80104939 <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049ee:	74 0a                	je     801049fa <wait+0xf2>
801049f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f3:	8b 40 24             	mov    0x24(%eax),%eax
801049f6:	85 c0                	test   %eax,%eax
801049f8:	74 17                	je     80104a11 <wait+0x109>
      release(&ptable.lock);
801049fa:	83 ec 0c             	sub    $0xc,%esp
801049fd:	68 a0 3d 11 80       	push   $0x80113da0
80104a02:	e8 aa 06 00 00       	call   801050b1 <release>
80104a07:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0f:	eb 18                	jmp    80104a29 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104a11:	83 ec 08             	sub    $0x8,%esp
80104a14:	68 a0 3d 11 80       	push   $0x80113da0
80104a19:	ff 75 ec             	pushl  -0x14(%ebp)
80104a1c:	e8 00 02 00 00       	call   80104c21 <sleep>
80104a21:	83 c4 10             	add    $0x10,%esp
  }
80104a24:	e9 fd fe ff ff       	jmp    80104926 <wait+0x1e>
}
80104a29:	c9                   	leave  
80104a2a:	c3                   	ret    

80104a2b <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a2b:	55                   	push   %ebp
80104a2c:	89 e5                	mov    %esp,%ebp
80104a2e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a31:	e8 72 f8 ff ff       	call   801042a8 <mycpu>
80104a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a3c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a43:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a46:	e8 17 f8 ff ff       	call   80104262 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	68 a0 3d 11 80       	push   $0x80113da0
80104a53:	e8 eb 05 00 00       	call   80105043 <acquire>
80104a58:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a5b:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104a62:	eb 64                	jmp    80104ac8 <scheduler+0x9d>
      if(p->state != RUNNABLE)
80104a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a67:	8b 40 0c             	mov    0xc(%eax),%eax
80104a6a:	83 f8 03             	cmp    $0x3,%eax
80104a6d:	75 51                	jne    80104ac0 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a75:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a7b:	83 ec 0c             	sub    $0xc,%esp
80104a7e:	ff 75 f4             	pushl  -0xc(%ebp)
80104a81:	e8 ca 32 00 00       	call   80107d50 <switchuvm>
80104a86:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a99:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a9c:	83 c2 04             	add    $0x4,%edx
80104a9f:	83 ec 08             	sub    $0x8,%esp
80104aa2:	50                   	push   %eax
80104aa3:	52                   	push   %edx
80104aa4:	e8 85 0a 00 00       	call   8010552e <swtch>
80104aa9:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104aac:	e8 86 32 00 00       	call   80107d37 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104abb:	00 00 00 
80104abe:	eb 01                	jmp    80104ac1 <scheduler+0x96>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104ac0:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ac1:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ac8:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104acf:	72 93                	jb     80104a64 <scheduler+0x39>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104ad1:	83 ec 0c             	sub    $0xc,%esp
80104ad4:	68 a0 3d 11 80       	push   $0x80113da0
80104ad9:	e8 d3 05 00 00       	call   801050b1 <release>
80104ade:	83 c4 10             	add    $0x10,%esp

  }
80104ae1:	e9 60 ff ff ff       	jmp    80104a46 <scheduler+0x1b>

80104ae6 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ae6:	55                   	push   %ebp
80104ae7:	89 e5                	mov    %esp,%ebp
80104ae9:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104aec:	e8 2f f8 ff ff       	call   80104320 <myproc>
80104af1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104af4:	83 ec 0c             	sub    $0xc,%esp
80104af7:	68 a0 3d 11 80       	push   $0x80113da0
80104afc:	e8 7c 06 00 00       	call   8010517d <holding>
80104b01:	83 c4 10             	add    $0x10,%esp
80104b04:	85 c0                	test   %eax,%eax
80104b06:	75 0d                	jne    80104b15 <sched+0x2f>
    panic("sched ptable.lock");
80104b08:	83 ec 0c             	sub    $0xc,%esp
80104b0b:	68 95 8a 10 80       	push   $0x80108a95
80104b10:	e8 8b ba ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli != 1)
80104b15:	e8 8e f7 ff ff       	call   801042a8 <mycpu>
80104b1a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b20:	83 f8 01             	cmp    $0x1,%eax
80104b23:	74 0d                	je     80104b32 <sched+0x4c>
    panic("sched locks");
80104b25:	83 ec 0c             	sub    $0xc,%esp
80104b28:	68 a7 8a 10 80       	push   $0x80108aa7
80104b2d:	e8 6e ba ff ff       	call   801005a0 <panic>
  if(p->state == RUNNING)
80104b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b35:	8b 40 0c             	mov    0xc(%eax),%eax
80104b38:	83 f8 04             	cmp    $0x4,%eax
80104b3b:	75 0d                	jne    80104b4a <sched+0x64>
    panic("sched running");
80104b3d:	83 ec 0c             	sub    $0xc,%esp
80104b40:	68 b3 8a 10 80       	push   $0x80108ab3
80104b45:	e8 56 ba ff ff       	call   801005a0 <panic>
  if(readeflags()&FL_IF)
80104b4a:	e8 03 f7 ff ff       	call   80104252 <readeflags>
80104b4f:	25 00 02 00 00       	and    $0x200,%eax
80104b54:	85 c0                	test   %eax,%eax
80104b56:	74 0d                	je     80104b65 <sched+0x7f>
    panic("sched interruptible");
80104b58:	83 ec 0c             	sub    $0xc,%esp
80104b5b:	68 c1 8a 10 80       	push   $0x80108ac1
80104b60:	e8 3b ba ff ff       	call   801005a0 <panic>
  intena = mycpu()->intena;
80104b65:	e8 3e f7 ff ff       	call   801042a8 <mycpu>
80104b6a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b73:	e8 30 f7 ff ff       	call   801042a8 <mycpu>
80104b78:	8b 40 04             	mov    0x4(%eax),%eax
80104b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b7e:	83 c2 1c             	add    $0x1c,%edx
80104b81:	83 ec 08             	sub    $0x8,%esp
80104b84:	50                   	push   %eax
80104b85:	52                   	push   %edx
80104b86:	e8 a3 09 00 00       	call   8010552e <swtch>
80104b8b:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b8e:	e8 15 f7 ff ff       	call   801042a8 <mycpu>
80104b93:	89 c2                	mov    %eax,%edx
80104b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b98:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
}
80104b9e:	90                   	nop
80104b9f:	c9                   	leave  
80104ba0:	c3                   	ret    

80104ba1 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ba1:	55                   	push   %ebp
80104ba2:	89 e5                	mov    %esp,%ebp
80104ba4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ba7:	83 ec 0c             	sub    $0xc,%esp
80104baa:	68 a0 3d 11 80       	push   $0x80113da0
80104baf:	e8 8f 04 00 00       	call   80105043 <acquire>
80104bb4:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104bb7:	e8 64 f7 ff ff       	call   80104320 <myproc>
80104bbc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bc3:	e8 1e ff ff ff       	call   80104ae6 <sched>
  release(&ptable.lock);
80104bc8:	83 ec 0c             	sub    $0xc,%esp
80104bcb:	68 a0 3d 11 80       	push   $0x80113da0
80104bd0:	e8 dc 04 00 00       	call   801050b1 <release>
80104bd5:	83 c4 10             	add    $0x10,%esp
}
80104bd8:	90                   	nop
80104bd9:	c9                   	leave  
80104bda:	c3                   	ret    

80104bdb <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bdb:	55                   	push   %ebp
80104bdc:	89 e5                	mov    %esp,%ebp
80104bde:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104be1:	83 ec 0c             	sub    $0xc,%esp
80104be4:	68 a0 3d 11 80       	push   $0x80113da0
80104be9:	e8 c3 04 00 00       	call   801050b1 <release>
80104bee:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bf1:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104bf6:	85 c0                	test   %eax,%eax
80104bf8:	74 24                	je     80104c1e <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bfa:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104c01:	00 00 00 
    iinit(ROOTDEV);
80104c04:	83 ec 0c             	sub    $0xc,%esp
80104c07:	6a 01                	push   $0x1
80104c09:	e8 23 cb ff ff       	call   80101731 <iinit>
80104c0e:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104c11:	83 ec 0c             	sub    $0xc,%esp
80104c14:	6a 01                	push   $0x1
80104c16:	e8 8f e7 ff ff       	call   801033aa <initlog>
80104c1b:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c1e:	90                   	nop
80104c1f:	c9                   	leave  
80104c20:	c3                   	ret    

80104c21 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c21:	55                   	push   %ebp
80104c22:	89 e5                	mov    %esp,%ebp
80104c24:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c27:	e8 f4 f6 ff ff       	call   80104320 <myproc>
80104c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c33:	75 0d                	jne    80104c42 <sleep+0x21>
    panic("sleep");
80104c35:	83 ec 0c             	sub    $0xc,%esp
80104c38:	68 d5 8a 10 80       	push   $0x80108ad5
80104c3d:	e8 5e b9 ff ff       	call   801005a0 <panic>

  if(lk == 0)
80104c42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c46:	75 0d                	jne    80104c55 <sleep+0x34>
    panic("sleep without lk");
80104c48:	83 ec 0c             	sub    $0xc,%esp
80104c4b:	68 db 8a 10 80       	push   $0x80108adb
80104c50:	e8 4b b9 ff ff       	call   801005a0 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c55:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104c5c:	74 1e                	je     80104c7c <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c5e:	83 ec 0c             	sub    $0xc,%esp
80104c61:	68 a0 3d 11 80       	push   $0x80113da0
80104c66:	e8 d8 03 00 00       	call   80105043 <acquire>
80104c6b:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c6e:	83 ec 0c             	sub    $0xc,%esp
80104c71:	ff 75 0c             	pushl  0xc(%ebp)
80104c74:	e8 38 04 00 00       	call   801050b1 <release>
80104c79:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7f:	8b 55 08             	mov    0x8(%ebp),%edx
80104c82:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c88:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c8f:	e8 52 fe ff ff       	call   80104ae6 <sched>

  // Tidy up.
  p->chan = 0;
80104c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c97:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c9e:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104ca5:	74 1e                	je     80104cc5 <sleep+0xa4>
    release(&ptable.lock);
80104ca7:	83 ec 0c             	sub    $0xc,%esp
80104caa:	68 a0 3d 11 80       	push   $0x80113da0
80104caf:	e8 fd 03 00 00       	call   801050b1 <release>
80104cb4:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104cb7:	83 ec 0c             	sub    $0xc,%esp
80104cba:	ff 75 0c             	pushl  0xc(%ebp)
80104cbd:	e8 81 03 00 00       	call   80105043 <acquire>
80104cc2:	83 c4 10             	add    $0x10,%esp
  }
}
80104cc5:	90                   	nop
80104cc6:	c9                   	leave  
80104cc7:	c3                   	ret    

80104cc8 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cc8:	55                   	push   %ebp
80104cc9:	89 e5                	mov    %esp,%ebp
80104ccb:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cce:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104cd5:	eb 27                	jmp    80104cfe <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104cd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cda:	8b 40 0c             	mov    0xc(%eax),%eax
80104cdd:	83 f8 02             	cmp    $0x2,%eax
80104ce0:	75 15                	jne    80104cf7 <wakeup1+0x2f>
80104ce2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce5:	8b 40 20             	mov    0x20(%eax),%eax
80104ce8:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ceb:	75 0a                	jne    80104cf7 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ced:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cf0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cf7:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104cfe:	81 7d fc d4 5e 11 80 	cmpl   $0x80115ed4,-0x4(%ebp)
80104d05:	72 d0                	jb     80104cd7 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104d07:	90                   	nop
80104d08:	c9                   	leave  
80104d09:	c3                   	ret    

80104d0a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d0a:	55                   	push   %ebp
80104d0b:	89 e5                	mov    %esp,%ebp
80104d0d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104d10:	83 ec 0c             	sub    $0xc,%esp
80104d13:	68 a0 3d 11 80       	push   $0x80113da0
80104d18:	e8 26 03 00 00       	call   80105043 <acquire>
80104d1d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d20:	83 ec 0c             	sub    $0xc,%esp
80104d23:	ff 75 08             	pushl  0x8(%ebp)
80104d26:	e8 9d ff ff ff       	call   80104cc8 <wakeup1>
80104d2b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d2e:	83 ec 0c             	sub    $0xc,%esp
80104d31:	68 a0 3d 11 80       	push   $0x80113da0
80104d36:	e8 76 03 00 00       	call   801050b1 <release>
80104d3b:	83 c4 10             	add    $0x10,%esp
}
80104d3e:	90                   	nop
80104d3f:	c9                   	leave  
80104d40:	c3                   	ret    

80104d41 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d41:	55                   	push   %ebp
80104d42:	89 e5                	mov    %esp,%ebp
80104d44:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d47:	83 ec 0c             	sub    $0xc,%esp
80104d4a:	68 a0 3d 11 80       	push   $0x80113da0
80104d4f:	e8 ef 02 00 00       	call   80105043 <acquire>
80104d54:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d57:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104d5e:	eb 48                	jmp    80104da8 <kill+0x67>
    if(p->pid == pid){
80104d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d63:	8b 40 10             	mov    0x10(%eax),%eax
80104d66:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d69:	75 36                	jne    80104da1 <kill+0x60>
      p->killed = 1;
80104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d78:	8b 40 0c             	mov    0xc(%eax),%eax
80104d7b:	83 f8 02             	cmp    $0x2,%eax
80104d7e:	75 0a                	jne    80104d8a <kill+0x49>
        p->state = RUNNABLE;
80104d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d83:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d8a:	83 ec 0c             	sub    $0xc,%esp
80104d8d:	68 a0 3d 11 80       	push   $0x80113da0
80104d92:	e8 1a 03 00 00       	call   801050b1 <release>
80104d97:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d9a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d9f:	eb 25                	jmp    80104dc6 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104da1:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104da8:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104daf:	72 af                	jb     80104d60 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104db1:	83 ec 0c             	sub    $0xc,%esp
80104db4:	68 a0 3d 11 80       	push   $0x80113da0
80104db9:	e8 f3 02 00 00       	call   801050b1 <release>
80104dbe:	83 c4 10             	add    $0x10,%esp
  return -1;
80104dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dce:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104dd5:	e9 da 00 00 00       	jmp    80104eb4 <procdump+0xec>
    if(p->state == UNUSED)
80104dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ddd:	8b 40 0c             	mov    0xc(%eax),%eax
80104de0:	85 c0                	test   %eax,%eax
80104de2:	0f 84 c4 00 00 00    	je     80104eac <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104deb:	8b 40 0c             	mov    0xc(%eax),%eax
80104dee:	83 f8 05             	cmp    $0x5,%eax
80104df1:	77 23                	ja     80104e16 <procdump+0x4e>
80104df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df6:	8b 40 0c             	mov    0xc(%eax),%eax
80104df9:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104e00:	85 c0                	test   %eax,%eax
80104e02:	74 12                	je     80104e16 <procdump+0x4e>
      state = states[p->state];
80104e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e07:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0a:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104e11:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e14:	eb 07                	jmp    80104e1d <procdump+0x55>
    else
      state = "???";
80104e16:	c7 45 ec ec 8a 10 80 	movl   $0x80108aec,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e20:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e26:	8b 40 10             	mov    0x10(%eax),%eax
80104e29:	52                   	push   %edx
80104e2a:	ff 75 ec             	pushl  -0x14(%ebp)
80104e2d:	50                   	push   %eax
80104e2e:	68 f0 8a 10 80       	push   $0x80108af0
80104e33:	e8 c8 b5 ff ff       	call   80100400 <cprintf>
80104e38:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3e:	8b 40 0c             	mov    0xc(%eax),%eax
80104e41:	83 f8 02             	cmp    $0x2,%eax
80104e44:	75 54                	jne    80104e9a <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e49:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104e4f:	83 c0 08             	add    $0x8,%eax
80104e52:	89 c2                	mov    %eax,%edx
80104e54:	83 ec 08             	sub    $0x8,%esp
80104e57:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e5a:	50                   	push   %eax
80104e5b:	52                   	push   %edx
80104e5c:	e8 a2 02 00 00       	call   80105103 <getcallerpcs>
80104e61:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e6b:	eb 1c                	jmp    80104e89 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e74:	83 ec 08             	sub    $0x8,%esp
80104e77:	50                   	push   %eax
80104e78:	68 f9 8a 10 80       	push   $0x80108af9
80104e7d:	e8 7e b5 ff ff       	call   80100400 <cprintf>
80104e82:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e89:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e8d:	7f 0b                	jg     80104e9a <procdump+0xd2>
80104e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e92:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e96:	85 c0                	test   %eax,%eax
80104e98:	75 d3                	jne    80104e6d <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e9a:	83 ec 0c             	sub    $0xc,%esp
80104e9d:	68 fd 8a 10 80       	push   $0x80108afd
80104ea2:	e8 59 b5 ff ff       	call   80100400 <cprintf>
80104ea7:	83 c4 10             	add    $0x10,%esp
80104eaa:	eb 01                	jmp    80104ead <procdump+0xe5>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104eac:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ead:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104eb4:	81 7d f0 d4 5e 11 80 	cmpl   $0x80115ed4,-0x10(%ebp)
80104ebb:	0f 82 19 ff ff ff    	jb     80104dda <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ec1:	90                   	nop
80104ec2:	c9                   	leave  
80104ec3:	c3                   	ret    

80104ec4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104ec4:	55                   	push   %ebp
80104ec5:	89 e5                	mov    %esp,%ebp
80104ec7:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104eca:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecd:	83 c0 04             	add    $0x4,%eax
80104ed0:	83 ec 08             	sub    $0x8,%esp
80104ed3:	68 29 8b 10 80       	push   $0x80108b29
80104ed8:	50                   	push   %eax
80104ed9:	e8 43 01 00 00       	call   80105021 <initlock>
80104ede:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee4:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ee7:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104eea:	8b 45 08             	mov    0x8(%ebp),%eax
80104eed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104efd:	90                   	nop
80104efe:	c9                   	leave  
80104eff:	c3                   	ret    

80104f00 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104f00:	55                   	push   %ebp
80104f01:	89 e5                	mov    %esp,%ebp
80104f03:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f06:	8b 45 08             	mov    0x8(%ebp),%eax
80104f09:	83 c0 04             	add    $0x4,%eax
80104f0c:	83 ec 0c             	sub    $0xc,%esp
80104f0f:	50                   	push   %eax
80104f10:	e8 2e 01 00 00       	call   80105043 <acquire>
80104f15:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f18:	eb 15                	jmp    80104f2f <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1d:	83 c0 04             	add    $0x4,%eax
80104f20:	83 ec 08             	sub    $0x8,%esp
80104f23:	50                   	push   %eax
80104f24:	ff 75 08             	pushl  0x8(%ebp)
80104f27:	e8 f5 fc ff ff       	call   80104c21 <sleep>
80104f2c:	83 c4 10             	add    $0x10,%esp

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f32:	8b 00                	mov    (%eax),%eax
80104f34:	85 c0                	test   %eax,%eax
80104f36:	75 e2                	jne    80104f1a <acquiresleep+0x1a>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104f38:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f41:	e8 da f3 ff ff       	call   80104320 <myproc>
80104f46:	8b 50 10             	mov    0x10(%eax),%edx
80104f49:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4c:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	83 c0 04             	add    $0x4,%eax
80104f55:	83 ec 0c             	sub    $0xc,%esp
80104f58:	50                   	push   %eax
80104f59:	e8 53 01 00 00       	call   801050b1 <release>
80104f5e:	83 c4 10             	add    $0x10,%esp
}
80104f61:	90                   	nop
80104f62:	c9                   	leave  
80104f63:	c3                   	ret    

80104f64 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f64:	55                   	push   %ebp
80104f65:	89 e5                	mov    %esp,%ebp
80104f67:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6d:	83 c0 04             	add    $0x4,%eax
80104f70:	83 ec 0c             	sub    $0xc,%esp
80104f73:	50                   	push   %eax
80104f74:	e8 ca 00 00 00       	call   80105043 <acquire>
80104f79:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f85:	8b 45 08             	mov    0x8(%ebp),%eax
80104f88:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f8f:	83 ec 0c             	sub    $0xc,%esp
80104f92:	ff 75 08             	pushl  0x8(%ebp)
80104f95:	e8 70 fd ff ff       	call   80104d0a <wakeup>
80104f9a:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa0:	83 c0 04             	add    $0x4,%eax
80104fa3:	83 ec 0c             	sub    $0xc,%esp
80104fa6:	50                   	push   %eax
80104fa7:	e8 05 01 00 00       	call   801050b1 <release>
80104fac:	83 c4 10             	add    $0x10,%esp
}
80104faf:	90                   	nop
80104fb0:	c9                   	leave  
80104fb1:	c3                   	ret    

80104fb2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104fb2:	55                   	push   %ebp
80104fb3:	89 e5                	mov    %esp,%ebp
80104fb5:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbb:	83 c0 04             	add    $0x4,%eax
80104fbe:	83 ec 0c             	sub    $0xc,%esp
80104fc1:	50                   	push   %eax
80104fc2:	e8 7c 00 00 00       	call   80105043 <acquire>
80104fc7:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104fca:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcd:	8b 00                	mov    (%eax),%eax
80104fcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd5:	83 c0 04             	add    $0x4,%eax
80104fd8:	83 ec 0c             	sub    $0xc,%esp
80104fdb:	50                   	push   %eax
80104fdc:	e8 d0 00 00 00       	call   801050b1 <release>
80104fe1:	83 c4 10             	add    $0x10,%esp
  return r;
80104fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fe7:	c9                   	leave  
80104fe8:	c3                   	ret    

80104fe9 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fe9:	55                   	push   %ebp
80104fea:	89 e5                	mov    %esp,%ebp
80104fec:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fef:	9c                   	pushf  
80104ff0:	58                   	pop    %eax
80104ff1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ff4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ff7:	c9                   	leave  
80104ff8:	c3                   	ret    

80104ff9 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104ff9:	55                   	push   %ebp
80104ffa:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ffc:	fa                   	cli    
}
80104ffd:	90                   	nop
80104ffe:	5d                   	pop    %ebp
80104fff:	c3                   	ret    

80105000 <sti>:

static inline void
sti(void)
{
80105000:	55                   	push   %ebp
80105001:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105003:	fb                   	sti    
}
80105004:	90                   	nop
80105005:	5d                   	pop    %ebp
80105006:	c3                   	ret    

80105007 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105007:	55                   	push   %ebp
80105008:	89 e5                	mov    %esp,%ebp
8010500a:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010500d:	8b 55 08             	mov    0x8(%ebp),%edx
80105010:	8b 45 0c             	mov    0xc(%ebp),%eax
80105013:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105016:	f0 87 02             	lock xchg %eax,(%edx)
80105019:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010501c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010501f:	c9                   	leave  
80105020:	c3                   	ret    

80105021 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105021:	55                   	push   %ebp
80105022:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105024:	8b 45 08             	mov    0x8(%ebp),%eax
80105027:	8b 55 0c             	mov    0xc(%ebp),%edx
8010502a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010502d:	8b 45 08             	mov    0x8(%ebp),%eax
80105030:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105036:	8b 45 08             	mov    0x8(%ebp),%eax
80105039:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105040:	90                   	nop
80105041:	5d                   	pop    %ebp
80105042:	c3                   	ret    

80105043 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105043:	55                   	push   %ebp
80105044:	89 e5                	mov    %esp,%ebp
80105046:	53                   	push   %ebx
80105047:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010504a:	e8 5f 01 00 00       	call   801051ae <pushcli>
  if(holding(lk))
8010504f:	8b 45 08             	mov    0x8(%ebp),%eax
80105052:	83 ec 0c             	sub    $0xc,%esp
80105055:	50                   	push   %eax
80105056:	e8 22 01 00 00       	call   8010517d <holding>
8010505b:	83 c4 10             	add    $0x10,%esp
8010505e:	85 c0                	test   %eax,%eax
80105060:	74 0d                	je     8010506f <acquire+0x2c>
    panic("acquire");
80105062:	83 ec 0c             	sub    $0xc,%esp
80105065:	68 34 8b 10 80       	push   $0x80108b34
8010506a:	e8 31 b5 ff ff       	call   801005a0 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010506f:	90                   	nop
80105070:	8b 45 08             	mov    0x8(%ebp),%eax
80105073:	83 ec 08             	sub    $0x8,%esp
80105076:	6a 01                	push   $0x1
80105078:	50                   	push   %eax
80105079:	e8 89 ff ff ff       	call   80105007 <xchg>
8010507e:	83 c4 10             	add    $0x10,%esp
80105081:	85 c0                	test   %eax,%eax
80105083:	75 eb                	jne    80105070 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105085:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010508a:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010508d:	e8 16 f2 ff ff       	call   801042a8 <mycpu>
80105092:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105095:	8b 45 08             	mov    0x8(%ebp),%eax
80105098:	83 c0 0c             	add    $0xc,%eax
8010509b:	83 ec 08             	sub    $0x8,%esp
8010509e:	50                   	push   %eax
8010509f:	8d 45 08             	lea    0x8(%ebp),%eax
801050a2:	50                   	push   %eax
801050a3:	e8 5b 00 00 00       	call   80105103 <getcallerpcs>
801050a8:	83 c4 10             	add    $0x10,%esp
}
801050ab:	90                   	nop
801050ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050af:	c9                   	leave  
801050b0:	c3                   	ret    

801050b1 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050b1:	55                   	push   %ebp
801050b2:	89 e5                	mov    %esp,%ebp
801050b4:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050b7:	83 ec 0c             	sub    $0xc,%esp
801050ba:	ff 75 08             	pushl  0x8(%ebp)
801050bd:	e8 bb 00 00 00       	call   8010517d <holding>
801050c2:	83 c4 10             	add    $0x10,%esp
801050c5:	85 c0                	test   %eax,%eax
801050c7:	75 0d                	jne    801050d6 <release+0x25>
    panic("release");
801050c9:	83 ec 0c             	sub    $0xc,%esp
801050cc:	68 3c 8b 10 80       	push   $0x80108b3c
801050d1:	e8 ca b4 ff ff       	call   801005a0 <panic>

  lk->pcs[0] = 0;
801050d6:	8b 45 08             	mov    0x8(%ebp),%eax
801050d9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050e0:	8b 45 08             	mov    0x8(%ebp),%eax
801050e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801050ea:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801050ef:	8b 45 08             	mov    0x8(%ebp),%eax
801050f2:	8b 55 08             	mov    0x8(%ebp),%edx
801050f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801050fb:	e8 fc 00 00 00       	call   801051fc <popcli>
}
80105100:	90                   	nop
80105101:	c9                   	leave  
80105102:	c3                   	ret    

80105103 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105103:	55                   	push   %ebp
80105104:	89 e5                	mov    %esp,%ebp
80105106:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105109:	8b 45 08             	mov    0x8(%ebp),%eax
8010510c:	83 e8 08             	sub    $0x8,%eax
8010510f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105112:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105119:	eb 38                	jmp    80105153 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010511b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010511f:	74 53                	je     80105174 <getcallerpcs+0x71>
80105121:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105128:	76 4a                	jbe    80105174 <getcallerpcs+0x71>
8010512a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010512e:	74 44                	je     80105174 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105130:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105133:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010513a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513d:	01 c2                	add    %eax,%edx
8010513f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105142:	8b 40 04             	mov    0x4(%eax),%eax
80105145:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105147:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010514a:	8b 00                	mov    (%eax),%eax
8010514c:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010514f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105153:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105157:	7e c2                	jle    8010511b <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105159:	eb 19                	jmp    80105174 <getcallerpcs+0x71>
    pcs[i] = 0;
8010515b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010515e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105165:	8b 45 0c             	mov    0xc(%ebp),%eax
80105168:	01 d0                	add    %edx,%eax
8010516a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105170:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105174:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105178:	7e e1                	jle    8010515b <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010517a:	90                   	nop
8010517b:	c9                   	leave  
8010517c:	c3                   	ret    

8010517d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010517d:	55                   	push   %ebp
8010517e:	89 e5                	mov    %esp,%ebp
80105180:	53                   	push   %ebx
80105181:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105184:	8b 45 08             	mov    0x8(%ebp),%eax
80105187:	8b 00                	mov    (%eax),%eax
80105189:	85 c0                	test   %eax,%eax
8010518b:	74 16                	je     801051a3 <holding+0x26>
8010518d:	8b 45 08             	mov    0x8(%ebp),%eax
80105190:	8b 58 08             	mov    0x8(%eax),%ebx
80105193:	e8 10 f1 ff ff       	call   801042a8 <mycpu>
80105198:	39 c3                	cmp    %eax,%ebx
8010519a:	75 07                	jne    801051a3 <holding+0x26>
8010519c:	b8 01 00 00 00       	mov    $0x1,%eax
801051a1:	eb 05                	jmp    801051a8 <holding+0x2b>
801051a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a8:	83 c4 04             	add    $0x4,%esp
801051ab:	5b                   	pop    %ebx
801051ac:	5d                   	pop    %ebp
801051ad:	c3                   	ret    

801051ae <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051ae:	55                   	push   %ebp
801051af:	89 e5                	mov    %esp,%ebp
801051b1:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801051b4:	e8 30 fe ff ff       	call   80104fe9 <readeflags>
801051b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801051bc:	e8 38 fe ff ff       	call   80104ff9 <cli>
  if(mycpu()->ncli == 0)
801051c1:	e8 e2 f0 ff ff       	call   801042a8 <mycpu>
801051c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051cc:	85 c0                	test   %eax,%eax
801051ce:	75 15                	jne    801051e5 <pushcli+0x37>
    mycpu()->intena = eflags & FL_IF;
801051d0:	e8 d3 f0 ff ff       	call   801042a8 <mycpu>
801051d5:	89 c2                	mov    %eax,%edx
801051d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051da:	25 00 02 00 00       	and    $0x200,%eax
801051df:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
  mycpu()->ncli += 1;
801051e5:	e8 be f0 ff ff       	call   801042a8 <mycpu>
801051ea:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051f0:	83 c2 01             	add    $0x1,%edx
801051f3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801051f9:	90                   	nop
801051fa:	c9                   	leave  
801051fb:	c3                   	ret    

801051fc <popcli>:

void
popcli(void)
{
801051fc:	55                   	push   %ebp
801051fd:	89 e5                	mov    %esp,%ebp
801051ff:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105202:	e8 e2 fd ff ff       	call   80104fe9 <readeflags>
80105207:	25 00 02 00 00       	and    $0x200,%eax
8010520c:	85 c0                	test   %eax,%eax
8010520e:	74 0d                	je     8010521d <popcli+0x21>
    panic("popcli - interruptible");
80105210:	83 ec 0c             	sub    $0xc,%esp
80105213:	68 44 8b 10 80       	push   $0x80108b44
80105218:	e8 83 b3 ff ff       	call   801005a0 <panic>
  if(--mycpu()->ncli < 0)
8010521d:	e8 86 f0 ff ff       	call   801042a8 <mycpu>
80105222:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105228:	83 ea 01             	sub    $0x1,%edx
8010522b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105231:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105237:	85 c0                	test   %eax,%eax
80105239:	79 0d                	jns    80105248 <popcli+0x4c>
    panic("popcli");
8010523b:	83 ec 0c             	sub    $0xc,%esp
8010523e:	68 5b 8b 10 80       	push   $0x80108b5b
80105243:	e8 58 b3 ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105248:	e8 5b f0 ff ff       	call   801042a8 <mycpu>
8010524d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105253:	85 c0                	test   %eax,%eax
80105255:	75 14                	jne    8010526b <popcli+0x6f>
80105257:	e8 4c f0 ff ff       	call   801042a8 <mycpu>
8010525c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105262:	85 c0                	test   %eax,%eax
80105264:	74 05                	je     8010526b <popcli+0x6f>
    sti();
80105266:	e8 95 fd ff ff       	call   80105000 <sti>
}
8010526b:	90                   	nop
8010526c:	c9                   	leave  
8010526d:	c3                   	ret    

8010526e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010526e:	55                   	push   %ebp
8010526f:	89 e5                	mov    %esp,%ebp
80105271:	57                   	push   %edi
80105272:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105273:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105276:	8b 55 10             	mov    0x10(%ebp),%edx
80105279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527c:	89 cb                	mov    %ecx,%ebx
8010527e:	89 df                	mov    %ebx,%edi
80105280:	89 d1                	mov    %edx,%ecx
80105282:	fc                   	cld    
80105283:	f3 aa                	rep stos %al,%es:(%edi)
80105285:	89 ca                	mov    %ecx,%edx
80105287:	89 fb                	mov    %edi,%ebx
80105289:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010528c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010528f:	90                   	nop
80105290:	5b                   	pop    %ebx
80105291:	5f                   	pop    %edi
80105292:	5d                   	pop    %ebp
80105293:	c3                   	ret    

80105294 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105294:	55                   	push   %ebp
80105295:	89 e5                	mov    %esp,%ebp
80105297:	57                   	push   %edi
80105298:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105299:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010529c:	8b 55 10             	mov    0x10(%ebp),%edx
8010529f:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a2:	89 cb                	mov    %ecx,%ebx
801052a4:	89 df                	mov    %ebx,%edi
801052a6:	89 d1                	mov    %edx,%ecx
801052a8:	fc                   	cld    
801052a9:	f3 ab                	rep stos %eax,%es:(%edi)
801052ab:	89 ca                	mov    %ecx,%edx
801052ad:	89 fb                	mov    %edi,%ebx
801052af:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052b2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052b5:	90                   	nop
801052b6:	5b                   	pop    %ebx
801052b7:	5f                   	pop    %edi
801052b8:	5d                   	pop    %ebp
801052b9:	c3                   	ret    

801052ba <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052ba:	55                   	push   %ebp
801052bb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052bd:	8b 45 08             	mov    0x8(%ebp),%eax
801052c0:	83 e0 03             	and    $0x3,%eax
801052c3:	85 c0                	test   %eax,%eax
801052c5:	75 43                	jne    8010530a <memset+0x50>
801052c7:	8b 45 10             	mov    0x10(%ebp),%eax
801052ca:	83 e0 03             	and    $0x3,%eax
801052cd:	85 c0                	test   %eax,%eax
801052cf:	75 39                	jne    8010530a <memset+0x50>
    c &= 0xFF;
801052d1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052d8:	8b 45 10             	mov    0x10(%ebp),%eax
801052db:	c1 e8 02             	shr    $0x2,%eax
801052de:	89 c1                	mov    %eax,%ecx
801052e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e3:	c1 e0 18             	shl    $0x18,%eax
801052e6:	89 c2                	mov    %eax,%edx
801052e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052eb:	c1 e0 10             	shl    $0x10,%eax
801052ee:	09 c2                	or     %eax,%edx
801052f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f3:	c1 e0 08             	shl    $0x8,%eax
801052f6:	09 d0                	or     %edx,%eax
801052f8:	0b 45 0c             	or     0xc(%ebp),%eax
801052fb:	51                   	push   %ecx
801052fc:	50                   	push   %eax
801052fd:	ff 75 08             	pushl  0x8(%ebp)
80105300:	e8 8f ff ff ff       	call   80105294 <stosl>
80105305:	83 c4 0c             	add    $0xc,%esp
80105308:	eb 12                	jmp    8010531c <memset+0x62>
  } else
    stosb(dst, c, n);
8010530a:	8b 45 10             	mov    0x10(%ebp),%eax
8010530d:	50                   	push   %eax
8010530e:	ff 75 0c             	pushl  0xc(%ebp)
80105311:	ff 75 08             	pushl  0x8(%ebp)
80105314:	e8 55 ff ff ff       	call   8010526e <stosb>
80105319:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010531c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010531f:	c9                   	leave  
80105320:	c3                   	ret    

80105321 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105321:	55                   	push   %ebp
80105322:	89 e5                	mov    %esp,%ebp
80105324:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105327:	8b 45 08             	mov    0x8(%ebp),%eax
8010532a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010532d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105330:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105333:	eb 30                	jmp    80105365 <memcmp+0x44>
    if(*s1 != *s2)
80105335:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105338:	0f b6 10             	movzbl (%eax),%edx
8010533b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010533e:	0f b6 00             	movzbl (%eax),%eax
80105341:	38 c2                	cmp    %al,%dl
80105343:	74 18                	je     8010535d <memcmp+0x3c>
      return *s1 - *s2;
80105345:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105348:	0f b6 00             	movzbl (%eax),%eax
8010534b:	0f b6 d0             	movzbl %al,%edx
8010534e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105351:	0f b6 00             	movzbl (%eax),%eax
80105354:	0f b6 c0             	movzbl %al,%eax
80105357:	29 c2                	sub    %eax,%edx
80105359:	89 d0                	mov    %edx,%eax
8010535b:	eb 1a                	jmp    80105377 <memcmp+0x56>
    s1++, s2++;
8010535d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105361:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105365:	8b 45 10             	mov    0x10(%ebp),%eax
80105368:	8d 50 ff             	lea    -0x1(%eax),%edx
8010536b:	89 55 10             	mov    %edx,0x10(%ebp)
8010536e:	85 c0                	test   %eax,%eax
80105370:	75 c3                	jne    80105335 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105372:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105377:	c9                   	leave  
80105378:	c3                   	ret    

80105379 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105379:	55                   	push   %ebp
8010537a:	89 e5                	mov    %esp,%ebp
8010537c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010537f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105385:	8b 45 08             	mov    0x8(%ebp),%eax
80105388:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010538b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105391:	73 54                	jae    801053e7 <memmove+0x6e>
80105393:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105396:	8b 45 10             	mov    0x10(%ebp),%eax
80105399:	01 d0                	add    %edx,%eax
8010539b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010539e:	76 47                	jbe    801053e7 <memmove+0x6e>
    s += n;
801053a0:	8b 45 10             	mov    0x10(%ebp),%eax
801053a3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053a6:	8b 45 10             	mov    0x10(%ebp),%eax
801053a9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053ac:	eb 13                	jmp    801053c1 <memmove+0x48>
      *--d = *--s;
801053ae:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053b2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b9:	0f b6 10             	movzbl (%eax),%edx
801053bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053bf:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801053c1:	8b 45 10             	mov    0x10(%ebp),%eax
801053c4:	8d 50 ff             	lea    -0x1(%eax),%edx
801053c7:	89 55 10             	mov    %edx,0x10(%ebp)
801053ca:	85 c0                	test   %eax,%eax
801053cc:	75 e0                	jne    801053ae <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801053ce:	eb 24                	jmp    801053f4 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801053d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d3:	8d 50 01             	lea    0x1(%eax),%edx
801053d6:	89 55 f8             	mov    %edx,-0x8(%ebp)
801053d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053dc:	8d 4a 01             	lea    0x1(%edx),%ecx
801053df:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801053e2:	0f b6 12             	movzbl (%edx),%edx
801053e5:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053e7:	8b 45 10             	mov    0x10(%ebp),%eax
801053ea:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ed:	89 55 10             	mov    %edx,0x10(%ebp)
801053f0:	85 c0                	test   %eax,%eax
801053f2:	75 dc                	jne    801053d0 <memmove+0x57>
      *d++ = *s++;

  return dst;
801053f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053f7:	c9                   	leave  
801053f8:	c3                   	ret    

801053f9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053f9:	55                   	push   %ebp
801053fa:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801053fc:	ff 75 10             	pushl  0x10(%ebp)
801053ff:	ff 75 0c             	pushl  0xc(%ebp)
80105402:	ff 75 08             	pushl  0x8(%ebp)
80105405:	e8 6f ff ff ff       	call   80105379 <memmove>
8010540a:	83 c4 0c             	add    $0xc,%esp
}
8010540d:	c9                   	leave  
8010540e:	c3                   	ret    

8010540f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010540f:	55                   	push   %ebp
80105410:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105412:	eb 0c                	jmp    80105420 <strncmp+0x11>
    n--, p++, q++;
80105414:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105418:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010541c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105420:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105424:	74 1a                	je     80105440 <strncmp+0x31>
80105426:	8b 45 08             	mov    0x8(%ebp),%eax
80105429:	0f b6 00             	movzbl (%eax),%eax
8010542c:	84 c0                	test   %al,%al
8010542e:	74 10                	je     80105440 <strncmp+0x31>
80105430:	8b 45 08             	mov    0x8(%ebp),%eax
80105433:	0f b6 10             	movzbl (%eax),%edx
80105436:	8b 45 0c             	mov    0xc(%ebp),%eax
80105439:	0f b6 00             	movzbl (%eax),%eax
8010543c:	38 c2                	cmp    %al,%dl
8010543e:	74 d4                	je     80105414 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105440:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105444:	75 07                	jne    8010544d <strncmp+0x3e>
    return 0;
80105446:	b8 00 00 00 00       	mov    $0x0,%eax
8010544b:	eb 16                	jmp    80105463 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010544d:	8b 45 08             	mov    0x8(%ebp),%eax
80105450:	0f b6 00             	movzbl (%eax),%eax
80105453:	0f b6 d0             	movzbl %al,%edx
80105456:	8b 45 0c             	mov    0xc(%ebp),%eax
80105459:	0f b6 00             	movzbl (%eax),%eax
8010545c:	0f b6 c0             	movzbl %al,%eax
8010545f:	29 c2                	sub    %eax,%edx
80105461:	89 d0                	mov    %edx,%eax
}
80105463:	5d                   	pop    %ebp
80105464:	c3                   	ret    

80105465 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105465:	55                   	push   %ebp
80105466:	89 e5                	mov    %esp,%ebp
80105468:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010546b:	8b 45 08             	mov    0x8(%ebp),%eax
8010546e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105471:	90                   	nop
80105472:	8b 45 10             	mov    0x10(%ebp),%eax
80105475:	8d 50 ff             	lea    -0x1(%eax),%edx
80105478:	89 55 10             	mov    %edx,0x10(%ebp)
8010547b:	85 c0                	test   %eax,%eax
8010547d:	7e 2c                	jle    801054ab <strncpy+0x46>
8010547f:	8b 45 08             	mov    0x8(%ebp),%eax
80105482:	8d 50 01             	lea    0x1(%eax),%edx
80105485:	89 55 08             	mov    %edx,0x8(%ebp)
80105488:	8b 55 0c             	mov    0xc(%ebp),%edx
8010548b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010548e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105491:	0f b6 12             	movzbl (%edx),%edx
80105494:	88 10                	mov    %dl,(%eax)
80105496:	0f b6 00             	movzbl (%eax),%eax
80105499:	84 c0                	test   %al,%al
8010549b:	75 d5                	jne    80105472 <strncpy+0xd>
    ;
  while(n-- > 0)
8010549d:	eb 0c                	jmp    801054ab <strncpy+0x46>
    *s++ = 0;
8010549f:	8b 45 08             	mov    0x8(%ebp),%eax
801054a2:	8d 50 01             	lea    0x1(%eax),%edx
801054a5:	89 55 08             	mov    %edx,0x8(%ebp)
801054a8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801054ab:	8b 45 10             	mov    0x10(%ebp),%eax
801054ae:	8d 50 ff             	lea    -0x1(%eax),%edx
801054b1:	89 55 10             	mov    %edx,0x10(%ebp)
801054b4:	85 c0                	test   %eax,%eax
801054b6:	7f e7                	jg     8010549f <strncpy+0x3a>
    *s++ = 0;
  return os;
801054b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054bb:	c9                   	leave  
801054bc:	c3                   	ret    

801054bd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054bd:	55                   	push   %ebp
801054be:	89 e5                	mov    %esp,%ebp
801054c0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054c3:	8b 45 08             	mov    0x8(%ebp),%eax
801054c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054cd:	7f 05                	jg     801054d4 <safestrcpy+0x17>
    return os;
801054cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d2:	eb 31                	jmp    80105505 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054d4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054dc:	7e 1e                	jle    801054fc <safestrcpy+0x3f>
801054de:	8b 45 08             	mov    0x8(%ebp),%eax
801054e1:	8d 50 01             	lea    0x1(%eax),%edx
801054e4:	89 55 08             	mov    %edx,0x8(%ebp)
801054e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ea:	8d 4a 01             	lea    0x1(%edx),%ecx
801054ed:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054f0:	0f b6 12             	movzbl (%edx),%edx
801054f3:	88 10                	mov    %dl,(%eax)
801054f5:	0f b6 00             	movzbl (%eax),%eax
801054f8:	84 c0                	test   %al,%al
801054fa:	75 d8                	jne    801054d4 <safestrcpy+0x17>
    ;
  *s = 0;
801054fc:	8b 45 08             	mov    0x8(%ebp),%eax
801054ff:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105502:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105505:	c9                   	leave  
80105506:	c3                   	ret    

80105507 <strlen>:

int
strlen(const char *s)
{
80105507:	55                   	push   %ebp
80105508:	89 e5                	mov    %esp,%ebp
8010550a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010550d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105514:	eb 04                	jmp    8010551a <strlen+0x13>
80105516:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010551a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	01 d0                	add    %edx,%eax
80105522:	0f b6 00             	movzbl (%eax),%eax
80105525:	84 c0                	test   %al,%al
80105527:	75 ed                	jne    80105516 <strlen+0xf>
    ;
  return n;
80105529:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552c:	c9                   	leave  
8010552d:	c3                   	ret    

8010552e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010552e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105532:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105536:	55                   	push   %ebp
  pushl %ebx
80105537:	53                   	push   %ebx
  pushl %esi
80105538:	56                   	push   %esi
  pushl %edi
80105539:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010553a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010553c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010553e:	5f                   	pop    %edi
  popl %esi
8010553f:	5e                   	pop    %esi
  popl %ebx
80105540:	5b                   	pop    %ebx
  popl %ebp
80105541:	5d                   	pop    %ebp
  ret
80105542:	c3                   	ret    

80105543 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105543:	55                   	push   %ebp
80105544:	89 e5                	mov    %esp,%ebp
80105546:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105549:	e8 d2 ed ff ff       	call   80104320 <myproc>
8010554e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105554:	8b 00                	mov    (%eax),%eax
80105556:	3b 45 08             	cmp    0x8(%ebp),%eax
80105559:	76 0f                	jbe    8010556a <fetchint+0x27>
8010555b:	8b 45 08             	mov    0x8(%ebp),%eax
8010555e:	8d 50 04             	lea    0x4(%eax),%edx
80105561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105564:	8b 00                	mov    (%eax),%eax
80105566:	39 c2                	cmp    %eax,%edx
80105568:	76 07                	jbe    80105571 <fetchint+0x2e>
    return -1;
8010556a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556f:	eb 0f                	jmp    80105580 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105571:	8b 45 08             	mov    0x8(%ebp),%eax
80105574:	8b 10                	mov    (%eax),%edx
80105576:	8b 45 0c             	mov    0xc(%ebp),%eax
80105579:	89 10                	mov    %edx,(%eax)
  return 0;
8010557b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105580:	c9                   	leave  
80105581:	c3                   	ret    

80105582 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105582:	55                   	push   %ebp
80105583:	89 e5                	mov    %esp,%ebp
80105585:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105588:	e8 93 ed ff ff       	call   80104320 <myproc>
8010558d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105590:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105593:	8b 00                	mov    (%eax),%eax
80105595:	3b 45 08             	cmp    0x8(%ebp),%eax
80105598:	77 07                	ja     801055a1 <fetchstr+0x1f>
    return -1;
8010559a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010559f:	eb 43                	jmp    801055e4 <fetchstr+0x62>
  *pp = (char*)addr;
801055a1:	8b 55 08             	mov    0x8(%ebp),%edx
801055a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a7:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801055a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ac:	8b 00                	mov    (%eax),%eax
801055ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801055b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b4:	8b 00                	mov    (%eax),%eax
801055b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055b9:	eb 1c                	jmp    801055d7 <fetchstr+0x55>
    if(*s == 0)
801055bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055be:	0f b6 00             	movzbl (%eax),%eax
801055c1:	84 c0                	test   %al,%al
801055c3:	75 0e                	jne    801055d3 <fetchstr+0x51>
      return s - *pp;
801055c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055cb:	8b 00                	mov    (%eax),%eax
801055cd:	29 c2                	sub    %eax,%edx
801055cf:	89 d0                	mov    %edx,%eax
801055d1:	eb 11                	jmp    801055e4 <fetchstr+0x62>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801055d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801055dd:	72 dc                	jb     801055bb <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801055df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055e4:	c9                   	leave  
801055e5:	c3                   	ret    

801055e6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055e6:	55                   	push   %ebp
801055e7:	89 e5                	mov    %esp,%ebp
801055e9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801055ec:	e8 2f ed ff ff       	call   80104320 <myproc>
801055f1:	8b 40 18             	mov    0x18(%eax),%eax
801055f4:	8b 40 44             	mov    0x44(%eax),%eax
801055f7:	8b 55 08             	mov    0x8(%ebp),%edx
801055fa:	c1 e2 02             	shl    $0x2,%edx
801055fd:	01 d0                	add    %edx,%eax
801055ff:	83 c0 04             	add    $0x4,%eax
80105602:	83 ec 08             	sub    $0x8,%esp
80105605:	ff 75 0c             	pushl  0xc(%ebp)
80105608:	50                   	push   %eax
80105609:	e8 35 ff ff ff       	call   80105543 <fetchint>
8010560e:	83 c4 10             	add    $0x10,%esp
}
80105611:	c9                   	leave  
80105612:	c3                   	ret    

80105613 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105613:	55                   	push   %ebp
80105614:	89 e5                	mov    %esp,%ebp
80105616:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105619:	e8 02 ed ff ff       	call   80104320 <myproc>
8010561e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105621:	83 ec 08             	sub    $0x8,%esp
80105624:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105627:	50                   	push   %eax
80105628:	ff 75 08             	pushl  0x8(%ebp)
8010562b:	e8 b6 ff ff ff       	call   801055e6 <argint>
80105630:	83 c4 10             	add    $0x10,%esp
80105633:	85 c0                	test   %eax,%eax
80105635:	79 07                	jns    8010563e <argptr+0x2b>
    return -1;
80105637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010563c:	eb 3b                	jmp    80105679 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010563e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105642:	78 1f                	js     80105663 <argptr+0x50>
80105644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105647:	8b 00                	mov    (%eax),%eax
80105649:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010564c:	39 d0                	cmp    %edx,%eax
8010564e:	76 13                	jbe    80105663 <argptr+0x50>
80105650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105653:	89 c2                	mov    %eax,%edx
80105655:	8b 45 10             	mov    0x10(%ebp),%eax
80105658:	01 c2                	add    %eax,%edx
8010565a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565d:	8b 00                	mov    (%eax),%eax
8010565f:	39 c2                	cmp    %eax,%edx
80105661:	76 07                	jbe    8010566a <argptr+0x57>
    return -1;
80105663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105668:	eb 0f                	jmp    80105679 <argptr+0x66>
  *pp = (char*)i;
8010566a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010566d:	89 c2                	mov    %eax,%edx
8010566f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105672:	89 10                	mov    %edx,(%eax)
  return 0;
80105674:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105679:	c9                   	leave  
8010567a:	c3                   	ret    

8010567b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010567b:	55                   	push   %ebp
8010567c:	89 e5                	mov    %esp,%ebp
8010567e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105681:	83 ec 08             	sub    $0x8,%esp
80105684:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105687:	50                   	push   %eax
80105688:	ff 75 08             	pushl  0x8(%ebp)
8010568b:	e8 56 ff ff ff       	call   801055e6 <argint>
80105690:	83 c4 10             	add    $0x10,%esp
80105693:	85 c0                	test   %eax,%eax
80105695:	79 07                	jns    8010569e <argstr+0x23>
    return -1;
80105697:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010569c:	eb 12                	jmp    801056b0 <argstr+0x35>
  return fetchstr(addr, pp);
8010569e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a1:	83 ec 08             	sub    $0x8,%esp
801056a4:	ff 75 0c             	pushl  0xc(%ebp)
801056a7:	50                   	push   %eax
801056a8:	e8 d5 fe ff ff       	call   80105582 <fetchstr>
801056ad:	83 c4 10             	add    $0x10,%esp
}
801056b0:	c9                   	leave  
801056b1:	c3                   	ret    

801056b2 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
801056b2:	55                   	push   %ebp
801056b3:	89 e5                	mov    %esp,%ebp
801056b5:	53                   	push   %ebx
801056b6:	83 ec 14             	sub    $0x14,%esp
  int num;
  struct proc *curproc = myproc();
801056b9:	e8 62 ec ff ff       	call   80104320 <myproc>
801056be:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801056c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c4:	8b 40 18             	mov    0x18(%eax),%eax
801056c7:	8b 40 1c             	mov    0x1c(%eax),%eax
801056ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056d1:	7e 2d                	jle    80105700 <syscall+0x4e>
801056d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d6:	83 f8 17             	cmp    $0x17,%eax
801056d9:	77 25                	ja     80105700 <syscall+0x4e>
801056db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056de:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801056e5:	85 c0                	test   %eax,%eax
801056e7:	74 17                	je     80105700 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ec:	8b 58 18             	mov    0x18(%eax),%ebx
801056ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f2:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801056f9:	ff d0                	call   *%eax
801056fb:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056fe:	eb 2b                	jmp    8010572b <syscall+0x79>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105703:	8d 50 6c             	lea    0x6c(%eax),%edx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105709:	8b 40 10             	mov    0x10(%eax),%eax
8010570c:	ff 75 f0             	pushl  -0x10(%ebp)
8010570f:	52                   	push   %edx
80105710:	50                   	push   %eax
80105711:	68 62 8b 10 80       	push   $0x80108b62
80105716:	e8 e5 ac ff ff       	call   80100400 <cprintf>
8010571b:	83 c4 10             	add    $0x10,%esp
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
8010571e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105721:	8b 40 18             	mov    0x18(%eax),%eax
80105724:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010572b:	90                   	nop
8010572c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010572f:	c9                   	leave  
80105730:	c3                   	ret    

80105731 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105731:	55                   	push   %ebp
80105732:	89 e5                	mov    %esp,%ebp
80105734:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105737:	83 ec 08             	sub    $0x8,%esp
8010573a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010573d:	50                   	push   %eax
8010573e:	ff 75 08             	pushl  0x8(%ebp)
80105741:	e8 a0 fe ff ff       	call   801055e6 <argint>
80105746:	83 c4 10             	add    $0x10,%esp
80105749:	85 c0                	test   %eax,%eax
8010574b:	79 07                	jns    80105754 <argfd+0x23>
    return -1;
8010574d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105752:	eb 51                	jmp    801057a5 <argfd+0x74>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105757:	85 c0                	test   %eax,%eax
80105759:	78 22                	js     8010577d <argfd+0x4c>
8010575b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575e:	83 f8 0f             	cmp    $0xf,%eax
80105761:	7f 1a                	jg     8010577d <argfd+0x4c>
80105763:	e8 b8 eb ff ff       	call   80104320 <myproc>
80105768:	89 c2                	mov    %eax,%edx
8010576a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576d:	83 c0 08             	add    $0x8,%eax
80105770:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
80105774:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105777:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010577b:	75 07                	jne    80105784 <argfd+0x53>
    return -1;
8010577d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105782:	eb 21                	jmp    801057a5 <argfd+0x74>
  if(pfd)
80105784:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105788:	74 08                	je     80105792 <argfd+0x61>
    *pfd = fd;
8010578a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010578d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105790:	89 10                	mov    %edx,(%eax)
  if(pf)
80105792:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105796:	74 08                	je     801057a0 <argfd+0x6f>
    *pf = f;
80105798:	8b 45 10             	mov    0x10(%ebp),%eax
8010579b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579e:	89 10                	mov    %edx,(%eax)
  return 0;
801057a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057a5:	c9                   	leave  
801057a6:	c3                   	ret    

801057a7 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057a7:	55                   	push   %ebp
801057a8:	89 e5                	mov    %esp,%ebp
801057aa:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801057ad:	e8 6e eb ff ff       	call   80104320 <myproc>
801057b2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801057b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801057bc:	eb 2a                	jmp    801057e8 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801057be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c4:	83 c2 08             	add    $0x8,%edx
801057c7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057cb:	85 c0                	test   %eax,%eax
801057cd:	75 15                	jne    801057e4 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801057cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057d5:	8d 4a 08             	lea    0x8(%edx),%ecx
801057d8:	8b 55 08             	mov    0x8(%ebp),%edx
801057db:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e2:	eb 0f                	jmp    801057f3 <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801057e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801057e8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801057ec:	7e d0                	jle    801057be <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057f3:	c9                   	leave  
801057f4:	c3                   	ret    

801057f5 <sys_dup>:

int
sys_dup(void)
{
801057f5:	55                   	push   %ebp
801057f6:	89 e5                	mov    %esp,%ebp
801057f8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801057fb:	83 ec 04             	sub    $0x4,%esp
801057fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105801:	50                   	push   %eax
80105802:	6a 00                	push   $0x0
80105804:	6a 00                	push   $0x0
80105806:	e8 26 ff ff ff       	call   80105731 <argfd>
8010580b:	83 c4 10             	add    $0x10,%esp
8010580e:	85 c0                	test   %eax,%eax
80105810:	79 07                	jns    80105819 <sys_dup+0x24>
    return -1;
80105812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105817:	eb 31                	jmp    8010584a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581c:	83 ec 0c             	sub    $0xc,%esp
8010581f:	50                   	push   %eax
80105820:	e8 82 ff ff ff       	call   801057a7 <fdalloc>
80105825:	83 c4 10             	add    $0x10,%esp
80105828:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010582b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010582f:	79 07                	jns    80105838 <sys_dup+0x43>
    return -1;
80105831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105836:	eb 12                	jmp    8010584a <sys_dup+0x55>
  filedup(f);
80105838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010583b:	83 ec 0c             	sub    $0xc,%esp
8010583e:	50                   	push   %eax
8010583f:	e8 af b8 ff ff       	call   801010f3 <filedup>
80105844:	83 c4 10             	add    $0x10,%esp
  return fd;
80105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010584a:	c9                   	leave  
8010584b:	c3                   	ret    

8010584c <sys_read>:

int
sys_read(void)
{
8010584c:	55                   	push   %ebp
8010584d:	89 e5                	mov    %esp,%ebp
8010584f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105852:	83 ec 04             	sub    $0x4,%esp
80105855:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105858:	50                   	push   %eax
80105859:	6a 00                	push   $0x0
8010585b:	6a 00                	push   $0x0
8010585d:	e8 cf fe ff ff       	call   80105731 <argfd>
80105862:	83 c4 10             	add    $0x10,%esp
80105865:	85 c0                	test   %eax,%eax
80105867:	78 2e                	js     80105897 <sys_read+0x4b>
80105869:	83 ec 08             	sub    $0x8,%esp
8010586c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010586f:	50                   	push   %eax
80105870:	6a 02                	push   $0x2
80105872:	e8 6f fd ff ff       	call   801055e6 <argint>
80105877:	83 c4 10             	add    $0x10,%esp
8010587a:	85 c0                	test   %eax,%eax
8010587c:	78 19                	js     80105897 <sys_read+0x4b>
8010587e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105881:	83 ec 04             	sub    $0x4,%esp
80105884:	50                   	push   %eax
80105885:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105888:	50                   	push   %eax
80105889:	6a 01                	push   $0x1
8010588b:	e8 83 fd ff ff       	call   80105613 <argptr>
80105890:	83 c4 10             	add    $0x10,%esp
80105893:	85 c0                	test   %eax,%eax
80105895:	79 07                	jns    8010589e <sys_read+0x52>
    return -1;
80105897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589c:	eb 17                	jmp    801058b5 <sys_read+0x69>
  return fileread(f, p, n);
8010589e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a7:	83 ec 04             	sub    $0x4,%esp
801058aa:	51                   	push   %ecx
801058ab:	52                   	push   %edx
801058ac:	50                   	push   %eax
801058ad:	e8 d1 b9 ff ff       	call   80101283 <fileread>
801058b2:	83 c4 10             	add    $0x10,%esp
}
801058b5:	c9                   	leave  
801058b6:	c3                   	ret    

801058b7 <sys_write>:

int
sys_write(void)
{
801058b7:	55                   	push   %ebp
801058b8:	89 e5                	mov    %esp,%ebp
801058ba:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058bd:	83 ec 04             	sub    $0x4,%esp
801058c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c3:	50                   	push   %eax
801058c4:	6a 00                	push   $0x0
801058c6:	6a 00                	push   $0x0
801058c8:	e8 64 fe ff ff       	call   80105731 <argfd>
801058cd:	83 c4 10             	add    $0x10,%esp
801058d0:	85 c0                	test   %eax,%eax
801058d2:	78 2e                	js     80105902 <sys_write+0x4b>
801058d4:	83 ec 08             	sub    $0x8,%esp
801058d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058da:	50                   	push   %eax
801058db:	6a 02                	push   $0x2
801058dd:	e8 04 fd ff ff       	call   801055e6 <argint>
801058e2:	83 c4 10             	add    $0x10,%esp
801058e5:	85 c0                	test   %eax,%eax
801058e7:	78 19                	js     80105902 <sys_write+0x4b>
801058e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ec:	83 ec 04             	sub    $0x4,%esp
801058ef:	50                   	push   %eax
801058f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058f3:	50                   	push   %eax
801058f4:	6a 01                	push   $0x1
801058f6:	e8 18 fd ff ff       	call   80105613 <argptr>
801058fb:	83 c4 10             	add    $0x10,%esp
801058fe:	85 c0                	test   %eax,%eax
80105900:	79 07                	jns    80105909 <sys_write+0x52>
    return -1;
80105902:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105907:	eb 17                	jmp    80105920 <sys_write+0x69>
  return filewrite(f, p, n);
80105909:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010590c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105912:	83 ec 04             	sub    $0x4,%esp
80105915:	51                   	push   %ecx
80105916:	52                   	push   %edx
80105917:	50                   	push   %eax
80105918:	e8 1e ba ff ff       	call   8010133b <filewrite>
8010591d:	83 c4 10             	add    $0x10,%esp
}
80105920:	c9                   	leave  
80105921:	c3                   	ret    

80105922 <sys_close>:

int
sys_close(void)
{
80105922:	55                   	push   %ebp
80105923:	89 e5                	mov    %esp,%ebp
80105925:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105928:	83 ec 04             	sub    $0x4,%esp
8010592b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592e:	50                   	push   %eax
8010592f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105932:	50                   	push   %eax
80105933:	6a 00                	push   $0x0
80105935:	e8 f7 fd ff ff       	call   80105731 <argfd>
8010593a:	83 c4 10             	add    $0x10,%esp
8010593d:	85 c0                	test   %eax,%eax
8010593f:	79 07                	jns    80105948 <sys_close+0x26>
    return -1;
80105941:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105946:	eb 29                	jmp    80105971 <sys_close+0x4f>
  myproc()->ofile[fd] = 0;
80105948:	e8 d3 e9 ff ff       	call   80104320 <myproc>
8010594d:	89 c2                	mov    %eax,%edx
8010594f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105952:	83 c0 08             	add    $0x8,%eax
80105955:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
8010595c:	00 
  fileclose(f);
8010595d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105960:	83 ec 0c             	sub    $0xc,%esp
80105963:	50                   	push   %eax
80105964:	e8 db b7 ff ff       	call   80101144 <fileclose>
80105969:	83 c4 10             	add    $0x10,%esp
  return 0;
8010596c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105971:	c9                   	leave  
80105972:	c3                   	ret    

80105973 <sys_fstat>:

int
sys_fstat(void)
{
80105973:	55                   	push   %ebp
80105974:	89 e5                	mov    %esp,%ebp
80105976:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105979:	83 ec 04             	sub    $0x4,%esp
8010597c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597f:	50                   	push   %eax
80105980:	6a 00                	push   $0x0
80105982:	6a 00                	push   $0x0
80105984:	e8 a8 fd ff ff       	call   80105731 <argfd>
80105989:	83 c4 10             	add    $0x10,%esp
8010598c:	85 c0                	test   %eax,%eax
8010598e:	78 17                	js     801059a7 <sys_fstat+0x34>
80105990:	83 ec 04             	sub    $0x4,%esp
80105993:	6a 14                	push   $0x14
80105995:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105998:	50                   	push   %eax
80105999:	6a 01                	push   $0x1
8010599b:	e8 73 fc ff ff       	call   80105613 <argptr>
801059a0:	83 c4 10             	add    $0x10,%esp
801059a3:	85 c0                	test   %eax,%eax
801059a5:	79 07                	jns    801059ae <sys_fstat+0x3b>
    return -1;
801059a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ac:	eb 13                	jmp    801059c1 <sys_fstat+0x4e>
  return filestat(f, st);
801059ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b4:	83 ec 08             	sub    $0x8,%esp
801059b7:	52                   	push   %edx
801059b8:	50                   	push   %eax
801059b9:	e8 6e b8 ff ff       	call   8010122c <filestat>
801059be:	83 c4 10             	add    $0x10,%esp
}
801059c1:	c9                   	leave  
801059c2:	c3                   	ret    

801059c3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059c3:	55                   	push   %ebp
801059c4:	89 e5                	mov    %esp,%ebp
801059c6:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059c9:	83 ec 08             	sub    $0x8,%esp
801059cc:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059cf:	50                   	push   %eax
801059d0:	6a 00                	push   $0x0
801059d2:	e8 a4 fc ff ff       	call   8010567b <argstr>
801059d7:	83 c4 10             	add    $0x10,%esp
801059da:	85 c0                	test   %eax,%eax
801059dc:	78 15                	js     801059f3 <sys_link+0x30>
801059de:	83 ec 08             	sub    $0x8,%esp
801059e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059e4:	50                   	push   %eax
801059e5:	6a 01                	push   $0x1
801059e7:	e8 8f fc ff ff       	call   8010567b <argstr>
801059ec:	83 c4 10             	add    $0x10,%esp
801059ef:	85 c0                	test   %eax,%eax
801059f1:	79 0a                	jns    801059fd <sys_link+0x3a>
    return -1;
801059f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f8:	e9 68 01 00 00       	jmp    80105b65 <sys_link+0x1a2>

  begin_op();
801059fd:	e8 c6 db ff ff       	call   801035c8 <begin_op>
  if((ip = namei(old)) == 0){
80105a02:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	50                   	push   %eax
80105a09:	e8 d5 cb ff ff       	call   801025e3 <namei>
80105a0e:	83 c4 10             	add    $0x10,%esp
80105a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a18:	75 0f                	jne    80105a29 <sys_link+0x66>
    end_op();
80105a1a:	e8 35 dc ff ff       	call   80103654 <end_op>
    return -1;
80105a1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a24:	e9 3c 01 00 00       	jmp    80105b65 <sys_link+0x1a2>
  }

  ilock(ip);
80105a29:	83 ec 0c             	sub    $0xc,%esp
80105a2c:	ff 75 f4             	pushl  -0xc(%ebp)
80105a2f:	e8 6f c0 ff ff       	call   80101aa3 <ilock>
80105a34:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a3e:	66 83 f8 01          	cmp    $0x1,%ax
80105a42:	75 1d                	jne    80105a61 <sys_link+0x9e>
    iunlockput(ip);
80105a44:	83 ec 0c             	sub    $0xc,%esp
80105a47:	ff 75 f4             	pushl  -0xc(%ebp)
80105a4a:	e8 85 c2 ff ff       	call   80101cd4 <iunlockput>
80105a4f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a52:	e8 fd db ff ff       	call   80103654 <end_op>
    return -1;
80105a57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5c:	e9 04 01 00 00       	jmp    80105b65 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a68:	83 c0 01             	add    $0x1,%eax
80105a6b:	89 c2                	mov    %eax,%edx
80105a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a70:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a74:	83 ec 0c             	sub    $0xc,%esp
80105a77:	ff 75 f4             	pushl  -0xc(%ebp)
80105a7a:	e8 47 be ff ff       	call   801018c6 <iupdate>
80105a7f:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a82:	83 ec 0c             	sub    $0xc,%esp
80105a85:	ff 75 f4             	pushl  -0xc(%ebp)
80105a88:	e8 29 c1 ff ff       	call   80101bb6 <iunlock>
80105a8d:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a93:	83 ec 08             	sub    $0x8,%esp
80105a96:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a99:	52                   	push   %edx
80105a9a:	50                   	push   %eax
80105a9b:	e8 5f cb ff ff       	call   801025ff <nameiparent>
80105aa0:	83 c4 10             	add    $0x10,%esp
80105aa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105aa6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aaa:	74 71                	je     80105b1d <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105aac:	83 ec 0c             	sub    $0xc,%esp
80105aaf:	ff 75 f0             	pushl  -0x10(%ebp)
80105ab2:	e8 ec bf ff ff       	call   80101aa3 <ilock>
80105ab7:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abd:	8b 10                	mov    (%eax),%edx
80105abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac2:	8b 00                	mov    (%eax),%eax
80105ac4:	39 c2                	cmp    %eax,%edx
80105ac6:	75 1d                	jne    80105ae5 <sys_link+0x122>
80105ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acb:	8b 40 04             	mov    0x4(%eax),%eax
80105ace:	83 ec 04             	sub    $0x4,%esp
80105ad1:	50                   	push   %eax
80105ad2:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ad5:	50                   	push   %eax
80105ad6:	ff 75 f0             	pushl  -0x10(%ebp)
80105ad9:	e8 6a c8 ff ff       	call   80102348 <dirlink>
80105ade:	83 c4 10             	add    $0x10,%esp
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	79 10                	jns    80105af5 <sys_link+0x132>
    iunlockput(dp);
80105ae5:	83 ec 0c             	sub    $0xc,%esp
80105ae8:	ff 75 f0             	pushl  -0x10(%ebp)
80105aeb:	e8 e4 c1 ff ff       	call   80101cd4 <iunlockput>
80105af0:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105af3:	eb 29                	jmp    80105b1e <sys_link+0x15b>
  }
  iunlockput(dp);
80105af5:	83 ec 0c             	sub    $0xc,%esp
80105af8:	ff 75 f0             	pushl  -0x10(%ebp)
80105afb:	e8 d4 c1 ff ff       	call   80101cd4 <iunlockput>
80105b00:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b03:	83 ec 0c             	sub    $0xc,%esp
80105b06:	ff 75 f4             	pushl  -0xc(%ebp)
80105b09:	e8 f6 c0 ff ff       	call   80101c04 <iput>
80105b0e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b11:	e8 3e db ff ff       	call   80103654 <end_op>

  return 0;
80105b16:	b8 00 00 00 00       	mov    $0x0,%eax
80105b1b:	eb 48                	jmp    80105b65 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105b1d:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105b1e:	83 ec 0c             	sub    $0xc,%esp
80105b21:	ff 75 f4             	pushl  -0xc(%ebp)
80105b24:	e8 7a bf ff ff       	call   80101aa3 <ilock>
80105b29:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b33:	83 e8 01             	sub    $0x1,%eax
80105b36:	89 c2                	mov    %eax,%edx
80105b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b3f:	83 ec 0c             	sub    $0xc,%esp
80105b42:	ff 75 f4             	pushl  -0xc(%ebp)
80105b45:	e8 7c bd ff ff       	call   801018c6 <iupdate>
80105b4a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b4d:	83 ec 0c             	sub    $0xc,%esp
80105b50:	ff 75 f4             	pushl  -0xc(%ebp)
80105b53:	e8 7c c1 ff ff       	call   80101cd4 <iunlockput>
80105b58:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b5b:	e8 f4 da ff ff       	call   80103654 <end_op>
  return -1;
80105b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b65:	c9                   	leave  
80105b66:	c3                   	ret    

80105b67 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b67:	55                   	push   %ebp
80105b68:	89 e5                	mov    %esp,%ebp
80105b6a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b6d:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b74:	eb 40                	jmp    80105bb6 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b79:	6a 10                	push   $0x10
80105b7b:	50                   	push   %eax
80105b7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b7f:	50                   	push   %eax
80105b80:	ff 75 08             	pushl  0x8(%ebp)
80105b83:	e8 0c c4 ff ff       	call   80101f94 <readi>
80105b88:	83 c4 10             	add    $0x10,%esp
80105b8b:	83 f8 10             	cmp    $0x10,%eax
80105b8e:	74 0d                	je     80105b9d <isdirempty+0x36>
      panic("isdirempty: readi");
80105b90:	83 ec 0c             	sub    $0xc,%esp
80105b93:	68 7e 8b 10 80       	push   $0x80108b7e
80105b98:	e8 03 aa ff ff       	call   801005a0 <panic>
    if(de.inum != 0)
80105b9d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ba1:	66 85 c0             	test   %ax,%ax
80105ba4:	74 07                	je     80105bad <isdirempty+0x46>
      return 0;
80105ba6:	b8 00 00 00 00       	mov    $0x0,%eax
80105bab:	eb 1b                	jmp    80105bc8 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb0:	83 c0 10             	add    $0x10,%eax
80105bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb9:	8b 50 58             	mov    0x58(%eax),%edx
80105bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbf:	39 c2                	cmp    %eax,%edx
80105bc1:	77 b3                	ja     80105b76 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105bc3:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bc8:	c9                   	leave  
80105bc9:	c3                   	ret    

80105bca <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bca:	55                   	push   %ebp
80105bcb:	89 e5                	mov    %esp,%ebp
80105bcd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bd0:	83 ec 08             	sub    $0x8,%esp
80105bd3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bd6:	50                   	push   %eax
80105bd7:	6a 00                	push   $0x0
80105bd9:	e8 9d fa ff ff       	call   8010567b <argstr>
80105bde:	83 c4 10             	add    $0x10,%esp
80105be1:	85 c0                	test   %eax,%eax
80105be3:	79 0a                	jns    80105bef <sys_unlink+0x25>
    return -1;
80105be5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bea:	e9 bc 01 00 00       	jmp    80105dab <sys_unlink+0x1e1>

  begin_op();
80105bef:	e8 d4 d9 ff ff       	call   801035c8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bf4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bf7:	83 ec 08             	sub    $0x8,%esp
80105bfa:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bfd:	52                   	push   %edx
80105bfe:	50                   	push   %eax
80105bff:	e8 fb c9 ff ff       	call   801025ff <nameiparent>
80105c04:	83 c4 10             	add    $0x10,%esp
80105c07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c0e:	75 0f                	jne    80105c1f <sys_unlink+0x55>
    end_op();
80105c10:	e8 3f da ff ff       	call   80103654 <end_op>
    return -1;
80105c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1a:	e9 8c 01 00 00       	jmp    80105dab <sys_unlink+0x1e1>
  }

  ilock(dp);
80105c1f:	83 ec 0c             	sub    $0xc,%esp
80105c22:	ff 75 f4             	pushl  -0xc(%ebp)
80105c25:	e8 79 be ff ff       	call   80101aa3 <ilock>
80105c2a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c2d:	83 ec 08             	sub    $0x8,%esp
80105c30:	68 90 8b 10 80       	push   $0x80108b90
80105c35:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c38:	50                   	push   %eax
80105c39:	e8 35 c6 ff ff       	call   80102273 <namecmp>
80105c3e:	83 c4 10             	add    $0x10,%esp
80105c41:	85 c0                	test   %eax,%eax
80105c43:	0f 84 4a 01 00 00    	je     80105d93 <sys_unlink+0x1c9>
80105c49:	83 ec 08             	sub    $0x8,%esp
80105c4c:	68 92 8b 10 80       	push   $0x80108b92
80105c51:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c54:	50                   	push   %eax
80105c55:	e8 19 c6 ff ff       	call   80102273 <namecmp>
80105c5a:	83 c4 10             	add    $0x10,%esp
80105c5d:	85 c0                	test   %eax,%eax
80105c5f:	0f 84 2e 01 00 00    	je     80105d93 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c65:	83 ec 04             	sub    $0x4,%esp
80105c68:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c6b:	50                   	push   %eax
80105c6c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c6f:	50                   	push   %eax
80105c70:	ff 75 f4             	pushl  -0xc(%ebp)
80105c73:	e8 16 c6 ff ff       	call   8010228e <dirlookup>
80105c78:	83 c4 10             	add    $0x10,%esp
80105c7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c82:	0f 84 0a 01 00 00    	je     80105d92 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105c88:	83 ec 0c             	sub    $0xc,%esp
80105c8b:	ff 75 f0             	pushl  -0x10(%ebp)
80105c8e:	e8 10 be ff ff       	call   80101aa3 <ilock>
80105c93:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c99:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c9d:	66 85 c0             	test   %ax,%ax
80105ca0:	7f 0d                	jg     80105caf <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105ca2:	83 ec 0c             	sub    $0xc,%esp
80105ca5:	68 95 8b 10 80       	push   $0x80108b95
80105caa:	e8 f1 a8 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cb6:	66 83 f8 01          	cmp    $0x1,%ax
80105cba:	75 25                	jne    80105ce1 <sys_unlink+0x117>
80105cbc:	83 ec 0c             	sub    $0xc,%esp
80105cbf:	ff 75 f0             	pushl  -0x10(%ebp)
80105cc2:	e8 a0 fe ff ff       	call   80105b67 <isdirempty>
80105cc7:	83 c4 10             	add    $0x10,%esp
80105cca:	85 c0                	test   %eax,%eax
80105ccc:	75 13                	jne    80105ce1 <sys_unlink+0x117>
    iunlockput(ip);
80105cce:	83 ec 0c             	sub    $0xc,%esp
80105cd1:	ff 75 f0             	pushl  -0x10(%ebp)
80105cd4:	e8 fb bf ff ff       	call   80101cd4 <iunlockput>
80105cd9:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cdc:	e9 b2 00 00 00       	jmp    80105d93 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105ce1:	83 ec 04             	sub    $0x4,%esp
80105ce4:	6a 10                	push   $0x10
80105ce6:	6a 00                	push   $0x0
80105ce8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ceb:	50                   	push   %eax
80105cec:	e8 c9 f5 ff ff       	call   801052ba <memset>
80105cf1:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cf4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105cf7:	6a 10                	push   $0x10
80105cf9:	50                   	push   %eax
80105cfa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cfd:	50                   	push   %eax
80105cfe:	ff 75 f4             	pushl  -0xc(%ebp)
80105d01:	e8 e5 c3 ff ff       	call   801020eb <writei>
80105d06:	83 c4 10             	add    $0x10,%esp
80105d09:	83 f8 10             	cmp    $0x10,%eax
80105d0c:	74 0d                	je     80105d1b <sys_unlink+0x151>
    panic("unlink: writei");
80105d0e:	83 ec 0c             	sub    $0xc,%esp
80105d11:	68 a7 8b 10 80       	push   $0x80108ba7
80105d16:	e8 85 a8 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR){
80105d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d22:	66 83 f8 01          	cmp    $0x1,%ax
80105d26:	75 21                	jne    80105d49 <sys_unlink+0x17f>
    dp->nlink--;
80105d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d2f:	83 e8 01             	sub    $0x1,%eax
80105d32:	89 c2                	mov    %eax,%edx
80105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d37:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105d3b:	83 ec 0c             	sub    $0xc,%esp
80105d3e:	ff 75 f4             	pushl  -0xc(%ebp)
80105d41:	e8 80 bb ff ff       	call   801018c6 <iupdate>
80105d46:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d49:	83 ec 0c             	sub    $0xc,%esp
80105d4c:	ff 75 f4             	pushl  -0xc(%ebp)
80105d4f:	e8 80 bf ff ff       	call   80101cd4 <iunlockput>
80105d54:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d5e:	83 e8 01             	sub    $0x1,%eax
80105d61:	89 c2                	mov    %eax,%edx
80105d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d66:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d6a:	83 ec 0c             	sub    $0xc,%esp
80105d6d:	ff 75 f0             	pushl  -0x10(%ebp)
80105d70:	e8 51 bb ff ff       	call   801018c6 <iupdate>
80105d75:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	ff 75 f0             	pushl  -0x10(%ebp)
80105d7e:	e8 51 bf ff ff       	call   80101cd4 <iunlockput>
80105d83:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d86:	e8 c9 d8 ff ff       	call   80103654 <end_op>

  return 0;
80105d8b:	b8 00 00 00 00       	mov    $0x0,%eax
80105d90:	eb 19                	jmp    80105dab <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d92:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d93:	83 ec 0c             	sub    $0xc,%esp
80105d96:	ff 75 f4             	pushl  -0xc(%ebp)
80105d99:	e8 36 bf ff ff       	call   80101cd4 <iunlockput>
80105d9e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105da1:	e8 ae d8 ff ff       	call   80103654 <end_op>
  return -1;
80105da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dab:	c9                   	leave  
80105dac:	c3                   	ret    

80105dad <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dad:	55                   	push   %ebp
80105dae:	89 e5                	mov    %esp,%ebp
80105db0:	83 ec 38             	sub    $0x38,%esp
80105db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105db6:	8b 55 10             	mov    0x10(%ebp),%edx
80105db9:	8b 45 14             	mov    0x14(%ebp),%eax
80105dbc:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dc0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dc4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dc8:	83 ec 08             	sub    $0x8,%esp
80105dcb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dce:	50                   	push   %eax
80105dcf:	ff 75 08             	pushl  0x8(%ebp)
80105dd2:	e8 28 c8 ff ff       	call   801025ff <nameiparent>
80105dd7:	83 c4 10             	add    $0x10,%esp
80105dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ddd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de1:	75 0a                	jne    80105ded <create+0x40>
    return 0;
80105de3:	b8 00 00 00 00       	mov    $0x0,%eax
80105de8:	e9 90 01 00 00       	jmp    80105f7d <create+0x1d0>
  ilock(dp);
80105ded:	83 ec 0c             	sub    $0xc,%esp
80105df0:	ff 75 f4             	pushl  -0xc(%ebp)
80105df3:	e8 ab bc ff ff       	call   80101aa3 <ilock>
80105df8:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105dfb:	83 ec 04             	sub    $0x4,%esp
80105dfe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e01:	50                   	push   %eax
80105e02:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e05:	50                   	push   %eax
80105e06:	ff 75 f4             	pushl  -0xc(%ebp)
80105e09:	e8 80 c4 ff ff       	call   8010228e <dirlookup>
80105e0e:	83 c4 10             	add    $0x10,%esp
80105e11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e18:	74 50                	je     80105e6a <create+0xbd>
    iunlockput(dp);
80105e1a:	83 ec 0c             	sub    $0xc,%esp
80105e1d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e20:	e8 af be ff ff       	call   80101cd4 <iunlockput>
80105e25:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e28:	83 ec 0c             	sub    $0xc,%esp
80105e2b:	ff 75 f0             	pushl  -0x10(%ebp)
80105e2e:	e8 70 bc ff ff       	call   80101aa3 <ilock>
80105e33:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e36:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e3b:	75 15                	jne    80105e52 <create+0xa5>
80105e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e40:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e44:	66 83 f8 02          	cmp    $0x2,%ax
80105e48:	75 08                	jne    80105e52 <create+0xa5>
      return ip;
80105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4d:	e9 2b 01 00 00       	jmp    80105f7d <create+0x1d0>
    iunlockput(ip);
80105e52:	83 ec 0c             	sub    $0xc,%esp
80105e55:	ff 75 f0             	pushl  -0x10(%ebp)
80105e58:	e8 77 be ff ff       	call   80101cd4 <iunlockput>
80105e5d:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e60:	b8 00 00 00 00       	mov    $0x0,%eax
80105e65:	e9 13 01 00 00       	jmp    80105f7d <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e6a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e71:	8b 00                	mov    (%eax),%eax
80105e73:	83 ec 08             	sub    $0x8,%esp
80105e76:	52                   	push   %edx
80105e77:	50                   	push   %eax
80105e78:	e8 72 b9 ff ff       	call   801017ef <ialloc>
80105e7d:	83 c4 10             	add    $0x10,%esp
80105e80:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e87:	75 0d                	jne    80105e96 <create+0xe9>
    panic("create: ialloc");
80105e89:	83 ec 0c             	sub    $0xc,%esp
80105e8c:	68 b6 8b 10 80       	push   $0x80108bb6
80105e91:	e8 0a a7 ff ff       	call   801005a0 <panic>

  ilock(ip);
80105e96:	83 ec 0c             	sub    $0xc,%esp
80105e99:	ff 75 f0             	pushl  -0x10(%ebp)
80105e9c:	e8 02 bc ff ff       	call   80101aa3 <ilock>
80105ea1:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea7:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105eab:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb2:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105eb6:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebd:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105ec3:	83 ec 0c             	sub    $0xc,%esp
80105ec6:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec9:	e8 f8 b9 ff ff       	call   801018c6 <iupdate>
80105ece:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ed1:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ed6:	75 6a                	jne    80105f42 <create+0x195>
    dp->nlink++;  // for ".."
80105ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105edf:	83 c0 01             	add    $0x1,%eax
80105ee2:	89 c2                	mov    %eax,%edx
80105ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee7:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105eeb:	83 ec 0c             	sub    $0xc,%esp
80105eee:	ff 75 f4             	pushl  -0xc(%ebp)
80105ef1:	e8 d0 b9 ff ff       	call   801018c6 <iupdate>
80105ef6:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efc:	8b 40 04             	mov    0x4(%eax),%eax
80105eff:	83 ec 04             	sub    $0x4,%esp
80105f02:	50                   	push   %eax
80105f03:	68 90 8b 10 80       	push   $0x80108b90
80105f08:	ff 75 f0             	pushl  -0x10(%ebp)
80105f0b:	e8 38 c4 ff ff       	call   80102348 <dirlink>
80105f10:	83 c4 10             	add    $0x10,%esp
80105f13:	85 c0                	test   %eax,%eax
80105f15:	78 1e                	js     80105f35 <create+0x188>
80105f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1a:	8b 40 04             	mov    0x4(%eax),%eax
80105f1d:	83 ec 04             	sub    $0x4,%esp
80105f20:	50                   	push   %eax
80105f21:	68 92 8b 10 80       	push   $0x80108b92
80105f26:	ff 75 f0             	pushl  -0x10(%ebp)
80105f29:	e8 1a c4 ff ff       	call   80102348 <dirlink>
80105f2e:	83 c4 10             	add    $0x10,%esp
80105f31:	85 c0                	test   %eax,%eax
80105f33:	79 0d                	jns    80105f42 <create+0x195>
      panic("create dots");
80105f35:	83 ec 0c             	sub    $0xc,%esp
80105f38:	68 c5 8b 10 80       	push   $0x80108bc5
80105f3d:	e8 5e a6 ff ff       	call   801005a0 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f45:	8b 40 04             	mov    0x4(%eax),%eax
80105f48:	83 ec 04             	sub    $0x4,%esp
80105f4b:	50                   	push   %eax
80105f4c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f4f:	50                   	push   %eax
80105f50:	ff 75 f4             	pushl  -0xc(%ebp)
80105f53:	e8 f0 c3 ff ff       	call   80102348 <dirlink>
80105f58:	83 c4 10             	add    $0x10,%esp
80105f5b:	85 c0                	test   %eax,%eax
80105f5d:	79 0d                	jns    80105f6c <create+0x1bf>
    panic("create: dirlink");
80105f5f:	83 ec 0c             	sub    $0xc,%esp
80105f62:	68 d1 8b 10 80       	push   $0x80108bd1
80105f67:	e8 34 a6 ff ff       	call   801005a0 <panic>

  iunlockput(dp);
80105f6c:	83 ec 0c             	sub    $0xc,%esp
80105f6f:	ff 75 f4             	pushl  -0xc(%ebp)
80105f72:	e8 5d bd ff ff       	call   80101cd4 <iunlockput>
80105f77:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f7d:	c9                   	leave  
80105f7e:	c3                   	ret    

80105f7f <sys_open>:

int
sys_open(void)
{
80105f7f:	55                   	push   %ebp
80105f80:	89 e5                	mov    %esp,%ebp
80105f82:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f85:	83 ec 08             	sub    $0x8,%esp
80105f88:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f8b:	50                   	push   %eax
80105f8c:	6a 00                	push   $0x0
80105f8e:	e8 e8 f6 ff ff       	call   8010567b <argstr>
80105f93:	83 c4 10             	add    $0x10,%esp
80105f96:	85 c0                	test   %eax,%eax
80105f98:	78 15                	js     80105faf <sys_open+0x30>
80105f9a:	83 ec 08             	sub    $0x8,%esp
80105f9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fa0:	50                   	push   %eax
80105fa1:	6a 01                	push   $0x1
80105fa3:	e8 3e f6 ff ff       	call   801055e6 <argint>
80105fa8:	83 c4 10             	add    $0x10,%esp
80105fab:	85 c0                	test   %eax,%eax
80105fad:	79 0a                	jns    80105fb9 <sys_open+0x3a>
    return -1;
80105faf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb4:	e9 61 01 00 00       	jmp    8010611a <sys_open+0x19b>

  begin_op();
80105fb9:	e8 0a d6 ff ff       	call   801035c8 <begin_op>

  if(omode & O_CREATE){
80105fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fc1:	25 00 02 00 00       	and    $0x200,%eax
80105fc6:	85 c0                	test   %eax,%eax
80105fc8:	74 2a                	je     80105ff4 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fcd:	6a 00                	push   $0x0
80105fcf:	6a 00                	push   $0x0
80105fd1:	6a 02                	push   $0x2
80105fd3:	50                   	push   %eax
80105fd4:	e8 d4 fd ff ff       	call   80105dad <create>
80105fd9:	83 c4 10             	add    $0x10,%esp
80105fdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe3:	75 75                	jne    8010605a <sys_open+0xdb>
      end_op();
80105fe5:	e8 6a d6 ff ff       	call   80103654 <end_op>
      return -1;
80105fea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fef:	e9 26 01 00 00       	jmp    8010611a <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ff4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ff7:	83 ec 0c             	sub    $0xc,%esp
80105ffa:	50                   	push   %eax
80105ffb:	e8 e3 c5 ff ff       	call   801025e3 <namei>
80106000:	83 c4 10             	add    $0x10,%esp
80106003:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106006:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010600a:	75 0f                	jne    8010601b <sys_open+0x9c>
      end_op();
8010600c:	e8 43 d6 ff ff       	call   80103654 <end_op>
      return -1;
80106011:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106016:	e9 ff 00 00 00       	jmp    8010611a <sys_open+0x19b>
    }
    ilock(ip);
8010601b:	83 ec 0c             	sub    $0xc,%esp
8010601e:	ff 75 f4             	pushl  -0xc(%ebp)
80106021:	e8 7d ba ff ff       	call   80101aa3 <ilock>
80106026:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106030:	66 83 f8 01          	cmp    $0x1,%ax
80106034:	75 24                	jne    8010605a <sys_open+0xdb>
80106036:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106039:	85 c0                	test   %eax,%eax
8010603b:	74 1d                	je     8010605a <sys_open+0xdb>
      iunlockput(ip);
8010603d:	83 ec 0c             	sub    $0xc,%esp
80106040:	ff 75 f4             	pushl  -0xc(%ebp)
80106043:	e8 8c bc ff ff       	call   80101cd4 <iunlockput>
80106048:	83 c4 10             	add    $0x10,%esp
      end_op();
8010604b:	e8 04 d6 ff ff       	call   80103654 <end_op>
      return -1;
80106050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106055:	e9 c0 00 00 00       	jmp    8010611a <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010605a:	e8 27 b0 ff ff       	call   80101086 <filealloc>
8010605f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106062:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106066:	74 17                	je     8010607f <sys_open+0x100>
80106068:	83 ec 0c             	sub    $0xc,%esp
8010606b:	ff 75 f0             	pushl  -0x10(%ebp)
8010606e:	e8 34 f7 ff ff       	call   801057a7 <fdalloc>
80106073:	83 c4 10             	add    $0x10,%esp
80106076:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106079:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010607d:	79 2e                	jns    801060ad <sys_open+0x12e>
    if(f)
8010607f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106083:	74 0e                	je     80106093 <sys_open+0x114>
      fileclose(f);
80106085:	83 ec 0c             	sub    $0xc,%esp
80106088:	ff 75 f0             	pushl  -0x10(%ebp)
8010608b:	e8 b4 b0 ff ff       	call   80101144 <fileclose>
80106090:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106093:	83 ec 0c             	sub    $0xc,%esp
80106096:	ff 75 f4             	pushl  -0xc(%ebp)
80106099:	e8 36 bc ff ff       	call   80101cd4 <iunlockput>
8010609e:	83 c4 10             	add    $0x10,%esp
    end_op();
801060a1:	e8 ae d5 ff ff       	call   80103654 <end_op>
    return -1;
801060a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ab:	eb 6d                	jmp    8010611a <sys_open+0x19b>
  }
  iunlock(ip);
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	ff 75 f4             	pushl  -0xc(%ebp)
801060b3:	e8 fe ba ff ff       	call   80101bb6 <iunlock>
801060b8:	83 c4 10             	add    $0x10,%esp
  end_op();
801060bb:	e8 94 d5 ff ff       	call   80103654 <end_op>

  f->type = FD_INODE;
801060c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060cf:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060df:	83 e0 01             	and    $0x1,%eax
801060e2:	85 c0                	test   %eax,%eax
801060e4:	0f 94 c0             	sete   %al
801060e7:	89 c2                	mov    %eax,%edx
801060e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ec:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f2:	83 e0 01             	and    $0x1,%eax
801060f5:	85 c0                	test   %eax,%eax
801060f7:	75 0a                	jne    80106103 <sys_open+0x184>
801060f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060fc:	83 e0 02             	and    $0x2,%eax
801060ff:	85 c0                	test   %eax,%eax
80106101:	74 07                	je     8010610a <sys_open+0x18b>
80106103:	b8 01 00 00 00       	mov    $0x1,%eax
80106108:	eb 05                	jmp    8010610f <sys_open+0x190>
8010610a:	b8 00 00 00 00       	mov    $0x0,%eax
8010610f:	89 c2                	mov    %eax,%edx
80106111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106114:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106117:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010611a:	c9                   	leave  
8010611b:	c3                   	ret    

8010611c <sys_mkdir>:

int
sys_mkdir(void)
{
8010611c:	55                   	push   %ebp
8010611d:	89 e5                	mov    %esp,%ebp
8010611f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106122:	e8 a1 d4 ff ff       	call   801035c8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106127:	83 ec 08             	sub    $0x8,%esp
8010612a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010612d:	50                   	push   %eax
8010612e:	6a 00                	push   $0x0
80106130:	e8 46 f5 ff ff       	call   8010567b <argstr>
80106135:	83 c4 10             	add    $0x10,%esp
80106138:	85 c0                	test   %eax,%eax
8010613a:	78 1b                	js     80106157 <sys_mkdir+0x3b>
8010613c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613f:	6a 00                	push   $0x0
80106141:	6a 00                	push   $0x0
80106143:	6a 01                	push   $0x1
80106145:	50                   	push   %eax
80106146:	e8 62 fc ff ff       	call   80105dad <create>
8010614b:	83 c4 10             	add    $0x10,%esp
8010614e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106151:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106155:	75 0c                	jne    80106163 <sys_mkdir+0x47>
    end_op();
80106157:	e8 f8 d4 ff ff       	call   80103654 <end_op>
    return -1;
8010615c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106161:	eb 18                	jmp    8010617b <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106163:	83 ec 0c             	sub    $0xc,%esp
80106166:	ff 75 f4             	pushl  -0xc(%ebp)
80106169:	e8 66 bb ff ff       	call   80101cd4 <iunlockput>
8010616e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106171:	e8 de d4 ff ff       	call   80103654 <end_op>
  return 0;
80106176:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010617b:	c9                   	leave  
8010617c:	c3                   	ret    

8010617d <sys_mknod>:

int
sys_mknod(void)
{
8010617d:	55                   	push   %ebp
8010617e:	89 e5                	mov    %esp,%ebp
80106180:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106183:	e8 40 d4 ff ff       	call   801035c8 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106188:	83 ec 08             	sub    $0x8,%esp
8010618b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010618e:	50                   	push   %eax
8010618f:	6a 00                	push   $0x0
80106191:	e8 e5 f4 ff ff       	call   8010567b <argstr>
80106196:	83 c4 10             	add    $0x10,%esp
80106199:	85 c0                	test   %eax,%eax
8010619b:	78 4f                	js     801061ec <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010619d:	83 ec 08             	sub    $0x8,%esp
801061a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061a3:	50                   	push   %eax
801061a4:	6a 01                	push   $0x1
801061a6:	e8 3b f4 ff ff       	call   801055e6 <argint>
801061ab:	83 c4 10             	add    $0x10,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801061ae:	85 c0                	test   %eax,%eax
801061b0:	78 3a                	js     801061ec <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061b2:	83 ec 08             	sub    $0x8,%esp
801061b5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061b8:	50                   	push   %eax
801061b9:	6a 02                	push   $0x2
801061bb:	e8 26 f4 ff ff       	call   801055e6 <argint>
801061c0:	83 c4 10             	add    $0x10,%esp
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061c3:	85 c0                	test   %eax,%eax
801061c5:	78 25                	js     801061ec <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ca:	0f bf c8             	movswl %ax,%ecx
801061cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061d0:	0f bf d0             	movswl %ax,%edx
801061d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061d6:	51                   	push   %ecx
801061d7:	52                   	push   %edx
801061d8:	6a 03                	push   $0x3
801061da:	50                   	push   %eax
801061db:	e8 cd fb ff ff       	call   80105dad <create>
801061e0:	83 c4 10             	add    $0x10,%esp
801061e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061ea:	75 0c                	jne    801061f8 <sys_mknod+0x7b>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801061ec:	e8 63 d4 ff ff       	call   80103654 <end_op>
    return -1;
801061f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f6:	eb 18                	jmp    80106210 <sys_mknod+0x93>
  }
  iunlockput(ip);
801061f8:	83 ec 0c             	sub    $0xc,%esp
801061fb:	ff 75 f4             	pushl  -0xc(%ebp)
801061fe:	e8 d1 ba ff ff       	call   80101cd4 <iunlockput>
80106203:	83 c4 10             	add    $0x10,%esp
  end_op();
80106206:	e8 49 d4 ff ff       	call   80103654 <end_op>
  return 0;
8010620b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106210:	c9                   	leave  
80106211:	c3                   	ret    

80106212 <sys_chdir>:

int
sys_chdir(void)
{
80106212:	55                   	push   %ebp
80106213:	89 e5                	mov    %esp,%ebp
80106215:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106218:	e8 03 e1 ff ff       	call   80104320 <myproc>
8010621d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106220:	e8 a3 d3 ff ff       	call   801035c8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106225:	83 ec 08             	sub    $0x8,%esp
80106228:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010622b:	50                   	push   %eax
8010622c:	6a 00                	push   $0x0
8010622e:	e8 48 f4 ff ff       	call   8010567b <argstr>
80106233:	83 c4 10             	add    $0x10,%esp
80106236:	85 c0                	test   %eax,%eax
80106238:	78 18                	js     80106252 <sys_chdir+0x40>
8010623a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010623d:	83 ec 0c             	sub    $0xc,%esp
80106240:	50                   	push   %eax
80106241:	e8 9d c3 ff ff       	call   801025e3 <namei>
80106246:	83 c4 10             	add    $0x10,%esp
80106249:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010624c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106250:	75 0c                	jne    8010625e <sys_chdir+0x4c>
    end_op();
80106252:	e8 fd d3 ff ff       	call   80103654 <end_op>
    return -1;
80106257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625c:	eb 68                	jmp    801062c6 <sys_chdir+0xb4>
  }
  ilock(ip);
8010625e:	83 ec 0c             	sub    $0xc,%esp
80106261:	ff 75 f0             	pushl  -0x10(%ebp)
80106264:	e8 3a b8 ff ff       	call   80101aa3 <ilock>
80106269:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010626c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106273:	66 83 f8 01          	cmp    $0x1,%ax
80106277:	74 1a                	je     80106293 <sys_chdir+0x81>
    iunlockput(ip);
80106279:	83 ec 0c             	sub    $0xc,%esp
8010627c:	ff 75 f0             	pushl  -0x10(%ebp)
8010627f:	e8 50 ba ff ff       	call   80101cd4 <iunlockput>
80106284:	83 c4 10             	add    $0x10,%esp
    end_op();
80106287:	e8 c8 d3 ff ff       	call   80103654 <end_op>
    return -1;
8010628c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106291:	eb 33                	jmp    801062c6 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106293:	83 ec 0c             	sub    $0xc,%esp
80106296:	ff 75 f0             	pushl  -0x10(%ebp)
80106299:	e8 18 b9 ff ff       	call   80101bb6 <iunlock>
8010629e:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801062a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a4:	8b 40 68             	mov    0x68(%eax),%eax
801062a7:	83 ec 0c             	sub    $0xc,%esp
801062aa:	50                   	push   %eax
801062ab:	e8 54 b9 ff ff       	call   80101c04 <iput>
801062b0:	83 c4 10             	add    $0x10,%esp
  end_op();
801062b3:	e8 9c d3 ff ff       	call   80103654 <end_op>
  curproc->cwd = ip;
801062b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062be:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c6:	c9                   	leave  
801062c7:	c3                   	ret    

801062c8 <sys_exec>:

int
sys_exec(void)
{
801062c8:	55                   	push   %ebp
801062c9:	89 e5                	mov    %esp,%ebp
801062cb:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062d1:	83 ec 08             	sub    $0x8,%esp
801062d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d7:	50                   	push   %eax
801062d8:	6a 00                	push   $0x0
801062da:	e8 9c f3 ff ff       	call   8010567b <argstr>
801062df:	83 c4 10             	add    $0x10,%esp
801062e2:	85 c0                	test   %eax,%eax
801062e4:	78 18                	js     801062fe <sys_exec+0x36>
801062e6:	83 ec 08             	sub    $0x8,%esp
801062e9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062ef:	50                   	push   %eax
801062f0:	6a 01                	push   $0x1
801062f2:	e8 ef f2 ff ff       	call   801055e6 <argint>
801062f7:	83 c4 10             	add    $0x10,%esp
801062fa:	85 c0                	test   %eax,%eax
801062fc:	79 0a                	jns    80106308 <sys_exec+0x40>
    return -1;
801062fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106303:	e9 c6 00 00 00       	jmp    801063ce <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106308:	83 ec 04             	sub    $0x4,%esp
8010630b:	68 80 00 00 00       	push   $0x80
80106310:	6a 00                	push   $0x0
80106312:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106318:	50                   	push   %eax
80106319:	e8 9c ef ff ff       	call   801052ba <memset>
8010631e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632b:	83 f8 1f             	cmp    $0x1f,%eax
8010632e:	76 0a                	jbe    8010633a <sys_exec+0x72>
      return -1;
80106330:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106335:	e9 94 00 00 00       	jmp    801063ce <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010633a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633d:	c1 e0 02             	shl    $0x2,%eax
80106340:	89 c2                	mov    %eax,%edx
80106342:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106348:	01 c2                	add    %eax,%edx
8010634a:	83 ec 08             	sub    $0x8,%esp
8010634d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106353:	50                   	push   %eax
80106354:	52                   	push   %edx
80106355:	e8 e9 f1 ff ff       	call   80105543 <fetchint>
8010635a:	83 c4 10             	add    $0x10,%esp
8010635d:	85 c0                	test   %eax,%eax
8010635f:	79 07                	jns    80106368 <sys_exec+0xa0>
      return -1;
80106361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106366:	eb 66                	jmp    801063ce <sys_exec+0x106>
    if(uarg == 0){
80106368:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010636e:	85 c0                	test   %eax,%eax
80106370:	75 27                	jne    80106399 <sys_exec+0xd1>
      argv[i] = 0;
80106372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106375:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010637c:	00 00 00 00 
      break;
80106380:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106384:	83 ec 08             	sub    $0x8,%esp
80106387:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010638d:	52                   	push   %edx
8010638e:	50                   	push   %eax
8010638f:	e8 02 a8 ff ff       	call   80100b96 <exec>
80106394:	83 c4 10             	add    $0x10,%esp
80106397:	eb 35                	jmp    801063ce <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106399:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010639f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063a2:	c1 e2 02             	shl    $0x2,%edx
801063a5:	01 c2                	add    %eax,%edx
801063a7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063ad:	83 ec 08             	sub    $0x8,%esp
801063b0:	52                   	push   %edx
801063b1:	50                   	push   %eax
801063b2:	e8 cb f1 ff ff       	call   80105582 <fetchstr>
801063b7:	83 c4 10             	add    $0x10,%esp
801063ba:	85 c0                	test   %eax,%eax
801063bc:	79 07                	jns    801063c5 <sys_exec+0xfd>
      return -1;
801063be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c3:	eb 09                	jmp    801063ce <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063c9:	e9 5a ff ff ff       	jmp    80106328 <sys_exec+0x60>
  return exec(path, argv);
}
801063ce:	c9                   	leave  
801063cf:	c3                   	ret    

801063d0 <sys_pipe>:

int
sys_pipe(void)
{
801063d0:	55                   	push   %ebp
801063d1:	89 e5                	mov    %esp,%ebp
801063d3:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063d6:	83 ec 04             	sub    $0x4,%esp
801063d9:	6a 08                	push   $0x8
801063db:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063de:	50                   	push   %eax
801063df:	6a 00                	push   $0x0
801063e1:	e8 2d f2 ff ff       	call   80105613 <argptr>
801063e6:	83 c4 10             	add    $0x10,%esp
801063e9:	85 c0                	test   %eax,%eax
801063eb:	79 0a                	jns    801063f7 <sys_pipe+0x27>
    return -1;
801063ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f2:	e9 b0 00 00 00       	jmp    801064a7 <sys_pipe+0xd7>
  if(pipealloc(&rf, &wf) < 0)
801063f7:	83 ec 08             	sub    $0x8,%esp
801063fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063fd:	50                   	push   %eax
801063fe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106401:	50                   	push   %eax
80106402:	e8 50 da ff ff       	call   80103e57 <pipealloc>
80106407:	83 c4 10             	add    $0x10,%esp
8010640a:	85 c0                	test   %eax,%eax
8010640c:	79 0a                	jns    80106418 <sys_pipe+0x48>
    return -1;
8010640e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106413:	e9 8f 00 00 00       	jmp    801064a7 <sys_pipe+0xd7>
  fd0 = -1;
80106418:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010641f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106422:	83 ec 0c             	sub    $0xc,%esp
80106425:	50                   	push   %eax
80106426:	e8 7c f3 ff ff       	call   801057a7 <fdalloc>
8010642b:	83 c4 10             	add    $0x10,%esp
8010642e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106431:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106435:	78 18                	js     8010644f <sys_pipe+0x7f>
80106437:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010643a:	83 ec 0c             	sub    $0xc,%esp
8010643d:	50                   	push   %eax
8010643e:	e8 64 f3 ff ff       	call   801057a7 <fdalloc>
80106443:	83 c4 10             	add    $0x10,%esp
80106446:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106449:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010644d:	79 40                	jns    8010648f <sys_pipe+0xbf>
    if(fd0 >= 0)
8010644f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106453:	78 15                	js     8010646a <sys_pipe+0x9a>
      myproc()->ofile[fd0] = 0;
80106455:	e8 c6 de ff ff       	call   80104320 <myproc>
8010645a:	89 c2                	mov    %eax,%edx
8010645c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645f:	83 c0 08             	add    $0x8,%eax
80106462:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
80106469:	00 
    fileclose(rf);
8010646a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010646d:	83 ec 0c             	sub    $0xc,%esp
80106470:	50                   	push   %eax
80106471:	e8 ce ac ff ff       	call   80101144 <fileclose>
80106476:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010647c:	83 ec 0c             	sub    $0xc,%esp
8010647f:	50                   	push   %eax
80106480:	e8 bf ac ff ff       	call   80101144 <fileclose>
80106485:	83 c4 10             	add    $0x10,%esp
    return -1;
80106488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648d:	eb 18                	jmp    801064a7 <sys_pipe+0xd7>
  }
  fd[0] = fd0;
8010648f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106492:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106495:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010649a:	8d 50 04             	lea    0x4(%eax),%edx
8010649d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a0:	89 02                	mov    %eax,(%edx)
  return 0;
801064a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a7:	c9                   	leave  
801064a8:	c3                   	ret    

801064a9 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
801064a9:	55                   	push   %ebp
801064aa:	89 e5                	mov    %esp,%ebp
801064ac:	83 ec 18             	sub    $0x18,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
801064af:	83 ec 08             	sub    $0x8,%esp
801064b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064b5:	50                   	push   %eax
801064b6:	6a 00                	push   $0x0
801064b8:	e8 29 f1 ff ff       	call   801055e6 <argint>
801064bd:	83 c4 10             	add    $0x10,%esp
801064c0:	85 c0                	test   %eax,%eax
801064c2:	79 07                	jns    801064cb <sys_shm_open+0x22>
    return -1;
801064c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c9:	eb 31                	jmp    801064fc <sys_shm_open+0x53>

  if(argptr(1, (char **) (&pointer),4)<0)
801064cb:	83 ec 04             	sub    $0x4,%esp
801064ce:	6a 04                	push   $0x4
801064d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064d3:	50                   	push   %eax
801064d4:	6a 01                	push   $0x1
801064d6:	e8 38 f1 ff ff       	call   80105613 <argptr>
801064db:	83 c4 10             	add    $0x10,%esp
801064de:	85 c0                	test   %eax,%eax
801064e0:	79 07                	jns    801064e9 <sys_shm_open+0x40>
    return -1;
801064e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e7:	eb 13                	jmp    801064fc <sys_shm_open+0x53>
  return shm_open(id, pointer);
801064e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ef:	83 ec 08             	sub    $0x8,%esp
801064f2:	52                   	push   %edx
801064f3:	50                   	push   %eax
801064f4:	e8 96 21 00 00       	call   8010868f <shm_open>
801064f9:	83 c4 10             	add    $0x10,%esp
}
801064fc:	c9                   	leave  
801064fd:	c3                   	ret    

801064fe <sys_shm_close>:

int sys_shm_close(void) {
801064fe:	55                   	push   %ebp
801064ff:	89 e5                	mov    %esp,%ebp
80106501:	83 ec 18             	sub    $0x18,%esp
  int id;

  if(argint(0, &id) < 0)
80106504:	83 ec 08             	sub    $0x8,%esp
80106507:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010650a:	50                   	push   %eax
8010650b:	6a 00                	push   $0x0
8010650d:	e8 d4 f0 ff ff       	call   801055e6 <argint>
80106512:	83 c4 10             	add    $0x10,%esp
80106515:	85 c0                	test   %eax,%eax
80106517:	79 07                	jns    80106520 <sys_shm_close+0x22>
    return -1;
80106519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651e:	eb 0f                	jmp    8010652f <sys_shm_close+0x31>

  
  return shm_close(id);
80106520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106523:	83 ec 0c             	sub    $0xc,%esp
80106526:	50                   	push   %eax
80106527:	e8 6d 21 00 00       	call   80108699 <shm_close>
8010652c:	83 c4 10             	add    $0x10,%esp
}
8010652f:	c9                   	leave  
80106530:	c3                   	ret    

80106531 <sys_fork>:

int
sys_fork(void)
{
80106531:	55                   	push   %ebp
80106532:	89 e5                	mov    %esp,%ebp
80106534:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106537:	e8 fc e0 ff ff       	call   80104638 <fork>
}
8010653c:	c9                   	leave  
8010653d:	c3                   	ret    

8010653e <sys_exit>:

int
sys_exit(void)
{
8010653e:	55                   	push   %ebp
8010653f:	89 e5                	mov    %esp,%ebp
80106541:	83 ec 08             	sub    $0x8,%esp
  exit();
80106544:	e8 9c e2 ff ff       	call   801047e5 <exit>
  return 0;  // not reached
80106549:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010654e:	c9                   	leave  
8010654f:	c3                   	ret    

80106550 <sys_wait>:

int
sys_wait(void)
{
80106550:	55                   	push   %ebp
80106551:	89 e5                	mov    %esp,%ebp
80106553:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106556:	e8 ad e3 ff ff       	call   80104908 <wait>
}
8010655b:	c9                   	leave  
8010655c:	c3                   	ret    

8010655d <sys_kill>:

int
sys_kill(void)
{
8010655d:	55                   	push   %ebp
8010655e:	89 e5                	mov    %esp,%ebp
80106560:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106563:	83 ec 08             	sub    $0x8,%esp
80106566:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106569:	50                   	push   %eax
8010656a:	6a 00                	push   $0x0
8010656c:	e8 75 f0 ff ff       	call   801055e6 <argint>
80106571:	83 c4 10             	add    $0x10,%esp
80106574:	85 c0                	test   %eax,%eax
80106576:	79 07                	jns    8010657f <sys_kill+0x22>
    return -1;
80106578:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657d:	eb 0f                	jmp    8010658e <sys_kill+0x31>
  return kill(pid);
8010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106582:	83 ec 0c             	sub    $0xc,%esp
80106585:	50                   	push   %eax
80106586:	e8 b6 e7 ff ff       	call   80104d41 <kill>
8010658b:	83 c4 10             	add    $0x10,%esp
}
8010658e:	c9                   	leave  
8010658f:	c3                   	ret    

80106590 <sys_getpid>:

int
sys_getpid(void)
{
80106590:	55                   	push   %ebp
80106591:	89 e5                	mov    %esp,%ebp
80106593:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106596:	e8 85 dd ff ff       	call   80104320 <myproc>
8010659b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010659e:	c9                   	leave  
8010659f:	c3                   	ret    

801065a0 <sys_sbrk>:

int
sys_sbrk(void)
{
801065a0:	55                   	push   %ebp
801065a1:	89 e5                	mov    %esp,%ebp
801065a3:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065a6:	83 ec 08             	sub    $0x8,%esp
801065a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ac:	50                   	push   %eax
801065ad:	6a 00                	push   $0x0
801065af:	e8 32 f0 ff ff       	call   801055e6 <argint>
801065b4:	83 c4 10             	add    $0x10,%esp
801065b7:	85 c0                	test   %eax,%eax
801065b9:	79 07                	jns    801065c2 <sys_sbrk+0x22>
    return -1;
801065bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c0:	eb 27                	jmp    801065e9 <sys_sbrk+0x49>
  addr = myproc()->sz;
801065c2:	e8 59 dd ff ff       	call   80104320 <myproc>
801065c7:	8b 00                	mov    (%eax),%eax
801065c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065cf:	83 ec 0c             	sub    $0xc,%esp
801065d2:	50                   	push   %eax
801065d3:	e8 b5 df ff ff       	call   8010458d <growproc>
801065d8:	83 c4 10             	add    $0x10,%esp
801065db:	85 c0                	test   %eax,%eax
801065dd:	79 07                	jns    801065e6 <sys_sbrk+0x46>
    return -1;
801065df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e4:	eb 03                	jmp    801065e9 <sys_sbrk+0x49>
  return addr;
801065e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065e9:	c9                   	leave  
801065ea:	c3                   	ret    

801065eb <sys_sleep>:

int
sys_sleep(void)
{
801065eb:	55                   	push   %ebp
801065ec:	89 e5                	mov    %esp,%ebp
801065ee:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801065f1:	83 ec 08             	sub    $0x8,%esp
801065f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065f7:	50                   	push   %eax
801065f8:	6a 00                	push   $0x0
801065fa:	e8 e7 ef ff ff       	call   801055e6 <argint>
801065ff:	83 c4 10             	add    $0x10,%esp
80106602:	85 c0                	test   %eax,%eax
80106604:	79 07                	jns    8010660d <sys_sleep+0x22>
    return -1;
80106606:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660b:	eb 76                	jmp    80106683 <sys_sleep+0x98>
  acquire(&tickslock);
8010660d:	83 ec 0c             	sub    $0xc,%esp
80106610:	68 e0 5e 11 80       	push   $0x80115ee0
80106615:	e8 29 ea ff ff       	call   80105043 <acquire>
8010661a:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010661d:	a1 20 67 11 80       	mov    0x80116720,%eax
80106622:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106625:	eb 38                	jmp    8010665f <sys_sleep+0x74>
    if(myproc()->killed){
80106627:	e8 f4 dc ff ff       	call   80104320 <myproc>
8010662c:	8b 40 24             	mov    0x24(%eax),%eax
8010662f:	85 c0                	test   %eax,%eax
80106631:	74 17                	je     8010664a <sys_sleep+0x5f>
      release(&tickslock);
80106633:	83 ec 0c             	sub    $0xc,%esp
80106636:	68 e0 5e 11 80       	push   $0x80115ee0
8010663b:	e8 71 ea ff ff       	call   801050b1 <release>
80106640:	83 c4 10             	add    $0x10,%esp
      return -1;
80106643:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106648:	eb 39                	jmp    80106683 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010664a:	83 ec 08             	sub    $0x8,%esp
8010664d:	68 e0 5e 11 80       	push   $0x80115ee0
80106652:	68 20 67 11 80       	push   $0x80116720
80106657:	e8 c5 e5 ff ff       	call   80104c21 <sleep>
8010665c:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010665f:	a1 20 67 11 80       	mov    0x80116720,%eax
80106664:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106667:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010666a:	39 d0                	cmp    %edx,%eax
8010666c:	72 b9                	jb     80106627 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010666e:	83 ec 0c             	sub    $0xc,%esp
80106671:	68 e0 5e 11 80       	push   $0x80115ee0
80106676:	e8 36 ea ff ff       	call   801050b1 <release>
8010667b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010667e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106683:	c9                   	leave  
80106684:	c3                   	ret    

80106685 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106685:	55                   	push   %ebp
80106686:	89 e5                	mov    %esp,%ebp
80106688:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010668b:	83 ec 0c             	sub    $0xc,%esp
8010668e:	68 e0 5e 11 80       	push   $0x80115ee0
80106693:	e8 ab e9 ff ff       	call   80105043 <acquire>
80106698:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010669b:	a1 20 67 11 80       	mov    0x80116720,%eax
801066a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066a3:	83 ec 0c             	sub    $0xc,%esp
801066a6:	68 e0 5e 11 80       	push   $0x80115ee0
801066ab:	e8 01 ea ff ff       	call   801050b1 <release>
801066b0:	83 c4 10             	add    $0x10,%esp
  return xticks;
801066b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066b6:	c9                   	leave  
801066b7:	c3                   	ret    

801066b8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801066b8:	1e                   	push   %ds
  pushl %es
801066b9:	06                   	push   %es
  pushl %fs
801066ba:	0f a0                	push   %fs
  pushl %gs
801066bc:	0f a8                	push   %gs
  pushal
801066be:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801066bf:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066c3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066c5:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801066c7:	54                   	push   %esp
  call trap
801066c8:	e8 d7 01 00 00       	call   801068a4 <trap>
  addl $4, %esp
801066cd:	83 c4 04             	add    $0x4,%esp

801066d0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801066d0:	61                   	popa   
  popl %gs
801066d1:	0f a9                	pop    %gs
  popl %fs
801066d3:	0f a1                	pop    %fs
  popl %es
801066d5:	07                   	pop    %es
  popl %ds
801066d6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066d7:	83 c4 08             	add    $0x8,%esp
  iret
801066da:	cf                   	iret   

801066db <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801066db:	55                   	push   %ebp
801066dc:	89 e5                	mov    %esp,%ebp
801066de:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801066e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801066e4:	83 e8 01             	sub    $0x1,%eax
801066e7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066eb:	8b 45 08             	mov    0x8(%ebp),%eax
801066ee:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066f2:	8b 45 08             	mov    0x8(%ebp),%eax
801066f5:	c1 e8 10             	shr    $0x10,%eax
801066f8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801066fc:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066ff:	0f 01 18             	lidtl  (%eax)
}
80106702:	90                   	nop
80106703:	c9                   	leave  
80106704:	c3                   	ret    

80106705 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106705:	55                   	push   %ebp
80106706:	89 e5                	mov    %esp,%ebp
80106708:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010670b:	0f 20 d0             	mov    %cr2,%eax
8010670e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106711:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106714:	c9                   	leave  
80106715:	c3                   	ret    

80106716 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106716:	55                   	push   %ebp
80106717:	89 e5                	mov    %esp,%ebp
80106719:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010671c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106723:	e9 c3 00 00 00       	jmp    801067eb <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672b:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106732:	89 c2                	mov    %eax,%edx
80106734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106737:	66 89 14 c5 20 5f 11 	mov    %dx,-0x7feea0e0(,%eax,8)
8010673e:	80 
8010673f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106742:	66 c7 04 c5 22 5f 11 	movw   $0x8,-0x7feea0de(,%eax,8)
80106749:	80 08 00 
8010674c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674f:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
80106756:	80 
80106757:	83 e2 e0             	and    $0xffffffe0,%edx
8010675a:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
80106761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106764:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
8010676b:	80 
8010676c:	83 e2 1f             	and    $0x1f,%edx
8010676f:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
80106776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106779:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106780:	80 
80106781:	83 e2 f0             	and    $0xfffffff0,%edx
80106784:	83 ca 0e             	or     $0xe,%edx
80106787:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
8010678e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106791:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106798:	80 
80106799:	83 e2 ef             	and    $0xffffffef,%edx
8010679c:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801067a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a6:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
801067ad:	80 
801067ae:	83 e2 9f             	and    $0xffffff9f,%edx
801067b1:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801067b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bb:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
801067c2:	80 
801067c3:	83 ca 80             	or     $0xffffff80,%edx
801067c6:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801067cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d0:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801067d7:	c1 e8 10             	shr    $0x10,%eax
801067da:	89 c2                	mov    %eax,%edx
801067dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067df:	66 89 14 c5 26 5f 11 	mov    %dx,-0x7feea0da(,%eax,8)
801067e6:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801067e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067eb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067f2:	0f 8e 30 ff ff ff    	jle    80106728 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067f8:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801067fd:	66 a3 20 61 11 80    	mov    %ax,0x80116120
80106803:	66 c7 05 22 61 11 80 	movw   $0x8,0x80116122
8010680a:	08 00 
8010680c:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
80106813:	83 e0 e0             	and    $0xffffffe0,%eax
80106816:	a2 24 61 11 80       	mov    %al,0x80116124
8010681b:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
80106822:	83 e0 1f             	and    $0x1f,%eax
80106825:	a2 24 61 11 80       	mov    %al,0x80116124
8010682a:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106831:	83 c8 0f             	or     $0xf,%eax
80106834:	a2 25 61 11 80       	mov    %al,0x80116125
80106839:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106840:	83 e0 ef             	and    $0xffffffef,%eax
80106843:	a2 25 61 11 80       	mov    %al,0x80116125
80106848:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
8010684f:	83 c8 60             	or     $0x60,%eax
80106852:	a2 25 61 11 80       	mov    %al,0x80116125
80106857:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
8010685e:	83 c8 80             	or     $0xffffff80,%eax
80106861:	a2 25 61 11 80       	mov    %al,0x80116125
80106866:	a1 80 b1 10 80       	mov    0x8010b180,%eax
8010686b:	c1 e8 10             	shr    $0x10,%eax
8010686e:	66 a3 26 61 11 80    	mov    %ax,0x80116126

  initlock(&tickslock, "time");
80106874:	83 ec 08             	sub    $0x8,%esp
80106877:	68 e4 8b 10 80       	push   $0x80108be4
8010687c:	68 e0 5e 11 80       	push   $0x80115ee0
80106881:	e8 9b e7 ff ff       	call   80105021 <initlock>
80106886:	83 c4 10             	add    $0x10,%esp
}
80106889:	90                   	nop
8010688a:	c9                   	leave  
8010688b:	c3                   	ret    

8010688c <idtinit>:

void
idtinit(void)
{
8010688c:	55                   	push   %ebp
8010688d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010688f:	68 00 08 00 00       	push   $0x800
80106894:	68 20 5f 11 80       	push   $0x80115f20
80106899:	e8 3d fe ff ff       	call   801066db <lidt>
8010689e:	83 c4 08             	add    $0x8,%esp
}
801068a1:	90                   	nop
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068a4:	55                   	push   %ebp
801068a5:	89 e5                	mov    %esp,%ebp
801068a7:	57                   	push   %edi
801068a8:	56                   	push   %esi
801068a9:	53                   	push   %ebx
801068aa:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801068ad:	8b 45 08             	mov    0x8(%ebp),%eax
801068b0:	8b 40 30             	mov    0x30(%eax),%eax
801068b3:	83 f8 40             	cmp    $0x40,%eax
801068b6:	75 3d                	jne    801068f5 <trap+0x51>
    if(myproc()->killed)
801068b8:	e8 63 da ff ff       	call   80104320 <myproc>
801068bd:	8b 40 24             	mov    0x24(%eax),%eax
801068c0:	85 c0                	test   %eax,%eax
801068c2:	74 05                	je     801068c9 <trap+0x25>
      exit();
801068c4:	e8 1c df ff ff       	call   801047e5 <exit>
    myproc()->tf = tf;
801068c9:	e8 52 da ff ff       	call   80104320 <myproc>
801068ce:	89 c2                	mov    %eax,%edx
801068d0:	8b 45 08             	mov    0x8(%ebp),%eax
801068d3:	89 42 18             	mov    %eax,0x18(%edx)
    syscall();
801068d6:	e8 d7 ed ff ff       	call   801056b2 <syscall>
    if(myproc()->killed)
801068db:	e8 40 da ff ff       	call   80104320 <myproc>
801068e0:	8b 40 24             	mov    0x24(%eax),%eax
801068e3:	85 c0                	test   %eax,%eax
801068e5:	0f 84 73 02 00 00    	je     80106b5e <trap+0x2ba>
      exit();
801068eb:	e8 f5 de ff ff       	call   801047e5 <exit>
    return;
801068f0:	e9 69 02 00 00       	jmp    80106b5e <trap+0x2ba>
  }

  switch(tf->trapno){
801068f5:	8b 45 08             	mov    0x8(%ebp),%eax
801068f8:	8b 40 30             	mov    0x30(%eax),%eax
801068fb:	83 e8 20             	sub    $0x20,%eax
801068fe:	83 f8 1f             	cmp    $0x1f,%eax
80106901:	0f 87 b5 00 00 00    	ja     801069bc <trap+0x118>
80106907:	8b 04 85 9c 8c 10 80 	mov    -0x7fef7364(,%eax,4),%eax
8010690e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106910:	e8 72 d9 ff ff       	call   80104287 <cpuid>
80106915:	85 c0                	test   %eax,%eax
80106917:	75 3d                	jne    80106956 <trap+0xb2>
      acquire(&tickslock);
80106919:	83 ec 0c             	sub    $0xc,%esp
8010691c:	68 e0 5e 11 80       	push   $0x80115ee0
80106921:	e8 1d e7 ff ff       	call   80105043 <acquire>
80106926:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106929:	a1 20 67 11 80       	mov    0x80116720,%eax
8010692e:	83 c0 01             	add    $0x1,%eax
80106931:	a3 20 67 11 80       	mov    %eax,0x80116720
      wakeup(&ticks);
80106936:	83 ec 0c             	sub    $0xc,%esp
80106939:	68 20 67 11 80       	push   $0x80116720
8010693e:	e8 c7 e3 ff ff       	call   80104d0a <wakeup>
80106943:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106946:	83 ec 0c             	sub    $0xc,%esp
80106949:	68 e0 5e 11 80       	push   $0x80115ee0
8010694e:	e8 5e e7 ff ff       	call   801050b1 <release>
80106953:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106956:	e8 45 c7 ff ff       	call   801030a0 <lapiceoi>
    break;
8010695b:	e9 7e 01 00 00       	jmp    80106ade <trap+0x23a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106960:	e8 b5 bf ff ff       	call   8010291a <ideintr>
    lapiceoi();
80106965:	e8 36 c7 ff ff       	call   801030a0 <lapiceoi>
    break;
8010696a:	e9 6f 01 00 00       	jmp    80106ade <trap+0x23a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010696f:	e8 75 c5 ff ff       	call   80102ee9 <kbdintr>
    lapiceoi();
80106974:	e8 27 c7 ff ff       	call   801030a0 <lapiceoi>
    break;
80106979:	e9 60 01 00 00       	jmp    80106ade <trap+0x23a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010697e:	e8 af 03 00 00       	call   80106d32 <uartintr>
    lapiceoi();
80106983:	e8 18 c7 ff ff       	call   801030a0 <lapiceoi>
    break;
80106988:	e9 51 01 00 00       	jmp    80106ade <trap+0x23a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010698d:	8b 45 08             	mov    0x8(%ebp),%eax
80106990:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106993:	8b 45 08             	mov    0x8(%ebp),%eax
80106996:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010699a:	0f b7 d8             	movzwl %ax,%ebx
8010699d:	e8 e5 d8 ff ff       	call   80104287 <cpuid>
801069a2:	56                   	push   %esi
801069a3:	53                   	push   %ebx
801069a4:	50                   	push   %eax
801069a5:	68 ec 8b 10 80       	push   $0x80108bec
801069aa:	e8 51 9a ff ff       	call   80100400 <cprintf>
801069af:	83 c4 10             	add    $0x10,%esp
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801069b2:	e8 e9 c6 ff ff       	call   801030a0 <lapiceoi>
    break;
801069b7:	e9 22 01 00 00       	jmp    80106ade <trap+0x23a>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801069bc:	e8 5f d9 ff ff       	call   80104320 <myproc>
801069c1:	85 c0                	test   %eax,%eax
801069c3:	74 11                	je     801069d6 <trap+0x132>
801069c5:	8b 45 08             	mov    0x8(%ebp),%eax
801069c8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069cc:	0f b7 c0             	movzwl %ax,%eax
801069cf:	83 e0 03             	and    $0x3,%eax
801069d2:	85 c0                	test   %eax,%eax
801069d4:	75 3b                	jne    80106a11 <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069d6:	e8 2a fd ff ff       	call   80106705 <rcr2>
801069db:	89 c6                	mov    %eax,%esi
801069dd:	8b 45 08             	mov    0x8(%ebp),%eax
801069e0:	8b 58 38             	mov    0x38(%eax),%ebx
801069e3:	e8 9f d8 ff ff       	call   80104287 <cpuid>
801069e8:	89 c2                	mov    %eax,%edx
801069ea:	8b 45 08             	mov    0x8(%ebp),%eax
801069ed:	8b 40 30             	mov    0x30(%eax),%eax
801069f0:	83 ec 0c             	sub    $0xc,%esp
801069f3:	56                   	push   %esi
801069f4:	53                   	push   %ebx
801069f5:	52                   	push   %edx
801069f6:	50                   	push   %eax
801069f7:	68 10 8c 10 80       	push   $0x80108c10
801069fc:	e8 ff 99 ff ff       	call   80100400 <cprintf>
80106a01:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106a04:	83 ec 0c             	sub    $0xc,%esp
80106a07:	68 42 8c 10 80       	push   $0x80108c42
80106a0c:	e8 8f 9b ff ff       	call   801005a0 <panic>
    }
    if (tf->trapno == T_PGFLT)
80106a11:	8b 45 08             	mov    0x8(%ebp),%eax
80106a14:	8b 40 30             	mov    0x30(%eax),%eax
80106a17:	83 f8 0e             	cmp    $0xe,%eax
80106a1a:	75 64                	jne    80106a80 <trap+0x1dc>
    {
//	if (myproc()->tf->esp < myproc()->last_page)
//	{
	    cprintf("DIFFERENCE: %d\n", myproc()->last_page - myproc()->tf->esp);
80106a1c:	e8 ff d8 ff ff       	call   80104320 <myproc>
80106a21:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a24:	e8 f7 d8 ff ff       	call   80104320 <myproc>
80106a29:	8b 40 18             	mov    0x18(%eax),%eax
80106a2c:	8b 40 44             	mov    0x44(%eax),%eax
80106a2f:	29 c3                	sub    %eax,%ebx
80106a31:	89 d8                	mov    %ebx,%eax
80106a33:	83 ec 08             	sub    $0x8,%esp
80106a36:	50                   	push   %eax
80106a37:	68 47 8c 10 80       	push   $0x80108c47
80106a3c:	e8 bf 99 ff ff       	call   80100400 <cprintf>
80106a41:	83 c4 10             	add    $0x10,%esp
            myproc()->last_page = allocuvm(myproc()->pgdir, myproc()->last_page-2*PGSIZE, (myproc()->last_page-PGSIZE-4)); 
80106a44:	e8 d7 d8 ff ff       	call   80104320 <myproc>
80106a49:	89 c7                	mov    %eax,%edi
80106a4b:	e8 d0 d8 ff ff       	call   80104320 <myproc>
80106a50:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a53:	8d b0 fc ef ff ff    	lea    -0x1004(%eax),%esi
80106a59:	e8 c2 d8 ff ff       	call   80104320 <myproc>
80106a5e:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a61:	8d 98 00 e0 ff ff    	lea    -0x2000(%eax),%ebx
80106a67:	e8 b4 d8 ff ff       	call   80104320 <myproc>
80106a6c:	8b 40 04             	mov    0x4(%eax),%eax
80106a6f:	83 ec 04             	sub    $0x4,%esp
80106a72:	56                   	push   %esi
80106a73:	53                   	push   %ebx
80106a74:	50                   	push   %eax
80106a75:	e8 b1 15 00 00       	call   8010802b <allocuvm>
80106a7a:	83 c4 10             	add    $0x10,%esp
80106a7d:	89 47 7c             	mov    %eax,0x7c(%edi)
//	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a80:	e8 80 fc ff ff       	call   80106705 <rcr2>
80106a85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a88:	8b 45 08             	mov    0x8(%ebp),%eax
80106a8b:	8b 78 38             	mov    0x38(%eax),%edi
80106a8e:	e8 f4 d7 ff ff       	call   80104287 <cpuid>
80106a93:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106a96:	8b 45 08             	mov    0x8(%ebp),%eax
80106a99:	8b 70 34             	mov    0x34(%eax),%esi
80106a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9f:	8b 58 30             	mov    0x30(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106aa2:	e8 79 d8 ff ff       	call   80104320 <myproc>
80106aa7:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106aaa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106aad:	e8 6e d8 ff ff       	call   80104320 <myproc>
	    cprintf("DIFFERENCE: %d\n", myproc()->last_page - myproc()->tf->esp);
            myproc()->last_page = allocuvm(myproc()->pgdir, myproc()->last_page-2*PGSIZE, (myproc()->last_page-PGSIZE-4)); 
//	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ab2:	8b 40 10             	mov    0x10(%eax),%eax
80106ab5:	ff 75 e4             	pushl  -0x1c(%ebp)
80106ab8:	57                   	push   %edi
80106ab9:	ff 75 e0             	pushl  -0x20(%ebp)
80106abc:	56                   	push   %esi
80106abd:	53                   	push   %ebx
80106abe:	ff 75 dc             	pushl  -0x24(%ebp)
80106ac1:	50                   	push   %eax
80106ac2:	68 58 8c 10 80       	push   $0x80108c58
80106ac7:	e8 34 99 ff ff       	call   80100400 <cprintf>
80106acc:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106acf:	e8 4c d8 ff ff       	call   80104320 <myproc>
80106ad4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106adb:	eb 01                	jmp    80106ade <trap+0x23a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106add:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ade:	e8 3d d8 ff ff       	call   80104320 <myproc>
80106ae3:	85 c0                	test   %eax,%eax
80106ae5:	74 23                	je     80106b0a <trap+0x266>
80106ae7:	e8 34 d8 ff ff       	call   80104320 <myproc>
80106aec:	8b 40 24             	mov    0x24(%eax),%eax
80106aef:	85 c0                	test   %eax,%eax
80106af1:	74 17                	je     80106b0a <trap+0x266>
80106af3:	8b 45 08             	mov    0x8(%ebp),%eax
80106af6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106afa:	0f b7 c0             	movzwl %ax,%eax
80106afd:	83 e0 03             	and    $0x3,%eax
80106b00:	83 f8 03             	cmp    $0x3,%eax
80106b03:	75 05                	jne    80106b0a <trap+0x266>
    exit();
80106b05:	e8 db dc ff ff       	call   801047e5 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b0a:	e8 11 d8 ff ff       	call   80104320 <myproc>
80106b0f:	85 c0                	test   %eax,%eax
80106b11:	74 1d                	je     80106b30 <trap+0x28c>
80106b13:	e8 08 d8 ff ff       	call   80104320 <myproc>
80106b18:	8b 40 0c             	mov    0xc(%eax),%eax
80106b1b:	83 f8 04             	cmp    $0x4,%eax
80106b1e:	75 10                	jne    80106b30 <trap+0x28c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b20:	8b 45 08             	mov    0x8(%ebp),%eax
80106b23:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b26:	83 f8 20             	cmp    $0x20,%eax
80106b29:	75 05                	jne    80106b30 <trap+0x28c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106b2b:	e8 71 e0 ff ff       	call   80104ba1 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b30:	e8 eb d7 ff ff       	call   80104320 <myproc>
80106b35:	85 c0                	test   %eax,%eax
80106b37:	74 26                	je     80106b5f <trap+0x2bb>
80106b39:	e8 e2 d7 ff ff       	call   80104320 <myproc>
80106b3e:	8b 40 24             	mov    0x24(%eax),%eax
80106b41:	85 c0                	test   %eax,%eax
80106b43:	74 1a                	je     80106b5f <trap+0x2bb>
80106b45:	8b 45 08             	mov    0x8(%ebp),%eax
80106b48:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b4c:	0f b7 c0             	movzwl %ax,%eax
80106b4f:	83 e0 03             	and    $0x3,%eax
80106b52:	83 f8 03             	cmp    $0x3,%eax
80106b55:	75 08                	jne    80106b5f <trap+0x2bb>
    exit();
80106b57:	e8 89 dc ff ff       	call   801047e5 <exit>
80106b5c:	eb 01                	jmp    80106b5f <trap+0x2bb>
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
80106b5e:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b62:	5b                   	pop    %ebx
80106b63:	5e                   	pop    %esi
80106b64:	5f                   	pop    %edi
80106b65:	5d                   	pop    %ebp
80106b66:	c3                   	ret    

80106b67 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b67:	55                   	push   %ebp
80106b68:	89 e5                	mov    %esp,%ebp
80106b6a:	83 ec 14             	sub    $0x14,%esp
80106b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b70:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b74:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b78:	89 c2                	mov    %eax,%edx
80106b7a:	ec                   	in     (%dx),%al
80106b7b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b7e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b82:	c9                   	leave  
80106b83:	c3                   	ret    

80106b84 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b84:	55                   	push   %ebp
80106b85:	89 e5                	mov    %esp,%ebp
80106b87:	83 ec 08             	sub    $0x8,%esp
80106b8a:	8b 55 08             	mov    0x8(%ebp),%edx
80106b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b90:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b94:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b97:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b9b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b9f:	ee                   	out    %al,(%dx)
}
80106ba0:	90                   	nop
80106ba1:	c9                   	leave  
80106ba2:	c3                   	ret    

80106ba3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ba3:	55                   	push   %ebp
80106ba4:	89 e5                	mov    %esp,%ebp
80106ba6:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ba9:	6a 00                	push   $0x0
80106bab:	68 fa 03 00 00       	push   $0x3fa
80106bb0:	e8 cf ff ff ff       	call   80106b84 <outb>
80106bb5:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bb8:	68 80 00 00 00       	push   $0x80
80106bbd:	68 fb 03 00 00       	push   $0x3fb
80106bc2:	e8 bd ff ff ff       	call   80106b84 <outb>
80106bc7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106bca:	6a 0c                	push   $0xc
80106bcc:	68 f8 03 00 00       	push   $0x3f8
80106bd1:	e8 ae ff ff ff       	call   80106b84 <outb>
80106bd6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106bd9:	6a 00                	push   $0x0
80106bdb:	68 f9 03 00 00       	push   $0x3f9
80106be0:	e8 9f ff ff ff       	call   80106b84 <outb>
80106be5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106be8:	6a 03                	push   $0x3
80106bea:	68 fb 03 00 00       	push   $0x3fb
80106bef:	e8 90 ff ff ff       	call   80106b84 <outb>
80106bf4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106bf7:	6a 00                	push   $0x0
80106bf9:	68 fc 03 00 00       	push   $0x3fc
80106bfe:	e8 81 ff ff ff       	call   80106b84 <outb>
80106c03:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c06:	6a 01                	push   $0x1
80106c08:	68 f9 03 00 00       	push   $0x3f9
80106c0d:	e8 72 ff ff ff       	call   80106b84 <outb>
80106c12:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c15:	68 fd 03 00 00       	push   $0x3fd
80106c1a:	e8 48 ff ff ff       	call   80106b67 <inb>
80106c1f:	83 c4 04             	add    $0x4,%esp
80106c22:	3c ff                	cmp    $0xff,%al
80106c24:	74 61                	je     80106c87 <uartinit+0xe4>
    return;
  uart = 1;
80106c26:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
80106c2d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c30:	68 fa 03 00 00       	push   $0x3fa
80106c35:	e8 2d ff ff ff       	call   80106b67 <inb>
80106c3a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c3d:	68 f8 03 00 00       	push   $0x3f8
80106c42:	e8 20 ff ff ff       	call   80106b67 <inb>
80106c47:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106c4a:	83 ec 08             	sub    $0x8,%esp
80106c4d:	6a 00                	push   $0x0
80106c4f:	6a 04                	push   $0x4
80106c51:	e8 61 bf ff ff       	call   80102bb7 <ioapicenable>
80106c56:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c59:	c7 45 f4 1c 8d 10 80 	movl   $0x80108d1c,-0xc(%ebp)
80106c60:	eb 19                	jmp    80106c7b <uartinit+0xd8>
    uartputc(*p);
80106c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c65:	0f b6 00             	movzbl (%eax),%eax
80106c68:	0f be c0             	movsbl %al,%eax
80106c6b:	83 ec 0c             	sub    $0xc,%esp
80106c6e:	50                   	push   %eax
80106c6f:	e8 16 00 00 00       	call   80106c8a <uartputc>
80106c74:	83 c4 10             	add    $0x10,%esp
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c77:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c7e:	0f b6 00             	movzbl (%eax),%eax
80106c81:	84 c0                	test   %al,%al
80106c83:	75 dd                	jne    80106c62 <uartinit+0xbf>
80106c85:	eb 01                	jmp    80106c88 <uartinit+0xe5>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106c87:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106c88:	c9                   	leave  
80106c89:	c3                   	ret    

80106c8a <uartputc>:

void
uartputc(int c)
{
80106c8a:	55                   	push   %ebp
80106c8b:	89 e5                	mov    %esp,%ebp
80106c8d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c90:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106c95:	85 c0                	test   %eax,%eax
80106c97:	74 53                	je     80106cec <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ca0:	eb 11                	jmp    80106cb3 <uartputc+0x29>
    microdelay(10);
80106ca2:	83 ec 0c             	sub    $0xc,%esp
80106ca5:	6a 0a                	push   $0xa
80106ca7:	e8 0f c4 ff ff       	call   801030bb <microdelay>
80106cac:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106caf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cb3:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106cb7:	7f 1a                	jg     80106cd3 <uartputc+0x49>
80106cb9:	83 ec 0c             	sub    $0xc,%esp
80106cbc:	68 fd 03 00 00       	push   $0x3fd
80106cc1:	e8 a1 fe ff ff       	call   80106b67 <inb>
80106cc6:	83 c4 10             	add    $0x10,%esp
80106cc9:	0f b6 c0             	movzbl %al,%eax
80106ccc:	83 e0 20             	and    $0x20,%eax
80106ccf:	85 c0                	test   %eax,%eax
80106cd1:	74 cf                	je     80106ca2 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd6:	0f b6 c0             	movzbl %al,%eax
80106cd9:	83 ec 08             	sub    $0x8,%esp
80106cdc:	50                   	push   %eax
80106cdd:	68 f8 03 00 00       	push   $0x3f8
80106ce2:	e8 9d fe ff ff       	call   80106b84 <outb>
80106ce7:	83 c4 10             	add    $0x10,%esp
80106cea:	eb 01                	jmp    80106ced <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106cec:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106ced:	c9                   	leave  
80106cee:	c3                   	ret    

80106cef <uartgetc>:

static int
uartgetc(void)
{
80106cef:	55                   	push   %ebp
80106cf0:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106cf2:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106cf7:	85 c0                	test   %eax,%eax
80106cf9:	75 07                	jne    80106d02 <uartgetc+0x13>
    return -1;
80106cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d00:	eb 2e                	jmp    80106d30 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d02:	68 fd 03 00 00       	push   $0x3fd
80106d07:	e8 5b fe ff ff       	call   80106b67 <inb>
80106d0c:	83 c4 04             	add    $0x4,%esp
80106d0f:	0f b6 c0             	movzbl %al,%eax
80106d12:	83 e0 01             	and    $0x1,%eax
80106d15:	85 c0                	test   %eax,%eax
80106d17:	75 07                	jne    80106d20 <uartgetc+0x31>
    return -1;
80106d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d1e:	eb 10                	jmp    80106d30 <uartgetc+0x41>
  return inb(COM1+0);
80106d20:	68 f8 03 00 00       	push   $0x3f8
80106d25:	e8 3d fe ff ff       	call   80106b67 <inb>
80106d2a:	83 c4 04             	add    $0x4,%esp
80106d2d:	0f b6 c0             	movzbl %al,%eax
}
80106d30:	c9                   	leave  
80106d31:	c3                   	ret    

80106d32 <uartintr>:

void
uartintr(void)
{
80106d32:	55                   	push   %ebp
80106d33:	89 e5                	mov    %esp,%ebp
80106d35:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d38:	83 ec 0c             	sub    $0xc,%esp
80106d3b:	68 ef 6c 10 80       	push   $0x80106cef
80106d40:	e8 e7 9a ff ff       	call   8010082c <consoleintr>
80106d45:	83 c4 10             	add    $0x10,%esp
}
80106d48:	90                   	nop
80106d49:	c9                   	leave  
80106d4a:	c3                   	ret    

80106d4b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $0
80106d4d:	6a 00                	push   $0x0
  jmp alltraps
80106d4f:	e9 64 f9 ff ff       	jmp    801066b8 <alltraps>

80106d54 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $1
80106d56:	6a 01                	push   $0x1
  jmp alltraps
80106d58:	e9 5b f9 ff ff       	jmp    801066b8 <alltraps>

80106d5d <vector2>:
.globl vector2
vector2:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $2
80106d5f:	6a 02                	push   $0x2
  jmp alltraps
80106d61:	e9 52 f9 ff ff       	jmp    801066b8 <alltraps>

80106d66 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $3
80106d68:	6a 03                	push   $0x3
  jmp alltraps
80106d6a:	e9 49 f9 ff ff       	jmp    801066b8 <alltraps>

80106d6f <vector4>:
.globl vector4
vector4:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $4
80106d71:	6a 04                	push   $0x4
  jmp alltraps
80106d73:	e9 40 f9 ff ff       	jmp    801066b8 <alltraps>

80106d78 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $5
80106d7a:	6a 05                	push   $0x5
  jmp alltraps
80106d7c:	e9 37 f9 ff ff       	jmp    801066b8 <alltraps>

80106d81 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $6
80106d83:	6a 06                	push   $0x6
  jmp alltraps
80106d85:	e9 2e f9 ff ff       	jmp    801066b8 <alltraps>

80106d8a <vector7>:
.globl vector7
vector7:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $7
80106d8c:	6a 07                	push   $0x7
  jmp alltraps
80106d8e:	e9 25 f9 ff ff       	jmp    801066b8 <alltraps>

80106d93 <vector8>:
.globl vector8
vector8:
  pushl $8
80106d93:	6a 08                	push   $0x8
  jmp alltraps
80106d95:	e9 1e f9 ff ff       	jmp    801066b8 <alltraps>

80106d9a <vector9>:
.globl vector9
vector9:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $9
80106d9c:	6a 09                	push   $0x9
  jmp alltraps
80106d9e:	e9 15 f9 ff ff       	jmp    801066b8 <alltraps>

80106da3 <vector10>:
.globl vector10
vector10:
  pushl $10
80106da3:	6a 0a                	push   $0xa
  jmp alltraps
80106da5:	e9 0e f9 ff ff       	jmp    801066b8 <alltraps>

80106daa <vector11>:
.globl vector11
vector11:
  pushl $11
80106daa:	6a 0b                	push   $0xb
  jmp alltraps
80106dac:	e9 07 f9 ff ff       	jmp    801066b8 <alltraps>

80106db1 <vector12>:
.globl vector12
vector12:
  pushl $12
80106db1:	6a 0c                	push   $0xc
  jmp alltraps
80106db3:	e9 00 f9 ff ff       	jmp    801066b8 <alltraps>

80106db8 <vector13>:
.globl vector13
vector13:
  pushl $13
80106db8:	6a 0d                	push   $0xd
  jmp alltraps
80106dba:	e9 f9 f8 ff ff       	jmp    801066b8 <alltraps>

80106dbf <vector14>:
.globl vector14
vector14:
  pushl $14
80106dbf:	6a 0e                	push   $0xe
  jmp alltraps
80106dc1:	e9 f2 f8 ff ff       	jmp    801066b8 <alltraps>

80106dc6 <vector15>:
.globl vector15
vector15:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $15
80106dc8:	6a 0f                	push   $0xf
  jmp alltraps
80106dca:	e9 e9 f8 ff ff       	jmp    801066b8 <alltraps>

80106dcf <vector16>:
.globl vector16
vector16:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $16
80106dd1:	6a 10                	push   $0x10
  jmp alltraps
80106dd3:	e9 e0 f8 ff ff       	jmp    801066b8 <alltraps>

80106dd8 <vector17>:
.globl vector17
vector17:
  pushl $17
80106dd8:	6a 11                	push   $0x11
  jmp alltraps
80106dda:	e9 d9 f8 ff ff       	jmp    801066b8 <alltraps>

80106ddf <vector18>:
.globl vector18
vector18:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $18
80106de1:	6a 12                	push   $0x12
  jmp alltraps
80106de3:	e9 d0 f8 ff ff       	jmp    801066b8 <alltraps>

80106de8 <vector19>:
.globl vector19
vector19:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $19
80106dea:	6a 13                	push   $0x13
  jmp alltraps
80106dec:	e9 c7 f8 ff ff       	jmp    801066b8 <alltraps>

80106df1 <vector20>:
.globl vector20
vector20:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $20
80106df3:	6a 14                	push   $0x14
  jmp alltraps
80106df5:	e9 be f8 ff ff       	jmp    801066b8 <alltraps>

80106dfa <vector21>:
.globl vector21
vector21:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $21
80106dfc:	6a 15                	push   $0x15
  jmp alltraps
80106dfe:	e9 b5 f8 ff ff       	jmp    801066b8 <alltraps>

80106e03 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $22
80106e05:	6a 16                	push   $0x16
  jmp alltraps
80106e07:	e9 ac f8 ff ff       	jmp    801066b8 <alltraps>

80106e0c <vector23>:
.globl vector23
vector23:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $23
80106e0e:	6a 17                	push   $0x17
  jmp alltraps
80106e10:	e9 a3 f8 ff ff       	jmp    801066b8 <alltraps>

80106e15 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $24
80106e17:	6a 18                	push   $0x18
  jmp alltraps
80106e19:	e9 9a f8 ff ff       	jmp    801066b8 <alltraps>

80106e1e <vector25>:
.globl vector25
vector25:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $25
80106e20:	6a 19                	push   $0x19
  jmp alltraps
80106e22:	e9 91 f8 ff ff       	jmp    801066b8 <alltraps>

80106e27 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $26
80106e29:	6a 1a                	push   $0x1a
  jmp alltraps
80106e2b:	e9 88 f8 ff ff       	jmp    801066b8 <alltraps>

80106e30 <vector27>:
.globl vector27
vector27:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $27
80106e32:	6a 1b                	push   $0x1b
  jmp alltraps
80106e34:	e9 7f f8 ff ff       	jmp    801066b8 <alltraps>

80106e39 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $28
80106e3b:	6a 1c                	push   $0x1c
  jmp alltraps
80106e3d:	e9 76 f8 ff ff       	jmp    801066b8 <alltraps>

80106e42 <vector29>:
.globl vector29
vector29:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $29
80106e44:	6a 1d                	push   $0x1d
  jmp alltraps
80106e46:	e9 6d f8 ff ff       	jmp    801066b8 <alltraps>

80106e4b <vector30>:
.globl vector30
vector30:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $30
80106e4d:	6a 1e                	push   $0x1e
  jmp alltraps
80106e4f:	e9 64 f8 ff ff       	jmp    801066b8 <alltraps>

80106e54 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $31
80106e56:	6a 1f                	push   $0x1f
  jmp alltraps
80106e58:	e9 5b f8 ff ff       	jmp    801066b8 <alltraps>

80106e5d <vector32>:
.globl vector32
vector32:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $32
80106e5f:	6a 20                	push   $0x20
  jmp alltraps
80106e61:	e9 52 f8 ff ff       	jmp    801066b8 <alltraps>

80106e66 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $33
80106e68:	6a 21                	push   $0x21
  jmp alltraps
80106e6a:	e9 49 f8 ff ff       	jmp    801066b8 <alltraps>

80106e6f <vector34>:
.globl vector34
vector34:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $34
80106e71:	6a 22                	push   $0x22
  jmp alltraps
80106e73:	e9 40 f8 ff ff       	jmp    801066b8 <alltraps>

80106e78 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $35
80106e7a:	6a 23                	push   $0x23
  jmp alltraps
80106e7c:	e9 37 f8 ff ff       	jmp    801066b8 <alltraps>

80106e81 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $36
80106e83:	6a 24                	push   $0x24
  jmp alltraps
80106e85:	e9 2e f8 ff ff       	jmp    801066b8 <alltraps>

80106e8a <vector37>:
.globl vector37
vector37:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $37
80106e8c:	6a 25                	push   $0x25
  jmp alltraps
80106e8e:	e9 25 f8 ff ff       	jmp    801066b8 <alltraps>

80106e93 <vector38>:
.globl vector38
vector38:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $38
80106e95:	6a 26                	push   $0x26
  jmp alltraps
80106e97:	e9 1c f8 ff ff       	jmp    801066b8 <alltraps>

80106e9c <vector39>:
.globl vector39
vector39:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $39
80106e9e:	6a 27                	push   $0x27
  jmp alltraps
80106ea0:	e9 13 f8 ff ff       	jmp    801066b8 <alltraps>

80106ea5 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $40
80106ea7:	6a 28                	push   $0x28
  jmp alltraps
80106ea9:	e9 0a f8 ff ff       	jmp    801066b8 <alltraps>

80106eae <vector41>:
.globl vector41
vector41:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $41
80106eb0:	6a 29                	push   $0x29
  jmp alltraps
80106eb2:	e9 01 f8 ff ff       	jmp    801066b8 <alltraps>

80106eb7 <vector42>:
.globl vector42
vector42:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $42
80106eb9:	6a 2a                	push   $0x2a
  jmp alltraps
80106ebb:	e9 f8 f7 ff ff       	jmp    801066b8 <alltraps>

80106ec0 <vector43>:
.globl vector43
vector43:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $43
80106ec2:	6a 2b                	push   $0x2b
  jmp alltraps
80106ec4:	e9 ef f7 ff ff       	jmp    801066b8 <alltraps>

80106ec9 <vector44>:
.globl vector44
vector44:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $44
80106ecb:	6a 2c                	push   $0x2c
  jmp alltraps
80106ecd:	e9 e6 f7 ff ff       	jmp    801066b8 <alltraps>

80106ed2 <vector45>:
.globl vector45
vector45:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $45
80106ed4:	6a 2d                	push   $0x2d
  jmp alltraps
80106ed6:	e9 dd f7 ff ff       	jmp    801066b8 <alltraps>

80106edb <vector46>:
.globl vector46
vector46:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $46
80106edd:	6a 2e                	push   $0x2e
  jmp alltraps
80106edf:	e9 d4 f7 ff ff       	jmp    801066b8 <alltraps>

80106ee4 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $47
80106ee6:	6a 2f                	push   $0x2f
  jmp alltraps
80106ee8:	e9 cb f7 ff ff       	jmp    801066b8 <alltraps>

80106eed <vector48>:
.globl vector48
vector48:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $48
80106eef:	6a 30                	push   $0x30
  jmp alltraps
80106ef1:	e9 c2 f7 ff ff       	jmp    801066b8 <alltraps>

80106ef6 <vector49>:
.globl vector49
vector49:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $49
80106ef8:	6a 31                	push   $0x31
  jmp alltraps
80106efa:	e9 b9 f7 ff ff       	jmp    801066b8 <alltraps>

80106eff <vector50>:
.globl vector50
vector50:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $50
80106f01:	6a 32                	push   $0x32
  jmp alltraps
80106f03:	e9 b0 f7 ff ff       	jmp    801066b8 <alltraps>

80106f08 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $51
80106f0a:	6a 33                	push   $0x33
  jmp alltraps
80106f0c:	e9 a7 f7 ff ff       	jmp    801066b8 <alltraps>

80106f11 <vector52>:
.globl vector52
vector52:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $52
80106f13:	6a 34                	push   $0x34
  jmp alltraps
80106f15:	e9 9e f7 ff ff       	jmp    801066b8 <alltraps>

80106f1a <vector53>:
.globl vector53
vector53:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $53
80106f1c:	6a 35                	push   $0x35
  jmp alltraps
80106f1e:	e9 95 f7 ff ff       	jmp    801066b8 <alltraps>

80106f23 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $54
80106f25:	6a 36                	push   $0x36
  jmp alltraps
80106f27:	e9 8c f7 ff ff       	jmp    801066b8 <alltraps>

80106f2c <vector55>:
.globl vector55
vector55:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $55
80106f2e:	6a 37                	push   $0x37
  jmp alltraps
80106f30:	e9 83 f7 ff ff       	jmp    801066b8 <alltraps>

80106f35 <vector56>:
.globl vector56
vector56:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $56
80106f37:	6a 38                	push   $0x38
  jmp alltraps
80106f39:	e9 7a f7 ff ff       	jmp    801066b8 <alltraps>

80106f3e <vector57>:
.globl vector57
vector57:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $57
80106f40:	6a 39                	push   $0x39
  jmp alltraps
80106f42:	e9 71 f7 ff ff       	jmp    801066b8 <alltraps>

80106f47 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $58
80106f49:	6a 3a                	push   $0x3a
  jmp alltraps
80106f4b:	e9 68 f7 ff ff       	jmp    801066b8 <alltraps>

80106f50 <vector59>:
.globl vector59
vector59:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $59
80106f52:	6a 3b                	push   $0x3b
  jmp alltraps
80106f54:	e9 5f f7 ff ff       	jmp    801066b8 <alltraps>

80106f59 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $60
80106f5b:	6a 3c                	push   $0x3c
  jmp alltraps
80106f5d:	e9 56 f7 ff ff       	jmp    801066b8 <alltraps>

80106f62 <vector61>:
.globl vector61
vector61:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $61
80106f64:	6a 3d                	push   $0x3d
  jmp alltraps
80106f66:	e9 4d f7 ff ff       	jmp    801066b8 <alltraps>

80106f6b <vector62>:
.globl vector62
vector62:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $62
80106f6d:	6a 3e                	push   $0x3e
  jmp alltraps
80106f6f:	e9 44 f7 ff ff       	jmp    801066b8 <alltraps>

80106f74 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $63
80106f76:	6a 3f                	push   $0x3f
  jmp alltraps
80106f78:	e9 3b f7 ff ff       	jmp    801066b8 <alltraps>

80106f7d <vector64>:
.globl vector64
vector64:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $64
80106f7f:	6a 40                	push   $0x40
  jmp alltraps
80106f81:	e9 32 f7 ff ff       	jmp    801066b8 <alltraps>

80106f86 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $65
80106f88:	6a 41                	push   $0x41
  jmp alltraps
80106f8a:	e9 29 f7 ff ff       	jmp    801066b8 <alltraps>

80106f8f <vector66>:
.globl vector66
vector66:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $66
80106f91:	6a 42                	push   $0x42
  jmp alltraps
80106f93:	e9 20 f7 ff ff       	jmp    801066b8 <alltraps>

80106f98 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f98:	6a 00                	push   $0x0
  pushl $67
80106f9a:	6a 43                	push   $0x43
  jmp alltraps
80106f9c:	e9 17 f7 ff ff       	jmp    801066b8 <alltraps>

80106fa1 <vector68>:
.globl vector68
vector68:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $68
80106fa3:	6a 44                	push   $0x44
  jmp alltraps
80106fa5:	e9 0e f7 ff ff       	jmp    801066b8 <alltraps>

80106faa <vector69>:
.globl vector69
vector69:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $69
80106fac:	6a 45                	push   $0x45
  jmp alltraps
80106fae:	e9 05 f7 ff ff       	jmp    801066b8 <alltraps>

80106fb3 <vector70>:
.globl vector70
vector70:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $70
80106fb5:	6a 46                	push   $0x46
  jmp alltraps
80106fb7:	e9 fc f6 ff ff       	jmp    801066b8 <alltraps>

80106fbc <vector71>:
.globl vector71
vector71:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $71
80106fbe:	6a 47                	push   $0x47
  jmp alltraps
80106fc0:	e9 f3 f6 ff ff       	jmp    801066b8 <alltraps>

80106fc5 <vector72>:
.globl vector72
vector72:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $72
80106fc7:	6a 48                	push   $0x48
  jmp alltraps
80106fc9:	e9 ea f6 ff ff       	jmp    801066b8 <alltraps>

80106fce <vector73>:
.globl vector73
vector73:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $73
80106fd0:	6a 49                	push   $0x49
  jmp alltraps
80106fd2:	e9 e1 f6 ff ff       	jmp    801066b8 <alltraps>

80106fd7 <vector74>:
.globl vector74
vector74:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $74
80106fd9:	6a 4a                	push   $0x4a
  jmp alltraps
80106fdb:	e9 d8 f6 ff ff       	jmp    801066b8 <alltraps>

80106fe0 <vector75>:
.globl vector75
vector75:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $75
80106fe2:	6a 4b                	push   $0x4b
  jmp alltraps
80106fe4:	e9 cf f6 ff ff       	jmp    801066b8 <alltraps>

80106fe9 <vector76>:
.globl vector76
vector76:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $76
80106feb:	6a 4c                	push   $0x4c
  jmp alltraps
80106fed:	e9 c6 f6 ff ff       	jmp    801066b8 <alltraps>

80106ff2 <vector77>:
.globl vector77
vector77:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $77
80106ff4:	6a 4d                	push   $0x4d
  jmp alltraps
80106ff6:	e9 bd f6 ff ff       	jmp    801066b8 <alltraps>

80106ffb <vector78>:
.globl vector78
vector78:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $78
80106ffd:	6a 4e                	push   $0x4e
  jmp alltraps
80106fff:	e9 b4 f6 ff ff       	jmp    801066b8 <alltraps>

80107004 <vector79>:
.globl vector79
vector79:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $79
80107006:	6a 4f                	push   $0x4f
  jmp alltraps
80107008:	e9 ab f6 ff ff       	jmp    801066b8 <alltraps>

8010700d <vector80>:
.globl vector80
vector80:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $80
8010700f:	6a 50                	push   $0x50
  jmp alltraps
80107011:	e9 a2 f6 ff ff       	jmp    801066b8 <alltraps>

80107016 <vector81>:
.globl vector81
vector81:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $81
80107018:	6a 51                	push   $0x51
  jmp alltraps
8010701a:	e9 99 f6 ff ff       	jmp    801066b8 <alltraps>

8010701f <vector82>:
.globl vector82
vector82:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $82
80107021:	6a 52                	push   $0x52
  jmp alltraps
80107023:	e9 90 f6 ff ff       	jmp    801066b8 <alltraps>

80107028 <vector83>:
.globl vector83
vector83:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $83
8010702a:	6a 53                	push   $0x53
  jmp alltraps
8010702c:	e9 87 f6 ff ff       	jmp    801066b8 <alltraps>

80107031 <vector84>:
.globl vector84
vector84:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $84
80107033:	6a 54                	push   $0x54
  jmp alltraps
80107035:	e9 7e f6 ff ff       	jmp    801066b8 <alltraps>

8010703a <vector85>:
.globl vector85
vector85:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $85
8010703c:	6a 55                	push   $0x55
  jmp alltraps
8010703e:	e9 75 f6 ff ff       	jmp    801066b8 <alltraps>

80107043 <vector86>:
.globl vector86
vector86:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $86
80107045:	6a 56                	push   $0x56
  jmp alltraps
80107047:	e9 6c f6 ff ff       	jmp    801066b8 <alltraps>

8010704c <vector87>:
.globl vector87
vector87:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $87
8010704e:	6a 57                	push   $0x57
  jmp alltraps
80107050:	e9 63 f6 ff ff       	jmp    801066b8 <alltraps>

80107055 <vector88>:
.globl vector88
vector88:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $88
80107057:	6a 58                	push   $0x58
  jmp alltraps
80107059:	e9 5a f6 ff ff       	jmp    801066b8 <alltraps>

8010705e <vector89>:
.globl vector89
vector89:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $89
80107060:	6a 59                	push   $0x59
  jmp alltraps
80107062:	e9 51 f6 ff ff       	jmp    801066b8 <alltraps>

80107067 <vector90>:
.globl vector90
vector90:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $90
80107069:	6a 5a                	push   $0x5a
  jmp alltraps
8010706b:	e9 48 f6 ff ff       	jmp    801066b8 <alltraps>

80107070 <vector91>:
.globl vector91
vector91:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $91
80107072:	6a 5b                	push   $0x5b
  jmp alltraps
80107074:	e9 3f f6 ff ff       	jmp    801066b8 <alltraps>

80107079 <vector92>:
.globl vector92
vector92:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $92
8010707b:	6a 5c                	push   $0x5c
  jmp alltraps
8010707d:	e9 36 f6 ff ff       	jmp    801066b8 <alltraps>

80107082 <vector93>:
.globl vector93
vector93:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $93
80107084:	6a 5d                	push   $0x5d
  jmp alltraps
80107086:	e9 2d f6 ff ff       	jmp    801066b8 <alltraps>

8010708b <vector94>:
.globl vector94
vector94:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $94
8010708d:	6a 5e                	push   $0x5e
  jmp alltraps
8010708f:	e9 24 f6 ff ff       	jmp    801066b8 <alltraps>

80107094 <vector95>:
.globl vector95
vector95:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $95
80107096:	6a 5f                	push   $0x5f
  jmp alltraps
80107098:	e9 1b f6 ff ff       	jmp    801066b8 <alltraps>

8010709d <vector96>:
.globl vector96
vector96:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $96
8010709f:	6a 60                	push   $0x60
  jmp alltraps
801070a1:	e9 12 f6 ff ff       	jmp    801066b8 <alltraps>

801070a6 <vector97>:
.globl vector97
vector97:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $97
801070a8:	6a 61                	push   $0x61
  jmp alltraps
801070aa:	e9 09 f6 ff ff       	jmp    801066b8 <alltraps>

801070af <vector98>:
.globl vector98
vector98:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $98
801070b1:	6a 62                	push   $0x62
  jmp alltraps
801070b3:	e9 00 f6 ff ff       	jmp    801066b8 <alltraps>

801070b8 <vector99>:
.globl vector99
vector99:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $99
801070ba:	6a 63                	push   $0x63
  jmp alltraps
801070bc:	e9 f7 f5 ff ff       	jmp    801066b8 <alltraps>

801070c1 <vector100>:
.globl vector100
vector100:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $100
801070c3:	6a 64                	push   $0x64
  jmp alltraps
801070c5:	e9 ee f5 ff ff       	jmp    801066b8 <alltraps>

801070ca <vector101>:
.globl vector101
vector101:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $101
801070cc:	6a 65                	push   $0x65
  jmp alltraps
801070ce:	e9 e5 f5 ff ff       	jmp    801066b8 <alltraps>

801070d3 <vector102>:
.globl vector102
vector102:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $102
801070d5:	6a 66                	push   $0x66
  jmp alltraps
801070d7:	e9 dc f5 ff ff       	jmp    801066b8 <alltraps>

801070dc <vector103>:
.globl vector103
vector103:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $103
801070de:	6a 67                	push   $0x67
  jmp alltraps
801070e0:	e9 d3 f5 ff ff       	jmp    801066b8 <alltraps>

801070e5 <vector104>:
.globl vector104
vector104:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $104
801070e7:	6a 68                	push   $0x68
  jmp alltraps
801070e9:	e9 ca f5 ff ff       	jmp    801066b8 <alltraps>

801070ee <vector105>:
.globl vector105
vector105:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $105
801070f0:	6a 69                	push   $0x69
  jmp alltraps
801070f2:	e9 c1 f5 ff ff       	jmp    801066b8 <alltraps>

801070f7 <vector106>:
.globl vector106
vector106:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $106
801070f9:	6a 6a                	push   $0x6a
  jmp alltraps
801070fb:	e9 b8 f5 ff ff       	jmp    801066b8 <alltraps>

80107100 <vector107>:
.globl vector107
vector107:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $107
80107102:	6a 6b                	push   $0x6b
  jmp alltraps
80107104:	e9 af f5 ff ff       	jmp    801066b8 <alltraps>

80107109 <vector108>:
.globl vector108
vector108:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $108
8010710b:	6a 6c                	push   $0x6c
  jmp alltraps
8010710d:	e9 a6 f5 ff ff       	jmp    801066b8 <alltraps>

80107112 <vector109>:
.globl vector109
vector109:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $109
80107114:	6a 6d                	push   $0x6d
  jmp alltraps
80107116:	e9 9d f5 ff ff       	jmp    801066b8 <alltraps>

8010711b <vector110>:
.globl vector110
vector110:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $110
8010711d:	6a 6e                	push   $0x6e
  jmp alltraps
8010711f:	e9 94 f5 ff ff       	jmp    801066b8 <alltraps>

80107124 <vector111>:
.globl vector111
vector111:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $111
80107126:	6a 6f                	push   $0x6f
  jmp alltraps
80107128:	e9 8b f5 ff ff       	jmp    801066b8 <alltraps>

8010712d <vector112>:
.globl vector112
vector112:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $112
8010712f:	6a 70                	push   $0x70
  jmp alltraps
80107131:	e9 82 f5 ff ff       	jmp    801066b8 <alltraps>

80107136 <vector113>:
.globl vector113
vector113:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $113
80107138:	6a 71                	push   $0x71
  jmp alltraps
8010713a:	e9 79 f5 ff ff       	jmp    801066b8 <alltraps>

8010713f <vector114>:
.globl vector114
vector114:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $114
80107141:	6a 72                	push   $0x72
  jmp alltraps
80107143:	e9 70 f5 ff ff       	jmp    801066b8 <alltraps>

80107148 <vector115>:
.globl vector115
vector115:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $115
8010714a:	6a 73                	push   $0x73
  jmp alltraps
8010714c:	e9 67 f5 ff ff       	jmp    801066b8 <alltraps>

80107151 <vector116>:
.globl vector116
vector116:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $116
80107153:	6a 74                	push   $0x74
  jmp alltraps
80107155:	e9 5e f5 ff ff       	jmp    801066b8 <alltraps>

8010715a <vector117>:
.globl vector117
vector117:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $117
8010715c:	6a 75                	push   $0x75
  jmp alltraps
8010715e:	e9 55 f5 ff ff       	jmp    801066b8 <alltraps>

80107163 <vector118>:
.globl vector118
vector118:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $118
80107165:	6a 76                	push   $0x76
  jmp alltraps
80107167:	e9 4c f5 ff ff       	jmp    801066b8 <alltraps>

8010716c <vector119>:
.globl vector119
vector119:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $119
8010716e:	6a 77                	push   $0x77
  jmp alltraps
80107170:	e9 43 f5 ff ff       	jmp    801066b8 <alltraps>

80107175 <vector120>:
.globl vector120
vector120:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $120
80107177:	6a 78                	push   $0x78
  jmp alltraps
80107179:	e9 3a f5 ff ff       	jmp    801066b8 <alltraps>

8010717e <vector121>:
.globl vector121
vector121:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $121
80107180:	6a 79                	push   $0x79
  jmp alltraps
80107182:	e9 31 f5 ff ff       	jmp    801066b8 <alltraps>

80107187 <vector122>:
.globl vector122
vector122:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $122
80107189:	6a 7a                	push   $0x7a
  jmp alltraps
8010718b:	e9 28 f5 ff ff       	jmp    801066b8 <alltraps>

80107190 <vector123>:
.globl vector123
vector123:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $123
80107192:	6a 7b                	push   $0x7b
  jmp alltraps
80107194:	e9 1f f5 ff ff       	jmp    801066b8 <alltraps>

80107199 <vector124>:
.globl vector124
vector124:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $124
8010719b:	6a 7c                	push   $0x7c
  jmp alltraps
8010719d:	e9 16 f5 ff ff       	jmp    801066b8 <alltraps>

801071a2 <vector125>:
.globl vector125
vector125:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $125
801071a4:	6a 7d                	push   $0x7d
  jmp alltraps
801071a6:	e9 0d f5 ff ff       	jmp    801066b8 <alltraps>

801071ab <vector126>:
.globl vector126
vector126:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $126
801071ad:	6a 7e                	push   $0x7e
  jmp alltraps
801071af:	e9 04 f5 ff ff       	jmp    801066b8 <alltraps>

801071b4 <vector127>:
.globl vector127
vector127:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $127
801071b6:	6a 7f                	push   $0x7f
  jmp alltraps
801071b8:	e9 fb f4 ff ff       	jmp    801066b8 <alltraps>

801071bd <vector128>:
.globl vector128
vector128:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $128
801071bf:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071c4:	e9 ef f4 ff ff       	jmp    801066b8 <alltraps>

801071c9 <vector129>:
.globl vector129
vector129:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $129
801071cb:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071d0:	e9 e3 f4 ff ff       	jmp    801066b8 <alltraps>

801071d5 <vector130>:
.globl vector130
vector130:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $130
801071d7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801071dc:	e9 d7 f4 ff ff       	jmp    801066b8 <alltraps>

801071e1 <vector131>:
.globl vector131
vector131:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $131
801071e3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071e8:	e9 cb f4 ff ff       	jmp    801066b8 <alltraps>

801071ed <vector132>:
.globl vector132
vector132:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $132
801071ef:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071f4:	e9 bf f4 ff ff       	jmp    801066b8 <alltraps>

801071f9 <vector133>:
.globl vector133
vector133:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $133
801071fb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107200:	e9 b3 f4 ff ff       	jmp    801066b8 <alltraps>

80107205 <vector134>:
.globl vector134
vector134:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $134
80107207:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010720c:	e9 a7 f4 ff ff       	jmp    801066b8 <alltraps>

80107211 <vector135>:
.globl vector135
vector135:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $135
80107213:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107218:	e9 9b f4 ff ff       	jmp    801066b8 <alltraps>

8010721d <vector136>:
.globl vector136
vector136:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $136
8010721f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107224:	e9 8f f4 ff ff       	jmp    801066b8 <alltraps>

80107229 <vector137>:
.globl vector137
vector137:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $137
8010722b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107230:	e9 83 f4 ff ff       	jmp    801066b8 <alltraps>

80107235 <vector138>:
.globl vector138
vector138:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $138
80107237:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010723c:	e9 77 f4 ff ff       	jmp    801066b8 <alltraps>

80107241 <vector139>:
.globl vector139
vector139:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $139
80107243:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107248:	e9 6b f4 ff ff       	jmp    801066b8 <alltraps>

8010724d <vector140>:
.globl vector140
vector140:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $140
8010724f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107254:	e9 5f f4 ff ff       	jmp    801066b8 <alltraps>

80107259 <vector141>:
.globl vector141
vector141:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $141
8010725b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107260:	e9 53 f4 ff ff       	jmp    801066b8 <alltraps>

80107265 <vector142>:
.globl vector142
vector142:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $142
80107267:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010726c:	e9 47 f4 ff ff       	jmp    801066b8 <alltraps>

80107271 <vector143>:
.globl vector143
vector143:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $143
80107273:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107278:	e9 3b f4 ff ff       	jmp    801066b8 <alltraps>

8010727d <vector144>:
.globl vector144
vector144:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $144
8010727f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107284:	e9 2f f4 ff ff       	jmp    801066b8 <alltraps>

80107289 <vector145>:
.globl vector145
vector145:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $145
8010728b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107290:	e9 23 f4 ff ff       	jmp    801066b8 <alltraps>

80107295 <vector146>:
.globl vector146
vector146:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $146
80107297:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010729c:	e9 17 f4 ff ff       	jmp    801066b8 <alltraps>

801072a1 <vector147>:
.globl vector147
vector147:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $147
801072a3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072a8:	e9 0b f4 ff ff       	jmp    801066b8 <alltraps>

801072ad <vector148>:
.globl vector148
vector148:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $148
801072af:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072b4:	e9 ff f3 ff ff       	jmp    801066b8 <alltraps>

801072b9 <vector149>:
.globl vector149
vector149:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $149
801072bb:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072c0:	e9 f3 f3 ff ff       	jmp    801066b8 <alltraps>

801072c5 <vector150>:
.globl vector150
vector150:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $150
801072c7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072cc:	e9 e7 f3 ff ff       	jmp    801066b8 <alltraps>

801072d1 <vector151>:
.globl vector151
vector151:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $151
801072d3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801072d8:	e9 db f3 ff ff       	jmp    801066b8 <alltraps>

801072dd <vector152>:
.globl vector152
vector152:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $152
801072df:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072e4:	e9 cf f3 ff ff       	jmp    801066b8 <alltraps>

801072e9 <vector153>:
.globl vector153
vector153:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $153
801072eb:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072f0:	e9 c3 f3 ff ff       	jmp    801066b8 <alltraps>

801072f5 <vector154>:
.globl vector154
vector154:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $154
801072f7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072fc:	e9 b7 f3 ff ff       	jmp    801066b8 <alltraps>

80107301 <vector155>:
.globl vector155
vector155:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $155
80107303:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107308:	e9 ab f3 ff ff       	jmp    801066b8 <alltraps>

8010730d <vector156>:
.globl vector156
vector156:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $156
8010730f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107314:	e9 9f f3 ff ff       	jmp    801066b8 <alltraps>

80107319 <vector157>:
.globl vector157
vector157:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $157
8010731b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107320:	e9 93 f3 ff ff       	jmp    801066b8 <alltraps>

80107325 <vector158>:
.globl vector158
vector158:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $158
80107327:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010732c:	e9 87 f3 ff ff       	jmp    801066b8 <alltraps>

80107331 <vector159>:
.globl vector159
vector159:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $159
80107333:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107338:	e9 7b f3 ff ff       	jmp    801066b8 <alltraps>

8010733d <vector160>:
.globl vector160
vector160:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $160
8010733f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107344:	e9 6f f3 ff ff       	jmp    801066b8 <alltraps>

80107349 <vector161>:
.globl vector161
vector161:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $161
8010734b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107350:	e9 63 f3 ff ff       	jmp    801066b8 <alltraps>

80107355 <vector162>:
.globl vector162
vector162:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $162
80107357:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010735c:	e9 57 f3 ff ff       	jmp    801066b8 <alltraps>

80107361 <vector163>:
.globl vector163
vector163:
  pushl $0
80107361:	6a 00                	push   $0x0
  pushl $163
80107363:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107368:	e9 4b f3 ff ff       	jmp    801066b8 <alltraps>

8010736d <vector164>:
.globl vector164
vector164:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $164
8010736f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107374:	e9 3f f3 ff ff       	jmp    801066b8 <alltraps>

80107379 <vector165>:
.globl vector165
vector165:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $165
8010737b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107380:	e9 33 f3 ff ff       	jmp    801066b8 <alltraps>

80107385 <vector166>:
.globl vector166
vector166:
  pushl $0
80107385:	6a 00                	push   $0x0
  pushl $166
80107387:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010738c:	e9 27 f3 ff ff       	jmp    801066b8 <alltraps>

80107391 <vector167>:
.globl vector167
vector167:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $167
80107393:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107398:	e9 1b f3 ff ff       	jmp    801066b8 <alltraps>

8010739d <vector168>:
.globl vector168
vector168:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $168
8010739f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073a4:	e9 0f f3 ff ff       	jmp    801066b8 <alltraps>

801073a9 <vector169>:
.globl vector169
vector169:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $169
801073ab:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073b0:	e9 03 f3 ff ff       	jmp    801066b8 <alltraps>

801073b5 <vector170>:
.globl vector170
vector170:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $170
801073b7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073bc:	e9 f7 f2 ff ff       	jmp    801066b8 <alltraps>

801073c1 <vector171>:
.globl vector171
vector171:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $171
801073c3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073c8:	e9 eb f2 ff ff       	jmp    801066b8 <alltraps>

801073cd <vector172>:
.globl vector172
vector172:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $172
801073cf:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801073d4:	e9 df f2 ff ff       	jmp    801066b8 <alltraps>

801073d9 <vector173>:
.globl vector173
vector173:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $173
801073db:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801073e0:	e9 d3 f2 ff ff       	jmp    801066b8 <alltraps>

801073e5 <vector174>:
.globl vector174
vector174:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $174
801073e7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073ec:	e9 c7 f2 ff ff       	jmp    801066b8 <alltraps>

801073f1 <vector175>:
.globl vector175
vector175:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $175
801073f3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801073f8:	e9 bb f2 ff ff       	jmp    801066b8 <alltraps>

801073fd <vector176>:
.globl vector176
vector176:
  pushl $0
801073fd:	6a 00                	push   $0x0
  pushl $176
801073ff:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107404:	e9 af f2 ff ff       	jmp    801066b8 <alltraps>

80107409 <vector177>:
.globl vector177
vector177:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $177
8010740b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107410:	e9 a3 f2 ff ff       	jmp    801066b8 <alltraps>

80107415 <vector178>:
.globl vector178
vector178:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $178
80107417:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010741c:	e9 97 f2 ff ff       	jmp    801066b8 <alltraps>

80107421 <vector179>:
.globl vector179
vector179:
  pushl $0
80107421:	6a 00                	push   $0x0
  pushl $179
80107423:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107428:	e9 8b f2 ff ff       	jmp    801066b8 <alltraps>

8010742d <vector180>:
.globl vector180
vector180:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $180
8010742f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107434:	e9 7f f2 ff ff       	jmp    801066b8 <alltraps>

80107439 <vector181>:
.globl vector181
vector181:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $181
8010743b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107440:	e9 73 f2 ff ff       	jmp    801066b8 <alltraps>

80107445 <vector182>:
.globl vector182
vector182:
  pushl $0
80107445:	6a 00                	push   $0x0
  pushl $182
80107447:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010744c:	e9 67 f2 ff ff       	jmp    801066b8 <alltraps>

80107451 <vector183>:
.globl vector183
vector183:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $183
80107453:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107458:	e9 5b f2 ff ff       	jmp    801066b8 <alltraps>

8010745d <vector184>:
.globl vector184
vector184:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $184
8010745f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107464:	e9 4f f2 ff ff       	jmp    801066b8 <alltraps>

80107469 <vector185>:
.globl vector185
vector185:
  pushl $0
80107469:	6a 00                	push   $0x0
  pushl $185
8010746b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107470:	e9 43 f2 ff ff       	jmp    801066b8 <alltraps>

80107475 <vector186>:
.globl vector186
vector186:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $186
80107477:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010747c:	e9 37 f2 ff ff       	jmp    801066b8 <alltraps>

80107481 <vector187>:
.globl vector187
vector187:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $187
80107483:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107488:	e9 2b f2 ff ff       	jmp    801066b8 <alltraps>

8010748d <vector188>:
.globl vector188
vector188:
  pushl $0
8010748d:	6a 00                	push   $0x0
  pushl $188
8010748f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107494:	e9 1f f2 ff ff       	jmp    801066b8 <alltraps>

80107499 <vector189>:
.globl vector189
vector189:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $189
8010749b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074a0:	e9 13 f2 ff ff       	jmp    801066b8 <alltraps>

801074a5 <vector190>:
.globl vector190
vector190:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $190
801074a7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074ac:	e9 07 f2 ff ff       	jmp    801066b8 <alltraps>

801074b1 <vector191>:
.globl vector191
vector191:
  pushl $0
801074b1:	6a 00                	push   $0x0
  pushl $191
801074b3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074b8:	e9 fb f1 ff ff       	jmp    801066b8 <alltraps>

801074bd <vector192>:
.globl vector192
vector192:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $192
801074bf:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074c4:	e9 ef f1 ff ff       	jmp    801066b8 <alltraps>

801074c9 <vector193>:
.globl vector193
vector193:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $193
801074cb:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074d0:	e9 e3 f1 ff ff       	jmp    801066b8 <alltraps>

801074d5 <vector194>:
.globl vector194
vector194:
  pushl $0
801074d5:	6a 00                	push   $0x0
  pushl $194
801074d7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801074dc:	e9 d7 f1 ff ff       	jmp    801066b8 <alltraps>

801074e1 <vector195>:
.globl vector195
vector195:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $195
801074e3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074e8:	e9 cb f1 ff ff       	jmp    801066b8 <alltraps>

801074ed <vector196>:
.globl vector196
vector196:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $196
801074ef:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074f4:	e9 bf f1 ff ff       	jmp    801066b8 <alltraps>

801074f9 <vector197>:
.globl vector197
vector197:
  pushl $0
801074f9:	6a 00                	push   $0x0
  pushl $197
801074fb:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107500:	e9 b3 f1 ff ff       	jmp    801066b8 <alltraps>

80107505 <vector198>:
.globl vector198
vector198:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $198
80107507:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010750c:	e9 a7 f1 ff ff       	jmp    801066b8 <alltraps>

80107511 <vector199>:
.globl vector199
vector199:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $199
80107513:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107518:	e9 9b f1 ff ff       	jmp    801066b8 <alltraps>

8010751d <vector200>:
.globl vector200
vector200:
  pushl $0
8010751d:	6a 00                	push   $0x0
  pushl $200
8010751f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107524:	e9 8f f1 ff ff       	jmp    801066b8 <alltraps>

80107529 <vector201>:
.globl vector201
vector201:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $201
8010752b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107530:	e9 83 f1 ff ff       	jmp    801066b8 <alltraps>

80107535 <vector202>:
.globl vector202
vector202:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $202
80107537:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010753c:	e9 77 f1 ff ff       	jmp    801066b8 <alltraps>

80107541 <vector203>:
.globl vector203
vector203:
  pushl $0
80107541:	6a 00                	push   $0x0
  pushl $203
80107543:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107548:	e9 6b f1 ff ff       	jmp    801066b8 <alltraps>

8010754d <vector204>:
.globl vector204
vector204:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $204
8010754f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107554:	e9 5f f1 ff ff       	jmp    801066b8 <alltraps>

80107559 <vector205>:
.globl vector205
vector205:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $205
8010755b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107560:	e9 53 f1 ff ff       	jmp    801066b8 <alltraps>

80107565 <vector206>:
.globl vector206
vector206:
  pushl $0
80107565:	6a 00                	push   $0x0
  pushl $206
80107567:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010756c:	e9 47 f1 ff ff       	jmp    801066b8 <alltraps>

80107571 <vector207>:
.globl vector207
vector207:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $207
80107573:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107578:	e9 3b f1 ff ff       	jmp    801066b8 <alltraps>

8010757d <vector208>:
.globl vector208
vector208:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $208
8010757f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107584:	e9 2f f1 ff ff       	jmp    801066b8 <alltraps>

80107589 <vector209>:
.globl vector209
vector209:
  pushl $0
80107589:	6a 00                	push   $0x0
  pushl $209
8010758b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107590:	e9 23 f1 ff ff       	jmp    801066b8 <alltraps>

80107595 <vector210>:
.globl vector210
vector210:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $210
80107597:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010759c:	e9 17 f1 ff ff       	jmp    801066b8 <alltraps>

801075a1 <vector211>:
.globl vector211
vector211:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $211
801075a3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075a8:	e9 0b f1 ff ff       	jmp    801066b8 <alltraps>

801075ad <vector212>:
.globl vector212
vector212:
  pushl $0
801075ad:	6a 00                	push   $0x0
  pushl $212
801075af:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075b4:	e9 ff f0 ff ff       	jmp    801066b8 <alltraps>

801075b9 <vector213>:
.globl vector213
vector213:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $213
801075bb:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075c0:	e9 f3 f0 ff ff       	jmp    801066b8 <alltraps>

801075c5 <vector214>:
.globl vector214
vector214:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $214
801075c7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075cc:	e9 e7 f0 ff ff       	jmp    801066b8 <alltraps>

801075d1 <vector215>:
.globl vector215
vector215:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $215
801075d3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801075d8:	e9 db f0 ff ff       	jmp    801066b8 <alltraps>

801075dd <vector216>:
.globl vector216
vector216:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $216
801075df:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075e4:	e9 cf f0 ff ff       	jmp    801066b8 <alltraps>

801075e9 <vector217>:
.globl vector217
vector217:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $217
801075eb:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075f0:	e9 c3 f0 ff ff       	jmp    801066b8 <alltraps>

801075f5 <vector218>:
.globl vector218
vector218:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $218
801075f7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075fc:	e9 b7 f0 ff ff       	jmp    801066b8 <alltraps>

80107601 <vector219>:
.globl vector219
vector219:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $219
80107603:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107608:	e9 ab f0 ff ff       	jmp    801066b8 <alltraps>

8010760d <vector220>:
.globl vector220
vector220:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $220
8010760f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107614:	e9 9f f0 ff ff       	jmp    801066b8 <alltraps>

80107619 <vector221>:
.globl vector221
vector221:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $221
8010761b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107620:	e9 93 f0 ff ff       	jmp    801066b8 <alltraps>

80107625 <vector222>:
.globl vector222
vector222:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $222
80107627:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010762c:	e9 87 f0 ff ff       	jmp    801066b8 <alltraps>

80107631 <vector223>:
.globl vector223
vector223:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $223
80107633:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107638:	e9 7b f0 ff ff       	jmp    801066b8 <alltraps>

8010763d <vector224>:
.globl vector224
vector224:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $224
8010763f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107644:	e9 6f f0 ff ff       	jmp    801066b8 <alltraps>

80107649 <vector225>:
.globl vector225
vector225:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $225
8010764b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107650:	e9 63 f0 ff ff       	jmp    801066b8 <alltraps>

80107655 <vector226>:
.globl vector226
vector226:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $226
80107657:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010765c:	e9 57 f0 ff ff       	jmp    801066b8 <alltraps>

80107661 <vector227>:
.globl vector227
vector227:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $227
80107663:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107668:	e9 4b f0 ff ff       	jmp    801066b8 <alltraps>

8010766d <vector228>:
.globl vector228
vector228:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $228
8010766f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107674:	e9 3f f0 ff ff       	jmp    801066b8 <alltraps>

80107679 <vector229>:
.globl vector229
vector229:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $229
8010767b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107680:	e9 33 f0 ff ff       	jmp    801066b8 <alltraps>

80107685 <vector230>:
.globl vector230
vector230:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $230
80107687:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010768c:	e9 27 f0 ff ff       	jmp    801066b8 <alltraps>

80107691 <vector231>:
.globl vector231
vector231:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $231
80107693:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107698:	e9 1b f0 ff ff       	jmp    801066b8 <alltraps>

8010769d <vector232>:
.globl vector232
vector232:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $232
8010769f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076a4:	e9 0f f0 ff ff       	jmp    801066b8 <alltraps>

801076a9 <vector233>:
.globl vector233
vector233:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $233
801076ab:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076b0:	e9 03 f0 ff ff       	jmp    801066b8 <alltraps>

801076b5 <vector234>:
.globl vector234
vector234:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $234
801076b7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076bc:	e9 f7 ef ff ff       	jmp    801066b8 <alltraps>

801076c1 <vector235>:
.globl vector235
vector235:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $235
801076c3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076c8:	e9 eb ef ff ff       	jmp    801066b8 <alltraps>

801076cd <vector236>:
.globl vector236
vector236:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $236
801076cf:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801076d4:	e9 df ef ff ff       	jmp    801066b8 <alltraps>

801076d9 <vector237>:
.globl vector237
vector237:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $237
801076db:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801076e0:	e9 d3 ef ff ff       	jmp    801066b8 <alltraps>

801076e5 <vector238>:
.globl vector238
vector238:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $238
801076e7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076ec:	e9 c7 ef ff ff       	jmp    801066b8 <alltraps>

801076f1 <vector239>:
.globl vector239
vector239:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $239
801076f3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801076f8:	e9 bb ef ff ff       	jmp    801066b8 <alltraps>

801076fd <vector240>:
.globl vector240
vector240:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $240
801076ff:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107704:	e9 af ef ff ff       	jmp    801066b8 <alltraps>

80107709 <vector241>:
.globl vector241
vector241:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $241
8010770b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107710:	e9 a3 ef ff ff       	jmp    801066b8 <alltraps>

80107715 <vector242>:
.globl vector242
vector242:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $242
80107717:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010771c:	e9 97 ef ff ff       	jmp    801066b8 <alltraps>

80107721 <vector243>:
.globl vector243
vector243:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $243
80107723:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107728:	e9 8b ef ff ff       	jmp    801066b8 <alltraps>

8010772d <vector244>:
.globl vector244
vector244:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $244
8010772f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107734:	e9 7f ef ff ff       	jmp    801066b8 <alltraps>

80107739 <vector245>:
.globl vector245
vector245:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $245
8010773b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107740:	e9 73 ef ff ff       	jmp    801066b8 <alltraps>

80107745 <vector246>:
.globl vector246
vector246:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $246
80107747:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010774c:	e9 67 ef ff ff       	jmp    801066b8 <alltraps>

80107751 <vector247>:
.globl vector247
vector247:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $247
80107753:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107758:	e9 5b ef ff ff       	jmp    801066b8 <alltraps>

8010775d <vector248>:
.globl vector248
vector248:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $248
8010775f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107764:	e9 4f ef ff ff       	jmp    801066b8 <alltraps>

80107769 <vector249>:
.globl vector249
vector249:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $249
8010776b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107770:	e9 43 ef ff ff       	jmp    801066b8 <alltraps>

80107775 <vector250>:
.globl vector250
vector250:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $250
80107777:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010777c:	e9 37 ef ff ff       	jmp    801066b8 <alltraps>

80107781 <vector251>:
.globl vector251
vector251:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $251
80107783:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107788:	e9 2b ef ff ff       	jmp    801066b8 <alltraps>

8010778d <vector252>:
.globl vector252
vector252:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $252
8010778f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107794:	e9 1f ef ff ff       	jmp    801066b8 <alltraps>

80107799 <vector253>:
.globl vector253
vector253:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $253
8010779b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077a0:	e9 13 ef ff ff       	jmp    801066b8 <alltraps>

801077a5 <vector254>:
.globl vector254
vector254:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $254
801077a7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077ac:	e9 07 ef ff ff       	jmp    801066b8 <alltraps>

801077b1 <vector255>:
.globl vector255
vector255:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $255
801077b3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077b8:	e9 fb ee ff ff       	jmp    801066b8 <alltraps>

801077bd <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801077bd:	55                   	push   %ebp
801077be:	89 e5                	mov    %esp,%ebp
801077c0:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801077c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801077c6:	83 e8 01             	sub    $0x1,%eax
801077c9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077cd:	8b 45 08             	mov    0x8(%ebp),%eax
801077d0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801077d4:	8b 45 08             	mov    0x8(%ebp),%eax
801077d7:	c1 e8 10             	shr    $0x10,%eax
801077da:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801077de:	8d 45 fa             	lea    -0x6(%ebp),%eax
801077e1:	0f 01 10             	lgdtl  (%eax)
}
801077e4:	90                   	nop
801077e5:	c9                   	leave  
801077e6:	c3                   	ret    

801077e7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801077e7:	55                   	push   %ebp
801077e8:	89 e5                	mov    %esp,%ebp
801077ea:	83 ec 04             	sub    $0x4,%esp
801077ed:	8b 45 08             	mov    0x8(%ebp),%eax
801077f0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077f4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077f8:	0f 00 d8             	ltr    %ax
}
801077fb:	90                   	nop
801077fc:	c9                   	leave  
801077fd:	c3                   	ret    

801077fe <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801077fe:	55                   	push   %ebp
801077ff:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107801:	8b 45 08             	mov    0x8(%ebp),%eax
80107804:	0f 22 d8             	mov    %eax,%cr3
}
80107807:	90                   	nop
80107808:	5d                   	pop    %ebp
80107809:	c3                   	ret    

8010780a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010780a:	55                   	push   %ebp
8010780b:	89 e5                	mov    %esp,%ebp
8010780d:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107810:	e8 72 ca ff ff       	call   80104287 <cpuid>
80107815:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010781b:	05 00 38 11 80       	add    $0x80113800,%eax
80107820:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107826:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010783c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107843:	83 e2 f0             	and    $0xfffffff0,%edx
80107846:	83 ca 0a             	or     $0xa,%edx
80107849:	88 50 7d             	mov    %dl,0x7d(%eax)
8010784c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107853:	83 ca 10             	or     $0x10,%edx
80107856:	88 50 7d             	mov    %dl,0x7d(%eax)
80107859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107860:	83 e2 9f             	and    $0xffffff9f,%edx
80107863:	88 50 7d             	mov    %dl,0x7d(%eax)
80107866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107869:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010786d:	83 ca 80             	or     $0xffffff80,%edx
80107870:	88 50 7d             	mov    %dl,0x7d(%eax)
80107873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107876:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010787a:	83 ca 0f             	or     $0xf,%edx
8010787d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107883:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107887:	83 e2 ef             	and    $0xffffffef,%edx
8010788a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010788d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107890:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107894:	83 e2 df             	and    $0xffffffdf,%edx
80107897:	88 50 7e             	mov    %dl,0x7e(%eax)
8010789a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078a1:	83 ca 40             	or     $0x40,%edx
801078a4:	88 50 7e             	mov    %dl,0x7e(%eax)
801078a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078aa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078ae:	83 ca 80             	or     $0xffffff80,%edx
801078b1:	88 50 7e             	mov    %dl,0x7e(%eax)
801078b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078be:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078c5:	ff ff 
801078c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ca:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078d1:	00 00 
801078d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078e7:	83 e2 f0             	and    $0xfffffff0,%edx
801078ea:	83 ca 02             	or     $0x2,%edx
801078ed:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078fd:	83 ca 10             	or     $0x10,%edx
80107900:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107909:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107910:	83 e2 9f             	and    $0xffffff9f,%edx
80107913:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107923:	83 ca 80             	or     $0xffffff80,%edx
80107926:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010792c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107936:	83 ca 0f             	or     $0xf,%edx
80107939:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010793f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107942:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107949:	83 e2 ef             	and    $0xffffffef,%edx
8010794c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107955:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010795c:	83 e2 df             	and    $0xffffffdf,%edx
8010795f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010796f:	83 ca 40             	or     $0x40,%edx
80107972:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107982:	83 ca 80             	or     $0xffffff80,%edx
80107985:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010798b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107998:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010799f:	ff ff 
801079a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a4:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801079ab:	00 00 
801079ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b0:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079c1:	83 e2 f0             	and    $0xfffffff0,%edx
801079c4:	83 ca 0a             	or     $0xa,%edx
801079c7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079d7:	83 ca 10             	or     $0x10,%edx
801079da:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079ea:	83 ca 60             	or     $0x60,%edx
801079ed:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079fd:	83 ca 80             	or     $0xffffff80,%edx
80107a00:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a09:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a10:	83 ca 0f             	or     $0xf,%edx
80107a13:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a23:	83 e2 ef             	and    $0xffffffef,%edx
80107a26:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a36:	83 e2 df             	and    $0xffffffdf,%edx
80107a39:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a49:	83 ca 40             	or     $0x40,%edx
80107a4c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a5c:	83 ca 80             	or     $0xffffff80,%edx
80107a5f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a68:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a79:	ff ff 
80107a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a85:	00 00 
80107a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a9b:	83 e2 f0             	and    $0xfffffff0,%edx
80107a9e:	83 ca 02             	or     $0x2,%edx
80107aa1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaa:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ab1:	83 ca 10             	or     $0x10,%edx
80107ab4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ac4:	83 ca 60             	or     $0x60,%edx
80107ac7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ad7:	83 ca 80             	or     $0xffffff80,%edx
80107ada:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107aea:	83 ca 0f             	or     $0xf,%edx
80107aed:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107afd:	83 e2 ef             	and    $0xffffffef,%edx
80107b00:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b09:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b10:	83 e2 df             	and    $0xffffffdf,%edx
80107b13:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b23:	83 ca 40             	or     $0x40,%edx
80107b26:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b36:	83 ca 80             	or     $0xffffff80,%edx
80107b39:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b42:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	83 c0 70             	add    $0x70,%eax
80107b4f:	83 ec 08             	sub    $0x8,%esp
80107b52:	6a 30                	push   $0x30
80107b54:	50                   	push   %eax
80107b55:	e8 63 fc ff ff       	call   801077bd <lgdt>
80107b5a:	83 c4 10             	add    $0x10,%esp
}
80107b5d:	90                   	nop
80107b5e:	c9                   	leave  
80107b5f:	c3                   	ret    

80107b60 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b60:	55                   	push   %ebp
80107b61:	89 e5                	mov    %esp,%ebp
80107b63:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b66:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b69:	c1 e8 16             	shr    $0x16,%eax
80107b6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b73:	8b 45 08             	mov    0x8(%ebp),%eax
80107b76:	01 d0                	add    %edx,%eax
80107b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7e:	8b 00                	mov    (%eax),%eax
80107b80:	83 e0 01             	and    $0x1,%eax
80107b83:	85 c0                	test   %eax,%eax
80107b85:	74 14                	je     80107b9b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b8a:	8b 00                	mov    (%eax),%eax
80107b8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b91:	05 00 00 00 80       	add    $0x80000000,%eax
80107b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b99:	eb 42                	jmp    80107bdd <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b9f:	74 0e                	je     80107baf <walkpgdir+0x4f>
80107ba1:	e8 82 b1 ff ff       	call   80102d28 <kalloc>
80107ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ba9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bad:	75 07                	jne    80107bb6 <walkpgdir+0x56>
      return 0;
80107baf:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb4:	eb 3e                	jmp    80107bf4 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107bb6:	83 ec 04             	sub    $0x4,%esp
80107bb9:	68 00 10 00 00       	push   $0x1000
80107bbe:	6a 00                	push   $0x0
80107bc0:	ff 75 f4             	pushl  -0xc(%ebp)
80107bc3:	e8 f2 d6 ff ff       	call   801052ba <memset>
80107bc8:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bce:	05 00 00 00 80       	add    $0x80000000,%eax
80107bd3:	83 c8 07             	or     $0x7,%eax
80107bd6:	89 c2                	mov    %eax,%edx
80107bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bdb:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be0:	c1 e8 0c             	shr    $0xc,%eax
80107be3:	25 ff 03 00 00       	and    $0x3ff,%eax
80107be8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	01 d0                	add    %edx,%eax
}
80107bf4:	c9                   	leave  
80107bf5:	c3                   	ret    

80107bf6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107bf6:	55                   	push   %ebp
80107bf7:	89 e5                	mov    %esp,%ebp
80107bf9:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
 
//  cprintf("SIZE: %x\n", va);
  a = (char*)PGROUNDDOWN((uint)va);
80107bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c07:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c0a:	8b 45 10             	mov    0x10(%ebp),%eax
80107c0d:	01 d0                	add    %edx,%eax
80107c0f:	83 e8 01             	sub    $0x1,%eax
80107c12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c1a:	83 ec 04             	sub    $0x4,%esp
80107c1d:	6a 01                	push   $0x1
80107c1f:	ff 75 f4             	pushl  -0xc(%ebp)
80107c22:	ff 75 08             	pushl  0x8(%ebp)
80107c25:	e8 36 ff ff ff       	call   80107b60 <walkpgdir>
80107c2a:	83 c4 10             	add    $0x10,%esp
80107c2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c30:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c34:	75 07                	jne    80107c3d <mappages+0x47>
      return -1;
80107c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c3b:	eb 47                	jmp    80107c84 <mappages+0x8e>
    if(*pte & PTE_P)
80107c3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c40:	8b 00                	mov    (%eax),%eax
80107c42:	83 e0 01             	and    $0x1,%eax
80107c45:	85 c0                	test   %eax,%eax
80107c47:	74 0d                	je     80107c56 <mappages+0x60>
      panic("remap");
80107c49:	83 ec 0c             	sub    $0xc,%esp
80107c4c:	68 24 8d 10 80       	push   $0x80108d24
80107c51:	e8 4a 89 ff ff       	call   801005a0 <panic>
    *pte = pa | perm | PTE_P;
80107c56:	8b 45 18             	mov    0x18(%ebp),%eax
80107c59:	0b 45 14             	or     0x14(%ebp),%eax
80107c5c:	83 c8 01             	or     $0x1,%eax
80107c5f:	89 c2                	mov    %eax,%edx
80107c61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c64:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c69:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c6c:	74 10                	je     80107c7e <mappages+0x88>
      break;
    a += PGSIZE;
80107c6e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c75:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107c7c:	eb 9c                	jmp    80107c1a <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107c7e:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c84:	c9                   	leave  
80107c85:	c3                   	ret    

80107c86 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c86:	55                   	push   %ebp
80107c87:	89 e5                	mov    %esp,%ebp
80107c89:	53                   	push   %ebx
80107c8a:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107c8d:	e8 96 b0 ff ff       	call   80102d28 <kalloc>
80107c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c99:	75 07                	jne    80107ca2 <setupkvm+0x1c>
    return 0;
80107c9b:	b8 00 00 00 00       	mov    $0x0,%eax
80107ca0:	eb 78                	jmp    80107d1a <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107ca2:	83 ec 04             	sub    $0x4,%esp
80107ca5:	68 00 10 00 00       	push   $0x1000
80107caa:	6a 00                	push   $0x0
80107cac:	ff 75 f0             	pushl  -0x10(%ebp)
80107caf:	e8 06 d6 ff ff       	call   801052ba <memset>
80107cb4:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cb7:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107cbe:	eb 4e                	jmp    80107d0e <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc3:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc9:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccf:	8b 58 08             	mov    0x8(%eax),%ebx
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	8b 40 04             	mov    0x4(%eax),%eax
80107cd8:	29 c3                	sub    %eax,%ebx
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	8b 00                	mov    (%eax),%eax
80107cdf:	83 ec 0c             	sub    $0xc,%esp
80107ce2:	51                   	push   %ecx
80107ce3:	52                   	push   %edx
80107ce4:	53                   	push   %ebx
80107ce5:	50                   	push   %eax
80107ce6:	ff 75 f0             	pushl  -0x10(%ebp)
80107ce9:	e8 08 ff ff ff       	call   80107bf6 <mappages>
80107cee:	83 c4 20             	add    $0x20,%esp
80107cf1:	85 c0                	test   %eax,%eax
80107cf3:	79 15                	jns    80107d0a <setupkvm+0x84>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107cf5:	83 ec 0c             	sub    $0xc,%esp
80107cf8:	ff 75 f0             	pushl  -0x10(%ebp)
80107cfb:	e8 2d 05 00 00       	call   8010822d <freevm>
80107d00:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d03:	b8 00 00 00 00       	mov    $0x0,%eax
80107d08:	eb 10                	jmp    80107d1a <setupkvm+0x94>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d0a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d0e:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107d15:	72 a9                	jb     80107cc0 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d1d:	c9                   	leave  
80107d1e:	c3                   	ret    

80107d1f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d1f:	55                   	push   %ebp
80107d20:	89 e5                	mov    %esp,%ebp
80107d22:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d25:	e8 5c ff ff ff       	call   80107c86 <setupkvm>
80107d2a:	a3 24 67 11 80       	mov    %eax,0x80116724
  switchkvm();
80107d2f:	e8 03 00 00 00       	call   80107d37 <switchkvm>
}
80107d34:	90                   	nop
80107d35:	c9                   	leave  
80107d36:	c3                   	ret    

80107d37 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d37:	55                   	push   %ebp
80107d38:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d3a:	a1 24 67 11 80       	mov    0x80116724,%eax
80107d3f:	05 00 00 00 80       	add    $0x80000000,%eax
80107d44:	50                   	push   %eax
80107d45:	e8 b4 fa ff ff       	call   801077fe <lcr3>
80107d4a:	83 c4 04             	add    $0x4,%esp
}
80107d4d:	90                   	nop
80107d4e:	c9                   	leave  
80107d4f:	c3                   	ret    

80107d50 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d50:	55                   	push   %ebp
80107d51:	89 e5                	mov    %esp,%ebp
80107d53:	56                   	push   %esi
80107d54:	53                   	push   %ebx
80107d55:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107d58:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d5c:	75 0d                	jne    80107d6b <switchuvm+0x1b>
    panic("switchuvm: no process");
80107d5e:	83 ec 0c             	sub    $0xc,%esp
80107d61:	68 2a 8d 10 80       	push   $0x80108d2a
80107d66:	e8 35 88 ff ff       	call   801005a0 <panic>
  if(p->kstack == 0)
80107d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d6e:	8b 40 08             	mov    0x8(%eax),%eax
80107d71:	85 c0                	test   %eax,%eax
80107d73:	75 0d                	jne    80107d82 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107d75:	83 ec 0c             	sub    $0xc,%esp
80107d78:	68 40 8d 10 80       	push   $0x80108d40
80107d7d:	e8 1e 88 ff ff       	call   801005a0 <panic>
  if(p->pgdir == 0)
80107d82:	8b 45 08             	mov    0x8(%ebp),%eax
80107d85:	8b 40 04             	mov    0x4(%eax),%eax
80107d88:	85 c0                	test   %eax,%eax
80107d8a:	75 0d                	jne    80107d99 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107d8c:	83 ec 0c             	sub    $0xc,%esp
80107d8f:	68 55 8d 10 80       	push   $0x80108d55
80107d94:	e8 07 88 ff ff       	call   801005a0 <panic>

  pushcli();
80107d99:	e8 10 d4 ff ff       	call   801051ae <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107d9e:	e8 05 c5 ff ff       	call   801042a8 <mycpu>
80107da3:	89 c3                	mov    %eax,%ebx
80107da5:	e8 fe c4 ff ff       	call   801042a8 <mycpu>
80107daa:	83 c0 08             	add    $0x8,%eax
80107dad:	89 c6                	mov    %eax,%esi
80107daf:	e8 f4 c4 ff ff       	call   801042a8 <mycpu>
80107db4:	83 c0 08             	add    $0x8,%eax
80107db7:	c1 e8 10             	shr    $0x10,%eax
80107dba:	88 45 f7             	mov    %al,-0x9(%ebp)
80107dbd:	e8 e6 c4 ff ff       	call   801042a8 <mycpu>
80107dc2:	83 c0 08             	add    $0x8,%eax
80107dc5:	c1 e8 18             	shr    $0x18,%eax
80107dc8:	89 c2                	mov    %eax,%edx
80107dca:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107dd1:	67 00 
80107dd3:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107dda:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107dde:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107de4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107deb:	83 e0 f0             	and    $0xfffffff0,%eax
80107dee:	83 c8 09             	or     $0x9,%eax
80107df1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107df7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107dfe:	83 c8 10             	or     $0x10,%eax
80107e01:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e07:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e0e:	83 e0 9f             	and    $0xffffff9f,%eax
80107e11:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e17:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e1e:	83 c8 80             	or     $0xffffff80,%eax
80107e21:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e27:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e2e:	83 e0 f0             	and    $0xfffffff0,%eax
80107e31:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e37:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e3e:	83 e0 ef             	and    $0xffffffef,%eax
80107e41:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e47:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e4e:	83 e0 df             	and    $0xffffffdf,%eax
80107e51:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e57:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e5e:	83 c8 40             	or     $0x40,%eax
80107e61:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e67:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e6e:	83 e0 7f             	and    $0x7f,%eax
80107e71:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e77:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107e7d:	e8 26 c4 ff ff       	call   801042a8 <mycpu>
80107e82:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e89:	83 e2 ef             	and    $0xffffffef,%edx
80107e8c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107e92:	e8 11 c4 ff ff       	call   801042a8 <mycpu>
80107e97:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107e9d:	e8 06 c4 ff ff       	call   801042a8 <mycpu>
80107ea2:	89 c2                	mov    %eax,%edx
80107ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea7:	8b 40 08             	mov    0x8(%eax),%eax
80107eaa:	05 00 10 00 00       	add    $0x1000,%eax
80107eaf:	89 42 0c             	mov    %eax,0xc(%edx)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107eb2:	e8 f1 c3 ff ff       	call   801042a8 <mycpu>
80107eb7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107ebd:	83 ec 0c             	sub    $0xc,%esp
80107ec0:	6a 28                	push   $0x28
80107ec2:	e8 20 f9 ff ff       	call   801077e7 <ltr>
80107ec7:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107eca:	8b 45 08             	mov    0x8(%ebp),%eax
80107ecd:	8b 40 04             	mov    0x4(%eax),%eax
80107ed0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ed5:	83 ec 0c             	sub    $0xc,%esp
80107ed8:	50                   	push   %eax
80107ed9:	e8 20 f9 ff ff       	call   801077fe <lcr3>
80107ede:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ee1:	e8 16 d3 ff ff       	call   801051fc <popcli>
}
80107ee6:	90                   	nop
80107ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107eea:	5b                   	pop    %ebx
80107eeb:	5e                   	pop    %esi
80107eec:	5d                   	pop    %ebp
80107eed:	c3                   	ret    

80107eee <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107eee:	55                   	push   %ebp
80107eef:	89 e5                	mov    %esp,%ebp
80107ef1:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ef4:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107efb:	76 0d                	jbe    80107f0a <inituvm+0x1c>
    panic("inituvm: more than a page");
80107efd:	83 ec 0c             	sub    $0xc,%esp
80107f00:	68 69 8d 10 80       	push   $0x80108d69
80107f05:	e8 96 86 ff ff       	call   801005a0 <panic>
  mem = kalloc();
80107f0a:	e8 19 ae ff ff       	call   80102d28 <kalloc>
80107f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f12:	83 ec 04             	sub    $0x4,%esp
80107f15:	68 00 10 00 00       	push   $0x1000
80107f1a:	6a 00                	push   $0x0
80107f1c:	ff 75 f4             	pushl  -0xc(%ebp)
80107f1f:	e8 96 d3 ff ff       	call   801052ba <memset>
80107f24:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f2f:	83 ec 0c             	sub    $0xc,%esp
80107f32:	6a 06                	push   $0x6
80107f34:	50                   	push   %eax
80107f35:	68 00 10 00 00       	push   $0x1000
80107f3a:	6a 00                	push   $0x0
80107f3c:	ff 75 08             	pushl  0x8(%ebp)
80107f3f:	e8 b2 fc ff ff       	call   80107bf6 <mappages>
80107f44:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f47:	83 ec 04             	sub    $0x4,%esp
80107f4a:	ff 75 10             	pushl  0x10(%ebp)
80107f4d:	ff 75 0c             	pushl  0xc(%ebp)
80107f50:	ff 75 f4             	pushl  -0xc(%ebp)
80107f53:	e8 21 d4 ff ff       	call   80105379 <memmove>
80107f58:	83 c4 10             	add    $0x10,%esp
}
80107f5b:	90                   	nop
80107f5c:	c9                   	leave  
80107f5d:	c3                   	ret    

80107f5e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f5e:	55                   	push   %ebp
80107f5f:	89 e5                	mov    %esp,%ebp
80107f61:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f67:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f6c:	85 c0                	test   %eax,%eax
80107f6e:	74 0d                	je     80107f7d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f70:	83 ec 0c             	sub    $0xc,%esp
80107f73:	68 84 8d 10 80       	push   $0x80108d84
80107f78:	e8 23 86 ff ff       	call   801005a0 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f84:	e9 8f 00 00 00       	jmp    80108018 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f89:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8f:	01 d0                	add    %edx,%eax
80107f91:	83 ec 04             	sub    $0x4,%esp
80107f94:	6a 00                	push   $0x0
80107f96:	50                   	push   %eax
80107f97:	ff 75 08             	pushl  0x8(%ebp)
80107f9a:	e8 c1 fb ff ff       	call   80107b60 <walkpgdir>
80107f9f:	83 c4 10             	add    $0x10,%esp
80107fa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fa5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fa9:	75 0d                	jne    80107fb8 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107fab:	83 ec 0c             	sub    $0xc,%esp
80107fae:	68 a7 8d 10 80       	push   $0x80108da7
80107fb3:	e8 e8 85 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80107fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fbb:	8b 00                	mov    (%eax),%eax
80107fbd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107fc5:	8b 45 18             	mov    0x18(%ebp),%eax
80107fc8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fcb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fd0:	77 0b                	ja     80107fdd <loaduvm+0x7f>
      n = sz - i;
80107fd2:	8b 45 18             	mov    0x18(%ebp),%eax
80107fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fdb:	eb 07                	jmp    80107fe4 <loaduvm+0x86>
    else
      n = PGSIZE;
80107fdd:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107fe4:	8b 55 14             	mov    0x14(%ebp),%edx
80107fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fea:	01 d0                	add    %edx,%eax
80107fec:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107fef:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107ff5:	ff 75 f0             	pushl  -0x10(%ebp)
80107ff8:	50                   	push   %eax
80107ff9:	52                   	push   %edx
80107ffa:	ff 75 10             	pushl  0x10(%ebp)
80107ffd:	e8 92 9f ff ff       	call   80101f94 <readi>
80108002:	83 c4 10             	add    $0x10,%esp
80108005:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108008:	74 07                	je     80108011 <loaduvm+0xb3>
      return -1;
8010800a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010800f:	eb 18                	jmp    80108029 <loaduvm+0xcb>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108011:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010801e:	0f 82 65 ff ff ff    	jb     80107f89 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108024:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108029:	c9                   	leave  
8010802a:	c3                   	ret    

8010802b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010802b:	55                   	push   %ebp
8010802c:	89 e5                	mov    %esp,%ebp
8010802e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108031:	8b 45 10             	mov    0x10(%ebp),%eax
80108034:	85 c0                	test   %eax,%eax
80108036:	79 0a                	jns    80108042 <allocuvm+0x17>
    return 0;
80108038:	b8 00 00 00 00       	mov    $0x0,%eax
8010803d:	e9 25 01 00 00       	jmp    80108167 <allocuvm+0x13c>
  if(newsz < oldsz)
80108042:	8b 45 10             	mov    0x10(%ebp),%eax
80108045:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108048:	73 08                	jae    80108052 <allocuvm+0x27>
    return oldsz;
8010804a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010804d:	e9 15 01 00 00       	jmp    80108167 <allocuvm+0x13c>

  a = PGROUNDUP(oldsz);
80108052:	8b 45 0c             	mov    0xc(%ebp),%eax
80108055:	05 ff 0f 00 00       	add    $0xfff,%eax
8010805a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010805f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("A: %x\n", a);
80108062:	83 ec 08             	sub    $0x8,%esp
80108065:	ff 75 f4             	pushl  -0xc(%ebp)
80108068:	68 c5 8d 10 80       	push   $0x80108dc5
8010806d:	e8 8e 83 ff ff       	call   80100400 <cprintf>
80108072:	83 c4 10             	add    $0x10,%esp
  for(; a < newsz; a += PGSIZE){
80108075:	e9 cb 00 00 00       	jmp    80108145 <allocuvm+0x11a>
    mem = kalloc();
8010807a:	e8 a9 ac ff ff       	call   80102d28 <kalloc>
8010807f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108082:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108086:	75 2e                	jne    801080b6 <allocuvm+0x8b>
      cprintf("allocuvm out of memory\n");
80108088:	83 ec 0c             	sub    $0xc,%esp
8010808b:	68 cc 8d 10 80       	push   $0x80108dcc
80108090:	e8 6b 83 ff ff       	call   80100400 <cprintf>
80108095:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108098:	83 ec 04             	sub    $0x4,%esp
8010809b:	ff 75 0c             	pushl  0xc(%ebp)
8010809e:	ff 75 10             	pushl  0x10(%ebp)
801080a1:	ff 75 08             	pushl  0x8(%ebp)
801080a4:	e8 c0 00 00 00       	call   80108169 <deallocuvm>
801080a9:	83 c4 10             	add    $0x10,%esp
      return 0;
801080ac:	b8 00 00 00 00       	mov    $0x0,%eax
801080b1:	e9 b1 00 00 00       	jmp    80108167 <allocuvm+0x13c>
    }
   cprintf("MEM: %x\n", mem);
801080b6:	83 ec 08             	sub    $0x8,%esp
801080b9:	ff 75 f0             	pushl  -0x10(%ebp)
801080bc:	68 e4 8d 10 80       	push   $0x80108de4
801080c1:	e8 3a 83 ff ff       	call   80100400 <cprintf>
801080c6:	83 c4 10             	add    $0x10,%esp
    memset(mem, 0, PGSIZE);
801080c9:	83 ec 04             	sub    $0x4,%esp
801080cc:	68 00 10 00 00       	push   $0x1000
801080d1:	6a 00                	push   $0x0
801080d3:	ff 75 f0             	pushl  -0x10(%ebp)
801080d6:	e8 df d1 ff ff       	call   801052ba <memset>
801080db:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801080de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801080e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ea:	83 ec 0c             	sub    $0xc,%esp
801080ed:	6a 06                	push   $0x6
801080ef:	52                   	push   %edx
801080f0:	68 00 10 00 00       	push   $0x1000
801080f5:	50                   	push   %eax
801080f6:	ff 75 08             	pushl  0x8(%ebp)
801080f9:	e8 f8 fa ff ff       	call   80107bf6 <mappages>
801080fe:	83 c4 20             	add    $0x20,%esp
80108101:	85 c0                	test   %eax,%eax
80108103:	79 39                	jns    8010813e <allocuvm+0x113>
      cprintf("allocuvm out of memory (2)\n");
80108105:	83 ec 0c             	sub    $0xc,%esp
80108108:	68 ed 8d 10 80       	push   $0x80108ded
8010810d:	e8 ee 82 ff ff       	call   80100400 <cprintf>
80108112:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108115:	83 ec 04             	sub    $0x4,%esp
80108118:	ff 75 0c             	pushl  0xc(%ebp)
8010811b:	ff 75 10             	pushl  0x10(%ebp)
8010811e:	ff 75 08             	pushl  0x8(%ebp)
80108121:	e8 43 00 00 00       	call   80108169 <deallocuvm>
80108126:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108129:	83 ec 0c             	sub    $0xc,%esp
8010812c:	ff 75 f0             	pushl  -0x10(%ebp)
8010812f:	e8 5a ab ff ff       	call   80102c8e <kfree>
80108134:	83 c4 10             	add    $0x10,%esp
      return 0;
80108137:	b8 00 00 00 00       	mov    $0x0,%eax
8010813c:	eb 29                	jmp    80108167 <allocuvm+0x13c>
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  cprintf("A: %x\n", a);
  for(; a < newsz; a += PGSIZE){
8010813e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108148:	3b 45 10             	cmp    0x10(%ebp),%eax
8010814b:	0f 82 29 ff ff ff    	jb     8010807a <allocuvm+0x4f>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  cprintf("TOPPAGE: %x\n", newsz);
80108151:	83 ec 08             	sub    $0x8,%esp
80108154:	ff 75 10             	pushl  0x10(%ebp)
80108157:	68 09 8e 10 80       	push   $0x80108e09
8010815c:	e8 9f 82 ff ff       	call   80100400 <cprintf>
80108161:	83 c4 10             	add    $0x10,%esp
  return newsz;
80108164:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108167:	c9                   	leave  
80108168:	c3                   	ret    

80108169 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108169:	55                   	push   %ebp
8010816a:	89 e5                	mov    %esp,%ebp
8010816c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010816f:	8b 45 10             	mov    0x10(%ebp),%eax
80108172:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108175:	72 08                	jb     8010817f <deallocuvm+0x16>
    return oldsz;
80108177:	8b 45 0c             	mov    0xc(%ebp),%eax
8010817a:	e9 ac 00 00 00       	jmp    8010822b <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010817f:	8b 45 10             	mov    0x10(%ebp),%eax
80108182:	05 ff 0f 00 00       	add    $0xfff,%eax
80108187:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010818c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010818f:	e9 88 00 00 00       	jmp    8010821c <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108197:	83 ec 04             	sub    $0x4,%esp
8010819a:	6a 00                	push   $0x0
8010819c:	50                   	push   %eax
8010819d:	ff 75 08             	pushl  0x8(%ebp)
801081a0:	e8 bb f9 ff ff       	call   80107b60 <walkpgdir>
801081a5:	83 c4 10             	add    $0x10,%esp
801081a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081af:	75 16                	jne    801081c7 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801081b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b4:	c1 e8 16             	shr    $0x16,%eax
801081b7:	83 c0 01             	add    $0x1,%eax
801081ba:	c1 e0 16             	shl    $0x16,%eax
801081bd:	2d 00 10 00 00       	sub    $0x1000,%eax
801081c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081c5:	eb 4e                	jmp    80108215 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801081c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ca:	8b 00                	mov    (%eax),%eax
801081cc:	83 e0 01             	and    $0x1,%eax
801081cf:	85 c0                	test   %eax,%eax
801081d1:	74 42                	je     80108215 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801081d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d6:	8b 00                	mov    (%eax),%eax
801081d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801081e0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081e4:	75 0d                	jne    801081f3 <deallocuvm+0x8a>
        panic("kfree");
801081e6:	83 ec 0c             	sub    $0xc,%esp
801081e9:	68 16 8e 10 80       	push   $0x80108e16
801081ee:	e8 ad 83 ff ff       	call   801005a0 <panic>
      char *v = P2V(pa);
801081f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081f6:	05 00 00 00 80       	add    $0x80000000,%eax
801081fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081fe:	83 ec 0c             	sub    $0xc,%esp
80108201:	ff 75 e8             	pushl  -0x18(%ebp)
80108204:	e8 85 aa ff ff       	call   80102c8e <kfree>
80108209:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010820c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010820f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108215:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010821c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108222:	0f 82 6c ff ff ff    	jb     80108194 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108228:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010822b:	c9                   	leave  
8010822c:	c3                   	ret    

8010822d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010822d:	55                   	push   %ebp
8010822e:	89 e5                	mov    %esp,%ebp
80108230:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108233:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108237:	75 0d                	jne    80108246 <freevm+0x19>
    panic("freevm: no pgdir");
80108239:	83 ec 0c             	sub    $0xc,%esp
8010823c:	68 1c 8e 10 80       	push   $0x80108e1c
80108241:	e8 5a 83 ff ff       	call   801005a0 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108246:	83 ec 04             	sub    $0x4,%esp
80108249:	6a 00                	push   $0x0
8010824b:	68 00 00 00 80       	push   $0x80000000
80108250:	ff 75 08             	pushl  0x8(%ebp)
80108253:	e8 11 ff ff ff       	call   80108169 <deallocuvm>
80108258:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010825b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108262:	eb 48                	jmp    801082ac <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108267:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010826e:	8b 45 08             	mov    0x8(%ebp),%eax
80108271:	01 d0                	add    %edx,%eax
80108273:	8b 00                	mov    (%eax),%eax
80108275:	83 e0 01             	and    $0x1,%eax
80108278:	85 c0                	test   %eax,%eax
8010827a:	74 2c                	je     801082a8 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010827c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108286:	8b 45 08             	mov    0x8(%ebp),%eax
80108289:	01 d0                	add    %edx,%eax
8010828b:	8b 00                	mov    (%eax),%eax
8010828d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108292:	05 00 00 00 80       	add    $0x80000000,%eax
80108297:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010829a:	83 ec 0c             	sub    $0xc,%esp
8010829d:	ff 75 f0             	pushl  -0x10(%ebp)
801082a0:	e8 e9 a9 ff ff       	call   80102c8e <kfree>
801082a5:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801082a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082ac:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082b3:	76 af                	jbe    80108264 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801082b5:	83 ec 0c             	sub    $0xc,%esp
801082b8:	ff 75 08             	pushl  0x8(%ebp)
801082bb:	e8 ce a9 ff ff       	call   80102c8e <kfree>
801082c0:	83 c4 10             	add    $0x10,%esp
}
801082c3:	90                   	nop
801082c4:	c9                   	leave  
801082c5:	c3                   	ret    

801082c6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801082c6:	55                   	push   %ebp
801082c7:	89 e5                	mov    %esp,%ebp
801082c9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082cc:	83 ec 04             	sub    $0x4,%esp
801082cf:	6a 00                	push   $0x0
801082d1:	ff 75 0c             	pushl  0xc(%ebp)
801082d4:	ff 75 08             	pushl  0x8(%ebp)
801082d7:	e8 84 f8 ff ff       	call   80107b60 <walkpgdir>
801082dc:	83 c4 10             	add    $0x10,%esp
801082df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801082e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082e6:	75 0d                	jne    801082f5 <clearpteu+0x2f>
    panic("clearpteu");
801082e8:	83 ec 0c             	sub    $0xc,%esp
801082eb:	68 2d 8e 10 80       	push   $0x80108e2d
801082f0:	e8 ab 82 ff ff       	call   801005a0 <panic>
  *pte &= ~PTE_U;
801082f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f8:	8b 00                	mov    (%eax),%eax
801082fa:	83 e0 fb             	and    $0xfffffffb,%eax
801082fd:	89 c2                	mov    %eax,%edx
801082ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108302:	89 10                	mov    %edx,(%eax)
}
80108304:	90                   	nop
80108305:	c9                   	leave  
80108306:	c3                   	ret    

80108307 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, uint lp)
{
80108307:	55                   	push   %ebp
80108308:	89 e5                	mov    %esp,%ebp
8010830a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010830d:	e8 74 f9 ff ff       	call   80107c86 <setupkvm>
80108312:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108315:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108319:	75 0a                	jne    80108325 <copyuvm+0x1e>
    return 0;
8010831b:	b8 00 00 00 00       	mov    $0x0,%eax
80108320:	e9 e1 01 00 00       	jmp    80108506 <copyuvm+0x1ff>
  for(i = 0; i < sz; i += PGSIZE){
80108325:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010832c:	e9 bf 00 00 00       	jmp    801083f0 <copyuvm+0xe9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108334:	83 ec 04             	sub    $0x4,%esp
80108337:	6a 00                	push   $0x0
80108339:	50                   	push   %eax
8010833a:	ff 75 08             	pushl  0x8(%ebp)
8010833d:	e8 1e f8 ff ff       	call   80107b60 <walkpgdir>
80108342:	83 c4 10             	add    $0x10,%esp
80108345:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108348:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010834c:	75 0d                	jne    8010835b <copyuvm+0x54>
      panic("copyuvm: pte should exist");
8010834e:	83 ec 0c             	sub    $0xc,%esp
80108351:	68 37 8e 10 80       	push   $0x80108e37
80108356:	e8 45 82 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010835b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835e:	8b 00                	mov    (%eax),%eax
80108360:	83 e0 01             	and    $0x1,%eax
80108363:	85 c0                	test   %eax,%eax
80108365:	75 0d                	jne    80108374 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108367:	83 ec 0c             	sub    $0xc,%esp
8010836a:	68 51 8e 10 80       	push   $0x80108e51
8010836f:	e8 2c 82 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108374:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108377:	8b 00                	mov    (%eax),%eax
80108379:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010837e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108381:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108384:	8b 00                	mov    (%eax),%eax
80108386:	25 ff 0f 00 00       	and    $0xfff,%eax
8010838b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010838e:	e8 95 a9 ff ff       	call   80102d28 <kalloc>
80108393:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108396:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010839a:	0f 84 49 01 00 00    	je     801084e9 <copyuvm+0x1e2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801083a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083a3:	05 00 00 00 80       	add    $0x80000000,%eax
801083a8:	83 ec 04             	sub    $0x4,%esp
801083ab:	68 00 10 00 00       	push   $0x1000
801083b0:	50                   	push   %eax
801083b1:	ff 75 e0             	pushl  -0x20(%ebp)
801083b4:	e8 c0 cf ff ff       	call   80105379 <memmove>
801083b9:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801083bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801083bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083c2:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801083c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cb:	83 ec 0c             	sub    $0xc,%esp
801083ce:	52                   	push   %edx
801083cf:	51                   	push   %ecx
801083d0:	68 00 10 00 00       	push   $0x1000
801083d5:	50                   	push   %eax
801083d6:	ff 75 f0             	pushl  -0x10(%ebp)
801083d9:	e8 18 f8 ff ff       	call   80107bf6 <mappages>
801083de:	83 c4 20             	add    $0x20,%esp
801083e1:	85 c0                	test   %eax,%eax
801083e3:	0f 88 03 01 00 00    	js     801084ec <copyuvm+0x1e5>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801083e9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083f6:	0f 82 35 ff ff ff    	jb     80108331 <copyuvm+0x2a>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }


 cprintf("COPUVM SP2 : %x\n", lp);
801083fc:	83 ec 08             	sub    $0x8,%esp
801083ff:	ff 75 10             	pushl  0x10(%ebp)
80108402:	68 6b 8e 10 80       	push   $0x80108e6b
80108407:	e8 f4 7f ff ff       	call   80100400 <cprintf>
8010840c:	83 c4 10             	add    $0x10,%esp
 for(i = PGROUNDDOWN(lp-1); i < KERNBASE; i += PGSIZE){
8010840f:	8b 45 10             	mov    0x10(%ebp),%eax
80108412:	83 e8 01             	sub    $0x1,%eax
80108415:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010841a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010841d:	e9 b7 00 00 00       	jmp    801084d9 <copyuvm+0x1d2>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108425:	83 ec 04             	sub    $0x4,%esp
80108428:	6a 00                	push   $0x0
8010842a:	50                   	push   %eax
8010842b:	ff 75 08             	pushl  0x8(%ebp)
8010842e:	e8 2d f7 ff ff       	call   80107b60 <walkpgdir>
80108433:	83 c4 10             	add    $0x10,%esp
80108436:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108439:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010843d:	75 0d                	jne    8010844c <copyuvm+0x145>
      panic("copyuvm: pte should exist");
8010843f:	83 ec 0c             	sub    $0xc,%esp
80108442:	68 37 8e 10 80       	push   $0x80108e37
80108447:	e8 54 81 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010844c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844f:	8b 00                	mov    (%eax),%eax
80108451:	83 e0 01             	and    $0x1,%eax
80108454:	85 c0                	test   %eax,%eax
80108456:	75 0d                	jne    80108465 <copyuvm+0x15e>
      panic("copyuvm: page not present");
80108458:	83 ec 0c             	sub    $0xc,%esp
8010845b:	68 51 8e 10 80       	push   $0x80108e51
80108460:	e8 3b 81 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108468:	8b 00                	mov    (%eax),%eax
8010846a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010846f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108475:	8b 00                	mov    (%eax),%eax
80108477:	25 ff 0f 00 00       	and    $0xfff,%eax
8010847c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010847f:	e8 a4 a8 ff ff       	call   80102d28 <kalloc>
80108484:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108487:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010848b:	74 62                	je     801084ef <copyuvm+0x1e8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010848d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108490:	05 00 00 00 80       	add    $0x80000000,%eax
80108495:	83 ec 04             	sub    $0x4,%esp
80108498:	68 00 10 00 00       	push   $0x1000
8010849d:	50                   	push   %eax
8010849e:	ff 75 e0             	pushl  -0x20(%ebp)
801084a1:	e8 d3 ce ff ff       	call   80105379 <memmove>
801084a6:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801084a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801084ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084af:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801084b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b8:	83 ec 0c             	sub    $0xc,%esp
801084bb:	52                   	push   %edx
801084bc:	51                   	push   %ecx
801084bd:	68 00 10 00 00       	push   $0x1000
801084c2:	50                   	push   %eax
801084c3:	ff 75 f0             	pushl  -0x10(%ebp)
801084c6:	e8 2b f7 ff ff       	call   80107bf6 <mappages>
801084cb:	83 c4 20             	add    $0x20,%esp
801084ce:	85 c0                	test   %eax,%eax
801084d0:	78 20                	js     801084f2 <copyuvm+0x1eb>
      goto bad;
  }


 cprintf("COPUVM SP2 : %x\n", lp);
 for(i = PGROUNDDOWN(lp-1); i < KERNBASE; i += PGSIZE){
801084d2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dc:	85 c0                	test   %eax,%eax
801084de:	0f 89 3e ff ff ff    	jns    80108422 <copyuvm+0x11b>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  return d;
801084e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e7:	eb 1d                	jmp    80108506 <copyuvm+0x1ff>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801084e9:	90                   	nop
801084ea:	eb 07                	jmp    801084f3 <copyuvm+0x1ec>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801084ec:	90                   	nop
801084ed:	eb 04                	jmp    801084f3 <copyuvm+0x1ec>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801084ef:	90                   	nop
801084f0:	eb 01                	jmp    801084f3 <copyuvm+0x1ec>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801084f2:	90                   	nop
  }

  return d;

bad:
  freevm(d);
801084f3:	83 ec 0c             	sub    $0xc,%esp
801084f6:	ff 75 f0             	pushl  -0x10(%ebp)
801084f9:	e8 2f fd ff ff       	call   8010822d <freevm>
801084fe:	83 c4 10             	add    $0x10,%esp
  return 0;
80108501:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108506:	c9                   	leave  
80108507:	c3                   	ret    

80108508 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108508:	55                   	push   %ebp
80108509:	89 e5                	mov    %esp,%ebp
8010850b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010850e:	83 ec 04             	sub    $0x4,%esp
80108511:	6a 00                	push   $0x0
80108513:	ff 75 0c             	pushl  0xc(%ebp)
80108516:	ff 75 08             	pushl  0x8(%ebp)
80108519:	e8 42 f6 ff ff       	call   80107b60 <walkpgdir>
8010851e:	83 c4 10             	add    $0x10,%esp
80108521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108527:	8b 00                	mov    (%eax),%eax
80108529:	83 e0 01             	and    $0x1,%eax
8010852c:	85 c0                	test   %eax,%eax
8010852e:	75 07                	jne    80108537 <uva2ka+0x2f>
    return 0;
80108530:	b8 00 00 00 00       	mov    $0x0,%eax
80108535:	eb 22                	jmp    80108559 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853a:	8b 00                	mov    (%eax),%eax
8010853c:	83 e0 04             	and    $0x4,%eax
8010853f:	85 c0                	test   %eax,%eax
80108541:	75 07                	jne    8010854a <uva2ka+0x42>
    return 0;
80108543:	b8 00 00 00 00       	mov    $0x0,%eax
80108548:	eb 0f                	jmp    80108559 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010854a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854d:	8b 00                	mov    (%eax),%eax
8010854f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108554:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108559:	c9                   	leave  
8010855a:	c3                   	ret    

8010855b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010855b:	55                   	push   %ebp
8010855c:	89 e5                	mov    %esp,%ebp
8010855e:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108561:	8b 45 10             	mov    0x10(%ebp),%eax
80108564:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108567:	eb 7f                	jmp    801085e8 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010856c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108571:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108574:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108577:	83 ec 08             	sub    $0x8,%esp
8010857a:	50                   	push   %eax
8010857b:	ff 75 08             	pushl  0x8(%ebp)
8010857e:	e8 85 ff ff ff       	call   80108508 <uva2ka>
80108583:	83 c4 10             	add    $0x10,%esp
80108586:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108589:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010858d:	75 07                	jne    80108596 <copyout+0x3b>
      return -1;
8010858f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108594:	eb 61                	jmp    801085f7 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108596:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108599:	2b 45 0c             	sub    0xc(%ebp),%eax
8010859c:	05 00 10 00 00       	add    $0x1000,%eax
801085a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085a7:	3b 45 14             	cmp    0x14(%ebp),%eax
801085aa:	76 06                	jbe    801085b2 <copyout+0x57>
      n = len;
801085ac:	8b 45 14             	mov    0x14(%ebp),%eax
801085af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801085b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801085b5:	2b 45 ec             	sub    -0x14(%ebp),%eax
801085b8:	89 c2                	mov    %eax,%edx
801085ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085bd:	01 d0                	add    %edx,%eax
801085bf:	83 ec 04             	sub    $0x4,%esp
801085c2:	ff 75 f0             	pushl  -0x10(%ebp)
801085c5:	ff 75 f4             	pushl  -0xc(%ebp)
801085c8:	50                   	push   %eax
801085c9:	e8 ab cd ff ff       	call   80105379 <memmove>
801085ce:	83 c4 10             	add    $0x10,%esp
    len -= n;
801085d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801085d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085da:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e0:	05 00 10 00 00       	add    $0x1000,%eax
801085e5:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801085e8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085ec:	0f 85 77 ff ff ff    	jne    80108569 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801085f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085f7:	c9                   	leave  
801085f8:	c3                   	ret    

801085f9 <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
801085f9:	55                   	push   %ebp
801085fa:	89 e5                	mov    %esp,%ebp
801085fc:	83 ec 18             	sub    $0x18,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
801085ff:	83 ec 08             	sub    $0x8,%esp
80108602:	68 7c 8e 10 80       	push   $0x80108e7c
80108607:	68 40 67 11 80       	push   $0x80116740
8010860c:	e8 10 ca ff ff       	call   80105021 <initlock>
80108611:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
80108614:	83 ec 0c             	sub    $0xc,%esp
80108617:	68 40 67 11 80       	push   $0x80116740
8010861c:	e8 22 ca ff ff       	call   80105043 <acquire>
80108621:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i< 64; i++) {
80108624:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010862b:	eb 49                	jmp    80108676 <shminit+0x7d>
    shm_table.shm_pages[i].id =0;
8010862d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108630:	89 d0                	mov    %edx,%eax
80108632:	01 c0                	add    %eax,%eax
80108634:	01 d0                	add    %edx,%eax
80108636:	c1 e0 02             	shl    $0x2,%eax
80108639:	05 74 67 11 80       	add    $0x80116774,%eax
8010863e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80108644:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108647:	89 d0                	mov    %edx,%eax
80108649:	01 c0                	add    %eax,%eax
8010864b:	01 d0                	add    %edx,%eax
8010864d:	c1 e0 02             	shl    $0x2,%eax
80108650:	05 78 67 11 80       	add    $0x80116778,%eax
80108655:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
8010865b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010865e:	89 d0                	mov    %edx,%eax
80108660:	01 c0                	add    %eax,%eax
80108662:	01 d0                	add    %edx,%eax
80108664:	c1 e0 02             	shl    $0x2,%eax
80108667:	05 7c 67 11 80       	add    $0x8011677c,%eax
8010866c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
80108672:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108676:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010867a:	7e b1                	jle    8010862d <shminit+0x34>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
8010867c:	83 ec 0c             	sub    $0xc,%esp
8010867f:	68 40 67 11 80       	push   $0x80116740
80108684:	e8 28 ca ff ff       	call   801050b1 <release>
80108689:	83 c4 10             	add    $0x10,%esp
}
8010868c:	90                   	nop
8010868d:	c9                   	leave  
8010868e:	c3                   	ret    

8010868f <shm_open>:

int shm_open(int id, char **pointer) {
8010868f:	55                   	push   %ebp
80108690:	89 e5                	mov    %esp,%ebp
//you write this




return 0; //added to remove compiler warning -- you should decide what to return
80108692:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108697:	5d                   	pop    %ebp
80108698:	c3                   	ret    

80108699 <shm_close>:


int shm_close(int id) {
80108699:	55                   	push   %ebp
8010869a:	89 e5                	mov    %esp,%ebp
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
8010869c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086a1:	5d                   	pop    %ebp
801086a2:	c3                   	ret    
