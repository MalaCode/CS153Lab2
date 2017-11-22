
_ln:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	53                   	push   %ebx
    100e:	51                   	push   %ecx
    100f:	89 cb                	mov    %ecx,%ebx
  if(argc != 3){
    1011:	83 3b 03             	cmpl   $0x3,(%ebx)
    1014:	74 17                	je     102d <main+0x2d>
    printf(2, "Usage: ln old new\n");
    1016:	83 ec 08             	sub    $0x8,%esp
    1019:	68 57 18 00 00       	push   $0x1857
    101e:	6a 02                	push   $0x2
    1020:	e8 2d 04 00 00       	call   1452 <printf>
    1025:	83 c4 10             	add    $0x10,%esp
    exit();
    1028:	e8 9e 02 00 00       	call   12cb <exit>
  }
  if(link(argv[1], argv[2]) < 0)
    102d:	8b 43 04             	mov    0x4(%ebx),%eax
    1030:	83 c0 08             	add    $0x8,%eax
    1033:	8b 10                	mov    (%eax),%edx
    1035:	8b 43 04             	mov    0x4(%ebx),%eax
    1038:	83 c0 04             	add    $0x4,%eax
    103b:	8b 00                	mov    (%eax),%eax
    103d:	83 ec 08             	sub    $0x8,%esp
    1040:	52                   	push   %edx
    1041:	50                   	push   %eax
    1042:	e8 e4 02 00 00       	call   132b <link>
    1047:	83 c4 10             	add    $0x10,%esp
    104a:	85 c0                	test   %eax,%eax
    104c:	79 21                	jns    106f <main+0x6f>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
    104e:	8b 43 04             	mov    0x4(%ebx),%eax
    1051:	83 c0 08             	add    $0x8,%eax
    1054:	8b 10                	mov    (%eax),%edx
    1056:	8b 43 04             	mov    0x4(%ebx),%eax
    1059:	83 c0 04             	add    $0x4,%eax
    105c:	8b 00                	mov    (%eax),%eax
    105e:	52                   	push   %edx
    105f:	50                   	push   %eax
    1060:	68 6a 18 00 00       	push   $0x186a
    1065:	6a 02                	push   $0x2
    1067:	e8 e6 03 00 00       	call   1452 <printf>
    106c:	83 c4 10             	add    $0x10,%esp
  exit();
    106f:	e8 57 02 00 00       	call   12cb <exit>

00001074 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1074:	55                   	push   %ebp
    1075:	89 e5                	mov    %esp,%ebp
    1077:	57                   	push   %edi
    1078:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1079:	8b 4d 08             	mov    0x8(%ebp),%ecx
    107c:	8b 55 10             	mov    0x10(%ebp),%edx
    107f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1082:	89 cb                	mov    %ecx,%ebx
    1084:	89 df                	mov    %ebx,%edi
    1086:	89 d1                	mov    %edx,%ecx
    1088:	fc                   	cld    
    1089:	f3 aa                	rep stos %al,%es:(%edi)
    108b:	89 ca                	mov    %ecx,%edx
    108d:	89 fb                	mov    %edi,%ebx
    108f:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1092:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1095:	90                   	nop
    1096:	5b                   	pop    %ebx
    1097:	5f                   	pop    %edi
    1098:	5d                   	pop    %ebp
    1099:	c3                   	ret    

0000109a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    109a:	55                   	push   %ebp
    109b:	89 e5                	mov    %esp,%ebp
    109d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    10a0:	8b 45 08             	mov    0x8(%ebp),%eax
    10a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    10a6:	90                   	nop
    10a7:	8b 45 08             	mov    0x8(%ebp),%eax
    10aa:	8d 50 01             	lea    0x1(%eax),%edx
    10ad:	89 55 08             	mov    %edx,0x8(%ebp)
    10b0:	8b 55 0c             	mov    0xc(%ebp),%edx
    10b3:	8d 4a 01             	lea    0x1(%edx),%ecx
    10b6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10b9:	0f b6 12             	movzbl (%edx),%edx
    10bc:	88 10                	mov    %dl,(%eax)
    10be:	0f b6 00             	movzbl (%eax),%eax
    10c1:	84 c0                	test   %al,%al
    10c3:	75 e2                	jne    10a7 <strcpy+0xd>
    ;
  return os;
    10c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10c8:	c9                   	leave  
    10c9:	c3                   	ret    

000010ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10ca:	55                   	push   %ebp
    10cb:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10cd:	eb 08                	jmp    10d7 <strcmp+0xd>
    p++, q++;
    10cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10d3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10d7:	8b 45 08             	mov    0x8(%ebp),%eax
    10da:	0f b6 00             	movzbl (%eax),%eax
    10dd:	84 c0                	test   %al,%al
    10df:	74 10                	je     10f1 <strcmp+0x27>
    10e1:	8b 45 08             	mov    0x8(%ebp),%eax
    10e4:	0f b6 10             	movzbl (%eax),%edx
    10e7:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ea:	0f b6 00             	movzbl (%eax),%eax
    10ed:	38 c2                	cmp    %al,%dl
    10ef:	74 de                	je     10cf <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10f1:	8b 45 08             	mov    0x8(%ebp),%eax
    10f4:	0f b6 00             	movzbl (%eax),%eax
    10f7:	0f b6 d0             	movzbl %al,%edx
    10fa:	8b 45 0c             	mov    0xc(%ebp),%eax
    10fd:	0f b6 00             	movzbl (%eax),%eax
    1100:	0f b6 c0             	movzbl %al,%eax
    1103:	29 c2                	sub    %eax,%edx
    1105:	89 d0                	mov    %edx,%eax
}
    1107:	5d                   	pop    %ebp
    1108:	c3                   	ret    

00001109 <strlen>:

uint
strlen(char *s)
{
    1109:	55                   	push   %ebp
    110a:	89 e5                	mov    %esp,%ebp
    110c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    110f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1116:	eb 04                	jmp    111c <strlen+0x13>
    1118:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    111c:	8b 55 fc             	mov    -0x4(%ebp),%edx
    111f:	8b 45 08             	mov    0x8(%ebp),%eax
    1122:	01 d0                	add    %edx,%eax
    1124:	0f b6 00             	movzbl (%eax),%eax
    1127:	84 c0                	test   %al,%al
    1129:	75 ed                	jne    1118 <strlen+0xf>
    ;
  return n;
    112b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    112e:	c9                   	leave  
    112f:	c3                   	ret    

00001130 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1130:	55                   	push   %ebp
    1131:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1133:	8b 45 10             	mov    0x10(%ebp),%eax
    1136:	50                   	push   %eax
    1137:	ff 75 0c             	pushl  0xc(%ebp)
    113a:	ff 75 08             	pushl  0x8(%ebp)
    113d:	e8 32 ff ff ff       	call   1074 <stosb>
    1142:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1145:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1148:	c9                   	leave  
    1149:	c3                   	ret    

0000114a <strchr>:

char*
strchr(const char *s, char c)
{
    114a:	55                   	push   %ebp
    114b:	89 e5                	mov    %esp,%ebp
    114d:	83 ec 04             	sub    $0x4,%esp
    1150:	8b 45 0c             	mov    0xc(%ebp),%eax
    1153:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1156:	eb 14                	jmp    116c <strchr+0x22>
    if(*s == c)
    1158:	8b 45 08             	mov    0x8(%ebp),%eax
    115b:	0f b6 00             	movzbl (%eax),%eax
    115e:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1161:	75 05                	jne    1168 <strchr+0x1e>
      return (char*)s;
    1163:	8b 45 08             	mov    0x8(%ebp),%eax
    1166:	eb 13                	jmp    117b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    116c:	8b 45 08             	mov    0x8(%ebp),%eax
    116f:	0f b6 00             	movzbl (%eax),%eax
    1172:	84 c0                	test   %al,%al
    1174:	75 e2                	jne    1158 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1176:	b8 00 00 00 00       	mov    $0x0,%eax
}
    117b:	c9                   	leave  
    117c:	c3                   	ret    

0000117d <gets>:

char*
gets(char *buf, int max)
{
    117d:	55                   	push   %ebp
    117e:	89 e5                	mov    %esp,%ebp
    1180:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    118a:	eb 42                	jmp    11ce <gets+0x51>
    cc = read(0, &c, 1);
    118c:	83 ec 04             	sub    $0x4,%esp
    118f:	6a 01                	push   $0x1
    1191:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1194:	50                   	push   %eax
    1195:	6a 00                	push   $0x0
    1197:	e8 47 01 00 00       	call   12e3 <read>
    119c:	83 c4 10             	add    $0x10,%esp
    119f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11a6:	7e 33                	jle    11db <gets+0x5e>
      break;
    buf[i++] = c;
    11a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ab:	8d 50 01             	lea    0x1(%eax),%edx
    11ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11b1:	89 c2                	mov    %eax,%edx
    11b3:	8b 45 08             	mov    0x8(%ebp),%eax
    11b6:	01 c2                	add    %eax,%edx
    11b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11bc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11be:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11c2:	3c 0a                	cmp    $0xa,%al
    11c4:	74 16                	je     11dc <gets+0x5f>
    11c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ca:	3c 0d                	cmp    $0xd,%al
    11cc:	74 0e                	je     11dc <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d1:	83 c0 01             	add    $0x1,%eax
    11d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11d7:	7c b3                	jl     118c <gets+0xf>
    11d9:	eb 01                	jmp    11dc <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11db:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11df:	8b 45 08             	mov    0x8(%ebp),%eax
    11e2:	01 d0                	add    %edx,%eax
    11e4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11ea:	c9                   	leave  
    11eb:	c3                   	ret    

000011ec <stat>:

int
stat(char *n, struct stat *st)
{
    11ec:	55                   	push   %ebp
    11ed:	89 e5                	mov    %esp,%ebp
    11ef:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11f2:	83 ec 08             	sub    $0x8,%esp
    11f5:	6a 00                	push   $0x0
    11f7:	ff 75 08             	pushl  0x8(%ebp)
    11fa:	e8 0c 01 00 00       	call   130b <open>
    11ff:	83 c4 10             	add    $0x10,%esp
    1202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1209:	79 07                	jns    1212 <stat+0x26>
    return -1;
    120b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1210:	eb 25                	jmp    1237 <stat+0x4b>
  r = fstat(fd, st);
    1212:	83 ec 08             	sub    $0x8,%esp
    1215:	ff 75 0c             	pushl  0xc(%ebp)
    1218:	ff 75 f4             	pushl  -0xc(%ebp)
    121b:	e8 03 01 00 00       	call   1323 <fstat>
    1220:	83 c4 10             	add    $0x10,%esp
    1223:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1226:	83 ec 0c             	sub    $0xc,%esp
    1229:	ff 75 f4             	pushl  -0xc(%ebp)
    122c:	e8 c2 00 00 00       	call   12f3 <close>
    1231:	83 c4 10             	add    $0x10,%esp
  return r;
    1234:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1237:	c9                   	leave  
    1238:	c3                   	ret    

00001239 <atoi>:

int
atoi(const char *s)
{
    1239:	55                   	push   %ebp
    123a:	89 e5                	mov    %esp,%ebp
    123c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    123f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1246:	eb 25                	jmp    126d <atoi+0x34>
    n = n*10 + *s++ - '0';
    1248:	8b 55 fc             	mov    -0x4(%ebp),%edx
    124b:	89 d0                	mov    %edx,%eax
    124d:	c1 e0 02             	shl    $0x2,%eax
    1250:	01 d0                	add    %edx,%eax
    1252:	01 c0                	add    %eax,%eax
    1254:	89 c1                	mov    %eax,%ecx
    1256:	8b 45 08             	mov    0x8(%ebp),%eax
    1259:	8d 50 01             	lea    0x1(%eax),%edx
    125c:	89 55 08             	mov    %edx,0x8(%ebp)
    125f:	0f b6 00             	movzbl (%eax),%eax
    1262:	0f be c0             	movsbl %al,%eax
    1265:	01 c8                	add    %ecx,%eax
    1267:	83 e8 30             	sub    $0x30,%eax
    126a:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    126d:	8b 45 08             	mov    0x8(%ebp),%eax
    1270:	0f b6 00             	movzbl (%eax),%eax
    1273:	3c 2f                	cmp    $0x2f,%al
    1275:	7e 0a                	jle    1281 <atoi+0x48>
    1277:	8b 45 08             	mov    0x8(%ebp),%eax
    127a:	0f b6 00             	movzbl (%eax),%eax
    127d:	3c 39                	cmp    $0x39,%al
    127f:	7e c7                	jle    1248 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1284:	c9                   	leave  
    1285:	c3                   	ret    

00001286 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1286:	55                   	push   %ebp
    1287:	89 e5                	mov    %esp,%ebp
    1289:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    128c:	8b 45 08             	mov    0x8(%ebp),%eax
    128f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1292:	8b 45 0c             	mov    0xc(%ebp),%eax
    1295:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1298:	eb 17                	jmp    12b1 <memmove+0x2b>
    *dst++ = *src++;
    129a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    129d:	8d 50 01             	lea    0x1(%eax),%edx
    12a0:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12a6:	8d 4a 01             	lea    0x1(%edx),%ecx
    12a9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12ac:	0f b6 12             	movzbl (%edx),%edx
    12af:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12b1:	8b 45 10             	mov    0x10(%ebp),%eax
    12b4:	8d 50 ff             	lea    -0x1(%eax),%edx
    12b7:	89 55 10             	mov    %edx,0x10(%ebp)
    12ba:	85 c0                	test   %eax,%eax
    12bc:	7f dc                	jg     129a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12be:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12c1:	c9                   	leave  
    12c2:	c3                   	ret    

000012c3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12c3:	b8 01 00 00 00       	mov    $0x1,%eax
    12c8:	cd 40                	int    $0x40
    12ca:	c3                   	ret    

000012cb <exit>:
SYSCALL(exit)
    12cb:	b8 02 00 00 00       	mov    $0x2,%eax
    12d0:	cd 40                	int    $0x40
    12d2:	c3                   	ret    

000012d3 <wait>:
SYSCALL(wait)
    12d3:	b8 03 00 00 00       	mov    $0x3,%eax
    12d8:	cd 40                	int    $0x40
    12da:	c3                   	ret    

000012db <pipe>:
SYSCALL(pipe)
    12db:	b8 04 00 00 00       	mov    $0x4,%eax
    12e0:	cd 40                	int    $0x40
    12e2:	c3                   	ret    

000012e3 <read>:
SYSCALL(read)
    12e3:	b8 05 00 00 00       	mov    $0x5,%eax
    12e8:	cd 40                	int    $0x40
    12ea:	c3                   	ret    

000012eb <write>:
SYSCALL(write)
    12eb:	b8 10 00 00 00       	mov    $0x10,%eax
    12f0:	cd 40                	int    $0x40
    12f2:	c3                   	ret    

000012f3 <close>:
SYSCALL(close)
    12f3:	b8 15 00 00 00       	mov    $0x15,%eax
    12f8:	cd 40                	int    $0x40
    12fa:	c3                   	ret    

000012fb <kill>:
SYSCALL(kill)
    12fb:	b8 06 00 00 00       	mov    $0x6,%eax
    1300:	cd 40                	int    $0x40
    1302:	c3                   	ret    

00001303 <exec>:
SYSCALL(exec)
    1303:	b8 07 00 00 00       	mov    $0x7,%eax
    1308:	cd 40                	int    $0x40
    130a:	c3                   	ret    

0000130b <open>:
SYSCALL(open)
    130b:	b8 0f 00 00 00       	mov    $0xf,%eax
    1310:	cd 40                	int    $0x40
    1312:	c3                   	ret    

00001313 <mknod>:
SYSCALL(mknod)
    1313:	b8 11 00 00 00       	mov    $0x11,%eax
    1318:	cd 40                	int    $0x40
    131a:	c3                   	ret    

0000131b <unlink>:
SYSCALL(unlink)
    131b:	b8 12 00 00 00       	mov    $0x12,%eax
    1320:	cd 40                	int    $0x40
    1322:	c3                   	ret    

00001323 <fstat>:
SYSCALL(fstat)
    1323:	b8 08 00 00 00       	mov    $0x8,%eax
    1328:	cd 40                	int    $0x40
    132a:	c3                   	ret    

0000132b <link>:
SYSCALL(link)
    132b:	b8 13 00 00 00       	mov    $0x13,%eax
    1330:	cd 40                	int    $0x40
    1332:	c3                   	ret    

00001333 <mkdir>:
SYSCALL(mkdir)
    1333:	b8 14 00 00 00       	mov    $0x14,%eax
    1338:	cd 40                	int    $0x40
    133a:	c3                   	ret    

0000133b <chdir>:
SYSCALL(chdir)
    133b:	b8 09 00 00 00       	mov    $0x9,%eax
    1340:	cd 40                	int    $0x40
    1342:	c3                   	ret    

00001343 <dup>:
SYSCALL(dup)
    1343:	b8 0a 00 00 00       	mov    $0xa,%eax
    1348:	cd 40                	int    $0x40
    134a:	c3                   	ret    

0000134b <getpid>:
SYSCALL(getpid)
    134b:	b8 0b 00 00 00       	mov    $0xb,%eax
    1350:	cd 40                	int    $0x40
    1352:	c3                   	ret    

00001353 <sbrk>:
SYSCALL(sbrk)
    1353:	b8 0c 00 00 00       	mov    $0xc,%eax
    1358:	cd 40                	int    $0x40
    135a:	c3                   	ret    

0000135b <sleep>:
SYSCALL(sleep)
    135b:	b8 0d 00 00 00       	mov    $0xd,%eax
    1360:	cd 40                	int    $0x40
    1362:	c3                   	ret    

00001363 <uptime>:
SYSCALL(uptime)
    1363:	b8 0e 00 00 00       	mov    $0xe,%eax
    1368:	cd 40                	int    $0x40
    136a:	c3                   	ret    

0000136b <shm_open>:
SYSCALL(shm_open)
    136b:	b8 16 00 00 00       	mov    $0x16,%eax
    1370:	cd 40                	int    $0x40
    1372:	c3                   	ret    

00001373 <shm_close>:
SYSCALL(shm_close)	
    1373:	b8 17 00 00 00       	mov    $0x17,%eax
    1378:	cd 40                	int    $0x40
    137a:	c3                   	ret    

0000137b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    137b:	55                   	push   %ebp
    137c:	89 e5                	mov    %esp,%ebp
    137e:	83 ec 18             	sub    $0x18,%esp
    1381:	8b 45 0c             	mov    0xc(%ebp),%eax
    1384:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1387:	83 ec 04             	sub    $0x4,%esp
    138a:	6a 01                	push   $0x1
    138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
    138f:	50                   	push   %eax
    1390:	ff 75 08             	pushl  0x8(%ebp)
    1393:	e8 53 ff ff ff       	call   12eb <write>
    1398:	83 c4 10             	add    $0x10,%esp
}
    139b:	90                   	nop
    139c:	c9                   	leave  
    139d:	c3                   	ret    

0000139e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    139e:	55                   	push   %ebp
    139f:	89 e5                	mov    %esp,%ebp
    13a1:	53                   	push   %ebx
    13a2:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13ac:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13b0:	74 17                	je     13c9 <printint+0x2b>
    13b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13b6:	79 11                	jns    13c9 <printint+0x2b>
    neg = 1;
    13b8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13bf:	8b 45 0c             	mov    0xc(%ebp),%eax
    13c2:	f7 d8                	neg    %eax
    13c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c7:	eb 06                	jmp    13cf <printint+0x31>
  } else {
    x = xx;
    13c9:	8b 45 0c             	mov    0xc(%ebp),%eax
    13cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13d6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13d9:	8d 41 01             	lea    0x1(%ecx),%eax
    13dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13df:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13e5:	ba 00 00 00 00       	mov    $0x0,%edx
    13ea:	f7 f3                	div    %ebx
    13ec:	89 d0                	mov    %edx,%eax
    13ee:	0f b6 80 34 1b 00 00 	movzbl 0x1b34(%eax),%eax
    13f5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13ff:	ba 00 00 00 00       	mov    $0x0,%edx
    1404:	f7 f3                	div    %ebx
    1406:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1409:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    140d:	75 c7                	jne    13d6 <printint+0x38>
  if(neg)
    140f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1413:	74 2d                	je     1442 <printint+0xa4>
    buf[i++] = '-';
    1415:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1418:	8d 50 01             	lea    0x1(%eax),%edx
    141b:	89 55 f4             	mov    %edx,-0xc(%ebp)
    141e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1423:	eb 1d                	jmp    1442 <printint+0xa4>
    putc(fd, buf[i]);
    1425:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1428:	8b 45 f4             	mov    -0xc(%ebp),%eax
    142b:	01 d0                	add    %edx,%eax
    142d:	0f b6 00             	movzbl (%eax),%eax
    1430:	0f be c0             	movsbl %al,%eax
    1433:	83 ec 08             	sub    $0x8,%esp
    1436:	50                   	push   %eax
    1437:	ff 75 08             	pushl  0x8(%ebp)
    143a:	e8 3c ff ff ff       	call   137b <putc>
    143f:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1442:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1446:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    144a:	79 d9                	jns    1425 <printint+0x87>
    putc(fd, buf[i]);
}
    144c:	90                   	nop
    144d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1450:	c9                   	leave  
    1451:	c3                   	ret    

00001452 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1452:	55                   	push   %ebp
    1453:	89 e5                	mov    %esp,%ebp
    1455:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1458:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    145f:	8d 45 0c             	lea    0xc(%ebp),%eax
    1462:	83 c0 04             	add    $0x4,%eax
    1465:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1468:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    146f:	e9 59 01 00 00       	jmp    15cd <printf+0x17b>
    c = fmt[i] & 0xff;
    1474:	8b 55 0c             	mov    0xc(%ebp),%edx
    1477:	8b 45 f0             	mov    -0x10(%ebp),%eax
    147a:	01 d0                	add    %edx,%eax
    147c:	0f b6 00             	movzbl (%eax),%eax
    147f:	0f be c0             	movsbl %al,%eax
    1482:	25 ff 00 00 00       	and    $0xff,%eax
    1487:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    148a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    148e:	75 2c                	jne    14bc <printf+0x6a>
      if(c == '%'){
    1490:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1494:	75 0c                	jne    14a2 <printf+0x50>
        state = '%';
    1496:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    149d:	e9 27 01 00 00       	jmp    15c9 <printf+0x177>
      } else {
        putc(fd, c);
    14a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14a5:	0f be c0             	movsbl %al,%eax
    14a8:	83 ec 08             	sub    $0x8,%esp
    14ab:	50                   	push   %eax
    14ac:	ff 75 08             	pushl  0x8(%ebp)
    14af:	e8 c7 fe ff ff       	call   137b <putc>
    14b4:	83 c4 10             	add    $0x10,%esp
    14b7:	e9 0d 01 00 00       	jmp    15c9 <printf+0x177>
      }
    } else if(state == '%'){
    14bc:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14c0:	0f 85 03 01 00 00    	jne    15c9 <printf+0x177>
      if(c == 'd'){
    14c6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14ca:	75 1e                	jne    14ea <printf+0x98>
        printint(fd, *ap, 10, 1);
    14cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14cf:	8b 00                	mov    (%eax),%eax
    14d1:	6a 01                	push   $0x1
    14d3:	6a 0a                	push   $0xa
    14d5:	50                   	push   %eax
    14d6:	ff 75 08             	pushl  0x8(%ebp)
    14d9:	e8 c0 fe ff ff       	call   139e <printint>
    14de:	83 c4 10             	add    $0x10,%esp
        ap++;
    14e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14e5:	e9 d8 00 00 00       	jmp    15c2 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14ea:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14ee:	74 06                	je     14f6 <printf+0xa4>
    14f0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14f4:	75 1e                	jne    1514 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14f9:	8b 00                	mov    (%eax),%eax
    14fb:	6a 00                	push   $0x0
    14fd:	6a 10                	push   $0x10
    14ff:	50                   	push   %eax
    1500:	ff 75 08             	pushl  0x8(%ebp)
    1503:	e8 96 fe ff ff       	call   139e <printint>
    1508:	83 c4 10             	add    $0x10,%esp
        ap++;
    150b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    150f:	e9 ae 00 00 00       	jmp    15c2 <printf+0x170>
      } else if(c == 's'){
    1514:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1518:	75 43                	jne    155d <printf+0x10b>
        s = (char*)*ap;
    151a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    151d:	8b 00                	mov    (%eax),%eax
    151f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1522:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1526:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    152a:	75 25                	jne    1551 <printf+0xff>
          s = "(null)";
    152c:	c7 45 f4 7e 18 00 00 	movl   $0x187e,-0xc(%ebp)
        while(*s != 0){
    1533:	eb 1c                	jmp    1551 <printf+0xff>
          putc(fd, *s);
    1535:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1538:	0f b6 00             	movzbl (%eax),%eax
    153b:	0f be c0             	movsbl %al,%eax
    153e:	83 ec 08             	sub    $0x8,%esp
    1541:	50                   	push   %eax
    1542:	ff 75 08             	pushl  0x8(%ebp)
    1545:	e8 31 fe ff ff       	call   137b <putc>
    154a:	83 c4 10             	add    $0x10,%esp
          s++;
    154d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1551:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1554:	0f b6 00             	movzbl (%eax),%eax
    1557:	84 c0                	test   %al,%al
    1559:	75 da                	jne    1535 <printf+0xe3>
    155b:	eb 65                	jmp    15c2 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    155d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1561:	75 1d                	jne    1580 <printf+0x12e>
        putc(fd, *ap);
    1563:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1566:	8b 00                	mov    (%eax),%eax
    1568:	0f be c0             	movsbl %al,%eax
    156b:	83 ec 08             	sub    $0x8,%esp
    156e:	50                   	push   %eax
    156f:	ff 75 08             	pushl  0x8(%ebp)
    1572:	e8 04 fe ff ff       	call   137b <putc>
    1577:	83 c4 10             	add    $0x10,%esp
        ap++;
    157a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    157e:	eb 42                	jmp    15c2 <printf+0x170>
      } else if(c == '%'){
    1580:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1584:	75 17                	jne    159d <printf+0x14b>
        putc(fd, c);
    1586:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1589:	0f be c0             	movsbl %al,%eax
    158c:	83 ec 08             	sub    $0x8,%esp
    158f:	50                   	push   %eax
    1590:	ff 75 08             	pushl  0x8(%ebp)
    1593:	e8 e3 fd ff ff       	call   137b <putc>
    1598:	83 c4 10             	add    $0x10,%esp
    159b:	eb 25                	jmp    15c2 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    159d:	83 ec 08             	sub    $0x8,%esp
    15a0:	6a 25                	push   $0x25
    15a2:	ff 75 08             	pushl  0x8(%ebp)
    15a5:	e8 d1 fd ff ff       	call   137b <putc>
    15aa:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    15ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15b0:	0f be c0             	movsbl %al,%eax
    15b3:	83 ec 08             	sub    $0x8,%esp
    15b6:	50                   	push   %eax
    15b7:	ff 75 08             	pushl  0x8(%ebp)
    15ba:	e8 bc fd ff ff       	call   137b <putc>
    15bf:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15c9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15cd:	8b 55 0c             	mov    0xc(%ebp),%edx
    15d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15d3:	01 d0                	add    %edx,%eax
    15d5:	0f b6 00             	movzbl (%eax),%eax
    15d8:	84 c0                	test   %al,%al
    15da:	0f 85 94 fe ff ff    	jne    1474 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15e0:	90                   	nop
    15e1:	c9                   	leave  
    15e2:	c3                   	ret    

000015e3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15e3:	55                   	push   %ebp
    15e4:	89 e5                	mov    %esp,%ebp
    15e6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15e9:	8b 45 08             	mov    0x8(%ebp),%eax
    15ec:	83 e8 08             	sub    $0x8,%eax
    15ef:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15f2:	a1 50 1b 00 00       	mov    0x1b50,%eax
    15f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15fa:	eb 24                	jmp    1620 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ff:	8b 00                	mov    (%eax),%eax
    1601:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1604:	77 12                	ja     1618 <free+0x35>
    1606:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1609:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    160c:	77 24                	ja     1632 <free+0x4f>
    160e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1611:	8b 00                	mov    (%eax),%eax
    1613:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1616:	77 1a                	ja     1632 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1618:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161b:	8b 00                	mov    (%eax),%eax
    161d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1620:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1623:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1626:	76 d4                	jbe    15fc <free+0x19>
    1628:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162b:	8b 00                	mov    (%eax),%eax
    162d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1630:	76 ca                	jbe    15fc <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1632:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1635:	8b 40 04             	mov    0x4(%eax),%eax
    1638:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    163f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1642:	01 c2                	add    %eax,%edx
    1644:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1647:	8b 00                	mov    (%eax),%eax
    1649:	39 c2                	cmp    %eax,%edx
    164b:	75 24                	jne    1671 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    164d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1650:	8b 50 04             	mov    0x4(%eax),%edx
    1653:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1656:	8b 00                	mov    (%eax),%eax
    1658:	8b 40 04             	mov    0x4(%eax),%eax
    165b:	01 c2                	add    %eax,%edx
    165d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1660:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1663:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1666:	8b 00                	mov    (%eax),%eax
    1668:	8b 10                	mov    (%eax),%edx
    166a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166d:	89 10                	mov    %edx,(%eax)
    166f:	eb 0a                	jmp    167b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1671:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1674:	8b 10                	mov    (%eax),%edx
    1676:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1679:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    167b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167e:	8b 40 04             	mov    0x4(%eax),%eax
    1681:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1688:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168b:	01 d0                	add    %edx,%eax
    168d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1690:	75 20                	jne    16b2 <free+0xcf>
    p->s.size += bp->s.size;
    1692:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1695:	8b 50 04             	mov    0x4(%eax),%edx
    1698:	8b 45 f8             	mov    -0x8(%ebp),%eax
    169b:	8b 40 04             	mov    0x4(%eax),%eax
    169e:	01 c2                	add    %eax,%edx
    16a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a9:	8b 10                	mov    (%eax),%edx
    16ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ae:	89 10                	mov    %edx,(%eax)
    16b0:	eb 08                	jmp    16ba <free+0xd7>
  } else
    p->s.ptr = bp;
    16b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b5:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16b8:	89 10                	mov    %edx,(%eax)
  freep = p;
    16ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16bd:	a3 50 1b 00 00       	mov    %eax,0x1b50
}
    16c2:	90                   	nop
    16c3:	c9                   	leave  
    16c4:	c3                   	ret    

000016c5 <morecore>:

static Header*
morecore(uint nu)
{
    16c5:	55                   	push   %ebp
    16c6:	89 e5                	mov    %esp,%ebp
    16c8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16cb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16d2:	77 07                	ja     16db <morecore+0x16>
    nu = 4096;
    16d4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16db:	8b 45 08             	mov    0x8(%ebp),%eax
    16de:	c1 e0 03             	shl    $0x3,%eax
    16e1:	83 ec 0c             	sub    $0xc,%esp
    16e4:	50                   	push   %eax
    16e5:	e8 69 fc ff ff       	call   1353 <sbrk>
    16ea:	83 c4 10             	add    $0x10,%esp
    16ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16f0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16f4:	75 07                	jne    16fd <morecore+0x38>
    return 0;
    16f6:	b8 00 00 00 00       	mov    $0x0,%eax
    16fb:	eb 26                	jmp    1723 <morecore+0x5e>
  hp = (Header*)p;
    16fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1700:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1703:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1706:	8b 55 08             	mov    0x8(%ebp),%edx
    1709:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    170f:	83 c0 08             	add    $0x8,%eax
    1712:	83 ec 0c             	sub    $0xc,%esp
    1715:	50                   	push   %eax
    1716:	e8 c8 fe ff ff       	call   15e3 <free>
    171b:	83 c4 10             	add    $0x10,%esp
  return freep;
    171e:	a1 50 1b 00 00       	mov    0x1b50,%eax
}
    1723:	c9                   	leave  
    1724:	c3                   	ret    

00001725 <malloc>:

void*
malloc(uint nbytes)
{
    1725:	55                   	push   %ebp
    1726:	89 e5                	mov    %esp,%ebp
    1728:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    172b:	8b 45 08             	mov    0x8(%ebp),%eax
    172e:	83 c0 07             	add    $0x7,%eax
    1731:	c1 e8 03             	shr    $0x3,%eax
    1734:	83 c0 01             	add    $0x1,%eax
    1737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    173a:	a1 50 1b 00 00       	mov    0x1b50,%eax
    173f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1742:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1746:	75 23                	jne    176b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1748:	c7 45 f0 48 1b 00 00 	movl   $0x1b48,-0x10(%ebp)
    174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1752:	a3 50 1b 00 00       	mov    %eax,0x1b50
    1757:	a1 50 1b 00 00       	mov    0x1b50,%eax
    175c:	a3 48 1b 00 00       	mov    %eax,0x1b48
    base.s.size = 0;
    1761:	c7 05 4c 1b 00 00 00 	movl   $0x0,0x1b4c
    1768:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    176e:	8b 00                	mov    (%eax),%eax
    1770:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1773:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1776:	8b 40 04             	mov    0x4(%eax),%eax
    1779:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    177c:	72 4d                	jb     17cb <malloc+0xa6>
      if(p->s.size == nunits)
    177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1781:	8b 40 04             	mov    0x4(%eax),%eax
    1784:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1787:	75 0c                	jne    1795 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1789:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178c:	8b 10                	mov    (%eax),%edx
    178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1791:	89 10                	mov    %edx,(%eax)
    1793:	eb 26                	jmp    17bb <malloc+0x96>
      else {
        p->s.size -= nunits;
    1795:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1798:	8b 40 04             	mov    0x4(%eax),%eax
    179b:	2b 45 ec             	sub    -0x14(%ebp),%eax
    179e:	89 c2                	mov    %eax,%edx
    17a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a9:	8b 40 04             	mov    0x4(%eax),%eax
    17ac:	c1 e0 03             	shl    $0x3,%eax
    17af:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17b8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17be:	a3 50 1b 00 00       	mov    %eax,0x1b50
      return (void*)(p + 1);
    17c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c6:	83 c0 08             	add    $0x8,%eax
    17c9:	eb 3b                	jmp    1806 <malloc+0xe1>
    }
    if(p == freep)
    17cb:	a1 50 1b 00 00       	mov    0x1b50,%eax
    17d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17d3:	75 1e                	jne    17f3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17d5:	83 ec 0c             	sub    $0xc,%esp
    17d8:	ff 75 ec             	pushl  -0x14(%ebp)
    17db:	e8 e5 fe ff ff       	call   16c5 <morecore>
    17e0:	83 c4 10             	add    $0x10,%esp
    17e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17ea:	75 07                	jne    17f3 <malloc+0xce>
        return 0;
    17ec:	b8 00 00 00 00       	mov    $0x0,%eax
    17f1:	eb 13                	jmp    1806 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17fc:	8b 00                	mov    (%eax),%eax
    17fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1801:	e9 6d ff ff ff       	jmp    1773 <malloc+0x4e>
}
    1806:	c9                   	leave  
    1807:	c3                   	ret    

00001808 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    1808:	55                   	push   %ebp
    1809:	89 e5                	mov    %esp,%ebp
    180b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    180e:	8b 55 08             	mov    0x8(%ebp),%edx
    1811:	8b 45 0c             	mov    0xc(%ebp),%eax
    1814:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1817:	f0 87 02             	lock xchg %eax,(%edx)
    181a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    181d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1820:	c9                   	leave  
    1821:	c3                   	ret    

00001822 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1822:	55                   	push   %ebp
    1823:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1825:	90                   	nop
    1826:	8b 45 08             	mov    0x8(%ebp),%eax
    1829:	6a 01                	push   $0x1
    182b:	50                   	push   %eax
    182c:	e8 d7 ff ff ff       	call   1808 <xchg>
    1831:	83 c4 08             	add    $0x8,%esp
    1834:	85 c0                	test   %eax,%eax
    1836:	75 ee                	jne    1826 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1838:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    183d:	90                   	nop
    183e:	c9                   	leave  
    183f:	c3                   	ret    

00001840 <urelease>:

void urelease (struct uspinlock *lk) {
    1840:	55                   	push   %ebp
    1841:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1843:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1848:	8b 45 08             	mov    0x8(%ebp),%eax
    184b:	8b 55 08             	mov    0x8(%ebp),%edx
    184e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1854:	90                   	nop
    1855:	5d                   	pop    %ebp
    1856:	c3                   	ret    
