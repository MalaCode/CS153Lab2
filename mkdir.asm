
_mkdir:     file format elf32-i386


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

  if(argc < 2){
    1014:	83 3b 01             	cmpl   $0x1,(%ebx)
    1017:	7f 17                	jg     1030 <main+0x30>
    printf(2, "Usage: mkdir files...\n");
    1019:	83 ec 08             	sub    $0x8,%esp
    101c:	68 73 18 00 00       	push   $0x1873
    1021:	6a 02                	push   $0x2
    1023:	e8 46 04 00 00       	call   146e <printf>
    1028:	83 c4 10             	add    $0x10,%esp
    exit();
    102b:	e8 b7 02 00 00       	call   12e7 <exit>
  }

  for(i = 1; i < argc; i++){
    1030:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    1037:	eb 4b                	jmp    1084 <main+0x84>
    if(mkdir(argv[i]) < 0){
    1039:	8b 45 f4             	mov    -0xc(%ebp),%eax
    103c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1043:	8b 43 04             	mov    0x4(%ebx),%eax
    1046:	01 d0                	add    %edx,%eax
    1048:	8b 00                	mov    (%eax),%eax
    104a:	83 ec 0c             	sub    $0xc,%esp
    104d:	50                   	push   %eax
    104e:	e8 fc 02 00 00       	call   134f <mkdir>
    1053:	83 c4 10             	add    $0x10,%esp
    1056:	85 c0                	test   %eax,%eax
    1058:	79 26                	jns    1080 <main+0x80>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
    105a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    105d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1064:	8b 43 04             	mov    0x4(%ebx),%eax
    1067:	01 d0                	add    %edx,%eax
    1069:	8b 00                	mov    (%eax),%eax
    106b:	83 ec 04             	sub    $0x4,%esp
    106e:	50                   	push   %eax
    106f:	68 8a 18 00 00       	push   $0x188a
    1074:	6a 02                	push   $0x2
    1076:	e8 f3 03 00 00       	call   146e <printf>
    107b:	83 c4 10             	add    $0x10,%esp
      break;
    107e:	eb 0b                	jmp    108b <main+0x8b>
  if(argc < 2){
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
    1080:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1084:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1087:	3b 03                	cmp    (%ebx),%eax
    1089:	7c ae                	jl     1039 <main+0x39>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit();
    108b:	e8 57 02 00 00       	call   12e7 <exit>

00001090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1090:	55                   	push   %ebp
    1091:	89 e5                	mov    %esp,%ebp
    1093:	57                   	push   %edi
    1094:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1095:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1098:	8b 55 10             	mov    0x10(%ebp),%edx
    109b:	8b 45 0c             	mov    0xc(%ebp),%eax
    109e:	89 cb                	mov    %ecx,%ebx
    10a0:	89 df                	mov    %ebx,%edi
    10a2:	89 d1                	mov    %edx,%ecx
    10a4:	fc                   	cld    
    10a5:	f3 aa                	rep stos %al,%es:(%edi)
    10a7:	89 ca                	mov    %ecx,%edx
    10a9:	89 fb                	mov    %edi,%ebx
    10ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
    10ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    10b1:	90                   	nop
    10b2:	5b                   	pop    %ebx
    10b3:	5f                   	pop    %edi
    10b4:	5d                   	pop    %ebp
    10b5:	c3                   	ret    

000010b6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    10b6:	55                   	push   %ebp
    10b7:	89 e5                	mov    %esp,%ebp
    10b9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    10bc:	8b 45 08             	mov    0x8(%ebp),%eax
    10bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    10c2:	90                   	nop
    10c3:	8b 45 08             	mov    0x8(%ebp),%eax
    10c6:	8d 50 01             	lea    0x1(%eax),%edx
    10c9:	89 55 08             	mov    %edx,0x8(%ebp)
    10cc:	8b 55 0c             	mov    0xc(%ebp),%edx
    10cf:	8d 4a 01             	lea    0x1(%edx),%ecx
    10d2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10d5:	0f b6 12             	movzbl (%edx),%edx
    10d8:	88 10                	mov    %dl,(%eax)
    10da:	0f b6 00             	movzbl (%eax),%eax
    10dd:	84 c0                	test   %al,%al
    10df:	75 e2                	jne    10c3 <strcpy+0xd>
    ;
  return os;
    10e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10e4:	c9                   	leave  
    10e5:	c3                   	ret    

000010e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10e6:	55                   	push   %ebp
    10e7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10e9:	eb 08                	jmp    10f3 <strcmp+0xd>
    p++, q++;
    10eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10ef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10f3:	8b 45 08             	mov    0x8(%ebp),%eax
    10f6:	0f b6 00             	movzbl (%eax),%eax
    10f9:	84 c0                	test   %al,%al
    10fb:	74 10                	je     110d <strcmp+0x27>
    10fd:	8b 45 08             	mov    0x8(%ebp),%eax
    1100:	0f b6 10             	movzbl (%eax),%edx
    1103:	8b 45 0c             	mov    0xc(%ebp),%eax
    1106:	0f b6 00             	movzbl (%eax),%eax
    1109:	38 c2                	cmp    %al,%dl
    110b:	74 de                	je     10eb <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    110d:	8b 45 08             	mov    0x8(%ebp),%eax
    1110:	0f b6 00             	movzbl (%eax),%eax
    1113:	0f b6 d0             	movzbl %al,%edx
    1116:	8b 45 0c             	mov    0xc(%ebp),%eax
    1119:	0f b6 00             	movzbl (%eax),%eax
    111c:	0f b6 c0             	movzbl %al,%eax
    111f:	29 c2                	sub    %eax,%edx
    1121:	89 d0                	mov    %edx,%eax
}
    1123:	5d                   	pop    %ebp
    1124:	c3                   	ret    

00001125 <strlen>:

uint
strlen(char *s)
{
    1125:	55                   	push   %ebp
    1126:	89 e5                	mov    %esp,%ebp
    1128:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    112b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1132:	eb 04                	jmp    1138 <strlen+0x13>
    1134:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1138:	8b 55 fc             	mov    -0x4(%ebp),%edx
    113b:	8b 45 08             	mov    0x8(%ebp),%eax
    113e:	01 d0                	add    %edx,%eax
    1140:	0f b6 00             	movzbl (%eax),%eax
    1143:	84 c0                	test   %al,%al
    1145:	75 ed                	jne    1134 <strlen+0xf>
    ;
  return n;
    1147:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    114a:	c9                   	leave  
    114b:	c3                   	ret    

0000114c <memset>:

void*
memset(void *dst, int c, uint n)
{
    114c:	55                   	push   %ebp
    114d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    114f:	8b 45 10             	mov    0x10(%ebp),%eax
    1152:	50                   	push   %eax
    1153:	ff 75 0c             	pushl  0xc(%ebp)
    1156:	ff 75 08             	pushl  0x8(%ebp)
    1159:	e8 32 ff ff ff       	call   1090 <stosb>
    115e:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1161:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1164:	c9                   	leave  
    1165:	c3                   	ret    

00001166 <strchr>:

char*
strchr(const char *s, char c)
{
    1166:	55                   	push   %ebp
    1167:	89 e5                	mov    %esp,%ebp
    1169:	83 ec 04             	sub    $0x4,%esp
    116c:	8b 45 0c             	mov    0xc(%ebp),%eax
    116f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1172:	eb 14                	jmp    1188 <strchr+0x22>
    if(*s == c)
    1174:	8b 45 08             	mov    0x8(%ebp),%eax
    1177:	0f b6 00             	movzbl (%eax),%eax
    117a:	3a 45 fc             	cmp    -0x4(%ebp),%al
    117d:	75 05                	jne    1184 <strchr+0x1e>
      return (char*)s;
    117f:	8b 45 08             	mov    0x8(%ebp),%eax
    1182:	eb 13                	jmp    1197 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1184:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1188:	8b 45 08             	mov    0x8(%ebp),%eax
    118b:	0f b6 00             	movzbl (%eax),%eax
    118e:	84 c0                	test   %al,%al
    1190:	75 e2                	jne    1174 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1192:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1197:	c9                   	leave  
    1198:	c3                   	ret    

00001199 <gets>:

char*
gets(char *buf, int max)
{
    1199:	55                   	push   %ebp
    119a:	89 e5                	mov    %esp,%ebp
    119c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    119f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    11a6:	eb 42                	jmp    11ea <gets+0x51>
    cc = read(0, &c, 1);
    11a8:	83 ec 04             	sub    $0x4,%esp
    11ab:	6a 01                	push   $0x1
    11ad:	8d 45 ef             	lea    -0x11(%ebp),%eax
    11b0:	50                   	push   %eax
    11b1:	6a 00                	push   $0x0
    11b3:	e8 47 01 00 00       	call   12ff <read>
    11b8:	83 c4 10             	add    $0x10,%esp
    11bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    11be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    11c2:	7e 33                	jle    11f7 <gets+0x5e>
      break;
    buf[i++] = c;
    11c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11c7:	8d 50 01             	lea    0x1(%eax),%edx
    11ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11cd:	89 c2                	mov    %eax,%edx
    11cf:	8b 45 08             	mov    0x8(%ebp),%eax
    11d2:	01 c2                	add    %eax,%edx
    11d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11d8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11da:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11de:	3c 0a                	cmp    $0xa,%al
    11e0:	74 16                	je     11f8 <gets+0x5f>
    11e2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11e6:	3c 0d                	cmp    $0xd,%al
    11e8:	74 0e                	je     11f8 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ed:	83 c0 01             	add    $0x1,%eax
    11f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11f3:	7c b3                	jl     11a8 <gets+0xf>
    11f5:	eb 01                	jmp    11f8 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11f7:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11fb:	8b 45 08             	mov    0x8(%ebp),%eax
    11fe:	01 d0                	add    %edx,%eax
    1200:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1203:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1206:	c9                   	leave  
    1207:	c3                   	ret    

00001208 <stat>:

int
stat(char *n, struct stat *st)
{
    1208:	55                   	push   %ebp
    1209:	89 e5                	mov    %esp,%ebp
    120b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    120e:	83 ec 08             	sub    $0x8,%esp
    1211:	6a 00                	push   $0x0
    1213:	ff 75 08             	pushl  0x8(%ebp)
    1216:	e8 0c 01 00 00       	call   1327 <open>
    121b:	83 c4 10             	add    $0x10,%esp
    121e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1221:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1225:	79 07                	jns    122e <stat+0x26>
    return -1;
    1227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    122c:	eb 25                	jmp    1253 <stat+0x4b>
  r = fstat(fd, st);
    122e:	83 ec 08             	sub    $0x8,%esp
    1231:	ff 75 0c             	pushl  0xc(%ebp)
    1234:	ff 75 f4             	pushl  -0xc(%ebp)
    1237:	e8 03 01 00 00       	call   133f <fstat>
    123c:	83 c4 10             	add    $0x10,%esp
    123f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1242:	83 ec 0c             	sub    $0xc,%esp
    1245:	ff 75 f4             	pushl  -0xc(%ebp)
    1248:	e8 c2 00 00 00       	call   130f <close>
    124d:	83 c4 10             	add    $0x10,%esp
  return r;
    1250:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1253:	c9                   	leave  
    1254:	c3                   	ret    

00001255 <atoi>:

int
atoi(const char *s)
{
    1255:	55                   	push   %ebp
    1256:	89 e5                	mov    %esp,%ebp
    1258:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    125b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1262:	eb 25                	jmp    1289 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1264:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1267:	89 d0                	mov    %edx,%eax
    1269:	c1 e0 02             	shl    $0x2,%eax
    126c:	01 d0                	add    %edx,%eax
    126e:	01 c0                	add    %eax,%eax
    1270:	89 c1                	mov    %eax,%ecx
    1272:	8b 45 08             	mov    0x8(%ebp),%eax
    1275:	8d 50 01             	lea    0x1(%eax),%edx
    1278:	89 55 08             	mov    %edx,0x8(%ebp)
    127b:	0f b6 00             	movzbl (%eax),%eax
    127e:	0f be c0             	movsbl %al,%eax
    1281:	01 c8                	add    %ecx,%eax
    1283:	83 e8 30             	sub    $0x30,%eax
    1286:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1289:	8b 45 08             	mov    0x8(%ebp),%eax
    128c:	0f b6 00             	movzbl (%eax),%eax
    128f:	3c 2f                	cmp    $0x2f,%al
    1291:	7e 0a                	jle    129d <atoi+0x48>
    1293:	8b 45 08             	mov    0x8(%ebp),%eax
    1296:	0f b6 00             	movzbl (%eax),%eax
    1299:	3c 39                	cmp    $0x39,%al
    129b:	7e c7                	jle    1264 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    129d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    12a0:	c9                   	leave  
    12a1:	c3                   	ret    

000012a2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    12a2:	55                   	push   %ebp
    12a3:	89 e5                	mov    %esp,%ebp
    12a5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    12a8:	8b 45 08             	mov    0x8(%ebp),%eax
    12ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    12ae:	8b 45 0c             	mov    0xc(%ebp),%eax
    12b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    12b4:	eb 17                	jmp    12cd <memmove+0x2b>
    *dst++ = *src++;
    12b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b9:	8d 50 01             	lea    0x1(%eax),%edx
    12bc:	89 55 fc             	mov    %edx,-0x4(%ebp)
    12bf:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12c2:	8d 4a 01             	lea    0x1(%edx),%ecx
    12c5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    12c8:	0f b6 12             	movzbl (%edx),%edx
    12cb:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12cd:	8b 45 10             	mov    0x10(%ebp),%eax
    12d0:	8d 50 ff             	lea    -0x1(%eax),%edx
    12d3:	89 55 10             	mov    %edx,0x10(%ebp)
    12d6:	85 c0                	test   %eax,%eax
    12d8:	7f dc                	jg     12b6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12da:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12dd:	c9                   	leave  
    12de:	c3                   	ret    

000012df <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12df:	b8 01 00 00 00       	mov    $0x1,%eax
    12e4:	cd 40                	int    $0x40
    12e6:	c3                   	ret    

000012e7 <exit>:
SYSCALL(exit)
    12e7:	b8 02 00 00 00       	mov    $0x2,%eax
    12ec:	cd 40                	int    $0x40
    12ee:	c3                   	ret    

000012ef <wait>:
SYSCALL(wait)
    12ef:	b8 03 00 00 00       	mov    $0x3,%eax
    12f4:	cd 40                	int    $0x40
    12f6:	c3                   	ret    

000012f7 <pipe>:
SYSCALL(pipe)
    12f7:	b8 04 00 00 00       	mov    $0x4,%eax
    12fc:	cd 40                	int    $0x40
    12fe:	c3                   	ret    

000012ff <read>:
SYSCALL(read)
    12ff:	b8 05 00 00 00       	mov    $0x5,%eax
    1304:	cd 40                	int    $0x40
    1306:	c3                   	ret    

00001307 <write>:
SYSCALL(write)
    1307:	b8 10 00 00 00       	mov    $0x10,%eax
    130c:	cd 40                	int    $0x40
    130e:	c3                   	ret    

0000130f <close>:
SYSCALL(close)
    130f:	b8 15 00 00 00       	mov    $0x15,%eax
    1314:	cd 40                	int    $0x40
    1316:	c3                   	ret    

00001317 <kill>:
SYSCALL(kill)
    1317:	b8 06 00 00 00       	mov    $0x6,%eax
    131c:	cd 40                	int    $0x40
    131e:	c3                   	ret    

0000131f <exec>:
SYSCALL(exec)
    131f:	b8 07 00 00 00       	mov    $0x7,%eax
    1324:	cd 40                	int    $0x40
    1326:	c3                   	ret    

00001327 <open>:
SYSCALL(open)
    1327:	b8 0f 00 00 00       	mov    $0xf,%eax
    132c:	cd 40                	int    $0x40
    132e:	c3                   	ret    

0000132f <mknod>:
SYSCALL(mknod)
    132f:	b8 11 00 00 00       	mov    $0x11,%eax
    1334:	cd 40                	int    $0x40
    1336:	c3                   	ret    

00001337 <unlink>:
SYSCALL(unlink)
    1337:	b8 12 00 00 00       	mov    $0x12,%eax
    133c:	cd 40                	int    $0x40
    133e:	c3                   	ret    

0000133f <fstat>:
SYSCALL(fstat)
    133f:	b8 08 00 00 00       	mov    $0x8,%eax
    1344:	cd 40                	int    $0x40
    1346:	c3                   	ret    

00001347 <link>:
SYSCALL(link)
    1347:	b8 13 00 00 00       	mov    $0x13,%eax
    134c:	cd 40                	int    $0x40
    134e:	c3                   	ret    

0000134f <mkdir>:
SYSCALL(mkdir)
    134f:	b8 14 00 00 00       	mov    $0x14,%eax
    1354:	cd 40                	int    $0x40
    1356:	c3                   	ret    

00001357 <chdir>:
SYSCALL(chdir)
    1357:	b8 09 00 00 00       	mov    $0x9,%eax
    135c:	cd 40                	int    $0x40
    135e:	c3                   	ret    

0000135f <dup>:
SYSCALL(dup)
    135f:	b8 0a 00 00 00       	mov    $0xa,%eax
    1364:	cd 40                	int    $0x40
    1366:	c3                   	ret    

00001367 <getpid>:
SYSCALL(getpid)
    1367:	b8 0b 00 00 00       	mov    $0xb,%eax
    136c:	cd 40                	int    $0x40
    136e:	c3                   	ret    

0000136f <sbrk>:
SYSCALL(sbrk)
    136f:	b8 0c 00 00 00       	mov    $0xc,%eax
    1374:	cd 40                	int    $0x40
    1376:	c3                   	ret    

00001377 <sleep>:
SYSCALL(sleep)
    1377:	b8 0d 00 00 00       	mov    $0xd,%eax
    137c:	cd 40                	int    $0x40
    137e:	c3                   	ret    

0000137f <uptime>:
SYSCALL(uptime)
    137f:	b8 0e 00 00 00       	mov    $0xe,%eax
    1384:	cd 40                	int    $0x40
    1386:	c3                   	ret    

00001387 <shm_open>:
SYSCALL(shm_open)
    1387:	b8 16 00 00 00       	mov    $0x16,%eax
    138c:	cd 40                	int    $0x40
    138e:	c3                   	ret    

0000138f <shm_close>:
SYSCALL(shm_close)	
    138f:	b8 17 00 00 00       	mov    $0x17,%eax
    1394:	cd 40                	int    $0x40
    1396:	c3                   	ret    

00001397 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1397:	55                   	push   %ebp
    1398:	89 e5                	mov    %esp,%ebp
    139a:	83 ec 18             	sub    $0x18,%esp
    139d:	8b 45 0c             	mov    0xc(%ebp),%eax
    13a0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    13a3:	83 ec 04             	sub    $0x4,%esp
    13a6:	6a 01                	push   $0x1
    13a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13ab:	50                   	push   %eax
    13ac:	ff 75 08             	pushl  0x8(%ebp)
    13af:	e8 53 ff ff ff       	call   1307 <write>
    13b4:	83 c4 10             	add    $0x10,%esp
}
    13b7:	90                   	nop
    13b8:	c9                   	leave  
    13b9:	c3                   	ret    

000013ba <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13ba:	55                   	push   %ebp
    13bb:	89 e5                	mov    %esp,%ebp
    13bd:	53                   	push   %ebx
    13be:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13c8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13cc:	74 17                	je     13e5 <printint+0x2b>
    13ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13d2:	79 11                	jns    13e5 <printint+0x2b>
    neg = 1;
    13d4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13db:	8b 45 0c             	mov    0xc(%ebp),%eax
    13de:	f7 d8                	neg    %eax
    13e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13e3:	eb 06                	jmp    13eb <printint+0x31>
  } else {
    x = xx;
    13e5:	8b 45 0c             	mov    0xc(%ebp),%eax
    13e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13f2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13f5:	8d 41 01             	lea    0x1(%ecx),%eax
    13f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1401:	ba 00 00 00 00       	mov    $0x0,%edx
    1406:	f7 f3                	div    %ebx
    1408:	89 d0                	mov    %edx,%eax
    140a:	0f b6 80 5c 1b 00 00 	movzbl 0x1b5c(%eax),%eax
    1411:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1415:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1418:	8b 45 ec             	mov    -0x14(%ebp),%eax
    141b:	ba 00 00 00 00       	mov    $0x0,%edx
    1420:	f7 f3                	div    %ebx
    1422:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1425:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1429:	75 c7                	jne    13f2 <printint+0x38>
  if(neg)
    142b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    142f:	74 2d                	je     145e <printint+0xa4>
    buf[i++] = '-';
    1431:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1434:	8d 50 01             	lea    0x1(%eax),%edx
    1437:	89 55 f4             	mov    %edx,-0xc(%ebp)
    143a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    143f:	eb 1d                	jmp    145e <printint+0xa4>
    putc(fd, buf[i]);
    1441:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1444:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1447:	01 d0                	add    %edx,%eax
    1449:	0f b6 00             	movzbl (%eax),%eax
    144c:	0f be c0             	movsbl %al,%eax
    144f:	83 ec 08             	sub    $0x8,%esp
    1452:	50                   	push   %eax
    1453:	ff 75 08             	pushl  0x8(%ebp)
    1456:	e8 3c ff ff ff       	call   1397 <putc>
    145b:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    145e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1462:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1466:	79 d9                	jns    1441 <printint+0x87>
    putc(fd, buf[i]);
}
    1468:	90                   	nop
    1469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    146c:	c9                   	leave  
    146d:	c3                   	ret    

0000146e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    146e:	55                   	push   %ebp
    146f:	89 e5                	mov    %esp,%ebp
    1471:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    147b:	8d 45 0c             	lea    0xc(%ebp),%eax
    147e:	83 c0 04             	add    $0x4,%eax
    1481:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1484:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    148b:	e9 59 01 00 00       	jmp    15e9 <printf+0x17b>
    c = fmt[i] & 0xff;
    1490:	8b 55 0c             	mov    0xc(%ebp),%edx
    1493:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1496:	01 d0                	add    %edx,%eax
    1498:	0f b6 00             	movzbl (%eax),%eax
    149b:	0f be c0             	movsbl %al,%eax
    149e:	25 ff 00 00 00       	and    $0xff,%eax
    14a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14aa:	75 2c                	jne    14d8 <printf+0x6a>
      if(c == '%'){
    14ac:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14b0:	75 0c                	jne    14be <printf+0x50>
        state = '%';
    14b2:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14b9:	e9 27 01 00 00       	jmp    15e5 <printf+0x177>
      } else {
        putc(fd, c);
    14be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14c1:	0f be c0             	movsbl %al,%eax
    14c4:	83 ec 08             	sub    $0x8,%esp
    14c7:	50                   	push   %eax
    14c8:	ff 75 08             	pushl  0x8(%ebp)
    14cb:	e8 c7 fe ff ff       	call   1397 <putc>
    14d0:	83 c4 10             	add    $0x10,%esp
    14d3:	e9 0d 01 00 00       	jmp    15e5 <printf+0x177>
      }
    } else if(state == '%'){
    14d8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14dc:	0f 85 03 01 00 00    	jne    15e5 <printf+0x177>
      if(c == 'd'){
    14e2:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14e6:	75 1e                	jne    1506 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14eb:	8b 00                	mov    (%eax),%eax
    14ed:	6a 01                	push   $0x1
    14ef:	6a 0a                	push   $0xa
    14f1:	50                   	push   %eax
    14f2:	ff 75 08             	pushl  0x8(%ebp)
    14f5:	e8 c0 fe ff ff       	call   13ba <printint>
    14fa:	83 c4 10             	add    $0x10,%esp
        ap++;
    14fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1501:	e9 d8 00 00 00       	jmp    15de <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1506:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    150a:	74 06                	je     1512 <printf+0xa4>
    150c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1510:	75 1e                	jne    1530 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1512:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1515:	8b 00                	mov    (%eax),%eax
    1517:	6a 00                	push   $0x0
    1519:	6a 10                	push   $0x10
    151b:	50                   	push   %eax
    151c:	ff 75 08             	pushl  0x8(%ebp)
    151f:	e8 96 fe ff ff       	call   13ba <printint>
    1524:	83 c4 10             	add    $0x10,%esp
        ap++;
    1527:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    152b:	e9 ae 00 00 00       	jmp    15de <printf+0x170>
      } else if(c == 's'){
    1530:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1534:	75 43                	jne    1579 <printf+0x10b>
        s = (char*)*ap;
    1536:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1539:	8b 00                	mov    (%eax),%eax
    153b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    153e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1542:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1546:	75 25                	jne    156d <printf+0xff>
          s = "(null)";
    1548:	c7 45 f4 a6 18 00 00 	movl   $0x18a6,-0xc(%ebp)
        while(*s != 0){
    154f:	eb 1c                	jmp    156d <printf+0xff>
          putc(fd, *s);
    1551:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1554:	0f b6 00             	movzbl (%eax),%eax
    1557:	0f be c0             	movsbl %al,%eax
    155a:	83 ec 08             	sub    $0x8,%esp
    155d:	50                   	push   %eax
    155e:	ff 75 08             	pushl  0x8(%ebp)
    1561:	e8 31 fe ff ff       	call   1397 <putc>
    1566:	83 c4 10             	add    $0x10,%esp
          s++;
    1569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    156d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1570:	0f b6 00             	movzbl (%eax),%eax
    1573:	84 c0                	test   %al,%al
    1575:	75 da                	jne    1551 <printf+0xe3>
    1577:	eb 65                	jmp    15de <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1579:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    157d:	75 1d                	jne    159c <printf+0x12e>
        putc(fd, *ap);
    157f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1582:	8b 00                	mov    (%eax),%eax
    1584:	0f be c0             	movsbl %al,%eax
    1587:	83 ec 08             	sub    $0x8,%esp
    158a:	50                   	push   %eax
    158b:	ff 75 08             	pushl  0x8(%ebp)
    158e:	e8 04 fe ff ff       	call   1397 <putc>
    1593:	83 c4 10             	add    $0x10,%esp
        ap++;
    1596:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    159a:	eb 42                	jmp    15de <printf+0x170>
      } else if(c == '%'){
    159c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15a0:	75 17                	jne    15b9 <printf+0x14b>
        putc(fd, c);
    15a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15a5:	0f be c0             	movsbl %al,%eax
    15a8:	83 ec 08             	sub    $0x8,%esp
    15ab:	50                   	push   %eax
    15ac:	ff 75 08             	pushl  0x8(%ebp)
    15af:	e8 e3 fd ff ff       	call   1397 <putc>
    15b4:	83 c4 10             	add    $0x10,%esp
    15b7:	eb 25                	jmp    15de <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    15b9:	83 ec 08             	sub    $0x8,%esp
    15bc:	6a 25                	push   $0x25
    15be:	ff 75 08             	pushl  0x8(%ebp)
    15c1:	e8 d1 fd ff ff       	call   1397 <putc>
    15c6:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    15c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15cc:	0f be c0             	movsbl %al,%eax
    15cf:	83 ec 08             	sub    $0x8,%esp
    15d2:	50                   	push   %eax
    15d3:	ff 75 08             	pushl  0x8(%ebp)
    15d6:	e8 bc fd ff ff       	call   1397 <putc>
    15db:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15e5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15e9:	8b 55 0c             	mov    0xc(%ebp),%edx
    15ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15ef:	01 d0                	add    %edx,%eax
    15f1:	0f b6 00             	movzbl (%eax),%eax
    15f4:	84 c0                	test   %al,%al
    15f6:	0f 85 94 fe ff ff    	jne    1490 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15fc:	90                   	nop
    15fd:	c9                   	leave  
    15fe:	c3                   	ret    

000015ff <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15ff:	55                   	push   %ebp
    1600:	89 e5                	mov    %esp,%ebp
    1602:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1605:	8b 45 08             	mov    0x8(%ebp),%eax
    1608:	83 e8 08             	sub    $0x8,%eax
    160b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    160e:	a1 78 1b 00 00       	mov    0x1b78,%eax
    1613:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1616:	eb 24                	jmp    163c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1618:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161b:	8b 00                	mov    (%eax),%eax
    161d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1620:	77 12                	ja     1634 <free+0x35>
    1622:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1625:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1628:	77 24                	ja     164e <free+0x4f>
    162a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162d:	8b 00                	mov    (%eax),%eax
    162f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1632:	77 1a                	ja     164e <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1634:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1637:	8b 00                	mov    (%eax),%eax
    1639:	89 45 fc             	mov    %eax,-0x4(%ebp)
    163c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    163f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1642:	76 d4                	jbe    1618 <free+0x19>
    1644:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1647:	8b 00                	mov    (%eax),%eax
    1649:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    164c:	76 ca                	jbe    1618 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    164e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1651:	8b 40 04             	mov    0x4(%eax),%eax
    1654:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    165b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    165e:	01 c2                	add    %eax,%edx
    1660:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1663:	8b 00                	mov    (%eax),%eax
    1665:	39 c2                	cmp    %eax,%edx
    1667:	75 24                	jne    168d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1669:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166c:	8b 50 04             	mov    0x4(%eax),%edx
    166f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1672:	8b 00                	mov    (%eax),%eax
    1674:	8b 40 04             	mov    0x4(%eax),%eax
    1677:	01 c2                	add    %eax,%edx
    1679:	8b 45 f8             	mov    -0x8(%ebp),%eax
    167c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    167f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1682:	8b 00                	mov    (%eax),%eax
    1684:	8b 10                	mov    (%eax),%edx
    1686:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1689:	89 10                	mov    %edx,(%eax)
    168b:	eb 0a                	jmp    1697 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    168d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1690:	8b 10                	mov    (%eax),%edx
    1692:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1695:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1697:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169a:	8b 40 04             	mov    0x4(%eax),%eax
    169d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a7:	01 d0                	add    %edx,%eax
    16a9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16ac:	75 20                	jne    16ce <free+0xcf>
    p->s.size += bp->s.size;
    16ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b1:	8b 50 04             	mov    0x4(%eax),%edx
    16b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b7:	8b 40 04             	mov    0x4(%eax),%eax
    16ba:	01 c2                	add    %eax,%edx
    16bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16bf:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    16c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c5:	8b 10                	mov    (%eax),%edx
    16c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ca:	89 10                	mov    %edx,(%eax)
    16cc:	eb 08                	jmp    16d6 <free+0xd7>
  } else
    p->s.ptr = bp;
    16ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d1:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16d4:	89 10                	mov    %edx,(%eax)
  freep = p;
    16d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d9:	a3 78 1b 00 00       	mov    %eax,0x1b78
}
    16de:	90                   	nop
    16df:	c9                   	leave  
    16e0:	c3                   	ret    

000016e1 <morecore>:

static Header*
morecore(uint nu)
{
    16e1:	55                   	push   %ebp
    16e2:	89 e5                	mov    %esp,%ebp
    16e4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16ee:	77 07                	ja     16f7 <morecore+0x16>
    nu = 4096;
    16f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16f7:	8b 45 08             	mov    0x8(%ebp),%eax
    16fa:	c1 e0 03             	shl    $0x3,%eax
    16fd:	83 ec 0c             	sub    $0xc,%esp
    1700:	50                   	push   %eax
    1701:	e8 69 fc ff ff       	call   136f <sbrk>
    1706:	83 c4 10             	add    $0x10,%esp
    1709:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    170c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1710:	75 07                	jne    1719 <morecore+0x38>
    return 0;
    1712:	b8 00 00 00 00       	mov    $0x0,%eax
    1717:	eb 26                	jmp    173f <morecore+0x5e>
  hp = (Header*)p;
    1719:	8b 45 f4             	mov    -0xc(%ebp),%eax
    171c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1722:	8b 55 08             	mov    0x8(%ebp),%edx
    1725:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1728:	8b 45 f0             	mov    -0x10(%ebp),%eax
    172b:	83 c0 08             	add    $0x8,%eax
    172e:	83 ec 0c             	sub    $0xc,%esp
    1731:	50                   	push   %eax
    1732:	e8 c8 fe ff ff       	call   15ff <free>
    1737:	83 c4 10             	add    $0x10,%esp
  return freep;
    173a:	a1 78 1b 00 00       	mov    0x1b78,%eax
}
    173f:	c9                   	leave  
    1740:	c3                   	ret    

00001741 <malloc>:

void*
malloc(uint nbytes)
{
    1741:	55                   	push   %ebp
    1742:	89 e5                	mov    %esp,%ebp
    1744:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1747:	8b 45 08             	mov    0x8(%ebp),%eax
    174a:	83 c0 07             	add    $0x7,%eax
    174d:	c1 e8 03             	shr    $0x3,%eax
    1750:	83 c0 01             	add    $0x1,%eax
    1753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1756:	a1 78 1b 00 00       	mov    0x1b78,%eax
    175b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    175e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1762:	75 23                	jne    1787 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1764:	c7 45 f0 70 1b 00 00 	movl   $0x1b70,-0x10(%ebp)
    176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    176e:	a3 78 1b 00 00       	mov    %eax,0x1b78
    1773:	a1 78 1b 00 00       	mov    0x1b78,%eax
    1778:	a3 70 1b 00 00       	mov    %eax,0x1b70
    base.s.size = 0;
    177d:	c7 05 74 1b 00 00 00 	movl   $0x0,0x1b74
    1784:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1787:	8b 45 f0             	mov    -0x10(%ebp),%eax
    178a:	8b 00                	mov    (%eax),%eax
    178c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1792:	8b 40 04             	mov    0x4(%eax),%eax
    1795:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1798:	72 4d                	jb     17e7 <malloc+0xa6>
      if(p->s.size == nunits)
    179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179d:	8b 40 04             	mov    0x4(%eax),%eax
    17a0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17a3:	75 0c                	jne    17b1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    17a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a8:	8b 10                	mov    (%eax),%edx
    17aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ad:	89 10                	mov    %edx,(%eax)
    17af:	eb 26                	jmp    17d7 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b4:	8b 40 04             	mov    0x4(%eax),%eax
    17b7:	2b 45 ec             	sub    -0x14(%ebp),%eax
    17ba:	89 c2                	mov    %eax,%edx
    17bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    17c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17c5:	8b 40 04             	mov    0x4(%eax),%eax
    17c8:	c1 e0 03             	shl    $0x3,%eax
    17cb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17d4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17da:	a3 78 1b 00 00       	mov    %eax,0x1b78
      return (void*)(p + 1);
    17df:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e2:	83 c0 08             	add    $0x8,%eax
    17e5:	eb 3b                	jmp    1822 <malloc+0xe1>
    }
    if(p == freep)
    17e7:	a1 78 1b 00 00       	mov    0x1b78,%eax
    17ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17ef:	75 1e                	jne    180f <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17f1:	83 ec 0c             	sub    $0xc,%esp
    17f4:	ff 75 ec             	pushl  -0x14(%ebp)
    17f7:	e8 e5 fe ff ff       	call   16e1 <morecore>
    17fc:	83 c4 10             	add    $0x10,%esp
    17ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1802:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1806:	75 07                	jne    180f <malloc+0xce>
        return 0;
    1808:	b8 00 00 00 00       	mov    $0x0,%eax
    180d:	eb 13                	jmp    1822 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    180f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1812:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1815:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1818:	8b 00                	mov    (%eax),%eax
    181a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    181d:	e9 6d ff ff ff       	jmp    178f <malloc+0x4e>
}
    1822:	c9                   	leave  
    1823:	c3                   	ret    

00001824 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    1824:	55                   	push   %ebp
    1825:	89 e5                	mov    %esp,%ebp
    1827:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    182a:	8b 55 08             	mov    0x8(%ebp),%edx
    182d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1830:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1833:	f0 87 02             	lock xchg %eax,(%edx)
    1836:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    1839:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    183c:	c9                   	leave  
    183d:	c3                   	ret    

0000183e <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    183e:	55                   	push   %ebp
    183f:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1841:	90                   	nop
    1842:	8b 45 08             	mov    0x8(%ebp),%eax
    1845:	6a 01                	push   $0x1
    1847:	50                   	push   %eax
    1848:	e8 d7 ff ff ff       	call   1824 <xchg>
    184d:	83 c4 08             	add    $0x8,%esp
    1850:	85 c0                	test   %eax,%eax
    1852:	75 ee                	jne    1842 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1854:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1859:	90                   	nop
    185a:	c9                   	leave  
    185b:	c3                   	ret    

0000185c <urelease>:

void urelease (struct uspinlock *lk) {
    185c:	55                   	push   %ebp
    185d:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    185f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1864:	8b 45 08             	mov    0x8(%ebp),%eax
    1867:	8b 55 08             	mov    0x8(%ebp),%edx
    186a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1870:	90                   	nop
    1871:	5d                   	pop    %ebp
    1872:	c3                   	ret    
