
_forktest:     file format elf32-i386


Disassembly of section .text:

00001000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
    1006:	83 ec 0c             	sub    $0xc,%esp
    1009:	ff 75 0c             	pushl  0xc(%ebp)
    100c:	e8 97 01 00 00       	call   11a8 <strlen>
    1011:	83 c4 10             	add    $0x10,%esp
    1014:	83 ec 04             	sub    $0x4,%esp
    1017:	50                   	push   %eax
    1018:	ff 75 0c             	pushl  0xc(%ebp)
    101b:	ff 75 08             	pushl  0x8(%ebp)
    101e:	e8 67 03 00 00       	call   138a <write>
    1023:	83 c4 10             	add    $0x10,%esp
}
    1026:	90                   	nop
    1027:	c9                   	leave  
    1028:	c3                   	ret    

00001029 <forktest>:

void
forktest(void)
{
    1029:	55                   	push   %ebp
    102a:	89 e5                	mov    %esp,%ebp
    102c:	83 ec 18             	sub    $0x18,%esp
  int n, pid;

  printf(1, "fork test\n");
    102f:	83 ec 08             	sub    $0x8,%esp
    1032:	68 1c 14 00 00       	push   $0x141c
    1037:	6a 01                	push   $0x1
    1039:	e8 c2 ff ff ff       	call   1000 <printf>
    103e:	83 c4 10             	add    $0x10,%esp

  for(n=0; n<N; n++){
    1041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1048:	eb 1d                	jmp    1067 <forktest+0x3e>
    pid = fork();
    104a:	e8 13 03 00 00       	call   1362 <fork>
    104f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    1052:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1056:	78 1a                	js     1072 <forktest+0x49>
      break;
    if(pid == 0)
    1058:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    105c:	75 05                	jne    1063 <forktest+0x3a>
      exit();
    105e:	e8 07 03 00 00       	call   136a <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
    1063:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1067:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    106e:	7e da                	jle    104a <forktest+0x21>
    1070:	eb 01                	jmp    1073 <forktest+0x4a>
    pid = fork();
    if(pid < 0)
      break;
    1072:	90                   	nop
    if(pid == 0)
      exit();
  }

  if(n == N){
    1073:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    107a:	75 40                	jne    10bc <forktest+0x93>
    printf(1, "fork claimed to work N times!\n", N);
    107c:	83 ec 04             	sub    $0x4,%esp
    107f:	68 e8 03 00 00       	push   $0x3e8
    1084:	68 28 14 00 00       	push   $0x1428
    1089:	6a 01                	push   $0x1
    108b:	e8 70 ff ff ff       	call   1000 <printf>
    1090:	83 c4 10             	add    $0x10,%esp
    exit();
    1093:	e8 d2 02 00 00       	call   136a <exit>
  }

  for(; n > 0; n--){
    if(wait() < 0){
    1098:	e8 d5 02 00 00       	call   1372 <wait>
    109d:	85 c0                	test   %eax,%eax
    109f:	79 17                	jns    10b8 <forktest+0x8f>
      printf(1, "wait stopped early\n");
    10a1:	83 ec 08             	sub    $0x8,%esp
    10a4:	68 47 14 00 00       	push   $0x1447
    10a9:	6a 01                	push   $0x1
    10ab:	e8 50 ff ff ff       	call   1000 <printf>
    10b0:	83 c4 10             	add    $0x10,%esp
      exit();
    10b3:	e8 b2 02 00 00       	call   136a <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
    10b8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    10bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10c0:	7f d6                	jg     1098 <forktest+0x6f>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
    10c2:	e8 ab 02 00 00       	call   1372 <wait>
    10c7:	83 f8 ff             	cmp    $0xffffffff,%eax
    10ca:	74 17                	je     10e3 <forktest+0xba>
    printf(1, "wait got too many\n");
    10cc:	83 ec 08             	sub    $0x8,%esp
    10cf:	68 5b 14 00 00       	push   $0x145b
    10d4:	6a 01                	push   $0x1
    10d6:	e8 25 ff ff ff       	call   1000 <printf>
    10db:	83 c4 10             	add    $0x10,%esp
    exit();
    10de:	e8 87 02 00 00       	call   136a <exit>
  }

  printf(1, "fork test OK\n");
    10e3:	83 ec 08             	sub    $0x8,%esp
    10e6:	68 6e 14 00 00       	push   $0x146e
    10eb:	6a 01                	push   $0x1
    10ed:	e8 0e ff ff ff       	call   1000 <printf>
    10f2:	83 c4 10             	add    $0x10,%esp
}
    10f5:	90                   	nop
    10f6:	c9                   	leave  
    10f7:	c3                   	ret    

000010f8 <main>:

int
main(void)
{
    10f8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    10fc:	83 e4 f0             	and    $0xfffffff0,%esp
    10ff:	ff 71 fc             	pushl  -0x4(%ecx)
    1102:	55                   	push   %ebp
    1103:	89 e5                	mov    %esp,%ebp
    1105:	51                   	push   %ecx
    1106:	83 ec 04             	sub    $0x4,%esp
  forktest();
    1109:	e8 1b ff ff ff       	call   1029 <forktest>
  exit();
    110e:	e8 57 02 00 00       	call   136a <exit>

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
