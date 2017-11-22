
_echo:     file format elf32-i386


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
    100f:	83 ec 10             	sub    $0x10,%esp
    1012:	89 cb                	mov    %ecx,%ebx
  int i;

  for(i = 1; i < argc; i++)
    1014:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    101b:	eb 3c                	jmp    1059 <main+0x59>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
    101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1020:	83 c0 01             	add    $0x1,%eax
    1023:	3b 03                	cmp    (%ebx),%eax
    1025:	7d 07                	jge    102e <main+0x2e>
    1027:	ba 48 18 00 00       	mov    $0x1848,%edx
    102c:	eb 05                	jmp    1033 <main+0x33>
    102e:	ba 4a 18 00 00       	mov    $0x184a,%edx
    1033:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1036:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
    103d:	8b 43 04             	mov    0x4(%ebx),%eax
    1040:	01 c8                	add    %ecx,%eax
    1042:	8b 00                	mov    (%eax),%eax
    1044:	52                   	push   %edx
    1045:	50                   	push   %eax
    1046:	68 4c 18 00 00       	push   $0x184c
    104b:	6a 01                	push   $0x1
    104d:	e8 f1 03 00 00       	call   1443 <printf>
    1052:	83 c4 10             	add    $0x10,%esp
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
    1055:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1059:	8b 45 f4             	mov    -0xc(%ebp),%eax
    105c:	3b 03                	cmp    (%ebx),%eax
    105e:	7c bd                	jl     101d <main+0x1d>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
    1060:	e8 57 02 00 00       	call   12bc <exit>

00001065 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1065:	55                   	push   %ebp
    1066:	89 e5                	mov    %esp,%ebp
    1068:	57                   	push   %edi
    1069:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
    106d:	8b 55 10             	mov    0x10(%ebp),%edx
    1070:	8b 45 0c             	mov    0xc(%ebp),%eax
    1073:	89 cb                	mov    %ecx,%ebx
    1075:	89 df                	mov    %ebx,%edi
    1077:	89 d1                	mov    %edx,%ecx
    1079:	fc                   	cld    
    107a:	f3 aa                	rep stos %al,%es:(%edi)
    107c:	89 ca                	mov    %ecx,%edx
    107e:	89 fb                	mov    %edi,%ebx
    1080:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1083:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1086:	90                   	nop
    1087:	5b                   	pop    %ebx
    1088:	5f                   	pop    %edi
    1089:	5d                   	pop    %ebp
    108a:	c3                   	ret    

0000108b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    108b:	55                   	push   %ebp
    108c:	89 e5                	mov    %esp,%ebp
    108e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1091:	8b 45 08             	mov    0x8(%ebp),%eax
    1094:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1097:	90                   	nop
    1098:	8b 45 08             	mov    0x8(%ebp),%eax
    109b:	8d 50 01             	lea    0x1(%eax),%edx
    109e:	89 55 08             	mov    %edx,0x8(%ebp)
    10a1:	8b 55 0c             	mov    0xc(%ebp),%edx
    10a4:	8d 4a 01             	lea    0x1(%edx),%ecx
    10a7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10aa:	0f b6 12             	movzbl (%edx),%edx
    10ad:	88 10                	mov    %dl,(%eax)
    10af:	0f b6 00             	movzbl (%eax),%eax
    10b2:	84 c0                	test   %al,%al
    10b4:	75 e2                	jne    1098 <strcpy+0xd>
    ;
  return os;
    10b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10b9:	c9                   	leave  
    10ba:	c3                   	ret    

000010bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10bb:	55                   	push   %ebp
    10bc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10be:	eb 08                	jmp    10c8 <strcmp+0xd>
    p++, q++;
    10c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10c8:	8b 45 08             	mov    0x8(%ebp),%eax
    10cb:	0f b6 00             	movzbl (%eax),%eax
    10ce:	84 c0                	test   %al,%al
    10d0:	74 10                	je     10e2 <strcmp+0x27>
    10d2:	8b 45 08             	mov    0x8(%ebp),%eax
    10d5:	0f b6 10             	movzbl (%eax),%edx
    10d8:	8b 45 0c             	mov    0xc(%ebp),%eax
    10db:	0f b6 00             	movzbl (%eax),%eax
    10de:	38 c2                	cmp    %al,%dl
    10e0:	74 de                	je     10c0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10e2:	8b 45 08             	mov    0x8(%ebp),%eax
    10e5:	0f b6 00             	movzbl (%eax),%eax
    10e8:	0f b6 d0             	movzbl %al,%edx
    10eb:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ee:	0f b6 00             	movzbl (%eax),%eax
    10f1:	0f b6 c0             	movzbl %al,%eax
    10f4:	29 c2                	sub    %eax,%edx
    10f6:	89 d0                	mov    %edx,%eax
}
    10f8:	5d                   	pop    %ebp
    10f9:	c3                   	ret    

000010fa <strlen>:

uint
strlen(char *s)
{
    10fa:	55                   	push   %ebp
    10fb:	89 e5                	mov    %esp,%ebp
    10fd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1100:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1107:	eb 04                	jmp    110d <strlen+0x13>
    1109:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    110d:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1110:	8b 45 08             	mov    0x8(%ebp),%eax
    1113:	01 d0                	add    %edx,%eax
    1115:	0f b6 00             	movzbl (%eax),%eax
    1118:	84 c0                	test   %al,%al
    111a:	75 ed                	jne    1109 <strlen+0xf>
    ;
  return n;
    111c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    111f:	c9                   	leave  
    1120:	c3                   	ret    

00001121 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1121:	55                   	push   %ebp
    1122:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1124:	8b 45 10             	mov    0x10(%ebp),%eax
    1127:	50                   	push   %eax
    1128:	ff 75 0c             	pushl  0xc(%ebp)
    112b:	ff 75 08             	pushl  0x8(%ebp)
    112e:	e8 32 ff ff ff       	call   1065 <stosb>
    1133:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1136:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1139:	c9                   	leave  
    113a:	c3                   	ret    

0000113b <strchr>:

char*
strchr(const char *s, char c)
{
    113b:	55                   	push   %ebp
    113c:	89 e5                	mov    %esp,%ebp
    113e:	83 ec 04             	sub    $0x4,%esp
    1141:	8b 45 0c             	mov    0xc(%ebp),%eax
    1144:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1147:	eb 14                	jmp    115d <strchr+0x22>
    if(*s == c)
    1149:	8b 45 08             	mov    0x8(%ebp),%eax
    114c:	0f b6 00             	movzbl (%eax),%eax
    114f:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1152:	75 05                	jne    1159 <strchr+0x1e>
      return (char*)s;
    1154:	8b 45 08             	mov    0x8(%ebp),%eax
    1157:	eb 13                	jmp    116c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1159:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    115d:	8b 45 08             	mov    0x8(%ebp),%eax
    1160:	0f b6 00             	movzbl (%eax),%eax
    1163:	84 c0                	test   %al,%al
    1165:	75 e2                	jne    1149 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1167:	b8 00 00 00 00       	mov    $0x0,%eax
}
    116c:	c9                   	leave  
    116d:	c3                   	ret    

0000116e <gets>:

char*
gets(char *buf, int max)
{
    116e:	55                   	push   %ebp
    116f:	89 e5                	mov    %esp,%ebp
    1171:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1174:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    117b:	eb 42                	jmp    11bf <gets+0x51>
    cc = read(0, &c, 1);
    117d:	83 ec 04             	sub    $0x4,%esp
    1180:	6a 01                	push   $0x1
    1182:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1185:	50                   	push   %eax
    1186:	6a 00                	push   $0x0
    1188:	e8 47 01 00 00       	call   12d4 <read>
    118d:	83 c4 10             	add    $0x10,%esp
    1190:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1193:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1197:	7e 33                	jle    11cc <gets+0x5e>
      break;
    buf[i++] = c;
    1199:	8b 45 f4             	mov    -0xc(%ebp),%eax
    119c:	8d 50 01             	lea    0x1(%eax),%edx
    119f:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11a2:	89 c2                	mov    %eax,%edx
    11a4:	8b 45 08             	mov    0x8(%ebp),%eax
    11a7:	01 c2                	add    %eax,%edx
    11a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ad:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11b3:	3c 0a                	cmp    $0xa,%al
    11b5:	74 16                	je     11cd <gets+0x5f>
    11b7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11bb:	3c 0d                	cmp    $0xd,%al
    11bd:	74 0e                	je     11cd <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11c2:	83 c0 01             	add    $0x1,%eax
    11c5:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11c8:	7c b3                	jl     117d <gets+0xf>
    11ca:	eb 01                	jmp    11cd <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11cc:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11d0:	8b 45 08             	mov    0x8(%ebp),%eax
    11d3:	01 d0                	add    %edx,%eax
    11d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11db:	c9                   	leave  
    11dc:	c3                   	ret    

000011dd <stat>:

int
stat(char *n, struct stat *st)
{
    11dd:	55                   	push   %ebp
    11de:	89 e5                	mov    %esp,%ebp
    11e0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11e3:	83 ec 08             	sub    $0x8,%esp
    11e6:	6a 00                	push   $0x0
    11e8:	ff 75 08             	pushl  0x8(%ebp)
    11eb:	e8 0c 01 00 00       	call   12fc <open>
    11f0:	83 c4 10             	add    $0x10,%esp
    11f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11fa:	79 07                	jns    1203 <stat+0x26>
    return -1;
    11fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1201:	eb 25                	jmp    1228 <stat+0x4b>
  r = fstat(fd, st);
    1203:	83 ec 08             	sub    $0x8,%esp
    1206:	ff 75 0c             	pushl  0xc(%ebp)
    1209:	ff 75 f4             	pushl  -0xc(%ebp)
    120c:	e8 03 01 00 00       	call   1314 <fstat>
    1211:	83 c4 10             	add    $0x10,%esp
    1214:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1217:	83 ec 0c             	sub    $0xc,%esp
    121a:	ff 75 f4             	pushl  -0xc(%ebp)
    121d:	e8 c2 00 00 00       	call   12e4 <close>
    1222:	83 c4 10             	add    $0x10,%esp
  return r;
    1225:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1228:	c9                   	leave  
    1229:	c3                   	ret    

0000122a <atoi>:

int
atoi(const char *s)
{
    122a:	55                   	push   %ebp
    122b:	89 e5                	mov    %esp,%ebp
    122d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1230:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1237:	eb 25                	jmp    125e <atoi+0x34>
    n = n*10 + *s++ - '0';
    1239:	8b 55 fc             	mov    -0x4(%ebp),%edx
    123c:	89 d0                	mov    %edx,%eax
    123e:	c1 e0 02             	shl    $0x2,%eax
    1241:	01 d0                	add    %edx,%eax
    1243:	01 c0                	add    %eax,%eax
    1245:	89 c1                	mov    %eax,%ecx
    1247:	8b 45 08             	mov    0x8(%ebp),%eax
    124a:	8d 50 01             	lea    0x1(%eax),%edx
    124d:	89 55 08             	mov    %edx,0x8(%ebp)
    1250:	0f b6 00             	movzbl (%eax),%eax
    1253:	0f be c0             	movsbl %al,%eax
    1256:	01 c8                	add    %ecx,%eax
    1258:	83 e8 30             	sub    $0x30,%eax
    125b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    125e:	8b 45 08             	mov    0x8(%ebp),%eax
    1261:	0f b6 00             	movzbl (%eax),%eax
    1264:	3c 2f                	cmp    $0x2f,%al
    1266:	7e 0a                	jle    1272 <atoi+0x48>
    1268:	8b 45 08             	mov    0x8(%ebp),%eax
    126b:	0f b6 00             	movzbl (%eax),%eax
    126e:	3c 39                	cmp    $0x39,%al
    1270:	7e c7                	jle    1239 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1272:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1275:	c9                   	leave  
    1276:	c3                   	ret    

00001277 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1277:	55                   	push   %ebp
    1278:	89 e5                	mov    %esp,%ebp
    127a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    127d:	8b 45 08             	mov    0x8(%ebp),%eax
    1280:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1283:	8b 45 0c             	mov    0xc(%ebp),%eax
    1286:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1289:	eb 17                	jmp    12a2 <memmove+0x2b>
    *dst++ = *src++;
    128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    128e:	8d 50 01             	lea    0x1(%eax),%edx
    1291:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1294:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1297:	8d 4a 01             	lea    0x1(%edx),%ecx
    129a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    129d:	0f b6 12             	movzbl (%edx),%edx
    12a0:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12a2:	8b 45 10             	mov    0x10(%ebp),%eax
    12a5:	8d 50 ff             	lea    -0x1(%eax),%edx
    12a8:	89 55 10             	mov    %edx,0x10(%ebp)
    12ab:	85 c0                	test   %eax,%eax
    12ad:	7f dc                	jg     128b <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12af:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12b2:	c9                   	leave  
    12b3:	c3                   	ret    

000012b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12b4:	b8 01 00 00 00       	mov    $0x1,%eax
    12b9:	cd 40                	int    $0x40
    12bb:	c3                   	ret    

000012bc <exit>:
SYSCALL(exit)
    12bc:	b8 02 00 00 00       	mov    $0x2,%eax
    12c1:	cd 40                	int    $0x40
    12c3:	c3                   	ret    

000012c4 <wait>:
SYSCALL(wait)
    12c4:	b8 03 00 00 00       	mov    $0x3,%eax
    12c9:	cd 40                	int    $0x40
    12cb:	c3                   	ret    

000012cc <pipe>:
SYSCALL(pipe)
    12cc:	b8 04 00 00 00       	mov    $0x4,%eax
    12d1:	cd 40                	int    $0x40
    12d3:	c3                   	ret    

000012d4 <read>:
SYSCALL(read)
    12d4:	b8 05 00 00 00       	mov    $0x5,%eax
    12d9:	cd 40                	int    $0x40
    12db:	c3                   	ret    

000012dc <write>:
SYSCALL(write)
    12dc:	b8 10 00 00 00       	mov    $0x10,%eax
    12e1:	cd 40                	int    $0x40
    12e3:	c3                   	ret    

000012e4 <close>:
SYSCALL(close)
    12e4:	b8 15 00 00 00       	mov    $0x15,%eax
    12e9:	cd 40                	int    $0x40
    12eb:	c3                   	ret    

000012ec <kill>:
SYSCALL(kill)
    12ec:	b8 06 00 00 00       	mov    $0x6,%eax
    12f1:	cd 40                	int    $0x40
    12f3:	c3                   	ret    

000012f4 <exec>:
SYSCALL(exec)
    12f4:	b8 07 00 00 00       	mov    $0x7,%eax
    12f9:	cd 40                	int    $0x40
    12fb:	c3                   	ret    

000012fc <open>:
SYSCALL(open)
    12fc:	b8 0f 00 00 00       	mov    $0xf,%eax
    1301:	cd 40                	int    $0x40
    1303:	c3                   	ret    

00001304 <mknod>:
SYSCALL(mknod)
    1304:	b8 11 00 00 00       	mov    $0x11,%eax
    1309:	cd 40                	int    $0x40
    130b:	c3                   	ret    

0000130c <unlink>:
SYSCALL(unlink)
    130c:	b8 12 00 00 00       	mov    $0x12,%eax
    1311:	cd 40                	int    $0x40
    1313:	c3                   	ret    

00001314 <fstat>:
SYSCALL(fstat)
    1314:	b8 08 00 00 00       	mov    $0x8,%eax
    1319:	cd 40                	int    $0x40
    131b:	c3                   	ret    

0000131c <link>:
SYSCALL(link)
    131c:	b8 13 00 00 00       	mov    $0x13,%eax
    1321:	cd 40                	int    $0x40
    1323:	c3                   	ret    

00001324 <mkdir>:
SYSCALL(mkdir)
    1324:	b8 14 00 00 00       	mov    $0x14,%eax
    1329:	cd 40                	int    $0x40
    132b:	c3                   	ret    

0000132c <chdir>:
SYSCALL(chdir)
    132c:	b8 09 00 00 00       	mov    $0x9,%eax
    1331:	cd 40                	int    $0x40
    1333:	c3                   	ret    

00001334 <dup>:
SYSCALL(dup)
    1334:	b8 0a 00 00 00       	mov    $0xa,%eax
    1339:	cd 40                	int    $0x40
    133b:	c3                   	ret    

0000133c <getpid>:
SYSCALL(getpid)
    133c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1341:	cd 40                	int    $0x40
    1343:	c3                   	ret    

00001344 <sbrk>:
SYSCALL(sbrk)
    1344:	b8 0c 00 00 00       	mov    $0xc,%eax
    1349:	cd 40                	int    $0x40
    134b:	c3                   	ret    

0000134c <sleep>:
SYSCALL(sleep)
    134c:	b8 0d 00 00 00       	mov    $0xd,%eax
    1351:	cd 40                	int    $0x40
    1353:	c3                   	ret    

00001354 <uptime>:
SYSCALL(uptime)
    1354:	b8 0e 00 00 00       	mov    $0xe,%eax
    1359:	cd 40                	int    $0x40
    135b:	c3                   	ret    

0000135c <shm_open>:
SYSCALL(shm_open)
    135c:	b8 16 00 00 00       	mov    $0x16,%eax
    1361:	cd 40                	int    $0x40
    1363:	c3                   	ret    

00001364 <shm_close>:
SYSCALL(shm_close)	
    1364:	b8 17 00 00 00       	mov    $0x17,%eax
    1369:	cd 40                	int    $0x40
    136b:	c3                   	ret    

0000136c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    136c:	55                   	push   %ebp
    136d:	89 e5                	mov    %esp,%ebp
    136f:	83 ec 18             	sub    $0x18,%esp
    1372:	8b 45 0c             	mov    0xc(%ebp),%eax
    1375:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1378:	83 ec 04             	sub    $0x4,%esp
    137b:	6a 01                	push   $0x1
    137d:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1380:	50                   	push   %eax
    1381:	ff 75 08             	pushl  0x8(%ebp)
    1384:	e8 53 ff ff ff       	call   12dc <write>
    1389:	83 c4 10             	add    $0x10,%esp
}
    138c:	90                   	nop
    138d:	c9                   	leave  
    138e:	c3                   	ret    

0000138f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    138f:	55                   	push   %ebp
    1390:	89 e5                	mov    %esp,%ebp
    1392:	53                   	push   %ebx
    1393:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    139d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13a1:	74 17                	je     13ba <printint+0x2b>
    13a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13a7:	79 11                	jns    13ba <printint+0x2b>
    neg = 1;
    13a9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13b0:	8b 45 0c             	mov    0xc(%ebp),%eax
    13b3:	f7 d8                	neg    %eax
    13b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13b8:	eb 06                	jmp    13c0 <printint+0x31>
  } else {
    x = xx;
    13ba:	8b 45 0c             	mov    0xc(%ebp),%eax
    13bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13c7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13ca:	8d 41 01             	lea    0x1(%ecx),%eax
    13cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13d6:	ba 00 00 00 00       	mov    $0x0,%edx
    13db:	f7 f3                	div    %ebx
    13dd:	89 d0                	mov    %edx,%eax
    13df:	0f b6 80 04 1b 00 00 	movzbl 0x1b04(%eax),%eax
    13e6:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13f0:	ba 00 00 00 00       	mov    $0x0,%edx
    13f5:	f7 f3                	div    %ebx
    13f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13fe:	75 c7                	jne    13c7 <printint+0x38>
  if(neg)
    1400:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1404:	74 2d                	je     1433 <printint+0xa4>
    buf[i++] = '-';
    1406:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1409:	8d 50 01             	lea    0x1(%eax),%edx
    140c:	89 55 f4             	mov    %edx,-0xc(%ebp)
    140f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1414:	eb 1d                	jmp    1433 <printint+0xa4>
    putc(fd, buf[i]);
    1416:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1419:	8b 45 f4             	mov    -0xc(%ebp),%eax
    141c:	01 d0                	add    %edx,%eax
    141e:	0f b6 00             	movzbl (%eax),%eax
    1421:	0f be c0             	movsbl %al,%eax
    1424:	83 ec 08             	sub    $0x8,%esp
    1427:	50                   	push   %eax
    1428:	ff 75 08             	pushl  0x8(%ebp)
    142b:	e8 3c ff ff ff       	call   136c <putc>
    1430:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1433:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1437:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    143b:	79 d9                	jns    1416 <printint+0x87>
    putc(fd, buf[i]);
}
    143d:	90                   	nop
    143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1441:	c9                   	leave  
    1442:	c3                   	ret    

00001443 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1443:	55                   	push   %ebp
    1444:	89 e5                	mov    %esp,%ebp
    1446:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1449:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1450:	8d 45 0c             	lea    0xc(%ebp),%eax
    1453:	83 c0 04             	add    $0x4,%eax
    1456:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1459:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1460:	e9 59 01 00 00       	jmp    15be <printf+0x17b>
    c = fmt[i] & 0xff;
    1465:	8b 55 0c             	mov    0xc(%ebp),%edx
    1468:	8b 45 f0             	mov    -0x10(%ebp),%eax
    146b:	01 d0                	add    %edx,%eax
    146d:	0f b6 00             	movzbl (%eax),%eax
    1470:	0f be c0             	movsbl %al,%eax
    1473:	25 ff 00 00 00       	and    $0xff,%eax
    1478:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    147b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    147f:	75 2c                	jne    14ad <printf+0x6a>
      if(c == '%'){
    1481:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1485:	75 0c                	jne    1493 <printf+0x50>
        state = '%';
    1487:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    148e:	e9 27 01 00 00       	jmp    15ba <printf+0x177>
      } else {
        putc(fd, c);
    1493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1496:	0f be c0             	movsbl %al,%eax
    1499:	83 ec 08             	sub    $0x8,%esp
    149c:	50                   	push   %eax
    149d:	ff 75 08             	pushl  0x8(%ebp)
    14a0:	e8 c7 fe ff ff       	call   136c <putc>
    14a5:	83 c4 10             	add    $0x10,%esp
    14a8:	e9 0d 01 00 00       	jmp    15ba <printf+0x177>
      }
    } else if(state == '%'){
    14ad:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14b1:	0f 85 03 01 00 00    	jne    15ba <printf+0x177>
      if(c == 'd'){
    14b7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14bb:	75 1e                	jne    14db <printf+0x98>
        printint(fd, *ap, 10, 1);
    14bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14c0:	8b 00                	mov    (%eax),%eax
    14c2:	6a 01                	push   $0x1
    14c4:	6a 0a                	push   $0xa
    14c6:	50                   	push   %eax
    14c7:	ff 75 08             	pushl  0x8(%ebp)
    14ca:	e8 c0 fe ff ff       	call   138f <printint>
    14cf:	83 c4 10             	add    $0x10,%esp
        ap++;
    14d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14d6:	e9 d8 00 00 00       	jmp    15b3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14db:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14df:	74 06                	je     14e7 <printf+0xa4>
    14e1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14e5:	75 1e                	jne    1505 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14ea:	8b 00                	mov    (%eax),%eax
    14ec:	6a 00                	push   $0x0
    14ee:	6a 10                	push   $0x10
    14f0:	50                   	push   %eax
    14f1:	ff 75 08             	pushl  0x8(%ebp)
    14f4:	e8 96 fe ff ff       	call   138f <printint>
    14f9:	83 c4 10             	add    $0x10,%esp
        ap++;
    14fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1500:	e9 ae 00 00 00       	jmp    15b3 <printf+0x170>
      } else if(c == 's'){
    1505:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1509:	75 43                	jne    154e <printf+0x10b>
        s = (char*)*ap;
    150b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    150e:	8b 00                	mov    (%eax),%eax
    1510:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1513:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1517:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    151b:	75 25                	jne    1542 <printf+0xff>
          s = "(null)";
    151d:	c7 45 f4 51 18 00 00 	movl   $0x1851,-0xc(%ebp)
        while(*s != 0){
    1524:	eb 1c                	jmp    1542 <printf+0xff>
          putc(fd, *s);
    1526:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1529:	0f b6 00             	movzbl (%eax),%eax
    152c:	0f be c0             	movsbl %al,%eax
    152f:	83 ec 08             	sub    $0x8,%esp
    1532:	50                   	push   %eax
    1533:	ff 75 08             	pushl  0x8(%ebp)
    1536:	e8 31 fe ff ff       	call   136c <putc>
    153b:	83 c4 10             	add    $0x10,%esp
          s++;
    153e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1542:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1545:	0f b6 00             	movzbl (%eax),%eax
    1548:	84 c0                	test   %al,%al
    154a:	75 da                	jne    1526 <printf+0xe3>
    154c:	eb 65                	jmp    15b3 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    154e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1552:	75 1d                	jne    1571 <printf+0x12e>
        putc(fd, *ap);
    1554:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1557:	8b 00                	mov    (%eax),%eax
    1559:	0f be c0             	movsbl %al,%eax
    155c:	83 ec 08             	sub    $0x8,%esp
    155f:	50                   	push   %eax
    1560:	ff 75 08             	pushl  0x8(%ebp)
    1563:	e8 04 fe ff ff       	call   136c <putc>
    1568:	83 c4 10             	add    $0x10,%esp
        ap++;
    156b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    156f:	eb 42                	jmp    15b3 <printf+0x170>
      } else if(c == '%'){
    1571:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1575:	75 17                	jne    158e <printf+0x14b>
        putc(fd, c);
    1577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    157a:	0f be c0             	movsbl %al,%eax
    157d:	83 ec 08             	sub    $0x8,%esp
    1580:	50                   	push   %eax
    1581:	ff 75 08             	pushl  0x8(%ebp)
    1584:	e8 e3 fd ff ff       	call   136c <putc>
    1589:	83 c4 10             	add    $0x10,%esp
    158c:	eb 25                	jmp    15b3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    158e:	83 ec 08             	sub    $0x8,%esp
    1591:	6a 25                	push   $0x25
    1593:	ff 75 08             	pushl  0x8(%ebp)
    1596:	e8 d1 fd ff ff       	call   136c <putc>
    159b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    159e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15a1:	0f be c0             	movsbl %al,%eax
    15a4:	83 ec 08             	sub    $0x8,%esp
    15a7:	50                   	push   %eax
    15a8:	ff 75 08             	pushl  0x8(%ebp)
    15ab:	e8 bc fd ff ff       	call   136c <putc>
    15b0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15ba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15be:	8b 55 0c             	mov    0xc(%ebp),%edx
    15c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15c4:	01 d0                	add    %edx,%eax
    15c6:	0f b6 00             	movzbl (%eax),%eax
    15c9:	84 c0                	test   %al,%al
    15cb:	0f 85 94 fe ff ff    	jne    1465 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15d1:	90                   	nop
    15d2:	c9                   	leave  
    15d3:	c3                   	ret    

000015d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15d4:	55                   	push   %ebp
    15d5:	89 e5                	mov    %esp,%ebp
    15d7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15da:	8b 45 08             	mov    0x8(%ebp),%eax
    15dd:	83 e8 08             	sub    $0x8,%eax
    15e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15e3:	a1 20 1b 00 00       	mov    0x1b20,%eax
    15e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15eb:	eb 24                	jmp    1611 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15f0:	8b 00                	mov    (%eax),%eax
    15f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15f5:	77 12                	ja     1609 <free+0x35>
    15f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15fd:	77 24                	ja     1623 <free+0x4f>
    15ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1602:	8b 00                	mov    (%eax),%eax
    1604:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1607:	77 1a                	ja     1623 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1609:	8b 45 fc             	mov    -0x4(%ebp),%eax
    160c:	8b 00                	mov    (%eax),%eax
    160e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1611:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1614:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1617:	76 d4                	jbe    15ed <free+0x19>
    1619:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161c:	8b 00                	mov    (%eax),%eax
    161e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1621:	76 ca                	jbe    15ed <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1623:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1626:	8b 40 04             	mov    0x4(%eax),%eax
    1629:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1630:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1633:	01 c2                	add    %eax,%edx
    1635:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1638:	8b 00                	mov    (%eax),%eax
    163a:	39 c2                	cmp    %eax,%edx
    163c:	75 24                	jne    1662 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    163e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1641:	8b 50 04             	mov    0x4(%eax),%edx
    1644:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1647:	8b 00                	mov    (%eax),%eax
    1649:	8b 40 04             	mov    0x4(%eax),%eax
    164c:	01 c2                	add    %eax,%edx
    164e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1651:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1654:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1657:	8b 00                	mov    (%eax),%eax
    1659:	8b 10                	mov    (%eax),%edx
    165b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    165e:	89 10                	mov    %edx,(%eax)
    1660:	eb 0a                	jmp    166c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1662:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1665:	8b 10                	mov    (%eax),%edx
    1667:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    166c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166f:	8b 40 04             	mov    0x4(%eax),%eax
    1672:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1679:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167c:	01 d0                	add    %edx,%eax
    167e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1681:	75 20                	jne    16a3 <free+0xcf>
    p->s.size += bp->s.size;
    1683:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1686:	8b 50 04             	mov    0x4(%eax),%edx
    1689:	8b 45 f8             	mov    -0x8(%ebp),%eax
    168c:	8b 40 04             	mov    0x4(%eax),%eax
    168f:	01 c2                	add    %eax,%edx
    1691:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1694:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1697:	8b 45 f8             	mov    -0x8(%ebp),%eax
    169a:	8b 10                	mov    (%eax),%edx
    169c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169f:	89 10                	mov    %edx,(%eax)
    16a1:	eb 08                	jmp    16ab <free+0xd7>
  } else
    p->s.ptr = bp;
    16a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a6:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16a9:	89 10                	mov    %edx,(%eax)
  freep = p;
    16ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ae:	a3 20 1b 00 00       	mov    %eax,0x1b20
}
    16b3:	90                   	nop
    16b4:	c9                   	leave  
    16b5:	c3                   	ret    

000016b6 <morecore>:

static Header*
morecore(uint nu)
{
    16b6:	55                   	push   %ebp
    16b7:	89 e5                	mov    %esp,%ebp
    16b9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16bc:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16c3:	77 07                	ja     16cc <morecore+0x16>
    nu = 4096;
    16c5:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16cc:	8b 45 08             	mov    0x8(%ebp),%eax
    16cf:	c1 e0 03             	shl    $0x3,%eax
    16d2:	83 ec 0c             	sub    $0xc,%esp
    16d5:	50                   	push   %eax
    16d6:	e8 69 fc ff ff       	call   1344 <sbrk>
    16db:	83 c4 10             	add    $0x10,%esp
    16de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16e1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16e5:	75 07                	jne    16ee <morecore+0x38>
    return 0;
    16e7:	b8 00 00 00 00       	mov    $0x0,%eax
    16ec:	eb 26                	jmp    1714 <morecore+0x5e>
  hp = (Header*)p;
    16ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16f7:	8b 55 08             	mov    0x8(%ebp),%edx
    16fa:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1700:	83 c0 08             	add    $0x8,%eax
    1703:	83 ec 0c             	sub    $0xc,%esp
    1706:	50                   	push   %eax
    1707:	e8 c8 fe ff ff       	call   15d4 <free>
    170c:	83 c4 10             	add    $0x10,%esp
  return freep;
    170f:	a1 20 1b 00 00       	mov    0x1b20,%eax
}
    1714:	c9                   	leave  
    1715:	c3                   	ret    

00001716 <malloc>:

void*
malloc(uint nbytes)
{
    1716:	55                   	push   %ebp
    1717:	89 e5                	mov    %esp,%ebp
    1719:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    171c:	8b 45 08             	mov    0x8(%ebp),%eax
    171f:	83 c0 07             	add    $0x7,%eax
    1722:	c1 e8 03             	shr    $0x3,%eax
    1725:	83 c0 01             	add    $0x1,%eax
    1728:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    172b:	a1 20 1b 00 00       	mov    0x1b20,%eax
    1730:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1733:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1737:	75 23                	jne    175c <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1739:	c7 45 f0 18 1b 00 00 	movl   $0x1b18,-0x10(%ebp)
    1740:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1743:	a3 20 1b 00 00       	mov    %eax,0x1b20
    1748:	a1 20 1b 00 00       	mov    0x1b20,%eax
    174d:	a3 18 1b 00 00       	mov    %eax,0x1b18
    base.s.size = 0;
    1752:	c7 05 1c 1b 00 00 00 	movl   $0x0,0x1b1c
    1759:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    175f:	8b 00                	mov    (%eax),%eax
    1761:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1764:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1767:	8b 40 04             	mov    0x4(%eax),%eax
    176a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    176d:	72 4d                	jb     17bc <malloc+0xa6>
      if(p->s.size == nunits)
    176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1772:	8b 40 04             	mov    0x4(%eax),%eax
    1775:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1778:	75 0c                	jne    1786 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177d:	8b 10                	mov    (%eax),%edx
    177f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1782:	89 10                	mov    %edx,(%eax)
    1784:	eb 26                	jmp    17ac <malloc+0x96>
      else {
        p->s.size -= nunits;
    1786:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1789:	8b 40 04             	mov    0x4(%eax),%eax
    178c:	2b 45 ec             	sub    -0x14(%ebp),%eax
    178f:	89 c2                	mov    %eax,%edx
    1791:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1794:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1797:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179a:	8b 40 04             	mov    0x4(%eax),%eax
    179d:	c1 e0 03             	shl    $0x3,%eax
    17a0:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17a9:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17af:	a3 20 1b 00 00       	mov    %eax,0x1b20
      return (void*)(p + 1);
    17b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b7:	83 c0 08             	add    $0x8,%eax
    17ba:	eb 3b                	jmp    17f7 <malloc+0xe1>
    }
    if(p == freep)
    17bc:	a1 20 1b 00 00       	mov    0x1b20,%eax
    17c1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17c4:	75 1e                	jne    17e4 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17c6:	83 ec 0c             	sub    $0xc,%esp
    17c9:	ff 75 ec             	pushl  -0x14(%ebp)
    17cc:	e8 e5 fe ff ff       	call   16b6 <morecore>
    17d1:	83 c4 10             	add    $0x10,%esp
    17d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17db:	75 07                	jne    17e4 <malloc+0xce>
        return 0;
    17dd:	b8 00 00 00 00       	mov    $0x0,%eax
    17e2:	eb 13                	jmp    17f7 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ed:	8b 00                	mov    (%eax),%eax
    17ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17f2:	e9 6d ff ff ff       	jmp    1764 <malloc+0x4e>
}
    17f7:	c9                   	leave  
    17f8:	c3                   	ret    

000017f9 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    17f9:	55                   	push   %ebp
    17fa:	89 e5                	mov    %esp,%ebp
    17fc:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    17ff:	8b 55 08             	mov    0x8(%ebp),%edx
    1802:	8b 45 0c             	mov    0xc(%ebp),%eax
    1805:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1808:	f0 87 02             	lock xchg %eax,(%edx)
    180b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    180e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1811:	c9                   	leave  
    1812:	c3                   	ret    

00001813 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1813:	55                   	push   %ebp
    1814:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1816:	90                   	nop
    1817:	8b 45 08             	mov    0x8(%ebp),%eax
    181a:	6a 01                	push   $0x1
    181c:	50                   	push   %eax
    181d:	e8 d7 ff ff ff       	call   17f9 <xchg>
    1822:	83 c4 08             	add    $0x8,%esp
    1825:	85 c0                	test   %eax,%eax
    1827:	75 ee                	jne    1817 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1829:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    182e:	90                   	nop
    182f:	c9                   	leave  
    1830:	c3                   	ret    

00001831 <urelease>:

void urelease (struct uspinlock *lk) {
    1831:	55                   	push   %ebp
    1832:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1834:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1839:	8b 45 08             	mov    0x8(%ebp),%eax
    183c:	8b 55 08             	mov    0x8(%ebp),%edx
    183f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1845:	90                   	nop
    1846:	5d                   	pop    %ebp
    1847:	c3                   	ret    
