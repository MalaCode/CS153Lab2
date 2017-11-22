
_kill:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	53                   	push   %ebx
    100e:	51                   	push   %ecx
    100f:	83 ec 10             	sub    $0x10,%esp
    1012:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
    1014:	83 3b 01             	cmpl   $0x1,(%ebx)
    1017:	7f 17                	jg     1030 <main+0x30>
    printf(2, "usage: kill pid...\n");
    1019:	83 ec 08             	sub    $0x8,%esp
    101c:	68 55 18 00 00       	push   $0x1855
    1021:	6a 02                	push   $0x2
    1023:	e8 28 04 00 00       	call   1450 <printf>
    1028:	83 c4 10             	add    $0x10,%esp
    exit();
    102b:	e8 99 02 00 00       	call   12c9 <exit>
  }
  for(i=1; i<argc; i++)
    1030:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    1037:	eb 2d                	jmp    1066 <main+0x66>
    kill(atoi(argv[i]));
    1039:	8b 45 f4             	mov    -0xc(%ebp),%eax
    103c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1043:	8b 43 04             	mov    0x4(%ebx),%eax
    1046:	01 d0                	add    %edx,%eax
    1048:	8b 00                	mov    (%eax),%eax
    104a:	83 ec 0c             	sub    $0xc,%esp
    104d:	50                   	push   %eax
    104e:	e8 e4 01 00 00       	call   1237 <atoi>
    1053:	83 c4 10             	add    $0x10,%esp
    1056:	83 ec 0c             	sub    $0xc,%esp
    1059:	50                   	push   %eax
    105a:	e8 9a 02 00 00       	call   12f9 <kill>
    105f:	83 c4 10             	add    $0x10,%esp

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
    1062:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1066:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1069:	3b 03                	cmp    (%ebx),%eax
    106b:	7c cc                	jl     1039 <main+0x39>
    kill(atoi(argv[i]));
  exit();
    106d:	e8 57 02 00 00       	call   12c9 <exit>

00001072 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1072:	55                   	push   %ebp
    1073:	89 e5                	mov    %esp,%ebp
    1075:	57                   	push   %edi
    1076:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1077:	8b 4d 08             	mov    0x8(%ebp),%ecx
    107a:	8b 55 10             	mov    0x10(%ebp),%edx
    107d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1080:	89 cb                	mov    %ecx,%ebx
    1082:	89 df                	mov    %ebx,%edi
    1084:	89 d1                	mov    %edx,%ecx
    1086:	fc                   	cld    
    1087:	f3 aa                	rep stos %al,%es:(%edi)
    1089:	89 ca                	mov    %ecx,%edx
    108b:	89 fb                	mov    %edi,%ebx
    108d:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1090:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1093:	90                   	nop
    1094:	5b                   	pop    %ebx
    1095:	5f                   	pop    %edi
    1096:	5d                   	pop    %ebp
    1097:	c3                   	ret    

00001098 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1098:	55                   	push   %ebp
    1099:	89 e5                	mov    %esp,%ebp
    109b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    109e:	8b 45 08             	mov    0x8(%ebp),%eax
    10a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    10a4:	90                   	nop
    10a5:	8b 45 08             	mov    0x8(%ebp),%eax
    10a8:	8d 50 01             	lea    0x1(%eax),%edx
    10ab:	89 55 08             	mov    %edx,0x8(%ebp)
    10ae:	8b 55 0c             	mov    0xc(%ebp),%edx
    10b1:	8d 4a 01             	lea    0x1(%edx),%ecx
    10b4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10b7:	0f b6 12             	movzbl (%edx),%edx
    10ba:	88 10                	mov    %dl,(%eax)
    10bc:	0f b6 00             	movzbl (%eax),%eax
    10bf:	84 c0                	test   %al,%al
    10c1:	75 e2                	jne    10a5 <strcpy+0xd>
    ;
  return os;
    10c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10c6:	c9                   	leave  
    10c7:	c3                   	ret    

000010c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10c8:	55                   	push   %ebp
    10c9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10cb:	eb 08                	jmp    10d5 <strcmp+0xd>
    p++, q++;
    10cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10d5:	8b 45 08             	mov    0x8(%ebp),%eax
    10d8:	0f b6 00             	movzbl (%eax),%eax
    10db:	84 c0                	test   %al,%al
    10dd:	74 10                	je     10ef <strcmp+0x27>
    10df:	8b 45 08             	mov    0x8(%ebp),%eax
    10e2:	0f b6 10             	movzbl (%eax),%edx
    10e5:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e8:	0f b6 00             	movzbl (%eax),%eax
    10eb:	38 c2                	cmp    %al,%dl
    10ed:	74 de                	je     10cd <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10ef:	8b 45 08             	mov    0x8(%ebp),%eax
    10f2:	0f b6 00             	movzbl (%eax),%eax
    10f5:	0f b6 d0             	movzbl %al,%edx
    10f8:	8b 45 0c             	mov    0xc(%ebp),%eax
    10fb:	0f b6 00             	movzbl (%eax),%eax
    10fe:	0f b6 c0             	movzbl %al,%eax
    1101:	29 c2                	sub    %eax,%edx
    1103:	89 d0                	mov    %edx,%eax
}
    1105:	5d                   	pop    %ebp
    1106:	c3                   	ret    

00001107 <strlen>:

uint
strlen(char *s)
{
    1107:	55                   	push   %ebp
    1108:	89 e5                	mov    %esp,%ebp
    110a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    110d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1114:	eb 04                	jmp    111a <strlen+0x13>
    1116:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    111a:	8b 55 fc             	mov    -0x4(%ebp),%edx
    111d:	8b 45 08             	mov    0x8(%ebp),%eax
    1120:	01 d0                	add    %edx,%eax
    1122:	0f b6 00             	movzbl (%eax),%eax
    1125:	84 c0                	test   %al,%al
    1127:	75 ed                	jne    1116 <strlen+0xf>
    ;
  return n;
    1129:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    112c:	c9                   	leave  
    112d:	c3                   	ret    

0000112e <memset>:

void*
memset(void *dst, int c, uint n)
{
    112e:	55                   	push   %ebp
    112f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1131:	8b 45 10             	mov    0x10(%ebp),%eax
    1134:	50                   	push   %eax
    1135:	ff 75 0c             	pushl  0xc(%ebp)
    1138:	ff 75 08             	pushl  0x8(%ebp)
    113b:	e8 32 ff ff ff       	call   1072 <stosb>
    1140:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1143:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1146:	c9                   	leave  
    1147:	c3                   	ret    

00001148 <strchr>:

char*
strchr(const char *s, char c)
{
    1148:	55                   	push   %ebp
    1149:	89 e5                	mov    %esp,%ebp
    114b:	83 ec 04             	sub    $0x4,%esp
    114e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1151:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1154:	eb 14                	jmp    116a <strchr+0x22>
    if(*s == c)
    1156:	8b 45 08             	mov    0x8(%ebp),%eax
    1159:	0f b6 00             	movzbl (%eax),%eax
    115c:	3a 45 fc             	cmp    -0x4(%ebp),%al
    115f:	75 05                	jne    1166 <strchr+0x1e>
      return (char*)s;
    1161:	8b 45 08             	mov    0x8(%ebp),%eax
    1164:	eb 13                	jmp    1179 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    116a:	8b 45 08             	mov    0x8(%ebp),%eax
    116d:	0f b6 00             	movzbl (%eax),%eax
    1170:	84 c0                	test   %al,%al
    1172:	75 e2                	jne    1156 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1174:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1179:	c9                   	leave  
    117a:	c3                   	ret    

0000117b <gets>:

char*
gets(char *buf, int max)
{
    117b:	55                   	push   %ebp
    117c:	89 e5                	mov    %esp,%ebp
    117e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1181:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1188:	eb 42                	jmp    11cc <gets+0x51>
    cc = read(0, &c, 1);
    118a:	83 ec 04             	sub    $0x4,%esp
    118d:	6a 01                	push   $0x1
    118f:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1192:	50                   	push   %eax
    1193:	6a 00                	push   $0x0
    1195:	e8 47 01 00 00       	call   12e1 <read>
    119a:	83 c4 10             	add    $0x10,%esp
    119d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11a4:	7e 33                	jle    11d9 <gets+0x5e>
      break;
    buf[i++] = c;
    11a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a9:	8d 50 01             	lea    0x1(%eax),%edx
    11ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11af:	89 c2                	mov    %eax,%edx
    11b1:	8b 45 08             	mov    0x8(%ebp),%eax
    11b4:	01 c2                	add    %eax,%edx
    11b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c0:	3c 0a                	cmp    $0xa,%al
    11c2:	74 16                	je     11da <gets+0x5f>
    11c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c8:	3c 0d                	cmp    $0xd,%al
    11ca:	74 0e                	je     11da <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11cf:	83 c0 01             	add    $0x1,%eax
    11d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11d5:	7c b3                	jl     118a <gets+0xf>
    11d7:	eb 01                	jmp    11da <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11d9:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11da:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11dd:	8b 45 08             	mov    0x8(%ebp),%eax
    11e0:	01 d0                	add    %edx,%eax
    11e2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11e8:	c9                   	leave  
    11e9:	c3                   	ret    

000011ea <stat>:

int
stat(char *n, struct stat *st)
{
    11ea:	55                   	push   %ebp
    11eb:	89 e5                	mov    %esp,%ebp
    11ed:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11f0:	83 ec 08             	sub    $0x8,%esp
    11f3:	6a 00                	push   $0x0
    11f5:	ff 75 08             	pushl  0x8(%ebp)
    11f8:	e8 0c 01 00 00       	call   1309 <open>
    11fd:	83 c4 10             	add    $0x10,%esp
    1200:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1203:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1207:	79 07                	jns    1210 <stat+0x26>
    return -1;
    1209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    120e:	eb 25                	jmp    1235 <stat+0x4b>
  r = fstat(fd, st);
    1210:	83 ec 08             	sub    $0x8,%esp
    1213:	ff 75 0c             	pushl  0xc(%ebp)
    1216:	ff 75 f4             	pushl  -0xc(%ebp)
    1219:	e8 03 01 00 00       	call   1321 <fstat>
    121e:	83 c4 10             	add    $0x10,%esp
    1221:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1224:	83 ec 0c             	sub    $0xc,%esp
    1227:	ff 75 f4             	pushl  -0xc(%ebp)
    122a:	e8 c2 00 00 00       	call   12f1 <close>
    122f:	83 c4 10             	add    $0x10,%esp
  return r;
    1232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1235:	c9                   	leave  
    1236:	c3                   	ret    

00001237 <atoi>:

int
atoi(const char *s)
{
    1237:	55                   	push   %ebp
    1238:	89 e5                	mov    %esp,%ebp
    123a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    123d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1244:	eb 25                	jmp    126b <atoi+0x34>
    n = n*10 + *s++ - '0';
    1246:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1249:	89 d0                	mov    %edx,%eax
    124b:	c1 e0 02             	shl    $0x2,%eax
    124e:	01 d0                	add    %edx,%eax
    1250:	01 c0                	add    %eax,%eax
    1252:	89 c1                	mov    %eax,%ecx
    1254:	8b 45 08             	mov    0x8(%ebp),%eax
    1257:	8d 50 01             	lea    0x1(%eax),%edx
    125a:	89 55 08             	mov    %edx,0x8(%ebp)
    125d:	0f b6 00             	movzbl (%eax),%eax
    1260:	0f be c0             	movsbl %al,%eax
    1263:	01 c8                	add    %ecx,%eax
    1265:	83 e8 30             	sub    $0x30,%eax
    1268:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    126b:	8b 45 08             	mov    0x8(%ebp),%eax
    126e:	0f b6 00             	movzbl (%eax),%eax
    1271:	3c 2f                	cmp    $0x2f,%al
    1273:	7e 0a                	jle    127f <atoi+0x48>
    1275:	8b 45 08             	mov    0x8(%ebp),%eax
    1278:	0f b6 00             	movzbl (%eax),%eax
    127b:	3c 39                	cmp    $0x39,%al
    127d:	7e c7                	jle    1246 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    127f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1282:	c9                   	leave  
    1283:	c3                   	ret    

00001284 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1284:	55                   	push   %ebp
    1285:	89 e5                	mov    %esp,%ebp
    1287:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    128a:	8b 45 08             	mov    0x8(%ebp),%eax
    128d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1290:	8b 45 0c             	mov    0xc(%ebp),%eax
    1293:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1296:	eb 17                	jmp    12af <memmove+0x2b>
    *dst++ = *src++;
    1298:	8b 45 fc             	mov    -0x4(%ebp),%eax
    129b:	8d 50 01             	lea    0x1(%eax),%edx
    129e:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12a1:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12a4:	8d 4a 01             	lea    0x1(%edx),%ecx
    12a7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12aa:	0f b6 12             	movzbl (%edx),%edx
    12ad:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12af:	8b 45 10             	mov    0x10(%ebp),%eax
    12b2:	8d 50 ff             	lea    -0x1(%eax),%edx
    12b5:	89 55 10             	mov    %edx,0x10(%ebp)
    12b8:	85 c0                	test   %eax,%eax
    12ba:	7f dc                	jg     1298 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12bf:	c9                   	leave  
    12c0:	c3                   	ret    

000012c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12c1:	b8 01 00 00 00       	mov    $0x1,%eax
    12c6:	cd 40                	int    $0x40
    12c8:	c3                   	ret    

000012c9 <exit>:
SYSCALL(exit)
    12c9:	b8 02 00 00 00       	mov    $0x2,%eax
    12ce:	cd 40                	int    $0x40
    12d0:	c3                   	ret    

000012d1 <wait>:
SYSCALL(wait)
    12d1:	b8 03 00 00 00       	mov    $0x3,%eax
    12d6:	cd 40                	int    $0x40
    12d8:	c3                   	ret    

000012d9 <pipe>:
SYSCALL(pipe)
    12d9:	b8 04 00 00 00       	mov    $0x4,%eax
    12de:	cd 40                	int    $0x40
    12e0:	c3                   	ret    

000012e1 <read>:
SYSCALL(read)
    12e1:	b8 05 00 00 00       	mov    $0x5,%eax
    12e6:	cd 40                	int    $0x40
    12e8:	c3                   	ret    

000012e9 <write>:
SYSCALL(write)
    12e9:	b8 10 00 00 00       	mov    $0x10,%eax
    12ee:	cd 40                	int    $0x40
    12f0:	c3                   	ret    

000012f1 <close>:
SYSCALL(close)
    12f1:	b8 15 00 00 00       	mov    $0x15,%eax
    12f6:	cd 40                	int    $0x40
    12f8:	c3                   	ret    

000012f9 <kill>:
SYSCALL(kill)
    12f9:	b8 06 00 00 00       	mov    $0x6,%eax
    12fe:	cd 40                	int    $0x40
    1300:	c3                   	ret    

00001301 <exec>:
SYSCALL(exec)
    1301:	b8 07 00 00 00       	mov    $0x7,%eax
    1306:	cd 40                	int    $0x40
    1308:	c3                   	ret    

00001309 <open>:
SYSCALL(open)
    1309:	b8 0f 00 00 00       	mov    $0xf,%eax
    130e:	cd 40                	int    $0x40
    1310:	c3                   	ret    

00001311 <mknod>:
SYSCALL(mknod)
    1311:	b8 11 00 00 00       	mov    $0x11,%eax
    1316:	cd 40                	int    $0x40
    1318:	c3                   	ret    

00001319 <unlink>:
SYSCALL(unlink)
    1319:	b8 12 00 00 00       	mov    $0x12,%eax
    131e:	cd 40                	int    $0x40
    1320:	c3                   	ret    

00001321 <fstat>:
SYSCALL(fstat)
    1321:	b8 08 00 00 00       	mov    $0x8,%eax
    1326:	cd 40                	int    $0x40
    1328:	c3                   	ret    

00001329 <link>:
SYSCALL(link)
    1329:	b8 13 00 00 00       	mov    $0x13,%eax
    132e:	cd 40                	int    $0x40
    1330:	c3                   	ret    

00001331 <mkdir>:
SYSCALL(mkdir)
    1331:	b8 14 00 00 00       	mov    $0x14,%eax
    1336:	cd 40                	int    $0x40
    1338:	c3                   	ret    

00001339 <chdir>:
SYSCALL(chdir)
    1339:	b8 09 00 00 00       	mov    $0x9,%eax
    133e:	cd 40                	int    $0x40
    1340:	c3                   	ret    

00001341 <dup>:
SYSCALL(dup)
    1341:	b8 0a 00 00 00       	mov    $0xa,%eax
    1346:	cd 40                	int    $0x40
    1348:	c3                   	ret    

00001349 <getpid>:
SYSCALL(getpid)
    1349:	b8 0b 00 00 00       	mov    $0xb,%eax
    134e:	cd 40                	int    $0x40
    1350:	c3                   	ret    

00001351 <sbrk>:
SYSCALL(sbrk)
    1351:	b8 0c 00 00 00       	mov    $0xc,%eax
    1356:	cd 40                	int    $0x40
    1358:	c3                   	ret    

00001359 <sleep>:
SYSCALL(sleep)
    1359:	b8 0d 00 00 00       	mov    $0xd,%eax
    135e:	cd 40                	int    $0x40
    1360:	c3                   	ret    

00001361 <uptime>:
SYSCALL(uptime)
    1361:	b8 0e 00 00 00       	mov    $0xe,%eax
    1366:	cd 40                	int    $0x40
    1368:	c3                   	ret    

00001369 <shm_open>:
SYSCALL(shm_open)
    1369:	b8 16 00 00 00       	mov    $0x16,%eax
    136e:	cd 40                	int    $0x40
    1370:	c3                   	ret    

00001371 <shm_close>:
SYSCALL(shm_close)	
    1371:	b8 17 00 00 00       	mov    $0x17,%eax
    1376:	cd 40                	int    $0x40
    1378:	c3                   	ret    

00001379 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1379:	55                   	push   %ebp
    137a:	89 e5                	mov    %esp,%ebp
    137c:	83 ec 18             	sub    $0x18,%esp
    137f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1382:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1385:	83 ec 04             	sub    $0x4,%esp
    1388:	6a 01                	push   $0x1
    138a:	8d 45 f4             	lea    -0xc(%ebp),%eax
    138d:	50                   	push   %eax
    138e:	ff 75 08             	pushl  0x8(%ebp)
    1391:	e8 53 ff ff ff       	call   12e9 <write>
    1396:	83 c4 10             	add    $0x10,%esp
}
    1399:	90                   	nop
    139a:	c9                   	leave  
    139b:	c3                   	ret    

0000139c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    139c:	55                   	push   %ebp
    139d:	89 e5                	mov    %esp,%ebp
    139f:	53                   	push   %ebx
    13a0:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13aa:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13ae:	74 17                	je     13c7 <printint+0x2b>
    13b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13b4:	79 11                	jns    13c7 <printint+0x2b>
    neg = 1;
    13b6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13bd:	8b 45 0c             	mov    0xc(%ebp),%eax
    13c0:	f7 d8                	neg    %eax
    13c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c5:	eb 06                	jmp    13cd <printint+0x31>
  } else {
    x = xx;
    13c7:	8b 45 0c             	mov    0xc(%ebp),%eax
    13ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13d4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13d7:	8d 41 01             	lea    0x1(%ecx),%eax
    13da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13e3:	ba 00 00 00 00       	mov    $0x0,%edx
    13e8:	f7 f3                	div    %ebx
    13ea:	89 d0                	mov    %edx,%eax
    13ec:	0f b6 80 1c 1b 00 00 	movzbl 0x1b1c(%eax),%eax
    13f3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13fd:	ba 00 00 00 00       	mov    $0x0,%edx
    1402:	f7 f3                	div    %ebx
    1404:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1407:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    140b:	75 c7                	jne    13d4 <printint+0x38>
  if(neg)
    140d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1411:	74 2d                	je     1440 <printint+0xa4>
    buf[i++] = '-';
    1413:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1416:	8d 50 01             	lea    0x1(%eax),%edx
    1419:	89 55 f4             	mov    %edx,-0xc(%ebp)
    141c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1421:	eb 1d                	jmp    1440 <printint+0xa4>
    putc(fd, buf[i]);
    1423:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1426:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1429:	01 d0                	add    %edx,%eax
    142b:	0f b6 00             	movzbl (%eax),%eax
    142e:	0f be c0             	movsbl %al,%eax
    1431:	83 ec 08             	sub    $0x8,%esp
    1434:	50                   	push   %eax
    1435:	ff 75 08             	pushl  0x8(%ebp)
    1438:	e8 3c ff ff ff       	call   1379 <putc>
    143d:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1440:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1444:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1448:	79 d9                	jns    1423 <printint+0x87>
    putc(fd, buf[i]);
}
    144a:	90                   	nop
    144b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    144e:	c9                   	leave  
    144f:	c3                   	ret    

00001450 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1450:	55                   	push   %ebp
    1451:	89 e5                	mov    %esp,%ebp
    1453:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1456:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    145d:	8d 45 0c             	lea    0xc(%ebp),%eax
    1460:	83 c0 04             	add    $0x4,%eax
    1463:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1466:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    146d:	e9 59 01 00 00       	jmp    15cb <printf+0x17b>
    c = fmt[i] & 0xff;
    1472:	8b 55 0c             	mov    0xc(%ebp),%edx
    1475:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1478:	01 d0                	add    %edx,%eax
    147a:	0f b6 00             	movzbl (%eax),%eax
    147d:	0f be c0             	movsbl %al,%eax
    1480:	25 ff 00 00 00       	and    $0xff,%eax
    1485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1488:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    148c:	75 2c                	jne    14ba <printf+0x6a>
      if(c == '%'){
    148e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1492:	75 0c                	jne    14a0 <printf+0x50>
        state = '%';
    1494:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    149b:	e9 27 01 00 00       	jmp    15c7 <printf+0x177>
      } else {
        putc(fd, c);
    14a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14a3:	0f be c0             	movsbl %al,%eax
    14a6:	83 ec 08             	sub    $0x8,%esp
    14a9:	50                   	push   %eax
    14aa:	ff 75 08             	pushl  0x8(%ebp)
    14ad:	e8 c7 fe ff ff       	call   1379 <putc>
    14b2:	83 c4 10             	add    $0x10,%esp
    14b5:	e9 0d 01 00 00       	jmp    15c7 <printf+0x177>
      }
    } else if(state == '%'){
    14ba:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14be:	0f 85 03 01 00 00    	jne    15c7 <printf+0x177>
      if(c == 'd'){
    14c4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14c8:	75 1e                	jne    14e8 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14cd:	8b 00                	mov    (%eax),%eax
    14cf:	6a 01                	push   $0x1
    14d1:	6a 0a                	push   $0xa
    14d3:	50                   	push   %eax
    14d4:	ff 75 08             	pushl  0x8(%ebp)
    14d7:	e8 c0 fe ff ff       	call   139c <printint>
    14dc:	83 c4 10             	add    $0x10,%esp
        ap++;
    14df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14e3:	e9 d8 00 00 00       	jmp    15c0 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14e8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14ec:	74 06                	je     14f4 <printf+0xa4>
    14ee:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14f2:	75 1e                	jne    1512 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14f7:	8b 00                	mov    (%eax),%eax
    14f9:	6a 00                	push   $0x0
    14fb:	6a 10                	push   $0x10
    14fd:	50                   	push   %eax
    14fe:	ff 75 08             	pushl  0x8(%ebp)
    1501:	e8 96 fe ff ff       	call   139c <printint>
    1506:	83 c4 10             	add    $0x10,%esp
        ap++;
    1509:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    150d:	e9 ae 00 00 00       	jmp    15c0 <printf+0x170>
      } else if(c == 's'){
    1512:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1516:	75 43                	jne    155b <printf+0x10b>
        s = (char*)*ap;
    1518:	8b 45 e8             	mov    -0x18(%ebp),%eax
    151b:	8b 00                	mov    (%eax),%eax
    151d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1520:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1524:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1528:	75 25                	jne    154f <printf+0xff>
          s = "(null)";
    152a:	c7 45 f4 69 18 00 00 	movl   $0x1869,-0xc(%ebp)
        while(*s != 0){
    1531:	eb 1c                	jmp    154f <printf+0xff>
          putc(fd, *s);
    1533:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1536:	0f b6 00             	movzbl (%eax),%eax
    1539:	0f be c0             	movsbl %al,%eax
    153c:	83 ec 08             	sub    $0x8,%esp
    153f:	50                   	push   %eax
    1540:	ff 75 08             	pushl  0x8(%ebp)
    1543:	e8 31 fe ff ff       	call   1379 <putc>
    1548:	83 c4 10             	add    $0x10,%esp
          s++;
    154b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    154f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1552:	0f b6 00             	movzbl (%eax),%eax
    1555:	84 c0                	test   %al,%al
    1557:	75 da                	jne    1533 <printf+0xe3>
    1559:	eb 65                	jmp    15c0 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    155b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    155f:	75 1d                	jne    157e <printf+0x12e>
        putc(fd, *ap);
    1561:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1564:	8b 00                	mov    (%eax),%eax
    1566:	0f be c0             	movsbl %al,%eax
    1569:	83 ec 08             	sub    $0x8,%esp
    156c:	50                   	push   %eax
    156d:	ff 75 08             	pushl  0x8(%ebp)
    1570:	e8 04 fe ff ff       	call   1379 <putc>
    1575:	83 c4 10             	add    $0x10,%esp
        ap++;
    1578:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    157c:	eb 42                	jmp    15c0 <printf+0x170>
      } else if(c == '%'){
    157e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1582:	75 17                	jne    159b <printf+0x14b>
        putc(fd, c);
    1584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1587:	0f be c0             	movsbl %al,%eax
    158a:	83 ec 08             	sub    $0x8,%esp
    158d:	50                   	push   %eax
    158e:	ff 75 08             	pushl  0x8(%ebp)
    1591:	e8 e3 fd ff ff       	call   1379 <putc>
    1596:	83 c4 10             	add    $0x10,%esp
    1599:	eb 25                	jmp    15c0 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    159b:	83 ec 08             	sub    $0x8,%esp
    159e:	6a 25                	push   $0x25
    15a0:	ff 75 08             	pushl  0x8(%ebp)
    15a3:	e8 d1 fd ff ff       	call   1379 <putc>
    15a8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    15ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15ae:	0f be c0             	movsbl %al,%eax
    15b1:	83 ec 08             	sub    $0x8,%esp
    15b4:	50                   	push   %eax
    15b5:	ff 75 08             	pushl  0x8(%ebp)
    15b8:	e8 bc fd ff ff       	call   1379 <putc>
    15bd:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15c7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15cb:	8b 55 0c             	mov    0xc(%ebp),%edx
    15ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15d1:	01 d0                	add    %edx,%eax
    15d3:	0f b6 00             	movzbl (%eax),%eax
    15d6:	84 c0                	test   %al,%al
    15d8:	0f 85 94 fe ff ff    	jne    1472 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15de:	90                   	nop
    15df:	c9                   	leave  
    15e0:	c3                   	ret    

000015e1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15e1:	55                   	push   %ebp
    15e2:	89 e5                	mov    %esp,%ebp
    15e4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15e7:	8b 45 08             	mov    0x8(%ebp),%eax
    15ea:	83 e8 08             	sub    $0x8,%eax
    15ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15f0:	a1 38 1b 00 00       	mov    0x1b38,%eax
    15f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15f8:	eb 24                	jmp    161e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15fd:	8b 00                	mov    (%eax),%eax
    15ff:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1602:	77 12                	ja     1616 <free+0x35>
    1604:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1607:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    160a:	77 24                	ja     1630 <free+0x4f>
    160c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    160f:	8b 00                	mov    (%eax),%eax
    1611:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1614:	77 1a                	ja     1630 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1616:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1619:	8b 00                	mov    (%eax),%eax
    161b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    161e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1621:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1624:	76 d4                	jbe    15fa <free+0x19>
    1626:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1629:	8b 00                	mov    (%eax),%eax
    162b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    162e:	76 ca                	jbe    15fa <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1630:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1633:	8b 40 04             	mov    0x4(%eax),%eax
    1636:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    163d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1640:	01 c2                	add    %eax,%edx
    1642:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1645:	8b 00                	mov    (%eax),%eax
    1647:	39 c2                	cmp    %eax,%edx
    1649:	75 24                	jne    166f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    164b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164e:	8b 50 04             	mov    0x4(%eax),%edx
    1651:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1654:	8b 00                	mov    (%eax),%eax
    1656:	8b 40 04             	mov    0x4(%eax),%eax
    1659:	01 c2                	add    %eax,%edx
    165b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    165e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1661:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1664:	8b 00                	mov    (%eax),%eax
    1666:	8b 10                	mov    (%eax),%edx
    1668:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166b:	89 10                	mov    %edx,(%eax)
    166d:	eb 0a                	jmp    1679 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    166f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1672:	8b 10                	mov    (%eax),%edx
    1674:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1677:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1679:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167c:	8b 40 04             	mov    0x4(%eax),%eax
    167f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1686:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1689:	01 d0                	add    %edx,%eax
    168b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    168e:	75 20                	jne    16b0 <free+0xcf>
    p->s.size += bp->s.size;
    1690:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1693:	8b 50 04             	mov    0x4(%eax),%edx
    1696:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1699:	8b 40 04             	mov    0x4(%eax),%eax
    169c:	01 c2                	add    %eax,%edx
    169e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a7:	8b 10                	mov    (%eax),%edx
    16a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ac:	89 10                	mov    %edx,(%eax)
    16ae:	eb 08                	jmp    16b8 <free+0xd7>
  } else
    p->s.ptr = bp;
    16b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16b6:	89 10                	mov    %edx,(%eax)
  freep = p;
    16b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16bb:	a3 38 1b 00 00       	mov    %eax,0x1b38
}
    16c0:	90                   	nop
    16c1:	c9                   	leave  
    16c2:	c3                   	ret    

000016c3 <morecore>:

static Header*
morecore(uint nu)
{
    16c3:	55                   	push   %ebp
    16c4:	89 e5                	mov    %esp,%ebp
    16c6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16d0:	77 07                	ja     16d9 <morecore+0x16>
    nu = 4096;
    16d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16d9:	8b 45 08             	mov    0x8(%ebp),%eax
    16dc:	c1 e0 03             	shl    $0x3,%eax
    16df:	83 ec 0c             	sub    $0xc,%esp
    16e2:	50                   	push   %eax
    16e3:	e8 69 fc ff ff       	call   1351 <sbrk>
    16e8:	83 c4 10             	add    $0x10,%esp
    16eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16f2:	75 07                	jne    16fb <morecore+0x38>
    return 0;
    16f4:	b8 00 00 00 00       	mov    $0x0,%eax
    16f9:	eb 26                	jmp    1721 <morecore+0x5e>
  hp = (Header*)p;
    16fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1701:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1704:	8b 55 08             	mov    0x8(%ebp),%edx
    1707:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    170d:	83 c0 08             	add    $0x8,%eax
    1710:	83 ec 0c             	sub    $0xc,%esp
    1713:	50                   	push   %eax
    1714:	e8 c8 fe ff ff       	call   15e1 <free>
    1719:	83 c4 10             	add    $0x10,%esp
  return freep;
    171c:	a1 38 1b 00 00       	mov    0x1b38,%eax
}
    1721:	c9                   	leave  
    1722:	c3                   	ret    

00001723 <malloc>:

void*
malloc(uint nbytes)
{
    1723:	55                   	push   %ebp
    1724:	89 e5                	mov    %esp,%ebp
    1726:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1729:	8b 45 08             	mov    0x8(%ebp),%eax
    172c:	83 c0 07             	add    $0x7,%eax
    172f:	c1 e8 03             	shr    $0x3,%eax
    1732:	83 c0 01             	add    $0x1,%eax
    1735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1738:	a1 38 1b 00 00       	mov    0x1b38,%eax
    173d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1740:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1744:	75 23                	jne    1769 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1746:	c7 45 f0 30 1b 00 00 	movl   $0x1b30,-0x10(%ebp)
    174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1750:	a3 38 1b 00 00       	mov    %eax,0x1b38
    1755:	a1 38 1b 00 00       	mov    0x1b38,%eax
    175a:	a3 30 1b 00 00       	mov    %eax,0x1b30
    base.s.size = 0;
    175f:	c7 05 34 1b 00 00 00 	movl   $0x0,0x1b34
    1766:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1769:	8b 45 f0             	mov    -0x10(%ebp),%eax
    176c:	8b 00                	mov    (%eax),%eax
    176e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1771:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1774:	8b 40 04             	mov    0x4(%eax),%eax
    1777:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    177a:	72 4d                	jb     17c9 <malloc+0xa6>
      if(p->s.size == nunits)
    177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177f:	8b 40 04             	mov    0x4(%eax),%eax
    1782:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1785:	75 0c                	jne    1793 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1787:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178a:	8b 10                	mov    (%eax),%edx
    178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    178f:	89 10                	mov    %edx,(%eax)
    1791:	eb 26                	jmp    17b9 <malloc+0x96>
      else {
        p->s.size -= nunits;
    1793:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1796:	8b 40 04             	mov    0x4(%eax),%eax
    1799:	2b 45 ec             	sub    -0x14(%ebp),%eax
    179c:	89 c2                	mov    %eax,%edx
    179e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a7:	8b 40 04             	mov    0x4(%eax),%eax
    17aa:	c1 e0 03             	shl    $0x3,%eax
    17ad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17b6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17bc:	a3 38 1b 00 00       	mov    %eax,0x1b38
      return (void*)(p + 1);
    17c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c4:	83 c0 08             	add    $0x8,%eax
    17c7:	eb 3b                	jmp    1804 <malloc+0xe1>
    }
    if(p == freep)
    17c9:	a1 38 1b 00 00       	mov    0x1b38,%eax
    17ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17d1:	75 1e                	jne    17f1 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17d3:	83 ec 0c             	sub    $0xc,%esp
    17d6:	ff 75 ec             	pushl  -0x14(%ebp)
    17d9:	e8 e5 fe ff ff       	call   16c3 <morecore>
    17de:	83 c4 10             	add    $0x10,%esp
    17e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17e8:	75 07                	jne    17f1 <malloc+0xce>
        return 0;
    17ea:	b8 00 00 00 00       	mov    $0x0,%eax
    17ef:	eb 13                	jmp    1804 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17fa:	8b 00                	mov    (%eax),%eax
    17fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17ff:	e9 6d ff ff ff       	jmp    1771 <malloc+0x4e>
}
    1804:	c9                   	leave  
    1805:	c3                   	ret    

00001806 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    1806:	55                   	push   %ebp
    1807:	89 e5                	mov    %esp,%ebp
    1809:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    180c:	8b 55 08             	mov    0x8(%ebp),%edx
    180f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1812:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1815:	f0 87 02             	lock xchg %eax,(%edx)
    1818:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    181b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    181e:	c9                   	leave  
    181f:	c3                   	ret    

00001820 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1820:	55                   	push   %ebp
    1821:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1823:	90                   	nop
    1824:	8b 45 08             	mov    0x8(%ebp),%eax
    1827:	6a 01                	push   $0x1
    1829:	50                   	push   %eax
    182a:	e8 d7 ff ff ff       	call   1806 <xchg>
    182f:	83 c4 08             	add    $0x8,%esp
    1832:	85 c0                	test   %eax,%eax
    1834:	75 ee                	jne    1824 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1836:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    183b:	90                   	nop
    183c:	c9                   	leave  
    183d:	c3                   	ret    

0000183e <urelease>:

void urelease (struct uspinlock *lk) {
    183e:	55                   	push   %ebp
    183f:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1841:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1846:	8b 45 08             	mov    0x8(%ebp),%eax
    1849:	8b 55 08             	mov    0x8(%ebp),%edx
    184c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1852:	90                   	nop
    1853:	5d                   	pop    %ebp
    1854:	c3                   	ret    
