
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
8010002d:	b8 e8 38 10 80       	mov    $0x801038e8,%eax
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
8010003d:	68 80 85 10 80       	push   $0x80108580
80100042:	68 40 c6 10 80       	push   $0x8010c640
80100047:	e8 ba 4f 00 00       	call   80105006 <initlock>
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
8010008b:	68 87 85 10 80       	push   $0x80108587
80100090:	50                   	push   %eax
80100091:	e8 13 4e 00 00       	call   80104ea9 <initsleeplock>
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
801000ce:	e8 55 4f 00 00       	call   80105028 <acquire>
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
8010010d:	e8 84 4f 00 00       	call   80105096 <release>
80100112:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	83 c0 0c             	add    $0xc,%eax
8010011b:	83 ec 0c             	sub    $0xc,%esp
8010011e:	50                   	push   %eax
8010011f:	e8 c1 4d 00 00       	call   80104ee5 <acquiresleep>
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
8010018e:	e8 03 4f 00 00       	call   80105096 <release>
80100193:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	83 c0 0c             	add    $0xc,%eax
8010019c:	83 ec 0c             	sub    $0xc,%esp
8010019f:	50                   	push   %eax
801001a0:	e8 40 4d 00 00       	call   80104ee5 <acquiresleep>
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
801001c2:	68 8e 85 10 80       	push   $0x8010858e
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
801001fa:	e8 e8 27 00 00       	call   801029e7 <iderw>
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
80100217:	e8 7b 4d 00 00       	call   80104f97 <holdingsleep>
8010021c:	83 c4 10             	add    $0x10,%esp
8010021f:	85 c0                	test   %eax,%eax
80100221:	75 0d                	jne    80100230 <bwrite+0x29>
    panic("bwrite");
80100223:	83 ec 0c             	sub    $0xc,%esp
80100226:	68 9f 85 10 80       	push   $0x8010859f
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
80100245:	e8 9d 27 00 00       	call   801029e7 <iderw>
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
80100260:	e8 32 4d 00 00       	call   80104f97 <holdingsleep>
80100265:	83 c4 10             	add    $0x10,%esp
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 0d                	jne    80100279 <brelse+0x29>
    panic("brelse");
8010026c:	83 ec 0c             	sub    $0xc,%esp
8010026f:	68 a6 85 10 80       	push   $0x801085a6
80100274:	e8 27 03 00 00       	call   801005a0 <panic>

  releasesleep(&b->lock);
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	83 c0 0c             	add    $0xc,%eax
8010027f:	83 ec 0c             	sub    $0xc,%esp
80100282:	50                   	push   %eax
80100283:	e8 c1 4c 00 00       	call   80104f49 <releasesleep>
80100288:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028b:	83 ec 0c             	sub    $0xc,%esp
8010028e:	68 40 c6 10 80       	push   $0x8010c640
80100293:	e8 90 4d 00 00       	call   80105028 <acquire>
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
80100303:	e8 8e 4d 00 00       	call   80105096 <release>
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
8010041c:	e8 07 4c 00 00       	call   80105028 <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 ad 85 10 80       	push   $0x801085ad
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
80100507:	c7 45 ec b6 85 10 80 	movl   $0x801085b6,-0x14(%ebp)
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
80100595:	e8 fc 4a 00 00       	call   80105096 <release>
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
801005b5:	e8 bc 2a 00 00       	call   80103076 <lapicid>
801005ba:	83 ec 08             	sub    $0x8,%esp
801005bd:	50                   	push   %eax
801005be:	68 bd 85 10 80       	push   $0x801085bd
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
801005dd:	68 d1 85 10 80       	push   $0x801085d1
801005e2:	e8 19 fe ff ff       	call   80100400 <cprintf>
801005e7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ea:	83 ec 08             	sub    $0x8,%esp
801005ed:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f0:	50                   	push   %eax
801005f1:	8d 45 08             	lea    0x8(%ebp),%eax
801005f4:	50                   	push   %eax
801005f5:	e8 ee 4a 00 00       	call   801050e8 <getcallerpcs>
801005fa:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100604:	eb 1c                	jmp    80100622 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100609:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060d:	83 ec 08             	sub    $0x8,%esp
80100610:	50                   	push   %eax
80100611:	68 d3 85 10 80       	push   $0x801085d3
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
801006fd:	68 d7 85 10 80       	push   $0x801085d7
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
8010072a:	e8 2f 4c 00 00       	call   8010535e <memmove>
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
80100754:	e8 46 4b 00 00       	call   8010529f <memset>
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
801007e9:	e8 81 64 00 00       	call   80106c6f <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	6a 20                	push   $0x20
801007f6:	e8 74 64 00 00       	call   80106c6f <uartputc>
801007fb:	83 c4 10             	add    $0x10,%esp
801007fe:	83 ec 0c             	sub    $0xc,%esp
80100801:	6a 08                	push   $0x8
80100803:	e8 67 64 00 00       	call   80106c6f <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	eb 0e                	jmp    8010081b <consputc+0x56>
  } else
    uartputc(c);
8010080d:	83 ec 0c             	sub    $0xc,%esp
80100810:	ff 75 08             	pushl  0x8(%ebp)
80100813:	e8 57 64 00 00       	call   80106c6f <uartputc>
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
80100841:	e8 e2 47 00 00       	call   80105028 <acquire>
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
80100989:	e8 61 43 00 00       	call   80104cef <wakeup>
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
801009ac:	e8 e5 46 00 00       	call   80105096 <release>
801009b1:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b8:	74 05                	je     801009bf <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
801009ba:	e8 ee 43 00 00       	call   80104dad <procdump>
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
801009ce:	e8 db 11 00 00       	call   80101bae <iunlock>
801009d3:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009dc:	83 ec 0c             	sub    $0xc,%esp
801009df:	68 a0 b5 10 80       	push   $0x8010b5a0
801009e4:	e8 3f 46 00 00       	call   80105028 <acquire>
801009e9:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ec:	e9 ab 00 00 00       	jmp    80100a9c <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009f1:	e8 22 39 00 00       	call   80104318 <myproc>
801009f6:	8b 40 24             	mov    0x24(%eax),%eax
801009f9:	85 c0                	test   %eax,%eax
801009fb:	74 28                	je     80100a25 <consoleread+0x63>
        release(&cons.lock);
801009fd:	83 ec 0c             	sub    $0xc,%esp
80100a00:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a05:	e8 8c 46 00 00       	call   80105096 <release>
80100a0a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0d:	83 ec 0c             	sub    $0xc,%esp
80100a10:	ff 75 08             	pushl  0x8(%ebp)
80100a13:	e8 83 10 00 00       	call   80101a9b <ilock>
80100a18:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a20:	e9 ab 00 00 00       	jmp    80100ad0 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
80100a25:	83 ec 08             	sub    $0x8,%esp
80100a28:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a2d:	68 20 10 11 80       	push   $0x80111020
80100a32:	e8 cf 41 00 00       	call   80104c06 <sleep>
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
80100ab0:	e8 e1 45 00 00       	call   80105096 <release>
80100ab5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab8:	83 ec 0c             	sub    $0xc,%esp
80100abb:	ff 75 08             	pushl  0x8(%ebp)
80100abe:	e8 d8 0f 00 00       	call   80101a9b <ilock>
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
80100ade:	e8 cb 10 00 00       	call   80101bae <iunlock>
80100ae3:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 a0 b5 10 80       	push   $0x8010b5a0
80100aee:	e8 35 45 00 00       	call   80105028 <acquire>
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
80100b30:	e8 61 45 00 00       	call   80105096 <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 58 0f 00 00       	call   80101a9b <ilock>
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
80100b54:	68 ea 85 10 80       	push   $0x801085ea
80100b59:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b5e:	e8 a3 44 00 00       	call   80105006 <initlock>
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
80100b8b:	e8 1f 20 00 00       	call   80102baf <ioapicenable>
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
80100b9f:	e8 74 37 00 00       	call   80104318 <myproc>
80100ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba7:	e8 14 2a 00 00       	call   801035c0 <begin_op>

  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 24 1a 00 00       	call   801025db <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 1f                	jne    80100be2 <exec+0x4c>
    end_op();
80100bc3:	e8 84 2a 00 00       	call   8010364c <end_op>
    cprintf("exec: fail\n");
80100bc8:	83 ec 0c             	sub    $0xc,%esp
80100bcb:	68 f2 85 10 80       	push   $0x801085f2
80100bd0:	e8 2b f8 ff ff       	call   80100400 <cprintf>
80100bd5:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdd:	e9 7c 04 00 00       	jmp    8010105e <exec+0x4c8>
  }
  ilock(ip);
80100be2:	83 ec 0c             	sub    $0xc,%esp
80100be5:	ff 75 d8             	pushl  -0x28(%ebp)
80100be8:	e8 ae 0e 00 00       	call   80101a9b <ilock>
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
80100c05:	e8 82 13 00 00       	call   80101f8c <readi>
80100c0a:	83 c4 10             	add    $0x10,%esp
80100c0d:	83 f8 34             	cmp    $0x34,%eax
80100c10:	0f 85 f1 03 00 00    	jne    80101007 <exec+0x471>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c21:	0f 85 e3 03 00 00    	jne    8010100a <exec+0x474>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c27:	e8 3f 70 00 00       	call   80107c6b <setupkvm>
80100c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c33:	0f 84 d4 03 00 00    	je     8010100d <exec+0x477>
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
80100c65:	e8 22 13 00 00       	call   80101f8c <readi>
80100c6a:	83 c4 10             	add    $0x10,%esp
80100c6d:	83 f8 20             	cmp    $0x20,%eax
80100c70:	0f 85 9a 03 00 00    	jne    80101010 <exec+0x47a>
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
80100c93:	0f 82 7a 03 00 00    	jb     80101013 <exec+0x47d>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c99:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c9f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca5:	01 c2                	add    %eax,%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	39 c2                	cmp    %eax,%edx
80100caf:	0f 82 61 03 00 00    	jb     80101016 <exec+0x480>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc1:	01 d0                	add    %edx,%eax
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 e0             	pushl  -0x20(%ebp)
80100cca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccd:	e8 3e 73 00 00       	call   80108010 <allocuvm>
80100cd2:	83 c4 10             	add    $0x10,%esp
80100cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdc:	0f 84 37 03 00 00    	je     80101019 <exec+0x483>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ce8:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	0f 85 27 03 00 00    	jne    8010101c <exec+0x486>
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
80100d13:	e8 2b 72 00 00       	call   80107f43 <loaduvm>
80100d18:	83 c4 20             	add    $0x20,%esp
80100d1b:	85 c0                	test   %eax,%eax
80100d1d:	0f 88 fc 02 00 00    	js     8010101f <exec+0x489>
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
80100d4c:	e8 7b 0f 00 00       	call   80101ccc <iunlockput>
80100d51:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d54:	e8 f3 28 00 00       	call   8010364c <end_op>
  ip = 0;
80100d59:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d63:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d73:	05 00 20 00 00       	add    $0x2000,%eax
80100d78:	83 ec 04             	sub    $0x4,%esp
80100d7b:	50                   	push   %eax
80100d7c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d7f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d82:	e8 89 72 00 00       	call   80108010 <allocuvm>
80100d87:	83 c4 10             	add    $0x10,%esp
80100d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d91:	0f 84 8b 02 00 00    	je     80101022 <exec+0x48c>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d9f:	83 ec 08             	sub    $0x8,%esp
80100da2:	50                   	push   %eax
80100da3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da6:	e8 ed 74 00 00       	call   80108298 <clearpteu>
80100dab:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)

   cprintf("KERNBASE: %x\n", KERNBASE);
80100db4:	83 ec 08             	sub    $0x8,%esp
80100db7:	68 00 00 00 80       	push   $0x80000000
80100dbc:	68 fe 85 10 80       	push   $0x801085fe
80100dc1:	e8 3a f6 ff ff       	call   80100400 <cprintf>
80100dc6:	83 c4 10             	add    $0x10,%esp
   //cprintf("PGSIZE: %d\n", PGSIZE);

   curproc->last_page = allocuvm(pgdir, KERNBASE - PGSIZE , KERNBASE-4);
80100dc9:	83 ec 04             	sub    $0x4,%esp
80100dcc:	68 fc ff ff 7f       	push   $0x7ffffffc
80100dd1:	68 00 f0 ff 7f       	push   $0x7ffff000
80100dd6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd9:	e8 32 72 00 00       	call   80108010 <allocuvm>
80100dde:	83 c4 10             	add    $0x10,%esp
80100de1:	89 c2                	mov    %eax,%edx
80100de3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100de6:	89 50 7c             	mov    %edx,0x7c(%eax)
   curproc->bottom_page = curproc->last_page - PGSIZE;
80100de9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dec:	8b 40 7c             	mov    0x7c(%eax),%eax
80100def:	8d 90 00 f0 ff ff    	lea    -0x1000(%eax),%edx
80100df5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100df8:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
   cprintf("LAST_PAGE: %x\n", curproc->last_page);
80100dfe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e01:	8b 40 7c             	mov    0x7c(%eax),%eax
80100e04:	83 ec 08             	sub    $0x8,%esp
80100e07:	50                   	push   %eax
80100e08:	68 0c 86 10 80       	push   $0x8010860c
80100e0d:	e8 ee f5 ff ff       	call   80100400 <cprintf>
80100e12:	83 c4 10             	add    $0x10,%esp
   cprintf("BOTTOM_PAGE: %x\n", curproc->bottom_page);
80100e15:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e18:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80100e1e:	83 ec 08             	sub    $0x8,%esp
80100e21:	50                   	push   %eax
80100e22:	68 1b 86 10 80       	push   $0x8010861b
80100e27:	e8 d4 f5 ff ff       	call   80100400 <cprintf>
80100e2c:	83 c4 10             	add    $0x10,%esp

//   sp = curproc->last_page;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e2f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e36:	e9 93 00 00 00       	jmp    80100ece <exec+0x338>
    if(argc >= MAXARG)
80100e3b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e3f:	0f 87 e0 01 00 00    	ja     80101025 <exec+0x48f>
      goto bad;
    sp = (sp - (strlen(argv[argc]) )) & ~3;
80100e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e52:	01 d0                	add    %edx,%eax
80100e54:	8b 00                	mov    (%eax),%eax
80100e56:	83 ec 0c             	sub    $0xc,%esp
80100e59:	50                   	push   %eax
80100e5a:	e8 8d 46 00 00       	call   801054ec <strlen>
80100e5f:	83 c4 10             	add    $0x10,%esp
80100e62:	89 c2                	mov    %eax,%edx
80100e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e67:	29 d0                	sub    %edx,%eax
80100e69:	83 e0 fc             	and    $0xfffffffc,%eax
80100e6c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e72:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e79:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e7c:	01 d0                	add    %edx,%eax
80100e7e:	8b 00                	mov    (%eax),%eax
80100e80:	83 ec 0c             	sub    $0xc,%esp
80100e83:	50                   	push   %eax
80100e84:	e8 63 46 00 00       	call   801054ec <strlen>
80100e89:	83 c4 10             	add    $0x10,%esp
80100e8c:	83 c0 01             	add    $0x1,%eax
80100e8f:	89 c1                	mov    %eax,%ecx
80100e91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e9e:	01 d0                	add    %edx,%eax
80100ea0:	8b 00                	mov    (%eax),%eax
80100ea2:	51                   	push   %ecx
80100ea3:	50                   	push   %eax
80100ea4:	ff 75 dc             	pushl  -0x24(%ebp)
80100ea7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eaa:	e8 88 75 00 00       	call   80108437 <copyout>
80100eaf:	83 c4 10             	add    $0x10,%esp
80100eb2:	85 c0                	test   %eax,%eax
80100eb4:	0f 88 6e 01 00 00    	js     80101028 <exec+0x492>
      goto bad;
    ustack[3+argc] = sp;
80100eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebd:	8d 50 03             	lea    0x3(%eax),%edx
80100ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec3:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
   cprintf("BOTTOM_PAGE: %x\n", curproc->bottom_page);

//   sp = curproc->last_page;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100eca:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ece:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100edb:	01 d0                	add    %edx,%eax
80100edd:	8b 00                	mov    (%eax),%eax
80100edf:	85 c0                	test   %eax,%eax
80100ee1:	0f 85 54 ff ff ff    	jne    80100e3b <exec+0x2a5>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eea:	83 c0 03             	add    $0x3,%eax
80100eed:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ef4:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ef8:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eff:	ff ff ff 
  ustack[1] = argc;
80100f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f05:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f0e:	83 c0 01             	add    $0x1,%eax
80100f11:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f1b:	29 d0                	sub    %edx,%eax
80100f1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f26:	83 c0 04             	add    $0x4,%eax
80100f29:	c1 e0 02             	shl    $0x2,%eax
80100f2c:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f32:	83 c0 04             	add    $0x4,%eax
80100f35:	c1 e0 02             	shl    $0x2,%eax
80100f38:	50                   	push   %eax
80100f39:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f3f:	50                   	push   %eax
80100f40:	ff 75 dc             	pushl  -0x24(%ebp)
80100f43:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f46:	e8 ec 74 00 00       	call   80108437 <copyout>
80100f4b:	83 c4 10             	add    $0x10,%esp
80100f4e:	85 c0                	test   %eax,%eax
80100f50:	0f 88 d5 00 00 00    	js     8010102b <exec+0x495>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f56:	8b 45 08             	mov    0x8(%ebp),%eax
80100f59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f62:	eb 17                	jmp    80100f7b <exec+0x3e5>
    if(*s == '/')
80100f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f67:	0f b6 00             	movzbl (%eax),%eax
80100f6a:	3c 2f                	cmp    $0x2f,%al
80100f6c:	75 09                	jne    80100f77 <exec+0x3e1>
      last = s+1;
80100f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f71:	83 c0 01             	add    $0x1,%eax
80100f74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f77:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7e:	0f b6 00             	movzbl (%eax),%eax
80100f81:	84 c0                	test   %al,%al
80100f83:	75 df                	jne    80100f64 <exec+0x3ce>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f85:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f88:	83 c0 6c             	add    $0x6c,%eax
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	6a 10                	push   $0x10
80100f90:	ff 75 f0             	pushl  -0x10(%ebp)
80100f93:	50                   	push   %eax
80100f94:	e8 09 45 00 00       	call   801054a2 <safestrcpy>
80100f99:	83 c4 10             	add    $0x10,%esp

 
 
  // Commit to the user image.
  cprintf("SP: %x\n", sp);
80100f9c:	83 ec 08             	sub    $0x8,%esp
80100f9f:	ff 75 dc             	pushl  -0x24(%ebp)
80100fa2:	68 2c 86 10 80       	push   $0x8010862c
80100fa7:	e8 54 f4 ff ff       	call   80100400 <cprintf>
80100fac:	83 c4 10             	add    $0x10,%esp
//  cprintf("DIFFERENCE: %d\n", curproc->last_page-sp);
  oldpgdir = curproc->pgdir;
80100faf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb2:	8b 40 04             	mov    0x4(%eax),%eax
80100fb5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100fb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fbb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fbe:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fc1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fc4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fc7:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fc9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fcc:	8b 40 18             	mov    0x18(%eax),%eax
80100fcf:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fd5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100fd8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fdb:	8b 40 18             	mov    0x18(%eax),%eax
80100fde:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fe1:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fe4:	83 ec 0c             	sub    $0xc,%esp
80100fe7:	ff 75 d0             	pushl  -0x30(%ebp)
80100fea:	e8 46 6d 00 00       	call   80107d35 <switchuvm>
80100fef:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ff2:	83 ec 0c             	sub    $0xc,%esp
80100ff5:	ff 75 cc             	pushl  -0x34(%ebp)
80100ff8:	e8 02 72 00 00       	call   801081ff <freevm>
80100ffd:	83 c4 10             	add    $0x10,%esp
  return 0;
80101000:	b8 00 00 00 00       	mov    $0x0,%eax
80101005:	eb 57                	jmp    8010105e <exec+0x4c8>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
80101007:	90                   	nop
80101008:	eb 22                	jmp    8010102c <exec+0x496>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010100a:	90                   	nop
8010100b:	eb 1f                	jmp    8010102c <exec+0x496>

  if((pgdir = setupkvm()) == 0)
    goto bad;
8010100d:	90                   	nop
8010100e:	eb 1c                	jmp    8010102c <exec+0x496>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101010:	90                   	nop
80101011:	eb 19                	jmp    8010102c <exec+0x496>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101013:	90                   	nop
80101014:	eb 16                	jmp    8010102c <exec+0x496>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
80101016:	90                   	nop
80101017:	eb 13                	jmp    8010102c <exec+0x496>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101019:	90                   	nop
8010101a:	eb 10                	jmp    8010102c <exec+0x496>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
8010101c:	90                   	nop
8010101d:	eb 0d                	jmp    8010102c <exec+0x496>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010101f:	90                   	nop
80101020:	eb 0a                	jmp    8010102c <exec+0x496>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101022:	90                   	nop
80101023:	eb 07                	jmp    8010102c <exec+0x496>
//   sp = curproc->last_page;
   
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101025:	90                   	nop
80101026:	eb 04                	jmp    8010102c <exec+0x496>
    sp = (sp - (strlen(argv[argc]) )) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101028:	90                   	nop
80101029:	eb 01                	jmp    8010102c <exec+0x496>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010102b:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010102c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101030:	74 0e                	je     80101040 <exec+0x4aa>
    freevm(pgdir);
80101032:	83 ec 0c             	sub    $0xc,%esp
80101035:	ff 75 d4             	pushl  -0x2c(%ebp)
80101038:	e8 c2 71 00 00       	call   801081ff <freevm>
8010103d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101040:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101044:	74 13                	je     80101059 <exec+0x4c3>
    iunlockput(ip);
80101046:	83 ec 0c             	sub    $0xc,%esp
80101049:	ff 75 d8             	pushl  -0x28(%ebp)
8010104c:	e8 7b 0c 00 00       	call   80101ccc <iunlockput>
80101051:	83 c4 10             	add    $0x10,%esp
    end_op();
80101054:	e8 f3 25 00 00       	call   8010364c <end_op>
  }
  return -1;
80101059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010105e:	c9                   	leave  
8010105f:	c3                   	ret    

80101060 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101060:	55                   	push   %ebp
80101061:	89 e5                	mov    %esp,%ebp
80101063:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101066:	83 ec 08             	sub    $0x8,%esp
80101069:	68 34 86 10 80       	push   $0x80108634
8010106e:	68 40 10 11 80       	push   $0x80111040
80101073:	e8 8e 3f 00 00       	call   80105006 <initlock>
80101078:	83 c4 10             	add    $0x10,%esp
}
8010107b:	90                   	nop
8010107c:	c9                   	leave  
8010107d:	c3                   	ret    

8010107e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010107e:	55                   	push   %ebp
8010107f:	89 e5                	mov    %esp,%ebp
80101081:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101084:	83 ec 0c             	sub    $0xc,%esp
80101087:	68 40 10 11 80       	push   $0x80111040
8010108c:	e8 97 3f 00 00       	call   80105028 <acquire>
80101091:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101094:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
8010109b:	eb 2d                	jmp    801010ca <filealloc+0x4c>
    if(f->ref == 0){
8010109d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a0:	8b 40 04             	mov    0x4(%eax),%eax
801010a3:	85 c0                	test   %eax,%eax
801010a5:	75 1f                	jne    801010c6 <filealloc+0x48>
      f->ref = 1;
801010a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010aa:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010b1:	83 ec 0c             	sub    $0xc,%esp
801010b4:	68 40 10 11 80       	push   $0x80111040
801010b9:	e8 d8 3f 00 00       	call   80105096 <release>
801010be:	83 c4 10             	add    $0x10,%esp
      return f;
801010c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010c4:	eb 23                	jmp    801010e9 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010c6:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010ca:	b8 d4 19 11 80       	mov    $0x801119d4,%eax
801010cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010d2:	72 c9                	jb     8010109d <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 40 10 11 80       	push   $0x80111040
801010dc:	e8 b5 3f 00 00       	call   80105096 <release>
801010e1:	83 c4 10             	add    $0x10,%esp
  return 0;
801010e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010e9:	c9                   	leave  
801010ea:	c3                   	ret    

801010eb <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010eb:	55                   	push   %ebp
801010ec:	89 e5                	mov    %esp,%ebp
801010ee:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010f1:	83 ec 0c             	sub    $0xc,%esp
801010f4:	68 40 10 11 80       	push   $0x80111040
801010f9:	e8 2a 3f 00 00       	call   80105028 <acquire>
801010fe:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101101:	8b 45 08             	mov    0x8(%ebp),%eax
80101104:	8b 40 04             	mov    0x4(%eax),%eax
80101107:	85 c0                	test   %eax,%eax
80101109:	7f 0d                	jg     80101118 <filedup+0x2d>
    panic("filedup");
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	68 3b 86 10 80       	push   $0x8010863b
80101113:	e8 88 f4 ff ff       	call   801005a0 <panic>
  f->ref++;
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 04             	mov    0x4(%eax),%eax
8010111e:	8d 50 01             	lea    0x1(%eax),%edx
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101127:	83 ec 0c             	sub    $0xc,%esp
8010112a:	68 40 10 11 80       	push   $0x80111040
8010112f:	e8 62 3f 00 00       	call   80105096 <release>
80101134:	83 c4 10             	add    $0x10,%esp
  return f;
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010113a:	c9                   	leave  
8010113b:	c3                   	ret    

8010113c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010113c:	55                   	push   %ebp
8010113d:	89 e5                	mov    %esp,%ebp
8010113f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101142:	83 ec 0c             	sub    $0xc,%esp
80101145:	68 40 10 11 80       	push   $0x80111040
8010114a:	e8 d9 3e 00 00       	call   80105028 <acquire>
8010114f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101152:	8b 45 08             	mov    0x8(%ebp),%eax
80101155:	8b 40 04             	mov    0x4(%eax),%eax
80101158:	85 c0                	test   %eax,%eax
8010115a:	7f 0d                	jg     80101169 <fileclose+0x2d>
    panic("fileclose");
8010115c:	83 ec 0c             	sub    $0xc,%esp
8010115f:	68 43 86 10 80       	push   $0x80108643
80101164:	e8 37 f4 ff ff       	call   801005a0 <panic>
  if(--f->ref > 0){
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	8b 40 04             	mov    0x4(%eax),%eax
8010116f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	89 50 04             	mov    %edx,0x4(%eax)
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	8b 40 04             	mov    0x4(%eax),%eax
8010117e:	85 c0                	test   %eax,%eax
80101180:	7e 15                	jle    80101197 <fileclose+0x5b>
    release(&ftable.lock);
80101182:	83 ec 0c             	sub    $0xc,%esp
80101185:	68 40 10 11 80       	push   $0x80111040
8010118a:	e8 07 3f 00 00       	call   80105096 <release>
8010118f:	83 c4 10             	add    $0x10,%esp
80101192:	e9 8b 00 00 00       	jmp    80101222 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
8010119a:	8b 10                	mov    (%eax),%edx
8010119c:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010119f:	8b 50 04             	mov    0x4(%eax),%edx
801011a2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011a5:	8b 50 08             	mov    0x8(%eax),%edx
801011a8:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011ab:	8b 50 0c             	mov    0xc(%eax),%edx
801011ae:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011b1:	8b 50 10             	mov    0x10(%eax),%edx
801011b4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011b7:	8b 40 14             	mov    0x14(%eax),%eax
801011ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011bd:	8b 45 08             	mov    0x8(%ebp),%eax
801011c0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011c7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011d0:	83 ec 0c             	sub    $0xc,%esp
801011d3:	68 40 10 11 80       	push   $0x80111040
801011d8:	e8 b9 3e 00 00       	call   80105096 <release>
801011dd:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011e3:	83 f8 01             	cmp    $0x1,%eax
801011e6:	75 19                	jne    80101201 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011e8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011ec:	0f be d0             	movsbl %al,%edx
801011ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011f2:	83 ec 08             	sub    $0x8,%esp
801011f5:	52                   	push   %edx
801011f6:	50                   	push   %eax
801011f7:	e8 a6 2d 00 00       	call   80103fa2 <pipeclose>
801011fc:	83 c4 10             	add    $0x10,%esp
801011ff:	eb 21                	jmp    80101222 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101201:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101204:	83 f8 02             	cmp    $0x2,%eax
80101207:	75 19                	jne    80101222 <fileclose+0xe6>
    begin_op();
80101209:	e8 b2 23 00 00       	call   801035c0 <begin_op>
    iput(ff.ip);
8010120e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101211:	83 ec 0c             	sub    $0xc,%esp
80101214:	50                   	push   %eax
80101215:	e8 e2 09 00 00       	call   80101bfc <iput>
8010121a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010121d:	e8 2a 24 00 00       	call   8010364c <end_op>
  }
}
80101222:	c9                   	leave  
80101223:	c3                   	ret    

80101224 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101224:	55                   	push   %ebp
80101225:	89 e5                	mov    %esp,%ebp
80101227:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	8b 00                	mov    (%eax),%eax
8010122f:	83 f8 02             	cmp    $0x2,%eax
80101232:	75 40                	jne    80101274 <filestat+0x50>
    ilock(f->ip);
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 40 10             	mov    0x10(%eax),%eax
8010123a:	83 ec 0c             	sub    $0xc,%esp
8010123d:	50                   	push   %eax
8010123e:	e8 58 08 00 00       	call   80101a9b <ilock>
80101243:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 40 10             	mov    0x10(%eax),%eax
8010124c:	83 ec 08             	sub    $0x8,%esp
8010124f:	ff 75 0c             	pushl  0xc(%ebp)
80101252:	50                   	push   %eax
80101253:	e8 ee 0c 00 00       	call   80101f46 <stati>
80101258:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 40 10             	mov    0x10(%eax),%eax
80101261:	83 ec 0c             	sub    $0xc,%esp
80101264:	50                   	push   %eax
80101265:	e8 44 09 00 00       	call   80101bae <iunlock>
8010126a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010126d:	b8 00 00 00 00       	mov    $0x0,%eax
80101272:	eb 05                	jmp    80101279 <filestat+0x55>
  }
  return -1;
80101274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101279:	c9                   	leave  
8010127a:	c3                   	ret    

8010127b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010127b:	55                   	push   %ebp
8010127c:	89 e5                	mov    %esp,%ebp
8010127e:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101288:	84 c0                	test   %al,%al
8010128a:	75 0a                	jne    80101296 <fileread+0x1b>
    return -1;
8010128c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101291:	e9 9b 00 00 00       	jmp    80101331 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 00                	mov    (%eax),%eax
8010129b:	83 f8 01             	cmp    $0x1,%eax
8010129e:	75 1a                	jne    801012ba <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801012a0:	8b 45 08             	mov    0x8(%ebp),%eax
801012a3:	8b 40 0c             	mov    0xc(%eax),%eax
801012a6:	83 ec 04             	sub    $0x4,%esp
801012a9:	ff 75 10             	pushl  0x10(%ebp)
801012ac:	ff 75 0c             	pushl  0xc(%ebp)
801012af:	50                   	push   %eax
801012b0:	e8 94 2e 00 00       	call   80104149 <piperead>
801012b5:	83 c4 10             	add    $0x10,%esp
801012b8:	eb 77                	jmp    80101331 <fileread+0xb6>
  if(f->type == FD_INODE){
801012ba:	8b 45 08             	mov    0x8(%ebp),%eax
801012bd:	8b 00                	mov    (%eax),%eax
801012bf:	83 f8 02             	cmp    $0x2,%eax
801012c2:	75 60                	jne    80101324 <fileread+0xa9>
    ilock(f->ip);
801012c4:	8b 45 08             	mov    0x8(%ebp),%eax
801012c7:	8b 40 10             	mov    0x10(%eax),%eax
801012ca:	83 ec 0c             	sub    $0xc,%esp
801012cd:	50                   	push   %eax
801012ce:	e8 c8 07 00 00       	call   80101a9b <ilock>
801012d3:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012d9:	8b 45 08             	mov    0x8(%ebp),%eax
801012dc:	8b 50 14             	mov    0x14(%eax),%edx
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 40 10             	mov    0x10(%eax),%eax
801012e5:	51                   	push   %ecx
801012e6:	52                   	push   %edx
801012e7:	ff 75 0c             	pushl  0xc(%ebp)
801012ea:	50                   	push   %eax
801012eb:	e8 9c 0c 00 00       	call   80101f8c <readi>
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012fa:	7e 11                	jle    8010130d <fileread+0x92>
      f->off += r;
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 50 14             	mov    0x14(%eax),%edx
80101302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101305:	01 c2                	add    %eax,%edx
80101307:	8b 45 08             	mov    0x8(%ebp),%eax
8010130a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010130d:	8b 45 08             	mov    0x8(%ebp),%eax
80101310:	8b 40 10             	mov    0x10(%eax),%eax
80101313:	83 ec 0c             	sub    $0xc,%esp
80101316:	50                   	push   %eax
80101317:	e8 92 08 00 00       	call   80101bae <iunlock>
8010131c:	83 c4 10             	add    $0x10,%esp
    return r;
8010131f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101322:	eb 0d                	jmp    80101331 <fileread+0xb6>
  }
  panic("fileread");
80101324:	83 ec 0c             	sub    $0xc,%esp
80101327:	68 4d 86 10 80       	push   $0x8010864d
8010132c:	e8 6f f2 ff ff       	call   801005a0 <panic>
}
80101331:	c9                   	leave  
80101332:	c3                   	ret    

80101333 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101333:	55                   	push   %ebp
80101334:	89 e5                	mov    %esp,%ebp
80101336:	53                   	push   %ebx
80101337:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010133a:	8b 45 08             	mov    0x8(%ebp),%eax
8010133d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101341:	84 c0                	test   %al,%al
80101343:	75 0a                	jne    8010134f <filewrite+0x1c>
    return -1;
80101345:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010134a:	e9 1b 01 00 00       	jmp    8010146a <filewrite+0x137>
  if(f->type == FD_PIPE)
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	8b 00                	mov    (%eax),%eax
80101354:	83 f8 01             	cmp    $0x1,%eax
80101357:	75 1d                	jne    80101376 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101359:	8b 45 08             	mov    0x8(%ebp),%eax
8010135c:	8b 40 0c             	mov    0xc(%eax),%eax
8010135f:	83 ec 04             	sub    $0x4,%esp
80101362:	ff 75 10             	pushl  0x10(%ebp)
80101365:	ff 75 0c             	pushl  0xc(%ebp)
80101368:	50                   	push   %eax
80101369:	e8 de 2c 00 00       	call   8010404c <pipewrite>
8010136e:	83 c4 10             	add    $0x10,%esp
80101371:	e9 f4 00 00 00       	jmp    8010146a <filewrite+0x137>
  if(f->type == FD_INODE){
80101376:	8b 45 08             	mov    0x8(%ebp),%eax
80101379:	8b 00                	mov    (%eax),%eax
8010137b:	83 f8 02             	cmp    $0x2,%eax
8010137e:	0f 85 d9 00 00 00    	jne    8010145d <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101384:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010138b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101392:	e9 a3 00 00 00       	jmp    8010143a <filewrite+0x107>
      int n1 = n - i;
80101397:	8b 45 10             	mov    0x10(%ebp),%eax
8010139a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010139d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013a6:	7e 06                	jle    801013ae <filewrite+0x7b>
        n1 = max;
801013a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013ae:	e8 0d 22 00 00       	call   801035c0 <begin_op>
      ilock(f->ip);
801013b3:	8b 45 08             	mov    0x8(%ebp),%eax
801013b6:	8b 40 10             	mov    0x10(%eax),%eax
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	50                   	push   %eax
801013bd:	e8 d9 06 00 00       	call   80101a9b <ilock>
801013c2:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013c5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013c8:	8b 45 08             	mov    0x8(%ebp),%eax
801013cb:	8b 50 14             	mov    0x14(%eax),%edx
801013ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801013d4:	01 c3                	add    %eax,%ebx
801013d6:	8b 45 08             	mov    0x8(%ebp),%eax
801013d9:	8b 40 10             	mov    0x10(%eax),%eax
801013dc:	51                   	push   %ecx
801013dd:	52                   	push   %edx
801013de:	53                   	push   %ebx
801013df:	50                   	push   %eax
801013e0:	e8 fe 0c 00 00       	call   801020e3 <writei>
801013e5:	83 c4 10             	add    $0x10,%esp
801013e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013eb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ef:	7e 11                	jle    80101402 <filewrite+0xcf>
        f->off += r;
801013f1:	8b 45 08             	mov    0x8(%ebp),%eax
801013f4:	8b 50 14             	mov    0x14(%eax),%edx
801013f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013fa:	01 c2                	add    %eax,%edx
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101402:	8b 45 08             	mov    0x8(%ebp),%eax
80101405:	8b 40 10             	mov    0x10(%eax),%eax
80101408:	83 ec 0c             	sub    $0xc,%esp
8010140b:	50                   	push   %eax
8010140c:	e8 9d 07 00 00       	call   80101bae <iunlock>
80101411:	83 c4 10             	add    $0x10,%esp
      end_op();
80101414:	e8 33 22 00 00       	call   8010364c <end_op>

      if(r < 0)
80101419:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010141d:	78 29                	js     80101448 <filewrite+0x115>
        break;
      if(r != n1)
8010141f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101422:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101425:	74 0d                	je     80101434 <filewrite+0x101>
        panic("short filewrite");
80101427:	83 ec 0c             	sub    $0xc,%esp
8010142a:	68 56 86 10 80       	push   $0x80108656
8010142f:	e8 6c f1 ff ff       	call   801005a0 <panic>
      i += r;
80101434:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101437:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010143a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101440:	0f 8c 51 ff ff ff    	jl     80101397 <filewrite+0x64>
80101446:	eb 01                	jmp    80101449 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101448:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010144f:	75 05                	jne    80101456 <filewrite+0x123>
80101451:	8b 45 10             	mov    0x10(%ebp),%eax
80101454:	eb 14                	jmp    8010146a <filewrite+0x137>
80101456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010145b:	eb 0d                	jmp    8010146a <filewrite+0x137>
  }
  panic("filewrite");
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	68 66 86 10 80       	push   $0x80108666
80101465:	e8 36 f1 ff ff       	call   801005a0 <panic>
}
8010146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010146d:	c9                   	leave  
8010146e:	c3                   	ret    

8010146f <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010146f:	55                   	push   %ebp
80101470:	89 e5                	mov    %esp,%ebp
80101472:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101475:	8b 45 08             	mov    0x8(%ebp),%eax
80101478:	83 ec 08             	sub    $0x8,%esp
8010147b:	6a 01                	push   $0x1
8010147d:	50                   	push   %eax
8010147e:	e8 4b ed ff ff       	call   801001ce <bread>
80101483:	83 c4 10             	add    $0x10,%esp
80101486:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148c:	83 c0 5c             	add    $0x5c,%eax
8010148f:	83 ec 04             	sub    $0x4,%esp
80101492:	6a 1c                	push   $0x1c
80101494:	50                   	push   %eax
80101495:	ff 75 0c             	pushl  0xc(%ebp)
80101498:	e8 c1 3e 00 00       	call   8010535e <memmove>
8010149d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014a0:	83 ec 0c             	sub    $0xc,%esp
801014a3:	ff 75 f4             	pushl  -0xc(%ebp)
801014a6:	e8 a5 ed ff ff       	call   80100250 <brelse>
801014ab:	83 c4 10             	add    $0x10,%esp
}
801014ae:	90                   	nop
801014af:	c9                   	leave  
801014b0:	c3                   	ret    

801014b1 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014b1:	55                   	push   %ebp
801014b2:	89 e5                	mov    %esp,%ebp
801014b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014b7:	8b 55 0c             	mov    0xc(%ebp),%edx
801014ba:	8b 45 08             	mov    0x8(%ebp),%eax
801014bd:	83 ec 08             	sub    $0x8,%esp
801014c0:	52                   	push   %edx
801014c1:	50                   	push   %eax
801014c2:	e8 07 ed ff ff       	call   801001ce <bread>
801014c7:	83 c4 10             	add    $0x10,%esp
801014ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d0:	83 c0 5c             	add    $0x5c,%eax
801014d3:	83 ec 04             	sub    $0x4,%esp
801014d6:	68 00 02 00 00       	push   $0x200
801014db:	6a 00                	push   $0x0
801014dd:	50                   	push   %eax
801014de:	e8 bc 3d 00 00       	call   8010529f <memset>
801014e3:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014e6:	83 ec 0c             	sub    $0xc,%esp
801014e9:	ff 75 f4             	pushl  -0xc(%ebp)
801014ec:	e8 07 23 00 00       	call   801037f8 <log_write>
801014f1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014f4:	83 ec 0c             	sub    $0xc,%esp
801014f7:	ff 75 f4             	pushl  -0xc(%ebp)
801014fa:	e8 51 ed ff ff       	call   80100250 <brelse>
801014ff:	83 c4 10             	add    $0x10,%esp
}
80101502:	90                   	nop
80101503:	c9                   	leave  
80101504:	c3                   	ret    

80101505 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101505:	55                   	push   %ebp
80101506:	89 e5                	mov    %esp,%ebp
80101508:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010150b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101512:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101519:	e9 13 01 00 00       	jmp    80101631 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010151e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101521:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101527:	85 c0                	test   %eax,%eax
80101529:	0f 48 c2             	cmovs  %edx,%eax
8010152c:	c1 f8 0c             	sar    $0xc,%eax
8010152f:	89 c2                	mov    %eax,%edx
80101531:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101536:	01 d0                	add    %edx,%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	50                   	push   %eax
8010153c:	ff 75 08             	pushl  0x8(%ebp)
8010153f:	e8 8a ec ff ff       	call   801001ce <bread>
80101544:	83 c4 10             	add    $0x10,%esp
80101547:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101551:	e9 a6 00 00 00       	jmp    801015fc <balloc+0xf7>
      m = 1 << (bi % 8);
80101556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101559:	99                   	cltd   
8010155a:	c1 ea 1d             	shr    $0x1d,%edx
8010155d:	01 d0                	add    %edx,%eax
8010155f:	83 e0 07             	and    $0x7,%eax
80101562:	29 d0                	sub    %edx,%eax
80101564:	ba 01 00 00 00       	mov    $0x1,%edx
80101569:	89 c1                	mov    %eax,%ecx
8010156b:	d3 e2                	shl    %cl,%edx
8010156d:	89 d0                	mov    %edx,%eax
8010156f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101575:	8d 50 07             	lea    0x7(%eax),%edx
80101578:	85 c0                	test   %eax,%eax
8010157a:	0f 48 c2             	cmovs  %edx,%eax
8010157d:	c1 f8 03             	sar    $0x3,%eax
80101580:	89 c2                	mov    %eax,%edx
80101582:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101585:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010158a:	0f b6 c0             	movzbl %al,%eax
8010158d:	23 45 e8             	and    -0x18(%ebp),%eax
80101590:	85 c0                	test   %eax,%eax
80101592:	75 64                	jne    801015f8 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
80101594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101597:	8d 50 07             	lea    0x7(%eax),%edx
8010159a:	85 c0                	test   %eax,%eax
8010159c:	0f 48 c2             	cmovs  %edx,%eax
8010159f:	c1 f8 03             	sar    $0x3,%eax
801015a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015a5:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015aa:	89 d1                	mov    %edx,%ecx
801015ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015af:	09 ca                	or     %ecx,%edx
801015b1:	89 d1                	mov    %edx,%ecx
801015b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015b6:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015ba:	83 ec 0c             	sub    $0xc,%esp
801015bd:	ff 75 ec             	pushl  -0x14(%ebp)
801015c0:	e8 33 22 00 00       	call   801037f8 <log_write>
801015c5:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015c8:	83 ec 0c             	sub    $0xc,%esp
801015cb:	ff 75 ec             	pushl  -0x14(%ebp)
801015ce:	e8 7d ec ff ff       	call   80100250 <brelse>
801015d3:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015dc:	01 c2                	add    %eax,%edx
801015de:	8b 45 08             	mov    0x8(%ebp),%eax
801015e1:	83 ec 08             	sub    $0x8,%esp
801015e4:	52                   	push   %edx
801015e5:	50                   	push   %eax
801015e6:	e8 c6 fe ff ff       	call   801014b1 <bzero>
801015eb:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f4:	01 d0                	add    %edx,%eax
801015f6:	eb 57                	jmp    8010164f <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015fc:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101603:	7f 17                	jg     8010161c <balloc+0x117>
80101605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160b:	01 d0                	add    %edx,%eax
8010160d:	89 c2                	mov    %eax,%edx
8010160f:	a1 40 1a 11 80       	mov    0x80111a40,%eax
80101614:	39 c2                	cmp    %eax,%edx
80101616:	0f 82 3a ff ff ff    	jb     80101556 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010161c:	83 ec 0c             	sub    $0xc,%esp
8010161f:	ff 75 ec             	pushl  -0x14(%ebp)
80101622:	e8 29 ec ff ff       	call   80100250 <brelse>
80101627:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010162a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101631:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
80101637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010163a:	39 c2                	cmp    %eax,%edx
8010163c:	0f 87 dc fe ff ff    	ja     8010151e <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101642:	83 ec 0c             	sub    $0xc,%esp
80101645:	68 70 86 10 80       	push   $0x80108670
8010164a:	e8 51 ef ff ff       	call   801005a0 <panic>
}
8010164f:	c9                   	leave  
80101650:	c3                   	ret    

80101651 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101651:	55                   	push   %ebp
80101652:	89 e5                	mov    %esp,%ebp
80101654:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101657:	83 ec 08             	sub    $0x8,%esp
8010165a:	68 40 1a 11 80       	push   $0x80111a40
8010165f:	ff 75 08             	pushl  0x8(%ebp)
80101662:	e8 08 fe ff ff       	call   8010146f <readsb>
80101667:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010166a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010166d:	c1 e8 0c             	shr    $0xc,%eax
80101670:	89 c2                	mov    %eax,%edx
80101672:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101677:	01 c2                	add    %eax,%edx
80101679:	8b 45 08             	mov    0x8(%ebp),%eax
8010167c:	83 ec 08             	sub    $0x8,%esp
8010167f:	52                   	push   %edx
80101680:	50                   	push   %eax
80101681:	e8 48 eb ff ff       	call   801001ce <bread>
80101686:	83 c4 10             	add    $0x10,%esp
80101689:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010168c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010168f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101694:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010169a:	99                   	cltd   
8010169b:	c1 ea 1d             	shr    $0x1d,%edx
8010169e:	01 d0                	add    %edx,%eax
801016a0:	83 e0 07             	and    $0x7,%eax
801016a3:	29 d0                	sub    %edx,%eax
801016a5:	ba 01 00 00 00       	mov    $0x1,%edx
801016aa:	89 c1                	mov    %eax,%ecx
801016ac:	d3 e2                	shl    %cl,%edx
801016ae:	89 d0                	mov    %edx,%eax
801016b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b6:	8d 50 07             	lea    0x7(%eax),%edx
801016b9:	85 c0                	test   %eax,%eax
801016bb:	0f 48 c2             	cmovs  %edx,%eax
801016be:	c1 f8 03             	sar    $0x3,%eax
801016c1:	89 c2                	mov    %eax,%edx
801016c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016cb:	0f b6 c0             	movzbl %al,%eax
801016ce:	23 45 ec             	and    -0x14(%ebp),%eax
801016d1:	85 c0                	test   %eax,%eax
801016d3:	75 0d                	jne    801016e2 <bfree+0x91>
    panic("freeing free block");
801016d5:	83 ec 0c             	sub    $0xc,%esp
801016d8:	68 86 86 10 80       	push   $0x80108686
801016dd:	e8 be ee ff ff       	call   801005a0 <panic>
  bp->data[bi/8] &= ~m;
801016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e5:	8d 50 07             	lea    0x7(%eax),%edx
801016e8:	85 c0                	test   %eax,%eax
801016ea:	0f 48 c2             	cmovs  %edx,%eax
801016ed:	c1 f8 03             	sar    $0x3,%eax
801016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f3:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016f8:	89 d1                	mov    %edx,%ecx
801016fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016fd:	f7 d2                	not    %edx
801016ff:	21 ca                	and    %ecx,%edx
80101701:	89 d1                	mov    %edx,%ecx
80101703:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101706:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010170a:	83 ec 0c             	sub    $0xc,%esp
8010170d:	ff 75 f4             	pushl  -0xc(%ebp)
80101710:	e8 e3 20 00 00       	call   801037f8 <log_write>
80101715:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101718:	83 ec 0c             	sub    $0xc,%esp
8010171b:	ff 75 f4             	pushl  -0xc(%ebp)
8010171e:	e8 2d eb ff ff       	call   80100250 <brelse>
80101723:	83 c4 10             	add    $0x10,%esp
}
80101726:	90                   	nop
80101727:	c9                   	leave  
80101728:	c3                   	ret    

80101729 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101729:	55                   	push   %ebp
8010172a:	89 e5                	mov    %esp,%ebp
8010172c:	57                   	push   %edi
8010172d:	56                   	push   %esi
8010172e:	53                   	push   %ebx
8010172f:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101732:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101739:	83 ec 08             	sub    $0x8,%esp
8010173c:	68 99 86 10 80       	push   $0x80108699
80101741:	68 60 1a 11 80       	push   $0x80111a60
80101746:	e8 bb 38 00 00       	call   80105006 <initlock>
8010174b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010174e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101755:	eb 2d                	jmp    80101784 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101757:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010175a:	89 d0                	mov    %edx,%eax
8010175c:	c1 e0 03             	shl    $0x3,%eax
8010175f:	01 d0                	add    %edx,%eax
80101761:	c1 e0 04             	shl    $0x4,%eax
80101764:	83 c0 30             	add    $0x30,%eax
80101767:	05 60 1a 11 80       	add    $0x80111a60,%eax
8010176c:	83 c0 10             	add    $0x10,%eax
8010176f:	83 ec 08             	sub    $0x8,%esp
80101772:	68 a0 86 10 80       	push   $0x801086a0
80101777:	50                   	push   %eax
80101778:	e8 2c 37 00 00       	call   80104ea9 <initsleeplock>
8010177d:	83 c4 10             	add    $0x10,%esp
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101780:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101784:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101788:	7e cd                	jle    80101757 <iinit+0x2e>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
8010178a:	83 ec 08             	sub    $0x8,%esp
8010178d:	68 40 1a 11 80       	push   $0x80111a40
80101792:	ff 75 08             	pushl  0x8(%ebp)
80101795:	e8 d5 fc ff ff       	call   8010146f <readsb>
8010179a:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010179d:	a1 58 1a 11 80       	mov    0x80111a58,%eax
801017a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017a5:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
801017ab:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
801017b1:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
801017b7:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
801017bd:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
801017c3:	a1 40 1a 11 80       	mov    0x80111a40,%eax
801017c8:	ff 75 d4             	pushl  -0x2c(%ebp)
801017cb:	57                   	push   %edi
801017cc:	56                   	push   %esi
801017cd:	53                   	push   %ebx
801017ce:	51                   	push   %ecx
801017cf:	52                   	push   %edx
801017d0:	50                   	push   %eax
801017d1:	68 a8 86 10 80       	push   $0x801086a8
801017d6:	e8 25 ec ff ff       	call   80100400 <cprintf>
801017db:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017de:	90                   	nop
801017df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017e2:	5b                   	pop    %ebx
801017e3:	5e                   	pop    %esi
801017e4:	5f                   	pop    %edi
801017e5:	5d                   	pop    %ebp
801017e6:	c3                   	ret    

801017e7 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017e7:	55                   	push   %ebp
801017e8:	89 e5                	mov    %esp,%ebp
801017ea:	83 ec 28             	sub    $0x28,%esp
801017ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801017f0:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017f4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017fb:	e9 9e 00 00 00       	jmp    8010189e <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	c1 e8 03             	shr    $0x3,%eax
80101806:	89 c2                	mov    %eax,%edx
80101808:	a1 54 1a 11 80       	mov    0x80111a54,%eax
8010180d:	01 d0                	add    %edx,%eax
8010180f:	83 ec 08             	sub    $0x8,%esp
80101812:	50                   	push   %eax
80101813:	ff 75 08             	pushl  0x8(%ebp)
80101816:	e8 b3 e9 ff ff       	call   801001ce <bread>
8010181b:	83 c4 10             	add    $0x10,%esp
8010181e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101824:	8d 50 5c             	lea    0x5c(%eax),%edx
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	83 e0 07             	and    $0x7,%eax
8010182d:	c1 e0 06             	shl    $0x6,%eax
80101830:	01 d0                	add    %edx,%eax
80101832:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101835:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101838:	0f b7 00             	movzwl (%eax),%eax
8010183b:	66 85 c0             	test   %ax,%ax
8010183e:	75 4c                	jne    8010188c <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101840:	83 ec 04             	sub    $0x4,%esp
80101843:	6a 40                	push   $0x40
80101845:	6a 00                	push   $0x0
80101847:	ff 75 ec             	pushl  -0x14(%ebp)
8010184a:	e8 50 3a 00 00       	call   8010529f <memset>
8010184f:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101852:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101855:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101859:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010185c:	83 ec 0c             	sub    $0xc,%esp
8010185f:	ff 75 f0             	pushl  -0x10(%ebp)
80101862:	e8 91 1f 00 00       	call   801037f8 <log_write>
80101867:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010186a:	83 ec 0c             	sub    $0xc,%esp
8010186d:	ff 75 f0             	pushl  -0x10(%ebp)
80101870:	e8 db e9 ff ff       	call   80100250 <brelse>
80101875:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187b:	83 ec 08             	sub    $0x8,%esp
8010187e:	50                   	push   %eax
8010187f:	ff 75 08             	pushl  0x8(%ebp)
80101882:	e8 f8 00 00 00       	call   8010197f <iget>
80101887:	83 c4 10             	add    $0x10,%esp
8010188a:	eb 30                	jmp    801018bc <ialloc+0xd5>
    }
    brelse(bp);
8010188c:	83 ec 0c             	sub    $0xc,%esp
8010188f:	ff 75 f0             	pushl  -0x10(%ebp)
80101892:	e8 b9 e9 ff ff       	call   80100250 <brelse>
80101897:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010189a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010189e:	8b 15 48 1a 11 80    	mov    0x80111a48,%edx
801018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a7:	39 c2                	cmp    %eax,%edx
801018a9:	0f 87 51 ff ff ff    	ja     80101800 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	68 fb 86 10 80       	push   $0x801086fb
801018b7:	e8 e4 ec ff ff       	call   801005a0 <panic>
}
801018bc:	c9                   	leave  
801018bd:	c3                   	ret    

801018be <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018be:	55                   	push   %ebp
801018bf:	89 e5                	mov    %esp,%ebp
801018c1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	8b 40 04             	mov    0x4(%eax),%eax
801018ca:	c1 e8 03             	shr    $0x3,%eax
801018cd:	89 c2                	mov    %eax,%edx
801018cf:	a1 54 1a 11 80       	mov    0x80111a54,%eax
801018d4:	01 c2                	add    %eax,%edx
801018d6:	8b 45 08             	mov    0x8(%ebp),%eax
801018d9:	8b 00                	mov    (%eax),%eax
801018db:	83 ec 08             	sub    $0x8,%esp
801018de:	52                   	push   %edx
801018df:	50                   	push   %eax
801018e0:	e8 e9 e8 ff ff       	call   801001ce <bread>
801018e5:	83 c4 10             	add    $0x10,%esp
801018e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ee:	8d 50 5c             	lea    0x5c(%eax),%edx
801018f1:	8b 45 08             	mov    0x8(%ebp),%eax
801018f4:	8b 40 04             	mov    0x4(%eax),%eax
801018f7:	83 e0 07             	and    $0x7,%eax
801018fa:	c1 e0 06             	shl    $0x6,%eax
801018fd:	01 d0                	add    %edx,%eax
801018ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101902:	8b 45 08             	mov    0x8(%ebp),%eax
80101905:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010190f:	8b 45 08             	mov    0x8(%ebp),%eax
80101912:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101919:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010191d:	8b 45 08             	mov    0x8(%ebp),%eax
80101920:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101932:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101935:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101939:	8b 45 08             	mov    0x8(%ebp),%eax
8010193c:	8b 50 58             	mov    0x58(%eax),%edx
8010193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101942:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	8d 50 5c             	lea    0x5c(%eax),%edx
8010194b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194e:	83 c0 0c             	add    $0xc,%eax
80101951:	83 ec 04             	sub    $0x4,%esp
80101954:	6a 34                	push   $0x34
80101956:	52                   	push   %edx
80101957:	50                   	push   %eax
80101958:	e8 01 3a 00 00       	call   8010535e <memmove>
8010195d:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101960:	83 ec 0c             	sub    $0xc,%esp
80101963:	ff 75 f4             	pushl  -0xc(%ebp)
80101966:	e8 8d 1e 00 00       	call   801037f8 <log_write>
8010196b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010196e:	83 ec 0c             	sub    $0xc,%esp
80101971:	ff 75 f4             	pushl  -0xc(%ebp)
80101974:	e8 d7 e8 ff ff       	call   80100250 <brelse>
80101979:	83 c4 10             	add    $0x10,%esp
}
8010197c:	90                   	nop
8010197d:	c9                   	leave  
8010197e:	c3                   	ret    

8010197f <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010197f:	55                   	push   %ebp
80101980:	89 e5                	mov    %esp,%ebp
80101982:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101985:	83 ec 0c             	sub    $0xc,%esp
80101988:	68 60 1a 11 80       	push   $0x80111a60
8010198d:	e8 96 36 00 00       	call   80105028 <acquire>
80101992:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101995:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010199c:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
801019a3:	eb 60                	jmp    80101a05 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a8:	8b 40 08             	mov    0x8(%eax),%eax
801019ab:	85 c0                	test   %eax,%eax
801019ad:	7e 39                	jle    801019e8 <iget+0x69>
801019af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b2:	8b 00                	mov    (%eax),%eax
801019b4:	3b 45 08             	cmp    0x8(%ebp),%eax
801019b7:	75 2f                	jne    801019e8 <iget+0x69>
801019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bc:	8b 40 04             	mov    0x4(%eax),%eax
801019bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801019c2:	75 24                	jne    801019e8 <iget+0x69>
      ip->ref++;
801019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c7:	8b 40 08             	mov    0x8(%eax),%eax
801019ca:	8d 50 01             	lea    0x1(%eax),%edx
801019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d0:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019d3:	83 ec 0c             	sub    $0xc,%esp
801019d6:	68 60 1a 11 80       	push   $0x80111a60
801019db:	e8 b6 36 00 00       	call   80105096 <release>
801019e0:	83 c4 10             	add    $0x10,%esp
      return ip;
801019e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e6:	eb 77                	jmp    80101a5f <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ec:	75 10                	jne    801019fe <iget+0x7f>
801019ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f1:	8b 40 08             	mov    0x8(%eax),%eax
801019f4:	85 c0                	test   %eax,%eax
801019f6:	75 06                	jne    801019fe <iget+0x7f>
      empty = ip;
801019f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019fe:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a05:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
80101a0c:	72 97                	jb     801019a5 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a12:	75 0d                	jne    80101a21 <iget+0xa2>
    panic("iget: no inodes");
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	68 0d 87 10 80       	push   $0x8010870d
80101a1c:	e8 7f eb ff ff       	call   801005a0 <panic>

  ip = empty;
80101a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2a:	8b 55 08             	mov    0x8(%ebp),%edx
80101a2d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a32:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a35:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a4c:	83 ec 0c             	sub    $0xc,%esp
80101a4f:	68 60 1a 11 80       	push   $0x80111a60
80101a54:	e8 3d 36 00 00       	call   80105096 <release>
80101a59:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a5f:	c9                   	leave  
80101a60:	c3                   	ret    

80101a61 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a61:	55                   	push   %ebp
80101a62:	89 e5                	mov    %esp,%ebp
80101a64:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 60 1a 11 80       	push   $0x80111a60
80101a6f:	e8 b4 35 00 00       	call   80105028 <acquire>
80101a74:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7a:	8b 40 08             	mov    0x8(%eax),%eax
80101a7d:	8d 50 01             	lea    0x1(%eax),%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a86:	83 ec 0c             	sub    $0xc,%esp
80101a89:	68 60 1a 11 80       	push   $0x80111a60
80101a8e:	e8 03 36 00 00       	call   80105096 <release>
80101a93:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a99:	c9                   	leave  
80101a9a:	c3                   	ret    

80101a9b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a9b:	55                   	push   %ebp
80101a9c:	89 e5                	mov    %esp,%ebp
80101a9e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101aa1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aa5:	74 0a                	je     80101ab1 <ilock+0x16>
80101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaa:	8b 40 08             	mov    0x8(%eax),%eax
80101aad:	85 c0                	test   %eax,%eax
80101aaf:	7f 0d                	jg     80101abe <ilock+0x23>
    panic("ilock");
80101ab1:	83 ec 0c             	sub    $0xc,%esp
80101ab4:	68 1d 87 10 80       	push   $0x8010871d
80101ab9:	e8 e2 ea ff ff       	call   801005a0 <panic>

  acquiresleep(&ip->lock);
80101abe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac1:	83 c0 0c             	add    $0xc,%eax
80101ac4:	83 ec 0c             	sub    $0xc,%esp
80101ac7:	50                   	push   %eax
80101ac8:	e8 18 34 00 00       	call   80104ee5 <acquiresleep>
80101acd:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ad6:	85 c0                	test   %eax,%eax
80101ad8:	0f 85 cd 00 00 00    	jne    80101bab <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	8b 40 04             	mov    0x4(%eax),%eax
80101ae4:	c1 e8 03             	shr    $0x3,%eax
80101ae7:	89 c2                	mov    %eax,%edx
80101ae9:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101aee:	01 c2                	add    %eax,%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	8b 00                	mov    (%eax),%eax
80101af5:	83 ec 08             	sub    $0x8,%esp
80101af8:	52                   	push   %edx
80101af9:	50                   	push   %eax
80101afa:	e8 cf e6 ff ff       	call   801001ce <bread>
80101aff:	83 c4 10             	add    $0x10,%esp
80101b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b08:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	8b 40 04             	mov    0x4(%eax),%eax
80101b11:	83 e0 07             	and    $0x7,%eax
80101b14:	c1 e0 06             	shl    $0x6,%eax
80101b17:	01 d0                	add    %edx,%eax
80101b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 10             	movzwl (%eax),%edx
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b48:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4f:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b56:	8b 50 08             	mov    0x8(%eax),%edx
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b62:	8d 50 0c             	lea    0xc(%eax),%edx
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	83 c0 5c             	add    $0x5c,%eax
80101b6b:	83 ec 04             	sub    $0x4,%esp
80101b6e:	6a 34                	push   $0x34
80101b70:	52                   	push   %edx
80101b71:	50                   	push   %eax
80101b72:	e8 e7 37 00 00       	call   8010535e <memmove>
80101b77:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b7a:	83 ec 0c             	sub    $0xc,%esp
80101b7d:	ff 75 f4             	pushl  -0xc(%ebp)
80101b80:	e8 cb e6 ff ff       	call   80100250 <brelse>
80101b85:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b88:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8b:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b92:	8b 45 08             	mov    0x8(%ebp),%eax
80101b95:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b99:	66 85 c0             	test   %ax,%ax
80101b9c:	75 0d                	jne    80101bab <ilock+0x110>
      panic("ilock: no type");
80101b9e:	83 ec 0c             	sub    $0xc,%esp
80101ba1:	68 23 87 10 80       	push   $0x80108723
80101ba6:	e8 f5 e9 ff ff       	call   801005a0 <panic>
  }
}
80101bab:	90                   	nop
80101bac:	c9                   	leave  
80101bad:	c3                   	ret    

80101bae <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bae:	55                   	push   %ebp
80101baf:	89 e5                	mov    %esp,%ebp
80101bb1:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bb4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bb8:	74 20                	je     80101bda <iunlock+0x2c>
80101bba:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbd:	83 c0 0c             	add    $0xc,%eax
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	50                   	push   %eax
80101bc4:	e8 ce 33 00 00       	call   80104f97 <holdingsleep>
80101bc9:	83 c4 10             	add    $0x10,%esp
80101bcc:	85 c0                	test   %eax,%eax
80101bce:	74 0a                	je     80101bda <iunlock+0x2c>
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	8b 40 08             	mov    0x8(%eax),%eax
80101bd6:	85 c0                	test   %eax,%eax
80101bd8:	7f 0d                	jg     80101be7 <iunlock+0x39>
    panic("iunlock");
80101bda:	83 ec 0c             	sub    $0xc,%esp
80101bdd:	68 32 87 10 80       	push   $0x80108732
80101be2:	e8 b9 e9 ff ff       	call   801005a0 <panic>

  releasesleep(&ip->lock);
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	83 c0 0c             	add    $0xc,%eax
80101bed:	83 ec 0c             	sub    $0xc,%esp
80101bf0:	50                   	push   %eax
80101bf1:	e8 53 33 00 00       	call   80104f49 <releasesleep>
80101bf6:	83 c4 10             	add    $0x10,%esp
}
80101bf9:	90                   	nop
80101bfa:	c9                   	leave  
80101bfb:	c3                   	ret    

80101bfc <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bfc:	55                   	push   %ebp
80101bfd:	89 e5                	mov    %esp,%ebp
80101bff:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	83 c0 0c             	add    $0xc,%eax
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	50                   	push   %eax
80101c0c:	e8 d4 32 00 00       	call   80104ee5 <acquiresleep>
80101c11:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c1a:	85 c0                	test   %eax,%eax
80101c1c:	74 6a                	je     80101c88 <iput+0x8c>
80101c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c21:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c25:	66 85 c0             	test   %ax,%ax
80101c28:	75 5e                	jne    80101c88 <iput+0x8c>
    acquire(&icache.lock);
80101c2a:	83 ec 0c             	sub    $0xc,%esp
80101c2d:	68 60 1a 11 80       	push   $0x80111a60
80101c32:	e8 f1 33 00 00       	call   80105028 <acquire>
80101c37:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 40 08             	mov    0x8(%eax),%eax
80101c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c43:	83 ec 0c             	sub    $0xc,%esp
80101c46:	68 60 1a 11 80       	push   $0x80111a60
80101c4b:	e8 46 34 00 00       	call   80105096 <release>
80101c50:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c53:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c57:	75 2f                	jne    80101c88 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c59:	83 ec 0c             	sub    $0xc,%esp
80101c5c:	ff 75 08             	pushl  0x8(%ebp)
80101c5f:	e8 b2 01 00 00       	call   80101e16 <itrunc>
80101c64:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c70:	83 ec 0c             	sub    $0xc,%esp
80101c73:	ff 75 08             	pushl  0x8(%ebp)
80101c76:	e8 43 fc ff ff       	call   801018be <iupdate>
80101c7b:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c88:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8b:	83 c0 0c             	add    $0xc,%eax
80101c8e:	83 ec 0c             	sub    $0xc,%esp
80101c91:	50                   	push   %eax
80101c92:	e8 b2 32 00 00       	call   80104f49 <releasesleep>
80101c97:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c9a:	83 ec 0c             	sub    $0xc,%esp
80101c9d:	68 60 1a 11 80       	push   $0x80111a60
80101ca2:	e8 81 33 00 00       	call   80105028 <acquire>
80101ca7:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	8b 40 08             	mov    0x8(%eax),%eax
80101cb0:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb9:	83 ec 0c             	sub    $0xc,%esp
80101cbc:	68 60 1a 11 80       	push   $0x80111a60
80101cc1:	e8 d0 33 00 00       	call   80105096 <release>
80101cc6:	83 c4 10             	add    $0x10,%esp
}
80101cc9:	90                   	nop
80101cca:	c9                   	leave  
80101ccb:	c3                   	ret    

80101ccc <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ccc:	55                   	push   %ebp
80101ccd:	89 e5                	mov    %esp,%ebp
80101ccf:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cd2:	83 ec 0c             	sub    $0xc,%esp
80101cd5:	ff 75 08             	pushl  0x8(%ebp)
80101cd8:	e8 d1 fe ff ff       	call   80101bae <iunlock>
80101cdd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ce0:	83 ec 0c             	sub    $0xc,%esp
80101ce3:	ff 75 08             	pushl  0x8(%ebp)
80101ce6:	e8 11 ff ff ff       	call   80101bfc <iput>
80101ceb:	83 c4 10             	add    $0x10,%esp
}
80101cee:	90                   	nop
80101cef:	c9                   	leave  
80101cf0:	c3                   	ret    

80101cf1 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cf1:	55                   	push   %ebp
80101cf2:	89 e5                	mov    %esp,%ebp
80101cf4:	53                   	push   %ebx
80101cf5:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cf8:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cfc:	77 42                	ja     80101d40 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d04:	83 c2 14             	add    $0x14,%edx
80101d07:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d12:	75 24                	jne    80101d38 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d14:	8b 45 08             	mov    0x8(%ebp),%eax
80101d17:	8b 00                	mov    (%eax),%eax
80101d19:	83 ec 0c             	sub    $0xc,%esp
80101d1c:	50                   	push   %eax
80101d1d:	e8 e3 f7 ff ff       	call   80101505 <balloc>
80101d22:	83 c4 10             	add    $0x10,%esp
80101d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d28:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d2e:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d34:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3b:	e9 d1 00 00 00       	jmp    80101e11 <bmap+0x120>
  }
  bn -= NDIRECT;
80101d40:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d44:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d48:	0f 87 b6 00 00 00    	ja     80101e04 <bmap+0x113>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d5e:	75 20                	jne    80101d80 <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	8b 00                	mov    (%eax),%eax
80101d65:	83 ec 0c             	sub    $0xc,%esp
80101d68:	50                   	push   %eax
80101d69:	e8 97 f7 ff ff       	call   80101505 <balloc>
80101d6e:	83 c4 10             	add    $0x10,%esp
80101d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7a:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 00                	mov    (%eax),%eax
80101d85:	83 ec 08             	sub    $0x8,%esp
80101d88:	ff 75 f4             	pushl  -0xc(%ebp)
80101d8b:	50                   	push   %eax
80101d8c:	e8 3d e4 ff ff       	call   801001ce <bread>
80101d91:	83 c4 10             	add    $0x10,%esp
80101d94:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9a:	83 c0 5c             	add    $0x5c,%eax
80101d9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dad:	01 d0                	add    %edx,%eax
80101daf:	8b 00                	mov    (%eax),%eax
80101db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101db8:	75 37                	jne    80101df1 <bmap+0x100>
      a[bn] = addr = balloc(ip->dev);
80101dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dc7:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	8b 00                	mov    (%eax),%eax
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	50                   	push   %eax
80101dd3:	e8 2d f7 ff ff       	call   80101505 <balloc>
80101dd8:	83 c4 10             	add    $0x10,%esp
80101ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de1:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101de3:	83 ec 0c             	sub    $0xc,%esp
80101de6:	ff 75 f0             	pushl  -0x10(%ebp)
80101de9:	e8 0a 1a 00 00       	call   801037f8 <log_write>
80101dee:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101df1:	83 ec 0c             	sub    $0xc,%esp
80101df4:	ff 75 f0             	pushl  -0x10(%ebp)
80101df7:	e8 54 e4 ff ff       	call   80100250 <brelse>
80101dfc:	83 c4 10             	add    $0x10,%esp
    return addr;
80101dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e02:	eb 0d                	jmp    80101e11 <bmap+0x120>
  }

  panic("bmap: out of range");
80101e04:	83 ec 0c             	sub    $0xc,%esp
80101e07:	68 3a 87 10 80       	push   $0x8010873a
80101e0c:	e8 8f e7 ff ff       	call   801005a0 <panic>
}
80101e11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e14:	c9                   	leave  
80101e15:	c3                   	ret    

80101e16 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e16:	55                   	push   %ebp
80101e17:	89 e5                	mov    %esp,%ebp
80101e19:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e23:	eb 45                	jmp    80101e6a <itrunc+0x54>
    if(ip->addrs[i]){
80101e25:	8b 45 08             	mov    0x8(%ebp),%eax
80101e28:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e2b:	83 c2 14             	add    $0x14,%edx
80101e2e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e32:	85 c0                	test   %eax,%eax
80101e34:	74 30                	je     80101e66 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e36:	8b 45 08             	mov    0x8(%ebp),%eax
80101e39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e3c:	83 c2 14             	add    $0x14,%edx
80101e3f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	8b 12                	mov    (%edx),%edx
80101e48:	83 ec 08             	sub    $0x8,%esp
80101e4b:	50                   	push   %eax
80101e4c:	52                   	push   %edx
80101e4d:	e8 ff f7 ff ff       	call   80101651 <bfree>
80101e52:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e5b:	83 c2 14             	add    $0x14,%edx
80101e5e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e65:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e6a:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e6e:	7e b5                	jle    80101e25 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e79:	85 c0                	test   %eax,%eax
80101e7b:	0f 84 aa 00 00 00    	je     80101f2b <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e81:	8b 45 08             	mov    0x8(%ebp),%eax
80101e84:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	8b 00                	mov    (%eax),%eax
80101e8f:	83 ec 08             	sub    $0x8,%esp
80101e92:	52                   	push   %edx
80101e93:	50                   	push   %eax
80101e94:	e8 35 e3 ff ff       	call   801001ce <bread>
80101e99:	83 c4 10             	add    $0x10,%esp
80101e9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea2:	83 c0 5c             	add    $0x5c,%eax
80101ea5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ea8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eaf:	eb 3c                	jmp    80101eed <itrunc+0xd7>
      if(a[j])
80101eb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ebb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ebe:	01 d0                	add    %edx,%eax
80101ec0:	8b 00                	mov    (%eax),%eax
80101ec2:	85 c0                	test   %eax,%eax
80101ec4:	74 23                	je     80101ee9 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ed3:	01 d0                	add    %edx,%eax
80101ed5:	8b 00                	mov    (%eax),%eax
80101ed7:	8b 55 08             	mov    0x8(%ebp),%edx
80101eda:	8b 12                	mov    (%edx),%edx
80101edc:	83 ec 08             	sub    $0x8,%esp
80101edf:	50                   	push   %eax
80101ee0:	52                   	push   %edx
80101ee1:	e8 6b f7 ff ff       	call   80101651 <bfree>
80101ee6:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ee9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef0:	83 f8 7f             	cmp    $0x7f,%eax
80101ef3:	76 bc                	jbe    80101eb1 <itrunc+0x9b>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ef5:	83 ec 0c             	sub    $0xc,%esp
80101ef8:	ff 75 ec             	pushl  -0x14(%ebp)
80101efb:	e8 50 e3 ff ff       	call   80100250 <brelse>
80101f00:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
80101f06:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f0c:	8b 55 08             	mov    0x8(%ebp),%edx
80101f0f:	8b 12                	mov    (%edx),%edx
80101f11:	83 ec 08             	sub    $0x8,%esp
80101f14:	50                   	push   %eax
80101f15:	52                   	push   %edx
80101f16:	e8 36 f7 ff ff       	call   80101651 <bfree>
80101f1b:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f28:	00 00 00 
  }

  ip->size = 0;
80101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2e:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f35:	83 ec 0c             	sub    $0xc,%esp
80101f38:	ff 75 08             	pushl  0x8(%ebp)
80101f3b:	e8 7e f9 ff ff       	call   801018be <iupdate>
80101f40:	83 c4 10             	add    $0x10,%esp
}
80101f43:	90                   	nop
80101f44:	c9                   	leave  
80101f45:	c3                   	ret    

80101f46 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f46:	55                   	push   %ebp
80101f47:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	8b 00                	mov    (%eax),%eax
80101f4e:	89 c2                	mov    %eax,%edx
80101f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f53:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	8b 50 04             	mov    0x4(%eax),%edx
80101f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5f:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f62:	8b 45 08             	mov    0x8(%ebp),%eax
80101f65:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f6c:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f76:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f79:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 50 58             	mov    0x58(%eax),%edx
80101f83:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f86:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f89:	90                   	nop
80101f8a:	5d                   	pop    %ebp
80101f8b:	c3                   	ret    

80101f8c <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f8c:	55                   	push   %ebp
80101f8d:	89 e5                	mov    %esp,%ebp
80101f8f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f92:	8b 45 08             	mov    0x8(%ebp),%eax
80101f95:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f99:	66 83 f8 03          	cmp    $0x3,%ax
80101f9d:	75 5c                	jne    80101ffb <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa6:	66 85 c0             	test   %ax,%ax
80101fa9:	78 20                	js     80101fcb <readi+0x3f>
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fb2:	66 83 f8 09          	cmp    $0x9,%ax
80101fb6:	7f 13                	jg     80101fcb <readi+0x3f>
80101fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbb:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbf:	98                   	cwtl   
80101fc0:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101fc7:	85 c0                	test   %eax,%eax
80101fc9:	75 0a                	jne    80101fd5 <readi+0x49>
      return -1;
80101fcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fd0:	e9 0c 01 00 00       	jmp    801020e1 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fdc:	98                   	cwtl   
80101fdd:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101fe4:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe7:	83 ec 04             	sub    $0x4,%esp
80101fea:	52                   	push   %edx
80101feb:	ff 75 0c             	pushl  0xc(%ebp)
80101fee:	ff 75 08             	pushl  0x8(%ebp)
80101ff1:	ff d0                	call   *%eax
80101ff3:	83 c4 10             	add    $0x10,%esp
80101ff6:	e9 e6 00 00 00       	jmp    801020e1 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffe:	8b 40 58             	mov    0x58(%eax),%eax
80102001:	3b 45 10             	cmp    0x10(%ebp),%eax
80102004:	72 0d                	jb     80102013 <readi+0x87>
80102006:	8b 55 10             	mov    0x10(%ebp),%edx
80102009:	8b 45 14             	mov    0x14(%ebp),%eax
8010200c:	01 d0                	add    %edx,%eax
8010200e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102011:	73 0a                	jae    8010201d <readi+0x91>
    return -1;
80102013:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102018:	e9 c4 00 00 00       	jmp    801020e1 <readi+0x155>
  if(off + n > ip->size)
8010201d:	8b 55 10             	mov    0x10(%ebp),%edx
80102020:	8b 45 14             	mov    0x14(%ebp),%eax
80102023:	01 c2                	add    %eax,%edx
80102025:	8b 45 08             	mov    0x8(%ebp),%eax
80102028:	8b 40 58             	mov    0x58(%eax),%eax
8010202b:	39 c2                	cmp    %eax,%edx
8010202d:	76 0c                	jbe    8010203b <readi+0xaf>
    n = ip->size - off;
8010202f:	8b 45 08             	mov    0x8(%ebp),%eax
80102032:	8b 40 58             	mov    0x58(%eax),%eax
80102035:	2b 45 10             	sub    0x10(%ebp),%eax
80102038:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010203b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102042:	e9 8b 00 00 00       	jmp    801020d2 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102047:	8b 45 10             	mov    0x10(%ebp),%eax
8010204a:	c1 e8 09             	shr    $0x9,%eax
8010204d:	83 ec 08             	sub    $0x8,%esp
80102050:	50                   	push   %eax
80102051:	ff 75 08             	pushl  0x8(%ebp)
80102054:	e8 98 fc ff ff       	call   80101cf1 <bmap>
80102059:	83 c4 10             	add    $0x10,%esp
8010205c:	89 c2                	mov    %eax,%edx
8010205e:	8b 45 08             	mov    0x8(%ebp),%eax
80102061:	8b 00                	mov    (%eax),%eax
80102063:	83 ec 08             	sub    $0x8,%esp
80102066:	52                   	push   %edx
80102067:	50                   	push   %eax
80102068:	e8 61 e1 ff ff       	call   801001ce <bread>
8010206d:	83 c4 10             	add    $0x10,%esp
80102070:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102073:	8b 45 10             	mov    0x10(%ebp),%eax
80102076:	25 ff 01 00 00       	and    $0x1ff,%eax
8010207b:	ba 00 02 00 00       	mov    $0x200,%edx
80102080:	29 c2                	sub    %eax,%edx
80102082:	8b 45 14             	mov    0x14(%ebp),%eax
80102085:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102088:	39 c2                	cmp    %eax,%edx
8010208a:	0f 46 c2             	cmovbe %edx,%eax
8010208d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102090:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102093:	8d 50 5c             	lea    0x5c(%eax),%edx
80102096:	8b 45 10             	mov    0x10(%ebp),%eax
80102099:	25 ff 01 00 00       	and    $0x1ff,%eax
8010209e:	01 d0                	add    %edx,%eax
801020a0:	83 ec 04             	sub    $0x4,%esp
801020a3:	ff 75 ec             	pushl  -0x14(%ebp)
801020a6:	50                   	push   %eax
801020a7:	ff 75 0c             	pushl  0xc(%ebp)
801020aa:	e8 af 32 00 00       	call   8010535e <memmove>
801020af:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020b2:	83 ec 0c             	sub    $0xc,%esp
801020b5:	ff 75 f0             	pushl  -0x10(%ebp)
801020b8:	e8 93 e1 ff ff       	call   80100250 <brelse>
801020bd:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c3:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c9:	01 45 10             	add    %eax,0x10(%ebp)
801020cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020cf:	01 45 0c             	add    %eax,0xc(%ebp)
801020d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020d5:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d8:	0f 82 69 ff ff ff    	jb     80102047 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020de:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020e1:	c9                   	leave  
801020e2:	c3                   	ret    

801020e3 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020e3:	55                   	push   %ebp
801020e4:	89 e5                	mov    %esp,%ebp
801020e6:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e9:	8b 45 08             	mov    0x8(%ebp),%eax
801020ec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020f0:	66 83 f8 03          	cmp    $0x3,%ax
801020f4:	75 5c                	jne    80102152 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f6:	8b 45 08             	mov    0x8(%ebp),%eax
801020f9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020fd:	66 85 c0             	test   %ax,%ax
80102100:	78 20                	js     80102122 <writei+0x3f>
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102109:	66 83 f8 09          	cmp    $0x9,%ax
8010210d:	7f 13                	jg     80102122 <writei+0x3f>
8010210f:	8b 45 08             	mov    0x8(%ebp),%eax
80102112:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102116:	98                   	cwtl   
80102117:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
8010211e:	85 c0                	test   %eax,%eax
80102120:	75 0a                	jne    8010212c <writei+0x49>
      return -1;
80102122:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102127:	e9 3d 01 00 00       	jmp    80102269 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010212c:	8b 45 08             	mov    0x8(%ebp),%eax
8010212f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102133:	98                   	cwtl   
80102134:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
8010213b:	8b 55 14             	mov    0x14(%ebp),%edx
8010213e:	83 ec 04             	sub    $0x4,%esp
80102141:	52                   	push   %edx
80102142:	ff 75 0c             	pushl  0xc(%ebp)
80102145:	ff 75 08             	pushl  0x8(%ebp)
80102148:	ff d0                	call   *%eax
8010214a:	83 c4 10             	add    $0x10,%esp
8010214d:	e9 17 01 00 00       	jmp    80102269 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102152:	8b 45 08             	mov    0x8(%ebp),%eax
80102155:	8b 40 58             	mov    0x58(%eax),%eax
80102158:	3b 45 10             	cmp    0x10(%ebp),%eax
8010215b:	72 0d                	jb     8010216a <writei+0x87>
8010215d:	8b 55 10             	mov    0x10(%ebp),%edx
80102160:	8b 45 14             	mov    0x14(%ebp),%eax
80102163:	01 d0                	add    %edx,%eax
80102165:	3b 45 10             	cmp    0x10(%ebp),%eax
80102168:	73 0a                	jae    80102174 <writei+0x91>
    return -1;
8010216a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216f:	e9 f5 00 00 00       	jmp    80102269 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102174:	8b 55 10             	mov    0x10(%ebp),%edx
80102177:	8b 45 14             	mov    0x14(%ebp),%eax
8010217a:	01 d0                	add    %edx,%eax
8010217c:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102181:	76 0a                	jbe    8010218d <writei+0xaa>
    return -1;
80102183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102188:	e9 dc 00 00 00       	jmp    80102269 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102194:	e9 99 00 00 00       	jmp    80102232 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102199:	8b 45 10             	mov    0x10(%ebp),%eax
8010219c:	c1 e8 09             	shr    $0x9,%eax
8010219f:	83 ec 08             	sub    $0x8,%esp
801021a2:	50                   	push   %eax
801021a3:	ff 75 08             	pushl  0x8(%ebp)
801021a6:	e8 46 fb ff ff       	call   80101cf1 <bmap>
801021ab:	83 c4 10             	add    $0x10,%esp
801021ae:	89 c2                	mov    %eax,%edx
801021b0:	8b 45 08             	mov    0x8(%ebp),%eax
801021b3:	8b 00                	mov    (%eax),%eax
801021b5:	83 ec 08             	sub    $0x8,%esp
801021b8:	52                   	push   %edx
801021b9:	50                   	push   %eax
801021ba:	e8 0f e0 ff ff       	call   801001ce <bread>
801021bf:	83 c4 10             	add    $0x10,%esp
801021c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c5:	8b 45 10             	mov    0x10(%ebp),%eax
801021c8:	25 ff 01 00 00       	and    $0x1ff,%eax
801021cd:	ba 00 02 00 00       	mov    $0x200,%edx
801021d2:	29 c2                	sub    %eax,%edx
801021d4:	8b 45 14             	mov    0x14(%ebp),%eax
801021d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021da:	39 c2                	cmp    %eax,%edx
801021dc:	0f 46 c2             	cmovbe %edx,%eax
801021df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e5:	8d 50 5c             	lea    0x5c(%eax),%edx
801021e8:	8b 45 10             	mov    0x10(%ebp),%eax
801021eb:	25 ff 01 00 00       	and    $0x1ff,%eax
801021f0:	01 d0                	add    %edx,%eax
801021f2:	83 ec 04             	sub    $0x4,%esp
801021f5:	ff 75 ec             	pushl  -0x14(%ebp)
801021f8:	ff 75 0c             	pushl  0xc(%ebp)
801021fb:	50                   	push   %eax
801021fc:	e8 5d 31 00 00       	call   8010535e <memmove>
80102201:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102204:	83 ec 0c             	sub    $0xc,%esp
80102207:	ff 75 f0             	pushl  -0x10(%ebp)
8010220a:	e8 e9 15 00 00       	call   801037f8 <log_write>
8010220f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102212:	83 ec 0c             	sub    $0xc,%esp
80102215:	ff 75 f0             	pushl  -0x10(%ebp)
80102218:	e8 33 e0 ff ff       	call   80100250 <brelse>
8010221d:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102220:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102223:	01 45 f4             	add    %eax,-0xc(%ebp)
80102226:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102229:	01 45 10             	add    %eax,0x10(%ebp)
8010222c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222f:	01 45 0c             	add    %eax,0xc(%ebp)
80102232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102235:	3b 45 14             	cmp    0x14(%ebp),%eax
80102238:	0f 82 5b ff ff ff    	jb     80102199 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010223e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102242:	74 22                	je     80102266 <writei+0x183>
80102244:	8b 45 08             	mov    0x8(%ebp),%eax
80102247:	8b 40 58             	mov    0x58(%eax),%eax
8010224a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010224d:	73 17                	jae    80102266 <writei+0x183>
    ip->size = off;
8010224f:	8b 45 08             	mov    0x8(%ebp),%eax
80102252:	8b 55 10             	mov    0x10(%ebp),%edx
80102255:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102258:	83 ec 0c             	sub    $0xc,%esp
8010225b:	ff 75 08             	pushl  0x8(%ebp)
8010225e:	e8 5b f6 ff ff       	call   801018be <iupdate>
80102263:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102266:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102269:	c9                   	leave  
8010226a:	c3                   	ret    

8010226b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010226b:	55                   	push   %ebp
8010226c:	89 e5                	mov    %esp,%ebp
8010226e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102271:	83 ec 04             	sub    $0x4,%esp
80102274:	6a 0e                	push   $0xe
80102276:	ff 75 0c             	pushl  0xc(%ebp)
80102279:	ff 75 08             	pushl  0x8(%ebp)
8010227c:	e8 73 31 00 00       	call   801053f4 <strncmp>
80102281:	83 c4 10             	add    $0x10,%esp
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102293:	66 83 f8 01          	cmp    $0x1,%ax
80102297:	74 0d                	je     801022a6 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102299:	83 ec 0c             	sub    $0xc,%esp
8010229c:	68 4d 87 10 80       	push   $0x8010874d
801022a1:	e8 fa e2 ff ff       	call   801005a0 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ad:	eb 7b                	jmp    8010232a <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022af:	6a 10                	push   $0x10
801022b1:	ff 75 f4             	pushl  -0xc(%ebp)
801022b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022b7:	50                   	push   %eax
801022b8:	ff 75 08             	pushl  0x8(%ebp)
801022bb:	e8 cc fc ff ff       	call   80101f8c <readi>
801022c0:	83 c4 10             	add    $0x10,%esp
801022c3:	83 f8 10             	cmp    $0x10,%eax
801022c6:	74 0d                	je     801022d5 <dirlookup+0x4f>
      panic("dirlookup read");
801022c8:	83 ec 0c             	sub    $0xc,%esp
801022cb:	68 5f 87 10 80       	push   $0x8010875f
801022d0:	e8 cb e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
801022d5:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022d9:	66 85 c0             	test   %ax,%ax
801022dc:	74 47                	je     80102325 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022de:	83 ec 08             	sub    $0x8,%esp
801022e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e4:	83 c0 02             	add    $0x2,%eax
801022e7:	50                   	push   %eax
801022e8:	ff 75 0c             	pushl  0xc(%ebp)
801022eb:	e8 7b ff ff ff       	call   8010226b <namecmp>
801022f0:	83 c4 10             	add    $0x10,%esp
801022f3:	85 c0                	test   %eax,%eax
801022f5:	75 2f                	jne    80102326 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022fb:	74 08                	je     80102305 <dirlookup+0x7f>
        *poff = off;
801022fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102300:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102303:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102305:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102309:	0f b7 c0             	movzwl %ax,%eax
8010230c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010230f:	8b 45 08             	mov    0x8(%ebp),%eax
80102312:	8b 00                	mov    (%eax),%eax
80102314:	83 ec 08             	sub    $0x8,%esp
80102317:	ff 75 f0             	pushl  -0x10(%ebp)
8010231a:	50                   	push   %eax
8010231b:	e8 5f f6 ff ff       	call   8010197f <iget>
80102320:	83 c4 10             	add    $0x10,%esp
80102323:	eb 19                	jmp    8010233e <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
80102325:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102326:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010232a:	8b 45 08             	mov    0x8(%ebp),%eax
8010232d:	8b 40 58             	mov    0x58(%eax),%eax
80102330:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102333:	0f 87 76 ff ff ff    	ja     801022af <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102339:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010233e:	c9                   	leave  
8010233f:	c3                   	ret    

80102340 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102340:	55                   	push   %ebp
80102341:	89 e5                	mov    %esp,%ebp
80102343:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102346:	83 ec 04             	sub    $0x4,%esp
80102349:	6a 00                	push   $0x0
8010234b:	ff 75 0c             	pushl  0xc(%ebp)
8010234e:	ff 75 08             	pushl  0x8(%ebp)
80102351:	e8 30 ff ff ff       	call   80102286 <dirlookup>
80102356:	83 c4 10             	add    $0x10,%esp
80102359:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010235c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102360:	74 18                	je     8010237a <dirlink+0x3a>
    iput(ip);
80102362:	83 ec 0c             	sub    $0xc,%esp
80102365:	ff 75 f0             	pushl  -0x10(%ebp)
80102368:	e8 8f f8 ff ff       	call   80101bfc <iput>
8010236d:	83 c4 10             	add    $0x10,%esp
    return -1;
80102370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102375:	e9 9c 00 00 00       	jmp    80102416 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010237a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102381:	eb 39                	jmp    801023bc <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102386:	6a 10                	push   $0x10
80102388:	50                   	push   %eax
80102389:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238c:	50                   	push   %eax
8010238d:	ff 75 08             	pushl  0x8(%ebp)
80102390:	e8 f7 fb ff ff       	call   80101f8c <readi>
80102395:	83 c4 10             	add    $0x10,%esp
80102398:	83 f8 10             	cmp    $0x10,%eax
8010239b:	74 0d                	je     801023aa <dirlink+0x6a>
      panic("dirlink read");
8010239d:	83 ec 0c             	sub    $0xc,%esp
801023a0:	68 6e 87 10 80       	push   $0x8010876e
801023a5:	e8 f6 e1 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
801023aa:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ae:	66 85 c0             	test   %ax,%ax
801023b1:	74 18                	je     801023cb <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b6:	83 c0 10             	add    $0x10,%eax
801023b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023bc:	8b 45 08             	mov    0x8(%ebp),%eax
801023bf:	8b 50 58             	mov    0x58(%eax),%edx
801023c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c5:	39 c2                	cmp    %eax,%edx
801023c7:	77 ba                	ja     80102383 <dirlink+0x43>
801023c9:	eb 01                	jmp    801023cc <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023cb:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	6a 0e                	push   $0xe
801023d1:	ff 75 0c             	pushl  0xc(%ebp)
801023d4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d7:	83 c0 02             	add    $0x2,%eax
801023da:	50                   	push   %eax
801023db:	e8 6a 30 00 00       	call   8010544a <strncpy>
801023e0:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023e3:	8b 45 10             	mov    0x10(%ebp),%eax
801023e6:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ed:	6a 10                	push   $0x10
801023ef:	50                   	push   %eax
801023f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f3:	50                   	push   %eax
801023f4:	ff 75 08             	pushl  0x8(%ebp)
801023f7:	e8 e7 fc ff ff       	call   801020e3 <writei>
801023fc:	83 c4 10             	add    $0x10,%esp
801023ff:	83 f8 10             	cmp    $0x10,%eax
80102402:	74 0d                	je     80102411 <dirlink+0xd1>
    panic("dirlink");
80102404:	83 ec 0c             	sub    $0xc,%esp
80102407:	68 7b 87 10 80       	push   $0x8010877b
8010240c:	e8 8f e1 ff ff       	call   801005a0 <panic>

  return 0;
80102411:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102416:	c9                   	leave  
80102417:	c3                   	ret    

80102418 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102418:	55                   	push   %ebp
80102419:	89 e5                	mov    %esp,%ebp
8010241b:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010241e:	eb 04                	jmp    80102424 <skipelem+0xc>
    path++;
80102420:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102424:	8b 45 08             	mov    0x8(%ebp),%eax
80102427:	0f b6 00             	movzbl (%eax),%eax
8010242a:	3c 2f                	cmp    $0x2f,%al
8010242c:	74 f2                	je     80102420 <skipelem+0x8>
    path++;
  if(*path == 0)
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	0f b6 00             	movzbl (%eax),%eax
80102434:	84 c0                	test   %al,%al
80102436:	75 07                	jne    8010243f <skipelem+0x27>
    return 0;
80102438:	b8 00 00 00 00       	mov    $0x0,%eax
8010243d:	eb 7b                	jmp    801024ba <skipelem+0xa2>
  s = path;
8010243f:	8b 45 08             	mov    0x8(%ebp),%eax
80102442:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102445:	eb 04                	jmp    8010244b <skipelem+0x33>
    path++;
80102447:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	0f b6 00             	movzbl (%eax),%eax
80102451:	3c 2f                	cmp    $0x2f,%al
80102453:	74 0a                	je     8010245f <skipelem+0x47>
80102455:	8b 45 08             	mov    0x8(%ebp),%eax
80102458:	0f b6 00             	movzbl (%eax),%eax
8010245b:	84 c0                	test   %al,%al
8010245d:	75 e8                	jne    80102447 <skipelem+0x2f>
    path++;
  len = path - s;
8010245f:	8b 55 08             	mov    0x8(%ebp),%edx
80102462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102465:	29 c2                	sub    %eax,%edx
80102467:	89 d0                	mov    %edx,%eax
80102469:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010246c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102470:	7e 15                	jle    80102487 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102472:	83 ec 04             	sub    $0x4,%esp
80102475:	6a 0e                	push   $0xe
80102477:	ff 75 f4             	pushl  -0xc(%ebp)
8010247a:	ff 75 0c             	pushl  0xc(%ebp)
8010247d:	e8 dc 2e 00 00       	call   8010535e <memmove>
80102482:	83 c4 10             	add    $0x10,%esp
80102485:	eb 26                	jmp    801024ad <skipelem+0x95>
  else {
    memmove(name, s, len);
80102487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010248a:	83 ec 04             	sub    $0x4,%esp
8010248d:	50                   	push   %eax
8010248e:	ff 75 f4             	pushl  -0xc(%ebp)
80102491:	ff 75 0c             	pushl  0xc(%ebp)
80102494:	e8 c5 2e 00 00       	call   8010535e <memmove>
80102499:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010249c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010249f:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a2:	01 d0                	add    %edx,%eax
801024a4:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024a7:	eb 04                	jmp    801024ad <skipelem+0x95>
    path++;
801024a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024ad:	8b 45 08             	mov    0x8(%ebp),%eax
801024b0:	0f b6 00             	movzbl (%eax),%eax
801024b3:	3c 2f                	cmp    $0x2f,%al
801024b5:	74 f2                	je     801024a9 <skipelem+0x91>
    path++;
  return path;
801024b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024ba:	c9                   	leave  
801024bb:	c3                   	ret    

801024bc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024bc:	55                   	push   %ebp
801024bd:	89 e5                	mov    %esp,%ebp
801024bf:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024c2:	8b 45 08             	mov    0x8(%ebp),%eax
801024c5:	0f b6 00             	movzbl (%eax),%eax
801024c8:	3c 2f                	cmp    $0x2f,%al
801024ca:	75 17                	jne    801024e3 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024cc:	83 ec 08             	sub    $0x8,%esp
801024cf:	6a 01                	push   $0x1
801024d1:	6a 01                	push   $0x1
801024d3:	e8 a7 f4 ff ff       	call   8010197f <iget>
801024d8:	83 c4 10             	add    $0x10,%esp
801024db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024de:	e9 ba 00 00 00       	jmp    8010259d <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
801024e3:	e8 30 1e 00 00       	call   80104318 <myproc>
801024e8:	8b 40 68             	mov    0x68(%eax),%eax
801024eb:	83 ec 0c             	sub    $0xc,%esp
801024ee:	50                   	push   %eax
801024ef:	e8 6d f5 ff ff       	call   80101a61 <idup>
801024f4:	83 c4 10             	add    $0x10,%esp
801024f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024fa:	e9 9e 00 00 00       	jmp    8010259d <namex+0xe1>
    ilock(ip);
801024ff:	83 ec 0c             	sub    $0xc,%esp
80102502:	ff 75 f4             	pushl  -0xc(%ebp)
80102505:	e8 91 f5 ff ff       	call   80101a9b <ilock>
8010250a:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010250d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102510:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102514:	66 83 f8 01          	cmp    $0x1,%ax
80102518:	74 18                	je     80102532 <namex+0x76>
      iunlockput(ip);
8010251a:	83 ec 0c             	sub    $0xc,%esp
8010251d:	ff 75 f4             	pushl  -0xc(%ebp)
80102520:	e8 a7 f7 ff ff       	call   80101ccc <iunlockput>
80102525:	83 c4 10             	add    $0x10,%esp
      return 0;
80102528:	b8 00 00 00 00       	mov    $0x0,%eax
8010252d:	e9 a7 00 00 00       	jmp    801025d9 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102532:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102536:	74 20                	je     80102558 <namex+0x9c>
80102538:	8b 45 08             	mov    0x8(%ebp),%eax
8010253b:	0f b6 00             	movzbl (%eax),%eax
8010253e:	84 c0                	test   %al,%al
80102540:	75 16                	jne    80102558 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102542:	83 ec 0c             	sub    $0xc,%esp
80102545:	ff 75 f4             	pushl  -0xc(%ebp)
80102548:	e8 61 f6 ff ff       	call   80101bae <iunlock>
8010254d:	83 c4 10             	add    $0x10,%esp
      return ip;
80102550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102553:	e9 81 00 00 00       	jmp    801025d9 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102558:	83 ec 04             	sub    $0x4,%esp
8010255b:	6a 00                	push   $0x0
8010255d:	ff 75 10             	pushl  0x10(%ebp)
80102560:	ff 75 f4             	pushl  -0xc(%ebp)
80102563:	e8 1e fd ff ff       	call   80102286 <dirlookup>
80102568:	83 c4 10             	add    $0x10,%esp
8010256b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010256e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102572:	75 15                	jne    80102589 <namex+0xcd>
      iunlockput(ip);
80102574:	83 ec 0c             	sub    $0xc,%esp
80102577:	ff 75 f4             	pushl  -0xc(%ebp)
8010257a:	e8 4d f7 ff ff       	call   80101ccc <iunlockput>
8010257f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102582:	b8 00 00 00 00       	mov    $0x0,%eax
80102587:	eb 50                	jmp    801025d9 <namex+0x11d>
    }
    iunlockput(ip);
80102589:	83 ec 0c             	sub    $0xc,%esp
8010258c:	ff 75 f4             	pushl  -0xc(%ebp)
8010258f:	e8 38 f7 ff ff       	call   80101ccc <iunlockput>
80102594:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102597:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010259a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010259d:	83 ec 08             	sub    $0x8,%esp
801025a0:	ff 75 10             	pushl  0x10(%ebp)
801025a3:	ff 75 08             	pushl  0x8(%ebp)
801025a6:	e8 6d fe ff ff       	call   80102418 <skipelem>
801025ab:	83 c4 10             	add    $0x10,%esp
801025ae:	89 45 08             	mov    %eax,0x8(%ebp)
801025b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025b5:	0f 85 44 ff ff ff    	jne    801024ff <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025bf:	74 15                	je     801025d6 <namex+0x11a>
    iput(ip);
801025c1:	83 ec 0c             	sub    $0xc,%esp
801025c4:	ff 75 f4             	pushl  -0xc(%ebp)
801025c7:	e8 30 f6 ff ff       	call   80101bfc <iput>
801025cc:	83 c4 10             	add    $0x10,%esp
    return 0;
801025cf:	b8 00 00 00 00       	mov    $0x0,%eax
801025d4:	eb 03                	jmp    801025d9 <namex+0x11d>
  }
  return ip;
801025d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025d9:	c9                   	leave  
801025da:	c3                   	ret    

801025db <namei>:

struct inode*
namei(char *path)
{
801025db:	55                   	push   %ebp
801025dc:	89 e5                	mov    %esp,%ebp
801025de:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025e1:	83 ec 04             	sub    $0x4,%esp
801025e4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025e7:	50                   	push   %eax
801025e8:	6a 00                	push   $0x0
801025ea:	ff 75 08             	pushl  0x8(%ebp)
801025ed:	e8 ca fe ff ff       	call   801024bc <namex>
801025f2:	83 c4 10             	add    $0x10,%esp
}
801025f5:	c9                   	leave  
801025f6:	c3                   	ret    

801025f7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025f7:	55                   	push   %ebp
801025f8:	89 e5                	mov    %esp,%ebp
801025fa:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025fd:	83 ec 04             	sub    $0x4,%esp
80102600:	ff 75 0c             	pushl  0xc(%ebp)
80102603:	6a 01                	push   $0x1
80102605:	ff 75 08             	pushl  0x8(%ebp)
80102608:	e8 af fe ff ff       	call   801024bc <namex>
8010260d:	83 c4 10             	add    $0x10,%esp
}
80102610:	c9                   	leave  
80102611:	c3                   	ret    

80102612 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102612:	55                   	push   %ebp
80102613:	89 e5                	mov    %esp,%ebp
80102615:	83 ec 14             	sub    $0x14,%esp
80102618:	8b 45 08             	mov    0x8(%ebp),%eax
8010261b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010261f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102623:	89 c2                	mov    %eax,%edx
80102625:	ec                   	in     (%dx),%al
80102626:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102629:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
80102632:	57                   	push   %edi
80102633:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102634:	8b 55 08             	mov    0x8(%ebp),%edx
80102637:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010263a:	8b 45 10             	mov    0x10(%ebp),%eax
8010263d:	89 cb                	mov    %ecx,%ebx
8010263f:	89 df                	mov    %ebx,%edi
80102641:	89 c1                	mov    %eax,%ecx
80102643:	fc                   	cld    
80102644:	f3 6d                	rep insl (%dx),%es:(%edi)
80102646:	89 c8                	mov    %ecx,%eax
80102648:	89 fb                	mov    %edi,%ebx
8010264a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010264d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102650:	90                   	nop
80102651:	5b                   	pop    %ebx
80102652:	5f                   	pop    %edi
80102653:	5d                   	pop    %ebp
80102654:	c3                   	ret    

80102655 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102655:	55                   	push   %ebp
80102656:	89 e5                	mov    %esp,%ebp
80102658:	83 ec 08             	sub    $0x8,%esp
8010265b:	8b 55 08             	mov    0x8(%ebp),%edx
8010265e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102661:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102665:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102668:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010266c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102670:	ee                   	out    %al,(%dx)
}
80102671:	90                   	nop
80102672:	c9                   	leave  
80102673:	c3                   	ret    

80102674 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102674:	55                   	push   %ebp
80102675:	89 e5                	mov    %esp,%ebp
80102677:	56                   	push   %esi
80102678:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102679:	8b 55 08             	mov    0x8(%ebp),%edx
8010267c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010267f:	8b 45 10             	mov    0x10(%ebp),%eax
80102682:	89 cb                	mov    %ecx,%ebx
80102684:	89 de                	mov    %ebx,%esi
80102686:	89 c1                	mov    %eax,%ecx
80102688:	fc                   	cld    
80102689:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010268b:	89 c8                	mov    %ecx,%eax
8010268d:	89 f3                	mov    %esi,%ebx
8010268f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102692:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102695:	90                   	nop
80102696:	5b                   	pop    %ebx
80102697:	5e                   	pop    %esi
80102698:	5d                   	pop    %ebp
80102699:	c3                   	ret    

8010269a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010269a:	55                   	push   %ebp
8010269b:	89 e5                	mov    %esp,%ebp
8010269d:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026a0:	90                   	nop
801026a1:	68 f7 01 00 00       	push   $0x1f7
801026a6:	e8 67 ff ff ff       	call   80102612 <inb>
801026ab:	83 c4 04             	add    $0x4,%esp
801026ae:	0f b6 c0             	movzbl %al,%eax
801026b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026b7:	25 c0 00 00 00       	and    $0xc0,%eax
801026bc:	83 f8 40             	cmp    $0x40,%eax
801026bf:	75 e0                	jne    801026a1 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c5:	74 11                	je     801026d8 <idewait+0x3e>
801026c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026ca:	83 e0 21             	and    $0x21,%eax
801026cd:	85 c0                	test   %eax,%eax
801026cf:	74 07                	je     801026d8 <idewait+0x3e>
    return -1;
801026d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026d6:	eb 05                	jmp    801026dd <idewait+0x43>
  return 0;
801026d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026dd:	c9                   	leave  
801026de:	c3                   	ret    

801026df <ideinit>:

void
ideinit(void)
{
801026df:	55                   	push   %ebp
801026e0:	89 e5                	mov    %esp,%ebp
801026e2:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026e5:	83 ec 08             	sub    $0x8,%esp
801026e8:	68 83 87 10 80       	push   $0x80108783
801026ed:	68 e0 b5 10 80       	push   $0x8010b5e0
801026f2:	e8 0f 29 00 00       	call   80105006 <initlock>
801026f7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026fa:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801026ff:	83 e8 01             	sub    $0x1,%eax
80102702:	83 ec 08             	sub    $0x8,%esp
80102705:	50                   	push   %eax
80102706:	6a 0e                	push   $0xe
80102708:	e8 a2 04 00 00       	call   80102baf <ioapicenable>
8010270d:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102710:	83 ec 0c             	sub    $0xc,%esp
80102713:	6a 00                	push   $0x0
80102715:	e8 80 ff ff ff       	call   8010269a <idewait>
8010271a:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010271d:	83 ec 08             	sub    $0x8,%esp
80102720:	68 f0 00 00 00       	push   $0xf0
80102725:	68 f6 01 00 00       	push   $0x1f6
8010272a:	e8 26 ff ff ff       	call   80102655 <outb>
8010272f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102739:	eb 24                	jmp    8010275f <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010273b:	83 ec 0c             	sub    $0xc,%esp
8010273e:	68 f7 01 00 00       	push   $0x1f7
80102743:	e8 ca fe ff ff       	call   80102612 <inb>
80102748:	83 c4 10             	add    $0x10,%esp
8010274b:	84 c0                	test   %al,%al
8010274d:	74 0c                	je     8010275b <ideinit+0x7c>
      havedisk1 = 1;
8010274f:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
80102756:	00 00 00 
      break;
80102759:	eb 0d                	jmp    80102768 <ideinit+0x89>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010275b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010275f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102766:	7e d3                	jle    8010273b <ideinit+0x5c>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102768:	83 ec 08             	sub    $0x8,%esp
8010276b:	68 e0 00 00 00       	push   $0xe0
80102770:	68 f6 01 00 00       	push   $0x1f6
80102775:	e8 db fe ff ff       	call   80102655 <outb>
8010277a:	83 c4 10             	add    $0x10,%esp
}
8010277d:	90                   	nop
8010277e:	c9                   	leave  
8010277f:	c3                   	ret    

80102780 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102780:	55                   	push   %ebp
80102781:	89 e5                	mov    %esp,%ebp
80102783:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102786:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010278a:	75 0d                	jne    80102799 <idestart+0x19>
    panic("idestart");
8010278c:	83 ec 0c             	sub    $0xc,%esp
8010278f:	68 87 87 10 80       	push   $0x80108787
80102794:	e8 07 de ff ff       	call   801005a0 <panic>
  if(b->blockno >= FSSIZE)
80102799:	8b 45 08             	mov    0x8(%ebp),%eax
8010279c:	8b 40 08             	mov    0x8(%eax),%eax
8010279f:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027a4:	76 0d                	jbe    801027b3 <idestart+0x33>
    panic("incorrect blockno");
801027a6:	83 ec 0c             	sub    $0xc,%esp
801027a9:	68 90 87 10 80       	push   $0x80108790
801027ae:	e8 ed dd ff ff       	call   801005a0 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027b3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027ba:	8b 45 08             	mov    0x8(%ebp),%eax
801027bd:	8b 50 08             	mov    0x8(%eax),%edx
801027c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c3:	0f af c2             	imul   %edx,%eax
801027c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027c9:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027cd:	75 07                	jne    801027d6 <idestart+0x56>
801027cf:	b8 20 00 00 00       	mov    $0x20,%eax
801027d4:	eb 05                	jmp    801027db <idestart+0x5b>
801027d6:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027de:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027e2:	75 07                	jne    801027eb <idestart+0x6b>
801027e4:	b8 30 00 00 00       	mov    $0x30,%eax
801027e9:	eb 05                	jmp    801027f0 <idestart+0x70>
801027eb:	b8 c5 00 00 00       	mov    $0xc5,%eax
801027f0:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027f3:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027f7:	7e 0d                	jle    80102806 <idestart+0x86>
801027f9:	83 ec 0c             	sub    $0xc,%esp
801027fc:	68 87 87 10 80       	push   $0x80108787
80102801:	e8 9a dd ff ff       	call   801005a0 <panic>

  idewait(0);
80102806:	83 ec 0c             	sub    $0xc,%esp
80102809:	6a 00                	push   $0x0
8010280b:	e8 8a fe ff ff       	call   8010269a <idewait>
80102810:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102813:	83 ec 08             	sub    $0x8,%esp
80102816:	6a 00                	push   $0x0
80102818:	68 f6 03 00 00       	push   $0x3f6
8010281d:	e8 33 fe ff ff       	call   80102655 <outb>
80102822:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102828:	0f b6 c0             	movzbl %al,%eax
8010282b:	83 ec 08             	sub    $0x8,%esp
8010282e:	50                   	push   %eax
8010282f:	68 f2 01 00 00       	push   $0x1f2
80102834:	e8 1c fe ff ff       	call   80102655 <outb>
80102839:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010283c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010283f:	0f b6 c0             	movzbl %al,%eax
80102842:	83 ec 08             	sub    $0x8,%esp
80102845:	50                   	push   %eax
80102846:	68 f3 01 00 00       	push   $0x1f3
8010284b:	e8 05 fe ff ff       	call   80102655 <outb>
80102850:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102856:	c1 f8 08             	sar    $0x8,%eax
80102859:	0f b6 c0             	movzbl %al,%eax
8010285c:	83 ec 08             	sub    $0x8,%esp
8010285f:	50                   	push   %eax
80102860:	68 f4 01 00 00       	push   $0x1f4
80102865:	e8 eb fd ff ff       	call   80102655 <outb>
8010286a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010286d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102870:	c1 f8 10             	sar    $0x10,%eax
80102873:	0f b6 c0             	movzbl %al,%eax
80102876:	83 ec 08             	sub    $0x8,%esp
80102879:	50                   	push   %eax
8010287a:	68 f5 01 00 00       	push   $0x1f5
8010287f:	e8 d1 fd ff ff       	call   80102655 <outb>
80102884:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102887:	8b 45 08             	mov    0x8(%ebp),%eax
8010288a:	8b 40 04             	mov    0x4(%eax),%eax
8010288d:	83 e0 01             	and    $0x1,%eax
80102890:	c1 e0 04             	shl    $0x4,%eax
80102893:	89 c2                	mov    %eax,%edx
80102895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102898:	c1 f8 18             	sar    $0x18,%eax
8010289b:	83 e0 0f             	and    $0xf,%eax
8010289e:	09 d0                	or     %edx,%eax
801028a0:	83 c8 e0             	or     $0xffffffe0,%eax
801028a3:	0f b6 c0             	movzbl %al,%eax
801028a6:	83 ec 08             	sub    $0x8,%esp
801028a9:	50                   	push   %eax
801028aa:	68 f6 01 00 00       	push   $0x1f6
801028af:	e8 a1 fd ff ff       	call   80102655 <outb>
801028b4:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028b7:	8b 45 08             	mov    0x8(%ebp),%eax
801028ba:	8b 00                	mov    (%eax),%eax
801028bc:	83 e0 04             	and    $0x4,%eax
801028bf:	85 c0                	test   %eax,%eax
801028c1:	74 35                	je     801028f8 <idestart+0x178>
    outb(0x1f7, write_cmd);
801028c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028c6:	0f b6 c0             	movzbl %al,%eax
801028c9:	83 ec 08             	sub    $0x8,%esp
801028cc:	50                   	push   %eax
801028cd:	68 f7 01 00 00       	push   $0x1f7
801028d2:	e8 7e fd ff ff       	call   80102655 <outb>
801028d7:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028da:	8b 45 08             	mov    0x8(%ebp),%eax
801028dd:	83 c0 5c             	add    $0x5c,%eax
801028e0:	83 ec 04             	sub    $0x4,%esp
801028e3:	68 80 00 00 00       	push   $0x80
801028e8:	50                   	push   %eax
801028e9:	68 f0 01 00 00       	push   $0x1f0
801028ee:	e8 81 fd ff ff       	call   80102674 <outsl>
801028f3:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
801028f6:	eb 17                	jmp    8010290f <idestart+0x18f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
801028f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028fb:	0f b6 c0             	movzbl %al,%eax
801028fe:	83 ec 08             	sub    $0x8,%esp
80102901:	50                   	push   %eax
80102902:	68 f7 01 00 00       	push   $0x1f7
80102907:	e8 49 fd ff ff       	call   80102655 <outb>
8010290c:	83 c4 10             	add    $0x10,%esp
  }
}
8010290f:	90                   	nop
80102910:	c9                   	leave  
80102911:	c3                   	ret    

80102912 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102912:	55                   	push   %ebp
80102913:	89 e5                	mov    %esp,%ebp
80102915:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102918:	83 ec 0c             	sub    $0xc,%esp
8010291b:	68 e0 b5 10 80       	push   $0x8010b5e0
80102920:	e8 03 27 00 00       	call   80105028 <acquire>
80102925:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102928:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010292d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102930:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102934:	75 15                	jne    8010294b <ideintr+0x39>
    release(&idelock);
80102936:	83 ec 0c             	sub    $0xc,%esp
80102939:	68 e0 b5 10 80       	push   $0x8010b5e0
8010293e:	e8 53 27 00 00       	call   80105096 <release>
80102943:	83 c4 10             	add    $0x10,%esp
    return;
80102946:	e9 9a 00 00 00       	jmp    801029e5 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010294b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294e:	8b 40 58             	mov    0x58(%eax),%eax
80102951:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102959:	8b 00                	mov    (%eax),%eax
8010295b:	83 e0 04             	and    $0x4,%eax
8010295e:	85 c0                	test   %eax,%eax
80102960:	75 2d                	jne    8010298f <ideintr+0x7d>
80102962:	83 ec 0c             	sub    $0xc,%esp
80102965:	6a 01                	push   $0x1
80102967:	e8 2e fd ff ff       	call   8010269a <idewait>
8010296c:	83 c4 10             	add    $0x10,%esp
8010296f:	85 c0                	test   %eax,%eax
80102971:	78 1c                	js     8010298f <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102976:	83 c0 5c             	add    $0x5c,%eax
80102979:	83 ec 04             	sub    $0x4,%esp
8010297c:	68 80 00 00 00       	push   $0x80
80102981:	50                   	push   %eax
80102982:	68 f0 01 00 00       	push   $0x1f0
80102987:	e8 a3 fc ff ff       	call   8010262f <insl>
8010298c:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010298f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102992:	8b 00                	mov    (%eax),%eax
80102994:	83 c8 02             	or     $0x2,%eax
80102997:	89 c2                	mov    %eax,%edx
80102999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299c:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010299e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a1:	8b 00                	mov    (%eax),%eax
801029a3:	83 e0 fb             	and    $0xfffffffb,%eax
801029a6:	89 c2                	mov    %eax,%edx
801029a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ab:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029ad:	83 ec 0c             	sub    $0xc,%esp
801029b0:	ff 75 f4             	pushl  -0xc(%ebp)
801029b3:	e8 37 23 00 00       	call   80104cef <wakeup>
801029b8:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029bb:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029c0:	85 c0                	test   %eax,%eax
801029c2:	74 11                	je     801029d5 <ideintr+0xc3>
    idestart(idequeue);
801029c4:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029c9:	83 ec 0c             	sub    $0xc,%esp
801029cc:	50                   	push   %eax
801029cd:	e8 ae fd ff ff       	call   80102780 <idestart>
801029d2:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029d5:	83 ec 0c             	sub    $0xc,%esp
801029d8:	68 e0 b5 10 80       	push   $0x8010b5e0
801029dd:	e8 b4 26 00 00       	call   80105096 <release>
801029e2:	83 c4 10             	add    $0x10,%esp
}
801029e5:	c9                   	leave  
801029e6:	c3                   	ret    

801029e7 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029e7:	55                   	push   %ebp
801029e8:	89 e5                	mov    %esp,%ebp
801029ea:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801029ed:	8b 45 08             	mov    0x8(%ebp),%eax
801029f0:	83 c0 0c             	add    $0xc,%eax
801029f3:	83 ec 0c             	sub    $0xc,%esp
801029f6:	50                   	push   %eax
801029f7:	e8 9b 25 00 00       	call   80104f97 <holdingsleep>
801029fc:	83 c4 10             	add    $0x10,%esp
801029ff:	85 c0                	test   %eax,%eax
80102a01:	75 0d                	jne    80102a10 <iderw+0x29>
    panic("iderw: buf not locked");
80102a03:	83 ec 0c             	sub    $0xc,%esp
80102a06:	68 a2 87 10 80       	push   $0x801087a2
80102a0b:	e8 90 db ff ff       	call   801005a0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a10:	8b 45 08             	mov    0x8(%ebp),%eax
80102a13:	8b 00                	mov    (%eax),%eax
80102a15:	83 e0 06             	and    $0x6,%eax
80102a18:	83 f8 02             	cmp    $0x2,%eax
80102a1b:	75 0d                	jne    80102a2a <iderw+0x43>
    panic("iderw: nothing to do");
80102a1d:	83 ec 0c             	sub    $0xc,%esp
80102a20:	68 b8 87 10 80       	push   $0x801087b8
80102a25:	e8 76 db ff ff       	call   801005a0 <panic>
  if(b->dev != 0 && !havedisk1)
80102a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2d:	8b 40 04             	mov    0x4(%eax),%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 16                	je     80102a4a <iderw+0x63>
80102a34:	a1 18 b6 10 80       	mov    0x8010b618,%eax
80102a39:	85 c0                	test   %eax,%eax
80102a3b:	75 0d                	jne    80102a4a <iderw+0x63>
    panic("iderw: ide disk 1 not present");
80102a3d:	83 ec 0c             	sub    $0xc,%esp
80102a40:	68 cd 87 10 80       	push   $0x801087cd
80102a45:	e8 56 db ff ff       	call   801005a0 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a4a:	83 ec 0c             	sub    $0xc,%esp
80102a4d:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a52:	e8 d1 25 00 00       	call   80105028 <acquire>
80102a57:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5d:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a64:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
80102a6b:	eb 0b                	jmp    80102a78 <iderw+0x91>
80102a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a70:	8b 00                	mov    (%eax),%eax
80102a72:	83 c0 58             	add    $0x58,%eax
80102a75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7b:	8b 00                	mov    (%eax),%eax
80102a7d:	85 c0                	test   %eax,%eax
80102a7f:	75 ec                	jne    80102a6d <iderw+0x86>
    ;
  *pp = b;
80102a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a84:	8b 55 08             	mov    0x8(%ebp),%edx
80102a87:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a89:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102a8e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a91:	75 23                	jne    80102ab6 <iderw+0xcf>
    idestart(b);
80102a93:	83 ec 0c             	sub    $0xc,%esp
80102a96:	ff 75 08             	pushl  0x8(%ebp)
80102a99:	e8 e2 fc ff ff       	call   80102780 <idestart>
80102a9e:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102aa1:	eb 13                	jmp    80102ab6 <iderw+0xcf>
    sleep(b, &idelock);
80102aa3:	83 ec 08             	sub    $0x8,%esp
80102aa6:	68 e0 b5 10 80       	push   $0x8010b5e0
80102aab:	ff 75 08             	pushl  0x8(%ebp)
80102aae:	e8 53 21 00 00       	call   80104c06 <sleep>
80102ab3:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab9:	8b 00                	mov    (%eax),%eax
80102abb:	83 e0 06             	and    $0x6,%eax
80102abe:	83 f8 02             	cmp    $0x2,%eax
80102ac1:	75 e0                	jne    80102aa3 <iderw+0xbc>
    sleep(b, &idelock);
  }


  release(&idelock);
80102ac3:	83 ec 0c             	sub    $0xc,%esp
80102ac6:	68 e0 b5 10 80       	push   $0x8010b5e0
80102acb:	e8 c6 25 00 00       	call   80105096 <release>
80102ad0:	83 c4 10             	add    $0x10,%esp
}
80102ad3:	90                   	nop
80102ad4:	c9                   	leave  
80102ad5:	c3                   	ret    

80102ad6 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ad6:	55                   	push   %ebp
80102ad7:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ad9:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ade:	8b 55 08             	mov    0x8(%ebp),%edx
80102ae1:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ae3:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102ae8:	8b 40 10             	mov    0x10(%eax),%eax
}
80102aeb:	5d                   	pop    %ebp
80102aec:	c3                   	ret    

80102aed <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102aed:	55                   	push   %ebp
80102aee:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102af0:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102af5:	8b 55 08             	mov    0x8(%ebp),%edx
80102af8:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102afa:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102aff:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b02:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b05:	90                   	nop
80102b06:	5d                   	pop    %ebp
80102b07:	c3                   	ret    

80102b08 <ioapicinit>:

void
ioapicinit(void)
{
80102b08:	55                   	push   %ebp
80102b09:	89 e5                	mov    %esp,%ebp
80102b0b:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b0e:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
80102b15:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b18:	6a 01                	push   $0x1
80102b1a:	e8 b7 ff ff ff       	call   80102ad6 <ioapicread>
80102b1f:	83 c4 04             	add    $0x4,%esp
80102b22:	c1 e8 10             	shr    $0x10,%eax
80102b25:	25 ff 00 00 00       	and    $0xff,%eax
80102b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b2d:	6a 00                	push   $0x0
80102b2f:	e8 a2 ff ff ff       	call   80102ad6 <ioapicread>
80102b34:	83 c4 04             	add    $0x4,%esp
80102b37:	c1 e8 18             	shr    $0x18,%eax
80102b3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b3d:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
80102b44:	0f b6 c0             	movzbl %al,%eax
80102b47:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b4a:	74 10                	je     80102b5c <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b4c:	83 ec 0c             	sub    $0xc,%esp
80102b4f:	68 ec 87 10 80       	push   $0x801087ec
80102b54:	e8 a7 d8 ff ff       	call   80100400 <cprintf>
80102b59:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b63:	eb 3f                	jmp    80102ba4 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b68:	83 c0 20             	add    $0x20,%eax
80102b6b:	0d 00 00 01 00       	or     $0x10000,%eax
80102b70:	89 c2                	mov    %eax,%edx
80102b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b75:	83 c0 08             	add    $0x8,%eax
80102b78:	01 c0                	add    %eax,%eax
80102b7a:	83 ec 08             	sub    $0x8,%esp
80102b7d:	52                   	push   %edx
80102b7e:	50                   	push   %eax
80102b7f:	e8 69 ff ff ff       	call   80102aed <ioapicwrite>
80102b84:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8a:	83 c0 08             	add    $0x8,%eax
80102b8d:	01 c0                	add    %eax,%eax
80102b8f:	83 c0 01             	add    $0x1,%eax
80102b92:	83 ec 08             	sub    $0x8,%esp
80102b95:	6a 00                	push   $0x0
80102b97:	50                   	push   %eax
80102b98:	e8 50 ff ff ff       	call   80102aed <ioapicwrite>
80102b9d:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ba0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102baa:	7e b9                	jle    80102b65 <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102bac:	90                   	nop
80102bad:	c9                   	leave  
80102bae:	c3                   	ret    

80102baf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102baf:	55                   	push   %ebp
80102bb0:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb5:	83 c0 20             	add    $0x20,%eax
80102bb8:	89 c2                	mov    %eax,%edx
80102bba:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbd:	83 c0 08             	add    $0x8,%eax
80102bc0:	01 c0                	add    %eax,%eax
80102bc2:	52                   	push   %edx
80102bc3:	50                   	push   %eax
80102bc4:	e8 24 ff ff ff       	call   80102aed <ioapicwrite>
80102bc9:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bcf:	c1 e0 18             	shl    $0x18,%eax
80102bd2:	89 c2                	mov    %eax,%edx
80102bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd7:	83 c0 08             	add    $0x8,%eax
80102bda:	01 c0                	add    %eax,%eax
80102bdc:	83 c0 01             	add    $0x1,%eax
80102bdf:	52                   	push   %edx
80102be0:	50                   	push   %eax
80102be1:	e8 07 ff ff ff       	call   80102aed <ioapicwrite>
80102be6:	83 c4 08             	add    $0x8,%esp
}
80102be9:	90                   	nop
80102bea:	c9                   	leave  
80102beb:	c3                   	ret    

80102bec <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bec:	55                   	push   %ebp
80102bed:	89 e5                	mov    %esp,%ebp
80102bef:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bf2:	83 ec 08             	sub    $0x8,%esp
80102bf5:	68 1e 88 10 80       	push   $0x8010881e
80102bfa:	68 c0 36 11 80       	push   $0x801136c0
80102bff:	e8 02 24 00 00       	call   80105006 <initlock>
80102c04:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c07:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102c0e:	00 00 00 
  freerange(vstart, vend);
80102c11:	83 ec 08             	sub    $0x8,%esp
80102c14:	ff 75 0c             	pushl  0xc(%ebp)
80102c17:	ff 75 08             	pushl  0x8(%ebp)
80102c1a:	e8 2a 00 00 00       	call   80102c49 <freerange>
80102c1f:	83 c4 10             	add    $0x10,%esp
}
80102c22:	90                   	nop
80102c23:	c9                   	leave  
80102c24:	c3                   	ret    

80102c25 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c25:	55                   	push   %ebp
80102c26:	89 e5                	mov    %esp,%ebp
80102c28:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c2b:	83 ec 08             	sub    $0x8,%esp
80102c2e:	ff 75 0c             	pushl  0xc(%ebp)
80102c31:	ff 75 08             	pushl  0x8(%ebp)
80102c34:	e8 10 00 00 00       	call   80102c49 <freerange>
80102c39:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c3c:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102c43:	00 00 00 
}
80102c46:	90                   	nop
80102c47:	c9                   	leave  
80102c48:	c3                   	ret    

80102c49 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c49:	55                   	push   %ebp
80102c4a:	89 e5                	mov    %esp,%ebp
80102c4c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c52:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c5f:	eb 15                	jmp    80102c76 <freerange+0x2d>
    kfree(p);
80102c61:	83 ec 0c             	sub    $0xc,%esp
80102c64:	ff 75 f4             	pushl  -0xc(%ebp)
80102c67:	e8 1a 00 00 00       	call   80102c86 <kfree>
80102c6c:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c6f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c79:	05 00 10 00 00       	add    $0x1000,%eax
80102c7e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c81:	76 de                	jbe    80102c61 <freerange+0x18>
    kfree(p);
}
80102c83:	90                   	nop
80102c84:	c9                   	leave  
80102c85:	c3                   	ret    

80102c86 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c86:	55                   	push   %ebp
80102c87:	89 e5                	mov    %esp,%ebp
80102c89:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c94:	85 c0                	test   %eax,%eax
80102c96:	75 18                	jne    80102cb0 <kfree+0x2a>
80102c98:	81 7d 08 74 6a 11 80 	cmpl   $0x80116a74,0x8(%ebp)
80102c9f:	72 0f                	jb     80102cb0 <kfree+0x2a>
80102ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca4:	05 00 00 00 80       	add    $0x80000000,%eax
80102ca9:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102cae:	76 0d                	jbe    80102cbd <kfree+0x37>
    panic("kfree");
80102cb0:	83 ec 0c             	sub    $0xc,%esp
80102cb3:	68 23 88 10 80       	push   $0x80108823
80102cb8:	e8 e3 d8 ff ff       	call   801005a0 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cbd:	83 ec 04             	sub    $0x4,%esp
80102cc0:	68 00 10 00 00       	push   $0x1000
80102cc5:	6a 01                	push   $0x1
80102cc7:	ff 75 08             	pushl  0x8(%ebp)
80102cca:	e8 d0 25 00 00       	call   8010529f <memset>
80102ccf:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cd2:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102cd7:	85 c0                	test   %eax,%eax
80102cd9:	74 10                	je     80102ceb <kfree+0x65>
    acquire(&kmem.lock);
80102cdb:	83 ec 0c             	sub    $0xc,%esp
80102cde:	68 c0 36 11 80       	push   $0x801136c0
80102ce3:	e8 40 23 00 00       	call   80105028 <acquire>
80102ce8:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102cf1:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cfa:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cff:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102d04:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d09:	85 c0                	test   %eax,%eax
80102d0b:	74 10                	je     80102d1d <kfree+0x97>
    release(&kmem.lock);
80102d0d:	83 ec 0c             	sub    $0xc,%esp
80102d10:	68 c0 36 11 80       	push   $0x801136c0
80102d15:	e8 7c 23 00 00       	call   80105096 <release>
80102d1a:	83 c4 10             	add    $0x10,%esp
}
80102d1d:	90                   	nop
80102d1e:	c9                   	leave  
80102d1f:	c3                   	ret    

80102d20 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d20:	55                   	push   %ebp
80102d21:	89 e5                	mov    %esp,%ebp
80102d23:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d26:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d2b:	85 c0                	test   %eax,%eax
80102d2d:	74 10                	je     80102d3f <kalloc+0x1f>
    acquire(&kmem.lock);
80102d2f:	83 ec 0c             	sub    $0xc,%esp
80102d32:	68 c0 36 11 80       	push   $0x801136c0
80102d37:	e8 ec 22 00 00       	call   80105028 <acquire>
80102d3c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d3f:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102d44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d4b:	74 0a                	je     80102d57 <kalloc+0x37>
    kmem.freelist = r->next;
80102d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d50:	8b 00                	mov    (%eax),%eax
80102d52:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102d57:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102d5c:	85 c0                	test   %eax,%eax
80102d5e:	74 10                	je     80102d70 <kalloc+0x50>
    release(&kmem.lock);
80102d60:	83 ec 0c             	sub    $0xc,%esp
80102d63:	68 c0 36 11 80       	push   $0x801136c0
80102d68:	e8 29 23 00 00       	call   80105096 <release>
80102d6d:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d73:	c9                   	leave  
80102d74:	c3                   	ret    

80102d75 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d75:	55                   	push   %ebp
80102d76:	89 e5                	mov    %esp,%ebp
80102d78:	83 ec 14             	sub    $0x14,%esp
80102d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d82:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d86:	89 c2                	mov    %eax,%edx
80102d88:	ec                   	in     (%dx),%al
80102d89:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d8c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d90:	c9                   	leave  
80102d91:	c3                   	ret    

80102d92 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d92:	55                   	push   %ebp
80102d93:	89 e5                	mov    %esp,%ebp
80102d95:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d98:	6a 64                	push   $0x64
80102d9a:	e8 d6 ff ff ff       	call   80102d75 <inb>
80102d9f:	83 c4 04             	add    $0x4,%esp
80102da2:	0f b6 c0             	movzbl %al,%eax
80102da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dab:	83 e0 01             	and    $0x1,%eax
80102dae:	85 c0                	test   %eax,%eax
80102db0:	75 0a                	jne    80102dbc <kbdgetc+0x2a>
    return -1;
80102db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102db7:	e9 23 01 00 00       	jmp    80102edf <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102dbc:	6a 60                	push   $0x60
80102dbe:	e8 b2 ff ff ff       	call   80102d75 <inb>
80102dc3:	83 c4 04             	add    $0x4,%esp
80102dc6:	0f b6 c0             	movzbl %al,%eax
80102dc9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102dcc:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dd3:	75 17                	jne    80102dec <kbdgetc+0x5a>
    shift |= E0ESC;
80102dd5:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dda:	83 c8 40             	or     $0x40,%eax
80102ddd:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102de2:	b8 00 00 00 00       	mov    $0x0,%eax
80102de7:	e9 f3 00 00 00       	jmp    80102edf <kbdgetc+0x14d>
  } else if(data & 0x80){
80102dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102def:	25 80 00 00 00       	and    $0x80,%eax
80102df4:	85 c0                	test   %eax,%eax
80102df6:	74 45                	je     80102e3d <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102df8:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dfd:	83 e0 40             	and    $0x40,%eax
80102e00:	85 c0                	test   %eax,%eax
80102e02:	75 08                	jne    80102e0c <kbdgetc+0x7a>
80102e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e07:	83 e0 7f             	and    $0x7f,%eax
80102e0a:	eb 03                	jmp    80102e0f <kbdgetc+0x7d>
80102e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e15:	05 20 90 10 80       	add    $0x80109020,%eax
80102e1a:	0f b6 00             	movzbl (%eax),%eax
80102e1d:	83 c8 40             	or     $0x40,%eax
80102e20:	0f b6 c0             	movzbl %al,%eax
80102e23:	f7 d0                	not    %eax
80102e25:	89 c2                	mov    %eax,%edx
80102e27:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e2c:	21 d0                	and    %edx,%eax
80102e2e:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102e33:	b8 00 00 00 00       	mov    $0x0,%eax
80102e38:	e9 a2 00 00 00       	jmp    80102edf <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e3d:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e42:	83 e0 40             	and    $0x40,%eax
80102e45:	85 c0                	test   %eax,%eax
80102e47:	74 14                	je     80102e5d <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e49:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e50:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e55:	83 e0 bf             	and    $0xffffffbf,%eax
80102e58:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102e5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e60:	05 20 90 10 80       	add    $0x80109020,%eax
80102e65:	0f b6 00             	movzbl (%eax),%eax
80102e68:	0f b6 d0             	movzbl %al,%edx
80102e6b:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e70:	09 d0                	or     %edx,%eax
80102e72:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102e77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e7a:	05 20 91 10 80       	add    $0x80109120,%eax
80102e7f:	0f b6 00             	movzbl (%eax),%eax
80102e82:	0f b6 d0             	movzbl %al,%edx
80102e85:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e8a:	31 d0                	xor    %edx,%eax
80102e8c:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e91:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e96:	83 e0 03             	and    $0x3,%eax
80102e99:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102ea0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ea3:	01 d0                	add    %edx,%eax
80102ea5:	0f b6 00             	movzbl (%eax),%eax
80102ea8:	0f b6 c0             	movzbl %al,%eax
80102eab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102eae:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102eb3:	83 e0 08             	and    $0x8,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	74 22                	je     80102edc <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102eba:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ebe:	76 0c                	jbe    80102ecc <kbdgetc+0x13a>
80102ec0:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ec4:	77 06                	ja     80102ecc <kbdgetc+0x13a>
      c += 'A' - 'a';
80102ec6:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102eca:	eb 10                	jmp    80102edc <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ecc:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ed0:	76 0a                	jbe    80102edc <kbdgetc+0x14a>
80102ed2:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ed6:	77 04                	ja     80102edc <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ed8:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102edc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102edf:	c9                   	leave  
80102ee0:	c3                   	ret    

80102ee1 <kbdintr>:

void
kbdintr(void)
{
80102ee1:	55                   	push   %ebp
80102ee2:	89 e5                	mov    %esp,%ebp
80102ee4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ee7:	83 ec 0c             	sub    $0xc,%esp
80102eea:	68 92 2d 10 80       	push   $0x80102d92
80102eef:	e8 38 d9 ff ff       	call   8010082c <consoleintr>
80102ef4:	83 c4 10             	add    $0x10,%esp
}
80102ef7:	90                   	nop
80102ef8:	c9                   	leave  
80102ef9:	c3                   	ret    

80102efa <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 14             	sub    $0x14,%esp
80102f00:	8b 45 08             	mov    0x8(%ebp),%eax
80102f03:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f07:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f0b:	89 c2                	mov    %eax,%edx
80102f0d:	ec                   	in     (%dx),%al
80102f0e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f11:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f15:	c9                   	leave  
80102f16:	c3                   	ret    

80102f17 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f17:	55                   	push   %ebp
80102f18:	89 e5                	mov    %esp,%ebp
80102f1a:	83 ec 08             	sub    $0x8,%esp
80102f1d:	8b 55 08             	mov    0x8(%ebp),%edx
80102f20:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f23:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f27:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f2a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f2e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f32:	ee                   	out    %al,(%dx)
}
80102f33:	90                   	nop
80102f34:	c9                   	leave  
80102f35:	c3                   	ret    

80102f36 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f36:	55                   	push   %ebp
80102f37:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f39:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f3e:	8b 55 08             	mov    0x8(%ebp),%edx
80102f41:	c1 e2 02             	shl    $0x2,%edx
80102f44:	01 c2                	add    %eax,%edx
80102f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f49:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f4b:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f50:	83 c0 20             	add    $0x20,%eax
80102f53:	8b 00                	mov    (%eax),%eax
}
80102f55:	90                   	nop
80102f56:	5d                   	pop    %ebp
80102f57:	c3                   	ret    

80102f58 <lapicinit>:

void
lapicinit(void)
{
80102f58:	55                   	push   %ebp
80102f59:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102f5b:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f60:	85 c0                	test   %eax,%eax
80102f62:	0f 84 0b 01 00 00    	je     80103073 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f68:	68 3f 01 00 00       	push   $0x13f
80102f6d:	6a 3c                	push   $0x3c
80102f6f:	e8 c2 ff ff ff       	call   80102f36 <lapicw>
80102f74:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f77:	6a 0b                	push   $0xb
80102f79:	68 f8 00 00 00       	push   $0xf8
80102f7e:	e8 b3 ff ff ff       	call   80102f36 <lapicw>
80102f83:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f86:	68 20 00 02 00       	push   $0x20020
80102f8b:	68 c8 00 00 00       	push   $0xc8
80102f90:	e8 a1 ff ff ff       	call   80102f36 <lapicw>
80102f95:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f98:	68 80 96 98 00       	push   $0x989680
80102f9d:	68 e0 00 00 00       	push   $0xe0
80102fa2:	e8 8f ff ff ff       	call   80102f36 <lapicw>
80102fa7:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102faa:	68 00 00 01 00       	push   $0x10000
80102faf:	68 d4 00 00 00       	push   $0xd4
80102fb4:	e8 7d ff ff ff       	call   80102f36 <lapicw>
80102fb9:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fbc:	68 00 00 01 00       	push   $0x10000
80102fc1:	68 d8 00 00 00       	push   $0xd8
80102fc6:	e8 6b ff ff ff       	call   80102f36 <lapicw>
80102fcb:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fce:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fd3:	83 c0 30             	add    $0x30,%eax
80102fd6:	8b 00                	mov    (%eax),%eax
80102fd8:	c1 e8 10             	shr    $0x10,%eax
80102fdb:	0f b6 c0             	movzbl %al,%eax
80102fde:	83 f8 03             	cmp    $0x3,%eax
80102fe1:	76 12                	jbe    80102ff5 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102fe3:	68 00 00 01 00       	push   $0x10000
80102fe8:	68 d0 00 00 00       	push   $0xd0
80102fed:	e8 44 ff ff ff       	call   80102f36 <lapicw>
80102ff2:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ff5:	6a 33                	push   $0x33
80102ff7:	68 dc 00 00 00       	push   $0xdc
80102ffc:	e8 35 ff ff ff       	call   80102f36 <lapicw>
80103001:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103004:	6a 00                	push   $0x0
80103006:	68 a0 00 00 00       	push   $0xa0
8010300b:	e8 26 ff ff ff       	call   80102f36 <lapicw>
80103010:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103013:	6a 00                	push   $0x0
80103015:	68 a0 00 00 00       	push   $0xa0
8010301a:	e8 17 ff ff ff       	call   80102f36 <lapicw>
8010301f:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103022:	6a 00                	push   $0x0
80103024:	6a 2c                	push   $0x2c
80103026:	e8 0b ff ff ff       	call   80102f36 <lapicw>
8010302b:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010302e:	6a 00                	push   $0x0
80103030:	68 c4 00 00 00       	push   $0xc4
80103035:	e8 fc fe ff ff       	call   80102f36 <lapicw>
8010303a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010303d:	68 00 85 08 00       	push   $0x88500
80103042:	68 c0 00 00 00       	push   $0xc0
80103047:	e8 ea fe ff ff       	call   80102f36 <lapicw>
8010304c:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010304f:	90                   	nop
80103050:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103055:	05 00 03 00 00       	add    $0x300,%eax
8010305a:	8b 00                	mov    (%eax),%eax
8010305c:	25 00 10 00 00       	and    $0x1000,%eax
80103061:	85 c0                	test   %eax,%eax
80103063:	75 eb                	jne    80103050 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103065:	6a 00                	push   $0x0
80103067:	6a 20                	push   $0x20
80103069:	e8 c8 fe ff ff       	call   80102f36 <lapicw>
8010306e:	83 c4 08             	add    $0x8,%esp
80103071:	eb 01                	jmp    80103074 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic)
    return;
80103073:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103074:	c9                   	leave  
80103075:	c3                   	ret    

80103076 <lapicid>:

int
lapicid(void)
{
80103076:	55                   	push   %ebp
80103077:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103079:	a1 fc 36 11 80       	mov    0x801136fc,%eax
8010307e:	85 c0                	test   %eax,%eax
80103080:	75 07                	jne    80103089 <lapicid+0x13>
    return 0;
80103082:	b8 00 00 00 00       	mov    $0x0,%eax
80103087:	eb 0d                	jmp    80103096 <lapicid+0x20>
  return lapic[ID] >> 24;
80103089:	a1 fc 36 11 80       	mov    0x801136fc,%eax
8010308e:	83 c0 20             	add    $0x20,%eax
80103091:	8b 00                	mov    (%eax),%eax
80103093:	c1 e8 18             	shr    $0x18,%eax
}
80103096:	5d                   	pop    %ebp
80103097:	c3                   	ret    

80103098 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103098:	55                   	push   %ebp
80103099:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010309b:	a1 fc 36 11 80       	mov    0x801136fc,%eax
801030a0:	85 c0                	test   %eax,%eax
801030a2:	74 0c                	je     801030b0 <lapiceoi+0x18>
    lapicw(EOI, 0);
801030a4:	6a 00                	push   $0x0
801030a6:	6a 2c                	push   $0x2c
801030a8:	e8 89 fe ff ff       	call   80102f36 <lapicw>
801030ad:	83 c4 08             	add    $0x8,%esp
}
801030b0:	90                   	nop
801030b1:	c9                   	leave  
801030b2:	c3                   	ret    

801030b3 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030b3:	55                   	push   %ebp
801030b4:	89 e5                	mov    %esp,%ebp
}
801030b6:	90                   	nop
801030b7:	5d                   	pop    %ebp
801030b8:	c3                   	ret    

801030b9 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030b9:	55                   	push   %ebp
801030ba:	89 e5                	mov    %esp,%ebp
801030bc:	83 ec 14             	sub    $0x14,%esp
801030bf:	8b 45 08             	mov    0x8(%ebp),%eax
801030c2:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030c5:	6a 0f                	push   $0xf
801030c7:	6a 70                	push   $0x70
801030c9:	e8 49 fe ff ff       	call   80102f17 <outb>
801030ce:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801030d1:	6a 0a                	push   $0xa
801030d3:	6a 71                	push   $0x71
801030d5:	e8 3d fe ff ff       	call   80102f17 <outb>
801030da:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030dd:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030e7:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030ef:	83 c0 02             	add    $0x2,%eax
801030f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801030f5:	c1 ea 04             	shr    $0x4,%edx
801030f8:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030fb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030ff:	c1 e0 18             	shl    $0x18,%eax
80103102:	50                   	push   %eax
80103103:	68 c4 00 00 00       	push   $0xc4
80103108:	e8 29 fe ff ff       	call   80102f36 <lapicw>
8010310d:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103110:	68 00 c5 00 00       	push   $0xc500
80103115:	68 c0 00 00 00       	push   $0xc0
8010311a:	e8 17 fe ff ff       	call   80102f36 <lapicw>
8010311f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103122:	68 c8 00 00 00       	push   $0xc8
80103127:	e8 87 ff ff ff       	call   801030b3 <microdelay>
8010312c:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010312f:	68 00 85 00 00       	push   $0x8500
80103134:	68 c0 00 00 00       	push   $0xc0
80103139:	e8 f8 fd ff ff       	call   80102f36 <lapicw>
8010313e:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103141:	6a 64                	push   $0x64
80103143:	e8 6b ff ff ff       	call   801030b3 <microdelay>
80103148:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010314b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103152:	eb 3d                	jmp    80103191 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103154:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103158:	c1 e0 18             	shl    $0x18,%eax
8010315b:	50                   	push   %eax
8010315c:	68 c4 00 00 00       	push   $0xc4
80103161:	e8 d0 fd ff ff       	call   80102f36 <lapicw>
80103166:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103169:	8b 45 0c             	mov    0xc(%ebp),%eax
8010316c:	c1 e8 0c             	shr    $0xc,%eax
8010316f:	80 cc 06             	or     $0x6,%ah
80103172:	50                   	push   %eax
80103173:	68 c0 00 00 00       	push   $0xc0
80103178:	e8 b9 fd ff ff       	call   80102f36 <lapicw>
8010317d:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103180:	68 c8 00 00 00       	push   $0xc8
80103185:	e8 29 ff ff ff       	call   801030b3 <microdelay>
8010318a:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010318d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103191:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103195:	7e bd                	jle    80103154 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103197:	90                   	nop
80103198:	c9                   	leave  
80103199:	c3                   	ret    

8010319a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010319d:	8b 45 08             	mov    0x8(%ebp),%eax
801031a0:	0f b6 c0             	movzbl %al,%eax
801031a3:	50                   	push   %eax
801031a4:	6a 70                	push   $0x70
801031a6:	e8 6c fd ff ff       	call   80102f17 <outb>
801031ab:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031ae:	68 c8 00 00 00       	push   $0xc8
801031b3:	e8 fb fe ff ff       	call   801030b3 <microdelay>
801031b8:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031bb:	6a 71                	push   $0x71
801031bd:	e8 38 fd ff ff       	call   80102efa <inb>
801031c2:	83 c4 04             	add    $0x4,%esp
801031c5:	0f b6 c0             	movzbl %al,%eax
}
801031c8:	c9                   	leave  
801031c9:	c3                   	ret    

801031ca <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031ca:	55                   	push   %ebp
801031cb:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801031cd:	6a 00                	push   $0x0
801031cf:	e8 c6 ff ff ff       	call   8010319a <cmos_read>
801031d4:	83 c4 04             	add    $0x4,%esp
801031d7:	89 c2                	mov    %eax,%edx
801031d9:	8b 45 08             	mov    0x8(%ebp),%eax
801031dc:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801031de:	6a 02                	push   $0x2
801031e0:	e8 b5 ff ff ff       	call   8010319a <cmos_read>
801031e5:	83 c4 04             	add    $0x4,%esp
801031e8:	89 c2                	mov    %eax,%edx
801031ea:	8b 45 08             	mov    0x8(%ebp),%eax
801031ed:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801031f0:	6a 04                	push   $0x4
801031f2:	e8 a3 ff ff ff       	call   8010319a <cmos_read>
801031f7:	83 c4 04             	add    $0x4,%esp
801031fa:	89 c2                	mov    %eax,%edx
801031fc:	8b 45 08             	mov    0x8(%ebp),%eax
801031ff:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103202:	6a 07                	push   $0x7
80103204:	e8 91 ff ff ff       	call   8010319a <cmos_read>
80103209:	83 c4 04             	add    $0x4,%esp
8010320c:	89 c2                	mov    %eax,%edx
8010320e:	8b 45 08             	mov    0x8(%ebp),%eax
80103211:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103214:	6a 08                	push   $0x8
80103216:	e8 7f ff ff ff       	call   8010319a <cmos_read>
8010321b:	83 c4 04             	add    $0x4,%esp
8010321e:	89 c2                	mov    %eax,%edx
80103220:	8b 45 08             	mov    0x8(%ebp),%eax
80103223:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103226:	6a 09                	push   $0x9
80103228:	e8 6d ff ff ff       	call   8010319a <cmos_read>
8010322d:	83 c4 04             	add    $0x4,%esp
80103230:	89 c2                	mov    %eax,%edx
80103232:	8b 45 08             	mov    0x8(%ebp),%eax
80103235:	89 50 14             	mov    %edx,0x14(%eax)
}
80103238:	90                   	nop
80103239:	c9                   	leave  
8010323a:	c3                   	ret    

8010323b <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010323b:	55                   	push   %ebp
8010323c:	89 e5                	mov    %esp,%ebp
8010323e:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103241:	6a 0b                	push   $0xb
80103243:	e8 52 ff ff ff       	call   8010319a <cmos_read>
80103248:	83 c4 04             	add    $0x4,%esp
8010324b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010324e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103251:	83 e0 04             	and    $0x4,%eax
80103254:	85 c0                	test   %eax,%eax
80103256:	0f 94 c0             	sete   %al
80103259:	0f b6 c0             	movzbl %al,%eax
8010325c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010325f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103262:	50                   	push   %eax
80103263:	e8 62 ff ff ff       	call   801031ca <fill_rtcdate>
80103268:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010326b:	6a 0a                	push   $0xa
8010326d:	e8 28 ff ff ff       	call   8010319a <cmos_read>
80103272:	83 c4 04             	add    $0x4,%esp
80103275:	25 80 00 00 00       	and    $0x80,%eax
8010327a:	85 c0                	test   %eax,%eax
8010327c:	75 27                	jne    801032a5 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010327e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103281:	50                   	push   %eax
80103282:	e8 43 ff ff ff       	call   801031ca <fill_rtcdate>
80103287:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010328a:	83 ec 04             	sub    $0x4,%esp
8010328d:	6a 18                	push   $0x18
8010328f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103292:	50                   	push   %eax
80103293:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103296:	50                   	push   %eax
80103297:	e8 6a 20 00 00       	call   80105306 <memcmp>
8010329c:	83 c4 10             	add    $0x10,%esp
8010329f:	85 c0                	test   %eax,%eax
801032a1:	74 05                	je     801032a8 <cmostime+0x6d>
801032a3:	eb ba                	jmp    8010325f <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032a5:	90                   	nop
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032a6:	eb b7                	jmp    8010325f <cmostime+0x24>
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032a8:	90                   	nop
  }

  // convert
  if(bcd) {
801032a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032ad:	0f 84 b4 00 00 00    	je     80103367 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032b6:	c1 e8 04             	shr    $0x4,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	89 d0                	mov    %edx,%eax
801032bd:	c1 e0 02             	shl    $0x2,%eax
801032c0:	01 d0                	add    %edx,%eax
801032c2:	01 c0                	add    %eax,%eax
801032c4:	89 c2                	mov    %eax,%edx
801032c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032c9:	83 e0 0f             	and    $0xf,%eax
801032cc:	01 d0                	add    %edx,%eax
801032ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801032d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032d4:	c1 e8 04             	shr    $0x4,%eax
801032d7:	89 c2                	mov    %eax,%edx
801032d9:	89 d0                	mov    %edx,%eax
801032db:	c1 e0 02             	shl    $0x2,%eax
801032de:	01 d0                	add    %edx,%eax
801032e0:	01 c0                	add    %eax,%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032e7:	83 e0 0f             	and    $0xf,%eax
801032ea:	01 d0                	add    %edx,%eax
801032ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032f2:	c1 e8 04             	shr    $0x4,%eax
801032f5:	89 c2                	mov    %eax,%edx
801032f7:	89 d0                	mov    %edx,%eax
801032f9:	c1 e0 02             	shl    $0x2,%eax
801032fc:	01 d0                	add    %edx,%eax
801032fe:	01 c0                	add    %eax,%eax
80103300:	89 c2                	mov    %eax,%edx
80103302:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103305:	83 e0 0f             	and    $0xf,%eax
80103308:	01 d0                	add    %edx,%eax
8010330a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010330d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103310:	c1 e8 04             	shr    $0x4,%eax
80103313:	89 c2                	mov    %eax,%edx
80103315:	89 d0                	mov    %edx,%eax
80103317:	c1 e0 02             	shl    $0x2,%eax
8010331a:	01 d0                	add    %edx,%eax
8010331c:	01 c0                	add    %eax,%eax
8010331e:	89 c2                	mov    %eax,%edx
80103320:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103323:	83 e0 0f             	and    $0xf,%eax
80103326:	01 d0                	add    %edx,%eax
80103328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010332b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010332e:	c1 e8 04             	shr    $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	89 d0                	mov    %edx,%eax
80103335:	c1 e0 02             	shl    $0x2,%eax
80103338:	01 d0                	add    %edx,%eax
8010333a:	01 c0                	add    %eax,%eax
8010333c:	89 c2                	mov    %eax,%edx
8010333e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103341:	83 e0 0f             	and    $0xf,%eax
80103344:	01 d0                	add    %edx,%eax
80103346:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103349:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010334c:	c1 e8 04             	shr    $0x4,%eax
8010334f:	89 c2                	mov    %eax,%edx
80103351:	89 d0                	mov    %edx,%eax
80103353:	c1 e0 02             	shl    $0x2,%eax
80103356:	01 d0                	add    %edx,%eax
80103358:	01 c0                	add    %eax,%eax
8010335a:	89 c2                	mov    %eax,%edx
8010335c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010335f:	83 e0 0f             	and    $0xf,%eax
80103362:	01 d0                	add    %edx,%eax
80103364:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103367:	8b 45 08             	mov    0x8(%ebp),%eax
8010336a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010336d:	89 10                	mov    %edx,(%eax)
8010336f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103372:	89 50 04             	mov    %edx,0x4(%eax)
80103375:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103378:	89 50 08             	mov    %edx,0x8(%eax)
8010337b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010337e:	89 50 0c             	mov    %edx,0xc(%eax)
80103381:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103384:	89 50 10             	mov    %edx,0x10(%eax)
80103387:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010338a:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010338d:	8b 45 08             	mov    0x8(%ebp),%eax
80103390:	8b 40 14             	mov    0x14(%eax),%eax
80103393:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103399:	8b 45 08             	mov    0x8(%ebp),%eax
8010339c:	89 50 14             	mov    %edx,0x14(%eax)
}
8010339f:	90                   	nop
801033a0:	c9                   	leave  
801033a1:	c3                   	ret    

801033a2 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033a2:	55                   	push   %ebp
801033a3:	89 e5                	mov    %esp,%ebp
801033a5:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033a8:	83 ec 08             	sub    $0x8,%esp
801033ab:	68 29 88 10 80       	push   $0x80108829
801033b0:	68 00 37 11 80       	push   $0x80113700
801033b5:	e8 4c 1c 00 00       	call   80105006 <initlock>
801033ba:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033bd:	83 ec 08             	sub    $0x8,%esp
801033c0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033c3:	50                   	push   %eax
801033c4:	ff 75 08             	pushl  0x8(%ebp)
801033c7:	e8 a3 e0 ff ff       	call   8010146f <readsb>
801033cc:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d2:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
801033d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033da:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
801033df:	8b 45 08             	mov    0x8(%ebp),%eax
801033e2:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
801033e7:	e8 b2 01 00 00       	call   8010359e <recover_from_log>
}
801033ec:	90                   	nop
801033ed:	c9                   	leave  
801033ee:	c3                   	ret    

801033ef <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801033ef:	55                   	push   %ebp
801033f0:	89 e5                	mov    %esp,%ebp
801033f2:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033fc:	e9 95 00 00 00       	jmp    80103496 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103401:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010340a:	01 d0                	add    %edx,%eax
8010340c:	83 c0 01             	add    $0x1,%eax
8010340f:	89 c2                	mov    %eax,%edx
80103411:	a1 44 37 11 80       	mov    0x80113744,%eax
80103416:	83 ec 08             	sub    $0x8,%esp
80103419:	52                   	push   %edx
8010341a:	50                   	push   %eax
8010341b:	e8 ae cd ff ff       	call   801001ce <bread>
80103420:	83 c4 10             	add    $0x10,%esp
80103423:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103429:	83 c0 10             	add    $0x10,%eax
8010342c:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103433:	89 c2                	mov    %eax,%edx
80103435:	a1 44 37 11 80       	mov    0x80113744,%eax
8010343a:	83 ec 08             	sub    $0x8,%esp
8010343d:	52                   	push   %edx
8010343e:	50                   	push   %eax
8010343f:	e8 8a cd ff ff       	call   801001ce <bread>
80103444:	83 c4 10             	add    $0x10,%esp
80103447:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010344a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010344d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103453:	83 c0 5c             	add    $0x5c,%eax
80103456:	83 ec 04             	sub    $0x4,%esp
80103459:	68 00 02 00 00       	push   $0x200
8010345e:	52                   	push   %edx
8010345f:	50                   	push   %eax
80103460:	e8 f9 1e 00 00       	call   8010535e <memmove>
80103465:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103468:	83 ec 0c             	sub    $0xc,%esp
8010346b:	ff 75 ec             	pushl  -0x14(%ebp)
8010346e:	e8 94 cd ff ff       	call   80100207 <bwrite>
80103473:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103476:	83 ec 0c             	sub    $0xc,%esp
80103479:	ff 75 f0             	pushl  -0x10(%ebp)
8010347c:	e8 cf cd ff ff       	call   80100250 <brelse>
80103481:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103484:	83 ec 0c             	sub    $0xc,%esp
80103487:	ff 75 ec             	pushl  -0x14(%ebp)
8010348a:	e8 c1 cd ff ff       	call   80100250 <brelse>
8010348f:	83 c4 10             	add    $0x10,%esp
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103492:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103496:	a1 48 37 11 80       	mov    0x80113748,%eax
8010349b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010349e:	0f 8f 5d ff ff ff    	jg     80103401 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801034a4:	90                   	nop
801034a5:	c9                   	leave  
801034a6:	c3                   	ret    

801034a7 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034a7:	55                   	push   %ebp
801034a8:	89 e5                	mov    %esp,%ebp
801034aa:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ad:	a1 34 37 11 80       	mov    0x80113734,%eax
801034b2:	89 c2                	mov    %eax,%edx
801034b4:	a1 44 37 11 80       	mov    0x80113744,%eax
801034b9:	83 ec 08             	sub    $0x8,%esp
801034bc:	52                   	push   %edx
801034bd:	50                   	push   %eax
801034be:	e8 0b cd ff ff       	call   801001ce <bread>
801034c3:	83 c4 10             	add    $0x10,%esp
801034c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 c0 5c             	add    $0x5c,%eax
801034cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d5:	8b 00                	mov    (%eax),%eax
801034d7:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
801034dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e3:	eb 1b                	jmp    80103500 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
801034e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034eb:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034f2:	83 c2 10             	add    $0x10,%edx
801034f5:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103500:	a1 48 37 11 80       	mov    0x80113748,%eax
80103505:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103508:	7f db                	jg     801034e5 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010350a:	83 ec 0c             	sub    $0xc,%esp
8010350d:	ff 75 f0             	pushl  -0x10(%ebp)
80103510:	e8 3b cd ff ff       	call   80100250 <brelse>
80103515:	83 c4 10             	add    $0x10,%esp
}
80103518:	90                   	nop
80103519:	c9                   	leave  
8010351a:	c3                   	ret    

8010351b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010351b:	55                   	push   %ebp
8010351c:	89 e5                	mov    %esp,%ebp
8010351e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103521:	a1 34 37 11 80       	mov    0x80113734,%eax
80103526:	89 c2                	mov    %eax,%edx
80103528:	a1 44 37 11 80       	mov    0x80113744,%eax
8010352d:	83 ec 08             	sub    $0x8,%esp
80103530:	52                   	push   %edx
80103531:	50                   	push   %eax
80103532:	e8 97 cc ff ff       	call   801001ce <bread>
80103537:	83 c4 10             	add    $0x10,%esp
8010353a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010353d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103540:	83 c0 5c             	add    $0x5c,%eax
80103543:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103546:	8b 15 48 37 11 80    	mov    0x80113748,%edx
8010354c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010354f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103551:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103558:	eb 1b                	jmp    80103575 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010355a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010355d:	83 c0 10             	add    $0x10,%eax
80103560:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
80103567:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010356a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010356d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103571:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103575:	a1 48 37 11 80       	mov    0x80113748,%eax
8010357a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010357d:	7f db                	jg     8010355a <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010357f:	83 ec 0c             	sub    $0xc,%esp
80103582:	ff 75 f0             	pushl  -0x10(%ebp)
80103585:	e8 7d cc ff ff       	call   80100207 <bwrite>
8010358a:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010358d:	83 ec 0c             	sub    $0xc,%esp
80103590:	ff 75 f0             	pushl  -0x10(%ebp)
80103593:	e8 b8 cc ff ff       	call   80100250 <brelse>
80103598:	83 c4 10             	add    $0x10,%esp
}
8010359b:	90                   	nop
8010359c:	c9                   	leave  
8010359d:	c3                   	ret    

8010359e <recover_from_log>:

static void
recover_from_log(void)
{
8010359e:	55                   	push   %ebp
8010359f:	89 e5                	mov    %esp,%ebp
801035a1:	83 ec 08             	sub    $0x8,%esp
  read_head();
801035a4:	e8 fe fe ff ff       	call   801034a7 <read_head>
  install_trans(); // if committed, copy from log to disk
801035a9:	e8 41 fe ff ff       	call   801033ef <install_trans>
  log.lh.n = 0;
801035ae:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
801035b5:	00 00 00 
  write_head(); // clear the log
801035b8:	e8 5e ff ff ff       	call   8010351b <write_head>
}
801035bd:	90                   	nop
801035be:	c9                   	leave  
801035bf:	c3                   	ret    

801035c0 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035c0:	55                   	push   %ebp
801035c1:	89 e5                	mov    %esp,%ebp
801035c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035c6:	83 ec 0c             	sub    $0xc,%esp
801035c9:	68 00 37 11 80       	push   $0x80113700
801035ce:	e8 55 1a 00 00       	call   80105028 <acquire>
801035d3:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801035d6:	a1 40 37 11 80       	mov    0x80113740,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 17                	je     801035f6 <begin_op+0x36>
      sleep(&log, &log.lock);
801035df:	83 ec 08             	sub    $0x8,%esp
801035e2:	68 00 37 11 80       	push   $0x80113700
801035e7:	68 00 37 11 80       	push   $0x80113700
801035ec:	e8 15 16 00 00       	call   80104c06 <sleep>
801035f1:	83 c4 10             	add    $0x10,%esp
801035f4:	eb e0                	jmp    801035d6 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035f6:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
801035fc:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103601:	8d 50 01             	lea    0x1(%eax),%edx
80103604:	89 d0                	mov    %edx,%eax
80103606:	c1 e0 02             	shl    $0x2,%eax
80103609:	01 d0                	add    %edx,%eax
8010360b:	01 c0                	add    %eax,%eax
8010360d:	01 c8                	add    %ecx,%eax
8010360f:	83 f8 1e             	cmp    $0x1e,%eax
80103612:	7e 17                	jle    8010362b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103614:	83 ec 08             	sub    $0x8,%esp
80103617:	68 00 37 11 80       	push   $0x80113700
8010361c:	68 00 37 11 80       	push   $0x80113700
80103621:	e8 e0 15 00 00       	call   80104c06 <sleep>
80103626:	83 c4 10             	add    $0x10,%esp
80103629:	eb ab                	jmp    801035d6 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010362b:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103630:	83 c0 01             	add    $0x1,%eax
80103633:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
80103638:	83 ec 0c             	sub    $0xc,%esp
8010363b:	68 00 37 11 80       	push   $0x80113700
80103640:	e8 51 1a 00 00       	call   80105096 <release>
80103645:	83 c4 10             	add    $0x10,%esp
      break;
80103648:	90                   	nop
    }
  }
}
80103649:	90                   	nop
8010364a:	c9                   	leave  
8010364b:	c3                   	ret    

8010364c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010364c:	55                   	push   %ebp
8010364d:	89 e5                	mov    %esp,%ebp
8010364f:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103659:	83 ec 0c             	sub    $0xc,%esp
8010365c:	68 00 37 11 80       	push   $0x80113700
80103661:	e8 c2 19 00 00       	call   80105028 <acquire>
80103666:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103669:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010366e:	83 e8 01             	sub    $0x1,%eax
80103671:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
80103676:	a1 40 37 11 80       	mov    0x80113740,%eax
8010367b:	85 c0                	test   %eax,%eax
8010367d:	74 0d                	je     8010368c <end_op+0x40>
    panic("log.committing");
8010367f:	83 ec 0c             	sub    $0xc,%esp
80103682:	68 2d 88 10 80       	push   $0x8010882d
80103687:	e8 14 cf ff ff       	call   801005a0 <panic>
  if(log.outstanding == 0){
8010368c:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103691:	85 c0                	test   %eax,%eax
80103693:	75 13                	jne    801036a8 <end_op+0x5c>
    do_commit = 1;
80103695:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010369c:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
801036a3:	00 00 00 
801036a6:	eb 10                	jmp    801036b8 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801036a8:	83 ec 0c             	sub    $0xc,%esp
801036ab:	68 00 37 11 80       	push   $0x80113700
801036b0:	e8 3a 16 00 00       	call   80104cef <wakeup>
801036b5:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036b8:	83 ec 0c             	sub    $0xc,%esp
801036bb:	68 00 37 11 80       	push   $0x80113700
801036c0:	e8 d1 19 00 00       	call   80105096 <release>
801036c5:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036cc:	74 3f                	je     8010370d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036ce:	e8 f5 00 00 00       	call   801037c8 <commit>
    acquire(&log.lock);
801036d3:	83 ec 0c             	sub    $0xc,%esp
801036d6:	68 00 37 11 80       	push   $0x80113700
801036db:	e8 48 19 00 00       	call   80105028 <acquire>
801036e0:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801036e3:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
801036ea:	00 00 00 
    wakeup(&log);
801036ed:	83 ec 0c             	sub    $0xc,%esp
801036f0:	68 00 37 11 80       	push   $0x80113700
801036f5:	e8 f5 15 00 00       	call   80104cef <wakeup>
801036fa:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036fd:	83 ec 0c             	sub    $0xc,%esp
80103700:	68 00 37 11 80       	push   $0x80113700
80103705:	e8 8c 19 00 00       	call   80105096 <release>
8010370a:	83 c4 10             	add    $0x10,%esp
  }
}
8010370d:	90                   	nop
8010370e:	c9                   	leave  
8010370f:	c3                   	ret    

80103710 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103710:	55                   	push   %ebp
80103711:	89 e5                	mov    %esp,%ebp
80103713:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010371d:	e9 95 00 00 00       	jmp    801037b7 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103722:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010372b:	01 d0                	add    %edx,%eax
8010372d:	83 c0 01             	add    $0x1,%eax
80103730:	89 c2                	mov    %eax,%edx
80103732:	a1 44 37 11 80       	mov    0x80113744,%eax
80103737:	83 ec 08             	sub    $0x8,%esp
8010373a:	52                   	push   %edx
8010373b:	50                   	push   %eax
8010373c:	e8 8d ca ff ff       	call   801001ce <bread>
80103741:	83 c4 10             	add    $0x10,%esp
80103744:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374a:	83 c0 10             	add    $0x10,%eax
8010374d:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103754:	89 c2                	mov    %eax,%edx
80103756:	a1 44 37 11 80       	mov    0x80113744,%eax
8010375b:	83 ec 08             	sub    $0x8,%esp
8010375e:	52                   	push   %edx
8010375f:	50                   	push   %eax
80103760:	e8 69 ca ff ff       	call   801001ce <bread>
80103765:	83 c4 10             	add    $0x10,%esp
80103768:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010376b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010376e:	8d 50 5c             	lea    0x5c(%eax),%edx
80103771:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103774:	83 c0 5c             	add    $0x5c,%eax
80103777:	83 ec 04             	sub    $0x4,%esp
8010377a:	68 00 02 00 00       	push   $0x200
8010377f:	52                   	push   %edx
80103780:	50                   	push   %eax
80103781:	e8 d8 1b 00 00       	call   8010535e <memmove>
80103786:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103789:	83 ec 0c             	sub    $0xc,%esp
8010378c:	ff 75 f0             	pushl  -0x10(%ebp)
8010378f:	e8 73 ca ff ff       	call   80100207 <bwrite>
80103794:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103797:	83 ec 0c             	sub    $0xc,%esp
8010379a:	ff 75 ec             	pushl  -0x14(%ebp)
8010379d:	e8 ae ca ff ff       	call   80100250 <brelse>
801037a2:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037a5:	83 ec 0c             	sub    $0xc,%esp
801037a8:	ff 75 f0             	pushl  -0x10(%ebp)
801037ab:	e8 a0 ca ff ff       	call   80100250 <brelse>
801037b0:	83 c4 10             	add    $0x10,%esp
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037b7:	a1 48 37 11 80       	mov    0x80113748,%eax
801037bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037bf:	0f 8f 5d ff ff ff    	jg     80103722 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801037c5:	90                   	nop
801037c6:	c9                   	leave  
801037c7:	c3                   	ret    

801037c8 <commit>:

static void
commit()
{
801037c8:	55                   	push   %ebp
801037c9:	89 e5                	mov    %esp,%ebp
801037cb:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037ce:	a1 48 37 11 80       	mov    0x80113748,%eax
801037d3:	85 c0                	test   %eax,%eax
801037d5:	7e 1e                	jle    801037f5 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037d7:	e8 34 ff ff ff       	call   80103710 <write_log>
    write_head();    // Write header to disk -- the real commit
801037dc:	e8 3a fd ff ff       	call   8010351b <write_head>
    install_trans(); // Now install writes to home locations
801037e1:	e8 09 fc ff ff       	call   801033ef <install_trans>
    log.lh.n = 0;
801037e6:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
801037ed:	00 00 00 
    write_head();    // Erase the transaction from the log
801037f0:	e8 26 fd ff ff       	call   8010351b <write_head>
  }
}
801037f5:	90                   	nop
801037f6:	c9                   	leave  
801037f7:	c3                   	ret    

801037f8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037f8:	55                   	push   %ebp
801037f9:	89 e5                	mov    %esp,%ebp
801037fb:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037fe:	a1 48 37 11 80       	mov    0x80113748,%eax
80103803:	83 f8 1d             	cmp    $0x1d,%eax
80103806:	7f 12                	jg     8010381a <log_write+0x22>
80103808:	a1 48 37 11 80       	mov    0x80113748,%eax
8010380d:	8b 15 38 37 11 80    	mov    0x80113738,%edx
80103813:	83 ea 01             	sub    $0x1,%edx
80103816:	39 d0                	cmp    %edx,%eax
80103818:	7c 0d                	jl     80103827 <log_write+0x2f>
    panic("too big a transaction");
8010381a:	83 ec 0c             	sub    $0xc,%esp
8010381d:	68 3c 88 10 80       	push   $0x8010883c
80103822:	e8 79 cd ff ff       	call   801005a0 <panic>
  if (log.outstanding < 1)
80103827:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010382c:	85 c0                	test   %eax,%eax
8010382e:	7f 0d                	jg     8010383d <log_write+0x45>
    panic("log_write outside of trans");
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	68 52 88 10 80       	push   $0x80108852
80103838:	e8 63 cd ff ff       	call   801005a0 <panic>

  acquire(&log.lock);
8010383d:	83 ec 0c             	sub    $0xc,%esp
80103840:	68 00 37 11 80       	push   $0x80113700
80103845:	e8 de 17 00 00       	call   80105028 <acquire>
8010384a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010384d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103854:	eb 1d                	jmp    80103873 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103859:	83 c0 10             	add    $0x10,%eax
8010385c:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103863:	89 c2                	mov    %eax,%edx
80103865:	8b 45 08             	mov    0x8(%ebp),%eax
80103868:	8b 40 08             	mov    0x8(%eax),%eax
8010386b:	39 c2                	cmp    %eax,%edx
8010386d:	74 10                	je     8010387f <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010386f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103873:	a1 48 37 11 80       	mov    0x80113748,%eax
80103878:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010387b:	7f d9                	jg     80103856 <log_write+0x5e>
8010387d:	eb 01                	jmp    80103880 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
8010387f:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103880:	8b 45 08             	mov    0x8(%ebp),%eax
80103883:	8b 40 08             	mov    0x8(%eax),%eax
80103886:	89 c2                	mov    %eax,%edx
80103888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010388b:	83 c0 10             	add    $0x10,%eax
8010388e:	89 14 85 0c 37 11 80 	mov    %edx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
80103895:	a1 48 37 11 80       	mov    0x80113748,%eax
8010389a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010389d:	75 0d                	jne    801038ac <log_write+0xb4>
    log.lh.n++;
8010389f:	a1 48 37 11 80       	mov    0x80113748,%eax
801038a4:	83 c0 01             	add    $0x1,%eax
801038a7:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
801038ac:	8b 45 08             	mov    0x8(%ebp),%eax
801038af:	8b 00                	mov    (%eax),%eax
801038b1:	83 c8 04             	or     $0x4,%eax
801038b4:	89 c2                	mov    %eax,%edx
801038b6:	8b 45 08             	mov    0x8(%ebp),%eax
801038b9:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038bb:	83 ec 0c             	sub    $0xc,%esp
801038be:	68 00 37 11 80       	push   $0x80113700
801038c3:	e8 ce 17 00 00       	call   80105096 <release>
801038c8:	83 c4 10             	add    $0x10,%esp
}
801038cb:	90                   	nop
801038cc:	c9                   	leave  
801038cd:	c3                   	ret    

801038ce <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038ce:	55                   	push   %ebp
801038cf:	89 e5                	mov    %esp,%ebp
801038d1:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038d4:	8b 55 08             	mov    0x8(%ebp),%edx
801038d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801038da:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038dd:	f0 87 02             	lock xchg %eax,(%edx)
801038e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038e6:	c9                   	leave  
801038e7:	c3                   	ret    

801038e8 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038e8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038ec:	83 e4 f0             	and    $0xfffffff0,%esp
801038ef:	ff 71 fc             	pushl  -0x4(%ecx)
801038f2:	55                   	push   %ebp
801038f3:	89 e5                	mov    %esp,%ebp
801038f5:	51                   	push   %ecx
801038f6:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038f9:	83 ec 08             	sub    $0x8,%esp
801038fc:	68 00 00 40 80       	push   $0x80400000
80103901:	68 74 6a 11 80       	push   $0x80116a74
80103906:	e8 e1 f2 ff ff       	call   80102bec <kinit1>
8010390b:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010390e:	e8 f1 43 00 00       	call   80107d04 <kvmalloc>
  mpinit();        // detect other processors
80103913:	e8 bf 03 00 00       	call   80103cd7 <mpinit>
  lapicinit();     // interrupt controller
80103918:	e8 3b f6 ff ff       	call   80102f58 <lapicinit>
  seginit();       // segment descriptors
8010391d:	e8 cd 3e 00 00       	call   801077ef <seginit>
  picinit();       // disable pic
80103922:	e8 01 05 00 00       	call   80103e28 <picinit>
  ioapicinit();    // another interrupt controller
80103927:	e8 dc f1 ff ff       	call   80102b08 <ioapicinit>
  consoleinit();   // console hardware
8010392c:	e8 1a d2 ff ff       	call   80100b4b <consoleinit>
  uartinit();      // serial port
80103931:	e8 52 32 00 00       	call   80106b88 <uartinit>
  pinit();         // process table
80103936:	e8 26 09 00 00       	call   80104261 <pinit>
  shminit();       // shared memory
8010393b:	e8 95 4b 00 00       	call   801084d5 <shminit>
  tvinit();        // trap vectors
80103940:	e8 b6 2d 00 00       	call   801066fb <tvinit>
  binit();         // buffer cache
80103945:	e8 ea c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010394a:	e8 11 d7 ff ff       	call   80101060 <fileinit>
  ideinit();       // disk 
8010394f:	e8 8b ed ff ff       	call   801026df <ideinit>
  startothers();   // start other processors
80103954:	e8 80 00 00 00       	call   801039d9 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103959:	83 ec 08             	sub    $0x8,%esp
8010395c:	68 00 00 00 8e       	push   $0x8e000000
80103961:	68 00 00 40 80       	push   $0x80400000
80103966:	e8 ba f2 ff ff       	call   80102c25 <kinit2>
8010396b:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010396e:	e8 d7 0a 00 00       	call   8010444a <userinit>
  mpmain();        // finish this processor's setup
80103973:	e8 1a 00 00 00       	call   80103992 <mpmain>

80103978 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
8010397b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010397e:	e8 99 43 00 00       	call   80107d1c <switchkvm>
  seginit();
80103983:	e8 67 3e 00 00       	call   801077ef <seginit>
  lapicinit();
80103988:	e8 cb f5 ff ff       	call   80102f58 <lapicinit>
  mpmain();
8010398d:	e8 00 00 00 00       	call   80103992 <mpmain>

80103992 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103992:	55                   	push   %ebp
80103993:	89 e5                	mov    %esp,%ebp
80103995:	53                   	push   %ebx
80103996:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103999:	e8 e1 08 00 00       	call   8010427f <cpuid>
8010399e:	89 c3                	mov    %eax,%ebx
801039a0:	e8 da 08 00 00       	call   8010427f <cpuid>
801039a5:	83 ec 04             	sub    $0x4,%esp
801039a8:	53                   	push   %ebx
801039a9:	50                   	push   %eax
801039aa:	68 6d 88 10 80       	push   $0x8010886d
801039af:	e8 4c ca ff ff       	call   80100400 <cprintf>
801039b4:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039b7:	e8 b5 2e 00 00       	call   80106871 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039bc:	e8 df 08 00 00       	call   801042a0 <mycpu>
801039c1:	05 a0 00 00 00       	add    $0xa0,%eax
801039c6:	83 ec 08             	sub    $0x8,%esp
801039c9:	6a 01                	push   $0x1
801039cb:	50                   	push   %eax
801039cc:	e8 fd fe ff ff       	call   801038ce <xchg>
801039d1:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039d4:	e8 37 10 00 00       	call   80104a10 <scheduler>

801039d9 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801039df:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039e6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039eb:	83 ec 04             	sub    $0x4,%esp
801039ee:	50                   	push   %eax
801039ef:	68 ec b4 10 80       	push   $0x8010b4ec
801039f4:	ff 75 f0             	pushl  -0x10(%ebp)
801039f7:	e8 62 19 00 00       	call   8010535e <memmove>
801039fc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039ff:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
80103a06:	eb 79                	jmp    80103a81 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103a08:	e8 93 08 00 00       	call   801042a0 <mycpu>
80103a0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a10:	74 67                	je     80103a79 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a12:	e8 09 f3 ff ff       	call   80102d20 <kalloc>
80103a17:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1d:	83 e8 04             	sub    $0x4,%eax
80103a20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a23:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a29:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2e:	83 e8 08             	sub    $0x8,%eax
80103a31:	c7 00 78 39 10 80    	movl   $0x80103978,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a3a:	83 e8 0c             	sub    $0xc,%eax
80103a3d:	ba 00 a0 10 80       	mov    $0x8010a000,%edx
80103a42:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80103a48:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a4d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a56:	0f b6 00             	movzbl (%eax),%eax
80103a59:	0f b6 c0             	movzbl %al,%eax
80103a5c:	83 ec 08             	sub    $0x8,%esp
80103a5f:	52                   	push   %edx
80103a60:	50                   	push   %eax
80103a61:	e8 53 f6 ff ff       	call   801030b9 <lapicstartap>
80103a66:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a69:	90                   	nop
80103a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a73:	85 c0                	test   %eax,%eax
80103a75:	74 f3                	je     80103a6a <startothers+0x91>
80103a77:	eb 01                	jmp    80103a7a <startothers+0xa1>
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == mycpu())  // We've started already.
      continue;
80103a79:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a7a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a81:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103a86:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a8c:	05 00 38 11 80       	add    $0x80113800,%eax
80103a91:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a94:	0f 87 6e ff ff ff    	ja     80103a08 <startothers+0x2f>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a9a:	90                   	nop
80103a9b:	c9                   	leave  
80103a9c:	c3                   	ret    

80103a9d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a9d:	55                   	push   %ebp
80103a9e:	89 e5                	mov    %esp,%ebp
80103aa0:	83 ec 14             	sub    $0x14,%esp
80103aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aaa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103aae:	89 c2                	mov    %eax,%edx
80103ab0:	ec                   	in     (%dx),%al
80103ab1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ab4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ab8:	c9                   	leave  
80103ab9:	c3                   	ret    

80103aba <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103aba:	55                   	push   %ebp
80103abb:	89 e5                	mov    %esp,%ebp
80103abd:	83 ec 08             	sub    $0x8,%esp
80103ac0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ac6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aca:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103acd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ad5:	ee                   	out    %al,(%dx)
}
80103ad6:	90                   	nop
80103ad7:	c9                   	leave  
80103ad8:	c3                   	ret    

80103ad9 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103ad9:	55                   	push   %ebp
80103ada:	89 e5                	mov    %esp,%ebp
80103adc:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103adf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ae6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103aed:	eb 15                	jmp    80103b04 <sum+0x2b>
    sum += addr[i];
80103aef:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103af2:	8b 45 08             	mov    0x8(%ebp),%eax
80103af5:	01 d0                	add    %edx,%eax
80103af7:	0f b6 00             	movzbl (%eax),%eax
80103afa:	0f b6 c0             	movzbl %al,%eax
80103afd:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b00:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b07:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b0a:	7c e3                	jl     80103aef <sum+0x16>
    sum += addr[i];
  return sum;
80103b0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b0f:	c9                   	leave  
80103b10:	c3                   	ret    

80103b11 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b11:	55                   	push   %ebp
80103b12:	89 e5                	mov    %esp,%ebp
80103b14:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b17:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1a:	05 00 00 00 80       	add    $0x80000000,%eax
80103b1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b22:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b28:	01 d0                	add    %edx,%eax
80103b2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b33:	eb 36                	jmp    80103b6b <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b35:	83 ec 04             	sub    $0x4,%esp
80103b38:	6a 04                	push   $0x4
80103b3a:	68 84 88 10 80       	push   $0x80108884
80103b3f:	ff 75 f4             	pushl  -0xc(%ebp)
80103b42:	e8 bf 17 00 00       	call   80105306 <memcmp>
80103b47:	83 c4 10             	add    $0x10,%esp
80103b4a:	85 c0                	test   %eax,%eax
80103b4c:	75 19                	jne    80103b67 <mpsearch1+0x56>
80103b4e:	83 ec 08             	sub    $0x8,%esp
80103b51:	6a 10                	push   $0x10
80103b53:	ff 75 f4             	pushl  -0xc(%ebp)
80103b56:	e8 7e ff ff ff       	call   80103ad9 <sum>
80103b5b:	83 c4 10             	add    $0x10,%esp
80103b5e:	84 c0                	test   %al,%al
80103b60:	75 05                	jne    80103b67 <mpsearch1+0x56>
      return (struct mp*)p;
80103b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b65:	eb 11                	jmp    80103b78 <mpsearch1+0x67>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b67:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b71:	72 c2                	jb     80103b35 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b78:	c9                   	leave  
80103b79:	c3                   	ret    

80103b7a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b7a:	55                   	push   %ebp
80103b7b:	89 e5                	mov    %esp,%ebp
80103b7d:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b80:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8a:	83 c0 0f             	add    $0xf,%eax
80103b8d:	0f b6 00             	movzbl (%eax),%eax
80103b90:	0f b6 c0             	movzbl %al,%eax
80103b93:	c1 e0 08             	shl    $0x8,%eax
80103b96:	89 c2                	mov    %eax,%edx
80103b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9b:	83 c0 0e             	add    $0xe,%eax
80103b9e:	0f b6 00             	movzbl (%eax),%eax
80103ba1:	0f b6 c0             	movzbl %al,%eax
80103ba4:	09 d0                	or     %edx,%eax
80103ba6:	c1 e0 04             	shl    $0x4,%eax
80103ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb0:	74 21                	je     80103bd3 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bb2:	83 ec 08             	sub    $0x8,%esp
80103bb5:	68 00 04 00 00       	push   $0x400
80103bba:	ff 75 f0             	pushl  -0x10(%ebp)
80103bbd:	e8 4f ff ff ff       	call   80103b11 <mpsearch1>
80103bc2:	83 c4 10             	add    $0x10,%esp
80103bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bc8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bcc:	74 51                	je     80103c1f <mpsearch+0xa5>
      return mp;
80103bce:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd1:	eb 61                	jmp    80103c34 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd6:	83 c0 14             	add    $0x14,%eax
80103bd9:	0f b6 00             	movzbl (%eax),%eax
80103bdc:	0f b6 c0             	movzbl %al,%eax
80103bdf:	c1 e0 08             	shl    $0x8,%eax
80103be2:	89 c2                	mov    %eax,%edx
80103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be7:	83 c0 13             	add    $0x13,%eax
80103bea:	0f b6 00             	movzbl (%eax),%eax
80103bed:	0f b6 c0             	movzbl %al,%eax
80103bf0:	09 d0                	or     %edx,%eax
80103bf2:	c1 e0 0a             	shl    $0xa,%eax
80103bf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfb:	2d 00 04 00 00       	sub    $0x400,%eax
80103c00:	83 ec 08             	sub    $0x8,%esp
80103c03:	68 00 04 00 00       	push   $0x400
80103c08:	50                   	push   %eax
80103c09:	e8 03 ff ff ff       	call   80103b11 <mpsearch1>
80103c0e:	83 c4 10             	add    $0x10,%esp
80103c11:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c14:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c18:	74 05                	je     80103c1f <mpsearch+0xa5>
      return mp;
80103c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c1d:	eb 15                	jmp    80103c34 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c1f:	83 ec 08             	sub    $0x8,%esp
80103c22:	68 00 00 01 00       	push   $0x10000
80103c27:	68 00 00 0f 00       	push   $0xf0000
80103c2c:	e8 e0 fe ff ff       	call   80103b11 <mpsearch1>
80103c31:	83 c4 10             	add    $0x10,%esp
}
80103c34:	c9                   	leave  
80103c35:	c3                   	ret    

80103c36 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c36:	55                   	push   %ebp
80103c37:	89 e5                	mov    %esp,%ebp
80103c39:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c3c:	e8 39 ff ff ff       	call   80103b7a <mpsearch>
80103c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c48:	74 0a                	je     80103c54 <mpconfig+0x1e>
80103c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4d:	8b 40 04             	mov    0x4(%eax),%eax
80103c50:	85 c0                	test   %eax,%eax
80103c52:	75 07                	jne    80103c5b <mpconfig+0x25>
    return 0;
80103c54:	b8 00 00 00 00       	mov    $0x0,%eax
80103c59:	eb 7a                	jmp    80103cd5 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5e:	8b 40 04             	mov    0x4(%eax),%eax
80103c61:	05 00 00 00 80       	add    $0x80000000,%eax
80103c66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c69:	83 ec 04             	sub    $0x4,%esp
80103c6c:	6a 04                	push   $0x4
80103c6e:	68 89 88 10 80       	push   $0x80108889
80103c73:	ff 75 f0             	pushl  -0x10(%ebp)
80103c76:	e8 8b 16 00 00       	call   80105306 <memcmp>
80103c7b:	83 c4 10             	add    $0x10,%esp
80103c7e:	85 c0                	test   %eax,%eax
80103c80:	74 07                	je     80103c89 <mpconfig+0x53>
    return 0;
80103c82:	b8 00 00 00 00       	mov    $0x0,%eax
80103c87:	eb 4c                	jmp    80103cd5 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c90:	3c 01                	cmp    $0x1,%al
80103c92:	74 12                	je     80103ca6 <mpconfig+0x70>
80103c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c97:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c9b:	3c 04                	cmp    $0x4,%al
80103c9d:	74 07                	je     80103ca6 <mpconfig+0x70>
    return 0;
80103c9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103ca4:	eb 2f                	jmp    80103cd5 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cad:	0f b7 c0             	movzwl %ax,%eax
80103cb0:	83 ec 08             	sub    $0x8,%esp
80103cb3:	50                   	push   %eax
80103cb4:	ff 75 f0             	pushl  -0x10(%ebp)
80103cb7:	e8 1d fe ff ff       	call   80103ad9 <sum>
80103cbc:	83 c4 10             	add    $0x10,%esp
80103cbf:	84 c0                	test   %al,%al
80103cc1:	74 07                	je     80103cca <mpconfig+0x94>
    return 0;
80103cc3:	b8 00 00 00 00       	mov    $0x0,%eax
80103cc8:	eb 0b                	jmp    80103cd5 <mpconfig+0x9f>
  *pmp = mp;
80103cca:	8b 45 08             	mov    0x8(%ebp),%eax
80103ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd0:	89 10                	mov    %edx,(%eax)
  return conf;
80103cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103cd5:	c9                   	leave  
80103cd6:	c3                   	ret    

80103cd7 <mpinit>:

void
mpinit(void)
{
80103cd7:	55                   	push   %ebp
80103cd8:	89 e5                	mov    %esp,%ebp
80103cda:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103cdd:	83 ec 0c             	sub    $0xc,%esp
80103ce0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103ce3:	50                   	push   %eax
80103ce4:	e8 4d ff ff ff       	call   80103c36 <mpconfig>
80103ce9:	83 c4 10             	add    $0x10,%esp
80103cec:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cf3:	75 0d                	jne    80103d02 <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103cf5:	83 ec 0c             	sub    $0xc,%esp
80103cf8:	68 8e 88 10 80       	push   $0x8010888e
80103cfd:	e8 9e c8 ff ff       	call   801005a0 <panic>
  ismp = 1;
80103d02:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d0c:	8b 40 24             	mov    0x24(%eax),%eax
80103d0f:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d17:	83 c0 2c             	add    $0x2c,%eax
80103d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d20:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d24:	0f b7 d0             	movzwl %ax,%edx
80103d27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d2a:	01 d0                	add    %edx,%eax
80103d2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d2f:	eb 7b                	jmp    80103dac <mpinit+0xd5>
    switch(*p){
80103d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d34:	0f b6 00             	movzbl (%eax),%eax
80103d37:	0f b6 c0             	movzbl %al,%eax
80103d3a:	83 f8 04             	cmp    $0x4,%eax
80103d3d:	77 65                	ja     80103da4 <mpinit+0xcd>
80103d3f:	8b 04 85 c8 88 10 80 	mov    -0x7fef7738(,%eax,4),%eax
80103d46:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d4e:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103d53:	83 f8 07             	cmp    $0x7,%eax
80103d56:	7f 28                	jg     80103d80 <mpinit+0xa9>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d58:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103d5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d61:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d65:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103d6b:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103d71:	88 02                	mov    %al,(%edx)
        ncpu++;
80103d73:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103d78:	83 c0 01             	add    $0x1,%eax
80103d7b:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103d80:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d84:	eb 26                	jmp    80103dac <mpinit+0xd5>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d89:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d8f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d93:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103d98:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d9c:	eb 0e                	jmp    80103dac <mpinit+0xd5>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d9e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da2:	eb 08                	jmp    80103dac <mpinit+0xd5>
    default:
      ismp = 0;
80103da4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103dab:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103daf:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103db2:	0f 82 79 ff ff ff    	jb     80103d31 <mpinit+0x5a>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103db8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dbc:	75 0d                	jne    80103dcb <mpinit+0xf4>
    panic("Didn't find a suitable machine");
80103dbe:	83 ec 0c             	sub    $0xc,%esp
80103dc1:	68 a8 88 10 80       	push   $0x801088a8
80103dc6:	e8 d5 c7 ff ff       	call   801005a0 <panic>

  if(mp->imcrp){
80103dcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dce:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dd2:	84 c0                	test   %al,%al
80103dd4:	74 30                	je     80103e06 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dd6:	83 ec 08             	sub    $0x8,%esp
80103dd9:	6a 70                	push   $0x70
80103ddb:	6a 22                	push   $0x22
80103ddd:	e8 d8 fc ff ff       	call   80103aba <outb>
80103de2:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103de5:	83 ec 0c             	sub    $0xc,%esp
80103de8:	6a 23                	push   $0x23
80103dea:	e8 ae fc ff ff       	call   80103a9d <inb>
80103def:	83 c4 10             	add    $0x10,%esp
80103df2:	83 c8 01             	or     $0x1,%eax
80103df5:	0f b6 c0             	movzbl %al,%eax
80103df8:	83 ec 08             	sub    $0x8,%esp
80103dfb:	50                   	push   %eax
80103dfc:	6a 23                	push   $0x23
80103dfe:	e8 b7 fc ff ff       	call   80103aba <outb>
80103e03:	83 c4 10             	add    $0x10,%esp
  }
}
80103e06:	90                   	nop
80103e07:	c9                   	leave  
80103e08:	c3                   	ret    

80103e09 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e09:	55                   	push   %ebp
80103e0a:	89 e5                	mov    %esp,%ebp
80103e0c:	83 ec 08             	sub    $0x8,%esp
80103e0f:	8b 55 08             	mov    0x8(%ebp),%edx
80103e12:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e15:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e19:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e1c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e20:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e24:	ee                   	out    %al,(%dx)
}
80103e25:	90                   	nop
80103e26:	c9                   	leave  
80103e27:	c3                   	ret    

80103e28 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e28:	55                   	push   %ebp
80103e29:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e2b:	68 ff 00 00 00       	push   $0xff
80103e30:	6a 21                	push   $0x21
80103e32:	e8 d2 ff ff ff       	call   80103e09 <outb>
80103e37:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103e3a:	68 ff 00 00 00       	push   $0xff
80103e3f:	68 a1 00 00 00       	push   $0xa1
80103e44:	e8 c0 ff ff ff       	call   80103e09 <outb>
80103e49:	83 c4 08             	add    $0x8,%esp
}
80103e4c:	90                   	nop
80103e4d:	c9                   	leave  
80103e4e:	c3                   	ret    

80103e4f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e4f:	55                   	push   %ebp
80103e50:	89 e5                	mov    %esp,%ebp
80103e52:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103e55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e65:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e68:	8b 10                	mov    (%eax),%edx
80103e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e6f:	e8 0a d2 ff ff       	call   8010107e <filealloc>
80103e74:	89 c2                	mov    %eax,%edx
80103e76:	8b 45 08             	mov    0x8(%ebp),%eax
80103e79:	89 10                	mov    %edx,(%eax)
80103e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7e:	8b 00                	mov    (%eax),%eax
80103e80:	85 c0                	test   %eax,%eax
80103e82:	0f 84 cb 00 00 00    	je     80103f53 <pipealloc+0x104>
80103e88:	e8 f1 d1 ff ff       	call   8010107e <filealloc>
80103e8d:	89 c2                	mov    %eax,%edx
80103e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e92:	89 10                	mov    %edx,(%eax)
80103e94:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e97:	8b 00                	mov    (%eax),%eax
80103e99:	85 c0                	test   %eax,%eax
80103e9b:	0f 84 b2 00 00 00    	je     80103f53 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ea1:	e8 7a ee ff ff       	call   80102d20 <kalloc>
80103ea6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ea9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ead:	0f 84 9f 00 00 00    	je     80103f52 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb6:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ebd:	00 00 00 
  p->writeopen = 1;
80103ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec3:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103eca:	00 00 00 
  p->nwrite = 0;
80103ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed0:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ed7:	00 00 00 
  p->nread = 0;
80103eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103edd:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ee4:	00 00 00 
  initlock(&p->lock, "pipe");
80103ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eea:	83 ec 08             	sub    $0x8,%esp
80103eed:	68 dc 88 10 80       	push   $0x801088dc
80103ef2:	50                   	push   %eax
80103ef3:	e8 0e 11 00 00       	call   80105006 <initlock>
80103ef8:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103efb:	8b 45 08             	mov    0x8(%ebp),%eax
80103efe:	8b 00                	mov    (%eax),%eax
80103f00:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f06:	8b 45 08             	mov    0x8(%ebp),%eax
80103f09:	8b 00                	mov    (%eax),%eax
80103f0b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f12:	8b 00                	mov    (%eax),%eax
80103f14:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f18:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1b:	8b 00                	mov    (%eax),%eax
80103f1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f20:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f23:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f26:	8b 00                	mov    (%eax),%eax
80103f28:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f31:	8b 00                	mov    (%eax),%eax
80103f33:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3a:	8b 00                	mov    (%eax),%eax
80103f3c:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f43:	8b 00                	mov    (%eax),%eax
80103f45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f48:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f4b:	b8 00 00 00 00       	mov    $0x0,%eax
80103f50:	eb 4e                	jmp    80103fa0 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103f52:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103f53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f57:	74 0e                	je     80103f67 <pipealloc+0x118>
    kfree((char*)p);
80103f59:	83 ec 0c             	sub    $0xc,%esp
80103f5c:	ff 75 f4             	pushl  -0xc(%ebp)
80103f5f:	e8 22 ed ff ff       	call   80102c86 <kfree>
80103f64:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103f67:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6a:	8b 00                	mov    (%eax),%eax
80103f6c:	85 c0                	test   %eax,%eax
80103f6e:	74 11                	je     80103f81 <pipealloc+0x132>
    fileclose(*f0);
80103f70:	8b 45 08             	mov    0x8(%ebp),%eax
80103f73:	8b 00                	mov    (%eax),%eax
80103f75:	83 ec 0c             	sub    $0xc,%esp
80103f78:	50                   	push   %eax
80103f79:	e8 be d1 ff ff       	call   8010113c <fileclose>
80103f7e:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f81:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f84:	8b 00                	mov    (%eax),%eax
80103f86:	85 c0                	test   %eax,%eax
80103f88:	74 11                	je     80103f9b <pipealloc+0x14c>
    fileclose(*f1);
80103f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8d:	8b 00                	mov    (%eax),%eax
80103f8f:	83 ec 0c             	sub    $0xc,%esp
80103f92:	50                   	push   %eax
80103f93:	e8 a4 d1 ff ff       	call   8010113c <fileclose>
80103f98:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fa0:	c9                   	leave  
80103fa1:	c3                   	ret    

80103fa2 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fa2:	55                   	push   %ebp
80103fa3:	89 e5                	mov    %esp,%ebp
80103fa5:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fab:	83 ec 0c             	sub    $0xc,%esp
80103fae:	50                   	push   %eax
80103faf:	e8 74 10 00 00       	call   80105028 <acquire>
80103fb4:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103fb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fbb:	74 23                	je     80103fe0 <pipeclose+0x3e>
    p->writeopen = 0;
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fc7:	00 00 00 
    wakeup(&p->nread);
80103fca:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcd:	05 34 02 00 00       	add    $0x234,%eax
80103fd2:	83 ec 0c             	sub    $0xc,%esp
80103fd5:	50                   	push   %eax
80103fd6:	e8 14 0d 00 00       	call   80104cef <wakeup>
80103fdb:	83 c4 10             	add    $0x10,%esp
80103fde:	eb 21                	jmp    80104001 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe3:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103fea:	00 00 00 
    wakeup(&p->nwrite);
80103fed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff0:	05 38 02 00 00       	add    $0x238,%eax
80103ff5:	83 ec 0c             	sub    $0xc,%esp
80103ff8:	50                   	push   %eax
80103ff9:	e8 f1 0c 00 00       	call   80104cef <wakeup>
80103ffe:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104001:	8b 45 08             	mov    0x8(%ebp),%eax
80104004:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010400a:	85 c0                	test   %eax,%eax
8010400c:	75 2c                	jne    8010403a <pipeclose+0x98>
8010400e:	8b 45 08             	mov    0x8(%ebp),%eax
80104011:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104017:	85 c0                	test   %eax,%eax
80104019:	75 1f                	jne    8010403a <pipeclose+0x98>
    release(&p->lock);
8010401b:	8b 45 08             	mov    0x8(%ebp),%eax
8010401e:	83 ec 0c             	sub    $0xc,%esp
80104021:	50                   	push   %eax
80104022:	e8 6f 10 00 00       	call   80105096 <release>
80104027:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010402a:	83 ec 0c             	sub    $0xc,%esp
8010402d:	ff 75 08             	pushl  0x8(%ebp)
80104030:	e8 51 ec ff ff       	call   80102c86 <kfree>
80104035:	83 c4 10             	add    $0x10,%esp
80104038:	eb 0f                	jmp    80104049 <pipeclose+0xa7>
  } else
    release(&p->lock);
8010403a:	8b 45 08             	mov    0x8(%ebp),%eax
8010403d:	83 ec 0c             	sub    $0xc,%esp
80104040:	50                   	push   %eax
80104041:	e8 50 10 00 00       	call   80105096 <release>
80104046:	83 c4 10             	add    $0x10,%esp
}
80104049:	90                   	nop
8010404a:	c9                   	leave  
8010404b:	c3                   	ret    

8010404c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010404c:	55                   	push   %ebp
8010404d:	89 e5                	mov    %esp,%ebp
8010404f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	83 ec 0c             	sub    $0xc,%esp
80104058:	50                   	push   %eax
80104059:	e8 ca 0f 00 00       	call   80105028 <acquire>
8010405e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104061:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104068:	e9 ac 00 00 00       	jmp    80104119 <pipewrite+0xcd>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104076:	85 c0                	test   %eax,%eax
80104078:	74 0c                	je     80104086 <pipewrite+0x3a>
8010407a:	e8 99 02 00 00       	call   80104318 <myproc>
8010407f:	8b 40 24             	mov    0x24(%eax),%eax
80104082:	85 c0                	test   %eax,%eax
80104084:	74 19                	je     8010409f <pipewrite+0x53>
        release(&p->lock);
80104086:	8b 45 08             	mov    0x8(%ebp),%eax
80104089:	83 ec 0c             	sub    $0xc,%esp
8010408c:	50                   	push   %eax
8010408d:	e8 04 10 00 00       	call   80105096 <release>
80104092:	83 c4 10             	add    $0x10,%esp
        return -1;
80104095:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010409a:	e9 a8 00 00 00       	jmp    80104147 <pipewrite+0xfb>
      }
      wakeup(&p->nread);
8010409f:	8b 45 08             	mov    0x8(%ebp),%eax
801040a2:	05 34 02 00 00       	add    $0x234,%eax
801040a7:	83 ec 0c             	sub    $0xc,%esp
801040aa:	50                   	push   %eax
801040ab:	e8 3f 0c 00 00       	call   80104cef <wakeup>
801040b0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801040b3:	8b 45 08             	mov    0x8(%ebp),%eax
801040b6:	8b 55 08             	mov    0x8(%ebp),%edx
801040b9:	81 c2 38 02 00 00    	add    $0x238,%edx
801040bf:	83 ec 08             	sub    $0x8,%esp
801040c2:	50                   	push   %eax
801040c3:	52                   	push   %edx
801040c4:	e8 3d 0b 00 00       	call   80104c06 <sleep>
801040c9:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040cc:	8b 45 08             	mov    0x8(%ebp),%eax
801040cf:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040de:	05 00 02 00 00       	add    $0x200,%eax
801040e3:	39 c2                	cmp    %eax,%edx
801040e5:	74 86                	je     8010406d <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040f0:	8d 48 01             	lea    0x1(%eax),%ecx
801040f3:	8b 55 08             	mov    0x8(%ebp),%edx
801040f6:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801040fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80104101:	89 c1                	mov    %eax,%ecx
80104103:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104106:	8b 45 0c             	mov    0xc(%ebp),%eax
80104109:	01 d0                	add    %edx,%eax
8010410b:	0f b6 10             	movzbl (%eax),%edx
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104115:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010411f:	7c ab                	jl     801040cc <pipewrite+0x80>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	05 34 02 00 00       	add    $0x234,%eax
80104129:	83 ec 0c             	sub    $0xc,%esp
8010412c:	50                   	push   %eax
8010412d:	e8 bd 0b 00 00       	call   80104cef <wakeup>
80104132:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104135:	8b 45 08             	mov    0x8(%ebp),%eax
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	50                   	push   %eax
8010413c:	e8 55 0f 00 00       	call   80105096 <release>
80104141:	83 c4 10             	add    $0x10,%esp
  return n;
80104144:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104147:	c9                   	leave  
80104148:	c3                   	ret    

80104149 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104149:	55                   	push   %ebp
8010414a:	89 e5                	mov    %esp,%ebp
8010414c:	53                   	push   %ebx
8010414d:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	83 ec 0c             	sub    $0xc,%esp
80104156:	50                   	push   %eax
80104157:	e8 cc 0e 00 00       	call   80105028 <acquire>
8010415c:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010415f:	eb 3e                	jmp    8010419f <piperead+0x56>
    if(myproc()->killed){
80104161:	e8 b2 01 00 00       	call   80104318 <myproc>
80104166:	8b 40 24             	mov    0x24(%eax),%eax
80104169:	85 c0                	test   %eax,%eax
8010416b:	74 19                	je     80104186 <piperead+0x3d>
      release(&p->lock);
8010416d:	8b 45 08             	mov    0x8(%ebp),%eax
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	50                   	push   %eax
80104174:	e8 1d 0f 00 00       	call   80105096 <release>
80104179:	83 c4 10             	add    $0x10,%esp
      return -1;
8010417c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104181:	e9 bf 00 00 00       	jmp    80104245 <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104186:	8b 45 08             	mov    0x8(%ebp),%eax
80104189:	8b 55 08             	mov    0x8(%ebp),%edx
8010418c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104192:	83 ec 08             	sub    $0x8,%esp
80104195:	50                   	push   %eax
80104196:	52                   	push   %edx
80104197:	e8 6a 0a 00 00       	call   80104c06 <sleep>
8010419c:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010419f:	8b 45 08             	mov    0x8(%ebp),%eax
801041a2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041a8:	8b 45 08             	mov    0x8(%ebp),%eax
801041ab:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041b1:	39 c2                	cmp    %eax,%edx
801041b3:	75 0d                	jne    801041c2 <piperead+0x79>
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041be:	85 c0                	test   %eax,%eax
801041c0:	75 9f                	jne    80104161 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041c9:	eb 49                	jmp    80104214 <piperead+0xcb>
    if(p->nread == p->nwrite)
801041cb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ce:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041d4:	8b 45 08             	mov    0x8(%ebp),%eax
801041d7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041dd:	39 c2                	cmp    %eax,%edx
801041df:	74 3d                	je     8010421e <piperead+0xd5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e7:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041ea:	8b 45 08             	mov    0x8(%ebp),%eax
801041ed:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041f3:	8d 48 01             	lea    0x1(%eax),%ecx
801041f6:	8b 55 08             	mov    0x8(%ebp),%edx
801041f9:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041ff:	25 ff 01 00 00       	and    $0x1ff,%eax
80104204:	89 c2                	mov    %eax,%edx
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010420e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104210:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104217:	3b 45 10             	cmp    0x10(%ebp),%eax
8010421a:	7c af                	jl     801041cb <piperead+0x82>
8010421c:	eb 01                	jmp    8010421f <piperead+0xd6>
    if(p->nread == p->nwrite)
      break;
8010421e:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010421f:	8b 45 08             	mov    0x8(%ebp),%eax
80104222:	05 38 02 00 00       	add    $0x238,%eax
80104227:	83 ec 0c             	sub    $0xc,%esp
8010422a:	50                   	push   %eax
8010422b:	e8 bf 0a 00 00       	call   80104cef <wakeup>
80104230:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104233:	8b 45 08             	mov    0x8(%ebp),%eax
80104236:	83 ec 0c             	sub    $0xc,%esp
80104239:	50                   	push   %eax
8010423a:	e8 57 0e 00 00       	call   80105096 <release>
8010423f:	83 c4 10             	add    $0x10,%esp
  return i;
80104242:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104245:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104248:	c9                   	leave  
80104249:	c3                   	ret    

8010424a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010424a:	55                   	push   %ebp
8010424b:	89 e5                	mov    %esp,%ebp
8010424d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104250:	9c                   	pushf  
80104251:	58                   	pop    %eax
80104252:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104255:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104258:	c9                   	leave  
80104259:	c3                   	ret    

8010425a <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010425a:	55                   	push   %ebp
8010425b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010425d:	fb                   	sti    
}
8010425e:	90                   	nop
8010425f:	5d                   	pop    %ebp
80104260:	c3                   	ret    

80104261 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104261:	55                   	push   %ebp
80104262:	89 e5                	mov    %esp,%ebp
80104264:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104267:	83 ec 08             	sub    $0x8,%esp
8010426a:	68 e4 88 10 80       	push   $0x801088e4
8010426f:	68 a0 3d 11 80       	push   $0x80113da0
80104274:	e8 8d 0d 00 00       	call   80105006 <initlock>
80104279:	83 c4 10             	add    $0x10,%esp
}
8010427c:	90                   	nop
8010427d:	c9                   	leave  
8010427e:	c3                   	ret    

8010427f <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010427f:	55                   	push   %ebp
80104280:	89 e5                	mov    %esp,%ebp
80104282:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104285:	e8 16 00 00 00       	call   801042a0 <mycpu>
8010428a:	89 c2                	mov    %eax,%edx
8010428c:	b8 00 38 11 80       	mov    $0x80113800,%eax
80104291:	29 c2                	sub    %eax,%edx
80104293:	89 d0                	mov    %edx,%eax
80104295:	c1 f8 04             	sar    $0x4,%eax
80104298:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010429e:	c9                   	leave  
8010429f:	c3                   	ret    

801042a0 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801042a0:	55                   	push   %ebp
801042a1:	89 e5                	mov    %esp,%ebp
801042a3:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801042a6:	e8 9f ff ff ff       	call   8010424a <readeflags>
801042ab:	25 00 02 00 00       	and    $0x200,%eax
801042b0:	85 c0                	test   %eax,%eax
801042b2:	74 0d                	je     801042c1 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801042b4:	83 ec 0c             	sub    $0xc,%esp
801042b7:	68 ec 88 10 80       	push   $0x801088ec
801042bc:	e8 df c2 ff ff       	call   801005a0 <panic>
  
  apicid = lapicid();
801042c1:	e8 b0 ed ff ff       	call   80103076 <lapicid>
801042c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042d0:	eb 2d                	jmp    801042ff <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
801042d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042db:	05 00 38 11 80       	add    $0x80113800,%eax
801042e0:	0f b6 00             	movzbl (%eax),%eax
801042e3:	0f b6 c0             	movzbl %al,%eax
801042e6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801042e9:	75 10                	jne    801042fb <mycpu+0x5b>
      return &cpus[i];
801042eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ee:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042f4:	05 00 38 11 80       	add    $0x80113800,%eax
801042f9:	eb 1b                	jmp    80104316 <mycpu+0x76>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042ff:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80104304:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104307:	7c c9                	jl     801042d2 <mycpu+0x32>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104309:	83 ec 0c             	sub    $0xc,%esp
8010430c:	68 12 89 10 80       	push   $0x80108912
80104311:	e8 8a c2 ff ff       	call   801005a0 <panic>
}
80104316:	c9                   	leave  
80104317:	c3                   	ret    

80104318 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104318:	55                   	push   %ebp
80104319:	89 e5                	mov    %esp,%ebp
8010431b:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010431e:	e8 70 0e 00 00       	call   80105193 <pushcli>
  c = mycpu();
80104323:	e8 78 ff ff ff       	call   801042a0 <mycpu>
80104328:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010432b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104334:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104337:	e8 a5 0e 00 00       	call   801051e1 <popcli>
  return p;
8010433c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010433f:	c9                   	leave  
80104340:	c3                   	ret    

80104341 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
80104344:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104347:	83 ec 0c             	sub    $0xc,%esp
8010434a:	68 a0 3d 11 80       	push   $0x80113da0
8010434f:	e8 d4 0c 00 00       	call   80105028 <acquire>
80104354:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104357:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010435e:	eb 11                	jmp    80104371 <allocproc+0x30>
    if(p->state == UNUSED)
80104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104363:	8b 40 0c             	mov    0xc(%eax),%eax
80104366:	85 c0                	test   %eax,%eax
80104368:	74 2a                	je     80104394 <allocproc+0x53>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010436a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104371:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104378:	72 e6                	jb     80104360 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010437a:	83 ec 0c             	sub    $0xc,%esp
8010437d:	68 a0 3d 11 80       	push   $0x80113da0
80104382:	e8 0f 0d 00 00       	call   80105096 <release>
80104387:	83 c4 10             	add    $0x10,%esp
  return 0;
8010438a:	b8 00 00 00 00       	mov    $0x0,%eax
8010438f:	e9 b4 00 00 00       	jmp    80104448 <allocproc+0x107>

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104394:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104398:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010439f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801043a4:	8d 50 01             	lea    0x1(%eax),%edx
801043a7:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
801043ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b0:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801043b3:	83 ec 0c             	sub    $0xc,%esp
801043b6:	68 a0 3d 11 80       	push   $0x80113da0
801043bb:	e8 d6 0c 00 00       	call   80105096 <release>
801043c0:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043c3:	e8 58 e9 ff ff       	call   80102d20 <kalloc>
801043c8:	89 c2                	mov    %eax,%edx
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	89 50 08             	mov    %edx,0x8(%eax)
801043d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d3:	8b 40 08             	mov    0x8(%eax),%eax
801043d6:	85 c0                	test   %eax,%eax
801043d8:	75 11                	jne    801043eb <allocproc+0xaa>
    p->state = UNUSED;
801043da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043dd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043e4:	b8 00 00 00 00       	mov    $0x0,%eax
801043e9:	eb 5d                	jmp    80104448 <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
801043eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ee:	8b 40 08             	mov    0x8(%eax),%eax
801043f1:	05 00 10 00 00       	add    $0x1000,%eax
801043f6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043f9:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104400:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104403:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104406:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010440a:	ba b5 66 10 80       	mov    $0x801066b5,%edx
8010440f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104412:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104414:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010441e:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	8b 40 1c             	mov    0x1c(%eax),%eax
80104427:	83 ec 04             	sub    $0x4,%esp
8010442a:	6a 14                	push   $0x14
8010442c:	6a 00                	push   $0x0
8010442e:	50                   	push   %eax
8010442f:	e8 6b 0e 00 00       	call   8010529f <memset>
80104434:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010443d:	ba c0 4b 10 80       	mov    $0x80104bc0,%edx
80104442:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104445:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104448:	c9                   	leave  
80104449:	c3                   	ret    

8010444a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010444a:	55                   	push   %ebp
8010444b:	89 e5                	mov    %esp,%ebp
8010444d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104450:	e8 ec fe ff ff       	call   80104341 <allocproc>
80104455:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445b:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
80104460:	e8 06 38 00 00       	call   80107c6b <setupkvm>
80104465:	89 c2                	mov    %eax,%edx
80104467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446a:	89 50 04             	mov    %edx,0x4(%eax)
8010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104470:	8b 40 04             	mov    0x4(%eax),%eax
80104473:	85 c0                	test   %eax,%eax
80104475:	75 0d                	jne    80104484 <userinit+0x3a>
    panic("userinit: out of memory?");
80104477:	83 ec 0c             	sub    $0xc,%esp
8010447a:	68 22 89 10 80       	push   $0x80108922
8010447f:	e8 1c c1 ff ff       	call   801005a0 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104484:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448c:	8b 40 04             	mov    0x4(%eax),%eax
8010448f:	83 ec 04             	sub    $0x4,%esp
80104492:	52                   	push   %edx
80104493:	68 c0 b4 10 80       	push   $0x8010b4c0
80104498:	50                   	push   %eax
80104499:	e8 35 3a 00 00       	call   80107ed3 <inituvm>
8010449e:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	8b 40 18             	mov    0x18(%eax),%eax
801044b0:	83 ec 04             	sub    $0x4,%esp
801044b3:	6a 4c                	push   $0x4c
801044b5:	6a 00                	push   $0x0
801044b7:	50                   	push   %eax
801044b8:	e8 e2 0d 00 00       	call   8010529f <memset>
801044bd:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c3:	8b 40 18             	mov    0x18(%eax),%eax
801044c6:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cf:	8b 40 18             	mov    0x18(%eax),%eax
801044d2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044db:	8b 40 18             	mov    0x18(%eax),%eax
801044de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e1:	8b 52 18             	mov    0x18(%edx),%edx
801044e4:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044e8:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ef:	8b 40 18             	mov    0x18(%eax),%eax
801044f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f5:	8b 52 18             	mov    0x18(%edx),%edx
801044f8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044fc:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	8b 40 18             	mov    0x18(%eax),%eax
80104506:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 40 18             	mov    0x18(%eax),%eax
80104513:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451d:	8b 40 18             	mov    0x18(%eax),%eax
80104520:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452a:	83 c0 6c             	add    $0x6c,%eax
8010452d:	83 ec 04             	sub    $0x4,%esp
80104530:	6a 10                	push   $0x10
80104532:	68 3b 89 10 80       	push   $0x8010893b
80104537:	50                   	push   %eax
80104538:	e8 65 0f 00 00       	call   801054a2 <safestrcpy>
8010453d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104540:	83 ec 0c             	sub    $0xc,%esp
80104543:	68 44 89 10 80       	push   $0x80108944
80104548:	e8 8e e0 ff ff       	call   801025db <namei>
8010454d:	83 c4 10             	add    $0x10,%esp
80104550:	89 c2                	mov    %eax,%edx
80104552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104555:	89 50 68             	mov    %edx,0x68(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104558:	83 ec 0c             	sub    $0xc,%esp
8010455b:	68 a0 3d 11 80       	push   $0x80113da0
80104560:	e8 c3 0a 00 00       	call   80105028 <acquire>
80104565:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104572:	83 ec 0c             	sub    $0xc,%esp
80104575:	68 a0 3d 11 80       	push   $0x80113da0
8010457a:	e8 17 0b 00 00       	call   80105096 <release>
8010457f:	83 c4 10             	add    $0x10,%esp
}
80104582:	90                   	nop
80104583:	c9                   	leave  
80104584:	c3                   	ret    

80104585 <growproc>:
// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
// Changed for cs 153
int
growproc(int n)
{
80104585:	55                   	push   %ebp
80104586:	89 e5                	mov    %esp,%ebp
80104588:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010458b:	e8 88 fd ff ff       	call   80104318 <myproc>
80104590:	89 45 f0             	mov    %eax,-0x10(%ebp)
 


  sz = curproc->sz;
80104593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104596:	8b 00                	mov    (%eax),%eax
80104598:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  sz = curproc->last_page;
  if(n > 0){
8010459b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010459f:	7e 2e                	jle    801045cf <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045a1:	8b 55 08             	mov    0x8(%ebp),%edx
801045a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a7:	01 c2                	add    %eax,%edx
801045a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ac:	8b 40 04             	mov    0x4(%eax),%eax
801045af:	83 ec 04             	sub    $0x4,%esp
801045b2:	52                   	push   %edx
801045b3:	ff 75 f4             	pushl  -0xc(%ebp)
801045b6:	50                   	push   %eax
801045b7:	e8 54 3a 00 00       	call   80108010 <allocuvm>
801045bc:	83 c4 10             	add    $0x10,%esp
801045bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045c6:	75 3b                	jne    80104603 <growproc+0x7e>
      return -1;
801045c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045cd:	eb 4f                	jmp    8010461e <growproc+0x99>
  } else if(n < 0){
801045cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045d3:	79 2e                	jns    80104603 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045d5:	8b 55 08             	mov    0x8(%ebp),%edx
801045d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045db:	01 c2                	add    %eax,%edx
801045dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045e0:	8b 40 04             	mov    0x4(%eax),%eax
801045e3:	83 ec 04             	sub    $0x4,%esp
801045e6:	52                   	push   %edx
801045e7:	ff 75 f4             	pushl  -0xc(%ebp)
801045ea:	50                   	push   %eax
801045eb:	e8 4b 3b 00 00       	call   8010813b <deallocuvm>
801045f0:	83 c4 10             	add    $0x10,%esp
801045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045fa:	75 07                	jne    80104603 <growproc+0x7e>
      return -1;
801045fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104601:	eb 1b                	jmp    8010461e <growproc+0x99>
  }
  curproc->sz = sz;
80104603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104606:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104609:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010460b:	83 ec 0c             	sub    $0xc,%esp
8010460e:	ff 75 f0             	pushl  -0x10(%ebp)
80104611:	e8 1f 37 00 00       	call   80107d35 <switchuvm>
80104616:	83 c4 10             	add    $0x10,%esp
  return 0;
80104619:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010461e:	c9                   	leave  
8010461f:	c3                   	ret    

80104620 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104620:	55                   	push   %ebp
80104621:	89 e5                	mov    %esp,%ebp
80104623:	57                   	push   %edi
80104624:	56                   	push   %esi
80104625:	53                   	push   %ebx
80104626:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104629:	e8 ea fc ff ff       	call   80104318 <myproc>
8010462e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104631:	e8 0b fd ff ff       	call   80104341 <allocproc>
80104636:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010463d:	75 0a                	jne    80104649 <fork+0x29>
    return -1;
8010463f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104644:	e9 79 01 00 00       	jmp    801047c2 <fork+0x1a2>
  }


 cprintf("SP2: %x\n", curproc->tf->esp);
80104649:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010464c:	8b 40 18             	mov    0x18(%eax),%eax
8010464f:	8b 40 44             	mov    0x44(%eax),%eax
80104652:	83 ec 08             	sub    $0x8,%esp
80104655:	50                   	push   %eax
80104656:	68 46 89 10 80       	push   $0x80108946
8010465b:	e8 a0 bd ff ff       	call   80100400 <cprintf>
80104660:	83 c4 10             	add    $0x10,%esp


  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, curproc->last_page)) == 0){
80104663:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104666:	8b 48 7c             	mov    0x7c(%eax),%ecx
80104669:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010466c:	8b 10                	mov    (%eax),%edx
8010466e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104671:	8b 40 04             	mov    0x4(%eax),%eax
80104674:	83 ec 04             	sub    $0x4,%esp
80104677:	51                   	push   %ecx
80104678:	52                   	push   %edx
80104679:	50                   	push   %eax
8010467a:	e8 5a 3c 00 00       	call   801082d9 <copyuvm>
8010467f:	83 c4 10             	add    $0x10,%esp
80104682:	89 c2                	mov    %eax,%edx
80104684:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104687:	89 50 04             	mov    %edx,0x4(%eax)
8010468a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010468d:	8b 40 04             	mov    0x4(%eax),%eax
80104690:	85 c0                	test   %eax,%eax
80104692:	75 30                	jne    801046c4 <fork+0xa4>
    kfree(np->kstack);
80104694:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104697:	8b 40 08             	mov    0x8(%eax),%eax
8010469a:	83 ec 0c             	sub    $0xc,%esp
8010469d:	50                   	push   %eax
8010469e:	e8 e3 e5 ff ff       	call   80102c86 <kfree>
801046a3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801046a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046bf:	e9 fe 00 00 00       	jmp    801047c2 <fork+0x1a2>
  }
  np->sz = curproc->sz;
801046c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c7:	8b 10                	mov    (%eax),%edx
801046c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046cc:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801046ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046d4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046da:	8b 50 18             	mov    0x18(%eax),%edx
801046dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e0:	8b 40 18             	mov    0x18(%eax),%eax
801046e3:	89 c3                	mov    %eax,%ebx
801046e5:	b8 13 00 00 00       	mov    $0x13,%eax
801046ea:	89 d7                	mov    %edx,%edi
801046ec:	89 de                	mov    %ebx,%esi
801046ee:	89 c1                	mov    %eax,%ecx
801046f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->last_page = curproc->last_page;
801046f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f5:	8b 50 7c             	mov    0x7c(%eax),%edx
801046f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046fb:	89 50 7c             	mov    %edx,0x7c(%eax)
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104701:	8b 40 18             	mov    0x18(%eax),%eax
80104704:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010470b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104712:	eb 3d                	jmp    80104751 <fork+0x131>
    if(curproc->ofile[i])
80104714:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471a:	83 c2 08             	add    $0x8,%edx
8010471d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104721:	85 c0                	test   %eax,%eax
80104723:	74 28                	je     8010474d <fork+0x12d>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104725:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010472b:	83 c2 08             	add    $0x8,%edx
8010472e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104732:	83 ec 0c             	sub    $0xc,%esp
80104735:	50                   	push   %eax
80104736:	e8 b0 c9 ff ff       	call   801010eb <filedup>
8010473b:	83 c4 10             	add    $0x10,%esp
8010473e:	89 c1                	mov    %eax,%ecx
80104740:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104743:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104746:	83 c2 08             	add    $0x8,%edx
80104749:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *curproc->tf;
  np->last_page = curproc->last_page;
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010474d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104751:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104755:	7e bd                	jle    80104714 <fork+0xf4>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104757:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475a:	8b 40 68             	mov    0x68(%eax),%eax
8010475d:	83 ec 0c             	sub    $0xc,%esp
80104760:	50                   	push   %eax
80104761:	e8 fb d2 ff ff       	call   80101a61 <idup>
80104766:	83 c4 10             	add    $0x10,%esp
80104769:	89 c2                	mov    %eax,%edx
8010476b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010476e:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104771:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104774:	8d 50 6c             	lea    0x6c(%eax),%edx
80104777:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010477a:	83 c0 6c             	add    $0x6c,%eax
8010477d:	83 ec 04             	sub    $0x4,%esp
80104780:	6a 10                	push   $0x10
80104782:	52                   	push   %edx
80104783:	50                   	push   %eax
80104784:	e8 19 0d 00 00       	call   801054a2 <safestrcpy>
80104789:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010478c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010478f:	8b 40 10             	mov    0x10(%eax),%eax
80104792:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104795:	83 ec 0c             	sub    $0xc,%esp
80104798:	68 a0 3d 11 80       	push   $0x80113da0
8010479d:	e8 86 08 00 00       	call   80105028 <acquire>
801047a2:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801047a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047af:	83 ec 0c             	sub    $0xc,%esp
801047b2:	68 a0 3d 11 80       	push   $0x80113da0
801047b7:	e8 da 08 00 00       	call   80105096 <release>
801047bc:	83 c4 10             	add    $0x10,%esp

  return pid;
801047bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801047c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047c5:	5b                   	pop    %ebx
801047c6:	5e                   	pop    %esi
801047c7:	5f                   	pop    %edi
801047c8:	5d                   	pop    %ebp
801047c9:	c3                   	ret    

801047ca <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047ca:	55                   	push   %ebp
801047cb:	89 e5                	mov    %esp,%ebp
801047cd:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801047d0:	e8 43 fb ff ff       	call   80104318 <myproc>
801047d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801047d8:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801047dd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047e0:	75 0d                	jne    801047ef <exit+0x25>
    panic("init exiting");
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	68 4f 89 10 80       	push   $0x8010894f
801047ea:	e8 b1 bd ff ff       	call   801005a0 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047f6:	eb 3f                	jmp    80104837 <exit+0x6d>
    if(curproc->ofile[fd]){
801047f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047fe:	83 c2 08             	add    $0x8,%edx
80104801:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104805:	85 c0                	test   %eax,%eax
80104807:	74 2a                	je     80104833 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80104809:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010480c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010480f:	83 c2 08             	add    $0x8,%edx
80104812:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104816:	83 ec 0c             	sub    $0xc,%esp
80104819:	50                   	push   %eax
8010481a:	e8 1d c9 ff ff       	call   8010113c <fileclose>
8010481f:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104822:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104825:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104828:	83 c2 08             	add    $0x8,%edx
8010482b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104832:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104833:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104837:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010483b:	7e bb                	jle    801047f8 <exit+0x2e>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010483d:	e8 7e ed ff ff       	call   801035c0 <begin_op>
  iput(curproc->cwd);
80104842:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104845:	8b 40 68             	mov    0x68(%eax),%eax
80104848:	83 ec 0c             	sub    $0xc,%esp
8010484b:	50                   	push   %eax
8010484c:	e8 ab d3 ff ff       	call   80101bfc <iput>
80104851:	83 c4 10             	add    $0x10,%esp
  end_op();
80104854:	e8 f3 ed ff ff       	call   8010364c <end_op>
  curproc->cwd = 0;
80104859:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010485c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104863:	83 ec 0c             	sub    $0xc,%esp
80104866:	68 a0 3d 11 80       	push   $0x80113da0
8010486b:	e8 b8 07 00 00       	call   80105028 <acquire>
80104870:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104873:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104876:	8b 40 14             	mov    0x14(%eax),%eax
80104879:	83 ec 0c             	sub    $0xc,%esp
8010487c:	50                   	push   %eax
8010487d:	e8 2b 04 00 00       	call   80104cad <wakeup1>
80104882:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104885:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010488c:	eb 3a                	jmp    801048c8 <exit+0xfe>
    if(p->parent == curproc){
8010488e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104891:	8b 40 14             	mov    0x14(%eax),%eax
80104894:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104897:	75 28                	jne    801048c1 <exit+0xf7>
      p->parent = initproc;
80104899:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
8010489f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a8:	8b 40 0c             	mov    0xc(%eax),%eax
801048ab:	83 f8 05             	cmp    $0x5,%eax
801048ae:	75 11                	jne    801048c1 <exit+0xf7>
        wakeup1(initproc);
801048b0:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801048b5:	83 ec 0c             	sub    $0xc,%esp
801048b8:	50                   	push   %eax
801048b9:	e8 ef 03 00 00       	call   80104cad <wakeup1>
801048be:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048c1:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048c8:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801048cf:	72 bd                	jb     8010488e <exit+0xc4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801048d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048d4:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048db:	e8 eb 01 00 00       	call   80104acb <sched>
  panic("zombie exit");
801048e0:	83 ec 0c             	sub    $0xc,%esp
801048e3:	68 5c 89 10 80       	push   $0x8010895c
801048e8:	e8 b3 bc ff ff       	call   801005a0 <panic>

801048ed <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048ed:	55                   	push   %ebp
801048ee:	89 e5                	mov    %esp,%ebp
801048f0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048f3:	e8 20 fa ff ff       	call   80104318 <myproc>
801048f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801048fb:	83 ec 0c             	sub    $0xc,%esp
801048fe:	68 a0 3d 11 80       	push   $0x80113da0
80104903:	e8 20 07 00 00       	call   80105028 <acquire>
80104908:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010490b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104912:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104919:	e9 a4 00 00 00       	jmp    801049c2 <wait+0xd5>
      if(p->parent != curproc)
8010491e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104921:	8b 40 14             	mov    0x14(%eax),%eax
80104924:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104927:	0f 85 8d 00 00 00    	jne    801049ba <wait+0xcd>
        continue;
      havekids = 1;
8010492d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104937:	8b 40 0c             	mov    0xc(%eax),%eax
8010493a:	83 f8 05             	cmp    $0x5,%eax
8010493d:	75 7c                	jne    801049bb <wait+0xce>
        // Found one.
        pid = p->pid;
8010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104942:	8b 40 10             	mov    0x10(%eax),%eax
80104945:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494b:	8b 40 08             	mov    0x8(%eax),%eax
8010494e:	83 ec 0c             	sub    $0xc,%esp
80104951:	50                   	push   %eax
80104952:	e8 2f e3 ff ff       	call   80102c86 <kfree>
80104957:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104967:	8b 40 04             	mov    0x4(%eax),%eax
8010496a:	83 ec 0c             	sub    $0xc,%esp
8010496d:	50                   	push   %eax
8010496e:	e8 8c 38 00 00       	call   801081ff <freevm>
80104973:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104979:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104983:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010498a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104994:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010499b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	68 a0 3d 11 80       	push   $0x80113da0
801049ad:	e8 e4 06 00 00       	call   80105096 <release>
801049b2:	83 c4 10             	add    $0x10,%esp
        return pid;
801049b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049b8:	eb 54                	jmp    80104a0e <wait+0x121>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
801049ba:	90                   	nop
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049bb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049c2:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
801049c9:	0f 82 4f ff ff ff    	jb     8010491e <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049d3:	74 0a                	je     801049df <wait+0xf2>
801049d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049d8:	8b 40 24             	mov    0x24(%eax),%eax
801049db:	85 c0                	test   %eax,%eax
801049dd:	74 17                	je     801049f6 <wait+0x109>
      release(&ptable.lock);
801049df:	83 ec 0c             	sub    $0xc,%esp
801049e2:	68 a0 3d 11 80       	push   $0x80113da0
801049e7:	e8 aa 06 00 00       	call   80105096 <release>
801049ec:	83 c4 10             	add    $0x10,%esp
      return -1;
801049ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049f4:	eb 18                	jmp    80104a0e <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801049f6:	83 ec 08             	sub    $0x8,%esp
801049f9:	68 a0 3d 11 80       	push   $0x80113da0
801049fe:	ff 75 ec             	pushl  -0x14(%ebp)
80104a01:	e8 00 02 00 00       	call   80104c06 <sleep>
80104a06:	83 c4 10             	add    $0x10,%esp
  }
80104a09:	e9 fd fe ff ff       	jmp    8010490b <wait+0x1e>
}
80104a0e:	c9                   	leave  
80104a0f:	c3                   	ret    

80104a10 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a16:	e8 85 f8 ff ff       	call   801042a0 <mycpu>
80104a1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a21:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a28:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a2b:	e8 2a f8 ff ff       	call   8010425a <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	68 a0 3d 11 80       	push   $0x80113da0
80104a38:	e8 eb 05 00 00       	call   80105028 <acquire>
80104a3d:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a40:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104a47:	eb 64                	jmp    80104aad <scheduler+0x9d>
      if(p->state != RUNNABLE)
80104a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a4f:	83 f8 03             	cmp    $0x3,%eax
80104a52:	75 51                	jne    80104aa5 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a5a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a60:	83 ec 0c             	sub    $0xc,%esp
80104a63:	ff 75 f4             	pushl  -0xc(%ebp)
80104a66:	e8 ca 32 00 00       	call   80107d35 <switchuvm>
80104a6b:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a7e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a81:	83 c2 04             	add    $0x4,%edx
80104a84:	83 ec 08             	sub    $0x8,%esp
80104a87:	50                   	push   %eax
80104a88:	52                   	push   %edx
80104a89:	e8 85 0a 00 00       	call   80105513 <swtch>
80104a8e:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104a91:	e8 86 32 00 00       	call   80107d1c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a99:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104aa0:	00 00 00 
80104aa3:	eb 01                	jmp    80104aa6 <scheduler+0x96>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104aa5:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa6:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104aad:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104ab4:	72 93                	jb     80104a49 <scheduler+0x39>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104ab6:	83 ec 0c             	sub    $0xc,%esp
80104ab9:	68 a0 3d 11 80       	push   $0x80113da0
80104abe:	e8 d3 05 00 00       	call   80105096 <release>
80104ac3:	83 c4 10             	add    $0x10,%esp

  }
80104ac6:	e9 60 ff ff ff       	jmp    80104a2b <scheduler+0x1b>

80104acb <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104acb:	55                   	push   %ebp
80104acc:	89 e5                	mov    %esp,%ebp
80104ace:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104ad1:	e8 42 f8 ff ff       	call   80104318 <myproc>
80104ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104ad9:	83 ec 0c             	sub    $0xc,%esp
80104adc:	68 a0 3d 11 80       	push   $0x80113da0
80104ae1:	e8 7c 06 00 00       	call   80105162 <holding>
80104ae6:	83 c4 10             	add    $0x10,%esp
80104ae9:	85 c0                	test   %eax,%eax
80104aeb:	75 0d                	jne    80104afa <sched+0x2f>
    panic("sched ptable.lock");
80104aed:	83 ec 0c             	sub    $0xc,%esp
80104af0:	68 68 89 10 80       	push   $0x80108968
80104af5:	e8 a6 ba ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli != 1)
80104afa:	e8 a1 f7 ff ff       	call   801042a0 <mycpu>
80104aff:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b05:	83 f8 01             	cmp    $0x1,%eax
80104b08:	74 0d                	je     80104b17 <sched+0x4c>
    panic("sched locks");
80104b0a:	83 ec 0c             	sub    $0xc,%esp
80104b0d:	68 7a 89 10 80       	push   $0x8010897a
80104b12:	e8 89 ba ff ff       	call   801005a0 <panic>
  if(p->state == RUNNING)
80104b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1a:	8b 40 0c             	mov    0xc(%eax),%eax
80104b1d:	83 f8 04             	cmp    $0x4,%eax
80104b20:	75 0d                	jne    80104b2f <sched+0x64>
    panic("sched running");
80104b22:	83 ec 0c             	sub    $0xc,%esp
80104b25:	68 86 89 10 80       	push   $0x80108986
80104b2a:	e8 71 ba ff ff       	call   801005a0 <panic>
  if(readeflags()&FL_IF)
80104b2f:	e8 16 f7 ff ff       	call   8010424a <readeflags>
80104b34:	25 00 02 00 00       	and    $0x200,%eax
80104b39:	85 c0                	test   %eax,%eax
80104b3b:	74 0d                	je     80104b4a <sched+0x7f>
    panic("sched interruptible");
80104b3d:	83 ec 0c             	sub    $0xc,%esp
80104b40:	68 94 89 10 80       	push   $0x80108994
80104b45:	e8 56 ba ff ff       	call   801005a0 <panic>
  intena = mycpu()->intena;
80104b4a:	e8 51 f7 ff ff       	call   801042a0 <mycpu>
80104b4f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b58:	e8 43 f7 ff ff       	call   801042a0 <mycpu>
80104b5d:	8b 40 04             	mov    0x4(%eax),%eax
80104b60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b63:	83 c2 1c             	add    $0x1c,%edx
80104b66:	83 ec 08             	sub    $0x8,%esp
80104b69:	50                   	push   %eax
80104b6a:	52                   	push   %edx
80104b6b:	e8 a3 09 00 00       	call   80105513 <swtch>
80104b70:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b73:	e8 28 f7 ff ff       	call   801042a0 <mycpu>
80104b78:	89 c2                	mov    %eax,%edx
80104b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b7d:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
}
80104b83:	90                   	nop
80104b84:	c9                   	leave  
80104b85:	c3                   	ret    

80104b86 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b86:	55                   	push   %ebp
80104b87:	89 e5                	mov    %esp,%ebp
80104b89:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b8c:	83 ec 0c             	sub    $0xc,%esp
80104b8f:	68 a0 3d 11 80       	push   $0x80113da0
80104b94:	e8 8f 04 00 00       	call   80105028 <acquire>
80104b99:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104b9c:	e8 77 f7 ff ff       	call   80104318 <myproc>
80104ba1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ba8:	e8 1e ff ff ff       	call   80104acb <sched>
  release(&ptable.lock);
80104bad:	83 ec 0c             	sub    $0xc,%esp
80104bb0:	68 a0 3d 11 80       	push   $0x80113da0
80104bb5:	e8 dc 04 00 00       	call   80105096 <release>
80104bba:	83 c4 10             	add    $0x10,%esp
}
80104bbd:	90                   	nop
80104bbe:	c9                   	leave  
80104bbf:	c3                   	ret    

80104bc0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
80104bc3:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bc6:	83 ec 0c             	sub    $0xc,%esp
80104bc9:	68 a0 3d 11 80       	push   $0x80113da0
80104bce:	e8 c3 04 00 00       	call   80105096 <release>
80104bd3:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bd6:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104bdb:	85 c0                	test   %eax,%eax
80104bdd:	74 24                	je     80104c03 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bdf:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104be6:	00 00 00 
    iinit(ROOTDEV);
80104be9:	83 ec 0c             	sub    $0xc,%esp
80104bec:	6a 01                	push   $0x1
80104bee:	e8 36 cb ff ff       	call   80101729 <iinit>
80104bf3:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104bf6:	83 ec 0c             	sub    $0xc,%esp
80104bf9:	6a 01                	push   $0x1
80104bfb:	e8 a2 e7 ff ff       	call   801033a2 <initlog>
80104c00:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c03:	90                   	nop
80104c04:	c9                   	leave  
80104c05:	c3                   	ret    

80104c06 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c06:	55                   	push   %ebp
80104c07:	89 e5                	mov    %esp,%ebp
80104c09:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c0c:	e8 07 f7 ff ff       	call   80104318 <myproc>
80104c11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c18:	75 0d                	jne    80104c27 <sleep+0x21>
    panic("sleep");
80104c1a:	83 ec 0c             	sub    $0xc,%esp
80104c1d:	68 a8 89 10 80       	push   $0x801089a8
80104c22:	e8 79 b9 ff ff       	call   801005a0 <panic>

  if(lk == 0)
80104c27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c2b:	75 0d                	jne    80104c3a <sleep+0x34>
    panic("sleep without lk");
80104c2d:	83 ec 0c             	sub    $0xc,%esp
80104c30:	68 ae 89 10 80       	push   $0x801089ae
80104c35:	e8 66 b9 ff ff       	call   801005a0 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c3a:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104c41:	74 1e                	je     80104c61 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	68 a0 3d 11 80       	push   $0x80113da0
80104c4b:	e8 d8 03 00 00       	call   80105028 <acquire>
80104c50:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c53:	83 ec 0c             	sub    $0xc,%esp
80104c56:	ff 75 0c             	pushl  0xc(%ebp)
80104c59:	e8 38 04 00 00       	call   80105096 <release>
80104c5e:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c64:	8b 55 08             	mov    0x8(%ebp),%edx
80104c67:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c74:	e8 52 fe ff ff       	call   80104acb <sched>

  // Tidy up.
  p->chan = 0;
80104c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c83:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104c8a:	74 1e                	je     80104caa <sleep+0xa4>
    release(&ptable.lock);
80104c8c:	83 ec 0c             	sub    $0xc,%esp
80104c8f:	68 a0 3d 11 80       	push   $0x80113da0
80104c94:	e8 fd 03 00 00       	call   80105096 <release>
80104c99:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104c9c:	83 ec 0c             	sub    $0xc,%esp
80104c9f:	ff 75 0c             	pushl  0xc(%ebp)
80104ca2:	e8 81 03 00 00       	call   80105028 <acquire>
80104ca7:	83 c4 10             	add    $0x10,%esp
  }
}
80104caa:	90                   	nop
80104cab:	c9                   	leave  
80104cac:	c3                   	ret    

80104cad <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
80104cb0:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cb3:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104cba:	eb 27                	jmp    80104ce3 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104cbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cbf:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc2:	83 f8 02             	cmp    $0x2,%eax
80104cc5:	75 15                	jne    80104cdc <wakeup1+0x2f>
80104cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cca:	8b 40 20             	mov    0x20(%eax),%eax
80104ccd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cd0:	75 0a                	jne    80104cdc <wakeup1+0x2f>
      p->state = RUNNABLE;
80104cd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cd5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cdc:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104ce3:	81 7d fc d4 5e 11 80 	cmpl   $0x80115ed4,-0x4(%ebp)
80104cea:	72 d0                	jb     80104cbc <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104cec:	90                   	nop
80104ced:	c9                   	leave  
80104cee:	c3                   	ret    

80104cef <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cef:	55                   	push   %ebp
80104cf0:	89 e5                	mov    %esp,%ebp
80104cf2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104cf5:	83 ec 0c             	sub    $0xc,%esp
80104cf8:	68 a0 3d 11 80       	push   $0x80113da0
80104cfd:	e8 26 03 00 00       	call   80105028 <acquire>
80104d02:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d05:	83 ec 0c             	sub    $0xc,%esp
80104d08:	ff 75 08             	pushl  0x8(%ebp)
80104d0b:	e8 9d ff ff ff       	call   80104cad <wakeup1>
80104d10:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d13:	83 ec 0c             	sub    $0xc,%esp
80104d16:	68 a0 3d 11 80       	push   $0x80113da0
80104d1b:	e8 76 03 00 00       	call   80105096 <release>
80104d20:	83 c4 10             	add    $0x10,%esp
}
80104d23:	90                   	nop
80104d24:	c9                   	leave  
80104d25:	c3                   	ret    

80104d26 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d26:	55                   	push   %ebp
80104d27:	89 e5                	mov    %esp,%ebp
80104d29:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d2c:	83 ec 0c             	sub    $0xc,%esp
80104d2f:	68 a0 3d 11 80       	push   $0x80113da0
80104d34:	e8 ef 02 00 00       	call   80105028 <acquire>
80104d39:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d3c:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104d43:	eb 48                	jmp    80104d8d <kill+0x67>
    if(p->pid == pid){
80104d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d48:	8b 40 10             	mov    0x10(%eax),%eax
80104d4b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d4e:	75 36                	jne    80104d86 <kill+0x60>
      p->killed = 1;
80104d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d53:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5d:	8b 40 0c             	mov    0xc(%eax),%eax
80104d60:	83 f8 02             	cmp    $0x2,%eax
80104d63:	75 0a                	jne    80104d6f <kill+0x49>
        p->state = RUNNABLE;
80104d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d68:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d6f:	83 ec 0c             	sub    $0xc,%esp
80104d72:	68 a0 3d 11 80       	push   $0x80113da0
80104d77:	e8 1a 03 00 00       	call   80105096 <release>
80104d7c:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d7f:	b8 00 00 00 00       	mov    $0x0,%eax
80104d84:	eb 25                	jmp    80104dab <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d86:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d8d:	81 7d f4 d4 5e 11 80 	cmpl   $0x80115ed4,-0xc(%ebp)
80104d94:	72 af                	jb     80104d45 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d96:	83 ec 0c             	sub    $0xc,%esp
80104d99:	68 a0 3d 11 80       	push   $0x80113da0
80104d9e:	e8 f3 02 00 00       	call   80105096 <release>
80104da3:	83 c4 10             	add    $0x10,%esp
  return -1;
80104da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dab:	c9                   	leave  
80104dac:	c3                   	ret    

80104dad <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dad:	55                   	push   %ebp
80104dae:	89 e5                	mov    %esp,%ebp
80104db0:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db3:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104dba:	e9 da 00 00 00       	jmp    80104e99 <procdump+0xec>
    if(p->state == UNUSED)
80104dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc2:	8b 40 0c             	mov    0xc(%eax),%eax
80104dc5:	85 c0                	test   %eax,%eax
80104dc7:	0f 84 c4 00 00 00    	je     80104e91 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd0:	8b 40 0c             	mov    0xc(%eax),%eax
80104dd3:	83 f8 05             	cmp    $0x5,%eax
80104dd6:	77 23                	ja     80104dfb <procdump+0x4e>
80104dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ddb:	8b 40 0c             	mov    0xc(%eax),%eax
80104dde:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104de5:	85 c0                	test   %eax,%eax
80104de7:	74 12                	je     80104dfb <procdump+0x4e>
      state = states[p->state];
80104de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dec:	8b 40 0c             	mov    0xc(%eax),%eax
80104def:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104df6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104df9:	eb 07                	jmp    80104e02 <procdump+0x55>
    else
      state = "???";
80104dfb:	c7 45 ec bf 89 10 80 	movl   $0x801089bf,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e05:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e0b:	8b 40 10             	mov    0x10(%eax),%eax
80104e0e:	52                   	push   %edx
80104e0f:	ff 75 ec             	pushl  -0x14(%ebp)
80104e12:	50                   	push   %eax
80104e13:	68 c3 89 10 80       	push   $0x801089c3
80104e18:	e8 e3 b5 ff ff       	call   80100400 <cprintf>
80104e1d:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e23:	8b 40 0c             	mov    0xc(%eax),%eax
80104e26:	83 f8 02             	cmp    $0x2,%eax
80104e29:	75 54                	jne    80104e7f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e31:	8b 40 0c             	mov    0xc(%eax),%eax
80104e34:	83 c0 08             	add    $0x8,%eax
80104e37:	89 c2                	mov    %eax,%edx
80104e39:	83 ec 08             	sub    $0x8,%esp
80104e3c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e3f:	50                   	push   %eax
80104e40:	52                   	push   %edx
80104e41:	e8 a2 02 00 00       	call   801050e8 <getcallerpcs>
80104e46:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e50:	eb 1c                	jmp    80104e6e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e55:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e59:	83 ec 08             	sub    $0x8,%esp
80104e5c:	50                   	push   %eax
80104e5d:	68 cc 89 10 80       	push   $0x801089cc
80104e62:	e8 99 b5 ff ff       	call   80100400 <cprintf>
80104e67:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e6e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e72:	7f 0b                	jg     80104e7f <procdump+0xd2>
80104e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e77:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e7b:	85 c0                	test   %eax,%eax
80104e7d:	75 d3                	jne    80104e52 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e7f:	83 ec 0c             	sub    $0xc,%esp
80104e82:	68 d0 89 10 80       	push   $0x801089d0
80104e87:	e8 74 b5 ff ff       	call   80100400 <cprintf>
80104e8c:	83 c4 10             	add    $0x10,%esp
80104e8f:	eb 01                	jmp    80104e92 <procdump+0xe5>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104e91:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e92:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e99:	81 7d f0 d4 5e 11 80 	cmpl   $0x80115ed4,-0x10(%ebp)
80104ea0:	0f 82 19 ff ff ff    	jb     80104dbf <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ea6:	90                   	nop
80104ea7:	c9                   	leave  
80104ea8:	c3                   	ret    

80104ea9 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104ea9:	55                   	push   %ebp
80104eaa:	89 e5                	mov    %esp,%ebp
80104eac:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb2:	83 c0 04             	add    $0x4,%eax
80104eb5:	83 ec 08             	sub    $0x8,%esp
80104eb8:	68 fc 89 10 80       	push   $0x801089fc
80104ebd:	50                   	push   %eax
80104ebe:	e8 43 01 00 00       	call   80105006 <initlock>
80104ec3:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ecc:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80104edb:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ee2:	90                   	nop
80104ee3:	c9                   	leave  
80104ee4:	c3                   	ret    

80104ee5 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ee5:	55                   	push   %ebp
80104ee6:	89 e5                	mov    %esp,%ebp
80104ee8:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80104eee:	83 c0 04             	add    $0x4,%eax
80104ef1:	83 ec 0c             	sub    $0xc,%esp
80104ef4:	50                   	push   %eax
80104ef5:	e8 2e 01 00 00       	call   80105028 <acquire>
80104efa:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104efd:	eb 15                	jmp    80104f14 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104eff:	8b 45 08             	mov    0x8(%ebp),%eax
80104f02:	83 c0 04             	add    $0x4,%eax
80104f05:	83 ec 08             	sub    $0x8,%esp
80104f08:	50                   	push   %eax
80104f09:	ff 75 08             	pushl  0x8(%ebp)
80104f0c:	e8 f5 fc ff ff       	call   80104c06 <sleep>
80104f11:	83 c4 10             	add    $0x10,%esp

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104f14:	8b 45 08             	mov    0x8(%ebp),%eax
80104f17:	8b 00                	mov    (%eax),%eax
80104f19:	85 c0                	test   %eax,%eax
80104f1b:	75 e2                	jne    80104eff <acquiresleep+0x1a>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f20:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f26:	e8 ed f3 ff ff       	call   80104318 <myproc>
80104f2b:	8b 50 10             	mov    0x10(%eax),%edx
80104f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f31:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f34:	8b 45 08             	mov    0x8(%ebp),%eax
80104f37:	83 c0 04             	add    $0x4,%eax
80104f3a:	83 ec 0c             	sub    $0xc,%esp
80104f3d:	50                   	push   %eax
80104f3e:	e8 53 01 00 00       	call   80105096 <release>
80104f43:	83 c4 10             	add    $0x10,%esp
}
80104f46:	90                   	nop
80104f47:	c9                   	leave  
80104f48:	c3                   	ret    

80104f49 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f49:	55                   	push   %ebp
80104f4a:	89 e5                	mov    %esp,%ebp
80104f4c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	83 c0 04             	add    $0x4,%eax
80104f55:	83 ec 0c             	sub    $0xc,%esp
80104f58:	50                   	push   %eax
80104f59:	e8 ca 00 00 00       	call   80105028 <acquire>
80104f5e:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f61:	8b 45 08             	mov    0x8(%ebp),%eax
80104f64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f74:	83 ec 0c             	sub    $0xc,%esp
80104f77:	ff 75 08             	pushl  0x8(%ebp)
80104f7a:	e8 70 fd ff ff       	call   80104cef <wakeup>
80104f7f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f82:	8b 45 08             	mov    0x8(%ebp),%eax
80104f85:	83 c0 04             	add    $0x4,%eax
80104f88:	83 ec 0c             	sub    $0xc,%esp
80104f8b:	50                   	push   %eax
80104f8c:	e8 05 01 00 00       	call   80105096 <release>
80104f91:	83 c4 10             	add    $0x10,%esp
}
80104f94:	90                   	nop
80104f95:	c9                   	leave  
80104f96:	c3                   	ret    

80104f97 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104f97:	55                   	push   %ebp
80104f98:	89 e5                	mov    %esp,%ebp
80104f9a:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa0:	83 c0 04             	add    $0x4,%eax
80104fa3:	83 ec 0c             	sub    $0xc,%esp
80104fa6:	50                   	push   %eax
80104fa7:	e8 7c 00 00 00       	call   80105028 <acquire>
80104fac:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104faf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb2:	8b 00                	mov    (%eax),%eax
80104fb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fba:	83 c0 04             	add    $0x4,%eax
80104fbd:	83 ec 0c             	sub    $0xc,%esp
80104fc0:	50                   	push   %eax
80104fc1:	e8 d0 00 00 00       	call   80105096 <release>
80104fc6:	83 c4 10             	add    $0x10,%esp
  return r;
80104fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fcc:	c9                   	leave  
80104fcd:	c3                   	ret    

80104fce <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fce:	55                   	push   %ebp
80104fcf:	89 e5                	mov    %esp,%ebp
80104fd1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fd4:	9c                   	pushf  
80104fd5:	58                   	pop    %eax
80104fd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fdc:	c9                   	leave  
80104fdd:	c3                   	ret    

80104fde <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fde:	55                   	push   %ebp
80104fdf:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fe1:	fa                   	cli    
}
80104fe2:	90                   	nop
80104fe3:	5d                   	pop    %ebp
80104fe4:	c3                   	ret    

80104fe5 <sti>:

static inline void
sti(void)
{
80104fe5:	55                   	push   %ebp
80104fe6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fe8:	fb                   	sti    
}
80104fe9:	90                   	nop
80104fea:	5d                   	pop    %ebp
80104feb:	c3                   	ret    

80104fec <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fec:	55                   	push   %ebp
80104fed:	89 e5                	mov    %esp,%ebp
80104fef:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ff2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ffb:	f0 87 02             	lock xchg %eax,(%edx)
80104ffe:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105001:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105004:	c9                   	leave  
80105005:	c3                   	ret    

80105006 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105006:	55                   	push   %ebp
80105007:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105009:	8b 45 08             	mov    0x8(%ebp),%eax
8010500c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010500f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105012:	8b 45 08             	mov    0x8(%ebp),%eax
80105015:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010501b:	8b 45 08             	mov    0x8(%ebp),%eax
8010501e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105025:	90                   	nop
80105026:	5d                   	pop    %ebp
80105027:	c3                   	ret    

80105028 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	53                   	push   %ebx
8010502c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010502f:	e8 5f 01 00 00       	call   80105193 <pushcli>
  if(holding(lk))
80105034:	8b 45 08             	mov    0x8(%ebp),%eax
80105037:	83 ec 0c             	sub    $0xc,%esp
8010503a:	50                   	push   %eax
8010503b:	e8 22 01 00 00       	call   80105162 <holding>
80105040:	83 c4 10             	add    $0x10,%esp
80105043:	85 c0                	test   %eax,%eax
80105045:	74 0d                	je     80105054 <acquire+0x2c>
    panic("acquire");
80105047:	83 ec 0c             	sub    $0xc,%esp
8010504a:	68 07 8a 10 80       	push   $0x80108a07
8010504f:	e8 4c b5 ff ff       	call   801005a0 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105054:	90                   	nop
80105055:	8b 45 08             	mov    0x8(%ebp),%eax
80105058:	83 ec 08             	sub    $0x8,%esp
8010505b:	6a 01                	push   $0x1
8010505d:	50                   	push   %eax
8010505e:	e8 89 ff ff ff       	call   80104fec <xchg>
80105063:	83 c4 10             	add    $0x10,%esp
80105066:	85 c0                	test   %eax,%eax
80105068:	75 eb                	jne    80105055 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010506a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010506f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105072:	e8 29 f2 ff ff       	call   801042a0 <mycpu>
80105077:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010507a:	8b 45 08             	mov    0x8(%ebp),%eax
8010507d:	83 c0 0c             	add    $0xc,%eax
80105080:	83 ec 08             	sub    $0x8,%esp
80105083:	50                   	push   %eax
80105084:	8d 45 08             	lea    0x8(%ebp),%eax
80105087:	50                   	push   %eax
80105088:	e8 5b 00 00 00       	call   801050e8 <getcallerpcs>
8010508d:	83 c4 10             	add    $0x10,%esp
}
80105090:	90                   	nop
80105091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105094:	c9                   	leave  
80105095:	c3                   	ret    

80105096 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105096:	55                   	push   %ebp
80105097:	89 e5                	mov    %esp,%ebp
80105099:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010509c:	83 ec 0c             	sub    $0xc,%esp
8010509f:	ff 75 08             	pushl  0x8(%ebp)
801050a2:	e8 bb 00 00 00       	call   80105162 <holding>
801050a7:	83 c4 10             	add    $0x10,%esp
801050aa:	85 c0                	test   %eax,%eax
801050ac:	75 0d                	jne    801050bb <release+0x25>
    panic("release");
801050ae:	83 ec 0c             	sub    $0xc,%esp
801050b1:	68 0f 8a 10 80       	push   $0x80108a0f
801050b6:	e8 e5 b4 ff ff       	call   801005a0 <panic>

  lk->pcs[0] = 0;
801050bb:	8b 45 08             	mov    0x8(%ebp),%eax
801050be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050c5:	8b 45 08             	mov    0x8(%ebp),%eax
801050c8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801050cf:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801050d4:	8b 45 08             	mov    0x8(%ebp),%eax
801050d7:	8b 55 08             	mov    0x8(%ebp),%edx
801050da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801050e0:	e8 fc 00 00 00       	call   801051e1 <popcli>
}
801050e5:	90                   	nop
801050e6:	c9                   	leave  
801050e7:	c3                   	ret    

801050e8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050e8:	55                   	push   %ebp
801050e9:	89 e5                	mov    %esp,%ebp
801050eb:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801050ee:	8b 45 08             	mov    0x8(%ebp),%eax
801050f1:	83 e8 08             	sub    $0x8,%eax
801050f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050f7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050fe:	eb 38                	jmp    80105138 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105100:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105104:	74 53                	je     80105159 <getcallerpcs+0x71>
80105106:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010510d:	76 4a                	jbe    80105159 <getcallerpcs+0x71>
8010510f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105113:	74 44                	je     80105159 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105115:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105118:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010511f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105122:	01 c2                	add    %eax,%edx
80105124:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105127:	8b 40 04             	mov    0x4(%eax),%eax
8010512a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010512c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010512f:	8b 00                	mov    (%eax),%eax
80105131:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105134:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105138:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010513c:	7e c2                	jle    80105100 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010513e:	eb 19                	jmp    80105159 <getcallerpcs+0x71>
    pcs[i] = 0;
80105140:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105143:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010514a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514d:	01 d0                	add    %edx,%eax
8010514f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105155:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105159:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010515d:	7e e1                	jle    80105140 <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010515f:	90                   	nop
80105160:	c9                   	leave  
80105161:	c3                   	ret    

80105162 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105162:	55                   	push   %ebp
80105163:	89 e5                	mov    %esp,%ebp
80105165:	53                   	push   %ebx
80105166:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	8b 00                	mov    (%eax),%eax
8010516e:	85 c0                	test   %eax,%eax
80105170:	74 16                	je     80105188 <holding+0x26>
80105172:	8b 45 08             	mov    0x8(%ebp),%eax
80105175:	8b 58 08             	mov    0x8(%eax),%ebx
80105178:	e8 23 f1 ff ff       	call   801042a0 <mycpu>
8010517d:	39 c3                	cmp    %eax,%ebx
8010517f:	75 07                	jne    80105188 <holding+0x26>
80105181:	b8 01 00 00 00       	mov    $0x1,%eax
80105186:	eb 05                	jmp    8010518d <holding+0x2b>
80105188:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010518d:	83 c4 04             	add    $0x4,%esp
80105190:	5b                   	pop    %ebx
80105191:	5d                   	pop    %ebp
80105192:	c3                   	ret    

80105193 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105193:	55                   	push   %ebp
80105194:	89 e5                	mov    %esp,%ebp
80105196:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105199:	e8 30 fe ff ff       	call   80104fce <readeflags>
8010519e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801051a1:	e8 38 fe ff ff       	call   80104fde <cli>
  if(mycpu()->ncli == 0)
801051a6:	e8 f5 f0 ff ff       	call   801042a0 <mycpu>
801051ab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051b1:	85 c0                	test   %eax,%eax
801051b3:	75 15                	jne    801051ca <pushcli+0x37>
    mycpu()->intena = eflags & FL_IF;
801051b5:	e8 e6 f0 ff ff       	call   801042a0 <mycpu>
801051ba:	89 c2                	mov    %eax,%edx
801051bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bf:	25 00 02 00 00       	and    $0x200,%eax
801051c4:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
  mycpu()->ncli += 1;
801051ca:	e8 d1 f0 ff ff       	call   801042a0 <mycpu>
801051cf:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801051d5:	83 c2 01             	add    $0x1,%edx
801051d8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801051de:	90                   	nop
801051df:	c9                   	leave  
801051e0:	c3                   	ret    

801051e1 <popcli>:

void
popcli(void)
{
801051e1:	55                   	push   %ebp
801051e2:	89 e5                	mov    %esp,%ebp
801051e4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801051e7:	e8 e2 fd ff ff       	call   80104fce <readeflags>
801051ec:	25 00 02 00 00       	and    $0x200,%eax
801051f1:	85 c0                	test   %eax,%eax
801051f3:	74 0d                	je     80105202 <popcli+0x21>
    panic("popcli - interruptible");
801051f5:	83 ec 0c             	sub    $0xc,%esp
801051f8:	68 17 8a 10 80       	push   $0x80108a17
801051fd:	e8 9e b3 ff ff       	call   801005a0 <panic>
  if(--mycpu()->ncli < 0)
80105202:	e8 99 f0 ff ff       	call   801042a0 <mycpu>
80105207:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010520d:	83 ea 01             	sub    $0x1,%edx
80105210:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105216:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010521c:	85 c0                	test   %eax,%eax
8010521e:	79 0d                	jns    8010522d <popcli+0x4c>
    panic("popcli");
80105220:	83 ec 0c             	sub    $0xc,%esp
80105223:	68 2e 8a 10 80       	push   $0x80108a2e
80105228:	e8 73 b3 ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010522d:	e8 6e f0 ff ff       	call   801042a0 <mycpu>
80105232:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105238:	85 c0                	test   %eax,%eax
8010523a:	75 14                	jne    80105250 <popcli+0x6f>
8010523c:	e8 5f f0 ff ff       	call   801042a0 <mycpu>
80105241:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105247:	85 c0                	test   %eax,%eax
80105249:	74 05                	je     80105250 <popcli+0x6f>
    sti();
8010524b:	e8 95 fd ff ff       	call   80104fe5 <sti>
}
80105250:	90                   	nop
80105251:	c9                   	leave  
80105252:	c3                   	ret    

80105253 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105253:	55                   	push   %ebp
80105254:	89 e5                	mov    %esp,%ebp
80105256:	57                   	push   %edi
80105257:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105258:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010525b:	8b 55 10             	mov    0x10(%ebp),%edx
8010525e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105261:	89 cb                	mov    %ecx,%ebx
80105263:	89 df                	mov    %ebx,%edi
80105265:	89 d1                	mov    %edx,%ecx
80105267:	fc                   	cld    
80105268:	f3 aa                	rep stos %al,%es:(%edi)
8010526a:	89 ca                	mov    %ecx,%edx
8010526c:	89 fb                	mov    %edi,%ebx
8010526e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105271:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105274:	90                   	nop
80105275:	5b                   	pop    %ebx
80105276:	5f                   	pop    %edi
80105277:	5d                   	pop    %ebp
80105278:	c3                   	ret    

80105279 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105279:	55                   	push   %ebp
8010527a:	89 e5                	mov    %esp,%ebp
8010527c:	57                   	push   %edi
8010527d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010527e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105281:	8b 55 10             	mov    0x10(%ebp),%edx
80105284:	8b 45 0c             	mov    0xc(%ebp),%eax
80105287:	89 cb                	mov    %ecx,%ebx
80105289:	89 df                	mov    %ebx,%edi
8010528b:	89 d1                	mov    %edx,%ecx
8010528d:	fc                   	cld    
8010528e:	f3 ab                	rep stos %eax,%es:(%edi)
80105290:	89 ca                	mov    %ecx,%edx
80105292:	89 fb                	mov    %edi,%ebx
80105294:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105297:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010529a:	90                   	nop
8010529b:	5b                   	pop    %ebx
8010529c:	5f                   	pop    %edi
8010529d:	5d                   	pop    %ebp
8010529e:	c3                   	ret    

8010529f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010529f:	55                   	push   %ebp
801052a0:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052a2:	8b 45 08             	mov    0x8(%ebp),%eax
801052a5:	83 e0 03             	and    $0x3,%eax
801052a8:	85 c0                	test   %eax,%eax
801052aa:	75 43                	jne    801052ef <memset+0x50>
801052ac:	8b 45 10             	mov    0x10(%ebp),%eax
801052af:	83 e0 03             	and    $0x3,%eax
801052b2:	85 c0                	test   %eax,%eax
801052b4:	75 39                	jne    801052ef <memset+0x50>
    c &= 0xFF;
801052b6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052bd:	8b 45 10             	mov    0x10(%ebp),%eax
801052c0:	c1 e8 02             	shr    $0x2,%eax
801052c3:	89 c1                	mov    %eax,%ecx
801052c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c8:	c1 e0 18             	shl    $0x18,%eax
801052cb:	89 c2                	mov    %eax,%edx
801052cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d0:	c1 e0 10             	shl    $0x10,%eax
801052d3:	09 c2                	or     %eax,%edx
801052d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d8:	c1 e0 08             	shl    $0x8,%eax
801052db:	09 d0                	or     %edx,%eax
801052dd:	0b 45 0c             	or     0xc(%ebp),%eax
801052e0:	51                   	push   %ecx
801052e1:	50                   	push   %eax
801052e2:	ff 75 08             	pushl  0x8(%ebp)
801052e5:	e8 8f ff ff ff       	call   80105279 <stosl>
801052ea:	83 c4 0c             	add    $0xc,%esp
801052ed:	eb 12                	jmp    80105301 <memset+0x62>
  } else
    stosb(dst, c, n);
801052ef:	8b 45 10             	mov    0x10(%ebp),%eax
801052f2:	50                   	push   %eax
801052f3:	ff 75 0c             	pushl  0xc(%ebp)
801052f6:	ff 75 08             	pushl  0x8(%ebp)
801052f9:	e8 55 ff ff ff       	call   80105253 <stosb>
801052fe:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105301:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105304:	c9                   	leave  
80105305:	c3                   	ret    

80105306 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105306:	55                   	push   %ebp
80105307:	89 e5                	mov    %esp,%ebp
80105309:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010530c:	8b 45 08             	mov    0x8(%ebp),%eax
8010530f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105312:	8b 45 0c             	mov    0xc(%ebp),%eax
80105315:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105318:	eb 30                	jmp    8010534a <memcmp+0x44>
    if(*s1 != *s2)
8010531a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010531d:	0f b6 10             	movzbl (%eax),%edx
80105320:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105323:	0f b6 00             	movzbl (%eax),%eax
80105326:	38 c2                	cmp    %al,%dl
80105328:	74 18                	je     80105342 <memcmp+0x3c>
      return *s1 - *s2;
8010532a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532d:	0f b6 00             	movzbl (%eax),%eax
80105330:	0f b6 d0             	movzbl %al,%edx
80105333:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105336:	0f b6 00             	movzbl (%eax),%eax
80105339:	0f b6 c0             	movzbl %al,%eax
8010533c:	29 c2                	sub    %eax,%edx
8010533e:	89 d0                	mov    %edx,%eax
80105340:	eb 1a                	jmp    8010535c <memcmp+0x56>
    s1++, s2++;
80105342:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105346:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010534a:	8b 45 10             	mov    0x10(%ebp),%eax
8010534d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105350:	89 55 10             	mov    %edx,0x10(%ebp)
80105353:	85 c0                	test   %eax,%eax
80105355:	75 c3                	jne    8010531a <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010535c:	c9                   	leave  
8010535d:	c3                   	ret    

8010535e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010535e:	55                   	push   %ebp
8010535f:	89 e5                	mov    %esp,%ebp
80105361:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105364:	8b 45 0c             	mov    0xc(%ebp),%eax
80105367:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010536a:	8b 45 08             	mov    0x8(%ebp),%eax
8010536d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105370:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105373:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105376:	73 54                	jae    801053cc <memmove+0x6e>
80105378:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010537b:	8b 45 10             	mov    0x10(%ebp),%eax
8010537e:	01 d0                	add    %edx,%eax
80105380:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105383:	76 47                	jbe    801053cc <memmove+0x6e>
    s += n;
80105385:	8b 45 10             	mov    0x10(%ebp),%eax
80105388:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010538b:	8b 45 10             	mov    0x10(%ebp),%eax
8010538e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105391:	eb 13                	jmp    801053a6 <memmove+0x48>
      *--d = *--s;
80105393:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105397:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010539b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539e:	0f b6 10             	movzbl (%eax),%edx
801053a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a4:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801053a6:	8b 45 10             	mov    0x10(%ebp),%eax
801053a9:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ac:	89 55 10             	mov    %edx,0x10(%ebp)
801053af:	85 c0                	test   %eax,%eax
801053b1:	75 e0                	jne    80105393 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801053b3:	eb 24                	jmp    801053d9 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801053b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b8:	8d 50 01             	lea    0x1(%eax),%edx
801053bb:	89 55 f8             	mov    %edx,-0x8(%ebp)
801053be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053c1:	8d 4a 01             	lea    0x1(%edx),%ecx
801053c4:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801053c7:	0f b6 12             	movzbl (%edx),%edx
801053ca:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053cc:	8b 45 10             	mov    0x10(%ebp),%eax
801053cf:	8d 50 ff             	lea    -0x1(%eax),%edx
801053d2:	89 55 10             	mov    %edx,0x10(%ebp)
801053d5:	85 c0                	test   %eax,%eax
801053d7:	75 dc                	jne    801053b5 <memmove+0x57>
      *d++ = *s++;

  return dst;
801053d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053dc:	c9                   	leave  
801053dd:	c3                   	ret    

801053de <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053de:	55                   	push   %ebp
801053df:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801053e1:	ff 75 10             	pushl  0x10(%ebp)
801053e4:	ff 75 0c             	pushl  0xc(%ebp)
801053e7:	ff 75 08             	pushl  0x8(%ebp)
801053ea:	e8 6f ff ff ff       	call   8010535e <memmove>
801053ef:	83 c4 0c             	add    $0xc,%esp
}
801053f2:	c9                   	leave  
801053f3:	c3                   	ret    

801053f4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053f4:	55                   	push   %ebp
801053f5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053f7:	eb 0c                	jmp    80105405 <strncmp+0x11>
    n--, p++, q++;
801053f9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105401:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105409:	74 1a                	je     80105425 <strncmp+0x31>
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	0f b6 00             	movzbl (%eax),%eax
80105411:	84 c0                	test   %al,%al
80105413:	74 10                	je     80105425 <strncmp+0x31>
80105415:	8b 45 08             	mov    0x8(%ebp),%eax
80105418:	0f b6 10             	movzbl (%eax),%edx
8010541b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541e:	0f b6 00             	movzbl (%eax),%eax
80105421:	38 c2                	cmp    %al,%dl
80105423:	74 d4                	je     801053f9 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105425:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105429:	75 07                	jne    80105432 <strncmp+0x3e>
    return 0;
8010542b:	b8 00 00 00 00       	mov    $0x0,%eax
80105430:	eb 16                	jmp    80105448 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105432:	8b 45 08             	mov    0x8(%ebp),%eax
80105435:	0f b6 00             	movzbl (%eax),%eax
80105438:	0f b6 d0             	movzbl %al,%edx
8010543b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543e:	0f b6 00             	movzbl (%eax),%eax
80105441:	0f b6 c0             	movzbl %al,%eax
80105444:	29 c2                	sub    %eax,%edx
80105446:	89 d0                	mov    %edx,%eax
}
80105448:	5d                   	pop    %ebp
80105449:	c3                   	ret    

8010544a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010544a:	55                   	push   %ebp
8010544b:	89 e5                	mov    %esp,%ebp
8010544d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105450:	8b 45 08             	mov    0x8(%ebp),%eax
80105453:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105456:	90                   	nop
80105457:	8b 45 10             	mov    0x10(%ebp),%eax
8010545a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010545d:	89 55 10             	mov    %edx,0x10(%ebp)
80105460:	85 c0                	test   %eax,%eax
80105462:	7e 2c                	jle    80105490 <strncpy+0x46>
80105464:	8b 45 08             	mov    0x8(%ebp),%eax
80105467:	8d 50 01             	lea    0x1(%eax),%edx
8010546a:	89 55 08             	mov    %edx,0x8(%ebp)
8010546d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105470:	8d 4a 01             	lea    0x1(%edx),%ecx
80105473:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105476:	0f b6 12             	movzbl (%edx),%edx
80105479:	88 10                	mov    %dl,(%eax)
8010547b:	0f b6 00             	movzbl (%eax),%eax
8010547e:	84 c0                	test   %al,%al
80105480:	75 d5                	jne    80105457 <strncpy+0xd>
    ;
  while(n-- > 0)
80105482:	eb 0c                	jmp    80105490 <strncpy+0x46>
    *s++ = 0;
80105484:	8b 45 08             	mov    0x8(%ebp),%eax
80105487:	8d 50 01             	lea    0x1(%eax),%edx
8010548a:	89 55 08             	mov    %edx,0x8(%ebp)
8010548d:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105490:	8b 45 10             	mov    0x10(%ebp),%eax
80105493:	8d 50 ff             	lea    -0x1(%eax),%edx
80105496:	89 55 10             	mov    %edx,0x10(%ebp)
80105499:	85 c0                	test   %eax,%eax
8010549b:	7f e7                	jg     80105484 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010549d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054a0:	c9                   	leave  
801054a1:	c3                   	ret    

801054a2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054a2:	55                   	push   %ebp
801054a3:	89 e5                	mov    %esp,%ebp
801054a5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054a8:	8b 45 08             	mov    0x8(%ebp),%eax
801054ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b2:	7f 05                	jg     801054b9 <safestrcpy+0x17>
    return os;
801054b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b7:	eb 31                	jmp    801054ea <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054b9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054c1:	7e 1e                	jle    801054e1 <safestrcpy+0x3f>
801054c3:	8b 45 08             	mov    0x8(%ebp),%eax
801054c6:	8d 50 01             	lea    0x1(%eax),%edx
801054c9:	89 55 08             	mov    %edx,0x8(%ebp)
801054cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801054cf:	8d 4a 01             	lea    0x1(%edx),%ecx
801054d2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054d5:	0f b6 12             	movzbl (%edx),%edx
801054d8:	88 10                	mov    %dl,(%eax)
801054da:	0f b6 00             	movzbl (%eax),%eax
801054dd:	84 c0                	test   %al,%al
801054df:	75 d8                	jne    801054b9 <safestrcpy+0x17>
    ;
  *s = 0;
801054e1:	8b 45 08             	mov    0x8(%ebp),%eax
801054e4:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054ea:	c9                   	leave  
801054eb:	c3                   	ret    

801054ec <strlen>:

int
strlen(const char *s)
{
801054ec:	55                   	push   %ebp
801054ed:	89 e5                	mov    %esp,%ebp
801054ef:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054f9:	eb 04                	jmp    801054ff <strlen+0x13>
801054fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105502:	8b 45 08             	mov    0x8(%ebp),%eax
80105505:	01 d0                	add    %edx,%eax
80105507:	0f b6 00             	movzbl (%eax),%eax
8010550a:	84 c0                	test   %al,%al
8010550c:	75 ed                	jne    801054fb <strlen+0xf>
    ;
  return n;
8010550e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105511:	c9                   	leave  
80105512:	c3                   	ret    

80105513 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105513:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105517:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010551b:	55                   	push   %ebp
  pushl %ebx
8010551c:	53                   	push   %ebx
  pushl %esi
8010551d:	56                   	push   %esi
  pushl %edi
8010551e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010551f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105521:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105523:	5f                   	pop    %edi
  popl %esi
80105524:	5e                   	pop    %esi
  popl %ebx
80105525:	5b                   	pop    %ebx
  popl %ebp
80105526:	5d                   	pop    %ebp
  ret
80105527:	c3                   	ret    

80105528 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105528:	55                   	push   %ebp
80105529:	89 e5                	mov    %esp,%ebp
8010552b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010552e:	e8 e5 ed ff ff       	call   80104318 <myproc>
80105533:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105539:	8b 00                	mov    (%eax),%eax
8010553b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010553e:	76 0f                	jbe    8010554f <fetchint+0x27>
80105540:	8b 45 08             	mov    0x8(%ebp),%eax
80105543:	8d 50 04             	lea    0x4(%eax),%edx
80105546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105549:	8b 00                	mov    (%eax),%eax
8010554b:	39 c2                	cmp    %eax,%edx
8010554d:	76 07                	jbe    80105556 <fetchint+0x2e>
    return -1;
8010554f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105554:	eb 0f                	jmp    80105565 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105556:	8b 45 08             	mov    0x8(%ebp),%eax
80105559:	8b 10                	mov    (%eax),%edx
8010555b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555e:	89 10                	mov    %edx,(%eax)
  return 0;
80105560:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105565:	c9                   	leave  
80105566:	c3                   	ret    

80105567 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105567:	55                   	push   %ebp
80105568:	89 e5                	mov    %esp,%ebp
8010556a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010556d:	e8 a6 ed ff ff       	call   80104318 <myproc>
80105572:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105575:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105578:	8b 00                	mov    (%eax),%eax
8010557a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010557d:	77 07                	ja     80105586 <fetchstr+0x1f>
    return -1;
8010557f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105584:	eb 43                	jmp    801055c9 <fetchstr+0x62>
  *pp = (char*)addr;
80105586:	8b 55 08             	mov    0x8(%ebp),%edx
80105589:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558c:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010558e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105591:	8b 00                	mov    (%eax),%eax
80105593:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105596:	8b 45 0c             	mov    0xc(%ebp),%eax
80105599:	8b 00                	mov    (%eax),%eax
8010559b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010559e:	eb 1c                	jmp    801055bc <fetchstr+0x55>
    if(*s == 0)
801055a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a3:	0f b6 00             	movzbl (%eax),%eax
801055a6:	84 c0                	test   %al,%al
801055a8:	75 0e                	jne    801055b8 <fetchstr+0x51>
      return s - *pp;
801055aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b0:	8b 00                	mov    (%eax),%eax
801055b2:	29 c2                	sub    %eax,%edx
801055b4:	89 d0                	mov    %edx,%eax
801055b6:	eb 11                	jmp    801055c9 <fetchstr+0x62>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801055b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801055c2:	72 dc                	jb     801055a0 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801055c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055c9:	c9                   	leave  
801055ca:	c3                   	ret    

801055cb <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055cb:	55                   	push   %ebp
801055cc:	89 e5                	mov    %esp,%ebp
801055ce:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801055d1:	e8 42 ed ff ff       	call   80104318 <myproc>
801055d6:	8b 40 18             	mov    0x18(%eax),%eax
801055d9:	8b 40 44             	mov    0x44(%eax),%eax
801055dc:	8b 55 08             	mov    0x8(%ebp),%edx
801055df:	c1 e2 02             	shl    $0x2,%edx
801055e2:	01 d0                	add    %edx,%eax
801055e4:	83 c0 04             	add    $0x4,%eax
801055e7:	83 ec 08             	sub    $0x8,%esp
801055ea:	ff 75 0c             	pushl  0xc(%ebp)
801055ed:	50                   	push   %eax
801055ee:	e8 35 ff ff ff       	call   80105528 <fetchint>
801055f3:	83 c4 10             	add    $0x10,%esp
}
801055f6:	c9                   	leave  
801055f7:	c3                   	ret    

801055f8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055f8:	55                   	push   %ebp
801055f9:	89 e5                	mov    %esp,%ebp
801055fb:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801055fe:	e8 15 ed ff ff       	call   80104318 <myproc>
80105603:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105606:	83 ec 08             	sub    $0x8,%esp
80105609:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010560c:	50                   	push   %eax
8010560d:	ff 75 08             	pushl  0x8(%ebp)
80105610:	e8 b6 ff ff ff       	call   801055cb <argint>
80105615:	83 c4 10             	add    $0x10,%esp
80105618:	85 c0                	test   %eax,%eax
8010561a:	79 07                	jns    80105623 <argptr+0x2b>
    return -1;
8010561c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105621:	eb 3b                	jmp    8010565e <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105623:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105627:	78 1f                	js     80105648 <argptr+0x50>
80105629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562c:	8b 00                	mov    (%eax),%eax
8010562e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105631:	39 d0                	cmp    %edx,%eax
80105633:	76 13                	jbe    80105648 <argptr+0x50>
80105635:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105638:	89 c2                	mov    %eax,%edx
8010563a:	8b 45 10             	mov    0x10(%ebp),%eax
8010563d:	01 c2                	add    %eax,%edx
8010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105642:	8b 00                	mov    (%eax),%eax
80105644:	39 c2                	cmp    %eax,%edx
80105646:	76 07                	jbe    8010564f <argptr+0x57>
    return -1;
80105648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010564d:	eb 0f                	jmp    8010565e <argptr+0x66>
  *pp = (char*)i;
8010564f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105652:	89 c2                	mov    %eax,%edx
80105654:	8b 45 0c             	mov    0xc(%ebp),%eax
80105657:	89 10                	mov    %edx,(%eax)
  return 0;
80105659:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010565e:	c9                   	leave  
8010565f:	c3                   	ret    

80105660 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105660:	55                   	push   %ebp
80105661:	89 e5                	mov    %esp,%ebp
80105663:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105666:	83 ec 08             	sub    $0x8,%esp
80105669:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010566c:	50                   	push   %eax
8010566d:	ff 75 08             	pushl  0x8(%ebp)
80105670:	e8 56 ff ff ff       	call   801055cb <argint>
80105675:	83 c4 10             	add    $0x10,%esp
80105678:	85 c0                	test   %eax,%eax
8010567a:	79 07                	jns    80105683 <argstr+0x23>
    return -1;
8010567c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105681:	eb 12                	jmp    80105695 <argstr+0x35>
  return fetchstr(addr, pp);
80105683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105686:	83 ec 08             	sub    $0x8,%esp
80105689:	ff 75 0c             	pushl  0xc(%ebp)
8010568c:	50                   	push   %eax
8010568d:	e8 d5 fe ff ff       	call   80105567 <fetchstr>
80105692:	83 c4 10             	add    $0x10,%esp
}
80105695:	c9                   	leave  
80105696:	c3                   	ret    

80105697 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
80105697:	55                   	push   %ebp
80105698:	89 e5                	mov    %esp,%ebp
8010569a:	53                   	push   %ebx
8010569b:	83 ec 14             	sub    $0x14,%esp
  int num;
  struct proc *curproc = myproc();
8010569e:	e8 75 ec ff ff       	call   80104318 <myproc>
801056a3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801056a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a9:	8b 40 18             	mov    0x18(%eax),%eax
801056ac:	8b 40 1c             	mov    0x1c(%eax),%eax
801056af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056b2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056b6:	7e 2d                	jle    801056e5 <syscall+0x4e>
801056b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056bb:	83 f8 17             	cmp    $0x17,%eax
801056be:	77 25                	ja     801056e5 <syscall+0x4e>
801056c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c3:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801056ca:	85 c0                	test   %eax,%eax
801056cc:	74 17                	je     801056e5 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801056ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d1:	8b 58 18             	mov    0x18(%eax),%ebx
801056d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d7:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801056de:	ff d0                	call   *%eax
801056e0:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056e3:	eb 2b                	jmp    80105710 <syscall+0x79>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801056e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e8:	8d 50 6c             	lea    0x6c(%eax),%edx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801056eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ee:	8b 40 10             	mov    0x10(%eax),%eax
801056f1:	ff 75 f0             	pushl  -0x10(%ebp)
801056f4:	52                   	push   %edx
801056f5:	50                   	push   %eax
801056f6:	68 35 8a 10 80       	push   $0x80108a35
801056fb:	e8 00 ad ff ff       	call   80100400 <cprintf>
80105700:	83 c4 10             	add    $0x10,%esp
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105706:	8b 40 18             	mov    0x18(%eax),%eax
80105709:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105710:	90                   	nop
80105711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105714:	c9                   	leave  
80105715:	c3                   	ret    

80105716 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105716:	55                   	push   %ebp
80105717:	89 e5                	mov    %esp,%ebp
80105719:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010571c:	83 ec 08             	sub    $0x8,%esp
8010571f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105722:	50                   	push   %eax
80105723:	ff 75 08             	pushl  0x8(%ebp)
80105726:	e8 a0 fe ff ff       	call   801055cb <argint>
8010572b:	83 c4 10             	add    $0x10,%esp
8010572e:	85 c0                	test   %eax,%eax
80105730:	79 07                	jns    80105739 <argfd+0x23>
    return -1;
80105732:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105737:	eb 51                	jmp    8010578a <argfd+0x74>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105739:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573c:	85 c0                	test   %eax,%eax
8010573e:	78 22                	js     80105762 <argfd+0x4c>
80105740:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105743:	83 f8 0f             	cmp    $0xf,%eax
80105746:	7f 1a                	jg     80105762 <argfd+0x4c>
80105748:	e8 cb eb ff ff       	call   80104318 <myproc>
8010574d:	89 c2                	mov    %eax,%edx
8010574f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105752:	83 c0 08             	add    $0x8,%eax
80105755:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
80105759:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010575c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105760:	75 07                	jne    80105769 <argfd+0x53>
    return -1;
80105762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105767:	eb 21                	jmp    8010578a <argfd+0x74>
  if(pfd)
80105769:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010576d:	74 08                	je     80105777 <argfd+0x61>
    *pfd = fd;
8010576f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105772:	8b 45 0c             	mov    0xc(%ebp),%eax
80105775:	89 10                	mov    %edx,(%eax)
  if(pf)
80105777:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010577b:	74 08                	je     80105785 <argfd+0x6f>
    *pf = f;
8010577d:	8b 45 10             	mov    0x10(%ebp),%eax
80105780:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105783:	89 10                	mov    %edx,(%eax)
  return 0;
80105785:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010578a:	c9                   	leave  
8010578b:	c3                   	ret    

8010578c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010578c:	55                   	push   %ebp
8010578d:	89 e5                	mov    %esp,%ebp
8010578f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105792:	e8 81 eb ff ff       	call   80104318 <myproc>
80105797:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010579a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801057a1:	eb 2a                	jmp    801057cd <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801057a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057a9:	83 c2 08             	add    $0x8,%edx
801057ac:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057b0:	85 c0                	test   %eax,%eax
801057b2:	75 15                	jne    801057c9 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801057b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057ba:	8d 4a 08             	lea    0x8(%edx),%ecx
801057bd:	8b 55 08             	mov    0x8(%ebp),%edx
801057c0:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c7:	eb 0f                	jmp    801057d8 <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801057c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801057cd:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801057d1:	7e d0                	jle    801057a3 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057d8:	c9                   	leave  
801057d9:	c3                   	ret    

801057da <sys_dup>:

int
sys_dup(void)
{
801057da:	55                   	push   %ebp
801057db:	89 e5                	mov    %esp,%ebp
801057dd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801057e0:	83 ec 04             	sub    $0x4,%esp
801057e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057e6:	50                   	push   %eax
801057e7:	6a 00                	push   $0x0
801057e9:	6a 00                	push   $0x0
801057eb:	e8 26 ff ff ff       	call   80105716 <argfd>
801057f0:	83 c4 10             	add    $0x10,%esp
801057f3:	85 c0                	test   %eax,%eax
801057f5:	79 07                	jns    801057fe <sys_dup+0x24>
    return -1;
801057f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057fc:	eb 31                	jmp    8010582f <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801057fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105801:	83 ec 0c             	sub    $0xc,%esp
80105804:	50                   	push   %eax
80105805:	e8 82 ff ff ff       	call   8010578c <fdalloc>
8010580a:	83 c4 10             	add    $0x10,%esp
8010580d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105810:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105814:	79 07                	jns    8010581d <sys_dup+0x43>
    return -1;
80105816:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581b:	eb 12                	jmp    8010582f <sys_dup+0x55>
  filedup(f);
8010581d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	50                   	push   %eax
80105824:	e8 c2 b8 ff ff       	call   801010eb <filedup>
80105829:	83 c4 10             	add    $0x10,%esp
  return fd;
8010582c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010582f:	c9                   	leave  
80105830:	c3                   	ret    

80105831 <sys_read>:

int
sys_read(void)
{
80105831:	55                   	push   %ebp
80105832:	89 e5                	mov    %esp,%ebp
80105834:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105837:	83 ec 04             	sub    $0x4,%esp
8010583a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010583d:	50                   	push   %eax
8010583e:	6a 00                	push   $0x0
80105840:	6a 00                	push   $0x0
80105842:	e8 cf fe ff ff       	call   80105716 <argfd>
80105847:	83 c4 10             	add    $0x10,%esp
8010584a:	85 c0                	test   %eax,%eax
8010584c:	78 2e                	js     8010587c <sys_read+0x4b>
8010584e:	83 ec 08             	sub    $0x8,%esp
80105851:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105854:	50                   	push   %eax
80105855:	6a 02                	push   $0x2
80105857:	e8 6f fd ff ff       	call   801055cb <argint>
8010585c:	83 c4 10             	add    $0x10,%esp
8010585f:	85 c0                	test   %eax,%eax
80105861:	78 19                	js     8010587c <sys_read+0x4b>
80105863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105866:	83 ec 04             	sub    $0x4,%esp
80105869:	50                   	push   %eax
8010586a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010586d:	50                   	push   %eax
8010586e:	6a 01                	push   $0x1
80105870:	e8 83 fd ff ff       	call   801055f8 <argptr>
80105875:	83 c4 10             	add    $0x10,%esp
80105878:	85 c0                	test   %eax,%eax
8010587a:	79 07                	jns    80105883 <sys_read+0x52>
    return -1;
8010587c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105881:	eb 17                	jmp    8010589a <sys_read+0x69>
  return fileread(f, p, n);
80105883:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105886:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588c:	83 ec 04             	sub    $0x4,%esp
8010588f:	51                   	push   %ecx
80105890:	52                   	push   %edx
80105891:	50                   	push   %eax
80105892:	e8 e4 b9 ff ff       	call   8010127b <fileread>
80105897:	83 c4 10             	add    $0x10,%esp
}
8010589a:	c9                   	leave  
8010589b:	c3                   	ret    

8010589c <sys_write>:

int
sys_write(void)
{
8010589c:	55                   	push   %ebp
8010589d:	89 e5                	mov    %esp,%ebp
8010589f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058a2:	83 ec 04             	sub    $0x4,%esp
801058a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058a8:	50                   	push   %eax
801058a9:	6a 00                	push   $0x0
801058ab:	6a 00                	push   $0x0
801058ad:	e8 64 fe ff ff       	call   80105716 <argfd>
801058b2:	83 c4 10             	add    $0x10,%esp
801058b5:	85 c0                	test   %eax,%eax
801058b7:	78 2e                	js     801058e7 <sys_write+0x4b>
801058b9:	83 ec 08             	sub    $0x8,%esp
801058bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058bf:	50                   	push   %eax
801058c0:	6a 02                	push   $0x2
801058c2:	e8 04 fd ff ff       	call   801055cb <argint>
801058c7:	83 c4 10             	add    $0x10,%esp
801058ca:	85 c0                	test   %eax,%eax
801058cc:	78 19                	js     801058e7 <sys_write+0x4b>
801058ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d1:	83 ec 04             	sub    $0x4,%esp
801058d4:	50                   	push   %eax
801058d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058d8:	50                   	push   %eax
801058d9:	6a 01                	push   $0x1
801058db:	e8 18 fd ff ff       	call   801055f8 <argptr>
801058e0:	83 c4 10             	add    $0x10,%esp
801058e3:	85 c0                	test   %eax,%eax
801058e5:	79 07                	jns    801058ee <sys_write+0x52>
    return -1;
801058e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ec:	eb 17                	jmp    80105905 <sys_write+0x69>
  return filewrite(f, p, n);
801058ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f7:	83 ec 04             	sub    $0x4,%esp
801058fa:	51                   	push   %ecx
801058fb:	52                   	push   %edx
801058fc:	50                   	push   %eax
801058fd:	e8 31 ba ff ff       	call   80101333 <filewrite>
80105902:	83 c4 10             	add    $0x10,%esp
}
80105905:	c9                   	leave  
80105906:	c3                   	ret    

80105907 <sys_close>:

int
sys_close(void)
{
80105907:	55                   	push   %ebp
80105908:	89 e5                	mov    %esp,%ebp
8010590a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010590d:	83 ec 04             	sub    $0x4,%esp
80105910:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105913:	50                   	push   %eax
80105914:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105917:	50                   	push   %eax
80105918:	6a 00                	push   $0x0
8010591a:	e8 f7 fd ff ff       	call   80105716 <argfd>
8010591f:	83 c4 10             	add    $0x10,%esp
80105922:	85 c0                	test   %eax,%eax
80105924:	79 07                	jns    8010592d <sys_close+0x26>
    return -1;
80105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592b:	eb 29                	jmp    80105956 <sys_close+0x4f>
  myproc()->ofile[fd] = 0;
8010592d:	e8 e6 e9 ff ff       	call   80104318 <myproc>
80105932:	89 c2                	mov    %eax,%edx
80105934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105937:	83 c0 08             	add    $0x8,%eax
8010593a:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
80105941:	00 
  fileclose(f);
80105942:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105945:	83 ec 0c             	sub    $0xc,%esp
80105948:	50                   	push   %eax
80105949:	e8 ee b7 ff ff       	call   8010113c <fileclose>
8010594e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105951:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105956:	c9                   	leave  
80105957:	c3                   	ret    

80105958 <sys_fstat>:

int
sys_fstat(void)
{
80105958:	55                   	push   %ebp
80105959:	89 e5                	mov    %esp,%ebp
8010595b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010595e:	83 ec 04             	sub    $0x4,%esp
80105961:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105964:	50                   	push   %eax
80105965:	6a 00                	push   $0x0
80105967:	6a 00                	push   $0x0
80105969:	e8 a8 fd ff ff       	call   80105716 <argfd>
8010596e:	83 c4 10             	add    $0x10,%esp
80105971:	85 c0                	test   %eax,%eax
80105973:	78 17                	js     8010598c <sys_fstat+0x34>
80105975:	83 ec 04             	sub    $0x4,%esp
80105978:	6a 14                	push   $0x14
8010597a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010597d:	50                   	push   %eax
8010597e:	6a 01                	push   $0x1
80105980:	e8 73 fc ff ff       	call   801055f8 <argptr>
80105985:	83 c4 10             	add    $0x10,%esp
80105988:	85 c0                	test   %eax,%eax
8010598a:	79 07                	jns    80105993 <sys_fstat+0x3b>
    return -1;
8010598c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105991:	eb 13                	jmp    801059a6 <sys_fstat+0x4e>
  return filestat(f, st);
80105993:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105999:	83 ec 08             	sub    $0x8,%esp
8010599c:	52                   	push   %edx
8010599d:	50                   	push   %eax
8010599e:	e8 81 b8 ff ff       	call   80101224 <filestat>
801059a3:	83 c4 10             	add    $0x10,%esp
}
801059a6:	c9                   	leave  
801059a7:	c3                   	ret    

801059a8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059a8:	55                   	push   %ebp
801059a9:	89 e5                	mov    %esp,%ebp
801059ab:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059ae:	83 ec 08             	sub    $0x8,%esp
801059b1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059b4:	50                   	push   %eax
801059b5:	6a 00                	push   $0x0
801059b7:	e8 a4 fc ff ff       	call   80105660 <argstr>
801059bc:	83 c4 10             	add    $0x10,%esp
801059bf:	85 c0                	test   %eax,%eax
801059c1:	78 15                	js     801059d8 <sys_link+0x30>
801059c3:	83 ec 08             	sub    $0x8,%esp
801059c6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059c9:	50                   	push   %eax
801059ca:	6a 01                	push   $0x1
801059cc:	e8 8f fc ff ff       	call   80105660 <argstr>
801059d1:	83 c4 10             	add    $0x10,%esp
801059d4:	85 c0                	test   %eax,%eax
801059d6:	79 0a                	jns    801059e2 <sys_link+0x3a>
    return -1;
801059d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059dd:	e9 68 01 00 00       	jmp    80105b4a <sys_link+0x1a2>

  begin_op();
801059e2:	e8 d9 db ff ff       	call   801035c0 <begin_op>
  if((ip = namei(old)) == 0){
801059e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059ea:	83 ec 0c             	sub    $0xc,%esp
801059ed:	50                   	push   %eax
801059ee:	e8 e8 cb ff ff       	call   801025db <namei>
801059f3:	83 c4 10             	add    $0x10,%esp
801059f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059fd:	75 0f                	jne    80105a0e <sys_link+0x66>
    end_op();
801059ff:	e8 48 dc ff ff       	call   8010364c <end_op>
    return -1;
80105a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a09:	e9 3c 01 00 00       	jmp    80105b4a <sys_link+0x1a2>
  }

  ilock(ip);
80105a0e:	83 ec 0c             	sub    $0xc,%esp
80105a11:	ff 75 f4             	pushl  -0xc(%ebp)
80105a14:	e8 82 c0 ff ff       	call   80101a9b <ilock>
80105a19:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a23:	66 83 f8 01          	cmp    $0x1,%ax
80105a27:	75 1d                	jne    80105a46 <sys_link+0x9e>
    iunlockput(ip);
80105a29:	83 ec 0c             	sub    $0xc,%esp
80105a2c:	ff 75 f4             	pushl  -0xc(%ebp)
80105a2f:	e8 98 c2 ff ff       	call   80101ccc <iunlockput>
80105a34:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a37:	e8 10 dc ff ff       	call   8010364c <end_op>
    return -1;
80105a3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a41:	e9 04 01 00 00       	jmp    80105b4a <sys_link+0x1a2>
  }

  ip->nlink++;
80105a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a49:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a4d:	83 c0 01             	add    $0x1,%eax
80105a50:	89 c2                	mov    %eax,%edx
80105a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a55:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a59:	83 ec 0c             	sub    $0xc,%esp
80105a5c:	ff 75 f4             	pushl  -0xc(%ebp)
80105a5f:	e8 5a be ff ff       	call   801018be <iupdate>
80105a64:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a67:	83 ec 0c             	sub    $0xc,%esp
80105a6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a6d:	e8 3c c1 ff ff       	call   80101bae <iunlock>
80105a72:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a78:	83 ec 08             	sub    $0x8,%esp
80105a7b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a7e:	52                   	push   %edx
80105a7f:	50                   	push   %eax
80105a80:	e8 72 cb ff ff       	call   801025f7 <nameiparent>
80105a85:	83 c4 10             	add    $0x10,%esp
80105a88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a8f:	74 71                	je     80105b02 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a91:	83 ec 0c             	sub    $0xc,%esp
80105a94:	ff 75 f0             	pushl  -0x10(%ebp)
80105a97:	e8 ff bf ff ff       	call   80101a9b <ilock>
80105a9c:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa2:	8b 10                	mov    (%eax),%edx
80105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa7:	8b 00                	mov    (%eax),%eax
80105aa9:	39 c2                	cmp    %eax,%edx
80105aab:	75 1d                	jne    80105aca <sys_link+0x122>
80105aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab0:	8b 40 04             	mov    0x4(%eax),%eax
80105ab3:	83 ec 04             	sub    $0x4,%esp
80105ab6:	50                   	push   %eax
80105ab7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105aba:	50                   	push   %eax
80105abb:	ff 75 f0             	pushl  -0x10(%ebp)
80105abe:	e8 7d c8 ff ff       	call   80102340 <dirlink>
80105ac3:	83 c4 10             	add    $0x10,%esp
80105ac6:	85 c0                	test   %eax,%eax
80105ac8:	79 10                	jns    80105ada <sys_link+0x132>
    iunlockput(dp);
80105aca:	83 ec 0c             	sub    $0xc,%esp
80105acd:	ff 75 f0             	pushl  -0x10(%ebp)
80105ad0:	e8 f7 c1 ff ff       	call   80101ccc <iunlockput>
80105ad5:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ad8:	eb 29                	jmp    80105b03 <sys_link+0x15b>
  }
  iunlockput(dp);
80105ada:	83 ec 0c             	sub    $0xc,%esp
80105add:	ff 75 f0             	pushl  -0x10(%ebp)
80105ae0:	e8 e7 c1 ff ff       	call   80101ccc <iunlockput>
80105ae5:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105ae8:	83 ec 0c             	sub    $0xc,%esp
80105aeb:	ff 75 f4             	pushl  -0xc(%ebp)
80105aee:	e8 09 c1 ff ff       	call   80101bfc <iput>
80105af3:	83 c4 10             	add    $0x10,%esp

  end_op();
80105af6:	e8 51 db ff ff       	call   8010364c <end_op>

  return 0;
80105afb:	b8 00 00 00 00       	mov    $0x0,%eax
80105b00:	eb 48                	jmp    80105b4a <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105b02:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105b03:	83 ec 0c             	sub    $0xc,%esp
80105b06:	ff 75 f4             	pushl  -0xc(%ebp)
80105b09:	e8 8d bf ff ff       	call   80101a9b <ilock>
80105b0e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b14:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b18:	83 e8 01             	sub    $0x1,%eax
80105b1b:	89 c2                	mov    %eax,%edx
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b24:	83 ec 0c             	sub    $0xc,%esp
80105b27:	ff 75 f4             	pushl  -0xc(%ebp)
80105b2a:	e8 8f bd ff ff       	call   801018be <iupdate>
80105b2f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b32:	83 ec 0c             	sub    $0xc,%esp
80105b35:	ff 75 f4             	pushl  -0xc(%ebp)
80105b38:	e8 8f c1 ff ff       	call   80101ccc <iunlockput>
80105b3d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b40:	e8 07 db ff ff       	call   8010364c <end_op>
  return -1;
80105b45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b4a:	c9                   	leave  
80105b4b:	c3                   	ret    

80105b4c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b4c:	55                   	push   %ebp
80105b4d:	89 e5                	mov    %esp,%ebp
80105b4f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b52:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b59:	eb 40                	jmp    80105b9b <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5e:	6a 10                	push   $0x10
80105b60:	50                   	push   %eax
80105b61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b64:	50                   	push   %eax
80105b65:	ff 75 08             	pushl  0x8(%ebp)
80105b68:	e8 1f c4 ff ff       	call   80101f8c <readi>
80105b6d:	83 c4 10             	add    $0x10,%esp
80105b70:	83 f8 10             	cmp    $0x10,%eax
80105b73:	74 0d                	je     80105b82 <isdirempty+0x36>
      panic("isdirempty: readi");
80105b75:	83 ec 0c             	sub    $0xc,%esp
80105b78:	68 51 8a 10 80       	push   $0x80108a51
80105b7d:	e8 1e aa ff ff       	call   801005a0 <panic>
    if(de.inum != 0)
80105b82:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b86:	66 85 c0             	test   %ax,%ax
80105b89:	74 07                	je     80105b92 <isdirempty+0x46>
      return 0;
80105b8b:	b8 00 00 00 00       	mov    $0x0,%eax
80105b90:	eb 1b                	jmp    80105bad <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b95:	83 c0 10             	add    $0x10,%eax
80105b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9e:	8b 50 58             	mov    0x58(%eax),%edx
80105ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba4:	39 c2                	cmp    %eax,%edx
80105ba6:	77 b3                	ja     80105b5b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ba8:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bad:	c9                   	leave  
80105bae:	c3                   	ret    

80105baf <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105baf:	55                   	push   %ebp
80105bb0:	89 e5                	mov    %esp,%ebp
80105bb2:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bb5:	83 ec 08             	sub    $0x8,%esp
80105bb8:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bbb:	50                   	push   %eax
80105bbc:	6a 00                	push   $0x0
80105bbe:	e8 9d fa ff ff       	call   80105660 <argstr>
80105bc3:	83 c4 10             	add    $0x10,%esp
80105bc6:	85 c0                	test   %eax,%eax
80105bc8:	79 0a                	jns    80105bd4 <sys_unlink+0x25>
    return -1;
80105bca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcf:	e9 bc 01 00 00       	jmp    80105d90 <sys_unlink+0x1e1>

  begin_op();
80105bd4:	e8 e7 d9 ff ff       	call   801035c0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bd9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bdc:	83 ec 08             	sub    $0x8,%esp
80105bdf:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105be2:	52                   	push   %edx
80105be3:	50                   	push   %eax
80105be4:	e8 0e ca ff ff       	call   801025f7 <nameiparent>
80105be9:	83 c4 10             	add    $0x10,%esp
80105bec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf3:	75 0f                	jne    80105c04 <sys_unlink+0x55>
    end_op();
80105bf5:	e8 52 da ff ff       	call   8010364c <end_op>
    return -1;
80105bfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bff:	e9 8c 01 00 00       	jmp    80105d90 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105c04:	83 ec 0c             	sub    $0xc,%esp
80105c07:	ff 75 f4             	pushl  -0xc(%ebp)
80105c0a:	e8 8c be ff ff       	call   80101a9b <ilock>
80105c0f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c12:	83 ec 08             	sub    $0x8,%esp
80105c15:	68 63 8a 10 80       	push   $0x80108a63
80105c1a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c1d:	50                   	push   %eax
80105c1e:	e8 48 c6 ff ff       	call   8010226b <namecmp>
80105c23:	83 c4 10             	add    $0x10,%esp
80105c26:	85 c0                	test   %eax,%eax
80105c28:	0f 84 4a 01 00 00    	je     80105d78 <sys_unlink+0x1c9>
80105c2e:	83 ec 08             	sub    $0x8,%esp
80105c31:	68 65 8a 10 80       	push   $0x80108a65
80105c36:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c39:	50                   	push   %eax
80105c3a:	e8 2c c6 ff ff       	call   8010226b <namecmp>
80105c3f:	83 c4 10             	add    $0x10,%esp
80105c42:	85 c0                	test   %eax,%eax
80105c44:	0f 84 2e 01 00 00    	je     80105d78 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c4a:	83 ec 04             	sub    $0x4,%esp
80105c4d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c50:	50                   	push   %eax
80105c51:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c54:	50                   	push   %eax
80105c55:	ff 75 f4             	pushl  -0xc(%ebp)
80105c58:	e8 29 c6 ff ff       	call   80102286 <dirlookup>
80105c5d:	83 c4 10             	add    $0x10,%esp
80105c60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c67:	0f 84 0a 01 00 00    	je     80105d77 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105c6d:	83 ec 0c             	sub    $0xc,%esp
80105c70:	ff 75 f0             	pushl  -0x10(%ebp)
80105c73:	e8 23 be ff ff       	call   80101a9b <ilock>
80105c78:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c82:	66 85 c0             	test   %ax,%ax
80105c85:	7f 0d                	jg     80105c94 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c87:	83 ec 0c             	sub    $0xc,%esp
80105c8a:	68 68 8a 10 80       	push   $0x80108a68
80105c8f:	e8 0c a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c97:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c9b:	66 83 f8 01          	cmp    $0x1,%ax
80105c9f:	75 25                	jne    80105cc6 <sys_unlink+0x117>
80105ca1:	83 ec 0c             	sub    $0xc,%esp
80105ca4:	ff 75 f0             	pushl  -0x10(%ebp)
80105ca7:	e8 a0 fe ff ff       	call   80105b4c <isdirempty>
80105cac:	83 c4 10             	add    $0x10,%esp
80105caf:	85 c0                	test   %eax,%eax
80105cb1:	75 13                	jne    80105cc6 <sys_unlink+0x117>
    iunlockput(ip);
80105cb3:	83 ec 0c             	sub    $0xc,%esp
80105cb6:	ff 75 f0             	pushl  -0x10(%ebp)
80105cb9:	e8 0e c0 ff ff       	call   80101ccc <iunlockput>
80105cbe:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cc1:	e9 b2 00 00 00       	jmp    80105d78 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105cc6:	83 ec 04             	sub    $0x4,%esp
80105cc9:	6a 10                	push   $0x10
80105ccb:	6a 00                	push   $0x0
80105ccd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cd0:	50                   	push   %eax
80105cd1:	e8 c9 f5 ff ff       	call   8010529f <memset>
80105cd6:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cd9:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105cdc:	6a 10                	push   $0x10
80105cde:	50                   	push   %eax
80105cdf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ce2:	50                   	push   %eax
80105ce3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ce6:	e8 f8 c3 ff ff       	call   801020e3 <writei>
80105ceb:	83 c4 10             	add    $0x10,%esp
80105cee:	83 f8 10             	cmp    $0x10,%eax
80105cf1:	74 0d                	je     80105d00 <sys_unlink+0x151>
    panic("unlink: writei");
80105cf3:	83 ec 0c             	sub    $0xc,%esp
80105cf6:	68 7a 8a 10 80       	push   $0x80108a7a
80105cfb:	e8 a0 a8 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR){
80105d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d03:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d07:	66 83 f8 01          	cmp    $0x1,%ax
80105d0b:	75 21                	jne    80105d2e <sys_unlink+0x17f>
    dp->nlink--;
80105d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d10:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d14:	83 e8 01             	sub    $0x1,%eax
80105d17:	89 c2                	mov    %eax,%edx
80105d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105d20:	83 ec 0c             	sub    $0xc,%esp
80105d23:	ff 75 f4             	pushl  -0xc(%ebp)
80105d26:	e8 93 bb ff ff       	call   801018be <iupdate>
80105d2b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d2e:	83 ec 0c             	sub    $0xc,%esp
80105d31:	ff 75 f4             	pushl  -0xc(%ebp)
80105d34:	e8 93 bf ff ff       	call   80101ccc <iunlockput>
80105d39:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d43:	83 e8 01             	sub    $0x1,%eax
80105d46:	89 c2                	mov    %eax,%edx
80105d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d4f:	83 ec 0c             	sub    $0xc,%esp
80105d52:	ff 75 f0             	pushl  -0x10(%ebp)
80105d55:	e8 64 bb ff ff       	call   801018be <iupdate>
80105d5a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d5d:	83 ec 0c             	sub    $0xc,%esp
80105d60:	ff 75 f0             	pushl  -0x10(%ebp)
80105d63:	e8 64 bf ff ff       	call   80101ccc <iunlockput>
80105d68:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d6b:	e8 dc d8 ff ff       	call   8010364c <end_op>

  return 0;
80105d70:	b8 00 00 00 00       	mov    $0x0,%eax
80105d75:	eb 19                	jmp    80105d90 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d77:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d7e:	e8 49 bf ff ff       	call   80101ccc <iunlockput>
80105d83:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d86:	e8 c1 d8 ff ff       	call   8010364c <end_op>
  return -1;
80105d8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d90:	c9                   	leave  
80105d91:	c3                   	ret    

80105d92 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d92:	55                   	push   %ebp
80105d93:	89 e5                	mov    %esp,%ebp
80105d95:	83 ec 38             	sub    $0x38,%esp
80105d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d9b:	8b 55 10             	mov    0x10(%ebp),%edx
80105d9e:	8b 45 14             	mov    0x14(%ebp),%eax
80105da1:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105da5:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105da9:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dad:	83 ec 08             	sub    $0x8,%esp
80105db0:	8d 45 de             	lea    -0x22(%ebp),%eax
80105db3:	50                   	push   %eax
80105db4:	ff 75 08             	pushl  0x8(%ebp)
80105db7:	e8 3b c8 ff ff       	call   801025f7 <nameiparent>
80105dbc:	83 c4 10             	add    $0x10,%esp
80105dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc6:	75 0a                	jne    80105dd2 <create+0x40>
    return 0;
80105dc8:	b8 00 00 00 00       	mov    $0x0,%eax
80105dcd:	e9 90 01 00 00       	jmp    80105f62 <create+0x1d0>
  ilock(dp);
80105dd2:	83 ec 0c             	sub    $0xc,%esp
80105dd5:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd8:	e8 be bc ff ff       	call   80101a9b <ilock>
80105ddd:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105de0:	83 ec 04             	sub    $0x4,%esp
80105de3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105de6:	50                   	push   %eax
80105de7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dea:	50                   	push   %eax
80105deb:	ff 75 f4             	pushl  -0xc(%ebp)
80105dee:	e8 93 c4 ff ff       	call   80102286 <dirlookup>
80105df3:	83 c4 10             	add    $0x10,%esp
80105df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dfd:	74 50                	je     80105e4f <create+0xbd>
    iunlockput(dp);
80105dff:	83 ec 0c             	sub    $0xc,%esp
80105e02:	ff 75 f4             	pushl  -0xc(%ebp)
80105e05:	e8 c2 be ff ff       	call   80101ccc <iunlockput>
80105e0a:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e0d:	83 ec 0c             	sub    $0xc,%esp
80105e10:	ff 75 f0             	pushl  -0x10(%ebp)
80105e13:	e8 83 bc ff ff       	call   80101a9b <ilock>
80105e18:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e1b:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e20:	75 15                	jne    80105e37 <create+0xa5>
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e29:	66 83 f8 02          	cmp    $0x2,%ax
80105e2d:	75 08                	jne    80105e37 <create+0xa5>
      return ip;
80105e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e32:	e9 2b 01 00 00       	jmp    80105f62 <create+0x1d0>
    iunlockput(ip);
80105e37:	83 ec 0c             	sub    $0xc,%esp
80105e3a:	ff 75 f0             	pushl  -0x10(%ebp)
80105e3d:	e8 8a be ff ff       	call   80101ccc <iunlockput>
80105e42:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e45:	b8 00 00 00 00       	mov    $0x0,%eax
80105e4a:	e9 13 01 00 00       	jmp    80105f62 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e4f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e56:	8b 00                	mov    (%eax),%eax
80105e58:	83 ec 08             	sub    $0x8,%esp
80105e5b:	52                   	push   %edx
80105e5c:	50                   	push   %eax
80105e5d:	e8 85 b9 ff ff       	call   801017e7 <ialloc>
80105e62:	83 c4 10             	add    $0x10,%esp
80105e65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e6c:	75 0d                	jne    80105e7b <create+0xe9>
    panic("create: ialloc");
80105e6e:	83 ec 0c             	sub    $0xc,%esp
80105e71:	68 89 8a 10 80       	push   $0x80108a89
80105e76:	e8 25 a7 ff ff       	call   801005a0 <panic>

  ilock(ip);
80105e7b:	83 ec 0c             	sub    $0xc,%esp
80105e7e:	ff 75 f0             	pushl  -0x10(%ebp)
80105e81:	e8 15 bc ff ff       	call   80101a9b <ilock>
80105e86:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e90:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e97:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e9b:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	ff 75 f0             	pushl  -0x10(%ebp)
80105eae:	e8 0b ba ff ff       	call   801018be <iupdate>
80105eb3:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105eb6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ebb:	75 6a                	jne    80105f27 <create+0x195>
    dp->nlink++;  // for ".."
80105ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ec4:	83 c0 01             	add    $0x1,%eax
80105ec7:	89 c2                	mov    %eax,%edx
80105ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecc:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ed0:	83 ec 0c             	sub    $0xc,%esp
80105ed3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ed6:	e8 e3 b9 ff ff       	call   801018be <iupdate>
80105edb:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee1:	8b 40 04             	mov    0x4(%eax),%eax
80105ee4:	83 ec 04             	sub    $0x4,%esp
80105ee7:	50                   	push   %eax
80105ee8:	68 63 8a 10 80       	push   $0x80108a63
80105eed:	ff 75 f0             	pushl  -0x10(%ebp)
80105ef0:	e8 4b c4 ff ff       	call   80102340 <dirlink>
80105ef5:	83 c4 10             	add    $0x10,%esp
80105ef8:	85 c0                	test   %eax,%eax
80105efa:	78 1e                	js     80105f1a <create+0x188>
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	8b 40 04             	mov    0x4(%eax),%eax
80105f02:	83 ec 04             	sub    $0x4,%esp
80105f05:	50                   	push   %eax
80105f06:	68 65 8a 10 80       	push   $0x80108a65
80105f0b:	ff 75 f0             	pushl  -0x10(%ebp)
80105f0e:	e8 2d c4 ff ff       	call   80102340 <dirlink>
80105f13:	83 c4 10             	add    $0x10,%esp
80105f16:	85 c0                	test   %eax,%eax
80105f18:	79 0d                	jns    80105f27 <create+0x195>
      panic("create dots");
80105f1a:	83 ec 0c             	sub    $0xc,%esp
80105f1d:	68 98 8a 10 80       	push   $0x80108a98
80105f22:	e8 79 a6 ff ff       	call   801005a0 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2a:	8b 40 04             	mov    0x4(%eax),%eax
80105f2d:	83 ec 04             	sub    $0x4,%esp
80105f30:	50                   	push   %eax
80105f31:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f34:	50                   	push   %eax
80105f35:	ff 75 f4             	pushl  -0xc(%ebp)
80105f38:	e8 03 c4 ff ff       	call   80102340 <dirlink>
80105f3d:	83 c4 10             	add    $0x10,%esp
80105f40:	85 c0                	test   %eax,%eax
80105f42:	79 0d                	jns    80105f51 <create+0x1bf>
    panic("create: dirlink");
80105f44:	83 ec 0c             	sub    $0xc,%esp
80105f47:	68 a4 8a 10 80       	push   $0x80108aa4
80105f4c:	e8 4f a6 ff ff       	call   801005a0 <panic>

  iunlockput(dp);
80105f51:	83 ec 0c             	sub    $0xc,%esp
80105f54:	ff 75 f4             	pushl  -0xc(%ebp)
80105f57:	e8 70 bd ff ff       	call   80101ccc <iunlockput>
80105f5c:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f62:	c9                   	leave  
80105f63:	c3                   	ret    

80105f64 <sys_open>:

int
sys_open(void)
{
80105f64:	55                   	push   %ebp
80105f65:	89 e5                	mov    %esp,%ebp
80105f67:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f6a:	83 ec 08             	sub    $0x8,%esp
80105f6d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f70:	50                   	push   %eax
80105f71:	6a 00                	push   $0x0
80105f73:	e8 e8 f6 ff ff       	call   80105660 <argstr>
80105f78:	83 c4 10             	add    $0x10,%esp
80105f7b:	85 c0                	test   %eax,%eax
80105f7d:	78 15                	js     80105f94 <sys_open+0x30>
80105f7f:	83 ec 08             	sub    $0x8,%esp
80105f82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f85:	50                   	push   %eax
80105f86:	6a 01                	push   $0x1
80105f88:	e8 3e f6 ff ff       	call   801055cb <argint>
80105f8d:	83 c4 10             	add    $0x10,%esp
80105f90:	85 c0                	test   %eax,%eax
80105f92:	79 0a                	jns    80105f9e <sys_open+0x3a>
    return -1;
80105f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f99:	e9 61 01 00 00       	jmp    801060ff <sys_open+0x19b>

  begin_op();
80105f9e:	e8 1d d6 ff ff       	call   801035c0 <begin_op>

  if(omode & O_CREATE){
80105fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa6:	25 00 02 00 00       	and    $0x200,%eax
80105fab:	85 c0                	test   %eax,%eax
80105fad:	74 2a                	je     80105fd9 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105faf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fb2:	6a 00                	push   $0x0
80105fb4:	6a 00                	push   $0x0
80105fb6:	6a 02                	push   $0x2
80105fb8:	50                   	push   %eax
80105fb9:	e8 d4 fd ff ff       	call   80105d92 <create>
80105fbe:	83 c4 10             	add    $0x10,%esp
80105fc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc8:	75 75                	jne    8010603f <sys_open+0xdb>
      end_op();
80105fca:	e8 7d d6 ff ff       	call   8010364c <end_op>
      return -1;
80105fcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd4:	e9 26 01 00 00       	jmp    801060ff <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105fd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fdc:	83 ec 0c             	sub    $0xc,%esp
80105fdf:	50                   	push   %eax
80105fe0:	e8 f6 c5 ff ff       	call   801025db <namei>
80105fe5:	83 c4 10             	add    $0x10,%esp
80105fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105feb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fef:	75 0f                	jne    80106000 <sys_open+0x9c>
      end_op();
80105ff1:	e8 56 d6 ff ff       	call   8010364c <end_op>
      return -1;
80105ff6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ffb:	e9 ff 00 00 00       	jmp    801060ff <sys_open+0x19b>
    }
    ilock(ip);
80106000:	83 ec 0c             	sub    $0xc,%esp
80106003:	ff 75 f4             	pushl  -0xc(%ebp)
80106006:	e8 90 ba ff ff       	call   80101a9b <ilock>
8010600b:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010600e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106011:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106015:	66 83 f8 01          	cmp    $0x1,%ax
80106019:	75 24                	jne    8010603f <sys_open+0xdb>
8010601b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010601e:	85 c0                	test   %eax,%eax
80106020:	74 1d                	je     8010603f <sys_open+0xdb>
      iunlockput(ip);
80106022:	83 ec 0c             	sub    $0xc,%esp
80106025:	ff 75 f4             	pushl  -0xc(%ebp)
80106028:	e8 9f bc ff ff       	call   80101ccc <iunlockput>
8010602d:	83 c4 10             	add    $0x10,%esp
      end_op();
80106030:	e8 17 d6 ff ff       	call   8010364c <end_op>
      return -1;
80106035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603a:	e9 c0 00 00 00       	jmp    801060ff <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010603f:	e8 3a b0 ff ff       	call   8010107e <filealloc>
80106044:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106047:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010604b:	74 17                	je     80106064 <sys_open+0x100>
8010604d:	83 ec 0c             	sub    $0xc,%esp
80106050:	ff 75 f0             	pushl  -0x10(%ebp)
80106053:	e8 34 f7 ff ff       	call   8010578c <fdalloc>
80106058:	83 c4 10             	add    $0x10,%esp
8010605b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010605e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106062:	79 2e                	jns    80106092 <sys_open+0x12e>
    if(f)
80106064:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106068:	74 0e                	je     80106078 <sys_open+0x114>
      fileclose(f);
8010606a:	83 ec 0c             	sub    $0xc,%esp
8010606d:	ff 75 f0             	pushl  -0x10(%ebp)
80106070:	e8 c7 b0 ff ff       	call   8010113c <fileclose>
80106075:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106078:	83 ec 0c             	sub    $0xc,%esp
8010607b:	ff 75 f4             	pushl  -0xc(%ebp)
8010607e:	e8 49 bc ff ff       	call   80101ccc <iunlockput>
80106083:	83 c4 10             	add    $0x10,%esp
    end_op();
80106086:	e8 c1 d5 ff ff       	call   8010364c <end_op>
    return -1;
8010608b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106090:	eb 6d                	jmp    801060ff <sys_open+0x19b>
  }
  iunlock(ip);
80106092:	83 ec 0c             	sub    $0xc,%esp
80106095:	ff 75 f4             	pushl  -0xc(%ebp)
80106098:	e8 11 bb ff ff       	call   80101bae <iunlock>
8010609d:	83 c4 10             	add    $0x10,%esp
  end_op();
801060a0:	e8 a7 d5 ff ff       	call   8010364c <end_op>

  f->type = FD_INODE;
801060a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060b4:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ba:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060c4:	83 e0 01             	and    $0x1,%eax
801060c7:	85 c0                	test   %eax,%eax
801060c9:	0f 94 c0             	sete   %al
801060cc:	89 c2                	mov    %eax,%edx
801060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d7:	83 e0 01             	and    $0x1,%eax
801060da:	85 c0                	test   %eax,%eax
801060dc:	75 0a                	jne    801060e8 <sys_open+0x184>
801060de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e1:	83 e0 02             	and    $0x2,%eax
801060e4:	85 c0                	test   %eax,%eax
801060e6:	74 07                	je     801060ef <sys_open+0x18b>
801060e8:	b8 01 00 00 00       	mov    $0x1,%eax
801060ed:	eb 05                	jmp    801060f4 <sys_open+0x190>
801060ef:	b8 00 00 00 00       	mov    $0x0,%eax
801060f4:	89 c2                	mov    %eax,%edx
801060f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060ff:	c9                   	leave  
80106100:	c3                   	ret    

80106101 <sys_mkdir>:

int
sys_mkdir(void)
{
80106101:	55                   	push   %ebp
80106102:	89 e5                	mov    %esp,%ebp
80106104:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106107:	e8 b4 d4 ff ff       	call   801035c0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010610c:	83 ec 08             	sub    $0x8,%esp
8010610f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106112:	50                   	push   %eax
80106113:	6a 00                	push   $0x0
80106115:	e8 46 f5 ff ff       	call   80105660 <argstr>
8010611a:	83 c4 10             	add    $0x10,%esp
8010611d:	85 c0                	test   %eax,%eax
8010611f:	78 1b                	js     8010613c <sys_mkdir+0x3b>
80106121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106124:	6a 00                	push   $0x0
80106126:	6a 00                	push   $0x0
80106128:	6a 01                	push   $0x1
8010612a:	50                   	push   %eax
8010612b:	e8 62 fc ff ff       	call   80105d92 <create>
80106130:	83 c4 10             	add    $0x10,%esp
80106133:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106136:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010613a:	75 0c                	jne    80106148 <sys_mkdir+0x47>
    end_op();
8010613c:	e8 0b d5 ff ff       	call   8010364c <end_op>
    return -1;
80106141:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106146:	eb 18                	jmp    80106160 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106148:	83 ec 0c             	sub    $0xc,%esp
8010614b:	ff 75 f4             	pushl  -0xc(%ebp)
8010614e:	e8 79 bb ff ff       	call   80101ccc <iunlockput>
80106153:	83 c4 10             	add    $0x10,%esp
  end_op();
80106156:	e8 f1 d4 ff ff       	call   8010364c <end_op>
  return 0;
8010615b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106160:	c9                   	leave  
80106161:	c3                   	ret    

80106162 <sys_mknod>:

int
sys_mknod(void)
{
80106162:	55                   	push   %ebp
80106163:	89 e5                	mov    %esp,%ebp
80106165:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106168:	e8 53 d4 ff ff       	call   801035c0 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010616d:	83 ec 08             	sub    $0x8,%esp
80106170:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106173:	50                   	push   %eax
80106174:	6a 00                	push   $0x0
80106176:	e8 e5 f4 ff ff       	call   80105660 <argstr>
8010617b:	83 c4 10             	add    $0x10,%esp
8010617e:	85 c0                	test   %eax,%eax
80106180:	78 4f                	js     801061d1 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106182:	83 ec 08             	sub    $0x8,%esp
80106185:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106188:	50                   	push   %eax
80106189:	6a 01                	push   $0x1
8010618b:	e8 3b f4 ff ff       	call   801055cb <argint>
80106190:	83 c4 10             	add    $0x10,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106193:	85 c0                	test   %eax,%eax
80106195:	78 3a                	js     801061d1 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106197:	83 ec 08             	sub    $0x8,%esp
8010619a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010619d:	50                   	push   %eax
8010619e:	6a 02                	push   $0x2
801061a0:	e8 26 f4 ff ff       	call   801055cb <argint>
801061a5:	83 c4 10             	add    $0x10,%esp
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061a8:	85 c0                	test   %eax,%eax
801061aa:	78 25                	js     801061d1 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061af:	0f bf c8             	movswl %ax,%ecx
801061b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061b5:	0f bf d0             	movswl %ax,%edx
801061b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061bb:	51                   	push   %ecx
801061bc:	52                   	push   %edx
801061bd:	6a 03                	push   $0x3
801061bf:	50                   	push   %eax
801061c0:	e8 cd fb ff ff       	call   80105d92 <create>
801061c5:	83 c4 10             	add    $0x10,%esp
801061c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061cf:	75 0c                	jne    801061dd <sys_mknod+0x7b>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801061d1:	e8 76 d4 ff ff       	call   8010364c <end_op>
    return -1;
801061d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061db:	eb 18                	jmp    801061f5 <sys_mknod+0x93>
  }
  iunlockput(ip);
801061dd:	83 ec 0c             	sub    $0xc,%esp
801061e0:	ff 75 f4             	pushl  -0xc(%ebp)
801061e3:	e8 e4 ba ff ff       	call   80101ccc <iunlockput>
801061e8:	83 c4 10             	add    $0x10,%esp
  end_op();
801061eb:	e8 5c d4 ff ff       	call   8010364c <end_op>
  return 0;
801061f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f5:	c9                   	leave  
801061f6:	c3                   	ret    

801061f7 <sys_chdir>:

int
sys_chdir(void)
{
801061f7:	55                   	push   %ebp
801061f8:	89 e5                	mov    %esp,%ebp
801061fa:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801061fd:	e8 16 e1 ff ff       	call   80104318 <myproc>
80106202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106205:	e8 b6 d3 ff ff       	call   801035c0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010620a:	83 ec 08             	sub    $0x8,%esp
8010620d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106210:	50                   	push   %eax
80106211:	6a 00                	push   $0x0
80106213:	e8 48 f4 ff ff       	call   80105660 <argstr>
80106218:	83 c4 10             	add    $0x10,%esp
8010621b:	85 c0                	test   %eax,%eax
8010621d:	78 18                	js     80106237 <sys_chdir+0x40>
8010621f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106222:	83 ec 0c             	sub    $0xc,%esp
80106225:	50                   	push   %eax
80106226:	e8 b0 c3 ff ff       	call   801025db <namei>
8010622b:	83 c4 10             	add    $0x10,%esp
8010622e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106231:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106235:	75 0c                	jne    80106243 <sys_chdir+0x4c>
    end_op();
80106237:	e8 10 d4 ff ff       	call   8010364c <end_op>
    return -1;
8010623c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106241:	eb 68                	jmp    801062ab <sys_chdir+0xb4>
  }
  ilock(ip);
80106243:	83 ec 0c             	sub    $0xc,%esp
80106246:	ff 75 f0             	pushl  -0x10(%ebp)
80106249:	e8 4d b8 ff ff       	call   80101a9b <ilock>
8010624e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106258:	66 83 f8 01          	cmp    $0x1,%ax
8010625c:	74 1a                	je     80106278 <sys_chdir+0x81>
    iunlockput(ip);
8010625e:	83 ec 0c             	sub    $0xc,%esp
80106261:	ff 75 f0             	pushl  -0x10(%ebp)
80106264:	e8 63 ba ff ff       	call   80101ccc <iunlockput>
80106269:	83 c4 10             	add    $0x10,%esp
    end_op();
8010626c:	e8 db d3 ff ff       	call   8010364c <end_op>
    return -1;
80106271:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106276:	eb 33                	jmp    801062ab <sys_chdir+0xb4>
  }
  iunlock(ip);
80106278:	83 ec 0c             	sub    $0xc,%esp
8010627b:	ff 75 f0             	pushl  -0x10(%ebp)
8010627e:	e8 2b b9 ff ff       	call   80101bae <iunlock>
80106283:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106289:	8b 40 68             	mov    0x68(%eax),%eax
8010628c:	83 ec 0c             	sub    $0xc,%esp
8010628f:	50                   	push   %eax
80106290:	e8 67 b9 ff ff       	call   80101bfc <iput>
80106295:	83 c4 10             	add    $0x10,%esp
  end_op();
80106298:	e8 af d3 ff ff       	call   8010364c <end_op>
  curproc->cwd = ip;
8010629d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062a3:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ab:	c9                   	leave  
801062ac:	c3                   	ret    

801062ad <sys_exec>:

int
sys_exec(void)
{
801062ad:	55                   	push   %ebp
801062ae:	89 e5                	mov    %esp,%ebp
801062b0:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062b6:	83 ec 08             	sub    $0x8,%esp
801062b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062bc:	50                   	push   %eax
801062bd:	6a 00                	push   $0x0
801062bf:	e8 9c f3 ff ff       	call   80105660 <argstr>
801062c4:	83 c4 10             	add    $0x10,%esp
801062c7:	85 c0                	test   %eax,%eax
801062c9:	78 18                	js     801062e3 <sys_exec+0x36>
801062cb:	83 ec 08             	sub    $0x8,%esp
801062ce:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062d4:	50                   	push   %eax
801062d5:	6a 01                	push   $0x1
801062d7:	e8 ef f2 ff ff       	call   801055cb <argint>
801062dc:	83 c4 10             	add    $0x10,%esp
801062df:	85 c0                	test   %eax,%eax
801062e1:	79 0a                	jns    801062ed <sys_exec+0x40>
    return -1;
801062e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e8:	e9 c6 00 00 00       	jmp    801063b3 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801062ed:	83 ec 04             	sub    $0x4,%esp
801062f0:	68 80 00 00 00       	push   $0x80
801062f5:	6a 00                	push   $0x0
801062f7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062fd:	50                   	push   %eax
801062fe:	e8 9c ef ff ff       	call   8010529f <memset>
80106303:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010630d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106310:	83 f8 1f             	cmp    $0x1f,%eax
80106313:	76 0a                	jbe    8010631f <sys_exec+0x72>
      return -1;
80106315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631a:	e9 94 00 00 00       	jmp    801063b3 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	c1 e0 02             	shl    $0x2,%eax
80106325:	89 c2                	mov    %eax,%edx
80106327:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010632d:	01 c2                	add    %eax,%edx
8010632f:	83 ec 08             	sub    $0x8,%esp
80106332:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106338:	50                   	push   %eax
80106339:	52                   	push   %edx
8010633a:	e8 e9 f1 ff ff       	call   80105528 <fetchint>
8010633f:	83 c4 10             	add    $0x10,%esp
80106342:	85 c0                	test   %eax,%eax
80106344:	79 07                	jns    8010634d <sys_exec+0xa0>
      return -1;
80106346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634b:	eb 66                	jmp    801063b3 <sys_exec+0x106>
    if(uarg == 0){
8010634d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106353:	85 c0                	test   %eax,%eax
80106355:	75 27                	jne    8010637e <sys_exec+0xd1>
      argv[i] = 0;
80106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106361:	00 00 00 00 
      break;
80106365:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106369:	83 ec 08             	sub    $0x8,%esp
8010636c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106372:	52                   	push   %edx
80106373:	50                   	push   %eax
80106374:	e8 1d a8 ff ff       	call   80100b96 <exec>
80106379:	83 c4 10             	add    $0x10,%esp
8010637c:	eb 35                	jmp    801063b3 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010637e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106384:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106387:	c1 e2 02             	shl    $0x2,%edx
8010638a:	01 c2                	add    %eax,%edx
8010638c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106392:	83 ec 08             	sub    $0x8,%esp
80106395:	52                   	push   %edx
80106396:	50                   	push   %eax
80106397:	e8 cb f1 ff ff       	call   80105567 <fetchstr>
8010639c:	83 c4 10             	add    $0x10,%esp
8010639f:	85 c0                	test   %eax,%eax
801063a1:	79 07                	jns    801063aa <sys_exec+0xfd>
      return -1;
801063a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a8:	eb 09                	jmp    801063b3 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063ae:	e9 5a ff ff ff       	jmp    8010630d <sys_exec+0x60>
  return exec(path, argv);
}
801063b3:	c9                   	leave  
801063b4:	c3                   	ret    

801063b5 <sys_pipe>:

int
sys_pipe(void)
{
801063b5:	55                   	push   %ebp
801063b6:	89 e5                	mov    %esp,%ebp
801063b8:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063bb:	83 ec 04             	sub    $0x4,%esp
801063be:	6a 08                	push   $0x8
801063c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063c3:	50                   	push   %eax
801063c4:	6a 00                	push   $0x0
801063c6:	e8 2d f2 ff ff       	call   801055f8 <argptr>
801063cb:	83 c4 10             	add    $0x10,%esp
801063ce:	85 c0                	test   %eax,%eax
801063d0:	79 0a                	jns    801063dc <sys_pipe+0x27>
    return -1;
801063d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d7:	e9 b0 00 00 00       	jmp    8010648c <sys_pipe+0xd7>
  if(pipealloc(&rf, &wf) < 0)
801063dc:	83 ec 08             	sub    $0x8,%esp
801063df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063e2:	50                   	push   %eax
801063e3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063e6:	50                   	push   %eax
801063e7:	e8 63 da ff ff       	call   80103e4f <pipealloc>
801063ec:	83 c4 10             	add    $0x10,%esp
801063ef:	85 c0                	test   %eax,%eax
801063f1:	79 0a                	jns    801063fd <sys_pipe+0x48>
    return -1;
801063f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f8:	e9 8f 00 00 00       	jmp    8010648c <sys_pipe+0xd7>
  fd0 = -1;
801063fd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106404:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106407:	83 ec 0c             	sub    $0xc,%esp
8010640a:	50                   	push   %eax
8010640b:	e8 7c f3 ff ff       	call   8010578c <fdalloc>
80106410:	83 c4 10             	add    $0x10,%esp
80106413:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106416:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010641a:	78 18                	js     80106434 <sys_pipe+0x7f>
8010641c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010641f:	83 ec 0c             	sub    $0xc,%esp
80106422:	50                   	push   %eax
80106423:	e8 64 f3 ff ff       	call   8010578c <fdalloc>
80106428:	83 c4 10             	add    $0x10,%esp
8010642b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010642e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106432:	79 40                	jns    80106474 <sys_pipe+0xbf>
    if(fd0 >= 0)
80106434:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106438:	78 15                	js     8010644f <sys_pipe+0x9a>
      myproc()->ofile[fd0] = 0;
8010643a:	e8 d9 de ff ff       	call   80104318 <myproc>
8010643f:	89 c2                	mov    %eax,%edx
80106441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106444:	83 c0 08             	add    $0x8,%eax
80106447:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
8010644e:	00 
    fileclose(rf);
8010644f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106452:	83 ec 0c             	sub    $0xc,%esp
80106455:	50                   	push   %eax
80106456:	e8 e1 ac ff ff       	call   8010113c <fileclose>
8010645b:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010645e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106461:	83 ec 0c             	sub    $0xc,%esp
80106464:	50                   	push   %eax
80106465:	e8 d2 ac ff ff       	call   8010113c <fileclose>
8010646a:	83 c4 10             	add    $0x10,%esp
    return -1;
8010646d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106472:	eb 18                	jmp    8010648c <sys_pipe+0xd7>
  }
  fd[0] = fd0;
80106474:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106477:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010647a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010647c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010647f:	8d 50 04             	lea    0x4(%eax),%edx
80106482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106485:	89 02                	mov    %eax,(%edx)
  return 0;
80106487:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010648c:	c9                   	leave  
8010648d:	c3                   	ret    

8010648e <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
8010648e:	55                   	push   %ebp
8010648f:	89 e5                	mov    %esp,%ebp
80106491:	83 ec 18             	sub    $0x18,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
80106494:	83 ec 08             	sub    $0x8,%esp
80106497:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010649a:	50                   	push   %eax
8010649b:	6a 00                	push   $0x0
8010649d:	e8 29 f1 ff ff       	call   801055cb <argint>
801064a2:	83 c4 10             	add    $0x10,%esp
801064a5:	85 c0                	test   %eax,%eax
801064a7:	79 07                	jns    801064b0 <sys_shm_open+0x22>
    return -1;
801064a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ae:	eb 31                	jmp    801064e1 <sys_shm_open+0x53>

  if(argptr(1, (char **) (&pointer),4)<0)
801064b0:	83 ec 04             	sub    $0x4,%esp
801064b3:	6a 04                	push   $0x4
801064b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b8:	50                   	push   %eax
801064b9:	6a 01                	push   $0x1
801064bb:	e8 38 f1 ff ff       	call   801055f8 <argptr>
801064c0:	83 c4 10             	add    $0x10,%esp
801064c3:	85 c0                	test   %eax,%eax
801064c5:	79 07                	jns    801064ce <sys_shm_open+0x40>
    return -1;
801064c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cc:	eb 13                	jmp    801064e1 <sys_shm_open+0x53>
  return shm_open(id, pointer);
801064ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d4:	83 ec 08             	sub    $0x8,%esp
801064d7:	52                   	push   %edx
801064d8:	50                   	push   %eax
801064d9:	e8 8d 20 00 00       	call   8010856b <shm_open>
801064de:	83 c4 10             	add    $0x10,%esp
}
801064e1:	c9                   	leave  
801064e2:	c3                   	ret    

801064e3 <sys_shm_close>:

int sys_shm_close(void) {
801064e3:	55                   	push   %ebp
801064e4:	89 e5                	mov    %esp,%ebp
801064e6:	83 ec 18             	sub    $0x18,%esp
  int id;

  if(argint(0, &id) < 0)
801064e9:	83 ec 08             	sub    $0x8,%esp
801064ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064ef:	50                   	push   %eax
801064f0:	6a 00                	push   $0x0
801064f2:	e8 d4 f0 ff ff       	call   801055cb <argint>
801064f7:	83 c4 10             	add    $0x10,%esp
801064fa:	85 c0                	test   %eax,%eax
801064fc:	79 07                	jns    80106505 <sys_shm_close+0x22>
    return -1;
801064fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106503:	eb 0f                	jmp    80106514 <sys_shm_close+0x31>

  
  return shm_close(id);
80106505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106508:	83 ec 0c             	sub    $0xc,%esp
8010650b:	50                   	push   %eax
8010650c:	e8 64 20 00 00       	call   80108575 <shm_close>
80106511:	83 c4 10             	add    $0x10,%esp
}
80106514:	c9                   	leave  
80106515:	c3                   	ret    

80106516 <sys_fork>:

int
sys_fork(void)
{
80106516:	55                   	push   %ebp
80106517:	89 e5                	mov    %esp,%ebp
80106519:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010651c:	e8 ff e0 ff ff       	call   80104620 <fork>
}
80106521:	c9                   	leave  
80106522:	c3                   	ret    

80106523 <sys_exit>:

int
sys_exit(void)
{
80106523:	55                   	push   %ebp
80106524:	89 e5                	mov    %esp,%ebp
80106526:	83 ec 08             	sub    $0x8,%esp
  exit();
80106529:	e8 9c e2 ff ff       	call   801047ca <exit>
  return 0;  // not reached
8010652e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106533:	c9                   	leave  
80106534:	c3                   	ret    

80106535 <sys_wait>:

int
sys_wait(void)
{
80106535:	55                   	push   %ebp
80106536:	89 e5                	mov    %esp,%ebp
80106538:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010653b:	e8 ad e3 ff ff       	call   801048ed <wait>
}
80106540:	c9                   	leave  
80106541:	c3                   	ret    

80106542 <sys_kill>:

int
sys_kill(void)
{
80106542:	55                   	push   %ebp
80106543:	89 e5                	mov    %esp,%ebp
80106545:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106548:	83 ec 08             	sub    $0x8,%esp
8010654b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010654e:	50                   	push   %eax
8010654f:	6a 00                	push   $0x0
80106551:	e8 75 f0 ff ff       	call   801055cb <argint>
80106556:	83 c4 10             	add    $0x10,%esp
80106559:	85 c0                	test   %eax,%eax
8010655b:	79 07                	jns    80106564 <sys_kill+0x22>
    return -1;
8010655d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106562:	eb 0f                	jmp    80106573 <sys_kill+0x31>
  return kill(pid);
80106564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106567:	83 ec 0c             	sub    $0xc,%esp
8010656a:	50                   	push   %eax
8010656b:	e8 b6 e7 ff ff       	call   80104d26 <kill>
80106570:	83 c4 10             	add    $0x10,%esp
}
80106573:	c9                   	leave  
80106574:	c3                   	ret    

80106575 <sys_getpid>:

int
sys_getpid(void)
{
80106575:	55                   	push   %ebp
80106576:	89 e5                	mov    %esp,%ebp
80106578:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010657b:	e8 98 dd ff ff       	call   80104318 <myproc>
80106580:	8b 40 10             	mov    0x10(%eax),%eax
}
80106583:	c9                   	leave  
80106584:	c3                   	ret    

80106585 <sys_sbrk>:

int
sys_sbrk(void)
{
80106585:	55                   	push   %ebp
80106586:	89 e5                	mov    %esp,%ebp
80106588:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010658b:	83 ec 08             	sub    $0x8,%esp
8010658e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106591:	50                   	push   %eax
80106592:	6a 00                	push   $0x0
80106594:	e8 32 f0 ff ff       	call   801055cb <argint>
80106599:	83 c4 10             	add    $0x10,%esp
8010659c:	85 c0                	test   %eax,%eax
8010659e:	79 07                	jns    801065a7 <sys_sbrk+0x22>
    return -1;
801065a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a5:	eb 27                	jmp    801065ce <sys_sbrk+0x49>
  addr = myproc()->sz;
801065a7:	e8 6c dd ff ff       	call   80104318 <myproc>
801065ac:	8b 00                	mov    (%eax),%eax
801065ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b4:	83 ec 0c             	sub    $0xc,%esp
801065b7:	50                   	push   %eax
801065b8:	e8 c8 df ff ff       	call   80104585 <growproc>
801065bd:	83 c4 10             	add    $0x10,%esp
801065c0:	85 c0                	test   %eax,%eax
801065c2:	79 07                	jns    801065cb <sys_sbrk+0x46>
    return -1;
801065c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c9:	eb 03                	jmp    801065ce <sys_sbrk+0x49>
  return addr;
801065cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065ce:	c9                   	leave  
801065cf:	c3                   	ret    

801065d0 <sys_sleep>:

int
sys_sleep(void)
{
801065d0:	55                   	push   %ebp
801065d1:	89 e5                	mov    %esp,%ebp
801065d3:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801065d6:	83 ec 08             	sub    $0x8,%esp
801065d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065dc:	50                   	push   %eax
801065dd:	6a 00                	push   $0x0
801065df:	e8 e7 ef ff ff       	call   801055cb <argint>
801065e4:	83 c4 10             	add    $0x10,%esp
801065e7:	85 c0                	test   %eax,%eax
801065e9:	79 07                	jns    801065f2 <sys_sleep+0x22>
    return -1;
801065eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f0:	eb 76                	jmp    80106668 <sys_sleep+0x98>
  acquire(&tickslock);
801065f2:	83 ec 0c             	sub    $0xc,%esp
801065f5:	68 e0 5e 11 80       	push   $0x80115ee0
801065fa:	e8 29 ea ff ff       	call   80105028 <acquire>
801065ff:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106602:	a1 20 67 11 80       	mov    0x80116720,%eax
80106607:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010660a:	eb 38                	jmp    80106644 <sys_sleep+0x74>
    if(myproc()->killed){
8010660c:	e8 07 dd ff ff       	call   80104318 <myproc>
80106611:	8b 40 24             	mov    0x24(%eax),%eax
80106614:	85 c0                	test   %eax,%eax
80106616:	74 17                	je     8010662f <sys_sleep+0x5f>
      release(&tickslock);
80106618:	83 ec 0c             	sub    $0xc,%esp
8010661b:	68 e0 5e 11 80       	push   $0x80115ee0
80106620:	e8 71 ea ff ff       	call   80105096 <release>
80106625:	83 c4 10             	add    $0x10,%esp
      return -1;
80106628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662d:	eb 39                	jmp    80106668 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
8010662f:	83 ec 08             	sub    $0x8,%esp
80106632:	68 e0 5e 11 80       	push   $0x80115ee0
80106637:	68 20 67 11 80       	push   $0x80116720
8010663c:	e8 c5 e5 ff ff       	call   80104c06 <sleep>
80106641:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106644:	a1 20 67 11 80       	mov    0x80116720,%eax
80106649:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010664c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010664f:	39 d0                	cmp    %edx,%eax
80106651:	72 b9                	jb     8010660c <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106653:	83 ec 0c             	sub    $0xc,%esp
80106656:	68 e0 5e 11 80       	push   $0x80115ee0
8010665b:	e8 36 ea ff ff       	call   80105096 <release>
80106660:	83 c4 10             	add    $0x10,%esp
  return 0;
80106663:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106668:	c9                   	leave  
80106669:	c3                   	ret    

8010666a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010666a:	55                   	push   %ebp
8010666b:	89 e5                	mov    %esp,%ebp
8010666d:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106670:	83 ec 0c             	sub    $0xc,%esp
80106673:	68 e0 5e 11 80       	push   $0x80115ee0
80106678:	e8 ab e9 ff ff       	call   80105028 <acquire>
8010667d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106680:	a1 20 67 11 80       	mov    0x80116720,%eax
80106685:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106688:	83 ec 0c             	sub    $0xc,%esp
8010668b:	68 e0 5e 11 80       	push   $0x80115ee0
80106690:	e8 01 ea ff ff       	call   80105096 <release>
80106695:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106698:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010669b:	c9                   	leave  
8010669c:	c3                   	ret    

8010669d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010669d:	1e                   	push   %ds
  pushl %es
8010669e:	06                   	push   %es
  pushl %fs
8010669f:	0f a0                	push   %fs
  pushl %gs
801066a1:	0f a8                	push   %gs
  pushal
801066a3:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801066a4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066a8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066aa:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801066ac:	54                   	push   %esp
  call trap
801066ad:	e8 d7 01 00 00       	call   80106889 <trap>
  addl $4, %esp
801066b2:	83 c4 04             	add    $0x4,%esp

801066b5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801066b5:	61                   	popa   
  popl %gs
801066b6:	0f a9                	pop    %gs
  popl %fs
801066b8:	0f a1                	pop    %fs
  popl %es
801066ba:	07                   	pop    %es
  popl %ds
801066bb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066bc:	83 c4 08             	add    $0x8,%esp
  iret
801066bf:	cf                   	iret   

801066c0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801066c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801066c9:	83 e8 01             	sub    $0x1,%eax
801066cc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066d0:	8b 45 08             	mov    0x8(%ebp),%eax
801066d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066d7:	8b 45 08             	mov    0x8(%ebp),%eax
801066da:	c1 e8 10             	shr    $0x10,%eax
801066dd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801066e1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066e4:	0f 01 18             	lidtl  (%eax)
}
801066e7:	90                   	nop
801066e8:	c9                   	leave  
801066e9:	c3                   	ret    

801066ea <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801066ea:	55                   	push   %ebp
801066eb:	89 e5                	mov    %esp,%ebp
801066ed:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066f0:	0f 20 d0             	mov    %cr2,%eax
801066f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066f9:	c9                   	leave  
801066fa:	c3                   	ret    

801066fb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066fb:	55                   	push   %ebp
801066fc:	89 e5                	mov    %esp,%ebp
801066fe:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106708:	e9 c3 00 00 00       	jmp    801067d0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010670d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106710:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106717:	89 c2                	mov    %eax,%edx
80106719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671c:	66 89 14 c5 20 5f 11 	mov    %dx,-0x7feea0e0(,%eax,8)
80106723:	80 
80106724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106727:	66 c7 04 c5 22 5f 11 	movw   $0x8,-0x7feea0de(,%eax,8)
8010672e:	80 08 00 
80106731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106734:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
8010673b:	80 
8010673c:	83 e2 e0             	and    $0xffffffe0,%edx
8010673f:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
80106746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106749:	0f b6 14 c5 24 5f 11 	movzbl -0x7feea0dc(,%eax,8),%edx
80106750:	80 
80106751:	83 e2 1f             	and    $0x1f,%edx
80106754:	88 14 c5 24 5f 11 80 	mov    %dl,-0x7feea0dc(,%eax,8)
8010675b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675e:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106765:	80 
80106766:	83 e2 f0             	and    $0xfffffff0,%edx
80106769:	83 ca 0e             	or     $0xe,%edx
8010676c:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
80106773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106776:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
8010677d:	80 
8010677e:	83 e2 ef             	and    $0xffffffef,%edx
80106781:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
80106788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678b:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
80106792:	80 
80106793:	83 e2 9f             	and    $0xffffff9f,%edx
80106796:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
8010679d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a0:	0f b6 14 c5 25 5f 11 	movzbl -0x7feea0db(,%eax,8),%edx
801067a7:	80 
801067a8:	83 ca 80             	or     $0xffffff80,%edx
801067ab:	88 14 c5 25 5f 11 80 	mov    %dl,-0x7feea0db(,%eax,8)
801067b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b5:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801067bc:	c1 e8 10             	shr    $0x10,%eax
801067bf:	89 c2                	mov    %eax,%edx
801067c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c4:	66 89 14 c5 26 5f 11 	mov    %dx,-0x7feea0da(,%eax,8)
801067cb:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801067cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067d0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067d7:	0f 8e 30 ff ff ff    	jle    8010670d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067dd:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801067e2:	66 a3 20 61 11 80    	mov    %ax,0x80116120
801067e8:	66 c7 05 22 61 11 80 	movw   $0x8,0x80116122
801067ef:	08 00 
801067f1:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
801067f8:	83 e0 e0             	and    $0xffffffe0,%eax
801067fb:	a2 24 61 11 80       	mov    %al,0x80116124
80106800:	0f b6 05 24 61 11 80 	movzbl 0x80116124,%eax
80106807:	83 e0 1f             	and    $0x1f,%eax
8010680a:	a2 24 61 11 80       	mov    %al,0x80116124
8010680f:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106816:	83 c8 0f             	or     $0xf,%eax
80106819:	a2 25 61 11 80       	mov    %al,0x80116125
8010681e:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106825:	83 e0 ef             	and    $0xffffffef,%eax
80106828:	a2 25 61 11 80       	mov    %al,0x80116125
8010682d:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106834:	83 c8 60             	or     $0x60,%eax
80106837:	a2 25 61 11 80       	mov    %al,0x80116125
8010683c:	0f b6 05 25 61 11 80 	movzbl 0x80116125,%eax
80106843:	83 c8 80             	or     $0xffffff80,%eax
80106846:	a2 25 61 11 80       	mov    %al,0x80116125
8010684b:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106850:	c1 e8 10             	shr    $0x10,%eax
80106853:	66 a3 26 61 11 80    	mov    %ax,0x80116126

  initlock(&tickslock, "time");
80106859:	83 ec 08             	sub    $0x8,%esp
8010685c:	68 b4 8a 10 80       	push   $0x80108ab4
80106861:	68 e0 5e 11 80       	push   $0x80115ee0
80106866:	e8 9b e7 ff ff       	call   80105006 <initlock>
8010686b:	83 c4 10             	add    $0x10,%esp
}
8010686e:	90                   	nop
8010686f:	c9                   	leave  
80106870:	c3                   	ret    

80106871 <idtinit>:

void
idtinit(void)
{
80106871:	55                   	push   %ebp
80106872:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106874:	68 00 08 00 00       	push   $0x800
80106879:	68 20 5f 11 80       	push   $0x80115f20
8010687e:	e8 3d fe ff ff       	call   801066c0 <lidt>
80106883:	83 c4 08             	add    $0x8,%esp
}
80106886:	90                   	nop
80106887:	c9                   	leave  
80106888:	c3                   	ret    

80106889 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106889:	55                   	push   %ebp
8010688a:	89 e5                	mov    %esp,%ebp
8010688c:	57                   	push   %edi
8010688d:	56                   	push   %esi
8010688e:	53                   	push   %ebx
8010688f:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106892:	8b 45 08             	mov    0x8(%ebp),%eax
80106895:	8b 40 30             	mov    0x30(%eax),%eax
80106898:	83 f8 40             	cmp    $0x40,%eax
8010689b:	75 3d                	jne    801068da <trap+0x51>
    if(myproc()->killed)
8010689d:	e8 76 da ff ff       	call   80104318 <myproc>
801068a2:	8b 40 24             	mov    0x24(%eax),%eax
801068a5:	85 c0                	test   %eax,%eax
801068a7:	74 05                	je     801068ae <trap+0x25>
      exit();
801068a9:	e8 1c df ff ff       	call   801047ca <exit>
    myproc()->tf = tf;
801068ae:	e8 65 da ff ff       	call   80104318 <myproc>
801068b3:	89 c2                	mov    %eax,%edx
801068b5:	8b 45 08             	mov    0x8(%ebp),%eax
801068b8:	89 42 18             	mov    %eax,0x18(%edx)
    syscall();
801068bb:	e8 d7 ed ff ff       	call   80105697 <syscall>
    if(myproc()->killed)
801068c0:	e8 53 da ff ff       	call   80104318 <myproc>
801068c5:	8b 40 24             	mov    0x24(%eax),%eax
801068c8:	85 c0                	test   %eax,%eax
801068ca:	0f 84 73 02 00 00    	je     80106b43 <trap+0x2ba>
      exit();
801068d0:	e8 f5 de ff ff       	call   801047ca <exit>
    return;
801068d5:	e9 69 02 00 00       	jmp    80106b43 <trap+0x2ba>
  }

  switch(tf->trapno){
801068da:	8b 45 08             	mov    0x8(%ebp),%eax
801068dd:	8b 40 30             	mov    0x30(%eax),%eax
801068e0:	83 e8 20             	sub    $0x20,%eax
801068e3:	83 f8 1f             	cmp    $0x1f,%eax
801068e6:	0f 87 b5 00 00 00    	ja     801069a1 <trap+0x118>
801068ec:	8b 04 85 6c 8b 10 80 	mov    -0x7fef7494(,%eax,4),%eax
801068f3:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801068f5:	e8 85 d9 ff ff       	call   8010427f <cpuid>
801068fa:	85 c0                	test   %eax,%eax
801068fc:	75 3d                	jne    8010693b <trap+0xb2>
      acquire(&tickslock);
801068fe:	83 ec 0c             	sub    $0xc,%esp
80106901:	68 e0 5e 11 80       	push   $0x80115ee0
80106906:	e8 1d e7 ff ff       	call   80105028 <acquire>
8010690b:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010690e:	a1 20 67 11 80       	mov    0x80116720,%eax
80106913:	83 c0 01             	add    $0x1,%eax
80106916:	a3 20 67 11 80       	mov    %eax,0x80116720
      wakeup(&ticks);
8010691b:	83 ec 0c             	sub    $0xc,%esp
8010691e:	68 20 67 11 80       	push   $0x80116720
80106923:	e8 c7 e3 ff ff       	call   80104cef <wakeup>
80106928:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010692b:	83 ec 0c             	sub    $0xc,%esp
8010692e:	68 e0 5e 11 80       	push   $0x80115ee0
80106933:	e8 5e e7 ff ff       	call   80105096 <release>
80106938:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010693b:	e8 58 c7 ff ff       	call   80103098 <lapiceoi>
    break;
80106940:	e9 7e 01 00 00       	jmp    80106ac3 <trap+0x23a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106945:	e8 c8 bf ff ff       	call   80102912 <ideintr>
    lapiceoi();
8010694a:	e8 49 c7 ff ff       	call   80103098 <lapiceoi>
    break;
8010694f:	e9 6f 01 00 00       	jmp    80106ac3 <trap+0x23a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106954:	e8 88 c5 ff ff       	call   80102ee1 <kbdintr>
    lapiceoi();
80106959:	e8 3a c7 ff ff       	call   80103098 <lapiceoi>
    break;
8010695e:	e9 60 01 00 00       	jmp    80106ac3 <trap+0x23a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106963:	e8 af 03 00 00       	call   80106d17 <uartintr>
    lapiceoi();
80106968:	e8 2b c7 ff ff       	call   80103098 <lapiceoi>
    break;
8010696d:	e9 51 01 00 00       	jmp    80106ac3 <trap+0x23a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106972:	8b 45 08             	mov    0x8(%ebp),%eax
80106975:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106978:	8b 45 08             	mov    0x8(%ebp),%eax
8010697b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010697f:	0f b7 d8             	movzwl %ax,%ebx
80106982:	e8 f8 d8 ff ff       	call   8010427f <cpuid>
80106987:	56                   	push   %esi
80106988:	53                   	push   %ebx
80106989:	50                   	push   %eax
8010698a:	68 bc 8a 10 80       	push   $0x80108abc
8010698f:	e8 6c 9a ff ff       	call   80100400 <cprintf>
80106994:	83 c4 10             	add    $0x10,%esp
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106997:	e8 fc c6 ff ff       	call   80103098 <lapiceoi>
    break;
8010699c:	e9 22 01 00 00       	jmp    80106ac3 <trap+0x23a>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801069a1:	e8 72 d9 ff ff       	call   80104318 <myproc>
801069a6:	85 c0                	test   %eax,%eax
801069a8:	74 11                	je     801069bb <trap+0x132>
801069aa:	8b 45 08             	mov    0x8(%ebp),%eax
801069ad:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069b1:	0f b7 c0             	movzwl %ax,%eax
801069b4:	83 e0 03             	and    $0x3,%eax
801069b7:	85 c0                	test   %eax,%eax
801069b9:	75 3b                	jne    801069f6 <trap+0x16d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069bb:	e8 2a fd ff ff       	call   801066ea <rcr2>
801069c0:	89 c6                	mov    %eax,%esi
801069c2:	8b 45 08             	mov    0x8(%ebp),%eax
801069c5:	8b 58 38             	mov    0x38(%eax),%ebx
801069c8:	e8 b2 d8 ff ff       	call   8010427f <cpuid>
801069cd:	89 c2                	mov    %eax,%edx
801069cf:	8b 45 08             	mov    0x8(%ebp),%eax
801069d2:	8b 40 30             	mov    0x30(%eax),%eax
801069d5:	83 ec 0c             	sub    $0xc,%esp
801069d8:	56                   	push   %esi
801069d9:	53                   	push   %ebx
801069da:	52                   	push   %edx
801069db:	50                   	push   %eax
801069dc:	68 e0 8a 10 80       	push   $0x80108ae0
801069e1:	e8 1a 9a ff ff       	call   80100400 <cprintf>
801069e6:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801069e9:	83 ec 0c             	sub    $0xc,%esp
801069ec:	68 12 8b 10 80       	push   $0x80108b12
801069f1:	e8 aa 9b ff ff       	call   801005a0 <panic>
    }
    if (tf->trapno == T_PGFLT)
801069f6:	8b 45 08             	mov    0x8(%ebp),%eax
801069f9:	8b 40 30             	mov    0x30(%eax),%eax
801069fc:	83 f8 0e             	cmp    $0xe,%eax
801069ff:	75 64                	jne    80106a65 <trap+0x1dc>
    {
//	if (myproc()->tf->esp < myproc()->last_page)
//	{
	    cprintf("DIFFERENCE: %d\n", myproc()->last_page - myproc()->tf->esp);
80106a01:	e8 12 d9 ff ff       	call   80104318 <myproc>
80106a06:	8b 58 7c             	mov    0x7c(%eax),%ebx
80106a09:	e8 0a d9 ff ff       	call   80104318 <myproc>
80106a0e:	8b 40 18             	mov    0x18(%eax),%eax
80106a11:	8b 40 44             	mov    0x44(%eax),%eax
80106a14:	29 c3                	sub    %eax,%ebx
80106a16:	89 d8                	mov    %ebx,%eax
80106a18:	83 ec 08             	sub    $0x8,%esp
80106a1b:	50                   	push   %eax
80106a1c:	68 17 8b 10 80       	push   $0x80108b17
80106a21:	e8 da 99 ff ff       	call   80100400 <cprintf>
80106a26:	83 c4 10             	add    $0x10,%esp
            myproc()->last_page = allocuvm(myproc()->pgdir, myproc()->last_page-2*PGSIZE, (myproc()->last_page-PGSIZE-4)); 
80106a29:	e8 ea d8 ff ff       	call   80104318 <myproc>
80106a2e:	89 c7                	mov    %eax,%edi
80106a30:	e8 e3 d8 ff ff       	call   80104318 <myproc>
80106a35:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a38:	8d b0 fc ef ff ff    	lea    -0x1004(%eax),%esi
80106a3e:	e8 d5 d8 ff ff       	call   80104318 <myproc>
80106a43:	8b 40 7c             	mov    0x7c(%eax),%eax
80106a46:	8d 98 00 e0 ff ff    	lea    -0x2000(%eax),%ebx
80106a4c:	e8 c7 d8 ff ff       	call   80104318 <myproc>
80106a51:	8b 40 04             	mov    0x4(%eax),%eax
80106a54:	83 ec 04             	sub    $0x4,%esp
80106a57:	56                   	push   %esi
80106a58:	53                   	push   %ebx
80106a59:	50                   	push   %eax
80106a5a:	e8 b1 15 00 00       	call   80108010 <allocuvm>
80106a5f:	83 c4 10             	add    $0x10,%esp
80106a62:	89 47 7c             	mov    %eax,0x7c(%edi)
//	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a65:	e8 80 fc ff ff       	call   801066ea <rcr2>
80106a6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a70:	8b 78 38             	mov    0x38(%eax),%edi
80106a73:	e8 07 d8 ff ff       	call   8010427f <cpuid>
80106a78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7e:	8b 70 34             	mov    0x34(%eax),%esi
80106a81:	8b 45 08             	mov    0x8(%ebp),%eax
80106a84:	8b 58 30             	mov    0x30(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106a87:	e8 8c d8 ff ff       	call   80104318 <myproc>
80106a8c:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106a8f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106a92:	e8 81 d8 ff ff       	call   80104318 <myproc>
	    cprintf("DIFFERENCE: %d\n", myproc()->last_page - myproc()->tf->esp);
            myproc()->last_page = allocuvm(myproc()->pgdir, myproc()->last_page-2*PGSIZE, (myproc()->last_page-PGSIZE-4)); 
//	}
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a97:	8b 40 10             	mov    0x10(%eax),%eax
80106a9a:	ff 75 e4             	pushl  -0x1c(%ebp)
80106a9d:	57                   	push   %edi
80106a9e:	ff 75 e0             	pushl  -0x20(%ebp)
80106aa1:	56                   	push   %esi
80106aa2:	53                   	push   %ebx
80106aa3:	ff 75 dc             	pushl  -0x24(%ebp)
80106aa6:	50                   	push   %eax
80106aa7:	68 28 8b 10 80       	push   $0x80108b28
80106aac:	e8 4f 99 ff ff       	call   80100400 <cprintf>
80106ab1:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106ab4:	e8 5f d8 ff ff       	call   80104318 <myproc>
80106ab9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ac0:	eb 01                	jmp    80106ac3 <trap+0x23a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106ac2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ac3:	e8 50 d8 ff ff       	call   80104318 <myproc>
80106ac8:	85 c0                	test   %eax,%eax
80106aca:	74 23                	je     80106aef <trap+0x266>
80106acc:	e8 47 d8 ff ff       	call   80104318 <myproc>
80106ad1:	8b 40 24             	mov    0x24(%eax),%eax
80106ad4:	85 c0                	test   %eax,%eax
80106ad6:	74 17                	je     80106aef <trap+0x266>
80106ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80106adb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106adf:	0f b7 c0             	movzwl %ax,%eax
80106ae2:	83 e0 03             	and    $0x3,%eax
80106ae5:	83 f8 03             	cmp    $0x3,%eax
80106ae8:	75 05                	jne    80106aef <trap+0x266>
    exit();
80106aea:	e8 db dc ff ff       	call   801047ca <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106aef:	e8 24 d8 ff ff       	call   80104318 <myproc>
80106af4:	85 c0                	test   %eax,%eax
80106af6:	74 1d                	je     80106b15 <trap+0x28c>
80106af8:	e8 1b d8 ff ff       	call   80104318 <myproc>
80106afd:	8b 40 0c             	mov    0xc(%eax),%eax
80106b00:	83 f8 04             	cmp    $0x4,%eax
80106b03:	75 10                	jne    80106b15 <trap+0x28c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106b05:	8b 45 08             	mov    0x8(%ebp),%eax
80106b08:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106b0b:	83 f8 20             	cmp    $0x20,%eax
80106b0e:	75 05                	jne    80106b15 <trap+0x28c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106b10:	e8 71 e0 ff ff       	call   80104b86 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106b15:	e8 fe d7 ff ff       	call   80104318 <myproc>
80106b1a:	85 c0                	test   %eax,%eax
80106b1c:	74 26                	je     80106b44 <trap+0x2bb>
80106b1e:	e8 f5 d7 ff ff       	call   80104318 <myproc>
80106b23:	8b 40 24             	mov    0x24(%eax),%eax
80106b26:	85 c0                	test   %eax,%eax
80106b28:	74 1a                	je     80106b44 <trap+0x2bb>
80106b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b31:	0f b7 c0             	movzwl %ax,%eax
80106b34:	83 e0 03             	and    $0x3,%eax
80106b37:	83 f8 03             	cmp    $0x3,%eax
80106b3a:	75 08                	jne    80106b44 <trap+0x2bb>
    exit();
80106b3c:	e8 89 dc ff ff       	call   801047ca <exit>
80106b41:	eb 01                	jmp    80106b44 <trap+0x2bb>
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
80106b43:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b47:	5b                   	pop    %ebx
80106b48:	5e                   	pop    %esi
80106b49:	5f                   	pop    %edi
80106b4a:	5d                   	pop    %ebp
80106b4b:	c3                   	ret    

80106b4c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b4c:	55                   	push   %ebp
80106b4d:	89 e5                	mov    %esp,%ebp
80106b4f:	83 ec 14             	sub    $0x14,%esp
80106b52:	8b 45 08             	mov    0x8(%ebp),%eax
80106b55:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b59:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b5d:	89 c2                	mov    %eax,%edx
80106b5f:	ec                   	in     (%dx),%al
80106b60:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b63:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b67:	c9                   	leave  
80106b68:	c3                   	ret    

80106b69 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b69:	55                   	push   %ebp
80106b6a:	89 e5                	mov    %esp,%ebp
80106b6c:	83 ec 08             	sub    $0x8,%esp
80106b6f:	8b 55 08             	mov    0x8(%ebp),%edx
80106b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b75:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b79:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b7c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b80:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b84:	ee                   	out    %al,(%dx)
}
80106b85:	90                   	nop
80106b86:	c9                   	leave  
80106b87:	c3                   	ret    

80106b88 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b88:	55                   	push   %ebp
80106b89:	89 e5                	mov    %esp,%ebp
80106b8b:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b8e:	6a 00                	push   $0x0
80106b90:	68 fa 03 00 00       	push   $0x3fa
80106b95:	e8 cf ff ff ff       	call   80106b69 <outb>
80106b9a:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b9d:	68 80 00 00 00       	push   $0x80
80106ba2:	68 fb 03 00 00       	push   $0x3fb
80106ba7:	e8 bd ff ff ff       	call   80106b69 <outb>
80106bac:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106baf:	6a 0c                	push   $0xc
80106bb1:	68 f8 03 00 00       	push   $0x3f8
80106bb6:	e8 ae ff ff ff       	call   80106b69 <outb>
80106bbb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106bbe:	6a 00                	push   $0x0
80106bc0:	68 f9 03 00 00       	push   $0x3f9
80106bc5:	e8 9f ff ff ff       	call   80106b69 <outb>
80106bca:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106bcd:	6a 03                	push   $0x3
80106bcf:	68 fb 03 00 00       	push   $0x3fb
80106bd4:	e8 90 ff ff ff       	call   80106b69 <outb>
80106bd9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106bdc:	6a 00                	push   $0x0
80106bde:	68 fc 03 00 00       	push   $0x3fc
80106be3:	e8 81 ff ff ff       	call   80106b69 <outb>
80106be8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106beb:	6a 01                	push   $0x1
80106bed:	68 f9 03 00 00       	push   $0x3f9
80106bf2:	e8 72 ff ff ff       	call   80106b69 <outb>
80106bf7:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bfa:	68 fd 03 00 00       	push   $0x3fd
80106bff:	e8 48 ff ff ff       	call   80106b4c <inb>
80106c04:	83 c4 04             	add    $0x4,%esp
80106c07:	3c ff                	cmp    $0xff,%al
80106c09:	74 61                	je     80106c6c <uartinit+0xe4>
    return;
  uart = 1;
80106c0b:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
80106c12:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c15:	68 fa 03 00 00       	push   $0x3fa
80106c1a:	e8 2d ff ff ff       	call   80106b4c <inb>
80106c1f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106c22:	68 f8 03 00 00       	push   $0x3f8
80106c27:	e8 20 ff ff ff       	call   80106b4c <inb>
80106c2c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106c2f:	83 ec 08             	sub    $0x8,%esp
80106c32:	6a 00                	push   $0x0
80106c34:	6a 04                	push   $0x4
80106c36:	e8 74 bf ff ff       	call   80102baf <ioapicenable>
80106c3b:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c3e:	c7 45 f4 ec 8b 10 80 	movl   $0x80108bec,-0xc(%ebp)
80106c45:	eb 19                	jmp    80106c60 <uartinit+0xd8>
    uartputc(*p);
80106c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c4a:	0f b6 00             	movzbl (%eax),%eax
80106c4d:	0f be c0             	movsbl %al,%eax
80106c50:	83 ec 0c             	sub    $0xc,%esp
80106c53:	50                   	push   %eax
80106c54:	e8 16 00 00 00       	call   80106c6f <uartputc>
80106c59:	83 c4 10             	add    $0x10,%esp
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c63:	0f b6 00             	movzbl (%eax),%eax
80106c66:	84 c0                	test   %al,%al
80106c68:	75 dd                	jne    80106c47 <uartinit+0xbf>
80106c6a:	eb 01                	jmp    80106c6d <uartinit+0xe5>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106c6c:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106c6d:	c9                   	leave  
80106c6e:	c3                   	ret    

80106c6f <uartputc>:

void
uartputc(int c)
{
80106c6f:	55                   	push   %ebp
80106c70:	89 e5                	mov    %esp,%ebp
80106c72:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c75:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106c7a:	85 c0                	test   %eax,%eax
80106c7c:	74 53                	je     80106cd1 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c85:	eb 11                	jmp    80106c98 <uartputc+0x29>
    microdelay(10);
80106c87:	83 ec 0c             	sub    $0xc,%esp
80106c8a:	6a 0a                	push   $0xa
80106c8c:	e8 22 c4 ff ff       	call   801030b3 <microdelay>
80106c91:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c98:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c9c:	7f 1a                	jg     80106cb8 <uartputc+0x49>
80106c9e:	83 ec 0c             	sub    $0xc,%esp
80106ca1:	68 fd 03 00 00       	push   $0x3fd
80106ca6:	e8 a1 fe ff ff       	call   80106b4c <inb>
80106cab:	83 c4 10             	add    $0x10,%esp
80106cae:	0f b6 c0             	movzbl %al,%eax
80106cb1:	83 e0 20             	and    $0x20,%eax
80106cb4:	85 c0                	test   %eax,%eax
80106cb6:	74 cf                	je     80106c87 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106cb8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cbb:	0f b6 c0             	movzbl %al,%eax
80106cbe:	83 ec 08             	sub    $0x8,%esp
80106cc1:	50                   	push   %eax
80106cc2:	68 f8 03 00 00       	push   $0x3f8
80106cc7:	e8 9d fe ff ff       	call   80106b69 <outb>
80106ccc:	83 c4 10             	add    $0x10,%esp
80106ccf:	eb 01                	jmp    80106cd2 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106cd1:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106cd2:	c9                   	leave  
80106cd3:	c3                   	ret    

80106cd4 <uartgetc>:

static int
uartgetc(void)
{
80106cd4:	55                   	push   %ebp
80106cd5:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106cd7:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106cdc:	85 c0                	test   %eax,%eax
80106cde:	75 07                	jne    80106ce7 <uartgetc+0x13>
    return -1;
80106ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce5:	eb 2e                	jmp    80106d15 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106ce7:	68 fd 03 00 00       	push   $0x3fd
80106cec:	e8 5b fe ff ff       	call   80106b4c <inb>
80106cf1:	83 c4 04             	add    $0x4,%esp
80106cf4:	0f b6 c0             	movzbl %al,%eax
80106cf7:	83 e0 01             	and    $0x1,%eax
80106cfa:	85 c0                	test   %eax,%eax
80106cfc:	75 07                	jne    80106d05 <uartgetc+0x31>
    return -1;
80106cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d03:	eb 10                	jmp    80106d15 <uartgetc+0x41>
  return inb(COM1+0);
80106d05:	68 f8 03 00 00       	push   $0x3f8
80106d0a:	e8 3d fe ff ff       	call   80106b4c <inb>
80106d0f:	83 c4 04             	add    $0x4,%esp
80106d12:	0f b6 c0             	movzbl %al,%eax
}
80106d15:	c9                   	leave  
80106d16:	c3                   	ret    

80106d17 <uartintr>:

void
uartintr(void)
{
80106d17:	55                   	push   %ebp
80106d18:	89 e5                	mov    %esp,%ebp
80106d1a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106d1d:	83 ec 0c             	sub    $0xc,%esp
80106d20:	68 d4 6c 10 80       	push   $0x80106cd4
80106d25:	e8 02 9b ff ff       	call   8010082c <consoleintr>
80106d2a:	83 c4 10             	add    $0x10,%esp
}
80106d2d:	90                   	nop
80106d2e:	c9                   	leave  
80106d2f:	c3                   	ret    

80106d30 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $0
80106d32:	6a 00                	push   $0x0
  jmp alltraps
80106d34:	e9 64 f9 ff ff       	jmp    8010669d <alltraps>

80106d39 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $1
80106d3b:	6a 01                	push   $0x1
  jmp alltraps
80106d3d:	e9 5b f9 ff ff       	jmp    8010669d <alltraps>

80106d42 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $2
80106d44:	6a 02                	push   $0x2
  jmp alltraps
80106d46:	e9 52 f9 ff ff       	jmp    8010669d <alltraps>

80106d4b <vector3>:
.globl vector3
vector3:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $3
80106d4d:	6a 03                	push   $0x3
  jmp alltraps
80106d4f:	e9 49 f9 ff ff       	jmp    8010669d <alltraps>

80106d54 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $4
80106d56:	6a 04                	push   $0x4
  jmp alltraps
80106d58:	e9 40 f9 ff ff       	jmp    8010669d <alltraps>

80106d5d <vector5>:
.globl vector5
vector5:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $5
80106d5f:	6a 05                	push   $0x5
  jmp alltraps
80106d61:	e9 37 f9 ff ff       	jmp    8010669d <alltraps>

80106d66 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $6
80106d68:	6a 06                	push   $0x6
  jmp alltraps
80106d6a:	e9 2e f9 ff ff       	jmp    8010669d <alltraps>

80106d6f <vector7>:
.globl vector7
vector7:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $7
80106d71:	6a 07                	push   $0x7
  jmp alltraps
80106d73:	e9 25 f9 ff ff       	jmp    8010669d <alltraps>

80106d78 <vector8>:
.globl vector8
vector8:
  pushl $8
80106d78:	6a 08                	push   $0x8
  jmp alltraps
80106d7a:	e9 1e f9 ff ff       	jmp    8010669d <alltraps>

80106d7f <vector9>:
.globl vector9
vector9:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $9
80106d81:	6a 09                	push   $0x9
  jmp alltraps
80106d83:	e9 15 f9 ff ff       	jmp    8010669d <alltraps>

80106d88 <vector10>:
.globl vector10
vector10:
  pushl $10
80106d88:	6a 0a                	push   $0xa
  jmp alltraps
80106d8a:	e9 0e f9 ff ff       	jmp    8010669d <alltraps>

80106d8f <vector11>:
.globl vector11
vector11:
  pushl $11
80106d8f:	6a 0b                	push   $0xb
  jmp alltraps
80106d91:	e9 07 f9 ff ff       	jmp    8010669d <alltraps>

80106d96 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d96:	6a 0c                	push   $0xc
  jmp alltraps
80106d98:	e9 00 f9 ff ff       	jmp    8010669d <alltraps>

80106d9d <vector13>:
.globl vector13
vector13:
  pushl $13
80106d9d:	6a 0d                	push   $0xd
  jmp alltraps
80106d9f:	e9 f9 f8 ff ff       	jmp    8010669d <alltraps>

80106da4 <vector14>:
.globl vector14
vector14:
  pushl $14
80106da4:	6a 0e                	push   $0xe
  jmp alltraps
80106da6:	e9 f2 f8 ff ff       	jmp    8010669d <alltraps>

80106dab <vector15>:
.globl vector15
vector15:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $15
80106dad:	6a 0f                	push   $0xf
  jmp alltraps
80106daf:	e9 e9 f8 ff ff       	jmp    8010669d <alltraps>

80106db4 <vector16>:
.globl vector16
vector16:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $16
80106db6:	6a 10                	push   $0x10
  jmp alltraps
80106db8:	e9 e0 f8 ff ff       	jmp    8010669d <alltraps>

80106dbd <vector17>:
.globl vector17
vector17:
  pushl $17
80106dbd:	6a 11                	push   $0x11
  jmp alltraps
80106dbf:	e9 d9 f8 ff ff       	jmp    8010669d <alltraps>

80106dc4 <vector18>:
.globl vector18
vector18:
  pushl $0
80106dc4:	6a 00                	push   $0x0
  pushl $18
80106dc6:	6a 12                	push   $0x12
  jmp alltraps
80106dc8:	e9 d0 f8 ff ff       	jmp    8010669d <alltraps>

80106dcd <vector19>:
.globl vector19
vector19:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $19
80106dcf:	6a 13                	push   $0x13
  jmp alltraps
80106dd1:	e9 c7 f8 ff ff       	jmp    8010669d <alltraps>

80106dd6 <vector20>:
.globl vector20
vector20:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $20
80106dd8:	6a 14                	push   $0x14
  jmp alltraps
80106dda:	e9 be f8 ff ff       	jmp    8010669d <alltraps>

80106ddf <vector21>:
.globl vector21
vector21:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $21
80106de1:	6a 15                	push   $0x15
  jmp alltraps
80106de3:	e9 b5 f8 ff ff       	jmp    8010669d <alltraps>

80106de8 <vector22>:
.globl vector22
vector22:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $22
80106dea:	6a 16                	push   $0x16
  jmp alltraps
80106dec:	e9 ac f8 ff ff       	jmp    8010669d <alltraps>

80106df1 <vector23>:
.globl vector23
vector23:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $23
80106df3:	6a 17                	push   $0x17
  jmp alltraps
80106df5:	e9 a3 f8 ff ff       	jmp    8010669d <alltraps>

80106dfa <vector24>:
.globl vector24
vector24:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $24
80106dfc:	6a 18                	push   $0x18
  jmp alltraps
80106dfe:	e9 9a f8 ff ff       	jmp    8010669d <alltraps>

80106e03 <vector25>:
.globl vector25
vector25:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $25
80106e05:	6a 19                	push   $0x19
  jmp alltraps
80106e07:	e9 91 f8 ff ff       	jmp    8010669d <alltraps>

80106e0c <vector26>:
.globl vector26
vector26:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $26
80106e0e:	6a 1a                	push   $0x1a
  jmp alltraps
80106e10:	e9 88 f8 ff ff       	jmp    8010669d <alltraps>

80106e15 <vector27>:
.globl vector27
vector27:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $27
80106e17:	6a 1b                	push   $0x1b
  jmp alltraps
80106e19:	e9 7f f8 ff ff       	jmp    8010669d <alltraps>

80106e1e <vector28>:
.globl vector28
vector28:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $28
80106e20:	6a 1c                	push   $0x1c
  jmp alltraps
80106e22:	e9 76 f8 ff ff       	jmp    8010669d <alltraps>

80106e27 <vector29>:
.globl vector29
vector29:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $29
80106e29:	6a 1d                	push   $0x1d
  jmp alltraps
80106e2b:	e9 6d f8 ff ff       	jmp    8010669d <alltraps>

80106e30 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e30:	6a 00                	push   $0x0
  pushl $30
80106e32:	6a 1e                	push   $0x1e
  jmp alltraps
80106e34:	e9 64 f8 ff ff       	jmp    8010669d <alltraps>

80106e39 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $31
80106e3b:	6a 1f                	push   $0x1f
  jmp alltraps
80106e3d:	e9 5b f8 ff ff       	jmp    8010669d <alltraps>

80106e42 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $32
80106e44:	6a 20                	push   $0x20
  jmp alltraps
80106e46:	e9 52 f8 ff ff       	jmp    8010669d <alltraps>

80106e4b <vector33>:
.globl vector33
vector33:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $33
80106e4d:	6a 21                	push   $0x21
  jmp alltraps
80106e4f:	e9 49 f8 ff ff       	jmp    8010669d <alltraps>

80106e54 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $34
80106e56:	6a 22                	push   $0x22
  jmp alltraps
80106e58:	e9 40 f8 ff ff       	jmp    8010669d <alltraps>

80106e5d <vector35>:
.globl vector35
vector35:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $35
80106e5f:	6a 23                	push   $0x23
  jmp alltraps
80106e61:	e9 37 f8 ff ff       	jmp    8010669d <alltraps>

80106e66 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $36
80106e68:	6a 24                	push   $0x24
  jmp alltraps
80106e6a:	e9 2e f8 ff ff       	jmp    8010669d <alltraps>

80106e6f <vector37>:
.globl vector37
vector37:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $37
80106e71:	6a 25                	push   $0x25
  jmp alltraps
80106e73:	e9 25 f8 ff ff       	jmp    8010669d <alltraps>

80106e78 <vector38>:
.globl vector38
vector38:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $38
80106e7a:	6a 26                	push   $0x26
  jmp alltraps
80106e7c:	e9 1c f8 ff ff       	jmp    8010669d <alltraps>

80106e81 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $39
80106e83:	6a 27                	push   $0x27
  jmp alltraps
80106e85:	e9 13 f8 ff ff       	jmp    8010669d <alltraps>

80106e8a <vector40>:
.globl vector40
vector40:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $40
80106e8c:	6a 28                	push   $0x28
  jmp alltraps
80106e8e:	e9 0a f8 ff ff       	jmp    8010669d <alltraps>

80106e93 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $41
80106e95:	6a 29                	push   $0x29
  jmp alltraps
80106e97:	e9 01 f8 ff ff       	jmp    8010669d <alltraps>

80106e9c <vector42>:
.globl vector42
vector42:
  pushl $0
80106e9c:	6a 00                	push   $0x0
  pushl $42
80106e9e:	6a 2a                	push   $0x2a
  jmp alltraps
80106ea0:	e9 f8 f7 ff ff       	jmp    8010669d <alltraps>

80106ea5 <vector43>:
.globl vector43
vector43:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $43
80106ea7:	6a 2b                	push   $0x2b
  jmp alltraps
80106ea9:	e9 ef f7 ff ff       	jmp    8010669d <alltraps>

80106eae <vector44>:
.globl vector44
vector44:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $44
80106eb0:	6a 2c                	push   $0x2c
  jmp alltraps
80106eb2:	e9 e6 f7 ff ff       	jmp    8010669d <alltraps>

80106eb7 <vector45>:
.globl vector45
vector45:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $45
80106eb9:	6a 2d                	push   $0x2d
  jmp alltraps
80106ebb:	e9 dd f7 ff ff       	jmp    8010669d <alltraps>

80106ec0 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ec0:	6a 00                	push   $0x0
  pushl $46
80106ec2:	6a 2e                	push   $0x2e
  jmp alltraps
80106ec4:	e9 d4 f7 ff ff       	jmp    8010669d <alltraps>

80106ec9 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $47
80106ecb:	6a 2f                	push   $0x2f
  jmp alltraps
80106ecd:	e9 cb f7 ff ff       	jmp    8010669d <alltraps>

80106ed2 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $48
80106ed4:	6a 30                	push   $0x30
  jmp alltraps
80106ed6:	e9 c2 f7 ff ff       	jmp    8010669d <alltraps>

80106edb <vector49>:
.globl vector49
vector49:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $49
80106edd:	6a 31                	push   $0x31
  jmp alltraps
80106edf:	e9 b9 f7 ff ff       	jmp    8010669d <alltraps>

80106ee4 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ee4:	6a 00                	push   $0x0
  pushl $50
80106ee6:	6a 32                	push   $0x32
  jmp alltraps
80106ee8:	e9 b0 f7 ff ff       	jmp    8010669d <alltraps>

80106eed <vector51>:
.globl vector51
vector51:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $51
80106eef:	6a 33                	push   $0x33
  jmp alltraps
80106ef1:	e9 a7 f7 ff ff       	jmp    8010669d <alltraps>

80106ef6 <vector52>:
.globl vector52
vector52:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $52
80106ef8:	6a 34                	push   $0x34
  jmp alltraps
80106efa:	e9 9e f7 ff ff       	jmp    8010669d <alltraps>

80106eff <vector53>:
.globl vector53
vector53:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $53
80106f01:	6a 35                	push   $0x35
  jmp alltraps
80106f03:	e9 95 f7 ff ff       	jmp    8010669d <alltraps>

80106f08 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f08:	6a 00                	push   $0x0
  pushl $54
80106f0a:	6a 36                	push   $0x36
  jmp alltraps
80106f0c:	e9 8c f7 ff ff       	jmp    8010669d <alltraps>

80106f11 <vector55>:
.globl vector55
vector55:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $55
80106f13:	6a 37                	push   $0x37
  jmp alltraps
80106f15:	e9 83 f7 ff ff       	jmp    8010669d <alltraps>

80106f1a <vector56>:
.globl vector56
vector56:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $56
80106f1c:	6a 38                	push   $0x38
  jmp alltraps
80106f1e:	e9 7a f7 ff ff       	jmp    8010669d <alltraps>

80106f23 <vector57>:
.globl vector57
vector57:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $57
80106f25:	6a 39                	push   $0x39
  jmp alltraps
80106f27:	e9 71 f7 ff ff       	jmp    8010669d <alltraps>

80106f2c <vector58>:
.globl vector58
vector58:
  pushl $0
80106f2c:	6a 00                	push   $0x0
  pushl $58
80106f2e:	6a 3a                	push   $0x3a
  jmp alltraps
80106f30:	e9 68 f7 ff ff       	jmp    8010669d <alltraps>

80106f35 <vector59>:
.globl vector59
vector59:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $59
80106f37:	6a 3b                	push   $0x3b
  jmp alltraps
80106f39:	e9 5f f7 ff ff       	jmp    8010669d <alltraps>

80106f3e <vector60>:
.globl vector60
vector60:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $60
80106f40:	6a 3c                	push   $0x3c
  jmp alltraps
80106f42:	e9 56 f7 ff ff       	jmp    8010669d <alltraps>

80106f47 <vector61>:
.globl vector61
vector61:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $61
80106f49:	6a 3d                	push   $0x3d
  jmp alltraps
80106f4b:	e9 4d f7 ff ff       	jmp    8010669d <alltraps>

80106f50 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $62
80106f52:	6a 3e                	push   $0x3e
  jmp alltraps
80106f54:	e9 44 f7 ff ff       	jmp    8010669d <alltraps>

80106f59 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $63
80106f5b:	6a 3f                	push   $0x3f
  jmp alltraps
80106f5d:	e9 3b f7 ff ff       	jmp    8010669d <alltraps>

80106f62 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $64
80106f64:	6a 40                	push   $0x40
  jmp alltraps
80106f66:	e9 32 f7 ff ff       	jmp    8010669d <alltraps>

80106f6b <vector65>:
.globl vector65
vector65:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $65
80106f6d:	6a 41                	push   $0x41
  jmp alltraps
80106f6f:	e9 29 f7 ff ff       	jmp    8010669d <alltraps>

80106f74 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $66
80106f76:	6a 42                	push   $0x42
  jmp alltraps
80106f78:	e9 20 f7 ff ff       	jmp    8010669d <alltraps>

80106f7d <vector67>:
.globl vector67
vector67:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $67
80106f7f:	6a 43                	push   $0x43
  jmp alltraps
80106f81:	e9 17 f7 ff ff       	jmp    8010669d <alltraps>

80106f86 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $68
80106f88:	6a 44                	push   $0x44
  jmp alltraps
80106f8a:	e9 0e f7 ff ff       	jmp    8010669d <alltraps>

80106f8f <vector69>:
.globl vector69
vector69:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $69
80106f91:	6a 45                	push   $0x45
  jmp alltraps
80106f93:	e9 05 f7 ff ff       	jmp    8010669d <alltraps>

80106f98 <vector70>:
.globl vector70
vector70:
  pushl $0
80106f98:	6a 00                	push   $0x0
  pushl $70
80106f9a:	6a 46                	push   $0x46
  jmp alltraps
80106f9c:	e9 fc f6 ff ff       	jmp    8010669d <alltraps>

80106fa1 <vector71>:
.globl vector71
vector71:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $71
80106fa3:	6a 47                	push   $0x47
  jmp alltraps
80106fa5:	e9 f3 f6 ff ff       	jmp    8010669d <alltraps>

80106faa <vector72>:
.globl vector72
vector72:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $72
80106fac:	6a 48                	push   $0x48
  jmp alltraps
80106fae:	e9 ea f6 ff ff       	jmp    8010669d <alltraps>

80106fb3 <vector73>:
.globl vector73
vector73:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $73
80106fb5:	6a 49                	push   $0x49
  jmp alltraps
80106fb7:	e9 e1 f6 ff ff       	jmp    8010669d <alltraps>

80106fbc <vector74>:
.globl vector74
vector74:
  pushl $0
80106fbc:	6a 00                	push   $0x0
  pushl $74
80106fbe:	6a 4a                	push   $0x4a
  jmp alltraps
80106fc0:	e9 d8 f6 ff ff       	jmp    8010669d <alltraps>

80106fc5 <vector75>:
.globl vector75
vector75:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $75
80106fc7:	6a 4b                	push   $0x4b
  jmp alltraps
80106fc9:	e9 cf f6 ff ff       	jmp    8010669d <alltraps>

80106fce <vector76>:
.globl vector76
vector76:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $76
80106fd0:	6a 4c                	push   $0x4c
  jmp alltraps
80106fd2:	e9 c6 f6 ff ff       	jmp    8010669d <alltraps>

80106fd7 <vector77>:
.globl vector77
vector77:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $77
80106fd9:	6a 4d                	push   $0x4d
  jmp alltraps
80106fdb:	e9 bd f6 ff ff       	jmp    8010669d <alltraps>

80106fe0 <vector78>:
.globl vector78
vector78:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $78
80106fe2:	6a 4e                	push   $0x4e
  jmp alltraps
80106fe4:	e9 b4 f6 ff ff       	jmp    8010669d <alltraps>

80106fe9 <vector79>:
.globl vector79
vector79:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $79
80106feb:	6a 4f                	push   $0x4f
  jmp alltraps
80106fed:	e9 ab f6 ff ff       	jmp    8010669d <alltraps>

80106ff2 <vector80>:
.globl vector80
vector80:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $80
80106ff4:	6a 50                	push   $0x50
  jmp alltraps
80106ff6:	e9 a2 f6 ff ff       	jmp    8010669d <alltraps>

80106ffb <vector81>:
.globl vector81
vector81:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $81
80106ffd:	6a 51                	push   $0x51
  jmp alltraps
80106fff:	e9 99 f6 ff ff       	jmp    8010669d <alltraps>

80107004 <vector82>:
.globl vector82
vector82:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $82
80107006:	6a 52                	push   $0x52
  jmp alltraps
80107008:	e9 90 f6 ff ff       	jmp    8010669d <alltraps>

8010700d <vector83>:
.globl vector83
vector83:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $83
8010700f:	6a 53                	push   $0x53
  jmp alltraps
80107011:	e9 87 f6 ff ff       	jmp    8010669d <alltraps>

80107016 <vector84>:
.globl vector84
vector84:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $84
80107018:	6a 54                	push   $0x54
  jmp alltraps
8010701a:	e9 7e f6 ff ff       	jmp    8010669d <alltraps>

8010701f <vector85>:
.globl vector85
vector85:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $85
80107021:	6a 55                	push   $0x55
  jmp alltraps
80107023:	e9 75 f6 ff ff       	jmp    8010669d <alltraps>

80107028 <vector86>:
.globl vector86
vector86:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $86
8010702a:	6a 56                	push   $0x56
  jmp alltraps
8010702c:	e9 6c f6 ff ff       	jmp    8010669d <alltraps>

80107031 <vector87>:
.globl vector87
vector87:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $87
80107033:	6a 57                	push   $0x57
  jmp alltraps
80107035:	e9 63 f6 ff ff       	jmp    8010669d <alltraps>

8010703a <vector88>:
.globl vector88
vector88:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $88
8010703c:	6a 58                	push   $0x58
  jmp alltraps
8010703e:	e9 5a f6 ff ff       	jmp    8010669d <alltraps>

80107043 <vector89>:
.globl vector89
vector89:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $89
80107045:	6a 59                	push   $0x59
  jmp alltraps
80107047:	e9 51 f6 ff ff       	jmp    8010669d <alltraps>

8010704c <vector90>:
.globl vector90
vector90:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $90
8010704e:	6a 5a                	push   $0x5a
  jmp alltraps
80107050:	e9 48 f6 ff ff       	jmp    8010669d <alltraps>

80107055 <vector91>:
.globl vector91
vector91:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $91
80107057:	6a 5b                	push   $0x5b
  jmp alltraps
80107059:	e9 3f f6 ff ff       	jmp    8010669d <alltraps>

8010705e <vector92>:
.globl vector92
vector92:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $92
80107060:	6a 5c                	push   $0x5c
  jmp alltraps
80107062:	e9 36 f6 ff ff       	jmp    8010669d <alltraps>

80107067 <vector93>:
.globl vector93
vector93:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $93
80107069:	6a 5d                	push   $0x5d
  jmp alltraps
8010706b:	e9 2d f6 ff ff       	jmp    8010669d <alltraps>

80107070 <vector94>:
.globl vector94
vector94:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $94
80107072:	6a 5e                	push   $0x5e
  jmp alltraps
80107074:	e9 24 f6 ff ff       	jmp    8010669d <alltraps>

80107079 <vector95>:
.globl vector95
vector95:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $95
8010707b:	6a 5f                	push   $0x5f
  jmp alltraps
8010707d:	e9 1b f6 ff ff       	jmp    8010669d <alltraps>

80107082 <vector96>:
.globl vector96
vector96:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $96
80107084:	6a 60                	push   $0x60
  jmp alltraps
80107086:	e9 12 f6 ff ff       	jmp    8010669d <alltraps>

8010708b <vector97>:
.globl vector97
vector97:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $97
8010708d:	6a 61                	push   $0x61
  jmp alltraps
8010708f:	e9 09 f6 ff ff       	jmp    8010669d <alltraps>

80107094 <vector98>:
.globl vector98
vector98:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $98
80107096:	6a 62                	push   $0x62
  jmp alltraps
80107098:	e9 00 f6 ff ff       	jmp    8010669d <alltraps>

8010709d <vector99>:
.globl vector99
vector99:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $99
8010709f:	6a 63                	push   $0x63
  jmp alltraps
801070a1:	e9 f7 f5 ff ff       	jmp    8010669d <alltraps>

801070a6 <vector100>:
.globl vector100
vector100:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $100
801070a8:	6a 64                	push   $0x64
  jmp alltraps
801070aa:	e9 ee f5 ff ff       	jmp    8010669d <alltraps>

801070af <vector101>:
.globl vector101
vector101:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $101
801070b1:	6a 65                	push   $0x65
  jmp alltraps
801070b3:	e9 e5 f5 ff ff       	jmp    8010669d <alltraps>

801070b8 <vector102>:
.globl vector102
vector102:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $102
801070ba:	6a 66                	push   $0x66
  jmp alltraps
801070bc:	e9 dc f5 ff ff       	jmp    8010669d <alltraps>

801070c1 <vector103>:
.globl vector103
vector103:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $103
801070c3:	6a 67                	push   $0x67
  jmp alltraps
801070c5:	e9 d3 f5 ff ff       	jmp    8010669d <alltraps>

801070ca <vector104>:
.globl vector104
vector104:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $104
801070cc:	6a 68                	push   $0x68
  jmp alltraps
801070ce:	e9 ca f5 ff ff       	jmp    8010669d <alltraps>

801070d3 <vector105>:
.globl vector105
vector105:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $105
801070d5:	6a 69                	push   $0x69
  jmp alltraps
801070d7:	e9 c1 f5 ff ff       	jmp    8010669d <alltraps>

801070dc <vector106>:
.globl vector106
vector106:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $106
801070de:	6a 6a                	push   $0x6a
  jmp alltraps
801070e0:	e9 b8 f5 ff ff       	jmp    8010669d <alltraps>

801070e5 <vector107>:
.globl vector107
vector107:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $107
801070e7:	6a 6b                	push   $0x6b
  jmp alltraps
801070e9:	e9 af f5 ff ff       	jmp    8010669d <alltraps>

801070ee <vector108>:
.globl vector108
vector108:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $108
801070f0:	6a 6c                	push   $0x6c
  jmp alltraps
801070f2:	e9 a6 f5 ff ff       	jmp    8010669d <alltraps>

801070f7 <vector109>:
.globl vector109
vector109:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $109
801070f9:	6a 6d                	push   $0x6d
  jmp alltraps
801070fb:	e9 9d f5 ff ff       	jmp    8010669d <alltraps>

80107100 <vector110>:
.globl vector110
vector110:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $110
80107102:	6a 6e                	push   $0x6e
  jmp alltraps
80107104:	e9 94 f5 ff ff       	jmp    8010669d <alltraps>

80107109 <vector111>:
.globl vector111
vector111:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $111
8010710b:	6a 6f                	push   $0x6f
  jmp alltraps
8010710d:	e9 8b f5 ff ff       	jmp    8010669d <alltraps>

80107112 <vector112>:
.globl vector112
vector112:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $112
80107114:	6a 70                	push   $0x70
  jmp alltraps
80107116:	e9 82 f5 ff ff       	jmp    8010669d <alltraps>

8010711b <vector113>:
.globl vector113
vector113:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $113
8010711d:	6a 71                	push   $0x71
  jmp alltraps
8010711f:	e9 79 f5 ff ff       	jmp    8010669d <alltraps>

80107124 <vector114>:
.globl vector114
vector114:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $114
80107126:	6a 72                	push   $0x72
  jmp alltraps
80107128:	e9 70 f5 ff ff       	jmp    8010669d <alltraps>

8010712d <vector115>:
.globl vector115
vector115:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $115
8010712f:	6a 73                	push   $0x73
  jmp alltraps
80107131:	e9 67 f5 ff ff       	jmp    8010669d <alltraps>

80107136 <vector116>:
.globl vector116
vector116:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $116
80107138:	6a 74                	push   $0x74
  jmp alltraps
8010713a:	e9 5e f5 ff ff       	jmp    8010669d <alltraps>

8010713f <vector117>:
.globl vector117
vector117:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $117
80107141:	6a 75                	push   $0x75
  jmp alltraps
80107143:	e9 55 f5 ff ff       	jmp    8010669d <alltraps>

80107148 <vector118>:
.globl vector118
vector118:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $118
8010714a:	6a 76                	push   $0x76
  jmp alltraps
8010714c:	e9 4c f5 ff ff       	jmp    8010669d <alltraps>

80107151 <vector119>:
.globl vector119
vector119:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $119
80107153:	6a 77                	push   $0x77
  jmp alltraps
80107155:	e9 43 f5 ff ff       	jmp    8010669d <alltraps>

8010715a <vector120>:
.globl vector120
vector120:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $120
8010715c:	6a 78                	push   $0x78
  jmp alltraps
8010715e:	e9 3a f5 ff ff       	jmp    8010669d <alltraps>

80107163 <vector121>:
.globl vector121
vector121:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $121
80107165:	6a 79                	push   $0x79
  jmp alltraps
80107167:	e9 31 f5 ff ff       	jmp    8010669d <alltraps>

8010716c <vector122>:
.globl vector122
vector122:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $122
8010716e:	6a 7a                	push   $0x7a
  jmp alltraps
80107170:	e9 28 f5 ff ff       	jmp    8010669d <alltraps>

80107175 <vector123>:
.globl vector123
vector123:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $123
80107177:	6a 7b                	push   $0x7b
  jmp alltraps
80107179:	e9 1f f5 ff ff       	jmp    8010669d <alltraps>

8010717e <vector124>:
.globl vector124
vector124:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $124
80107180:	6a 7c                	push   $0x7c
  jmp alltraps
80107182:	e9 16 f5 ff ff       	jmp    8010669d <alltraps>

80107187 <vector125>:
.globl vector125
vector125:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $125
80107189:	6a 7d                	push   $0x7d
  jmp alltraps
8010718b:	e9 0d f5 ff ff       	jmp    8010669d <alltraps>

80107190 <vector126>:
.globl vector126
vector126:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $126
80107192:	6a 7e                	push   $0x7e
  jmp alltraps
80107194:	e9 04 f5 ff ff       	jmp    8010669d <alltraps>

80107199 <vector127>:
.globl vector127
vector127:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $127
8010719b:	6a 7f                	push   $0x7f
  jmp alltraps
8010719d:	e9 fb f4 ff ff       	jmp    8010669d <alltraps>

801071a2 <vector128>:
.globl vector128
vector128:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $128
801071a4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801071a9:	e9 ef f4 ff ff       	jmp    8010669d <alltraps>

801071ae <vector129>:
.globl vector129
vector129:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $129
801071b0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801071b5:	e9 e3 f4 ff ff       	jmp    8010669d <alltraps>

801071ba <vector130>:
.globl vector130
vector130:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $130
801071bc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801071c1:	e9 d7 f4 ff ff       	jmp    8010669d <alltraps>

801071c6 <vector131>:
.globl vector131
vector131:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $131
801071c8:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071cd:	e9 cb f4 ff ff       	jmp    8010669d <alltraps>

801071d2 <vector132>:
.globl vector132
vector132:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $132
801071d4:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071d9:	e9 bf f4 ff ff       	jmp    8010669d <alltraps>

801071de <vector133>:
.globl vector133
vector133:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $133
801071e0:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801071e5:	e9 b3 f4 ff ff       	jmp    8010669d <alltraps>

801071ea <vector134>:
.globl vector134
vector134:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $134
801071ec:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071f1:	e9 a7 f4 ff ff       	jmp    8010669d <alltraps>

801071f6 <vector135>:
.globl vector135
vector135:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $135
801071f8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071fd:	e9 9b f4 ff ff       	jmp    8010669d <alltraps>

80107202 <vector136>:
.globl vector136
vector136:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $136
80107204:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107209:	e9 8f f4 ff ff       	jmp    8010669d <alltraps>

8010720e <vector137>:
.globl vector137
vector137:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $137
80107210:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107215:	e9 83 f4 ff ff       	jmp    8010669d <alltraps>

8010721a <vector138>:
.globl vector138
vector138:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $138
8010721c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107221:	e9 77 f4 ff ff       	jmp    8010669d <alltraps>

80107226 <vector139>:
.globl vector139
vector139:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $139
80107228:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010722d:	e9 6b f4 ff ff       	jmp    8010669d <alltraps>

80107232 <vector140>:
.globl vector140
vector140:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $140
80107234:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107239:	e9 5f f4 ff ff       	jmp    8010669d <alltraps>

8010723e <vector141>:
.globl vector141
vector141:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $141
80107240:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107245:	e9 53 f4 ff ff       	jmp    8010669d <alltraps>

8010724a <vector142>:
.globl vector142
vector142:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $142
8010724c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107251:	e9 47 f4 ff ff       	jmp    8010669d <alltraps>

80107256 <vector143>:
.globl vector143
vector143:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $143
80107258:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010725d:	e9 3b f4 ff ff       	jmp    8010669d <alltraps>

80107262 <vector144>:
.globl vector144
vector144:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $144
80107264:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107269:	e9 2f f4 ff ff       	jmp    8010669d <alltraps>

8010726e <vector145>:
.globl vector145
vector145:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $145
80107270:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107275:	e9 23 f4 ff ff       	jmp    8010669d <alltraps>

8010727a <vector146>:
.globl vector146
vector146:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $146
8010727c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107281:	e9 17 f4 ff ff       	jmp    8010669d <alltraps>

80107286 <vector147>:
.globl vector147
vector147:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $147
80107288:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010728d:	e9 0b f4 ff ff       	jmp    8010669d <alltraps>

80107292 <vector148>:
.globl vector148
vector148:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $148
80107294:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107299:	e9 ff f3 ff ff       	jmp    8010669d <alltraps>

8010729e <vector149>:
.globl vector149
vector149:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $149
801072a0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072a5:	e9 f3 f3 ff ff       	jmp    8010669d <alltraps>

801072aa <vector150>:
.globl vector150
vector150:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $150
801072ac:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801072b1:	e9 e7 f3 ff ff       	jmp    8010669d <alltraps>

801072b6 <vector151>:
.globl vector151
vector151:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $151
801072b8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801072bd:	e9 db f3 ff ff       	jmp    8010669d <alltraps>

801072c2 <vector152>:
.globl vector152
vector152:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $152
801072c4:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072c9:	e9 cf f3 ff ff       	jmp    8010669d <alltraps>

801072ce <vector153>:
.globl vector153
vector153:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $153
801072d0:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072d5:	e9 c3 f3 ff ff       	jmp    8010669d <alltraps>

801072da <vector154>:
.globl vector154
vector154:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $154
801072dc:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072e1:	e9 b7 f3 ff ff       	jmp    8010669d <alltraps>

801072e6 <vector155>:
.globl vector155
vector155:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $155
801072e8:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072ed:	e9 ab f3 ff ff       	jmp    8010669d <alltraps>

801072f2 <vector156>:
.globl vector156
vector156:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $156
801072f4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072f9:	e9 9f f3 ff ff       	jmp    8010669d <alltraps>

801072fe <vector157>:
.globl vector157
vector157:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $157
80107300:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107305:	e9 93 f3 ff ff       	jmp    8010669d <alltraps>

8010730a <vector158>:
.globl vector158
vector158:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $158
8010730c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107311:	e9 87 f3 ff ff       	jmp    8010669d <alltraps>

80107316 <vector159>:
.globl vector159
vector159:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $159
80107318:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010731d:	e9 7b f3 ff ff       	jmp    8010669d <alltraps>

80107322 <vector160>:
.globl vector160
vector160:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $160
80107324:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107329:	e9 6f f3 ff ff       	jmp    8010669d <alltraps>

8010732e <vector161>:
.globl vector161
vector161:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $161
80107330:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107335:	e9 63 f3 ff ff       	jmp    8010669d <alltraps>

8010733a <vector162>:
.globl vector162
vector162:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $162
8010733c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107341:	e9 57 f3 ff ff       	jmp    8010669d <alltraps>

80107346 <vector163>:
.globl vector163
vector163:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $163
80107348:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010734d:	e9 4b f3 ff ff       	jmp    8010669d <alltraps>

80107352 <vector164>:
.globl vector164
vector164:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $164
80107354:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107359:	e9 3f f3 ff ff       	jmp    8010669d <alltraps>

8010735e <vector165>:
.globl vector165
vector165:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $165
80107360:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107365:	e9 33 f3 ff ff       	jmp    8010669d <alltraps>

8010736a <vector166>:
.globl vector166
vector166:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $166
8010736c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107371:	e9 27 f3 ff ff       	jmp    8010669d <alltraps>

80107376 <vector167>:
.globl vector167
vector167:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $167
80107378:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010737d:	e9 1b f3 ff ff       	jmp    8010669d <alltraps>

80107382 <vector168>:
.globl vector168
vector168:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $168
80107384:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107389:	e9 0f f3 ff ff       	jmp    8010669d <alltraps>

8010738e <vector169>:
.globl vector169
vector169:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $169
80107390:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107395:	e9 03 f3 ff ff       	jmp    8010669d <alltraps>

8010739a <vector170>:
.globl vector170
vector170:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $170
8010739c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073a1:	e9 f7 f2 ff ff       	jmp    8010669d <alltraps>

801073a6 <vector171>:
.globl vector171
vector171:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $171
801073a8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801073ad:	e9 eb f2 ff ff       	jmp    8010669d <alltraps>

801073b2 <vector172>:
.globl vector172
vector172:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $172
801073b4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801073b9:	e9 df f2 ff ff       	jmp    8010669d <alltraps>

801073be <vector173>:
.globl vector173
vector173:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $173
801073c0:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801073c5:	e9 d3 f2 ff ff       	jmp    8010669d <alltraps>

801073ca <vector174>:
.globl vector174
vector174:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $174
801073cc:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073d1:	e9 c7 f2 ff ff       	jmp    8010669d <alltraps>

801073d6 <vector175>:
.globl vector175
vector175:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $175
801073d8:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801073dd:	e9 bb f2 ff ff       	jmp    8010669d <alltraps>

801073e2 <vector176>:
.globl vector176
vector176:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $176
801073e4:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073e9:	e9 af f2 ff ff       	jmp    8010669d <alltraps>

801073ee <vector177>:
.globl vector177
vector177:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $177
801073f0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073f5:	e9 a3 f2 ff ff       	jmp    8010669d <alltraps>

801073fa <vector178>:
.globl vector178
vector178:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $178
801073fc:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107401:	e9 97 f2 ff ff       	jmp    8010669d <alltraps>

80107406 <vector179>:
.globl vector179
vector179:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $179
80107408:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010740d:	e9 8b f2 ff ff       	jmp    8010669d <alltraps>

80107412 <vector180>:
.globl vector180
vector180:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $180
80107414:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107419:	e9 7f f2 ff ff       	jmp    8010669d <alltraps>

8010741e <vector181>:
.globl vector181
vector181:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $181
80107420:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107425:	e9 73 f2 ff ff       	jmp    8010669d <alltraps>

8010742a <vector182>:
.globl vector182
vector182:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $182
8010742c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107431:	e9 67 f2 ff ff       	jmp    8010669d <alltraps>

80107436 <vector183>:
.globl vector183
vector183:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $183
80107438:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010743d:	e9 5b f2 ff ff       	jmp    8010669d <alltraps>

80107442 <vector184>:
.globl vector184
vector184:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $184
80107444:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107449:	e9 4f f2 ff ff       	jmp    8010669d <alltraps>

8010744e <vector185>:
.globl vector185
vector185:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $185
80107450:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107455:	e9 43 f2 ff ff       	jmp    8010669d <alltraps>

8010745a <vector186>:
.globl vector186
vector186:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $186
8010745c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107461:	e9 37 f2 ff ff       	jmp    8010669d <alltraps>

80107466 <vector187>:
.globl vector187
vector187:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $187
80107468:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010746d:	e9 2b f2 ff ff       	jmp    8010669d <alltraps>

80107472 <vector188>:
.globl vector188
vector188:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $188
80107474:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107479:	e9 1f f2 ff ff       	jmp    8010669d <alltraps>

8010747e <vector189>:
.globl vector189
vector189:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $189
80107480:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107485:	e9 13 f2 ff ff       	jmp    8010669d <alltraps>

8010748a <vector190>:
.globl vector190
vector190:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $190
8010748c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107491:	e9 07 f2 ff ff       	jmp    8010669d <alltraps>

80107496 <vector191>:
.globl vector191
vector191:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $191
80107498:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010749d:	e9 fb f1 ff ff       	jmp    8010669d <alltraps>

801074a2 <vector192>:
.globl vector192
vector192:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $192
801074a4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801074a9:	e9 ef f1 ff ff       	jmp    8010669d <alltraps>

801074ae <vector193>:
.globl vector193
vector193:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $193
801074b0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801074b5:	e9 e3 f1 ff ff       	jmp    8010669d <alltraps>

801074ba <vector194>:
.globl vector194
vector194:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $194
801074bc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801074c1:	e9 d7 f1 ff ff       	jmp    8010669d <alltraps>

801074c6 <vector195>:
.globl vector195
vector195:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $195
801074c8:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074cd:	e9 cb f1 ff ff       	jmp    8010669d <alltraps>

801074d2 <vector196>:
.globl vector196
vector196:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $196
801074d4:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074d9:	e9 bf f1 ff ff       	jmp    8010669d <alltraps>

801074de <vector197>:
.globl vector197
vector197:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $197
801074e0:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801074e5:	e9 b3 f1 ff ff       	jmp    8010669d <alltraps>

801074ea <vector198>:
.globl vector198
vector198:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $198
801074ec:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074f1:	e9 a7 f1 ff ff       	jmp    8010669d <alltraps>

801074f6 <vector199>:
.globl vector199
vector199:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $199
801074f8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074fd:	e9 9b f1 ff ff       	jmp    8010669d <alltraps>

80107502 <vector200>:
.globl vector200
vector200:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $200
80107504:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107509:	e9 8f f1 ff ff       	jmp    8010669d <alltraps>

8010750e <vector201>:
.globl vector201
vector201:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $201
80107510:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107515:	e9 83 f1 ff ff       	jmp    8010669d <alltraps>

8010751a <vector202>:
.globl vector202
vector202:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $202
8010751c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107521:	e9 77 f1 ff ff       	jmp    8010669d <alltraps>

80107526 <vector203>:
.globl vector203
vector203:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $203
80107528:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010752d:	e9 6b f1 ff ff       	jmp    8010669d <alltraps>

80107532 <vector204>:
.globl vector204
vector204:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $204
80107534:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107539:	e9 5f f1 ff ff       	jmp    8010669d <alltraps>

8010753e <vector205>:
.globl vector205
vector205:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $205
80107540:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107545:	e9 53 f1 ff ff       	jmp    8010669d <alltraps>

8010754a <vector206>:
.globl vector206
vector206:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $206
8010754c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107551:	e9 47 f1 ff ff       	jmp    8010669d <alltraps>

80107556 <vector207>:
.globl vector207
vector207:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $207
80107558:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010755d:	e9 3b f1 ff ff       	jmp    8010669d <alltraps>

80107562 <vector208>:
.globl vector208
vector208:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $208
80107564:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107569:	e9 2f f1 ff ff       	jmp    8010669d <alltraps>

8010756e <vector209>:
.globl vector209
vector209:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $209
80107570:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107575:	e9 23 f1 ff ff       	jmp    8010669d <alltraps>

8010757a <vector210>:
.globl vector210
vector210:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $210
8010757c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107581:	e9 17 f1 ff ff       	jmp    8010669d <alltraps>

80107586 <vector211>:
.globl vector211
vector211:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $211
80107588:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010758d:	e9 0b f1 ff ff       	jmp    8010669d <alltraps>

80107592 <vector212>:
.globl vector212
vector212:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $212
80107594:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107599:	e9 ff f0 ff ff       	jmp    8010669d <alltraps>

8010759e <vector213>:
.globl vector213
vector213:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $213
801075a0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075a5:	e9 f3 f0 ff ff       	jmp    8010669d <alltraps>

801075aa <vector214>:
.globl vector214
vector214:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $214
801075ac:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801075b1:	e9 e7 f0 ff ff       	jmp    8010669d <alltraps>

801075b6 <vector215>:
.globl vector215
vector215:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $215
801075b8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801075bd:	e9 db f0 ff ff       	jmp    8010669d <alltraps>

801075c2 <vector216>:
.globl vector216
vector216:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $216
801075c4:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075c9:	e9 cf f0 ff ff       	jmp    8010669d <alltraps>

801075ce <vector217>:
.globl vector217
vector217:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $217
801075d0:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075d5:	e9 c3 f0 ff ff       	jmp    8010669d <alltraps>

801075da <vector218>:
.globl vector218
vector218:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $218
801075dc:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075e1:	e9 b7 f0 ff ff       	jmp    8010669d <alltraps>

801075e6 <vector219>:
.globl vector219
vector219:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $219
801075e8:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075ed:	e9 ab f0 ff ff       	jmp    8010669d <alltraps>

801075f2 <vector220>:
.globl vector220
vector220:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $220
801075f4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075f9:	e9 9f f0 ff ff       	jmp    8010669d <alltraps>

801075fe <vector221>:
.globl vector221
vector221:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $221
80107600:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107605:	e9 93 f0 ff ff       	jmp    8010669d <alltraps>

8010760a <vector222>:
.globl vector222
vector222:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $222
8010760c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107611:	e9 87 f0 ff ff       	jmp    8010669d <alltraps>

80107616 <vector223>:
.globl vector223
vector223:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $223
80107618:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010761d:	e9 7b f0 ff ff       	jmp    8010669d <alltraps>

80107622 <vector224>:
.globl vector224
vector224:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $224
80107624:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107629:	e9 6f f0 ff ff       	jmp    8010669d <alltraps>

8010762e <vector225>:
.globl vector225
vector225:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $225
80107630:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107635:	e9 63 f0 ff ff       	jmp    8010669d <alltraps>

8010763a <vector226>:
.globl vector226
vector226:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $226
8010763c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107641:	e9 57 f0 ff ff       	jmp    8010669d <alltraps>

80107646 <vector227>:
.globl vector227
vector227:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $227
80107648:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010764d:	e9 4b f0 ff ff       	jmp    8010669d <alltraps>

80107652 <vector228>:
.globl vector228
vector228:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $228
80107654:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107659:	e9 3f f0 ff ff       	jmp    8010669d <alltraps>

8010765e <vector229>:
.globl vector229
vector229:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $229
80107660:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107665:	e9 33 f0 ff ff       	jmp    8010669d <alltraps>

8010766a <vector230>:
.globl vector230
vector230:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $230
8010766c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107671:	e9 27 f0 ff ff       	jmp    8010669d <alltraps>

80107676 <vector231>:
.globl vector231
vector231:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $231
80107678:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010767d:	e9 1b f0 ff ff       	jmp    8010669d <alltraps>

80107682 <vector232>:
.globl vector232
vector232:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $232
80107684:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107689:	e9 0f f0 ff ff       	jmp    8010669d <alltraps>

8010768e <vector233>:
.globl vector233
vector233:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $233
80107690:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107695:	e9 03 f0 ff ff       	jmp    8010669d <alltraps>

8010769a <vector234>:
.globl vector234
vector234:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $234
8010769c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076a1:	e9 f7 ef ff ff       	jmp    8010669d <alltraps>

801076a6 <vector235>:
.globl vector235
vector235:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $235
801076a8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801076ad:	e9 eb ef ff ff       	jmp    8010669d <alltraps>

801076b2 <vector236>:
.globl vector236
vector236:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $236
801076b4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801076b9:	e9 df ef ff ff       	jmp    8010669d <alltraps>

801076be <vector237>:
.globl vector237
vector237:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $237
801076c0:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801076c5:	e9 d3 ef ff ff       	jmp    8010669d <alltraps>

801076ca <vector238>:
.globl vector238
vector238:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $238
801076cc:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076d1:	e9 c7 ef ff ff       	jmp    8010669d <alltraps>

801076d6 <vector239>:
.globl vector239
vector239:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $239
801076d8:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801076dd:	e9 bb ef ff ff       	jmp    8010669d <alltraps>

801076e2 <vector240>:
.globl vector240
vector240:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $240
801076e4:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076e9:	e9 af ef ff ff       	jmp    8010669d <alltraps>

801076ee <vector241>:
.globl vector241
vector241:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $241
801076f0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076f5:	e9 a3 ef ff ff       	jmp    8010669d <alltraps>

801076fa <vector242>:
.globl vector242
vector242:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $242
801076fc:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107701:	e9 97 ef ff ff       	jmp    8010669d <alltraps>

80107706 <vector243>:
.globl vector243
vector243:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $243
80107708:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010770d:	e9 8b ef ff ff       	jmp    8010669d <alltraps>

80107712 <vector244>:
.globl vector244
vector244:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $244
80107714:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107719:	e9 7f ef ff ff       	jmp    8010669d <alltraps>

8010771e <vector245>:
.globl vector245
vector245:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $245
80107720:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107725:	e9 73 ef ff ff       	jmp    8010669d <alltraps>

8010772a <vector246>:
.globl vector246
vector246:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $246
8010772c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107731:	e9 67 ef ff ff       	jmp    8010669d <alltraps>

80107736 <vector247>:
.globl vector247
vector247:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $247
80107738:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010773d:	e9 5b ef ff ff       	jmp    8010669d <alltraps>

80107742 <vector248>:
.globl vector248
vector248:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $248
80107744:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107749:	e9 4f ef ff ff       	jmp    8010669d <alltraps>

8010774e <vector249>:
.globl vector249
vector249:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $249
80107750:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107755:	e9 43 ef ff ff       	jmp    8010669d <alltraps>

8010775a <vector250>:
.globl vector250
vector250:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $250
8010775c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107761:	e9 37 ef ff ff       	jmp    8010669d <alltraps>

80107766 <vector251>:
.globl vector251
vector251:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $251
80107768:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010776d:	e9 2b ef ff ff       	jmp    8010669d <alltraps>

80107772 <vector252>:
.globl vector252
vector252:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $252
80107774:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107779:	e9 1f ef ff ff       	jmp    8010669d <alltraps>

8010777e <vector253>:
.globl vector253
vector253:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $253
80107780:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107785:	e9 13 ef ff ff       	jmp    8010669d <alltraps>

8010778a <vector254>:
.globl vector254
vector254:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $254
8010778c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107791:	e9 07 ef ff ff       	jmp    8010669d <alltraps>

80107796 <vector255>:
.globl vector255
vector255:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $255
80107798:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010779d:	e9 fb ee ff ff       	jmp    8010669d <alltraps>

801077a2 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801077a2:	55                   	push   %ebp
801077a3:	89 e5                	mov    %esp,%ebp
801077a5:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801077a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801077ab:	83 e8 01             	sub    $0x1,%eax
801077ae:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801077b2:	8b 45 08             	mov    0x8(%ebp),%eax
801077b5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801077b9:	8b 45 08             	mov    0x8(%ebp),%eax
801077bc:	c1 e8 10             	shr    $0x10,%eax
801077bf:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801077c3:	8d 45 fa             	lea    -0x6(%ebp),%eax
801077c6:	0f 01 10             	lgdtl  (%eax)
}
801077c9:	90                   	nop
801077ca:	c9                   	leave  
801077cb:	c3                   	ret    

801077cc <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801077cc:	55                   	push   %ebp
801077cd:	89 e5                	mov    %esp,%ebp
801077cf:	83 ec 04             	sub    $0x4,%esp
801077d2:	8b 45 08             	mov    0x8(%ebp),%eax
801077d5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077d9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077dd:	0f 00 d8             	ltr    %ax
}
801077e0:	90                   	nop
801077e1:	c9                   	leave  
801077e2:	c3                   	ret    

801077e3 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801077e3:	55                   	push   %ebp
801077e4:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077e6:	8b 45 08             	mov    0x8(%ebp),%eax
801077e9:	0f 22 d8             	mov    %eax,%cr3
}
801077ec:	90                   	nop
801077ed:	5d                   	pop    %ebp
801077ee:	c3                   	ret    

801077ef <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077ef:	55                   	push   %ebp
801077f0:	89 e5                	mov    %esp,%ebp
801077f2:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801077f5:	e8 85 ca ff ff       	call   8010427f <cpuid>
801077fa:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107800:	05 00 38 11 80       	add    $0x80113800,%eax
80107805:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107814:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010781a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107824:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107828:	83 e2 f0             	and    $0xfffffff0,%edx
8010782b:	83 ca 0a             	or     $0xa,%edx
8010782e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107838:	83 ca 10             	or     $0x10,%edx
8010783b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010783e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107841:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107845:	83 e2 9f             	and    $0xffffff9f,%edx
80107848:	88 50 7d             	mov    %dl,0x7d(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107852:	83 ca 80             	or     $0xffffff80,%edx
80107855:	88 50 7d             	mov    %dl,0x7d(%eax)
80107858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010785f:	83 ca 0f             	or     $0xf,%edx
80107862:	88 50 7e             	mov    %dl,0x7e(%eax)
80107865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107868:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010786c:	83 e2 ef             	and    $0xffffffef,%edx
8010786f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107879:	83 e2 df             	and    $0xffffffdf,%edx
8010787c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107886:	83 ca 40             	or     $0x40,%edx
80107889:	88 50 7e             	mov    %dl,0x7e(%eax)
8010788c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107893:	83 ca 80             	or     $0xffffff80,%edx
80107896:	88 50 7e             	mov    %dl,0x7e(%eax)
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078aa:	ff ff 
801078ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078af:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078b6:	00 00 
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078cc:	83 e2 f0             	and    $0xfffffff0,%edx
801078cf:	83 ca 02             	or     $0x2,%edx
801078d2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078db:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078e2:	83 ca 10             	or     $0x10,%edx
801078e5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078f5:	83 e2 9f             	and    $0xffffff9f,%edx
801078f8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107901:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107908:	83 ca 80             	or     $0xffffff80,%edx
8010790b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107914:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010791b:	83 ca 0f             	or     $0xf,%edx
8010791e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107927:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010792e:	83 e2 ef             	and    $0xffffffef,%edx
80107931:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107941:	83 e2 df             	and    $0xffffffdf,%edx
80107944:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010794a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107954:	83 ca 40             	or     $0x40,%edx
80107957:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107960:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107967:	83 ca 80             	or     $0xffffff80,%edx
8010796a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107984:	ff ff 
80107986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107989:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107990:	00 00 
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079a6:	83 e2 f0             	and    $0xfffffff0,%edx
801079a9:	83 ca 0a             	or     $0xa,%edx
801079ac:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079bc:	83 ca 10             	or     $0x10,%edx
801079bf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079cf:	83 ca 60             	or     $0x60,%edx
801079d2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079db:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801079e2:	83 ca 80             	or     $0xffffff80,%edx
801079e5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ee:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079f5:	83 ca 0f             	or     $0xf,%edx
801079f8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a01:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a08:	83 e2 ef             	and    $0xffffffef,%edx
80107a0b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a14:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a1b:	83 e2 df             	and    $0xffffffdf,%edx
80107a1e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a2e:	83 ca 40             	or     $0x40,%edx
80107a31:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107a41:	83 ca 80             	or     $0xffffff80,%edx
80107a44:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a57:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a5e:	ff ff 
80107a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a63:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a6a:	00 00 
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a79:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a80:	83 e2 f0             	and    $0xfffffff0,%edx
80107a83:	83 ca 02             	or     $0x2,%edx
80107a86:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a96:	83 ca 10             	or     $0x10,%edx
80107a99:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aa9:	83 ca 60             	or     $0x60,%edx
80107aac:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107abc:	83 ca 80             	or     $0xffffff80,%edx
80107abf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107acf:	83 ca 0f             	or     $0xf,%edx
80107ad2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ae2:	83 e2 ef             	and    $0xffffffef,%edx
80107ae5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aee:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107af5:	83 e2 df             	and    $0xffffffdf,%edx
80107af8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b08:	83 ca 40             	or     $0x40,%edx
80107b0b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b14:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b1b:	83 ca 80             	or     $0xffffff80,%edx
80107b1e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b27:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	83 c0 70             	add    $0x70,%eax
80107b34:	83 ec 08             	sub    $0x8,%esp
80107b37:	6a 30                	push   $0x30
80107b39:	50                   	push   %eax
80107b3a:	e8 63 fc ff ff       	call   801077a2 <lgdt>
80107b3f:	83 c4 10             	add    $0x10,%esp
}
80107b42:	90                   	nop
80107b43:	c9                   	leave  
80107b44:	c3                   	ret    

80107b45 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b45:	55                   	push   %ebp
80107b46:	89 e5                	mov    %esp,%ebp
80107b48:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b4e:	c1 e8 16             	shr    $0x16,%eax
80107b51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b58:	8b 45 08             	mov    0x8(%ebp),%eax
80107b5b:	01 d0                	add    %edx,%eax
80107b5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b63:	8b 00                	mov    (%eax),%eax
80107b65:	83 e0 01             	and    $0x1,%eax
80107b68:	85 c0                	test   %eax,%eax
80107b6a:	74 14                	je     80107b80 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b6f:	8b 00                	mov    (%eax),%eax
80107b71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b76:	05 00 00 00 80       	add    $0x80000000,%eax
80107b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b7e:	eb 42                	jmp    80107bc2 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b84:	74 0e                	je     80107b94 <walkpgdir+0x4f>
80107b86:	e8 95 b1 ff ff       	call   80102d20 <kalloc>
80107b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b92:	75 07                	jne    80107b9b <walkpgdir+0x56>
      return 0;
80107b94:	b8 00 00 00 00       	mov    $0x0,%eax
80107b99:	eb 3e                	jmp    80107bd9 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b9b:	83 ec 04             	sub    $0x4,%esp
80107b9e:	68 00 10 00 00       	push   $0x1000
80107ba3:	6a 00                	push   $0x0
80107ba5:	ff 75 f4             	pushl  -0xc(%ebp)
80107ba8:	e8 f2 d6 ff ff       	call   8010529f <memset>
80107bad:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb3:	05 00 00 00 80       	add    $0x80000000,%eax
80107bb8:	83 c8 07             	or     $0x7,%eax
80107bbb:	89 c2                	mov    %eax,%edx
80107bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bc0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc5:	c1 e8 0c             	shr    $0xc,%eax
80107bc8:	25 ff 03 00 00       	and    $0x3ff,%eax
80107bcd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd7:	01 d0                	add    %edx,%eax
}
80107bd9:	c9                   	leave  
80107bda:	c3                   	ret    

80107bdb <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107bdb:	55                   	push   %ebp
80107bdc:	89 e5                	mov    %esp,%ebp
80107bde:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
 
//  cprintf("SIZE: %x\n", va);
  a = (char*)PGROUNDDOWN((uint)va);
80107be1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107bec:	8b 55 0c             	mov    0xc(%ebp),%edx
80107bef:	8b 45 10             	mov    0x10(%ebp),%eax
80107bf2:	01 d0                	add    %edx,%eax
80107bf4:	83 e8 01             	sub    $0x1,%eax
80107bf7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107bff:	83 ec 04             	sub    $0x4,%esp
80107c02:	6a 01                	push   $0x1
80107c04:	ff 75 f4             	pushl  -0xc(%ebp)
80107c07:	ff 75 08             	pushl  0x8(%ebp)
80107c0a:	e8 36 ff ff ff       	call   80107b45 <walkpgdir>
80107c0f:	83 c4 10             	add    $0x10,%esp
80107c12:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c19:	75 07                	jne    80107c22 <mappages+0x47>
      return -1;
80107c1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c20:	eb 47                	jmp    80107c69 <mappages+0x8e>
    if(*pte & PTE_P)
80107c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c25:	8b 00                	mov    (%eax),%eax
80107c27:	83 e0 01             	and    $0x1,%eax
80107c2a:	85 c0                	test   %eax,%eax
80107c2c:	74 0d                	je     80107c3b <mappages+0x60>
      panic("remap");
80107c2e:	83 ec 0c             	sub    $0xc,%esp
80107c31:	68 f4 8b 10 80       	push   $0x80108bf4
80107c36:	e8 65 89 ff ff       	call   801005a0 <panic>
    *pte = pa | perm | PTE_P;
80107c3b:	8b 45 18             	mov    0x18(%ebp),%eax
80107c3e:	0b 45 14             	or     0x14(%ebp),%eax
80107c41:	83 c8 01             	or     $0x1,%eax
80107c44:	89 c2                	mov    %eax,%edx
80107c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c49:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c51:	74 10                	je     80107c63 <mappages+0x88>
      break;
    a += PGSIZE;
80107c53:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c5a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107c61:	eb 9c                	jmp    80107bff <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107c63:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c69:	c9                   	leave  
80107c6a:	c3                   	ret    

80107c6b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c6b:	55                   	push   %ebp
80107c6c:	89 e5                	mov    %esp,%ebp
80107c6e:	53                   	push   %ebx
80107c6f:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107c72:	e8 a9 b0 ff ff       	call   80102d20 <kalloc>
80107c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c7e:	75 07                	jne    80107c87 <setupkvm+0x1c>
    return 0;
80107c80:	b8 00 00 00 00       	mov    $0x0,%eax
80107c85:	eb 78                	jmp    80107cff <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107c87:	83 ec 04             	sub    $0x4,%esp
80107c8a:	68 00 10 00 00       	push   $0x1000
80107c8f:	6a 00                	push   $0x0
80107c91:	ff 75 f0             	pushl  -0x10(%ebp)
80107c94:	e8 06 d6 ff ff       	call   8010529f <memset>
80107c99:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c9c:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107ca3:	eb 4e                	jmp    80107cf3 <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	8b 58 08             	mov    0x8(%eax),%ebx
80107cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cba:	8b 40 04             	mov    0x4(%eax),%eax
80107cbd:	29 c3                	sub    %eax,%ebx
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	8b 00                	mov    (%eax),%eax
80107cc4:	83 ec 0c             	sub    $0xc,%esp
80107cc7:	51                   	push   %ecx
80107cc8:	52                   	push   %edx
80107cc9:	53                   	push   %ebx
80107cca:	50                   	push   %eax
80107ccb:	ff 75 f0             	pushl  -0x10(%ebp)
80107cce:	e8 08 ff ff ff       	call   80107bdb <mappages>
80107cd3:	83 c4 20             	add    $0x20,%esp
80107cd6:	85 c0                	test   %eax,%eax
80107cd8:	79 15                	jns    80107cef <setupkvm+0x84>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107cda:	83 ec 0c             	sub    $0xc,%esp
80107cdd:	ff 75 f0             	pushl  -0x10(%ebp)
80107ce0:	e8 1a 05 00 00       	call   801081ff <freevm>
80107ce5:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ce8:	b8 00 00 00 00       	mov    $0x0,%eax
80107ced:	eb 10                	jmp    80107cff <setupkvm+0x94>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cef:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107cf3:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107cfa:	72 a9                	jb     80107ca5 <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107cff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d02:	c9                   	leave  
80107d03:	c3                   	ret    

80107d04 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d04:	55                   	push   %ebp
80107d05:	89 e5                	mov    %esp,%ebp
80107d07:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d0a:	e8 5c ff ff ff       	call   80107c6b <setupkvm>
80107d0f:	a3 24 67 11 80       	mov    %eax,0x80116724
  switchkvm();
80107d14:	e8 03 00 00 00       	call   80107d1c <switchkvm>
}
80107d19:	90                   	nop
80107d1a:	c9                   	leave  
80107d1b:	c3                   	ret    

80107d1c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d1c:	55                   	push   %ebp
80107d1d:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d1f:	a1 24 67 11 80       	mov    0x80116724,%eax
80107d24:	05 00 00 00 80       	add    $0x80000000,%eax
80107d29:	50                   	push   %eax
80107d2a:	e8 b4 fa ff ff       	call   801077e3 <lcr3>
80107d2f:	83 c4 04             	add    $0x4,%esp
}
80107d32:	90                   	nop
80107d33:	c9                   	leave  
80107d34:	c3                   	ret    

80107d35 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d35:	55                   	push   %ebp
80107d36:	89 e5                	mov    %esp,%ebp
80107d38:	56                   	push   %esi
80107d39:	53                   	push   %ebx
80107d3a:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107d3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d41:	75 0d                	jne    80107d50 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107d43:	83 ec 0c             	sub    $0xc,%esp
80107d46:	68 fa 8b 10 80       	push   $0x80108bfa
80107d4b:	e8 50 88 ff ff       	call   801005a0 <panic>
  if(p->kstack == 0)
80107d50:	8b 45 08             	mov    0x8(%ebp),%eax
80107d53:	8b 40 08             	mov    0x8(%eax),%eax
80107d56:	85 c0                	test   %eax,%eax
80107d58:	75 0d                	jne    80107d67 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107d5a:	83 ec 0c             	sub    $0xc,%esp
80107d5d:	68 10 8c 10 80       	push   $0x80108c10
80107d62:	e8 39 88 ff ff       	call   801005a0 <panic>
  if(p->pgdir == 0)
80107d67:	8b 45 08             	mov    0x8(%ebp),%eax
80107d6a:	8b 40 04             	mov    0x4(%eax),%eax
80107d6d:	85 c0                	test   %eax,%eax
80107d6f:	75 0d                	jne    80107d7e <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107d71:	83 ec 0c             	sub    $0xc,%esp
80107d74:	68 25 8c 10 80       	push   $0x80108c25
80107d79:	e8 22 88 ff ff       	call   801005a0 <panic>

  pushcli();
80107d7e:	e8 10 d4 ff ff       	call   80105193 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107d83:	e8 18 c5 ff ff       	call   801042a0 <mycpu>
80107d88:	89 c3                	mov    %eax,%ebx
80107d8a:	e8 11 c5 ff ff       	call   801042a0 <mycpu>
80107d8f:	83 c0 08             	add    $0x8,%eax
80107d92:	89 c6                	mov    %eax,%esi
80107d94:	e8 07 c5 ff ff       	call   801042a0 <mycpu>
80107d99:	83 c0 08             	add    $0x8,%eax
80107d9c:	c1 e8 10             	shr    $0x10,%eax
80107d9f:	88 45 f7             	mov    %al,-0x9(%ebp)
80107da2:	e8 f9 c4 ff ff       	call   801042a0 <mycpu>
80107da7:	83 c0 08             	add    $0x8,%eax
80107daa:	c1 e8 18             	shr    $0x18,%eax
80107dad:	89 c2                	mov    %eax,%edx
80107daf:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107db6:	67 00 
80107db8:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107dbf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107dc3:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107dc9:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107dd0:	83 e0 f0             	and    $0xfffffff0,%eax
80107dd3:	83 c8 09             	or     $0x9,%eax
80107dd6:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ddc:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107de3:	83 c8 10             	or     $0x10,%eax
80107de6:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107dec:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107df3:	83 e0 9f             	and    $0xffffff9f,%eax
80107df6:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107dfc:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e03:	83 c8 80             	or     $0xffffff80,%eax
80107e06:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e0c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e13:	83 e0 f0             	and    $0xfffffff0,%eax
80107e16:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e1c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e23:	83 e0 ef             	and    $0xffffffef,%eax
80107e26:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e2c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e33:	83 e0 df             	and    $0xffffffdf,%eax
80107e36:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e3c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e43:	83 c8 40             	or     $0x40,%eax
80107e46:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e4c:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e53:	83 e0 7f             	and    $0x7f,%eax
80107e56:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e5c:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107e62:	e8 39 c4 ff ff       	call   801042a0 <mycpu>
80107e67:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e6e:	83 e2 ef             	and    $0xffffffef,%edx
80107e71:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107e77:	e8 24 c4 ff ff       	call   801042a0 <mycpu>
80107e7c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107e82:	e8 19 c4 ff ff       	call   801042a0 <mycpu>
80107e87:	89 c2                	mov    %eax,%edx
80107e89:	8b 45 08             	mov    0x8(%ebp),%eax
80107e8c:	8b 40 08             	mov    0x8(%eax),%eax
80107e8f:	05 00 10 00 00       	add    $0x1000,%eax
80107e94:	89 42 0c             	mov    %eax,0xc(%edx)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107e97:	e8 04 c4 ff ff       	call   801042a0 <mycpu>
80107e9c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107ea2:	83 ec 0c             	sub    $0xc,%esp
80107ea5:	6a 28                	push   $0x28
80107ea7:	e8 20 f9 ff ff       	call   801077cc <ltr>
80107eac:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80107eb2:	8b 40 04             	mov    0x4(%eax),%eax
80107eb5:	05 00 00 00 80       	add    $0x80000000,%eax
80107eba:	83 ec 0c             	sub    $0xc,%esp
80107ebd:	50                   	push   %eax
80107ebe:	e8 20 f9 ff ff       	call   801077e3 <lcr3>
80107ec3:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ec6:	e8 16 d3 ff ff       	call   801051e1 <popcli>
}
80107ecb:	90                   	nop
80107ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107ecf:	5b                   	pop    %ebx
80107ed0:	5e                   	pop    %esi
80107ed1:	5d                   	pop    %ebp
80107ed2:	c3                   	ret    

80107ed3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ed3:	55                   	push   %ebp
80107ed4:	89 e5                	mov    %esp,%ebp
80107ed6:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ed9:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ee0:	76 0d                	jbe    80107eef <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ee2:	83 ec 0c             	sub    $0xc,%esp
80107ee5:	68 39 8c 10 80       	push   $0x80108c39
80107eea:	e8 b1 86 ff ff       	call   801005a0 <panic>
  mem = kalloc();
80107eef:	e8 2c ae ff ff       	call   80102d20 <kalloc>
80107ef4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ef7:	83 ec 04             	sub    $0x4,%esp
80107efa:	68 00 10 00 00       	push   $0x1000
80107eff:	6a 00                	push   $0x0
80107f01:	ff 75 f4             	pushl  -0xc(%ebp)
80107f04:	e8 96 d3 ff ff       	call   8010529f <memset>
80107f09:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0f:	05 00 00 00 80       	add    $0x80000000,%eax
80107f14:	83 ec 0c             	sub    $0xc,%esp
80107f17:	6a 06                	push   $0x6
80107f19:	50                   	push   %eax
80107f1a:	68 00 10 00 00       	push   $0x1000
80107f1f:	6a 00                	push   $0x0
80107f21:	ff 75 08             	pushl  0x8(%ebp)
80107f24:	e8 b2 fc ff ff       	call   80107bdb <mappages>
80107f29:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f2c:	83 ec 04             	sub    $0x4,%esp
80107f2f:	ff 75 10             	pushl  0x10(%ebp)
80107f32:	ff 75 0c             	pushl  0xc(%ebp)
80107f35:	ff 75 f4             	pushl  -0xc(%ebp)
80107f38:	e8 21 d4 ff ff       	call   8010535e <memmove>
80107f3d:	83 c4 10             	add    $0x10,%esp
}
80107f40:	90                   	nop
80107f41:	c9                   	leave  
80107f42:	c3                   	ret    

80107f43 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f43:	55                   	push   %ebp
80107f44:	89 e5                	mov    %esp,%ebp
80107f46:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f4c:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f51:	85 c0                	test   %eax,%eax
80107f53:	74 0d                	je     80107f62 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f55:	83 ec 0c             	sub    $0xc,%esp
80107f58:	68 54 8c 10 80       	push   $0x80108c54
80107f5d:	e8 3e 86 ff ff       	call   801005a0 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f69:	e9 8f 00 00 00       	jmp    80107ffd <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f74:	01 d0                	add    %edx,%eax
80107f76:	83 ec 04             	sub    $0x4,%esp
80107f79:	6a 00                	push   $0x0
80107f7b:	50                   	push   %eax
80107f7c:	ff 75 08             	pushl  0x8(%ebp)
80107f7f:	e8 c1 fb ff ff       	call   80107b45 <walkpgdir>
80107f84:	83 c4 10             	add    $0x10,%esp
80107f87:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f8a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f8e:	75 0d                	jne    80107f9d <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107f90:	83 ec 0c             	sub    $0xc,%esp
80107f93:	68 77 8c 10 80       	push   $0x80108c77
80107f98:	e8 03 86 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80107f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fa0:	8b 00                	mov    (%eax),%eax
80107fa2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107faa:	8b 45 18             	mov    0x18(%ebp),%eax
80107fad:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fb0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fb5:	77 0b                	ja     80107fc2 <loaduvm+0x7f>
      n = sz - i;
80107fb7:	8b 45 18             	mov    0x18(%ebp),%eax
80107fba:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fc0:	eb 07                	jmp    80107fc9 <loaduvm+0x86>
    else
      n = PGSIZE;
80107fc2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107fc9:	8b 55 14             	mov    0x14(%ebp),%edx
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	01 d0                	add    %edx,%eax
80107fd1:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107fd4:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107fda:	ff 75 f0             	pushl  -0x10(%ebp)
80107fdd:	50                   	push   %eax
80107fde:	52                   	push   %edx
80107fdf:	ff 75 10             	pushl  0x10(%ebp)
80107fe2:	e8 a5 9f ff ff       	call   80101f8c <readi>
80107fe7:	83 c4 10             	add    $0x10,%esp
80107fea:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fed:	74 07                	je     80107ff6 <loaduvm+0xb3>
      return -1;
80107fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ff4:	eb 18                	jmp    8010800e <loaduvm+0xcb>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107ff6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108000:	3b 45 18             	cmp    0x18(%ebp),%eax
80108003:	0f 82 65 ff ff ff    	jb     80107f6e <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108009:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010800e:	c9                   	leave  
8010800f:	c3                   	ret    

80108010 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108010:	55                   	push   %ebp
80108011:	89 e5                	mov    %esp,%ebp
80108013:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108016:	8b 45 10             	mov    0x10(%ebp),%eax
80108019:	85 c0                	test   %eax,%eax
8010801b:	79 0a                	jns    80108027 <allocuvm+0x17>
    return 0;
8010801d:	b8 00 00 00 00       	mov    $0x0,%eax
80108022:	e9 12 01 00 00       	jmp    80108139 <allocuvm+0x129>
  if(newsz < oldsz)
80108027:	8b 45 10             	mov    0x10(%ebp),%eax
8010802a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010802d:	73 08                	jae    80108037 <allocuvm+0x27>
    return oldsz;
8010802f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108032:	e9 02 01 00 00       	jmp    80108139 <allocuvm+0x129>

  a = PGROUNDUP(oldsz);
80108037:	8b 45 0c             	mov    0xc(%ebp),%eax
8010803a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010803f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108044:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("A: %x\n", a);
80108047:	83 ec 08             	sub    $0x8,%esp
8010804a:	ff 75 f4             	pushl  -0xc(%ebp)
8010804d:	68 95 8c 10 80       	push   $0x80108c95
80108052:	e8 a9 83 ff ff       	call   80100400 <cprintf>
80108057:	83 c4 10             	add    $0x10,%esp
  for(; a < newsz; a += PGSIZE){
8010805a:	e9 cb 00 00 00       	jmp    8010812a <allocuvm+0x11a>
    mem = kalloc();
8010805f:	e8 bc ac ff ff       	call   80102d20 <kalloc>
80108064:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108067:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010806b:	75 2e                	jne    8010809b <allocuvm+0x8b>
      cprintf("allocuvm out of memory\n");
8010806d:	83 ec 0c             	sub    $0xc,%esp
80108070:	68 9c 8c 10 80       	push   $0x80108c9c
80108075:	e8 86 83 ff ff       	call   80100400 <cprintf>
8010807a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010807d:	83 ec 04             	sub    $0x4,%esp
80108080:	ff 75 0c             	pushl  0xc(%ebp)
80108083:	ff 75 10             	pushl  0x10(%ebp)
80108086:	ff 75 08             	pushl  0x8(%ebp)
80108089:	e8 ad 00 00 00       	call   8010813b <deallocuvm>
8010808e:	83 c4 10             	add    $0x10,%esp
      return 0;
80108091:	b8 00 00 00 00       	mov    $0x0,%eax
80108096:	e9 9e 00 00 00       	jmp    80108139 <allocuvm+0x129>
    }
   cprintf("MEM: %x\n", mem);
8010809b:	83 ec 08             	sub    $0x8,%esp
8010809e:	ff 75 f0             	pushl  -0x10(%ebp)
801080a1:	68 b4 8c 10 80       	push   $0x80108cb4
801080a6:	e8 55 83 ff ff       	call   80100400 <cprintf>
801080ab:	83 c4 10             	add    $0x10,%esp
    memset(mem, 0, PGSIZE);
801080ae:	83 ec 04             	sub    $0x4,%esp
801080b1:	68 00 10 00 00       	push   $0x1000
801080b6:	6a 00                	push   $0x0
801080b8:	ff 75 f0             	pushl  -0x10(%ebp)
801080bb:	e8 df d1 ff ff       	call   8010529f <memset>
801080c0:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801080c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801080cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cf:	83 ec 0c             	sub    $0xc,%esp
801080d2:	6a 06                	push   $0x6
801080d4:	52                   	push   %edx
801080d5:	68 00 10 00 00       	push   $0x1000
801080da:	50                   	push   %eax
801080db:	ff 75 08             	pushl  0x8(%ebp)
801080de:	e8 f8 fa ff ff       	call   80107bdb <mappages>
801080e3:	83 c4 20             	add    $0x20,%esp
801080e6:	85 c0                	test   %eax,%eax
801080e8:	79 39                	jns    80108123 <allocuvm+0x113>
      cprintf("allocuvm out of memory (2)\n");
801080ea:	83 ec 0c             	sub    $0xc,%esp
801080ed:	68 bd 8c 10 80       	push   $0x80108cbd
801080f2:	e8 09 83 ff ff       	call   80100400 <cprintf>
801080f7:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080fa:	83 ec 04             	sub    $0x4,%esp
801080fd:	ff 75 0c             	pushl  0xc(%ebp)
80108100:	ff 75 10             	pushl  0x10(%ebp)
80108103:	ff 75 08             	pushl  0x8(%ebp)
80108106:	e8 30 00 00 00       	call   8010813b <deallocuvm>
8010810b:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010810e:	83 ec 0c             	sub    $0xc,%esp
80108111:	ff 75 f0             	pushl  -0x10(%ebp)
80108114:	e8 6d ab ff ff       	call   80102c86 <kfree>
80108119:	83 c4 10             	add    $0x10,%esp
      return 0;
8010811c:	b8 00 00 00 00       	mov    $0x0,%eax
80108121:	eb 16                	jmp    80108139 <allocuvm+0x129>
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  cprintf("A: %x\n", a);
  for(; a < newsz; a += PGSIZE){
80108123:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010812a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812d:	3b 45 10             	cmp    0x10(%ebp),%eax
80108130:	0f 82 29 ff ff ff    	jb     8010805f <allocuvm+0x4f>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108136:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108139:	c9                   	leave  
8010813a:	c3                   	ret    

8010813b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010813b:	55                   	push   %ebp
8010813c:	89 e5                	mov    %esp,%ebp
8010813e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108141:	8b 45 10             	mov    0x10(%ebp),%eax
80108144:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108147:	72 08                	jb     80108151 <deallocuvm+0x16>
    return oldsz;
80108149:	8b 45 0c             	mov    0xc(%ebp),%eax
8010814c:	e9 ac 00 00 00       	jmp    801081fd <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108151:	8b 45 10             	mov    0x10(%ebp),%eax
80108154:	05 ff 0f 00 00       	add    $0xfff,%eax
80108159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010815e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108161:	e9 88 00 00 00       	jmp    801081ee <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108169:	83 ec 04             	sub    $0x4,%esp
8010816c:	6a 00                	push   $0x0
8010816e:	50                   	push   %eax
8010816f:	ff 75 08             	pushl  0x8(%ebp)
80108172:	e8 ce f9 ff ff       	call   80107b45 <walkpgdir>
80108177:	83 c4 10             	add    $0x10,%esp
8010817a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010817d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108181:	75 16                	jne    80108199 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108186:	c1 e8 16             	shr    $0x16,%eax
80108189:	83 c0 01             	add    $0x1,%eax
8010818c:	c1 e0 16             	shl    $0x16,%eax
8010818f:	2d 00 10 00 00       	sub    $0x1000,%eax
80108194:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108197:	eb 4e                	jmp    801081e7 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108199:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010819c:	8b 00                	mov    (%eax),%eax
8010819e:	83 e0 01             	and    $0x1,%eax
801081a1:	85 c0                	test   %eax,%eax
801081a3:	74 42                	je     801081e7 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801081a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a8:	8b 00                	mov    (%eax),%eax
801081aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081af:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801081b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081b6:	75 0d                	jne    801081c5 <deallocuvm+0x8a>
        panic("kfree");
801081b8:	83 ec 0c             	sub    $0xc,%esp
801081bb:	68 d9 8c 10 80       	push   $0x80108cd9
801081c0:	e8 db 83 ff ff       	call   801005a0 <panic>
      char *v = P2V(pa);
801081c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081c8:	05 00 00 00 80       	add    $0x80000000,%eax
801081cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081d0:	83 ec 0c             	sub    $0xc,%esp
801081d3:	ff 75 e8             	pushl  -0x18(%ebp)
801081d6:	e8 ab aa ff ff       	call   80102c86 <kfree>
801081db:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801081de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801081e7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081f4:	0f 82 6c ff ff ff    	jb     80108166 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801081fa:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081fd:	c9                   	leave  
801081fe:	c3                   	ret    

801081ff <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801081ff:	55                   	push   %ebp
80108200:	89 e5                	mov    %esp,%ebp
80108202:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108205:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108209:	75 0d                	jne    80108218 <freevm+0x19>
    panic("freevm: no pgdir");
8010820b:	83 ec 0c             	sub    $0xc,%esp
8010820e:	68 df 8c 10 80       	push   $0x80108cdf
80108213:	e8 88 83 ff ff       	call   801005a0 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108218:	83 ec 04             	sub    $0x4,%esp
8010821b:	6a 00                	push   $0x0
8010821d:	68 00 00 00 80       	push   $0x80000000
80108222:	ff 75 08             	pushl  0x8(%ebp)
80108225:	e8 11 ff ff ff       	call   8010813b <deallocuvm>
8010822a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010822d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108234:	eb 48                	jmp    8010827e <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108239:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108240:	8b 45 08             	mov    0x8(%ebp),%eax
80108243:	01 d0                	add    %edx,%eax
80108245:	8b 00                	mov    (%eax),%eax
80108247:	83 e0 01             	and    $0x1,%eax
8010824a:	85 c0                	test   %eax,%eax
8010824c:	74 2c                	je     8010827a <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010824e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108251:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108258:	8b 45 08             	mov    0x8(%ebp),%eax
8010825b:	01 d0                	add    %edx,%eax
8010825d:	8b 00                	mov    (%eax),%eax
8010825f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108264:	05 00 00 00 80       	add    $0x80000000,%eax
80108269:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010826c:	83 ec 0c             	sub    $0xc,%esp
8010826f:	ff 75 f0             	pushl  -0x10(%ebp)
80108272:	e8 0f aa ff ff       	call   80102c86 <kfree>
80108277:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010827a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010827e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108285:	76 af                	jbe    80108236 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108287:	83 ec 0c             	sub    $0xc,%esp
8010828a:	ff 75 08             	pushl  0x8(%ebp)
8010828d:	e8 f4 a9 ff ff       	call   80102c86 <kfree>
80108292:	83 c4 10             	add    $0x10,%esp
}
80108295:	90                   	nop
80108296:	c9                   	leave  
80108297:	c3                   	ret    

80108298 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108298:	55                   	push   %ebp
80108299:	89 e5                	mov    %esp,%ebp
8010829b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010829e:	83 ec 04             	sub    $0x4,%esp
801082a1:	6a 00                	push   $0x0
801082a3:	ff 75 0c             	pushl  0xc(%ebp)
801082a6:	ff 75 08             	pushl  0x8(%ebp)
801082a9:	e8 97 f8 ff ff       	call   80107b45 <walkpgdir>
801082ae:	83 c4 10             	add    $0x10,%esp
801082b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801082b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082b8:	75 0d                	jne    801082c7 <clearpteu+0x2f>
    panic("clearpteu");
801082ba:	83 ec 0c             	sub    $0xc,%esp
801082bd:	68 f0 8c 10 80       	push   $0x80108cf0
801082c2:	e8 d9 82 ff ff       	call   801005a0 <panic>
  *pte &= ~PTE_U;
801082c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ca:	8b 00                	mov    (%eax),%eax
801082cc:	83 e0 fb             	and    $0xfffffffb,%eax
801082cf:	89 c2                	mov    %eax,%edx
801082d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d4:	89 10                	mov    %edx,(%eax)
}
801082d6:	90                   	nop
801082d7:	c9                   	leave  
801082d8:	c3                   	ret    

801082d9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, uint lp)
{
801082d9:	55                   	push   %ebp
801082da:	89 e5                	mov    %esp,%ebp
801082dc:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801082df:	e8 87 f9 ff ff       	call   80107c6b <setupkvm>
801082e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082eb:	75 0a                	jne    801082f7 <copyuvm+0x1e>
    return 0;
801082ed:	b8 00 00 00 00       	mov    $0x0,%eax
801082f2:	e9 eb 00 00 00       	jmp    801083e2 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801082f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082fe:	e9 b7 00 00 00       	jmp    801083ba <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108306:	83 ec 04             	sub    $0x4,%esp
80108309:	6a 00                	push   $0x0
8010830b:	50                   	push   %eax
8010830c:	ff 75 08             	pushl  0x8(%ebp)
8010830f:	e8 31 f8 ff ff       	call   80107b45 <walkpgdir>
80108314:	83 c4 10             	add    $0x10,%esp
80108317:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010831a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010831e:	75 0d                	jne    8010832d <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108320:	83 ec 0c             	sub    $0xc,%esp
80108323:	68 fa 8c 10 80       	push   $0x80108cfa
80108328:	e8 73 82 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010832d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108330:	8b 00                	mov    (%eax),%eax
80108332:	83 e0 01             	and    $0x1,%eax
80108335:	85 c0                	test   %eax,%eax
80108337:	75 0d                	jne    80108346 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108339:	83 ec 0c             	sub    $0xc,%esp
8010833c:	68 14 8d 10 80       	push   $0x80108d14
80108341:	e8 5a 82 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108346:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108349:	8b 00                	mov    (%eax),%eax
8010834b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108350:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108353:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108356:	8b 00                	mov    (%eax),%eax
80108358:	25 ff 0f 00 00       	and    $0xfff,%eax
8010835d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108360:	e8 bb a9 ff ff       	call   80102d20 <kalloc>
80108365:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108368:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010836c:	74 5d                	je     801083cb <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010836e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108371:	05 00 00 00 80       	add    $0x80000000,%eax
80108376:	83 ec 04             	sub    $0x4,%esp
80108379:	68 00 10 00 00       	push   $0x1000
8010837e:	50                   	push   %eax
8010837f:	ff 75 e0             	pushl  -0x20(%ebp)
80108382:	e8 d7 cf ff ff       	call   8010535e <memmove>
80108387:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010838a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010838d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108390:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108399:	83 ec 0c             	sub    $0xc,%esp
8010839c:	52                   	push   %edx
8010839d:	51                   	push   %ecx
8010839e:	68 00 10 00 00       	push   $0x1000
801083a3:	50                   	push   %eax
801083a4:	ff 75 f0             	pushl  -0x10(%ebp)
801083a7:	e8 2f f8 ff ff       	call   80107bdb <mappages>
801083ac:	83 c4 20             	add    $0x20,%esp
801083af:	85 c0                	test   %eax,%eax
801083b1:	78 1b                	js     801083ce <copyuvm+0xf5>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801083b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083c0:	0f 82 3d ff ff ff    	jb     80108303 <copyuvm+0x2a>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
*/
  return d;
801083c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083c9:	eb 17                	jmp    801083e2 <copyuvm+0x109>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801083cb:	90                   	nop
801083cc:	eb 01                	jmp    801083cf <copyuvm+0xf6>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801083ce:	90                   	nop
  }
*/
  return d;

bad:
  freevm(d);
801083cf:	83 ec 0c             	sub    $0xc,%esp
801083d2:	ff 75 f0             	pushl  -0x10(%ebp)
801083d5:	e8 25 fe ff ff       	call   801081ff <freevm>
801083da:	83 c4 10             	add    $0x10,%esp
  return 0;
801083dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083e2:	c9                   	leave  
801083e3:	c3                   	ret    

801083e4 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083e4:	55                   	push   %ebp
801083e5:	89 e5                	mov    %esp,%ebp
801083e7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083ea:	83 ec 04             	sub    $0x4,%esp
801083ed:	6a 00                	push   $0x0
801083ef:	ff 75 0c             	pushl  0xc(%ebp)
801083f2:	ff 75 08             	pushl  0x8(%ebp)
801083f5:	e8 4b f7 ff ff       	call   80107b45 <walkpgdir>
801083fa:	83 c4 10             	add    $0x10,%esp
801083fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108403:	8b 00                	mov    (%eax),%eax
80108405:	83 e0 01             	and    $0x1,%eax
80108408:	85 c0                	test   %eax,%eax
8010840a:	75 07                	jne    80108413 <uva2ka+0x2f>
    return 0;
8010840c:	b8 00 00 00 00       	mov    $0x0,%eax
80108411:	eb 22                	jmp    80108435 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108416:	8b 00                	mov    (%eax),%eax
80108418:	83 e0 04             	and    $0x4,%eax
8010841b:	85 c0                	test   %eax,%eax
8010841d:	75 07                	jne    80108426 <uva2ka+0x42>
    return 0;
8010841f:	b8 00 00 00 00       	mov    $0x0,%eax
80108424:	eb 0f                	jmp    80108435 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108429:	8b 00                	mov    (%eax),%eax
8010842b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108430:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108435:	c9                   	leave  
80108436:	c3                   	ret    

80108437 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108437:	55                   	push   %ebp
80108438:	89 e5                	mov    %esp,%ebp
8010843a:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010843d:	8b 45 10             	mov    0x10(%ebp),%eax
80108440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108443:	eb 7f                	jmp    801084c4 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108445:	8b 45 0c             	mov    0xc(%ebp),%eax
80108448:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010844d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108453:	83 ec 08             	sub    $0x8,%esp
80108456:	50                   	push   %eax
80108457:	ff 75 08             	pushl  0x8(%ebp)
8010845a:	e8 85 ff ff ff       	call   801083e4 <uva2ka>
8010845f:	83 c4 10             	add    $0x10,%esp
80108462:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108465:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108469:	75 07                	jne    80108472 <copyout+0x3b>
      return -1;
8010846b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108470:	eb 61                	jmp    801084d3 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108475:	2b 45 0c             	sub    0xc(%ebp),%eax
80108478:	05 00 10 00 00       	add    $0x1000,%eax
8010847d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108483:	3b 45 14             	cmp    0x14(%ebp),%eax
80108486:	76 06                	jbe    8010848e <copyout+0x57>
      n = len;
80108488:	8b 45 14             	mov    0x14(%ebp),%eax
8010848b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010848e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108491:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108494:	89 c2                	mov    %eax,%edx
80108496:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108499:	01 d0                	add    %edx,%eax
8010849b:	83 ec 04             	sub    $0x4,%esp
8010849e:	ff 75 f0             	pushl  -0x10(%ebp)
801084a1:	ff 75 f4             	pushl  -0xc(%ebp)
801084a4:	50                   	push   %eax
801084a5:	e8 b4 ce ff ff       	call   8010535e <memmove>
801084aa:	83 c4 10             	add    $0x10,%esp
    len -= n;
801084ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b0:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801084b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b6:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084bc:	05 00 10 00 00       	add    $0x1000,%eax
801084c1:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801084c4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084c8:	0f 85 77 ff ff ff    	jne    80108445 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801084ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084d3:	c9                   	leave  
801084d4:	c3                   	ret    

801084d5 <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
801084d5:	55                   	push   %ebp
801084d6:	89 e5                	mov    %esp,%ebp
801084d8:	83 ec 18             	sub    $0x18,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
801084db:	83 ec 08             	sub    $0x8,%esp
801084de:	68 2e 8d 10 80       	push   $0x80108d2e
801084e3:	68 40 67 11 80       	push   $0x80116740
801084e8:	e8 19 cb ff ff       	call   80105006 <initlock>
801084ed:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
801084f0:	83 ec 0c             	sub    $0xc,%esp
801084f3:	68 40 67 11 80       	push   $0x80116740
801084f8:	e8 2b cb ff ff       	call   80105028 <acquire>
801084fd:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i< 64; i++) {
80108500:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108507:	eb 49                	jmp    80108552 <shminit+0x7d>
    shm_table.shm_pages[i].id =0;
80108509:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010850c:	89 d0                	mov    %edx,%eax
8010850e:	01 c0                	add    %eax,%eax
80108510:	01 d0                	add    %edx,%eax
80108512:	c1 e0 02             	shl    $0x2,%eax
80108515:	05 74 67 11 80       	add    $0x80116774,%eax
8010851a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80108520:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108523:	89 d0                	mov    %edx,%eax
80108525:	01 c0                	add    %eax,%eax
80108527:	01 d0                	add    %edx,%eax
80108529:	c1 e0 02             	shl    $0x2,%eax
8010852c:	05 78 67 11 80       	add    $0x80116778,%eax
80108531:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
80108537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010853a:	89 d0                	mov    %edx,%eax
8010853c:	01 c0                	add    %eax,%eax
8010853e:	01 d0                	add    %edx,%eax
80108540:	c1 e0 02             	shl    $0x2,%eax
80108543:	05 7c 67 11 80       	add    $0x8011677c,%eax
80108548:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
8010854e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108552:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80108556:	7e b1                	jle    80108509 <shminit+0x34>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
80108558:	83 ec 0c             	sub    $0xc,%esp
8010855b:	68 40 67 11 80       	push   $0x80116740
80108560:	e8 31 cb ff ff       	call   80105096 <release>
80108565:	83 c4 10             	add    $0x10,%esp
}
80108568:	90                   	nop
80108569:	c9                   	leave  
8010856a:	c3                   	ret    

8010856b <shm_open>:

int shm_open(int id, char **pointer) {
8010856b:	55                   	push   %ebp
8010856c:	89 e5                	mov    %esp,%ebp
//you write this




return 0; //added to remove compiler warning -- you should decide what to return
8010856e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108573:	5d                   	pop    %ebp
80108574:	c3                   	ret    

80108575 <shm_close>:


int shm_close(int id) {
80108575:	55                   	push   %ebp
80108576:	89 e5                	mov    %esp,%ebp
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
80108578:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010857d:	5d                   	pop    %ebp
8010857e:	c3                   	ret    
