
_null:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	51                   	push   %ecx
    100e:	83 ec 14             	sub    $0x14,%esp
int *i = 0;
    1011:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

(*i)++;
    1018:	8b 45 f4             	mov    -0xc(%ebp),%eax
    101b:	8b 00                	mov    (%eax),%eax
    101d:	8d 50 01             	lea    0x1(%eax),%edx
    1020:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1023:	89 10                	mov    %edx,(%eax)

printf(1,"Hi %d",*i);
    1025:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1028:	8b 00                	mov    (%eax),%eax
    102a:	83 ec 04             	sub    $0x4,%esp
    102d:	50                   	push   %eax
    102e:	68 2d 18 00 00       	push   $0x182d
    1033:	6a 01                	push   $0x1
    1035:	e8 ee 03 00 00       	call   1428 <printf>
    103a:	83 c4 10             	add    $0x10,%esp

return 1;
    103d:	b8 01 00 00 00       	mov    $0x1,%eax
}
    1042:	8b 4d fc             	mov    -0x4(%ebp),%ecx
    1045:	c9                   	leave  
    1046:	8d 61 fc             	lea    -0x4(%ecx),%esp
    1049:	c3                   	ret    

0000104a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    104a:	55                   	push   %ebp
    104b:	89 e5                	mov    %esp,%ebp
    104d:	57                   	push   %edi
    104e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    104f:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1052:	8b 55 10             	mov    0x10(%ebp),%edx
    1055:	8b 45 0c             	mov    0xc(%ebp),%eax
    1058:	89 cb                	mov    %ecx,%ebx
    105a:	89 df                	mov    %ebx,%edi
    105c:	89 d1                	mov    %edx,%ecx
    105e:	fc                   	cld    
    105f:	f3 aa                	rep stos %al,%es:(%edi)
    1061:	89 ca                	mov    %ecx,%edx
    1063:	89 fb                	mov    %edi,%ebx
    1065:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1068:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    106b:	90                   	nop
    106c:	5b                   	pop    %ebx
    106d:	5f                   	pop    %edi
    106e:	5d                   	pop    %ebp
    106f:	c3                   	ret    

00001070 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1070:	55                   	push   %ebp
    1071:	89 e5                	mov    %esp,%ebp
    1073:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1076:	8b 45 08             	mov    0x8(%ebp),%eax
    1079:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    107c:	90                   	nop
    107d:	8b 45 08             	mov    0x8(%ebp),%eax
    1080:	8d 50 01             	lea    0x1(%eax),%edx
    1083:	89 55 08             	mov    %edx,0x8(%ebp)
    1086:	8b 55 0c             	mov    0xc(%ebp),%edx
    1089:	8d 4a 01             	lea    0x1(%edx),%ecx
    108c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    108f:	0f b6 12             	movzbl (%edx),%edx
    1092:	88 10                	mov    %dl,(%eax)
    1094:	0f b6 00             	movzbl (%eax),%eax
    1097:	84 c0                	test   %al,%al
    1099:	75 e2                	jne    107d <strcpy+0xd>
    ;
  return os;
    109b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    109e:	c9                   	leave  
    109f:	c3                   	ret    

000010a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10a0:	55                   	push   %ebp
    10a1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10a3:	eb 08                	jmp    10ad <strcmp+0xd>
    p++, q++;
    10a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10ad:	8b 45 08             	mov    0x8(%ebp),%eax
    10b0:	0f b6 00             	movzbl (%eax),%eax
    10b3:	84 c0                	test   %al,%al
    10b5:	74 10                	je     10c7 <strcmp+0x27>
    10b7:	8b 45 08             	mov    0x8(%ebp),%eax
    10ba:	0f b6 10             	movzbl (%eax),%edx
    10bd:	8b 45 0c             	mov    0xc(%ebp),%eax
    10c0:	0f b6 00             	movzbl (%eax),%eax
    10c3:	38 c2                	cmp    %al,%dl
    10c5:	74 de                	je     10a5 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10c7:	8b 45 08             	mov    0x8(%ebp),%eax
    10ca:	0f b6 00             	movzbl (%eax),%eax
    10cd:	0f b6 d0             	movzbl %al,%edx
    10d0:	8b 45 0c             	mov    0xc(%ebp),%eax
    10d3:	0f b6 00             	movzbl (%eax),%eax
    10d6:	0f b6 c0             	movzbl %al,%eax
    10d9:	29 c2                	sub    %eax,%edx
    10db:	89 d0                	mov    %edx,%eax
}
    10dd:	5d                   	pop    %ebp
    10de:	c3                   	ret    

000010df <strlen>:

uint
strlen(char *s)
{
    10df:	55                   	push   %ebp
    10e0:	89 e5                	mov    %esp,%ebp
    10e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10ec:	eb 04                	jmp    10f2 <strlen+0x13>
    10ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    10f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10f5:	8b 45 08             	mov    0x8(%ebp),%eax
    10f8:	01 d0                	add    %edx,%eax
    10fa:	0f b6 00             	movzbl (%eax),%eax
    10fd:	84 c0                	test   %al,%al
    10ff:	75 ed                	jne    10ee <strlen+0xf>
    ;
  return n;
    1101:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1104:	c9                   	leave  
    1105:	c3                   	ret    

00001106 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1106:	55                   	push   %ebp
    1107:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1109:	8b 45 10             	mov    0x10(%ebp),%eax
    110c:	50                   	push   %eax
    110d:	ff 75 0c             	pushl  0xc(%ebp)
    1110:	ff 75 08             	pushl  0x8(%ebp)
    1113:	e8 32 ff ff ff       	call   104a <stosb>
    1118:	83 c4 0c             	add    $0xc,%esp
  return dst;
    111b:	8b 45 08             	mov    0x8(%ebp),%eax
}
    111e:	c9                   	leave  
    111f:	c3                   	ret    

00001120 <strchr>:

char*
strchr(const char *s, char c)
{
    1120:	55                   	push   %ebp
    1121:	89 e5                	mov    %esp,%ebp
    1123:	83 ec 04             	sub    $0x4,%esp
    1126:	8b 45 0c             	mov    0xc(%ebp),%eax
    1129:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    112c:	eb 14                	jmp    1142 <strchr+0x22>
    if(*s == c)
    112e:	8b 45 08             	mov    0x8(%ebp),%eax
    1131:	0f b6 00             	movzbl (%eax),%eax
    1134:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1137:	75 05                	jne    113e <strchr+0x1e>
      return (char*)s;
    1139:	8b 45 08             	mov    0x8(%ebp),%eax
    113c:	eb 13                	jmp    1151 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    113e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1142:	8b 45 08             	mov    0x8(%ebp),%eax
    1145:	0f b6 00             	movzbl (%eax),%eax
    1148:	84 c0                	test   %al,%al
    114a:	75 e2                	jne    112e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    114c:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1151:	c9                   	leave  
    1152:	c3                   	ret    

00001153 <gets>:

char*
gets(char *buf, int max)
{
    1153:	55                   	push   %ebp
    1154:	89 e5                	mov    %esp,%ebp
    1156:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1159:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1160:	eb 42                	jmp    11a4 <gets+0x51>
    cc = read(0, &c, 1);
    1162:	83 ec 04             	sub    $0x4,%esp
    1165:	6a 01                	push   $0x1
    1167:	8d 45 ef             	lea    -0x11(%ebp),%eax
    116a:	50                   	push   %eax
    116b:	6a 00                	push   $0x0
    116d:	e8 47 01 00 00       	call   12b9 <read>
    1172:	83 c4 10             	add    $0x10,%esp
    1175:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1178:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    117c:	7e 33                	jle    11b1 <gets+0x5e>
      break;
    buf[i++] = c;
    117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1181:	8d 50 01             	lea    0x1(%eax),%edx
    1184:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1187:	89 c2                	mov    %eax,%edx
    1189:	8b 45 08             	mov    0x8(%ebp),%eax
    118c:	01 c2                	add    %eax,%edx
    118e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1192:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1194:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1198:	3c 0a                	cmp    $0xa,%al
    119a:	74 16                	je     11b2 <gets+0x5f>
    119c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11a0:	3c 0d                	cmp    $0xd,%al
    11a2:	74 0e                	je     11b2 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a7:	83 c0 01             	add    $0x1,%eax
    11aa:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11ad:	7c b3                	jl     1162 <gets+0xf>
    11af:	eb 01                	jmp    11b2 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11b1:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11b5:	8b 45 08             	mov    0x8(%ebp),%eax
    11b8:	01 d0                	add    %edx,%eax
    11ba:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11bd:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11c0:	c9                   	leave  
    11c1:	c3                   	ret    

000011c2 <stat>:

int
stat(char *n, struct stat *st)
{
    11c2:	55                   	push   %ebp
    11c3:	89 e5                	mov    %esp,%ebp
    11c5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11c8:	83 ec 08             	sub    $0x8,%esp
    11cb:	6a 00                	push   $0x0
    11cd:	ff 75 08             	pushl  0x8(%ebp)
    11d0:	e8 0c 01 00 00       	call   12e1 <open>
    11d5:	83 c4 10             	add    $0x10,%esp
    11d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11df:	79 07                	jns    11e8 <stat+0x26>
    return -1;
    11e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11e6:	eb 25                	jmp    120d <stat+0x4b>
  r = fstat(fd, st);
    11e8:	83 ec 08             	sub    $0x8,%esp
    11eb:	ff 75 0c             	pushl  0xc(%ebp)
    11ee:	ff 75 f4             	pushl  -0xc(%ebp)
    11f1:	e8 03 01 00 00       	call   12f9 <fstat>
    11f6:	83 c4 10             	add    $0x10,%esp
    11f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    11fc:	83 ec 0c             	sub    $0xc,%esp
    11ff:	ff 75 f4             	pushl  -0xc(%ebp)
    1202:	e8 c2 00 00 00       	call   12c9 <close>
    1207:	83 c4 10             	add    $0x10,%esp
  return r;
    120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    120d:	c9                   	leave  
    120e:	c3                   	ret    

0000120f <atoi>:

int
atoi(const char *s)
{
    120f:	55                   	push   %ebp
    1210:	89 e5                	mov    %esp,%ebp
    1212:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1215:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    121c:	eb 25                	jmp    1243 <atoi+0x34>
    n = n*10 + *s++ - '0';
    121e:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1221:	89 d0                	mov    %edx,%eax
    1223:	c1 e0 02             	shl    $0x2,%eax
    1226:	01 d0                	add    %edx,%eax
    1228:	01 c0                	add    %eax,%eax
    122a:	89 c1                	mov    %eax,%ecx
    122c:	8b 45 08             	mov    0x8(%ebp),%eax
    122f:	8d 50 01             	lea    0x1(%eax),%edx
    1232:	89 55 08             	mov    %edx,0x8(%ebp)
    1235:	0f b6 00             	movzbl (%eax),%eax
    1238:	0f be c0             	movsbl %al,%eax
    123b:	01 c8                	add    %ecx,%eax
    123d:	83 e8 30             	sub    $0x30,%eax
    1240:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1243:	8b 45 08             	mov    0x8(%ebp),%eax
    1246:	0f b6 00             	movzbl (%eax),%eax
    1249:	3c 2f                	cmp    $0x2f,%al
    124b:	7e 0a                	jle    1257 <atoi+0x48>
    124d:	8b 45 08             	mov    0x8(%ebp),%eax
    1250:	0f b6 00             	movzbl (%eax),%eax
    1253:	3c 39                	cmp    $0x39,%al
    1255:	7e c7                	jle    121e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1257:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    125a:	c9                   	leave  
    125b:	c3                   	ret    

0000125c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    125c:	55                   	push   %ebp
    125d:	89 e5                	mov    %esp,%ebp
    125f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1262:	8b 45 08             	mov    0x8(%ebp),%eax
    1265:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1268:	8b 45 0c             	mov    0xc(%ebp),%eax
    126b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    126e:	eb 17                	jmp    1287 <memmove+0x2b>
    *dst++ = *src++;
    1270:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1273:	8d 50 01             	lea    0x1(%eax),%edx
    1276:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1279:	8b 55 f8             	mov    -0x8(%ebp),%edx
    127c:	8d 4a 01             	lea    0x1(%edx),%ecx
    127f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1282:	0f b6 12             	movzbl (%edx),%edx
    1285:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1287:	8b 45 10             	mov    0x10(%ebp),%eax
    128a:	8d 50 ff             	lea    -0x1(%eax),%edx
    128d:	89 55 10             	mov    %edx,0x10(%ebp)
    1290:	85 c0                	test   %eax,%eax
    1292:	7f dc                	jg     1270 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1294:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1297:	c9                   	leave  
    1298:	c3                   	ret    

00001299 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1299:	b8 01 00 00 00       	mov    $0x1,%eax
    129e:	cd 40                	int    $0x40
    12a0:	c3                   	ret    

000012a1 <exit>:
SYSCALL(exit)
    12a1:	b8 02 00 00 00       	mov    $0x2,%eax
    12a6:	cd 40                	int    $0x40
    12a8:	c3                   	ret    

000012a9 <wait>:
SYSCALL(wait)
    12a9:	b8 03 00 00 00       	mov    $0x3,%eax
    12ae:	cd 40                	int    $0x40
    12b0:	c3                   	ret    

000012b1 <pipe>:
SYSCALL(pipe)
    12b1:	b8 04 00 00 00       	mov    $0x4,%eax
    12b6:	cd 40                	int    $0x40
    12b8:	c3                   	ret    

000012b9 <read>:
SYSCALL(read)
    12b9:	b8 05 00 00 00       	mov    $0x5,%eax
    12be:	cd 40                	int    $0x40
    12c0:	c3                   	ret    

000012c1 <write>:
SYSCALL(write)
    12c1:	b8 10 00 00 00       	mov    $0x10,%eax
    12c6:	cd 40                	int    $0x40
    12c8:	c3                   	ret    

000012c9 <close>:
SYSCALL(close)
    12c9:	b8 15 00 00 00       	mov    $0x15,%eax
    12ce:	cd 40                	int    $0x40
    12d0:	c3                   	ret    

000012d1 <kill>:
SYSCALL(kill)
    12d1:	b8 06 00 00 00       	mov    $0x6,%eax
    12d6:	cd 40                	int    $0x40
    12d8:	c3                   	ret    

000012d9 <exec>:
SYSCALL(exec)
    12d9:	b8 07 00 00 00       	mov    $0x7,%eax
    12de:	cd 40                	int    $0x40
    12e0:	c3                   	ret    

000012e1 <open>:
SYSCALL(open)
    12e1:	b8 0f 00 00 00       	mov    $0xf,%eax
    12e6:	cd 40                	int    $0x40
    12e8:	c3                   	ret    

000012e9 <mknod>:
SYSCALL(mknod)
    12e9:	b8 11 00 00 00       	mov    $0x11,%eax
    12ee:	cd 40                	int    $0x40
    12f0:	c3                   	ret    

000012f1 <unlink>:
SYSCALL(unlink)
    12f1:	b8 12 00 00 00       	mov    $0x12,%eax
    12f6:	cd 40                	int    $0x40
    12f8:	c3                   	ret    

000012f9 <fstat>:
SYSCALL(fstat)
    12f9:	b8 08 00 00 00       	mov    $0x8,%eax
    12fe:	cd 40                	int    $0x40
    1300:	c3                   	ret    

00001301 <link>:
SYSCALL(link)
    1301:	b8 13 00 00 00       	mov    $0x13,%eax
    1306:	cd 40                	int    $0x40
    1308:	c3                   	ret    

00001309 <mkdir>:
SYSCALL(mkdir)
    1309:	b8 14 00 00 00       	mov    $0x14,%eax
    130e:	cd 40                	int    $0x40
    1310:	c3                   	ret    

00001311 <chdir>:
SYSCALL(chdir)
    1311:	b8 09 00 00 00       	mov    $0x9,%eax
    1316:	cd 40                	int    $0x40
    1318:	c3                   	ret    

00001319 <dup>:
SYSCALL(dup)
    1319:	b8 0a 00 00 00       	mov    $0xa,%eax
    131e:	cd 40                	int    $0x40
    1320:	c3                   	ret    

00001321 <getpid>:
SYSCALL(getpid)
    1321:	b8 0b 00 00 00       	mov    $0xb,%eax
    1326:	cd 40                	int    $0x40
    1328:	c3                   	ret    

00001329 <sbrk>:
SYSCALL(sbrk)
    1329:	b8 0c 00 00 00       	mov    $0xc,%eax
    132e:	cd 40                	int    $0x40
    1330:	c3                   	ret    

00001331 <sleep>:
SYSCALL(sleep)
    1331:	b8 0d 00 00 00       	mov    $0xd,%eax
    1336:	cd 40                	int    $0x40
    1338:	c3                   	ret    

00001339 <uptime>:
SYSCALL(uptime)
    1339:	b8 0e 00 00 00       	mov    $0xe,%eax
    133e:	cd 40                	int    $0x40
    1340:	c3                   	ret    

00001341 <shm_open>:
SYSCALL(shm_open)
    1341:	b8 16 00 00 00       	mov    $0x16,%eax
    1346:	cd 40                	int    $0x40
    1348:	c3                   	ret    

00001349 <shm_close>:
SYSCALL(shm_close)	
    1349:	b8 17 00 00 00       	mov    $0x17,%eax
    134e:	cd 40                	int    $0x40
    1350:	c3                   	ret    

00001351 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1351:	55                   	push   %ebp
    1352:	89 e5                	mov    %esp,%ebp
    1354:	83 ec 18             	sub    $0x18,%esp
    1357:	8b 45 0c             	mov    0xc(%ebp),%eax
    135a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    135d:	83 ec 04             	sub    $0x4,%esp
    1360:	6a 01                	push   $0x1
    1362:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1365:	50                   	push   %eax
    1366:	ff 75 08             	pushl  0x8(%ebp)
    1369:	e8 53 ff ff ff       	call   12c1 <write>
    136e:	83 c4 10             	add    $0x10,%esp
}
    1371:	90                   	nop
    1372:	c9                   	leave  
    1373:	c3                   	ret    

00001374 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1374:	55                   	push   %ebp
    1375:	89 e5                	mov    %esp,%ebp
    1377:	53                   	push   %ebx
    1378:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    137b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1382:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1386:	74 17                	je     139f <printint+0x2b>
    1388:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    138c:	79 11                	jns    139f <printint+0x2b>
    neg = 1;
    138e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1395:	8b 45 0c             	mov    0xc(%ebp),%eax
    1398:	f7 d8                	neg    %eax
    139a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    139d:	eb 06                	jmp    13a5 <printint+0x31>
  } else {
    x = xx;
    139f:	8b 45 0c             	mov    0xc(%ebp),%eax
    13a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13ac:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13af:	8d 41 01             	lea    0x1(%ecx),%eax
    13b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13bb:	ba 00 00 00 00       	mov    $0x0,%edx
    13c0:	f7 f3                	div    %ebx
    13c2:	89 d0                	mov    %edx,%eax
    13c4:	0f b6 80 ec 1a 00 00 	movzbl 0x1aec(%eax),%eax
    13cb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13d5:	ba 00 00 00 00       	mov    $0x0,%edx
    13da:	f7 f3                	div    %ebx
    13dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13e3:	75 c7                	jne    13ac <printint+0x38>
  if(neg)
    13e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13e9:	74 2d                	je     1418 <printint+0xa4>
    buf[i++] = '-';
    13eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ee:	8d 50 01             	lea    0x1(%eax),%edx
    13f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
    13f4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    13f9:	eb 1d                	jmp    1418 <printint+0xa4>
    putc(fd, buf[i]);
    13fb:	8d 55 dc             	lea    -0x24(%ebp),%edx
    13fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1401:	01 d0                	add    %edx,%eax
    1403:	0f b6 00             	movzbl (%eax),%eax
    1406:	0f be c0             	movsbl %al,%eax
    1409:	83 ec 08             	sub    $0x8,%esp
    140c:	50                   	push   %eax
    140d:	ff 75 08             	pushl  0x8(%ebp)
    1410:	e8 3c ff ff ff       	call   1351 <putc>
    1415:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1418:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    141c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1420:	79 d9                	jns    13fb <printint+0x87>
    putc(fd, buf[i]);
}
    1422:	90                   	nop
    1423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1426:	c9                   	leave  
    1427:	c3                   	ret    

00001428 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1428:	55                   	push   %ebp
    1429:	89 e5                	mov    %esp,%ebp
    142b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    142e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1435:	8d 45 0c             	lea    0xc(%ebp),%eax
    1438:	83 c0 04             	add    $0x4,%eax
    143b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    143e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1445:	e9 59 01 00 00       	jmp    15a3 <printf+0x17b>
    c = fmt[i] & 0xff;
    144a:	8b 55 0c             	mov    0xc(%ebp),%edx
    144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1450:	01 d0                	add    %edx,%eax
    1452:	0f b6 00             	movzbl (%eax),%eax
    1455:	0f be c0             	movsbl %al,%eax
    1458:	25 ff 00 00 00       	and    $0xff,%eax
    145d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1460:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1464:	75 2c                	jne    1492 <printf+0x6a>
      if(c == '%'){
    1466:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    146a:	75 0c                	jne    1478 <printf+0x50>
        state = '%';
    146c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1473:	e9 27 01 00 00       	jmp    159f <printf+0x177>
      } else {
        putc(fd, c);
    1478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    147b:	0f be c0             	movsbl %al,%eax
    147e:	83 ec 08             	sub    $0x8,%esp
    1481:	50                   	push   %eax
    1482:	ff 75 08             	pushl  0x8(%ebp)
    1485:	e8 c7 fe ff ff       	call   1351 <putc>
    148a:	83 c4 10             	add    $0x10,%esp
    148d:	e9 0d 01 00 00       	jmp    159f <printf+0x177>
      }
    } else if(state == '%'){
    1492:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1496:	0f 85 03 01 00 00    	jne    159f <printf+0x177>
      if(c == 'd'){
    149c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14a0:	75 1e                	jne    14c0 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14a5:	8b 00                	mov    (%eax),%eax
    14a7:	6a 01                	push   $0x1
    14a9:	6a 0a                	push   $0xa
    14ab:	50                   	push   %eax
    14ac:	ff 75 08             	pushl  0x8(%ebp)
    14af:	e8 c0 fe ff ff       	call   1374 <printint>
    14b4:	83 c4 10             	add    $0x10,%esp
        ap++;
    14b7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14bb:	e9 d8 00 00 00       	jmp    1598 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14c0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14c4:	74 06                	je     14cc <printf+0xa4>
    14c6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14ca:	75 1e                	jne    14ea <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14cf:	8b 00                	mov    (%eax),%eax
    14d1:	6a 00                	push   $0x0
    14d3:	6a 10                	push   $0x10
    14d5:	50                   	push   %eax
    14d6:	ff 75 08             	pushl  0x8(%ebp)
    14d9:	e8 96 fe ff ff       	call   1374 <printint>
    14de:	83 c4 10             	add    $0x10,%esp
        ap++;
    14e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14e5:	e9 ae 00 00 00       	jmp    1598 <printf+0x170>
      } else if(c == 's'){
    14ea:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    14ee:	75 43                	jne    1533 <printf+0x10b>
        s = (char*)*ap;
    14f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14f3:	8b 00                	mov    (%eax),%eax
    14f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    14f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    14fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1500:	75 25                	jne    1527 <printf+0xff>
          s = "(null)";
    1502:	c7 45 f4 33 18 00 00 	movl   $0x1833,-0xc(%ebp)
        while(*s != 0){
    1509:	eb 1c                	jmp    1527 <printf+0xff>
          putc(fd, *s);
    150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    150e:	0f b6 00             	movzbl (%eax),%eax
    1511:	0f be c0             	movsbl %al,%eax
    1514:	83 ec 08             	sub    $0x8,%esp
    1517:	50                   	push   %eax
    1518:	ff 75 08             	pushl  0x8(%ebp)
    151b:	e8 31 fe ff ff       	call   1351 <putc>
    1520:	83 c4 10             	add    $0x10,%esp
          s++;
    1523:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1527:	8b 45 f4             	mov    -0xc(%ebp),%eax
    152a:	0f b6 00             	movzbl (%eax),%eax
    152d:	84 c0                	test   %al,%al
    152f:	75 da                	jne    150b <printf+0xe3>
    1531:	eb 65                	jmp    1598 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1533:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1537:	75 1d                	jne    1556 <printf+0x12e>
        putc(fd, *ap);
    1539:	8b 45 e8             	mov    -0x18(%ebp),%eax
    153c:	8b 00                	mov    (%eax),%eax
    153e:	0f be c0             	movsbl %al,%eax
    1541:	83 ec 08             	sub    $0x8,%esp
    1544:	50                   	push   %eax
    1545:	ff 75 08             	pushl  0x8(%ebp)
    1548:	e8 04 fe ff ff       	call   1351 <putc>
    154d:	83 c4 10             	add    $0x10,%esp
        ap++;
    1550:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1554:	eb 42                	jmp    1598 <printf+0x170>
      } else if(c == '%'){
    1556:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    155a:	75 17                	jne    1573 <printf+0x14b>
        putc(fd, c);
    155c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    155f:	0f be c0             	movsbl %al,%eax
    1562:	83 ec 08             	sub    $0x8,%esp
    1565:	50                   	push   %eax
    1566:	ff 75 08             	pushl  0x8(%ebp)
    1569:	e8 e3 fd ff ff       	call   1351 <putc>
    156e:	83 c4 10             	add    $0x10,%esp
    1571:	eb 25                	jmp    1598 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1573:	83 ec 08             	sub    $0x8,%esp
    1576:	6a 25                	push   $0x25
    1578:	ff 75 08             	pushl  0x8(%ebp)
    157b:	e8 d1 fd ff ff       	call   1351 <putc>
    1580:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1586:	0f be c0             	movsbl %al,%eax
    1589:	83 ec 08             	sub    $0x8,%esp
    158c:	50                   	push   %eax
    158d:	ff 75 08             	pushl  0x8(%ebp)
    1590:	e8 bc fd ff ff       	call   1351 <putc>
    1595:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    1598:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    159f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15a3:	8b 55 0c             	mov    0xc(%ebp),%edx
    15a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15a9:	01 d0                	add    %edx,%eax
    15ab:	0f b6 00             	movzbl (%eax),%eax
    15ae:	84 c0                	test   %al,%al
    15b0:	0f 85 94 fe ff ff    	jne    144a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15b6:	90                   	nop
    15b7:	c9                   	leave  
    15b8:	c3                   	ret    

000015b9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15b9:	55                   	push   %ebp
    15ba:	89 e5                	mov    %esp,%ebp
    15bc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15bf:	8b 45 08             	mov    0x8(%ebp),%eax
    15c2:	83 e8 08             	sub    $0x8,%eax
    15c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15c8:	a1 08 1b 00 00       	mov    0x1b08,%eax
    15cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15d0:	eb 24                	jmp    15f6 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15d5:	8b 00                	mov    (%eax),%eax
    15d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15da:	77 12                	ja     15ee <free+0x35>
    15dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15df:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15e2:	77 24                	ja     1608 <free+0x4f>
    15e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15e7:	8b 00                	mov    (%eax),%eax
    15e9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15ec:	77 1a                	ja     1608 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15f1:	8b 00                	mov    (%eax),%eax
    15f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15f9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15fc:	76 d4                	jbe    15d2 <free+0x19>
    15fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1601:	8b 00                	mov    (%eax),%eax
    1603:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1606:	76 ca                	jbe    15d2 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1608:	8b 45 f8             	mov    -0x8(%ebp),%eax
    160b:	8b 40 04             	mov    0x4(%eax),%eax
    160e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1615:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1618:	01 c2                	add    %eax,%edx
    161a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161d:	8b 00                	mov    (%eax),%eax
    161f:	39 c2                	cmp    %eax,%edx
    1621:	75 24                	jne    1647 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1623:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1626:	8b 50 04             	mov    0x4(%eax),%edx
    1629:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162c:	8b 00                	mov    (%eax),%eax
    162e:	8b 40 04             	mov    0x4(%eax),%eax
    1631:	01 c2                	add    %eax,%edx
    1633:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1636:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1639:	8b 45 fc             	mov    -0x4(%ebp),%eax
    163c:	8b 00                	mov    (%eax),%eax
    163e:	8b 10                	mov    (%eax),%edx
    1640:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1643:	89 10                	mov    %edx,(%eax)
    1645:	eb 0a                	jmp    1651 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1647:	8b 45 fc             	mov    -0x4(%ebp),%eax
    164a:	8b 10                	mov    (%eax),%edx
    164c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1651:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1654:	8b 40 04             	mov    0x4(%eax),%eax
    1657:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    165e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1661:	01 d0                	add    %edx,%eax
    1663:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1666:	75 20                	jne    1688 <free+0xcf>
    p->s.size += bp->s.size;
    1668:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166b:	8b 50 04             	mov    0x4(%eax),%edx
    166e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1671:	8b 40 04             	mov    0x4(%eax),%eax
    1674:	01 c2                	add    %eax,%edx
    1676:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1679:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    167c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167f:	8b 10                	mov    (%eax),%edx
    1681:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1684:	89 10                	mov    %edx,(%eax)
    1686:	eb 08                	jmp    1690 <free+0xd7>
  } else
    p->s.ptr = bp;
    1688:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168b:	8b 55 f8             	mov    -0x8(%ebp),%edx
    168e:	89 10                	mov    %edx,(%eax)
  freep = p;
    1690:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1693:	a3 08 1b 00 00       	mov    %eax,0x1b08
}
    1698:	90                   	nop
    1699:	c9                   	leave  
    169a:	c3                   	ret    

0000169b <morecore>:

static Header*
morecore(uint nu)
{
    169b:	55                   	push   %ebp
    169c:	89 e5                	mov    %esp,%ebp
    169e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16a1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16a8:	77 07                	ja     16b1 <morecore+0x16>
    nu = 4096;
    16aa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16b1:	8b 45 08             	mov    0x8(%ebp),%eax
    16b4:	c1 e0 03             	shl    $0x3,%eax
    16b7:	83 ec 0c             	sub    $0xc,%esp
    16ba:	50                   	push   %eax
    16bb:	e8 69 fc ff ff       	call   1329 <sbrk>
    16c0:	83 c4 10             	add    $0x10,%esp
    16c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16ca:	75 07                	jne    16d3 <morecore+0x38>
    return 0;
    16cc:	b8 00 00 00 00       	mov    $0x0,%eax
    16d1:	eb 26                	jmp    16f9 <morecore+0x5e>
  hp = (Header*)p;
    16d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16dc:	8b 55 08             	mov    0x8(%ebp),%edx
    16df:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16e5:	83 c0 08             	add    $0x8,%eax
    16e8:	83 ec 0c             	sub    $0xc,%esp
    16eb:	50                   	push   %eax
    16ec:	e8 c8 fe ff ff       	call   15b9 <free>
    16f1:	83 c4 10             	add    $0x10,%esp
  return freep;
    16f4:	a1 08 1b 00 00       	mov    0x1b08,%eax
}
    16f9:	c9                   	leave  
    16fa:	c3                   	ret    

000016fb <malloc>:

void*
malloc(uint nbytes)
{
    16fb:	55                   	push   %ebp
    16fc:	89 e5                	mov    %esp,%ebp
    16fe:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1701:	8b 45 08             	mov    0x8(%ebp),%eax
    1704:	83 c0 07             	add    $0x7,%eax
    1707:	c1 e8 03             	shr    $0x3,%eax
    170a:	83 c0 01             	add    $0x1,%eax
    170d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1710:	a1 08 1b 00 00       	mov    0x1b08,%eax
    1715:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1718:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    171c:	75 23                	jne    1741 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    171e:	c7 45 f0 00 1b 00 00 	movl   $0x1b00,-0x10(%ebp)
    1725:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1728:	a3 08 1b 00 00       	mov    %eax,0x1b08
    172d:	a1 08 1b 00 00       	mov    0x1b08,%eax
    1732:	a3 00 1b 00 00       	mov    %eax,0x1b00
    base.s.size = 0;
    1737:	c7 05 04 1b 00 00 00 	movl   $0x0,0x1b04
    173e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1741:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1744:	8b 00                	mov    (%eax),%eax
    1746:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1749:	8b 45 f4             	mov    -0xc(%ebp),%eax
    174c:	8b 40 04             	mov    0x4(%eax),%eax
    174f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1752:	72 4d                	jb     17a1 <malloc+0xa6>
      if(p->s.size == nunits)
    1754:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1757:	8b 40 04             	mov    0x4(%eax),%eax
    175a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    175d:	75 0c                	jne    176b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    175f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1762:	8b 10                	mov    (%eax),%edx
    1764:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1767:	89 10                	mov    %edx,(%eax)
    1769:	eb 26                	jmp    1791 <malloc+0x96>
      else {
        p->s.size -= nunits;
    176b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    176e:	8b 40 04             	mov    0x4(%eax),%eax
    1771:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1774:	89 c2                	mov    %eax,%edx
    1776:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1779:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177f:	8b 40 04             	mov    0x4(%eax),%eax
    1782:	c1 e0 03             	shl    $0x3,%eax
    1785:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1788:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178b:	8b 55 ec             	mov    -0x14(%ebp),%edx
    178e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1791:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1794:	a3 08 1b 00 00       	mov    %eax,0x1b08
      return (void*)(p + 1);
    1799:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179c:	83 c0 08             	add    $0x8,%eax
    179f:	eb 3b                	jmp    17dc <malloc+0xe1>
    }
    if(p == freep)
    17a1:	a1 08 1b 00 00       	mov    0x1b08,%eax
    17a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17a9:	75 1e                	jne    17c9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17ab:	83 ec 0c             	sub    $0xc,%esp
    17ae:	ff 75 ec             	pushl  -0x14(%ebp)
    17b1:	e8 e5 fe ff ff       	call   169b <morecore>
    17b6:	83 c4 10             	add    $0x10,%esp
    17b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17c0:	75 07                	jne    17c9 <malloc+0xce>
        return 0;
    17c2:	b8 00 00 00 00       	mov    $0x0,%eax
    17c7:	eb 13                	jmp    17dc <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d2:	8b 00                	mov    (%eax),%eax
    17d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17d7:	e9 6d ff ff ff       	jmp    1749 <malloc+0x4e>
}
    17dc:	c9                   	leave  
    17dd:	c3                   	ret    

000017de <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    17de:	55                   	push   %ebp
    17df:	89 e5                	mov    %esp,%ebp
    17e1:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    17e4:	8b 55 08             	mov    0x8(%ebp),%edx
    17e7:	8b 45 0c             	mov    0xc(%ebp),%eax
    17ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
    17ed:	f0 87 02             	lock xchg %eax,(%edx)
    17f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    17f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    17f6:	c9                   	leave  
    17f7:	c3                   	ret    

000017f8 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    17f8:	55                   	push   %ebp
    17f9:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    17fb:	90                   	nop
    17fc:	8b 45 08             	mov    0x8(%ebp),%eax
    17ff:	6a 01                	push   $0x1
    1801:	50                   	push   %eax
    1802:	e8 d7 ff ff ff       	call   17de <xchg>
    1807:	83 c4 08             	add    $0x8,%esp
    180a:	85 c0                	test   %eax,%eax
    180c:	75 ee                	jne    17fc <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    180e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1813:	90                   	nop
    1814:	c9                   	leave  
    1815:	c3                   	ret    

00001816 <urelease>:

void urelease (struct uspinlock *lk) {
    1816:	55                   	push   %ebp
    1817:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1819:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    181e:	8b 45 08             	mov    0x8(%ebp),%eax
    1821:	8b 55 08             	mov    0x8(%ebp),%edx
    1824:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    182a:	90                   	nop
    182b:	5d                   	pop    %ebp
    182c:	c3                   	ret    
