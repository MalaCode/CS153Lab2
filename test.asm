
_test:     file format elf32-i386


Disassembly of section .text:

00001000 <test>:
#include "user.h"
#include "fcntl.h"


int test(int n)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 08             	sub    $0x8,%esp
   test(n+1);
    1006:	8b 45 08             	mov    0x8(%ebp),%eax
    1009:	83 c0 01             	add    $0x1,%eax
    100c:	83 ec 0c             	sub    $0xc,%esp
    100f:	50                   	push   %eax
    1010:	e8 eb ff ff ff       	call   1000 <test>
    1015:	83 c4 10             	add    $0x10,%esp
   return n;
    1018:	8b 45 08             	mov    0x8(%ebp),%eax
}
    101b:	c9                   	leave  
    101c:	c3                   	ret    

0000101d <main>:
int main(int argc, char *argv[])
{
    101d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1021:	83 e4 f0             	and    $0xfffffff0,%esp
    1024:	ff 71 fc             	pushl  -0x4(%ecx)
    1027:	55                   	push   %ebp
    1028:	89 e5                	mov    %esp,%ebp
    102a:	51                   	push   %ecx
    102b:	83 ec 14             	sub    $0x14,%esp
   int pid=0;
    102e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
   pid=fork();
    1035:	e8 91 02 00 00       	call   12cb <fork>
    103a:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if(pid==0){
    103d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1041:	75 2f                	jne    1072 <main+0x55>
   int x=1;
    1043:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
   printf(1, "address %x\n", &x);
    104a:	83 ec 04             	sub    $0x4,%esp
    104d:	8d 45 f0             	lea    -0x10(%ebp),%eax
    1050:	50                   	push   %eax
    1051:	68 5f 18 00 00       	push   $0x185f
    1056:	6a 01                	push   $0x1
    1058:	e8 fd 03 00 00       	call   145a <printf>
    105d:	83 c4 10             	add    $0x10,%esp
   test(1);
    1060:	83 ec 0c             	sub    $0xc,%esp
    1063:	6a 01                	push   $0x1
    1065:	e8 96 ff ff ff       	call   1000 <test>
    106a:	83 c4 10             	add    $0x10,%esp
   exit();
    106d:	e8 61 02 00 00       	call   12d3 <exit>
   }
   wait();
    1072:	e8 64 02 00 00       	call   12db <wait>
   exit();
    1077:	e8 57 02 00 00       	call   12d3 <exit>

0000107c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    107c:	55                   	push   %ebp
    107d:	89 e5                	mov    %esp,%ebp
    107f:	57                   	push   %edi
    1080:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1081:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1084:	8b 55 10             	mov    0x10(%ebp),%edx
    1087:	8b 45 0c             	mov    0xc(%ebp),%eax
    108a:	89 cb                	mov    %ecx,%ebx
    108c:	89 df                	mov    %ebx,%edi
    108e:	89 d1                	mov    %edx,%ecx
    1090:	fc                   	cld    
    1091:	f3 aa                	rep stos %al,%es:(%edi)
    1093:	89 ca                	mov    %ecx,%edx
    1095:	89 fb                	mov    %edi,%ebx
    1097:	89 5d 08             	mov    %ebx,0x8(%ebp)
    109a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    109d:	90                   	nop
    109e:	5b                   	pop    %ebx
    109f:	5f                   	pop    %edi
    10a0:	5d                   	pop    %ebp
    10a1:	c3                   	ret    

000010a2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    10a2:	55                   	push   %ebp
    10a3:	89 e5                	mov    %esp,%ebp
    10a5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    10a8:	8b 45 08             	mov    0x8(%ebp),%eax
    10ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    10ae:	90                   	nop
    10af:	8b 45 08             	mov    0x8(%ebp),%eax
    10b2:	8d 50 01             	lea    0x1(%eax),%edx
    10b5:	89 55 08             	mov    %edx,0x8(%ebp)
    10b8:	8b 55 0c             	mov    0xc(%ebp),%edx
    10bb:	8d 4a 01             	lea    0x1(%edx),%ecx
    10be:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10c1:	0f b6 12             	movzbl (%edx),%edx
    10c4:	88 10                	mov    %dl,(%eax)
    10c6:	0f b6 00             	movzbl (%eax),%eax
    10c9:	84 c0                	test   %al,%al
    10cb:	75 e2                	jne    10af <strcpy+0xd>
    ;
  return os;
    10cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10d0:	c9                   	leave  
    10d1:	c3                   	ret    

000010d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10d2:	55                   	push   %ebp
    10d3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10d5:	eb 08                	jmp    10df <strcmp+0xd>
    p++, q++;
    10d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10db:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10df:	8b 45 08             	mov    0x8(%ebp),%eax
    10e2:	0f b6 00             	movzbl (%eax),%eax
    10e5:	84 c0                	test   %al,%al
    10e7:	74 10                	je     10f9 <strcmp+0x27>
    10e9:	8b 45 08             	mov    0x8(%ebp),%eax
    10ec:	0f b6 10             	movzbl (%eax),%edx
    10ef:	8b 45 0c             	mov    0xc(%ebp),%eax
    10f2:	0f b6 00             	movzbl (%eax),%eax
    10f5:	38 c2                	cmp    %al,%dl
    10f7:	74 de                	je     10d7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10f9:	8b 45 08             	mov    0x8(%ebp),%eax
    10fc:	0f b6 00             	movzbl (%eax),%eax
    10ff:	0f b6 d0             	movzbl %al,%edx
    1102:	8b 45 0c             	mov    0xc(%ebp),%eax
    1105:	0f b6 00             	movzbl (%eax),%eax
    1108:	0f b6 c0             	movzbl %al,%eax
    110b:	29 c2                	sub    %eax,%edx
    110d:	89 d0                	mov    %edx,%eax
}
    110f:	5d                   	pop    %ebp
    1110:	c3                   	ret    

00001111 <strlen>:

uint
strlen(char *s)
{
    1111:	55                   	push   %ebp
    1112:	89 e5                	mov    %esp,%ebp
    1114:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1117:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    111e:	eb 04                	jmp    1124 <strlen+0x13>
    1120:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1124:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1127:	8b 45 08             	mov    0x8(%ebp),%eax
    112a:	01 d0                	add    %edx,%eax
    112c:	0f b6 00             	movzbl (%eax),%eax
    112f:	84 c0                	test   %al,%al
    1131:	75 ed                	jne    1120 <strlen+0xf>
    ;
  return n;
    1133:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1136:	c9                   	leave  
    1137:	c3                   	ret    

00001138 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1138:	55                   	push   %ebp
    1139:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    113b:	8b 45 10             	mov    0x10(%ebp),%eax
    113e:	50                   	push   %eax
    113f:	ff 75 0c             	pushl  0xc(%ebp)
    1142:	ff 75 08             	pushl  0x8(%ebp)
    1145:	e8 32 ff ff ff       	call   107c <stosb>
    114a:	83 c4 0c             	add    $0xc,%esp
  return dst;
    114d:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1150:	c9                   	leave  
    1151:	c3                   	ret    

00001152 <strchr>:

char*
strchr(const char *s, char c)
{
    1152:	55                   	push   %ebp
    1153:	89 e5                	mov    %esp,%ebp
    1155:	83 ec 04             	sub    $0x4,%esp
    1158:	8b 45 0c             	mov    0xc(%ebp),%eax
    115b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    115e:	eb 14                	jmp    1174 <strchr+0x22>
    if(*s == c)
    1160:	8b 45 08             	mov    0x8(%ebp),%eax
    1163:	0f b6 00             	movzbl (%eax),%eax
    1166:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1169:	75 05                	jne    1170 <strchr+0x1e>
      return (char*)s;
    116b:	8b 45 08             	mov    0x8(%ebp),%eax
    116e:	eb 13                	jmp    1183 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1170:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1174:	8b 45 08             	mov    0x8(%ebp),%eax
    1177:	0f b6 00             	movzbl (%eax),%eax
    117a:	84 c0                	test   %al,%al
    117c:	75 e2                	jne    1160 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    117e:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1183:	c9                   	leave  
    1184:	c3                   	ret    

00001185 <gets>:

char*
gets(char *buf, int max)
{
    1185:	55                   	push   %ebp
    1186:	89 e5                	mov    %esp,%ebp
    1188:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    118b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1192:	eb 42                	jmp    11d6 <gets+0x51>
    cc = read(0, &c, 1);
    1194:	83 ec 04             	sub    $0x4,%esp
    1197:	6a 01                	push   $0x1
    1199:	8d 45 ef             	lea    -0x11(%ebp),%eax
    119c:	50                   	push   %eax
    119d:	6a 00                	push   $0x0
    119f:	e8 47 01 00 00       	call   12eb <read>
    11a4:	83 c4 10             	add    $0x10,%esp
    11a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11ae:	7e 33                	jle    11e3 <gets+0x5e>
      break;
    buf[i++] = c;
    11b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11b3:	8d 50 01             	lea    0x1(%eax),%edx
    11b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11b9:	89 c2                	mov    %eax,%edx
    11bb:	8b 45 08             	mov    0x8(%ebp),%eax
    11be:	01 c2                	add    %eax,%edx
    11c0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ca:	3c 0a                	cmp    $0xa,%al
    11cc:	74 16                	je     11e4 <gets+0x5f>
    11ce:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11d2:	3c 0d                	cmp    $0xd,%al
    11d4:	74 0e                	je     11e4 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d9:	83 c0 01             	add    $0x1,%eax
    11dc:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11df:	7c b3                	jl     1194 <gets+0xf>
    11e1:	eb 01                	jmp    11e4 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11e3:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11e7:	8b 45 08             	mov    0x8(%ebp),%eax
    11ea:	01 d0                	add    %edx,%eax
    11ec:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11f2:	c9                   	leave  
    11f3:	c3                   	ret    

000011f4 <stat>:

int
stat(char *n, struct stat *st)
{
    11f4:	55                   	push   %ebp
    11f5:	89 e5                	mov    %esp,%ebp
    11f7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11fa:	83 ec 08             	sub    $0x8,%esp
    11fd:	6a 00                	push   $0x0
    11ff:	ff 75 08             	pushl  0x8(%ebp)
    1202:	e8 0c 01 00 00       	call   1313 <open>
    1207:	83 c4 10             	add    $0x10,%esp
    120a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    120d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1211:	79 07                	jns    121a <stat+0x26>
    return -1;
    1213:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1218:	eb 25                	jmp    123f <stat+0x4b>
  r = fstat(fd, st);
    121a:	83 ec 08             	sub    $0x8,%esp
    121d:	ff 75 0c             	pushl  0xc(%ebp)
    1220:	ff 75 f4             	pushl  -0xc(%ebp)
    1223:	e8 03 01 00 00       	call   132b <fstat>
    1228:	83 c4 10             	add    $0x10,%esp
    122b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    122e:	83 ec 0c             	sub    $0xc,%esp
    1231:	ff 75 f4             	pushl  -0xc(%ebp)
    1234:	e8 c2 00 00 00       	call   12fb <close>
    1239:	83 c4 10             	add    $0x10,%esp
  return r;
    123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    123f:	c9                   	leave  
    1240:	c3                   	ret    

00001241 <atoi>:

int
atoi(const char *s)
{
    1241:	55                   	push   %ebp
    1242:	89 e5                	mov    %esp,%ebp
    1244:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1247:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    124e:	eb 25                	jmp    1275 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1250:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1253:	89 d0                	mov    %edx,%eax
    1255:	c1 e0 02             	shl    $0x2,%eax
    1258:	01 d0                	add    %edx,%eax
    125a:	01 c0                	add    %eax,%eax
    125c:	89 c1                	mov    %eax,%ecx
    125e:	8b 45 08             	mov    0x8(%ebp),%eax
    1261:	8d 50 01             	lea    0x1(%eax),%edx
    1264:	89 55 08             	mov    %edx,0x8(%ebp)
    1267:	0f b6 00             	movzbl (%eax),%eax
    126a:	0f be c0             	movsbl %al,%eax
    126d:	01 c8                	add    %ecx,%eax
    126f:	83 e8 30             	sub    $0x30,%eax
    1272:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1275:	8b 45 08             	mov    0x8(%ebp),%eax
    1278:	0f b6 00             	movzbl (%eax),%eax
    127b:	3c 2f                	cmp    $0x2f,%al
    127d:	7e 0a                	jle    1289 <atoi+0x48>
    127f:	8b 45 08             	mov    0x8(%ebp),%eax
    1282:	0f b6 00             	movzbl (%eax),%eax
    1285:	3c 39                	cmp    $0x39,%al
    1287:	7e c7                	jle    1250 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1289:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    128c:	c9                   	leave  
    128d:	c3                   	ret    

0000128e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    128e:	55                   	push   %ebp
    128f:	89 e5                	mov    %esp,%ebp
    1291:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1294:	8b 45 08             	mov    0x8(%ebp),%eax
    1297:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    129a:	8b 45 0c             	mov    0xc(%ebp),%eax
    129d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    12a0:	eb 17                	jmp    12b9 <memmove+0x2b>
    *dst++ = *src++;
    12a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a5:	8d 50 01             	lea    0x1(%eax),%edx
    12a8:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12ae:	8d 4a 01             	lea    0x1(%edx),%ecx
    12b1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12b4:	0f b6 12             	movzbl (%edx),%edx
    12b7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12b9:	8b 45 10             	mov    0x10(%ebp),%eax
    12bc:	8d 50 ff             	lea    -0x1(%eax),%edx
    12bf:	89 55 10             	mov    %edx,0x10(%ebp)
    12c2:	85 c0                	test   %eax,%eax
    12c4:	7f dc                	jg     12a2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12c6:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12c9:	c9                   	leave  
    12ca:	c3                   	ret    

000012cb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12cb:	b8 01 00 00 00       	mov    $0x1,%eax
    12d0:	cd 40                	int    $0x40
    12d2:	c3                   	ret    

000012d3 <exit>:
SYSCALL(exit)
    12d3:	b8 02 00 00 00       	mov    $0x2,%eax
    12d8:	cd 40                	int    $0x40
    12da:	c3                   	ret    

000012db <wait>:
SYSCALL(wait)
    12db:	b8 03 00 00 00       	mov    $0x3,%eax
    12e0:	cd 40                	int    $0x40
    12e2:	c3                   	ret    

000012e3 <pipe>:
SYSCALL(pipe)
    12e3:	b8 04 00 00 00       	mov    $0x4,%eax
    12e8:	cd 40                	int    $0x40
    12ea:	c3                   	ret    

000012eb <read>:
SYSCALL(read)
    12eb:	b8 05 00 00 00       	mov    $0x5,%eax
    12f0:	cd 40                	int    $0x40
    12f2:	c3                   	ret    

000012f3 <write>:
SYSCALL(write)
    12f3:	b8 10 00 00 00       	mov    $0x10,%eax
    12f8:	cd 40                	int    $0x40
    12fa:	c3                   	ret    

000012fb <close>:
SYSCALL(close)
    12fb:	b8 15 00 00 00       	mov    $0x15,%eax
    1300:	cd 40                	int    $0x40
    1302:	c3                   	ret    

00001303 <kill>:
SYSCALL(kill)
    1303:	b8 06 00 00 00       	mov    $0x6,%eax
    1308:	cd 40                	int    $0x40
    130a:	c3                   	ret    

0000130b <exec>:
SYSCALL(exec)
    130b:	b8 07 00 00 00       	mov    $0x7,%eax
    1310:	cd 40                	int    $0x40
    1312:	c3                   	ret    

00001313 <open>:
SYSCALL(open)
    1313:	b8 0f 00 00 00       	mov    $0xf,%eax
    1318:	cd 40                	int    $0x40
    131a:	c3                   	ret    

0000131b <mknod>:
SYSCALL(mknod)
    131b:	b8 11 00 00 00       	mov    $0x11,%eax
    1320:	cd 40                	int    $0x40
    1322:	c3                   	ret    

00001323 <unlink>:
SYSCALL(unlink)
    1323:	b8 12 00 00 00       	mov    $0x12,%eax
    1328:	cd 40                	int    $0x40
    132a:	c3                   	ret    

0000132b <fstat>:
SYSCALL(fstat)
    132b:	b8 08 00 00 00       	mov    $0x8,%eax
    1330:	cd 40                	int    $0x40
    1332:	c3                   	ret    

00001333 <link>:
SYSCALL(link)
    1333:	b8 13 00 00 00       	mov    $0x13,%eax
    1338:	cd 40                	int    $0x40
    133a:	c3                   	ret    

0000133b <mkdir>:
SYSCALL(mkdir)
    133b:	b8 14 00 00 00       	mov    $0x14,%eax
    1340:	cd 40                	int    $0x40
    1342:	c3                   	ret    

00001343 <chdir>:
SYSCALL(chdir)
    1343:	b8 09 00 00 00       	mov    $0x9,%eax
    1348:	cd 40                	int    $0x40
    134a:	c3                   	ret    

0000134b <dup>:
SYSCALL(dup)
    134b:	b8 0a 00 00 00       	mov    $0xa,%eax
    1350:	cd 40                	int    $0x40
    1352:	c3                   	ret    

00001353 <getpid>:
SYSCALL(getpid)
    1353:	b8 0b 00 00 00       	mov    $0xb,%eax
    1358:	cd 40                	int    $0x40
    135a:	c3                   	ret    

0000135b <sbrk>:
SYSCALL(sbrk)
    135b:	b8 0c 00 00 00       	mov    $0xc,%eax
    1360:	cd 40                	int    $0x40
    1362:	c3                   	ret    

00001363 <sleep>:
SYSCALL(sleep)
    1363:	b8 0d 00 00 00       	mov    $0xd,%eax
    1368:	cd 40                	int    $0x40
    136a:	c3                   	ret    

0000136b <uptime>:
SYSCALL(uptime)
    136b:	b8 0e 00 00 00       	mov    $0xe,%eax
    1370:	cd 40                	int    $0x40
    1372:	c3                   	ret    

00001373 <shm_open>:
SYSCALL(shm_open)
    1373:	b8 16 00 00 00       	mov    $0x16,%eax
    1378:	cd 40                	int    $0x40
    137a:	c3                   	ret    

0000137b <shm_close>:
SYSCALL(shm_close)	
    137b:	b8 17 00 00 00       	mov    $0x17,%eax
    1380:	cd 40                	int    $0x40
    1382:	c3                   	ret    

00001383 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1383:	55                   	push   %ebp
    1384:	89 e5                	mov    %esp,%ebp
    1386:	83 ec 18             	sub    $0x18,%esp
    1389:	8b 45 0c             	mov    0xc(%ebp),%eax
    138c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    138f:	83 ec 04             	sub    $0x4,%esp
    1392:	6a 01                	push   $0x1
    1394:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1397:	50                   	push   %eax
    1398:	ff 75 08             	pushl  0x8(%ebp)
    139b:	e8 53 ff ff ff       	call   12f3 <write>
    13a0:	83 c4 10             	add    $0x10,%esp
}
    13a3:	90                   	nop
    13a4:	c9                   	leave  
    13a5:	c3                   	ret    

000013a6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13a6:	55                   	push   %ebp
    13a7:	89 e5                	mov    %esp,%ebp
    13a9:	53                   	push   %ebx
    13aa:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13b8:	74 17                	je     13d1 <printint+0x2b>
    13ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13be:	79 11                	jns    13d1 <printint+0x2b>
    neg = 1;
    13c0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13c7:	8b 45 0c             	mov    0xc(%ebp),%eax
    13ca:	f7 d8                	neg    %eax
    13cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13cf:	eb 06                	jmp    13d7 <printint+0x31>
  } else {
    x = xx;
    13d1:	8b 45 0c             	mov    0xc(%ebp),%eax
    13d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13de:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13e1:	8d 41 01             	lea    0x1(%ecx),%eax
    13e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13ed:	ba 00 00 00 00       	mov    $0x0,%edx
    13f2:	f7 f3                	div    %ebx
    13f4:	89 d0                	mov    %edx,%eax
    13f6:	0f b6 80 3c 1b 00 00 	movzbl 0x1b3c(%eax),%eax
    13fd:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1401:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1404:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1407:	ba 00 00 00 00       	mov    $0x0,%edx
    140c:	f7 f3                	div    %ebx
    140e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1411:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1415:	75 c7                	jne    13de <printint+0x38>
  if(neg)
    1417:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    141b:	74 2d                	je     144a <printint+0xa4>
    buf[i++] = '-';
    141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1420:	8d 50 01             	lea    0x1(%eax),%edx
    1423:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1426:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    142b:	eb 1d                	jmp    144a <printint+0xa4>
    putc(fd, buf[i]);
    142d:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1430:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1433:	01 d0                	add    %edx,%eax
    1435:	0f b6 00             	movzbl (%eax),%eax
    1438:	0f be c0             	movsbl %al,%eax
    143b:	83 ec 08             	sub    $0x8,%esp
    143e:	50                   	push   %eax
    143f:	ff 75 08             	pushl  0x8(%ebp)
    1442:	e8 3c ff ff ff       	call   1383 <putc>
    1447:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    144a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    144e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1452:	79 d9                	jns    142d <printint+0x87>
    putc(fd, buf[i]);
}
    1454:	90                   	nop
    1455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1458:	c9                   	leave  
    1459:	c3                   	ret    

0000145a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    145a:	55                   	push   %ebp
    145b:	89 e5                	mov    %esp,%ebp
    145d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1460:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1467:	8d 45 0c             	lea    0xc(%ebp),%eax
    146a:	83 c0 04             	add    $0x4,%eax
    146d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1470:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1477:	e9 59 01 00 00       	jmp    15d5 <printf+0x17b>
    c = fmt[i] & 0xff;
    147c:	8b 55 0c             	mov    0xc(%ebp),%edx
    147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1482:	01 d0                	add    %edx,%eax
    1484:	0f b6 00             	movzbl (%eax),%eax
    1487:	0f be c0             	movsbl %al,%eax
    148a:	25 ff 00 00 00       	and    $0xff,%eax
    148f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1492:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1496:	75 2c                	jne    14c4 <printf+0x6a>
      if(c == '%'){
    1498:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    149c:	75 0c                	jne    14aa <printf+0x50>
        state = '%';
    149e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14a5:	e9 27 01 00 00       	jmp    15d1 <printf+0x177>
      } else {
        putc(fd, c);
    14aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14ad:	0f be c0             	movsbl %al,%eax
    14b0:	83 ec 08             	sub    $0x8,%esp
    14b3:	50                   	push   %eax
    14b4:	ff 75 08             	pushl  0x8(%ebp)
    14b7:	e8 c7 fe ff ff       	call   1383 <putc>
    14bc:	83 c4 10             	add    $0x10,%esp
    14bf:	e9 0d 01 00 00       	jmp    15d1 <printf+0x177>
      }
    } else if(state == '%'){
    14c4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14c8:	0f 85 03 01 00 00    	jne    15d1 <printf+0x177>
      if(c == 'd'){
    14ce:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14d2:	75 1e                	jne    14f2 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14d7:	8b 00                	mov    (%eax),%eax
    14d9:	6a 01                	push   $0x1
    14db:	6a 0a                	push   $0xa
    14dd:	50                   	push   %eax
    14de:	ff 75 08             	pushl  0x8(%ebp)
    14e1:	e8 c0 fe ff ff       	call   13a6 <printint>
    14e6:	83 c4 10             	add    $0x10,%esp
        ap++;
    14e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14ed:	e9 d8 00 00 00       	jmp    15ca <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14f2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14f6:	74 06                	je     14fe <printf+0xa4>
    14f8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14fc:	75 1e                	jne    151c <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1501:	8b 00                	mov    (%eax),%eax
    1503:	6a 00                	push   $0x0
    1505:	6a 10                	push   $0x10
    1507:	50                   	push   %eax
    1508:	ff 75 08             	pushl  0x8(%ebp)
    150b:	e8 96 fe ff ff       	call   13a6 <printint>
    1510:	83 c4 10             	add    $0x10,%esp
        ap++;
    1513:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1517:	e9 ae 00 00 00       	jmp    15ca <printf+0x170>
      } else if(c == 's'){
    151c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1520:	75 43                	jne    1565 <printf+0x10b>
        s = (char*)*ap;
    1522:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1525:	8b 00                	mov    (%eax),%eax
    1527:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    152a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    152e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1532:	75 25                	jne    1559 <printf+0xff>
          s = "(null)";
    1534:	c7 45 f4 6b 18 00 00 	movl   $0x186b,-0xc(%ebp)
        while(*s != 0){
    153b:	eb 1c                	jmp    1559 <printf+0xff>
          putc(fd, *s);
    153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1540:	0f b6 00             	movzbl (%eax),%eax
    1543:	0f be c0             	movsbl %al,%eax
    1546:	83 ec 08             	sub    $0x8,%esp
    1549:	50                   	push   %eax
    154a:	ff 75 08             	pushl  0x8(%ebp)
    154d:	e8 31 fe ff ff       	call   1383 <putc>
    1552:	83 c4 10             	add    $0x10,%esp
          s++;
    1555:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1559:	8b 45 f4             	mov    -0xc(%ebp),%eax
    155c:	0f b6 00             	movzbl (%eax),%eax
    155f:	84 c0                	test   %al,%al
    1561:	75 da                	jne    153d <printf+0xe3>
    1563:	eb 65                	jmp    15ca <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1565:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1569:	75 1d                	jne    1588 <printf+0x12e>
        putc(fd, *ap);
    156b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    156e:	8b 00                	mov    (%eax),%eax
    1570:	0f be c0             	movsbl %al,%eax
    1573:	83 ec 08             	sub    $0x8,%esp
    1576:	50                   	push   %eax
    1577:	ff 75 08             	pushl  0x8(%ebp)
    157a:	e8 04 fe ff ff       	call   1383 <putc>
    157f:	83 c4 10             	add    $0x10,%esp
        ap++;
    1582:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1586:	eb 42                	jmp    15ca <printf+0x170>
      } else if(c == '%'){
    1588:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    158c:	75 17                	jne    15a5 <printf+0x14b>
        putc(fd, c);
    158e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1591:	0f be c0             	movsbl %al,%eax
    1594:	83 ec 08             	sub    $0x8,%esp
    1597:	50                   	push   %eax
    1598:	ff 75 08             	pushl  0x8(%ebp)
    159b:	e8 e3 fd ff ff       	call   1383 <putc>
    15a0:	83 c4 10             	add    $0x10,%esp
    15a3:	eb 25                	jmp    15ca <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15a5:	83 ec 08             	sub    $0x8,%esp
    15a8:	6a 25                	push   $0x25
    15aa:	ff 75 08             	pushl  0x8(%ebp)
    15ad:	e8 d1 fd ff ff       	call   1383 <putc>
    15b2:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    15b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15b8:	0f be c0             	movsbl %al,%eax
    15bb:	83 ec 08             	sub    $0x8,%esp
    15be:	50                   	push   %eax
    15bf:	ff 75 08             	pushl  0x8(%ebp)
    15c2:	e8 bc fd ff ff       	call   1383 <putc>
    15c7:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15d5:	8b 55 0c             	mov    0xc(%ebp),%edx
    15d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15db:	01 d0                	add    %edx,%eax
    15dd:	0f b6 00             	movzbl (%eax),%eax
    15e0:	84 c0                	test   %al,%al
    15e2:	0f 85 94 fe ff ff    	jne    147c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15e8:	90                   	nop
    15e9:	c9                   	leave  
    15ea:	c3                   	ret    

000015eb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15eb:	55                   	push   %ebp
    15ec:	89 e5                	mov    %esp,%ebp
    15ee:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15f1:	8b 45 08             	mov    0x8(%ebp),%eax
    15f4:	83 e8 08             	sub    $0x8,%eax
    15f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15fa:	a1 58 1b 00 00       	mov    0x1b58,%eax
    15ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1602:	eb 24                	jmp    1628 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1604:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1607:	8b 00                	mov    (%eax),%eax
    1609:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    160c:	77 12                	ja     1620 <free+0x35>
    160e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1611:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1614:	77 24                	ja     163a <free+0x4f>
    1616:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1619:	8b 00                	mov    (%eax),%eax
    161b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    161e:	77 1a                	ja     163a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1620:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1623:	8b 00                	mov    (%eax),%eax
    1625:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1628:	8b 45 f8             	mov    -0x8(%ebp),%eax
    162b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    162e:	76 d4                	jbe    1604 <free+0x19>
    1630:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1633:	8b 00                	mov    (%eax),%eax
    1635:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1638:	76 ca                	jbe    1604 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    163a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    163d:	8b 40 04             	mov    0x4(%eax),%eax
    1640:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1647:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164a:	01 c2                	add    %eax,%edx
    164c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164f:	8b 00                	mov    (%eax),%eax
    1651:	39 c2                	cmp    %eax,%edx
    1653:	75 24                	jne    1679 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1655:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1658:	8b 50 04             	mov    0x4(%eax),%edx
    165b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    165e:	8b 00                	mov    (%eax),%eax
    1660:	8b 40 04             	mov    0x4(%eax),%eax
    1663:	01 c2                	add    %eax,%edx
    1665:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1668:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    166b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166e:	8b 00                	mov    (%eax),%eax
    1670:	8b 10                	mov    (%eax),%edx
    1672:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1675:	89 10                	mov    %edx,(%eax)
    1677:	eb 0a                	jmp    1683 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1679:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167c:	8b 10                	mov    (%eax),%edx
    167e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1681:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1683:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1686:	8b 40 04             	mov    0x4(%eax),%eax
    1689:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1690:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1693:	01 d0                	add    %edx,%eax
    1695:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1698:	75 20                	jne    16ba <free+0xcf>
    p->s.size += bp->s.size;
    169a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169d:	8b 50 04             	mov    0x4(%eax),%edx
    16a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a3:	8b 40 04             	mov    0x4(%eax),%eax
    16a6:	01 c2                	add    %eax,%edx
    16a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ab:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b1:	8b 10                	mov    (%eax),%edx
    16b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b6:	89 10                	mov    %edx,(%eax)
    16b8:	eb 08                	jmp    16c2 <free+0xd7>
  } else
    p->s.ptr = bp;
    16ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16c0:	89 10                	mov    %edx,(%eax)
  freep = p;
    16c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c5:	a3 58 1b 00 00       	mov    %eax,0x1b58
}
    16ca:	90                   	nop
    16cb:	c9                   	leave  
    16cc:	c3                   	ret    

000016cd <morecore>:

static Header*
morecore(uint nu)
{
    16cd:	55                   	push   %ebp
    16ce:	89 e5                	mov    %esp,%ebp
    16d0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16d3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16da:	77 07                	ja     16e3 <morecore+0x16>
    nu = 4096;
    16dc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16e3:	8b 45 08             	mov    0x8(%ebp),%eax
    16e6:	c1 e0 03             	shl    $0x3,%eax
    16e9:	83 ec 0c             	sub    $0xc,%esp
    16ec:	50                   	push   %eax
    16ed:	e8 69 fc ff ff       	call   135b <sbrk>
    16f2:	83 c4 10             	add    $0x10,%esp
    16f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16f8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16fc:	75 07                	jne    1705 <morecore+0x38>
    return 0;
    16fe:	b8 00 00 00 00       	mov    $0x0,%eax
    1703:	eb 26                	jmp    172b <morecore+0x5e>
  hp = (Header*)p;
    1705:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1708:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    170e:	8b 55 08             	mov    0x8(%ebp),%edx
    1711:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1714:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1717:	83 c0 08             	add    $0x8,%eax
    171a:	83 ec 0c             	sub    $0xc,%esp
    171d:	50                   	push   %eax
    171e:	e8 c8 fe ff ff       	call   15eb <free>
    1723:	83 c4 10             	add    $0x10,%esp
  return freep;
    1726:	a1 58 1b 00 00       	mov    0x1b58,%eax
}
    172b:	c9                   	leave  
    172c:	c3                   	ret    

0000172d <malloc>:

void*
malloc(uint nbytes)
{
    172d:	55                   	push   %ebp
    172e:	89 e5                	mov    %esp,%ebp
    1730:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1733:	8b 45 08             	mov    0x8(%ebp),%eax
    1736:	83 c0 07             	add    $0x7,%eax
    1739:	c1 e8 03             	shr    $0x3,%eax
    173c:	83 c0 01             	add    $0x1,%eax
    173f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1742:	a1 58 1b 00 00       	mov    0x1b58,%eax
    1747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    174a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    174e:	75 23                	jne    1773 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1750:	c7 45 f0 50 1b 00 00 	movl   $0x1b50,-0x10(%ebp)
    1757:	8b 45 f0             	mov    -0x10(%ebp),%eax
    175a:	a3 58 1b 00 00       	mov    %eax,0x1b58
    175f:	a1 58 1b 00 00       	mov    0x1b58,%eax
    1764:	a3 50 1b 00 00       	mov    %eax,0x1b50
    base.s.size = 0;
    1769:	c7 05 54 1b 00 00 00 	movl   $0x0,0x1b54
    1770:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1773:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1776:	8b 00                	mov    (%eax),%eax
    1778:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177e:	8b 40 04             	mov    0x4(%eax),%eax
    1781:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1784:	72 4d                	jb     17d3 <malloc+0xa6>
      if(p->s.size == nunits)
    1786:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1789:	8b 40 04             	mov    0x4(%eax),%eax
    178c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    178f:	75 0c                	jne    179d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1791:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1794:	8b 10                	mov    (%eax),%edx
    1796:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1799:	89 10                	mov    %edx,(%eax)
    179b:	eb 26                	jmp    17c3 <malloc+0x96>
      else {
        p->s.size -= nunits;
    179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a0:	8b 40 04             	mov    0x4(%eax),%eax
    17a3:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17a6:	89 c2                	mov    %eax,%edx
    17a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ab:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b1:	8b 40 04             	mov    0x4(%eax),%eax
    17b4:	c1 e0 03             	shl    $0x3,%eax
    17b7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17c0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17c6:	a3 58 1b 00 00       	mov    %eax,0x1b58
      return (void*)(p + 1);
    17cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ce:	83 c0 08             	add    $0x8,%eax
    17d1:	eb 3b                	jmp    180e <malloc+0xe1>
    }
    if(p == freep)
    17d3:	a1 58 1b 00 00       	mov    0x1b58,%eax
    17d8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17db:	75 1e                	jne    17fb <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17dd:	83 ec 0c             	sub    $0xc,%esp
    17e0:	ff 75 ec             	pushl  -0x14(%ebp)
    17e3:	e8 e5 fe ff ff       	call   16cd <morecore>
    17e8:	83 c4 10             	add    $0x10,%esp
    17eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17f2:	75 07                	jne    17fb <malloc+0xce>
        return 0;
    17f4:	b8 00 00 00 00       	mov    $0x0,%eax
    17f9:	eb 13                	jmp    180e <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1801:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1804:	8b 00                	mov    (%eax),%eax
    1806:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1809:	e9 6d ff ff ff       	jmp    177b <malloc+0x4e>
}
    180e:	c9                   	leave  
    180f:	c3                   	ret    

00001810 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    1810:	55                   	push   %ebp
    1811:	89 e5                	mov    %esp,%ebp
    1813:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    1816:	8b 55 08             	mov    0x8(%ebp),%edx
    1819:	8b 45 0c             	mov    0xc(%ebp),%eax
    181c:	8b 4d 08             	mov    0x8(%ebp),%ecx
    181f:	f0 87 02             	lock xchg %eax,(%edx)
    1822:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    1825:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1828:	c9                   	leave  
    1829:	c3                   	ret    

0000182a <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    182a:	55                   	push   %ebp
    182b:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    182d:	90                   	nop
    182e:	8b 45 08             	mov    0x8(%ebp),%eax
    1831:	6a 01                	push   $0x1
    1833:	50                   	push   %eax
    1834:	e8 d7 ff ff ff       	call   1810 <xchg>
    1839:	83 c4 08             	add    $0x8,%esp
    183c:	85 c0                	test   %eax,%eax
    183e:	75 ee                	jne    182e <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1840:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1845:	90                   	nop
    1846:	c9                   	leave  
    1847:	c3                   	ret    

00001848 <urelease>:

void urelease (struct uspinlock *lk) {
    1848:	55                   	push   %ebp
    1849:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    184b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1850:	8b 45 08             	mov    0x8(%ebp),%eax
    1853:	8b 55 08             	mov    0x8(%ebp),%edx
    1856:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    185c:	90                   	nop
    185d:	5d                   	pop    %ebp
    185e:	c3                   	ret    
