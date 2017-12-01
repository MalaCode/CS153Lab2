
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
    1016:	68 e7 18 00 00       	push   $0x18e7
    101b:	e8 78 03 00 00       	call   1398 <open>
    1020:	83 c4 10             	add    $0x10,%esp
    1023:	85 c0                	test   %eax,%eax
    1025:	79 26                	jns    104d <main+0x4d>
    mknod("console", 1, 1);
    1027:	83 ec 04             	sub    $0x4,%esp
    102a:	6a 01                	push   $0x1
    102c:	6a 01                	push   $0x1
    102e:	68 e7 18 00 00       	push   $0x18e7
    1033:	e8 68 03 00 00       	call   13a0 <mknod>
    1038:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
    103b:	83 ec 08             	sub    $0x8,%esp
    103e:	6a 02                	push   $0x2
    1040:	68 e7 18 00 00       	push   $0x18e7
    1045:	e8 4e 03 00 00       	call   1398 <open>
    104a:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
    104d:	83 ec 0c             	sub    $0xc,%esp
    1050:	6a 00                	push   $0x0
    1052:	e8 79 03 00 00       	call   13d0 <dup>
    1057:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
    105a:	83 ec 0c             	sub    $0xc,%esp
    105d:	6a 00                	push   $0x0
    105f:	e8 6c 03 00 00       	call   13d0 <dup>
    1064:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
    1067:	83 ec 08             	sub    $0x8,%esp
    106a:	68 ef 18 00 00       	push   $0x18ef
    106f:	6a 01                	push   $0x1
    1071:	e8 69 04 00 00       	call   14df <printf>
    1076:	83 c4 10             	add    $0x10,%esp
    pid = fork();
    1079:	e8 d2 02 00 00       	call   1350 <fork>
    107e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
    1081:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1085:	79 17                	jns    109e <main+0x9e>
      printf(1, "init: fork failed\n");
    1087:	83 ec 08             	sub    $0x8,%esp
    108a:	68 02 19 00 00       	push   $0x1902
    108f:	6a 01                	push   $0x1
    1091:	e8 49 04 00 00       	call   14df <printf>
    1096:	83 c4 10             	add    $0x10,%esp
      exit();
    1099:	e8 ba 02 00 00       	call   1358 <exit>
    }
    if(pid == 0){
    109e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10a2:	75 3e                	jne    10e2 <main+0xe2>
	
//	printf(1, "MYINIT\n");
	
      exec("sh", argv);
    10a4:	83 ec 08             	sub    $0x8,%esp
    10a7:	68 e4 1b 00 00       	push   $0x1be4
    10ac:	68 e4 18 00 00       	push   $0x18e4
    10b1:	e8 da 02 00 00       	call   1390 <exec>
    10b6:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
    10b9:	83 ec 08             	sub    $0x8,%esp
    10bc:	68 15 19 00 00       	push   $0x1915
    10c1:	6a 01                	push   $0x1
    10c3:	e8 17 04 00 00       	call   14df <printf>
    10c8:	83 c4 10             	add    $0x10,%esp
      exit();
    10cb:	e8 88 02 00 00       	call   1358 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
    10d0:	83 ec 08             	sub    $0x8,%esp
    10d3:	68 2b 19 00 00       	push   $0x192b
    10d8:	6a 01                	push   $0x1
    10da:	e8 00 04 00 00       	call   14df <printf>
    10df:	83 c4 10             	add    $0x10,%esp
	
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
    10e2:	e8 79 02 00 00       	call   1360 <wait>
    10e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    10ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10ee:	0f 88 73 ff ff ff    	js     1067 <main+0x67>
    10f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10f7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    10fa:	75 d4                	jne    10d0 <main+0xd0>
      printf(1, "zombie!\n");
  }
    10fc:	e9 66 ff ff ff       	jmp    1067 <main+0x67>

00001101 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1101:	55                   	push   %ebp
    1102:	89 e5                	mov    %esp,%ebp
    1104:	57                   	push   %edi
    1105:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1106:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1109:	8b 55 10             	mov    0x10(%ebp),%edx
    110c:	8b 45 0c             	mov    0xc(%ebp),%eax
    110f:	89 cb                	mov    %ecx,%ebx
    1111:	89 df                	mov    %ebx,%edi
    1113:	89 d1                	mov    %edx,%ecx
    1115:	fc                   	cld    
    1116:	f3 aa                	rep stos %al,%es:(%edi)
    1118:	89 ca                	mov    %ecx,%edx
    111a:	89 fb                	mov    %edi,%ebx
    111c:	89 5d 08             	mov    %ebx,0x8(%ebp)
    111f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1122:	90                   	nop
    1123:	5b                   	pop    %ebx
    1124:	5f                   	pop    %edi
    1125:	5d                   	pop    %ebp
    1126:	c3                   	ret    

00001127 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1127:	55                   	push   %ebp
    1128:	89 e5                	mov    %esp,%ebp
    112a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    112d:	8b 45 08             	mov    0x8(%ebp),%eax
    1130:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1133:	90                   	nop
    1134:	8b 45 08             	mov    0x8(%ebp),%eax
    1137:	8d 50 01             	lea    0x1(%eax),%edx
    113a:	89 55 08             	mov    %edx,0x8(%ebp)
    113d:	8b 55 0c             	mov    0xc(%ebp),%edx
    1140:	8d 4a 01             	lea    0x1(%edx),%ecx
    1143:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1146:	0f b6 12             	movzbl (%edx),%edx
    1149:	88 10                	mov    %dl,(%eax)
    114b:	0f b6 00             	movzbl (%eax),%eax
    114e:	84 c0                	test   %al,%al
    1150:	75 e2                	jne    1134 <strcpy+0xd>
    ;
  return os;
    1152:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1155:	c9                   	leave  
    1156:	c3                   	ret    

00001157 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1157:	55                   	push   %ebp
    1158:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    115a:	eb 08                	jmp    1164 <strcmp+0xd>
    p++, q++;
    115c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1160:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1164:	8b 45 08             	mov    0x8(%ebp),%eax
    1167:	0f b6 00             	movzbl (%eax),%eax
    116a:	84 c0                	test   %al,%al
    116c:	74 10                	je     117e <strcmp+0x27>
    116e:	8b 45 08             	mov    0x8(%ebp),%eax
    1171:	0f b6 10             	movzbl (%eax),%edx
    1174:	8b 45 0c             	mov    0xc(%ebp),%eax
    1177:	0f b6 00             	movzbl (%eax),%eax
    117a:	38 c2                	cmp    %al,%dl
    117c:	74 de                	je     115c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    117e:	8b 45 08             	mov    0x8(%ebp),%eax
    1181:	0f b6 00             	movzbl (%eax),%eax
    1184:	0f b6 d0             	movzbl %al,%edx
    1187:	8b 45 0c             	mov    0xc(%ebp),%eax
    118a:	0f b6 00             	movzbl (%eax),%eax
    118d:	0f b6 c0             	movzbl %al,%eax
    1190:	29 c2                	sub    %eax,%edx
    1192:	89 d0                	mov    %edx,%eax
}
    1194:	5d                   	pop    %ebp
    1195:	c3                   	ret    

00001196 <strlen>:

uint
strlen(char *s)
{
    1196:	55                   	push   %ebp
    1197:	89 e5                	mov    %esp,%ebp
    1199:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    119c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    11a3:	eb 04                	jmp    11a9 <strlen+0x13>
    11a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    11a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11ac:	8b 45 08             	mov    0x8(%ebp),%eax
    11af:	01 d0                	add    %edx,%eax
    11b1:	0f b6 00             	movzbl (%eax),%eax
    11b4:	84 c0                	test   %al,%al
    11b6:	75 ed                	jne    11a5 <strlen+0xf>
    ;
  return n;
    11b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11bb:	c9                   	leave  
    11bc:	c3                   	ret    

000011bd <memset>:

void*
memset(void *dst, int c, uint n)
{
    11bd:	55                   	push   %ebp
    11be:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    11c0:	8b 45 10             	mov    0x10(%ebp),%eax
    11c3:	50                   	push   %eax
    11c4:	ff 75 0c             	pushl  0xc(%ebp)
    11c7:	ff 75 08             	pushl  0x8(%ebp)
    11ca:	e8 32 ff ff ff       	call   1101 <stosb>
    11cf:	83 c4 0c             	add    $0xc,%esp
  return dst;
    11d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11d5:	c9                   	leave  
    11d6:	c3                   	ret    

000011d7 <strchr>:

char*
strchr(const char *s, char c)
{
    11d7:	55                   	push   %ebp
    11d8:	89 e5                	mov    %esp,%ebp
    11da:	83 ec 04             	sub    $0x4,%esp
    11dd:	8b 45 0c             	mov    0xc(%ebp),%eax
    11e0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    11e3:	eb 14                	jmp    11f9 <strchr+0x22>
    if(*s == c)
    11e5:	8b 45 08             	mov    0x8(%ebp),%eax
    11e8:	0f b6 00             	movzbl (%eax),%eax
    11eb:	3a 45 fc             	cmp    -0x4(%ebp),%al
    11ee:	75 05                	jne    11f5 <strchr+0x1e>
      return (char*)s;
    11f0:	8b 45 08             	mov    0x8(%ebp),%eax
    11f3:	eb 13                	jmp    1208 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    11f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11f9:	8b 45 08             	mov    0x8(%ebp),%eax
    11fc:	0f b6 00             	movzbl (%eax),%eax
    11ff:	84 c0                	test   %al,%al
    1201:	75 e2                	jne    11e5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1203:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1208:	c9                   	leave  
    1209:	c3                   	ret    

0000120a <gets>:

char*
gets(char *buf, int max)
{
    120a:	55                   	push   %ebp
    120b:	89 e5                	mov    %esp,%ebp
    120d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1210:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1217:	eb 42                	jmp    125b <gets+0x51>
    cc = read(0, &c, 1);
    1219:	83 ec 04             	sub    $0x4,%esp
    121c:	6a 01                	push   $0x1
    121e:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1221:	50                   	push   %eax
    1222:	6a 00                	push   $0x0
    1224:	e8 47 01 00 00       	call   1370 <read>
    1229:	83 c4 10             	add    $0x10,%esp
    122c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    122f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1233:	7e 33                	jle    1268 <gets+0x5e>
      break;
    buf[i++] = c;
    1235:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1238:	8d 50 01             	lea    0x1(%eax),%edx
    123b:	89 55 f4             	mov    %edx,-0xc(%ebp)
    123e:	89 c2                	mov    %eax,%edx
    1240:	8b 45 08             	mov    0x8(%ebp),%eax
    1243:	01 c2                	add    %eax,%edx
    1245:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1249:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    124b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    124f:	3c 0a                	cmp    $0xa,%al
    1251:	74 16                	je     1269 <gets+0x5f>
    1253:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1257:	3c 0d                	cmp    $0xd,%al
    1259:	74 0e                	je     1269 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    125b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    125e:	83 c0 01             	add    $0x1,%eax
    1261:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1264:	7c b3                	jl     1219 <gets+0xf>
    1266:	eb 01                	jmp    1269 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1268:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1269:	8b 55 f4             	mov    -0xc(%ebp),%edx
    126c:	8b 45 08             	mov    0x8(%ebp),%eax
    126f:	01 d0                	add    %edx,%eax
    1271:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1274:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1277:	c9                   	leave  
    1278:	c3                   	ret    

00001279 <stat>:

int
stat(char *n, struct stat *st)
{
    1279:	55                   	push   %ebp
    127a:	89 e5                	mov    %esp,%ebp
    127c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    127f:	83 ec 08             	sub    $0x8,%esp
    1282:	6a 00                	push   $0x0
    1284:	ff 75 08             	pushl  0x8(%ebp)
    1287:	e8 0c 01 00 00       	call   1398 <open>
    128c:	83 c4 10             	add    $0x10,%esp
    128f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1292:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1296:	79 07                	jns    129f <stat+0x26>
    return -1;
    1298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    129d:	eb 25                	jmp    12c4 <stat+0x4b>
  r = fstat(fd, st);
    129f:	83 ec 08             	sub    $0x8,%esp
    12a2:	ff 75 0c             	pushl  0xc(%ebp)
    12a5:	ff 75 f4             	pushl  -0xc(%ebp)
    12a8:	e8 03 01 00 00       	call   13b0 <fstat>
    12ad:	83 c4 10             	add    $0x10,%esp
    12b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    12b3:	83 ec 0c             	sub    $0xc,%esp
    12b6:	ff 75 f4             	pushl  -0xc(%ebp)
    12b9:	e8 c2 00 00 00       	call   1380 <close>
    12be:	83 c4 10             	add    $0x10,%esp
  return r;
    12c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    12c4:	c9                   	leave  
    12c5:	c3                   	ret    

000012c6 <atoi>:

int
atoi(const char *s)
{
    12c6:	55                   	push   %ebp
    12c7:	89 e5                	mov    %esp,%ebp
    12c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    12cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    12d3:	eb 25                	jmp    12fa <atoi+0x34>
    n = n*10 + *s++ - '0';
    12d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
    12d8:	89 d0                	mov    %edx,%eax
    12da:	c1 e0 02             	shl    $0x2,%eax
    12dd:	01 d0                	add    %edx,%eax
    12df:	01 c0                	add    %eax,%eax
    12e1:	89 c1                	mov    %eax,%ecx
    12e3:	8b 45 08             	mov    0x8(%ebp),%eax
    12e6:	8d 50 01             	lea    0x1(%eax),%edx
    12e9:	89 55 08             	mov    %edx,0x8(%ebp)
    12ec:	0f b6 00             	movzbl (%eax),%eax
    12ef:	0f be c0             	movsbl %al,%eax
    12f2:	01 c8                	add    %ecx,%eax
    12f4:	83 e8 30             	sub    $0x30,%eax
    12f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    12fa:	8b 45 08             	mov    0x8(%ebp),%eax
    12fd:	0f b6 00             	movzbl (%eax),%eax
    1300:	3c 2f                	cmp    $0x2f,%al
    1302:	7e 0a                	jle    130e <atoi+0x48>
    1304:	8b 45 08             	mov    0x8(%ebp),%eax
    1307:	0f b6 00             	movzbl (%eax),%eax
    130a:	3c 39                	cmp    $0x39,%al
    130c:	7e c7                	jle    12d5 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    130e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1311:	c9                   	leave  
    1312:	c3                   	ret    

00001313 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1313:	55                   	push   %ebp
    1314:	89 e5                	mov    %esp,%ebp
    1316:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1319:	8b 45 08             	mov    0x8(%ebp),%eax
    131c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    131f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1322:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1325:	eb 17                	jmp    133e <memmove+0x2b>
    *dst++ = *src++;
    1327:	8b 45 fc             	mov    -0x4(%ebp),%eax
    132a:	8d 50 01             	lea    0x1(%eax),%edx
    132d:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1330:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1333:	8d 4a 01             	lea    0x1(%edx),%ecx
    1336:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1339:	0f b6 12             	movzbl (%edx),%edx
    133c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    133e:	8b 45 10             	mov    0x10(%ebp),%eax
    1341:	8d 50 ff             	lea    -0x1(%eax),%edx
    1344:	89 55 10             	mov    %edx,0x10(%ebp)
    1347:	85 c0                	test   %eax,%eax
    1349:	7f dc                	jg     1327 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    134b:	8b 45 08             	mov    0x8(%ebp),%eax
}
    134e:	c9                   	leave  
    134f:	c3                   	ret    

00001350 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1350:	b8 01 00 00 00       	mov    $0x1,%eax
    1355:	cd 40                	int    $0x40
    1357:	c3                   	ret    

00001358 <exit>:
SYSCALL(exit)
    1358:	b8 02 00 00 00       	mov    $0x2,%eax
    135d:	cd 40                	int    $0x40
    135f:	c3                   	ret    

00001360 <wait>:
SYSCALL(wait)
    1360:	b8 03 00 00 00       	mov    $0x3,%eax
    1365:	cd 40                	int    $0x40
    1367:	c3                   	ret    

00001368 <pipe>:
SYSCALL(pipe)
    1368:	b8 04 00 00 00       	mov    $0x4,%eax
    136d:	cd 40                	int    $0x40
    136f:	c3                   	ret    

00001370 <read>:
SYSCALL(read)
    1370:	b8 05 00 00 00       	mov    $0x5,%eax
    1375:	cd 40                	int    $0x40
    1377:	c3                   	ret    

00001378 <write>:
SYSCALL(write)
    1378:	b8 10 00 00 00       	mov    $0x10,%eax
    137d:	cd 40                	int    $0x40
    137f:	c3                   	ret    

00001380 <close>:
SYSCALL(close)
    1380:	b8 15 00 00 00       	mov    $0x15,%eax
    1385:	cd 40                	int    $0x40
    1387:	c3                   	ret    

00001388 <kill>:
SYSCALL(kill)
    1388:	b8 06 00 00 00       	mov    $0x6,%eax
    138d:	cd 40                	int    $0x40
    138f:	c3                   	ret    

00001390 <exec>:
SYSCALL(exec)
    1390:	b8 07 00 00 00       	mov    $0x7,%eax
    1395:	cd 40                	int    $0x40
    1397:	c3                   	ret    

00001398 <open>:
SYSCALL(open)
    1398:	b8 0f 00 00 00       	mov    $0xf,%eax
    139d:	cd 40                	int    $0x40
    139f:	c3                   	ret    

000013a0 <mknod>:
SYSCALL(mknod)
    13a0:	b8 11 00 00 00       	mov    $0x11,%eax
    13a5:	cd 40                	int    $0x40
    13a7:	c3                   	ret    

000013a8 <unlink>:
SYSCALL(unlink)
    13a8:	b8 12 00 00 00       	mov    $0x12,%eax
    13ad:	cd 40                	int    $0x40
    13af:	c3                   	ret    

000013b0 <fstat>:
SYSCALL(fstat)
    13b0:	b8 08 00 00 00       	mov    $0x8,%eax
    13b5:	cd 40                	int    $0x40
    13b7:	c3                   	ret    

000013b8 <link>:
SYSCALL(link)
    13b8:	b8 13 00 00 00       	mov    $0x13,%eax
    13bd:	cd 40                	int    $0x40
    13bf:	c3                   	ret    

000013c0 <mkdir>:
SYSCALL(mkdir)
    13c0:	b8 14 00 00 00       	mov    $0x14,%eax
    13c5:	cd 40                	int    $0x40
    13c7:	c3                   	ret    

000013c8 <chdir>:
SYSCALL(chdir)
    13c8:	b8 09 00 00 00       	mov    $0x9,%eax
    13cd:	cd 40                	int    $0x40
    13cf:	c3                   	ret    

000013d0 <dup>:
SYSCALL(dup)
    13d0:	b8 0a 00 00 00       	mov    $0xa,%eax
    13d5:	cd 40                	int    $0x40
    13d7:	c3                   	ret    

000013d8 <getpid>:
SYSCALL(getpid)
    13d8:	b8 0b 00 00 00       	mov    $0xb,%eax
    13dd:	cd 40                	int    $0x40
    13df:	c3                   	ret    

000013e0 <sbrk>:
SYSCALL(sbrk)
    13e0:	b8 0c 00 00 00       	mov    $0xc,%eax
    13e5:	cd 40                	int    $0x40
    13e7:	c3                   	ret    

000013e8 <sleep>:
SYSCALL(sleep)
    13e8:	b8 0d 00 00 00       	mov    $0xd,%eax
    13ed:	cd 40                	int    $0x40
    13ef:	c3                   	ret    

000013f0 <uptime>:
SYSCALL(uptime)
    13f0:	b8 0e 00 00 00       	mov    $0xe,%eax
    13f5:	cd 40                	int    $0x40
    13f7:	c3                   	ret    

000013f8 <shm_open>:
SYSCALL(shm_open)
    13f8:	b8 16 00 00 00       	mov    $0x16,%eax
    13fd:	cd 40                	int    $0x40
    13ff:	c3                   	ret    

00001400 <shm_close>:
SYSCALL(shm_close)	
    1400:	b8 17 00 00 00       	mov    $0x17,%eax
    1405:	cd 40                	int    $0x40
    1407:	c3                   	ret    

00001408 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1408:	55                   	push   %ebp
    1409:	89 e5                	mov    %esp,%ebp
    140b:	83 ec 18             	sub    $0x18,%esp
    140e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1411:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1414:	83 ec 04             	sub    $0x4,%esp
    1417:	6a 01                	push   $0x1
    1419:	8d 45 f4             	lea    -0xc(%ebp),%eax
    141c:	50                   	push   %eax
    141d:	ff 75 08             	pushl  0x8(%ebp)
    1420:	e8 53 ff ff ff       	call   1378 <write>
    1425:	83 c4 10             	add    $0x10,%esp
}
    1428:	90                   	nop
    1429:	c9                   	leave  
    142a:	c3                   	ret    

0000142b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    142b:	55                   	push   %ebp
    142c:	89 e5                	mov    %esp,%ebp
    142e:	53                   	push   %ebx
    142f:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1432:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1439:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    143d:	74 17                	je     1456 <printint+0x2b>
    143f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1443:	79 11                	jns    1456 <printint+0x2b>
    neg = 1;
    1445:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    144c:	8b 45 0c             	mov    0xc(%ebp),%eax
    144f:	f7 d8                	neg    %eax
    1451:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1454:	eb 06                	jmp    145c <printint+0x31>
  } else {
    x = xx;
    1456:	8b 45 0c             	mov    0xc(%ebp),%eax
    1459:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    145c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1463:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1466:	8d 41 01             	lea    0x1(%ecx),%eax
    1469:	89 45 f4             	mov    %eax,-0xc(%ebp)
    146c:	8b 5d 10             	mov    0x10(%ebp),%ebx
    146f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1472:	ba 00 00 00 00       	mov    $0x0,%edx
    1477:	f7 f3                	div    %ebx
    1479:	89 d0                	mov    %edx,%eax
    147b:	0f b6 80 ec 1b 00 00 	movzbl 0x1bec(%eax),%eax
    1482:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    1486:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1489:	8b 45 ec             	mov    -0x14(%ebp),%eax
    148c:	ba 00 00 00 00       	mov    $0x0,%edx
    1491:	f7 f3                	div    %ebx
    1493:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1496:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    149a:	75 c7                	jne    1463 <printint+0x38>
  if(neg)
    149c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14a0:	74 2d                	je     14cf <printint+0xa4>
    buf[i++] = '-';
    14a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a5:	8d 50 01             	lea    0x1(%eax),%edx
    14a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
    14ab:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    14b0:	eb 1d                	jmp    14cf <printint+0xa4>
    putc(fd, buf[i]);
    14b2:	8d 55 dc             	lea    -0x24(%ebp),%edx
    14b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b8:	01 d0                	add    %edx,%eax
    14ba:	0f b6 00             	movzbl (%eax),%eax
    14bd:	0f be c0             	movsbl %al,%eax
    14c0:	83 ec 08             	sub    $0x8,%esp
    14c3:	50                   	push   %eax
    14c4:	ff 75 08             	pushl  0x8(%ebp)
    14c7:	e8 3c ff ff ff       	call   1408 <putc>
    14cc:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    14cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14d7:	79 d9                	jns    14b2 <printint+0x87>
    putc(fd, buf[i]);
}
    14d9:	90                   	nop
    14da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    14dd:	c9                   	leave  
    14de:	c3                   	ret    

000014df <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    14df:	55                   	push   %ebp
    14e0:	89 e5                	mov    %esp,%ebp
    14e2:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    14e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14ec:	8d 45 0c             	lea    0xc(%ebp),%eax
    14ef:	83 c0 04             	add    $0x4,%eax
    14f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    14f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14fc:	e9 59 01 00 00       	jmp    165a <printf+0x17b>
    c = fmt[i] & 0xff;
    1501:	8b 55 0c             	mov    0xc(%ebp),%edx
    1504:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1507:	01 d0                	add    %edx,%eax
    1509:	0f b6 00             	movzbl (%eax),%eax
    150c:	0f be c0             	movsbl %al,%eax
    150f:	25 ff 00 00 00       	and    $0xff,%eax
    1514:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1517:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    151b:	75 2c                	jne    1549 <printf+0x6a>
      if(c == '%'){
    151d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1521:	75 0c                	jne    152f <printf+0x50>
        state = '%';
    1523:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    152a:	e9 27 01 00 00       	jmp    1656 <printf+0x177>
      } else {
        putc(fd, c);
    152f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1532:	0f be c0             	movsbl %al,%eax
    1535:	83 ec 08             	sub    $0x8,%esp
    1538:	50                   	push   %eax
    1539:	ff 75 08             	pushl  0x8(%ebp)
    153c:	e8 c7 fe ff ff       	call   1408 <putc>
    1541:	83 c4 10             	add    $0x10,%esp
    1544:	e9 0d 01 00 00       	jmp    1656 <printf+0x177>
      }
    } else if(state == '%'){
    1549:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    154d:	0f 85 03 01 00 00    	jne    1656 <printf+0x177>
      if(c == 'd'){
    1553:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1557:	75 1e                	jne    1577 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1559:	8b 45 e8             	mov    -0x18(%ebp),%eax
    155c:	8b 00                	mov    (%eax),%eax
    155e:	6a 01                	push   $0x1
    1560:	6a 0a                	push   $0xa
    1562:	50                   	push   %eax
    1563:	ff 75 08             	pushl  0x8(%ebp)
    1566:	e8 c0 fe ff ff       	call   142b <printint>
    156b:	83 c4 10             	add    $0x10,%esp
        ap++;
    156e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1572:	e9 d8 00 00 00       	jmp    164f <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1577:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    157b:	74 06                	je     1583 <printf+0xa4>
    157d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1581:	75 1e                	jne    15a1 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    1583:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1586:	8b 00                	mov    (%eax),%eax
    1588:	6a 00                	push   $0x0
    158a:	6a 10                	push   $0x10
    158c:	50                   	push   %eax
    158d:	ff 75 08             	pushl  0x8(%ebp)
    1590:	e8 96 fe ff ff       	call   142b <printint>
    1595:	83 c4 10             	add    $0x10,%esp
        ap++;
    1598:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    159c:	e9 ae 00 00 00       	jmp    164f <printf+0x170>
      } else if(c == 's'){
    15a1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    15a5:	75 43                	jne    15ea <printf+0x10b>
        s = (char*)*ap;
    15a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15aa:	8b 00                	mov    (%eax),%eax
    15ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    15af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    15b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15b7:	75 25                	jne    15de <printf+0xff>
          s = "(null)";
    15b9:	c7 45 f4 34 19 00 00 	movl   $0x1934,-0xc(%ebp)
        while(*s != 0){
    15c0:	eb 1c                	jmp    15de <printf+0xff>
          putc(fd, *s);
    15c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15c5:	0f b6 00             	movzbl (%eax),%eax
    15c8:	0f be c0             	movsbl %al,%eax
    15cb:	83 ec 08             	sub    $0x8,%esp
    15ce:	50                   	push   %eax
    15cf:	ff 75 08             	pushl  0x8(%ebp)
    15d2:	e8 31 fe ff ff       	call   1408 <putc>
    15d7:	83 c4 10             	add    $0x10,%esp
          s++;
    15da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    15de:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15e1:	0f b6 00             	movzbl (%eax),%eax
    15e4:	84 c0                	test   %al,%al
    15e6:	75 da                	jne    15c2 <printf+0xe3>
    15e8:	eb 65                	jmp    164f <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15ea:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15ee:	75 1d                	jne    160d <printf+0x12e>
        putc(fd, *ap);
    15f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15f3:	8b 00                	mov    (%eax),%eax
    15f5:	0f be c0             	movsbl %al,%eax
    15f8:	83 ec 08             	sub    $0x8,%esp
    15fb:	50                   	push   %eax
    15fc:	ff 75 08             	pushl  0x8(%ebp)
    15ff:	e8 04 fe ff ff       	call   1408 <putc>
    1604:	83 c4 10             	add    $0x10,%esp
        ap++;
    1607:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    160b:	eb 42                	jmp    164f <printf+0x170>
      } else if(c == '%'){
    160d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1611:	75 17                	jne    162a <printf+0x14b>
        putc(fd, c);
    1613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1616:	0f be c0             	movsbl %al,%eax
    1619:	83 ec 08             	sub    $0x8,%esp
    161c:	50                   	push   %eax
    161d:	ff 75 08             	pushl  0x8(%ebp)
    1620:	e8 e3 fd ff ff       	call   1408 <putc>
    1625:	83 c4 10             	add    $0x10,%esp
    1628:	eb 25                	jmp    164f <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    162a:	83 ec 08             	sub    $0x8,%esp
    162d:	6a 25                	push   $0x25
    162f:	ff 75 08             	pushl  0x8(%ebp)
    1632:	e8 d1 fd ff ff       	call   1408 <putc>
    1637:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    163a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    163d:	0f be c0             	movsbl %al,%eax
    1640:	83 ec 08             	sub    $0x8,%esp
    1643:	50                   	push   %eax
    1644:	ff 75 08             	pushl  0x8(%ebp)
    1647:	e8 bc fd ff ff       	call   1408 <putc>
    164c:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    164f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1656:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    165a:	8b 55 0c             	mov    0xc(%ebp),%edx
    165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1660:	01 d0                	add    %edx,%eax
    1662:	0f b6 00             	movzbl (%eax),%eax
    1665:	84 c0                	test   %al,%al
    1667:	0f 85 94 fe ff ff    	jne    1501 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    166d:	90                   	nop
    166e:	c9                   	leave  
    166f:	c3                   	ret    

00001670 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1670:	55                   	push   %ebp
    1671:	89 e5                	mov    %esp,%ebp
    1673:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1676:	8b 45 08             	mov    0x8(%ebp),%eax
    1679:	83 e8 08             	sub    $0x8,%eax
    167c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    167f:	a1 08 1c 00 00       	mov    0x1c08,%eax
    1684:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1687:	eb 24                	jmp    16ad <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1689:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168c:	8b 00                	mov    (%eax),%eax
    168e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1691:	77 12                	ja     16a5 <free+0x35>
    1693:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1696:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1699:	77 24                	ja     16bf <free+0x4f>
    169b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169e:	8b 00                	mov    (%eax),%eax
    16a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16a3:	77 1a                	ja     16bf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a8:	8b 00                	mov    (%eax),%eax
    16aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16b3:	76 d4                	jbe    1689 <free+0x19>
    16b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b8:	8b 00                	mov    (%eax),%eax
    16ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16bd:	76 ca                	jbe    1689 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c2:	8b 40 04             	mov    0x4(%eax),%eax
    16c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16cf:	01 c2                	add    %eax,%edx
    16d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d4:	8b 00                	mov    (%eax),%eax
    16d6:	39 c2                	cmp    %eax,%edx
    16d8:	75 24                	jne    16fe <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    16da:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16dd:	8b 50 04             	mov    0x4(%eax),%edx
    16e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e3:	8b 00                	mov    (%eax),%eax
    16e5:	8b 40 04             	mov    0x4(%eax),%eax
    16e8:	01 c2                	add    %eax,%edx
    16ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ed:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f3:	8b 00                	mov    (%eax),%eax
    16f5:	8b 10                	mov    (%eax),%edx
    16f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16fa:	89 10                	mov    %edx,(%eax)
    16fc:	eb 0a                	jmp    1708 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    16fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1701:	8b 10                	mov    (%eax),%edx
    1703:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1706:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1708:	8b 45 fc             	mov    -0x4(%ebp),%eax
    170b:	8b 40 04             	mov    0x4(%eax),%eax
    170e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1715:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1718:	01 d0                	add    %edx,%eax
    171a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    171d:	75 20                	jne    173f <free+0xcf>
    p->s.size += bp->s.size;
    171f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1722:	8b 50 04             	mov    0x4(%eax),%edx
    1725:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1728:	8b 40 04             	mov    0x4(%eax),%eax
    172b:	01 c2                	add    %eax,%edx
    172d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1730:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1733:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1736:	8b 10                	mov    (%eax),%edx
    1738:	8b 45 fc             	mov    -0x4(%ebp),%eax
    173b:	89 10                	mov    %edx,(%eax)
    173d:	eb 08                	jmp    1747 <free+0xd7>
  } else
    p->s.ptr = bp;
    173f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1742:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1745:	89 10                	mov    %edx,(%eax)
  freep = p;
    1747:	8b 45 fc             	mov    -0x4(%ebp),%eax
    174a:	a3 08 1c 00 00       	mov    %eax,0x1c08
}
    174f:	90                   	nop
    1750:	c9                   	leave  
    1751:	c3                   	ret    

00001752 <morecore>:

static Header*
morecore(uint nu)
{
    1752:	55                   	push   %ebp
    1753:	89 e5                	mov    %esp,%ebp
    1755:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1758:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    175f:	77 07                	ja     1768 <morecore+0x16>
    nu = 4096;
    1761:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1768:	8b 45 08             	mov    0x8(%ebp),%eax
    176b:	c1 e0 03             	shl    $0x3,%eax
    176e:	83 ec 0c             	sub    $0xc,%esp
    1771:	50                   	push   %eax
    1772:	e8 69 fc ff ff       	call   13e0 <sbrk>
    1777:	83 c4 10             	add    $0x10,%esp
    177a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    177d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1781:	75 07                	jne    178a <morecore+0x38>
    return 0;
    1783:	b8 00 00 00 00       	mov    $0x0,%eax
    1788:	eb 26                	jmp    17b0 <morecore+0x5e>
  hp = (Header*)p;
    178a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1790:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1793:	8b 55 08             	mov    0x8(%ebp),%edx
    1796:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1799:	8b 45 f0             	mov    -0x10(%ebp),%eax
    179c:	83 c0 08             	add    $0x8,%eax
    179f:	83 ec 0c             	sub    $0xc,%esp
    17a2:	50                   	push   %eax
    17a3:	e8 c8 fe ff ff       	call   1670 <free>
    17a8:	83 c4 10             	add    $0x10,%esp
  return freep;
    17ab:	a1 08 1c 00 00       	mov    0x1c08,%eax
}
    17b0:	c9                   	leave  
    17b1:	c3                   	ret    

000017b2 <malloc>:

void*
malloc(uint nbytes)
{
    17b2:	55                   	push   %ebp
    17b3:	89 e5                	mov    %esp,%ebp
    17b5:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    17b8:	8b 45 08             	mov    0x8(%ebp),%eax
    17bb:	83 c0 07             	add    $0x7,%eax
    17be:	c1 e8 03             	shr    $0x3,%eax
    17c1:	83 c0 01             	add    $0x1,%eax
    17c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17c7:	a1 08 1c 00 00       	mov    0x1c08,%eax
    17cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17d3:	75 23                	jne    17f8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17d5:	c7 45 f0 00 1c 00 00 	movl   $0x1c00,-0x10(%ebp)
    17dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17df:	a3 08 1c 00 00       	mov    %eax,0x1c08
    17e4:	a1 08 1c 00 00       	mov    0x1c08,%eax
    17e9:	a3 00 1c 00 00       	mov    %eax,0x1c00
    base.s.size = 0;
    17ee:	c7 05 04 1c 00 00 00 	movl   $0x0,0x1c04
    17f5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17fb:	8b 00                	mov    (%eax),%eax
    17fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1800:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1803:	8b 40 04             	mov    0x4(%eax),%eax
    1806:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1809:	72 4d                	jb     1858 <malloc+0xa6>
      if(p->s.size == nunits)
    180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180e:	8b 40 04             	mov    0x4(%eax),%eax
    1811:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1814:	75 0c                	jne    1822 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1816:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1819:	8b 10                	mov    (%eax),%edx
    181b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    181e:	89 10                	mov    %edx,(%eax)
    1820:	eb 26                	jmp    1848 <malloc+0x96>
      else {
        p->s.size -= nunits;
    1822:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1825:	8b 40 04             	mov    0x4(%eax),%eax
    1828:	2b 45 ec             	sub    -0x14(%ebp),%eax
    182b:	89 c2                	mov    %eax,%edx
    182d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1830:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1833:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1836:	8b 40 04             	mov    0x4(%eax),%eax
    1839:	c1 e0 03             	shl    $0x3,%eax
    183c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1842:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1845:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1848:	8b 45 f0             	mov    -0x10(%ebp),%eax
    184b:	a3 08 1c 00 00       	mov    %eax,0x1c08
      return (void*)(p + 1);
    1850:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1853:	83 c0 08             	add    $0x8,%eax
    1856:	eb 3b                	jmp    1893 <malloc+0xe1>
    }
    if(p == freep)
    1858:	a1 08 1c 00 00       	mov    0x1c08,%eax
    185d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1860:	75 1e                	jne    1880 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    1862:	83 ec 0c             	sub    $0xc,%esp
    1865:	ff 75 ec             	pushl  -0x14(%ebp)
    1868:	e8 e5 fe ff ff       	call   1752 <morecore>
    186d:	83 c4 10             	add    $0x10,%esp
    1870:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1873:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1877:	75 07                	jne    1880 <malloc+0xce>
        return 0;
    1879:	b8 00 00 00 00       	mov    $0x0,%eax
    187e:	eb 13                	jmp    1893 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1880:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1883:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1886:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1889:	8b 00                	mov    (%eax),%eax
    188b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    188e:	e9 6d ff ff ff       	jmp    1800 <malloc+0x4e>
}
    1893:	c9                   	leave  
    1894:	c3                   	ret    

00001895 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    1895:	55                   	push   %ebp
    1896:	89 e5                	mov    %esp,%ebp
    1898:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    189b:	8b 55 08             	mov    0x8(%ebp),%edx
    189e:	8b 45 0c             	mov    0xc(%ebp),%eax
    18a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
    18a4:	f0 87 02             	lock xchg %eax,(%edx)
    18a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    18aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    18ad:	c9                   	leave  
    18ae:	c3                   	ret    

000018af <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    18af:	55                   	push   %ebp
    18b0:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    18b2:	90                   	nop
    18b3:	8b 45 08             	mov    0x8(%ebp),%eax
    18b6:	6a 01                	push   $0x1
    18b8:	50                   	push   %eax
    18b9:	e8 d7 ff ff ff       	call   1895 <xchg>
    18be:	83 c4 08             	add    $0x8,%esp
    18c1:	85 c0                	test   %eax,%eax
    18c3:	75 ee                	jne    18b3 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    18c5:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    18ca:	90                   	nop
    18cb:	c9                   	leave  
    18cc:	c3                   	ret    

000018cd <urelease>:

void urelease (struct uspinlock *lk) {
    18cd:	55                   	push   %ebp
    18ce:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    18d0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    18d5:	8b 45 08             	mov    0x8(%ebp),%eax
    18d8:	8b 55 08             	mov    0x8(%ebp),%edx
    18db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    18e1:	90                   	nop
    18e2:	5d                   	pop    %ebp
    18e3:	c3                   	ret    
