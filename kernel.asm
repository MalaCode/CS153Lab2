
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
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
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
80100028:	bc 30 d6 10 80       	mov    $0x8010d630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 90 38 10 80       	mov    $0x80103890,%eax
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
8010003d:	68 80 8a 10 80       	push   $0x80108a80
80100042:	68 40 d6 10 80       	push   $0x8010d640
80100047:	e8 61 4f 00 00       	call   80104fad <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 8c 1d 11 80 3c 	movl   $0x80111d3c,0x80111d8c
80100056:	1d 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 90 1d 11 80 3c 	movl   $0x80111d3c,0x80111d90
80100060:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 74 d6 10 80 	movl   $0x8010d674,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 90 1d 11 80    	mov    0x80111d90,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 3c 1d 11 80 	movl   $0x80111d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 87 8a 10 80       	push   $0x80108a87
80100090:	50                   	push   %eax
80100091:	e8 ba 4d 00 00       	call   80104e50 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 90 1d 11 80       	mov    0x80111d90,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 90 1d 11 80       	mov    %eax,0x80111d90

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 3c 1d 11 80       	mov    $0x80111d3c,%eax
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
801000c9:	68 40 d6 10 80       	push   $0x8010d640
801000ce:	e8 fc 4e 00 00       	call   80104fcf <acquire>
801000d3:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d6:	a1 90 1d 11 80       	mov    0x80111d90,%eax
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
80100108:	68 40 d6 10 80       	push   $0x8010d640
8010010d:	e8 2b 4f 00 00       	call   8010503d <release>
80100112:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	83 c0 0c             	add    $0xc,%eax
8010011b:	83 ec 0c             	sub    $0xc,%esp
8010011e:	50                   	push   %eax
8010011f:	e8 68 4d 00 00       	call   80104e8c <acquiresleep>
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
80100138:	81 7d f4 3c 1d 11 80 	cmpl   $0x80111d3c,-0xc(%ebp)
8010013f:	75 9f                	jne    801000e0 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 8c 1d 11 80       	mov    0x80111d8c,%eax
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
80100189:	68 40 d6 10 80       	push   $0x8010d640
8010018e:	e8 aa 4e 00 00       	call   8010503d <release>
80100193:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	83 c0 0c             	add    $0xc,%eax
8010019c:	83 ec 0c             	sub    $0xc,%esp
8010019f:	50                   	push   %eax
801001a0:	e8 e7 4c 00 00       	call   80104e8c <acquiresleep>
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
801001b6:	81 7d f4 3c 1d 11 80 	cmpl   $0x80111d3c,-0xc(%ebp)
801001bd:	75 8c                	jne    8010014b <bget+0x8b>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001bf:	83 ec 0c             	sub    $0xc,%esp
801001c2:	68 8e 8a 10 80       	push   $0x80108a8e
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
801001fa:	e8 90 27 00 00       	call   8010298f <iderw>
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
80100217:	e8 22 4d 00 00       	call   80104f3e <holdingsleep>
8010021c:	83 c4 10             	add    $0x10,%esp
8010021f:	85 c0                	test   %eax,%eax
80100221:	75 0d                	jne    80100230 <bwrite+0x29>
    panic("bwrite");
80100223:	83 ec 0c             	sub    $0xc,%esp
80100226:	68 9f 8a 10 80       	push   $0x80108a9f
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
80100245:	e8 45 27 00 00       	call   8010298f <iderw>
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
80100260:	e8 d9 4c 00 00       	call   80104f3e <holdingsleep>
80100265:	83 c4 10             	add    $0x10,%esp
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 0d                	jne    80100279 <brelse+0x29>
    panic("brelse");
8010026c:	83 ec 0c             	sub    $0xc,%esp
8010026f:	68 a6 8a 10 80       	push   $0x80108aa6
80100274:	e8 27 03 00 00       	call   801005a0 <panic>

  releasesleep(&b->lock);
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	83 c0 0c             	add    $0xc,%eax
8010027f:	83 ec 0c             	sub    $0xc,%esp
80100282:	50                   	push   %eax
80100283:	e8 68 4c 00 00       	call   80104ef0 <releasesleep>
80100288:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028b:	83 ec 0c             	sub    $0xc,%esp
8010028e:	68 40 d6 10 80       	push   $0x8010d640
80100293:	e8 37 4d 00 00       	call   80104fcf <acquire>
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
801002d2:	8b 15 90 1d 11 80    	mov    0x80111d90,%edx
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	c7 40 50 3c 1d 11 80 	movl   $0x80111d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002e8:	a1 90 1d 11 80       	mov    0x80111d90,%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	a3 90 1d 11 80       	mov    %eax,0x80111d90
  }
  
  release(&bcache.lock);
801002fb:	83 ec 0c             	sub    $0xc,%esp
801002fe:	68 40 d6 10 80       	push   $0x8010d640
80100303:	e8 35 4d 00 00       	call   8010503d <release>
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
8010039f:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
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
80100406:	a1 d4 c5 10 80       	mov    0x8010c5d4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 a0 c5 10 80       	push   $0x8010c5a0
8010041c:	e8 ae 4b 00 00       	call   80104fcf <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 ad 8a 10 80       	push   $0x80108aad
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
80100507:	c7 45 ec b6 8a 10 80 	movl   $0x80108ab6,-0x14(%ebp)
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
80100590:	68 a0 c5 10 80       	push   $0x8010c5a0
80100595:	e8 a3 4a 00 00       	call   8010503d <release>
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
801005ab:	c7 05 d4 c5 10 80 00 	movl   $0x0,0x8010c5d4
801005b2:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005b5:	e8 64 2a 00 00       	call   8010301e <lapicid>
801005ba:	83 ec 08             	sub    $0x8,%esp
801005bd:	50                   	push   %eax
801005be:	68 bd 8a 10 80       	push   $0x80108abd
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
801005dd:	68 d1 8a 10 80       	push   $0x80108ad1
801005e2:	e8 19 fe ff ff       	call   80100400 <cprintf>
801005e7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ea:	83 ec 08             	sub    $0x8,%esp
801005ed:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f0:	50                   	push   %eax
801005f1:	8d 45 08             	lea    0x8(%ebp),%eax
801005f4:	50                   	push   %eax
801005f5:	e8 95 4a 00 00       	call   8010508f <getcallerpcs>
801005fa:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100604:	eb 1c                	jmp    80100622 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100609:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060d:	83 ec 08             	sub    $0x8,%esp
80100610:	50                   	push   %eax
80100611:	68 d3 8a 10 80       	push   $0x80108ad3
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
80100628:	c7 05 80 c5 10 80 01 	movl   $0x1,0x8010c580
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
801006cc:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
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
801006fd:	68 d7 8a 10 80       	push   $0x80108ad7
80100702:	e8 99 fe ff ff       	call   801005a0 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100707:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070e:	7e 4c                	jle    8010075c <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100710:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100715:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010071b:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100720:	83 ec 04             	sub    $0x4,%esp
80100723:	68 60 0e 00 00       	push   $0xe60
80100728:	52                   	push   %edx
80100729:	50                   	push   %eax
8010072a:	e8 d6 4b 00 00       	call   80105305 <memmove>
8010072f:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100732:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100736:	b8 80 07 00 00       	mov    $0x780,%eax
8010073b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073e:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100741:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100746:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100749:	01 c9                	add    %ecx,%ecx
8010074b:	01 c8                	add    %ecx,%eax
8010074d:	83 ec 04             	sub    $0x4,%esp
80100750:	52                   	push   %edx
80100751:	6a 00                	push   $0x0
80100753:	50                   	push   %eax
80100754:	e8 ed 4a 00 00       	call   80105246 <memset>
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
801007b1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
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
801007cb:	a1 80 c5 10 80       	mov    0x8010c580,%eax
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
801007e9:	e8 fa 64 00 00       	call   80106ce8 <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	6a 20                	push   $0x20
801007f6:	e8 ed 64 00 00       	call   80106ce8 <uartputc>
801007fb:	83 c4 10             	add    $0x10,%esp
801007fe:	83 ec 0c             	sub    $0xc,%esp
80100801:	6a 08                	push   $0x8
80100803:	e8 e0 64 00 00       	call   80106ce8 <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	eb 0e                	jmp    8010081b <consputc+0x56>
  } else
    uartputc(c);
8010080d:	83 ec 0c             	sub    $0xc,%esp
80100810:	ff 75 08             	pushl  0x8(%ebp)
80100813:	e8 d0 64 00 00       	call   80106ce8 <uartputc>
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
8010083c:	68 a0 c5 10 80       	push   $0x8010c5a0
80100841:	e8 89 47 00 00       	call   80104fcf <acquire>
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
80100880:	a1 28 20 11 80       	mov    0x80112028,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	a3 28 20 11 80       	mov    %eax,0x80112028
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
8010089d:	8b 15 28 20 11 80    	mov    0x80112028,%edx
801008a3:	a1 24 20 11 80       	mov    0x80112024,%eax
801008a8:	39 c2                	cmp    %eax,%edx
801008aa:	0f 84 e2 00 00 00    	je     80100992 <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008b0:	a1 28 20 11 80       	mov    0x80112028,%eax
801008b5:	83 e8 01             	sub    $0x1,%eax
801008b8:	83 e0 7f             	and    $0x7f,%eax
801008bb:	0f b6 80 a0 1f 11 80 	movzbl -0x7feee060(%eax),%eax
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
801008cb:	8b 15 28 20 11 80    	mov    0x80112028,%edx
801008d1:	a1 24 20 11 80       	mov    0x80112024,%eax
801008d6:	39 c2                	cmp    %eax,%edx
801008d8:	0f 84 b4 00 00 00    	je     80100992 <consoleintr+0x166>
        input.e--;
801008de:	a1 28 20 11 80       	mov    0x80112028,%eax
801008e3:	83 e8 01             	sub    $0x1,%eax
801008e6:	a3 28 20 11 80       	mov    %eax,0x80112028
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
8010090a:	8b 15 28 20 11 80    	mov    0x80112028,%edx
80100910:	a1 20 20 11 80       	mov    0x80112020,%eax
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
80100931:	a1 28 20 11 80       	mov    0x80112028,%eax
80100936:	8d 50 01             	lea    0x1(%eax),%edx
80100939:	89 15 28 20 11 80    	mov    %edx,0x80112028
8010093f:	83 e0 7f             	and    $0x7f,%eax
80100942:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100945:	88 90 a0 1f 11 80    	mov    %dl,-0x7feee060(%eax)
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
80100965:	a1 28 20 11 80       	mov    0x80112028,%eax
8010096a:	8b 15 20 20 11 80    	mov    0x80112020,%edx
80100970:	83 ea 80             	sub    $0xffffff80,%edx
80100973:	39 d0                	cmp    %edx,%eax
80100975:	75 1a                	jne    80100991 <consoleintr+0x165>
          input.w = input.e;
80100977:	a1 28 20 11 80       	mov    0x80112028,%eax
8010097c:	a3 24 20 11 80       	mov    %eax,0x80112024
          wakeup(&input.r);
80100981:	83 ec 0c             	sub    $0xc,%esp
80100984:	68 20 20 11 80       	push   $0x80112020
80100989:	e8 08 43 00 00       	call   80104c96 <wakeup>
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
801009a7:	68 a0 c5 10 80       	push   $0x8010c5a0
801009ac:	e8 8c 46 00 00       	call   8010503d <release>
801009b1:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b8:	74 05                	je     801009bf <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
801009ba:	e8 95 43 00 00       	call   80104d54 <procdump>
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
801009ce:	e8 83 11 00 00       	call   80101b56 <iunlock>
801009d3:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009dc:	83 ec 0c             	sub    $0xc,%esp
801009df:	68 a0 c5 10 80       	push   $0x8010c5a0
801009e4:	e8 e6 45 00 00       	call   80104fcf <acquire>
801009e9:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ec:	e9 ab 00 00 00       	jmp    80100a9c <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009f1:	e8 ca 38 00 00       	call   801042c0 <myproc>
801009f6:	8b 40 24             	mov    0x24(%eax),%eax
801009f9:	85 c0                	test   %eax,%eax
801009fb:	74 28                	je     80100a25 <consoleread+0x63>
        release(&cons.lock);
801009fd:	83 ec 0c             	sub    $0xc,%esp
80100a00:	68 a0 c5 10 80       	push   $0x8010c5a0
80100a05:	e8 33 46 00 00       	call   8010503d <release>
80100a0a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0d:	83 ec 0c             	sub    $0xc,%esp
80100a10:	ff 75 08             	pushl  0x8(%ebp)
80100a13:	e8 2b 10 00 00       	call   80101a43 <ilock>
80100a18:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a20:	e9 ab 00 00 00       	jmp    80100ad0 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
80100a25:	83 ec 08             	sub    $0x8,%esp
80100a28:	68 a0 c5 10 80       	push   $0x8010c5a0
80100a2d:	68 20 20 11 80       	push   $0x80112020
80100a32:	e8 76 41 00 00       	call   80104bad <sleep>
80100a37:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a3a:	8b 15 20 20 11 80    	mov    0x80112020,%edx
80100a40:	a1 24 20 11 80       	mov    0x80112024,%eax
80100a45:	39 c2                	cmp    %eax,%edx
80100a47:	74 a8                	je     801009f1 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a49:	a1 20 20 11 80       	mov    0x80112020,%eax
80100a4e:	8d 50 01             	lea    0x1(%eax),%edx
80100a51:	89 15 20 20 11 80    	mov    %edx,0x80112020
80100a57:	83 e0 7f             	and    $0x7f,%eax
80100a5a:	0f b6 80 a0 1f 11 80 	movzbl -0x7feee060(%eax),%eax
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
80100a75:	a1 20 20 11 80       	mov    0x80112020,%eax
80100a7a:	83 e8 01             	sub    $0x1,%eax
80100a7d:	a3 20 20 11 80       	mov    %eax,0x80112020
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
80100aab:	68 a0 c5 10 80       	push   $0x8010c5a0
80100ab0:	e8 88 45 00 00       	call   8010503d <release>
80100ab5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab8:	83 ec 0c             	sub    $0xc,%esp
80100abb:	ff 75 08             	pushl  0x8(%ebp)
80100abe:	e8 80 0f 00 00       	call   80101a43 <ilock>
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
80100ade:	e8 73 10 00 00       	call   80101b56 <iunlock>
80100ae3:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 a0 c5 10 80       	push   $0x8010c5a0
80100aee:	e8 dc 44 00 00       	call   80104fcf <acquire>
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
80100b2b:	68 a0 c5 10 80       	push   $0x8010c5a0
80100b30:	e8 08 45 00 00       	call   8010503d <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 00 0f 00 00       	call   80101a43 <ilock>
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
80100b54:	68 ea 8a 10 80       	push   $0x80108aea
80100b59:	68 a0 c5 10 80       	push   $0x8010c5a0
80100b5e:	e8 4a 44 00 00       	call   80104fad <initlock>
80100b63:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b66:	c7 05 ec 29 11 80 d2 	movl   $0x80100ad2,0x801129ec
80100b6d:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b70:	c7 05 e8 29 11 80 c2 	movl   $0x801009c2,0x801129e8
80100b77:	09 10 80 
  cons.locking = 1;
80100b7a:	c7 05 d4 c5 10 80 01 	movl   $0x1,0x8010c5d4
80100b81:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b84:	83 ec 08             	sub    $0x8,%esp
80100b87:	6a 00                	push   $0x0
80100b89:	6a 01                	push   $0x1
80100b8b:	e8 c7 1f 00 00       	call   80102b57 <ioapicenable>
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
80100b9f:	e8 1c 37 00 00       	call   801042c0 <myproc>
80100ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba7:	e8 bc 29 00 00       	call   80103568 <begin_op>

  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 cc 19 00 00       	call   80102583 <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 1f                	jne    80100be2 <exec+0x4c>
    end_op();
80100bc3:	e8 2c 2a 00 00       	call   801035f4 <end_op>
    cprintf("exec: fail\n");
80100bc8:	83 ec 0c             	sub    $0xc,%esp
80100bcb:	68 f2 8a 10 80       	push   $0x80108af2
80100bd0:	e8 2b f8 ff ff       	call   80100400 <cprintf>
80100bd5:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdd:	e9 24 04 00 00       	jmp    80101006 <exec+0x470>
  }
  ilock(ip);
80100be2:	83 ec 0c             	sub    $0xc,%esp
80100be5:	ff 75 d8             	pushl  -0x28(%ebp)
80100be8:	e8 56 0e 00 00       	call   80101a43 <ilock>
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
80100c05:	e8 2a 13 00 00       	call   80101f34 <readi>
80100c0a:	83 c4 10             	add    $0x10,%esp
80100c0d:	83 f8 34             	cmp    $0x34,%eax
80100c10:	0f 85 99 03 00 00    	jne    80100faf <exec+0x419>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c21:	0f 85 8b 03 00 00    	jne    80100fb2 <exec+0x41c>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c27:	e8 b8 70 00 00       	call   80107ce4 <setupkvm>
80100c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c33:	0f 84 7c 03 00 00    	je     80100fb5 <exec+0x41f>
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
80100c65:	e8 ca 12 00 00       	call   80101f34 <readi>
80100c6a:	83 c4 10             	add    $0x10,%esp
80100c6d:	83 f8 20             	cmp    $0x20,%eax
80100c70:	0f 85 42 03 00 00    	jne    80100fb8 <exec+0x422>
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
80100c93:	0f 82 22 03 00 00    	jb     80100fbb <exec+0x425>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c99:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c9f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca5:	01 c2                	add    %eax,%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	39 c2                	cmp    %eax,%edx
80100caf:	0f 82 09 03 00 00    	jb     80100fbe <exec+0x428>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc1:	01 d0                	add    %edx,%eax
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 e0             	pushl  -0x20(%ebp)
80100cca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccd:	e8 b7 73 00 00       	call   80108089 <allocuvm>
80100cd2:	83 c4 10             	add    $0x10,%esp
80100cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdc:	0f 84 df 02 00 00    	je     80100fc1 <exec+0x42b>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ce8:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	0f 85 cf 02 00 00    	jne    80100fc4 <exec+0x42e>
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
80100d13:	e8 a4 72 00 00       	call   80107fbc <loaduvm>
80100d18:	83 c4 20             	add    $0x20,%esp
80100d1b:	85 c0                	test   %eax,%eax
80100d1d:	0f 88 a4 02 00 00    	js     80100fc7 <exec+0x431>
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
80100d4c:	e8 23 0f 00 00       	call   80101c74 <iunlockput>
80100d51:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d54:	e8 9b 28 00 00       	call   801035f4 <end_op>
  ip = 0;
80100d59:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  // Left in for buffer page before code section CS153
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
80100d82:	e8 02 73 00 00       	call   80108089 <allocuvm>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d91:	0f 84 33 02 00 00    	je     80100fca <exec+0x434>
    goto bad;
  clearpteu(pgdir, (char*)(sz - PGSIZE));
80100d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9a:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d9f:	83 ec 08             	sub    $0x8,%esp
80100da2:	50                   	push   %eax
80100da3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da6:	e8 40 75 00 00       	call   801082eb <clearpteu>
80100dab:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)

   //cprintf("KERNBASE: %x\n", KERNBASE);
   //cprintf("PGSIZE: %d\n", PGSIZE);

   //Allocate a page right below KERNBASE to become the new stack CS153
   curproc->stackTop = allocuvm(pgdir, KERNBASE - PGSIZE, KERNBASE - 4);
80100db4:	83 ec 04             	sub    $0x4,%esp
80100db7:	68 fc ff ff 7f       	push   $0x7ffffffc
80100dbc:	68 00 f0 ff 7f       	push   $0x7ffff000
80100dc1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc4:	e8 c0 72 00 00       	call   80108089 <allocuvm>
80100dc9:	83 c4 10             	add    $0x10,%esp
80100dcc:	89 c2                	mov    %eax,%edx
80100dce:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dd1:	89 50 7c             	mov    %edx,0x7c(%eax)
   curproc->pageNum = 1;
80100dd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dd7:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
80100dde:	00 00 00 
  
  // cprintf("stackTop: %x\n", curproc->stackTop);
  // cprintf("pageNum: %x\n", curproc->pageNum);

   sp = curproc->stackTop;
80100de1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100de4:	8b 40 7c             	mov    0x7c(%eax),%eax
80100de7:	89 45 dc             	mov    %eax,-0x24(%ebp)
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100df1:	e9 93 00 00 00       	jmp    80100e89 <exec+0x2f3>
    if(argc >= MAXARG)
80100df6:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dfa:	0f 87 cd 01 00 00    	ja     80100fcd <exec+0x437>
      goto bad;
    sp = (sp - (strlen(argv[argc]) )) & ~3;
80100e00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e03:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e0d:	01 d0                	add    %edx,%eax
80100e0f:	8b 00                	mov    (%eax),%eax
80100e11:	83 ec 0c             	sub    $0xc,%esp
80100e14:	50                   	push   %eax
80100e15:	e8 79 46 00 00       	call   80105493 <strlen>
80100e1a:	83 c4 10             	add    $0x10,%esp
80100e1d:	89 c2                	mov    %eax,%edx
80100e1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e22:	29 d0                	sub    %edx,%eax
80100e24:	83 e0 fc             	and    $0xfffffffc,%eax
80100e27:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e37:	01 d0                	add    %edx,%eax
80100e39:	8b 00                	mov    (%eax),%eax
80100e3b:	83 ec 0c             	sub    $0xc,%esp
80100e3e:	50                   	push   %eax
80100e3f:	e8 4f 46 00 00       	call   80105493 <strlen>
80100e44:	83 c4 10             	add    $0x10,%esp
80100e47:	83 c0 01             	add    $0x1,%eax
80100e4a:	89 c1                	mov    %eax,%ecx
80100e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e59:	01 d0                	add    %edx,%eax
80100e5b:	8b 00                	mov    (%eax),%eax
80100e5d:	51                   	push   %ecx
80100e5e:	50                   	push   %eax
80100e5f:	ff 75 dc             	pushl  -0x24(%ebp)
80100e62:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e65:	e8 03 77 00 00       	call   8010856d <copyout>
80100e6a:	83 c4 10             	add    $0x10,%esp
80100e6d:	85 c0                	test   %eax,%eax
80100e6f:	0f 88 5b 01 00 00    	js     80100fd0 <exec+0x43a>
      goto bad;
    ustack[3+argc] = sp;
80100e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e78:	8d 50 03             	lea    0x3(%eax),%edx
80100e7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e7e:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  // cprintf("pageNum: %x\n", curproc->pageNum);

   sp = curproc->stackTop;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e85:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e96:	01 d0                	add    %edx,%eax
80100e98:	8b 00                	mov    (%eax),%eax
80100e9a:	85 c0                	test   %eax,%eax
80100e9c:	0f 85 54 ff ff ff    	jne    80100df6 <exec+0x260>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea5:	83 c0 03             	add    $0x3,%eax
80100ea8:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100eaf:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eb3:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eba:	ff ff ff 
  ustack[1] = argc;
80100ebd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec0:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec9:	83 c0 01             	add    $0x1,%eax
80100ecc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ed3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed6:	29 d0                	sub    %edx,%eax
80100ed8:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	83 c0 04             	add    $0x4,%eax
80100ee4:	c1 e0 02             	shl    $0x2,%eax
80100ee7:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eed:	83 c0 04             	add    $0x4,%eax
80100ef0:	c1 e0 02             	shl    $0x2,%eax
80100ef3:	50                   	push   %eax
80100ef4:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100efa:	50                   	push   %eax
80100efb:	ff 75 dc             	pushl  -0x24(%ebp)
80100efe:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f01:	e8 67 76 00 00       	call   8010856d <copyout>
80100f06:	83 c4 10             	add    $0x10,%esp
80100f09:	85 c0                	test   %eax,%eax
80100f0b:	0f 88 c2 00 00 00    	js     80100fd3 <exec+0x43d>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f11:	8b 45 08             	mov    0x8(%ebp),%eax
80100f14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f1d:	eb 17                	jmp    80100f36 <exec+0x3a0>
    if(*s == '/')
80100f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f22:	0f b6 00             	movzbl (%eax),%eax
80100f25:	3c 2f                	cmp    $0x2f,%al
80100f27:	75 09                	jne    80100f32 <exec+0x39c>
      last = s+1;
80100f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f2c:	83 c0 01             	add    $0x1,%eax
80100f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f39:	0f b6 00             	movzbl (%eax),%eax
80100f3c:	84 c0                	test   %al,%al
80100f3e:	75 df                	jne    80100f1f <exec+0x389>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f40:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f43:	83 c0 6c             	add    $0x6c,%eax
80100f46:	83 ec 04             	sub    $0x4,%esp
80100f49:	6a 10                	push   $0x10
80100f4b:	ff 75 f0             	pushl  -0x10(%ebp)
80100f4e:	50                   	push   %eax
80100f4f:	e8 f5 44 00 00       	call   80105449 <safestrcpy>
80100f54:	83 c4 10             	add    $0x10,%esp
 
 
  // Commit to the user image.
//  cprintf("SP: %x\n", sp);
//  cprintf("DIFFERENCE: %d\n", curproc->last_page-sp);
  oldpgdir = curproc->pgdir;
80100f57:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5a:	8b 40 04             	mov    0x4(%eax),%eax
80100f5d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f60:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f63:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f66:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f69:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f6f:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f74:	8b 40 18             	mov    0x18(%eax),%eax
80100f77:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f7d:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f80:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f83:	8b 40 18             	mov    0x18(%eax),%eax
80100f86:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f89:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	ff 75 d0             	pushl  -0x30(%ebp)
80100f92:	e8 17 6e 00 00       	call   80107dae <switchuvm>
80100f97:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f9a:	83 ec 0c             	sub    $0xc,%esp
80100f9d:	ff 75 cc             	pushl  -0x34(%ebp)
80100fa0:	e8 ad 72 00 00       	call   80108252 <freevm>
80100fa5:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa8:	b8 00 00 00 00       	mov    $0x0,%eax
80100fad:	eb 57                	jmp    80101006 <exec+0x470>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
80100faf:	90                   	nop
80100fb0:	eb 22                	jmp    80100fd4 <exec+0x43e>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fb2:	90                   	nop
80100fb3:	eb 1f                	jmp    80100fd4 <exec+0x43e>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fb5:	90                   	nop
80100fb6:	eb 1c                	jmp    80100fd4 <exec+0x43e>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fb8:	90                   	nop
80100fb9:	eb 19                	jmp    80100fd4 <exec+0x43e>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fbb:	90                   	nop
80100fbc:	eb 16                	jmp    80100fd4 <exec+0x43e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
80100fbe:	90                   	nop
80100fbf:	eb 13                	jmp    80100fd4 <exec+0x43e>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fc1:	90                   	nop
80100fc2:	eb 10                	jmp    80100fd4 <exec+0x43e>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
80100fc4:	90                   	nop
80100fc5:	eb 0d                	jmp    80100fd4 <exec+0x43e>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fc7:	90                   	nop
80100fc8:	eb 0a                	jmp    80100fd4 <exec+0x43e>
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  // Left in for buffer page before code section CS153
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
    goto bad;
80100fca:	90                   	nop
80100fcb:	eb 07                	jmp    80100fd4 <exec+0x43e>
   sp = curproc->stackTop;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fcd:	90                   	nop
80100fce:	eb 04                	jmp    80100fd4 <exec+0x43e>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fd0:	90                   	nop
80100fd1:	eb 01                	jmp    80100fd4 <exec+0x43e>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100fd3:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100fd4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd8:	74 0e                	je     80100fe8 <exec+0x452>
    freevm(pgdir);
80100fda:	83 ec 0c             	sub    $0xc,%esp
80100fdd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fe0:	e8 6d 72 00 00       	call   80108252 <freevm>
80100fe5:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fec:	74 13                	je     80101001 <exec+0x46b>
    iunlockput(ip);
80100fee:	83 ec 0c             	sub    $0xc,%esp
80100ff1:	ff 75 d8             	pushl  -0x28(%ebp)
80100ff4:	e8 7b 0c 00 00       	call   80101c74 <iunlockput>
80100ff9:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ffc:	e8 f3 25 00 00       	call   801035f4 <end_op>
  }
  return -1;
80101001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101006:	c9                   	leave  
80101007:	c3                   	ret    

80101008 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101008:	55                   	push   %ebp
80101009:	89 e5                	mov    %esp,%ebp
8010100b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100e:	83 ec 08             	sub    $0x8,%esp
80101011:	68 fe 8a 10 80       	push   $0x80108afe
80101016:	68 40 20 11 80       	push   $0x80112040
8010101b:	e8 8d 3f 00 00       	call   80104fad <initlock>
80101020:	83 c4 10             	add    $0x10,%esp
}
80101023:	90                   	nop
80101024:	c9                   	leave  
80101025:	c3                   	ret    

80101026 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101026:	55                   	push   %ebp
80101027:	89 e5                	mov    %esp,%ebp
80101029:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102c:	83 ec 0c             	sub    $0xc,%esp
8010102f:	68 40 20 11 80       	push   $0x80112040
80101034:	e8 96 3f 00 00       	call   80104fcf <acquire>
80101039:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103c:	c7 45 f4 74 20 11 80 	movl   $0x80112074,-0xc(%ebp)
80101043:	eb 2d                	jmp    80101072 <filealloc+0x4c>
    if(f->ref == 0){
80101045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101048:	8b 40 04             	mov    0x4(%eax),%eax
8010104b:	85 c0                	test   %eax,%eax
8010104d:	75 1f                	jne    8010106e <filealloc+0x48>
      f->ref = 1;
8010104f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101052:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101059:	83 ec 0c             	sub    $0xc,%esp
8010105c:	68 40 20 11 80       	push   $0x80112040
80101061:	e8 d7 3f 00 00       	call   8010503d <release>
80101066:	83 c4 10             	add    $0x10,%esp
      return f;
80101069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106c:	eb 23                	jmp    80101091 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106e:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101072:	b8 d4 29 11 80       	mov    $0x801129d4,%eax
80101077:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107a:	72 c9                	jb     80101045 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 40 20 11 80       	push   $0x80112040
80101084:	e8 b4 3f 00 00       	call   8010503d <release>
80101089:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101091:	c9                   	leave  
80101092:	c3                   	ret    

80101093 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101093:	55                   	push   %ebp
80101094:	89 e5                	mov    %esp,%ebp
80101096:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101099:	83 ec 0c             	sub    $0xc,%esp
8010109c:	68 40 20 11 80       	push   $0x80112040
801010a1:	e8 29 3f 00 00       	call   80104fcf <acquire>
801010a6:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a9:	8b 45 08             	mov    0x8(%ebp),%eax
801010ac:	8b 40 04             	mov    0x4(%eax),%eax
801010af:	85 c0                	test   %eax,%eax
801010b1:	7f 0d                	jg     801010c0 <filedup+0x2d>
    panic("filedup");
801010b3:	83 ec 0c             	sub    $0xc,%esp
801010b6:	68 05 8b 10 80       	push   $0x80108b05
801010bb:	e8 e0 f4 ff ff       	call   801005a0 <panic>
  f->ref++;
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	8b 40 04             	mov    0x4(%eax),%eax
801010c6:	8d 50 01             	lea    0x1(%eax),%edx
801010c9:	8b 45 08             	mov    0x8(%ebp),%eax
801010cc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010cf:	83 ec 0c             	sub    $0xc,%esp
801010d2:	68 40 20 11 80       	push   $0x80112040
801010d7:	e8 61 3f 00 00       	call   8010503d <release>
801010dc:	83 c4 10             	add    $0x10,%esp
  return f;
801010df:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e2:	c9                   	leave  
801010e3:	c3                   	ret    

801010e4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e4:	55                   	push   %ebp
801010e5:	89 e5                	mov    %esp,%ebp
801010e7:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ea:	83 ec 0c             	sub    $0xc,%esp
801010ed:	68 40 20 11 80       	push   $0x80112040
801010f2:	e8 d8 3e 00 00       	call   80104fcf <acquire>
801010f7:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010fa:	8b 45 08             	mov    0x8(%ebp),%eax
801010fd:	8b 40 04             	mov    0x4(%eax),%eax
80101100:	85 c0                	test   %eax,%eax
80101102:	7f 0d                	jg     80101111 <fileclose+0x2d>
    panic("fileclose");
80101104:	83 ec 0c             	sub    $0xc,%esp
80101107:	68 0d 8b 10 80       	push   $0x80108b0d
8010110c:	e8 8f f4 ff ff       	call   801005a0 <panic>
  if(--f->ref > 0){
80101111:	8b 45 08             	mov    0x8(%ebp),%eax
80101114:	8b 40 04             	mov    0x4(%eax),%eax
80101117:	8d 50 ff             	lea    -0x1(%eax),%edx
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	89 50 04             	mov    %edx,0x4(%eax)
80101120:	8b 45 08             	mov    0x8(%ebp),%eax
80101123:	8b 40 04             	mov    0x4(%eax),%eax
80101126:	85 c0                	test   %eax,%eax
80101128:	7e 15                	jle    8010113f <fileclose+0x5b>
    release(&ftable.lock);
8010112a:	83 ec 0c             	sub    $0xc,%esp
8010112d:	68 40 20 11 80       	push   $0x80112040
80101132:	e8 06 3f 00 00       	call   8010503d <release>
80101137:	83 c4 10             	add    $0x10,%esp
8010113a:	e9 8b 00 00 00       	jmp    801011ca <fileclose+0xe6>
    return;
  }
  ff = *f;
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 10                	mov    (%eax),%edx
80101144:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101147:	8b 50 04             	mov    0x4(%eax),%edx
8010114a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010114d:	8b 50 08             	mov    0x8(%eax),%edx
80101150:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101153:	8b 50 0c             	mov    0xc(%eax),%edx
80101156:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101159:	8b 50 10             	mov    0x10(%eax),%edx
8010115c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010115f:	8b 40 14             	mov    0x14(%eax),%eax
80101162:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101165:	8b 45 08             	mov    0x8(%ebp),%eax
80101168:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010116f:	8b 45 08             	mov    0x8(%ebp),%eax
80101172:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101178:	83 ec 0c             	sub    $0xc,%esp
8010117b:	68 40 20 11 80       	push   $0x80112040
80101180:	e8 b8 3e 00 00       	call   8010503d <release>
80101185:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101188:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010118b:	83 f8 01             	cmp    $0x1,%eax
8010118e:	75 19                	jne    801011a9 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101190:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101194:	0f be d0             	movsbl %al,%edx
80101197:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010119a:	83 ec 08             	sub    $0x8,%esp
8010119d:	52                   	push   %edx
8010119e:	50                   	push   %eax
8010119f:	e8 a6 2d 00 00       	call   80103f4a <pipeclose>
801011a4:	83 c4 10             	add    $0x10,%esp
801011a7:	eb 21                	jmp    801011ca <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011ac:	83 f8 02             	cmp    $0x2,%eax
801011af:	75 19                	jne    801011ca <fileclose+0xe6>
    begin_op();
801011b1:	e8 b2 23 00 00       	call   80103568 <begin_op>
    iput(ff.ip);
801011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b9:	83 ec 0c             	sub    $0xc,%esp
801011bc:	50                   	push   %eax
801011bd:	e8 e2 09 00 00       	call   80101ba4 <iput>
801011c2:	83 c4 10             	add    $0x10,%esp
    end_op();
801011c5:	e8 2a 24 00 00       	call   801035f4 <end_op>
  }
}
801011ca:	c9                   	leave  
801011cb:	c3                   	ret    

801011cc <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011cc:	55                   	push   %ebp
801011cd:	89 e5                	mov    %esp,%ebp
801011cf:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011d2:	8b 45 08             	mov    0x8(%ebp),%eax
801011d5:	8b 00                	mov    (%eax),%eax
801011d7:	83 f8 02             	cmp    $0x2,%eax
801011da:	75 40                	jne    8010121c <filestat+0x50>
    ilock(f->ip);
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 40 10             	mov    0x10(%eax),%eax
801011e2:	83 ec 0c             	sub    $0xc,%esp
801011e5:	50                   	push   %eax
801011e6:	e8 58 08 00 00       	call   80101a43 <ilock>
801011eb:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 40 10             	mov    0x10(%eax),%eax
801011f4:	83 ec 08             	sub    $0x8,%esp
801011f7:	ff 75 0c             	pushl  0xc(%ebp)
801011fa:	50                   	push   %eax
801011fb:	e8 ee 0c 00 00       	call   80101eee <stati>
80101200:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101203:	8b 45 08             	mov    0x8(%ebp),%eax
80101206:	8b 40 10             	mov    0x10(%eax),%eax
80101209:	83 ec 0c             	sub    $0xc,%esp
8010120c:	50                   	push   %eax
8010120d:	e8 44 09 00 00       	call   80101b56 <iunlock>
80101212:	83 c4 10             	add    $0x10,%esp
    return 0;
80101215:	b8 00 00 00 00       	mov    $0x0,%eax
8010121a:	eb 05                	jmp    80101221 <filestat+0x55>
  }
  return -1;
8010121c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101221:	c9                   	leave  
80101222:	c3                   	ret    

80101223 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101223:	55                   	push   %ebp
80101224:	89 e5                	mov    %esp,%ebp
80101226:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101229:	8b 45 08             	mov    0x8(%ebp),%eax
8010122c:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101230:	84 c0                	test   %al,%al
80101232:	75 0a                	jne    8010123e <fileread+0x1b>
    return -1;
80101234:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101239:	e9 9b 00 00 00       	jmp    801012d9 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 00                	mov    (%eax),%eax
80101243:	83 f8 01             	cmp    $0x1,%eax
80101246:	75 1a                	jne    80101262 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 0c             	mov    0xc(%eax),%eax
8010124e:	83 ec 04             	sub    $0x4,%esp
80101251:	ff 75 10             	pushl  0x10(%ebp)
80101254:	ff 75 0c             	pushl  0xc(%ebp)
80101257:	50                   	push   %eax
80101258:	e8 94 2e 00 00       	call   801040f1 <piperead>
8010125d:	83 c4 10             	add    $0x10,%esp
80101260:	eb 77                	jmp    801012d9 <fileread+0xb6>
  if(f->type == FD_INODE){
80101262:	8b 45 08             	mov    0x8(%ebp),%eax
80101265:	8b 00                	mov    (%eax),%eax
80101267:	83 f8 02             	cmp    $0x2,%eax
8010126a:	75 60                	jne    801012cc <fileread+0xa9>
    ilock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 c8 07 00 00       	call   80101a43 <ilock>
8010127b:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010127e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	8b 50 14             	mov    0x14(%eax),%edx
80101287:	8b 45 08             	mov    0x8(%ebp),%eax
8010128a:	8b 40 10             	mov    0x10(%eax),%eax
8010128d:	51                   	push   %ecx
8010128e:	52                   	push   %edx
8010128f:	ff 75 0c             	pushl  0xc(%ebp)
80101292:	50                   	push   %eax
80101293:	e8 9c 0c 00 00       	call   80101f34 <readi>
80101298:	83 c4 10             	add    $0x10,%esp
8010129b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010129e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012a2:	7e 11                	jle    801012b5 <fileread+0x92>
      f->off += r;
801012a4:	8b 45 08             	mov    0x8(%ebp),%eax
801012a7:	8b 50 14             	mov    0x14(%eax),%edx
801012aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ad:	01 c2                	add    %eax,%edx
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 40 10             	mov    0x10(%eax),%eax
801012bb:	83 ec 0c             	sub    $0xc,%esp
801012be:	50                   	push   %eax
801012bf:	e8 92 08 00 00       	call   80101b56 <iunlock>
801012c4:	83 c4 10             	add    $0x10,%esp
    return r;
801012c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ca:	eb 0d                	jmp    801012d9 <fileread+0xb6>
  }
  panic("fileread");
801012cc:	83 ec 0c             	sub    $0xc,%esp
801012cf:	68 17 8b 10 80       	push   $0x80108b17
801012d4:	e8 c7 f2 ff ff       	call   801005a0 <panic>
}
801012d9:	c9                   	leave  
801012da:	c3                   	ret    

801012db <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012db:	55                   	push   %ebp
801012dc:	89 e5                	mov    %esp,%ebp
801012de:	53                   	push   %ebx
801012df:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012e9:	84 c0                	test   %al,%al
801012eb:	75 0a                	jne    801012f7 <filewrite+0x1c>
    return -1;
801012ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f2:	e9 1b 01 00 00       	jmp    80101412 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	8b 00                	mov    (%eax),%eax
801012fc:	83 f8 01             	cmp    $0x1,%eax
801012ff:	75 1d                	jne    8010131e <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101301:	8b 45 08             	mov    0x8(%ebp),%eax
80101304:	8b 40 0c             	mov    0xc(%eax),%eax
80101307:	83 ec 04             	sub    $0x4,%esp
8010130a:	ff 75 10             	pushl  0x10(%ebp)
8010130d:	ff 75 0c             	pushl  0xc(%ebp)
80101310:	50                   	push   %eax
80101311:	e8 de 2c 00 00       	call   80103ff4 <pipewrite>
80101316:	83 c4 10             	add    $0x10,%esp
80101319:	e9 f4 00 00 00       	jmp    80101412 <filewrite+0x137>
  if(f->type == FD_INODE){
8010131e:	8b 45 08             	mov    0x8(%ebp),%eax
80101321:	8b 00                	mov    (%eax),%eax
80101323:	83 f8 02             	cmp    $0x2,%eax
80101326:	0f 85 d9 00 00 00    	jne    80101405 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010132c:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101333:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010133a:	e9 a3 00 00 00       	jmp    801013e2 <filewrite+0x107>
      int n1 = n - i;
8010133f:	8b 45 10             	mov    0x10(%ebp),%eax
80101342:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101345:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010134b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010134e:	7e 06                	jle    80101356 <filewrite+0x7b>
        n1 = max;
80101350:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101353:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101356:	e8 0d 22 00 00       	call   80103568 <begin_op>
      ilock(f->ip);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 40 10             	mov    0x10(%eax),%eax
80101361:	83 ec 0c             	sub    $0xc,%esp
80101364:	50                   	push   %eax
80101365:	e8 d9 06 00 00       	call   80101a43 <ilock>
8010136a:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010136d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 50 14             	mov    0x14(%eax),%edx
80101376:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101379:	8b 45 0c             	mov    0xc(%ebp),%eax
8010137c:	01 c3                	add    %eax,%ebx
8010137e:	8b 45 08             	mov    0x8(%ebp),%eax
80101381:	8b 40 10             	mov    0x10(%eax),%eax
80101384:	51                   	push   %ecx
80101385:	52                   	push   %edx
80101386:	53                   	push   %ebx
80101387:	50                   	push   %eax
80101388:	e8 fe 0c 00 00       	call   8010208b <writei>
8010138d:	83 c4 10             	add    $0x10,%esp
80101390:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101393:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101397:	7e 11                	jle    801013aa <filewrite+0xcf>
        f->off += r;
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 50 14             	mov    0x14(%eax),%edx
8010139f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a2:	01 c2                	add    %eax,%edx
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013aa:	8b 45 08             	mov    0x8(%ebp),%eax
801013ad:	8b 40 10             	mov    0x10(%eax),%eax
801013b0:	83 ec 0c             	sub    $0xc,%esp
801013b3:	50                   	push   %eax
801013b4:	e8 9d 07 00 00       	call   80101b56 <iunlock>
801013b9:	83 c4 10             	add    $0x10,%esp
      end_op();
801013bc:	e8 33 22 00 00       	call   801035f4 <end_op>

      if(r < 0)
801013c1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013c5:	78 29                	js     801013f0 <filewrite+0x115>
        break;
      if(r != n1)
801013c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ca:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013cd:	74 0d                	je     801013dc <filewrite+0x101>
        panic("short filewrite");
801013cf:	83 ec 0c             	sub    $0xc,%esp
801013d2:	68 20 8b 10 80       	push   $0x80108b20
801013d7:	e8 c4 f1 ff ff       	call   801005a0 <panic>
      i += r;
801013dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013df:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013e8:	0f 8c 51 ff ff ff    	jl     8010133f <filewrite+0x64>
801013ee:	eb 01                	jmp    801013f1 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013f0:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f4:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f7:	75 05                	jne    801013fe <filewrite+0x123>
801013f9:	8b 45 10             	mov    0x10(%ebp),%eax
801013fc:	eb 14                	jmp    80101412 <filewrite+0x137>
801013fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101403:	eb 0d                	jmp    80101412 <filewrite+0x137>
  }
  panic("filewrite");
80101405:	83 ec 0c             	sub    $0xc,%esp
80101408:	68 30 8b 10 80       	push   $0x80108b30
8010140d:	e8 8e f1 ff ff       	call   801005a0 <panic>
}
80101412:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101415:	c9                   	leave  
80101416:	c3                   	ret    

80101417 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101417:	55                   	push   %ebp
80101418:	89 e5                	mov    %esp,%ebp
8010141a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010141d:	8b 45 08             	mov    0x8(%ebp),%eax
80101420:	83 ec 08             	sub    $0x8,%esp
80101423:	6a 01                	push   $0x1
80101425:	50                   	push   %eax
80101426:	e8 a3 ed ff ff       	call   801001ce <bread>
8010142b:	83 c4 10             	add    $0x10,%esp
8010142e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101434:	83 c0 5c             	add    $0x5c,%eax
80101437:	83 ec 04             	sub    $0x4,%esp
8010143a:	6a 1c                	push   $0x1c
8010143c:	50                   	push   %eax
8010143d:	ff 75 0c             	pushl  0xc(%ebp)
80101440:	e8 c0 3e 00 00       	call   80105305 <memmove>
80101445:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101448:	83 ec 0c             	sub    $0xc,%esp
8010144b:	ff 75 f4             	pushl  -0xc(%ebp)
8010144e:	e8 fd ed ff ff       	call   80100250 <brelse>
80101453:	83 c4 10             	add    $0x10,%esp
}
80101456:	90                   	nop
80101457:	c9                   	leave  
80101458:	c3                   	ret    

80101459 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101459:	55                   	push   %ebp
8010145a:	89 e5                	mov    %esp,%ebp
8010145c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010145f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101462:	8b 45 08             	mov    0x8(%ebp),%eax
80101465:	83 ec 08             	sub    $0x8,%esp
80101468:	52                   	push   %edx
80101469:	50                   	push   %eax
8010146a:	e8 5f ed ff ff       	call   801001ce <bread>
8010146f:	83 c4 10             	add    $0x10,%esp
80101472:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101478:	83 c0 5c             	add    $0x5c,%eax
8010147b:	83 ec 04             	sub    $0x4,%esp
8010147e:	68 00 02 00 00       	push   $0x200
80101483:	6a 00                	push   $0x0
80101485:	50                   	push   %eax
80101486:	e8 bb 3d 00 00       	call   80105246 <memset>
8010148b:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010148e:	83 ec 0c             	sub    $0xc,%esp
80101491:	ff 75 f4             	pushl  -0xc(%ebp)
80101494:	e8 07 23 00 00       	call   801037a0 <log_write>
80101499:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010149c:	83 ec 0c             	sub    $0xc,%esp
8010149f:	ff 75 f4             	pushl  -0xc(%ebp)
801014a2:	e8 a9 ed ff ff       	call   80100250 <brelse>
801014a7:	83 c4 10             	add    $0x10,%esp
}
801014aa:	90                   	nop
801014ab:	c9                   	leave  
801014ac:	c3                   	ret    

801014ad <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ad:	55                   	push   %ebp
801014ae:	89 e5                	mov    %esp,%ebp
801014b0:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014c1:	e9 13 01 00 00       	jmp    801015d9 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 0c             	sar    $0xc,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	a1 58 2a 11 80       	mov    0x80112a58,%eax
801014de:	01 d0                	add    %edx,%eax
801014e0:	83 ec 08             	sub    $0x8,%esp
801014e3:	50                   	push   %eax
801014e4:	ff 75 08             	pushl  0x8(%ebp)
801014e7:	e8 e2 ec ff ff       	call   801001ce <bread>
801014ec:	83 c4 10             	add    $0x10,%esp
801014ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014f9:	e9 a6 00 00 00       	jmp    801015a4 <balloc+0xf7>
      m = 1 << (bi % 8);
801014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101501:	99                   	cltd   
80101502:	c1 ea 1d             	shr    $0x1d,%edx
80101505:	01 d0                	add    %edx,%eax
80101507:	83 e0 07             	and    $0x7,%eax
8010150a:	29 d0                	sub    %edx,%eax
8010150c:	ba 01 00 00 00       	mov    $0x1,%edx
80101511:	89 c1                	mov    %eax,%ecx
80101513:	d3 e2                	shl    %cl,%edx
80101515:	89 d0                	mov    %edx,%eax
80101517:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151d:	8d 50 07             	lea    0x7(%eax),%edx
80101520:	85 c0                	test   %eax,%eax
80101522:	0f 48 c2             	cmovs  %edx,%eax
80101525:	c1 f8 03             	sar    $0x3,%eax
80101528:	89 c2                	mov    %eax,%edx
8010152a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010152d:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101532:	0f b6 c0             	movzbl %al,%eax
80101535:	23 45 e8             	and    -0x18(%ebp),%eax
80101538:	85 c0                	test   %eax,%eax
8010153a:	75 64                	jne    801015a0 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153f:	8d 50 07             	lea    0x7(%eax),%edx
80101542:	85 c0                	test   %eax,%eax
80101544:	0f 48 c2             	cmovs  %edx,%eax
80101547:	c1 f8 03             	sar    $0x3,%eax
8010154a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010154d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101552:	89 d1                	mov    %edx,%ecx
80101554:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101557:	09 ca                	or     %ecx,%edx
80101559:	89 d1                	mov    %edx,%ecx
8010155b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010155e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	ff 75 ec             	pushl  -0x14(%ebp)
80101568:	e8 33 22 00 00       	call   801037a0 <log_write>
8010156d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101570:	83 ec 0c             	sub    $0xc,%esp
80101573:	ff 75 ec             	pushl  -0x14(%ebp)
80101576:	e8 d5 ec ff ff       	call   80100250 <brelse>
8010157b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010157e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101581:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101584:	01 c2                	add    %eax,%edx
80101586:	8b 45 08             	mov    0x8(%ebp),%eax
80101589:	83 ec 08             	sub    $0x8,%esp
8010158c:	52                   	push   %edx
8010158d:	50                   	push   %eax
8010158e:	e8 c6 fe ff ff       	call   80101459 <bzero>
80101593:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101596:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101599:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159c:	01 d0                	add    %edx,%eax
8010159e:	eb 57                	jmp    801015f7 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015a0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015a4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015ab:	7f 17                	jg     801015c4 <balloc+0x117>
801015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b3:	01 d0                	add    %edx,%eax
801015b5:	89 c2                	mov    %eax,%edx
801015b7:	a1 40 2a 11 80       	mov    0x80112a40,%eax
801015bc:	39 c2                	cmp    %eax,%edx
801015be:	0f 82 3a ff ff ff    	jb     801014fe <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015c4:	83 ec 0c             	sub    $0xc,%esp
801015c7:	ff 75 ec             	pushl  -0x14(%ebp)
801015ca:	e8 81 ec ff ff       	call   80100250 <brelse>
801015cf:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015d2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015d9:	8b 15 40 2a 11 80    	mov    0x80112a40,%edx
801015df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e2:	39 c2                	cmp    %eax,%edx
801015e4:	0f 87 dc fe ff ff    	ja     801014c6 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015ea:	83 ec 0c             	sub    $0xc,%esp
801015ed:	68 3c 8b 10 80       	push   $0x80108b3c
801015f2:	e8 a9 ef ff ff       	call   801005a0 <panic>
}
801015f7:	c9                   	leave  
801015f8:	c3                   	ret    

801015f9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015f9:	55                   	push   %ebp
801015fa:	89 e5                	mov    %esp,%ebp
801015fc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ff:	83 ec 08             	sub    $0x8,%esp
80101602:	68 40 2a 11 80       	push   $0x80112a40
80101607:	ff 75 08             	pushl  0x8(%ebp)
8010160a:	e8 08 fe ff ff       	call   80101417 <readsb>
8010160f:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101612:	8b 45 0c             	mov    0xc(%ebp),%eax
80101615:	c1 e8 0c             	shr    $0xc,%eax
80101618:	89 c2                	mov    %eax,%edx
8010161a:	a1 58 2a 11 80       	mov    0x80112a58,%eax
8010161f:	01 c2                	add    %eax,%edx
80101621:	8b 45 08             	mov    0x8(%ebp),%eax
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	52                   	push   %edx
80101628:	50                   	push   %eax
80101629:	e8 a0 eb ff ff       	call   801001ce <bread>
8010162e:	83 c4 10             	add    $0x10,%esp
80101631:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101634:	8b 45 0c             	mov    0xc(%ebp),%eax
80101637:	25 ff 0f 00 00       	and    $0xfff,%eax
8010163c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101642:	99                   	cltd   
80101643:	c1 ea 1d             	shr    $0x1d,%edx
80101646:	01 d0                	add    %edx,%eax
80101648:	83 e0 07             	and    $0x7,%eax
8010164b:	29 d0                	sub    %edx,%eax
8010164d:	ba 01 00 00 00       	mov    $0x1,%edx
80101652:	89 c1                	mov    %eax,%ecx
80101654:	d3 e2                	shl    %cl,%edx
80101656:	89 d0                	mov    %edx,%eax
80101658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165e:	8d 50 07             	lea    0x7(%eax),%edx
80101661:	85 c0                	test   %eax,%eax
80101663:	0f 48 c2             	cmovs  %edx,%eax
80101666:	c1 f8 03             	sar    $0x3,%eax
80101669:	89 c2                	mov    %eax,%edx
8010166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101673:	0f b6 c0             	movzbl %al,%eax
80101676:	23 45 ec             	and    -0x14(%ebp),%eax
80101679:	85 c0                	test   %eax,%eax
8010167b:	75 0d                	jne    8010168a <bfree+0x91>
    panic("freeing free block");
8010167d:	83 ec 0c             	sub    $0xc,%esp
80101680:	68 52 8b 10 80       	push   $0x80108b52
80101685:	e8 16 ef ff ff       	call   801005a0 <panic>
  bp->data[bi/8] &= ~m;
8010168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168d:	8d 50 07             	lea    0x7(%eax),%edx
80101690:	85 c0                	test   %eax,%eax
80101692:	0f 48 c2             	cmovs  %edx,%eax
80101695:	c1 f8 03             	sar    $0x3,%eax
80101698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010169b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016a0:	89 d1                	mov    %edx,%ecx
801016a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016a5:	f7 d2                	not    %edx
801016a7:	21 ca                	and    %ecx,%edx
801016a9:	89 d1                	mov    %edx,%ecx
801016ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ae:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016b2:	83 ec 0c             	sub    $0xc,%esp
801016b5:	ff 75 f4             	pushl  -0xc(%ebp)
801016b8:	e8 e3 20 00 00       	call   801037a0 <log_write>
801016bd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016c0:	83 ec 0c             	sub    $0xc,%esp
801016c3:	ff 75 f4             	pushl  -0xc(%ebp)
801016c6:	e8 85 eb ff ff       	call   80100250 <brelse>
801016cb:	83 c4 10             	add    $0x10,%esp
}
801016ce:	90                   	nop
801016cf:	c9                   	leave  
801016d0:	c3                   	ret    

801016d1 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016d1:	55                   	push   %ebp
801016d2:	89 e5                	mov    %esp,%ebp
801016d4:	57                   	push   %edi
801016d5:	56                   	push   %esi
801016d6:	53                   	push   %ebx
801016d7:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016e1:	83 ec 08             	sub    $0x8,%esp
801016e4:	68 65 8b 10 80       	push   $0x80108b65
801016e9:	68 60 2a 11 80       	push   $0x80112a60
801016ee:	e8 ba 38 00 00       	call   80104fad <initlock>
801016f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016fd:	eb 2d                	jmp    8010172c <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101702:	89 d0                	mov    %edx,%eax
80101704:	c1 e0 03             	shl    $0x3,%eax
80101707:	01 d0                	add    %edx,%eax
80101709:	c1 e0 04             	shl    $0x4,%eax
8010170c:	83 c0 30             	add    $0x30,%eax
8010170f:	05 60 2a 11 80       	add    $0x80112a60,%eax
80101714:	83 c0 10             	add    $0x10,%eax
80101717:	83 ec 08             	sub    $0x8,%esp
8010171a:	68 6c 8b 10 80       	push   $0x80108b6c
8010171f:	50                   	push   %eax
80101720:	e8 2b 37 00 00       	call   80104e50 <initsleeplock>
80101725:	83 c4 10             	add    $0x10,%esp
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101728:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010172c:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101730:	7e cd                	jle    801016ff <iinit+0x2e>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101732:	83 ec 08             	sub    $0x8,%esp
80101735:	68 40 2a 11 80       	push   $0x80112a40
8010173a:	ff 75 08             	pushl  0x8(%ebp)
8010173d:	e8 d5 fc ff ff       	call   80101417 <readsb>
80101742:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101745:	a1 58 2a 11 80       	mov    0x80112a58,%eax
8010174a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010174d:	8b 3d 54 2a 11 80    	mov    0x80112a54,%edi
80101753:	8b 35 50 2a 11 80    	mov    0x80112a50,%esi
80101759:	8b 1d 4c 2a 11 80    	mov    0x80112a4c,%ebx
8010175f:	8b 0d 48 2a 11 80    	mov    0x80112a48,%ecx
80101765:	8b 15 44 2a 11 80    	mov    0x80112a44,%edx
8010176b:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101770:	ff 75 d4             	pushl  -0x2c(%ebp)
80101773:	57                   	push   %edi
80101774:	56                   	push   %esi
80101775:	53                   	push   %ebx
80101776:	51                   	push   %ecx
80101777:	52                   	push   %edx
80101778:	50                   	push   %eax
80101779:	68 74 8b 10 80       	push   $0x80108b74
8010177e:	e8 7d ec ff ff       	call   80100400 <cprintf>
80101783:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101786:	90                   	nop
80101787:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010178a:	5b                   	pop    %ebx
8010178b:	5e                   	pop    %esi
8010178c:	5f                   	pop    %edi
8010178d:	5d                   	pop    %ebp
8010178e:	c3                   	ret    

8010178f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010178f:	55                   	push   %ebp
80101790:	89 e5                	mov    %esp,%ebp
80101792:	83 ec 28             	sub    $0x28,%esp
80101795:	8b 45 0c             	mov    0xc(%ebp),%eax
80101798:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010179c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017a3:	e9 9e 00 00 00       	jmp    80101846 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ab:	c1 e8 03             	shr    $0x3,%eax
801017ae:	89 c2                	mov    %eax,%edx
801017b0:	a1 54 2a 11 80       	mov    0x80112a54,%eax
801017b5:	01 d0                	add    %edx,%eax
801017b7:	83 ec 08             	sub    $0x8,%esp
801017ba:	50                   	push   %eax
801017bb:	ff 75 08             	pushl  0x8(%ebp)
801017be:	e8 0b ea ff ff       	call   801001ce <bread>
801017c3:	83 c4 10             	add    $0x10,%esp
801017c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017cc:	8d 50 5c             	lea    0x5c(%eax),%edx
801017cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d2:	83 e0 07             	and    $0x7,%eax
801017d5:	c1 e0 06             	shl    $0x6,%eax
801017d8:	01 d0                	add    %edx,%eax
801017da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017e0:	0f b7 00             	movzwl (%eax),%eax
801017e3:	66 85 c0             	test   %ax,%ax
801017e6:	75 4c                	jne    80101834 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017e8:	83 ec 04             	sub    $0x4,%esp
801017eb:	6a 40                	push   $0x40
801017ed:	6a 00                	push   $0x0
801017ef:	ff 75 ec             	pushl  -0x14(%ebp)
801017f2:	e8 4f 3a 00 00       	call   80105246 <memset>
801017f7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017fd:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101801:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101804:	83 ec 0c             	sub    $0xc,%esp
80101807:	ff 75 f0             	pushl  -0x10(%ebp)
8010180a:	e8 91 1f 00 00       	call   801037a0 <log_write>
8010180f:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101812:	83 ec 0c             	sub    $0xc,%esp
80101815:	ff 75 f0             	pushl  -0x10(%ebp)
80101818:	e8 33 ea ff ff       	call   80100250 <brelse>
8010181d:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101823:	83 ec 08             	sub    $0x8,%esp
80101826:	50                   	push   %eax
80101827:	ff 75 08             	pushl  0x8(%ebp)
8010182a:	e8 f8 00 00 00       	call   80101927 <iget>
8010182f:	83 c4 10             	add    $0x10,%esp
80101832:	eb 30                	jmp    80101864 <ialloc+0xd5>
    }
    brelse(bp);
80101834:	83 ec 0c             	sub    $0xc,%esp
80101837:	ff 75 f0             	pushl  -0x10(%ebp)
8010183a:	e8 11 ea ff ff       	call   80100250 <brelse>
8010183f:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101842:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101846:	8b 15 48 2a 11 80    	mov    0x80112a48,%edx
8010184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184f:	39 c2                	cmp    %eax,%edx
80101851:	0f 87 51 ff ff ff    	ja     801017a8 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 c7 8b 10 80       	push   $0x80108bc7
8010185f:	e8 3c ed ff ff       	call   801005a0 <panic>
}
80101864:	c9                   	leave  
80101865:	c3                   	ret    

80101866 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101866:	55                   	push   %ebp
80101867:	89 e5                	mov    %esp,%ebp
80101869:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	8b 40 04             	mov    0x4(%eax),%eax
80101872:	c1 e8 03             	shr    $0x3,%eax
80101875:	89 c2                	mov    %eax,%edx
80101877:	a1 54 2a 11 80       	mov    0x80112a54,%eax
8010187c:	01 c2                	add    %eax,%edx
8010187e:	8b 45 08             	mov    0x8(%ebp),%eax
80101881:	8b 00                	mov    (%eax),%eax
80101883:	83 ec 08             	sub    $0x8,%esp
80101886:	52                   	push   %edx
80101887:	50                   	push   %eax
80101888:	e8 41 e9 ff ff       	call   801001ce <bread>
8010188d:	83 c4 10             	add    $0x10,%esp
80101890:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101896:	8d 50 5c             	lea    0x5c(%eax),%edx
80101899:	8b 45 08             	mov    0x8(%ebp),%eax
8010189c:	8b 40 04             	mov    0x4(%eax),%eax
8010189f:	83 e0 07             	and    $0x7,%eax
801018a2:	c1 e0 06             	shl    $0x6,%eax
801018a5:	01 d0                	add    %edx,%eax
801018a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018aa:	8b 45 08             	mov    0x8(%ebp),%eax
801018ad:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b4:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018b7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ba:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c1:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018c5:	8b 45 08             	mov    0x8(%ebp),%eax
801018c8:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cf:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018d3:	8b 45 08             	mov    0x8(%ebp),%eax
801018d6:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018dd:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018e1:	8b 45 08             	mov    0x8(%ebp),%eax
801018e4:	8b 50 58             	mov    0x58(%eax),%edx
801018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ea:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018ed:	8b 45 08             	mov    0x8(%ebp),%eax
801018f0:	8d 50 5c             	lea    0x5c(%eax),%edx
801018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f6:	83 c0 0c             	add    $0xc,%eax
801018f9:	83 ec 04             	sub    $0x4,%esp
801018fc:	6a 34                	push   $0x34
801018fe:	52                   	push   %edx
801018ff:	50                   	push   %eax
80101900:	e8 00 3a 00 00       	call   80105305 <memmove>
80101905:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101908:	83 ec 0c             	sub    $0xc,%esp
8010190b:	ff 75 f4             	pushl  -0xc(%ebp)
8010190e:	e8 8d 1e 00 00       	call   801037a0 <log_write>
80101913:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101916:	83 ec 0c             	sub    $0xc,%esp
80101919:	ff 75 f4             	pushl  -0xc(%ebp)
8010191c:	e8 2f e9 ff ff       	call   80100250 <brelse>
80101921:	83 c4 10             	add    $0x10,%esp
}
80101924:	90                   	nop
80101925:	c9                   	leave  
80101926:	c3                   	ret    

80101927 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101927:	55                   	push   %ebp
80101928:	89 e5                	mov    %esp,%ebp
8010192a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010192d:	83 ec 0c             	sub    $0xc,%esp
80101930:	68 60 2a 11 80       	push   $0x80112a60
80101935:	e8 95 36 00 00       	call   80104fcf <acquire>
8010193a:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010193d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101944:	c7 45 f4 94 2a 11 80 	movl   $0x80112a94,-0xc(%ebp)
8010194b:	eb 60                	jmp    801019ad <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010194d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101950:	8b 40 08             	mov    0x8(%eax),%eax
80101953:	85 c0                	test   %eax,%eax
80101955:	7e 39                	jle    80101990 <iget+0x69>
80101957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195a:	8b 00                	mov    (%eax),%eax
8010195c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010195f:	75 2f                	jne    80101990 <iget+0x69>
80101961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101964:	8b 40 04             	mov    0x4(%eax),%eax
80101967:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010196a:	75 24                	jne    80101990 <iget+0x69>
      ip->ref++;
8010196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196f:	8b 40 08             	mov    0x8(%eax),%eax
80101972:	8d 50 01             	lea    0x1(%eax),%edx
80101975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101978:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010197b:	83 ec 0c             	sub    $0xc,%esp
8010197e:	68 60 2a 11 80       	push   $0x80112a60
80101983:	e8 b5 36 00 00       	call   8010503d <release>
80101988:	83 c4 10             	add    $0x10,%esp
      return ip;
8010198b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198e:	eb 77                	jmp    80101a07 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101990:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101994:	75 10                	jne    801019a6 <iget+0x7f>
80101996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101999:	8b 40 08             	mov    0x8(%eax),%eax
8010199c:	85 c0                	test   %eax,%eax
8010199e:	75 06                	jne    801019a6 <iget+0x7f>
      empty = ip;
801019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019a6:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019ad:	81 7d f4 b4 46 11 80 	cmpl   $0x801146b4,-0xc(%ebp)
801019b4:	72 97                	jb     8010194d <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ba:	75 0d                	jne    801019c9 <iget+0xa2>
    panic("iget: no inodes");
801019bc:	83 ec 0c             	sub    $0xc,%esp
801019bf:	68 d9 8b 10 80       	push   $0x80108bd9
801019c4:	e8 d7 eb ff ff       	call   801005a0 <panic>

  ip = empty;
801019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d2:	8b 55 08             	mov    0x8(%ebp),%edx
801019d5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019da:	8b 55 0c             	mov    0xc(%ebp),%edx
801019dd:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ed:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019f4:	83 ec 0c             	sub    $0xc,%esp
801019f7:	68 60 2a 11 80       	push   $0x80112a60
801019fc:	e8 3c 36 00 00       	call   8010503d <release>
80101a01:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a07:	c9                   	leave  
80101a08:	c3                   	ret    

80101a09 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a09:	55                   	push   %ebp
80101a0a:	89 e5                	mov    %esp,%ebp
80101a0c:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a0f:	83 ec 0c             	sub    $0xc,%esp
80101a12:	68 60 2a 11 80       	push   $0x80112a60
80101a17:	e8 b3 35 00 00       	call   80104fcf <acquire>
80101a1c:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 08             	mov    0x8(%eax),%eax
80101a25:	8d 50 01             	lea    0x1(%eax),%edx
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a2e:	83 ec 0c             	sub    $0xc,%esp
80101a31:	68 60 2a 11 80       	push   $0x80112a60
80101a36:	e8 02 36 00 00       	call   8010503d <release>
80101a3b:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a41:	c9                   	leave  
80101a42:	c3                   	ret    

80101a43 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a43:	55                   	push   %ebp
80101a44:	89 e5                	mov    %esp,%ebp
80101a46:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a49:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a4d:	74 0a                	je     80101a59 <ilock+0x16>
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	8b 40 08             	mov    0x8(%eax),%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	7f 0d                	jg     80101a66 <ilock+0x23>
    panic("ilock");
80101a59:	83 ec 0c             	sub    $0xc,%esp
80101a5c:	68 e9 8b 10 80       	push   $0x80108be9
80101a61:	e8 3a eb ff ff       	call   801005a0 <panic>

  acquiresleep(&ip->lock);
80101a66:	8b 45 08             	mov    0x8(%ebp),%eax
80101a69:	83 c0 0c             	add    $0xc,%eax
80101a6c:	83 ec 0c             	sub    $0xc,%esp
80101a6f:	50                   	push   %eax
80101a70:	e8 17 34 00 00       	call   80104e8c <acquiresleep>
80101a75:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a7e:	85 c0                	test   %eax,%eax
80101a80:	0f 85 cd 00 00 00    	jne    80101b53 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a86:	8b 45 08             	mov    0x8(%ebp),%eax
80101a89:	8b 40 04             	mov    0x4(%eax),%eax
80101a8c:	c1 e8 03             	shr    $0x3,%eax
80101a8f:	89 c2                	mov    %eax,%edx
80101a91:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101a96:	01 c2                	add    %eax,%edx
80101a98:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9b:	8b 00                	mov    (%eax),%eax
80101a9d:	83 ec 08             	sub    $0x8,%esp
80101aa0:	52                   	push   %edx
80101aa1:	50                   	push   %eax
80101aa2:	e8 27 e7 ff ff       	call   801001ce <bread>
80101aa7:	83 c4 10             	add    $0x10,%esp
80101aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab0:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab6:	8b 40 04             	mov    0x4(%eax),%eax
80101ab9:	83 e0 07             	and    $0x7,%eax
80101abc:	c1 e0 06             	shl    $0x6,%eax
80101abf:	01 d0                	add    %edx,%eax
80101ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac7:	0f b7 10             	movzwl (%eax),%edx
80101aca:	8b 45 08             	mov    0x8(%ebp),%eax
80101acd:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad4:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae2:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae9:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af0:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101af4:	8b 45 08             	mov    0x8(%ebp),%eax
80101af7:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101afe:	8b 50 08             	mov    0x8(%eax),%edx
80101b01:	8b 45 08             	mov    0x8(%ebp),%eax
80101b04:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0a:	8d 50 0c             	lea    0xc(%eax),%edx
80101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b10:	83 c0 5c             	add    $0x5c,%eax
80101b13:	83 ec 04             	sub    $0x4,%esp
80101b16:	6a 34                	push   $0x34
80101b18:	52                   	push   %edx
80101b19:	50                   	push   %eax
80101b1a:	e8 e6 37 00 00       	call   80105305 <memmove>
80101b1f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b22:	83 ec 0c             	sub    $0xc,%esp
80101b25:	ff 75 f4             	pushl  -0xc(%ebp)
80101b28:	e8 23 e7 ff ff       	call   80100250 <brelse>
80101b2d:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b41:	66 85 c0             	test   %ax,%ax
80101b44:	75 0d                	jne    80101b53 <ilock+0x110>
      panic("ilock: no type");
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 ef 8b 10 80       	push   $0x80108bef
80101b4e:	e8 4d ea ff ff       	call   801005a0 <panic>
  }
}
80101b53:	90                   	nop
80101b54:	c9                   	leave  
80101b55:	c3                   	ret    

80101b56 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b56:	55                   	push   %ebp
80101b57:	89 e5                	mov    %esp,%ebp
80101b59:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b5c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b60:	74 20                	je     80101b82 <iunlock+0x2c>
80101b62:	8b 45 08             	mov    0x8(%ebp),%eax
80101b65:	83 c0 0c             	add    $0xc,%eax
80101b68:	83 ec 0c             	sub    $0xc,%esp
80101b6b:	50                   	push   %eax
80101b6c:	e8 cd 33 00 00       	call   80104f3e <holdingsleep>
80101b71:	83 c4 10             	add    $0x10,%esp
80101b74:	85 c0                	test   %eax,%eax
80101b76:	74 0a                	je     80101b82 <iunlock+0x2c>
80101b78:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7b:	8b 40 08             	mov    0x8(%eax),%eax
80101b7e:	85 c0                	test   %eax,%eax
80101b80:	7f 0d                	jg     80101b8f <iunlock+0x39>
    panic("iunlock");
80101b82:	83 ec 0c             	sub    $0xc,%esp
80101b85:	68 fe 8b 10 80       	push   $0x80108bfe
80101b8a:	e8 11 ea ff ff       	call   801005a0 <panic>

  releasesleep(&ip->lock);
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	83 c0 0c             	add    $0xc,%eax
80101b95:	83 ec 0c             	sub    $0xc,%esp
80101b98:	50                   	push   %eax
80101b99:	e8 52 33 00 00       	call   80104ef0 <releasesleep>
80101b9e:	83 c4 10             	add    $0x10,%esp
}
80101ba1:	90                   	nop
80101ba2:	c9                   	leave  
80101ba3:	c3                   	ret    

80101ba4 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101ba4:	55                   	push   %ebp
80101ba5:	89 e5                	mov    %esp,%ebp
80101ba7:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	83 c0 0c             	add    $0xc,%eax
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	50                   	push   %eax
80101bb4:	e8 d3 32 00 00       	call   80104e8c <acquiresleep>
80101bb9:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bc2:	85 c0                	test   %eax,%eax
80101bc4:	74 6a                	je     80101c30 <iput+0x8c>
80101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101bcd:	66 85 c0             	test   %ax,%ax
80101bd0:	75 5e                	jne    80101c30 <iput+0x8c>
    acquire(&icache.lock);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	68 60 2a 11 80       	push   $0x80112a60
80101bda:	e8 f0 33 00 00       	call   80104fcf <acquire>
80101bdf:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101be2:	8b 45 08             	mov    0x8(%ebp),%eax
80101be5:	8b 40 08             	mov    0x8(%eax),%eax
80101be8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101beb:	83 ec 0c             	sub    $0xc,%esp
80101bee:	68 60 2a 11 80       	push   $0x80112a60
80101bf3:	e8 45 34 00 00       	call   8010503d <release>
80101bf8:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101bfb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bff:	75 2f                	jne    80101c30 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c01:	83 ec 0c             	sub    $0xc,%esp
80101c04:	ff 75 08             	pushl  0x8(%ebp)
80101c07:	e8 b2 01 00 00       	call   80101dbe <itrunc>
80101c0c:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c12:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c18:	83 ec 0c             	sub    $0xc,%esp
80101c1b:	ff 75 08             	pushl  0x8(%ebp)
80101c1e:	e8 43 fc ff ff       	call   80101866 <iupdate>
80101c23:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c30:	8b 45 08             	mov    0x8(%ebp),%eax
80101c33:	83 c0 0c             	add    $0xc,%eax
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	50                   	push   %eax
80101c3a:	e8 b1 32 00 00       	call   80104ef0 <releasesleep>
80101c3f:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c42:	83 ec 0c             	sub    $0xc,%esp
80101c45:	68 60 2a 11 80       	push   $0x80112a60
80101c4a:	e8 80 33 00 00       	call   80104fcf <acquire>
80101c4f:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c52:	8b 45 08             	mov    0x8(%ebp),%eax
80101c55:	8b 40 08             	mov    0x8(%eax),%eax
80101c58:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c61:	83 ec 0c             	sub    $0xc,%esp
80101c64:	68 60 2a 11 80       	push   $0x80112a60
80101c69:	e8 cf 33 00 00       	call   8010503d <release>
80101c6e:	83 c4 10             	add    $0x10,%esp
}
80101c71:	90                   	nop
80101c72:	c9                   	leave  
80101c73:	c3                   	ret    

80101c74 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c74:	55                   	push   %ebp
80101c75:	89 e5                	mov    %esp,%ebp
80101c77:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c7a:	83 ec 0c             	sub    $0xc,%esp
80101c7d:	ff 75 08             	pushl  0x8(%ebp)
80101c80:	e8 d1 fe ff ff       	call   80101b56 <iunlock>
80101c85:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c88:	83 ec 0c             	sub    $0xc,%esp
80101c8b:	ff 75 08             	pushl  0x8(%ebp)
80101c8e:	e8 11 ff ff ff       	call   80101ba4 <iput>
80101c93:	83 c4 10             	add    $0x10,%esp
}
80101c96:	90                   	nop
80101c97:	c9                   	leave  
80101c98:	c3                   	ret    

80101c99 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c99:	55                   	push   %ebp
80101c9a:	89 e5                	mov    %esp,%ebp
80101c9c:	53                   	push   %ebx
80101c9d:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ca0:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101ca4:	77 42                	ja     80101ce8 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cac:	83 c2 14             	add    $0x14,%edx
80101caf:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cba:	75 24                	jne    80101ce0 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbf:	8b 00                	mov    (%eax),%eax
80101cc1:	83 ec 0c             	sub    $0xc,%esp
80101cc4:	50                   	push   %eax
80101cc5:	e8 e3 f7 ff ff       	call   801014ad <balloc>
80101cca:	83 c4 10             	add    $0x10,%esp
80101ccd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cd6:	8d 4a 14             	lea    0x14(%edx),%ecx
80101cd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cdc:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce3:	e9 d1 00 00 00       	jmp    80101db9 <bmap+0x120>
  }
  bn -= NDIRECT;
80101ce8:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cec:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cf0:	0f 87 b6 00 00 00    	ja     80101dac <bmap+0x113>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 20                	jne    80101d28 <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 97 f7 ff ff       	call   801014ad <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d22:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d28:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	83 ec 08             	sub    $0x8,%esp
80101d30:	ff 75 f4             	pushl  -0xc(%ebp)
80101d33:	50                   	push   %eax
80101d34:	e8 95 e4 ff ff       	call   801001ce <bread>
80101d39:	83 c4 10             	add    $0x10,%esp
80101d3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d42:	83 c0 5c             	add    $0x5c,%eax
80101d45:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d55:	01 d0                	add    %edx,%eax
80101d57:	8b 00                	mov    (%eax),%eax
80101d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d60:	75 37                	jne    80101d99 <bmap+0x100>
      a[bn] = addr = balloc(ip->dev);
80101d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d6f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	8b 00                	mov    (%eax),%eax
80101d77:	83 ec 0c             	sub    $0xc,%esp
80101d7a:	50                   	push   %eax
80101d7b:	e8 2d f7 ff ff       	call   801014ad <balloc>
80101d80:	83 c4 10             	add    $0x10,%esp
80101d83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d89:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d8b:	83 ec 0c             	sub    $0xc,%esp
80101d8e:	ff 75 f0             	pushl  -0x10(%ebp)
80101d91:	e8 0a 1a 00 00       	call   801037a0 <log_write>
80101d96:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d99:	83 ec 0c             	sub    $0xc,%esp
80101d9c:	ff 75 f0             	pushl  -0x10(%ebp)
80101d9f:	e8 ac e4 ff ff       	call   80100250 <brelse>
80101da4:	83 c4 10             	add    $0x10,%esp
    return addr;
80101da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101daa:	eb 0d                	jmp    80101db9 <bmap+0x120>
  }

  panic("bmap: out of range");
80101dac:	83 ec 0c             	sub    $0xc,%esp
80101daf:	68 06 8c 10 80       	push   $0x80108c06
80101db4:	e8 e7 e7 ff ff       	call   801005a0 <panic>
}
80101db9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101dbc:	c9                   	leave  
80101dbd:	c3                   	ret    

80101dbe <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101dbe:	55                   	push   %ebp
80101dbf:	89 e5                	mov    %esp,%ebp
80101dc1:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101dcb:	eb 45                	jmp    80101e12 <itrunc+0x54>
    if(ip->addrs[i]){
80101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd3:	83 c2 14             	add    $0x14,%edx
80101dd6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dda:	85 c0                	test   %eax,%eax
80101ddc:	74 30                	je     80101e0e <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101dde:	8b 45 08             	mov    0x8(%ebp),%eax
80101de1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101de4:	83 c2 14             	add    $0x14,%edx
80101de7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101deb:	8b 55 08             	mov    0x8(%ebp),%edx
80101dee:	8b 12                	mov    (%edx),%edx
80101df0:	83 ec 08             	sub    $0x8,%esp
80101df3:	50                   	push   %eax
80101df4:	52                   	push   %edx
80101df5:	e8 ff f7 ff ff       	call   801015f9 <bfree>
80101dfa:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101e00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e03:	83 c2 14             	add    $0x14,%edx
80101e06:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e0d:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e12:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e16:	7e b5                	jle    80101dcd <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e21:	85 c0                	test   %eax,%eax
80101e23:	0f 84 aa 00 00 00    	je     80101ed3 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e29:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2c:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e32:	8b 45 08             	mov    0x8(%ebp),%eax
80101e35:	8b 00                	mov    (%eax),%eax
80101e37:	83 ec 08             	sub    $0x8,%esp
80101e3a:	52                   	push   %edx
80101e3b:	50                   	push   %eax
80101e3c:	e8 8d e3 ff ff       	call   801001ce <bread>
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e4a:	83 c0 5c             	add    $0x5c,%eax
80101e4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e57:	eb 3c                	jmp    80101e95 <itrunc+0xd7>
      if(a[j])
80101e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e66:	01 d0                	add    %edx,%eax
80101e68:	8b 00                	mov    (%eax),%eax
80101e6a:	85 c0                	test   %eax,%eax
80101e6c:	74 23                	je     80101e91 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e7b:	01 d0                	add    %edx,%eax
80101e7d:	8b 00                	mov    (%eax),%eax
80101e7f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e82:	8b 12                	mov    (%edx),%edx
80101e84:	83 ec 08             	sub    $0x8,%esp
80101e87:	50                   	push   %eax
80101e88:	52                   	push   %edx
80101e89:	e8 6b f7 ff ff       	call   801015f9 <bfree>
80101e8e:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e91:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e98:	83 f8 7f             	cmp    $0x7f,%eax
80101e9b:	76 bc                	jbe    80101e59 <itrunc+0x9b>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e9d:	83 ec 0c             	sub    $0xc,%esp
80101ea0:	ff 75 ec             	pushl  -0x14(%ebp)
80101ea3:	e8 a8 e3 ff ff       	call   80100250 <brelse>
80101ea8:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101eab:	8b 45 08             	mov    0x8(%ebp),%eax
80101eae:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eb4:	8b 55 08             	mov    0x8(%ebp),%edx
80101eb7:	8b 12                	mov    (%edx),%edx
80101eb9:	83 ec 08             	sub    $0x8,%esp
80101ebc:	50                   	push   %eax
80101ebd:	52                   	push   %edx
80101ebe:	e8 36 f7 ff ff       	call   801015f9 <bfree>
80101ec3:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ed0:	00 00 00 
  }

  ip->size = 0;
80101ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed6:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101edd:	83 ec 0c             	sub    $0xc,%esp
80101ee0:	ff 75 08             	pushl  0x8(%ebp)
80101ee3:	e8 7e f9 ff ff       	call   80101866 <iupdate>
80101ee8:	83 c4 10             	add    $0x10,%esp
}
80101eeb:	90                   	nop
80101eec:	c9                   	leave  
80101eed:	c3                   	ret    

80101eee <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101eee:	55                   	push   %ebp
80101eef:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	8b 00                	mov    (%eax),%eax
80101ef6:	89 c2                	mov    %eax,%edx
80101ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101efb:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101efe:	8b 45 08             	mov    0x8(%ebp),%eax
80101f01:	8b 50 04             	mov    0x4(%eax),%edx
80101f04:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f07:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f11:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f14:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f17:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f21:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	8b 50 58             	mov    0x58(%eax),%edx
80101f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f31:	90                   	nop
80101f32:	5d                   	pop    %ebp
80101f33:	c3                   	ret    

80101f34 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f34:	55                   	push   %ebp
80101f35:	89 e5                	mov    %esp,%ebp
80101f37:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f41:	66 83 f8 03          	cmp    $0x3,%ax
80101f45:	75 5c                	jne    80101fa3 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f4e:	66 85 c0             	test   %ax,%ax
80101f51:	78 20                	js     80101f73 <readi+0x3f>
80101f53:	8b 45 08             	mov    0x8(%ebp),%eax
80101f56:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f5a:	66 83 f8 09          	cmp    $0x9,%ax
80101f5e:	7f 13                	jg     80101f73 <readi+0x3f>
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f67:	98                   	cwtl   
80101f68:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
80101f6f:	85 c0                	test   %eax,%eax
80101f71:	75 0a                	jne    80101f7d <readi+0x49>
      return -1;
80101f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f78:	e9 0c 01 00 00       	jmp    80102089 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f84:	98                   	cwtl   
80101f85:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
80101f8c:	8b 55 14             	mov    0x14(%ebp),%edx
80101f8f:	83 ec 04             	sub    $0x4,%esp
80101f92:	52                   	push   %edx
80101f93:	ff 75 0c             	pushl  0xc(%ebp)
80101f96:	ff 75 08             	pushl  0x8(%ebp)
80101f99:	ff d0                	call   *%eax
80101f9b:	83 c4 10             	add    $0x10,%esp
80101f9e:	e9 e6 00 00 00       	jmp    80102089 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa6:	8b 40 58             	mov    0x58(%eax),%eax
80101fa9:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fac:	72 0d                	jb     80101fbb <readi+0x87>
80101fae:	8b 55 10             	mov    0x10(%ebp),%edx
80101fb1:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb4:	01 d0                	add    %edx,%eax
80101fb6:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fb9:	73 0a                	jae    80101fc5 <readi+0x91>
    return -1;
80101fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fc0:	e9 c4 00 00 00       	jmp    80102089 <readi+0x155>
  if(off + n > ip->size)
80101fc5:	8b 55 10             	mov    0x10(%ebp),%edx
80101fc8:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcb:	01 c2                	add    %eax,%edx
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 40 58             	mov    0x58(%eax),%eax
80101fd3:	39 c2                	cmp    %eax,%edx
80101fd5:	76 0c                	jbe    80101fe3 <readi+0xaf>
    n = ip->size - off;
80101fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fda:	8b 40 58             	mov    0x58(%eax),%eax
80101fdd:	2b 45 10             	sub    0x10(%ebp),%eax
80101fe0:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fe3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fea:	e9 8b 00 00 00       	jmp    8010207a <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fef:	8b 45 10             	mov    0x10(%ebp),%eax
80101ff2:	c1 e8 09             	shr    $0x9,%eax
80101ff5:	83 ec 08             	sub    $0x8,%esp
80101ff8:	50                   	push   %eax
80101ff9:	ff 75 08             	pushl  0x8(%ebp)
80101ffc:	e8 98 fc ff ff       	call   80101c99 <bmap>
80102001:	83 c4 10             	add    $0x10,%esp
80102004:	89 c2                	mov    %eax,%edx
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	8b 00                	mov    (%eax),%eax
8010200b:	83 ec 08             	sub    $0x8,%esp
8010200e:	52                   	push   %edx
8010200f:	50                   	push   %eax
80102010:	e8 b9 e1 ff ff       	call   801001ce <bread>
80102015:	83 c4 10             	add    $0x10,%esp
80102018:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010201b:	8b 45 10             	mov    0x10(%ebp),%eax
8010201e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102023:	ba 00 02 00 00       	mov    $0x200,%edx
80102028:	29 c2                	sub    %eax,%edx
8010202a:	8b 45 14             	mov    0x14(%ebp),%eax
8010202d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102030:	39 c2                	cmp    %eax,%edx
80102032:	0f 46 c2             	cmovbe %edx,%eax
80102035:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102038:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010203b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010203e:	8b 45 10             	mov    0x10(%ebp),%eax
80102041:	25 ff 01 00 00       	and    $0x1ff,%eax
80102046:	01 d0                	add    %edx,%eax
80102048:	83 ec 04             	sub    $0x4,%esp
8010204b:	ff 75 ec             	pushl  -0x14(%ebp)
8010204e:	50                   	push   %eax
8010204f:	ff 75 0c             	pushl  0xc(%ebp)
80102052:	e8 ae 32 00 00       	call   80105305 <memmove>
80102057:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010205a:	83 ec 0c             	sub    $0xc,%esp
8010205d:	ff 75 f0             	pushl  -0x10(%ebp)
80102060:	e8 eb e1 ff ff       	call   80100250 <brelse>
80102065:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102068:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010206b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010206e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102071:	01 45 10             	add    %eax,0x10(%ebp)
80102074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102077:	01 45 0c             	add    %eax,0xc(%ebp)
8010207a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010207d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102080:	0f 82 69 ff ff ff    	jb     80101fef <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102086:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102089:	c9                   	leave  
8010208a:	c3                   	ret    

8010208b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010208b:	55                   	push   %ebp
8010208c:	89 e5                	mov    %esp,%ebp
8010208e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102098:	66 83 f8 03          	cmp    $0x3,%ax
8010209c:	75 5c                	jne    801020fa <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020a5:	66 85 c0             	test   %ax,%ax
801020a8:	78 20                	js     801020ca <writei+0x3f>
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020b1:	66 83 f8 09          	cmp    $0x9,%ax
801020b5:	7f 13                	jg     801020ca <writei+0x3f>
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020be:	98                   	cwtl   
801020bf:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
801020c6:	85 c0                	test   %eax,%eax
801020c8:	75 0a                	jne    801020d4 <writei+0x49>
      return -1;
801020ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020cf:	e9 3d 01 00 00       	jmp    80102211 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
801020d4:	8b 45 08             	mov    0x8(%ebp),%eax
801020d7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020db:	98                   	cwtl   
801020dc:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
801020e3:	8b 55 14             	mov    0x14(%ebp),%edx
801020e6:	83 ec 04             	sub    $0x4,%esp
801020e9:	52                   	push   %edx
801020ea:	ff 75 0c             	pushl  0xc(%ebp)
801020ed:	ff 75 08             	pushl  0x8(%ebp)
801020f0:	ff d0                	call   *%eax
801020f2:	83 c4 10             	add    $0x10,%esp
801020f5:	e9 17 01 00 00       	jmp    80102211 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801020fa:	8b 45 08             	mov    0x8(%ebp),%eax
801020fd:	8b 40 58             	mov    0x58(%eax),%eax
80102100:	3b 45 10             	cmp    0x10(%ebp),%eax
80102103:	72 0d                	jb     80102112 <writei+0x87>
80102105:	8b 55 10             	mov    0x10(%ebp),%edx
80102108:	8b 45 14             	mov    0x14(%ebp),%eax
8010210b:	01 d0                	add    %edx,%eax
8010210d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102110:	73 0a                	jae    8010211c <writei+0x91>
    return -1;
80102112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102117:	e9 f5 00 00 00       	jmp    80102211 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010211c:	8b 55 10             	mov    0x10(%ebp),%edx
8010211f:	8b 45 14             	mov    0x14(%ebp),%eax
80102122:	01 d0                	add    %edx,%eax
80102124:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102129:	76 0a                	jbe    80102135 <writei+0xaa>
    return -1;
8010212b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102130:	e9 dc 00 00 00       	jmp    80102211 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102135:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010213c:	e9 99 00 00 00       	jmp    801021da <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102141:	8b 45 10             	mov    0x10(%ebp),%eax
80102144:	c1 e8 09             	shr    $0x9,%eax
80102147:	83 ec 08             	sub    $0x8,%esp
8010214a:	50                   	push   %eax
8010214b:	ff 75 08             	pushl  0x8(%ebp)
8010214e:	e8 46 fb ff ff       	call   80101c99 <bmap>
80102153:	83 c4 10             	add    $0x10,%esp
80102156:	89 c2                	mov    %eax,%edx
80102158:	8b 45 08             	mov    0x8(%ebp),%eax
8010215b:	8b 00                	mov    (%eax),%eax
8010215d:	83 ec 08             	sub    $0x8,%esp
80102160:	52                   	push   %edx
80102161:	50                   	push   %eax
80102162:	e8 67 e0 ff ff       	call   801001ce <bread>
80102167:	83 c4 10             	add    $0x10,%esp
8010216a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010216d:	8b 45 10             	mov    0x10(%ebp),%eax
80102170:	25 ff 01 00 00       	and    $0x1ff,%eax
80102175:	ba 00 02 00 00       	mov    $0x200,%edx
8010217a:	29 c2                	sub    %eax,%edx
8010217c:	8b 45 14             	mov    0x14(%ebp),%eax
8010217f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102182:	39 c2                	cmp    %eax,%edx
80102184:	0f 46 c2             	cmovbe %edx,%eax
80102187:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010218a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010218d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102190:	8b 45 10             	mov    0x10(%ebp),%eax
80102193:	25 ff 01 00 00       	and    $0x1ff,%eax
80102198:	01 d0                	add    %edx,%eax
8010219a:	83 ec 04             	sub    $0x4,%esp
8010219d:	ff 75 ec             	pushl  -0x14(%ebp)
801021a0:	ff 75 0c             	pushl  0xc(%ebp)
801021a3:	50                   	push   %eax
801021a4:	e8 5c 31 00 00       	call   80105305 <memmove>
801021a9:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021ac:	83 ec 0c             	sub    $0xc,%esp
801021af:	ff 75 f0             	pushl  -0x10(%ebp)
801021b2:	e8 e9 15 00 00       	call   801037a0 <log_write>
801021b7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021ba:	83 ec 0c             	sub    $0xc,%esp
801021bd:	ff 75 f0             	pushl  -0x10(%ebp)
801021c0:	e8 8b e0 ff ff       	call   80100250 <brelse>
801021c5:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021cb:	01 45 f4             	add    %eax,-0xc(%ebp)
801021ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d1:	01 45 10             	add    %eax,0x10(%ebp)
801021d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d7:	01 45 0c             	add    %eax,0xc(%ebp)
801021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021dd:	3b 45 14             	cmp    0x14(%ebp),%eax
801021e0:	0f 82 5b ff ff ff    	jb     80102141 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801021e6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021ea:	74 22                	je     8010220e <writei+0x183>
801021ec:	8b 45 08             	mov    0x8(%ebp),%eax
801021ef:	8b 40 58             	mov    0x58(%eax),%eax
801021f2:	3b 45 10             	cmp    0x10(%ebp),%eax
801021f5:	73 17                	jae    8010220e <writei+0x183>
    ip->size = off;
801021f7:	8b 45 08             	mov    0x8(%ebp),%eax
801021fa:	8b 55 10             	mov    0x10(%ebp),%edx
801021fd:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 08             	pushl  0x8(%ebp)
80102206:	e8 5b f6 ff ff       	call   80101866 <iupdate>
8010220b:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010220e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102211:	c9                   	leave  
80102212:	c3                   	ret    

80102213 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102213:	55                   	push   %ebp
80102214:	89 e5                	mov    %esp,%ebp
80102216:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102219:	83 ec 04             	sub    $0x4,%esp
8010221c:	6a 0e                	push   $0xe
8010221e:	ff 75 0c             	pushl  0xc(%ebp)
80102221:	ff 75 08             	pushl  0x8(%ebp)
80102224:	e8 72 31 00 00       	call   8010539b <strncmp>
80102229:	83 c4 10             	add    $0x10,%esp
}
8010222c:	c9                   	leave  
8010222d:	c3                   	ret    

8010222e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010222e:	55                   	push   %ebp
8010222f:	89 e5                	mov    %esp,%ebp
80102231:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102234:	8b 45 08             	mov    0x8(%ebp),%eax
80102237:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010223b:	66 83 f8 01          	cmp    $0x1,%ax
8010223f:	74 0d                	je     8010224e <dirlookup+0x20>
    panic("dirlookup not DIR");
80102241:	83 ec 0c             	sub    $0xc,%esp
80102244:	68 19 8c 10 80       	push   $0x80108c19
80102249:	e8 52 e3 ff ff       	call   801005a0 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010224e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102255:	eb 7b                	jmp    801022d2 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102257:	6a 10                	push   $0x10
80102259:	ff 75 f4             	pushl  -0xc(%ebp)
8010225c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225f:	50                   	push   %eax
80102260:	ff 75 08             	pushl  0x8(%ebp)
80102263:	e8 cc fc ff ff       	call   80101f34 <readi>
80102268:	83 c4 10             	add    $0x10,%esp
8010226b:	83 f8 10             	cmp    $0x10,%eax
8010226e:	74 0d                	je     8010227d <dirlookup+0x4f>
      panic("dirlookup read");
80102270:	83 ec 0c             	sub    $0xc,%esp
80102273:	68 2b 8c 10 80       	push   $0x80108c2b
80102278:	e8 23 e3 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
8010227d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102281:	66 85 c0             	test   %ax,%ax
80102284:	74 47                	je     801022cd <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102286:	83 ec 08             	sub    $0x8,%esp
80102289:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010228c:	83 c0 02             	add    $0x2,%eax
8010228f:	50                   	push   %eax
80102290:	ff 75 0c             	pushl  0xc(%ebp)
80102293:	e8 7b ff ff ff       	call   80102213 <namecmp>
80102298:	83 c4 10             	add    $0x10,%esp
8010229b:	85 c0                	test   %eax,%eax
8010229d:	75 2f                	jne    801022ce <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010229f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022a3:	74 08                	je     801022ad <dirlookup+0x7f>
        *poff = off;
801022a5:	8b 45 10             	mov    0x10(%ebp),%eax
801022a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022ab:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022ad:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022b1:	0f b7 c0             	movzwl %ax,%eax
801022b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022b7:	8b 45 08             	mov    0x8(%ebp),%eax
801022ba:	8b 00                	mov    (%eax),%eax
801022bc:	83 ec 08             	sub    $0x8,%esp
801022bf:	ff 75 f0             	pushl  -0x10(%ebp)
801022c2:	50                   	push   %eax
801022c3:	e8 5f f6 ff ff       	call   80101927 <iget>
801022c8:	83 c4 10             	add    $0x10,%esp
801022cb:	eb 19                	jmp    801022e6 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
801022cd:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801022ce:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022d2:	8b 45 08             	mov    0x8(%ebp),%eax
801022d5:	8b 40 58             	mov    0x58(%eax),%eax
801022d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801022db:	0f 87 76 ff ff ff    	ja     80102257 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801022e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022e6:	c9                   	leave  
801022e7:	c3                   	ret    

801022e8 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022e8:	55                   	push   %ebp
801022e9:	89 e5                	mov    %esp,%ebp
801022eb:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022ee:	83 ec 04             	sub    $0x4,%esp
801022f1:	6a 00                	push   $0x0
801022f3:	ff 75 0c             	pushl  0xc(%ebp)
801022f6:	ff 75 08             	pushl  0x8(%ebp)
801022f9:	e8 30 ff ff ff       	call   8010222e <dirlookup>
801022fe:	83 c4 10             	add    $0x10,%esp
80102301:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102304:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102308:	74 18                	je     80102322 <dirlink+0x3a>
    iput(ip);
8010230a:	83 ec 0c             	sub    $0xc,%esp
8010230d:	ff 75 f0             	pushl  -0x10(%ebp)
80102310:	e8 8f f8 ff ff       	call   80101ba4 <iput>
80102315:	83 c4 10             	add    $0x10,%esp
    return -1;
80102318:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010231d:	e9 9c 00 00 00       	jmp    801023be <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102322:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102329:	eb 39                	jmp    80102364 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232e:	6a 10                	push   $0x10
80102330:	50                   	push   %eax
80102331:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102334:	50                   	push   %eax
80102335:	ff 75 08             	pushl  0x8(%ebp)
80102338:	e8 f7 fb ff ff       	call   80101f34 <readi>
8010233d:	83 c4 10             	add    $0x10,%esp
80102340:	83 f8 10             	cmp    $0x10,%eax
80102343:	74 0d                	je     80102352 <dirlink+0x6a>
      panic("dirlink read");
80102345:	83 ec 0c             	sub    $0xc,%esp
80102348:	68 3a 8c 10 80       	push   $0x80108c3a
8010234d:	e8 4e e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
80102352:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102356:	66 85 c0             	test   %ax,%ax
80102359:	74 18                	je     80102373 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010235b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235e:	83 c0 10             	add    $0x10,%eax
80102361:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102364:	8b 45 08             	mov    0x8(%ebp),%eax
80102367:	8b 50 58             	mov    0x58(%eax),%edx
8010236a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236d:	39 c2                	cmp    %eax,%edx
8010236f:	77 ba                	ja     8010232b <dirlink+0x43>
80102371:	eb 01                	jmp    80102374 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102373:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102374:	83 ec 04             	sub    $0x4,%esp
80102377:	6a 0e                	push   $0xe
80102379:	ff 75 0c             	pushl  0xc(%ebp)
8010237c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010237f:	83 c0 02             	add    $0x2,%eax
80102382:	50                   	push   %eax
80102383:	e8 69 30 00 00       	call   801053f1 <strncpy>
80102388:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010238b:	8b 45 10             	mov    0x10(%ebp),%eax
8010238e:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102395:	6a 10                	push   $0x10
80102397:	50                   	push   %eax
80102398:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010239b:	50                   	push   %eax
8010239c:	ff 75 08             	pushl  0x8(%ebp)
8010239f:	e8 e7 fc ff ff       	call   8010208b <writei>
801023a4:	83 c4 10             	add    $0x10,%esp
801023a7:	83 f8 10             	cmp    $0x10,%eax
801023aa:	74 0d                	je     801023b9 <dirlink+0xd1>
    panic("dirlink");
801023ac:	83 ec 0c             	sub    $0xc,%esp
801023af:	68 47 8c 10 80       	push   $0x80108c47
801023b4:	e8 e7 e1 ff ff       	call   801005a0 <panic>

  return 0;
801023b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023be:	c9                   	leave  
801023bf:	c3                   	ret    

801023c0 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023c0:	55                   	push   %ebp
801023c1:	89 e5                	mov    %esp,%ebp
801023c3:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023c6:	eb 04                	jmp    801023cc <skipelem+0xc>
    path++;
801023c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023cc:	8b 45 08             	mov    0x8(%ebp),%eax
801023cf:	0f b6 00             	movzbl (%eax),%eax
801023d2:	3c 2f                	cmp    $0x2f,%al
801023d4:	74 f2                	je     801023c8 <skipelem+0x8>
    path++;
  if(*path == 0)
801023d6:	8b 45 08             	mov    0x8(%ebp),%eax
801023d9:	0f b6 00             	movzbl (%eax),%eax
801023dc:	84 c0                	test   %al,%al
801023de:	75 07                	jne    801023e7 <skipelem+0x27>
    return 0;
801023e0:	b8 00 00 00 00       	mov    $0x0,%eax
801023e5:	eb 7b                	jmp    80102462 <skipelem+0xa2>
  s = path;
801023e7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023ed:	eb 04                	jmp    801023f3 <skipelem+0x33>
    path++;
801023ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023f3:	8b 45 08             	mov    0x8(%ebp),%eax
801023f6:	0f b6 00             	movzbl (%eax),%eax
801023f9:	3c 2f                	cmp    $0x2f,%al
801023fb:	74 0a                	je     80102407 <skipelem+0x47>
801023fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102400:	0f b6 00             	movzbl (%eax),%eax
80102403:	84 c0                	test   %al,%al
80102405:	75 e8                	jne    801023ef <skipelem+0x2f>
    path++;
  len = path - s;
80102407:	8b 55 08             	mov    0x8(%ebp),%edx
8010240a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240d:	29 c2                	sub    %eax,%edx
8010240f:	89 d0                	mov    %edx,%eax
80102411:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102414:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102418:	7e 15                	jle    8010242f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010241a:	83 ec 04             	sub    $0x4,%esp
8010241d:	6a 0e                	push   $0xe
8010241f:	ff 75 f4             	pushl  -0xc(%ebp)
80102422:	ff 75 0c             	pushl  0xc(%ebp)
80102425:	e8 db 2e 00 00       	call   80105305 <memmove>
8010242a:	83 c4 10             	add    $0x10,%esp
8010242d:	eb 26                	jmp    80102455 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010242f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102432:	83 ec 04             	sub    $0x4,%esp
80102435:	50                   	push   %eax
80102436:	ff 75 f4             	pushl  -0xc(%ebp)
80102439:	ff 75 0c             	pushl  0xc(%ebp)
8010243c:	e8 c4 2e 00 00       	call   80105305 <memmove>
80102441:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102444:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010244a:	01 d0                	add    %edx,%eax
8010244c:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010244f:	eb 04                	jmp    80102455 <skipelem+0x95>
    path++;
80102451:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102455:	8b 45 08             	mov    0x8(%ebp),%eax
80102458:	0f b6 00             	movzbl (%eax),%eax
8010245b:	3c 2f                	cmp    $0x2f,%al
8010245d:	74 f2                	je     80102451 <skipelem+0x91>
    path++;
  return path;
8010245f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102462:	c9                   	leave  
80102463:	c3                   	ret    

80102464 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102464:	55                   	push   %ebp
80102465:	89 e5                	mov    %esp,%ebp
80102467:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010246a:	8b 45 08             	mov    0x8(%ebp),%eax
8010246d:	0f b6 00             	movzbl (%eax),%eax
80102470:	3c 2f                	cmp    $0x2f,%al
80102472:	75 17                	jne    8010248b <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102474:	83 ec 08             	sub    $0x8,%esp
80102477:	6a 01                	push   $0x1
80102479:	6a 01                	push   $0x1
8010247b:	e8 a7 f4 ff ff       	call   80101927 <iget>
80102480:	83 c4 10             	add    $0x10,%esp
80102483:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102486:	e9 ba 00 00 00       	jmp    80102545 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010248b:	e8 30 1e 00 00       	call   801042c0 <myproc>
80102490:	8b 40 68             	mov    0x68(%eax),%eax
80102493:	83 ec 0c             	sub    $0xc,%esp
80102496:	50                   	push   %eax
80102497:	e8 6d f5 ff ff       	call   80101a09 <idup>
8010249c:	83 c4 10             	add    $0x10,%esp
8010249f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024a2:	e9 9e 00 00 00       	jmp    80102545 <namex+0xe1>
    ilock(ip);
801024a7:	83 ec 0c             	sub    $0xc,%esp
801024aa:	ff 75 f4             	pushl  -0xc(%ebp)
801024ad:	e8 91 f5 ff ff       	call   80101a43 <ilock>
801024b2:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801024bc:	66 83 f8 01          	cmp    $0x1,%ax
801024c0:	74 18                	je     801024da <namex+0x76>
      iunlockput(ip);
801024c2:	83 ec 0c             	sub    $0xc,%esp
801024c5:	ff 75 f4             	pushl  -0xc(%ebp)
801024c8:	e8 a7 f7 ff ff       	call   80101c74 <iunlockput>
801024cd:	83 c4 10             	add    $0x10,%esp
      return 0;
801024d0:	b8 00 00 00 00       	mov    $0x0,%eax
801024d5:	e9 a7 00 00 00       	jmp    80102581 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
801024da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024de:	74 20                	je     80102500 <namex+0x9c>
801024e0:	8b 45 08             	mov    0x8(%ebp),%eax
801024e3:	0f b6 00             	movzbl (%eax),%eax
801024e6:	84 c0                	test   %al,%al
801024e8:	75 16                	jne    80102500 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024ea:	83 ec 0c             	sub    $0xc,%esp
801024ed:	ff 75 f4             	pushl  -0xc(%ebp)
801024f0:	e8 61 f6 ff ff       	call   80101b56 <iunlock>
801024f5:	83 c4 10             	add    $0x10,%esp
      return ip;
801024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fb:	e9 81 00 00 00       	jmp    80102581 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102500:	83 ec 04             	sub    $0x4,%esp
80102503:	6a 00                	push   $0x0
80102505:	ff 75 10             	pushl  0x10(%ebp)
80102508:	ff 75 f4             	pushl  -0xc(%ebp)
8010250b:	e8 1e fd ff ff       	call   8010222e <dirlookup>
80102510:	83 c4 10             	add    $0x10,%esp
80102513:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102516:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010251a:	75 15                	jne    80102531 <namex+0xcd>
      iunlockput(ip);
8010251c:	83 ec 0c             	sub    $0xc,%esp
8010251f:	ff 75 f4             	pushl  -0xc(%ebp)
80102522:	e8 4d f7 ff ff       	call   80101c74 <iunlockput>
80102527:	83 c4 10             	add    $0x10,%esp
      return 0;
8010252a:	b8 00 00 00 00       	mov    $0x0,%eax
8010252f:	eb 50                	jmp    80102581 <namex+0x11d>
    }
    iunlockput(ip);
80102531:	83 ec 0c             	sub    $0xc,%esp
80102534:	ff 75 f4             	pushl  -0xc(%ebp)
80102537:	e8 38 f7 ff ff       	call   80101c74 <iunlockput>
8010253c:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010253f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102542:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102545:	83 ec 08             	sub    $0x8,%esp
80102548:	ff 75 10             	pushl  0x10(%ebp)
8010254b:	ff 75 08             	pushl  0x8(%ebp)
8010254e:	e8 6d fe ff ff       	call   801023c0 <skipelem>
80102553:	83 c4 10             	add    $0x10,%esp
80102556:	89 45 08             	mov    %eax,0x8(%ebp)
80102559:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010255d:	0f 85 44 ff ff ff    	jne    801024a7 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102563:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102567:	74 15                	je     8010257e <namex+0x11a>
    iput(ip);
80102569:	83 ec 0c             	sub    $0xc,%esp
8010256c:	ff 75 f4             	pushl  -0xc(%ebp)
8010256f:	e8 30 f6 ff ff       	call   80101ba4 <iput>
80102574:	83 c4 10             	add    $0x10,%esp
    return 0;
80102577:	b8 00 00 00 00       	mov    $0x0,%eax
8010257c:	eb 03                	jmp    80102581 <namex+0x11d>
  }
  return ip;
8010257e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102581:	c9                   	leave  
80102582:	c3                   	ret    

80102583 <namei>:

struct inode*
namei(char *path)
{
80102583:	55                   	push   %ebp
80102584:	89 e5                	mov    %esp,%ebp
80102586:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102589:	83 ec 04             	sub    $0x4,%esp
8010258c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010258f:	50                   	push   %eax
80102590:	6a 00                	push   $0x0
80102592:	ff 75 08             	pushl  0x8(%ebp)
80102595:	e8 ca fe ff ff       	call   80102464 <namex>
8010259a:	83 c4 10             	add    $0x10,%esp
}
8010259d:	c9                   	leave  
8010259e:	c3                   	ret    

8010259f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010259f:	55                   	push   %ebp
801025a0:	89 e5                	mov    %esp,%ebp
801025a2:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025a5:	83 ec 04             	sub    $0x4,%esp
801025a8:	ff 75 0c             	pushl  0xc(%ebp)
801025ab:	6a 01                	push   $0x1
801025ad:	ff 75 08             	pushl  0x8(%ebp)
801025b0:	e8 af fe ff ff       	call   80102464 <namex>
801025b5:	83 c4 10             	add    $0x10,%esp
}
801025b8:	c9                   	leave  
801025b9:	c3                   	ret    

801025ba <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025ba:	55                   	push   %ebp
801025bb:	89 e5                	mov    %esp,%ebp
801025bd:	83 ec 14             	sub    $0x14,%esp
801025c0:	8b 45 08             	mov    0x8(%ebp),%eax
801025c3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025c7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801025cb:	89 c2                	mov    %eax,%edx
801025cd:	ec                   	in     (%dx),%al
801025ce:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801025d1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801025d5:	c9                   	leave  
801025d6:	c3                   	ret    

801025d7 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801025d7:	55                   	push   %ebp
801025d8:	89 e5                	mov    %esp,%ebp
801025da:	57                   	push   %edi
801025db:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025dc:	8b 55 08             	mov    0x8(%ebp),%edx
801025df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025e2:	8b 45 10             	mov    0x10(%ebp),%eax
801025e5:	89 cb                	mov    %ecx,%ebx
801025e7:	89 df                	mov    %ebx,%edi
801025e9:	89 c1                	mov    %eax,%ecx
801025eb:	fc                   	cld    
801025ec:	f3 6d                	rep insl (%dx),%es:(%edi)
801025ee:	89 c8                	mov    %ecx,%eax
801025f0:	89 fb                	mov    %edi,%ebx
801025f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025f5:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025f8:	90                   	nop
801025f9:	5b                   	pop    %ebx
801025fa:	5f                   	pop    %edi
801025fb:	5d                   	pop    %ebp
801025fc:	c3                   	ret    

801025fd <outb>:

static inline void
outb(ushort port, uchar data)
{
801025fd:	55                   	push   %ebp
801025fe:	89 e5                	mov    %esp,%ebp
80102600:	83 ec 08             	sub    $0x8,%esp
80102603:	8b 55 08             	mov    0x8(%ebp),%edx
80102606:	8b 45 0c             	mov    0xc(%ebp),%eax
80102609:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010260d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102610:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102614:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102618:	ee                   	out    %al,(%dx)
}
80102619:	90                   	nop
8010261a:	c9                   	leave  
8010261b:	c3                   	ret    

8010261c <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010261c:	55                   	push   %ebp
8010261d:	89 e5                	mov    %esp,%ebp
8010261f:	56                   	push   %esi
80102620:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102621:	8b 55 08             	mov    0x8(%ebp),%edx
80102624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102627:	8b 45 10             	mov    0x10(%ebp),%eax
8010262a:	89 cb                	mov    %ecx,%ebx
8010262c:	89 de                	mov    %ebx,%esi
8010262e:	89 c1                	mov    %eax,%ecx
80102630:	fc                   	cld    
80102631:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102633:	89 c8                	mov    %ecx,%eax
80102635:	89 f3                	mov    %esi,%ebx
80102637:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010263a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010263d:	90                   	nop
8010263e:	5b                   	pop    %ebx
8010263f:	5e                   	pop    %esi
80102640:	5d                   	pop    %ebp
80102641:	c3                   	ret    

80102642 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102642:	55                   	push   %ebp
80102643:	89 e5                	mov    %esp,%ebp
80102645:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102648:	90                   	nop
80102649:	68 f7 01 00 00       	push   $0x1f7
8010264e:	e8 67 ff ff ff       	call   801025ba <inb>
80102653:	83 c4 04             	add    $0x4,%esp
80102656:	0f b6 c0             	movzbl %al,%eax
80102659:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010265c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010265f:	25 c0 00 00 00       	and    $0xc0,%eax
80102664:	83 f8 40             	cmp    $0x40,%eax
80102667:	75 e0                	jne    80102649 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102669:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010266d:	74 11                	je     80102680 <idewait+0x3e>
8010266f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102672:	83 e0 21             	and    $0x21,%eax
80102675:	85 c0                	test   %eax,%eax
80102677:	74 07                	je     80102680 <idewait+0x3e>
    return -1;
80102679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010267e:	eb 05                	jmp    80102685 <idewait+0x43>
  return 0;
80102680:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102685:	c9                   	leave  
80102686:	c3                   	ret    

80102687 <ideinit>:

void
ideinit(void)
{
80102687:	55                   	push   %ebp
80102688:	89 e5                	mov    %esp,%ebp
8010268a:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010268d:	83 ec 08             	sub    $0x8,%esp
80102690:	68 4f 8c 10 80       	push   $0x80108c4f
80102695:	68 e0 c5 10 80       	push   $0x8010c5e0
8010269a:	e8 0e 29 00 00       	call   80104fad <initlock>
8010269f:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026a2:	a1 80 4d 11 80       	mov    0x80114d80,%eax
801026a7:	83 e8 01             	sub    $0x1,%eax
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	50                   	push   %eax
801026ae:	6a 0e                	push   $0xe
801026b0:	e8 a2 04 00 00       	call   80102b57 <ioapicenable>
801026b5:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801026b8:	83 ec 0c             	sub    $0xc,%esp
801026bb:	6a 00                	push   $0x0
801026bd:	e8 80 ff ff ff       	call   80102642 <idewait>
801026c2:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801026c5:	83 ec 08             	sub    $0x8,%esp
801026c8:	68 f0 00 00 00       	push   $0xf0
801026cd:	68 f6 01 00 00       	push   $0x1f6
801026d2:	e8 26 ff ff ff       	call   801025fd <outb>
801026d7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801026da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026e1:	eb 24                	jmp    80102707 <ideinit+0x80>
    if(inb(0x1f7) != 0){
801026e3:	83 ec 0c             	sub    $0xc,%esp
801026e6:	68 f7 01 00 00       	push   $0x1f7
801026eb:	e8 ca fe ff ff       	call   801025ba <inb>
801026f0:	83 c4 10             	add    $0x10,%esp
801026f3:	84 c0                	test   %al,%al
801026f5:	74 0c                	je     80102703 <ideinit+0x7c>
      havedisk1 = 1;
801026f7:	c7 05 18 c6 10 80 01 	movl   $0x1,0x8010c618
801026fe:	00 00 00 
      break;
80102701:	eb 0d                	jmp    80102710 <ideinit+0x89>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102703:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102707:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010270e:	7e d3                	jle    801026e3 <ideinit+0x5c>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102710:	83 ec 08             	sub    $0x8,%esp
80102713:	68 e0 00 00 00       	push   $0xe0
80102718:	68 f6 01 00 00       	push   $0x1f6
8010271d:	e8 db fe ff ff       	call   801025fd <outb>
80102722:	83 c4 10             	add    $0x10,%esp
}
80102725:	90                   	nop
80102726:	c9                   	leave  
80102727:	c3                   	ret    

80102728 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102728:	55                   	push   %ebp
80102729:	89 e5                	mov    %esp,%ebp
8010272b:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010272e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102732:	75 0d                	jne    80102741 <idestart+0x19>
    panic("idestart");
80102734:	83 ec 0c             	sub    $0xc,%esp
80102737:	68 53 8c 10 80       	push   $0x80108c53
8010273c:	e8 5f de ff ff       	call   801005a0 <panic>
  if(b->blockno >= FSSIZE)
80102741:	8b 45 08             	mov    0x8(%ebp),%eax
80102744:	8b 40 08             	mov    0x8(%eax),%eax
80102747:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010274c:	76 0d                	jbe    8010275b <idestart+0x33>
    panic("incorrect blockno");
8010274e:	83 ec 0c             	sub    $0xc,%esp
80102751:	68 5c 8c 10 80       	push   $0x80108c5c
80102756:	e8 45 de ff ff       	call   801005a0 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010275b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102762:	8b 45 08             	mov    0x8(%ebp),%eax
80102765:	8b 50 08             	mov    0x8(%eax),%edx
80102768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276b:	0f af c2             	imul   %edx,%eax
8010276e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102771:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102775:	75 07                	jne    8010277e <idestart+0x56>
80102777:	b8 20 00 00 00       	mov    $0x20,%eax
8010277c:	eb 05                	jmp    80102783 <idestart+0x5b>
8010277e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102783:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102786:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010278a:	75 07                	jne    80102793 <idestart+0x6b>
8010278c:	b8 30 00 00 00       	mov    $0x30,%eax
80102791:	eb 05                	jmp    80102798 <idestart+0x70>
80102793:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102798:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010279b:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010279f:	7e 0d                	jle    801027ae <idestart+0x86>
801027a1:	83 ec 0c             	sub    $0xc,%esp
801027a4:	68 53 8c 10 80       	push   $0x80108c53
801027a9:	e8 f2 dd ff ff       	call   801005a0 <panic>

  idewait(0);
801027ae:	83 ec 0c             	sub    $0xc,%esp
801027b1:	6a 00                	push   $0x0
801027b3:	e8 8a fe ff ff       	call   80102642 <idewait>
801027b8:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027bb:	83 ec 08             	sub    $0x8,%esp
801027be:	6a 00                	push   $0x0
801027c0:	68 f6 03 00 00       	push   $0x3f6
801027c5:	e8 33 fe ff ff       	call   801025fd <outb>
801027ca:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	0f b6 c0             	movzbl %al,%eax
801027d3:	83 ec 08             	sub    $0x8,%esp
801027d6:	50                   	push   %eax
801027d7:	68 f2 01 00 00       	push   $0x1f2
801027dc:	e8 1c fe ff ff       	call   801025fd <outb>
801027e1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801027e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f3 01 00 00       	push   $0x1f3
801027f3:	e8 05 fe ff ff       	call   801025fd <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027fe:	c1 f8 08             	sar    $0x8,%eax
80102801:	0f b6 c0             	movzbl %al,%eax
80102804:	83 ec 08             	sub    $0x8,%esp
80102807:	50                   	push   %eax
80102808:	68 f4 01 00 00       	push   $0x1f4
8010280d:	e8 eb fd ff ff       	call   801025fd <outb>
80102812:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102818:	c1 f8 10             	sar    $0x10,%eax
8010281b:	0f b6 c0             	movzbl %al,%eax
8010281e:	83 ec 08             	sub    $0x8,%esp
80102821:	50                   	push   %eax
80102822:	68 f5 01 00 00       	push   $0x1f5
80102827:	e8 d1 fd ff ff       	call   801025fd <outb>
8010282c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010282f:	8b 45 08             	mov    0x8(%ebp),%eax
80102832:	8b 40 04             	mov    0x4(%eax),%eax
80102835:	83 e0 01             	and    $0x1,%eax
80102838:	c1 e0 04             	shl    $0x4,%eax
8010283b:	89 c2                	mov    %eax,%edx
8010283d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102840:	c1 f8 18             	sar    $0x18,%eax
80102843:	83 e0 0f             	and    $0xf,%eax
80102846:	09 d0                	or     %edx,%eax
80102848:	83 c8 e0             	or     $0xffffffe0,%eax
8010284b:	0f b6 c0             	movzbl %al,%eax
8010284e:	83 ec 08             	sub    $0x8,%esp
80102851:	50                   	push   %eax
80102852:	68 f6 01 00 00       	push   $0x1f6
80102857:	e8 a1 fd ff ff       	call   801025fd <outb>
8010285c:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010285f:	8b 45 08             	mov    0x8(%ebp),%eax
80102862:	8b 00                	mov    (%eax),%eax
80102864:	83 e0 04             	and    $0x4,%eax
80102867:	85 c0                	test   %eax,%eax
80102869:	74 35                	je     801028a0 <idestart+0x178>
    outb(0x1f7, write_cmd);
8010286b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010286e:	0f b6 c0             	movzbl %al,%eax
80102871:	83 ec 08             	sub    $0x8,%esp
80102874:	50                   	push   %eax
80102875:	68 f7 01 00 00       	push   $0x1f7
8010287a:	e8 7e fd ff ff       	call   801025fd <outb>
8010287f:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102882:	8b 45 08             	mov    0x8(%ebp),%eax
80102885:	83 c0 5c             	add    $0x5c,%eax
80102888:	83 ec 04             	sub    $0x4,%esp
8010288b:	68 80 00 00 00       	push   $0x80
80102890:	50                   	push   %eax
80102891:	68 f0 01 00 00       	push   $0x1f0
80102896:	e8 81 fd ff ff       	call   8010261c <outsl>
8010289b:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010289e:	eb 17                	jmp    801028b7 <idestart+0x18f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
801028a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028a3:	0f b6 c0             	movzbl %al,%eax
801028a6:	83 ec 08             	sub    $0x8,%esp
801028a9:	50                   	push   %eax
801028aa:	68 f7 01 00 00       	push   $0x1f7
801028af:	e8 49 fd ff ff       	call   801025fd <outb>
801028b4:	83 c4 10             	add    $0x10,%esp
  }
}
801028b7:	90                   	nop
801028b8:	c9                   	leave  
801028b9:	c3                   	ret    

801028ba <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028ba:	55                   	push   %ebp
801028bb:	89 e5                	mov    %esp,%ebp
801028bd:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028c0:	83 ec 0c             	sub    $0xc,%esp
801028c3:	68 e0 c5 10 80       	push   $0x8010c5e0
801028c8:	e8 02 27 00 00       	call   80104fcf <acquire>
801028cd:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
801028d0:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801028d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028dc:	75 15                	jne    801028f3 <ideintr+0x39>
    release(&idelock);
801028de:	83 ec 0c             	sub    $0xc,%esp
801028e1:	68 e0 c5 10 80       	push   $0x8010c5e0
801028e6:	e8 52 27 00 00       	call   8010503d <release>
801028eb:	83 c4 10             	add    $0x10,%esp
    return;
801028ee:	e9 9a 00 00 00       	jmp    8010298d <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f6:	8b 40 58             	mov    0x58(%eax),%eax
801028f9:	a3 14 c6 10 80       	mov    %eax,0x8010c614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102901:	8b 00                	mov    (%eax),%eax
80102903:	83 e0 04             	and    $0x4,%eax
80102906:	85 c0                	test   %eax,%eax
80102908:	75 2d                	jne    80102937 <ideintr+0x7d>
8010290a:	83 ec 0c             	sub    $0xc,%esp
8010290d:	6a 01                	push   $0x1
8010290f:	e8 2e fd ff ff       	call   80102642 <idewait>
80102914:	83 c4 10             	add    $0x10,%esp
80102917:	85 c0                	test   %eax,%eax
80102919:	78 1c                	js     80102937 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010291b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291e:	83 c0 5c             	add    $0x5c,%eax
80102921:	83 ec 04             	sub    $0x4,%esp
80102924:	68 80 00 00 00       	push   $0x80
80102929:	50                   	push   %eax
8010292a:	68 f0 01 00 00       	push   $0x1f0
8010292f:	e8 a3 fc ff ff       	call   801025d7 <insl>
80102934:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293a:	8b 00                	mov    (%eax),%eax
8010293c:	83 c8 02             	or     $0x2,%eax
8010293f:	89 c2                	mov    %eax,%edx
80102941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102944:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102949:	8b 00                	mov    (%eax),%eax
8010294b:	83 e0 fb             	and    $0xfffffffb,%eax
8010294e:	89 c2                	mov    %eax,%edx
80102950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102953:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	ff 75 f4             	pushl  -0xc(%ebp)
8010295b:	e8 36 23 00 00       	call   80104c96 <wakeup>
80102960:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102963:	a1 14 c6 10 80       	mov    0x8010c614,%eax
80102968:	85 c0                	test   %eax,%eax
8010296a:	74 11                	je     8010297d <ideintr+0xc3>
    idestart(idequeue);
8010296c:	a1 14 c6 10 80       	mov    0x8010c614,%eax
80102971:	83 ec 0c             	sub    $0xc,%esp
80102974:	50                   	push   %eax
80102975:	e8 ae fd ff ff       	call   80102728 <idestart>
8010297a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010297d:	83 ec 0c             	sub    $0xc,%esp
80102980:	68 e0 c5 10 80       	push   $0x8010c5e0
80102985:	e8 b3 26 00 00       	call   8010503d <release>
8010298a:	83 c4 10             	add    $0x10,%esp
}
8010298d:	c9                   	leave  
8010298e:	c3                   	ret    

8010298f <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010298f:	55                   	push   %ebp
80102990:	89 e5                	mov    %esp,%ebp
80102992:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102995:	8b 45 08             	mov    0x8(%ebp),%eax
80102998:	83 c0 0c             	add    $0xc,%eax
8010299b:	83 ec 0c             	sub    $0xc,%esp
8010299e:	50                   	push   %eax
8010299f:	e8 9a 25 00 00       	call   80104f3e <holdingsleep>
801029a4:	83 c4 10             	add    $0x10,%esp
801029a7:	85 c0                	test   %eax,%eax
801029a9:	75 0d                	jne    801029b8 <iderw+0x29>
    panic("iderw: buf not locked");
801029ab:	83 ec 0c             	sub    $0xc,%esp
801029ae:	68 6e 8c 10 80       	push   $0x80108c6e
801029b3:	e8 e8 db ff ff       	call   801005a0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029b8:	8b 45 08             	mov    0x8(%ebp),%eax
801029bb:	8b 00                	mov    (%eax),%eax
801029bd:	83 e0 06             	and    $0x6,%eax
801029c0:	83 f8 02             	cmp    $0x2,%eax
801029c3:	75 0d                	jne    801029d2 <iderw+0x43>
    panic("iderw: nothing to do");
801029c5:	83 ec 0c             	sub    $0xc,%esp
801029c8:	68 84 8c 10 80       	push   $0x80108c84
801029cd:	e8 ce db ff ff       	call   801005a0 <panic>
  if(b->dev != 0 && !havedisk1)
801029d2:	8b 45 08             	mov    0x8(%ebp),%eax
801029d5:	8b 40 04             	mov    0x4(%eax),%eax
801029d8:	85 c0                	test   %eax,%eax
801029da:	74 16                	je     801029f2 <iderw+0x63>
801029dc:	a1 18 c6 10 80       	mov    0x8010c618,%eax
801029e1:	85 c0                	test   %eax,%eax
801029e3:	75 0d                	jne    801029f2 <iderw+0x63>
    panic("iderw: ide disk 1 not present");
801029e5:	83 ec 0c             	sub    $0xc,%esp
801029e8:	68 99 8c 10 80       	push   $0x80108c99
801029ed:	e8 ae db ff ff       	call   801005a0 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029f2:	83 ec 0c             	sub    $0xc,%esp
801029f5:	68 e0 c5 10 80       	push   $0x8010c5e0
801029fa:	e8 d0 25 00 00       	call   80104fcf <acquire>
801029ff:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a02:	8b 45 08             	mov    0x8(%ebp),%eax
80102a05:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a0c:	c7 45 f4 14 c6 10 80 	movl   $0x8010c614,-0xc(%ebp)
80102a13:	eb 0b                	jmp    80102a20 <iderw+0x91>
80102a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a18:	8b 00                	mov    (%eax),%eax
80102a1a:	83 c0 58             	add    $0x58,%eax
80102a1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a23:	8b 00                	mov    (%eax),%eax
80102a25:	85 c0                	test   %eax,%eax
80102a27:	75 ec                	jne    80102a15 <iderw+0x86>
    ;
  *pp = b;
80102a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a2f:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a31:	a1 14 c6 10 80       	mov    0x8010c614,%eax
80102a36:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a39:	75 23                	jne    80102a5e <iderw+0xcf>
    idestart(b);
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	ff 75 08             	pushl  0x8(%ebp)
80102a41:	e8 e2 fc ff ff       	call   80102728 <idestart>
80102a46:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a49:	eb 13                	jmp    80102a5e <iderw+0xcf>
    sleep(b, &idelock);
80102a4b:	83 ec 08             	sub    $0x8,%esp
80102a4e:	68 e0 c5 10 80       	push   $0x8010c5e0
80102a53:	ff 75 08             	pushl  0x8(%ebp)
80102a56:	e8 52 21 00 00       	call   80104bad <sleep>
80102a5b:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a61:	8b 00                	mov    (%eax),%eax
80102a63:	83 e0 06             	and    $0x6,%eax
80102a66:	83 f8 02             	cmp    $0x2,%eax
80102a69:	75 e0                	jne    80102a4b <iderw+0xbc>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a6b:	83 ec 0c             	sub    $0xc,%esp
80102a6e:	68 e0 c5 10 80       	push   $0x8010c5e0
80102a73:	e8 c5 25 00 00       	call   8010503d <release>
80102a78:	83 c4 10             	add    $0x10,%esp
}
80102a7b:	90                   	nop
80102a7c:	c9                   	leave  
80102a7d:	c3                   	ret    

80102a7e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a7e:	55                   	push   %ebp
80102a7f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a81:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102a86:	8b 55 08             	mov    0x8(%ebp),%edx
80102a89:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a8b:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102a90:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a93:	5d                   	pop    %ebp
80102a94:	c3                   	ret    

80102a95 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a98:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102a9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102aa0:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102aa2:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aaa:	89 50 10             	mov    %edx,0x10(%eax)
}
80102aad:	90                   	nop
80102aae:	5d                   	pop    %ebp
80102aaf:	c3                   	ret    

80102ab0 <ioapicinit>:

void
ioapicinit(void)
{
80102ab0:	55                   	push   %ebp
80102ab1:	89 e5                	mov    %esp,%ebp
80102ab3:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ab6:	c7 05 b4 46 11 80 00 	movl   $0xfec00000,0x801146b4
80102abd:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102ac0:	6a 01                	push   $0x1
80102ac2:	e8 b7 ff ff ff       	call   80102a7e <ioapicread>
80102ac7:	83 c4 04             	add    $0x4,%esp
80102aca:	c1 e8 10             	shr    $0x10,%eax
80102acd:	25 ff 00 00 00       	and    $0xff,%eax
80102ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102ad5:	6a 00                	push   $0x0
80102ad7:	e8 a2 ff ff ff       	call   80102a7e <ioapicread>
80102adc:	83 c4 04             	add    $0x4,%esp
80102adf:	c1 e8 18             	shr    $0x18,%eax
80102ae2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102ae5:	0f b6 05 e0 47 11 80 	movzbl 0x801147e0,%eax
80102aec:	0f b6 c0             	movzbl %al,%eax
80102aef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102af2:	74 10                	je     80102b04 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102af4:	83 ec 0c             	sub    $0xc,%esp
80102af7:	68 b8 8c 10 80       	push   $0x80108cb8
80102afc:	e8 ff d8 ff ff       	call   80100400 <cprintf>
80102b01:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b0b:	eb 3f                	jmp    80102b4c <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b10:	83 c0 20             	add    $0x20,%eax
80102b13:	0d 00 00 01 00       	or     $0x10000,%eax
80102b18:	89 c2                	mov    %eax,%edx
80102b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1d:	83 c0 08             	add    $0x8,%eax
80102b20:	01 c0                	add    %eax,%eax
80102b22:	83 ec 08             	sub    $0x8,%esp
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 69 ff ff ff       	call   80102a95 <ioapicwrite>
80102b2c:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b32:	83 c0 08             	add    $0x8,%eax
80102b35:	01 c0                	add    %eax,%eax
80102b37:	83 c0 01             	add    $0x1,%eax
80102b3a:	83 ec 08             	sub    $0x8,%esp
80102b3d:	6a 00                	push   $0x0
80102b3f:	50                   	push   %eax
80102b40:	e8 50 ff ff ff       	call   80102a95 <ioapicwrite>
80102b45:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b52:	7e b9                	jle    80102b0d <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b54:	90                   	nop
80102b55:	c9                   	leave  
80102b56:	c3                   	ret    

80102b57 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b57:	55                   	push   %ebp
80102b58:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5d:	83 c0 20             	add    $0x20,%eax
80102b60:	89 c2                	mov    %eax,%edx
80102b62:	8b 45 08             	mov    0x8(%ebp),%eax
80102b65:	83 c0 08             	add    $0x8,%eax
80102b68:	01 c0                	add    %eax,%eax
80102b6a:	52                   	push   %edx
80102b6b:	50                   	push   %eax
80102b6c:	e8 24 ff ff ff       	call   80102a95 <ioapicwrite>
80102b71:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b74:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b77:	c1 e0 18             	shl    $0x18,%eax
80102b7a:	89 c2                	mov    %eax,%edx
80102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7f:	83 c0 08             	add    $0x8,%eax
80102b82:	01 c0                	add    %eax,%eax
80102b84:	83 c0 01             	add    $0x1,%eax
80102b87:	52                   	push   %edx
80102b88:	50                   	push   %eax
80102b89:	e8 07 ff ff ff       	call   80102a95 <ioapicwrite>
80102b8e:	83 c4 08             	add    $0x8,%esp
}
80102b91:	90                   	nop
80102b92:	c9                   	leave  
80102b93:	c3                   	ret    

80102b94 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b94:	55                   	push   %ebp
80102b95:	89 e5                	mov    %esp,%ebp
80102b97:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b9a:	83 ec 08             	sub    $0x8,%esp
80102b9d:	68 ea 8c 10 80       	push   $0x80108cea
80102ba2:	68 c0 46 11 80       	push   $0x801146c0
80102ba7:	e8 01 24 00 00       	call   80104fad <initlock>
80102bac:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102baf:	c7 05 f4 46 11 80 00 	movl   $0x0,0x801146f4
80102bb6:	00 00 00 
  freerange(vstart, vend);
80102bb9:	83 ec 08             	sub    $0x8,%esp
80102bbc:	ff 75 0c             	pushl  0xc(%ebp)
80102bbf:	ff 75 08             	pushl  0x8(%ebp)
80102bc2:	e8 2a 00 00 00       	call   80102bf1 <freerange>
80102bc7:	83 c4 10             	add    $0x10,%esp
}
80102bca:	90                   	nop
80102bcb:	c9                   	leave  
80102bcc:	c3                   	ret    

80102bcd <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bcd:	55                   	push   %ebp
80102bce:	89 e5                	mov    %esp,%ebp
80102bd0:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102bd3:	83 ec 08             	sub    $0x8,%esp
80102bd6:	ff 75 0c             	pushl  0xc(%ebp)
80102bd9:	ff 75 08             	pushl  0x8(%ebp)
80102bdc:	e8 10 00 00 00       	call   80102bf1 <freerange>
80102be1:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102be4:	c7 05 f4 46 11 80 01 	movl   $0x1,0x801146f4
80102beb:	00 00 00 
}
80102bee:	90                   	nop
80102bef:	c9                   	leave  
80102bf0:	c3                   	ret    

80102bf1 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bf1:	55                   	push   %ebp
80102bf2:	89 e5                	mov    %esp,%ebp
80102bf4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfa:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c07:	eb 15                	jmp    80102c1e <freerange+0x2d>
    kfree(p);
80102c09:	83 ec 0c             	sub    $0xc,%esp
80102c0c:	ff 75 f4             	pushl  -0xc(%ebp)
80102c0f:	e8 1a 00 00 00       	call   80102c2e <kfree>
80102c14:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c17:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c21:	05 00 10 00 00       	add    $0x1000,%eax
80102c26:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c29:	76 de                	jbe    80102c09 <freerange+0x18>
    kfree(p);
}
80102c2b:	90                   	nop
80102c2c:	c9                   	leave  
80102c2d:	c3                   	ret    

80102c2e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c2e:	55                   	push   %ebp
80102c2f:	89 e5                	mov    %esp,%ebp
80102c31:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c34:	8b 45 08             	mov    0x8(%ebp),%eax
80102c37:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c3c:	85 c0                	test   %eax,%eax
80102c3e:	75 18                	jne    80102c58 <kfree+0x2a>
80102c40:	81 7d 08 74 7a 11 80 	cmpl   $0x80117a74,0x8(%ebp)
80102c47:	72 0f                	jb     80102c58 <kfree+0x2a>
80102c49:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4c:	05 00 00 00 80       	add    $0x80000000,%eax
80102c51:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c56:	76 0d                	jbe    80102c65 <kfree+0x37>
    panic("kfree");
80102c58:	83 ec 0c             	sub    $0xc,%esp
80102c5b:	68 ef 8c 10 80       	push   $0x80108cef
80102c60:	e8 3b d9 ff ff       	call   801005a0 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c65:	83 ec 04             	sub    $0x4,%esp
80102c68:	68 00 10 00 00       	push   $0x1000
80102c6d:	6a 01                	push   $0x1
80102c6f:	ff 75 08             	pushl  0x8(%ebp)
80102c72:	e8 cf 25 00 00       	call   80105246 <memset>
80102c77:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c7a:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102c7f:	85 c0                	test   %eax,%eax
80102c81:	74 10                	je     80102c93 <kfree+0x65>
    acquire(&kmem.lock);
80102c83:	83 ec 0c             	sub    $0xc,%esp
80102c86:	68 c0 46 11 80       	push   $0x801146c0
80102c8b:	e8 3f 23 00 00       	call   80104fcf <acquire>
80102c90:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c93:	8b 45 08             	mov    0x8(%ebp),%eax
80102c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c99:	8b 15 f8 46 11 80    	mov    0x801146f8,%edx
80102c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca7:	a3 f8 46 11 80       	mov    %eax,0x801146f8
  if(kmem.use_lock)
80102cac:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102cb1:	85 c0                	test   %eax,%eax
80102cb3:	74 10                	je     80102cc5 <kfree+0x97>
    release(&kmem.lock);
80102cb5:	83 ec 0c             	sub    $0xc,%esp
80102cb8:	68 c0 46 11 80       	push   $0x801146c0
80102cbd:	e8 7b 23 00 00       	call   8010503d <release>
80102cc2:	83 c4 10             	add    $0x10,%esp
}
80102cc5:	90                   	nop
80102cc6:	c9                   	leave  
80102cc7:	c3                   	ret    

80102cc8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cc8:	55                   	push   %ebp
80102cc9:	89 e5                	mov    %esp,%ebp
80102ccb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102cce:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102cd3:	85 c0                	test   %eax,%eax
80102cd5:	74 10                	je     80102ce7 <kalloc+0x1f>
    acquire(&kmem.lock);
80102cd7:	83 ec 0c             	sub    $0xc,%esp
80102cda:	68 c0 46 11 80       	push   $0x801146c0
80102cdf:	e8 eb 22 00 00       	call   80104fcf <acquire>
80102ce4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ce7:	a1 f8 46 11 80       	mov    0x801146f8,%eax
80102cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cf3:	74 0a                	je     80102cff <kalloc+0x37>
    kmem.freelist = r->next;
80102cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf8:	8b 00                	mov    (%eax),%eax
80102cfa:	a3 f8 46 11 80       	mov    %eax,0x801146f8
  if(kmem.use_lock)
80102cff:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102d04:	85 c0                	test   %eax,%eax
80102d06:	74 10                	je     80102d18 <kalloc+0x50>
    release(&kmem.lock);
80102d08:	83 ec 0c             	sub    $0xc,%esp
80102d0b:	68 c0 46 11 80       	push   $0x801146c0
80102d10:	e8 28 23 00 00       	call   8010503d <release>
80102d15:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d1b:	c9                   	leave  
80102d1c:	c3                   	ret    

80102d1d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d1d:	55                   	push   %ebp
80102d1e:	89 e5                	mov    %esp,%ebp
80102d20:	83 ec 14             	sub    $0x14,%esp
80102d23:	8b 45 08             	mov    0x8(%ebp),%eax
80102d26:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d2a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d2e:	89 c2                	mov    %eax,%edx
80102d30:	ec                   	in     (%dx),%al
80102d31:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d34:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d38:	c9                   	leave  
80102d39:	c3                   	ret    

80102d3a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
80102d3d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d40:	6a 64                	push   $0x64
80102d42:	e8 d6 ff ff ff       	call   80102d1d <inb>
80102d47:	83 c4 04             	add    $0x4,%esp
80102d4a:	0f b6 c0             	movzbl %al,%eax
80102d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d53:	83 e0 01             	and    $0x1,%eax
80102d56:	85 c0                	test   %eax,%eax
80102d58:	75 0a                	jne    80102d64 <kbdgetc+0x2a>
    return -1;
80102d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d5f:	e9 23 01 00 00       	jmp    80102e87 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d64:	6a 60                	push   $0x60
80102d66:	e8 b2 ff ff ff       	call   80102d1d <inb>
80102d6b:	83 c4 04             	add    $0x4,%esp
80102d6e:	0f b6 c0             	movzbl %al,%eax
80102d71:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d74:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d7b:	75 17                	jne    80102d94 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d7d:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102d82:	83 c8 40             	or     $0x40,%eax
80102d85:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
    return 0;
80102d8a:	b8 00 00 00 00       	mov    $0x0,%eax
80102d8f:	e9 f3 00 00 00       	jmp    80102e87 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d97:	25 80 00 00 00       	and    $0x80,%eax
80102d9c:	85 c0                	test   %eax,%eax
80102d9e:	74 45                	je     80102de5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102da0:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102da5:	83 e0 40             	and    $0x40,%eax
80102da8:	85 c0                	test   %eax,%eax
80102daa:	75 08                	jne    80102db4 <kbdgetc+0x7a>
80102dac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102daf:	83 e0 7f             	and    $0x7f,%eax
80102db2:	eb 03                	jmp    80102db7 <kbdgetc+0x7d>
80102db4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102dba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dbd:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102dc2:	0f b6 00             	movzbl (%eax),%eax
80102dc5:	83 c8 40             	or     $0x40,%eax
80102dc8:	0f b6 c0             	movzbl %al,%eax
80102dcb:	f7 d0                	not    %eax
80102dcd:	89 c2                	mov    %eax,%edx
80102dcf:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102dd4:	21 d0                	and    %edx,%eax
80102dd6:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
    return 0;
80102ddb:	b8 00 00 00 00       	mov    $0x0,%eax
80102de0:	e9 a2 00 00 00       	jmp    80102e87 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102de5:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102dea:	83 e0 40             	and    $0x40,%eax
80102ded:	85 c0                	test   %eax,%eax
80102def:	74 14                	je     80102e05 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102df1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102df8:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102dfd:	83 e0 bf             	and    $0xffffffbf,%eax
80102e00:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
  }

  shift |= shiftcode[data];
80102e05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e08:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e0d:	0f b6 00             	movzbl (%eax),%eax
80102e10:	0f b6 d0             	movzbl %al,%edx
80102e13:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102e18:	09 d0                	or     %edx,%eax
80102e1a:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
  shift ^= togglecode[data];
80102e1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e22:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e27:	0f b6 00             	movzbl (%eax),%eax
80102e2a:	0f b6 d0             	movzbl %al,%edx
80102e2d:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102e32:	31 d0                	xor    %edx,%eax
80102e34:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e39:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102e3e:	83 e0 03             	and    $0x3,%eax
80102e41:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e4b:	01 d0                	add    %edx,%eax
80102e4d:	0f b6 00             	movzbl (%eax),%eax
80102e50:	0f b6 c0             	movzbl %al,%eax
80102e53:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e56:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102e5b:	83 e0 08             	and    $0x8,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	74 22                	je     80102e84 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e62:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e66:	76 0c                	jbe    80102e74 <kbdgetc+0x13a>
80102e68:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e6c:	77 06                	ja     80102e74 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e6e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e72:	eb 10                	jmp    80102e84 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e74:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e78:	76 0a                	jbe    80102e84 <kbdgetc+0x14a>
80102e7a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e7e:	77 04                	ja     80102e84 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e80:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e87:	c9                   	leave  
80102e88:	c3                   	ret    

80102e89 <kbdintr>:

void
kbdintr(void)
{
80102e89:	55                   	push   %ebp
80102e8a:	89 e5                	mov    %esp,%ebp
80102e8c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e8f:	83 ec 0c             	sub    $0xc,%esp
80102e92:	68 3a 2d 10 80       	push   $0x80102d3a
80102e97:	e8 90 d9 ff ff       	call   8010082c <consoleintr>
80102e9c:	83 c4 10             	add    $0x10,%esp
}
80102e9f:	90                   	nop
80102ea0:	c9                   	leave  
80102ea1:	c3                   	ret    

80102ea2 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ea2:	55                   	push   %ebp
80102ea3:	89 e5                	mov    %esp,%ebp
80102ea5:	83 ec 14             	sub    $0x14,%esp
80102ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80102eab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eaf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102eb3:	89 c2                	mov    %eax,%edx
80102eb5:	ec                   	in     (%dx),%al
80102eb6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102eb9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ebd:	c9                   	leave  
80102ebe:	c3                   	ret    

80102ebf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
80102ec2:	83 ec 08             	sub    $0x8,%esp
80102ec5:	8b 55 08             	mov    0x8(%ebp),%edx
80102ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ecb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ecf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ed2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ed6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102eda:	ee                   	out    %al,(%dx)
}
80102edb:	90                   	nop
80102edc:	c9                   	leave  
80102edd:	c3                   	ret    

80102ede <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ede:	55                   	push   %ebp
80102edf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ee1:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102ee6:	8b 55 08             	mov    0x8(%ebp),%edx
80102ee9:	c1 e2 02             	shl    $0x2,%edx
80102eec:	01 c2                	add    %eax,%edx
80102eee:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ef1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ef3:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102ef8:	83 c0 20             	add    $0x20,%eax
80102efb:	8b 00                	mov    (%eax),%eax
}
80102efd:	90                   	nop
80102efe:	5d                   	pop    %ebp
80102eff:	c3                   	ret    

80102f00 <lapicinit>:

void
lapicinit(void)
{
80102f00:	55                   	push   %ebp
80102f01:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102f03:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102f08:	85 c0                	test   %eax,%eax
80102f0a:	0f 84 0b 01 00 00    	je     8010301b <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f10:	68 3f 01 00 00       	push   $0x13f
80102f15:	6a 3c                	push   $0x3c
80102f17:	e8 c2 ff ff ff       	call   80102ede <lapicw>
80102f1c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f1f:	6a 0b                	push   $0xb
80102f21:	68 f8 00 00 00       	push   $0xf8
80102f26:	e8 b3 ff ff ff       	call   80102ede <lapicw>
80102f2b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f2e:	68 20 00 02 00       	push   $0x20020
80102f33:	68 c8 00 00 00       	push   $0xc8
80102f38:	e8 a1 ff ff ff       	call   80102ede <lapicw>
80102f3d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f40:	68 80 96 98 00       	push   $0x989680
80102f45:	68 e0 00 00 00       	push   $0xe0
80102f4a:	e8 8f ff ff ff       	call   80102ede <lapicw>
80102f4f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f52:	68 00 00 01 00       	push   $0x10000
80102f57:	68 d4 00 00 00       	push   $0xd4
80102f5c:	e8 7d ff ff ff       	call   80102ede <lapicw>
80102f61:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f64:	68 00 00 01 00       	push   $0x10000
80102f69:	68 d8 00 00 00       	push   $0xd8
80102f6e:	e8 6b ff ff ff       	call   80102ede <lapicw>
80102f73:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f76:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102f7b:	83 c0 30             	add    $0x30,%eax
80102f7e:	8b 00                	mov    (%eax),%eax
80102f80:	c1 e8 10             	shr    $0x10,%eax
80102f83:	0f b6 c0             	movzbl %al,%eax
80102f86:	83 f8 03             	cmp    $0x3,%eax
80102f89:	76 12                	jbe    80102f9d <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f8b:	68 00 00 01 00       	push   $0x10000
80102f90:	68 d0 00 00 00       	push   $0xd0
80102f95:	e8 44 ff ff ff       	call   80102ede <lapicw>
80102f9a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f9d:	6a 33                	push   $0x33
80102f9f:	68 dc 00 00 00       	push   $0xdc
80102fa4:	e8 35 ff ff ff       	call   80102ede <lapicw>
80102fa9:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fac:	6a 00                	push   $0x0
80102fae:	68 a0 00 00 00       	push   $0xa0
80102fb3:	e8 26 ff ff ff       	call   80102ede <lapicw>
80102fb8:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102fbb:	6a 00                	push   $0x0
80102fbd:	68 a0 00 00 00       	push   $0xa0
80102fc2:	e8 17 ff ff ff       	call   80102ede <lapicw>
80102fc7:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fca:	6a 00                	push   $0x0
80102fcc:	6a 2c                	push   $0x2c
80102fce:	e8 0b ff ff ff       	call   80102ede <lapicw>
80102fd3:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fd6:	6a 00                	push   $0x0
80102fd8:	68 c4 00 00 00       	push   $0xc4
80102fdd:	e8 fc fe ff ff       	call   80102ede <lapicw>
80102fe2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fe5:	68 00 85 08 00       	push   $0x88500
80102fea:	68 c0 00 00 00       	push   $0xc0
80102fef:	e8 ea fe ff ff       	call   80102ede <lapicw>
80102ff4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ff7:	90                   	nop
80102ff8:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102ffd:	05 00 03 00 00       	add    $0x300,%eax
80103002:	8b 00                	mov    (%eax),%eax
80103004:	25 00 10 00 00       	and    $0x1000,%eax
80103009:	85 c0                	test   %eax,%eax
8010300b:	75 eb                	jne    80102ff8 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010300d:	6a 00                	push   $0x0
8010300f:	6a 20                	push   $0x20
80103011:	e8 c8 fe ff ff       	call   80102ede <lapicw>
80103016:	83 c4 08             	add    $0x8,%esp
80103019:	eb 01                	jmp    8010301c <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic)
    return;
8010301b:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010301c:	c9                   	leave  
8010301d:	c3                   	ret    

8010301e <lapicid>:

int
lapicid(void)
{
8010301e:	55                   	push   %ebp
8010301f:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103021:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80103026:	85 c0                	test   %eax,%eax
80103028:	75 07                	jne    80103031 <lapicid+0x13>
    return 0;
8010302a:	b8 00 00 00 00       	mov    $0x0,%eax
8010302f:	eb 0d                	jmp    8010303e <lapicid+0x20>
  return lapic[ID] >> 24;
80103031:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80103036:	83 c0 20             	add    $0x20,%eax
80103039:	8b 00                	mov    (%eax),%eax
8010303b:	c1 e8 18             	shr    $0x18,%eax
}
8010303e:	5d                   	pop    %ebp
8010303f:	c3                   	ret    

80103040 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103043:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80103048:	85 c0                	test   %eax,%eax
8010304a:	74 0c                	je     80103058 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010304c:	6a 00                	push   $0x0
8010304e:	6a 2c                	push   $0x2c
80103050:	e8 89 fe ff ff       	call   80102ede <lapicw>
80103055:	83 c4 08             	add    $0x8,%esp
}
80103058:	90                   	nop
80103059:	c9                   	leave  
8010305a:	c3                   	ret    

8010305b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010305b:	55                   	push   %ebp
8010305c:	89 e5                	mov    %esp,%ebp
}
8010305e:	90                   	nop
8010305f:	5d                   	pop    %ebp
80103060:	c3                   	ret    

80103061 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103061:	55                   	push   %ebp
80103062:	89 e5                	mov    %esp,%ebp
80103064:	83 ec 14             	sub    $0x14,%esp
80103067:	8b 45 08             	mov    0x8(%ebp),%eax
8010306a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010306d:	6a 0f                	push   $0xf
8010306f:	6a 70                	push   $0x70
80103071:	e8 49 fe ff ff       	call   80102ebf <outb>
80103076:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103079:	6a 0a                	push   $0xa
8010307b:	6a 71                	push   $0x71
8010307d:	e8 3d fe ff ff       	call   80102ebf <outb>
80103082:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103085:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010308c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010308f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103094:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103097:	83 c0 02             	add    $0x2,%eax
8010309a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010309d:	c1 ea 04             	shr    $0x4,%edx
801030a0:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030a3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030a7:	c1 e0 18             	shl    $0x18,%eax
801030aa:	50                   	push   %eax
801030ab:	68 c4 00 00 00       	push   $0xc4
801030b0:	e8 29 fe ff ff       	call   80102ede <lapicw>
801030b5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030b8:	68 00 c5 00 00       	push   $0xc500
801030bd:	68 c0 00 00 00       	push   $0xc0
801030c2:	e8 17 fe ff ff       	call   80102ede <lapicw>
801030c7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030ca:	68 c8 00 00 00       	push   $0xc8
801030cf:	e8 87 ff ff ff       	call   8010305b <microdelay>
801030d4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030d7:	68 00 85 00 00       	push   $0x8500
801030dc:	68 c0 00 00 00       	push   $0xc0
801030e1:	e8 f8 fd ff ff       	call   80102ede <lapicw>
801030e6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030e9:	6a 64                	push   $0x64
801030eb:	e8 6b ff ff ff       	call   8010305b <microdelay>
801030f0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030fa:	eb 3d                	jmp    80103139 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030fc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103100:	c1 e0 18             	shl    $0x18,%eax
80103103:	50                   	push   %eax
80103104:	68 c4 00 00 00       	push   $0xc4
80103109:	e8 d0 fd ff ff       	call   80102ede <lapicw>
8010310e:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103111:	8b 45 0c             	mov    0xc(%ebp),%eax
80103114:	c1 e8 0c             	shr    $0xc,%eax
80103117:	80 cc 06             	or     $0x6,%ah
8010311a:	50                   	push   %eax
8010311b:	68 c0 00 00 00       	push   $0xc0
80103120:	e8 b9 fd ff ff       	call   80102ede <lapicw>
80103125:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103128:	68 c8 00 00 00       	push   $0xc8
8010312d:	e8 29 ff ff ff       	call   8010305b <microdelay>
80103132:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103135:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103139:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010313d:	7e bd                	jle    801030fc <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010313f:	90                   	nop
80103140:	c9                   	leave  
80103141:	c3                   	ret    

80103142 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103142:	55                   	push   %ebp
80103143:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103145:	8b 45 08             	mov    0x8(%ebp),%eax
80103148:	0f b6 c0             	movzbl %al,%eax
8010314b:	50                   	push   %eax
8010314c:	6a 70                	push   $0x70
8010314e:	e8 6c fd ff ff       	call   80102ebf <outb>
80103153:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103156:	68 c8 00 00 00       	push   $0xc8
8010315b:	e8 fb fe ff ff       	call   8010305b <microdelay>
80103160:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103163:	6a 71                	push   $0x71
80103165:	e8 38 fd ff ff       	call   80102ea2 <inb>
8010316a:	83 c4 04             	add    $0x4,%esp
8010316d:	0f b6 c0             	movzbl %al,%eax
}
80103170:	c9                   	leave  
80103171:	c3                   	ret    

80103172 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103172:	55                   	push   %ebp
80103173:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103175:	6a 00                	push   $0x0
80103177:	e8 c6 ff ff ff       	call   80103142 <cmos_read>
8010317c:	83 c4 04             	add    $0x4,%esp
8010317f:	89 c2                	mov    %eax,%edx
80103181:	8b 45 08             	mov    0x8(%ebp),%eax
80103184:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103186:	6a 02                	push   $0x2
80103188:	e8 b5 ff ff ff       	call   80103142 <cmos_read>
8010318d:	83 c4 04             	add    $0x4,%esp
80103190:	89 c2                	mov    %eax,%edx
80103192:	8b 45 08             	mov    0x8(%ebp),%eax
80103195:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103198:	6a 04                	push   $0x4
8010319a:	e8 a3 ff ff ff       	call   80103142 <cmos_read>
8010319f:	83 c4 04             	add    $0x4,%esp
801031a2:	89 c2                	mov    %eax,%edx
801031a4:	8b 45 08             	mov    0x8(%ebp),%eax
801031a7:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801031aa:	6a 07                	push   $0x7
801031ac:	e8 91 ff ff ff       	call   80103142 <cmos_read>
801031b1:	83 c4 04             	add    $0x4,%esp
801031b4:	89 c2                	mov    %eax,%edx
801031b6:	8b 45 08             	mov    0x8(%ebp),%eax
801031b9:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031bc:	6a 08                	push   $0x8
801031be:	e8 7f ff ff ff       	call   80103142 <cmos_read>
801031c3:	83 c4 04             	add    $0x4,%esp
801031c6:	89 c2                	mov    %eax,%edx
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031ce:	6a 09                	push   $0x9
801031d0:	e8 6d ff ff ff       	call   80103142 <cmos_read>
801031d5:	83 c4 04             	add    $0x4,%esp
801031d8:	89 c2                	mov    %eax,%edx
801031da:	8b 45 08             	mov    0x8(%ebp),%eax
801031dd:	89 50 14             	mov    %edx,0x14(%eax)
}
801031e0:	90                   	nop
801031e1:	c9                   	leave  
801031e2:	c3                   	ret    

801031e3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031e3:	55                   	push   %ebp
801031e4:	89 e5                	mov    %esp,%ebp
801031e6:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031e9:	6a 0b                	push   $0xb
801031eb:	e8 52 ff ff ff       	call   80103142 <cmos_read>
801031f0:	83 c4 04             	add    $0x4,%esp
801031f3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031f9:	83 e0 04             	and    $0x4,%eax
801031fc:	85 c0                	test   %eax,%eax
801031fe:	0f 94 c0             	sete   %al
80103201:	0f b6 c0             	movzbl %al,%eax
80103204:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103207:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010320a:	50                   	push   %eax
8010320b:	e8 62 ff ff ff       	call   80103172 <fill_rtcdate>
80103210:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103213:	6a 0a                	push   $0xa
80103215:	e8 28 ff ff ff       	call   80103142 <cmos_read>
8010321a:	83 c4 04             	add    $0x4,%esp
8010321d:	25 80 00 00 00       	and    $0x80,%eax
80103222:	85 c0                	test   %eax,%eax
80103224:	75 27                	jne    8010324d <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103226:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103229:	50                   	push   %eax
8010322a:	e8 43 ff ff ff       	call   80103172 <fill_rtcdate>
8010322f:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103232:	83 ec 04             	sub    $0x4,%esp
80103235:	6a 18                	push   $0x18
80103237:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010323a:	50                   	push   %eax
8010323b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010323e:	50                   	push   %eax
8010323f:	e8 69 20 00 00       	call   801052ad <memcmp>
80103244:	83 c4 10             	add    $0x10,%esp
80103247:	85 c0                	test   %eax,%eax
80103249:	74 05                	je     80103250 <cmostime+0x6d>
8010324b:	eb ba                	jmp    80103207 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010324d:	90                   	nop
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010324e:	eb b7                	jmp    80103207 <cmostime+0x24>
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103250:	90                   	nop
  }

  // convert
  if(bcd) {
80103251:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103255:	0f 84 b4 00 00 00    	je     8010330f <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010325b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325e:	c1 e8 04             	shr    $0x4,%eax
80103261:	89 c2                	mov    %eax,%edx
80103263:	89 d0                	mov    %edx,%eax
80103265:	c1 e0 02             	shl    $0x2,%eax
80103268:	01 d0                	add    %edx,%eax
8010326a:	01 c0                	add    %eax,%eax
8010326c:	89 c2                	mov    %eax,%edx
8010326e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103271:	83 e0 0f             	and    $0xf,%eax
80103274:	01 d0                	add    %edx,%eax
80103276:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103279:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327c:	c1 e8 04             	shr    $0x4,%eax
8010327f:	89 c2                	mov    %eax,%edx
80103281:	89 d0                	mov    %edx,%eax
80103283:	c1 e0 02             	shl    $0x2,%eax
80103286:	01 d0                	add    %edx,%eax
80103288:	01 c0                	add    %eax,%eax
8010328a:	89 c2                	mov    %eax,%edx
8010328c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010328f:	83 e0 0f             	and    $0xf,%eax
80103292:	01 d0                	add    %edx,%eax
80103294:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010329a:	c1 e8 04             	shr    $0x4,%eax
8010329d:	89 c2                	mov    %eax,%edx
8010329f:	89 d0                	mov    %edx,%eax
801032a1:	c1 e0 02             	shl    $0x2,%eax
801032a4:	01 d0                	add    %edx,%eax
801032a6:	01 c0                	add    %eax,%eax
801032a8:	89 c2                	mov    %eax,%edx
801032aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032ad:	83 e0 0f             	and    $0xf,%eax
801032b0:	01 d0                	add    %edx,%eax
801032b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b8:	c1 e8 04             	shr    $0x4,%eax
801032bb:	89 c2                	mov    %eax,%edx
801032bd:	89 d0                	mov    %edx,%eax
801032bf:	c1 e0 02             	shl    $0x2,%eax
801032c2:	01 d0                	add    %edx,%eax
801032c4:	01 c0                	add    %eax,%eax
801032c6:	89 c2                	mov    %eax,%edx
801032c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032cb:	83 e0 0f             	and    $0xf,%eax
801032ce:	01 d0                	add    %edx,%eax
801032d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032d6:	c1 e8 04             	shr    $0x4,%eax
801032d9:	89 c2                	mov    %eax,%edx
801032db:	89 d0                	mov    %edx,%eax
801032dd:	c1 e0 02             	shl    $0x2,%eax
801032e0:	01 d0                	add    %edx,%eax
801032e2:	01 c0                	add    %eax,%eax
801032e4:	89 c2                	mov    %eax,%edx
801032e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032e9:	83 e0 0f             	and    $0xf,%eax
801032ec:	01 d0                	add    %edx,%eax
801032ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f4:	c1 e8 04             	shr    $0x4,%eax
801032f7:	89 c2                	mov    %eax,%edx
801032f9:	89 d0                	mov    %edx,%eax
801032fb:	c1 e0 02             	shl    $0x2,%eax
801032fe:	01 d0                	add    %edx,%eax
80103300:	01 c0                	add    %eax,%eax
80103302:	89 c2                	mov    %eax,%edx
80103304:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103307:	83 e0 0f             	and    $0xf,%eax
8010330a:	01 d0                	add    %edx,%eax
8010330c:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010330f:	8b 45 08             	mov    0x8(%ebp),%eax
80103312:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103315:	89 10                	mov    %edx,(%eax)
80103317:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010331a:	89 50 04             	mov    %edx,0x4(%eax)
8010331d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103320:	89 50 08             	mov    %edx,0x8(%eax)
80103323:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103326:	89 50 0c             	mov    %edx,0xc(%eax)
80103329:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010332c:	89 50 10             	mov    %edx,0x10(%eax)
8010332f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103332:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	8b 40 14             	mov    0x14(%eax),%eax
8010333b:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	89 50 14             	mov    %edx,0x14(%eax)
}
80103347:	90                   	nop
80103348:	c9                   	leave  
80103349:	c3                   	ret    

8010334a <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010334a:	55                   	push   %ebp
8010334b:	89 e5                	mov    %esp,%ebp
8010334d:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103350:	83 ec 08             	sub    $0x8,%esp
80103353:	68 f5 8c 10 80       	push   $0x80108cf5
80103358:	68 00 47 11 80       	push   $0x80114700
8010335d:	e8 4b 1c 00 00       	call   80104fad <initlock>
80103362:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103365:	83 ec 08             	sub    $0x8,%esp
80103368:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010336b:	50                   	push   %eax
8010336c:	ff 75 08             	pushl  0x8(%ebp)
8010336f:	e8 a3 e0 ff ff       	call   80101417 <readsb>
80103374:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103377:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337a:	a3 34 47 11 80       	mov    %eax,0x80114734
  log.size = sb.nlog;
8010337f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103382:	a3 38 47 11 80       	mov    %eax,0x80114738
  log.dev = dev;
80103387:	8b 45 08             	mov    0x8(%ebp),%eax
8010338a:	a3 44 47 11 80       	mov    %eax,0x80114744
  recover_from_log();
8010338f:	e8 b2 01 00 00       	call   80103546 <recover_from_log>
}
80103394:	90                   	nop
80103395:	c9                   	leave  
80103396:	c3                   	ret    

80103397 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103397:	55                   	push   %ebp
80103398:	89 e5                	mov    %esp,%ebp
8010339a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010339d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033a4:	e9 95 00 00 00       	jmp    8010343e <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033a9:	8b 15 34 47 11 80    	mov    0x80114734,%edx
801033af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b2:	01 d0                	add    %edx,%eax
801033b4:	83 c0 01             	add    $0x1,%eax
801033b7:	89 c2                	mov    %eax,%edx
801033b9:	a1 44 47 11 80       	mov    0x80114744,%eax
801033be:	83 ec 08             	sub    $0x8,%esp
801033c1:	52                   	push   %edx
801033c2:	50                   	push   %eax
801033c3:	e8 06 ce ff ff       	call   801001ce <bread>
801033c8:	83 c4 10             	add    $0x10,%esp
801033cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d1:	83 c0 10             	add    $0x10,%eax
801033d4:	8b 04 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%eax
801033db:	89 c2                	mov    %eax,%edx
801033dd:	a1 44 47 11 80       	mov    0x80114744,%eax
801033e2:	83 ec 08             	sub    $0x8,%esp
801033e5:	52                   	push   %edx
801033e6:	50                   	push   %eax
801033e7:	e8 e2 cd ff ff       	call   801001ce <bread>
801033ec:	83 c4 10             	add    $0x10,%esp
801033ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f5:	8d 50 5c             	lea    0x5c(%eax),%edx
801033f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fb:	83 c0 5c             	add    $0x5c,%eax
801033fe:	83 ec 04             	sub    $0x4,%esp
80103401:	68 00 02 00 00       	push   $0x200
80103406:	52                   	push   %edx
80103407:	50                   	push   %eax
80103408:	e8 f8 1e 00 00       	call   80105305 <memmove>
8010340d:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103410:	83 ec 0c             	sub    $0xc,%esp
80103413:	ff 75 ec             	pushl  -0x14(%ebp)
80103416:	e8 ec cd ff ff       	call   80100207 <bwrite>
8010341b:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010341e:	83 ec 0c             	sub    $0xc,%esp
80103421:	ff 75 f0             	pushl  -0x10(%ebp)
80103424:	e8 27 ce ff ff       	call   80100250 <brelse>
80103429:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010342c:	83 ec 0c             	sub    $0xc,%esp
8010342f:	ff 75 ec             	pushl  -0x14(%ebp)
80103432:	e8 19 ce ff ff       	call   80100250 <brelse>
80103437:	83 c4 10             	add    $0x10,%esp
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010343a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010343e:	a1 48 47 11 80       	mov    0x80114748,%eax
80103443:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103446:	0f 8f 5d ff ff ff    	jg     801033a9 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
8010344c:	90                   	nop
8010344d:	c9                   	leave  
8010344e:	c3                   	ret    

8010344f <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010344f:	55                   	push   %ebp
80103450:	89 e5                	mov    %esp,%ebp
80103452:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103455:	a1 34 47 11 80       	mov    0x80114734,%eax
8010345a:	89 c2                	mov    %eax,%edx
8010345c:	a1 44 47 11 80       	mov    0x80114744,%eax
80103461:	83 ec 08             	sub    $0x8,%esp
80103464:	52                   	push   %edx
80103465:	50                   	push   %eax
80103466:	e8 63 cd ff ff       	call   801001ce <bread>
8010346b:	83 c4 10             	add    $0x10,%esp
8010346e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103474:	83 c0 5c             	add    $0x5c,%eax
80103477:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010347a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347d:	8b 00                	mov    (%eax),%eax
8010347f:	a3 48 47 11 80       	mov    %eax,0x80114748
  for (i = 0; i < log.lh.n; i++) {
80103484:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010348b:	eb 1b                	jmp    801034a8 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010348d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103493:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103497:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010349a:	83 c2 10             	add    $0x10,%edx
8010349d:	89 04 95 0c 47 11 80 	mov    %eax,-0x7feeb8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034a8:	a1 48 47 11 80       	mov    0x80114748,%eax
801034ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034b0:	7f db                	jg     8010348d <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801034b2:	83 ec 0c             	sub    $0xc,%esp
801034b5:	ff 75 f0             	pushl  -0x10(%ebp)
801034b8:	e8 93 cd ff ff       	call   80100250 <brelse>
801034bd:	83 c4 10             	add    $0x10,%esp
}
801034c0:	90                   	nop
801034c1:	c9                   	leave  
801034c2:	c3                   	ret    

801034c3 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034c3:	55                   	push   %ebp
801034c4:	89 e5                	mov    %esp,%ebp
801034c6:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034c9:	a1 34 47 11 80       	mov    0x80114734,%eax
801034ce:	89 c2                	mov    %eax,%edx
801034d0:	a1 44 47 11 80       	mov    0x80114744,%eax
801034d5:	83 ec 08             	sub    $0x8,%esp
801034d8:	52                   	push   %edx
801034d9:	50                   	push   %eax
801034da:	e8 ef cc ff ff       	call   801001ce <bread>
801034df:	83 c4 10             	add    $0x10,%esp
801034e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e8:	83 c0 5c             	add    $0x5c,%eax
801034eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034ee:	8b 15 48 47 11 80    	mov    0x80114748,%edx
801034f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103500:	eb 1b                	jmp    8010351d <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103505:	83 c0 10             	add    $0x10,%eax
80103508:	8b 0c 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%ecx
8010350f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103512:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103515:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103519:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010351d:	a1 48 47 11 80       	mov    0x80114748,%eax
80103522:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103525:	7f db                	jg     80103502 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103527:	83 ec 0c             	sub    $0xc,%esp
8010352a:	ff 75 f0             	pushl  -0x10(%ebp)
8010352d:	e8 d5 cc ff ff       	call   80100207 <bwrite>
80103532:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103535:	83 ec 0c             	sub    $0xc,%esp
80103538:	ff 75 f0             	pushl  -0x10(%ebp)
8010353b:	e8 10 cd ff ff       	call   80100250 <brelse>
80103540:	83 c4 10             	add    $0x10,%esp
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <recover_from_log>:

static void
recover_from_log(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
80103549:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010354c:	e8 fe fe ff ff       	call   8010344f <read_head>
  install_trans(); // if committed, copy from log to disk
80103551:	e8 41 fe ff ff       	call   80103397 <install_trans>
  log.lh.n = 0;
80103556:	c7 05 48 47 11 80 00 	movl   $0x0,0x80114748
8010355d:	00 00 00 
  write_head(); // clear the log
80103560:	e8 5e ff ff ff       	call   801034c3 <write_head>
}
80103565:	90                   	nop
80103566:	c9                   	leave  
80103567:	c3                   	ret    

80103568 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103568:	55                   	push   %ebp
80103569:	89 e5                	mov    %esp,%ebp
8010356b:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010356e:	83 ec 0c             	sub    $0xc,%esp
80103571:	68 00 47 11 80       	push   $0x80114700
80103576:	e8 54 1a 00 00       	call   80104fcf <acquire>
8010357b:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010357e:	a1 40 47 11 80       	mov    0x80114740,%eax
80103583:	85 c0                	test   %eax,%eax
80103585:	74 17                	je     8010359e <begin_op+0x36>
      sleep(&log, &log.lock);
80103587:	83 ec 08             	sub    $0x8,%esp
8010358a:	68 00 47 11 80       	push   $0x80114700
8010358f:	68 00 47 11 80       	push   $0x80114700
80103594:	e8 14 16 00 00       	call   80104bad <sleep>
80103599:	83 c4 10             	add    $0x10,%esp
8010359c:	eb e0                	jmp    8010357e <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010359e:	8b 0d 48 47 11 80    	mov    0x80114748,%ecx
801035a4:	a1 3c 47 11 80       	mov    0x8011473c,%eax
801035a9:	8d 50 01             	lea    0x1(%eax),%edx
801035ac:	89 d0                	mov    %edx,%eax
801035ae:	c1 e0 02             	shl    $0x2,%eax
801035b1:	01 d0                	add    %edx,%eax
801035b3:	01 c0                	add    %eax,%eax
801035b5:	01 c8                	add    %ecx,%eax
801035b7:	83 f8 1e             	cmp    $0x1e,%eax
801035ba:	7e 17                	jle    801035d3 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035bc:	83 ec 08             	sub    $0x8,%esp
801035bf:	68 00 47 11 80       	push   $0x80114700
801035c4:	68 00 47 11 80       	push   $0x80114700
801035c9:	e8 df 15 00 00       	call   80104bad <sleep>
801035ce:	83 c4 10             	add    $0x10,%esp
801035d1:	eb ab                	jmp    8010357e <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035d3:	a1 3c 47 11 80       	mov    0x8011473c,%eax
801035d8:	83 c0 01             	add    $0x1,%eax
801035db:	a3 3c 47 11 80       	mov    %eax,0x8011473c
      release(&log.lock);
801035e0:	83 ec 0c             	sub    $0xc,%esp
801035e3:	68 00 47 11 80       	push   $0x80114700
801035e8:	e8 50 1a 00 00       	call   8010503d <release>
801035ed:	83 c4 10             	add    $0x10,%esp
      break;
801035f0:	90                   	nop
    }
  }
}
801035f1:	90                   	nop
801035f2:	c9                   	leave  
801035f3:	c3                   	ret    

801035f4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035f4:	55                   	push   %ebp
801035f5:	89 e5                	mov    %esp,%ebp
801035f7:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103601:	83 ec 0c             	sub    $0xc,%esp
80103604:	68 00 47 11 80       	push   $0x80114700
80103609:	e8 c1 19 00 00       	call   80104fcf <acquire>
8010360e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103611:	a1 3c 47 11 80       	mov    0x8011473c,%eax
80103616:	83 e8 01             	sub    $0x1,%eax
80103619:	a3 3c 47 11 80       	mov    %eax,0x8011473c
  if(log.committing)
8010361e:	a1 40 47 11 80       	mov    0x80114740,%eax
80103623:	85 c0                	test   %eax,%eax
80103625:	74 0d                	je     80103634 <end_op+0x40>
    panic("log.committing");
80103627:	83 ec 0c             	sub    $0xc,%esp
8010362a:	68 f9 8c 10 80       	push   $0x80108cf9
8010362f:	e8 6c cf ff ff       	call   801005a0 <panic>
  if(log.outstanding == 0){
80103634:	a1 3c 47 11 80       	mov    0x8011473c,%eax
80103639:	85 c0                	test   %eax,%eax
8010363b:	75 13                	jne    80103650 <end_op+0x5c>
    do_commit = 1;
8010363d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103644:	c7 05 40 47 11 80 01 	movl   $0x1,0x80114740
8010364b:	00 00 00 
8010364e:	eb 10                	jmp    80103660 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103650:	83 ec 0c             	sub    $0xc,%esp
80103653:	68 00 47 11 80       	push   $0x80114700
80103658:	e8 39 16 00 00       	call   80104c96 <wakeup>
8010365d:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103660:	83 ec 0c             	sub    $0xc,%esp
80103663:	68 00 47 11 80       	push   $0x80114700
80103668:	e8 d0 19 00 00       	call   8010503d <release>
8010366d:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 3f                	je     801036b5 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103676:	e8 f5 00 00 00       	call   80103770 <commit>
    acquire(&log.lock);
8010367b:	83 ec 0c             	sub    $0xc,%esp
8010367e:	68 00 47 11 80       	push   $0x80114700
80103683:	e8 47 19 00 00       	call   80104fcf <acquire>
80103688:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010368b:	c7 05 40 47 11 80 00 	movl   $0x0,0x80114740
80103692:	00 00 00 
    wakeup(&log);
80103695:	83 ec 0c             	sub    $0xc,%esp
80103698:	68 00 47 11 80       	push   $0x80114700
8010369d:	e8 f4 15 00 00       	call   80104c96 <wakeup>
801036a2:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036a5:	83 ec 0c             	sub    $0xc,%esp
801036a8:	68 00 47 11 80       	push   $0x80114700
801036ad:	e8 8b 19 00 00       	call   8010503d <release>
801036b2:	83 c4 10             	add    $0x10,%esp
  }
}
801036b5:	90                   	nop
801036b6:	c9                   	leave  
801036b7:	c3                   	ret    

801036b8 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801036b8:	55                   	push   %ebp
801036b9:	89 e5                	mov    %esp,%ebp
801036bb:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036c5:	e9 95 00 00 00       	jmp    8010375f <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036ca:	8b 15 34 47 11 80    	mov    0x80114734,%edx
801036d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d3:	01 d0                	add    %edx,%eax
801036d5:	83 c0 01             	add    $0x1,%eax
801036d8:	89 c2                	mov    %eax,%edx
801036da:	a1 44 47 11 80       	mov    0x80114744,%eax
801036df:	83 ec 08             	sub    $0x8,%esp
801036e2:	52                   	push   %edx
801036e3:	50                   	push   %eax
801036e4:	e8 e5 ca ff ff       	call   801001ce <bread>
801036e9:	83 c4 10             	add    $0x10,%esp
801036ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036f2:	83 c0 10             	add    $0x10,%eax
801036f5:	8b 04 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%eax
801036fc:	89 c2                	mov    %eax,%edx
801036fe:	a1 44 47 11 80       	mov    0x80114744,%eax
80103703:	83 ec 08             	sub    $0x8,%esp
80103706:	52                   	push   %edx
80103707:	50                   	push   %eax
80103708:	e8 c1 ca ff ff       	call   801001ce <bread>
8010370d:	83 c4 10             	add    $0x10,%esp
80103710:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103713:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103716:	8d 50 5c             	lea    0x5c(%eax),%edx
80103719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010371c:	83 c0 5c             	add    $0x5c,%eax
8010371f:	83 ec 04             	sub    $0x4,%esp
80103722:	68 00 02 00 00       	push   $0x200
80103727:	52                   	push   %edx
80103728:	50                   	push   %eax
80103729:	e8 d7 1b 00 00       	call   80105305 <memmove>
8010372e:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103731:	83 ec 0c             	sub    $0xc,%esp
80103734:	ff 75 f0             	pushl  -0x10(%ebp)
80103737:	e8 cb ca ff ff       	call   80100207 <bwrite>
8010373c:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010373f:	83 ec 0c             	sub    $0xc,%esp
80103742:	ff 75 ec             	pushl  -0x14(%ebp)
80103745:	e8 06 cb ff ff       	call   80100250 <brelse>
8010374a:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010374d:	83 ec 0c             	sub    $0xc,%esp
80103750:	ff 75 f0             	pushl  -0x10(%ebp)
80103753:	e8 f8 ca ff ff       	call   80100250 <brelse>
80103758:	83 c4 10             	add    $0x10,%esp
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010375b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010375f:	a1 48 47 11 80       	mov    0x80114748,%eax
80103764:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103767:	0f 8f 5d ff ff ff    	jg     801036ca <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
8010376d:	90                   	nop
8010376e:	c9                   	leave  
8010376f:	c3                   	ret    

80103770 <commit>:

static void
commit()
{
80103770:	55                   	push   %ebp
80103771:	89 e5                	mov    %esp,%ebp
80103773:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103776:	a1 48 47 11 80       	mov    0x80114748,%eax
8010377b:	85 c0                	test   %eax,%eax
8010377d:	7e 1e                	jle    8010379d <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010377f:	e8 34 ff ff ff       	call   801036b8 <write_log>
    write_head();    // Write header to disk -- the real commit
80103784:	e8 3a fd ff ff       	call   801034c3 <write_head>
    install_trans(); // Now install writes to home locations
80103789:	e8 09 fc ff ff       	call   80103397 <install_trans>
    log.lh.n = 0;
8010378e:	c7 05 48 47 11 80 00 	movl   $0x0,0x80114748
80103795:	00 00 00 
    write_head();    // Erase the transaction from the log
80103798:	e8 26 fd ff ff       	call   801034c3 <write_head>
  }
}
8010379d:	90                   	nop
8010379e:	c9                   	leave  
8010379f:	c3                   	ret    

801037a0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037a0:	55                   	push   %ebp
801037a1:	89 e5                	mov    %esp,%ebp
801037a3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037a6:	a1 48 47 11 80       	mov    0x80114748,%eax
801037ab:	83 f8 1d             	cmp    $0x1d,%eax
801037ae:	7f 12                	jg     801037c2 <log_write+0x22>
801037b0:	a1 48 47 11 80       	mov    0x80114748,%eax
801037b5:	8b 15 38 47 11 80    	mov    0x80114738,%edx
801037bb:	83 ea 01             	sub    $0x1,%edx
801037be:	39 d0                	cmp    %edx,%eax
801037c0:	7c 0d                	jl     801037cf <log_write+0x2f>
    panic("too big a transaction");
801037c2:	83 ec 0c             	sub    $0xc,%esp
801037c5:	68 08 8d 10 80       	push   $0x80108d08
801037ca:	e8 d1 cd ff ff       	call   801005a0 <panic>
  if (log.outstanding < 1)
801037cf:	a1 3c 47 11 80       	mov    0x8011473c,%eax
801037d4:	85 c0                	test   %eax,%eax
801037d6:	7f 0d                	jg     801037e5 <log_write+0x45>
    panic("log_write outside of trans");
801037d8:	83 ec 0c             	sub    $0xc,%esp
801037db:	68 1e 8d 10 80       	push   $0x80108d1e
801037e0:	e8 bb cd ff ff       	call   801005a0 <panic>

  acquire(&log.lock);
801037e5:	83 ec 0c             	sub    $0xc,%esp
801037e8:	68 00 47 11 80       	push   $0x80114700
801037ed:	e8 dd 17 00 00       	call   80104fcf <acquire>
801037f2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037fc:	eb 1d                	jmp    8010381b <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103801:	83 c0 10             	add    $0x10,%eax
80103804:	8b 04 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%eax
8010380b:	89 c2                	mov    %eax,%edx
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 40 08             	mov    0x8(%eax),%eax
80103813:	39 c2                	cmp    %eax,%edx
80103815:	74 10                	je     80103827 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103817:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010381b:	a1 48 47 11 80       	mov    0x80114748,%eax
80103820:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103823:	7f d9                	jg     801037fe <log_write+0x5e>
80103825:	eb 01                	jmp    80103828 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103827:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103828:	8b 45 08             	mov    0x8(%ebp),%eax
8010382b:	8b 40 08             	mov    0x8(%eax),%eax
8010382e:	89 c2                	mov    %eax,%edx
80103830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103833:	83 c0 10             	add    $0x10,%eax
80103836:	89 14 85 0c 47 11 80 	mov    %edx,-0x7feeb8f4(,%eax,4)
  if (i == log.lh.n)
8010383d:	a1 48 47 11 80       	mov    0x80114748,%eax
80103842:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103845:	75 0d                	jne    80103854 <log_write+0xb4>
    log.lh.n++;
80103847:	a1 48 47 11 80       	mov    0x80114748,%eax
8010384c:	83 c0 01             	add    $0x1,%eax
8010384f:	a3 48 47 11 80       	mov    %eax,0x80114748
  b->flags |= B_DIRTY; // prevent eviction
80103854:	8b 45 08             	mov    0x8(%ebp),%eax
80103857:	8b 00                	mov    (%eax),%eax
80103859:	83 c8 04             	or     $0x4,%eax
8010385c:	89 c2                	mov    %eax,%edx
8010385e:	8b 45 08             	mov    0x8(%ebp),%eax
80103861:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103863:	83 ec 0c             	sub    $0xc,%esp
80103866:	68 00 47 11 80       	push   $0x80114700
8010386b:	e8 cd 17 00 00       	call   8010503d <release>
80103870:	83 c4 10             	add    $0x10,%esp
}
80103873:	90                   	nop
80103874:	c9                   	leave  
80103875:	c3                   	ret    

80103876 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103876:	55                   	push   %ebp
80103877:	89 e5                	mov    %esp,%ebp
80103879:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010387c:	8b 55 08             	mov    0x8(%ebp),%edx
8010387f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103882:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103885:	f0 87 02             	lock xchg %eax,(%edx)
80103888:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010388b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010388e:	c9                   	leave  
8010388f:	c3                   	ret    

80103890 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103890:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103894:	83 e4 f0             	and    $0xfffffff0,%esp
80103897:	ff 71 fc             	pushl  -0x4(%ecx)
8010389a:	55                   	push   %ebp
8010389b:	89 e5                	mov    %esp,%ebp
8010389d:	51                   	push   %ecx
8010389e:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038a1:	83 ec 08             	sub    $0x8,%esp
801038a4:	68 00 00 40 80       	push   $0x80400000
801038a9:	68 74 7a 11 80       	push   $0x80117a74
801038ae:	e8 e1 f2 ff ff       	call   80102b94 <kinit1>
801038b3:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038b6:	e8 c2 44 00 00       	call   80107d7d <kvmalloc>
  mpinit();        // detect other processors
801038bb:	e8 bf 03 00 00       	call   80103c7f <mpinit>
  lapicinit();     // interrupt controller
801038c0:	e8 3b f6 ff ff       	call   80102f00 <lapicinit>
  seginit();       // segment descriptors
801038c5:	e8 9e 3f 00 00       	call   80107868 <seginit>
  picinit();       // disable pic
801038ca:	e8 01 05 00 00       	call   80103dd0 <picinit>
  ioapicinit();    // another interrupt controller
801038cf:	e8 dc f1 ff ff       	call   80102ab0 <ioapicinit>
  consoleinit();   // console hardware
801038d4:	e8 72 d2 ff ff       	call   80100b4b <consoleinit>
  uartinit();      // serial port
801038d9:	e8 23 33 00 00       	call   80106c01 <uartinit>
  pinit();         // process table
801038de:	e8 26 09 00 00       	call   80104209 <pinit>
  shminit();       // shared memory
801038e3:	e8 23 4d 00 00       	call   8010860b <shminit>
  tvinit();        // trap vectors
801038e8:	e8 91 2d 00 00       	call   8010667e <tvinit>
  binit();         // buffer cache
801038ed:	e8 42 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038f2:	e8 11 d7 ff ff       	call   80101008 <fileinit>
  ideinit();       // disk 
801038f7:	e8 8b ed ff ff       	call   80102687 <ideinit>
  startothers();   // start other processors
801038fc:	e8 80 00 00 00       	call   80103981 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103901:	83 ec 08             	sub    $0x8,%esp
80103904:	68 00 00 00 8e       	push   $0x8e000000
80103909:	68 00 00 40 80       	push   $0x80400000
8010390e:	e8 ba f2 ff ff       	call   80102bcd <kinit2>
80103913:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103916:	e8 d7 0a 00 00       	call   801043f2 <userinit>
  mpmain();        // finish this processor's setup
8010391b:	e8 1a 00 00 00       	call   8010393a <mpmain>

80103920 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103920:	55                   	push   %ebp
80103921:	89 e5                	mov    %esp,%ebp
80103923:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103926:	e8 6a 44 00 00       	call   80107d95 <switchkvm>
  seginit();
8010392b:	e8 38 3f 00 00       	call   80107868 <seginit>
  lapicinit();
80103930:	e8 cb f5 ff ff       	call   80102f00 <lapicinit>
  mpmain();
80103935:	e8 00 00 00 00       	call   8010393a <mpmain>

8010393a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010393a:	55                   	push   %ebp
8010393b:	89 e5                	mov    %esp,%ebp
8010393d:	53                   	push   %ebx
8010393e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103941:	e8 e1 08 00 00       	call   80104227 <cpuid>
80103946:	89 c3                	mov    %eax,%ebx
80103948:	e8 da 08 00 00       	call   80104227 <cpuid>
8010394d:	83 ec 04             	sub    $0x4,%esp
80103950:	53                   	push   %ebx
80103951:	50                   	push   %eax
80103952:	68 39 8d 10 80       	push   $0x80108d39
80103957:	e8 a4 ca ff ff       	call   80100400 <cprintf>
8010395c:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010395f:	e8 90 2e 00 00       	call   801067f4 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103964:	e8 df 08 00 00       	call   80104248 <mycpu>
80103969:	05 a0 00 00 00       	add    $0xa0,%eax
8010396e:	83 ec 08             	sub    $0x8,%esp
80103971:	6a 01                	push   $0x1
80103973:	50                   	push   %eax
80103974:	e8 fd fe ff ff       	call   80103876 <xchg>
80103979:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010397c:	e8 36 10 00 00       	call   801049b7 <scheduler>

80103981 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103981:	55                   	push   %ebp
80103982:	89 e5                	mov    %esp,%ebp
80103984:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103987:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010398e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103993:	83 ec 04             	sub    $0x4,%esp
80103996:	50                   	push   %eax
80103997:	68 ec c4 10 80       	push   $0x8010c4ec
8010399c:	ff 75 f0             	pushl  -0x10(%ebp)
8010399f:	e8 61 19 00 00       	call   80105305 <memmove>
801039a4:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039a7:	c7 45 f4 00 48 11 80 	movl   $0x80114800,-0xc(%ebp)
801039ae:	eb 79                	jmp    80103a29 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
801039b0:	e8 93 08 00 00       	call   80104248 <mycpu>
801039b5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039b8:	74 67                	je     80103a21 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039ba:	e8 09 f3 ff ff       	call   80102cc8 <kalloc>
801039bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c5:	83 e8 04             	sub    $0x4,%eax
801039c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039cb:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039d1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d6:	83 e8 08             	sub    $0x8,%eax
801039d9:	c7 00 20 39 10 80    	movl   $0x80103920,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e2:	83 e8 0c             	sub    $0xc,%eax
801039e5:	ba 00 b0 10 80       	mov    $0x8010b000,%edx
801039ea:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801039f0:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fe:	0f b6 00             	movzbl (%eax),%eax
80103a01:	0f b6 c0             	movzbl %al,%eax
80103a04:	83 ec 08             	sub    $0x8,%esp
80103a07:	52                   	push   %edx
80103a08:	50                   	push   %eax
80103a09:	e8 53 f6 ff ff       	call   80103061 <lapicstartap>
80103a0e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a11:	90                   	nop
80103a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a15:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a1b:	85 c0                	test   %eax,%eax
80103a1d:	74 f3                	je     80103a12 <startothers+0x91>
80103a1f:	eb 01                	jmp    80103a22 <startothers+0xa1>
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == mycpu())  // We've started already.
      continue;
80103a21:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a22:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a29:	a1 80 4d 11 80       	mov    0x80114d80,%eax
80103a2e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a34:	05 00 48 11 80       	add    $0x80114800,%eax
80103a39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a3c:	0f 87 6e ff ff ff    	ja     801039b0 <startothers+0x2f>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a42:	90                   	nop
80103a43:	c9                   	leave  
80103a44:	c3                   	ret    

80103a45 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a45:	55                   	push   %ebp
80103a46:	89 e5                	mov    %esp,%ebp
80103a48:	83 ec 14             	sub    $0x14,%esp
80103a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a52:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a56:	89 c2                	mov    %eax,%edx
80103a58:	ec                   	in     (%dx),%al
80103a59:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a5c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a60:	c9                   	leave  
80103a61:	c3                   	ret    

80103a62 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a62:	55                   	push   %ebp
80103a63:	89 e5                	mov    %esp,%ebp
80103a65:	83 ec 08             	sub    $0x8,%esp
80103a68:	8b 55 08             	mov    0x8(%ebp),%edx
80103a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a6e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a72:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a75:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a79:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a7d:	ee                   	out    %al,(%dx)
}
80103a7e:	90                   	nop
80103a7f:	c9                   	leave  
80103a80:	c3                   	ret    

80103a81 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a81:	55                   	push   %ebp
80103a82:	89 e5                	mov    %esp,%ebp
80103a84:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a87:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a8e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a95:	eb 15                	jmp    80103aac <sum+0x2b>
    sum += addr[i];
80103a97:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9d:	01 d0                	add    %edx,%eax
80103a9f:	0f b6 00             	movzbl (%eax),%eax
80103aa2:	0f b6 c0             	movzbl %al,%eax
80103aa5:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103aa8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103aac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103aaf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ab2:	7c e3                	jl     80103a97 <sum+0x16>
    sum += addr[i];
  return sum;
80103ab4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ab7:	c9                   	leave  
80103ab8:	c3                   	ret    

80103ab9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ab9:	55                   	push   %ebp
80103aba:	89 e5                	mov    %esp,%ebp
80103abc:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103abf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac2:	05 00 00 00 80       	add    $0x80000000,%eax
80103ac7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103aca:	8b 55 0c             	mov    0xc(%ebp),%edx
80103acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad0:	01 d0                	add    %edx,%eax
80103ad2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103adb:	eb 36                	jmp    80103b13 <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103add:	83 ec 04             	sub    $0x4,%esp
80103ae0:	6a 04                	push   $0x4
80103ae2:	68 50 8d 10 80       	push   $0x80108d50
80103ae7:	ff 75 f4             	pushl  -0xc(%ebp)
80103aea:	e8 be 17 00 00       	call   801052ad <memcmp>
80103aef:	83 c4 10             	add    $0x10,%esp
80103af2:	85 c0                	test   %eax,%eax
80103af4:	75 19                	jne    80103b0f <mpsearch1+0x56>
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	6a 10                	push   $0x10
80103afb:	ff 75 f4             	pushl  -0xc(%ebp)
80103afe:	e8 7e ff ff ff       	call   80103a81 <sum>
80103b03:	83 c4 10             	add    $0x10,%esp
80103b06:	84 c0                	test   %al,%al
80103b08:	75 05                	jne    80103b0f <mpsearch1+0x56>
      return (struct mp*)p;
80103b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0d:	eb 11                	jmp    80103b20 <mpsearch1+0x67>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b0f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b16:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b19:	72 c2                	jb     80103add <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b20:	c9                   	leave  
80103b21:	c3                   	ret    

80103b22 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b22:	55                   	push   %ebp
80103b23:	89 e5                	mov    %esp,%ebp
80103b25:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b28:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b32:	83 c0 0f             	add    $0xf,%eax
80103b35:	0f b6 00             	movzbl (%eax),%eax
80103b38:	0f b6 c0             	movzbl %al,%eax
80103b3b:	c1 e0 08             	shl    $0x8,%eax
80103b3e:	89 c2                	mov    %eax,%edx
80103b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b43:	83 c0 0e             	add    $0xe,%eax
80103b46:	0f b6 00             	movzbl (%eax),%eax
80103b49:	0f b6 c0             	movzbl %al,%eax
80103b4c:	09 d0                	or     %edx,%eax
80103b4e:	c1 e0 04             	shl    $0x4,%eax
80103b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b58:	74 21                	je     80103b7b <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b5a:	83 ec 08             	sub    $0x8,%esp
80103b5d:	68 00 04 00 00       	push   $0x400
80103b62:	ff 75 f0             	pushl  -0x10(%ebp)
80103b65:	e8 4f ff ff ff       	call   80103ab9 <mpsearch1>
80103b6a:	83 c4 10             	add    $0x10,%esp
80103b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b70:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b74:	74 51                	je     80103bc7 <mpsearch+0xa5>
      return mp;
80103b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b79:	eb 61                	jmp    80103bdc <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7e:	83 c0 14             	add    $0x14,%eax
80103b81:	0f b6 00             	movzbl (%eax),%eax
80103b84:	0f b6 c0             	movzbl %al,%eax
80103b87:	c1 e0 08             	shl    $0x8,%eax
80103b8a:	89 c2                	mov    %eax,%edx
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	83 c0 13             	add    $0x13,%eax
80103b92:	0f b6 00             	movzbl (%eax),%eax
80103b95:	0f b6 c0             	movzbl %al,%eax
80103b98:	09 d0                	or     %edx,%eax
80103b9a:	c1 e0 0a             	shl    $0xa,%eax
80103b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba3:	2d 00 04 00 00       	sub    $0x400,%eax
80103ba8:	83 ec 08             	sub    $0x8,%esp
80103bab:	68 00 04 00 00       	push   $0x400
80103bb0:	50                   	push   %eax
80103bb1:	e8 03 ff ff ff       	call   80103ab9 <mpsearch1>
80103bb6:	83 c4 10             	add    $0x10,%esp
80103bb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bbc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bc0:	74 05                	je     80103bc7 <mpsearch+0xa5>
      return mp;
80103bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bc5:	eb 15                	jmp    80103bdc <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bc7:	83 ec 08             	sub    $0x8,%esp
80103bca:	68 00 00 01 00       	push   $0x10000
80103bcf:	68 00 00 0f 00       	push   $0xf0000
80103bd4:	e8 e0 fe ff ff       	call   80103ab9 <mpsearch1>
80103bd9:	83 c4 10             	add    $0x10,%esp
}
80103bdc:	c9                   	leave  
80103bdd:	c3                   	ret    

80103bde <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103bde:	55                   	push   %ebp
80103bdf:	89 e5                	mov    %esp,%ebp
80103be1:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103be4:	e8 39 ff ff ff       	call   80103b22 <mpsearch>
80103be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bf0:	74 0a                	je     80103bfc <mpconfig+0x1e>
80103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf5:	8b 40 04             	mov    0x4(%eax),%eax
80103bf8:	85 c0                	test   %eax,%eax
80103bfa:	75 07                	jne    80103c03 <mpconfig+0x25>
    return 0;
80103bfc:	b8 00 00 00 00       	mov    $0x0,%eax
80103c01:	eb 7a                	jmp    80103c7d <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	8b 40 04             	mov    0x4(%eax),%eax
80103c09:	05 00 00 00 80       	add    $0x80000000,%eax
80103c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c11:	83 ec 04             	sub    $0x4,%esp
80103c14:	6a 04                	push   $0x4
80103c16:	68 55 8d 10 80       	push   $0x80108d55
80103c1b:	ff 75 f0             	pushl  -0x10(%ebp)
80103c1e:	e8 8a 16 00 00       	call   801052ad <memcmp>
80103c23:	83 c4 10             	add    $0x10,%esp
80103c26:	85 c0                	test   %eax,%eax
80103c28:	74 07                	je     80103c31 <mpconfig+0x53>
    return 0;
80103c2a:	b8 00 00 00 00       	mov    $0x0,%eax
80103c2f:	eb 4c                	jmp    80103c7d <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c34:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c38:	3c 01                	cmp    $0x1,%al
80103c3a:	74 12                	je     80103c4e <mpconfig+0x70>
80103c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3f:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c43:	3c 04                	cmp    $0x4,%al
80103c45:	74 07                	je     80103c4e <mpconfig+0x70>
    return 0;
80103c47:	b8 00 00 00 00       	mov    $0x0,%eax
80103c4c:	eb 2f                	jmp    80103c7d <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c51:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c55:	0f b7 c0             	movzwl %ax,%eax
80103c58:	83 ec 08             	sub    $0x8,%esp
80103c5b:	50                   	push   %eax
80103c5c:	ff 75 f0             	pushl  -0x10(%ebp)
80103c5f:	e8 1d fe ff ff       	call   80103a81 <sum>
80103c64:	83 c4 10             	add    $0x10,%esp
80103c67:	84 c0                	test   %al,%al
80103c69:	74 07                	je     80103c72 <mpconfig+0x94>
    return 0;
80103c6b:	b8 00 00 00 00       	mov    $0x0,%eax
80103c70:	eb 0b                	jmp    80103c7d <mpconfig+0x9f>
  *pmp = mp;
80103c72:	8b 45 08             	mov    0x8(%ebp),%eax
80103c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c78:	89 10                	mov    %edx,(%eax)
  return conf;
80103c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c7d:	c9                   	leave  
80103c7e:	c3                   	ret    

80103c7f <mpinit>:

void
mpinit(void)
{
80103c7f:	55                   	push   %ebp
80103c80:	89 e5                	mov    %esp,%ebp
80103c82:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c85:	83 ec 0c             	sub    $0xc,%esp
80103c88:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c8b:	50                   	push   %eax
80103c8c:	e8 4d ff ff ff       	call   80103bde <mpconfig>
80103c91:	83 c4 10             	add    $0x10,%esp
80103c94:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c9b:	75 0d                	jne    80103caa <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103c9d:	83 ec 0c             	sub    $0xc,%esp
80103ca0:	68 5a 8d 10 80       	push   $0x80108d5a
80103ca5:	e8 f6 c8 ff ff       	call   801005a0 <panic>
  ismp = 1;
80103caa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cb4:	8b 40 24             	mov    0x24(%eax),%eax
80103cb7:	a3 fc 46 11 80       	mov    %eax,0x801146fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cbf:	83 c0 2c             	add    $0x2c,%eax
80103cc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cc8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103ccc:	0f b7 d0             	movzwl %ax,%edx
80103ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cd2:	01 d0                	add    %edx,%eax
80103cd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103cd7:	eb 7b                	jmp    80103d54 <mpinit+0xd5>
    switch(*p){
80103cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdc:	0f b6 00             	movzbl (%eax),%eax
80103cdf:	0f b6 c0             	movzbl %al,%eax
80103ce2:	83 f8 04             	cmp    $0x4,%eax
80103ce5:	77 65                	ja     80103d4c <mpinit+0xcd>
80103ce7:	8b 04 85 94 8d 10 80 	mov    -0x7fef726c(,%eax,4),%eax
80103cee:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103cf6:	a1 80 4d 11 80       	mov    0x80114d80,%eax
80103cfb:	83 f8 07             	cmp    $0x7,%eax
80103cfe:	7f 28                	jg     80103d28 <mpinit+0xa9>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d00:	8b 15 80 4d 11 80    	mov    0x80114d80,%edx
80103d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d09:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d0d:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103d13:	81 c2 00 48 11 80    	add    $0x80114800,%edx
80103d19:	88 02                	mov    %al,(%edx)
        ncpu++;
80103d1b:	a1 80 4d 11 80       	mov    0x80114d80,%eax
80103d20:	83 c0 01             	add    $0x1,%eax
80103d23:	a3 80 4d 11 80       	mov    %eax,0x80114d80
      }
      p += sizeof(struct mpproc);
80103d28:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d2c:	eb 26                	jmp    80103d54 <mpinit+0xd5>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d31:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d37:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d3b:	a2 e0 47 11 80       	mov    %al,0x801147e0
      p += sizeof(struct mpioapic);
80103d40:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d44:	eb 0e                	jmp    80103d54 <mpinit+0xd5>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d46:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d4a:	eb 08                	jmp    80103d54 <mpinit+0xd5>
    default:
      ismp = 0;
80103d4c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d53:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d57:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d5a:	0f 82 79 ff ff ff    	jb     80103cd9 <mpinit+0x5a>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103d60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d64:	75 0d                	jne    80103d73 <mpinit+0xf4>
    panic("Didn't find a suitable machine");
80103d66:	83 ec 0c             	sub    $0xc,%esp
80103d69:	68 74 8d 10 80       	push   $0x80108d74
80103d6e:	e8 2d c8 ff ff       	call   801005a0 <panic>

  if(mp->imcrp){
80103d73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d76:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d7a:	84 c0                	test   %al,%al
80103d7c:	74 30                	je     80103dae <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d7e:	83 ec 08             	sub    $0x8,%esp
80103d81:	6a 70                	push   $0x70
80103d83:	6a 22                	push   $0x22
80103d85:	e8 d8 fc ff ff       	call   80103a62 <outb>
80103d8a:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d8d:	83 ec 0c             	sub    $0xc,%esp
80103d90:	6a 23                	push   $0x23
80103d92:	e8 ae fc ff ff       	call   80103a45 <inb>
80103d97:	83 c4 10             	add    $0x10,%esp
80103d9a:	83 c8 01             	or     $0x1,%eax
80103d9d:	0f b6 c0             	movzbl %al,%eax
80103da0:	83 ec 08             	sub    $0x8,%esp
80103da3:	50                   	push   %eax
80103da4:	6a 23                	push   $0x23
80103da6:	e8 b7 fc ff ff       	call   80103a62 <outb>
80103dab:	83 c4 10             	add    $0x10,%esp
  }
}
80103dae:	90                   	nop
80103daf:	c9                   	leave  
80103db0:	c3                   	ret    

80103db1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	83 ec 08             	sub    $0x8,%esp
80103db7:	8b 55 08             	mov    0x8(%ebp),%edx
80103dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dbd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dc1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dc4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dc8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dcc:	ee                   	out    %al,(%dx)
}
80103dcd:	90                   	nop
80103dce:	c9                   	leave  
80103dcf:	c3                   	ret    

80103dd0 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103dd0:	55                   	push   %ebp
80103dd1:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103dd3:	68 ff 00 00 00       	push   $0xff
80103dd8:	6a 21                	push   $0x21
80103dda:	e8 d2 ff ff ff       	call   80103db1 <outb>
80103ddf:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103de2:	68 ff 00 00 00       	push   $0xff
80103de7:	68 a1 00 00 00       	push   $0xa1
80103dec:	e8 c0 ff ff ff       	call   80103db1 <outb>
80103df1:	83 c4 08             	add    $0x8,%esp
}
80103df4:	90                   	nop
80103df5:	c9                   	leave  
80103df6:	c3                   	ret    

80103df7 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103df7:	55                   	push   %ebp
80103df8:	89 e5                	mov    %esp,%ebp
80103dfa:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103dfd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e04:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e10:	8b 10                	mov    (%eax),%edx
80103e12:	8b 45 08             	mov    0x8(%ebp),%eax
80103e15:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e17:	e8 0a d2 ff ff       	call   80101026 <filealloc>
80103e1c:	89 c2                	mov    %eax,%edx
80103e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e21:	89 10                	mov    %edx,(%eax)
80103e23:	8b 45 08             	mov    0x8(%ebp),%eax
80103e26:	8b 00                	mov    (%eax),%eax
80103e28:	85 c0                	test   %eax,%eax
80103e2a:	0f 84 cb 00 00 00    	je     80103efb <pipealloc+0x104>
80103e30:	e8 f1 d1 ff ff       	call   80101026 <filealloc>
80103e35:	89 c2                	mov    %eax,%edx
80103e37:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e3a:	89 10                	mov    %edx,(%eax)
80103e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e3f:	8b 00                	mov    (%eax),%eax
80103e41:	85 c0                	test   %eax,%eax
80103e43:	0f 84 b2 00 00 00    	je     80103efb <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e49:	e8 7a ee ff ff       	call   80102cc8 <kalloc>
80103e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e55:	0f 84 9f 00 00 00    	je     80103efa <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e5e:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e65:	00 00 00 
  p->writeopen = 1;
80103e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6b:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e72:	00 00 00 
  p->nwrite = 0;
80103e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e78:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e7f:	00 00 00 
  p->nread = 0;
80103e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e85:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e8c:	00 00 00 
  initlock(&p->lock, "pipe");
80103e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e92:	83 ec 08             	sub    $0x8,%esp
80103e95:	68 a8 8d 10 80       	push   $0x80108da8
80103e9a:	50                   	push   %eax
80103e9b:	e8 0d 11 00 00       	call   80104fad <initlock>
80103ea0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea6:	8b 00                	mov    (%eax),%eax
80103ea8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103eae:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb1:	8b 00                	mov    (%eax),%eax
80103eb3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eba:	8b 00                	mov    (%eax),%eax
80103ebc:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec3:	8b 00                	mov    (%eax),%eax
80103ec5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ec8:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ece:	8b 00                	mov    (%eax),%eax
80103ed0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed9:	8b 00                	mov    (%eax),%eax
80103edb:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103edf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee2:	8b 00                	mov    (%eax),%eax
80103ee4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eeb:	8b 00                	mov    (%eax),%eax
80103eed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ef0:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ef3:	b8 00 00 00 00       	mov    $0x0,%eax
80103ef8:	eb 4e                	jmp    80103f48 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103efa:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103efb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eff:	74 0e                	je     80103f0f <pipealloc+0x118>
    kfree((char*)p);
80103f01:	83 ec 0c             	sub    $0xc,%esp
80103f04:	ff 75 f4             	pushl  -0xc(%ebp)
80103f07:	e8 22 ed ff ff       	call   80102c2e <kfree>
80103f0c:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f12:	8b 00                	mov    (%eax),%eax
80103f14:	85 c0                	test   %eax,%eax
80103f16:	74 11                	je     80103f29 <pipealloc+0x132>
    fileclose(*f0);
80103f18:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1b:	8b 00                	mov    (%eax),%eax
80103f1d:	83 ec 0c             	sub    $0xc,%esp
80103f20:	50                   	push   %eax
80103f21:	e8 be d1 ff ff       	call   801010e4 <fileclose>
80103f26:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2c:	8b 00                	mov    (%eax),%eax
80103f2e:	85 c0                	test   %eax,%eax
80103f30:	74 11                	je     80103f43 <pipealloc+0x14c>
    fileclose(*f1);
80103f32:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f35:	8b 00                	mov    (%eax),%eax
80103f37:	83 ec 0c             	sub    $0xc,%esp
80103f3a:	50                   	push   %eax
80103f3b:	e8 a4 d1 ff ff       	call   801010e4 <fileclose>
80103f40:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f48:	c9                   	leave  
80103f49:	c3                   	ret    

80103f4a <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f4a:	55                   	push   %ebp
80103f4b:	89 e5                	mov    %esp,%ebp
80103f4d:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f50:	8b 45 08             	mov    0x8(%ebp),%eax
80103f53:	83 ec 0c             	sub    $0xc,%esp
80103f56:	50                   	push   %eax
80103f57:	e8 73 10 00 00       	call   80104fcf <acquire>
80103f5c:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f63:	74 23                	je     80103f88 <pipeclose+0x3e>
    p->writeopen = 0;
80103f65:	8b 45 08             	mov    0x8(%ebp),%eax
80103f68:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f6f:	00 00 00 
    wakeup(&p->nread);
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	05 34 02 00 00       	add    $0x234,%eax
80103f7a:	83 ec 0c             	sub    $0xc,%esp
80103f7d:	50                   	push   %eax
80103f7e:	e8 13 0d 00 00       	call   80104c96 <wakeup>
80103f83:	83 c4 10             	add    $0x10,%esp
80103f86:	eb 21                	jmp    80103fa9 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103f88:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8b:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f92:	00 00 00 
    wakeup(&p->nwrite);
80103f95:	8b 45 08             	mov    0x8(%ebp),%eax
80103f98:	05 38 02 00 00       	add    $0x238,%eax
80103f9d:	83 ec 0c             	sub    $0xc,%esp
80103fa0:	50                   	push   %eax
80103fa1:	e8 f0 0c 00 00       	call   80104c96 <wakeup>
80103fa6:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fac:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fb2:	85 c0                	test   %eax,%eax
80103fb4:	75 2c                	jne    80103fe2 <pipeclose+0x98>
80103fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb9:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103fbf:	85 c0                	test   %eax,%eax
80103fc1:	75 1f                	jne    80103fe2 <pipeclose+0x98>
    release(&p->lock);
80103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc6:	83 ec 0c             	sub    $0xc,%esp
80103fc9:	50                   	push   %eax
80103fca:	e8 6e 10 00 00       	call   8010503d <release>
80103fcf:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103fd2:	83 ec 0c             	sub    $0xc,%esp
80103fd5:	ff 75 08             	pushl  0x8(%ebp)
80103fd8:	e8 51 ec ff ff       	call   80102c2e <kfree>
80103fdd:	83 c4 10             	add    $0x10,%esp
80103fe0:	eb 0f                	jmp    80103ff1 <pipeclose+0xa7>
  } else
    release(&p->lock);
80103fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe5:	83 ec 0c             	sub    $0xc,%esp
80103fe8:	50                   	push   %eax
80103fe9:	e8 4f 10 00 00       	call   8010503d <release>
80103fee:	83 c4 10             	add    $0x10,%esp
}
80103ff1:	90                   	nop
80103ff2:	c9                   	leave  
80103ff3:	c3                   	ret    

80103ff4 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103ff4:	55                   	push   %ebp
80103ff5:	89 e5                	mov    %esp,%ebp
80103ff7:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	83 ec 0c             	sub    $0xc,%esp
80104000:	50                   	push   %eax
80104001:	e8 c9 0f 00 00       	call   80104fcf <acquire>
80104006:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104009:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104010:	e9 ac 00 00 00       	jmp    801040c1 <pipewrite+0xcd>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80104015:	8b 45 08             	mov    0x8(%ebp),%eax
80104018:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010401e:	85 c0                	test   %eax,%eax
80104020:	74 0c                	je     8010402e <pipewrite+0x3a>
80104022:	e8 99 02 00 00       	call   801042c0 <myproc>
80104027:	8b 40 24             	mov    0x24(%eax),%eax
8010402a:	85 c0                	test   %eax,%eax
8010402c:	74 19                	je     80104047 <pipewrite+0x53>
        release(&p->lock);
8010402e:	8b 45 08             	mov    0x8(%ebp),%eax
80104031:	83 ec 0c             	sub    $0xc,%esp
80104034:	50                   	push   %eax
80104035:	e8 03 10 00 00       	call   8010503d <release>
8010403a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010403d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104042:	e9 a8 00 00 00       	jmp    801040ef <pipewrite+0xfb>
      }
      wakeup(&p->nread);
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	05 34 02 00 00       	add    $0x234,%eax
8010404f:	83 ec 0c             	sub    $0xc,%esp
80104052:	50                   	push   %eax
80104053:	e8 3e 0c 00 00       	call   80104c96 <wakeup>
80104058:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010405b:	8b 45 08             	mov    0x8(%ebp),%eax
8010405e:	8b 55 08             	mov    0x8(%ebp),%edx
80104061:	81 c2 38 02 00 00    	add    $0x238,%edx
80104067:	83 ec 08             	sub    $0x8,%esp
8010406a:	50                   	push   %eax
8010406b:	52                   	push   %edx
8010406c:	e8 3c 0b 00 00       	call   80104bad <sleep>
80104071:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104074:	8b 45 08             	mov    0x8(%ebp),%eax
80104077:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010407d:	8b 45 08             	mov    0x8(%ebp),%eax
80104080:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104086:	05 00 02 00 00       	add    $0x200,%eax
8010408b:	39 c2                	cmp    %eax,%edx
8010408d:	74 86                	je     80104015 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010408f:	8b 45 08             	mov    0x8(%ebp),%eax
80104092:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104098:	8d 48 01             	lea    0x1(%eax),%ecx
8010409b:	8b 55 08             	mov    0x8(%ebp),%edx
8010409e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801040a4:	25 ff 01 00 00       	and    $0x1ff,%eax
801040a9:	89 c1                	mov    %eax,%ecx
801040ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b1:	01 d0                	add    %edx,%eax
801040b3:	0f b6 10             	movzbl (%eax),%edx
801040b6:	8b 45 08             	mov    0x8(%ebp),%eax
801040b9:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801040bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c4:	3b 45 10             	cmp    0x10(%ebp),%eax
801040c7:	7c ab                	jl     80104074 <pipewrite+0x80>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801040c9:	8b 45 08             	mov    0x8(%ebp),%eax
801040cc:	05 34 02 00 00       	add    $0x234,%eax
801040d1:	83 ec 0c             	sub    $0xc,%esp
801040d4:	50                   	push   %eax
801040d5:	e8 bc 0b 00 00       	call   80104c96 <wakeup>
801040da:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801040dd:	8b 45 08             	mov    0x8(%ebp),%eax
801040e0:	83 ec 0c             	sub    $0xc,%esp
801040e3:	50                   	push   %eax
801040e4:	e8 54 0f 00 00       	call   8010503d <release>
801040e9:	83 c4 10             	add    $0x10,%esp
  return n;
801040ec:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040ef:	c9                   	leave  
801040f0:	c3                   	ret    

801040f1 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040f1:	55                   	push   %ebp
801040f2:	89 e5                	mov    %esp,%ebp
801040f4:	53                   	push   %ebx
801040f5:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	83 ec 0c             	sub    $0xc,%esp
801040fe:	50                   	push   %eax
801040ff:	e8 cb 0e 00 00       	call   80104fcf <acquire>
80104104:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104107:	eb 3e                	jmp    80104147 <piperead+0x56>
    if(myproc()->killed){
80104109:	e8 b2 01 00 00       	call   801042c0 <myproc>
8010410e:	8b 40 24             	mov    0x24(%eax),%eax
80104111:	85 c0                	test   %eax,%eax
80104113:	74 19                	je     8010412e <piperead+0x3d>
      release(&p->lock);
80104115:	8b 45 08             	mov    0x8(%ebp),%eax
80104118:	83 ec 0c             	sub    $0xc,%esp
8010411b:	50                   	push   %eax
8010411c:	e8 1c 0f 00 00       	call   8010503d <release>
80104121:	83 c4 10             	add    $0x10,%esp
      return -1;
80104124:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104129:	e9 bf 00 00 00       	jmp    801041ed <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010412e:	8b 45 08             	mov    0x8(%ebp),%eax
80104131:	8b 55 08             	mov    0x8(%ebp),%edx
80104134:	81 c2 34 02 00 00    	add    $0x234,%edx
8010413a:	83 ec 08             	sub    $0x8,%esp
8010413d:	50                   	push   %eax
8010413e:	52                   	push   %edx
8010413f:	e8 69 0a 00 00       	call   80104bad <sleep>
80104144:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104147:	8b 45 08             	mov    0x8(%ebp),%eax
8010414a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104159:	39 c2                	cmp    %eax,%edx
8010415b:	75 0d                	jne    8010416a <piperead+0x79>
8010415d:	8b 45 08             	mov    0x8(%ebp),%eax
80104160:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104166:	85 c0                	test   %eax,%eax
80104168:	75 9f                	jne    80104109 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010416a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104171:	eb 49                	jmp    801041bc <piperead+0xcb>
    if(p->nread == p->nwrite)
80104173:	8b 45 08             	mov    0x8(%ebp),%eax
80104176:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104185:	39 c2                	cmp    %eax,%edx
80104187:	74 3d                	je     801041c6 <piperead+0xd5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104189:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010418c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010418f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104192:	8b 45 08             	mov    0x8(%ebp),%eax
80104195:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010419b:	8d 48 01             	lea    0x1(%eax),%ecx
8010419e:	8b 55 08             	mov    0x8(%ebp),%edx
801041a1:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041a7:	25 ff 01 00 00       	and    $0x1ff,%eax
801041ac:	89 c2                	mov    %eax,%edx
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801041b6:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bf:	3b 45 10             	cmp    0x10(%ebp),%eax
801041c2:	7c af                	jl     80104173 <piperead+0x82>
801041c4:	eb 01                	jmp    801041c7 <piperead+0xd6>
    if(p->nread == p->nwrite)
      break;
801041c6:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041c7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ca:	05 38 02 00 00       	add    $0x238,%eax
801041cf:	83 ec 0c             	sub    $0xc,%esp
801041d2:	50                   	push   %eax
801041d3:	e8 be 0a 00 00       	call   80104c96 <wakeup>
801041d8:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801041db:	8b 45 08             	mov    0x8(%ebp),%eax
801041de:	83 ec 0c             	sub    $0xc,%esp
801041e1:	50                   	push   %eax
801041e2:	e8 56 0e 00 00       	call   8010503d <release>
801041e7:	83 c4 10             	add    $0x10,%esp
  return i;
801041ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041f0:	c9                   	leave  
801041f1:	c3                   	ret    

801041f2 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801041f2:	55                   	push   %ebp
801041f3:	89 e5                	mov    %esp,%ebp
801041f5:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041f8:	9c                   	pushf  
801041f9:	58                   	pop    %eax
801041fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104200:	c9                   	leave  
80104201:	c3                   	ret    

80104202 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104202:	55                   	push   %ebp
80104203:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104205:	fb                   	sti    
}
80104206:	90                   	nop
80104207:	5d                   	pop    %ebp
80104208:	c3                   	ret    

80104209 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104209:	55                   	push   %ebp
8010420a:	89 e5                	mov    %esp,%ebp
8010420c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010420f:	83 ec 08             	sub    $0x8,%esp
80104212:	68 b0 8d 10 80       	push   $0x80108db0
80104217:	68 a0 4d 11 80       	push   $0x80114da0
8010421c:	e8 8c 0d 00 00       	call   80104fad <initlock>
80104221:	83 c4 10             	add    $0x10,%esp
}
80104224:	90                   	nop
80104225:	c9                   	leave  
80104226:	c3                   	ret    

80104227 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104227:	55                   	push   %ebp
80104228:	89 e5                	mov    %esp,%ebp
8010422a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010422d:	e8 16 00 00 00       	call   80104248 <mycpu>
80104232:	89 c2                	mov    %eax,%edx
80104234:	b8 00 48 11 80       	mov    $0x80114800,%eax
80104239:	29 c2                	sub    %eax,%edx
8010423b:	89 d0                	mov    %edx,%eax
8010423d:	c1 f8 04             	sar    $0x4,%eax
80104240:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104246:	c9                   	leave  
80104247:	c3                   	ret    

80104248 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104248:	55                   	push   %ebp
80104249:	89 e5                	mov    %esp,%ebp
8010424b:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010424e:	e8 9f ff ff ff       	call   801041f2 <readeflags>
80104253:	25 00 02 00 00       	and    $0x200,%eax
80104258:	85 c0                	test   %eax,%eax
8010425a:	74 0d                	je     80104269 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
8010425c:	83 ec 0c             	sub    $0xc,%esp
8010425f:	68 b8 8d 10 80       	push   $0x80108db8
80104264:	e8 37 c3 ff ff       	call   801005a0 <panic>
  
  apicid = lapicid();
80104269:	e8 b0 ed ff ff       	call   8010301e <lapicid>
8010426e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104271:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104278:	eb 2d                	jmp    801042a7 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
8010427a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104283:	05 00 48 11 80       	add    $0x80114800,%eax
80104288:	0f b6 00             	movzbl (%eax),%eax
8010428b:	0f b6 c0             	movzbl %al,%eax
8010428e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104291:	75 10                	jne    801042a3 <mycpu+0x5b>
      return &cpus[i];
80104293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104296:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010429c:	05 00 48 11 80       	add    $0x80114800,%eax
801042a1:	eb 1b                	jmp    801042be <mycpu+0x76>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042a7:	a1 80 4d 11 80       	mov    0x80114d80,%eax
801042ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042af:	7c c9                	jl     8010427a <mycpu+0x32>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801042b1:	83 ec 0c             	sub    $0xc,%esp
801042b4:	68 de 8d 10 80       	push   $0x80108dde
801042b9:	e8 e2 c2 ff ff       	call   801005a0 <panic>
}
801042be:	c9                   	leave  
801042bf:	c3                   	ret    

801042c0 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801042c0:	55                   	push   %ebp
801042c1:	89 e5                	mov    %esp,%ebp
801042c3:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801042c6:	e8 6f 0e 00 00       	call   8010513a <pushcli>
  c = mycpu();
801042cb:	e8 78 ff ff ff       	call   80104248 <mycpu>
801042d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801042d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042df:	e8 a4 0e 00 00       	call   80105188 <popcli>
  return p;
801042e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042e7:	c9                   	leave  
801042e8:	c3                   	ret    

801042e9 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801042e9:	55                   	push   %ebp
801042ea:	89 e5                	mov    %esp,%ebp
801042ec:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801042ef:	83 ec 0c             	sub    $0xc,%esp
801042f2:	68 a0 4d 11 80       	push   $0x80114da0
801042f7:	e8 d3 0c 00 00       	call   80104fcf <acquire>
801042fc:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042ff:	c7 45 f4 d4 4d 11 80 	movl   $0x80114dd4,-0xc(%ebp)
80104306:	eb 11                	jmp    80104319 <allocproc+0x30>
    if(p->state == UNUSED)
80104308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430b:	8b 40 0c             	mov    0xc(%eax),%eax
8010430e:	85 c0                	test   %eax,%eax
80104310:	74 2a                	je     8010433c <allocproc+0x53>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104312:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104319:	81 7d f4 d4 6e 11 80 	cmpl   $0x80116ed4,-0xc(%ebp)
80104320:	72 e6                	jb     80104308 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80104322:	83 ec 0c             	sub    $0xc,%esp
80104325:	68 a0 4d 11 80       	push   $0x80114da0
8010432a:	e8 0e 0d 00 00       	call   8010503d <release>
8010432f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104332:	b8 00 00 00 00       	mov    $0x0,%eax
80104337:	e9 b4 00 00 00       	jmp    801043f0 <allocproc+0x107>

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010433c:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010433d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104340:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104347:	a1 00 c0 10 80       	mov    0x8010c000,%eax
8010434c:	8d 50 01             	lea    0x1(%eax),%edx
8010434f:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104355:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104358:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	68 a0 4d 11 80       	push   $0x80114da0
80104363:	e8 d5 0c 00 00       	call   8010503d <release>
80104368:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010436b:	e8 58 e9 ff ff       	call   80102cc8 <kalloc>
80104370:	89 c2                	mov    %eax,%edx
80104372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104375:	89 50 08             	mov    %edx,0x8(%eax)
80104378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437b:	8b 40 08             	mov    0x8(%eax),%eax
8010437e:	85 c0                	test   %eax,%eax
80104380:	75 11                	jne    80104393 <allocproc+0xaa>
    p->state = UNUSED;
80104382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104385:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010438c:	b8 00 00 00 00       	mov    $0x0,%eax
80104391:	eb 5d                	jmp    801043f0 <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	8b 40 08             	mov    0x8(%eax),%eax
80104399:	05 00 10 00 00       	add    $0x1000,%eax
8010439e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043a1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ab:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043ae:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043b2:	ba 38 66 10 80       	mov    $0x80106638,%edx
801043b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043ba:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043bc:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043c6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801043cf:	83 ec 04             	sub    $0x4,%esp
801043d2:	6a 14                	push   $0x14
801043d4:	6a 00                	push   $0x0
801043d6:	50                   	push   %eax
801043d7:	e8 6a 0e 00 00       	call   80105246 <memset>
801043dc:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801043df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e2:	8b 40 1c             	mov    0x1c(%eax),%eax
801043e5:	ba 67 4b 10 80       	mov    $0x80104b67,%edx
801043ea:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043f0:	c9                   	leave  
801043f1:	c3                   	ret    

801043f2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801043f2:	55                   	push   %ebp
801043f3:	89 e5                	mov    %esp,%ebp
801043f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801043f8:	e8 ec fe ff ff       	call   801042e9 <allocproc>
801043fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  //cprintf("USERINIT");
  

  initproc = p;
80104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104403:	a3 20 c6 10 80       	mov    %eax,0x8010c620
  if((p->pgdir = setupkvm()) == 0)
80104408:	e8 d7 38 00 00       	call   80107ce4 <setupkvm>
8010440d:	89 c2                	mov    %eax,%edx
8010440f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104412:	89 50 04             	mov    %edx,0x4(%eax)
80104415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104418:	8b 40 04             	mov    0x4(%eax),%eax
8010441b:	85 c0                	test   %eax,%eax
8010441d:	75 0d                	jne    8010442c <userinit+0x3a>
    panic("userinit: out of memory?");
8010441f:	83 ec 0c             	sub    $0xc,%esp
80104422:	68 ee 8d 10 80       	push   $0x80108dee
80104427:	e8 74 c1 ff ff       	call   801005a0 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010442c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104434:	8b 40 04             	mov    0x4(%eax),%eax
80104437:	83 ec 04             	sub    $0x4,%esp
8010443a:	52                   	push   %edx
8010443b:	68 c0 c4 10 80       	push   $0x8010c4c0
80104440:	50                   	push   %eax
80104441:	e8 06 3b 00 00       	call   80107f4c <inituvm>
80104446:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	8b 40 18             	mov    0x18(%eax),%eax
80104458:	83 ec 04             	sub    $0x4,%esp
8010445b:	6a 4c                	push   $0x4c
8010445d:	6a 00                	push   $0x0
8010445f:	50                   	push   %eax
80104460:	e8 e1 0d 00 00       	call   80105246 <memset>
80104465:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446b:	8b 40 18             	mov    0x18(%eax),%eax
8010446e:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104477:	8b 40 18             	mov    0x18(%eax),%eax
8010447a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104483:	8b 40 18             	mov    0x18(%eax),%eax
80104486:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104489:	8b 52 18             	mov    0x18(%edx),%edx
8010448c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104490:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	8b 40 18             	mov    0x18(%eax),%eax
8010449a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449d:	8b 52 18             	mov    0x18(%edx),%edx
801044a0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044a4:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ab:	8b 40 18             	mov    0x18(%eax),%eax
801044ae:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b8:	8b 40 18             	mov    0x18(%eax),%eax
801044bb:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c5:	8b 40 18             	mov    0x18(%eax),%eax
801044c8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d2:	83 c0 6c             	add    $0x6c,%eax
801044d5:	83 ec 04             	sub    $0x4,%esp
801044d8:	6a 10                	push   $0x10
801044da:	68 07 8e 10 80       	push   $0x80108e07
801044df:	50                   	push   %eax
801044e0:	e8 64 0f 00 00       	call   80105449 <safestrcpy>
801044e5:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801044e8:	83 ec 0c             	sub    $0xc,%esp
801044eb:	68 10 8e 10 80       	push   $0x80108e10
801044f0:	e8 8e e0 ff ff       	call   80102583 <namei>
801044f5:	83 c4 10             	add    $0x10,%esp
801044f8:	89 c2                	mov    %eax,%edx
801044fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fd:	89 50 68             	mov    %edx,0x68(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104500:	83 ec 0c             	sub    $0xc,%esp
80104503:	68 a0 4d 11 80       	push   $0x80114da0
80104508:	e8 c2 0a 00 00       	call   80104fcf <acquire>
8010450d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010451a:	83 ec 0c             	sub    $0xc,%esp
8010451d:	68 a0 4d 11 80       	push   $0x80114da0
80104522:	e8 16 0b 00 00       	call   8010503d <release>
80104527:	83 c4 10             	add    $0x10,%esp
}
8010452a:	90                   	nop
8010452b:	c9                   	leave  
8010452c:	c3                   	ret    

8010452d <growproc>:
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
// Changed for cs 153
int
growproc(int n)
{
8010452d:	55                   	push   %ebp
8010452e:	89 e5                	mov    %esp,%ebp
80104530:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104533:	e8 88 fd ff ff       	call   801042c0 <myproc>
80104538:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
//  cprintf("GROWPROC");

  sz = curproc->sz;
8010453b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453e:	8b 00                	mov    (%eax),%eax
80104540:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  sz = curproc->last_page;
  if(n > 0){
80104543:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104547:	7e 2e                	jle    80104577 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104549:	8b 55 08             	mov    0x8(%ebp),%edx
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	01 c2                	add    %eax,%edx
80104551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104554:	8b 40 04             	mov    0x4(%eax),%eax
80104557:	83 ec 04             	sub    $0x4,%esp
8010455a:	52                   	push   %edx
8010455b:	ff 75 f4             	pushl  -0xc(%ebp)
8010455e:	50                   	push   %eax
8010455f:	e8 25 3b 00 00       	call   80108089 <allocuvm>
80104564:	83 c4 10             	add    $0x10,%esp
80104567:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010456a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010456e:	75 3b                	jne    801045ab <growproc+0x7e>
      return -1;
80104570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104575:	eb 4f                	jmp    801045c6 <growproc+0x99>
  } else if(n < 0){
80104577:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010457b:	79 2e                	jns    801045ab <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010457d:	8b 55 08             	mov    0x8(%ebp),%edx
80104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104583:	01 c2                	add    %eax,%edx
80104585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104588:	8b 40 04             	mov    0x4(%eax),%eax
8010458b:	83 ec 04             	sub    $0x4,%esp
8010458e:	52                   	push   %edx
8010458f:	ff 75 f4             	pushl  -0xc(%ebp)
80104592:	50                   	push   %eax
80104593:	e8 f6 3b 00 00       	call   8010818e <deallocuvm>
80104598:	83 c4 10             	add    $0x10,%esp
8010459b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010459e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045a2:	75 07                	jne    801045ab <growproc+0x7e>
      return -1;
801045a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a9:	eb 1b                	jmp    801045c6 <growproc+0x99>
  }
  curproc->sz = sz;
801045ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b1:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801045b3:	83 ec 0c             	sub    $0xc,%esp
801045b6:	ff 75 f0             	pushl  -0x10(%ebp)
801045b9:	e8 f0 37 00 00       	call   80107dae <switchuvm>
801045be:	83 c4 10             	add    $0x10,%esp
  return 0;
801045c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045c6:	c9                   	leave  
801045c7:	c3                   	ret    

801045c8 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045c8:	55                   	push   %ebp
801045c9:	89 e5                	mov    %esp,%ebp
801045cb:	57                   	push   %edi
801045cc:	56                   	push   %esi
801045cd:	53                   	push   %ebx
801045ce:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801045d1:	e8 ea fc ff ff       	call   801042c0 <myproc>
801045d6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801045d9:	e8 0b fd ff ff       	call   801042e9 <allocproc>
801045de:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045e5:	75 0a                	jne    801045f1 <fork+0x29>
    return -1;
801045e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ec:	e9 78 01 00 00       	jmp    80104769 <fork+0x1a1>
  // cprintf("SP2: %x\n", curproc->tf->esp);


  // Copy process state from proc.
  // Changed the parameters such that it takes in the top of the stack and number of pages allocated to the stack CS153
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->stackTop, curproc->pageNum)) == 0){
801045f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045f4:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
801045fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045fd:	8b 48 7c             	mov    0x7c(%eax),%ecx
80104600:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104603:	8b 10                	mov    (%eax),%edx
80104605:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104608:	8b 40 04             	mov    0x4(%eax),%eax
8010460b:	53                   	push   %ebx
8010460c:	51                   	push   %ecx
8010460d:	52                   	push   %edx
8010460e:	50                   	push   %eax
8010460f:	e8 18 3d 00 00       	call   8010832c <copyuvm>
80104614:	83 c4 10             	add    $0x10,%esp
80104617:	89 c2                	mov    %eax,%edx
80104619:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010461c:	89 50 04             	mov    %edx,0x4(%eax)
8010461f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104622:	8b 40 04             	mov    0x4(%eax),%eax
80104625:	85 c0                	test   %eax,%eax
80104627:	75 30                	jne    80104659 <fork+0x91>
    kfree(np->kstack);
80104629:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010462c:	8b 40 08             	mov    0x8(%eax),%eax
8010462f:	83 ec 0c             	sub    $0xc,%esp
80104632:	50                   	push   %eax
80104633:	e8 f6 e5 ff ff       	call   80102c2e <kfree>
80104638:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010463b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010463e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104645:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104648:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010464f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104654:	e9 10 01 00 00       	jmp    80104769 <fork+0x1a1>
  }

  // Make sure that all paramters added by our code are transfered to the new process CS153
  np->sz = curproc->sz;
80104659:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010465c:	8b 10                	mov    (%eax),%edx
8010465e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104661:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104663:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104666:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104669:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010466c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010466f:	8b 50 18             	mov    0x18(%eax),%edx
80104672:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104675:	8b 40 18             	mov    0x18(%eax),%eax
80104678:	89 c3                	mov    %eax,%ebx
8010467a:	b8 13 00 00 00       	mov    $0x13,%eax
8010467f:	89 d7                	mov    %edx,%edi
80104681:	89 de                	mov    %ebx,%esi
80104683:	89 c1                	mov    %eax,%ecx
80104685:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->stackTop = curproc->stackTop;
80104687:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468a:	8b 50 7c             	mov    0x7c(%eax),%edx
8010468d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104690:	89 50 7c             	mov    %edx,0x7c(%eax)
  np->pageNum = curproc->pageNum;
80104693:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104696:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
8010469c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010469f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a8:	8b 40 18             	mov    0x18(%eax),%eax
801046ab:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046b9:	eb 3d                	jmp    801046f8 <fork+0x130>
    if(curproc->ofile[i])
801046bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046c1:	83 c2 08             	add    $0x8,%edx
801046c4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046c8:	85 c0                	test   %eax,%eax
801046ca:	74 28                	je     801046f4 <fork+0x12c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046d2:	83 c2 08             	add    $0x8,%edx
801046d5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046d9:	83 ec 0c             	sub    $0xc,%esp
801046dc:	50                   	push   %eax
801046dd:	e8 b1 c9 ff ff       	call   80101093 <filedup>
801046e2:	83 c4 10             	add    $0x10,%esp
801046e5:	89 c1                	mov    %eax,%ecx
801046e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046ed:	83 c2 08             	add    $0x8,%edx
801046f0:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  np->stackTop = curproc->stackTop;
  np->pageNum = curproc->pageNum;
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046f4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801046f8:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046fc:	7e bd                	jle    801046bb <fork+0xf3>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801046fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104701:	8b 40 68             	mov    0x68(%eax),%eax
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	50                   	push   %eax
80104708:	e8 fc d2 ff ff       	call   80101a09 <idup>
8010470d:	83 c4 10             	add    $0x10,%esp
80104710:	89 c2                	mov    %eax,%edx
80104712:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104715:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104718:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010471e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104721:	83 c0 6c             	add    $0x6c,%eax
80104724:	83 ec 04             	sub    $0x4,%esp
80104727:	6a 10                	push   $0x10
80104729:	52                   	push   %edx
8010472a:	50                   	push   %eax
8010472b:	e8 19 0d 00 00       	call   80105449 <safestrcpy>
80104730:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104733:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104736:	8b 40 10             	mov    0x10(%eax),%eax
80104739:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010473c:	83 ec 0c             	sub    $0xc,%esp
8010473f:	68 a0 4d 11 80       	push   $0x80114da0
80104744:	e8 86 08 00 00       	call   80104fcf <acquire>
80104749:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010474c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010474f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104756:	83 ec 0c             	sub    $0xc,%esp
80104759:	68 a0 4d 11 80       	push   $0x80114da0
8010475e:	e8 da 08 00 00       	call   8010503d <release>
80104763:	83 c4 10             	add    $0x10,%esp

  return pid;
80104766:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104769:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010476c:	5b                   	pop    %ebx
8010476d:	5e                   	pop    %esi
8010476e:	5f                   	pop    %edi
8010476f:	5d                   	pop    %ebp
80104770:	c3                   	ret    

80104771 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104771:	55                   	push   %ebp
80104772:	89 e5                	mov    %esp,%ebp
80104774:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104777:	e8 44 fb ff ff       	call   801042c0 <myproc>
8010477c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010477f:	a1 20 c6 10 80       	mov    0x8010c620,%eax
80104784:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104787:	75 0d                	jne    80104796 <exit+0x25>
    panic("init exiting");
80104789:	83 ec 0c             	sub    $0xc,%esp
8010478c:	68 12 8e 10 80       	push   $0x80108e12
80104791:	e8 0a be ff ff       	call   801005a0 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104796:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010479d:	eb 3f                	jmp    801047de <exit+0x6d>
    if(curproc->ofile[fd]){
8010479f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047a5:	83 c2 08             	add    $0x8,%edx
801047a8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047ac:	85 c0                	test   %eax,%eax
801047ae:	74 2a                	je     801047da <exit+0x69>
      fileclose(curproc->ofile[fd]);
801047b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047b6:	83 c2 08             	add    $0x8,%edx
801047b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047bd:	83 ec 0c             	sub    $0xc,%esp
801047c0:	50                   	push   %eax
801047c1:	e8 1e c9 ff ff       	call   801010e4 <fileclose>
801047c6:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801047c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047cf:	83 c2 08             	add    $0x8,%edx
801047d2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047d9:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801047de:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047e2:	7e bb                	jle    8010479f <exit+0x2e>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
801047e4:	e8 7f ed ff ff       	call   80103568 <begin_op>
  iput(curproc->cwd);
801047e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ec:	8b 40 68             	mov    0x68(%eax),%eax
801047ef:	83 ec 0c             	sub    $0xc,%esp
801047f2:	50                   	push   %eax
801047f3:	e8 ac d3 ff ff       	call   80101ba4 <iput>
801047f8:	83 c4 10             	add    $0x10,%esp
  end_op();
801047fb:	e8 f4 ed ff ff       	call   801035f4 <end_op>
  curproc->cwd = 0;
80104800:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104803:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010480a:	83 ec 0c             	sub    $0xc,%esp
8010480d:	68 a0 4d 11 80       	push   $0x80114da0
80104812:	e8 b8 07 00 00       	call   80104fcf <acquire>
80104817:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010481a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010481d:	8b 40 14             	mov    0x14(%eax),%eax
80104820:	83 ec 0c             	sub    $0xc,%esp
80104823:	50                   	push   %eax
80104824:	e8 2b 04 00 00       	call   80104c54 <wakeup1>
80104829:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010482c:	c7 45 f4 d4 4d 11 80 	movl   $0x80114dd4,-0xc(%ebp)
80104833:	eb 3a                	jmp    8010486f <exit+0xfe>
    if(p->parent == curproc){
80104835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104838:	8b 40 14             	mov    0x14(%eax),%eax
8010483b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010483e:	75 28                	jne    80104868 <exit+0xf7>
      p->parent = initproc;
80104840:	8b 15 20 c6 10 80    	mov    0x8010c620,%edx
80104846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104849:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010484c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484f:	8b 40 0c             	mov    0xc(%eax),%eax
80104852:	83 f8 05             	cmp    $0x5,%eax
80104855:	75 11                	jne    80104868 <exit+0xf7>
        wakeup1(initproc);
80104857:	a1 20 c6 10 80       	mov    0x8010c620,%eax
8010485c:	83 ec 0c             	sub    $0xc,%esp
8010485f:	50                   	push   %eax
80104860:	e8 ef 03 00 00       	call   80104c54 <wakeup1>
80104865:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104868:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010486f:	81 7d f4 d4 6e 11 80 	cmpl   $0x80116ed4,-0xc(%ebp)
80104876:	72 bd                	jb     80104835 <exit+0xc4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104878:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010487b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104882:	e8 eb 01 00 00       	call   80104a72 <sched>
  panic("zombie exit");
80104887:	83 ec 0c             	sub    $0xc,%esp
8010488a:	68 1f 8e 10 80       	push   $0x80108e1f
8010488f:	e8 0c bd ff ff       	call   801005a0 <panic>

80104894 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104894:	55                   	push   %ebp
80104895:	89 e5                	mov    %esp,%ebp
80104897:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010489a:	e8 21 fa ff ff       	call   801042c0 <myproc>
8010489f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801048a2:	83 ec 0c             	sub    $0xc,%esp
801048a5:	68 a0 4d 11 80       	push   $0x80114da0
801048aa:	e8 20 07 00 00       	call   80104fcf <acquire>
801048af:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801048b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b9:	c7 45 f4 d4 4d 11 80 	movl   $0x80114dd4,-0xc(%ebp)
801048c0:	e9 a4 00 00 00       	jmp    80104969 <wait+0xd5>
      if(p->parent != curproc)
801048c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c8:	8b 40 14             	mov    0x14(%eax),%eax
801048cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048ce:	0f 85 8d 00 00 00    	jne    80104961 <wait+0xcd>
        continue;
      havekids = 1;
801048d4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048de:	8b 40 0c             	mov    0xc(%eax),%eax
801048e1:	83 f8 05             	cmp    $0x5,%eax
801048e4:	75 7c                	jne    80104962 <wait+0xce>
        // Found one.
        pid = p->pid;
801048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e9:	8b 40 10             	mov    0x10(%eax),%eax
801048ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801048ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f2:	8b 40 08             	mov    0x8(%eax),%eax
801048f5:	83 ec 0c             	sub    $0xc,%esp
801048f8:	50                   	push   %eax
801048f9:	e8 30 e3 ff ff       	call   80102c2e <kfree>
801048fe:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104904:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010490b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490e:	8b 40 04             	mov    0x4(%eax),%eax
80104911:	83 ec 0c             	sub    $0xc,%esp
80104914:	50                   	push   %eax
80104915:	e8 38 39 00 00       	call   80108252 <freevm>
8010491a:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104934:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104945:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010494c:	83 ec 0c             	sub    $0xc,%esp
8010494f:	68 a0 4d 11 80       	push   $0x80114da0
80104954:	e8 e4 06 00 00       	call   8010503d <release>
80104959:	83 c4 10             	add    $0x10,%esp
        return pid;
8010495c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010495f:	eb 54                	jmp    801049b5 <wait+0x121>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
80104961:	90                   	nop
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104962:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104969:	81 7d f4 d4 6e 11 80 	cmpl   $0x80116ed4,-0xc(%ebp)
80104970:	0f 82 4f ff ff ff    	jb     801048c5 <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104976:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010497a:	74 0a                	je     80104986 <wait+0xf2>
8010497c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010497f:	8b 40 24             	mov    0x24(%eax),%eax
80104982:	85 c0                	test   %eax,%eax
80104984:	74 17                	je     8010499d <wait+0x109>
      release(&ptable.lock);
80104986:	83 ec 0c             	sub    $0xc,%esp
80104989:	68 a0 4d 11 80       	push   $0x80114da0
8010498e:	e8 aa 06 00 00       	call   8010503d <release>
80104993:	83 c4 10             	add    $0x10,%esp
      return -1;
80104996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010499b:	eb 18                	jmp    801049b5 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010499d:	83 ec 08             	sub    $0x8,%esp
801049a0:	68 a0 4d 11 80       	push   $0x80114da0
801049a5:	ff 75 ec             	pushl  -0x14(%ebp)
801049a8:	e8 00 02 00 00       	call   80104bad <sleep>
801049ad:	83 c4 10             	add    $0x10,%esp
  }
801049b0:	e9 fd fe ff ff       	jmp    801048b2 <wait+0x1e>
}
801049b5:	c9                   	leave  
801049b6:	c3                   	ret    

801049b7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801049b7:	55                   	push   %ebp
801049b8:	89 e5                	mov    %esp,%ebp
801049ba:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801049bd:	e8 86 f8 ff ff       	call   80104248 <mycpu>
801049c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801049c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801049cf:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801049d2:	e8 2b f8 ff ff       	call   80104202 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049d7:	83 ec 0c             	sub    $0xc,%esp
801049da:	68 a0 4d 11 80       	push   $0x80114da0
801049df:	e8 eb 05 00 00       	call   80104fcf <acquire>
801049e4:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e7:	c7 45 f4 d4 4d 11 80 	movl   $0x80114dd4,-0xc(%ebp)
801049ee:	eb 64                	jmp    80104a54 <scheduler+0x9d>
      if(p->state != RUNNABLE)
801049f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f3:	8b 40 0c             	mov    0xc(%eax),%eax
801049f6:	83 f8 03             	cmp    $0x3,%eax
801049f9:	75 51                	jne    80104a4c <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801049fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a01:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	ff 75 f4             	pushl  -0xc(%ebp)
80104a0d:	e8 9c 33 00 00       	call   80107dae <switchuvm>
80104a12:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a18:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a22:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a28:	83 c2 04             	add    $0x4,%edx
80104a2b:	83 ec 08             	sub    $0x8,%esp
80104a2e:	50                   	push   %eax
80104a2f:	52                   	push   %edx
80104a30:	e8 85 0a 00 00       	call   801054ba <swtch>
80104a35:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104a38:	e8 58 33 00 00       	call   80107d95 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a40:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a47:	00 00 00 
80104a4a:	eb 01                	jmp    80104a4d <scheduler+0x96>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104a4c:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4d:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a54:	81 7d f4 d4 6e 11 80 	cmpl   $0x80116ed4,-0xc(%ebp)
80104a5b:	72 93                	jb     801049f0 <scheduler+0x39>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104a5d:	83 ec 0c             	sub    $0xc,%esp
80104a60:	68 a0 4d 11 80       	push   $0x80114da0
80104a65:	e8 d3 05 00 00       	call   8010503d <release>
80104a6a:	83 c4 10             	add    $0x10,%esp

  }
80104a6d:	e9 60 ff ff ff       	jmp    801049d2 <scheduler+0x1b>

80104a72 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104a72:	55                   	push   %ebp
80104a73:	89 e5                	mov    %esp,%ebp
80104a75:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104a78:	e8 43 f8 ff ff       	call   801042c0 <myproc>
80104a7d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104a80:	83 ec 0c             	sub    $0xc,%esp
80104a83:	68 a0 4d 11 80       	push   $0x80114da0
80104a88:	e8 7c 06 00 00       	call   80105109 <holding>
80104a8d:	83 c4 10             	add    $0x10,%esp
80104a90:	85 c0                	test   %eax,%eax
80104a92:	75 0d                	jne    80104aa1 <sched+0x2f>
    panic("sched ptable.lock");
80104a94:	83 ec 0c             	sub    $0xc,%esp
80104a97:	68 2b 8e 10 80       	push   $0x80108e2b
80104a9c:	e8 ff ba ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli != 1)
80104aa1:	e8 a2 f7 ff ff       	call   80104248 <mycpu>
80104aa6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104aac:	83 f8 01             	cmp    $0x1,%eax
80104aaf:	74 0d                	je     80104abe <sched+0x4c>
    panic("sched locks");
80104ab1:	83 ec 0c             	sub    $0xc,%esp
80104ab4:	68 3d 8e 10 80       	push   $0x80108e3d
80104ab9:	e8 e2 ba ff ff       	call   801005a0 <panic>
  if(p->state == RUNNING)
80104abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac4:	83 f8 04             	cmp    $0x4,%eax
80104ac7:	75 0d                	jne    80104ad6 <sched+0x64>
    panic("sched running");
80104ac9:	83 ec 0c             	sub    $0xc,%esp
80104acc:	68 49 8e 10 80       	push   $0x80108e49
80104ad1:	e8 ca ba ff ff       	call   801005a0 <panic>
  if(readeflags()&FL_IF)
80104ad6:	e8 17 f7 ff ff       	call   801041f2 <readeflags>
80104adb:	25 00 02 00 00       	and    $0x200,%eax
80104ae0:	85 c0                	test   %eax,%eax
80104ae2:	74 0d                	je     80104af1 <sched+0x7f>
    panic("sched interruptible");
80104ae4:	83 ec 0c             	sub    $0xc,%esp
80104ae7:	68 57 8e 10 80       	push   $0x80108e57
80104aec:	e8 af ba ff ff       	call   801005a0 <panic>
  intena = mycpu()->intena;
80104af1:	e8 52 f7 ff ff       	call   80104248 <mycpu>
80104af6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104aff:	e8 44 f7 ff ff       	call   80104248 <mycpu>
80104b04:	8b 40 04             	mov    0x4(%eax),%eax
80104b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b0a:	83 c2 1c             	add    $0x1c,%edx
80104b0d:	83 ec 08             	sub    $0x8,%esp
80104b10:	50                   	push   %eax
80104b11:	52                   	push   %edx
80104b12:	e8 a3 09 00 00       	call   801054ba <swtch>
80104b17:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b1a:	e8 29 f7 ff ff       	call   80104248 <mycpu>
80104b1f:	89 c2                	mov    %eax,%edx
80104b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b24:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
}
80104b2a:	90                   	nop
80104b2b:	c9                   	leave  
80104b2c:	c3                   	ret    

80104b2d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b2d:	55                   	push   %ebp
80104b2e:	89 e5                	mov    %esp,%ebp
80104b30:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b33:	83 ec 0c             	sub    $0xc,%esp
80104b36:	68 a0 4d 11 80       	push   $0x80114da0
80104b3b:	e8 8f 04 00 00       	call   80104fcf <acquire>
80104b40:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104b43:	e8 78 f7 ff ff       	call   801042c0 <myproc>
80104b48:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b4f:	e8 1e ff ff ff       	call   80104a72 <sched>
  release(&ptable.lock);
80104b54:	83 ec 0c             	sub    $0xc,%esp
80104b57:	68 a0 4d 11 80       	push   $0x80114da0
80104b5c:	e8 dc 04 00 00       	call   8010503d <release>
80104b61:	83 c4 10             	add    $0x10,%esp
}
80104b64:	90                   	nop
80104b65:	c9                   	leave  
80104b66:	c3                   	ret    

80104b67 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b67:	55                   	push   %ebp
80104b68:	89 e5                	mov    %esp,%ebp
80104b6a:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	68 a0 4d 11 80       	push   $0x80114da0
80104b75:	e8 c3 04 00 00       	call   8010503d <release>
80104b7a:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104b7d:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b82:	85 c0                	test   %eax,%eax
80104b84:	74 24                	je     80104baa <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b86:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104b8d:	00 00 00 
    iinit(ROOTDEV);
80104b90:	83 ec 0c             	sub    $0xc,%esp
80104b93:	6a 01                	push   $0x1
80104b95:	e8 37 cb ff ff       	call   801016d1 <iinit>
80104b9a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104b9d:	83 ec 0c             	sub    $0xc,%esp
80104ba0:	6a 01                	push   $0x1
80104ba2:	e8 a3 e7 ff ff       	call   8010334a <initlog>
80104ba7:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104baa:	90                   	nop
80104bab:	c9                   	leave  
80104bac:	c3                   	ret    

80104bad <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bad:	55                   	push   %ebp
80104bae:	89 e5                	mov    %esp,%ebp
80104bb0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104bb3:	e8 08 f7 ff ff       	call   801042c0 <myproc>
80104bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bbf:	75 0d                	jne    80104bce <sleep+0x21>
    panic("sleep");
80104bc1:	83 ec 0c             	sub    $0xc,%esp
80104bc4:	68 6b 8e 10 80       	push   $0x80108e6b
80104bc9:	e8 d2 b9 ff ff       	call   801005a0 <panic>

  if(lk == 0)
80104bce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104bd2:	75 0d                	jne    80104be1 <sleep+0x34>
    panic("sleep without lk");
80104bd4:	83 ec 0c             	sub    $0xc,%esp
80104bd7:	68 71 8e 10 80       	push   $0x80108e71
80104bdc:	e8 bf b9 ff ff       	call   801005a0 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104be1:	81 7d 0c a0 4d 11 80 	cmpl   $0x80114da0,0xc(%ebp)
80104be8:	74 1e                	je     80104c08 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104bea:	83 ec 0c             	sub    $0xc,%esp
80104bed:	68 a0 4d 11 80       	push   $0x80114da0
80104bf2:	e8 d8 03 00 00       	call   80104fcf <acquire>
80104bf7:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104bfa:	83 ec 0c             	sub    $0xc,%esp
80104bfd:	ff 75 0c             	pushl  0xc(%ebp)
80104c00:	e8 38 04 00 00       	call   8010503d <release>
80104c05:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0b:	8b 55 08             	mov    0x8(%ebp),%edx
80104c0e:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c1b:	e8 52 fe ff ff       	call   80104a72 <sched>

  // Tidy up.
  p->chan = 0;
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c2a:	81 7d 0c a0 4d 11 80 	cmpl   $0x80114da0,0xc(%ebp)
80104c31:	74 1e                	je     80104c51 <sleep+0xa4>
    release(&ptable.lock);
80104c33:	83 ec 0c             	sub    $0xc,%esp
80104c36:	68 a0 4d 11 80       	push   $0x80114da0
80104c3b:	e8 fd 03 00 00       	call   8010503d <release>
80104c40:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	ff 75 0c             	pushl  0xc(%ebp)
80104c49:	e8 81 03 00 00       	call   80104fcf <acquire>
80104c4e:	83 c4 10             	add    $0x10,%esp
  }
}
80104c51:	90                   	nop
80104c52:	c9                   	leave  
80104c53:	c3                   	ret    

80104c54 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c54:	55                   	push   %ebp
80104c55:	89 e5                	mov    %esp,%ebp
80104c57:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c5a:	c7 45 fc d4 4d 11 80 	movl   $0x80114dd4,-0x4(%ebp)
80104c61:	eb 27                	jmp    80104c8a <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104c63:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c66:	8b 40 0c             	mov    0xc(%eax),%eax
80104c69:	83 f8 02             	cmp    $0x2,%eax
80104c6c:	75 15                	jne    80104c83 <wakeup1+0x2f>
80104c6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c71:	8b 40 20             	mov    0x20(%eax),%eax
80104c74:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c77:	75 0a                	jne    80104c83 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c7c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c83:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104c8a:	81 7d fc d4 6e 11 80 	cmpl   $0x80116ed4,-0x4(%ebp)
80104c91:	72 d0                	jb     80104c63 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c93:	90                   	nop
80104c94:	c9                   	leave  
80104c95:	c3                   	ret    

80104c96 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c96:	55                   	push   %ebp
80104c97:	89 e5                	mov    %esp,%ebp
80104c99:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104c9c:	83 ec 0c             	sub    $0xc,%esp
80104c9f:	68 a0 4d 11 80       	push   $0x80114da0
80104ca4:	e8 26 03 00 00       	call   80104fcf <acquire>
80104ca9:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104cac:	83 ec 0c             	sub    $0xc,%esp
80104caf:	ff 75 08             	pushl  0x8(%ebp)
80104cb2:	e8 9d ff ff ff       	call   80104c54 <wakeup1>
80104cb7:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104cba:	83 ec 0c             	sub    $0xc,%esp
80104cbd:	68 a0 4d 11 80       	push   $0x80114da0
80104cc2:	e8 76 03 00 00       	call   8010503d <release>
80104cc7:	83 c4 10             	add    $0x10,%esp
}
80104cca:	90                   	nop
80104ccb:	c9                   	leave  
80104ccc:	c3                   	ret    

80104ccd <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ccd:	55                   	push   %ebp
80104cce:	89 e5                	mov    %esp,%ebp
80104cd0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104cd3:	83 ec 0c             	sub    $0xc,%esp
80104cd6:	68 a0 4d 11 80       	push   $0x80114da0
80104cdb:	e8 ef 02 00 00       	call   80104fcf <acquire>
80104ce0:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ce3:	c7 45 f4 d4 4d 11 80 	movl   $0x80114dd4,-0xc(%ebp)
80104cea:	eb 48                	jmp    80104d34 <kill+0x67>
    if(p->pid == pid){
80104cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cef:	8b 40 10             	mov    0x10(%eax),%eax
80104cf2:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cf5:	75 36                	jne    80104d2d <kill+0x60>
      p->killed = 1;
80104cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cfa:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d04:	8b 40 0c             	mov    0xc(%eax),%eax
80104d07:	83 f8 02             	cmp    $0x2,%eax
80104d0a:	75 0a                	jne    80104d16 <kill+0x49>
        p->state = RUNNABLE;
80104d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d16:	83 ec 0c             	sub    $0xc,%esp
80104d19:	68 a0 4d 11 80       	push   $0x80114da0
80104d1e:	e8 1a 03 00 00       	call   8010503d <release>
80104d23:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d26:	b8 00 00 00 00       	mov    $0x0,%eax
80104d2b:	eb 25                	jmp    80104d52 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d2d:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d34:	81 7d f4 d4 6e 11 80 	cmpl   $0x80116ed4,-0xc(%ebp)
80104d3b:	72 af                	jb     80104cec <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d3d:	83 ec 0c             	sub    $0xc,%esp
80104d40:	68 a0 4d 11 80       	push   $0x80114da0
80104d45:	e8 f3 02 00 00       	call   8010503d <release>
80104d4a:	83 c4 10             	add    $0x10,%esp
  return -1;
80104d4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d52:	c9                   	leave  
80104d53:	c3                   	ret    

80104d54 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d54:	55                   	push   %ebp
80104d55:	89 e5                	mov    %esp,%ebp
80104d57:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d5a:	c7 45 f0 d4 4d 11 80 	movl   $0x80114dd4,-0x10(%ebp)
80104d61:	e9 da 00 00 00       	jmp    80104e40 <procdump+0xec>
    if(p->state == UNUSED)
80104d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d69:	8b 40 0c             	mov    0xc(%eax),%eax
80104d6c:	85 c0                	test   %eax,%eax
80104d6e:	0f 84 c4 00 00 00    	je     80104e38 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d77:	8b 40 0c             	mov    0xc(%eax),%eax
80104d7a:	83 f8 05             	cmp    $0x5,%eax
80104d7d:	77 23                	ja     80104da2 <procdump+0x4e>
80104d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d82:	8b 40 0c             	mov    0xc(%eax),%eax
80104d85:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d8c:	85 c0                	test   %eax,%eax
80104d8e:	74 12                	je     80104da2 <procdump+0x4e>
      state = states[p->state];
80104d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d93:	8b 40 0c             	mov    0xc(%eax),%eax
80104d96:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104da0:	eb 07                	jmp    80104da9 <procdump+0x55>
    else
      state = "???";
80104da2:	c7 45 ec 82 8e 10 80 	movl   $0x80108e82,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dac:	8d 50 6c             	lea    0x6c(%eax),%edx
80104daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db2:	8b 40 10             	mov    0x10(%eax),%eax
80104db5:	52                   	push   %edx
80104db6:	ff 75 ec             	pushl  -0x14(%ebp)
80104db9:	50                   	push   %eax
80104dba:	68 86 8e 10 80       	push   $0x80108e86
80104dbf:	e8 3c b6 ff ff       	call   80100400 <cprintf>
80104dc4:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dca:	8b 40 0c             	mov    0xc(%eax),%eax
80104dcd:	83 f8 02             	cmp    $0x2,%eax
80104dd0:	75 54                	jne    80104e26 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd5:	8b 40 1c             	mov    0x1c(%eax),%eax
80104dd8:	8b 40 0c             	mov    0xc(%eax),%eax
80104ddb:	83 c0 08             	add    $0x8,%eax
80104dde:	89 c2                	mov    %eax,%edx
80104de0:	83 ec 08             	sub    $0x8,%esp
80104de3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104de6:	50                   	push   %eax
80104de7:	52                   	push   %edx
80104de8:	e8 a2 02 00 00       	call   8010508f <getcallerpcs>
80104ded:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104df0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104df7:	eb 1c                	jmp    80104e15 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e00:	83 ec 08             	sub    $0x8,%esp
80104e03:	50                   	push   %eax
80104e04:	68 8f 8e 10 80       	push   $0x80108e8f
80104e09:	e8 f2 b5 ff ff       	call   80100400 <cprintf>
80104e0e:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e15:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e19:	7f 0b                	jg     80104e26 <procdump+0xd2>
80104e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e1e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e22:	85 c0                	test   %eax,%eax
80104e24:	75 d3                	jne    80104df9 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e26:	83 ec 0c             	sub    $0xc,%esp
80104e29:	68 93 8e 10 80       	push   $0x80108e93
80104e2e:	e8 cd b5 ff ff       	call   80100400 <cprintf>
80104e33:	83 c4 10             	add    $0x10,%esp
80104e36:	eb 01                	jmp    80104e39 <procdump+0xe5>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104e38:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e39:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e40:	81 7d f0 d4 6e 11 80 	cmpl   $0x80116ed4,-0x10(%ebp)
80104e47:	0f 82 19 ff ff ff    	jb     80104d66 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e4d:	90                   	nop
80104e4e:	c9                   	leave  
80104e4f:	c3                   	ret    

80104e50 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104e50:	55                   	push   %ebp
80104e51:	89 e5                	mov    %esp,%ebp
80104e53:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104e56:	8b 45 08             	mov    0x8(%ebp),%eax
80104e59:	83 c0 04             	add    $0x4,%eax
80104e5c:	83 ec 08             	sub    $0x8,%esp
80104e5f:	68 bf 8e 10 80       	push   $0x80108ebf
80104e64:	50                   	push   %eax
80104e65:	e8 43 01 00 00       	call   80104fad <initlock>
80104e6a:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e70:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e73:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104e76:	8b 45 08             	mov    0x8(%ebp),%eax
80104e79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e82:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104e89:	90                   	nop
80104e8a:	c9                   	leave  
80104e8b:	c3                   	ret    

80104e8c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104e8c:	55                   	push   %ebp
80104e8d:	89 e5                	mov    %esp,%ebp
80104e8f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104e92:	8b 45 08             	mov    0x8(%ebp),%eax
80104e95:	83 c0 04             	add    $0x4,%eax
80104e98:	83 ec 0c             	sub    $0xc,%esp
80104e9b:	50                   	push   %eax
80104e9c:	e8 2e 01 00 00       	call   80104fcf <acquire>
80104ea1:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ea4:	eb 15                	jmp    80104ebb <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea9:	83 c0 04             	add    $0x4,%eax
80104eac:	83 ec 08             	sub    $0x8,%esp
80104eaf:	50                   	push   %eax
80104eb0:	ff 75 08             	pushl  0x8(%ebp)
80104eb3:	e8 f5 fc ff ff       	call   80104bad <sleep>
80104eb8:	83 c4 10             	add    $0x10,%esp

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebe:	8b 00                	mov    (%eax),%eax
80104ec0:	85 c0                	test   %eax,%eax
80104ec2:	75 e2                	jne    80104ea6 <acquiresleep+0x1a>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104ecd:	e8 ee f3 ff ff       	call   801042c0 <myproc>
80104ed2:	8b 50 10             	mov    0x10(%eax),%edx
80104ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed8:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104edb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ede:	83 c0 04             	add    $0x4,%eax
80104ee1:	83 ec 0c             	sub    $0xc,%esp
80104ee4:	50                   	push   %eax
80104ee5:	e8 53 01 00 00       	call   8010503d <release>
80104eea:	83 c4 10             	add    $0x10,%esp
}
80104eed:	90                   	nop
80104eee:	c9                   	leave  
80104eef:	c3                   	ret    

80104ef0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104ef0:	55                   	push   %ebp
80104ef1:	89 e5                	mov    %esp,%ebp
80104ef3:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef9:	83 c0 04             	add    $0x4,%eax
80104efc:	83 ec 0c             	sub    $0xc,%esp
80104eff:	50                   	push   %eax
80104f00:	e8 ca 00 00 00       	call   80104fcf <acquire>
80104f05:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f08:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f11:	8b 45 08             	mov    0x8(%ebp),%eax
80104f14:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f1b:	83 ec 0c             	sub    $0xc,%esp
80104f1e:	ff 75 08             	pushl  0x8(%ebp)
80104f21:	e8 70 fd ff ff       	call   80104c96 <wakeup>
80104f26:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f29:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2c:	83 c0 04             	add    $0x4,%eax
80104f2f:	83 ec 0c             	sub    $0xc,%esp
80104f32:	50                   	push   %eax
80104f33:	e8 05 01 00 00       	call   8010503d <release>
80104f38:	83 c4 10             	add    $0x10,%esp
}
80104f3b:	90                   	nop
80104f3c:	c9                   	leave  
80104f3d:	c3                   	ret    

80104f3e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104f3e:	55                   	push   %ebp
80104f3f:	89 e5                	mov    %esp,%ebp
80104f41:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	83 c0 04             	add    $0x4,%eax
80104f4a:	83 ec 0c             	sub    $0xc,%esp
80104f4d:	50                   	push   %eax
80104f4e:	e8 7c 00 00 00       	call   80104fcf <acquire>
80104f53:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104f56:	8b 45 08             	mov    0x8(%ebp),%eax
80104f59:	8b 00                	mov    (%eax),%eax
80104f5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f61:	83 c0 04             	add    $0x4,%eax
80104f64:	83 ec 0c             	sub    $0xc,%esp
80104f67:	50                   	push   %eax
80104f68:	e8 d0 00 00 00       	call   8010503d <release>
80104f6d:	83 c4 10             	add    $0x10,%esp
  return r;
80104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f73:	c9                   	leave  
80104f74:	c3                   	ret    

80104f75 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f75:	55                   	push   %ebp
80104f76:	89 e5                	mov    %esp,%ebp
80104f78:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f7b:	9c                   	pushf  
80104f7c:	58                   	pop    %eax
80104f7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f83:	c9                   	leave  
80104f84:	c3                   	ret    

80104f85 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104f85:	55                   	push   %ebp
80104f86:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104f88:	fa                   	cli    
}
80104f89:	90                   	nop
80104f8a:	5d                   	pop    %ebp
80104f8b:	c3                   	ret    

80104f8c <sti>:

static inline void
sti(void)
{
80104f8c:	55                   	push   %ebp
80104f8d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f8f:	fb                   	sti    
}
80104f90:	90                   	nop
80104f91:	5d                   	pop    %ebp
80104f92:	c3                   	ret    

80104f93 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104f93:	55                   	push   %ebp
80104f94:	89 e5                	mov    %esp,%ebp
80104f96:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104f99:	8b 55 08             	mov    0x8(%ebp),%edx
80104f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fa2:	f0 87 02             	lock xchg %eax,(%edx)
80104fa5:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104fa8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fab:	c9                   	leave  
80104fac:	c3                   	ret    

80104fad <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104fad:	55                   	push   %ebp
80104fae:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fb6:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104fcc:	90                   	nop
80104fcd:	5d                   	pop    %ebp
80104fce:	c3                   	ret    

80104fcf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104fcf:	55                   	push   %ebp
80104fd0:	89 e5                	mov    %esp,%ebp
80104fd2:	53                   	push   %ebx
80104fd3:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104fd6:	e8 5f 01 00 00       	call   8010513a <pushcli>
  if(holding(lk))
80104fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104fde:	83 ec 0c             	sub    $0xc,%esp
80104fe1:	50                   	push   %eax
80104fe2:	e8 22 01 00 00       	call   80105109 <holding>
80104fe7:	83 c4 10             	add    $0x10,%esp
80104fea:	85 c0                	test   %eax,%eax
80104fec:	74 0d                	je     80104ffb <acquire+0x2c>
    panic("acquire");
80104fee:	83 ec 0c             	sub    $0xc,%esp
80104ff1:	68 ca 8e 10 80       	push   $0x80108eca
80104ff6:	e8 a5 b5 ff ff       	call   801005a0 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104ffb:	90                   	nop
80104ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fff:	83 ec 08             	sub    $0x8,%esp
80105002:	6a 01                	push   $0x1
80105004:	50                   	push   %eax
80105005:	e8 89 ff ff ff       	call   80104f93 <xchg>
8010500a:	83 c4 10             	add    $0x10,%esp
8010500d:	85 c0                	test   %eax,%eax
8010500f:	75 eb                	jne    80104ffc <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105011:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105016:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105019:	e8 2a f2 ff ff       	call   80104248 <mycpu>
8010501e:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105021:	8b 45 08             	mov    0x8(%ebp),%eax
80105024:	83 c0 0c             	add    $0xc,%eax
80105027:	83 ec 08             	sub    $0x8,%esp
8010502a:	50                   	push   %eax
8010502b:	8d 45 08             	lea    0x8(%ebp),%eax
8010502e:	50                   	push   %eax
8010502f:	e8 5b 00 00 00       	call   8010508f <getcallerpcs>
80105034:	83 c4 10             	add    $0x10,%esp
}
80105037:	90                   	nop
80105038:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010503b:	c9                   	leave  
8010503c:	c3                   	ret    

8010503d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010503d:	55                   	push   %ebp
8010503e:	89 e5                	mov    %esp,%ebp
80105040:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105043:	83 ec 0c             	sub    $0xc,%esp
80105046:	ff 75 08             	pushl  0x8(%ebp)
80105049:	e8 bb 00 00 00       	call   80105109 <holding>
8010504e:	83 c4 10             	add    $0x10,%esp
80105051:	85 c0                	test   %eax,%eax
80105053:	75 0d                	jne    80105062 <release+0x25>
    panic("release");
80105055:	83 ec 0c             	sub    $0xc,%esp
80105058:	68 d2 8e 10 80       	push   $0x80108ed2
8010505d:	e8 3e b5 ff ff       	call   801005a0 <panic>

  lk->pcs[0] = 0;
80105062:	8b 45 08             	mov    0x8(%ebp),%eax
80105065:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010506c:	8b 45 08             	mov    0x8(%ebp),%eax
8010506f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105076:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010507b:	8b 45 08             	mov    0x8(%ebp),%eax
8010507e:	8b 55 08             	mov    0x8(%ebp),%edx
80105081:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105087:	e8 fc 00 00 00       	call   80105188 <popcli>
}
8010508c:	90                   	nop
8010508d:	c9                   	leave  
8010508e:	c3                   	ret    

8010508f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010508f:	55                   	push   %ebp
80105090:	89 e5                	mov    %esp,%ebp
80105092:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105095:	8b 45 08             	mov    0x8(%ebp),%eax
80105098:	83 e8 08             	sub    $0x8,%eax
8010509b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010509e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050a5:	eb 38                	jmp    801050df <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050a7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050ab:	74 53                	je     80105100 <getcallerpcs+0x71>
801050ad:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050b4:	76 4a                	jbe    80105100 <getcallerpcs+0x71>
801050b6:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050ba:	74 44                	je     80105100 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801050c9:	01 c2                	add    %eax,%edx
801050cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ce:	8b 40 04             	mov    0x4(%eax),%eax
801050d1:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801050d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050d6:	8b 00                	mov    (%eax),%eax
801050d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801050db:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801050df:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801050e3:	7e c2                	jle    801050a7 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801050e5:	eb 19                	jmp    80105100 <getcallerpcs+0x71>
    pcs[i] = 0;
801050e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f4:	01 d0                	add    %edx,%eax
801050f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801050fc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105100:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105104:	7e e1                	jle    801050e7 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105106:	90                   	nop
80105107:	c9                   	leave  
80105108:	c3                   	ret    

80105109 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105109:	55                   	push   %ebp
8010510a:	89 e5                	mov    %esp,%ebp
8010510c:	53                   	push   %ebx
8010510d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105110:	8b 45 08             	mov    0x8(%ebp),%eax
80105113:	8b 00                	mov    (%eax),%eax
80105115:	85 c0                	test   %eax,%eax
80105117:	74 16                	je     8010512f <holding+0x26>
80105119:	8b 45 08             	mov    0x8(%ebp),%eax
8010511c:	8b 58 08             	mov    0x8(%eax),%ebx
8010511f:	e8 24 f1 ff ff       	call   80104248 <mycpu>
80105124:	39 c3                	cmp    %eax,%ebx
80105126:	75 07                	jne    8010512f <holding+0x26>
80105128:	b8 01 00 00 00       	mov    $0x1,%eax
8010512d:	eb 05                	jmp    80105134 <holding+0x2b>
8010512f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105134:	83 c4 04             	add    $0x4,%esp
80105137:	5b                   	pop    %ebx
80105138:	5d                   	pop    %ebp
80105139:	c3                   	ret    

8010513a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010513a:	55                   	push   %ebp
8010513b:	89 e5                	mov    %esp,%ebp
8010513d:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105140:	e8 30 fe ff ff       	call   80104f75 <readeflags>
80105145:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105148:	e8 38 fe ff ff       	call   80104f85 <cli>
  if(mycpu()->ncli == 0)
8010514d:	e8 f6 f0 ff ff       	call   80104248 <mycpu>
80105152:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105158:	85 c0                	test   %eax,%eax
8010515a:	75 15                	jne    80105171 <pushcli+0x37>
    mycpu()->intena = eflags & FL_IF;
8010515c:	e8 e7 f0 ff ff       	call   80104248 <mycpu>
80105161:	89 c2                	mov    %eax,%edx
80105163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105166:	25 00 02 00 00       	and    $0x200,%eax
8010516b:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
  mycpu()->ncli += 1;
80105171:	e8 d2 f0 ff ff       	call   80104248 <mycpu>
80105176:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010517c:	83 c2 01             	add    $0x1,%edx
8010517f:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105185:	90                   	nop
80105186:	c9                   	leave  
80105187:	c3                   	ret    

80105188 <popcli>:

void
popcli(void)
{
80105188:	55                   	push   %ebp
80105189:	89 e5                	mov    %esp,%ebp
8010518b:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010518e:	e8 e2 fd ff ff       	call   80104f75 <readeflags>
80105193:	25 00 02 00 00       	and    $0x200,%eax
80105198:	85 c0                	test   %eax,%eax
8010519a:	74 0d                	je     801051a9 <popcli+0x21>
    panic("popcli - interruptible");
8010519c:	83 ec 0c             	sub    $0xc,%esp
8010519f:	68 da 8e 10 80       	push   $0x80108eda
801051a4:	e8 f7 b3 ff ff       	call   801005a0 <panic>
  if(--mycpu()->ncli < 0)
801051a9:	e8 9a f0 ff ff       	call   80104248 <mycpu>
801051ae:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051b4:	83 ea 01             	sub    $0x1,%edx
801051b7:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801051bd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051c3:	85 c0                	test   %eax,%eax
801051c5:	79 0d                	jns    801051d4 <popcli+0x4c>
    panic("popcli");
801051c7:	83 ec 0c             	sub    $0xc,%esp
801051ca:	68 f1 8e 10 80       	push   $0x80108ef1
801051cf:	e8 cc b3 ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801051d4:	e8 6f f0 ff ff       	call   80104248 <mycpu>
801051d9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051df:	85 c0                	test   %eax,%eax
801051e1:	75 14                	jne    801051f7 <popcli+0x6f>
801051e3:	e8 60 f0 ff ff       	call   80104248 <mycpu>
801051e8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801051ee:	85 c0                	test   %eax,%eax
801051f0:	74 05                	je     801051f7 <popcli+0x6f>
    sti();
801051f2:	e8 95 fd ff ff       	call   80104f8c <sti>
}
801051f7:	90                   	nop
801051f8:	c9                   	leave  
801051f9:	c3                   	ret    

801051fa <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801051fa:	55                   	push   %ebp
801051fb:	89 e5                	mov    %esp,%ebp
801051fd:	57                   	push   %edi
801051fe:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801051ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105202:	8b 55 10             	mov    0x10(%ebp),%edx
80105205:	8b 45 0c             	mov    0xc(%ebp),%eax
80105208:	89 cb                	mov    %ecx,%ebx
8010520a:	89 df                	mov    %ebx,%edi
8010520c:	89 d1                	mov    %edx,%ecx
8010520e:	fc                   	cld    
8010520f:	f3 aa                	rep stos %al,%es:(%edi)
80105211:	89 ca                	mov    %ecx,%edx
80105213:	89 fb                	mov    %edi,%ebx
80105215:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105218:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010521b:	90                   	nop
8010521c:	5b                   	pop    %ebx
8010521d:	5f                   	pop    %edi
8010521e:	5d                   	pop    %ebp
8010521f:	c3                   	ret    

80105220 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105220:	55                   	push   %ebp
80105221:	89 e5                	mov    %esp,%ebp
80105223:	57                   	push   %edi
80105224:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105225:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105228:	8b 55 10             	mov    0x10(%ebp),%edx
8010522b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010522e:	89 cb                	mov    %ecx,%ebx
80105230:	89 df                	mov    %ebx,%edi
80105232:	89 d1                	mov    %edx,%ecx
80105234:	fc                   	cld    
80105235:	f3 ab                	rep stos %eax,%es:(%edi)
80105237:	89 ca                	mov    %ecx,%edx
80105239:	89 fb                	mov    %edi,%ebx
8010523b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010523e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105241:	90                   	nop
80105242:	5b                   	pop    %ebx
80105243:	5f                   	pop    %edi
80105244:	5d                   	pop    %ebp
80105245:	c3                   	ret    

80105246 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105246:	55                   	push   %ebp
80105247:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105249:	8b 45 08             	mov    0x8(%ebp),%eax
8010524c:	83 e0 03             	and    $0x3,%eax
8010524f:	85 c0                	test   %eax,%eax
80105251:	75 43                	jne    80105296 <memset+0x50>
80105253:	8b 45 10             	mov    0x10(%ebp),%eax
80105256:	83 e0 03             	and    $0x3,%eax
80105259:	85 c0                	test   %eax,%eax
8010525b:	75 39                	jne    80105296 <memset+0x50>
    c &= 0xFF;
8010525d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105264:	8b 45 10             	mov    0x10(%ebp),%eax
80105267:	c1 e8 02             	shr    $0x2,%eax
8010526a:	89 c1                	mov    %eax,%ecx
8010526c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010526f:	c1 e0 18             	shl    $0x18,%eax
80105272:	89 c2                	mov    %eax,%edx
80105274:	8b 45 0c             	mov    0xc(%ebp),%eax
80105277:	c1 e0 10             	shl    $0x10,%eax
8010527a:	09 c2                	or     %eax,%edx
8010527c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527f:	c1 e0 08             	shl    $0x8,%eax
80105282:	09 d0                	or     %edx,%eax
80105284:	0b 45 0c             	or     0xc(%ebp),%eax
80105287:	51                   	push   %ecx
80105288:	50                   	push   %eax
80105289:	ff 75 08             	pushl  0x8(%ebp)
8010528c:	e8 8f ff ff ff       	call   80105220 <stosl>
80105291:	83 c4 0c             	add    $0xc,%esp
80105294:	eb 12                	jmp    801052a8 <memset+0x62>
  } else
    stosb(dst, c, n);
80105296:	8b 45 10             	mov    0x10(%ebp),%eax
80105299:	50                   	push   %eax
8010529a:	ff 75 0c             	pushl  0xc(%ebp)
8010529d:	ff 75 08             	pushl  0x8(%ebp)
801052a0:	e8 55 ff ff ff       	call   801051fa <stosb>
801052a5:	83 c4 0c             	add    $0xc,%esp
  return dst;
801052a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052ab:	c9                   	leave  
801052ac:	c3                   	ret    

801052ad <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052ad:	55                   	push   %ebp
801052ae:	89 e5                	mov    %esp,%ebp
801052b0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801052b3:	8b 45 08             	mov    0x8(%ebp),%eax
801052b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052bf:	eb 30                	jmp    801052f1 <memcmp+0x44>
    if(*s1 != *s2)
801052c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052c4:	0f b6 10             	movzbl (%eax),%edx
801052c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ca:	0f b6 00             	movzbl (%eax),%eax
801052cd:	38 c2                	cmp    %al,%dl
801052cf:	74 18                	je     801052e9 <memcmp+0x3c>
      return *s1 - *s2;
801052d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d4:	0f b6 00             	movzbl (%eax),%eax
801052d7:	0f b6 d0             	movzbl %al,%edx
801052da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052dd:	0f b6 00             	movzbl (%eax),%eax
801052e0:	0f b6 c0             	movzbl %al,%eax
801052e3:	29 c2                	sub    %eax,%edx
801052e5:	89 d0                	mov    %edx,%eax
801052e7:	eb 1a                	jmp    80105303 <memcmp+0x56>
    s1++, s2++;
801052e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052ed:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801052f1:	8b 45 10             	mov    0x10(%ebp),%eax
801052f4:	8d 50 ff             	lea    -0x1(%eax),%edx
801052f7:	89 55 10             	mov    %edx,0x10(%ebp)
801052fa:	85 c0                	test   %eax,%eax
801052fc:	75 c3                	jne    801052c1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801052fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105303:	c9                   	leave  
80105304:	c3                   	ret    

80105305 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
80105308:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010530b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105311:	8b 45 08             	mov    0x8(%ebp),%eax
80105314:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105317:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010531a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010531d:	73 54                	jae    80105373 <memmove+0x6e>
8010531f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105322:	8b 45 10             	mov    0x10(%ebp),%eax
80105325:	01 d0                	add    %edx,%eax
80105327:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010532a:	76 47                	jbe    80105373 <memmove+0x6e>
    s += n;
8010532c:	8b 45 10             	mov    0x10(%ebp),%eax
8010532f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105332:	8b 45 10             	mov    0x10(%ebp),%eax
80105335:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105338:	eb 13                	jmp    8010534d <memmove+0x48>
      *--d = *--s;
8010533a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010533e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105342:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105345:	0f b6 10             	movzbl (%eax),%edx
80105348:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010534b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010534d:	8b 45 10             	mov    0x10(%ebp),%eax
80105350:	8d 50 ff             	lea    -0x1(%eax),%edx
80105353:	89 55 10             	mov    %edx,0x10(%ebp)
80105356:	85 c0                	test   %eax,%eax
80105358:	75 e0                	jne    8010533a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010535a:	eb 24                	jmp    80105380 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010535c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010535f:	8d 50 01             	lea    0x1(%eax),%edx
80105362:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105365:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105368:	8d 4a 01             	lea    0x1(%edx),%ecx
8010536b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010536e:	0f b6 12             	movzbl (%edx),%edx
80105371:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105373:	8b 45 10             	mov    0x10(%ebp),%eax
80105376:	8d 50 ff             	lea    -0x1(%eax),%edx
80105379:	89 55 10             	mov    %edx,0x10(%ebp)
8010537c:	85 c0                	test   %eax,%eax
8010537e:	75 dc                	jne    8010535c <memmove+0x57>
      *d++ = *s++;

  return dst;
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105383:	c9                   	leave  
80105384:	c3                   	ret    

80105385 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105385:	55                   	push   %ebp
80105386:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105388:	ff 75 10             	pushl  0x10(%ebp)
8010538b:	ff 75 0c             	pushl  0xc(%ebp)
8010538e:	ff 75 08             	pushl  0x8(%ebp)
80105391:	e8 6f ff ff ff       	call   80105305 <memmove>
80105396:	83 c4 0c             	add    $0xc,%esp
}
80105399:	c9                   	leave  
8010539a:	c3                   	ret    

8010539b <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010539b:	55                   	push   %ebp
8010539c:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010539e:	eb 0c                	jmp    801053ac <strncmp+0x11>
    n--, p++, q++;
801053a0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053b0:	74 1a                	je     801053cc <strncmp+0x31>
801053b2:	8b 45 08             	mov    0x8(%ebp),%eax
801053b5:	0f b6 00             	movzbl (%eax),%eax
801053b8:	84 c0                	test   %al,%al
801053ba:	74 10                	je     801053cc <strncmp+0x31>
801053bc:	8b 45 08             	mov    0x8(%ebp),%eax
801053bf:	0f b6 10             	movzbl (%eax),%edx
801053c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c5:	0f b6 00             	movzbl (%eax),%eax
801053c8:	38 c2                	cmp    %al,%dl
801053ca:	74 d4                	je     801053a0 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801053cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053d0:	75 07                	jne    801053d9 <strncmp+0x3e>
    return 0;
801053d2:	b8 00 00 00 00       	mov    $0x0,%eax
801053d7:	eb 16                	jmp    801053ef <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801053d9:	8b 45 08             	mov    0x8(%ebp),%eax
801053dc:	0f b6 00             	movzbl (%eax),%eax
801053df:	0f b6 d0             	movzbl %al,%edx
801053e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e5:	0f b6 00             	movzbl (%eax),%eax
801053e8:	0f b6 c0             	movzbl %al,%eax
801053eb:	29 c2                	sub    %eax,%edx
801053ed:	89 d0                	mov    %edx,%eax
}
801053ef:	5d                   	pop    %ebp
801053f0:	c3                   	ret    

801053f1 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801053f1:	55                   	push   %ebp
801053f2:	89 e5                	mov    %esp,%ebp
801053f4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801053f7:	8b 45 08             	mov    0x8(%ebp),%eax
801053fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801053fd:	90                   	nop
801053fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105401:	8d 50 ff             	lea    -0x1(%eax),%edx
80105404:	89 55 10             	mov    %edx,0x10(%ebp)
80105407:	85 c0                	test   %eax,%eax
80105409:	7e 2c                	jle    80105437 <strncpy+0x46>
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	8d 50 01             	lea    0x1(%eax),%edx
80105411:	89 55 08             	mov    %edx,0x8(%ebp)
80105414:	8b 55 0c             	mov    0xc(%ebp),%edx
80105417:	8d 4a 01             	lea    0x1(%edx),%ecx
8010541a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010541d:	0f b6 12             	movzbl (%edx),%edx
80105420:	88 10                	mov    %dl,(%eax)
80105422:	0f b6 00             	movzbl (%eax),%eax
80105425:	84 c0                	test   %al,%al
80105427:	75 d5                	jne    801053fe <strncpy+0xd>
    ;
  while(n-- > 0)
80105429:	eb 0c                	jmp    80105437 <strncpy+0x46>
    *s++ = 0;
8010542b:	8b 45 08             	mov    0x8(%ebp),%eax
8010542e:	8d 50 01             	lea    0x1(%eax),%edx
80105431:	89 55 08             	mov    %edx,0x8(%ebp)
80105434:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105437:	8b 45 10             	mov    0x10(%ebp),%eax
8010543a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010543d:	89 55 10             	mov    %edx,0x10(%ebp)
80105440:	85 c0                	test   %eax,%eax
80105442:	7f e7                	jg     8010542b <strncpy+0x3a>
    *s++ = 0;
  return os;
80105444:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105447:	c9                   	leave  
80105448:	c3                   	ret    

80105449 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105449:	55                   	push   %ebp
8010544a:	89 e5                	mov    %esp,%ebp
8010544c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010544f:	8b 45 08             	mov    0x8(%ebp),%eax
80105452:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105455:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105459:	7f 05                	jg     80105460 <safestrcpy+0x17>
    return os;
8010545b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010545e:	eb 31                	jmp    80105491 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105460:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105464:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105468:	7e 1e                	jle    80105488 <safestrcpy+0x3f>
8010546a:	8b 45 08             	mov    0x8(%ebp),%eax
8010546d:	8d 50 01             	lea    0x1(%eax),%edx
80105470:	89 55 08             	mov    %edx,0x8(%ebp)
80105473:	8b 55 0c             	mov    0xc(%ebp),%edx
80105476:	8d 4a 01             	lea    0x1(%edx),%ecx
80105479:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010547c:	0f b6 12             	movzbl (%edx),%edx
8010547f:	88 10                	mov    %dl,(%eax)
80105481:	0f b6 00             	movzbl (%eax),%eax
80105484:	84 c0                	test   %al,%al
80105486:	75 d8                	jne    80105460 <safestrcpy+0x17>
    ;
  *s = 0;
80105488:	8b 45 08             	mov    0x8(%ebp),%eax
8010548b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010548e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105491:	c9                   	leave  
80105492:	c3                   	ret    

80105493 <strlen>:

int
strlen(const char *s)
{
80105493:	55                   	push   %ebp
80105494:	89 e5                	mov    %esp,%ebp
80105496:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105499:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054a0:	eb 04                	jmp    801054a6 <strlen+0x13>
801054a2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054a9:	8b 45 08             	mov    0x8(%ebp),%eax
801054ac:	01 d0                	add    %edx,%eax
801054ae:	0f b6 00             	movzbl (%eax),%eax
801054b1:	84 c0                	test   %al,%al
801054b3:	75 ed                	jne    801054a2 <strlen+0xf>
    ;
  return n;
801054b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054b8:	c9                   	leave  
801054b9:	c3                   	ret    

801054ba <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801054ba:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801054be:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801054c2:	55                   	push   %ebp
  pushl %ebx
801054c3:	53                   	push   %ebx
  pushl %esi
801054c4:	56                   	push   %esi
  pushl %edi
801054c5:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801054c6:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801054c8:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801054ca:	5f                   	pop    %edi
  popl %esi
801054cb:	5e                   	pop    %esi
  popl %ebx
801054cc:	5b                   	pop    %ebx
  popl %ebp
801054cd:	5d                   	pop    %ebp
  ret
801054ce:	c3                   	ret    

801054cf <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801054cf:	55                   	push   %ebp
801054d0:	89 e5                	mov    %esp,%ebp
//  struct proc *curproc = myproc();

//  cprintf("FETCHINT: %x\n", curproc->sz);
 

  if(addr >= USER_TOP|| addr+4 > USER_TOP)
801054d2:	81 7d 08 fb ff ff 7f 	cmpl   $0x7ffffffb,0x8(%ebp)
801054d9:	77 0d                	ja     801054e8 <fetchint+0x19>
801054db:	8b 45 08             	mov    0x8(%ebp),%eax
801054de:	83 c0 04             	add    $0x4,%eax
801054e1:	3d fc ff ff 7f       	cmp    $0x7ffffffc,%eax
801054e6:	76 07                	jbe    801054ef <fetchint+0x20>
    return -1;
801054e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ed:	eb 0f                	jmp    801054fe <fetchint+0x2f>
  *ip = *(int*)(addr);
801054ef:	8b 45 08             	mov    0x8(%ebp),%eax
801054f2:	8b 10                	mov    (%eax),%edx
801054f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f7:	89 10                	mov    %edx,(%eax)
  return 0;
801054f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054fe:	5d                   	pop    %ebp
801054ff:	c3                   	ret    

80105500 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105500:	55                   	push   %ebp
80105501:	89 e5                	mov    %esp,%ebp
80105503:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

//  cprintf("FETCHSTR: %x\n", USER_TOP);

  if(addr >= USER_TOP)
80105506:	81 7d 08 fb ff ff 7f 	cmpl   $0x7ffffffb,0x8(%ebp)
8010550d:	76 07                	jbe    80105516 <fetchstr+0x16>
    return -1;
8010550f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105514:	eb 42                	jmp    80105558 <fetchstr+0x58>
  *pp = (char*)addr;
80105516:	8b 55 08             	mov    0x8(%ebp),%edx
80105519:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551c:	89 10                	mov    %edx,(%eax)
  ep = (char*)USER_TOP;
8010551e:	c7 45 f8 fc ff ff 7f 	movl   $0x7ffffffc,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80105525:	8b 45 0c             	mov    0xc(%ebp),%eax
80105528:	8b 00                	mov    (%eax),%eax
8010552a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010552d:	eb 1c                	jmp    8010554b <fetchstr+0x4b>
    if(*s == 0)
8010552f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105532:	0f b6 00             	movzbl (%eax),%eax
80105535:	84 c0                	test   %al,%al
80105537:	75 0e                	jne    80105547 <fetchstr+0x47>
      return s - *pp;
80105539:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010553c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553f:	8b 00                	mov    (%eax),%eax
80105541:	29 c2                	sub    %eax,%edx
80105543:	89 d0                	mov    %edx,%eax
80105545:	eb 11                	jmp    80105558 <fetchstr+0x58>

  if(addr >= USER_TOP)
    return -1;
  *pp = (char*)addr;
  ep = (char*)USER_TOP;
  for(s = *pp; s < ep; s++){
80105547:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010554b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010554e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105551:	72 dc                	jb     8010552f <fetchstr+0x2f>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105553:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105558:	c9                   	leave  
80105559:	c3                   	ret    

8010555a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010555a:	55                   	push   %ebp
8010555b:	89 e5                	mov    %esp,%ebp
8010555d:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105560:	e8 5b ed ff ff       	call   801042c0 <myproc>
80105565:	8b 40 18             	mov    0x18(%eax),%eax
80105568:	8b 40 44             	mov    0x44(%eax),%eax
8010556b:	8b 55 08             	mov    0x8(%ebp),%edx
8010556e:	c1 e2 02             	shl    $0x2,%edx
80105571:	01 d0                	add    %edx,%eax
80105573:	83 c0 04             	add    $0x4,%eax
80105576:	83 ec 08             	sub    $0x8,%esp
80105579:	ff 75 0c             	pushl  0xc(%ebp)
8010557c:	50                   	push   %eax
8010557d:	e8 4d ff ff ff       	call   801054cf <fetchint>
80105582:	83 c4 10             	add    $0x10,%esp
}
80105585:	c9                   	leave  
80105586:	c3                   	ret    

80105587 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105587:	55                   	push   %ebp
80105588:	89 e5                	mov    %esp,%ebp
8010558a:	83 ec 18             	sub    $0x18,%esp
  int i;
//  struct proc *curproc = myproc();

//  cprintf("ARGPTR: %x\n", curproc->sz);
 
  if(argint(n, &i) < 0)
8010558d:	83 ec 08             	sub    $0x8,%esp
80105590:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105593:	50                   	push   %eax
80105594:	ff 75 08             	pushl  0x8(%ebp)
80105597:	e8 be ff ff ff       	call   8010555a <argint>
8010559c:	83 c4 10             	add    $0x10,%esp
8010559f:	85 c0                	test   %eax,%eax
801055a1:	79 07                	jns    801055aa <argptr+0x23>
    return -1;
801055a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a8:	eb 37                	jmp    801055e1 <argptr+0x5a>
  if(size < 0 || (uint)i >= USER_TOP|| (uint)i+size > USER_TOP)
801055aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ae:	78 1b                	js     801055cb <argptr+0x44>
801055b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b3:	3d fb ff ff 7f       	cmp    $0x7ffffffb,%eax
801055b8:	77 11                	ja     801055cb <argptr+0x44>
801055ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bd:	89 c2                	mov    %eax,%edx
801055bf:	8b 45 10             	mov    0x10(%ebp),%eax
801055c2:	01 d0                	add    %edx,%eax
801055c4:	3d fc ff ff 7f       	cmp    $0x7ffffffc,%eax
801055c9:	76 07                	jbe    801055d2 <argptr+0x4b>
    return -1;
801055cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d0:	eb 0f                	jmp    801055e1 <argptr+0x5a>
  *pp = (char*)i;
801055d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d5:	89 c2                	mov    %eax,%edx
801055d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055da:	89 10                	mov    %edx,(%eax)
  return 0;
801055dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055e1:	c9                   	leave  
801055e2:	c3                   	ret    

801055e3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801055e3:	55                   	push   %ebp
801055e4:	89 e5                	mov    %esp,%ebp
801055e6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801055e9:	83 ec 08             	sub    $0x8,%esp
801055ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055ef:	50                   	push   %eax
801055f0:	ff 75 08             	pushl  0x8(%ebp)
801055f3:	e8 62 ff ff ff       	call   8010555a <argint>
801055f8:	83 c4 10             	add    $0x10,%esp
801055fb:	85 c0                	test   %eax,%eax
801055fd:	79 07                	jns    80105606 <argstr+0x23>
    return -1;
801055ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105604:	eb 12                	jmp    80105618 <argstr+0x35>
  return fetchstr(addr, pp);
80105606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105609:	83 ec 08             	sub    $0x8,%esp
8010560c:	ff 75 0c             	pushl  0xc(%ebp)
8010560f:	50                   	push   %eax
80105610:	e8 eb fe ff ff       	call   80105500 <fetchstr>
80105615:	83 c4 10             	add    $0x10,%esp
}
80105618:	c9                   	leave  
80105619:	c3                   	ret    

8010561a <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
8010561a:	55                   	push   %ebp
8010561b:	89 e5                	mov    %esp,%ebp
8010561d:	53                   	push   %ebx
8010561e:	83 ec 14             	sub    $0x14,%esp
  int num;
  struct proc *curproc = myproc();
80105621:	e8 9a ec ff ff       	call   801042c0 <myproc>
80105626:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562c:	8b 40 18             	mov    0x18(%eax),%eax
8010562f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105632:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105635:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105639:	7e 2d                	jle    80105668 <syscall+0x4e>
8010563b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563e:	83 f8 17             	cmp    $0x17,%eax
80105641:	77 25                	ja     80105668 <syscall+0x4e>
80105643:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105646:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
8010564d:	85 c0                	test   %eax,%eax
8010564f:	74 17                	je     80105668 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105654:	8b 58 18             	mov    0x18(%eax),%ebx
80105657:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565a:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105661:	ff d0                	call   *%eax
80105663:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105666:	eb 2b                	jmp    80105693 <syscall+0x79>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566b:	8d 50 6c             	lea    0x6c(%eax),%edx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010566e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105671:	8b 40 10             	mov    0x10(%eax),%eax
80105674:	ff 75 f0             	pushl  -0x10(%ebp)
80105677:	52                   	push   %edx
80105678:	50                   	push   %eax
80105679:	68 f8 8e 10 80       	push   $0x80108ef8
8010567e:	e8 7d ad ff ff       	call   80100400 <cprintf>
80105683:	83 c4 10             	add    $0x10,%esp
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105689:	8b 40 18             	mov    0x18(%eax),%eax
8010568c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105693:	90                   	nop
80105694:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105697:	c9                   	leave  
80105698:	c3                   	ret    

80105699 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105699:	55                   	push   %ebp
8010569a:	89 e5                	mov    %esp,%ebp
8010569c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010569f:	83 ec 08             	sub    $0x8,%esp
801056a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056a5:	50                   	push   %eax
801056a6:	ff 75 08             	pushl  0x8(%ebp)
801056a9:	e8 ac fe ff ff       	call   8010555a <argint>
801056ae:	83 c4 10             	add    $0x10,%esp
801056b1:	85 c0                	test   %eax,%eax
801056b3:	79 07                	jns    801056bc <argfd+0x23>
    return -1;
801056b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ba:	eb 51                	jmp    8010570d <argfd+0x74>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801056bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056bf:	85 c0                	test   %eax,%eax
801056c1:	78 22                	js     801056e5 <argfd+0x4c>
801056c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c6:	83 f8 0f             	cmp    $0xf,%eax
801056c9:	7f 1a                	jg     801056e5 <argfd+0x4c>
801056cb:	e8 f0 eb ff ff       	call   801042c0 <myproc>
801056d0:	89 c2                	mov    %eax,%edx
801056d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d5:	83 c0 08             	add    $0x8,%eax
801056d8:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
801056dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056e3:	75 07                	jne    801056ec <argfd+0x53>
    return -1;
801056e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ea:	eb 21                	jmp    8010570d <argfd+0x74>
  if(pfd)
801056ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801056f0:	74 08                	je     801056fa <argfd+0x61>
    *pfd = fd;
801056f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f8:	89 10                	mov    %edx,(%eax)
  if(pf)
801056fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056fe:	74 08                	je     80105708 <argfd+0x6f>
    *pf = f;
80105700:	8b 45 10             	mov    0x10(%ebp),%eax
80105703:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105706:	89 10                	mov    %edx,(%eax)
  return 0;
80105708:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010570d:	c9                   	leave  
8010570e:	c3                   	ret    

8010570f <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010570f:	55                   	push   %ebp
80105710:	89 e5                	mov    %esp,%ebp
80105712:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105715:	e8 a6 eb ff ff       	call   801042c0 <myproc>
8010571a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010571d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105724:	eb 2a                	jmp    80105750 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105729:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010572c:	83 c2 08             	add    $0x8,%edx
8010572f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105733:	85 c0                	test   %eax,%eax
80105735:	75 15                	jne    8010574c <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010573d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105740:	8b 55 08             	mov    0x8(%ebp),%edx
80105743:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574a:	eb 0f                	jmp    8010575b <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
8010574c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105750:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105754:	7e d0                	jle    80105726 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010575b:	c9                   	leave  
8010575c:	c3                   	ret    

8010575d <sys_dup>:

int
sys_dup(void)
{
8010575d:	55                   	push   %ebp
8010575e:	89 e5                	mov    %esp,%ebp
80105760:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105763:	83 ec 04             	sub    $0x4,%esp
80105766:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105769:	50                   	push   %eax
8010576a:	6a 00                	push   $0x0
8010576c:	6a 00                	push   $0x0
8010576e:	e8 26 ff ff ff       	call   80105699 <argfd>
80105773:	83 c4 10             	add    $0x10,%esp
80105776:	85 c0                	test   %eax,%eax
80105778:	79 07                	jns    80105781 <sys_dup+0x24>
    return -1;
8010577a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577f:	eb 31                	jmp    801057b2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105784:	83 ec 0c             	sub    $0xc,%esp
80105787:	50                   	push   %eax
80105788:	e8 82 ff ff ff       	call   8010570f <fdalloc>
8010578d:	83 c4 10             	add    $0x10,%esp
80105790:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105793:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105797:	79 07                	jns    801057a0 <sys_dup+0x43>
    return -1;
80105799:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579e:	eb 12                	jmp    801057b2 <sys_dup+0x55>
  filedup(f);
801057a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a3:	83 ec 0c             	sub    $0xc,%esp
801057a6:	50                   	push   %eax
801057a7:	e8 e7 b8 ff ff       	call   80101093 <filedup>
801057ac:	83 c4 10             	add    $0x10,%esp
  return fd;
801057af:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057b2:	c9                   	leave  
801057b3:	c3                   	ret    

801057b4 <sys_read>:

int
sys_read(void)
{
801057b4:	55                   	push   %ebp
801057b5:	89 e5                	mov    %esp,%ebp
801057b7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057ba:	83 ec 04             	sub    $0x4,%esp
801057bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057c0:	50                   	push   %eax
801057c1:	6a 00                	push   $0x0
801057c3:	6a 00                	push   $0x0
801057c5:	e8 cf fe ff ff       	call   80105699 <argfd>
801057ca:	83 c4 10             	add    $0x10,%esp
801057cd:	85 c0                	test   %eax,%eax
801057cf:	78 2e                	js     801057ff <sys_read+0x4b>
801057d1:	83 ec 08             	sub    $0x8,%esp
801057d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d7:	50                   	push   %eax
801057d8:	6a 02                	push   $0x2
801057da:	e8 7b fd ff ff       	call   8010555a <argint>
801057df:	83 c4 10             	add    $0x10,%esp
801057e2:	85 c0                	test   %eax,%eax
801057e4:	78 19                	js     801057ff <sys_read+0x4b>
801057e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e9:	83 ec 04             	sub    $0x4,%esp
801057ec:	50                   	push   %eax
801057ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057f0:	50                   	push   %eax
801057f1:	6a 01                	push   $0x1
801057f3:	e8 8f fd ff ff       	call   80105587 <argptr>
801057f8:	83 c4 10             	add    $0x10,%esp
801057fb:	85 c0                	test   %eax,%eax
801057fd:	79 07                	jns    80105806 <sys_read+0x52>
    return -1;
801057ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105804:	eb 17                	jmp    8010581d <sys_read+0x69>
  return fileread(f, p, n);
80105806:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105809:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010580c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580f:	83 ec 04             	sub    $0x4,%esp
80105812:	51                   	push   %ecx
80105813:	52                   	push   %edx
80105814:	50                   	push   %eax
80105815:	e8 09 ba ff ff       	call   80101223 <fileread>
8010581a:	83 c4 10             	add    $0x10,%esp
}
8010581d:	c9                   	leave  
8010581e:	c3                   	ret    

8010581f <sys_write>:

int
sys_write(void)
{
8010581f:	55                   	push   %ebp
80105820:	89 e5                	mov    %esp,%ebp
80105822:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105825:	83 ec 04             	sub    $0x4,%esp
80105828:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010582b:	50                   	push   %eax
8010582c:	6a 00                	push   $0x0
8010582e:	6a 00                	push   $0x0
80105830:	e8 64 fe ff ff       	call   80105699 <argfd>
80105835:	83 c4 10             	add    $0x10,%esp
80105838:	85 c0                	test   %eax,%eax
8010583a:	78 2e                	js     8010586a <sys_write+0x4b>
8010583c:	83 ec 08             	sub    $0x8,%esp
8010583f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105842:	50                   	push   %eax
80105843:	6a 02                	push   $0x2
80105845:	e8 10 fd ff ff       	call   8010555a <argint>
8010584a:	83 c4 10             	add    $0x10,%esp
8010584d:	85 c0                	test   %eax,%eax
8010584f:	78 19                	js     8010586a <sys_write+0x4b>
80105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105854:	83 ec 04             	sub    $0x4,%esp
80105857:	50                   	push   %eax
80105858:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010585b:	50                   	push   %eax
8010585c:	6a 01                	push   $0x1
8010585e:	e8 24 fd ff ff       	call   80105587 <argptr>
80105863:	83 c4 10             	add    $0x10,%esp
80105866:	85 c0                	test   %eax,%eax
80105868:	79 07                	jns    80105871 <sys_write+0x52>
    return -1;
8010586a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010586f:	eb 17                	jmp    80105888 <sys_write+0x69>
  return filewrite(f, p, n);
80105871:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105874:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587a:	83 ec 04             	sub    $0x4,%esp
8010587d:	51                   	push   %ecx
8010587e:	52                   	push   %edx
8010587f:	50                   	push   %eax
80105880:	e8 56 ba ff ff       	call   801012db <filewrite>
80105885:	83 c4 10             	add    $0x10,%esp
}
80105888:	c9                   	leave  
80105889:	c3                   	ret    

8010588a <sys_close>:

int
sys_close(void)
{
8010588a:	55                   	push   %ebp
8010588b:	89 e5                	mov    %esp,%ebp
8010588d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105890:	83 ec 04             	sub    $0x4,%esp
80105893:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105896:	50                   	push   %eax
80105897:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010589a:	50                   	push   %eax
8010589b:	6a 00                	push   $0x0
8010589d:	e8 f7 fd ff ff       	call   80105699 <argfd>
801058a2:	83 c4 10             	add    $0x10,%esp
801058a5:	85 c0                	test   %eax,%eax
801058a7:	79 07                	jns    801058b0 <sys_close+0x26>
    return -1;
801058a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ae:	eb 29                	jmp    801058d9 <sys_close+0x4f>
  myproc()->ofile[fd] = 0;
801058b0:	e8 0b ea ff ff       	call   801042c0 <myproc>
801058b5:	89 c2                	mov    %eax,%edx
801058b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ba:	83 c0 08             	add    $0x8,%eax
801058bd:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
801058c4:	00 
  fileclose(f);
801058c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c8:	83 ec 0c             	sub    $0xc,%esp
801058cb:	50                   	push   %eax
801058cc:	e8 13 b8 ff ff       	call   801010e4 <fileclose>
801058d1:	83 c4 10             	add    $0x10,%esp
  return 0;
801058d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d9:	c9                   	leave  
801058da:	c3                   	ret    

801058db <sys_fstat>:

int
sys_fstat(void)
{
801058db:	55                   	push   %ebp
801058dc:	89 e5                	mov    %esp,%ebp
801058de:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801058e1:	83 ec 04             	sub    $0x4,%esp
801058e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058e7:	50                   	push   %eax
801058e8:	6a 00                	push   $0x0
801058ea:	6a 00                	push   $0x0
801058ec:	e8 a8 fd ff ff       	call   80105699 <argfd>
801058f1:	83 c4 10             	add    $0x10,%esp
801058f4:	85 c0                	test   %eax,%eax
801058f6:	78 17                	js     8010590f <sys_fstat+0x34>
801058f8:	83 ec 04             	sub    $0x4,%esp
801058fb:	6a 14                	push   $0x14
801058fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105900:	50                   	push   %eax
80105901:	6a 01                	push   $0x1
80105903:	e8 7f fc ff ff       	call   80105587 <argptr>
80105908:	83 c4 10             	add    $0x10,%esp
8010590b:	85 c0                	test   %eax,%eax
8010590d:	79 07                	jns    80105916 <sys_fstat+0x3b>
    return -1;
8010590f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105914:	eb 13                	jmp    80105929 <sys_fstat+0x4e>
  return filestat(f, st);
80105916:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591c:	83 ec 08             	sub    $0x8,%esp
8010591f:	52                   	push   %edx
80105920:	50                   	push   %eax
80105921:	e8 a6 b8 ff ff       	call   801011cc <filestat>
80105926:	83 c4 10             	add    $0x10,%esp
}
80105929:	c9                   	leave  
8010592a:	c3                   	ret    

8010592b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010592b:	55                   	push   %ebp
8010592c:	89 e5                	mov    %esp,%ebp
8010592e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105931:	83 ec 08             	sub    $0x8,%esp
80105934:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105937:	50                   	push   %eax
80105938:	6a 00                	push   $0x0
8010593a:	e8 a4 fc ff ff       	call   801055e3 <argstr>
8010593f:	83 c4 10             	add    $0x10,%esp
80105942:	85 c0                	test   %eax,%eax
80105944:	78 15                	js     8010595b <sys_link+0x30>
80105946:	83 ec 08             	sub    $0x8,%esp
80105949:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010594c:	50                   	push   %eax
8010594d:	6a 01                	push   $0x1
8010594f:	e8 8f fc ff ff       	call   801055e3 <argstr>
80105954:	83 c4 10             	add    $0x10,%esp
80105957:	85 c0                	test   %eax,%eax
80105959:	79 0a                	jns    80105965 <sys_link+0x3a>
    return -1;
8010595b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105960:	e9 68 01 00 00       	jmp    80105acd <sys_link+0x1a2>

  begin_op();
80105965:	e8 fe db ff ff       	call   80103568 <begin_op>
  if((ip = namei(old)) == 0){
8010596a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010596d:	83 ec 0c             	sub    $0xc,%esp
80105970:	50                   	push   %eax
80105971:	e8 0d cc ff ff       	call   80102583 <namei>
80105976:	83 c4 10             	add    $0x10,%esp
80105979:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010597c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105980:	75 0f                	jne    80105991 <sys_link+0x66>
    end_op();
80105982:	e8 6d dc ff ff       	call   801035f4 <end_op>
    return -1;
80105987:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598c:	e9 3c 01 00 00       	jmp    80105acd <sys_link+0x1a2>
  }

  ilock(ip);
80105991:	83 ec 0c             	sub    $0xc,%esp
80105994:	ff 75 f4             	pushl  -0xc(%ebp)
80105997:	e8 a7 c0 ff ff       	call   80101a43 <ilock>
8010599c:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010599f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059a6:	66 83 f8 01          	cmp    $0x1,%ax
801059aa:	75 1d                	jne    801059c9 <sys_link+0x9e>
    iunlockput(ip);
801059ac:	83 ec 0c             	sub    $0xc,%esp
801059af:	ff 75 f4             	pushl  -0xc(%ebp)
801059b2:	e8 bd c2 ff ff       	call   80101c74 <iunlockput>
801059b7:	83 c4 10             	add    $0x10,%esp
    end_op();
801059ba:	e8 35 dc ff ff       	call   801035f4 <end_op>
    return -1;
801059bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c4:	e9 04 01 00 00       	jmp    80105acd <sys_link+0x1a2>
  }

  ip->nlink++;
801059c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059d0:	83 c0 01             	add    $0x1,%eax
801059d3:	89 c2                	mov    %eax,%edx
801059d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801059dc:	83 ec 0c             	sub    $0xc,%esp
801059df:	ff 75 f4             	pushl  -0xc(%ebp)
801059e2:	e8 7f be ff ff       	call   80101866 <iupdate>
801059e7:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801059ea:	83 ec 0c             	sub    $0xc,%esp
801059ed:	ff 75 f4             	pushl  -0xc(%ebp)
801059f0:	e8 61 c1 ff ff       	call   80101b56 <iunlock>
801059f5:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801059f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801059fb:	83 ec 08             	sub    $0x8,%esp
801059fe:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a01:	52                   	push   %edx
80105a02:	50                   	push   %eax
80105a03:	e8 97 cb ff ff       	call   8010259f <nameiparent>
80105a08:	83 c4 10             	add    $0x10,%esp
80105a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a12:	74 71                	je     80105a85 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a14:	83 ec 0c             	sub    $0xc,%esp
80105a17:	ff 75 f0             	pushl  -0x10(%ebp)
80105a1a:	e8 24 c0 ff ff       	call   80101a43 <ilock>
80105a1f:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a25:	8b 10                	mov    (%eax),%edx
80105a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2a:	8b 00                	mov    (%eax),%eax
80105a2c:	39 c2                	cmp    %eax,%edx
80105a2e:	75 1d                	jne    80105a4d <sys_link+0x122>
80105a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a33:	8b 40 04             	mov    0x4(%eax),%eax
80105a36:	83 ec 04             	sub    $0x4,%esp
80105a39:	50                   	push   %eax
80105a3a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a3d:	50                   	push   %eax
80105a3e:	ff 75 f0             	pushl  -0x10(%ebp)
80105a41:	e8 a2 c8 ff ff       	call   801022e8 <dirlink>
80105a46:	83 c4 10             	add    $0x10,%esp
80105a49:	85 c0                	test   %eax,%eax
80105a4b:	79 10                	jns    80105a5d <sys_link+0x132>
    iunlockput(dp);
80105a4d:	83 ec 0c             	sub    $0xc,%esp
80105a50:	ff 75 f0             	pushl  -0x10(%ebp)
80105a53:	e8 1c c2 ff ff       	call   80101c74 <iunlockput>
80105a58:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a5b:	eb 29                	jmp    80105a86 <sys_link+0x15b>
  }
  iunlockput(dp);
80105a5d:	83 ec 0c             	sub    $0xc,%esp
80105a60:	ff 75 f0             	pushl  -0x10(%ebp)
80105a63:	e8 0c c2 ff ff       	call   80101c74 <iunlockput>
80105a68:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105a6b:	83 ec 0c             	sub    $0xc,%esp
80105a6e:	ff 75 f4             	pushl  -0xc(%ebp)
80105a71:	e8 2e c1 ff ff       	call   80101ba4 <iput>
80105a76:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a79:	e8 76 db ff ff       	call   801035f4 <end_op>

  return 0;
80105a7e:	b8 00 00 00 00       	mov    $0x0,%eax
80105a83:	eb 48                	jmp    80105acd <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105a85:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105a86:	83 ec 0c             	sub    $0xc,%esp
80105a89:	ff 75 f4             	pushl  -0xc(%ebp)
80105a8c:	e8 b2 bf ff ff       	call   80101a43 <ilock>
80105a91:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a97:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a9b:	83 e8 01             	sub    $0x1,%eax
80105a9e:	89 c2                	mov    %eax,%edx
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105aa7:	83 ec 0c             	sub    $0xc,%esp
80105aaa:	ff 75 f4             	pushl  -0xc(%ebp)
80105aad:	e8 b4 bd ff ff       	call   80101866 <iupdate>
80105ab2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ab5:	83 ec 0c             	sub    $0xc,%esp
80105ab8:	ff 75 f4             	pushl  -0xc(%ebp)
80105abb:	e8 b4 c1 ff ff       	call   80101c74 <iunlockput>
80105ac0:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ac3:	e8 2c db ff ff       	call   801035f4 <end_op>
  return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105acd:	c9                   	leave  
80105ace:	c3                   	ret    

80105acf <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105acf:	55                   	push   %ebp
80105ad0:	89 e5                	mov    %esp,%ebp
80105ad2:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ad5:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105adc:	eb 40                	jmp    80105b1e <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae1:	6a 10                	push   $0x10
80105ae3:	50                   	push   %eax
80105ae4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ae7:	50                   	push   %eax
80105ae8:	ff 75 08             	pushl  0x8(%ebp)
80105aeb:	e8 44 c4 ff ff       	call   80101f34 <readi>
80105af0:	83 c4 10             	add    $0x10,%esp
80105af3:	83 f8 10             	cmp    $0x10,%eax
80105af6:	74 0d                	je     80105b05 <isdirempty+0x36>
      panic("isdirempty: readi");
80105af8:	83 ec 0c             	sub    $0xc,%esp
80105afb:	68 14 8f 10 80       	push   $0x80108f14
80105b00:	e8 9b aa ff ff       	call   801005a0 <panic>
    if(de.inum != 0)
80105b05:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b09:	66 85 c0             	test   %ax,%ax
80105b0c:	74 07                	je     80105b15 <isdirempty+0x46>
      return 0;
80105b0e:	b8 00 00 00 00       	mov    $0x0,%eax
80105b13:	eb 1b                	jmp    80105b30 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b18:	83 c0 10             	add    $0x10,%eax
80105b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b21:	8b 50 58             	mov    0x58(%eax),%edx
80105b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b27:	39 c2                	cmp    %eax,%edx
80105b29:	77 b3                	ja     80105ade <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105b2b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b30:	c9                   	leave  
80105b31:	c3                   	ret    

80105b32 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b32:	55                   	push   %ebp
80105b33:	89 e5                	mov    %esp,%ebp
80105b35:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105b38:	83 ec 08             	sub    $0x8,%esp
80105b3b:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b3e:	50                   	push   %eax
80105b3f:	6a 00                	push   $0x0
80105b41:	e8 9d fa ff ff       	call   801055e3 <argstr>
80105b46:	83 c4 10             	add    $0x10,%esp
80105b49:	85 c0                	test   %eax,%eax
80105b4b:	79 0a                	jns    80105b57 <sys_unlink+0x25>
    return -1;
80105b4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b52:	e9 bc 01 00 00       	jmp    80105d13 <sys_unlink+0x1e1>

  begin_op();
80105b57:	e8 0c da ff ff       	call   80103568 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105b5c:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105b5f:	83 ec 08             	sub    $0x8,%esp
80105b62:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105b65:	52                   	push   %edx
80105b66:	50                   	push   %eax
80105b67:	e8 33 ca ff ff       	call   8010259f <nameiparent>
80105b6c:	83 c4 10             	add    $0x10,%esp
80105b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b76:	75 0f                	jne    80105b87 <sys_unlink+0x55>
    end_op();
80105b78:	e8 77 da ff ff       	call   801035f4 <end_op>
    return -1;
80105b7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b82:	e9 8c 01 00 00       	jmp    80105d13 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105b87:	83 ec 0c             	sub    $0xc,%esp
80105b8a:	ff 75 f4             	pushl  -0xc(%ebp)
80105b8d:	e8 b1 be ff ff       	call   80101a43 <ilock>
80105b92:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105b95:	83 ec 08             	sub    $0x8,%esp
80105b98:	68 26 8f 10 80       	push   $0x80108f26
80105b9d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ba0:	50                   	push   %eax
80105ba1:	e8 6d c6 ff ff       	call   80102213 <namecmp>
80105ba6:	83 c4 10             	add    $0x10,%esp
80105ba9:	85 c0                	test   %eax,%eax
80105bab:	0f 84 4a 01 00 00    	je     80105cfb <sys_unlink+0x1c9>
80105bb1:	83 ec 08             	sub    $0x8,%esp
80105bb4:	68 28 8f 10 80       	push   $0x80108f28
80105bb9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bbc:	50                   	push   %eax
80105bbd:	e8 51 c6 ff ff       	call   80102213 <namecmp>
80105bc2:	83 c4 10             	add    $0x10,%esp
80105bc5:	85 c0                	test   %eax,%eax
80105bc7:	0f 84 2e 01 00 00    	je     80105cfb <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105bcd:	83 ec 04             	sub    $0x4,%esp
80105bd0:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105bd3:	50                   	push   %eax
80105bd4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bd7:	50                   	push   %eax
80105bd8:	ff 75 f4             	pushl  -0xc(%ebp)
80105bdb:	e8 4e c6 ff ff       	call   8010222e <dirlookup>
80105be0:	83 c4 10             	add    $0x10,%esp
80105be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105be6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bea:	0f 84 0a 01 00 00    	je     80105cfa <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105bf0:	83 ec 0c             	sub    $0xc,%esp
80105bf3:	ff 75 f0             	pushl  -0x10(%ebp)
80105bf6:	e8 48 be ff ff       	call   80101a43 <ilock>
80105bfb:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c01:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c05:	66 85 c0             	test   %ax,%ax
80105c08:	7f 0d                	jg     80105c17 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c0a:	83 ec 0c             	sub    $0xc,%esp
80105c0d:	68 2b 8f 10 80       	push   $0x80108f2b
80105c12:	e8 89 a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c1e:	66 83 f8 01          	cmp    $0x1,%ax
80105c22:	75 25                	jne    80105c49 <sys_unlink+0x117>
80105c24:	83 ec 0c             	sub    $0xc,%esp
80105c27:	ff 75 f0             	pushl  -0x10(%ebp)
80105c2a:	e8 a0 fe ff ff       	call   80105acf <isdirempty>
80105c2f:	83 c4 10             	add    $0x10,%esp
80105c32:	85 c0                	test   %eax,%eax
80105c34:	75 13                	jne    80105c49 <sys_unlink+0x117>
    iunlockput(ip);
80105c36:	83 ec 0c             	sub    $0xc,%esp
80105c39:	ff 75 f0             	pushl  -0x10(%ebp)
80105c3c:	e8 33 c0 ff ff       	call   80101c74 <iunlockput>
80105c41:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c44:	e9 b2 00 00 00       	jmp    80105cfb <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105c49:	83 ec 04             	sub    $0x4,%esp
80105c4c:	6a 10                	push   $0x10
80105c4e:	6a 00                	push   $0x0
80105c50:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c53:	50                   	push   %eax
80105c54:	e8 ed f5 ff ff       	call   80105246 <memset>
80105c59:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c5c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105c5f:	6a 10                	push   $0x10
80105c61:	50                   	push   %eax
80105c62:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c65:	50                   	push   %eax
80105c66:	ff 75 f4             	pushl  -0xc(%ebp)
80105c69:	e8 1d c4 ff ff       	call   8010208b <writei>
80105c6e:	83 c4 10             	add    $0x10,%esp
80105c71:	83 f8 10             	cmp    $0x10,%eax
80105c74:	74 0d                	je     80105c83 <sys_unlink+0x151>
    panic("unlink: writei");
80105c76:	83 ec 0c             	sub    $0xc,%esp
80105c79:	68 3d 8f 10 80       	push   $0x80108f3d
80105c7e:	e8 1d a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR){
80105c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c86:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c8a:	66 83 f8 01          	cmp    $0x1,%ax
80105c8e:	75 21                	jne    80105cb1 <sys_unlink+0x17f>
    dp->nlink--;
80105c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c93:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c97:	83 e8 01             	sub    $0x1,%eax
80105c9a:	89 c2                	mov    %eax,%edx
80105c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9f:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ca3:	83 ec 0c             	sub    $0xc,%esp
80105ca6:	ff 75 f4             	pushl  -0xc(%ebp)
80105ca9:	e8 b8 bb ff ff       	call   80101866 <iupdate>
80105cae:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105cb1:	83 ec 0c             	sub    $0xc,%esp
80105cb4:	ff 75 f4             	pushl  -0xc(%ebp)
80105cb7:	e8 b8 bf ff ff       	call   80101c74 <iunlockput>
80105cbc:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cc6:	83 e8 01             	sub    $0x1,%eax
80105cc9:	89 c2                	mov    %eax,%edx
80105ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cce:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105cd2:	83 ec 0c             	sub    $0xc,%esp
80105cd5:	ff 75 f0             	pushl  -0x10(%ebp)
80105cd8:	e8 89 bb ff ff       	call   80101866 <iupdate>
80105cdd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ce0:	83 ec 0c             	sub    $0xc,%esp
80105ce3:	ff 75 f0             	pushl  -0x10(%ebp)
80105ce6:	e8 89 bf ff ff       	call   80101c74 <iunlockput>
80105ceb:	83 c4 10             	add    $0x10,%esp

  end_op();
80105cee:	e8 01 d9 ff ff       	call   801035f4 <end_op>

  return 0;
80105cf3:	b8 00 00 00 00       	mov    $0x0,%eax
80105cf8:	eb 19                	jmp    80105d13 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105cfa:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105cfb:	83 ec 0c             	sub    $0xc,%esp
80105cfe:	ff 75 f4             	pushl  -0xc(%ebp)
80105d01:	e8 6e bf ff ff       	call   80101c74 <iunlockput>
80105d06:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d09:	e8 e6 d8 ff ff       	call   801035f4 <end_op>
  return -1;
80105d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d13:	c9                   	leave  
80105d14:	c3                   	ret    

80105d15 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d15:	55                   	push   %ebp
80105d16:	89 e5                	mov    %esp,%ebp
80105d18:	83 ec 38             	sub    $0x38,%esp
80105d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d1e:	8b 55 10             	mov    0x10(%ebp),%edx
80105d21:	8b 45 14             	mov    0x14(%ebp),%eax
80105d24:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d28:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d2c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d30:	83 ec 08             	sub    $0x8,%esp
80105d33:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d36:	50                   	push   %eax
80105d37:	ff 75 08             	pushl  0x8(%ebp)
80105d3a:	e8 60 c8 ff ff       	call   8010259f <nameiparent>
80105d3f:	83 c4 10             	add    $0x10,%esp
80105d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d49:	75 0a                	jne    80105d55 <create+0x40>
    return 0;
80105d4b:	b8 00 00 00 00       	mov    $0x0,%eax
80105d50:	e9 90 01 00 00       	jmp    80105ee5 <create+0x1d0>
  ilock(dp);
80105d55:	83 ec 0c             	sub    $0xc,%esp
80105d58:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5b:	e8 e3 bc ff ff       	call   80101a43 <ilock>
80105d60:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105d63:	83 ec 04             	sub    $0x4,%esp
80105d66:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d69:	50                   	push   %eax
80105d6a:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d6d:	50                   	push   %eax
80105d6e:	ff 75 f4             	pushl  -0xc(%ebp)
80105d71:	e8 b8 c4 ff ff       	call   8010222e <dirlookup>
80105d76:	83 c4 10             	add    $0x10,%esp
80105d79:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d7c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d80:	74 50                	je     80105dd2 <create+0xbd>
    iunlockput(dp);
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	ff 75 f4             	pushl  -0xc(%ebp)
80105d88:	e8 e7 be ff ff       	call   80101c74 <iunlockput>
80105d8d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	ff 75 f0             	pushl  -0x10(%ebp)
80105d96:	e8 a8 bc ff ff       	call   80101a43 <ilock>
80105d9b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105d9e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105da3:	75 15                	jne    80105dba <create+0xa5>
80105da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dac:	66 83 f8 02          	cmp    $0x2,%ax
80105db0:	75 08                	jne    80105dba <create+0xa5>
      return ip;
80105db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db5:	e9 2b 01 00 00       	jmp    80105ee5 <create+0x1d0>
    iunlockput(ip);
80105dba:	83 ec 0c             	sub    $0xc,%esp
80105dbd:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc0:	e8 af be ff ff       	call   80101c74 <iunlockput>
80105dc5:	83 c4 10             	add    $0x10,%esp
    return 0;
80105dc8:	b8 00 00 00 00       	mov    $0x0,%eax
80105dcd:	e9 13 01 00 00       	jmp    80105ee5 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105dd2:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd9:	8b 00                	mov    (%eax),%eax
80105ddb:	83 ec 08             	sub    $0x8,%esp
80105dde:	52                   	push   %edx
80105ddf:	50                   	push   %eax
80105de0:	e8 aa b9 ff ff       	call   8010178f <ialloc>
80105de5:	83 c4 10             	add    $0x10,%esp
80105de8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105deb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105def:	75 0d                	jne    80105dfe <create+0xe9>
    panic("create: ialloc");
80105df1:	83 ec 0c             	sub    $0xc,%esp
80105df4:	68 4c 8f 10 80       	push   $0x80108f4c
80105df9:	e8 a2 a7 ff ff       	call   801005a0 <panic>

  ilock(ip);
80105dfe:	83 ec 0c             	sub    $0xc,%esp
80105e01:	ff 75 f0             	pushl  -0x10(%ebp)
80105e04:	e8 3a bc ff ff       	call   80101a43 <ilock>
80105e09:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e13:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e1e:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105e2b:	83 ec 0c             	sub    $0xc,%esp
80105e2e:	ff 75 f0             	pushl  -0x10(%ebp)
80105e31:	e8 30 ba ff ff       	call   80101866 <iupdate>
80105e36:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105e39:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e3e:	75 6a                	jne    80105eaa <create+0x195>
    dp->nlink++;  // for ".."
80105e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e43:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e47:	83 c0 01             	add    $0x1,%eax
80105e4a:	89 c2                	mov    %eax,%edx
80105e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4f:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105e53:	83 ec 0c             	sub    $0xc,%esp
80105e56:	ff 75 f4             	pushl  -0xc(%ebp)
80105e59:	e8 08 ba ff ff       	call   80101866 <iupdate>
80105e5e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e64:	8b 40 04             	mov    0x4(%eax),%eax
80105e67:	83 ec 04             	sub    $0x4,%esp
80105e6a:	50                   	push   %eax
80105e6b:	68 26 8f 10 80       	push   $0x80108f26
80105e70:	ff 75 f0             	pushl  -0x10(%ebp)
80105e73:	e8 70 c4 ff ff       	call   801022e8 <dirlink>
80105e78:	83 c4 10             	add    $0x10,%esp
80105e7b:	85 c0                	test   %eax,%eax
80105e7d:	78 1e                	js     80105e9d <create+0x188>
80105e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e82:	8b 40 04             	mov    0x4(%eax),%eax
80105e85:	83 ec 04             	sub    $0x4,%esp
80105e88:	50                   	push   %eax
80105e89:	68 28 8f 10 80       	push   $0x80108f28
80105e8e:	ff 75 f0             	pushl  -0x10(%ebp)
80105e91:	e8 52 c4 ff ff       	call   801022e8 <dirlink>
80105e96:	83 c4 10             	add    $0x10,%esp
80105e99:	85 c0                	test   %eax,%eax
80105e9b:	79 0d                	jns    80105eaa <create+0x195>
      panic("create dots");
80105e9d:	83 ec 0c             	sub    $0xc,%esp
80105ea0:	68 5b 8f 10 80       	push   $0x80108f5b
80105ea5:	e8 f6 a6 ff ff       	call   801005a0 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ead:	8b 40 04             	mov    0x4(%eax),%eax
80105eb0:	83 ec 04             	sub    $0x4,%esp
80105eb3:	50                   	push   %eax
80105eb4:	8d 45 de             	lea    -0x22(%ebp),%eax
80105eb7:	50                   	push   %eax
80105eb8:	ff 75 f4             	pushl  -0xc(%ebp)
80105ebb:	e8 28 c4 ff ff       	call   801022e8 <dirlink>
80105ec0:	83 c4 10             	add    $0x10,%esp
80105ec3:	85 c0                	test   %eax,%eax
80105ec5:	79 0d                	jns    80105ed4 <create+0x1bf>
    panic("create: dirlink");
80105ec7:	83 ec 0c             	sub    $0xc,%esp
80105eca:	68 67 8f 10 80       	push   $0x80108f67
80105ecf:	e8 cc a6 ff ff       	call   801005a0 <panic>

  iunlockput(dp);
80105ed4:	83 ec 0c             	sub    $0xc,%esp
80105ed7:	ff 75 f4             	pushl  -0xc(%ebp)
80105eda:	e8 95 bd ff ff       	call   80101c74 <iunlockput>
80105edf:	83 c4 10             	add    $0x10,%esp

  return ip;
80105ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ee5:	c9                   	leave  
80105ee6:	c3                   	ret    

80105ee7 <sys_open>:

int
sys_open(void)
{
80105ee7:	55                   	push   %ebp
80105ee8:	89 e5                	mov    %esp,%ebp
80105eea:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105eed:	83 ec 08             	sub    $0x8,%esp
80105ef0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ef3:	50                   	push   %eax
80105ef4:	6a 00                	push   $0x0
80105ef6:	e8 e8 f6 ff ff       	call   801055e3 <argstr>
80105efb:	83 c4 10             	add    $0x10,%esp
80105efe:	85 c0                	test   %eax,%eax
80105f00:	78 15                	js     80105f17 <sys_open+0x30>
80105f02:	83 ec 08             	sub    $0x8,%esp
80105f05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f08:	50                   	push   %eax
80105f09:	6a 01                	push   $0x1
80105f0b:	e8 4a f6 ff ff       	call   8010555a <argint>
80105f10:	83 c4 10             	add    $0x10,%esp
80105f13:	85 c0                	test   %eax,%eax
80105f15:	79 0a                	jns    80105f21 <sys_open+0x3a>
    return -1;
80105f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1c:	e9 61 01 00 00       	jmp    80106082 <sys_open+0x19b>

  begin_op();
80105f21:	e8 42 d6 ff ff       	call   80103568 <begin_op>

  if(omode & O_CREATE){
80105f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f29:	25 00 02 00 00       	and    $0x200,%eax
80105f2e:	85 c0                	test   %eax,%eax
80105f30:	74 2a                	je     80105f5c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105f32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f35:	6a 00                	push   $0x0
80105f37:	6a 00                	push   $0x0
80105f39:	6a 02                	push   $0x2
80105f3b:	50                   	push   %eax
80105f3c:	e8 d4 fd ff ff       	call   80105d15 <create>
80105f41:	83 c4 10             	add    $0x10,%esp
80105f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105f47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f4b:	75 75                	jne    80105fc2 <sys_open+0xdb>
      end_op();
80105f4d:	e8 a2 d6 ff ff       	call   801035f4 <end_op>
      return -1;
80105f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f57:	e9 26 01 00 00       	jmp    80106082 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105f5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f5f:	83 ec 0c             	sub    $0xc,%esp
80105f62:	50                   	push   %eax
80105f63:	e8 1b c6 ff ff       	call   80102583 <namei>
80105f68:	83 c4 10             	add    $0x10,%esp
80105f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f72:	75 0f                	jne    80105f83 <sys_open+0x9c>
      end_op();
80105f74:	e8 7b d6 ff ff       	call   801035f4 <end_op>
      return -1;
80105f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f7e:	e9 ff 00 00 00       	jmp    80106082 <sys_open+0x19b>
    }
    ilock(ip);
80105f83:	83 ec 0c             	sub    $0xc,%esp
80105f86:	ff 75 f4             	pushl  -0xc(%ebp)
80105f89:	e8 b5 ba ff ff       	call   80101a43 <ilock>
80105f8e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f94:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f98:	66 83 f8 01          	cmp    $0x1,%ax
80105f9c:	75 24                	jne    80105fc2 <sys_open+0xdb>
80105f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa1:	85 c0                	test   %eax,%eax
80105fa3:	74 1d                	je     80105fc2 <sys_open+0xdb>
      iunlockput(ip);
80105fa5:	83 ec 0c             	sub    $0xc,%esp
80105fa8:	ff 75 f4             	pushl  -0xc(%ebp)
80105fab:	e8 c4 bc ff ff       	call   80101c74 <iunlockput>
80105fb0:	83 c4 10             	add    $0x10,%esp
      end_op();
80105fb3:	e8 3c d6 ff ff       	call   801035f4 <end_op>
      return -1;
80105fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fbd:	e9 c0 00 00 00       	jmp    80106082 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105fc2:	e8 5f b0 ff ff       	call   80101026 <filealloc>
80105fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fce:	74 17                	je     80105fe7 <sys_open+0x100>
80105fd0:	83 ec 0c             	sub    $0xc,%esp
80105fd3:	ff 75 f0             	pushl  -0x10(%ebp)
80105fd6:	e8 34 f7 ff ff       	call   8010570f <fdalloc>
80105fdb:	83 c4 10             	add    $0x10,%esp
80105fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105fe1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105fe5:	79 2e                	jns    80106015 <sys_open+0x12e>
    if(f)
80105fe7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105feb:	74 0e                	je     80105ffb <sys_open+0x114>
      fileclose(f);
80105fed:	83 ec 0c             	sub    $0xc,%esp
80105ff0:	ff 75 f0             	pushl  -0x10(%ebp)
80105ff3:	e8 ec b0 ff ff       	call   801010e4 <fileclose>
80105ff8:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105ffb:	83 ec 0c             	sub    $0xc,%esp
80105ffe:	ff 75 f4             	pushl  -0xc(%ebp)
80106001:	e8 6e bc ff ff       	call   80101c74 <iunlockput>
80106006:	83 c4 10             	add    $0x10,%esp
    end_op();
80106009:	e8 e6 d5 ff ff       	call   801035f4 <end_op>
    return -1;
8010600e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106013:	eb 6d                	jmp    80106082 <sys_open+0x19b>
  }
  iunlock(ip);
80106015:	83 ec 0c             	sub    $0xc,%esp
80106018:	ff 75 f4             	pushl  -0xc(%ebp)
8010601b:	e8 36 bb ff ff       	call   80101b56 <iunlock>
80106020:	83 c4 10             	add    $0x10,%esp
  end_op();
80106023:	e8 cc d5 ff ff       	call   801035f4 <end_op>

  f->type = FD_INODE;
80106028:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106034:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106037:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010603a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106047:	83 e0 01             	and    $0x1,%eax
8010604a:	85 c0                	test   %eax,%eax
8010604c:	0f 94 c0             	sete   %al
8010604f:	89 c2                	mov    %eax,%edx
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106057:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010605a:	83 e0 01             	and    $0x1,%eax
8010605d:	85 c0                	test   %eax,%eax
8010605f:	75 0a                	jne    8010606b <sys_open+0x184>
80106061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106064:	83 e0 02             	and    $0x2,%eax
80106067:	85 c0                	test   %eax,%eax
80106069:	74 07                	je     80106072 <sys_open+0x18b>
8010606b:	b8 01 00 00 00       	mov    $0x1,%eax
80106070:	eb 05                	jmp    80106077 <sys_open+0x190>
80106072:	b8 00 00 00 00       	mov    $0x0,%eax
80106077:	89 c2                	mov    %eax,%edx
80106079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010607f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106082:	c9                   	leave  
80106083:	c3                   	ret    

80106084 <sys_mkdir>:

int
sys_mkdir(void)
{
80106084:	55                   	push   %ebp
80106085:	89 e5                	mov    %esp,%ebp
80106087:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010608a:	e8 d9 d4 ff ff       	call   80103568 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010608f:	83 ec 08             	sub    $0x8,%esp
80106092:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106095:	50                   	push   %eax
80106096:	6a 00                	push   $0x0
80106098:	e8 46 f5 ff ff       	call   801055e3 <argstr>
8010609d:	83 c4 10             	add    $0x10,%esp
801060a0:	85 c0                	test   %eax,%eax
801060a2:	78 1b                	js     801060bf <sys_mkdir+0x3b>
801060a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a7:	6a 00                	push   $0x0
801060a9:	6a 00                	push   $0x0
801060ab:	6a 01                	push   $0x1
801060ad:	50                   	push   %eax
801060ae:	e8 62 fc ff ff       	call   80105d15 <create>
801060b3:	83 c4 10             	add    $0x10,%esp
801060b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060bd:	75 0c                	jne    801060cb <sys_mkdir+0x47>
    end_op();
801060bf:	e8 30 d5 ff ff       	call   801035f4 <end_op>
    return -1;
801060c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c9:	eb 18                	jmp    801060e3 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801060cb:	83 ec 0c             	sub    $0xc,%esp
801060ce:	ff 75 f4             	pushl  -0xc(%ebp)
801060d1:	e8 9e bb ff ff       	call   80101c74 <iunlockput>
801060d6:	83 c4 10             	add    $0x10,%esp
  end_op();
801060d9:	e8 16 d5 ff ff       	call   801035f4 <end_op>
  return 0;
801060de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060e3:	c9                   	leave  
801060e4:	c3                   	ret    

801060e5 <sys_mknod>:

int
sys_mknod(void)
{
801060e5:	55                   	push   %ebp
801060e6:	89 e5                	mov    %esp,%ebp
801060e8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801060eb:	e8 78 d4 ff ff       	call   80103568 <begin_op>
  if((argstr(0, &path)) < 0 ||
801060f0:	83 ec 08             	sub    $0x8,%esp
801060f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060f6:	50                   	push   %eax
801060f7:	6a 00                	push   $0x0
801060f9:	e8 e5 f4 ff ff       	call   801055e3 <argstr>
801060fe:	83 c4 10             	add    $0x10,%esp
80106101:	85 c0                	test   %eax,%eax
80106103:	78 4f                	js     80106154 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106105:	83 ec 08             	sub    $0x8,%esp
80106108:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010610b:	50                   	push   %eax
8010610c:	6a 01                	push   $0x1
8010610e:	e8 47 f4 ff ff       	call   8010555a <argint>
80106113:	83 c4 10             	add    $0x10,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106116:	85 c0                	test   %eax,%eax
80106118:	78 3a                	js     80106154 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010611a:	83 ec 08             	sub    $0x8,%esp
8010611d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106120:	50                   	push   %eax
80106121:	6a 02                	push   $0x2
80106123:	e8 32 f4 ff ff       	call   8010555a <argint>
80106128:	83 c4 10             	add    $0x10,%esp
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010612b:	85 c0                	test   %eax,%eax
8010612d:	78 25                	js     80106154 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010612f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106132:	0f bf c8             	movswl %ax,%ecx
80106135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106138:	0f bf d0             	movswl %ax,%edx
8010613b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010613e:	51                   	push   %ecx
8010613f:	52                   	push   %edx
80106140:	6a 03                	push   $0x3
80106142:	50                   	push   %eax
80106143:	e8 cd fb ff ff       	call   80105d15 <create>
80106148:	83 c4 10             	add    $0x10,%esp
8010614b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010614e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106152:	75 0c                	jne    80106160 <sys_mknod+0x7b>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106154:	e8 9b d4 ff ff       	call   801035f4 <end_op>
    return -1;
80106159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615e:	eb 18                	jmp    80106178 <sys_mknod+0x93>
  }
  iunlockput(ip);
80106160:	83 ec 0c             	sub    $0xc,%esp
80106163:	ff 75 f4             	pushl  -0xc(%ebp)
80106166:	e8 09 bb ff ff       	call   80101c74 <iunlockput>
8010616b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010616e:	e8 81 d4 ff ff       	call   801035f4 <end_op>
  return 0;
80106173:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106178:	c9                   	leave  
80106179:	c3                   	ret    

8010617a <sys_chdir>:

int
sys_chdir(void)
{
8010617a:	55                   	push   %ebp
8010617b:	89 e5                	mov    %esp,%ebp
8010617d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106180:	e8 3b e1 ff ff       	call   801042c0 <myproc>
80106185:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106188:	e8 db d3 ff ff       	call   80103568 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010618d:	83 ec 08             	sub    $0x8,%esp
80106190:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106193:	50                   	push   %eax
80106194:	6a 00                	push   $0x0
80106196:	e8 48 f4 ff ff       	call   801055e3 <argstr>
8010619b:	83 c4 10             	add    $0x10,%esp
8010619e:	85 c0                	test   %eax,%eax
801061a0:	78 18                	js     801061ba <sys_chdir+0x40>
801061a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061a5:	83 ec 0c             	sub    $0xc,%esp
801061a8:	50                   	push   %eax
801061a9:	e8 d5 c3 ff ff       	call   80102583 <namei>
801061ae:	83 c4 10             	add    $0x10,%esp
801061b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061b8:	75 0c                	jne    801061c6 <sys_chdir+0x4c>
    end_op();
801061ba:	e8 35 d4 ff ff       	call   801035f4 <end_op>
    return -1;
801061bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c4:	eb 68                	jmp    8010622e <sys_chdir+0xb4>
  }
  ilock(ip);
801061c6:	83 ec 0c             	sub    $0xc,%esp
801061c9:	ff 75 f0             	pushl  -0x10(%ebp)
801061cc:	e8 72 b8 ff ff       	call   80101a43 <ilock>
801061d1:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801061d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061db:	66 83 f8 01          	cmp    $0x1,%ax
801061df:	74 1a                	je     801061fb <sys_chdir+0x81>
    iunlockput(ip);
801061e1:	83 ec 0c             	sub    $0xc,%esp
801061e4:	ff 75 f0             	pushl  -0x10(%ebp)
801061e7:	e8 88 ba ff ff       	call   80101c74 <iunlockput>
801061ec:	83 c4 10             	add    $0x10,%esp
    end_op();
801061ef:	e8 00 d4 ff ff       	call   801035f4 <end_op>
    return -1;
801061f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f9:	eb 33                	jmp    8010622e <sys_chdir+0xb4>
  }
  iunlock(ip);
801061fb:	83 ec 0c             	sub    $0xc,%esp
801061fe:	ff 75 f0             	pushl  -0x10(%ebp)
80106201:	e8 50 b9 ff ff       	call   80101b56 <iunlock>
80106206:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620c:	8b 40 68             	mov    0x68(%eax),%eax
8010620f:	83 ec 0c             	sub    $0xc,%esp
80106212:	50                   	push   %eax
80106213:	e8 8c b9 ff ff       	call   80101ba4 <iput>
80106218:	83 c4 10             	add    $0x10,%esp
  end_op();
8010621b:	e8 d4 d3 ff ff       	call   801035f4 <end_op>
  curproc->cwd = ip;
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106226:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106229:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010622e:	c9                   	leave  
8010622f:	c3                   	ret    

80106230 <sys_exec>:

int
sys_exec(void)
{
80106230:	55                   	push   %ebp
80106231:	89 e5                	mov    %esp,%ebp
80106233:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106239:	83 ec 08             	sub    $0x8,%esp
8010623c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010623f:	50                   	push   %eax
80106240:	6a 00                	push   $0x0
80106242:	e8 9c f3 ff ff       	call   801055e3 <argstr>
80106247:	83 c4 10             	add    $0x10,%esp
8010624a:	85 c0                	test   %eax,%eax
8010624c:	78 18                	js     80106266 <sys_exec+0x36>
8010624e:	83 ec 08             	sub    $0x8,%esp
80106251:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106257:	50                   	push   %eax
80106258:	6a 01                	push   $0x1
8010625a:	e8 fb f2 ff ff       	call   8010555a <argint>
8010625f:	83 c4 10             	add    $0x10,%esp
80106262:	85 c0                	test   %eax,%eax
80106264:	79 0a                	jns    80106270 <sys_exec+0x40>
    return -1;
80106266:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626b:	e9 c6 00 00 00       	jmp    80106336 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106270:	83 ec 04             	sub    $0x4,%esp
80106273:	68 80 00 00 00       	push   $0x80
80106278:	6a 00                	push   $0x0
8010627a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106280:	50                   	push   %eax
80106281:	e8 c0 ef ff ff       	call   80105246 <memset>
80106286:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106289:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106293:	83 f8 1f             	cmp    $0x1f,%eax
80106296:	76 0a                	jbe    801062a2 <sys_exec+0x72>
      return -1;
80106298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629d:	e9 94 00 00 00       	jmp    80106336 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a5:	c1 e0 02             	shl    $0x2,%eax
801062a8:	89 c2                	mov    %eax,%edx
801062aa:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801062b0:	01 c2                	add    %eax,%edx
801062b2:	83 ec 08             	sub    $0x8,%esp
801062b5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801062bb:	50                   	push   %eax
801062bc:	52                   	push   %edx
801062bd:	e8 0d f2 ff ff       	call   801054cf <fetchint>
801062c2:	83 c4 10             	add    $0x10,%esp
801062c5:	85 c0                	test   %eax,%eax
801062c7:	79 07                	jns    801062d0 <sys_exec+0xa0>
      return -1;
801062c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ce:	eb 66                	jmp    80106336 <sys_exec+0x106>
    if(uarg == 0){
801062d0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801062d6:	85 c0                	test   %eax,%eax
801062d8:	75 27                	jne    80106301 <sys_exec+0xd1>
      argv[i] = 0;
801062da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dd:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801062e4:	00 00 00 00 
      break;
801062e8:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ec:	83 ec 08             	sub    $0x8,%esp
801062ef:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801062f5:	52                   	push   %edx
801062f6:	50                   	push   %eax
801062f7:	e8 9a a8 ff ff       	call   80100b96 <exec>
801062fc:	83 c4 10             	add    $0x10,%esp
801062ff:	eb 35                	jmp    80106336 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106301:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106307:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010630a:	c1 e2 02             	shl    $0x2,%edx
8010630d:	01 c2                	add    %eax,%edx
8010630f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106315:	83 ec 08             	sub    $0x8,%esp
80106318:	52                   	push   %edx
80106319:	50                   	push   %eax
8010631a:	e8 e1 f1 ff ff       	call   80105500 <fetchstr>
8010631f:	83 c4 10             	add    $0x10,%esp
80106322:	85 c0                	test   %eax,%eax
80106324:	79 07                	jns    8010632d <sys_exec+0xfd>
      return -1;
80106326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632b:	eb 09                	jmp    80106336 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010632d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106331:	e9 5a ff ff ff       	jmp    80106290 <sys_exec+0x60>
  return exec(path, argv);
}
80106336:	c9                   	leave  
80106337:	c3                   	ret    

80106338 <sys_pipe>:

int
sys_pipe(void)
{
80106338:	55                   	push   %ebp
80106339:	89 e5                	mov    %esp,%ebp
8010633b:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010633e:	83 ec 04             	sub    $0x4,%esp
80106341:	6a 08                	push   $0x8
80106343:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106346:	50                   	push   %eax
80106347:	6a 00                	push   $0x0
80106349:	e8 39 f2 ff ff       	call   80105587 <argptr>
8010634e:	83 c4 10             	add    $0x10,%esp
80106351:	85 c0                	test   %eax,%eax
80106353:	79 0a                	jns    8010635f <sys_pipe+0x27>
    return -1;
80106355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635a:	e9 b0 00 00 00       	jmp    8010640f <sys_pipe+0xd7>
  if(pipealloc(&rf, &wf) < 0)
8010635f:	83 ec 08             	sub    $0x8,%esp
80106362:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106365:	50                   	push   %eax
80106366:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106369:	50                   	push   %eax
8010636a:	e8 88 da ff ff       	call   80103df7 <pipealloc>
8010636f:	83 c4 10             	add    $0x10,%esp
80106372:	85 c0                	test   %eax,%eax
80106374:	79 0a                	jns    80106380 <sys_pipe+0x48>
    return -1;
80106376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637b:	e9 8f 00 00 00       	jmp    8010640f <sys_pipe+0xd7>
  fd0 = -1;
80106380:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106387:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010638a:	83 ec 0c             	sub    $0xc,%esp
8010638d:	50                   	push   %eax
8010638e:	e8 7c f3 ff ff       	call   8010570f <fdalloc>
80106393:	83 c4 10             	add    $0x10,%esp
80106396:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010639d:	78 18                	js     801063b7 <sys_pipe+0x7f>
8010639f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063a2:	83 ec 0c             	sub    $0xc,%esp
801063a5:	50                   	push   %eax
801063a6:	e8 64 f3 ff ff       	call   8010570f <fdalloc>
801063ab:	83 c4 10             	add    $0x10,%esp
801063ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063b5:	79 40                	jns    801063f7 <sys_pipe+0xbf>
    if(fd0 >= 0)
801063b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063bb:	78 15                	js     801063d2 <sys_pipe+0x9a>
      myproc()->ofile[fd0] = 0;
801063bd:	e8 fe de ff ff       	call   801042c0 <myproc>
801063c2:	89 c2                	mov    %eax,%edx
801063c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c7:	83 c0 08             	add    $0x8,%eax
801063ca:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
801063d1:	00 
    fileclose(rf);
801063d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063d5:	83 ec 0c             	sub    $0xc,%esp
801063d8:	50                   	push   %eax
801063d9:	e8 06 ad ff ff       	call   801010e4 <fileclose>
801063de:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801063e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063e4:	83 ec 0c             	sub    $0xc,%esp
801063e7:	50                   	push   %eax
801063e8:	e8 f7 ac ff ff       	call   801010e4 <fileclose>
801063ed:	83 c4 10             	add    $0x10,%esp
    return -1;
801063f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f5:	eb 18                	jmp    8010640f <sys_pipe+0xd7>
  }
  fd[0] = fd0;
801063f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063fd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801063ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106402:	8d 50 04             	lea    0x4(%eax),%edx
80106405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106408:	89 02                	mov    %eax,(%edx)
  return 0;
8010640a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640f:	c9                   	leave  
80106410:	c3                   	ret    

80106411 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
80106411:	55                   	push   %ebp
80106412:	89 e5                	mov    %esp,%ebp
80106414:	83 ec 18             	sub    $0x18,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
80106417:	83 ec 08             	sub    $0x8,%esp
8010641a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010641d:	50                   	push   %eax
8010641e:	6a 00                	push   $0x0
80106420:	e8 35 f1 ff ff       	call   8010555a <argint>
80106425:	83 c4 10             	add    $0x10,%esp
80106428:	85 c0                	test   %eax,%eax
8010642a:	79 07                	jns    80106433 <sys_shm_open+0x22>
    return -1;
8010642c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106431:	eb 31                	jmp    80106464 <sys_shm_open+0x53>

  if(argptr(1, (char **) (&pointer),4)<0)
80106433:	83 ec 04             	sub    $0x4,%esp
80106436:	6a 04                	push   $0x4
80106438:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010643b:	50                   	push   %eax
8010643c:	6a 01                	push   $0x1
8010643e:	e8 44 f1 ff ff       	call   80105587 <argptr>
80106443:	83 c4 10             	add    $0x10,%esp
80106446:	85 c0                	test   %eax,%eax
80106448:	79 07                	jns    80106451 <sys_shm_open+0x40>
    return -1;
8010644a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010644f:	eb 13                	jmp    80106464 <sys_shm_open+0x53>
  return shm_open(id, pointer);
80106451:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106457:	83 ec 08             	sub    $0x8,%esp
8010645a:	52                   	push   %edx
8010645b:	50                   	push   %eax
8010645c:	e8 40 22 00 00       	call   801086a1 <shm_open>
80106461:	83 c4 10             	add    $0x10,%esp
}
80106464:	c9                   	leave  
80106465:	c3                   	ret    

80106466 <sys_shm_close>:

int sys_shm_close(void) {
80106466:	55                   	push   %ebp
80106467:	89 e5                	mov    %esp,%ebp
80106469:	83 ec 18             	sub    $0x18,%esp
  int id;

  if(argint(0, &id) < 0)
8010646c:	83 ec 08             	sub    $0x8,%esp
8010646f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106472:	50                   	push   %eax
80106473:	6a 00                	push   $0x0
80106475:	e8 e0 f0 ff ff       	call   8010555a <argint>
8010647a:	83 c4 10             	add    $0x10,%esp
8010647d:	85 c0                	test   %eax,%eax
8010647f:	79 07                	jns    80106488 <sys_shm_close+0x22>
    return -1;
80106481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106486:	eb 0f                	jmp    80106497 <sys_shm_close+0x31>

  
  return shm_close(id);
80106488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648b:	83 ec 0c             	sub    $0xc,%esp
8010648e:	50                   	push   %eax
8010648f:	e8 05 25 00 00       	call   80108999 <shm_close>
80106494:	83 c4 10             	add    $0x10,%esp
}
80106497:	c9                   	leave  
80106498:	c3                   	ret    

80106499 <sys_fork>:

int
sys_fork(void)
{
80106499:	55                   	push   %ebp
8010649a:	89 e5                	mov    %esp,%ebp
8010649c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010649f:	e8 24 e1 ff ff       	call   801045c8 <fork>
}
801064a4:	c9                   	leave  
801064a5:	c3                   	ret    

801064a6 <sys_exit>:

int
sys_exit(void)
{
801064a6:	55                   	push   %ebp
801064a7:	89 e5                	mov    %esp,%ebp
801064a9:	83 ec 08             	sub    $0x8,%esp
  exit();
801064ac:	e8 c0 e2 ff ff       	call   80104771 <exit>
  return 0;  // not reached
801064b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b6:	c9                   	leave  
801064b7:	c3                   	ret    

801064b8 <sys_wait>:

int
sys_wait(void)
{
801064b8:	55                   	push   %ebp
801064b9:	89 e5                	mov    %esp,%ebp
801064bb:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064be:	e8 d1 e3 ff ff       	call   80104894 <wait>
}
801064c3:	c9                   	leave  
801064c4:	c3                   	ret    

801064c5 <sys_kill>:

int
sys_kill(void)
{
801064c5:	55                   	push   %ebp
801064c6:	89 e5                	mov    %esp,%ebp
801064c8:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064cb:	83 ec 08             	sub    $0x8,%esp
801064ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064d1:	50                   	push   %eax
801064d2:	6a 00                	push   $0x0
801064d4:	e8 81 f0 ff ff       	call   8010555a <argint>
801064d9:	83 c4 10             	add    $0x10,%esp
801064dc:	85 c0                	test   %eax,%eax
801064de:	79 07                	jns    801064e7 <sys_kill+0x22>
    return -1;
801064e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e5:	eb 0f                	jmp    801064f6 <sys_kill+0x31>
  return kill(pid);
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	83 ec 0c             	sub    $0xc,%esp
801064ed:	50                   	push   %eax
801064ee:	e8 da e7 ff ff       	call   80104ccd <kill>
801064f3:	83 c4 10             	add    $0x10,%esp
}
801064f6:	c9                   	leave  
801064f7:	c3                   	ret    

801064f8 <sys_getpid>:

int
sys_getpid(void)
{
801064f8:	55                   	push   %ebp
801064f9:	89 e5                	mov    %esp,%ebp
801064fb:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801064fe:	e8 bd dd ff ff       	call   801042c0 <myproc>
80106503:	8b 40 10             	mov    0x10(%eax),%eax
}
80106506:	c9                   	leave  
80106507:	c3                   	ret    

80106508 <sys_sbrk>:

int
sys_sbrk(void)
{
80106508:	55                   	push   %ebp
80106509:	89 e5                	mov    %esp,%ebp
8010650b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010650e:	83 ec 08             	sub    $0x8,%esp
80106511:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106514:	50                   	push   %eax
80106515:	6a 00                	push   $0x0
80106517:	e8 3e f0 ff ff       	call   8010555a <argint>
8010651c:	83 c4 10             	add    $0x10,%esp
8010651f:	85 c0                	test   %eax,%eax
80106521:	79 07                	jns    8010652a <sys_sbrk+0x22>
    return -1;
80106523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106528:	eb 27                	jmp    80106551 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010652a:	e8 91 dd ff ff       	call   801042c0 <myproc>
8010652f:	8b 00                	mov    (%eax),%eax
80106531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106537:	83 ec 0c             	sub    $0xc,%esp
8010653a:	50                   	push   %eax
8010653b:	e8 ed df ff ff       	call   8010452d <growproc>
80106540:	83 c4 10             	add    $0x10,%esp
80106543:	85 c0                	test   %eax,%eax
80106545:	79 07                	jns    8010654e <sys_sbrk+0x46>
    return -1;
80106547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654c:	eb 03                	jmp    80106551 <sys_sbrk+0x49>
  return addr;
8010654e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106551:	c9                   	leave  
80106552:	c3                   	ret    

80106553 <sys_sleep>:

int
sys_sleep(void)
{
80106553:	55                   	push   %ebp
80106554:	89 e5                	mov    %esp,%ebp
80106556:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106559:	83 ec 08             	sub    $0x8,%esp
8010655c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010655f:	50                   	push   %eax
80106560:	6a 00                	push   $0x0
80106562:	e8 f3 ef ff ff       	call   8010555a <argint>
80106567:	83 c4 10             	add    $0x10,%esp
8010656a:	85 c0                	test   %eax,%eax
8010656c:	79 07                	jns    80106575 <sys_sleep+0x22>
    return -1;
8010656e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106573:	eb 76                	jmp    801065eb <sys_sleep+0x98>
  acquire(&tickslock);
80106575:	83 ec 0c             	sub    $0xc,%esp
80106578:	68 e0 6e 11 80       	push   $0x80116ee0
8010657d:	e8 4d ea ff ff       	call   80104fcf <acquire>
80106582:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106585:	a1 20 77 11 80       	mov    0x80117720,%eax
8010658a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010658d:	eb 38                	jmp    801065c7 <sys_sleep+0x74>
    if(myproc()->killed){
8010658f:	e8 2c dd ff ff       	call   801042c0 <myproc>
80106594:	8b 40 24             	mov    0x24(%eax),%eax
80106597:	85 c0                	test   %eax,%eax
80106599:	74 17                	je     801065b2 <sys_sleep+0x5f>
      release(&tickslock);
8010659b:	83 ec 0c             	sub    $0xc,%esp
8010659e:	68 e0 6e 11 80       	push   $0x80116ee0
801065a3:	e8 95 ea ff ff       	call   8010503d <release>
801065a8:	83 c4 10             	add    $0x10,%esp
      return -1;
801065ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b0:	eb 39                	jmp    801065eb <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801065b2:	83 ec 08             	sub    $0x8,%esp
801065b5:	68 e0 6e 11 80       	push   $0x80116ee0
801065ba:	68 20 77 11 80       	push   $0x80117720
801065bf:	e8 e9 e5 ff ff       	call   80104bad <sleep>
801065c4:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801065c7:	a1 20 77 11 80       	mov    0x80117720,%eax
801065cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065d2:	39 d0                	cmp    %edx,%eax
801065d4:	72 b9                	jb     8010658f <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801065d6:	83 ec 0c             	sub    $0xc,%esp
801065d9:	68 e0 6e 11 80       	push   $0x80116ee0
801065de:	e8 5a ea ff ff       	call   8010503d <release>
801065e3:	83 c4 10             	add    $0x10,%esp
  return 0;
801065e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065eb:	c9                   	leave  
801065ec:	c3                   	ret    

801065ed <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065ed:	55                   	push   %ebp
801065ee:	89 e5                	mov    %esp,%ebp
801065f0:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801065f3:	83 ec 0c             	sub    $0xc,%esp
801065f6:	68 e0 6e 11 80       	push   $0x80116ee0
801065fb:	e8 cf e9 ff ff       	call   80104fcf <acquire>
80106600:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106603:	a1 20 77 11 80       	mov    0x80117720,%eax
80106608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010660b:	83 ec 0c             	sub    $0xc,%esp
8010660e:	68 e0 6e 11 80       	push   $0x80116ee0
80106613:	e8 25 ea ff ff       	call   8010503d <release>
80106618:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010661b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010661e:	c9                   	leave  
8010661f:	c3                   	ret    

80106620 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106620:	1e                   	push   %ds
  pushl %es
80106621:	06                   	push   %es
  pushl %fs
80106622:	0f a0                	push   %fs
  pushl %gs
80106624:	0f a8                	push   %gs
  pushal
80106626:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106627:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010662b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010662d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010662f:	54                   	push   %esp
  call trap
80106630:	e8 d7 01 00 00       	call   8010680c <trap>
  addl $4, %esp
80106635:	83 c4 04             	add    $0x4,%esp

80106638 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106638:	61                   	popa   
  popl %gs
80106639:	0f a9                	pop    %gs
  popl %fs
8010663b:	0f a1                	pop    %fs
  popl %es
8010663d:	07                   	pop    %es
  popl %ds
8010663e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010663f:	83 c4 08             	add    $0x8,%esp
  iret
80106642:	cf                   	iret   

80106643 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106643:	55                   	push   %ebp
80106644:	89 e5                	mov    %esp,%ebp
80106646:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010664c:	83 e8 01             	sub    $0x1,%eax
8010664f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106653:	8b 45 08             	mov    0x8(%ebp),%eax
80106656:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010665a:	8b 45 08             	mov    0x8(%ebp),%eax
8010665d:	c1 e8 10             	shr    $0x10,%eax
80106660:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106664:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106667:	0f 01 18             	lidtl  (%eax)
}
8010666a:	90                   	nop
8010666b:	c9                   	leave  
8010666c:	c3                   	ret    

8010666d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010666d:	55                   	push   %ebp
8010666e:	89 e5                	mov    %esp,%ebp
80106670:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106673:	0f 20 d0             	mov    %cr2,%eax
80106676:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106679:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010667c:	c9                   	leave  
8010667d:	c3                   	ret    

8010667e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010667e:	55                   	push   %ebp
8010667f:	89 e5                	mov    %esp,%ebp
80106681:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010668b:	e9 c3 00 00 00       	jmp    80106753 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106693:	8b 04 85 80 c0 10 80 	mov    -0x7fef3f80(,%eax,4),%eax
8010669a:	89 c2                	mov    %eax,%edx
8010669c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669f:	66 89 14 c5 20 6f 11 	mov    %dx,-0x7fee90e0(,%eax,8)
801066a6:	80 
801066a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066aa:	66 c7 04 c5 22 6f 11 	movw   $0x8,-0x7fee90de(,%eax,8)
801066b1:	80 08 00 
801066b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b7:	0f b6 14 c5 24 6f 11 	movzbl -0x7fee90dc(,%eax,8),%edx
801066be:	80 
801066bf:	83 e2 e0             	and    $0xffffffe0,%edx
801066c2:	88 14 c5 24 6f 11 80 	mov    %dl,-0x7fee90dc(,%eax,8)
801066c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066cc:	0f b6 14 c5 24 6f 11 	movzbl -0x7fee90dc(,%eax,8),%edx
801066d3:	80 
801066d4:	83 e2 1f             	and    $0x1f,%edx
801066d7:	88 14 c5 24 6f 11 80 	mov    %dl,-0x7fee90dc(,%eax,8)
801066de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e1:	0f b6 14 c5 25 6f 11 	movzbl -0x7fee90db(,%eax,8),%edx
801066e8:	80 
801066e9:	83 e2 f0             	and    $0xfffffff0,%edx
801066ec:	83 ca 0e             	or     $0xe,%edx
801066ef:	88 14 c5 25 6f 11 80 	mov    %dl,-0x7fee90db(,%eax,8)
801066f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f9:	0f b6 14 c5 25 6f 11 	movzbl -0x7fee90db(,%eax,8),%edx
80106700:	80 
80106701:	83 e2 ef             	and    $0xffffffef,%edx
80106704:	88 14 c5 25 6f 11 80 	mov    %dl,-0x7fee90db(,%eax,8)
8010670b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670e:	0f b6 14 c5 25 6f 11 	movzbl -0x7fee90db(,%eax,8),%edx
80106715:	80 
80106716:	83 e2 9f             	and    $0xffffff9f,%edx
80106719:	88 14 c5 25 6f 11 80 	mov    %dl,-0x7fee90db(,%eax,8)
80106720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106723:	0f b6 14 c5 25 6f 11 	movzbl -0x7fee90db(,%eax,8),%edx
8010672a:	80 
8010672b:	83 ca 80             	or     $0xffffff80,%edx
8010672e:	88 14 c5 25 6f 11 80 	mov    %dl,-0x7fee90db(,%eax,8)
80106735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106738:	8b 04 85 80 c0 10 80 	mov    -0x7fef3f80(,%eax,4),%eax
8010673f:	c1 e8 10             	shr    $0x10,%eax
80106742:	89 c2                	mov    %eax,%edx
80106744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106747:	66 89 14 c5 26 6f 11 	mov    %dx,-0x7fee90da(,%eax,8)
8010674e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010674f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106753:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010675a:	0f 8e 30 ff ff ff    	jle    80106690 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106760:	a1 80 c1 10 80       	mov    0x8010c180,%eax
80106765:	66 a3 20 71 11 80    	mov    %ax,0x80117120
8010676b:	66 c7 05 22 71 11 80 	movw   $0x8,0x80117122
80106772:	08 00 
80106774:	0f b6 05 24 71 11 80 	movzbl 0x80117124,%eax
8010677b:	83 e0 e0             	and    $0xffffffe0,%eax
8010677e:	a2 24 71 11 80       	mov    %al,0x80117124
80106783:	0f b6 05 24 71 11 80 	movzbl 0x80117124,%eax
8010678a:	83 e0 1f             	and    $0x1f,%eax
8010678d:	a2 24 71 11 80       	mov    %al,0x80117124
80106792:	0f b6 05 25 71 11 80 	movzbl 0x80117125,%eax
80106799:	83 c8 0f             	or     $0xf,%eax
8010679c:	a2 25 71 11 80       	mov    %al,0x80117125
801067a1:	0f b6 05 25 71 11 80 	movzbl 0x80117125,%eax
801067a8:	83 e0 ef             	and    $0xffffffef,%eax
801067ab:	a2 25 71 11 80       	mov    %al,0x80117125
801067b0:	0f b6 05 25 71 11 80 	movzbl 0x80117125,%eax
801067b7:	83 c8 60             	or     $0x60,%eax
801067ba:	a2 25 71 11 80       	mov    %al,0x80117125
801067bf:	0f b6 05 25 71 11 80 	movzbl 0x80117125,%eax
801067c6:	83 c8 80             	or     $0xffffff80,%eax
801067c9:	a2 25 71 11 80       	mov    %al,0x80117125
801067ce:	a1 80 c1 10 80       	mov    0x8010c180,%eax
801067d3:	c1 e8 10             	shr    $0x10,%eax
801067d6:	66 a3 26 71 11 80    	mov    %ax,0x80117126

  initlock(&tickslock, "time");
801067dc:	83 ec 08             	sub    $0x8,%esp
801067df:	68 78 8f 10 80       	push   $0x80108f78
801067e4:	68 e0 6e 11 80       	push   $0x80116ee0
801067e9:	e8 bf e7 ff ff       	call   80104fad <initlock>
801067ee:	83 c4 10             	add    $0x10,%esp
}
801067f1:	90                   	nop
801067f2:	c9                   	leave  
801067f3:	c3                   	ret    

801067f4 <idtinit>:

void
idtinit(void)
{
801067f4:	55                   	push   %ebp
801067f5:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801067f7:	68 00 08 00 00       	push   $0x800
801067fc:	68 20 6f 11 80       	push   $0x80116f20
80106801:	e8 3d fe ff ff       	call   80106643 <lidt>
80106806:	83 c4 08             	add    $0x8,%esp
}
80106809:	90                   	nop
8010680a:	c9                   	leave  
8010680b:	c3                   	ret    

8010680c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010680c:	55                   	push   %ebp
8010680d:	89 e5                	mov    %esp,%ebp
8010680f:	57                   	push   %edi
80106810:	56                   	push   %esi
80106811:	53                   	push   %ebx
80106812:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106815:	8b 45 08             	mov    0x8(%ebp),%eax
80106818:	8b 40 30             	mov    0x30(%eax),%eax
8010681b:	83 f8 40             	cmp    $0x40,%eax
8010681e:	75 3d                	jne    8010685d <trap+0x51>
    if(myproc()->killed)
80106820:	e8 9b da ff ff       	call   801042c0 <myproc>
80106825:	8b 40 24             	mov    0x24(%eax),%eax
80106828:	85 c0                	test   %eax,%eax
8010682a:	74 05                	je     80106831 <trap+0x25>
      exit();
8010682c:	e8 40 df ff ff       	call   80104771 <exit>
    myproc()->tf = tf;
80106831:	e8 8a da ff ff       	call   801042c0 <myproc>
80106836:	89 c2                	mov    %eax,%edx
80106838:	8b 45 08             	mov    0x8(%ebp),%eax
8010683b:	89 42 18             	mov    %eax,0x18(%edx)
    syscall();
8010683e:	e8 d7 ed ff ff       	call   8010561a <syscall>
    if(myproc()->killed)
80106843:	e8 78 da ff ff       	call   801042c0 <myproc>
80106848:	8b 40 24             	mov    0x24(%eax),%eax
8010684b:	85 c0                	test   %eax,%eax
8010684d:	0f 84 69 03 00 00    	je     80106bbc <trap+0x3b0>
      exit();
80106853:	e8 19 df ff ff       	call   80104771 <exit>
    return;
80106858:	e9 5f 03 00 00       	jmp    80106bbc <trap+0x3b0>
  }

  switch(tf->trapno){
8010685d:	8b 45 08             	mov    0x8(%ebp),%eax
80106860:	8b 40 30             	mov    0x30(%eax),%eax
80106863:	83 e8 20             	sub    $0x20,%eax
80106866:	83 f8 1f             	cmp    $0x1f,%eax
80106869:	0f 87 b5 00 00 00    	ja     80106924 <trap+0x118>
8010686f:	8b 04 85 90 90 10 80 	mov    -0x7fef6f70(,%eax,4),%eax
80106876:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106878:	e8 aa d9 ff ff       	call   80104227 <cpuid>
8010687d:	85 c0                	test   %eax,%eax
8010687f:	75 3d                	jne    801068be <trap+0xb2>
      acquire(&tickslock);
80106881:	83 ec 0c             	sub    $0xc,%esp
80106884:	68 e0 6e 11 80       	push   $0x80116ee0
80106889:	e8 41 e7 ff ff       	call   80104fcf <acquire>
8010688e:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106891:	a1 20 77 11 80       	mov    0x80117720,%eax
80106896:	83 c0 01             	add    $0x1,%eax
80106899:	a3 20 77 11 80       	mov    %eax,0x80117720
      wakeup(&ticks);
8010689e:	83 ec 0c             	sub    $0xc,%esp
801068a1:	68 20 77 11 80       	push   $0x80117720
801068a6:	e8 eb e3 ff ff       	call   80104c96 <wakeup>
801068ab:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801068ae:	83 ec 0c             	sub    $0xc,%esp
801068b1:	68 e0 6e 11 80       	push   $0x80116ee0
801068b6:	e8 82 e7 ff ff       	call   8010503d <release>
801068bb:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801068be:	e8 7d c7 ff ff       	call   80103040 <lapiceoi>
    break;
801068c3:	e9 74 02 00 00       	jmp    80106b3c <trap+0x330>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801068c8:	e8 ed bf ff ff       	call   801028ba <ideintr>
    lapiceoi();
801068cd:	e8 6e c7 ff ff       	call   80103040 <lapiceoi>
    break;
801068d2:	e9 65 02 00 00       	jmp    80106b3c <trap+0x330>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801068d7:	e8 ad c5 ff ff       	call   80102e89 <kbdintr>
    lapiceoi();
801068dc:	e8 5f c7 ff ff       	call   80103040 <lapiceoi>
    break;
801068e1:	e9 56 02 00 00       	jmp    80106b3c <trap+0x330>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801068e6:	e8 a5 04 00 00       	call   80106d90 <uartintr>
    lapiceoi();
801068eb:	e8 50 c7 ff ff       	call   80103040 <lapiceoi>
    break;
801068f0:	e9 47 02 00 00       	jmp    80106b3c <trap+0x330>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068f5:	8b 45 08             	mov    0x8(%ebp),%eax
801068f8:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801068fb:	8b 45 08             	mov    0x8(%ebp),%eax
801068fe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106902:	0f b7 d8             	movzwl %ax,%ebx
80106905:	e8 1d d9 ff ff       	call   80104227 <cpuid>
8010690a:	56                   	push   %esi
8010690b:	53                   	push   %ebx
8010690c:	50                   	push   %eax
8010690d:	68 80 8f 10 80       	push   $0x80108f80
80106912:	e8 e9 9a ff ff       	call   80100400 <cprintf>
80106917:	83 c4 10             	add    $0x10,%esp
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
8010691a:	e8 21 c7 ff ff       	call   80103040 <lapiceoi>
    break;
8010691f:	e9 18 02 00 00       	jmp    80106b3c <trap+0x330>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106924:	e8 97 d9 ff ff       	call   801042c0 <myproc>
80106929:	85 c0                	test   %eax,%eax
8010692b:	74 11                	je     8010693e <trap+0x132>
8010692d:	8b 45 08             	mov    0x8(%ebp),%eax
80106930:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106934:	0f b7 c0             	movzwl %ax,%eax
80106937:	83 e0 03             	and    $0x3,%eax
8010693a:	85 c0                	test   %eax,%eax
8010693c:	75 3b                	jne    80106979 <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010693e:	e8 2a fd ff ff       	call   8010666d <rcr2>
80106943:	89 c6                	mov    %eax,%esi
80106945:	8b 45 08             	mov    0x8(%ebp),%eax
80106948:	8b 58 38             	mov    0x38(%eax),%ebx
8010694b:	e8 d7 d8 ff ff       	call   80104227 <cpuid>
80106950:	89 c2                	mov    %eax,%edx
80106952:	8b 45 08             	mov    0x8(%ebp),%eax
80106955:	8b 40 30             	mov    0x30(%eax),%eax
80106958:	83 ec 0c             	sub    $0xc,%esp
8010695b:	56                   	push   %esi
8010695c:	53                   	push   %ebx
8010695d:	52                   	push   %edx
8010695e:	50                   	push   %eax
8010695f:	68 a4 8f 10 80       	push   $0x80108fa4
80106964:	e8 97 9a ff ff       	call   80100400 <cprintf>
80106969:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010696c:	83 ec 0c             	sub    $0xc,%esp
8010696f:	68 d6 8f 10 80       	push   $0x80108fd6
80106974:	e8 27 9c ff ff       	call   801005a0 <panic>
    }
    //Added case to handle page faults CS153
    if (tf->trapno == T_PGFLT)
80106979:	8b 45 08             	mov    0x8(%ebp),%eax
8010697c:	8b 40 30             	mov    0x30(%eax),%eax
8010697f:	83 f8 0e             	cmp    $0xe,%eax
80106982:	0f 85 56 01 00 00    	jne    80106ade <trap+0x2d2>
    {
	//Added a check to determine when the stack has run out of space using kalloc() CS153
	if (kalloc() == 0)
80106988:	e8 3b c3 ff ff       	call   80102cc8 <kalloc>
8010698d:	85 c0                	test   %eax,%eax
8010698f:	75 71                	jne    80106a02 <trap+0x1f6>
	{
	    cprintf("OUT OF STACK SPACE\n");
80106991:	83 ec 0c             	sub    $0xc,%esp
80106994:	68 db 8f 10 80       	push   $0x80108fdb
80106999:	e8 62 9a ff ff       	call   80100400 <cprintf>
8010699e:	83 c4 10             	add    $0x10,%esp
	    cprintf("STOPPED AT %x\n", (myproc()->tf->esp));
801069a1:	e8 1a d9 ff ff       	call   801042c0 <myproc>
801069a6:	8b 40 18             	mov    0x18(%eax),%eax
801069a9:	8b 40 44             	mov    0x44(%eax),%eax
801069ac:	83 ec 08             	sub    $0x8,%esp
801069af:	50                   	push   %eax
801069b0:	68 ef 8f 10 80       	push   $0x80108fef
801069b5:	e8 46 9a ff ff       	call   80100400 <cprintf>
801069ba:	83 c4 10             	add    $0x10,%esp
	    cprintf("TOP OF CODE + BUFFER: %x\n", myproc()->sz);
801069bd:	e8 fe d8 ff ff       	call   801042c0 <myproc>
801069c2:	8b 00                	mov    (%eax),%eax
801069c4:	83 ec 08             	sub    $0x8,%esp
801069c7:	50                   	push   %eax
801069c8:	68 fe 8f 10 80       	push   $0x80108ffe
801069cd:	e8 2e 9a ff ff       	call   80100400 <cprintf>
801069d2:	83 c4 10             	add    $0x10,%esp
	    cprintf("NUM PAGES %d\n", myproc()->pageNum);
801069d5:	e8 e6 d8 ff ff       	call   801042c0 <myproc>
801069da:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069e0:	83 ec 08             	sub    $0x8,%esp
801069e3:	50                   	push   %eax
801069e4:	68 18 90 10 80       	push   $0x80109018
801069e9:	e8 12 9a ff ff       	call   80100400 <cprintf>
801069ee:	83 c4 10             	add    $0x10,%esp
	    myproc()->killed = 1;
801069f1:	e8 ca d8 ff ff       	call   801042c0 <myproc>
801069f6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
	    exit();
801069fd:	e8 6f dd ff ff       	call   80104771 <exit>
	
	}

	//Check to make sure the stack is properly allocated CS153
	if (myproc()->tf->esp < myproc()->stackTop)
80106a02:	e8 b9 d8 ff ff       	call   801042c0 <myproc>
80106a07:	8b 40 18             	mov    0x18(%eax),%eax
80106a0a:	8b 58 44             	mov    0x44(%eax),%ebx
80106a0d:	e8 ae d8 ff ff       	call   801042c0 <myproc>
80106a12:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a15:	39 c3                	cmp    %eax,%ebx
80106a17:	0f 83 c1 00 00 00    	jae    80106ade <trap+0x2d2>
	{
	    myproc()->pageNum += 1;
80106a1d:	e8 9e d8 ff ff       	call   801042c0 <myproc>
80106a22:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80106a28:	83 c2 01             	add    $0x1,%edx
80106a2b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
//	    cprintf("TOP: %x\n", myproc()->stackTop);
//	    cprintf("NUM_PAGES: %d\n", myproc()->pageNum);
	    cprintf("TOP_NEWPAGE: %x\n", myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE));
80106a31:	e8 8a d8 ff ff       	call   801042c0 <myproc>
80106a36:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a39:	e8 82 d8 ff ff       	call   801042c0 <myproc>
80106a3e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a44:	05 ff ff 0f 00       	add    $0xfffff,%eax
80106a49:	c1 e0 0c             	shl    $0xc,%eax
80106a4c:	29 c3                	sub    %eax,%ebx
80106a4e:	89 d8                	mov    %ebx,%eax
80106a50:	83 ec 08             	sub    $0x8,%esp
80106a53:	50                   	push   %eax
80106a54:	68 26 90 10 80       	push   $0x80109026
80106a59:	e8 a2 99 ff ff       	call   80100400 <cprintf>
80106a5e:	83 c4 10             	add    $0x10,%esp
	    cprintf("BOTTOM_NEWPAGE: %x\n", myproc()->stackTop - ((myproc()->pageNum)*PGSIZE));
80106a61:	e8 5a d8 ff ff       	call   801042c0 <myproc>
80106a66:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a69:	e8 52 d8 ff ff       	call   801042c0 <myproc>
80106a6e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a74:	c1 e0 0c             	shl    $0xc,%eax
80106a77:	29 c3                	sub    %eax,%ebx
80106a79:	89 d8                	mov    %ebx,%eax
80106a7b:	83 ec 08             	sub    $0x8,%esp
80106a7e:	50                   	push   %eax
80106a7f:	68 37 90 10 80       	push   $0x80109037
80106a84:	e8 77 99 ff ff       	call   80100400 <cprintf>
80106a89:	83 c4 10             	add    $0x10,%esp
//	    cprintf("SP: %x\n", myproc()->tf->esp);
	   
 // 	    cprintf("TRAP DIFFERENCE: %d\n", myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE) -  myproc()->stackTop - ((myproc()->pageNum)*PGSIZE));

            allocuvm(myproc()->pgdir, myproc()->stackTop - (myproc()->pageNum*PGSIZE), myproc()->stackTop - ((myproc()->pageNum-1)*PGSIZE));
80106a8c:	e8 2f d8 ff ff       	call   801042c0 <myproc>
80106a91:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a94:	e8 27 d8 ff ff       	call   801042c0 <myproc>
80106a99:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106a9f:	05 ff ff 0f 00       	add    $0xfffff,%eax
80106aa4:	c1 e0 0c             	shl    $0xc,%eax
80106aa7:	89 de                	mov    %ebx,%esi
80106aa9:	29 c6                	sub    %eax,%esi
80106aab:	e8 10 d8 ff ff       	call   801042c0 <myproc>
80106ab0:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106ab3:	e8 08 d8 ff ff       	call   801042c0 <myproc>
80106ab8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106abe:	c1 e0 0c             	shl    $0xc,%eax
80106ac1:	29 c3                	sub    %eax,%ebx
80106ac3:	e8 f8 d7 ff ff       	call   801042c0 <myproc>
80106ac8:	8b 40 04             	mov    0x4(%eax),%eax
80106acb:	83 ec 04             	sub    $0x4,%esp
80106ace:	56                   	push   %esi
80106acf:	53                   	push   %ebx
80106ad0:	50                   	push   %eax
80106ad1:	e8 b3 15 00 00       	call   80108089 <allocuvm>
80106ad6:	83 c4 10             	add    $0x10,%esp
	    return;	
80106ad9:	e9 df 00 00 00       	jmp    80106bbd <trap+0x3b1>
	    cprintf("DONE?"); 
	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ade:	e8 8a fb ff ff       	call   8010666d <rcr2>
80106ae3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae9:	8b 78 38             	mov    0x38(%eax),%edi
80106aec:	e8 36 d7 ff ff       	call   80104227 <cpuid>
80106af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106af4:	8b 45 08             	mov    0x8(%ebp),%eax
80106af7:	8b 70 34             	mov    0x34(%eax),%esi
80106afa:	8b 45 08             	mov    0x8(%ebp),%eax
80106afd:	8b 58 30             	mov    0x30(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106b00:	e8 bb d7 ff ff       	call   801042c0 <myproc>
80106b05:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106b08:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106b0b:	e8 b0 d7 ff ff       	call   801042c0 <myproc>
	    return;	
	    cprintf("DONE?"); 
	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b10:	8b 40 10             	mov    0x10(%eax),%eax
80106b13:	ff 75 e4             	pushl  -0x1c(%ebp)
80106b16:	57                   	push   %edi
80106b17:	ff 75 e0             	pushl  -0x20(%ebp)
80106b1a:	56                   	push   %esi
80106b1b:	53                   	push   %ebx
80106b1c:	ff 75 dc             	pushl  -0x24(%ebp)
80106b1f:	50                   	push   %eax
80106b20:	68 4c 90 10 80       	push   $0x8010904c
80106b25:	e8 d6 98 ff ff       	call   80100400 <cprintf>
80106b2a:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106b2d:	e8 8e d7 ff ff       	call   801042c0 <myproc>
80106b32:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b39:	eb 01                	jmp    80106b3c <trap+0x330>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b3b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b3c:	e8 7f d7 ff ff       	call   801042c0 <myproc>
80106b41:	85 c0                	test   %eax,%eax
80106b43:	74 23                	je     80106b68 <trap+0x35c>
80106b45:	e8 76 d7 ff ff       	call   801042c0 <myproc>
80106b4a:	8b 40 24             	mov    0x24(%eax),%eax
80106b4d:	85 c0                	test   %eax,%eax
80106b4f:	74 17                	je     80106b68 <trap+0x35c>
80106b51:	8b 45 08             	mov    0x8(%ebp),%eax
80106b54:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b58:	0f b7 c0             	movzwl %ax,%eax
80106b5b:	83 e0 03             	and    $0x3,%eax
80106b5e:	83 f8 03             	cmp    $0x3,%eax
80106b61:	75 05                	jne    80106b68 <trap+0x35c>
    exit();
80106b63:	e8 09 dc ff ff       	call   80104771 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b68:	e8 53 d7 ff ff       	call   801042c0 <myproc>
80106b6d:	85 c0                	test   %eax,%eax
80106b6f:	74 1d                	je     80106b8e <trap+0x382>
80106b71:	e8 4a d7 ff ff       	call   801042c0 <myproc>
80106b76:	8b 40 0c             	mov    0xc(%eax),%eax
80106b79:	83 f8 04             	cmp    $0x4,%eax
80106b7c:	75 10                	jne    80106b8e <trap+0x382>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b81:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b84:	83 f8 20             	cmp    $0x20,%eax
80106b87:	75 05                	jne    80106b8e <trap+0x382>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106b89:	e8 9f df ff ff       	call   80104b2d <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b8e:	e8 2d d7 ff ff       	call   801042c0 <myproc>
80106b93:	85 c0                	test   %eax,%eax
80106b95:	74 26                	je     80106bbd <trap+0x3b1>
80106b97:	e8 24 d7 ff ff       	call   801042c0 <myproc>
80106b9c:	8b 40 24             	mov    0x24(%eax),%eax
80106b9f:	85 c0                	test   %eax,%eax
80106ba1:	74 1a                	je     80106bbd <trap+0x3b1>
80106ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106baa:	0f b7 c0             	movzwl %ax,%eax
80106bad:	83 e0 03             	and    $0x3,%eax
80106bb0:	83 f8 03             	cmp    $0x3,%eax
80106bb3:	75 08                	jne    80106bbd <trap+0x3b1>
    exit();
80106bb5:	e8 b7 db ff ff       	call   80104771 <exit>
80106bba:	eb 01                	jmp    80106bbd <trap+0x3b1>
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
80106bbc:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bc0:	5b                   	pop    %ebx
80106bc1:	5e                   	pop    %esi
80106bc2:	5f                   	pop    %edi
80106bc3:	5d                   	pop    %ebp
80106bc4:	c3                   	ret    

80106bc5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bc5:	55                   	push   %ebp
80106bc6:	89 e5                	mov    %esp,%ebp
80106bc8:	83 ec 14             	sub    $0x14,%esp
80106bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bce:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106bd2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106bd6:	89 c2                	mov    %eax,%edx
80106bd8:	ec                   	in     (%dx),%al
80106bd9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106bdc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106be0:	c9                   	leave  
80106be1:	c3                   	ret    

80106be2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106be2:	55                   	push   %ebp
80106be3:	89 e5                	mov    %esp,%ebp
80106be5:	83 ec 08             	sub    $0x8,%esp
80106be8:	8b 55 08             	mov    0x8(%ebp),%edx
80106beb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bee:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106bf2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106bf5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106bf9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106bfd:	ee                   	out    %al,(%dx)
}
80106bfe:	90                   	nop
80106bff:	c9                   	leave  
80106c00:	c3                   	ret    

80106c01 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c01:	55                   	push   %ebp
80106c02:	89 e5                	mov    %esp,%ebp
80106c04:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c07:	6a 00                	push   $0x0
80106c09:	68 fa 03 00 00       	push   $0x3fa
80106c0e:	e8 cf ff ff ff       	call   80106be2 <outb>
80106c13:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c16:	68 80 00 00 00       	push   $0x80
80106c1b:	68 fb 03 00 00       	push   $0x3fb
80106c20:	e8 bd ff ff ff       	call   80106be2 <outb>
80106c25:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106c28:	6a 0c                	push   $0xc
80106c2a:	68 f8 03 00 00       	push   $0x3f8
80106c2f:	e8 ae ff ff ff       	call   80106be2 <outb>
80106c34:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106c37:	6a 00                	push   $0x0
80106c39:	68 f9 03 00 00       	push   $0x3f9
80106c3e:	e8 9f ff ff ff       	call   80106be2 <outb>
80106c43:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c46:	6a 03                	push   $0x3
80106c48:	68 fb 03 00 00       	push   $0x3fb
80106c4d:	e8 90 ff ff ff       	call   80106be2 <outb>
80106c52:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106c55:	6a 00                	push   $0x0
80106c57:	68 fc 03 00 00       	push   $0x3fc
80106c5c:	e8 81 ff ff ff       	call   80106be2 <outb>
80106c61:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c64:	6a 01                	push   $0x1
80106c66:	68 f9 03 00 00       	push   $0x3f9
80106c6b:	e8 72 ff ff ff       	call   80106be2 <outb>
80106c70:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c73:	68 fd 03 00 00       	push   $0x3fd
80106c78:	e8 48 ff ff ff       	call   80106bc5 <inb>
80106c7d:	83 c4 04             	add    $0x4,%esp
80106c80:	3c ff                	cmp    $0xff,%al
80106c82:	74 61                	je     80106ce5 <uartinit+0xe4>
    return;
  uart = 1;
80106c84:	c7 05 24 c6 10 80 01 	movl   $0x1,0x8010c624
80106c8b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c8e:	68 fa 03 00 00       	push   $0x3fa
80106c93:	e8 2d ff ff ff       	call   80106bc5 <inb>
80106c98:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c9b:	68 f8 03 00 00       	push   $0x3f8
80106ca0:	e8 20 ff ff ff       	call   80106bc5 <inb>
80106ca5:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106ca8:	83 ec 08             	sub    $0x8,%esp
80106cab:	6a 00                	push   $0x0
80106cad:	6a 04                	push   $0x4
80106caf:	e8 a3 be ff ff       	call   80102b57 <ioapicenable>
80106cb4:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cb7:	c7 45 f4 10 91 10 80 	movl   $0x80109110,-0xc(%ebp)
80106cbe:	eb 19                	jmp    80106cd9 <uartinit+0xd8>
    uartputc(*p);
80106cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cc3:	0f b6 00             	movzbl (%eax),%eax
80106cc6:	0f be c0             	movsbl %al,%eax
80106cc9:	83 ec 0c             	sub    $0xc,%esp
80106ccc:	50                   	push   %eax
80106ccd:	e8 16 00 00 00       	call   80106ce8 <uartputc>
80106cd2:	83 c4 10             	add    $0x10,%esp
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cd5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cdc:	0f b6 00             	movzbl (%eax),%eax
80106cdf:	84 c0                	test   %al,%al
80106ce1:	75 dd                	jne    80106cc0 <uartinit+0xbf>
80106ce3:	eb 01                	jmp    80106ce6 <uartinit+0xe5>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106ce5:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106ce6:	c9                   	leave  
80106ce7:	c3                   	ret    

80106ce8 <uartputc>:

void
uartputc(int c)
{
80106ce8:	55                   	push   %ebp
80106ce9:	89 e5                	mov    %esp,%ebp
80106ceb:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106cee:	a1 24 c6 10 80       	mov    0x8010c624,%eax
80106cf3:	85 c0                	test   %eax,%eax
80106cf5:	74 53                	je     80106d4a <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cf7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106cfe:	eb 11                	jmp    80106d11 <uartputc+0x29>
    microdelay(10);
80106d00:	83 ec 0c             	sub    $0xc,%esp
80106d03:	6a 0a                	push   $0xa
80106d05:	e8 51 c3 ff ff       	call   8010305b <microdelay>
80106d0a:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d11:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d15:	7f 1a                	jg     80106d31 <uartputc+0x49>
80106d17:	83 ec 0c             	sub    $0xc,%esp
80106d1a:	68 fd 03 00 00       	push   $0x3fd
80106d1f:	e8 a1 fe ff ff       	call   80106bc5 <inb>
80106d24:	83 c4 10             	add    $0x10,%esp
80106d27:	0f b6 c0             	movzbl %al,%eax
80106d2a:	83 e0 20             	and    $0x20,%eax
80106d2d:	85 c0                	test   %eax,%eax
80106d2f:	74 cf                	je     80106d00 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106d31:	8b 45 08             	mov    0x8(%ebp),%eax
80106d34:	0f b6 c0             	movzbl %al,%eax
80106d37:	83 ec 08             	sub    $0x8,%esp
80106d3a:	50                   	push   %eax
80106d3b:	68 f8 03 00 00       	push   $0x3f8
80106d40:	e8 9d fe ff ff       	call   80106be2 <outb>
80106d45:	83 c4 10             	add    $0x10,%esp
80106d48:	eb 01                	jmp    80106d4b <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106d4a:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106d4b:	c9                   	leave  
80106d4c:	c3                   	ret    

80106d4d <uartgetc>:

static int
uartgetc(void)
{
80106d4d:	55                   	push   %ebp
80106d4e:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106d50:	a1 24 c6 10 80       	mov    0x8010c624,%eax
80106d55:	85 c0                	test   %eax,%eax
80106d57:	75 07                	jne    80106d60 <uartgetc+0x13>
    return -1;
80106d59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d5e:	eb 2e                	jmp    80106d8e <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106d60:	68 fd 03 00 00       	push   $0x3fd
80106d65:	e8 5b fe ff ff       	call   80106bc5 <inb>
80106d6a:	83 c4 04             	add    $0x4,%esp
80106d6d:	0f b6 c0             	movzbl %al,%eax
80106d70:	83 e0 01             	and    $0x1,%eax
80106d73:	85 c0                	test   %eax,%eax
80106d75:	75 07                	jne    80106d7e <uartgetc+0x31>
    return -1;
80106d77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d7c:	eb 10                	jmp    80106d8e <uartgetc+0x41>
  return inb(COM1+0);
80106d7e:	68 f8 03 00 00       	push   $0x3f8
80106d83:	e8 3d fe ff ff       	call   80106bc5 <inb>
80106d88:	83 c4 04             	add    $0x4,%esp
80106d8b:	0f b6 c0             	movzbl %al,%eax
}
80106d8e:	c9                   	leave  
80106d8f:	c3                   	ret    

80106d90 <uartintr>:

void
uartintr(void)
{
80106d90:	55                   	push   %ebp
80106d91:	89 e5                	mov    %esp,%ebp
80106d93:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d96:	83 ec 0c             	sub    $0xc,%esp
80106d99:	68 4d 6d 10 80       	push   $0x80106d4d
80106d9e:	e8 89 9a ff ff       	call   8010082c <consoleintr>
80106da3:	83 c4 10             	add    $0x10,%esp
}
80106da6:	90                   	nop
80106da7:	c9                   	leave  
80106da8:	c3                   	ret    

80106da9 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $0
80106dab:	6a 00                	push   $0x0
  jmp alltraps
80106dad:	e9 6e f8 ff ff       	jmp    80106620 <alltraps>

80106db2 <vector1>:
.globl vector1
vector1:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $1
80106db4:	6a 01                	push   $0x1
  jmp alltraps
80106db6:	e9 65 f8 ff ff       	jmp    80106620 <alltraps>

80106dbb <vector2>:
.globl vector2
vector2:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $2
80106dbd:	6a 02                	push   $0x2
  jmp alltraps
80106dbf:	e9 5c f8 ff ff       	jmp    80106620 <alltraps>

80106dc4 <vector3>:
.globl vector3
vector3:
  pushl $0
80106dc4:	6a 00                	push   $0x0
  pushl $3
80106dc6:	6a 03                	push   $0x3
  jmp alltraps
80106dc8:	e9 53 f8 ff ff       	jmp    80106620 <alltraps>

80106dcd <vector4>:
.globl vector4
vector4:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $4
80106dcf:	6a 04                	push   $0x4
  jmp alltraps
80106dd1:	e9 4a f8 ff ff       	jmp    80106620 <alltraps>

80106dd6 <vector5>:
.globl vector5
vector5:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $5
80106dd8:	6a 05                	push   $0x5
  jmp alltraps
80106dda:	e9 41 f8 ff ff       	jmp    80106620 <alltraps>

80106ddf <vector6>:
.globl vector6
vector6:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $6
80106de1:	6a 06                	push   $0x6
  jmp alltraps
80106de3:	e9 38 f8 ff ff       	jmp    80106620 <alltraps>

80106de8 <vector7>:
.globl vector7
vector7:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $7
80106dea:	6a 07                	push   $0x7
  jmp alltraps
80106dec:	e9 2f f8 ff ff       	jmp    80106620 <alltraps>

80106df1 <vector8>:
.globl vector8
vector8:
  pushl $8
80106df1:	6a 08                	push   $0x8
  jmp alltraps
80106df3:	e9 28 f8 ff ff       	jmp    80106620 <alltraps>

80106df8 <vector9>:
.globl vector9
vector9:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $9
80106dfa:	6a 09                	push   $0x9
  jmp alltraps
80106dfc:	e9 1f f8 ff ff       	jmp    80106620 <alltraps>

80106e01 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e01:	6a 0a                	push   $0xa
  jmp alltraps
80106e03:	e9 18 f8 ff ff       	jmp    80106620 <alltraps>

80106e08 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e08:	6a 0b                	push   $0xb
  jmp alltraps
80106e0a:	e9 11 f8 ff ff       	jmp    80106620 <alltraps>

80106e0f <vector12>:
.globl vector12
vector12:
  pushl $12
80106e0f:	6a 0c                	push   $0xc
  jmp alltraps
80106e11:	e9 0a f8 ff ff       	jmp    80106620 <alltraps>

80106e16 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e16:	6a 0d                	push   $0xd
  jmp alltraps
80106e18:	e9 03 f8 ff ff       	jmp    80106620 <alltraps>

80106e1d <vector14>:
.globl vector14
vector14:
  pushl $14
80106e1d:	6a 0e                	push   $0xe
  jmp alltraps
80106e1f:	e9 fc f7 ff ff       	jmp    80106620 <alltraps>

80106e24 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $15
80106e26:	6a 0f                	push   $0xf
  jmp alltraps
80106e28:	e9 f3 f7 ff ff       	jmp    80106620 <alltraps>

80106e2d <vector16>:
.globl vector16
vector16:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $16
80106e2f:	6a 10                	push   $0x10
  jmp alltraps
80106e31:	e9 ea f7 ff ff       	jmp    80106620 <alltraps>

80106e36 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e36:	6a 11                	push   $0x11
  jmp alltraps
80106e38:	e9 e3 f7 ff ff       	jmp    80106620 <alltraps>

80106e3d <vector18>:
.globl vector18
vector18:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $18
80106e3f:	6a 12                	push   $0x12
  jmp alltraps
80106e41:	e9 da f7 ff ff       	jmp    80106620 <alltraps>

80106e46 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $19
80106e48:	6a 13                	push   $0x13
  jmp alltraps
80106e4a:	e9 d1 f7 ff ff       	jmp    80106620 <alltraps>

80106e4f <vector20>:
.globl vector20
vector20:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $20
80106e51:	6a 14                	push   $0x14
  jmp alltraps
80106e53:	e9 c8 f7 ff ff       	jmp    80106620 <alltraps>

80106e58 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $21
80106e5a:	6a 15                	push   $0x15
  jmp alltraps
80106e5c:	e9 bf f7 ff ff       	jmp    80106620 <alltraps>

80106e61 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $22
80106e63:	6a 16                	push   $0x16
  jmp alltraps
80106e65:	e9 b6 f7 ff ff       	jmp    80106620 <alltraps>

80106e6a <vector23>:
.globl vector23
vector23:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $23
80106e6c:	6a 17                	push   $0x17
  jmp alltraps
80106e6e:	e9 ad f7 ff ff       	jmp    80106620 <alltraps>

80106e73 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $24
80106e75:	6a 18                	push   $0x18
  jmp alltraps
80106e77:	e9 a4 f7 ff ff       	jmp    80106620 <alltraps>

80106e7c <vector25>:
.globl vector25
vector25:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $25
80106e7e:	6a 19                	push   $0x19
  jmp alltraps
80106e80:	e9 9b f7 ff ff       	jmp    80106620 <alltraps>

80106e85 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $26
80106e87:	6a 1a                	push   $0x1a
  jmp alltraps
80106e89:	e9 92 f7 ff ff       	jmp    80106620 <alltraps>

80106e8e <vector27>:
.globl vector27
vector27:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $27
80106e90:	6a 1b                	push   $0x1b
  jmp alltraps
80106e92:	e9 89 f7 ff ff       	jmp    80106620 <alltraps>

80106e97 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $28
80106e99:	6a 1c                	push   $0x1c
  jmp alltraps
80106e9b:	e9 80 f7 ff ff       	jmp    80106620 <alltraps>

80106ea0 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $29
80106ea2:	6a 1d                	push   $0x1d
  jmp alltraps
80106ea4:	e9 77 f7 ff ff       	jmp    80106620 <alltraps>

80106ea9 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $30
80106eab:	6a 1e                	push   $0x1e
  jmp alltraps
80106ead:	e9 6e f7 ff ff       	jmp    80106620 <alltraps>

80106eb2 <vector31>:
.globl vector31
vector31:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $31
80106eb4:	6a 1f                	push   $0x1f
  jmp alltraps
80106eb6:	e9 65 f7 ff ff       	jmp    80106620 <alltraps>

80106ebb <vector32>:
.globl vector32
vector32:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $32
80106ebd:	6a 20                	push   $0x20
  jmp alltraps
80106ebf:	e9 5c f7 ff ff       	jmp    80106620 <alltraps>

80106ec4 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $33
80106ec6:	6a 21                	push   $0x21
  jmp alltraps
80106ec8:	e9 53 f7 ff ff       	jmp    80106620 <alltraps>

80106ecd <vector34>:
.globl vector34
vector34:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $34
80106ecf:	6a 22                	push   $0x22
  jmp alltraps
80106ed1:	e9 4a f7 ff ff       	jmp    80106620 <alltraps>

80106ed6 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $35
80106ed8:	6a 23                	push   $0x23
  jmp alltraps
80106eda:	e9 41 f7 ff ff       	jmp    80106620 <alltraps>

80106edf <vector36>:
.globl vector36
vector36:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $36
80106ee1:	6a 24                	push   $0x24
  jmp alltraps
80106ee3:	e9 38 f7 ff ff       	jmp    80106620 <alltraps>

80106ee8 <vector37>:
.globl vector37
vector37:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $37
80106eea:	6a 25                	push   $0x25
  jmp alltraps
80106eec:	e9 2f f7 ff ff       	jmp    80106620 <alltraps>

80106ef1 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $38
80106ef3:	6a 26                	push   $0x26
  jmp alltraps
80106ef5:	e9 26 f7 ff ff       	jmp    80106620 <alltraps>

80106efa <vector39>:
.globl vector39
vector39:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $39
80106efc:	6a 27                	push   $0x27
  jmp alltraps
80106efe:	e9 1d f7 ff ff       	jmp    80106620 <alltraps>

80106f03 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $40
80106f05:	6a 28                	push   $0x28
  jmp alltraps
80106f07:	e9 14 f7 ff ff       	jmp    80106620 <alltraps>

80106f0c <vector41>:
.globl vector41
vector41:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $41
80106f0e:	6a 29                	push   $0x29
  jmp alltraps
80106f10:	e9 0b f7 ff ff       	jmp    80106620 <alltraps>

80106f15 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $42
80106f17:	6a 2a                	push   $0x2a
  jmp alltraps
80106f19:	e9 02 f7 ff ff       	jmp    80106620 <alltraps>

80106f1e <vector43>:
.globl vector43
vector43:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $43
80106f20:	6a 2b                	push   $0x2b
  jmp alltraps
80106f22:	e9 f9 f6 ff ff       	jmp    80106620 <alltraps>

80106f27 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $44
80106f29:	6a 2c                	push   $0x2c
  jmp alltraps
80106f2b:	e9 f0 f6 ff ff       	jmp    80106620 <alltraps>

80106f30 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $45
80106f32:	6a 2d                	push   $0x2d
  jmp alltraps
80106f34:	e9 e7 f6 ff ff       	jmp    80106620 <alltraps>

80106f39 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $46
80106f3b:	6a 2e                	push   $0x2e
  jmp alltraps
80106f3d:	e9 de f6 ff ff       	jmp    80106620 <alltraps>

80106f42 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $47
80106f44:	6a 2f                	push   $0x2f
  jmp alltraps
80106f46:	e9 d5 f6 ff ff       	jmp    80106620 <alltraps>

80106f4b <vector48>:
.globl vector48
vector48:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $48
80106f4d:	6a 30                	push   $0x30
  jmp alltraps
80106f4f:	e9 cc f6 ff ff       	jmp    80106620 <alltraps>

80106f54 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $49
80106f56:	6a 31                	push   $0x31
  jmp alltraps
80106f58:	e9 c3 f6 ff ff       	jmp    80106620 <alltraps>

80106f5d <vector50>:
.globl vector50
vector50:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $50
80106f5f:	6a 32                	push   $0x32
  jmp alltraps
80106f61:	e9 ba f6 ff ff       	jmp    80106620 <alltraps>

80106f66 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $51
80106f68:	6a 33                	push   $0x33
  jmp alltraps
80106f6a:	e9 b1 f6 ff ff       	jmp    80106620 <alltraps>

80106f6f <vector52>:
.globl vector52
vector52:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $52
80106f71:	6a 34                	push   $0x34
  jmp alltraps
80106f73:	e9 a8 f6 ff ff       	jmp    80106620 <alltraps>

80106f78 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $53
80106f7a:	6a 35                	push   $0x35
  jmp alltraps
80106f7c:	e9 9f f6 ff ff       	jmp    80106620 <alltraps>

80106f81 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $54
80106f83:	6a 36                	push   $0x36
  jmp alltraps
80106f85:	e9 96 f6 ff ff       	jmp    80106620 <alltraps>

80106f8a <vector55>:
.globl vector55
vector55:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $55
80106f8c:	6a 37                	push   $0x37
  jmp alltraps
80106f8e:	e9 8d f6 ff ff       	jmp    80106620 <alltraps>

80106f93 <vector56>:
.globl vector56
vector56:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $56
80106f95:	6a 38                	push   $0x38
  jmp alltraps
80106f97:	e9 84 f6 ff ff       	jmp    80106620 <alltraps>

80106f9c <vector57>:
.globl vector57
vector57:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $57
80106f9e:	6a 39                	push   $0x39
  jmp alltraps
80106fa0:	e9 7b f6 ff ff       	jmp    80106620 <alltraps>

80106fa5 <vector58>:
.globl vector58
vector58:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $58
80106fa7:	6a 3a                	push   $0x3a
  jmp alltraps
80106fa9:	e9 72 f6 ff ff       	jmp    80106620 <alltraps>

80106fae <vector59>:
.globl vector59
vector59:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $59
80106fb0:	6a 3b                	push   $0x3b
  jmp alltraps
80106fb2:	e9 69 f6 ff ff       	jmp    80106620 <alltraps>

80106fb7 <vector60>:
.globl vector60
vector60:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $60
80106fb9:	6a 3c                	push   $0x3c
  jmp alltraps
80106fbb:	e9 60 f6 ff ff       	jmp    80106620 <alltraps>

80106fc0 <vector61>:
.globl vector61
vector61:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $61
80106fc2:	6a 3d                	push   $0x3d
  jmp alltraps
80106fc4:	e9 57 f6 ff ff       	jmp    80106620 <alltraps>

80106fc9 <vector62>:
.globl vector62
vector62:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $62
80106fcb:	6a 3e                	push   $0x3e
  jmp alltraps
80106fcd:	e9 4e f6 ff ff       	jmp    80106620 <alltraps>

80106fd2 <vector63>:
.globl vector63
vector63:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $63
80106fd4:	6a 3f                	push   $0x3f
  jmp alltraps
80106fd6:	e9 45 f6 ff ff       	jmp    80106620 <alltraps>

80106fdb <vector64>:
.globl vector64
vector64:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $64
80106fdd:	6a 40                	push   $0x40
  jmp alltraps
80106fdf:	e9 3c f6 ff ff       	jmp    80106620 <alltraps>

80106fe4 <vector65>:
.globl vector65
vector65:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $65
80106fe6:	6a 41                	push   $0x41
  jmp alltraps
80106fe8:	e9 33 f6 ff ff       	jmp    80106620 <alltraps>

80106fed <vector66>:
.globl vector66
vector66:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $66
80106fef:	6a 42                	push   $0x42
  jmp alltraps
80106ff1:	e9 2a f6 ff ff       	jmp    80106620 <alltraps>

80106ff6 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $67
80106ff8:	6a 43                	push   $0x43
  jmp alltraps
80106ffa:	e9 21 f6 ff ff       	jmp    80106620 <alltraps>

80106fff <vector68>:
.globl vector68
vector68:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $68
80107001:	6a 44                	push   $0x44
  jmp alltraps
80107003:	e9 18 f6 ff ff       	jmp    80106620 <alltraps>

80107008 <vector69>:
.globl vector69
vector69:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $69
8010700a:	6a 45                	push   $0x45
  jmp alltraps
8010700c:	e9 0f f6 ff ff       	jmp    80106620 <alltraps>

80107011 <vector70>:
.globl vector70
vector70:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $70
80107013:	6a 46                	push   $0x46
  jmp alltraps
80107015:	e9 06 f6 ff ff       	jmp    80106620 <alltraps>

8010701a <vector71>:
.globl vector71
vector71:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $71
8010701c:	6a 47                	push   $0x47
  jmp alltraps
8010701e:	e9 fd f5 ff ff       	jmp    80106620 <alltraps>

80107023 <vector72>:
.globl vector72
vector72:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $72
80107025:	6a 48                	push   $0x48
  jmp alltraps
80107027:	e9 f4 f5 ff ff       	jmp    80106620 <alltraps>

8010702c <vector73>:
.globl vector73
vector73:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $73
8010702e:	6a 49                	push   $0x49
  jmp alltraps
80107030:	e9 eb f5 ff ff       	jmp    80106620 <alltraps>

80107035 <vector74>:
.globl vector74
vector74:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $74
80107037:	6a 4a                	push   $0x4a
  jmp alltraps
80107039:	e9 e2 f5 ff ff       	jmp    80106620 <alltraps>

8010703e <vector75>:
.globl vector75
vector75:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $75
80107040:	6a 4b                	push   $0x4b
  jmp alltraps
80107042:	e9 d9 f5 ff ff       	jmp    80106620 <alltraps>

80107047 <vector76>:
.globl vector76
vector76:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $76
80107049:	6a 4c                	push   $0x4c
  jmp alltraps
8010704b:	e9 d0 f5 ff ff       	jmp    80106620 <alltraps>

80107050 <vector77>:
.globl vector77
vector77:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $77
80107052:	6a 4d                	push   $0x4d
  jmp alltraps
80107054:	e9 c7 f5 ff ff       	jmp    80106620 <alltraps>

80107059 <vector78>:
.globl vector78
vector78:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $78
8010705b:	6a 4e                	push   $0x4e
  jmp alltraps
8010705d:	e9 be f5 ff ff       	jmp    80106620 <alltraps>

80107062 <vector79>:
.globl vector79
vector79:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $79
80107064:	6a 4f                	push   $0x4f
  jmp alltraps
80107066:	e9 b5 f5 ff ff       	jmp    80106620 <alltraps>

8010706b <vector80>:
.globl vector80
vector80:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $80
8010706d:	6a 50                	push   $0x50
  jmp alltraps
8010706f:	e9 ac f5 ff ff       	jmp    80106620 <alltraps>

80107074 <vector81>:
.globl vector81
vector81:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $81
80107076:	6a 51                	push   $0x51
  jmp alltraps
80107078:	e9 a3 f5 ff ff       	jmp    80106620 <alltraps>

8010707d <vector82>:
.globl vector82
vector82:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $82
8010707f:	6a 52                	push   $0x52
  jmp alltraps
80107081:	e9 9a f5 ff ff       	jmp    80106620 <alltraps>

80107086 <vector83>:
.globl vector83
vector83:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $83
80107088:	6a 53                	push   $0x53
  jmp alltraps
8010708a:	e9 91 f5 ff ff       	jmp    80106620 <alltraps>

8010708f <vector84>:
.globl vector84
vector84:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $84
80107091:	6a 54                	push   $0x54
  jmp alltraps
80107093:	e9 88 f5 ff ff       	jmp    80106620 <alltraps>

80107098 <vector85>:
.globl vector85
vector85:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $85
8010709a:	6a 55                	push   $0x55
  jmp alltraps
8010709c:	e9 7f f5 ff ff       	jmp    80106620 <alltraps>

801070a1 <vector86>:
.globl vector86
vector86:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $86
801070a3:	6a 56                	push   $0x56
  jmp alltraps
801070a5:	e9 76 f5 ff ff       	jmp    80106620 <alltraps>

801070aa <vector87>:
.globl vector87
vector87:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $87
801070ac:	6a 57                	push   $0x57
  jmp alltraps
801070ae:	e9 6d f5 ff ff       	jmp    80106620 <alltraps>

801070b3 <vector88>:
.globl vector88
vector88:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $88
801070b5:	6a 58                	push   $0x58
  jmp alltraps
801070b7:	e9 64 f5 ff ff       	jmp    80106620 <alltraps>

801070bc <vector89>:
.globl vector89
vector89:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $89
801070be:	6a 59                	push   $0x59
  jmp alltraps
801070c0:	e9 5b f5 ff ff       	jmp    80106620 <alltraps>

801070c5 <vector90>:
.globl vector90
vector90:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $90
801070c7:	6a 5a                	push   $0x5a
  jmp alltraps
801070c9:	e9 52 f5 ff ff       	jmp    80106620 <alltraps>

801070ce <vector91>:
.globl vector91
vector91:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $91
801070d0:	6a 5b                	push   $0x5b
  jmp alltraps
801070d2:	e9 49 f5 ff ff       	jmp    80106620 <alltraps>

801070d7 <vector92>:
.globl vector92
vector92:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $92
801070d9:	6a 5c                	push   $0x5c
  jmp alltraps
801070db:	e9 40 f5 ff ff       	jmp    80106620 <alltraps>

801070e0 <vector93>:
.globl vector93
vector93:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $93
801070e2:	6a 5d                	push   $0x5d
  jmp alltraps
801070e4:	e9 37 f5 ff ff       	jmp    80106620 <alltraps>

801070e9 <vector94>:
.globl vector94
vector94:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $94
801070eb:	6a 5e                	push   $0x5e
  jmp alltraps
801070ed:	e9 2e f5 ff ff       	jmp    80106620 <alltraps>

801070f2 <vector95>:
.globl vector95
vector95:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $95
801070f4:	6a 5f                	push   $0x5f
  jmp alltraps
801070f6:	e9 25 f5 ff ff       	jmp    80106620 <alltraps>

801070fb <vector96>:
.globl vector96
vector96:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $96
801070fd:	6a 60                	push   $0x60
  jmp alltraps
801070ff:	e9 1c f5 ff ff       	jmp    80106620 <alltraps>

80107104 <vector97>:
.globl vector97
vector97:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $97
80107106:	6a 61                	push   $0x61
  jmp alltraps
80107108:	e9 13 f5 ff ff       	jmp    80106620 <alltraps>

8010710d <vector98>:
.globl vector98
vector98:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $98
8010710f:	6a 62                	push   $0x62
  jmp alltraps
80107111:	e9 0a f5 ff ff       	jmp    80106620 <alltraps>

80107116 <vector99>:
.globl vector99
vector99:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $99
80107118:	6a 63                	push   $0x63
  jmp alltraps
8010711a:	e9 01 f5 ff ff       	jmp    80106620 <alltraps>

8010711f <vector100>:
.globl vector100
vector100:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $100
80107121:	6a 64                	push   $0x64
  jmp alltraps
80107123:	e9 f8 f4 ff ff       	jmp    80106620 <alltraps>

80107128 <vector101>:
.globl vector101
vector101:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $101
8010712a:	6a 65                	push   $0x65
  jmp alltraps
8010712c:	e9 ef f4 ff ff       	jmp    80106620 <alltraps>

80107131 <vector102>:
.globl vector102
vector102:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $102
80107133:	6a 66                	push   $0x66
  jmp alltraps
80107135:	e9 e6 f4 ff ff       	jmp    80106620 <alltraps>

8010713a <vector103>:
.globl vector103
vector103:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $103
8010713c:	6a 67                	push   $0x67
  jmp alltraps
8010713e:	e9 dd f4 ff ff       	jmp    80106620 <alltraps>

80107143 <vector104>:
.globl vector104
vector104:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $104
80107145:	6a 68                	push   $0x68
  jmp alltraps
80107147:	e9 d4 f4 ff ff       	jmp    80106620 <alltraps>

8010714c <vector105>:
.globl vector105
vector105:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $105
8010714e:	6a 69                	push   $0x69
  jmp alltraps
80107150:	e9 cb f4 ff ff       	jmp    80106620 <alltraps>

80107155 <vector106>:
.globl vector106
vector106:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $106
80107157:	6a 6a                	push   $0x6a
  jmp alltraps
80107159:	e9 c2 f4 ff ff       	jmp    80106620 <alltraps>

8010715e <vector107>:
.globl vector107
vector107:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $107
80107160:	6a 6b                	push   $0x6b
  jmp alltraps
80107162:	e9 b9 f4 ff ff       	jmp    80106620 <alltraps>

80107167 <vector108>:
.globl vector108
vector108:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $108
80107169:	6a 6c                	push   $0x6c
  jmp alltraps
8010716b:	e9 b0 f4 ff ff       	jmp    80106620 <alltraps>

80107170 <vector109>:
.globl vector109
vector109:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $109
80107172:	6a 6d                	push   $0x6d
  jmp alltraps
80107174:	e9 a7 f4 ff ff       	jmp    80106620 <alltraps>

80107179 <vector110>:
.globl vector110
vector110:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $110
8010717b:	6a 6e                	push   $0x6e
  jmp alltraps
8010717d:	e9 9e f4 ff ff       	jmp    80106620 <alltraps>

80107182 <vector111>:
.globl vector111
vector111:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $111
80107184:	6a 6f                	push   $0x6f
  jmp alltraps
80107186:	e9 95 f4 ff ff       	jmp    80106620 <alltraps>

8010718b <vector112>:
.globl vector112
vector112:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $112
8010718d:	6a 70                	push   $0x70
  jmp alltraps
8010718f:	e9 8c f4 ff ff       	jmp    80106620 <alltraps>

80107194 <vector113>:
.globl vector113
vector113:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $113
80107196:	6a 71                	push   $0x71
  jmp alltraps
80107198:	e9 83 f4 ff ff       	jmp    80106620 <alltraps>

8010719d <vector114>:
.globl vector114
vector114:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $114
8010719f:	6a 72                	push   $0x72
  jmp alltraps
801071a1:	e9 7a f4 ff ff       	jmp    80106620 <alltraps>

801071a6 <vector115>:
.globl vector115
vector115:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $115
801071a8:	6a 73                	push   $0x73
  jmp alltraps
801071aa:	e9 71 f4 ff ff       	jmp    80106620 <alltraps>

801071af <vector116>:
.globl vector116
vector116:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $116
801071b1:	6a 74                	push   $0x74
  jmp alltraps
801071b3:	e9 68 f4 ff ff       	jmp    80106620 <alltraps>

801071b8 <vector117>:
.globl vector117
vector117:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $117
801071ba:	6a 75                	push   $0x75
  jmp alltraps
801071bc:	e9 5f f4 ff ff       	jmp    80106620 <alltraps>

801071c1 <vector118>:
.globl vector118
vector118:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $118
801071c3:	6a 76                	push   $0x76
  jmp alltraps
801071c5:	e9 56 f4 ff ff       	jmp    80106620 <alltraps>

801071ca <vector119>:
.globl vector119
vector119:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $119
801071cc:	6a 77                	push   $0x77
  jmp alltraps
801071ce:	e9 4d f4 ff ff       	jmp    80106620 <alltraps>

801071d3 <vector120>:
.globl vector120
vector120:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $120
801071d5:	6a 78                	push   $0x78
  jmp alltraps
801071d7:	e9 44 f4 ff ff       	jmp    80106620 <alltraps>

801071dc <vector121>:
.globl vector121
vector121:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $121
801071de:	6a 79                	push   $0x79
  jmp alltraps
801071e0:	e9 3b f4 ff ff       	jmp    80106620 <alltraps>

801071e5 <vector122>:
.globl vector122
vector122:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $122
801071e7:	6a 7a                	push   $0x7a
  jmp alltraps
801071e9:	e9 32 f4 ff ff       	jmp    80106620 <alltraps>

801071ee <vector123>:
.globl vector123
vector123:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $123
801071f0:	6a 7b                	push   $0x7b
  jmp alltraps
801071f2:	e9 29 f4 ff ff       	jmp    80106620 <alltraps>

801071f7 <vector124>:
.globl vector124
vector124:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $124
801071f9:	6a 7c                	push   $0x7c
  jmp alltraps
801071fb:	e9 20 f4 ff ff       	jmp    80106620 <alltraps>

80107200 <vector125>:
.globl vector125
vector125:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $125
80107202:	6a 7d                	push   $0x7d
  jmp alltraps
80107204:	e9 17 f4 ff ff       	jmp    80106620 <alltraps>

80107209 <vector126>:
.globl vector126
vector126:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $126
8010720b:	6a 7e                	push   $0x7e
  jmp alltraps
8010720d:	e9 0e f4 ff ff       	jmp    80106620 <alltraps>

80107212 <vector127>:
.globl vector127
vector127:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $127
80107214:	6a 7f                	push   $0x7f
  jmp alltraps
80107216:	e9 05 f4 ff ff       	jmp    80106620 <alltraps>

8010721b <vector128>:
.globl vector128
vector128:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $128
8010721d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107222:	e9 f9 f3 ff ff       	jmp    80106620 <alltraps>

80107227 <vector129>:
.globl vector129
vector129:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $129
80107229:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010722e:	e9 ed f3 ff ff       	jmp    80106620 <alltraps>

80107233 <vector130>:
.globl vector130
vector130:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $130
80107235:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010723a:	e9 e1 f3 ff ff       	jmp    80106620 <alltraps>

8010723f <vector131>:
.globl vector131
vector131:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $131
80107241:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107246:	e9 d5 f3 ff ff       	jmp    80106620 <alltraps>

8010724b <vector132>:
.globl vector132
vector132:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $132
8010724d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107252:	e9 c9 f3 ff ff       	jmp    80106620 <alltraps>

80107257 <vector133>:
.globl vector133
vector133:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $133
80107259:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010725e:	e9 bd f3 ff ff       	jmp    80106620 <alltraps>

80107263 <vector134>:
.globl vector134
vector134:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $134
80107265:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010726a:	e9 b1 f3 ff ff       	jmp    80106620 <alltraps>

8010726f <vector135>:
.globl vector135
vector135:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $135
80107271:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107276:	e9 a5 f3 ff ff       	jmp    80106620 <alltraps>

8010727b <vector136>:
.globl vector136
vector136:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $136
8010727d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107282:	e9 99 f3 ff ff       	jmp    80106620 <alltraps>

80107287 <vector137>:
.globl vector137
vector137:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $137
80107289:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010728e:	e9 8d f3 ff ff       	jmp    80106620 <alltraps>

80107293 <vector138>:
.globl vector138
vector138:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $138
80107295:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010729a:	e9 81 f3 ff ff       	jmp    80106620 <alltraps>

8010729f <vector139>:
.globl vector139
vector139:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $139
801072a1:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072a6:	e9 75 f3 ff ff       	jmp    80106620 <alltraps>

801072ab <vector140>:
.globl vector140
vector140:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $140
801072ad:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801072b2:	e9 69 f3 ff ff       	jmp    80106620 <alltraps>

801072b7 <vector141>:
.globl vector141
vector141:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $141
801072b9:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801072be:	e9 5d f3 ff ff       	jmp    80106620 <alltraps>

801072c3 <vector142>:
.globl vector142
vector142:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $142
801072c5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801072ca:	e9 51 f3 ff ff       	jmp    80106620 <alltraps>

801072cf <vector143>:
.globl vector143
vector143:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $143
801072d1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801072d6:	e9 45 f3 ff ff       	jmp    80106620 <alltraps>

801072db <vector144>:
.globl vector144
vector144:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $144
801072dd:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801072e2:	e9 39 f3 ff ff       	jmp    80106620 <alltraps>

801072e7 <vector145>:
.globl vector145
vector145:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $145
801072e9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801072ee:	e9 2d f3 ff ff       	jmp    80106620 <alltraps>

801072f3 <vector146>:
.globl vector146
vector146:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $146
801072f5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072fa:	e9 21 f3 ff ff       	jmp    80106620 <alltraps>

801072ff <vector147>:
.globl vector147
vector147:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $147
80107301:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107306:	e9 15 f3 ff ff       	jmp    80106620 <alltraps>

8010730b <vector148>:
.globl vector148
vector148:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $148
8010730d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107312:	e9 09 f3 ff ff       	jmp    80106620 <alltraps>

80107317 <vector149>:
.globl vector149
vector149:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $149
80107319:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010731e:	e9 fd f2 ff ff       	jmp    80106620 <alltraps>

80107323 <vector150>:
.globl vector150
vector150:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $150
80107325:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010732a:	e9 f1 f2 ff ff       	jmp    80106620 <alltraps>

8010732f <vector151>:
.globl vector151
vector151:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $151
80107331:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107336:	e9 e5 f2 ff ff       	jmp    80106620 <alltraps>

8010733b <vector152>:
.globl vector152
vector152:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $152
8010733d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107342:	e9 d9 f2 ff ff       	jmp    80106620 <alltraps>

80107347 <vector153>:
.globl vector153
vector153:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $153
80107349:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010734e:	e9 cd f2 ff ff       	jmp    80106620 <alltraps>

80107353 <vector154>:
.globl vector154
vector154:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $154
80107355:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010735a:	e9 c1 f2 ff ff       	jmp    80106620 <alltraps>

8010735f <vector155>:
.globl vector155
vector155:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $155
80107361:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107366:	e9 b5 f2 ff ff       	jmp    80106620 <alltraps>

8010736b <vector156>:
.globl vector156
vector156:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $156
8010736d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107372:	e9 a9 f2 ff ff       	jmp    80106620 <alltraps>

80107377 <vector157>:
.globl vector157
vector157:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $157
80107379:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010737e:	e9 9d f2 ff ff       	jmp    80106620 <alltraps>

80107383 <vector158>:
.globl vector158
vector158:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $158
80107385:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010738a:	e9 91 f2 ff ff       	jmp    80106620 <alltraps>

8010738f <vector159>:
.globl vector159
vector159:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $159
80107391:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107396:	e9 85 f2 ff ff       	jmp    80106620 <alltraps>

8010739b <vector160>:
.globl vector160
vector160:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $160
8010739d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073a2:	e9 79 f2 ff ff       	jmp    80106620 <alltraps>

801073a7 <vector161>:
.globl vector161
vector161:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $161
801073a9:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801073ae:	e9 6d f2 ff ff       	jmp    80106620 <alltraps>

801073b3 <vector162>:
.globl vector162
vector162:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $162
801073b5:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801073ba:	e9 61 f2 ff ff       	jmp    80106620 <alltraps>

801073bf <vector163>:
.globl vector163
vector163:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $163
801073c1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801073c6:	e9 55 f2 ff ff       	jmp    80106620 <alltraps>

801073cb <vector164>:
.globl vector164
vector164:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $164
801073cd:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801073d2:	e9 49 f2 ff ff       	jmp    80106620 <alltraps>

801073d7 <vector165>:
.globl vector165
vector165:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $165
801073d9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801073de:	e9 3d f2 ff ff       	jmp    80106620 <alltraps>

801073e3 <vector166>:
.globl vector166
vector166:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $166
801073e5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801073ea:	e9 31 f2 ff ff       	jmp    80106620 <alltraps>

801073ef <vector167>:
.globl vector167
vector167:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $167
801073f1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073f6:	e9 25 f2 ff ff       	jmp    80106620 <alltraps>

801073fb <vector168>:
.globl vector168
vector168:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $168
801073fd:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107402:	e9 19 f2 ff ff       	jmp    80106620 <alltraps>

80107407 <vector169>:
.globl vector169
vector169:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $169
80107409:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010740e:	e9 0d f2 ff ff       	jmp    80106620 <alltraps>

80107413 <vector170>:
.globl vector170
vector170:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $170
80107415:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010741a:	e9 01 f2 ff ff       	jmp    80106620 <alltraps>

8010741f <vector171>:
.globl vector171
vector171:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $171
80107421:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107426:	e9 f5 f1 ff ff       	jmp    80106620 <alltraps>

8010742b <vector172>:
.globl vector172
vector172:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $172
8010742d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107432:	e9 e9 f1 ff ff       	jmp    80106620 <alltraps>

80107437 <vector173>:
.globl vector173
vector173:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $173
80107439:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010743e:	e9 dd f1 ff ff       	jmp    80106620 <alltraps>

80107443 <vector174>:
.globl vector174
vector174:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $174
80107445:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010744a:	e9 d1 f1 ff ff       	jmp    80106620 <alltraps>

8010744f <vector175>:
.globl vector175
vector175:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $175
80107451:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107456:	e9 c5 f1 ff ff       	jmp    80106620 <alltraps>

8010745b <vector176>:
.globl vector176
vector176:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $176
8010745d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107462:	e9 b9 f1 ff ff       	jmp    80106620 <alltraps>

80107467 <vector177>:
.globl vector177
vector177:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $177
80107469:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010746e:	e9 ad f1 ff ff       	jmp    80106620 <alltraps>

80107473 <vector178>:
.globl vector178
vector178:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $178
80107475:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010747a:	e9 a1 f1 ff ff       	jmp    80106620 <alltraps>

8010747f <vector179>:
.globl vector179
vector179:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $179
80107481:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107486:	e9 95 f1 ff ff       	jmp    80106620 <alltraps>

8010748b <vector180>:
.globl vector180
vector180:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $180
8010748d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107492:	e9 89 f1 ff ff       	jmp    80106620 <alltraps>

80107497 <vector181>:
.globl vector181
vector181:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $181
80107499:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010749e:	e9 7d f1 ff ff       	jmp    80106620 <alltraps>

801074a3 <vector182>:
.globl vector182
vector182:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $182
801074a5:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074aa:	e9 71 f1 ff ff       	jmp    80106620 <alltraps>

801074af <vector183>:
.globl vector183
vector183:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $183
801074b1:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801074b6:	e9 65 f1 ff ff       	jmp    80106620 <alltraps>

801074bb <vector184>:
.globl vector184
vector184:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $184
801074bd:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801074c2:	e9 59 f1 ff ff       	jmp    80106620 <alltraps>

801074c7 <vector185>:
.globl vector185
vector185:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $185
801074c9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801074ce:	e9 4d f1 ff ff       	jmp    80106620 <alltraps>

801074d3 <vector186>:
.globl vector186
vector186:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $186
801074d5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801074da:	e9 41 f1 ff ff       	jmp    80106620 <alltraps>

801074df <vector187>:
.globl vector187
vector187:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $187
801074e1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801074e6:	e9 35 f1 ff ff       	jmp    80106620 <alltraps>

801074eb <vector188>:
.globl vector188
vector188:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $188
801074ed:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801074f2:	e9 29 f1 ff ff       	jmp    80106620 <alltraps>

801074f7 <vector189>:
.globl vector189
vector189:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $189
801074f9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074fe:	e9 1d f1 ff ff       	jmp    80106620 <alltraps>

80107503 <vector190>:
.globl vector190
vector190:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $190
80107505:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010750a:	e9 11 f1 ff ff       	jmp    80106620 <alltraps>

8010750f <vector191>:
.globl vector191
vector191:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $191
80107511:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107516:	e9 05 f1 ff ff       	jmp    80106620 <alltraps>

8010751b <vector192>:
.globl vector192
vector192:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $192
8010751d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107522:	e9 f9 f0 ff ff       	jmp    80106620 <alltraps>

80107527 <vector193>:
.globl vector193
vector193:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $193
80107529:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010752e:	e9 ed f0 ff ff       	jmp    80106620 <alltraps>

80107533 <vector194>:
.globl vector194
vector194:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $194
80107535:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010753a:	e9 e1 f0 ff ff       	jmp    80106620 <alltraps>

8010753f <vector195>:
.globl vector195
vector195:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $195
80107541:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107546:	e9 d5 f0 ff ff       	jmp    80106620 <alltraps>

8010754b <vector196>:
.globl vector196
vector196:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $196
8010754d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107552:	e9 c9 f0 ff ff       	jmp    80106620 <alltraps>

80107557 <vector197>:
.globl vector197
vector197:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $197
80107559:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010755e:	e9 bd f0 ff ff       	jmp    80106620 <alltraps>

80107563 <vector198>:
.globl vector198
vector198:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $198
80107565:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010756a:	e9 b1 f0 ff ff       	jmp    80106620 <alltraps>

8010756f <vector199>:
.globl vector199
vector199:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $199
80107571:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107576:	e9 a5 f0 ff ff       	jmp    80106620 <alltraps>

8010757b <vector200>:
.globl vector200
vector200:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $200
8010757d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107582:	e9 99 f0 ff ff       	jmp    80106620 <alltraps>

80107587 <vector201>:
.globl vector201
vector201:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $201
80107589:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010758e:	e9 8d f0 ff ff       	jmp    80106620 <alltraps>

80107593 <vector202>:
.globl vector202
vector202:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $202
80107595:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010759a:	e9 81 f0 ff ff       	jmp    80106620 <alltraps>

8010759f <vector203>:
.globl vector203
vector203:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $203
801075a1:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075a6:	e9 75 f0 ff ff       	jmp    80106620 <alltraps>

801075ab <vector204>:
.globl vector204
vector204:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $204
801075ad:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801075b2:	e9 69 f0 ff ff       	jmp    80106620 <alltraps>

801075b7 <vector205>:
.globl vector205
vector205:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $205
801075b9:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801075be:	e9 5d f0 ff ff       	jmp    80106620 <alltraps>

801075c3 <vector206>:
.globl vector206
vector206:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $206
801075c5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801075ca:	e9 51 f0 ff ff       	jmp    80106620 <alltraps>

801075cf <vector207>:
.globl vector207
vector207:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $207
801075d1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801075d6:	e9 45 f0 ff ff       	jmp    80106620 <alltraps>

801075db <vector208>:
.globl vector208
vector208:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $208
801075dd:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801075e2:	e9 39 f0 ff ff       	jmp    80106620 <alltraps>

801075e7 <vector209>:
.globl vector209
vector209:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $209
801075e9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801075ee:	e9 2d f0 ff ff       	jmp    80106620 <alltraps>

801075f3 <vector210>:
.globl vector210
vector210:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $210
801075f5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075fa:	e9 21 f0 ff ff       	jmp    80106620 <alltraps>

801075ff <vector211>:
.globl vector211
vector211:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $211
80107601:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107606:	e9 15 f0 ff ff       	jmp    80106620 <alltraps>

8010760b <vector212>:
.globl vector212
vector212:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $212
8010760d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107612:	e9 09 f0 ff ff       	jmp    80106620 <alltraps>

80107617 <vector213>:
.globl vector213
vector213:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $213
80107619:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010761e:	e9 fd ef ff ff       	jmp    80106620 <alltraps>

80107623 <vector214>:
.globl vector214
vector214:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $214
80107625:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010762a:	e9 f1 ef ff ff       	jmp    80106620 <alltraps>

8010762f <vector215>:
.globl vector215
vector215:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $215
80107631:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107636:	e9 e5 ef ff ff       	jmp    80106620 <alltraps>

8010763b <vector216>:
.globl vector216
vector216:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $216
8010763d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107642:	e9 d9 ef ff ff       	jmp    80106620 <alltraps>

80107647 <vector217>:
.globl vector217
vector217:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $217
80107649:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010764e:	e9 cd ef ff ff       	jmp    80106620 <alltraps>

80107653 <vector218>:
.globl vector218
vector218:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $218
80107655:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010765a:	e9 c1 ef ff ff       	jmp    80106620 <alltraps>

8010765f <vector219>:
.globl vector219
vector219:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $219
80107661:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107666:	e9 b5 ef ff ff       	jmp    80106620 <alltraps>

8010766b <vector220>:
.globl vector220
vector220:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $220
8010766d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107672:	e9 a9 ef ff ff       	jmp    80106620 <alltraps>

80107677 <vector221>:
.globl vector221
vector221:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $221
80107679:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010767e:	e9 9d ef ff ff       	jmp    80106620 <alltraps>

80107683 <vector222>:
.globl vector222
vector222:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $222
80107685:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010768a:	e9 91 ef ff ff       	jmp    80106620 <alltraps>

8010768f <vector223>:
.globl vector223
vector223:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $223
80107691:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107696:	e9 85 ef ff ff       	jmp    80106620 <alltraps>

8010769b <vector224>:
.globl vector224
vector224:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $224
8010769d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076a2:	e9 79 ef ff ff       	jmp    80106620 <alltraps>

801076a7 <vector225>:
.globl vector225
vector225:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $225
801076a9:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801076ae:	e9 6d ef ff ff       	jmp    80106620 <alltraps>

801076b3 <vector226>:
.globl vector226
vector226:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $226
801076b5:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801076ba:	e9 61 ef ff ff       	jmp    80106620 <alltraps>

801076bf <vector227>:
.globl vector227
vector227:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $227
801076c1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801076c6:	e9 55 ef ff ff       	jmp    80106620 <alltraps>

801076cb <vector228>:
.globl vector228
vector228:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $228
801076cd:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801076d2:	e9 49 ef ff ff       	jmp    80106620 <alltraps>

801076d7 <vector229>:
.globl vector229
vector229:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $229
801076d9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801076de:	e9 3d ef ff ff       	jmp    80106620 <alltraps>

801076e3 <vector230>:
.globl vector230
vector230:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $230
801076e5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801076ea:	e9 31 ef ff ff       	jmp    80106620 <alltraps>

801076ef <vector231>:
.globl vector231
vector231:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $231
801076f1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076f6:	e9 25 ef ff ff       	jmp    80106620 <alltraps>

801076fb <vector232>:
.globl vector232
vector232:
  pushl $0
801076fb:	6a 00                	push   $0x0
  pushl $232
801076fd:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107702:	e9 19 ef ff ff       	jmp    80106620 <alltraps>

80107707 <vector233>:
.globl vector233
vector233:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $233
80107709:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010770e:	e9 0d ef ff ff       	jmp    80106620 <alltraps>

80107713 <vector234>:
.globl vector234
vector234:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $234
80107715:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010771a:	e9 01 ef ff ff       	jmp    80106620 <alltraps>

8010771f <vector235>:
.globl vector235
vector235:
  pushl $0
8010771f:	6a 00                	push   $0x0
  pushl $235
80107721:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107726:	e9 f5 ee ff ff       	jmp    80106620 <alltraps>

8010772b <vector236>:
.globl vector236
vector236:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $236
8010772d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107732:	e9 e9 ee ff ff       	jmp    80106620 <alltraps>

80107737 <vector237>:
.globl vector237
vector237:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $237
80107739:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010773e:	e9 dd ee ff ff       	jmp    80106620 <alltraps>

80107743 <vector238>:
.globl vector238
vector238:
  pushl $0
80107743:	6a 00                	push   $0x0
  pushl $238
80107745:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010774a:	e9 d1 ee ff ff       	jmp    80106620 <alltraps>

8010774f <vector239>:
.globl vector239
vector239:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $239
80107751:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107756:	e9 c5 ee ff ff       	jmp    80106620 <alltraps>

8010775b <vector240>:
.globl vector240
vector240:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $240
8010775d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107762:	e9 b9 ee ff ff       	jmp    80106620 <alltraps>

80107767 <vector241>:
.globl vector241
vector241:
  pushl $0
80107767:	6a 00                	push   $0x0
  pushl $241
80107769:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010776e:	e9 ad ee ff ff       	jmp    80106620 <alltraps>

80107773 <vector242>:
.globl vector242
vector242:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $242
80107775:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010777a:	e9 a1 ee ff ff       	jmp    80106620 <alltraps>

8010777f <vector243>:
.globl vector243
vector243:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $243
80107781:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107786:	e9 95 ee ff ff       	jmp    80106620 <alltraps>

8010778b <vector244>:
.globl vector244
vector244:
  pushl $0
8010778b:	6a 00                	push   $0x0
  pushl $244
8010778d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107792:	e9 89 ee ff ff       	jmp    80106620 <alltraps>

80107797 <vector245>:
.globl vector245
vector245:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $245
80107799:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010779e:	e9 7d ee ff ff       	jmp    80106620 <alltraps>

801077a3 <vector246>:
.globl vector246
vector246:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $246
801077a5:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077aa:	e9 71 ee ff ff       	jmp    80106620 <alltraps>

801077af <vector247>:
.globl vector247
vector247:
  pushl $0
801077af:	6a 00                	push   $0x0
  pushl $247
801077b1:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801077b6:	e9 65 ee ff ff       	jmp    80106620 <alltraps>

801077bb <vector248>:
.globl vector248
vector248:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $248
801077bd:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801077c2:	e9 59 ee ff ff       	jmp    80106620 <alltraps>

801077c7 <vector249>:
.globl vector249
vector249:
  pushl $0
801077c7:	6a 00                	push   $0x0
  pushl $249
801077c9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801077ce:	e9 4d ee ff ff       	jmp    80106620 <alltraps>

801077d3 <vector250>:
.globl vector250
vector250:
  pushl $0
801077d3:	6a 00                	push   $0x0
  pushl $250
801077d5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801077da:	e9 41 ee ff ff       	jmp    80106620 <alltraps>

801077df <vector251>:
.globl vector251
vector251:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $251
801077e1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801077e6:	e9 35 ee ff ff       	jmp    80106620 <alltraps>

801077eb <vector252>:
.globl vector252
vector252:
  pushl $0
801077eb:	6a 00                	push   $0x0
  pushl $252
801077ed:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801077f2:	e9 29 ee ff ff       	jmp    80106620 <alltraps>

801077f7 <vector253>:
.globl vector253
vector253:
  pushl $0
801077f7:	6a 00                	push   $0x0
  pushl $253
801077f9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077fe:	e9 1d ee ff ff       	jmp    80106620 <alltraps>

80107803 <vector254>:
.globl vector254
vector254:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $254
80107805:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010780a:	e9 11 ee ff ff       	jmp    80106620 <alltraps>

8010780f <vector255>:
.globl vector255
vector255:
  pushl $0
8010780f:	6a 00                	push   $0x0
  pushl $255
80107811:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107816:	e9 05 ee ff ff       	jmp    80106620 <alltraps>

8010781b <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010781b:	55                   	push   %ebp
8010781c:	89 e5                	mov    %esp,%ebp
8010781e:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107821:	8b 45 0c             	mov    0xc(%ebp),%eax
80107824:	83 e8 01             	sub    $0x1,%eax
80107827:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010782b:	8b 45 08             	mov    0x8(%ebp),%eax
8010782e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107832:	8b 45 08             	mov    0x8(%ebp),%eax
80107835:	c1 e8 10             	shr    $0x10,%eax
80107838:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010783c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010783f:	0f 01 10             	lgdtl  (%eax)
}
80107842:	90                   	nop
80107843:	c9                   	leave  
80107844:	c3                   	ret    

80107845 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107845:	55                   	push   %ebp
80107846:	89 e5                	mov    %esp,%ebp
80107848:	83 ec 04             	sub    $0x4,%esp
8010784b:	8b 45 08             	mov    0x8(%ebp),%eax
8010784e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107852:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107856:	0f 00 d8             	ltr    %ax
}
80107859:	90                   	nop
8010785a:	c9                   	leave  
8010785b:	c3                   	ret    

8010785c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010785c:	55                   	push   %ebp
8010785d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010785f:	8b 45 08             	mov    0x8(%ebp),%eax
80107862:	0f 22 d8             	mov    %eax,%cr3
}
80107865:	90                   	nop
80107866:	5d                   	pop    %ebp
80107867:	c3                   	ret    

80107868 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107868:	55                   	push   %ebp
80107869:	89 e5                	mov    %esp,%ebp
8010786b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010786e:	e8 b4 c9 ff ff       	call   80104227 <cpuid>
80107873:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107879:	05 00 48 11 80       	add    $0x80114800,%eax
8010787e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107884:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107896:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010789a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078a1:	83 e2 f0             	and    $0xfffffff0,%edx
801078a4:	83 ca 0a             	or     $0xa,%edx
801078a7:	88 50 7d             	mov    %dl,0x7d(%eax)
801078aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ad:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078b1:	83 ca 10             	or     $0x10,%edx
801078b4:	88 50 7d             	mov    %dl,0x7d(%eax)
801078b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ba:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078be:	83 e2 9f             	and    $0xffffff9f,%edx
801078c1:	88 50 7d             	mov    %dl,0x7d(%eax)
801078c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801078cb:	83 ca 80             	or     $0xffffff80,%edx
801078ce:	88 50 7d             	mov    %dl,0x7d(%eax)
801078d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078d8:	83 ca 0f             	or     $0xf,%edx
801078db:	88 50 7e             	mov    %dl,0x7e(%eax)
801078de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078e5:	83 e2 ef             	and    $0xffffffef,%edx
801078e8:	88 50 7e             	mov    %dl,0x7e(%eax)
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078f2:	83 e2 df             	and    $0xffffffdf,%edx
801078f5:	88 50 7e             	mov    %dl,0x7e(%eax)
801078f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801078ff:	83 ca 40             	or     $0x40,%edx
80107902:	88 50 7e             	mov    %dl,0x7e(%eax)
80107905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107908:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010790c:	83 ca 80             	or     $0xffffff80,%edx
8010790f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107915:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107923:	ff ff 
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010792f:	00 00 
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010793b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107945:	83 e2 f0             	and    $0xfffffff0,%edx
80107948:	83 ca 02             	or     $0x2,%edx
8010794b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107954:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010795b:	83 ca 10             	or     $0x10,%edx
8010795e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010796e:	83 e2 9f             	and    $0xffffff9f,%edx
80107971:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107981:	83 ca 80             	or     $0xffffff80,%edx
80107984:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010798a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107994:	83 ca 0f             	or     $0xf,%edx
80107997:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010799d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079a7:	83 e2 ef             	and    $0xffffffef,%edx
801079aa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079ba:	83 e2 df             	and    $0xffffffdf,%edx
801079bd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079cd:	83 ca 40             	or     $0x40,%edx
801079d0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801079e0:	83 ca 80             	or     $0xffffff80,%edx
801079e3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801079e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ec:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801079fd:	ff ff 
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107a09:	00 00 
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a18:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a1f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a22:	83 ca 0a             	or     $0xa,%edx
80107a25:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a35:	83 ca 10             	or     $0x10,%edx
80107a38:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a48:	83 ca 60             	or     $0x60,%edx
80107a4b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a5b:	83 ca 80             	or     $0xffffff80,%edx
80107a5e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a67:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a6e:	83 ca 0f             	or     $0xf,%edx
80107a71:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a81:	83 e2 ef             	and    $0xffffffef,%edx
80107a84:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a94:	83 e2 df             	and    $0xffffffdf,%edx
80107a97:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107aa7:	83 ca 40             	or     $0x40,%edx
80107aaa:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107aba:	83 ca 80             	or     $0xffffff80,%edx
80107abd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac6:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ad7:	ff ff 
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107ae3:	00 00 
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107af9:	83 e2 f0             	and    $0xfffffff0,%edx
80107afc:	83 ca 02             	or     $0x2,%edx
80107aff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b0f:	83 ca 10             	or     $0x10,%edx
80107b12:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b22:	83 ca 60             	or     $0x60,%edx
80107b25:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b35:	83 ca 80             	or     $0xffffff80,%edx
80107b38:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b41:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b48:	83 ca 0f             	or     $0xf,%edx
80107b4b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b5b:	83 e2 ef             	and    $0xffffffef,%edx
80107b5e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b67:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b6e:	83 e2 df             	and    $0xffffffdf,%edx
80107b71:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b81:	83 ca 40             	or     $0x40,%edx
80107b84:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b94:	83 ca 80             	or     $0xffffff80,%edx
80107b97:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	83 c0 70             	add    $0x70,%eax
80107bad:	83 ec 08             	sub    $0x8,%esp
80107bb0:	6a 30                	push   $0x30
80107bb2:	50                   	push   %eax
80107bb3:	e8 63 fc ff ff       	call   8010781b <lgdt>
80107bb8:	83 c4 10             	add    $0x10,%esp
}
80107bbb:	90                   	nop
80107bbc:	c9                   	leave  
80107bbd:	c3                   	ret    

80107bbe <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107bbe:	55                   	push   %ebp
80107bbf:	89 e5                	mov    %esp,%ebp
80107bc1:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc7:	c1 e8 16             	shr    $0x16,%eax
80107bca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd4:	01 d0                	add    %edx,%eax
80107bd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bdc:	8b 00                	mov    (%eax),%eax
80107bde:	83 e0 01             	and    $0x1,%eax
80107be1:	85 c0                	test   %eax,%eax
80107be3:	74 14                	je     80107bf9 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be8:	8b 00                	mov    (%eax),%eax
80107bea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bef:	05 00 00 00 80       	add    $0x80000000,%eax
80107bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bf7:	eb 42                	jmp    80107c3b <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107bf9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107bfd:	74 0e                	je     80107c0d <walkpgdir+0x4f>
80107bff:	e8 c4 b0 ff ff       	call   80102cc8 <kalloc>
80107c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c0b:	75 07                	jne    80107c14 <walkpgdir+0x56>
      return 0;
80107c0d:	b8 00 00 00 00       	mov    $0x0,%eax
80107c12:	eb 3e                	jmp    80107c52 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c14:	83 ec 04             	sub    $0x4,%esp
80107c17:	68 00 10 00 00       	push   $0x1000
80107c1c:	6a 00                	push   $0x0
80107c1e:	ff 75 f4             	pushl  -0xc(%ebp)
80107c21:	e8 20 d6 ff ff       	call   80105246 <memset>
80107c26:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2c:	05 00 00 00 80       	add    $0x80000000,%eax
80107c31:	83 c8 07             	or     $0x7,%eax
80107c34:	89 c2                	mov    %eax,%edx
80107c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c39:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c3e:	c1 e8 0c             	shr    $0xc,%eax
80107c41:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c46:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c50:	01 d0                	add    %edx,%eax
}
80107c52:	c9                   	leave  
80107c53:	c3                   	ret    

80107c54 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c54:	55                   	push   %ebp
80107c55:	89 e5                	mov    %esp,%ebp
80107c57:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
 
//  cprintf("SIZE: %x\n", size);
  a = (char*)PGROUNDDOWN((uint)va);
80107c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c65:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c68:	8b 45 10             	mov    0x10(%ebp),%eax
80107c6b:	01 d0                	add    %edx,%eax
80107c6d:	83 e8 01             	sub    $0x1,%eax
80107c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c78:	83 ec 04             	sub    $0x4,%esp
80107c7b:	6a 01                	push   $0x1
80107c7d:	ff 75 f4             	pushl  -0xc(%ebp)
80107c80:	ff 75 08             	pushl  0x8(%ebp)
80107c83:	e8 36 ff ff ff       	call   80107bbe <walkpgdir>
80107c88:	83 c4 10             	add    $0x10,%esp
80107c8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c92:	75 07                	jne    80107c9b <mappages+0x47>
      return -1;
80107c94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c99:	eb 47                	jmp    80107ce2 <mappages+0x8e>
    if(*pte & PTE_P)
80107c9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c9e:	8b 00                	mov    (%eax),%eax
80107ca0:	83 e0 01             	and    $0x1,%eax
80107ca3:	85 c0                	test   %eax,%eax
80107ca5:	74 0d                	je     80107cb4 <mappages+0x60>
      panic("remap");
80107ca7:	83 ec 0c             	sub    $0xc,%esp
80107caa:	68 18 91 10 80       	push   $0x80109118
80107caf:	e8 ec 88 ff ff       	call   801005a0 <panic>
    *pte = pa | perm | PTE_P;
80107cb4:	8b 45 18             	mov    0x18(%ebp),%eax
80107cb7:	0b 45 14             	or     0x14(%ebp),%eax
80107cba:	83 c8 01             	or     $0x1,%eax
80107cbd:	89 c2                	mov    %eax,%edx
80107cbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cc2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107cca:	74 10                	je     80107cdc <mappages+0x88>
      break;
    a += PGSIZE;
80107ccc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107cd3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107cda:	eb 9c                	jmp    80107c78 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107cdc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107cdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ce2:	c9                   	leave  
80107ce3:	c3                   	ret    

80107ce4 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ce4:	55                   	push   %ebp
80107ce5:	89 e5                	mov    %esp,%ebp
80107ce7:	53                   	push   %ebx
80107ce8:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ceb:	e8 d8 af ff ff       	call   80102cc8 <kalloc>
80107cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cf3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cf7:	75 07                	jne    80107d00 <setupkvm+0x1c>
    return 0;
80107cf9:	b8 00 00 00 00       	mov    $0x0,%eax
80107cfe:	eb 78                	jmp    80107d78 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107d00:	83 ec 04             	sub    $0x4,%esp
80107d03:	68 00 10 00 00       	push   $0x1000
80107d08:	6a 00                	push   $0x0
80107d0a:	ff 75 f0             	pushl  -0x10(%ebp)
80107d0d:	e8 34 d5 ff ff       	call   80105246 <memset>
80107d12:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d15:	c7 45 f4 80 c4 10 80 	movl   $0x8010c480,-0xc(%ebp)
80107d1c:	eb 4e                	jmp    80107d6c <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d27:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	8b 58 08             	mov    0x8(%eax),%ebx
80107d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d33:	8b 40 04             	mov    0x4(%eax),%eax
80107d36:	29 c3                	sub    %eax,%ebx
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	8b 00                	mov    (%eax),%eax
80107d3d:	83 ec 0c             	sub    $0xc,%esp
80107d40:	51                   	push   %ecx
80107d41:	52                   	push   %edx
80107d42:	53                   	push   %ebx
80107d43:	50                   	push   %eax
80107d44:	ff 75 f0             	pushl  -0x10(%ebp)
80107d47:	e8 08 ff ff ff       	call   80107c54 <mappages>
80107d4c:	83 c4 20             	add    $0x20,%esp
80107d4f:	85 c0                	test   %eax,%eax
80107d51:	79 15                	jns    80107d68 <setupkvm+0x84>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107d53:	83 ec 0c             	sub    $0xc,%esp
80107d56:	ff 75 f0             	pushl  -0x10(%ebp)
80107d59:	e8 f4 04 00 00       	call   80108252 <freevm>
80107d5e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d61:	b8 00 00 00 00       	mov    $0x0,%eax
80107d66:	eb 10                	jmp    80107d78 <setupkvm+0x94>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d68:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d6c:	81 7d f4 c0 c4 10 80 	cmpl   $0x8010c4c0,-0xc(%ebp)
80107d73:	72 a9                	jb     80107d1e <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d7b:	c9                   	leave  
80107d7c:	c3                   	ret    

80107d7d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d7d:	55                   	push   %ebp
80107d7e:	89 e5                	mov    %esp,%ebp
80107d80:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d83:	e8 5c ff ff ff       	call   80107ce4 <setupkvm>
80107d88:	a3 24 77 11 80       	mov    %eax,0x80117724
  switchkvm();
80107d8d:	e8 03 00 00 00       	call   80107d95 <switchkvm>
}
80107d92:	90                   	nop
80107d93:	c9                   	leave  
80107d94:	c3                   	ret    

80107d95 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d95:	55                   	push   %ebp
80107d96:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d98:	a1 24 77 11 80       	mov    0x80117724,%eax
80107d9d:	05 00 00 00 80       	add    $0x80000000,%eax
80107da2:	50                   	push   %eax
80107da3:	e8 b4 fa ff ff       	call   8010785c <lcr3>
80107da8:	83 c4 04             	add    $0x4,%esp
}
80107dab:	90                   	nop
80107dac:	c9                   	leave  
80107dad:	c3                   	ret    

80107dae <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107dae:	55                   	push   %ebp
80107daf:	89 e5                	mov    %esp,%ebp
80107db1:	56                   	push   %esi
80107db2:	53                   	push   %ebx
80107db3:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107db6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107dba:	75 0d                	jne    80107dc9 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107dbc:	83 ec 0c             	sub    $0xc,%esp
80107dbf:	68 1e 91 10 80       	push   $0x8010911e
80107dc4:	e8 d7 87 ff ff       	call   801005a0 <panic>
  if(p->kstack == 0)
80107dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80107dcc:	8b 40 08             	mov    0x8(%eax),%eax
80107dcf:	85 c0                	test   %eax,%eax
80107dd1:	75 0d                	jne    80107de0 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107dd3:	83 ec 0c             	sub    $0xc,%esp
80107dd6:	68 34 91 10 80       	push   $0x80109134
80107ddb:	e8 c0 87 ff ff       	call   801005a0 <panic>
  if(p->pgdir == 0)
80107de0:	8b 45 08             	mov    0x8(%ebp),%eax
80107de3:	8b 40 04             	mov    0x4(%eax),%eax
80107de6:	85 c0                	test   %eax,%eax
80107de8:	75 0d                	jne    80107df7 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107dea:	83 ec 0c             	sub    $0xc,%esp
80107ded:	68 49 91 10 80       	push   $0x80109149
80107df2:	e8 a9 87 ff ff       	call   801005a0 <panic>

  pushcli();
80107df7:	e8 3e d3 ff ff       	call   8010513a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107dfc:	e8 47 c4 ff ff       	call   80104248 <mycpu>
80107e01:	89 c3                	mov    %eax,%ebx
80107e03:	e8 40 c4 ff ff       	call   80104248 <mycpu>
80107e08:	83 c0 08             	add    $0x8,%eax
80107e0b:	89 c6                	mov    %eax,%esi
80107e0d:	e8 36 c4 ff ff       	call   80104248 <mycpu>
80107e12:	83 c0 08             	add    $0x8,%eax
80107e15:	c1 e8 10             	shr    $0x10,%eax
80107e18:	88 45 f7             	mov    %al,-0x9(%ebp)
80107e1b:	e8 28 c4 ff ff       	call   80104248 <mycpu>
80107e20:	83 c0 08             	add    $0x8,%eax
80107e23:	c1 e8 18             	shr    $0x18,%eax
80107e26:	89 c2                	mov    %eax,%edx
80107e28:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107e2f:	67 00 
80107e31:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107e38:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107e3c:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107e42:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e49:	83 e0 f0             	and    $0xfffffff0,%eax
80107e4c:	83 c8 09             	or     $0x9,%eax
80107e4f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e55:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e5c:	83 c8 10             	or     $0x10,%eax
80107e5f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e65:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e6c:	83 e0 9f             	and    $0xffffff9f,%eax
80107e6f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e75:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e7c:	83 c8 80             	or     $0xffffff80,%eax
80107e7f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e85:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e8c:	83 e0 f0             	and    $0xfffffff0,%eax
80107e8f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e95:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e9c:	83 e0 ef             	and    $0xffffffef,%eax
80107e9f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ea5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107eac:	83 e0 df             	and    $0xffffffdf,%eax
80107eaf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107eb5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ebc:	83 c8 40             	or     $0x40,%eax
80107ebf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ec5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ecc:	83 e0 7f             	and    $0x7f,%eax
80107ecf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ed5:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107edb:	e8 68 c3 ff ff       	call   80104248 <mycpu>
80107ee0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ee7:	83 e2 ef             	and    $0xffffffef,%edx
80107eea:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107ef0:	e8 53 c3 ff ff       	call   80104248 <mycpu>
80107ef5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107efb:	e8 48 c3 ff ff       	call   80104248 <mycpu>
80107f00:	89 c2                	mov    %eax,%edx
80107f02:	8b 45 08             	mov    0x8(%ebp),%eax
80107f05:	8b 40 08             	mov    0x8(%eax),%eax
80107f08:	05 00 10 00 00       	add    $0x1000,%eax
80107f0d:	89 42 0c             	mov    %eax,0xc(%edx)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107f10:	e8 33 c3 ff ff       	call   80104248 <mycpu>
80107f15:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107f1b:	83 ec 0c             	sub    $0xc,%esp
80107f1e:	6a 28                	push   $0x28
80107f20:	e8 20 f9 ff ff       	call   80107845 <ltr>
80107f25:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107f28:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2b:	8b 40 04             	mov    0x4(%eax),%eax
80107f2e:	05 00 00 00 80       	add    $0x80000000,%eax
80107f33:	83 ec 0c             	sub    $0xc,%esp
80107f36:	50                   	push   %eax
80107f37:	e8 20 f9 ff ff       	call   8010785c <lcr3>
80107f3c:	83 c4 10             	add    $0x10,%esp
  popcli();
80107f3f:	e8 44 d2 ff ff       	call   80105188 <popcli>
}
80107f44:	90                   	nop
80107f45:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107f48:	5b                   	pop    %ebx
80107f49:	5e                   	pop    %esi
80107f4a:	5d                   	pop    %ebp
80107f4b:	c3                   	ret    

80107f4c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107f4c:	55                   	push   %ebp
80107f4d:	89 e5                	mov    %esp,%ebp
80107f4f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107f52:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f59:	76 0d                	jbe    80107f68 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107f5b:	83 ec 0c             	sub    $0xc,%esp
80107f5e:	68 5d 91 10 80       	push   $0x8010915d
80107f63:	e8 38 86 ff ff       	call   801005a0 <panic>
  mem = kalloc();
80107f68:	e8 5b ad ff ff       	call   80102cc8 <kalloc>
80107f6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f70:	83 ec 04             	sub    $0x4,%esp
80107f73:	68 00 10 00 00       	push   $0x1000
80107f78:	6a 00                	push   $0x0
80107f7a:	ff 75 f4             	pushl  -0xc(%ebp)
80107f7d:	e8 c4 d2 ff ff       	call   80105246 <memset>
80107f82:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	05 00 00 00 80       	add    $0x80000000,%eax
80107f8d:	83 ec 0c             	sub    $0xc,%esp
80107f90:	6a 06                	push   $0x6
80107f92:	50                   	push   %eax
80107f93:	68 00 10 00 00       	push   $0x1000
80107f98:	6a 00                	push   $0x0
80107f9a:	ff 75 08             	pushl  0x8(%ebp)
80107f9d:	e8 b2 fc ff ff       	call   80107c54 <mappages>
80107fa2:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107fa5:	83 ec 04             	sub    $0x4,%esp
80107fa8:	ff 75 10             	pushl  0x10(%ebp)
80107fab:	ff 75 0c             	pushl  0xc(%ebp)
80107fae:	ff 75 f4             	pushl  -0xc(%ebp)
80107fb1:	e8 4f d3 ff ff       	call   80105305 <memmove>
80107fb6:	83 c4 10             	add    $0x10,%esp
}
80107fb9:	90                   	nop
80107fba:	c9                   	leave  
80107fbb:	c3                   	ret    

80107fbc <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107fbc:	55                   	push   %ebp
80107fbd:	89 e5                	mov    %esp,%ebp
80107fbf:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc5:	25 ff 0f 00 00       	and    $0xfff,%eax
80107fca:	85 c0                	test   %eax,%eax
80107fcc:	74 0d                	je     80107fdb <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107fce:	83 ec 0c             	sub    $0xc,%esp
80107fd1:	68 78 91 10 80       	push   $0x80109178
80107fd6:	e8 c5 85 ff ff       	call   801005a0 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fe2:	e9 8f 00 00 00       	jmp    80108076 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fed:	01 d0                	add    %edx,%eax
80107fef:	83 ec 04             	sub    $0x4,%esp
80107ff2:	6a 00                	push   $0x0
80107ff4:	50                   	push   %eax
80107ff5:	ff 75 08             	pushl  0x8(%ebp)
80107ff8:	e8 c1 fb ff ff       	call   80107bbe <walkpgdir>
80107ffd:	83 c4 10             	add    $0x10,%esp
80108000:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108003:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108007:	75 0d                	jne    80108016 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108009:	83 ec 0c             	sub    $0xc,%esp
8010800c:	68 9b 91 10 80       	push   $0x8010919b
80108011:	e8 8a 85 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108019:	8b 00                	mov    (%eax),%eax
8010801b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108020:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108023:	8b 45 18             	mov    0x18(%ebp),%eax
80108026:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108029:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010802e:	77 0b                	ja     8010803b <loaduvm+0x7f>
      n = sz - i;
80108030:	8b 45 18             	mov    0x18(%ebp),%eax
80108033:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108036:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108039:	eb 07                	jmp    80108042 <loaduvm+0x86>
    else
      n = PGSIZE;
8010803b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108042:	8b 55 14             	mov    0x14(%ebp),%edx
80108045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108048:	01 d0                	add    %edx,%eax
8010804a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010804d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108053:	ff 75 f0             	pushl  -0x10(%ebp)
80108056:	50                   	push   %eax
80108057:	52                   	push   %edx
80108058:	ff 75 10             	pushl  0x10(%ebp)
8010805b:	e8 d4 9e ff ff       	call   80101f34 <readi>
80108060:	83 c4 10             	add    $0x10,%esp
80108063:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108066:	74 07                	je     8010806f <loaduvm+0xb3>
      return -1;
80108068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010806d:	eb 18                	jmp    80108087 <loaduvm+0xcb>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010806f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108079:	3b 45 18             	cmp    0x18(%ebp),%eax
8010807c:	0f 82 65 ff ff ff    	jb     80107fe7 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108082:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108087:	c9                   	leave  
80108088:	c3                   	ret    

80108089 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108089:	55                   	push   %ebp
8010808a:	89 e5                	mov    %esp,%ebp
8010808c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010808f:	8b 45 10             	mov    0x10(%ebp),%eax
80108092:	85 c0                	test   %eax,%eax
80108094:	79 0a                	jns    801080a0 <allocuvm+0x17>
    return 0;
80108096:	b8 00 00 00 00       	mov    $0x0,%eax
8010809b:	e9 ec 00 00 00       	jmp    8010818c <allocuvm+0x103>
  if(newsz < oldsz)
801080a0:	8b 45 10             	mov    0x10(%ebp),%eax
801080a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080a6:	73 08                	jae    801080b0 <allocuvm+0x27>
    return oldsz;
801080a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ab:	e9 dc 00 00 00       	jmp    8010818c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801080b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801080b3:	05 ff 0f 00 00       	add    $0xfff,%eax
801080b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  a = oldsz;
//  cprintf("ALLOC TOP: %x\n", newsz);
//  cprintf("ALLOC BOTTOM: %x\n", a);
  for(; a < newsz; a += PGSIZE){
801080c0:	e9 b8 00 00 00       	jmp    8010817d <allocuvm+0xf4>
    mem = kalloc();
801080c5:	e8 fe ab ff ff       	call   80102cc8 <kalloc>
801080ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801080cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080d1:	75 2e                	jne    80108101 <allocuvm+0x78>
//	cprintf("SP: %x\n", myproc()->tf->esp);
      cprintf("allocuvm out of memory\n");
801080d3:	83 ec 0c             	sub    $0xc,%esp
801080d6:	68 b9 91 10 80       	push   $0x801091b9
801080db:	e8 20 83 ff ff       	call   80100400 <cprintf>
801080e0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080e3:	83 ec 04             	sub    $0x4,%esp
801080e6:	ff 75 0c             	pushl  0xc(%ebp)
801080e9:	ff 75 10             	pushl  0x10(%ebp)
801080ec:	ff 75 08             	pushl  0x8(%ebp)
801080ef:	e8 9a 00 00 00       	call   8010818e <deallocuvm>
801080f4:	83 c4 10             	add    $0x10,%esp
      return 0;
801080f7:	b8 00 00 00 00       	mov    $0x0,%eax
801080fc:	e9 8b 00 00 00       	jmp    8010818c <allocuvm+0x103>
    }
//   cprintf("MEM: %x\n", mem);
    memset(mem, 0, PGSIZE);
80108101:	83 ec 04             	sub    $0x4,%esp
80108104:	68 00 10 00 00       	push   $0x1000
80108109:	6a 00                	push   $0x0
8010810b:	ff 75 f0             	pushl  -0x10(%ebp)
8010810e:	e8 33 d1 ff ff       	call   80105246 <memset>
80108113:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108119:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	83 ec 0c             	sub    $0xc,%esp
80108125:	6a 06                	push   $0x6
80108127:	52                   	push   %edx
80108128:	68 00 10 00 00       	push   $0x1000
8010812d:	50                   	push   %eax
8010812e:	ff 75 08             	pushl  0x8(%ebp)
80108131:	e8 1e fb ff ff       	call   80107c54 <mappages>
80108136:	83 c4 20             	add    $0x20,%esp
80108139:	85 c0                	test   %eax,%eax
8010813b:	79 39                	jns    80108176 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010813d:	83 ec 0c             	sub    $0xc,%esp
80108140:	68 d1 91 10 80       	push   $0x801091d1
80108145:	e8 b6 82 ff ff       	call   80100400 <cprintf>
8010814a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010814d:	83 ec 04             	sub    $0x4,%esp
80108150:	ff 75 0c             	pushl  0xc(%ebp)
80108153:	ff 75 10             	pushl  0x10(%ebp)
80108156:	ff 75 08             	pushl  0x8(%ebp)
80108159:	e8 30 00 00 00       	call   8010818e <deallocuvm>
8010815e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108161:	83 ec 0c             	sub    $0xc,%esp
80108164:	ff 75 f0             	pushl  -0x10(%ebp)
80108167:	e8 c2 aa ff ff       	call   80102c2e <kfree>
8010816c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010816f:	b8 00 00 00 00       	mov    $0x0,%eax
80108174:	eb 16                	jmp    8010818c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
//  a = oldsz;
//  cprintf("ALLOC TOP: %x\n", newsz);
//  cprintf("ALLOC BOTTOM: %x\n", a);
  for(; a < newsz; a += PGSIZE){
80108176:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010817d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108180:	3b 45 10             	cmp    0x10(%ebp),%eax
80108183:	0f 82 3c ff ff ff    	jb     801080c5 <allocuvm+0x3c>
      kfree(mem);
      return 0;
    }
  }
//  cprintf("TOPPAGE: %x\n", newsz);
  return newsz;
80108189:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010818c:	c9                   	leave  
8010818d:	c3                   	ret    

8010818e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010818e:	55                   	push   %ebp
8010818f:	89 e5                	mov    %esp,%ebp
80108191:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108194:	8b 45 10             	mov    0x10(%ebp),%eax
80108197:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010819a:	72 08                	jb     801081a4 <deallocuvm+0x16>
    return oldsz;
8010819c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010819f:	e9 ac 00 00 00       	jmp    80108250 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801081a4:	8b 45 10             	mov    0x10(%ebp),%eax
801081a7:	05 ff 0f 00 00       	add    $0xfff,%eax
801081ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081b4:	e9 88 00 00 00       	jmp    80108241 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801081b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bc:	83 ec 04             	sub    $0x4,%esp
801081bf:	6a 00                	push   $0x0
801081c1:	50                   	push   %eax
801081c2:	ff 75 08             	pushl  0x8(%ebp)
801081c5:	e8 f4 f9 ff ff       	call   80107bbe <walkpgdir>
801081ca:	83 c4 10             	add    $0x10,%esp
801081cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081d4:	75 16                	jne    801081ec <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801081d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d9:	c1 e8 16             	shr    $0x16,%eax
801081dc:	83 c0 01             	add    $0x1,%eax
801081df:	c1 e0 16             	shl    $0x16,%eax
801081e2:	2d 00 10 00 00       	sub    $0x1000,%eax
801081e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081ea:	eb 4e                	jmp    8010823a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801081ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ef:	8b 00                	mov    (%eax),%eax
801081f1:	83 e0 01             	and    $0x1,%eax
801081f4:	85 c0                	test   %eax,%eax
801081f6:	74 42                	je     8010823a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801081f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fb:	8b 00                	mov    (%eax),%eax
801081fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108202:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108205:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108209:	75 0d                	jne    80108218 <deallocuvm+0x8a>
        panic("kfree");
8010820b:	83 ec 0c             	sub    $0xc,%esp
8010820e:	68 ed 91 10 80       	push   $0x801091ed
80108213:	e8 88 83 ff ff       	call   801005a0 <panic>
      char *v = P2V(pa);
80108218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010821b:	05 00 00 00 80       	add    $0x80000000,%eax
80108220:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108223:	83 ec 0c             	sub    $0xc,%esp
80108226:	ff 75 e8             	pushl  -0x18(%ebp)
80108229:	e8 00 aa ff ff       	call   80102c2e <kfree>
8010822e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108234:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010823a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108244:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108247:	0f 82 6c ff ff ff    	jb     801081b9 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010824d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108250:	c9                   	leave  
80108251:	c3                   	ret    

80108252 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108252:	55                   	push   %ebp
80108253:	89 e5                	mov    %esp,%ebp
80108255:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108258:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010825c:	75 0d                	jne    8010826b <freevm+0x19>
    panic("freevm: no pgdir");
8010825e:	83 ec 0c             	sub    $0xc,%esp
80108261:	68 f3 91 10 80       	push   $0x801091f3
80108266:	e8 35 83 ff ff       	call   801005a0 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010826b:	83 ec 04             	sub    $0x4,%esp
8010826e:	6a 00                	push   $0x0
80108270:	68 00 00 00 80       	push   $0x80000000
80108275:	ff 75 08             	pushl  0x8(%ebp)
80108278:	e8 11 ff ff ff       	call   8010818e <deallocuvm>
8010827d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108287:	eb 48                	jmp    801082d1 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108293:	8b 45 08             	mov    0x8(%ebp),%eax
80108296:	01 d0                	add    %edx,%eax
80108298:	8b 00                	mov    (%eax),%eax
8010829a:	83 e0 01             	and    $0x1,%eax
8010829d:	85 c0                	test   %eax,%eax
8010829f:	74 2c                	je     801082cd <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801082a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082ab:	8b 45 08             	mov    0x8(%ebp),%eax
801082ae:	01 d0                	add    %edx,%eax
801082b0:	8b 00                	mov    (%eax),%eax
801082b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b7:	05 00 00 00 80       	add    $0x80000000,%eax
801082bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801082bf:	83 ec 0c             	sub    $0xc,%esp
801082c2:	ff 75 f0             	pushl  -0x10(%ebp)
801082c5:	e8 64 a9 ff ff       	call   80102c2e <kfree>
801082ca:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801082cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082d1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801082d8:	76 af                	jbe    80108289 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801082da:	83 ec 0c             	sub    $0xc,%esp
801082dd:	ff 75 08             	pushl  0x8(%ebp)
801082e0:	e8 49 a9 ff ff       	call   80102c2e <kfree>
801082e5:	83 c4 10             	add    $0x10,%esp
}
801082e8:	90                   	nop
801082e9:	c9                   	leave  
801082ea:	c3                   	ret    

801082eb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801082eb:	55                   	push   %ebp
801082ec:	89 e5                	mov    %esp,%ebp
801082ee:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082f1:	83 ec 04             	sub    $0x4,%esp
801082f4:	6a 00                	push   $0x0
801082f6:	ff 75 0c             	pushl  0xc(%ebp)
801082f9:	ff 75 08             	pushl  0x8(%ebp)
801082fc:	e8 bd f8 ff ff       	call   80107bbe <walkpgdir>
80108301:	83 c4 10             	add    $0x10,%esp
80108304:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010830b:	75 0d                	jne    8010831a <clearpteu+0x2f>
    panic("clearpteu");
8010830d:	83 ec 0c             	sub    $0xc,%esp
80108310:	68 04 92 10 80       	push   $0x80109204
80108315:	e8 86 82 ff ff       	call   801005a0 <panic>
  *pte &= ~PTE_U;
8010831a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831d:	8b 00                	mov    (%eax),%eax
8010831f:	83 e0 fb             	and    $0xfffffffb,%eax
80108322:	89 c2                	mov    %eax,%edx
80108324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108327:	89 10                	mov    %edx,(%eax)
}
80108329:	90                   	nop
8010832a:	c9                   	leave  
8010832b:	c3                   	ret    

8010832c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, uint lp, uint pn)
{
8010832c:	55                   	push   %ebp
8010832d:	89 e5                	mov    %esp,%ebp
8010832f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108332:	e8 ad f9 ff ff       	call   80107ce4 <setupkvm>
80108337:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010833a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010833e:	75 0a                	jne    8010834a <copyuvm+0x1e>
    return 0;
80108340:	b8 00 00 00 00       	mov    $0x0,%eax
80108345:	e9 ce 01 00 00       	jmp    80108518 <copyuvm+0x1ec>
  for(i = 0; i < sz; i += PGSIZE){
8010834a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108351:	e9 bf 00 00 00       	jmp    80108415 <copyuvm+0xe9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108359:	83 ec 04             	sub    $0x4,%esp
8010835c:	6a 00                	push   $0x0
8010835e:	50                   	push   %eax
8010835f:	ff 75 08             	pushl  0x8(%ebp)
80108362:	e8 57 f8 ff ff       	call   80107bbe <walkpgdir>
80108367:	83 c4 10             	add    $0x10,%esp
8010836a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010836d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108371:	75 0d                	jne    80108380 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108373:	83 ec 0c             	sub    $0xc,%esp
80108376:	68 0e 92 10 80       	push   $0x8010920e
8010837b:	e8 20 82 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
80108380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108383:	8b 00                	mov    (%eax),%eax
80108385:	83 e0 01             	and    $0x1,%eax
80108388:	85 c0                	test   %eax,%eax
8010838a:	75 0d                	jne    80108399 <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010838c:	83 ec 0c             	sub    $0xc,%esp
8010838f:	68 28 92 10 80       	push   $0x80109228
80108394:	e8 07 82 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108399:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010839c:	8b 00                	mov    (%eax),%eax
8010839e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a9:	8b 00                	mov    (%eax),%eax
801083ab:	25 ff 0f 00 00       	and    $0xfff,%eax
801083b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083b3:	e8 10 a9 ff ff       	call   80102cc8 <kalloc>
801083b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
801083bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801083bf:	0f 84 36 01 00 00    	je     801084fb <copyuvm+0x1cf>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801083c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083c8:	05 00 00 00 80       	add    $0x80000000,%eax
801083cd:	83 ec 04             	sub    $0x4,%esp
801083d0:	68 00 10 00 00       	push   $0x1000
801083d5:	50                   	push   %eax
801083d6:	ff 75 e0             	pushl  -0x20(%ebp)
801083d9:	e8 27 cf ff ff       	call   80105305 <memmove>
801083de:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801083e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801083e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083e7:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801083ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f0:	83 ec 0c             	sub    $0xc,%esp
801083f3:	52                   	push   %edx
801083f4:	51                   	push   %ecx
801083f5:	68 00 10 00 00       	push   $0x1000
801083fa:	50                   	push   %eax
801083fb:	ff 75 f0             	pushl  -0x10(%ebp)
801083fe:	e8 51 f8 ff ff       	call   80107c54 <mappages>
80108403:	83 c4 20             	add    $0x20,%esp
80108406:	85 c0                	test   %eax,%eax
80108408:	0f 88 f0 00 00 00    	js     801084fe <copyuvm+0x1d2>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010840e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010841b:	0f 82 35 ff ff ff    	jb     80108356 <copyuvm+0x2a>
      goto bad;
  }

  //Added second loop so that the stack is correctly copied over to the new process CS153
// cprintf("COPUVM SP2 : %x\n", lp-pn*PGSIZE);
 for(i = PGROUNDDOWN(lp-1); i < KERNBASE; i += PGSIZE){
80108421:	8b 45 10             	mov    0x10(%ebp),%eax
80108424:	83 e8 01             	sub    $0x1,%eax
80108427:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010842c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010842f:	e9 b7 00 00 00       	jmp    801084eb <copyuvm+0x1bf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108437:	83 ec 04             	sub    $0x4,%esp
8010843a:	6a 00                	push   $0x0
8010843c:	50                   	push   %eax
8010843d:	ff 75 08             	pushl  0x8(%ebp)
80108440:	e8 79 f7 ff ff       	call   80107bbe <walkpgdir>
80108445:	83 c4 10             	add    $0x10,%esp
80108448:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010844b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010844f:	75 0d                	jne    8010845e <copyuvm+0x132>
      panic("copyuvm: pte should exist");
80108451:	83 ec 0c             	sub    $0xc,%esp
80108454:	68 0e 92 10 80       	push   $0x8010920e
80108459:	e8 42 81 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010845e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108461:	8b 00                	mov    (%eax),%eax
80108463:	83 e0 01             	and    $0x1,%eax
80108466:	85 c0                	test   %eax,%eax
80108468:	75 0d                	jne    80108477 <copyuvm+0x14b>
      panic("copyuvm: page not present");
8010846a:	83 ec 0c             	sub    $0xc,%esp
8010846d:	68 28 92 10 80       	push   $0x80109228
80108472:	e8 29 81 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847a:	8b 00                	mov    (%eax),%eax
8010847c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108481:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108484:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108487:	8b 00                	mov    (%eax),%eax
80108489:	25 ff 0f 00 00       	and    $0xfff,%eax
8010848e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108491:	e8 32 a8 ff ff       	call   80102cc8 <kalloc>
80108496:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108499:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010849d:	74 62                	je     80108501 <copyuvm+0x1d5>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010849f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084a2:	05 00 00 00 80       	add    $0x80000000,%eax
801084a7:	83 ec 04             	sub    $0x4,%esp
801084aa:	68 00 10 00 00       	push   $0x1000
801084af:	50                   	push   %eax
801084b0:	ff 75 e0             	pushl  -0x20(%ebp)
801084b3:	e8 4d ce ff ff       	call   80105305 <memmove>
801084b8:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801084bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801084be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084c1:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801084c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ca:	83 ec 0c             	sub    $0xc,%esp
801084cd:	52                   	push   %edx
801084ce:	51                   	push   %ecx
801084cf:	68 00 10 00 00       	push   $0x1000
801084d4:	50                   	push   %eax
801084d5:	ff 75 f0             	pushl  -0x10(%ebp)
801084d8:	e8 77 f7 ff ff       	call   80107c54 <mappages>
801084dd:	83 c4 20             	add    $0x20,%esp
801084e0:	85 c0                	test   %eax,%eax
801084e2:	78 20                	js     80108504 <copyuvm+0x1d8>
      goto bad;
  }

  //Added second loop so that the stack is correctly copied over to the new process CS153
// cprintf("COPUVM SP2 : %x\n", lp-pn*PGSIZE);
 for(i = PGROUNDDOWN(lp-1); i < KERNBASE; i += PGSIZE){
801084e4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ee:	85 c0                	test   %eax,%eax
801084f0:	0f 89 3e ff ff ff    	jns    80108434 <copyuvm+0x108>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }

  return d;
801084f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f9:	eb 1d                	jmp    80108518 <copyuvm+0x1ec>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801084fb:	90                   	nop
801084fc:	eb 07                	jmp    80108505 <copyuvm+0x1d9>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801084fe:	90                   	nop
801084ff:	eb 04                	jmp    80108505 <copyuvm+0x1d9>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108501:	90                   	nop
80108502:	eb 01                	jmp    80108505 <copyuvm+0x1d9>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
80108504:	90                   	nop
  }

  return d;

bad:
  freevm(d);
80108505:	83 ec 0c             	sub    $0xc,%esp
80108508:	ff 75 f0             	pushl  -0x10(%ebp)
8010850b:	e8 42 fd ff ff       	call   80108252 <freevm>
80108510:	83 c4 10             	add    $0x10,%esp
  return 0;
80108513:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108518:	c9                   	leave  
80108519:	c3                   	ret    

8010851a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010851a:	55                   	push   %ebp
8010851b:	89 e5                	mov    %esp,%ebp
8010851d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108520:	83 ec 04             	sub    $0x4,%esp
80108523:	6a 00                	push   $0x0
80108525:	ff 75 0c             	pushl  0xc(%ebp)
80108528:	ff 75 08             	pushl  0x8(%ebp)
8010852b:	e8 8e f6 ff ff       	call   80107bbe <walkpgdir>
80108530:	83 c4 10             	add    $0x10,%esp
80108533:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108539:	8b 00                	mov    (%eax),%eax
8010853b:	83 e0 01             	and    $0x1,%eax
8010853e:	85 c0                	test   %eax,%eax
80108540:	75 07                	jne    80108549 <uva2ka+0x2f>
    return 0;
80108542:	b8 00 00 00 00       	mov    $0x0,%eax
80108547:	eb 22                	jmp    8010856b <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854c:	8b 00                	mov    (%eax),%eax
8010854e:	83 e0 04             	and    $0x4,%eax
80108551:	85 c0                	test   %eax,%eax
80108553:	75 07                	jne    8010855c <uva2ka+0x42>
    return 0;
80108555:	b8 00 00 00 00       	mov    $0x0,%eax
8010855a:	eb 0f                	jmp    8010856b <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010855c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855f:	8b 00                	mov    (%eax),%eax
80108561:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108566:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010856b:	c9                   	leave  
8010856c:	c3                   	ret    

8010856d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010856d:	55                   	push   %ebp
8010856e:	89 e5                	mov    %esp,%ebp
80108570:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108573:	8b 45 10             	mov    0x10(%ebp),%eax
80108576:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108579:	eb 7f                	jmp    801085fa <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010857b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010857e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108583:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108589:	83 ec 08             	sub    $0x8,%esp
8010858c:	50                   	push   %eax
8010858d:	ff 75 08             	pushl  0x8(%ebp)
80108590:	e8 85 ff ff ff       	call   8010851a <uva2ka>
80108595:	83 c4 10             	add    $0x10,%esp
80108598:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010859b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010859f:	75 07                	jne    801085a8 <copyout+0x3b>
      return -1;
801085a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085a6:	eb 61                	jmp    80108609 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801085a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ab:	2b 45 0c             	sub    0xc(%ebp),%eax
801085ae:	05 00 10 00 00       	add    $0x1000,%eax
801085b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b9:	3b 45 14             	cmp    0x14(%ebp),%eax
801085bc:	76 06                	jbe    801085c4 <copyout+0x57>
      n = len;
801085be:	8b 45 14             	mov    0x14(%ebp),%eax
801085c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801085c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c7:	2b 45 ec             	sub    -0x14(%ebp),%eax
801085ca:	89 c2                	mov    %eax,%edx
801085cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085cf:	01 d0                	add    %edx,%eax
801085d1:	83 ec 04             	sub    $0x4,%esp
801085d4:	ff 75 f0             	pushl  -0x10(%ebp)
801085d7:	ff 75 f4             	pushl  -0xc(%ebp)
801085da:	50                   	push   %eax
801085db:	e8 25 cd ff ff       	call   80105305 <memmove>
801085e0:	83 c4 10             	add    $0x10,%esp
    len -= n;
801085e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e6:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801085e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ec:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f2:	05 00 10 00 00       	add    $0x1000,%eax
801085f7:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801085fa:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085fe:	0f 85 77 ff ff ff    	jne    8010857b <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108604:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108609:	c9                   	leave  
8010860a:	c3                   	ret    

8010860b <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
8010860b:	55                   	push   %ebp
8010860c:	89 e5                	mov    %esp,%ebp
8010860e:	83 ec 18             	sub    $0x18,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
80108611:	83 ec 08             	sub    $0x8,%esp
80108614:	68 42 92 10 80       	push   $0x80109242
80108619:	68 40 77 11 80       	push   $0x80117740
8010861e:	e8 8a c9 ff ff       	call   80104fad <initlock>
80108623:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
80108626:	83 ec 0c             	sub    $0xc,%esp
80108629:	68 40 77 11 80       	push   $0x80117740
8010862e:	e8 9c c9 ff ff       	call   80104fcf <acquire>
80108633:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i< 64; i++) {
80108636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010863d:	eb 49                	jmp    80108688 <shminit+0x7d>
    shm_table.shm_pages[i].id =0;
8010863f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108642:	89 d0                	mov    %edx,%eax
80108644:	01 c0                	add    %eax,%eax
80108646:	01 d0                	add    %edx,%eax
80108648:	c1 e0 02             	shl    $0x2,%eax
8010864b:	05 74 77 11 80       	add    $0x80117774,%eax
80108650:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80108656:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108659:	89 d0                	mov    %edx,%eax
8010865b:	01 c0                	add    %eax,%eax
8010865d:	01 d0                	add    %edx,%eax
8010865f:	c1 e0 02             	shl    $0x2,%eax
80108662:	05 78 77 11 80       	add    $0x80117778,%eax
80108667:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
8010866d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108670:	89 d0                	mov    %edx,%eax
80108672:	01 c0                	add    %eax,%eax
80108674:	01 d0                	add    %edx,%eax
80108676:	c1 e0 02             	shl    $0x2,%eax
80108679:	05 7c 77 11 80       	add    $0x8011777c,%eax
8010867e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
80108684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108688:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010868c:	7e b1                	jle    8010863f <shminit+0x34>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
8010868e:	83 ec 0c             	sub    $0xc,%esp
80108691:	68 40 77 11 80       	push   $0x80117740
80108696:	e8 a2 c9 ff ff       	call   8010503d <release>
8010869b:	83 c4 10             	add    $0x10,%esp
}
8010869e:	90                   	nop
8010869f:	c9                   	leave  
801086a0:	c3                   	ret    

801086a1 <shm_open>:

int shm_open(int id, char **pointer) {
801086a1:	55                   	push   %ebp
801086a2:	89 e5                	mov    %esp,%ebp
801086a4:	56                   	push   %esi
801086a5:	53                   	push   %ebx
801086a6:	83 ec 10             	sub    $0x10,%esp

//you write this
  initlock(&(shm_table.lock), "SHM lock");
801086a9:	83 ec 08             	sub    $0x8,%esp
801086ac:	68 42 92 10 80       	push   $0x80109242
801086b1:	68 40 77 11 80       	push   $0x80117740
801086b6:	e8 f2 c8 ff ff       	call   80104fad <initlock>
801086bb:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
801086be:	83 ec 0c             	sub    $0xc,%esp
801086c1:	68 40 77 11 80       	push   $0x80117740
801086c6:	e8 04 c9 ff ff       	call   80104fcf <acquire>
801086cb:	83 c4 10             	add    $0x10,%esp
  char *mem;

  for (int i = 0; i < 64; i++)
801086ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086d5:	e9 f4 00 00 00       	jmp    801087ce <shm_open+0x12d>
  {
      if (shm_table.shm_pages[i].id == id)
801086da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086dd:	89 d0                	mov    %edx,%eax
801086df:	01 c0                	add    %eax,%eax
801086e1:	01 d0                	add    %edx,%eax
801086e3:	c1 e0 02             	shl    $0x2,%eax
801086e6:	05 74 77 11 80       	add    $0x80117774,%eax
801086eb:	8b 10                	mov    (%eax),%edx
801086ed:	8b 45 08             	mov    0x8(%ebp),%eax
801086f0:	39 c2                	cmp    %eax,%edx
801086f2:	0f 85 d2 00 00 00    	jne    801087ca <shm_open+0x129>
      {
	  shm_table.shm_pages[i].refcnt++;
801086f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086fb:	89 d0                	mov    %edx,%eax
801086fd:	01 c0                	add    %eax,%eax
801086ff:	01 d0                	add    %edx,%eax
80108701:	c1 e0 02             	shl    $0x2,%eax
80108704:	05 7c 77 11 80       	add    $0x8011777c,%eax
80108709:	8b 00                	mov    (%eax),%eax
8010870b:	8d 48 01             	lea    0x1(%eax),%ecx
8010870e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108711:	89 d0                	mov    %edx,%eax
80108713:	01 c0                	add    %eax,%eax
80108715:	01 d0                	add    %edx,%eax
80108717:	c1 e0 02             	shl    $0x2,%eax
8010871a:	05 7c 77 11 80       	add    $0x8011777c,%eax
8010871f:	89 08                	mov    %ecx,(%eax)
 	  memset((char*)pointer, 0, PGSIZE);
80108721:	83 ec 04             	sub    $0x4,%esp
80108724:	68 00 10 00 00       	push   $0x1000
80108729:	6a 00                	push   $0x0
8010872b:	ff 75 0c             	pushl  0xc(%ebp)
8010872e:	e8 13 cb ff ff       	call   80105246 <memset>
80108733:	83 c4 10             	add    $0x10,%esp
          if (mappages(myproc()->pgdir, (char*)myproc()->sz, PGSIZE, V2P(shm_table.shm_pages[i].frame), PTE_W|PTE_U) < 0)
80108736:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108739:	89 d0                	mov    %edx,%eax
8010873b:	01 c0                	add    %eax,%eax
8010873d:	01 d0                	add    %edx,%eax
8010873f:	c1 e0 02             	shl    $0x2,%eax
80108742:	05 78 77 11 80       	add    $0x80117778,%eax
80108747:	8b 00                	mov    (%eax),%eax
80108749:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
8010874f:	e8 6c bb ff ff       	call   801042c0 <myproc>
80108754:	8b 00                	mov    (%eax),%eax
80108756:	89 c6                	mov    %eax,%esi
80108758:	e8 63 bb ff ff       	call   801042c0 <myproc>
8010875d:	8b 40 04             	mov    0x4(%eax),%eax
80108760:	83 ec 0c             	sub    $0xc,%esp
80108763:	6a 06                	push   $0x6
80108765:	53                   	push   %ebx
80108766:	68 00 10 00 00       	push   $0x1000
8010876b:	56                   	push   %esi
8010876c:	50                   	push   %eax
8010876d:	e8 e2 f4 ff ff       	call   80107c54 <mappages>
80108772:	83 c4 20             	add    $0x20,%esp
80108775:	85 c0                	test   %eax,%eax
80108777:	79 1a                	jns    80108793 <shm_open+0xf2>
	  {
	      cprintf("allocuvm out of memory (2)\n");
80108779:	83 ec 0c             	sub    $0xc,%esp
8010877c:	68 4b 92 10 80       	push   $0x8010924b
80108781:	e8 7a 7c ff ff       	call   80100400 <cprintf>
80108786:	83 c4 10             	add    $0x10,%esp
//              deallocuvm(myproc()->pgdir, myproc()->sz+PGSIZE, myproc()->sz);
//              kfree(mem);
              return 0;
80108789:	b8 00 00 00 00       	mov    $0x0,%eax
8010878e:	e9 ff 01 00 00       	jmp    80108992 <shm_open+0x2f1>
	  }
	  *pointer = (char*)myproc()->sz;
80108793:	e8 28 bb ff ff       	call   801042c0 <myproc>
80108798:	8b 00                	mov    (%eax),%eax
8010879a:	89 c2                	mov    %eax,%edx
8010879c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010879f:	89 10                	mov    %edx,(%eax)
	  myproc()->sz += PGSIZE;
801087a1:	e8 1a bb ff ff       	call   801042c0 <myproc>
801087a6:	8b 10                	mov    (%eax),%edx
801087a8:	81 c2 00 10 00 00    	add    $0x1000,%edx
801087ae:	89 10                	mov    %edx,(%eax)

 	  release(&(shm_table.lock));
801087b0:	83 ec 0c             	sub    $0xc,%esp
801087b3:	68 40 77 11 80       	push   $0x80117740
801087b8:	e8 80 c8 ff ff       	call   8010503d <release>
801087bd:	83 c4 10             	add    $0x10,%esp
  	  return 1;
801087c0:	b8 01 00 00 00       	mov    $0x1,%eax
801087c5:	e9 c8 01 00 00       	jmp    80108992 <shm_open+0x2f1>
//you write this
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  char *mem;

  for (int i = 0; i < 64; i++)
801087ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087ce:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801087d2:	0f 8e 02 ff ff ff    	jle    801086da <shm_open+0x39>
      }
  }



  for (int i = 0; i < 64; i++)
801087d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801087df:	e9 8f 01 00 00       	jmp    80108973 <shm_open+0x2d2>
  {
    if (shm_table.shm_pages[i].id == 0)
801087e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087e7:	89 d0                	mov    %edx,%eax
801087e9:	01 c0                	add    %eax,%eax
801087eb:	01 d0                	add    %edx,%eax
801087ed:	c1 e0 02             	shl    $0x2,%eax
801087f0:	05 74 77 11 80       	add    $0x80117774,%eax
801087f5:	8b 00                	mov    (%eax),%eax
801087f7:	85 c0                	test   %eax,%eax
801087f9:	0f 85 70 01 00 00    	jne    8010896f <shm_open+0x2ce>
    {
	  mem = kalloc();
801087ff:	e8 c4 a4 ff ff       	call   80102cc8 <kalloc>
80108804:	89 45 ec             	mov    %eax,-0x14(%ebp)
          if(mem == 0)
80108807:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010880b:	75 3e                	jne    8010884b <shm_open+0x1aa>
          {
      	     //cprintf("SP: %x\n", myproc()->tf->esp);
      	     cprintf("allocuvm out of memory\n");
8010880d:	83 ec 0c             	sub    $0xc,%esp
80108810:	68 67 92 10 80       	push   $0x80109267
80108815:	e8 e6 7b ff ff       	call   80100400 <cprintf>
8010881a:	83 c4 10             	add    $0x10,%esp
       	     deallocuvm(myproc()->pgdir, myproc()->sz+PGSIZE, 0);
8010881d:	e8 9e ba ff ff       	call   801042c0 <myproc>
80108822:	8b 00                	mov    (%eax),%eax
80108824:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
8010882a:	e8 91 ba ff ff       	call   801042c0 <myproc>
8010882f:	8b 40 04             	mov    0x4(%eax),%eax
80108832:	83 ec 04             	sub    $0x4,%esp
80108835:	6a 00                	push   $0x0
80108837:	53                   	push   %ebx
80108838:	50                   	push   %eax
80108839:	e8 50 f9 ff ff       	call   8010818e <deallocuvm>
8010883e:	83 c4 10             	add    $0x10,%esp
      	     return 0;
80108841:	b8 00 00 00 00       	mov    $0x0,%eax
80108846:	e9 47 01 00 00       	jmp    80108992 <shm_open+0x2f1>
          }
          //cprintf("MEM: %x\n", mem);
          memset(mem, 0, PGSIZE);
8010884b:	83 ec 04             	sub    $0x4,%esp
8010884e:	68 00 10 00 00       	push   $0x1000
80108853:	6a 00                	push   $0x0
80108855:	ff 75 ec             	pushl  -0x14(%ebp)
80108858:	e8 e9 c9 ff ff       	call   80105246 <memset>
8010885d:	83 c4 10             	add    $0x10,%esp
          if(mappages(myproc()->pgdir, (char*)myproc()->sz, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0)
80108860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108863:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80108869:	e8 52 ba ff ff       	call   801042c0 <myproc>
8010886e:	8b 00                	mov    (%eax),%eax
80108870:	89 c6                	mov    %eax,%esi
80108872:	e8 49 ba ff ff       	call   801042c0 <myproc>
80108877:	8b 40 04             	mov    0x4(%eax),%eax
8010887a:	83 ec 0c             	sub    $0xc,%esp
8010887d:	6a 06                	push   $0x6
8010887f:	53                   	push   %ebx
80108880:	68 00 10 00 00       	push   $0x1000
80108885:	56                   	push   %esi
80108886:	50                   	push   %eax
80108887:	e8 c8 f3 ff ff       	call   80107c54 <mappages>
8010888c:	83 c4 20             	add    $0x20,%esp
8010888f:	85 c0                	test   %eax,%eax
80108891:	79 52                	jns    801088e5 <shm_open+0x244>
          {
              cprintf("allocuvm out of memory (2)\n");
80108893:	83 ec 0c             	sub    $0xc,%esp
80108896:	68 4b 92 10 80       	push   $0x8010924b
8010889b:	e8 60 7b ff ff       	call   80100400 <cprintf>
801088a0:	83 c4 10             	add    $0x10,%esp
              deallocuvm(myproc()->pgdir, myproc()->sz+PGSIZE, myproc()->sz);
801088a3:	e8 18 ba ff ff       	call   801042c0 <myproc>
801088a8:	8b 18                	mov    (%eax),%ebx
801088aa:	e8 11 ba ff ff       	call   801042c0 <myproc>
801088af:	8b 00                	mov    (%eax),%eax
801088b1:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
801088b7:	e8 04 ba ff ff       	call   801042c0 <myproc>
801088bc:	8b 40 04             	mov    0x4(%eax),%eax
801088bf:	83 ec 04             	sub    $0x4,%esp
801088c2:	53                   	push   %ebx
801088c3:	56                   	push   %esi
801088c4:	50                   	push   %eax
801088c5:	e8 c4 f8 ff ff       	call   8010818e <deallocuvm>
801088ca:	83 c4 10             	add    $0x10,%esp
              kfree(mem);
801088cd:	83 ec 0c             	sub    $0xc,%esp
801088d0:	ff 75 ec             	pushl  -0x14(%ebp)
801088d3:	e8 56 a3 ff ff       	call   80102c2e <kfree>
801088d8:	83 c4 10             	add    $0x10,%esp
              return 0;
801088db:	b8 00 00 00 00       	mov    $0x0,%eax
801088e0:	e9 ad 00 00 00       	jmp    80108992 <shm_open+0x2f1>
          }
	  *pointer = (char*)myproc()->sz;
801088e5:	e8 d6 b9 ff ff       	call   801042c0 <myproc>
801088ea:	8b 00                	mov    (%eax),%eax
801088ec:	89 c2                	mov    %eax,%edx
801088ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801088f1:	89 10                	mov    %edx,(%eax)
	  myproc()->sz += PGSIZE;
801088f3:	e8 c8 b9 ff ff       	call   801042c0 <myproc>
801088f8:	8b 10                	mov    (%eax),%edx
801088fa:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108900:	89 10                	mov    %edx,(%eax)
     
      shm_table.shm_pages[i].refcnt++;
80108902:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108905:	89 d0                	mov    %edx,%eax
80108907:	01 c0                	add    %eax,%eax
80108909:	01 d0                	add    %edx,%eax
8010890b:	c1 e0 02             	shl    $0x2,%eax
8010890e:	05 7c 77 11 80       	add    $0x8011777c,%eax
80108913:	8b 00                	mov    (%eax),%eax
80108915:	8d 48 01             	lea    0x1(%eax),%ecx
80108918:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010891b:	89 d0                	mov    %edx,%eax
8010891d:	01 c0                	add    %eax,%eax
8010891f:	01 d0                	add    %edx,%eax
80108921:	c1 e0 02             	shl    $0x2,%eax
80108924:	05 7c 77 11 80       	add    $0x8011777c,%eax
80108929:	89 08                	mov    %ecx,(%eax)
      shm_table.shm_pages[i].id = id;
8010892b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010892e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108931:	89 d0                	mov    %edx,%eax
80108933:	01 c0                	add    %eax,%eax
80108935:	01 d0                	add    %edx,%eax
80108937:	c1 e0 02             	shl    $0x2,%eax
8010893a:	05 74 77 11 80       	add    $0x80117774,%eax
8010893f:	89 08                	mov    %ecx,(%eax)
      shm_table.shm_pages[i].frame = mem;
80108941:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108944:	89 d0                	mov    %edx,%eax
80108946:	01 c0                	add    %eax,%eax
80108948:	01 d0                	add    %edx,%eax
8010894a:	c1 e0 02             	shl    $0x2,%eax
8010894d:	8d 90 78 77 11 80    	lea    -0x7fee8888(%eax),%edx
80108953:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108956:	89 02                	mov    %eax,(%edx)
      release(&(shm_table.lock));
80108958:	83 ec 0c             	sub    $0xc,%esp
8010895b:	68 40 77 11 80       	push   $0x80117740
80108960:	e8 d8 c6 ff ff       	call   8010503d <release>
80108965:	83 c4 10             	add    $0x10,%esp
      return 1;
80108968:	b8 01 00 00 00       	mov    $0x1,%eax
8010896d:	eb 23                	jmp    80108992 <shm_open+0x2f1>
      }
  }



  for (int i = 0; i < 64; i++)
8010896f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108973:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80108977:	0f 8e 67 fe ff ff    	jle    801087e4 <shm_open+0x143>


//  allocuvm(myproc()->pgdir, (uint)pointer + PGSIZE, (uint)pointer);

  
  release(&(shm_table.lock));
8010897d:	83 ec 0c             	sub    $0xc,%esp
80108980:	68 40 77 11 80       	push   $0x80117740
80108985:	e8 b3 c6 ff ff       	call   8010503d <release>
8010898a:	83 c4 10             	add    $0x10,%esp
  
  return 0; //added to remove compiler warning -- you should decide what to return
8010898d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108992:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108995:	5b                   	pop    %ebx
80108996:	5e                   	pop    %esi
80108997:	5d                   	pop    %ebp
80108998:	c3                   	ret    

80108999 <shm_close>:


int shm_close(int id) {
80108999:	55                   	push   %ebp
8010899a:	89 e5                	mov    %esp,%ebp
8010899c:	83 ec 18             	sub    $0x18,%esp
//you write this too!

  initlock(&(shm_table.lock), "SHM lock");
8010899f:	83 ec 08             	sub    $0x8,%esp
801089a2:	68 42 92 10 80       	push   $0x80109242
801089a7:	68 40 77 11 80       	push   $0x80117740
801089ac:	e8 fc c5 ff ff       	call   80104fad <initlock>
801089b1:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
801089b4:	83 ec 0c             	sub    $0xc,%esp
801089b7:	68 40 77 11 80       	push   $0x80117740
801089bc:	e8 0e c6 ff ff       	call   80104fcf <acquire>
801089c1:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i< 64; i++) {
801089c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089cb:	e9 8a 00 00 00       	jmp    80108a5a <shm_close+0xc1>
	if (shm_table.shm_pages[i].id == id)
801089d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089d3:	89 d0                	mov    %edx,%eax
801089d5:	01 c0                	add    %eax,%eax
801089d7:	01 d0                	add    %edx,%eax
801089d9:	c1 e0 02             	shl    $0x2,%eax
801089dc:	05 74 77 11 80       	add    $0x80117774,%eax
801089e1:	8b 10                	mov    (%eax),%edx
801089e3:	8b 45 08             	mov    0x8(%ebp),%eax
801089e6:	39 c2                	cmp    %eax,%edx
801089e8:	75 6c                	jne    80108a56 <shm_close+0xbd>
	{
	  shm_table.shm_pages[i].refcnt -= 1;
801089ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089ed:	89 d0                	mov    %edx,%eax
801089ef:	01 c0                	add    %eax,%eax
801089f1:	01 d0                	add    %edx,%eax
801089f3:	c1 e0 02             	shl    $0x2,%eax
801089f6:	05 7c 77 11 80       	add    $0x8011777c,%eax
801089fb:	8b 00                	mov    (%eax),%eax
801089fd:	8d 48 ff             	lea    -0x1(%eax),%ecx
80108a00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a03:	89 d0                	mov    %edx,%eax
80108a05:	01 c0                	add    %eax,%eax
80108a07:	01 d0                	add    %edx,%eax
80108a09:	c1 e0 02             	shl    $0x2,%eax
80108a0c:	05 7c 77 11 80       	add    $0x8011777c,%eax
80108a11:	89 08                	mov    %ecx,(%eax)
	  if (shm_table.shm_pages[i].refcnt == 0)
80108a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a16:	89 d0                	mov    %edx,%eax
80108a18:	01 c0                	add    %eax,%eax
80108a1a:	01 d0                	add    %edx,%eax
80108a1c:	c1 e0 02             	shl    $0x2,%eax
80108a1f:	05 7c 77 11 80       	add    $0x8011777c,%eax
80108a24:	8b 00                	mov    (%eax),%eax
80108a26:	85 c0                	test   %eax,%eax
80108a28:	75 3c                	jne    80108a66 <shm_close+0xcd>
	  {
	    cprintf("CLEARING ENTRY WITH ID %d\n", id);
80108a2a:	83 ec 08             	sub    $0x8,%esp
80108a2d:	ff 75 08             	pushl  0x8(%ebp)
80108a30:	68 7f 92 10 80       	push   $0x8010927f
80108a35:	e8 c6 79 ff ff       	call   80100400 <cprintf>
80108a3a:	83 c4 10             	add    $0x10,%esp
	    shm_table.shm_pages[i].id = 0;
80108a3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a40:	89 d0                	mov    %edx,%eax
80108a42:	01 c0                	add    %eax,%eax
80108a44:	01 d0                	add    %edx,%eax
80108a46:	c1 e0 02             	shl    $0x2,%eax
80108a49:	05 74 77 11 80       	add    $0x80117774,%eax
80108a4e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	  }
	break;
80108a54:	eb 10                	jmp    80108a66 <shm_close+0xcd>
int shm_close(int id) {
//you write this too!

  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (int i = 0; i< 64; i++) {
80108a56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a5a:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80108a5e:	0f 8e 6c ff ff ff    	jle    801089d0 <shm_close+0x37>
80108a64:	eb 01                	jmp    80108a67 <shm_close+0xce>
	  if (shm_table.shm_pages[i].refcnt == 0)
	  {
	    cprintf("CLEARING ENTRY WITH ID %d\n", id);
	    shm_table.shm_pages[i].id = 0;
	  }
	break;
80108a66:	90                   	nop
	}
  }
  release(&(shm_table.lock));
80108a67:	83 ec 0c             	sub    $0xc,%esp
80108a6a:	68 40 77 11 80       	push   $0x80117740
80108a6f:	e8 c9 c5 ff ff       	call   8010503d <release>
80108a74:	83 c4 10             	add    $0x10,%esp



return 0; //added to remove compiler warning -- you should decide what to return
80108a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a7c:	c9                   	leave  
80108a7d:	c3                   	ret    
