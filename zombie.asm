
_zombie:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	51                   	push   %ecx
    100e:	83 ec 04             	sub    $0x4,%esp
  if(fork() > 0)
    1011:	e8 65 02 00 00       	call   127b <fork>
    1016:	85 c0                	test   %eax,%eax
    1018:	7e 0d                	jle    1027 <main+0x27>
    sleep(5);  // Let child exit before parent.
    101a:	83 ec 0c             	sub    $0xc,%esp
    101d:	6a 05                	push   $0x5
    101f:	e8 ef 02 00 00       	call   1313 <sleep>
    1024:	83 c4 10             	add    $0x10,%esp
  exit();
    1027:	e8 57 02 00 00       	call   1283 <exit>

0000102c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    102c:	55                   	push   %ebp
    102d:	89 e5                	mov    %esp,%ebp
    102f:	57                   	push   %edi
    1030:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1031:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1034:	8b 55 10             	mov    0x10(%ebp),%edx
    1037:	8b 45 0c             	mov    0xc(%ebp),%eax
    103a:	89 cb                	mov    %ecx,%ebx
    103c:	89 df                	mov    %ebx,%edi
    103e:	89 d1                	mov    %edx,%ecx
    1040:	fc                   	cld    
    1041:	f3 aa                	rep stos %al,%es:(%edi)
    1043:	89 ca                	mov    %ecx,%edx
    1045:	89 fb                	mov    %edi,%ebx
    1047:	89 5d 08             	mov    %ebx,0x8(%ebp)
    104a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    104d:	90                   	nop
    104e:	5b                   	pop    %ebx
    104f:	5f                   	pop    %edi
    1050:	5d                   	pop    %ebp
    1051:	c3                   	ret    

00001052 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1052:	55                   	push   %ebp
    1053:	89 e5                	mov    %esp,%ebp
    1055:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1058:	8b 45 08             	mov    0x8(%ebp),%eax
    105b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    105e:	90                   	nop
    105f:	8b 45 08             	mov    0x8(%ebp),%eax
    1062:	8d 50 01             	lea    0x1(%eax),%edx
    1065:	89 55 08             	mov    %edx,0x8(%ebp)
    1068:	8b 55 0c             	mov    0xc(%ebp),%edx
    106b:	8d 4a 01             	lea    0x1(%edx),%ecx
    106e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1071:	0f b6 12             	movzbl (%edx),%edx
    1074:	88 10                	mov    %dl,(%eax)
    1076:	0f b6 00             	movzbl (%eax),%eax
    1079:	84 c0                	test   %al,%al
    107b:	75 e2                	jne    105f <strcpy+0xd>
    ;
  return os;
    107d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1080:	c9                   	leave  
    1081:	c3                   	ret    

00001082 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1082:	55                   	push   %ebp
    1083:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1085:	eb 08                	jmp    108f <strcmp+0xd>
    p++, q++;
    1087:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    108b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    108f:	8b 45 08             	mov    0x8(%ebp),%eax
    1092:	0f b6 00             	movzbl (%eax),%eax
    1095:	84 c0                	test   %al,%al
    1097:	74 10                	je     10a9 <strcmp+0x27>
    1099:	8b 45 08             	mov    0x8(%ebp),%eax
    109c:	0f b6 10             	movzbl (%eax),%edx
    109f:	8b 45 0c             	mov    0xc(%ebp),%eax
    10a2:	0f b6 00             	movzbl (%eax),%eax
    10a5:	38 c2                	cmp    %al,%dl
    10a7:	74 de                	je     1087 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10a9:	8b 45 08             	mov    0x8(%ebp),%eax
    10ac:	0f b6 00             	movzbl (%eax),%eax
    10af:	0f b6 d0             	movzbl %al,%edx
    10b2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10b5:	0f b6 00             	movzbl (%eax),%eax
    10b8:	0f b6 c0             	movzbl %al,%eax
    10bb:	29 c2                	sub    %eax,%edx
    10bd:	89 d0                	mov    %edx,%eax
}
    10bf:	5d                   	pop    %ebp
    10c0:	c3                   	ret    

000010c1 <strlen>:

uint
strlen(char *s)
{
    10c1:	55                   	push   %ebp
    10c2:	89 e5                	mov    %esp,%ebp
    10c4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10ce:	eb 04                	jmp    10d4 <strlen+0x13>
    10d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    10d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10d7:	8b 45 08             	mov    0x8(%ebp),%eax
    10da:	01 d0                	add    %edx,%eax
    10dc:	0f b6 00             	movzbl (%eax),%eax
    10df:	84 c0                	test   %al,%al
    10e1:	75 ed                	jne    10d0 <strlen+0xf>
    ;
  return n;
    10e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10e6:	c9                   	leave  
    10e7:	c3                   	ret    

000010e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
    10e8:	55                   	push   %ebp
    10e9:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    10eb:	8b 45 10             	mov    0x10(%ebp),%eax
    10ee:	50                   	push   %eax
    10ef:	ff 75 0c             	pushl  0xc(%ebp)
    10f2:	ff 75 08             	pushl  0x8(%ebp)
    10f5:	e8 32 ff ff ff       	call   102c <stosb>
    10fa:	83 c4 0c             	add    $0xc,%esp
  return dst;
    10fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1100:	c9                   	leave  
    1101:	c3                   	ret    

00001102 <strchr>:

char*
strchr(const char *s, char c)
{
    1102:	55                   	push   %ebp
    1103:	89 e5                	mov    %esp,%ebp
    1105:	83 ec 04             	sub    $0x4,%esp
    1108:	8b 45 0c             	mov    0xc(%ebp),%eax
    110b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    110e:	eb 14                	jmp    1124 <strchr+0x22>
    if(*s == c)
    1110:	8b 45 08             	mov    0x8(%ebp),%eax
    1113:	0f b6 00             	movzbl (%eax),%eax
    1116:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1119:	75 05                	jne    1120 <strchr+0x1e>
      return (char*)s;
    111b:	8b 45 08             	mov    0x8(%ebp),%eax
    111e:	eb 13                	jmp    1133 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1120:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1124:	8b 45 08             	mov    0x8(%ebp),%eax
    1127:	0f b6 00             	movzbl (%eax),%eax
    112a:	84 c0                	test   %al,%al
    112c:	75 e2                	jne    1110 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    112e:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1133:	c9                   	leave  
    1134:	c3                   	ret    

00001135 <gets>:

char*
gets(char *buf, int max)
{
    1135:	55                   	push   %ebp
    1136:	89 e5                	mov    %esp,%ebp
    1138:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    113b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1142:	eb 42                	jmp    1186 <gets+0x51>
    cc = read(0, &c, 1);
    1144:	83 ec 04             	sub    $0x4,%esp
    1147:	6a 01                	push   $0x1
    1149:	8d 45 ef             	lea    -0x11(%ebp),%eax
    114c:	50                   	push   %eax
    114d:	6a 00                	push   $0x0
    114f:	e8 47 01 00 00       	call   129b <read>
    1154:	83 c4 10             	add    $0x10,%esp
    1157:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    115a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    115e:	7e 33                	jle    1193 <gets+0x5e>
      break;
    buf[i++] = c;
    1160:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1163:	8d 50 01             	lea    0x1(%eax),%edx
    1166:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1169:	89 c2                	mov    %eax,%edx
    116b:	8b 45 08             	mov    0x8(%ebp),%eax
    116e:	01 c2                	add    %eax,%edx
    1170:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1174:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1176:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    117a:	3c 0a                	cmp    $0xa,%al
    117c:	74 16                	je     1194 <gets+0x5f>
    117e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1182:	3c 0d                	cmp    $0xd,%al
    1184:	74 0e                	je     1194 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1186:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1189:	83 c0 01             	add    $0x1,%eax
    118c:	3b 45 0c             	cmp    0xc(%ebp),%eax
    118f:	7c b3                	jl     1144 <gets+0xf>
    1191:	eb 01                	jmp    1194 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1193:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1194:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1197:	8b 45 08             	mov    0x8(%ebp),%eax
    119a:	01 d0                	add    %edx,%eax
    119c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    119f:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11a2:	c9                   	leave  
    11a3:	c3                   	ret    

000011a4 <stat>:

int
stat(char *n, struct stat *st)
{
    11a4:	55                   	push   %ebp
    11a5:	89 e5                	mov    %esp,%ebp
    11a7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11aa:	83 ec 08             	sub    $0x8,%esp
    11ad:	6a 00                	push   $0x0
    11af:	ff 75 08             	pushl  0x8(%ebp)
    11b2:	e8 0c 01 00 00       	call   12c3 <open>
    11b7:	83 c4 10             	add    $0x10,%esp
    11ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11c1:	79 07                	jns    11ca <stat+0x26>
    return -1;
    11c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11c8:	eb 25                	jmp    11ef <stat+0x4b>
  r = fstat(fd, st);
    11ca:	83 ec 08             	sub    $0x8,%esp
    11cd:	ff 75 0c             	pushl  0xc(%ebp)
    11d0:	ff 75 f4             	pushl  -0xc(%ebp)
    11d3:	e8 03 01 00 00       	call   12db <fstat>
    11d8:	83 c4 10             	add    $0x10,%esp
    11db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    11de:	83 ec 0c             	sub    $0xc,%esp
    11e1:	ff 75 f4             	pushl  -0xc(%ebp)
    11e4:	e8 c2 00 00 00       	call   12ab <close>
    11e9:	83 c4 10             	add    $0x10,%esp
  return r;
    11ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    11ef:	c9                   	leave  
    11f0:	c3                   	ret    

000011f1 <atoi>:

int
atoi(const char *s)
{
    11f1:	55                   	push   %ebp
    11f2:	89 e5                	mov    %esp,%ebp
    11f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    11f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    11fe:	eb 25                	jmp    1225 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1200:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1203:	89 d0                	mov    %edx,%eax
    1205:	c1 e0 02             	shl    $0x2,%eax
    1208:	01 d0                	add    %edx,%eax
    120a:	01 c0                	add    %eax,%eax
    120c:	89 c1                	mov    %eax,%ecx
    120e:	8b 45 08             	mov    0x8(%ebp),%eax
    1211:	8d 50 01             	lea    0x1(%eax),%edx
    1214:	89 55 08             	mov    %edx,0x8(%ebp)
    1217:	0f b6 00             	movzbl (%eax),%eax
    121a:	0f be c0             	movsbl %al,%eax
    121d:	01 c8                	add    %ecx,%eax
    121f:	83 e8 30             	sub    $0x30,%eax
    1222:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1225:	8b 45 08             	mov    0x8(%ebp),%eax
    1228:	0f b6 00             	movzbl (%eax),%eax
    122b:	3c 2f                	cmp    $0x2f,%al
    122d:	7e 0a                	jle    1239 <atoi+0x48>
    122f:	8b 45 08             	mov    0x8(%ebp),%eax
    1232:	0f b6 00             	movzbl (%eax),%eax
    1235:	3c 39                	cmp    $0x39,%al
    1237:	7e c7                	jle    1200 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1239:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    123c:	c9                   	leave  
    123d:	c3                   	ret    

0000123e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    123e:	55                   	push   %ebp
    123f:	89 e5                	mov    %esp,%ebp
    1241:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1244:	8b 45 08             	mov    0x8(%ebp),%eax
    1247:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    124a:	8b 45 0c             	mov    0xc(%ebp),%eax
    124d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1250:	eb 17                	jmp    1269 <memmove+0x2b>
    *dst++ = *src++;
    1252:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1255:	8d 50 01             	lea    0x1(%eax),%edx
    1258:	89 55 fc             	mov    %edx,-0x4(%ebp)
    125b:	8b 55 f8             	mov    -0x8(%ebp),%edx
    125e:	8d 4a 01             	lea    0x1(%edx),%ecx
    1261:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1264:	0f b6 12             	movzbl (%edx),%edx
    1267:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1269:	8b 45 10             	mov    0x10(%ebp),%eax
    126c:	8d 50 ff             	lea    -0x1(%eax),%edx
    126f:	89 55 10             	mov    %edx,0x10(%ebp)
    1272:	85 c0                	test   %eax,%eax
    1274:	7f dc                	jg     1252 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1276:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1279:	c9                   	leave  
    127a:	c3                   	ret    

0000127b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    127b:	b8 01 00 00 00       	mov    $0x1,%eax
    1280:	cd 40                	int    $0x40
    1282:	c3                   	ret    

00001283 <exit>:
SYSCALL(exit)
    1283:	b8 02 00 00 00       	mov    $0x2,%eax
    1288:	cd 40                	int    $0x40
    128a:	c3                   	ret    

0000128b <wait>:
SYSCALL(wait)
    128b:	b8 03 00 00 00       	mov    $0x3,%eax
    1290:	cd 40                	int    $0x40
    1292:	c3                   	ret    

00001293 <pipe>:
SYSCALL(pipe)
    1293:	b8 04 00 00 00       	mov    $0x4,%eax
    1298:	cd 40                	int    $0x40
    129a:	c3                   	ret    

0000129b <read>:
SYSCALL(read)
    129b:	b8 05 00 00 00       	mov    $0x5,%eax
    12a0:	cd 40                	int    $0x40
    12a2:	c3                   	ret    

000012a3 <write>:
SYSCALL(write)
    12a3:	b8 10 00 00 00       	mov    $0x10,%eax
    12a8:	cd 40                	int    $0x40
    12aa:	c3                   	ret    

000012ab <close>:
SYSCALL(close)
    12ab:	b8 15 00 00 00       	mov    $0x15,%eax
    12b0:	cd 40                	int    $0x40
    12b2:	c3                   	ret    

000012b3 <kill>:
SYSCALL(kill)
    12b3:	b8 06 00 00 00       	mov    $0x6,%eax
    12b8:	cd 40                	int    $0x40
    12ba:	c3                   	ret    

000012bb <exec>:
SYSCALL(exec)
    12bb:	b8 07 00 00 00       	mov    $0x7,%eax
    12c0:	cd 40                	int    $0x40
    12c2:	c3                   	ret    

000012c3 <open>:
SYSCALL(open)
    12c3:	b8 0f 00 00 00       	mov    $0xf,%eax
    12c8:	cd 40                	int    $0x40
    12ca:	c3                   	ret    

000012cb <mknod>:
SYSCALL(mknod)
    12cb:	b8 11 00 00 00       	mov    $0x11,%eax
    12d0:	cd 40                	int    $0x40
    12d2:	c3                   	ret    

000012d3 <unlink>:
SYSCALL(unlink)
    12d3:	b8 12 00 00 00       	mov    $0x12,%eax
    12d8:	cd 40                	int    $0x40
    12da:	c3                   	ret    

000012db <fstat>:
SYSCALL(fstat)
    12db:	b8 08 00 00 00       	mov    $0x8,%eax
    12e0:	cd 40                	int    $0x40
    12e2:	c3                   	ret    

000012e3 <link>:
SYSCALL(link)
    12e3:	b8 13 00 00 00       	mov    $0x13,%eax
    12e8:	cd 40                	int    $0x40
    12ea:	c3                   	ret    

000012eb <mkdir>:
SYSCALL(mkdir)
    12eb:	b8 14 00 00 00       	mov    $0x14,%eax
    12f0:	cd 40                	int    $0x40
    12f2:	c3                   	ret    

000012f3 <chdir>:
SYSCALL(chdir)
    12f3:	b8 09 00 00 00       	mov    $0x9,%eax
    12f8:	cd 40                	int    $0x40
    12fa:	c3                   	ret    

000012fb <dup>:
SYSCALL(dup)
    12fb:	b8 0a 00 00 00       	mov    $0xa,%eax
    1300:	cd 40                	int    $0x40
    1302:	c3                   	ret    

00001303 <getpid>:
SYSCALL(getpid)
    1303:	b8 0b 00 00 00       	mov    $0xb,%eax
    1308:	cd 40                	int    $0x40
    130a:	c3                   	ret    

0000130b <sbrk>:
SYSCALL(sbrk)
    130b:	b8 0c 00 00 00       	mov    $0xc,%eax
    1310:	cd 40                	int    $0x40
    1312:	c3                   	ret    

00001313 <sleep>:
SYSCALL(sleep)
    1313:	b8 0d 00 00 00       	mov    $0xd,%eax
    1318:	cd 40                	int    $0x40
    131a:	c3                   	ret    

0000131b <uptime>:
SYSCALL(uptime)
    131b:	b8 0e 00 00 00       	mov    $0xe,%eax
    1320:	cd 40                	int    $0x40
    1322:	c3                   	ret    

00001323 <shm_open>:
SYSCALL(shm_open)
    1323:	b8 16 00 00 00       	mov    $0x16,%eax
    1328:	cd 40                	int    $0x40
    132a:	c3                   	ret    

0000132b <shm_close>:
SYSCALL(shm_close)	
    132b:	b8 17 00 00 00       	mov    $0x17,%eax
    1330:	cd 40                	int    $0x40
    1332:	c3                   	ret    

00001333 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1333:	55                   	push   %ebp
    1334:	89 e5                	mov    %esp,%ebp
    1336:	83 ec 18             	sub    $0x18,%esp
    1339:	8b 45 0c             	mov    0xc(%ebp),%eax
    133c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    133f:	83 ec 04             	sub    $0x4,%esp
    1342:	6a 01                	push   $0x1
    1344:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1347:	50                   	push   %eax
    1348:	ff 75 08             	pushl  0x8(%ebp)
    134b:	e8 53 ff ff ff       	call   12a3 <write>
    1350:	83 c4 10             	add    $0x10,%esp
}
    1353:	90                   	nop
    1354:	c9                   	leave  
    1355:	c3                   	ret    

00001356 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1356:	55                   	push   %ebp
    1357:	89 e5                	mov    %esp,%ebp
    1359:	53                   	push   %ebx
    135a:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    135d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1364:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1368:	74 17                	je     1381 <printint+0x2b>
    136a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    136e:	79 11                	jns    1381 <printint+0x2b>
    neg = 1;
    1370:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1377:	8b 45 0c             	mov    0xc(%ebp),%eax
    137a:	f7 d8                	neg    %eax
    137c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    137f:	eb 06                	jmp    1387 <printint+0x31>
  } else {
    x = xx;
    1381:	8b 45 0c             	mov    0xc(%ebp),%eax
    1384:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1387:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    138e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1391:	8d 41 01             	lea    0x1(%ecx),%eax
    1394:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1397:	8b 5d 10             	mov    0x10(%ebp),%ebx
    139a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    139d:	ba 00 00 00 00       	mov    $0x0,%edx
    13a2:	f7 f3                	div    %ebx
    13a4:	89 d0                	mov    %edx,%eax
    13a6:	0f b6 80 c0 1a 00 00 	movzbl 0x1ac0(%eax),%eax
    13ad:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13b7:	ba 00 00 00 00       	mov    $0x0,%edx
    13bc:	f7 f3                	div    %ebx
    13be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13c5:	75 c7                	jne    138e <printint+0x38>
  if(neg)
    13c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13cb:	74 2d                	je     13fa <printint+0xa4>
    buf[i++] = '-';
    13cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13d0:	8d 50 01             	lea    0x1(%eax),%edx
    13d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
    13d6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    13db:	eb 1d                	jmp    13fa <printint+0xa4>
    putc(fd, buf[i]);
    13dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
    13e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e3:	01 d0                	add    %edx,%eax
    13e5:	0f b6 00             	movzbl (%eax),%eax
    13e8:	0f be c0             	movsbl %al,%eax
    13eb:	83 ec 08             	sub    $0x8,%esp
    13ee:	50                   	push   %eax
    13ef:	ff 75 08             	pushl  0x8(%ebp)
    13f2:	e8 3c ff ff ff       	call   1333 <putc>
    13f7:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    13fa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    13fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1402:	79 d9                	jns    13dd <printint+0x87>
    putc(fd, buf[i]);
}
    1404:	90                   	nop
    1405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1408:	c9                   	leave  
    1409:	c3                   	ret    

0000140a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    140a:	55                   	push   %ebp
    140b:	89 e5                	mov    %esp,%ebp
    140d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1410:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1417:	8d 45 0c             	lea    0xc(%ebp),%eax
    141a:	83 c0 04             	add    $0x4,%eax
    141d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1420:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1427:	e9 59 01 00 00       	jmp    1585 <printf+0x17b>
    c = fmt[i] & 0xff;
    142c:	8b 55 0c             	mov    0xc(%ebp),%edx
    142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1432:	01 d0                	add    %edx,%eax
    1434:	0f b6 00             	movzbl (%eax),%eax
    1437:	0f be c0             	movsbl %al,%eax
    143a:	25 ff 00 00 00       	and    $0xff,%eax
    143f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1442:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1446:	75 2c                	jne    1474 <printf+0x6a>
      if(c == '%'){
    1448:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    144c:	75 0c                	jne    145a <printf+0x50>
        state = '%';
    144e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1455:	e9 27 01 00 00       	jmp    1581 <printf+0x177>
      } else {
        putc(fd, c);
    145a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    145d:	0f be c0             	movsbl %al,%eax
    1460:	83 ec 08             	sub    $0x8,%esp
    1463:	50                   	push   %eax
    1464:	ff 75 08             	pushl  0x8(%ebp)
    1467:	e8 c7 fe ff ff       	call   1333 <putc>
    146c:	83 c4 10             	add    $0x10,%esp
    146f:	e9 0d 01 00 00       	jmp    1581 <printf+0x177>
      }
    } else if(state == '%'){
    1474:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1478:	0f 85 03 01 00 00    	jne    1581 <printf+0x177>
      if(c == 'd'){
    147e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1482:	75 1e                	jne    14a2 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1484:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1487:	8b 00                	mov    (%eax),%eax
    1489:	6a 01                	push   $0x1
    148b:	6a 0a                	push   $0xa
    148d:	50                   	push   %eax
    148e:	ff 75 08             	pushl  0x8(%ebp)
    1491:	e8 c0 fe ff ff       	call   1356 <printint>
    1496:	83 c4 10             	add    $0x10,%esp
        ap++;
    1499:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    149d:	e9 d8 00 00 00       	jmp    157a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14a2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14a6:	74 06                	je     14ae <printf+0xa4>
    14a8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14ac:	75 1e                	jne    14cc <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14b1:	8b 00                	mov    (%eax),%eax
    14b3:	6a 00                	push   $0x0
    14b5:	6a 10                	push   $0x10
    14b7:	50                   	push   %eax
    14b8:	ff 75 08             	pushl  0x8(%ebp)
    14bb:	e8 96 fe ff ff       	call   1356 <printint>
    14c0:	83 c4 10             	add    $0x10,%esp
        ap++;
    14c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14c7:	e9 ae 00 00 00       	jmp    157a <printf+0x170>
      } else if(c == 's'){
    14cc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    14d0:	75 43                	jne    1515 <printf+0x10b>
        s = (char*)*ap;
    14d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14d5:	8b 00                	mov    (%eax),%eax
    14d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    14da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    14de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14e2:	75 25                	jne    1509 <printf+0xff>
          s = "(null)";
    14e4:	c7 45 f4 0f 18 00 00 	movl   $0x180f,-0xc(%ebp)
        while(*s != 0){
    14eb:	eb 1c                	jmp    1509 <printf+0xff>
          putc(fd, *s);
    14ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14f0:	0f b6 00             	movzbl (%eax),%eax
    14f3:	0f be c0             	movsbl %al,%eax
    14f6:	83 ec 08             	sub    $0x8,%esp
    14f9:	50                   	push   %eax
    14fa:	ff 75 08             	pushl  0x8(%ebp)
    14fd:	e8 31 fe ff ff       	call   1333 <putc>
    1502:	83 c4 10             	add    $0x10,%esp
          s++;
    1505:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1509:	8b 45 f4             	mov    -0xc(%ebp),%eax
    150c:	0f b6 00             	movzbl (%eax),%eax
    150f:	84 c0                	test   %al,%al
    1511:	75 da                	jne    14ed <printf+0xe3>
    1513:	eb 65                	jmp    157a <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1515:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1519:	75 1d                	jne    1538 <printf+0x12e>
        putc(fd, *ap);
    151b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    151e:	8b 00                	mov    (%eax),%eax
    1520:	0f be c0             	movsbl %al,%eax
    1523:	83 ec 08             	sub    $0x8,%esp
    1526:	50                   	push   %eax
    1527:	ff 75 08             	pushl  0x8(%ebp)
    152a:	e8 04 fe ff ff       	call   1333 <putc>
    152f:	83 c4 10             	add    $0x10,%esp
        ap++;
    1532:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1536:	eb 42                	jmp    157a <printf+0x170>
      } else if(c == '%'){
    1538:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    153c:	75 17                	jne    1555 <printf+0x14b>
        putc(fd, c);
    153e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1541:	0f be c0             	movsbl %al,%eax
    1544:	83 ec 08             	sub    $0x8,%esp
    1547:	50                   	push   %eax
    1548:	ff 75 08             	pushl  0x8(%ebp)
    154b:	e8 e3 fd ff ff       	call   1333 <putc>
    1550:	83 c4 10             	add    $0x10,%esp
    1553:	eb 25                	jmp    157a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1555:	83 ec 08             	sub    $0x8,%esp
    1558:	6a 25                	push   $0x25
    155a:	ff 75 08             	pushl  0x8(%ebp)
    155d:	e8 d1 fd ff ff       	call   1333 <putc>
    1562:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1565:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1568:	0f be c0             	movsbl %al,%eax
    156b:	83 ec 08             	sub    $0x8,%esp
    156e:	50                   	push   %eax
    156f:	ff 75 08             	pushl  0x8(%ebp)
    1572:	e8 bc fd ff ff       	call   1333 <putc>
    1577:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    157a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1581:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1585:	8b 55 0c             	mov    0xc(%ebp),%edx
    1588:	8b 45 f0             	mov    -0x10(%ebp),%eax
    158b:	01 d0                	add    %edx,%eax
    158d:	0f b6 00             	movzbl (%eax),%eax
    1590:	84 c0                	test   %al,%al
    1592:	0f 85 94 fe ff ff    	jne    142c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1598:	90                   	nop
    1599:	c9                   	leave  
    159a:	c3                   	ret    

0000159b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    159b:	55                   	push   %ebp
    159c:	89 e5                	mov    %esp,%ebp
    159e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15a1:	8b 45 08             	mov    0x8(%ebp),%eax
    15a4:	83 e8 08             	sub    $0x8,%eax
    15a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15aa:	a1 dc 1a 00 00       	mov    0x1adc,%eax
    15af:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15b2:	eb 24                	jmp    15d8 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15b7:	8b 00                	mov    (%eax),%eax
    15b9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15bc:	77 12                	ja     15d0 <free+0x35>
    15be:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15c1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15c4:	77 24                	ja     15ea <free+0x4f>
    15c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15c9:	8b 00                	mov    (%eax),%eax
    15cb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15ce:	77 1a                	ja     15ea <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15d3:	8b 00                	mov    (%eax),%eax
    15d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15de:	76 d4                	jbe    15b4 <free+0x19>
    15e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15e3:	8b 00                	mov    (%eax),%eax
    15e5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15e8:	76 ca                	jbe    15b4 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    15ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15ed:	8b 40 04             	mov    0x4(%eax),%eax
    15f0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    15f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15fa:	01 c2                	add    %eax,%edx
    15fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ff:	8b 00                	mov    (%eax),%eax
    1601:	39 c2                	cmp    %eax,%edx
    1603:	75 24                	jne    1629 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1605:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1608:	8b 50 04             	mov    0x4(%eax),%edx
    160b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    160e:	8b 00                	mov    (%eax),%eax
    1610:	8b 40 04             	mov    0x4(%eax),%eax
    1613:	01 c2                	add    %eax,%edx
    1615:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1618:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    161b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161e:	8b 00                	mov    (%eax),%eax
    1620:	8b 10                	mov    (%eax),%edx
    1622:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1625:	89 10                	mov    %edx,(%eax)
    1627:	eb 0a                	jmp    1633 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1629:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162c:	8b 10                	mov    (%eax),%edx
    162e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1631:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1633:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1636:	8b 40 04             	mov    0x4(%eax),%eax
    1639:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1640:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1643:	01 d0                	add    %edx,%eax
    1645:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1648:	75 20                	jne    166a <free+0xcf>
    p->s.size += bp->s.size;
    164a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164d:	8b 50 04             	mov    0x4(%eax),%edx
    1650:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1653:	8b 40 04             	mov    0x4(%eax),%eax
    1656:	01 c2                	add    %eax,%edx
    1658:	8b 45 fc             	mov    -0x4(%ebp),%eax
    165b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    165e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1661:	8b 10                	mov    (%eax),%edx
    1663:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1666:	89 10                	mov    %edx,(%eax)
    1668:	eb 08                	jmp    1672 <free+0xd7>
  } else
    p->s.ptr = bp;
    166a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166d:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1670:	89 10                	mov    %edx,(%eax)
  freep = p;
    1672:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1675:	a3 dc 1a 00 00       	mov    %eax,0x1adc
}
    167a:	90                   	nop
    167b:	c9                   	leave  
    167c:	c3                   	ret    

0000167d <morecore>:

static Header*
morecore(uint nu)
{
    167d:	55                   	push   %ebp
    167e:	89 e5                	mov    %esp,%ebp
    1680:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1683:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    168a:	77 07                	ja     1693 <morecore+0x16>
    nu = 4096;
    168c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1693:	8b 45 08             	mov    0x8(%ebp),%eax
    1696:	c1 e0 03             	shl    $0x3,%eax
    1699:	83 ec 0c             	sub    $0xc,%esp
    169c:	50                   	push   %eax
    169d:	e8 69 fc ff ff       	call   130b <sbrk>
    16a2:	83 c4 10             	add    $0x10,%esp
    16a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16a8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16ac:	75 07                	jne    16b5 <morecore+0x38>
    return 0;
    16ae:	b8 00 00 00 00       	mov    $0x0,%eax
    16b3:	eb 26                	jmp    16db <morecore+0x5e>
  hp = (Header*)p;
    16b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16be:	8b 55 08             	mov    0x8(%ebp),%edx
    16c1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16c7:	83 c0 08             	add    $0x8,%eax
    16ca:	83 ec 0c             	sub    $0xc,%esp
    16cd:	50                   	push   %eax
    16ce:	e8 c8 fe ff ff       	call   159b <free>
    16d3:	83 c4 10             	add    $0x10,%esp
  return freep;
    16d6:	a1 dc 1a 00 00       	mov    0x1adc,%eax
}
    16db:	c9                   	leave  
    16dc:	c3                   	ret    

000016dd <malloc>:

void*
malloc(uint nbytes)
{
    16dd:	55                   	push   %ebp
    16de:	89 e5                	mov    %esp,%ebp
    16e0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    16e3:	8b 45 08             	mov    0x8(%ebp),%eax
    16e6:	83 c0 07             	add    $0x7,%eax
    16e9:	c1 e8 03             	shr    $0x3,%eax
    16ec:	83 c0 01             	add    $0x1,%eax
    16ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    16f2:	a1 dc 1a 00 00       	mov    0x1adc,%eax
    16f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    16fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    16fe:	75 23                	jne    1723 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1700:	c7 45 f0 d4 1a 00 00 	movl   $0x1ad4,-0x10(%ebp)
    1707:	8b 45 f0             	mov    -0x10(%ebp),%eax
    170a:	a3 dc 1a 00 00       	mov    %eax,0x1adc
    170f:	a1 dc 1a 00 00       	mov    0x1adc,%eax
    1714:	a3 d4 1a 00 00       	mov    %eax,0x1ad4
    base.s.size = 0;
    1719:	c7 05 d8 1a 00 00 00 	movl   $0x0,0x1ad8
    1720:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1723:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1726:	8b 00                	mov    (%eax),%eax
    1728:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    172e:	8b 40 04             	mov    0x4(%eax),%eax
    1731:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1734:	72 4d                	jb     1783 <malloc+0xa6>
      if(p->s.size == nunits)
    1736:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1739:	8b 40 04             	mov    0x4(%eax),%eax
    173c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    173f:	75 0c                	jne    174d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1741:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1744:	8b 10                	mov    (%eax),%edx
    1746:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1749:	89 10                	mov    %edx,(%eax)
    174b:	eb 26                	jmp    1773 <malloc+0x96>
      else {
        p->s.size -= nunits;
    174d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1750:	8b 40 04             	mov    0x4(%eax),%eax
    1753:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1756:	89 c2                	mov    %eax,%edx
    1758:	8b 45 f4             	mov    -0xc(%ebp),%eax
    175b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1761:	8b 40 04             	mov    0x4(%eax),%eax
    1764:	c1 e0 03             	shl    $0x3,%eax
    1767:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    176d:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1770:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1773:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1776:	a3 dc 1a 00 00       	mov    %eax,0x1adc
      return (void*)(p + 1);
    177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177e:	83 c0 08             	add    $0x8,%eax
    1781:	eb 3b                	jmp    17be <malloc+0xe1>
    }
    if(p == freep)
    1783:	a1 dc 1a 00 00       	mov    0x1adc,%eax
    1788:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    178b:	75 1e                	jne    17ab <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    178d:	83 ec 0c             	sub    $0xc,%esp
    1790:	ff 75 ec             	pushl  -0x14(%ebp)
    1793:	e8 e5 fe ff ff       	call   167d <morecore>
    1798:	83 c4 10             	add    $0x10,%esp
    179b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    179e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17a2:	75 07                	jne    17ab <malloc+0xce>
        return 0;
    17a4:	b8 00 00 00 00       	mov    $0x0,%eax
    17a9:	eb 13                	jmp    17be <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b4:	8b 00                	mov    (%eax),%eax
    17b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17b9:	e9 6d ff ff ff       	jmp    172b <malloc+0x4e>
}
    17be:	c9                   	leave  
    17bf:	c3                   	ret    

000017c0 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    17c0:	55                   	push   %ebp
    17c1:	89 e5                	mov    %esp,%ebp
    17c3:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    17c6:	8b 55 08             	mov    0x8(%ebp),%edx
    17c9:	8b 45 0c             	mov    0xc(%ebp),%eax
    17cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
    17cf:	f0 87 02             	lock xchg %eax,(%edx)
    17d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    17d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    17d8:	c9                   	leave  
    17d9:	c3                   	ret    

000017da <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    17da:	55                   	push   %ebp
    17db:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    17dd:	90                   	nop
    17de:	8b 45 08             	mov    0x8(%ebp),%eax
    17e1:	6a 01                	push   $0x1
    17e3:	50                   	push   %eax
    17e4:	e8 d7 ff ff ff       	call   17c0 <xchg>
    17e9:	83 c4 08             	add    $0x8,%esp
    17ec:	85 c0                	test   %eax,%eax
    17ee:	75 ee                	jne    17de <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    17f0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    17f5:	90                   	nop
    17f6:	c9                   	leave  
    17f7:	c3                   	ret    

000017f8 <urelease>:

void urelease (struct uspinlock *lk) {
    17f8:	55                   	push   %ebp
    17f9:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    17fb:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1800:	8b 45 08             	mov    0x8(%ebp),%eax
    1803:	8b 55 08             	mov    0x8(%ebp),%edx
    1806:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    180c:	90                   	nop
    180d:	5d                   	pop    %ebp
    180e:	c3                   	ret    
