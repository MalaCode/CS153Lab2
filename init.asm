
_init:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	51                   	push   %ecx
    100e:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    1011:	83 ec 08             	sub    $0x8,%esp
    1014:	6a 02                	push   $0x2
    1016:	68 f9 18 00 00       	push   $0x18f9
    101b:	e8 8a 03 00 00       	call   13aa <open>
    1020:	83 c4 10             	add    $0x10,%esp
    1023:	85 c0                	test   %eax,%eax
    1025:	79 26                	jns    104d <main+0x4d>
    mknod("console", 1, 1);
    1027:	83 ec 04             	sub    $0x4,%esp
    102a:	6a 01                	push   $0x1
    102c:	6a 01                	push   $0x1
    102e:	68 f9 18 00 00       	push   $0x18f9
    1033:	e8 7a 03 00 00       	call   13b2 <mknod>
    1038:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
    103b:	83 ec 08             	sub    $0x8,%esp
    103e:	6a 02                	push   $0x2
    1040:	68 f9 18 00 00       	push   $0x18f9
    1045:	e8 60 03 00 00       	call   13aa <open>
    104a:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
    104d:	83 ec 0c             	sub    $0xc,%esp
    1050:	6a 00                	push   $0x0
    1052:	e8 8b 03 00 00       	call   13e2 <dup>
    1057:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
    105a:	83 ec 0c             	sub    $0xc,%esp
    105d:	6a 00                	push   $0x0
    105f:	e8 7e 03 00 00       	call   13e2 <dup>
    1064:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
    1067:	83 ec 08             	sub    $0x8,%esp
    106a:	68 01 19 00 00       	push   $0x1901
    106f:	6a 01                	push   $0x1
    1071:	e8 7b 04 00 00       	call   14f1 <printf>
    1076:	83 c4 10             	add    $0x10,%esp
    pid = fork();
    1079:	e8 e4 02 00 00       	call   1362 <fork>
    107e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
    1081:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1085:	79 17                	jns    109e <main+0x9e>
      printf(1, "init: fork failed\n");
    1087:	83 ec 08             	sub    $0x8,%esp
    108a:	68 14 19 00 00       	push   $0x1914
    108f:	6a 01                	push   $0x1
    1091:	e8 5b 04 00 00       	call   14f1 <printf>
    1096:	83 c4 10             	add    $0x10,%esp
      exit();
    1099:	e8 cc 02 00 00       	call   136a <exit>
    }
    if(pid == 0){
    109e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10a2:	75 50                	jne    10f4 <main+0xf4>
	
	printf(1, "MYINIT\n");
    10a4:	83 ec 08             	sub    $0x8,%esp
    10a7:	68 27 19 00 00       	push   $0x1927
    10ac:	6a 01                	push   $0x1
    10ae:	e8 3e 04 00 00       	call   14f1 <printf>
    10b3:	83 c4 10             	add    $0x10,%esp
	
      exec("sh", argv);
    10b6:	83 ec 08             	sub    $0x8,%esp
    10b9:	68 00 1c 00 00       	push   $0x1c00
    10be:	68 f6 18 00 00       	push   $0x18f6
    10c3:	e8 da 02 00 00       	call   13a2 <exec>
    10c8:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
    10cb:	83 ec 08             	sub    $0x8,%esp
    10ce:	68 2f 19 00 00       	push   $0x192f
    10d3:	6a 01                	push   $0x1
    10d5:	e8 17 04 00 00       	call   14f1 <printf>
    10da:	83 c4 10             	add    $0x10,%esp
      exit();
    10dd:	e8 88 02 00 00       	call   136a <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
    10e2:	83 ec 08             	sub    $0x8,%esp
    10e5:	68 45 19 00 00       	push   $0x1945
    10ea:	6a 01                	push   $0x1
    10ec:	e8 00 04 00 00       	call   14f1 <printf>
    10f1:	83 c4 10             	add    $0x10,%esp
	
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
    10f4:	e8 79 02 00 00       	call   1372 <wait>
    10f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1100:	0f 88 61 ff ff ff    	js     1067 <main+0x67>
    1106:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1109:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    110c:	75 d4                	jne    10e2 <main+0xe2>
      printf(1, "zombie!\n");
  }
    110e:	e9 54 ff ff ff       	jmp    1067 <main+0x67>

00001113 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1113:	55                   	push   %ebp
    1114:	89 e5                	mov    %esp,%ebp
    1116:	57                   	push   %edi
    1117:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1118:	8b 4d 08             	mov    0x8(%ebp),%ecx
    111b:	8b 55 10             	mov    0x10(%ebp),%edx
    111e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1121:	89 cb                	mov    %ecx,%ebx
    1123:	89 df                	mov    %ebx,%edi
    1125:	89 d1                	mov    %edx,%ecx
    1127:	fc                   	cld    
    1128:	f3 aa                	rep stos %al,%es:(%edi)
    112a:	89 ca                	mov    %ecx,%edx
    112c:	89 fb                	mov    %edi,%ebx
    112e:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1131:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1134:	90                   	nop
    1135:	5b                   	pop    %ebx
    1136:	5f                   	pop    %edi
    1137:	5d                   	pop    %ebp
    1138:	c3                   	ret    

00001139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1139:	55                   	push   %ebp
    113a:	89 e5                	mov    %esp,%ebp
    113c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    113f:	8b 45 08             	mov    0x8(%ebp),%eax
    1142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1145:	90                   	nop
    1146:	8b 45 08             	mov    0x8(%ebp),%eax
    1149:	8d 50 01             	lea    0x1(%eax),%edx
    114c:	89 55 08             	mov    %edx,0x8(%ebp)
    114f:	8b 55 0c             	mov    0xc(%ebp),%edx
    1152:	8d 4a 01             	lea    0x1(%edx),%ecx
    1155:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1158:	0f b6 12             	movzbl (%edx),%edx
    115b:	88 10                	mov    %dl,(%eax)
    115d:	0f b6 00             	movzbl (%eax),%eax
    1160:	84 c0                	test   %al,%al
    1162:	75 e2                	jne    1146 <strcpy+0xd>
    ;
  return os;
    1164:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1167:	c9                   	leave  
    1168:	c3                   	ret    

00001169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1169:	55                   	push   %ebp
    116a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    116c:	eb 08                	jmp    1176 <strcmp+0xd>
    p++, q++;
    116e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1172:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1176:	8b 45 08             	mov    0x8(%ebp),%eax
    1179:	0f b6 00             	movzbl (%eax),%eax
    117c:	84 c0                	test   %al,%al
    117e:	74 10                	je     1190 <strcmp+0x27>
    1180:	8b 45 08             	mov    0x8(%ebp),%eax
    1183:	0f b6 10             	movzbl (%eax),%edx
    1186:	8b 45 0c             	mov    0xc(%ebp),%eax
    1189:	0f b6 00             	movzbl (%eax),%eax
    118c:	38 c2                	cmp    %al,%dl
    118e:	74 de                	je     116e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1190:	8b 45 08             	mov    0x8(%ebp),%eax
    1193:	0f b6 00             	movzbl (%eax),%eax
    1196:	0f b6 d0             	movzbl %al,%edx
    1199:	8b 45 0c             	mov    0xc(%ebp),%eax
    119c:	0f b6 00             	movzbl (%eax),%eax
    119f:	0f b6 c0             	movzbl %al,%eax
    11a2:	29 c2                	sub    %eax,%edx
    11a4:	89 d0                	mov    %edx,%eax
}
    11a6:	5d                   	pop    %ebp
    11a7:	c3                   	ret    

000011a8 <strlen>:

uint
strlen(char *s)
{
    11a8:	55                   	push   %ebp
    11a9:	89 e5                	mov    %esp,%ebp
    11ab:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    11ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    11b5:	eb 04                	jmp    11bb <strlen+0x13>
    11b7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    11bb:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11be:	8b 45 08             	mov    0x8(%ebp),%eax
    11c1:	01 d0                	add    %edx,%eax
    11c3:	0f b6 00             	movzbl (%eax),%eax
    11c6:	84 c0                	test   %al,%al
    11c8:	75 ed                	jne    11b7 <strlen+0xf>
    ;
  return n;
    11ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11cd:	c9                   	leave  
    11ce:	c3                   	ret    

000011cf <memset>:

void*
memset(void *dst, int c, uint n)
{
    11cf:	55                   	push   %ebp
    11d0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    11d2:	8b 45 10             	mov    0x10(%ebp),%eax
    11d5:	50                   	push   %eax
    11d6:	ff 75 0c             	pushl  0xc(%ebp)
    11d9:	ff 75 08             	pushl  0x8(%ebp)
    11dc:	e8 32 ff ff ff       	call   1113 <stosb>
    11e1:	83 c4 0c             	add    $0xc,%esp
  return dst;
    11e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11e7:	c9                   	leave  
    11e8:	c3                   	ret    

000011e9 <strchr>:

char*
strchr(const char *s, char c)
{
    11e9:	55                   	push   %ebp
    11ea:	89 e5                	mov    %esp,%ebp
    11ec:	83 ec 04             	sub    $0x4,%esp
    11ef:	8b 45 0c             	mov    0xc(%ebp),%eax
    11f2:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    11f5:	eb 14                	jmp    120b <strchr+0x22>
    if(*s == c)
    11f7:	8b 45 08             	mov    0x8(%ebp),%eax
    11fa:	0f b6 00             	movzbl (%eax),%eax
    11fd:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1200:	75 05                	jne    1207 <strchr+0x1e>
      return (char*)s;
    1202:	8b 45 08             	mov    0x8(%ebp),%eax
    1205:	eb 13                	jmp    121a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1207:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    120b:	8b 45 08             	mov    0x8(%ebp),%eax
    120e:	0f b6 00             	movzbl (%eax),%eax
    1211:	84 c0                	test   %al,%al
    1213:	75 e2                	jne    11f7 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1215:	b8 00 00 00 00       	mov    $0x0,%eax
}
    121a:	c9                   	leave  
    121b:	c3                   	ret    

0000121c <gets>:

char*
gets(char *buf, int max)
{
    121c:	55                   	push   %ebp
    121d:	89 e5                	mov    %esp,%ebp
    121f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1222:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1229:	eb 42                	jmp    126d <gets+0x51>
    cc = read(0, &c, 1);
    122b:	83 ec 04             	sub    $0x4,%esp
    122e:	6a 01                	push   $0x1
    1230:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1233:	50                   	push   %eax
    1234:	6a 00                	push   $0x0
    1236:	e8 47 01 00 00       	call   1382 <read>
    123b:	83 c4 10             	add    $0x10,%esp
    123e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1241:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1245:	7e 33                	jle    127a <gets+0x5e>
      break;
    buf[i++] = c;
    1247:	8b 45 f4             	mov    -0xc(%ebp),%eax
    124a:	8d 50 01             	lea    0x1(%eax),%edx
    124d:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1250:	89 c2                	mov    %eax,%edx
    1252:	8b 45 08             	mov    0x8(%ebp),%eax
    1255:	01 c2                	add    %eax,%edx
    1257:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    125b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    125d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1261:	3c 0a                	cmp    $0xa,%al
    1263:	74 16                	je     127b <gets+0x5f>
    1265:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1269:	3c 0d                	cmp    $0xd,%al
    126b:	74 0e                	je     127b <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    126d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1270:	83 c0 01             	add    $0x1,%eax
    1273:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1276:	7c b3                	jl     122b <gets+0xf>
    1278:	eb 01                	jmp    127b <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    127a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    127b:	8b 55 f4             	mov    -0xc(%ebp),%edx
    127e:	8b 45 08             	mov    0x8(%ebp),%eax
    1281:	01 d0                	add    %edx,%eax
    1283:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1286:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1289:	c9                   	leave  
    128a:	c3                   	ret    

0000128b <stat>:

int
stat(char *n, struct stat *st)
{
    128b:	55                   	push   %ebp
    128c:	89 e5                	mov    %esp,%ebp
    128e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1291:	83 ec 08             	sub    $0x8,%esp
    1294:	6a 00                	push   $0x0
    1296:	ff 75 08             	pushl  0x8(%ebp)
    1299:	e8 0c 01 00 00       	call   13aa <open>
    129e:	83 c4 10             	add    $0x10,%esp
    12a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    12a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12a8:	79 07                	jns    12b1 <stat+0x26>
    return -1;
    12aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    12af:	eb 25                	jmp    12d6 <stat+0x4b>
  r = fstat(fd, st);
    12b1:	83 ec 08             	sub    $0x8,%esp
    12b4:	ff 75 0c             	pushl  0xc(%ebp)
    12b7:	ff 75 f4             	pushl  -0xc(%ebp)
    12ba:	e8 03 01 00 00       	call   13c2 <fstat>
    12bf:	83 c4 10             	add    $0x10,%esp
    12c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    12c5:	83 ec 0c             	sub    $0xc,%esp
    12c8:	ff 75 f4             	pushl  -0xc(%ebp)
    12cb:	e8 c2 00 00 00       	call   1392 <close>
    12d0:	83 c4 10             	add    $0x10,%esp
  return r;
    12d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    12d6:	c9                   	leave  
    12d7:	c3                   	ret    

000012d8 <atoi>:

int
atoi(const char *s)
{
    12d8:	55                   	push   %ebp
    12d9:	89 e5                	mov    %esp,%ebp
    12db:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    12de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    12e5:	eb 25                	jmp    130c <atoi+0x34>
    n = n*10 + *s++ - '0';
    12e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
    12ea:	89 d0                	mov    %edx,%eax
    12ec:	c1 e0 02             	shl    $0x2,%eax
    12ef:	01 d0                	add    %edx,%eax
    12f1:	01 c0                	add    %eax,%eax
    12f3:	89 c1                	mov    %eax,%ecx
    12f5:	8b 45 08             	mov    0x8(%ebp),%eax
    12f8:	8d 50 01             	lea    0x1(%eax),%edx
    12fb:	89 55 08             	mov    %edx,0x8(%ebp)
    12fe:	0f b6 00             	movzbl (%eax),%eax
    1301:	0f be c0             	movsbl %al,%eax
    1304:	01 c8                	add    %ecx,%eax
    1306:	83 e8 30             	sub    $0x30,%eax
    1309:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    130c:	8b 45 08             	mov    0x8(%ebp),%eax
    130f:	0f b6 00             	movzbl (%eax),%eax
    1312:	3c 2f                	cmp    $0x2f,%al
    1314:	7e 0a                	jle    1320 <atoi+0x48>
    1316:	8b 45 08             	mov    0x8(%ebp),%eax
    1319:	0f b6 00             	movzbl (%eax),%eax
    131c:	3c 39                	cmp    $0x39,%al
    131e:	7e c7                	jle    12e7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1320:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1323:	c9                   	leave  
    1324:	c3                   	ret    

00001325 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1325:	55                   	push   %ebp
    1326:	89 e5                	mov    %esp,%ebp
    1328:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    132b:	8b 45 08             	mov    0x8(%ebp),%eax
    132e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1331:	8b 45 0c             	mov    0xc(%ebp),%eax
    1334:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1337:	eb 17                	jmp    1350 <memmove+0x2b>
    *dst++ = *src++;
    1339:	8b 45 fc             	mov    -0x4(%ebp),%eax
    133c:	8d 50 01             	lea    0x1(%eax),%edx
    133f:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1342:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1345:	8d 4a 01             	lea    0x1(%edx),%ecx
    1348:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    134b:	0f b6 12             	movzbl (%edx),%edx
    134e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1350:	8b 45 10             	mov    0x10(%ebp),%eax
    1353:	8d 50 ff             	lea    -0x1(%eax),%edx
    1356:	89 55 10             	mov    %edx,0x10(%ebp)
    1359:	85 c0                	test   %eax,%eax
    135b:	7f dc                	jg     1339 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    135d:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1360:	c9                   	leave  
    1361:	c3                   	ret    

00001362 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1362:	b8 01 00 00 00       	mov    $0x1,%eax
    1367:	cd 40                	int    $0x40
    1369:	c3                   	ret    

0000136a <exit>:
SYSCALL(exit)
    136a:	b8 02 00 00 00       	mov    $0x2,%eax
    136f:	cd 40                	int    $0x40
    1371:	c3                   	ret    

00001372 <wait>:
SYSCALL(wait)
    1372:	b8 03 00 00 00       	mov    $0x3,%eax
    1377:	cd 40                	int    $0x40
    1379:	c3                   	ret    

0000137a <pipe>:
SYSCALL(pipe)
    137a:	b8 04 00 00 00       	mov    $0x4,%eax
    137f:	cd 40                	int    $0x40
    1381:	c3                   	ret    

00001382 <read>:
SYSCALL(read)
    1382:	b8 05 00 00 00       	mov    $0x5,%eax
    1387:	cd 40                	int    $0x40
    1389:	c3                   	ret    

0000138a <write>:
SYSCALL(write)
    138a:	b8 10 00 00 00       	mov    $0x10,%eax
    138f:	cd 40                	int    $0x40
    1391:	c3                   	ret    

00001392 <close>:
SYSCALL(close)
    1392:	b8 15 00 00 00       	mov    $0x15,%eax
    1397:	cd 40                	int    $0x40
    1399:	c3                   	ret    

0000139a <kill>:
SYSCALL(kill)
    139a:	b8 06 00 00 00       	mov    $0x6,%eax
    139f:	cd 40                	int    $0x40
    13a1:	c3                   	ret    

000013a2 <exec>:
SYSCALL(exec)
    13a2:	b8 07 00 00 00       	mov    $0x7,%eax
    13a7:	cd 40                	int    $0x40
    13a9:	c3                   	ret    

000013aa <open>:
SYSCALL(open)
    13aa:	b8 0f 00 00 00       	mov    $0xf,%eax
    13af:	cd 40                	int    $0x40
    13b1:	c3                   	ret    

000013b2 <mknod>:
SYSCALL(mknod)
    13b2:	b8 11 00 00 00       	mov    $0x11,%eax
    13b7:	cd 40                	int    $0x40
    13b9:	c3                   	ret    

000013ba <unlink>:
SYSCALL(unlink)
    13ba:	b8 12 00 00 00       	mov    $0x12,%eax
    13bf:	cd 40                	int    $0x40
    13c1:	c3                   	ret    

000013c2 <fstat>:
SYSCALL(fstat)
    13c2:	b8 08 00 00 00       	mov    $0x8,%eax
    13c7:	cd 40                	int    $0x40
    13c9:	c3                   	ret    

000013ca <link>:
SYSCALL(link)
    13ca:	b8 13 00 00 00       	mov    $0x13,%eax
    13cf:	cd 40                	int    $0x40
    13d1:	c3                   	ret    

000013d2 <mkdir>:
SYSCALL(mkdir)
    13d2:	b8 14 00 00 00       	mov    $0x14,%eax
    13d7:	cd 40                	int    $0x40
    13d9:	c3                   	ret    

000013da <chdir>:
SYSCALL(chdir)
    13da:	b8 09 00 00 00       	mov    $0x9,%eax
    13df:	cd 40                	int    $0x40
    13e1:	c3                   	ret    

000013e2 <dup>:
SYSCALL(dup)
    13e2:	b8 0a 00 00 00       	mov    $0xa,%eax
    13e7:	cd 40                	int    $0x40
    13e9:	c3                   	ret    

000013ea <getpid>:
SYSCALL(getpid)
    13ea:	b8 0b 00 00 00       	mov    $0xb,%eax
    13ef:	cd 40                	int    $0x40
    13f1:	c3                   	ret    

000013f2 <sbrk>:
SYSCALL(sbrk)
    13f2:	b8 0c 00 00 00       	mov    $0xc,%eax
    13f7:	cd 40                	int    $0x40
    13f9:	c3                   	ret    

000013fa <sleep>:
SYSCALL(sleep)
    13fa:	b8 0d 00 00 00       	mov    $0xd,%eax
    13ff:	cd 40                	int    $0x40
    1401:	c3                   	ret    

00001402 <uptime>:
SYSCALL(uptime)
    1402:	b8 0e 00 00 00       	mov    $0xe,%eax
    1407:	cd 40                	int    $0x40
    1409:	c3                   	ret    

0000140a <shm_open>:
SYSCALL(shm_open)
    140a:	b8 16 00 00 00       	mov    $0x16,%eax
    140f:	cd 40                	int    $0x40
    1411:	c3                   	ret    

00001412 <shm_close>:
SYSCALL(shm_close)	
    1412:	b8 17 00 00 00       	mov    $0x17,%eax
    1417:	cd 40                	int    $0x40
    1419:	c3                   	ret    

0000141a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    141a:	55                   	push   %ebp
    141b:	89 e5                	mov    %esp,%ebp
    141d:	83 ec 18             	sub    $0x18,%esp
    1420:	8b 45 0c             	mov    0xc(%ebp),%eax
    1423:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1426:	83 ec 04             	sub    $0x4,%esp
    1429:	6a 01                	push   $0x1
    142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
    142e:	50                   	push   %eax
    142f:	ff 75 08             	pushl  0x8(%ebp)
    1432:	e8 53 ff ff ff       	call   138a <write>
    1437:	83 c4 10             	add    $0x10,%esp
}
    143a:	90                   	nop
    143b:	c9                   	leave  
    143c:	c3                   	ret    

0000143d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    143d:	55                   	push   %ebp
    143e:	89 e5                	mov    %esp,%ebp
    1440:	53                   	push   %ebx
    1441:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1444:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    144b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    144f:	74 17                	je     1468 <printint+0x2b>
    1451:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1455:	79 11                	jns    1468 <printint+0x2b>
    neg = 1;
    1457:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    145e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1461:	f7 d8                	neg    %eax
    1463:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1466:	eb 06                	jmp    146e <printint+0x31>
  } else {
    x = xx;
    1468:	8b 45 0c             	mov    0xc(%ebp),%eax
    146b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    146e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1475:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1478:	8d 41 01             	lea    0x1(%ecx),%eax
    147b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    147e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1481:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1484:	ba 00 00 00 00       	mov    $0x0,%edx
    1489:	f7 f3                	div    %ebx
    148b:	89 d0                	mov    %edx,%eax
    148d:	0f b6 80 08 1c 00 00 	movzbl 0x1c08(%eax),%eax
    1494:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1498:	8b 5d 10             	mov    0x10(%ebp),%ebx
    149b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    149e:	ba 00 00 00 00       	mov    $0x0,%edx
    14a3:	f7 f3                	div    %ebx
    14a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    14a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14ac:	75 c7                	jne    1475 <printint+0x38>
  if(neg)
    14ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14b2:	74 2d                	je     14e1 <printint+0xa4>
    buf[i++] = '-';
    14b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b7:	8d 50 01             	lea    0x1(%eax),%edx
    14ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
    14bd:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    14c2:	eb 1d                	jmp    14e1 <printint+0xa4>
    putc(fd, buf[i]);
    14c4:	8d 55 dc             	lea    -0x24(%ebp),%edx
    14c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ca:	01 d0                	add    %edx,%eax
    14cc:	0f b6 00             	movzbl (%eax),%eax
    14cf:	0f be c0             	movsbl %al,%eax
    14d2:	83 ec 08             	sub    $0x8,%esp
    14d5:	50                   	push   %eax
    14d6:	ff 75 08             	pushl  0x8(%ebp)
    14d9:	e8 3c ff ff ff       	call   141a <putc>
    14de:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    14e1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14e9:	79 d9                	jns    14c4 <printint+0x87>
    putc(fd, buf[i]);
}
    14eb:	90                   	nop
    14ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    14ef:	c9                   	leave  
    14f0:	c3                   	ret    

000014f1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    14f1:	55                   	push   %ebp
    14f2:	89 e5                	mov    %esp,%ebp
    14f4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    14f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14fe:	8d 45 0c             	lea    0xc(%ebp),%eax
    1501:	83 c0 04             	add    $0x4,%eax
    1504:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1507:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    150e:	e9 59 01 00 00       	jmp    166c <printf+0x17b>
    c = fmt[i] & 0xff;
    1513:	8b 55 0c             	mov    0xc(%ebp),%edx
    1516:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1519:	01 d0                	add    %edx,%eax
    151b:	0f b6 00             	movzbl (%eax),%eax
    151e:	0f be c0             	movsbl %al,%eax
    1521:	25 ff 00 00 00       	and    $0xff,%eax
    1526:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1529:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    152d:	75 2c                	jne    155b <printf+0x6a>
      if(c == '%'){
    152f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1533:	75 0c                	jne    1541 <printf+0x50>
        state = '%';
    1535:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    153c:	e9 27 01 00 00       	jmp    1668 <printf+0x177>
      } else {
        putc(fd, c);
    1541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1544:	0f be c0             	movsbl %al,%eax
    1547:	83 ec 08             	sub    $0x8,%esp
    154a:	50                   	push   %eax
    154b:	ff 75 08             	pushl  0x8(%ebp)
    154e:	e8 c7 fe ff ff       	call   141a <putc>
    1553:	83 c4 10             	add    $0x10,%esp
    1556:	e9 0d 01 00 00       	jmp    1668 <printf+0x177>
      }
    } else if(state == '%'){
    155b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    155f:	0f 85 03 01 00 00    	jne    1668 <printf+0x177>
      if(c == 'd'){
    1565:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1569:	75 1e                	jne    1589 <printf+0x98>
        printint(fd, *ap, 10, 1);
    156b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    156e:	8b 00                	mov    (%eax),%eax
    1570:	6a 01                	push   $0x1
    1572:	6a 0a                	push   $0xa
    1574:	50                   	push   %eax
    1575:	ff 75 08             	pushl  0x8(%ebp)
    1578:	e8 c0 fe ff ff       	call   143d <printint>
    157d:	83 c4 10             	add    $0x10,%esp
        ap++;
    1580:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1584:	e9 d8 00 00 00       	jmp    1661 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1589:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    158d:	74 06                	je     1595 <printf+0xa4>
    158f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1593:	75 1e                	jne    15b3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1595:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1598:	8b 00                	mov    (%eax),%eax
    159a:	6a 00                	push   $0x0
    159c:	6a 10                	push   $0x10
    159e:	50                   	push   %eax
    159f:	ff 75 08             	pushl  0x8(%ebp)
    15a2:	e8 96 fe ff ff       	call   143d <printint>
    15a7:	83 c4 10             	add    $0x10,%esp
        ap++;
    15aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15ae:	e9 ae 00 00 00       	jmp    1661 <printf+0x170>
      } else if(c == 's'){
    15b3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    15b7:	75 43                	jne    15fc <printf+0x10b>
        s = (char*)*ap;
    15b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15bc:	8b 00                	mov    (%eax),%eax
    15be:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    15c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    15c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15c9:	75 25                	jne    15f0 <printf+0xff>
          s = "(null)";
    15cb:	c7 45 f4 4e 19 00 00 	movl   $0x194e,-0xc(%ebp)
        while(*s != 0){
    15d2:	eb 1c                	jmp    15f0 <printf+0xff>
          putc(fd, *s);
    15d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15d7:	0f b6 00             	movzbl (%eax),%eax
    15da:	0f be c0             	movsbl %al,%eax
    15dd:	83 ec 08             	sub    $0x8,%esp
    15e0:	50                   	push   %eax
    15e1:	ff 75 08             	pushl  0x8(%ebp)
    15e4:	e8 31 fe ff ff       	call   141a <putc>
    15e9:	83 c4 10             	add    $0x10,%esp
          s++;
    15ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    15f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15f3:	0f b6 00             	movzbl (%eax),%eax
    15f6:	84 c0                	test   %al,%al
    15f8:	75 da                	jne    15d4 <printf+0xe3>
    15fa:	eb 65                	jmp    1661 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15fc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1600:	75 1d                	jne    161f <printf+0x12e>
        putc(fd, *ap);
    1602:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1605:	8b 00                	mov    (%eax),%eax
    1607:	0f be c0             	movsbl %al,%eax
    160a:	83 ec 08             	sub    $0x8,%esp
    160d:	50                   	push   %eax
    160e:	ff 75 08             	pushl  0x8(%ebp)
    1611:	e8 04 fe ff ff       	call   141a <putc>
    1616:	83 c4 10             	add    $0x10,%esp
        ap++;
    1619:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    161d:	eb 42                	jmp    1661 <printf+0x170>
      } else if(c == '%'){
    161f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1623:	75 17                	jne    163c <printf+0x14b>
        putc(fd, c);
    1625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1628:	0f be c0             	movsbl %al,%eax
    162b:	83 ec 08             	sub    $0x8,%esp
    162e:	50                   	push   %eax
    162f:	ff 75 08             	pushl  0x8(%ebp)
    1632:	e8 e3 fd ff ff       	call   141a <putc>
    1637:	83 c4 10             	add    $0x10,%esp
    163a:	eb 25                	jmp    1661 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    163c:	83 ec 08             	sub    $0x8,%esp
    163f:	6a 25                	push   $0x25
    1641:	ff 75 08             	pushl  0x8(%ebp)
    1644:	e8 d1 fd ff ff       	call   141a <putc>
    1649:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    164c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    164f:	0f be c0             	movsbl %al,%eax
    1652:	83 ec 08             	sub    $0x8,%esp
    1655:	50                   	push   %eax
    1656:	ff 75 08             	pushl  0x8(%ebp)
    1659:	e8 bc fd ff ff       	call   141a <putc>
    165e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    1661:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1668:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    166c:	8b 55 0c             	mov    0xc(%ebp),%edx
    166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1672:	01 d0                	add    %edx,%eax
    1674:	0f b6 00             	movzbl (%eax),%eax
    1677:	84 c0                	test   %al,%al
    1679:	0f 85 94 fe ff ff    	jne    1513 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    167f:	90                   	nop
    1680:	c9                   	leave  
    1681:	c3                   	ret    

00001682 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1682:	55                   	push   %ebp
    1683:	89 e5                	mov    %esp,%ebp
    1685:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1688:	8b 45 08             	mov    0x8(%ebp),%eax
    168b:	83 e8 08             	sub    $0x8,%eax
    168e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1691:	a1 24 1c 00 00       	mov    0x1c24,%eax
    1696:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1699:	eb 24                	jmp    16bf <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    169b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169e:	8b 00                	mov    (%eax),%eax
    16a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16a3:	77 12                	ja     16b7 <free+0x35>
    16a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16ab:	77 24                	ja     16d1 <free+0x4f>
    16ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b0:	8b 00                	mov    (%eax),%eax
    16b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16b5:	77 1a                	ja     16d1 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ba:	8b 00                	mov    (%eax),%eax
    16bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16c5:	76 d4                	jbe    169b <free+0x19>
    16c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ca:	8b 00                	mov    (%eax),%eax
    16cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16cf:	76 ca                	jbe    169b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16d4:	8b 40 04             	mov    0x4(%eax),%eax
    16d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16de:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16e1:	01 c2                	add    %eax,%edx
    16e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e6:	8b 00                	mov    (%eax),%eax
    16e8:	39 c2                	cmp    %eax,%edx
    16ea:	75 24                	jne    1710 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    16ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ef:	8b 50 04             	mov    0x4(%eax),%edx
    16f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f5:	8b 00                	mov    (%eax),%eax
    16f7:	8b 40 04             	mov    0x4(%eax),%eax
    16fa:	01 c2                	add    %eax,%edx
    16fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ff:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1702:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1705:	8b 00                	mov    (%eax),%eax
    1707:	8b 10                	mov    (%eax),%edx
    1709:	8b 45 f8             	mov    -0x8(%ebp),%eax
    170c:	89 10                	mov    %edx,(%eax)
    170e:	eb 0a                	jmp    171a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1710:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1713:	8b 10                	mov    (%eax),%edx
    1715:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1718:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    171a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    171d:	8b 40 04             	mov    0x4(%eax),%eax
    1720:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1727:	8b 45 fc             	mov    -0x4(%ebp),%eax
    172a:	01 d0                	add    %edx,%eax
    172c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    172f:	75 20                	jne    1751 <free+0xcf>
    p->s.size += bp->s.size;
    1731:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1734:	8b 50 04             	mov    0x4(%eax),%edx
    1737:	8b 45 f8             	mov    -0x8(%ebp),%eax
    173a:	8b 40 04             	mov    0x4(%eax),%eax
    173d:	01 c2                	add    %eax,%edx
    173f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1742:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1745:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1748:	8b 10                	mov    (%eax),%edx
    174a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    174d:	89 10                	mov    %edx,(%eax)
    174f:	eb 08                	jmp    1759 <free+0xd7>
  } else
    p->s.ptr = bp;
    1751:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1754:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1757:	89 10                	mov    %edx,(%eax)
  freep = p;
    1759:	8b 45 fc             	mov    -0x4(%ebp),%eax
    175c:	a3 24 1c 00 00       	mov    %eax,0x1c24
}
    1761:	90                   	nop
    1762:	c9                   	leave  
    1763:	c3                   	ret    

00001764 <morecore>:

static Header*
morecore(uint nu)
{
    1764:	55                   	push   %ebp
    1765:	89 e5                	mov    %esp,%ebp
    1767:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    176a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1771:	77 07                	ja     177a <morecore+0x16>
    nu = 4096;
    1773:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    177a:	8b 45 08             	mov    0x8(%ebp),%eax
    177d:	c1 e0 03             	shl    $0x3,%eax
    1780:	83 ec 0c             	sub    $0xc,%esp
    1783:	50                   	push   %eax
    1784:	e8 69 fc ff ff       	call   13f2 <sbrk>
    1789:	83 c4 10             	add    $0x10,%esp
    178c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    178f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1793:	75 07                	jne    179c <morecore+0x38>
    return 0;
    1795:	b8 00 00 00 00       	mov    $0x0,%eax
    179a:	eb 26                	jmp    17c2 <morecore+0x5e>
  hp = (Header*)p;
    179c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    179f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    17a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17a5:	8b 55 08             	mov    0x8(%ebp),%edx
    17a8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    17ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ae:	83 c0 08             	add    $0x8,%eax
    17b1:	83 ec 0c             	sub    $0xc,%esp
    17b4:	50                   	push   %eax
    17b5:	e8 c8 fe ff ff       	call   1682 <free>
    17ba:	83 c4 10             	add    $0x10,%esp
  return freep;
    17bd:	a1 24 1c 00 00       	mov    0x1c24,%eax
}
    17c2:	c9                   	leave  
    17c3:	c3                   	ret    

000017c4 <malloc>:

void*
malloc(uint nbytes)
{
    17c4:	55                   	push   %ebp
    17c5:	89 e5                	mov    %esp,%ebp
    17c7:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    17ca:	8b 45 08             	mov    0x8(%ebp),%eax
    17cd:	83 c0 07             	add    $0x7,%eax
    17d0:	c1 e8 03             	shr    $0x3,%eax
    17d3:	83 c0 01             	add    $0x1,%eax
    17d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17d9:	a1 24 1c 00 00       	mov    0x1c24,%eax
    17de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17e5:	75 23                	jne    180a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17e7:	c7 45 f0 1c 1c 00 00 	movl   $0x1c1c,-0x10(%ebp)
    17ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17f1:	a3 24 1c 00 00       	mov    %eax,0x1c24
    17f6:	a1 24 1c 00 00       	mov    0x1c24,%eax
    17fb:	a3 1c 1c 00 00       	mov    %eax,0x1c1c
    base.s.size = 0;
    1800:	c7 05 20 1c 00 00 00 	movl   $0x0,0x1c20
    1807:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    180d:	8b 00                	mov    (%eax),%eax
    180f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1812:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1815:	8b 40 04             	mov    0x4(%eax),%eax
    1818:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    181b:	72 4d                	jb     186a <malloc+0xa6>
      if(p->s.size == nunits)
    181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1820:	8b 40 04             	mov    0x4(%eax),%eax
    1823:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1826:	75 0c                	jne    1834 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1828:	8b 45 f4             	mov    -0xc(%ebp),%eax
    182b:	8b 10                	mov    (%eax),%edx
    182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1830:	89 10                	mov    %edx,(%eax)
    1832:	eb 26                	jmp    185a <malloc+0x96>
      else {
        p->s.size -= nunits;
    1834:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1837:	8b 40 04             	mov    0x4(%eax),%eax
    183a:	2b 45 ec             	sub    -0x14(%ebp),%eax
    183d:	89 c2                	mov    %eax,%edx
    183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1842:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1845:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1848:	8b 40 04             	mov    0x4(%eax),%eax
    184b:	c1 e0 03             	shl    $0x3,%eax
    184e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1851:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1854:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1857:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    185d:	a3 24 1c 00 00       	mov    %eax,0x1c24
      return (void*)(p + 1);
    1862:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1865:	83 c0 08             	add    $0x8,%eax
    1868:	eb 3b                	jmp    18a5 <malloc+0xe1>
    }
    if(p == freep)
    186a:	a1 24 1c 00 00       	mov    0x1c24,%eax
    186f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1872:	75 1e                	jne    1892 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    1874:	83 ec 0c             	sub    $0xc,%esp
    1877:	ff 75 ec             	pushl  -0x14(%ebp)
    187a:	e8 e5 fe ff ff       	call   1764 <morecore>
    187f:	83 c4 10             	add    $0x10,%esp
    1882:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1885:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1889:	75 07                	jne    1892 <malloc+0xce>
        return 0;
    188b:	b8 00 00 00 00       	mov    $0x0,%eax
    1890:	eb 13                	jmp    18a5 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1892:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1895:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1898:	8b 45 f4             	mov    -0xc(%ebp),%eax
    189b:	8b 00                	mov    (%eax),%eax
    189d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    18a0:	e9 6d ff ff ff       	jmp    1812 <malloc+0x4e>
}
    18a5:	c9                   	leave  
    18a6:	c3                   	ret    

000018a7 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    18a7:	55                   	push   %ebp
    18a8:	89 e5                	mov    %esp,%ebp
    18aa:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    18ad:	8b 55 08             	mov    0x8(%ebp),%edx
    18b0:	8b 45 0c             	mov    0xc(%ebp),%eax
    18b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
    18b6:	f0 87 02             	lock xchg %eax,(%edx)
    18b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    18bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    18bf:	c9                   	leave  
    18c0:	c3                   	ret    

000018c1 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    18c1:	55                   	push   %ebp
    18c2:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    18c4:	90                   	nop
    18c5:	8b 45 08             	mov    0x8(%ebp),%eax
    18c8:	6a 01                	push   $0x1
    18ca:	50                   	push   %eax
    18cb:	e8 d7 ff ff ff       	call   18a7 <xchg>
    18d0:	83 c4 08             	add    $0x8,%esp
    18d3:	85 c0                	test   %eax,%eax
    18d5:	75 ee                	jne    18c5 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    18d7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    18dc:	90                   	nop
    18dd:	c9                   	leave  
    18de:	c3                   	ret    

000018df <urelease>:

void urelease (struct uspinlock *lk) {
    18df:	55                   	push   %ebp
    18e0:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    18e2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    18e7:	8b 45 08             	mov    0x8(%ebp),%eax
    18ea:	8b 55 08             	mov    0x8(%ebp),%edx
    18ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    18f3:	90                   	nop
    18f4:	5d                   	pop    %ebp
    18f5:	c3                   	ret    
