
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
    1035:	e8 74 02 00 00       	call   12ae <fork>
    103a:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if(pid==0){
    103d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1041:	75 12                	jne    1055 <main+0x38>
   //int x=1;
  // printf(1, "address %x\n", &x);
   test(1);
    1043:	83 ec 0c             	sub    $0xc,%esp
    1046:	6a 01                	push   $0x1
    1048:	e8 b3 ff ff ff       	call   1000 <test>
    104d:	83 c4 10             	add    $0x10,%esp
   exit();
    1050:	e8 61 02 00 00       	call   12b6 <exit>
   }
   wait();
    1055:	e8 64 02 00 00       	call   12be <wait>
   exit();
    105a:	e8 57 02 00 00       	call   12b6 <exit>

0000105f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    105f:	55                   	push   %ebp
    1060:	89 e5                	mov    %esp,%ebp
    1062:	57                   	push   %edi
    1063:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1064:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1067:	8b 55 10             	mov    0x10(%ebp),%edx
    106a:	8b 45 0c             	mov    0xc(%ebp),%eax
    106d:	89 cb                	mov    %ecx,%ebx
    106f:	89 df                	mov    %ebx,%edi
    1071:	89 d1                	mov    %edx,%ecx
    1073:	fc                   	cld    
    1074:	f3 aa                	rep stos %al,%es:(%edi)
    1076:	89 ca                	mov    %ecx,%edx
    1078:	89 fb                	mov    %edi,%ebx
    107a:	89 5d 08             	mov    %ebx,0x8(%ebp)
    107d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1080:	90                   	nop
    1081:	5b                   	pop    %ebx
    1082:	5f                   	pop    %edi
    1083:	5d                   	pop    %ebp
    1084:	c3                   	ret    

00001085 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1085:	55                   	push   %ebp
    1086:	89 e5                	mov    %esp,%ebp
    1088:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    108b:	8b 45 08             	mov    0x8(%ebp),%eax
    108e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1091:	90                   	nop
    1092:	8b 45 08             	mov    0x8(%ebp),%eax
    1095:	8d 50 01             	lea    0x1(%eax),%edx
    1098:	89 55 08             	mov    %edx,0x8(%ebp)
    109b:	8b 55 0c             	mov    0xc(%ebp),%edx
    109e:	8d 4a 01             	lea    0x1(%edx),%ecx
    10a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10a4:	0f b6 12             	movzbl (%edx),%edx
    10a7:	88 10                	mov    %dl,(%eax)
    10a9:	0f b6 00             	movzbl (%eax),%eax
    10ac:	84 c0                	test   %al,%al
    10ae:	75 e2                	jne    1092 <strcpy+0xd>
    ;
  return os;
    10b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10b3:	c9                   	leave  
    10b4:	c3                   	ret    

000010b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10b5:	55                   	push   %ebp
    10b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10b8:	eb 08                	jmp    10c2 <strcmp+0xd>
    p++, q++;
    10ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10c2:	8b 45 08             	mov    0x8(%ebp),%eax
    10c5:	0f b6 00             	movzbl (%eax),%eax
    10c8:	84 c0                	test   %al,%al
    10ca:	74 10                	je     10dc <strcmp+0x27>
    10cc:	8b 45 08             	mov    0x8(%ebp),%eax
    10cf:	0f b6 10             	movzbl (%eax),%edx
    10d2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10d5:	0f b6 00             	movzbl (%eax),%eax
    10d8:	38 c2                	cmp    %al,%dl
    10da:	74 de                	je     10ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10dc:	8b 45 08             	mov    0x8(%ebp),%eax
    10df:	0f b6 00             	movzbl (%eax),%eax
    10e2:	0f b6 d0             	movzbl %al,%edx
    10e5:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e8:	0f b6 00             	movzbl (%eax),%eax
    10eb:	0f b6 c0             	movzbl %al,%eax
    10ee:	29 c2                	sub    %eax,%edx
    10f0:	89 d0                	mov    %edx,%eax
}
    10f2:	5d                   	pop    %ebp
    10f3:	c3                   	ret    

000010f4 <strlen>:

uint
strlen(char *s)
{
    10f4:	55                   	push   %ebp
    10f5:	89 e5                	mov    %esp,%ebp
    10f7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1101:	eb 04                	jmp    1107 <strlen+0x13>
    1103:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1107:	8b 55 fc             	mov    -0x4(%ebp),%edx
    110a:	8b 45 08             	mov    0x8(%ebp),%eax
    110d:	01 d0                	add    %edx,%eax
    110f:	0f b6 00             	movzbl (%eax),%eax
    1112:	84 c0                	test   %al,%al
    1114:	75 ed                	jne    1103 <strlen+0xf>
    ;
  return n;
    1116:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1119:	c9                   	leave  
    111a:	c3                   	ret    

0000111b <memset>:

void*
memset(void *dst, int c, uint n)
{
    111b:	55                   	push   %ebp
    111c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    111e:	8b 45 10             	mov    0x10(%ebp),%eax
    1121:	50                   	push   %eax
    1122:	ff 75 0c             	pushl  0xc(%ebp)
    1125:	ff 75 08             	pushl  0x8(%ebp)
    1128:	e8 32 ff ff ff       	call   105f <stosb>
    112d:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1130:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1133:	c9                   	leave  
    1134:	c3                   	ret    

00001135 <strchr>:

char*
strchr(const char *s, char c)
{
    1135:	55                   	push   %ebp
    1136:	89 e5                	mov    %esp,%ebp
    1138:	83 ec 04             	sub    $0x4,%esp
    113b:	8b 45 0c             	mov    0xc(%ebp),%eax
    113e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1141:	eb 14                	jmp    1157 <strchr+0x22>
    if(*s == c)
    1143:	8b 45 08             	mov    0x8(%ebp),%eax
    1146:	0f b6 00             	movzbl (%eax),%eax
    1149:	3a 45 fc             	cmp    -0x4(%ebp),%al
    114c:	75 05                	jne    1153 <strchr+0x1e>
      return (char*)s;
    114e:	8b 45 08             	mov    0x8(%ebp),%eax
    1151:	eb 13                	jmp    1166 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1153:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1157:	8b 45 08             	mov    0x8(%ebp),%eax
    115a:	0f b6 00             	movzbl (%eax),%eax
    115d:	84 c0                	test   %al,%al
    115f:	75 e2                	jne    1143 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1161:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1166:	c9                   	leave  
    1167:	c3                   	ret    

00001168 <gets>:

char*
gets(char *buf, int max)
{
    1168:	55                   	push   %ebp
    1169:	89 e5                	mov    %esp,%ebp
    116b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    116e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1175:	eb 42                	jmp    11b9 <gets+0x51>
    cc = read(0, &c, 1);
    1177:	83 ec 04             	sub    $0x4,%esp
    117a:	6a 01                	push   $0x1
    117c:	8d 45 ef             	lea    -0x11(%ebp),%eax
    117f:	50                   	push   %eax
    1180:	6a 00                	push   $0x0
    1182:	e8 47 01 00 00       	call   12ce <read>
    1187:	83 c4 10             	add    $0x10,%esp
    118a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    118d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1191:	7e 33                	jle    11c6 <gets+0x5e>
      break;
    buf[i++] = c;
    1193:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1196:	8d 50 01             	lea    0x1(%eax),%edx
    1199:	89 55 f4             	mov    %edx,-0xc(%ebp)
    119c:	89 c2                	mov    %eax,%edx
    119e:	8b 45 08             	mov    0x8(%ebp),%eax
    11a1:	01 c2                	add    %eax,%edx
    11a3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11a7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ad:	3c 0a                	cmp    $0xa,%al
    11af:	74 16                	je     11c7 <gets+0x5f>
    11b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11b5:	3c 0d                	cmp    $0xd,%al
    11b7:	74 0e                	je     11c7 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11bc:	83 c0 01             	add    $0x1,%eax
    11bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11c2:	7c b3                	jl     1177 <gets+0xf>
    11c4:	eb 01                	jmp    11c7 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11c6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11ca:	8b 45 08             	mov    0x8(%ebp),%eax
    11cd:	01 d0                	add    %edx,%eax
    11cf:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11d5:	c9                   	leave  
    11d6:	c3                   	ret    

000011d7 <stat>:

int
stat(char *n, struct stat *st)
{
    11d7:	55                   	push   %ebp
    11d8:	89 e5                	mov    %esp,%ebp
    11da:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11dd:	83 ec 08             	sub    $0x8,%esp
    11e0:	6a 00                	push   $0x0
    11e2:	ff 75 08             	pushl  0x8(%ebp)
    11e5:	e8 0c 01 00 00       	call   12f6 <open>
    11ea:	83 c4 10             	add    $0x10,%esp
    11ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11f4:	79 07                	jns    11fd <stat+0x26>
    return -1;
    11f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11fb:	eb 25                	jmp    1222 <stat+0x4b>
  r = fstat(fd, st);
    11fd:	83 ec 08             	sub    $0x8,%esp
    1200:	ff 75 0c             	pushl  0xc(%ebp)
    1203:	ff 75 f4             	pushl  -0xc(%ebp)
    1206:	e8 03 01 00 00       	call   130e <fstat>
    120b:	83 c4 10             	add    $0x10,%esp
    120e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1211:	83 ec 0c             	sub    $0xc,%esp
    1214:	ff 75 f4             	pushl  -0xc(%ebp)
    1217:	e8 c2 00 00 00       	call   12de <close>
    121c:	83 c4 10             	add    $0x10,%esp
  return r;
    121f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1222:	c9                   	leave  
    1223:	c3                   	ret    

00001224 <atoi>:

int
atoi(const char *s)
{
    1224:	55                   	push   %ebp
    1225:	89 e5                	mov    %esp,%ebp
    1227:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    122a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1231:	eb 25                	jmp    1258 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1233:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1236:	89 d0                	mov    %edx,%eax
    1238:	c1 e0 02             	shl    $0x2,%eax
    123b:	01 d0                	add    %edx,%eax
    123d:	01 c0                	add    %eax,%eax
    123f:	89 c1                	mov    %eax,%ecx
    1241:	8b 45 08             	mov    0x8(%ebp),%eax
    1244:	8d 50 01             	lea    0x1(%eax),%edx
    1247:	89 55 08             	mov    %edx,0x8(%ebp)
    124a:	0f b6 00             	movzbl (%eax),%eax
    124d:	0f be c0             	movsbl %al,%eax
    1250:	01 c8                	add    %ecx,%eax
    1252:	83 e8 30             	sub    $0x30,%eax
    1255:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1258:	8b 45 08             	mov    0x8(%ebp),%eax
    125b:	0f b6 00             	movzbl (%eax),%eax
    125e:	3c 2f                	cmp    $0x2f,%al
    1260:	7e 0a                	jle    126c <atoi+0x48>
    1262:	8b 45 08             	mov    0x8(%ebp),%eax
    1265:	0f b6 00             	movzbl (%eax),%eax
    1268:	3c 39                	cmp    $0x39,%al
    126a:	7e c7                	jle    1233 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    126c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    126f:	c9                   	leave  
    1270:	c3                   	ret    

00001271 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1271:	55                   	push   %ebp
    1272:	89 e5                	mov    %esp,%ebp
    1274:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1277:	8b 45 08             	mov    0x8(%ebp),%eax
    127a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    127d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1280:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1283:	eb 17                	jmp    129c <memmove+0x2b>
    *dst++ = *src++;
    1285:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1288:	8d 50 01             	lea    0x1(%eax),%edx
    128b:	89 55 fc             	mov    %edx,-0x4(%ebp)
    128e:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1291:	8d 4a 01             	lea    0x1(%edx),%ecx
    1294:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1297:	0f b6 12             	movzbl (%edx),%edx
    129a:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    129c:	8b 45 10             	mov    0x10(%ebp),%eax
    129f:	8d 50 ff             	lea    -0x1(%eax),%edx
    12a2:	89 55 10             	mov    %edx,0x10(%ebp)
    12a5:	85 c0                	test   %eax,%eax
    12a7:	7f dc                	jg     1285 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12ac:	c9                   	leave  
    12ad:	c3                   	ret    

000012ae <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12ae:	b8 01 00 00 00       	mov    $0x1,%eax
    12b3:	cd 40                	int    $0x40
    12b5:	c3                   	ret    

000012b6 <exit>:
SYSCALL(exit)
    12b6:	b8 02 00 00 00       	mov    $0x2,%eax
    12bb:	cd 40                	int    $0x40
    12bd:	c3                   	ret    

000012be <wait>:
SYSCALL(wait)
    12be:	b8 03 00 00 00       	mov    $0x3,%eax
    12c3:	cd 40                	int    $0x40
    12c5:	c3                   	ret    

000012c6 <pipe>:
SYSCALL(pipe)
    12c6:	b8 04 00 00 00       	mov    $0x4,%eax
    12cb:	cd 40                	int    $0x40
    12cd:	c3                   	ret    

000012ce <read>:
SYSCALL(read)
    12ce:	b8 05 00 00 00       	mov    $0x5,%eax
    12d3:	cd 40                	int    $0x40
    12d5:	c3                   	ret    

000012d6 <write>:
SYSCALL(write)
    12d6:	b8 10 00 00 00       	mov    $0x10,%eax
    12db:	cd 40                	int    $0x40
    12dd:	c3                   	ret    

000012de <close>:
SYSCALL(close)
    12de:	b8 15 00 00 00       	mov    $0x15,%eax
    12e3:	cd 40                	int    $0x40
    12e5:	c3                   	ret    

000012e6 <kill>:
SYSCALL(kill)
    12e6:	b8 06 00 00 00       	mov    $0x6,%eax
    12eb:	cd 40                	int    $0x40
    12ed:	c3                   	ret    

000012ee <exec>:
SYSCALL(exec)
    12ee:	b8 07 00 00 00       	mov    $0x7,%eax
    12f3:	cd 40                	int    $0x40
    12f5:	c3                   	ret    

000012f6 <open>:
SYSCALL(open)
    12f6:	b8 0f 00 00 00       	mov    $0xf,%eax
    12fb:	cd 40                	int    $0x40
    12fd:	c3                   	ret    

000012fe <mknod>:
SYSCALL(mknod)
    12fe:	b8 11 00 00 00       	mov    $0x11,%eax
    1303:	cd 40                	int    $0x40
    1305:	c3                   	ret    

00001306 <unlink>:
SYSCALL(unlink)
    1306:	b8 12 00 00 00       	mov    $0x12,%eax
    130b:	cd 40                	int    $0x40
    130d:	c3                   	ret    

0000130e <fstat>:
SYSCALL(fstat)
    130e:	b8 08 00 00 00       	mov    $0x8,%eax
    1313:	cd 40                	int    $0x40
    1315:	c3                   	ret    

00001316 <link>:
SYSCALL(link)
    1316:	b8 13 00 00 00       	mov    $0x13,%eax
    131b:	cd 40                	int    $0x40
    131d:	c3                   	ret    

0000131e <mkdir>:
SYSCALL(mkdir)
    131e:	b8 14 00 00 00       	mov    $0x14,%eax
    1323:	cd 40                	int    $0x40
    1325:	c3                   	ret    

00001326 <chdir>:
SYSCALL(chdir)
    1326:	b8 09 00 00 00       	mov    $0x9,%eax
    132b:	cd 40                	int    $0x40
    132d:	c3                   	ret    

0000132e <dup>:
SYSCALL(dup)
    132e:	b8 0a 00 00 00       	mov    $0xa,%eax
    1333:	cd 40                	int    $0x40
    1335:	c3                   	ret    

00001336 <getpid>:
SYSCALL(getpid)
    1336:	b8 0b 00 00 00       	mov    $0xb,%eax
    133b:	cd 40                	int    $0x40
    133d:	c3                   	ret    

0000133e <sbrk>:
SYSCALL(sbrk)
    133e:	b8 0c 00 00 00       	mov    $0xc,%eax
    1343:	cd 40                	int    $0x40
    1345:	c3                   	ret    

00001346 <sleep>:
SYSCALL(sleep)
    1346:	b8 0d 00 00 00       	mov    $0xd,%eax
    134b:	cd 40                	int    $0x40
    134d:	c3                   	ret    

0000134e <uptime>:
SYSCALL(uptime)
    134e:	b8 0e 00 00 00       	mov    $0xe,%eax
    1353:	cd 40                	int    $0x40
    1355:	c3                   	ret    

00001356 <shm_open>:
SYSCALL(shm_open)
    1356:	b8 16 00 00 00       	mov    $0x16,%eax
    135b:	cd 40                	int    $0x40
    135d:	c3                   	ret    

0000135e <shm_close>:
SYSCALL(shm_close)	
    135e:	b8 17 00 00 00       	mov    $0x17,%eax
    1363:	cd 40                	int    $0x40
    1365:	c3                   	ret    

00001366 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1366:	55                   	push   %ebp
    1367:	89 e5                	mov    %esp,%ebp
    1369:	83 ec 18             	sub    $0x18,%esp
    136c:	8b 45 0c             	mov    0xc(%ebp),%eax
    136f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1372:	83 ec 04             	sub    $0x4,%esp
    1375:	6a 01                	push   $0x1
    1377:	8d 45 f4             	lea    -0xc(%ebp),%eax
    137a:	50                   	push   %eax
    137b:	ff 75 08             	pushl  0x8(%ebp)
    137e:	e8 53 ff ff ff       	call   12d6 <write>
    1383:	83 c4 10             	add    $0x10,%esp
}
    1386:	90                   	nop
    1387:	c9                   	leave  
    1388:	c3                   	ret    

00001389 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1389:	55                   	push   %ebp
    138a:	89 e5                	mov    %esp,%ebp
    138c:	53                   	push   %ebx
    138d:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1390:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1397:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    139b:	74 17                	je     13b4 <printint+0x2b>
    139d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13a1:	79 11                	jns    13b4 <printint+0x2b>
    neg = 1;
    13a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13aa:	8b 45 0c             	mov    0xc(%ebp),%eax
    13ad:	f7 d8                	neg    %eax
    13af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13b2:	eb 06                	jmp    13ba <printint+0x31>
  } else {
    x = xx;
    13b4:	8b 45 0c             	mov    0xc(%ebp),%eax
    13b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13c1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13c4:	8d 41 01             	lea    0x1(%ecx),%eax
    13c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13d0:	ba 00 00 00 00       	mov    $0x0,%edx
    13d5:	f7 f3                	div    %ebx
    13d7:	89 d0                	mov    %edx,%eax
    13d9:	0f b6 80 14 1b 00 00 	movzbl 0x1b14(%eax),%eax
    13e0:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13ea:	ba 00 00 00 00       	mov    $0x0,%edx
    13ef:	f7 f3                	div    %ebx
    13f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13f8:	75 c7                	jne    13c1 <printint+0x38>
  if(neg)
    13fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13fe:	74 2d                	je     142d <printint+0xa4>
    buf[i++] = '-';
    1400:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1403:	8d 50 01             	lea    0x1(%eax),%edx
    1406:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1409:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    140e:	eb 1d                	jmp    142d <printint+0xa4>
    putc(fd, buf[i]);
    1410:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1413:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1416:	01 d0                	add    %edx,%eax
    1418:	0f b6 00             	movzbl (%eax),%eax
    141b:	0f be c0             	movsbl %al,%eax
    141e:	83 ec 08             	sub    $0x8,%esp
    1421:	50                   	push   %eax
    1422:	ff 75 08             	pushl  0x8(%ebp)
    1425:	e8 3c ff ff ff       	call   1366 <putc>
    142a:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    142d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1431:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1435:	79 d9                	jns    1410 <printint+0x87>
    putc(fd, buf[i]);
}
    1437:	90                   	nop
    1438:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    143b:	c9                   	leave  
    143c:	c3                   	ret    

0000143d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    143d:	55                   	push   %ebp
    143e:	89 e5                	mov    %esp,%ebp
    1440:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1443:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    144a:	8d 45 0c             	lea    0xc(%ebp),%eax
    144d:	83 c0 04             	add    $0x4,%eax
    1450:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1453:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    145a:	e9 59 01 00 00       	jmp    15b8 <printf+0x17b>
    c = fmt[i] & 0xff;
    145f:	8b 55 0c             	mov    0xc(%ebp),%edx
    1462:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1465:	01 d0                	add    %edx,%eax
    1467:	0f b6 00             	movzbl (%eax),%eax
    146a:	0f be c0             	movsbl %al,%eax
    146d:	25 ff 00 00 00       	and    $0xff,%eax
    1472:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1475:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1479:	75 2c                	jne    14a7 <printf+0x6a>
      if(c == '%'){
    147b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    147f:	75 0c                	jne    148d <printf+0x50>
        state = '%';
    1481:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1488:	e9 27 01 00 00       	jmp    15b4 <printf+0x177>
      } else {
        putc(fd, c);
    148d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1490:	0f be c0             	movsbl %al,%eax
    1493:	83 ec 08             	sub    $0x8,%esp
    1496:	50                   	push   %eax
    1497:	ff 75 08             	pushl  0x8(%ebp)
    149a:	e8 c7 fe ff ff       	call   1366 <putc>
    149f:	83 c4 10             	add    $0x10,%esp
    14a2:	e9 0d 01 00 00       	jmp    15b4 <printf+0x177>
      }
    } else if(state == '%'){
    14a7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14ab:	0f 85 03 01 00 00    	jne    15b4 <printf+0x177>
      if(c == 'd'){
    14b1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14b5:	75 1e                	jne    14d5 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14ba:	8b 00                	mov    (%eax),%eax
    14bc:	6a 01                	push   $0x1
    14be:	6a 0a                	push   $0xa
    14c0:	50                   	push   %eax
    14c1:	ff 75 08             	pushl  0x8(%ebp)
    14c4:	e8 c0 fe ff ff       	call   1389 <printint>
    14c9:	83 c4 10             	add    $0x10,%esp
        ap++;
    14cc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14d0:	e9 d8 00 00 00       	jmp    15ad <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14d5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14d9:	74 06                	je     14e1 <printf+0xa4>
    14db:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14df:	75 1e                	jne    14ff <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14e4:	8b 00                	mov    (%eax),%eax
    14e6:	6a 00                	push   $0x0
    14e8:	6a 10                	push   $0x10
    14ea:	50                   	push   %eax
    14eb:	ff 75 08             	pushl  0x8(%ebp)
    14ee:	e8 96 fe ff ff       	call   1389 <printint>
    14f3:	83 c4 10             	add    $0x10,%esp
        ap++;
    14f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14fa:	e9 ae 00 00 00       	jmp    15ad <printf+0x170>
      } else if(c == 's'){
    14ff:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1503:	75 43                	jne    1548 <printf+0x10b>
        s = (char*)*ap;
    1505:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1508:	8b 00                	mov    (%eax),%eax
    150a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    150d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1511:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1515:	75 25                	jne    153c <printf+0xff>
          s = "(null)";
    1517:	c7 45 f4 42 18 00 00 	movl   $0x1842,-0xc(%ebp)
        while(*s != 0){
    151e:	eb 1c                	jmp    153c <printf+0xff>
          putc(fd, *s);
    1520:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1523:	0f b6 00             	movzbl (%eax),%eax
    1526:	0f be c0             	movsbl %al,%eax
    1529:	83 ec 08             	sub    $0x8,%esp
    152c:	50                   	push   %eax
    152d:	ff 75 08             	pushl  0x8(%ebp)
    1530:	e8 31 fe ff ff       	call   1366 <putc>
    1535:	83 c4 10             	add    $0x10,%esp
          s++;
    1538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    153c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    153f:	0f b6 00             	movzbl (%eax),%eax
    1542:	84 c0                	test   %al,%al
    1544:	75 da                	jne    1520 <printf+0xe3>
    1546:	eb 65                	jmp    15ad <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1548:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    154c:	75 1d                	jne    156b <printf+0x12e>
        putc(fd, *ap);
    154e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1551:	8b 00                	mov    (%eax),%eax
    1553:	0f be c0             	movsbl %al,%eax
    1556:	83 ec 08             	sub    $0x8,%esp
    1559:	50                   	push   %eax
    155a:	ff 75 08             	pushl  0x8(%ebp)
    155d:	e8 04 fe ff ff       	call   1366 <putc>
    1562:	83 c4 10             	add    $0x10,%esp
        ap++;
    1565:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1569:	eb 42                	jmp    15ad <printf+0x170>
      } else if(c == '%'){
    156b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    156f:	75 17                	jne    1588 <printf+0x14b>
        putc(fd, c);
    1571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1574:	0f be c0             	movsbl %al,%eax
    1577:	83 ec 08             	sub    $0x8,%esp
    157a:	50                   	push   %eax
    157b:	ff 75 08             	pushl  0x8(%ebp)
    157e:	e8 e3 fd ff ff       	call   1366 <putc>
    1583:	83 c4 10             	add    $0x10,%esp
    1586:	eb 25                	jmp    15ad <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1588:	83 ec 08             	sub    $0x8,%esp
    158b:	6a 25                	push   $0x25
    158d:	ff 75 08             	pushl  0x8(%ebp)
    1590:	e8 d1 fd ff ff       	call   1366 <putc>
    1595:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    159b:	0f be c0             	movsbl %al,%eax
    159e:	83 ec 08             	sub    $0x8,%esp
    15a1:	50                   	push   %eax
    15a2:	ff 75 08             	pushl  0x8(%ebp)
    15a5:	e8 bc fd ff ff       	call   1366 <putc>
    15aa:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15b8:	8b 55 0c             	mov    0xc(%ebp),%edx
    15bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15be:	01 d0                	add    %edx,%eax
    15c0:	0f b6 00             	movzbl (%eax),%eax
    15c3:	84 c0                	test   %al,%al
    15c5:	0f 85 94 fe ff ff    	jne    145f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15cb:	90                   	nop
    15cc:	c9                   	leave  
    15cd:	c3                   	ret    

000015ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15ce:	55                   	push   %ebp
    15cf:	89 e5                	mov    %esp,%ebp
    15d1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15d4:	8b 45 08             	mov    0x8(%ebp),%eax
    15d7:	83 e8 08             	sub    $0x8,%eax
    15da:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15dd:	a1 30 1b 00 00       	mov    0x1b30,%eax
    15e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15e5:	eb 24                	jmp    160b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ea:	8b 00                	mov    (%eax),%eax
    15ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15ef:	77 12                	ja     1603 <free+0x35>
    15f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15f7:	77 24                	ja     161d <free+0x4f>
    15f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15fc:	8b 00                	mov    (%eax),%eax
    15fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1601:	77 1a                	ja     161d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1603:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1606:	8b 00                	mov    (%eax),%eax
    1608:	89 45 fc             	mov    %eax,-0x4(%ebp)
    160b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    160e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1611:	76 d4                	jbe    15e7 <free+0x19>
    1613:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1616:	8b 00                	mov    (%eax),%eax
    1618:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    161b:	76 ca                	jbe    15e7 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    161d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1620:	8b 40 04             	mov    0x4(%eax),%eax
    1623:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    162a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    162d:	01 c2                	add    %eax,%edx
    162f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1632:	8b 00                	mov    (%eax),%eax
    1634:	39 c2                	cmp    %eax,%edx
    1636:	75 24                	jne    165c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1638:	8b 45 f8             	mov    -0x8(%ebp),%eax
    163b:	8b 50 04             	mov    0x4(%eax),%edx
    163e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1641:	8b 00                	mov    (%eax),%eax
    1643:	8b 40 04             	mov    0x4(%eax),%eax
    1646:	01 c2                	add    %eax,%edx
    1648:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    164e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1651:	8b 00                	mov    (%eax),%eax
    1653:	8b 10                	mov    (%eax),%edx
    1655:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1658:	89 10                	mov    %edx,(%eax)
    165a:	eb 0a                	jmp    1666 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    165c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    165f:	8b 10                	mov    (%eax),%edx
    1661:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1664:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1666:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1669:	8b 40 04             	mov    0x4(%eax),%eax
    166c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1673:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1676:	01 d0                	add    %edx,%eax
    1678:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    167b:	75 20                	jne    169d <free+0xcf>
    p->s.size += bp->s.size;
    167d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1680:	8b 50 04             	mov    0x4(%eax),%edx
    1683:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1686:	8b 40 04             	mov    0x4(%eax),%eax
    1689:	01 c2                	add    %eax,%edx
    168b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1691:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1694:	8b 10                	mov    (%eax),%edx
    1696:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1699:	89 10                	mov    %edx,(%eax)
    169b:	eb 08                	jmp    16a5 <free+0xd7>
  } else
    p->s.ptr = bp;
    169d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a0:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16a3:	89 10                	mov    %edx,(%eax)
  freep = p;
    16a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a8:	a3 30 1b 00 00       	mov    %eax,0x1b30
}
    16ad:	90                   	nop
    16ae:	c9                   	leave  
    16af:	c3                   	ret    

000016b0 <morecore>:

static Header*
morecore(uint nu)
{
    16b0:	55                   	push   %ebp
    16b1:	89 e5                	mov    %esp,%ebp
    16b3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16b6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16bd:	77 07                	ja     16c6 <morecore+0x16>
    nu = 4096;
    16bf:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16c6:	8b 45 08             	mov    0x8(%ebp),%eax
    16c9:	c1 e0 03             	shl    $0x3,%eax
    16cc:	83 ec 0c             	sub    $0xc,%esp
    16cf:	50                   	push   %eax
    16d0:	e8 69 fc ff ff       	call   133e <sbrk>
    16d5:	83 c4 10             	add    $0x10,%esp
    16d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16db:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16df:	75 07                	jne    16e8 <morecore+0x38>
    return 0;
    16e1:	b8 00 00 00 00       	mov    $0x0,%eax
    16e6:	eb 26                	jmp    170e <morecore+0x5e>
  hp = (Header*)p;
    16e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16f1:	8b 55 08             	mov    0x8(%ebp),%edx
    16f4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16fa:	83 c0 08             	add    $0x8,%eax
    16fd:	83 ec 0c             	sub    $0xc,%esp
    1700:	50                   	push   %eax
    1701:	e8 c8 fe ff ff       	call   15ce <free>
    1706:	83 c4 10             	add    $0x10,%esp
  return freep;
    1709:	a1 30 1b 00 00       	mov    0x1b30,%eax
}
    170e:	c9                   	leave  
    170f:	c3                   	ret    

00001710 <malloc>:

void*
malloc(uint nbytes)
{
    1710:	55                   	push   %ebp
    1711:	89 e5                	mov    %esp,%ebp
    1713:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1716:	8b 45 08             	mov    0x8(%ebp),%eax
    1719:	83 c0 07             	add    $0x7,%eax
    171c:	c1 e8 03             	shr    $0x3,%eax
    171f:	83 c0 01             	add    $0x1,%eax
    1722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1725:	a1 30 1b 00 00       	mov    0x1b30,%eax
    172a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    172d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1731:	75 23                	jne    1756 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1733:	c7 45 f0 28 1b 00 00 	movl   $0x1b28,-0x10(%ebp)
    173a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    173d:	a3 30 1b 00 00       	mov    %eax,0x1b30
    1742:	a1 30 1b 00 00       	mov    0x1b30,%eax
    1747:	a3 28 1b 00 00       	mov    %eax,0x1b28
    base.s.size = 0;
    174c:	c7 05 2c 1b 00 00 00 	movl   $0x0,0x1b2c
    1753:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1756:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1759:	8b 00                	mov    (%eax),%eax
    175b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1761:	8b 40 04             	mov    0x4(%eax),%eax
    1764:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1767:	72 4d                	jb     17b6 <malloc+0xa6>
      if(p->s.size == nunits)
    1769:	8b 45 f4             	mov    -0xc(%ebp),%eax
    176c:	8b 40 04             	mov    0x4(%eax),%eax
    176f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1772:	75 0c                	jne    1780 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1774:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1777:	8b 10                	mov    (%eax),%edx
    1779:	8b 45 f0             	mov    -0x10(%ebp),%eax
    177c:	89 10                	mov    %edx,(%eax)
    177e:	eb 26                	jmp    17a6 <malloc+0x96>
      else {
        p->s.size -= nunits;
    1780:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1783:	8b 40 04             	mov    0x4(%eax),%eax
    1786:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1789:	89 c2                	mov    %eax,%edx
    178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1791:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1794:	8b 40 04             	mov    0x4(%eax),%eax
    1797:	c1 e0 03             	shl    $0x3,%eax
    179a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17a3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a9:	a3 30 1b 00 00       	mov    %eax,0x1b30
      return (void*)(p + 1);
    17ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b1:	83 c0 08             	add    $0x8,%eax
    17b4:	eb 3b                	jmp    17f1 <malloc+0xe1>
    }
    if(p == freep)
    17b6:	a1 30 1b 00 00       	mov    0x1b30,%eax
    17bb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17be:	75 1e                	jne    17de <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17c0:	83 ec 0c             	sub    $0xc,%esp
    17c3:	ff 75 ec             	pushl  -0x14(%ebp)
    17c6:	e8 e5 fe ff ff       	call   16b0 <morecore>
    17cb:	83 c4 10             	add    $0x10,%esp
    17ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17d5:	75 07                	jne    17de <malloc+0xce>
        return 0;
    17d7:	b8 00 00 00 00       	mov    $0x0,%eax
    17dc:	eb 13                	jmp    17f1 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17de:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e7:	8b 00                	mov    (%eax),%eax
    17e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17ec:	e9 6d ff ff ff       	jmp    175e <malloc+0x4e>
}
    17f1:	c9                   	leave  
    17f2:	c3                   	ret    

000017f3 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    17f3:	55                   	push   %ebp
    17f4:	89 e5                	mov    %esp,%ebp
    17f6:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    17f9:	8b 55 08             	mov    0x8(%ebp),%edx
    17fc:	8b 45 0c             	mov    0xc(%ebp),%eax
    17ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1802:	f0 87 02             	lock xchg %eax,(%edx)
    1805:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    1808:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    180b:	c9                   	leave  
    180c:	c3                   	ret    

0000180d <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    180d:	55                   	push   %ebp
    180e:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1810:	90                   	nop
    1811:	8b 45 08             	mov    0x8(%ebp),%eax
    1814:	6a 01                	push   $0x1
    1816:	50                   	push   %eax
    1817:	e8 d7 ff ff ff       	call   17f3 <xchg>
    181c:	83 c4 08             	add    $0x8,%esp
    181f:	85 c0                	test   %eax,%eax
    1821:	75 ee                	jne    1811 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1823:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1828:	90                   	nop
    1829:	c9                   	leave  
    182a:	c3                   	ret    

0000182b <urelease>:

void urelease (struct uspinlock *lk) {
    182b:	55                   	push   %ebp
    182c:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    182e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1833:	8b 45 08             	mov    0x8(%ebp),%eax
    1836:	8b 55 08             	mov    0x8(%ebp),%edx
    1839:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    183f:	90                   	nop
    1840:	5d                   	pop    %ebp
    1841:	c3                   	ret    
