
_cat:     file format elf32-i386


Disassembly of section .text:

00001000 <cat>:

char buf[512];

void
cat(int fd)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 18             	sub    $0x18,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
    1006:	eb 31                	jmp    1039 <cat+0x39>
    if (write(1, buf, n) != n) {
    1008:	83 ec 04             	sub    $0x4,%esp
    100b:	ff 75 f4             	pushl  -0xc(%ebp)
    100e:	68 60 1c 00 00       	push   $0x1c60
    1013:	6a 01                	push   $0x1
    1015:	e8 88 03 00 00       	call   13a2 <write>
    101a:	83 c4 10             	add    $0x10,%esp
    101d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    1020:	74 17                	je     1039 <cat+0x39>
      printf(1, "cat: write error\n");
    1022:	83 ec 08             	sub    $0x8,%esp
    1025:	68 0e 19 00 00       	push   $0x190e
    102a:	6a 01                	push   $0x1
    102c:	e8 d8 04 00 00       	call   1509 <printf>
    1031:	83 c4 10             	add    $0x10,%esp
      exit();
    1034:	e8 49 03 00 00       	call   1382 <exit>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
    1039:	83 ec 04             	sub    $0x4,%esp
    103c:	68 00 02 00 00       	push   $0x200
    1041:	68 60 1c 00 00       	push   $0x1c60
    1046:	ff 75 08             	pushl  0x8(%ebp)
    1049:	e8 4c 03 00 00       	call   139a <read>
    104e:	83 c4 10             	add    $0x10,%esp
    1051:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1054:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1058:	7f ae                	jg     1008 <cat+0x8>
    if (write(1, buf, n) != n) {
      printf(1, "cat: write error\n");
      exit();
    }
  }
  if(n < 0){
    105a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    105e:	79 17                	jns    1077 <cat+0x77>
    printf(1, "cat: read error\n");
    1060:	83 ec 08             	sub    $0x8,%esp
    1063:	68 20 19 00 00       	push   $0x1920
    1068:	6a 01                	push   $0x1
    106a:	e8 9a 04 00 00       	call   1509 <printf>
    106f:	83 c4 10             	add    $0x10,%esp
    exit();
    1072:	e8 0b 03 00 00       	call   1382 <exit>
  }
}
    1077:	90                   	nop
    1078:	c9                   	leave  
    1079:	c3                   	ret    

0000107a <main>:

int
main(int argc, char *argv[])
{
    107a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    107e:	83 e4 f0             	and    $0xfffffff0,%esp
    1081:	ff 71 fc             	pushl  -0x4(%ecx)
    1084:	55                   	push   %ebp
    1085:	89 e5                	mov    %esp,%ebp
    1087:	53                   	push   %ebx
    1088:	51                   	push   %ecx
    1089:	83 ec 10             	sub    $0x10,%esp
    108c:	89 cb                	mov    %ecx,%ebx
  int fd, i;

  if(argc <= 1){
    108e:	83 3b 01             	cmpl   $0x1,(%ebx)
    1091:	7f 12                	jg     10a5 <main+0x2b>
    cat(0);
    1093:	83 ec 0c             	sub    $0xc,%esp
    1096:	6a 00                	push   $0x0
    1098:	e8 63 ff ff ff       	call   1000 <cat>
    109d:	83 c4 10             	add    $0x10,%esp
    exit();
    10a0:	e8 dd 02 00 00       	call   1382 <exit>
  }

  for(i = 1; i < argc; i++){
    10a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    10ac:	eb 71                	jmp    111f <main+0xa5>
    if((fd = open(argv[i], 0)) < 0){
    10ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    10b8:	8b 43 04             	mov    0x4(%ebx),%eax
    10bb:	01 d0                	add    %edx,%eax
    10bd:	8b 00                	mov    (%eax),%eax
    10bf:	83 ec 08             	sub    $0x8,%esp
    10c2:	6a 00                	push   $0x0
    10c4:	50                   	push   %eax
    10c5:	e8 f8 02 00 00       	call   13c2 <open>
    10ca:	83 c4 10             	add    $0x10,%esp
    10cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10d4:	79 29                	jns    10ff <main+0x85>
      printf(1, "cat: cannot open %s\n", argv[i]);
    10d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    10e0:	8b 43 04             	mov    0x4(%ebx),%eax
    10e3:	01 d0                	add    %edx,%eax
    10e5:	8b 00                	mov    (%eax),%eax
    10e7:	83 ec 04             	sub    $0x4,%esp
    10ea:	50                   	push   %eax
    10eb:	68 31 19 00 00       	push   $0x1931
    10f0:	6a 01                	push   $0x1
    10f2:	e8 12 04 00 00       	call   1509 <printf>
    10f7:	83 c4 10             	add    $0x10,%esp
      exit();
    10fa:	e8 83 02 00 00       	call   1382 <exit>
    }
    cat(fd);
    10ff:	83 ec 0c             	sub    $0xc,%esp
    1102:	ff 75 f0             	pushl  -0x10(%ebp)
    1105:	e8 f6 fe ff ff       	call   1000 <cat>
    110a:	83 c4 10             	add    $0x10,%esp
    close(fd);
    110d:	83 ec 0c             	sub    $0xc,%esp
    1110:	ff 75 f0             	pushl  -0x10(%ebp)
    1113:	e8 92 02 00 00       	call   13aa <close>
    1118:	83 c4 10             	add    $0x10,%esp
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
    111b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    111f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1122:	3b 03                	cmp    (%ebx),%eax
    1124:	7c 88                	jl     10ae <main+0x34>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
    1126:	e8 57 02 00 00       	call   1382 <exit>

0000112b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    112b:	55                   	push   %ebp
    112c:	89 e5                	mov    %esp,%ebp
    112e:	57                   	push   %edi
    112f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1130:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1133:	8b 55 10             	mov    0x10(%ebp),%edx
    1136:	8b 45 0c             	mov    0xc(%ebp),%eax
    1139:	89 cb                	mov    %ecx,%ebx
    113b:	89 df                	mov    %ebx,%edi
    113d:	89 d1                	mov    %edx,%ecx
    113f:	fc                   	cld    
    1140:	f3 aa                	rep stos %al,%es:(%edi)
    1142:	89 ca                	mov    %ecx,%edx
    1144:	89 fb                	mov    %edi,%ebx
    1146:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1149:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    114c:	90                   	nop
    114d:	5b                   	pop    %ebx
    114e:	5f                   	pop    %edi
    114f:	5d                   	pop    %ebp
    1150:	c3                   	ret    

00001151 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1151:	55                   	push   %ebp
    1152:	89 e5                	mov    %esp,%ebp
    1154:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1157:	8b 45 08             	mov    0x8(%ebp),%eax
    115a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    115d:	90                   	nop
    115e:	8b 45 08             	mov    0x8(%ebp),%eax
    1161:	8d 50 01             	lea    0x1(%eax),%edx
    1164:	89 55 08             	mov    %edx,0x8(%ebp)
    1167:	8b 55 0c             	mov    0xc(%ebp),%edx
    116a:	8d 4a 01             	lea    0x1(%edx),%ecx
    116d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1170:	0f b6 12             	movzbl (%edx),%edx
    1173:	88 10                	mov    %dl,(%eax)
    1175:	0f b6 00             	movzbl (%eax),%eax
    1178:	84 c0                	test   %al,%al
    117a:	75 e2                	jne    115e <strcpy+0xd>
    ;
  return os;
    117c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    117f:	c9                   	leave  
    1180:	c3                   	ret    

00001181 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1181:	55                   	push   %ebp
    1182:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1184:	eb 08                	jmp    118e <strcmp+0xd>
    p++, q++;
    1186:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    118a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    118e:	8b 45 08             	mov    0x8(%ebp),%eax
    1191:	0f b6 00             	movzbl (%eax),%eax
    1194:	84 c0                	test   %al,%al
    1196:	74 10                	je     11a8 <strcmp+0x27>
    1198:	8b 45 08             	mov    0x8(%ebp),%eax
    119b:	0f b6 10             	movzbl (%eax),%edx
    119e:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a1:	0f b6 00             	movzbl (%eax),%eax
    11a4:	38 c2                	cmp    %al,%dl
    11a6:	74 de                	je     1186 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    11a8:	8b 45 08             	mov    0x8(%ebp),%eax
    11ab:	0f b6 00             	movzbl (%eax),%eax
    11ae:	0f b6 d0             	movzbl %al,%edx
    11b1:	8b 45 0c             	mov    0xc(%ebp),%eax
    11b4:	0f b6 00             	movzbl (%eax),%eax
    11b7:	0f b6 c0             	movzbl %al,%eax
    11ba:	29 c2                	sub    %eax,%edx
    11bc:	89 d0                	mov    %edx,%eax
}
    11be:	5d                   	pop    %ebp
    11bf:	c3                   	ret    

000011c0 <strlen>:

uint
strlen(char *s)
{
    11c0:	55                   	push   %ebp
    11c1:	89 e5                	mov    %esp,%ebp
    11c3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    11c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    11cd:	eb 04                	jmp    11d3 <strlen+0x13>
    11cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    11d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11d6:	8b 45 08             	mov    0x8(%ebp),%eax
    11d9:	01 d0                	add    %edx,%eax
    11db:	0f b6 00             	movzbl (%eax),%eax
    11de:	84 c0                	test   %al,%al
    11e0:	75 ed                	jne    11cf <strlen+0xf>
    ;
  return n;
    11e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11e5:	c9                   	leave  
    11e6:	c3                   	ret    

000011e7 <memset>:

void*
memset(void *dst, int c, uint n)
{
    11e7:	55                   	push   %ebp
    11e8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    11ea:	8b 45 10             	mov    0x10(%ebp),%eax
    11ed:	50                   	push   %eax
    11ee:	ff 75 0c             	pushl  0xc(%ebp)
    11f1:	ff 75 08             	pushl  0x8(%ebp)
    11f4:	e8 32 ff ff ff       	call   112b <stosb>
    11f9:	83 c4 0c             	add    $0xc,%esp
  return dst;
    11fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11ff:	c9                   	leave  
    1200:	c3                   	ret    

00001201 <strchr>:

char*
strchr(const char *s, char c)
{
    1201:	55                   	push   %ebp
    1202:	89 e5                	mov    %esp,%ebp
    1204:	83 ec 04             	sub    $0x4,%esp
    1207:	8b 45 0c             	mov    0xc(%ebp),%eax
    120a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    120d:	eb 14                	jmp    1223 <strchr+0x22>
    if(*s == c)
    120f:	8b 45 08             	mov    0x8(%ebp),%eax
    1212:	0f b6 00             	movzbl (%eax),%eax
    1215:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1218:	75 05                	jne    121f <strchr+0x1e>
      return (char*)s;
    121a:	8b 45 08             	mov    0x8(%ebp),%eax
    121d:	eb 13                	jmp    1232 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    121f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1223:	8b 45 08             	mov    0x8(%ebp),%eax
    1226:	0f b6 00             	movzbl (%eax),%eax
    1229:	84 c0                	test   %al,%al
    122b:	75 e2                	jne    120f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    122d:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1232:	c9                   	leave  
    1233:	c3                   	ret    

00001234 <gets>:

char*
gets(char *buf, int max)
{
    1234:	55                   	push   %ebp
    1235:	89 e5                	mov    %esp,%ebp
    1237:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    123a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1241:	eb 42                	jmp    1285 <gets+0x51>
    cc = read(0, &c, 1);
    1243:	83 ec 04             	sub    $0x4,%esp
    1246:	6a 01                	push   $0x1
    1248:	8d 45 ef             	lea    -0x11(%ebp),%eax
    124b:	50                   	push   %eax
    124c:	6a 00                	push   $0x0
    124e:	e8 47 01 00 00       	call   139a <read>
    1253:	83 c4 10             	add    $0x10,%esp
    1256:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1259:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    125d:	7e 33                	jle    1292 <gets+0x5e>
      break;
    buf[i++] = c;
    125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1262:	8d 50 01             	lea    0x1(%eax),%edx
    1265:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1268:	89 c2                	mov    %eax,%edx
    126a:	8b 45 08             	mov    0x8(%ebp),%eax
    126d:	01 c2                	add    %eax,%edx
    126f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1273:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1275:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1279:	3c 0a                	cmp    $0xa,%al
    127b:	74 16                	je     1293 <gets+0x5f>
    127d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1281:	3c 0d                	cmp    $0xd,%al
    1283:	74 0e                	je     1293 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1285:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1288:	83 c0 01             	add    $0x1,%eax
    128b:	3b 45 0c             	cmp    0xc(%ebp),%eax
    128e:	7c b3                	jl     1243 <gets+0xf>
    1290:	eb 01                	jmp    1293 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1292:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1293:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1296:	8b 45 08             	mov    0x8(%ebp),%eax
    1299:	01 d0                	add    %edx,%eax
    129b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    129e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12a1:	c9                   	leave  
    12a2:	c3                   	ret    

000012a3 <stat>:

int
stat(char *n, struct stat *st)
{
    12a3:	55                   	push   %ebp
    12a4:	89 e5                	mov    %esp,%ebp
    12a6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    12a9:	83 ec 08             	sub    $0x8,%esp
    12ac:	6a 00                	push   $0x0
    12ae:	ff 75 08             	pushl  0x8(%ebp)
    12b1:	e8 0c 01 00 00       	call   13c2 <open>
    12b6:	83 c4 10             	add    $0x10,%esp
    12b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    12bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12c0:	79 07                	jns    12c9 <stat+0x26>
    return -1;
    12c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    12c7:	eb 25                	jmp    12ee <stat+0x4b>
  r = fstat(fd, st);
    12c9:	83 ec 08             	sub    $0x8,%esp
    12cc:	ff 75 0c             	pushl  0xc(%ebp)
    12cf:	ff 75 f4             	pushl  -0xc(%ebp)
    12d2:	e8 03 01 00 00       	call   13da <fstat>
    12d7:	83 c4 10             	add    $0x10,%esp
    12da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    12dd:	83 ec 0c             	sub    $0xc,%esp
    12e0:	ff 75 f4             	pushl  -0xc(%ebp)
    12e3:	e8 c2 00 00 00       	call   13aa <close>
    12e8:	83 c4 10             	add    $0x10,%esp
  return r;
    12eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    12ee:	c9                   	leave  
    12ef:	c3                   	ret    

000012f0 <atoi>:

int
atoi(const char *s)
{
    12f0:	55                   	push   %ebp
    12f1:	89 e5                	mov    %esp,%ebp
    12f3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    12f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    12fd:	eb 25                	jmp    1324 <atoi+0x34>
    n = n*10 + *s++ - '0';
    12ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1302:	89 d0                	mov    %edx,%eax
    1304:	c1 e0 02             	shl    $0x2,%eax
    1307:	01 d0                	add    %edx,%eax
    1309:	01 c0                	add    %eax,%eax
    130b:	89 c1                	mov    %eax,%ecx
    130d:	8b 45 08             	mov    0x8(%ebp),%eax
    1310:	8d 50 01             	lea    0x1(%eax),%edx
    1313:	89 55 08             	mov    %edx,0x8(%ebp)
    1316:	0f b6 00             	movzbl (%eax),%eax
    1319:	0f be c0             	movsbl %al,%eax
    131c:	01 c8                	add    %ecx,%eax
    131e:	83 e8 30             	sub    $0x30,%eax
    1321:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1324:	8b 45 08             	mov    0x8(%ebp),%eax
    1327:	0f b6 00             	movzbl (%eax),%eax
    132a:	3c 2f                	cmp    $0x2f,%al
    132c:	7e 0a                	jle    1338 <atoi+0x48>
    132e:	8b 45 08             	mov    0x8(%ebp),%eax
    1331:	0f b6 00             	movzbl (%eax),%eax
    1334:	3c 39                	cmp    $0x39,%al
    1336:	7e c7                	jle    12ff <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1338:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    133b:	c9                   	leave  
    133c:	c3                   	ret    

0000133d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    133d:	55                   	push   %ebp
    133e:	89 e5                	mov    %esp,%ebp
    1340:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1343:	8b 45 08             	mov    0x8(%ebp),%eax
    1346:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1349:	8b 45 0c             	mov    0xc(%ebp),%eax
    134c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    134f:	eb 17                	jmp    1368 <memmove+0x2b>
    *dst++ = *src++;
    1351:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1354:	8d 50 01             	lea    0x1(%eax),%edx
    1357:	89 55 fc             	mov    %edx,-0x4(%ebp)
    135a:	8b 55 f8             	mov    -0x8(%ebp),%edx
    135d:	8d 4a 01             	lea    0x1(%edx),%ecx
    1360:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1363:	0f b6 12             	movzbl (%edx),%edx
    1366:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1368:	8b 45 10             	mov    0x10(%ebp),%eax
    136b:	8d 50 ff             	lea    -0x1(%eax),%edx
    136e:	89 55 10             	mov    %edx,0x10(%ebp)
    1371:	85 c0                	test   %eax,%eax
    1373:	7f dc                	jg     1351 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1375:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1378:	c9                   	leave  
    1379:	c3                   	ret    

0000137a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    137a:	b8 01 00 00 00       	mov    $0x1,%eax
    137f:	cd 40                	int    $0x40
    1381:	c3                   	ret    

00001382 <exit>:
SYSCALL(exit)
    1382:	b8 02 00 00 00       	mov    $0x2,%eax
    1387:	cd 40                	int    $0x40
    1389:	c3                   	ret    

0000138a <wait>:
SYSCALL(wait)
    138a:	b8 03 00 00 00       	mov    $0x3,%eax
    138f:	cd 40                	int    $0x40
    1391:	c3                   	ret    

00001392 <pipe>:
SYSCALL(pipe)
    1392:	b8 04 00 00 00       	mov    $0x4,%eax
    1397:	cd 40                	int    $0x40
    1399:	c3                   	ret    

0000139a <read>:
SYSCALL(read)
    139a:	b8 05 00 00 00       	mov    $0x5,%eax
    139f:	cd 40                	int    $0x40
    13a1:	c3                   	ret    

000013a2 <write>:
SYSCALL(write)
    13a2:	b8 10 00 00 00       	mov    $0x10,%eax
    13a7:	cd 40                	int    $0x40
    13a9:	c3                   	ret    

000013aa <close>:
SYSCALL(close)
    13aa:	b8 15 00 00 00       	mov    $0x15,%eax
    13af:	cd 40                	int    $0x40
    13b1:	c3                   	ret    

000013b2 <kill>:
SYSCALL(kill)
    13b2:	b8 06 00 00 00       	mov    $0x6,%eax
    13b7:	cd 40                	int    $0x40
    13b9:	c3                   	ret    

000013ba <exec>:
SYSCALL(exec)
    13ba:	b8 07 00 00 00       	mov    $0x7,%eax
    13bf:	cd 40                	int    $0x40
    13c1:	c3                   	ret    

000013c2 <open>:
SYSCALL(open)
    13c2:	b8 0f 00 00 00       	mov    $0xf,%eax
    13c7:	cd 40                	int    $0x40
    13c9:	c3                   	ret    

000013ca <mknod>:
SYSCALL(mknod)
    13ca:	b8 11 00 00 00       	mov    $0x11,%eax
    13cf:	cd 40                	int    $0x40
    13d1:	c3                   	ret    

000013d2 <unlink>:
SYSCALL(unlink)
    13d2:	b8 12 00 00 00       	mov    $0x12,%eax
    13d7:	cd 40                	int    $0x40
    13d9:	c3                   	ret    

000013da <fstat>:
SYSCALL(fstat)
    13da:	b8 08 00 00 00       	mov    $0x8,%eax
    13df:	cd 40                	int    $0x40
    13e1:	c3                   	ret    

000013e2 <link>:
SYSCALL(link)
    13e2:	b8 13 00 00 00       	mov    $0x13,%eax
    13e7:	cd 40                	int    $0x40
    13e9:	c3                   	ret    

000013ea <mkdir>:
SYSCALL(mkdir)
    13ea:	b8 14 00 00 00       	mov    $0x14,%eax
    13ef:	cd 40                	int    $0x40
    13f1:	c3                   	ret    

000013f2 <chdir>:
SYSCALL(chdir)
    13f2:	b8 09 00 00 00       	mov    $0x9,%eax
    13f7:	cd 40                	int    $0x40
    13f9:	c3                   	ret    

000013fa <dup>:
SYSCALL(dup)
    13fa:	b8 0a 00 00 00       	mov    $0xa,%eax
    13ff:	cd 40                	int    $0x40
    1401:	c3                   	ret    

00001402 <getpid>:
SYSCALL(getpid)
    1402:	b8 0b 00 00 00       	mov    $0xb,%eax
    1407:	cd 40                	int    $0x40
    1409:	c3                   	ret    

0000140a <sbrk>:
SYSCALL(sbrk)
    140a:	b8 0c 00 00 00       	mov    $0xc,%eax
    140f:	cd 40                	int    $0x40
    1411:	c3                   	ret    

00001412 <sleep>:
SYSCALL(sleep)
    1412:	b8 0d 00 00 00       	mov    $0xd,%eax
    1417:	cd 40                	int    $0x40
    1419:	c3                   	ret    

0000141a <uptime>:
SYSCALL(uptime)
    141a:	b8 0e 00 00 00       	mov    $0xe,%eax
    141f:	cd 40                	int    $0x40
    1421:	c3                   	ret    

00001422 <shm_open>:
SYSCALL(shm_open)
    1422:	b8 16 00 00 00       	mov    $0x16,%eax
    1427:	cd 40                	int    $0x40
    1429:	c3                   	ret    

0000142a <shm_close>:
SYSCALL(shm_close)	
    142a:	b8 17 00 00 00       	mov    $0x17,%eax
    142f:	cd 40                	int    $0x40
    1431:	c3                   	ret    

00001432 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1432:	55                   	push   %ebp
    1433:	89 e5                	mov    %esp,%ebp
    1435:	83 ec 18             	sub    $0x18,%esp
    1438:	8b 45 0c             	mov    0xc(%ebp),%eax
    143b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    143e:	83 ec 04             	sub    $0x4,%esp
    1441:	6a 01                	push   $0x1
    1443:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1446:	50                   	push   %eax
    1447:	ff 75 08             	pushl  0x8(%ebp)
    144a:	e8 53 ff ff ff       	call   13a2 <write>
    144f:	83 c4 10             	add    $0x10,%esp
}
    1452:	90                   	nop
    1453:	c9                   	leave  
    1454:	c3                   	ret    

00001455 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1455:	55                   	push   %ebp
    1456:	89 e5                	mov    %esp,%ebp
    1458:	53                   	push   %ebx
    1459:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    145c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1463:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1467:	74 17                	je     1480 <printint+0x2b>
    1469:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    146d:	79 11                	jns    1480 <printint+0x2b>
    neg = 1;
    146f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1476:	8b 45 0c             	mov    0xc(%ebp),%eax
    1479:	f7 d8                	neg    %eax
    147b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    147e:	eb 06                	jmp    1486 <printint+0x31>
  } else {
    x = xx;
    1480:	8b 45 0c             	mov    0xc(%ebp),%eax
    1483:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1486:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    148d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1490:	8d 41 01             	lea    0x1(%ecx),%eax
    1493:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1496:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1499:	8b 45 ec             	mov    -0x14(%ebp),%eax
    149c:	ba 00 00 00 00       	mov    $0x0,%edx
    14a1:	f7 f3                	div    %ebx
    14a3:	89 d0                	mov    %edx,%eax
    14a5:	0f b6 80 1c 1c 00 00 	movzbl 0x1c1c(%eax),%eax
    14ac:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    14b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
    14b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14b6:	ba 00 00 00 00       	mov    $0x0,%edx
    14bb:	f7 f3                	div    %ebx
    14bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    14c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14c4:	75 c7                	jne    148d <printint+0x38>
  if(neg)
    14c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14ca:	74 2d                	je     14f9 <printint+0xa4>
    buf[i++] = '-';
    14cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14cf:	8d 50 01             	lea    0x1(%eax),%edx
    14d2:	89 55 f4             	mov    %edx,-0xc(%ebp)
    14d5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    14da:	eb 1d                	jmp    14f9 <printint+0xa4>
    putc(fd, buf[i]);
    14dc:	8d 55 dc             	lea    -0x24(%ebp),%edx
    14df:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14e2:	01 d0                	add    %edx,%eax
    14e4:	0f b6 00             	movzbl (%eax),%eax
    14e7:	0f be c0             	movsbl %al,%eax
    14ea:	83 ec 08             	sub    $0x8,%esp
    14ed:	50                   	push   %eax
    14ee:	ff 75 08             	pushl  0x8(%ebp)
    14f1:	e8 3c ff ff ff       	call   1432 <putc>
    14f6:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    14f9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1501:	79 d9                	jns    14dc <printint+0x87>
    putc(fd, buf[i]);
}
    1503:	90                   	nop
    1504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1507:	c9                   	leave  
    1508:	c3                   	ret    

00001509 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1509:	55                   	push   %ebp
    150a:	89 e5                	mov    %esp,%ebp
    150c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    150f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1516:	8d 45 0c             	lea    0xc(%ebp),%eax
    1519:	83 c0 04             	add    $0x4,%eax
    151c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    151f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1526:	e9 59 01 00 00       	jmp    1684 <printf+0x17b>
    c = fmt[i] & 0xff;
    152b:	8b 55 0c             	mov    0xc(%ebp),%edx
    152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1531:	01 d0                	add    %edx,%eax
    1533:	0f b6 00             	movzbl (%eax),%eax
    1536:	0f be c0             	movsbl %al,%eax
    1539:	25 ff 00 00 00       	and    $0xff,%eax
    153e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1541:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1545:	75 2c                	jne    1573 <printf+0x6a>
      if(c == '%'){
    1547:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    154b:	75 0c                	jne    1559 <printf+0x50>
        state = '%';
    154d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1554:	e9 27 01 00 00       	jmp    1680 <printf+0x177>
      } else {
        putc(fd, c);
    1559:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    155c:	0f be c0             	movsbl %al,%eax
    155f:	83 ec 08             	sub    $0x8,%esp
    1562:	50                   	push   %eax
    1563:	ff 75 08             	pushl  0x8(%ebp)
    1566:	e8 c7 fe ff ff       	call   1432 <putc>
    156b:	83 c4 10             	add    $0x10,%esp
    156e:	e9 0d 01 00 00       	jmp    1680 <printf+0x177>
      }
    } else if(state == '%'){
    1573:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1577:	0f 85 03 01 00 00    	jne    1680 <printf+0x177>
      if(c == 'd'){
    157d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1581:	75 1e                	jne    15a1 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1583:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1586:	8b 00                	mov    (%eax),%eax
    1588:	6a 01                	push   $0x1
    158a:	6a 0a                	push   $0xa
    158c:	50                   	push   %eax
    158d:	ff 75 08             	pushl  0x8(%ebp)
    1590:	e8 c0 fe ff ff       	call   1455 <printint>
    1595:	83 c4 10             	add    $0x10,%esp
        ap++;
    1598:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    159c:	e9 d8 00 00 00       	jmp    1679 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    15a1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    15a5:	74 06                	je     15ad <printf+0xa4>
    15a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    15ab:	75 1e                	jne    15cb <printf+0xc2>
        printint(fd, *ap, 16, 0);
    15ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15b0:	8b 00                	mov    (%eax),%eax
    15b2:	6a 00                	push   $0x0
    15b4:	6a 10                	push   $0x10
    15b6:	50                   	push   %eax
    15b7:	ff 75 08             	pushl  0x8(%ebp)
    15ba:	e8 96 fe ff ff       	call   1455 <printint>
    15bf:	83 c4 10             	add    $0x10,%esp
        ap++;
    15c2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15c6:	e9 ae 00 00 00       	jmp    1679 <printf+0x170>
      } else if(c == 's'){
    15cb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    15cf:	75 43                	jne    1614 <printf+0x10b>
        s = (char*)*ap;
    15d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15d4:	8b 00                	mov    (%eax),%eax
    15d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    15d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    15dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15e1:	75 25                	jne    1608 <printf+0xff>
          s = "(null)";
    15e3:	c7 45 f4 46 19 00 00 	movl   $0x1946,-0xc(%ebp)
        while(*s != 0){
    15ea:	eb 1c                	jmp    1608 <printf+0xff>
          putc(fd, *s);
    15ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15ef:	0f b6 00             	movzbl (%eax),%eax
    15f2:	0f be c0             	movsbl %al,%eax
    15f5:	83 ec 08             	sub    $0x8,%esp
    15f8:	50                   	push   %eax
    15f9:	ff 75 08             	pushl  0x8(%ebp)
    15fc:	e8 31 fe ff ff       	call   1432 <putc>
    1601:	83 c4 10             	add    $0x10,%esp
          s++;
    1604:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1608:	8b 45 f4             	mov    -0xc(%ebp),%eax
    160b:	0f b6 00             	movzbl (%eax),%eax
    160e:	84 c0                	test   %al,%al
    1610:	75 da                	jne    15ec <printf+0xe3>
    1612:	eb 65                	jmp    1679 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1614:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1618:	75 1d                	jne    1637 <printf+0x12e>
        putc(fd, *ap);
    161a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    161d:	8b 00                	mov    (%eax),%eax
    161f:	0f be c0             	movsbl %al,%eax
    1622:	83 ec 08             	sub    $0x8,%esp
    1625:	50                   	push   %eax
    1626:	ff 75 08             	pushl  0x8(%ebp)
    1629:	e8 04 fe ff ff       	call   1432 <putc>
    162e:	83 c4 10             	add    $0x10,%esp
        ap++;
    1631:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1635:	eb 42                	jmp    1679 <printf+0x170>
      } else if(c == '%'){
    1637:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    163b:	75 17                	jne    1654 <printf+0x14b>
        putc(fd, c);
    163d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1640:	0f be c0             	movsbl %al,%eax
    1643:	83 ec 08             	sub    $0x8,%esp
    1646:	50                   	push   %eax
    1647:	ff 75 08             	pushl  0x8(%ebp)
    164a:	e8 e3 fd ff ff       	call   1432 <putc>
    164f:	83 c4 10             	add    $0x10,%esp
    1652:	eb 25                	jmp    1679 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1654:	83 ec 08             	sub    $0x8,%esp
    1657:	6a 25                	push   $0x25
    1659:	ff 75 08             	pushl  0x8(%ebp)
    165c:	e8 d1 fd ff ff       	call   1432 <putc>
    1661:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1664:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1667:	0f be c0             	movsbl %al,%eax
    166a:	83 ec 08             	sub    $0x8,%esp
    166d:	50                   	push   %eax
    166e:	ff 75 08             	pushl  0x8(%ebp)
    1671:	e8 bc fd ff ff       	call   1432 <putc>
    1676:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    1679:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1680:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1684:	8b 55 0c             	mov    0xc(%ebp),%edx
    1687:	8b 45 f0             	mov    -0x10(%ebp),%eax
    168a:	01 d0                	add    %edx,%eax
    168c:	0f b6 00             	movzbl (%eax),%eax
    168f:	84 c0                	test   %al,%al
    1691:	0f 85 94 fe ff ff    	jne    152b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1697:	90                   	nop
    1698:	c9                   	leave  
    1699:	c3                   	ret    

0000169a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    169a:	55                   	push   %ebp
    169b:	89 e5                	mov    %esp,%ebp
    169d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    16a0:	8b 45 08             	mov    0x8(%ebp),%eax
    16a3:	83 e8 08             	sub    $0x8,%eax
    16a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16a9:	a1 48 1c 00 00       	mov    0x1c48,%eax
    16ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16b1:	eb 24                	jmp    16d7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    16b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b6:	8b 00                	mov    (%eax),%eax
    16b8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16bb:	77 12                	ja     16cf <free+0x35>
    16bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16c3:	77 24                	ja     16e9 <free+0x4f>
    16c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c8:	8b 00                	mov    (%eax),%eax
    16ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16cd:	77 1a                	ja     16e9 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d2:	8b 00                	mov    (%eax),%eax
    16d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16dd:	76 d4                	jbe    16b3 <free+0x19>
    16df:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e2:	8b 00                	mov    (%eax),%eax
    16e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16e7:	76 ca                	jbe    16b3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ec:	8b 40 04             	mov    0x4(%eax),%eax
    16ef:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16f9:	01 c2                	add    %eax,%edx
    16fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16fe:	8b 00                	mov    (%eax),%eax
    1700:	39 c2                	cmp    %eax,%edx
    1702:	75 24                	jne    1728 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1704:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1707:	8b 50 04             	mov    0x4(%eax),%edx
    170a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    170d:	8b 00                	mov    (%eax),%eax
    170f:	8b 40 04             	mov    0x4(%eax),%eax
    1712:	01 c2                	add    %eax,%edx
    1714:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1717:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    171a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    171d:	8b 00                	mov    (%eax),%eax
    171f:	8b 10                	mov    (%eax),%edx
    1721:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1724:	89 10                	mov    %edx,(%eax)
    1726:	eb 0a                	jmp    1732 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1728:	8b 45 fc             	mov    -0x4(%ebp),%eax
    172b:	8b 10                	mov    (%eax),%edx
    172d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1730:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1732:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1735:	8b 40 04             	mov    0x4(%eax),%eax
    1738:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    173f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1742:	01 d0                	add    %edx,%eax
    1744:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1747:	75 20                	jne    1769 <free+0xcf>
    p->s.size += bp->s.size;
    1749:	8b 45 fc             	mov    -0x4(%ebp),%eax
    174c:	8b 50 04             	mov    0x4(%eax),%edx
    174f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1752:	8b 40 04             	mov    0x4(%eax),%eax
    1755:	01 c2                	add    %eax,%edx
    1757:	8b 45 fc             	mov    -0x4(%ebp),%eax
    175a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    175d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1760:	8b 10                	mov    (%eax),%edx
    1762:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1765:	89 10                	mov    %edx,(%eax)
    1767:	eb 08                	jmp    1771 <free+0xd7>
  } else
    p->s.ptr = bp;
    1769:	8b 45 fc             	mov    -0x4(%ebp),%eax
    176c:	8b 55 f8             	mov    -0x8(%ebp),%edx
    176f:	89 10                	mov    %edx,(%eax)
  freep = p;
    1771:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1774:	a3 48 1c 00 00       	mov    %eax,0x1c48
}
    1779:	90                   	nop
    177a:	c9                   	leave  
    177b:	c3                   	ret    

0000177c <morecore>:

static Header*
morecore(uint nu)
{
    177c:	55                   	push   %ebp
    177d:	89 e5                	mov    %esp,%ebp
    177f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1782:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1789:	77 07                	ja     1792 <morecore+0x16>
    nu = 4096;
    178b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1792:	8b 45 08             	mov    0x8(%ebp),%eax
    1795:	c1 e0 03             	shl    $0x3,%eax
    1798:	83 ec 0c             	sub    $0xc,%esp
    179b:	50                   	push   %eax
    179c:	e8 69 fc ff ff       	call   140a <sbrk>
    17a1:	83 c4 10             	add    $0x10,%esp
    17a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    17a7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    17ab:	75 07                	jne    17b4 <morecore+0x38>
    return 0;
    17ad:	b8 00 00 00 00       	mov    $0x0,%eax
    17b2:	eb 26                	jmp    17da <morecore+0x5e>
  hp = (Header*)p;
    17b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    17ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17bd:	8b 55 08             	mov    0x8(%ebp),%edx
    17c0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    17c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17c6:	83 c0 08             	add    $0x8,%eax
    17c9:	83 ec 0c             	sub    $0xc,%esp
    17cc:	50                   	push   %eax
    17cd:	e8 c8 fe ff ff       	call   169a <free>
    17d2:	83 c4 10             	add    $0x10,%esp
  return freep;
    17d5:	a1 48 1c 00 00       	mov    0x1c48,%eax
}
    17da:	c9                   	leave  
    17db:	c3                   	ret    

000017dc <malloc>:

void*
malloc(uint nbytes)
{
    17dc:	55                   	push   %ebp
    17dd:	89 e5                	mov    %esp,%ebp
    17df:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    17e2:	8b 45 08             	mov    0x8(%ebp),%eax
    17e5:	83 c0 07             	add    $0x7,%eax
    17e8:	c1 e8 03             	shr    $0x3,%eax
    17eb:	83 c0 01             	add    $0x1,%eax
    17ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17f1:	a1 48 1c 00 00       	mov    0x1c48,%eax
    17f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17fd:	75 23                	jne    1822 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17ff:	c7 45 f0 40 1c 00 00 	movl   $0x1c40,-0x10(%ebp)
    1806:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1809:	a3 48 1c 00 00       	mov    %eax,0x1c48
    180e:	a1 48 1c 00 00       	mov    0x1c48,%eax
    1813:	a3 40 1c 00 00       	mov    %eax,0x1c40
    base.s.size = 0;
    1818:	c7 05 44 1c 00 00 00 	movl   $0x0,0x1c44
    181f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1822:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1825:	8b 00                	mov    (%eax),%eax
    1827:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    182d:	8b 40 04             	mov    0x4(%eax),%eax
    1830:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1833:	72 4d                	jb     1882 <malloc+0xa6>
      if(p->s.size == nunits)
    1835:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1838:	8b 40 04             	mov    0x4(%eax),%eax
    183b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    183e:	75 0c                	jne    184c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1840:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1843:	8b 10                	mov    (%eax),%edx
    1845:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1848:	89 10                	mov    %edx,(%eax)
    184a:	eb 26                	jmp    1872 <malloc+0x96>
      else {
        p->s.size -= nunits;
    184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    184f:	8b 40 04             	mov    0x4(%eax),%eax
    1852:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1855:	89 c2                	mov    %eax,%edx
    1857:	8b 45 f4             	mov    -0xc(%ebp),%eax
    185a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    185d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1860:	8b 40 04             	mov    0x4(%eax),%eax
    1863:	c1 e0 03             	shl    $0x3,%eax
    1866:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1869:	8b 45 f4             	mov    -0xc(%ebp),%eax
    186c:	8b 55 ec             	mov    -0x14(%ebp),%edx
    186f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1872:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1875:	a3 48 1c 00 00       	mov    %eax,0x1c48
      return (void*)(p + 1);
    187a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    187d:	83 c0 08             	add    $0x8,%eax
    1880:	eb 3b                	jmp    18bd <malloc+0xe1>
    }
    if(p == freep)
    1882:	a1 48 1c 00 00       	mov    0x1c48,%eax
    1887:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    188a:	75 1e                	jne    18aa <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    188c:	83 ec 0c             	sub    $0xc,%esp
    188f:	ff 75 ec             	pushl  -0x14(%ebp)
    1892:	e8 e5 fe ff ff       	call   177c <morecore>
    1897:	83 c4 10             	add    $0x10,%esp
    189a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    189d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    18a1:	75 07                	jne    18aa <malloc+0xce>
        return 0;
    18a3:	b8 00 00 00 00       	mov    $0x0,%eax
    18a8:	eb 13                	jmp    18bd <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    18aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    18b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18b3:	8b 00                	mov    (%eax),%eax
    18b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    18b8:	e9 6d ff ff ff       	jmp    182a <malloc+0x4e>
}
    18bd:	c9                   	leave  
    18be:	c3                   	ret    

000018bf <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    18bf:	55                   	push   %ebp
    18c0:	89 e5                	mov    %esp,%ebp
    18c2:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    18c5:	8b 55 08             	mov    0x8(%ebp),%edx
    18c8:	8b 45 0c             	mov    0xc(%ebp),%eax
    18cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
    18ce:	f0 87 02             	lock xchg %eax,(%edx)
    18d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    18d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    18d7:	c9                   	leave  
    18d8:	c3                   	ret    

000018d9 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    18d9:	55                   	push   %ebp
    18da:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    18dc:	90                   	nop
    18dd:	8b 45 08             	mov    0x8(%ebp),%eax
    18e0:	6a 01                	push   $0x1
    18e2:	50                   	push   %eax
    18e3:	e8 d7 ff ff ff       	call   18bf <xchg>
    18e8:	83 c4 08             	add    $0x8,%esp
    18eb:	85 c0                	test   %eax,%eax
    18ed:	75 ee                	jne    18dd <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    18ef:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    18f4:	90                   	nop
    18f5:	c9                   	leave  
    18f6:	c3                   	ret    

000018f7 <urelease>:

void urelease (struct uspinlock *lk) {
    18f7:	55                   	push   %ebp
    18f8:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    18fa:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    18ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1902:	8b 55 08             	mov    0x8(%ebp),%edx
    1905:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    190b:	90                   	nop
    190c:	5d                   	pop    %ebp
    190d:	c3                   	ret    
