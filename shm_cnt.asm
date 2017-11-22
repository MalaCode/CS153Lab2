
_shm_cnt:     file format elf32-i386


Disassembly of section .text:

00001000 <main>:
   struct uspinlock lock;
   int cnt;
};

int main(int argc, char *argv[])
{
    1000:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    1004:	83 e4 f0             	and    $0xfffffff0,%esp
    1007:	ff 71 fc             	pushl  -0x4(%ecx)
    100a:	55                   	push   %ebp
    100b:	89 e5                	mov    %esp,%ebp
    100d:	51                   	push   %ecx
    100e:	83 ec 14             	sub    $0x14,%esp
int pid;
int i=0;
    1011:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
struct shm_cnt *counter;
  pid=fork();
    1018:	e8 5e 03 00 00       	call   137b <fork>
    101d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sleep(1);
    1020:	83 ec 0c             	sub    $0xc,%esp
    1023:	6a 01                	push   $0x1
    1025:	e8 e9 03 00 00       	call   1413 <sleep>
    102a:	83 c4 10             	add    $0x10,%esp

//shm_open: first process will create the page, the second will just attach to the same page
//we get the virtual address of the page returned into counter
//which we can now use but will be shared between the two processes
  
shm_open(1,(char **)&counter);
    102d:	83 ec 08             	sub    $0x8,%esp
    1030:	8d 45 ec             	lea    -0x14(%ebp),%eax
    1033:	50                   	push   %eax
    1034:	6a 01                	push   $0x1
    1036:	e8 e8 03 00 00       	call   1423 <shm_open>
    103b:	83 c4 10             	add    $0x10,%esp
 
//  printf(1,"%s returned successfully from shm_open with counter %x\n", pid? "Child": "Parent", counter); 
  for(i = 0; i < 10000; i++)
    103e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1045:	e9 84 00 00 00       	jmp    10ce <main+0xce>
    {
     uacquire(&(counter->lock));
    104a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    104d:	83 ec 0c             	sub    $0xc,%esp
    1050:	50                   	push   %eax
    1051:	e8 84 08 00 00       	call   18da <uacquire>
    1056:	83 c4 10             	add    $0x10,%esp
     counter->cnt++;
    1059:	8b 45 ec             	mov    -0x14(%ebp),%eax
    105c:	8b 50 04             	mov    0x4(%eax),%edx
    105f:	83 c2 01             	add    $0x1,%edx
    1062:	89 50 04             	mov    %edx,0x4(%eax)
     urelease(&(counter->lock));
    1065:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1068:	83 ec 0c             	sub    $0xc,%esp
    106b:	50                   	push   %eax
    106c:	e8 87 08 00 00       	call   18f8 <urelease>
    1071:	83 c4 10             	add    $0x10,%esp

//print something because we are curious and to give a chance to switch process
     if(i%1000 == 0)
    1074:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1077:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    107c:	89 c8                	mov    %ecx,%eax
    107e:	f7 ea                	imul   %edx
    1080:	c1 fa 06             	sar    $0x6,%edx
    1083:	89 c8                	mov    %ecx,%eax
    1085:	c1 f8 1f             	sar    $0x1f,%eax
    1088:	29 c2                	sub    %eax,%edx
    108a:	89 d0                	mov    %edx,%eax
    108c:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
    1092:	29 c1                	sub    %eax,%ecx
    1094:	89 c8                	mov    %ecx,%eax
    1096:	85 c0                	test   %eax,%eax
    1098:	75 30                	jne    10ca <main+0xca>
       printf(1,"Counter in %s is %d at address %x\n",pid? "Parent" : "Child", counter->cnt, counter);
    109a:	8b 55 ec             	mov    -0x14(%ebp),%edx
    109d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10a0:	8b 40 04             	mov    0x4(%eax),%eax
    10a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10a7:	74 07                	je     10b0 <main+0xb0>
    10a9:	b9 10 19 00 00       	mov    $0x1910,%ecx
    10ae:	eb 05                	jmp    10b5 <main+0xb5>
    10b0:	b9 17 19 00 00       	mov    $0x1917,%ecx
    10b5:	83 ec 0c             	sub    $0xc,%esp
    10b8:	52                   	push   %edx
    10b9:	50                   	push   %eax
    10ba:	51                   	push   %ecx
    10bb:	68 20 19 00 00       	push   $0x1920
    10c0:	6a 01                	push   $0x1
    10c2:	e8 43 04 00 00       	call   150a <printf>
    10c7:	83 c4 20             	add    $0x20,%esp
//which we can now use but will be shared between the two processes
  
shm_open(1,(char **)&counter);
 
//  printf(1,"%s returned successfully from shm_open with counter %x\n", pid? "Child": "Parent", counter); 
  for(i = 0; i < 10000; i++)
    10ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    10ce:	81 7d f4 0f 27 00 00 	cmpl   $0x270f,-0xc(%ebp)
    10d5:	0f 8e 6f ff ff ff    	jle    104a <main+0x4a>
//print something because we are curious and to give a chance to switch process
     if(i%1000 == 0)
       printf(1,"Counter in %s is %d at address %x\n",pid? "Parent" : "Child", counter->cnt, counter);
}
  
  if(pid)
    10db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10df:	74 20                	je     1101 <main+0x101>
     {
       printf(1,"Counter in parent is %d\n",counter->cnt);
    10e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10e4:	8b 40 04             	mov    0x4(%eax),%eax
    10e7:	83 ec 04             	sub    $0x4,%esp
    10ea:	50                   	push   %eax
    10eb:	68 43 19 00 00       	push   $0x1943
    10f0:	6a 01                	push   $0x1
    10f2:	e8 13 04 00 00       	call   150a <printf>
    10f7:	83 c4 10             	add    $0x10,%esp
    wait();
    10fa:	e8 8c 02 00 00       	call   138b <wait>
    10ff:	eb 19                	jmp    111a <main+0x11a>
    } else
    printf(1,"Counter in child is %d\n\n",counter->cnt);
    1101:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1104:	8b 40 04             	mov    0x4(%eax),%eax
    1107:	83 ec 04             	sub    $0x4,%esp
    110a:	50                   	push   %eax
    110b:	68 5c 19 00 00       	push   $0x195c
    1110:	6a 01                	push   $0x1
    1112:	e8 f3 03 00 00       	call   150a <printf>
    1117:	83 c4 10             	add    $0x10,%esp

//shm_close: first process will just detach, next one will free up the shm_table entry (but for now not the page)
   shm_close(1);
    111a:	83 ec 0c             	sub    $0xc,%esp
    111d:	6a 01                	push   $0x1
    111f:	e8 07 03 00 00       	call   142b <shm_close>
    1124:	83 c4 10             	add    $0x10,%esp
   exit();
    1127:	e8 57 02 00 00       	call   1383 <exit>

0000112c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    112c:	55                   	push   %ebp
    112d:	89 e5                	mov    %esp,%ebp
    112f:	57                   	push   %edi
    1130:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1131:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1134:	8b 55 10             	mov    0x10(%ebp),%edx
    1137:	8b 45 0c             	mov    0xc(%ebp),%eax
    113a:	89 cb                	mov    %ecx,%ebx
    113c:	89 df                	mov    %ebx,%edi
    113e:	89 d1                	mov    %edx,%ecx
    1140:	fc                   	cld    
    1141:	f3 aa                	rep stos %al,%es:(%edi)
    1143:	89 ca                	mov    %ecx,%edx
    1145:	89 fb                	mov    %edi,%ebx
    1147:	89 5d 08             	mov    %ebx,0x8(%ebp)
    114a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    114d:	90                   	nop
    114e:	5b                   	pop    %ebx
    114f:	5f                   	pop    %edi
    1150:	5d                   	pop    %ebp
    1151:	c3                   	ret    

00001152 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1152:	55                   	push   %ebp
    1153:	89 e5                	mov    %esp,%ebp
    1155:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1158:	8b 45 08             	mov    0x8(%ebp),%eax
    115b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    115e:	90                   	nop
    115f:	8b 45 08             	mov    0x8(%ebp),%eax
    1162:	8d 50 01             	lea    0x1(%eax),%edx
    1165:	89 55 08             	mov    %edx,0x8(%ebp)
    1168:	8b 55 0c             	mov    0xc(%ebp),%edx
    116b:	8d 4a 01             	lea    0x1(%edx),%ecx
    116e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1171:	0f b6 12             	movzbl (%edx),%edx
    1174:	88 10                	mov    %dl,(%eax)
    1176:	0f b6 00             	movzbl (%eax),%eax
    1179:	84 c0                	test   %al,%al
    117b:	75 e2                	jne    115f <strcpy+0xd>
    ;
  return os;
    117d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1180:	c9                   	leave  
    1181:	c3                   	ret    

00001182 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1182:	55                   	push   %ebp
    1183:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1185:	eb 08                	jmp    118f <strcmp+0xd>
    p++, q++;
    1187:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    118b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    118f:	8b 45 08             	mov    0x8(%ebp),%eax
    1192:	0f b6 00             	movzbl (%eax),%eax
    1195:	84 c0                	test   %al,%al
    1197:	74 10                	je     11a9 <strcmp+0x27>
    1199:	8b 45 08             	mov    0x8(%ebp),%eax
    119c:	0f b6 10             	movzbl (%eax),%edx
    119f:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a2:	0f b6 00             	movzbl (%eax),%eax
    11a5:	38 c2                	cmp    %al,%dl
    11a7:	74 de                	je     1187 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    11a9:	8b 45 08             	mov    0x8(%ebp),%eax
    11ac:	0f b6 00             	movzbl (%eax),%eax
    11af:	0f b6 d0             	movzbl %al,%edx
    11b2:	8b 45 0c             	mov    0xc(%ebp),%eax
    11b5:	0f b6 00             	movzbl (%eax),%eax
    11b8:	0f b6 c0             	movzbl %al,%eax
    11bb:	29 c2                	sub    %eax,%edx
    11bd:	89 d0                	mov    %edx,%eax
}
    11bf:	5d                   	pop    %ebp
    11c0:	c3                   	ret    

000011c1 <strlen>:

uint
strlen(char *s)
{
    11c1:	55                   	push   %ebp
    11c2:	89 e5                	mov    %esp,%ebp
    11c4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    11c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    11ce:	eb 04                	jmp    11d4 <strlen+0x13>
    11d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    11d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11d7:	8b 45 08             	mov    0x8(%ebp),%eax
    11da:	01 d0                	add    %edx,%eax
    11dc:	0f b6 00             	movzbl (%eax),%eax
    11df:	84 c0                	test   %al,%al
    11e1:	75 ed                	jne    11d0 <strlen+0xf>
    ;
  return n;
    11e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11e6:	c9                   	leave  
    11e7:	c3                   	ret    

000011e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
    11e8:	55                   	push   %ebp
    11e9:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    11eb:	8b 45 10             	mov    0x10(%ebp),%eax
    11ee:	50                   	push   %eax
    11ef:	ff 75 0c             	pushl  0xc(%ebp)
    11f2:	ff 75 08             	pushl  0x8(%ebp)
    11f5:	e8 32 ff ff ff       	call   112c <stosb>
    11fa:	83 c4 0c             	add    $0xc,%esp
  return dst;
    11fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1200:	c9                   	leave  
    1201:	c3                   	ret    

00001202 <strchr>:

char*
strchr(const char *s, char c)
{
    1202:	55                   	push   %ebp
    1203:	89 e5                	mov    %esp,%ebp
    1205:	83 ec 04             	sub    $0x4,%esp
    1208:	8b 45 0c             	mov    0xc(%ebp),%eax
    120b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    120e:	eb 14                	jmp    1224 <strchr+0x22>
    if(*s == c)
    1210:	8b 45 08             	mov    0x8(%ebp),%eax
    1213:	0f b6 00             	movzbl (%eax),%eax
    1216:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1219:	75 05                	jne    1220 <strchr+0x1e>
      return (char*)s;
    121b:	8b 45 08             	mov    0x8(%ebp),%eax
    121e:	eb 13                	jmp    1233 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1220:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1224:	8b 45 08             	mov    0x8(%ebp),%eax
    1227:	0f b6 00             	movzbl (%eax),%eax
    122a:	84 c0                	test   %al,%al
    122c:	75 e2                	jne    1210 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    122e:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1233:	c9                   	leave  
    1234:	c3                   	ret    

00001235 <gets>:

char*
gets(char *buf, int max)
{
    1235:	55                   	push   %ebp
    1236:	89 e5                	mov    %esp,%ebp
    1238:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    123b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1242:	eb 42                	jmp    1286 <gets+0x51>
    cc = read(0, &c, 1);
    1244:	83 ec 04             	sub    $0x4,%esp
    1247:	6a 01                	push   $0x1
    1249:	8d 45 ef             	lea    -0x11(%ebp),%eax
    124c:	50                   	push   %eax
    124d:	6a 00                	push   $0x0
    124f:	e8 47 01 00 00       	call   139b <read>
    1254:	83 c4 10             	add    $0x10,%esp
    1257:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    125a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    125e:	7e 33                	jle    1293 <gets+0x5e>
      break;
    buf[i++] = c;
    1260:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1263:	8d 50 01             	lea    0x1(%eax),%edx
    1266:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1269:	89 c2                	mov    %eax,%edx
    126b:	8b 45 08             	mov    0x8(%ebp),%eax
    126e:	01 c2                	add    %eax,%edx
    1270:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1274:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1276:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    127a:	3c 0a                	cmp    $0xa,%al
    127c:	74 16                	je     1294 <gets+0x5f>
    127e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1282:	3c 0d                	cmp    $0xd,%al
    1284:	74 0e                	je     1294 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1286:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1289:	83 c0 01             	add    $0x1,%eax
    128c:	3b 45 0c             	cmp    0xc(%ebp),%eax
    128f:	7c b3                	jl     1244 <gets+0xf>
    1291:	eb 01                	jmp    1294 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1293:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1294:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1297:	8b 45 08             	mov    0x8(%ebp),%eax
    129a:	01 d0                	add    %edx,%eax
    129c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    129f:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12a2:	c9                   	leave  
    12a3:	c3                   	ret    

000012a4 <stat>:

int
stat(char *n, struct stat *st)
{
    12a4:	55                   	push   %ebp
    12a5:	89 e5                	mov    %esp,%ebp
    12a7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    12aa:	83 ec 08             	sub    $0x8,%esp
    12ad:	6a 00                	push   $0x0
    12af:	ff 75 08             	pushl  0x8(%ebp)
    12b2:	e8 0c 01 00 00       	call   13c3 <open>
    12b7:	83 c4 10             	add    $0x10,%esp
    12ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    12bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12c1:	79 07                	jns    12ca <stat+0x26>
    return -1;
    12c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    12c8:	eb 25                	jmp    12ef <stat+0x4b>
  r = fstat(fd, st);
    12ca:	83 ec 08             	sub    $0x8,%esp
    12cd:	ff 75 0c             	pushl  0xc(%ebp)
    12d0:	ff 75 f4             	pushl  -0xc(%ebp)
    12d3:	e8 03 01 00 00       	call   13db <fstat>
    12d8:	83 c4 10             	add    $0x10,%esp
    12db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    12de:	83 ec 0c             	sub    $0xc,%esp
    12e1:	ff 75 f4             	pushl  -0xc(%ebp)
    12e4:	e8 c2 00 00 00       	call   13ab <close>
    12e9:	83 c4 10             	add    $0x10,%esp
  return r;
    12ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    12ef:	c9                   	leave  
    12f0:	c3                   	ret    

000012f1 <atoi>:

int
atoi(const char *s)
{
    12f1:	55                   	push   %ebp
    12f2:	89 e5                	mov    %esp,%ebp
    12f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    12f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    12fe:	eb 25                	jmp    1325 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1300:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1303:	89 d0                	mov    %edx,%eax
    1305:	c1 e0 02             	shl    $0x2,%eax
    1308:	01 d0                	add    %edx,%eax
    130a:	01 c0                	add    %eax,%eax
    130c:	89 c1                	mov    %eax,%ecx
    130e:	8b 45 08             	mov    0x8(%ebp),%eax
    1311:	8d 50 01             	lea    0x1(%eax),%edx
    1314:	89 55 08             	mov    %edx,0x8(%ebp)
    1317:	0f b6 00             	movzbl (%eax),%eax
    131a:	0f be c0             	movsbl %al,%eax
    131d:	01 c8                	add    %ecx,%eax
    131f:	83 e8 30             	sub    $0x30,%eax
    1322:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1325:	8b 45 08             	mov    0x8(%ebp),%eax
    1328:	0f b6 00             	movzbl (%eax),%eax
    132b:	3c 2f                	cmp    $0x2f,%al
    132d:	7e 0a                	jle    1339 <atoi+0x48>
    132f:	8b 45 08             	mov    0x8(%ebp),%eax
    1332:	0f b6 00             	movzbl (%eax),%eax
    1335:	3c 39                	cmp    $0x39,%al
    1337:	7e c7                	jle    1300 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1339:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    133c:	c9                   	leave  
    133d:	c3                   	ret    

0000133e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    133e:	55                   	push   %ebp
    133f:	89 e5                	mov    %esp,%ebp
    1341:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1344:	8b 45 08             	mov    0x8(%ebp),%eax
    1347:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    134a:	8b 45 0c             	mov    0xc(%ebp),%eax
    134d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1350:	eb 17                	jmp    1369 <memmove+0x2b>
    *dst++ = *src++;
    1352:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1355:	8d 50 01             	lea    0x1(%eax),%edx
    1358:	89 55 fc             	mov    %edx,-0x4(%ebp)
    135b:	8b 55 f8             	mov    -0x8(%ebp),%edx
    135e:	8d 4a 01             	lea    0x1(%edx),%ecx
    1361:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1364:	0f b6 12             	movzbl (%edx),%edx
    1367:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1369:	8b 45 10             	mov    0x10(%ebp),%eax
    136c:	8d 50 ff             	lea    -0x1(%eax),%edx
    136f:	89 55 10             	mov    %edx,0x10(%ebp)
    1372:	85 c0                	test   %eax,%eax
    1374:	7f dc                	jg     1352 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1376:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1379:	c9                   	leave  
    137a:	c3                   	ret    

0000137b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    137b:	b8 01 00 00 00       	mov    $0x1,%eax
    1380:	cd 40                	int    $0x40
    1382:	c3                   	ret    

00001383 <exit>:
SYSCALL(exit)
    1383:	b8 02 00 00 00       	mov    $0x2,%eax
    1388:	cd 40                	int    $0x40
    138a:	c3                   	ret    

0000138b <wait>:
SYSCALL(wait)
    138b:	b8 03 00 00 00       	mov    $0x3,%eax
    1390:	cd 40                	int    $0x40
    1392:	c3                   	ret    

00001393 <pipe>:
SYSCALL(pipe)
    1393:	b8 04 00 00 00       	mov    $0x4,%eax
    1398:	cd 40                	int    $0x40
    139a:	c3                   	ret    

0000139b <read>:
SYSCALL(read)
    139b:	b8 05 00 00 00       	mov    $0x5,%eax
    13a0:	cd 40                	int    $0x40
    13a2:	c3                   	ret    

000013a3 <write>:
SYSCALL(write)
    13a3:	b8 10 00 00 00       	mov    $0x10,%eax
    13a8:	cd 40                	int    $0x40
    13aa:	c3                   	ret    

000013ab <close>:
SYSCALL(close)
    13ab:	b8 15 00 00 00       	mov    $0x15,%eax
    13b0:	cd 40                	int    $0x40
    13b2:	c3                   	ret    

000013b3 <kill>:
SYSCALL(kill)
    13b3:	b8 06 00 00 00       	mov    $0x6,%eax
    13b8:	cd 40                	int    $0x40
    13ba:	c3                   	ret    

000013bb <exec>:
SYSCALL(exec)
    13bb:	b8 07 00 00 00       	mov    $0x7,%eax
    13c0:	cd 40                	int    $0x40
    13c2:	c3                   	ret    

000013c3 <open>:
SYSCALL(open)
    13c3:	b8 0f 00 00 00       	mov    $0xf,%eax
    13c8:	cd 40                	int    $0x40
    13ca:	c3                   	ret    

000013cb <mknod>:
SYSCALL(mknod)
    13cb:	b8 11 00 00 00       	mov    $0x11,%eax
    13d0:	cd 40                	int    $0x40
    13d2:	c3                   	ret    

000013d3 <unlink>:
SYSCALL(unlink)
    13d3:	b8 12 00 00 00       	mov    $0x12,%eax
    13d8:	cd 40                	int    $0x40
    13da:	c3                   	ret    

000013db <fstat>:
SYSCALL(fstat)
    13db:	b8 08 00 00 00       	mov    $0x8,%eax
    13e0:	cd 40                	int    $0x40
    13e2:	c3                   	ret    

000013e3 <link>:
SYSCALL(link)
    13e3:	b8 13 00 00 00       	mov    $0x13,%eax
    13e8:	cd 40                	int    $0x40
    13ea:	c3                   	ret    

000013eb <mkdir>:
SYSCALL(mkdir)
    13eb:	b8 14 00 00 00       	mov    $0x14,%eax
    13f0:	cd 40                	int    $0x40
    13f2:	c3                   	ret    

000013f3 <chdir>:
SYSCALL(chdir)
    13f3:	b8 09 00 00 00       	mov    $0x9,%eax
    13f8:	cd 40                	int    $0x40
    13fa:	c3                   	ret    

000013fb <dup>:
SYSCALL(dup)
    13fb:	b8 0a 00 00 00       	mov    $0xa,%eax
    1400:	cd 40                	int    $0x40
    1402:	c3                   	ret    

00001403 <getpid>:
SYSCALL(getpid)
    1403:	b8 0b 00 00 00       	mov    $0xb,%eax
    1408:	cd 40                	int    $0x40
    140a:	c3                   	ret    

0000140b <sbrk>:
SYSCALL(sbrk)
    140b:	b8 0c 00 00 00       	mov    $0xc,%eax
    1410:	cd 40                	int    $0x40
    1412:	c3                   	ret    

00001413 <sleep>:
SYSCALL(sleep)
    1413:	b8 0d 00 00 00       	mov    $0xd,%eax
    1418:	cd 40                	int    $0x40
    141a:	c3                   	ret    

0000141b <uptime>:
SYSCALL(uptime)
    141b:	b8 0e 00 00 00       	mov    $0xe,%eax
    1420:	cd 40                	int    $0x40
    1422:	c3                   	ret    

00001423 <shm_open>:
SYSCALL(shm_open)
    1423:	b8 16 00 00 00       	mov    $0x16,%eax
    1428:	cd 40                	int    $0x40
    142a:	c3                   	ret    

0000142b <shm_close>:
SYSCALL(shm_close)	
    142b:	b8 17 00 00 00       	mov    $0x17,%eax
    1430:	cd 40                	int    $0x40
    1432:	c3                   	ret    

00001433 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1433:	55                   	push   %ebp
    1434:	89 e5                	mov    %esp,%ebp
    1436:	83 ec 18             	sub    $0x18,%esp
    1439:	8b 45 0c             	mov    0xc(%ebp),%eax
    143c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    143f:	83 ec 04             	sub    $0x4,%esp
    1442:	6a 01                	push   $0x1
    1444:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1447:	50                   	push   %eax
    1448:	ff 75 08             	pushl  0x8(%ebp)
    144b:	e8 53 ff ff ff       	call   13a3 <write>
    1450:	83 c4 10             	add    $0x10,%esp
}
    1453:	90                   	nop
    1454:	c9                   	leave  
    1455:	c3                   	ret    

00001456 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1456:	55                   	push   %ebp
    1457:	89 e5                	mov    %esp,%ebp
    1459:	53                   	push   %ebx
    145a:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    145d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1464:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1468:	74 17                	je     1481 <printint+0x2b>
    146a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    146e:	79 11                	jns    1481 <printint+0x2b>
    neg = 1;
    1470:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1477:	8b 45 0c             	mov    0xc(%ebp),%eax
    147a:	f7 d8                	neg    %eax
    147c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    147f:	eb 06                	jmp    1487 <printint+0x31>
  } else {
    x = xx;
    1481:	8b 45 0c             	mov    0xc(%ebp),%eax
    1484:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1487:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    148e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1491:	8d 41 01             	lea    0x1(%ecx),%eax
    1494:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1497:	8b 5d 10             	mov    0x10(%ebp),%ebx
    149a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    149d:	ba 00 00 00 00       	mov    $0x0,%edx
    14a2:	f7 f3                	div    %ebx
    14a4:	89 d0                	mov    %edx,%eax
    14a6:	0f b6 80 24 1c 00 00 	movzbl 0x1c24(%eax),%eax
    14ad:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    14b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    14b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14b7:	ba 00 00 00 00       	mov    $0x0,%edx
    14bc:	f7 f3                	div    %ebx
    14be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    14c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14c5:	75 c7                	jne    148e <printint+0x38>
  if(neg)
    14c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14cb:	74 2d                	je     14fa <printint+0xa4>
    buf[i++] = '-';
    14cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14d0:	8d 50 01             	lea    0x1(%eax),%edx
    14d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
    14d6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    14db:	eb 1d                	jmp    14fa <printint+0xa4>
    putc(fd, buf[i]);
    14dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
    14e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14e3:	01 d0                	add    %edx,%eax
    14e5:	0f b6 00             	movzbl (%eax),%eax
    14e8:	0f be c0             	movsbl %al,%eax
    14eb:	83 ec 08             	sub    $0x8,%esp
    14ee:	50                   	push   %eax
    14ef:	ff 75 08             	pushl  0x8(%ebp)
    14f2:	e8 3c ff ff ff       	call   1433 <putc>
    14f7:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    14fa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1502:	79 d9                	jns    14dd <printint+0x87>
    putc(fd, buf[i]);
}
    1504:	90                   	nop
    1505:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1508:	c9                   	leave  
    1509:	c3                   	ret    

0000150a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    150a:	55                   	push   %ebp
    150b:	89 e5                	mov    %esp,%ebp
    150d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1510:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1517:	8d 45 0c             	lea    0xc(%ebp),%eax
    151a:	83 c0 04             	add    $0x4,%eax
    151d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1520:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1527:	e9 59 01 00 00       	jmp    1685 <printf+0x17b>
    c = fmt[i] & 0xff;
    152c:	8b 55 0c             	mov    0xc(%ebp),%edx
    152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1532:	01 d0                	add    %edx,%eax
    1534:	0f b6 00             	movzbl (%eax),%eax
    1537:	0f be c0             	movsbl %al,%eax
    153a:	25 ff 00 00 00       	and    $0xff,%eax
    153f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1542:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1546:	75 2c                	jne    1574 <printf+0x6a>
      if(c == '%'){
    1548:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    154c:	75 0c                	jne    155a <printf+0x50>
        state = '%';
    154e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1555:	e9 27 01 00 00       	jmp    1681 <printf+0x177>
      } else {
        putc(fd, c);
    155a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    155d:	0f be c0             	movsbl %al,%eax
    1560:	83 ec 08             	sub    $0x8,%esp
    1563:	50                   	push   %eax
    1564:	ff 75 08             	pushl  0x8(%ebp)
    1567:	e8 c7 fe ff ff       	call   1433 <putc>
    156c:	83 c4 10             	add    $0x10,%esp
    156f:	e9 0d 01 00 00       	jmp    1681 <printf+0x177>
      }
    } else if(state == '%'){
    1574:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1578:	0f 85 03 01 00 00    	jne    1681 <printf+0x177>
      if(c == 'd'){
    157e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1582:	75 1e                	jne    15a2 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1584:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1587:	8b 00                	mov    (%eax),%eax
    1589:	6a 01                	push   $0x1
    158b:	6a 0a                	push   $0xa
    158d:	50                   	push   %eax
    158e:	ff 75 08             	pushl  0x8(%ebp)
    1591:	e8 c0 fe ff ff       	call   1456 <printint>
    1596:	83 c4 10             	add    $0x10,%esp
        ap++;
    1599:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    159d:	e9 d8 00 00 00       	jmp    167a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    15a2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    15a6:	74 06                	je     15ae <printf+0xa4>
    15a8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    15ac:	75 1e                	jne    15cc <printf+0xc2>
        printint(fd, *ap, 16, 0);
    15ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15b1:	8b 00                	mov    (%eax),%eax
    15b3:	6a 00                	push   $0x0
    15b5:	6a 10                	push   $0x10
    15b7:	50                   	push   %eax
    15b8:	ff 75 08             	pushl  0x8(%ebp)
    15bb:	e8 96 fe ff ff       	call   1456 <printint>
    15c0:	83 c4 10             	add    $0x10,%esp
        ap++;
    15c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15c7:	e9 ae 00 00 00       	jmp    167a <printf+0x170>
      } else if(c == 's'){
    15cc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    15d0:	75 43                	jne    1615 <printf+0x10b>
        s = (char*)*ap;
    15d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15d5:	8b 00                	mov    (%eax),%eax
    15d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    15da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    15de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15e2:	75 25                	jne    1609 <printf+0xff>
          s = "(null)";
    15e4:	c7 45 f4 75 19 00 00 	movl   $0x1975,-0xc(%ebp)
        while(*s != 0){
    15eb:	eb 1c                	jmp    1609 <printf+0xff>
          putc(fd, *s);
    15ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15f0:	0f b6 00             	movzbl (%eax),%eax
    15f3:	0f be c0             	movsbl %al,%eax
    15f6:	83 ec 08             	sub    $0x8,%esp
    15f9:	50                   	push   %eax
    15fa:	ff 75 08             	pushl  0x8(%ebp)
    15fd:	e8 31 fe ff ff       	call   1433 <putc>
    1602:	83 c4 10             	add    $0x10,%esp
          s++;
    1605:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1609:	8b 45 f4             	mov    -0xc(%ebp),%eax
    160c:	0f b6 00             	movzbl (%eax),%eax
    160f:	84 c0                	test   %al,%al
    1611:	75 da                	jne    15ed <printf+0xe3>
    1613:	eb 65                	jmp    167a <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1615:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1619:	75 1d                	jne    1638 <printf+0x12e>
        putc(fd, *ap);
    161b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    161e:	8b 00                	mov    (%eax),%eax
    1620:	0f be c0             	movsbl %al,%eax
    1623:	83 ec 08             	sub    $0x8,%esp
    1626:	50                   	push   %eax
    1627:	ff 75 08             	pushl  0x8(%ebp)
    162a:	e8 04 fe ff ff       	call   1433 <putc>
    162f:	83 c4 10             	add    $0x10,%esp
        ap++;
    1632:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1636:	eb 42                	jmp    167a <printf+0x170>
      } else if(c == '%'){
    1638:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    163c:	75 17                	jne    1655 <printf+0x14b>
        putc(fd, c);
    163e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1641:	0f be c0             	movsbl %al,%eax
    1644:	83 ec 08             	sub    $0x8,%esp
    1647:	50                   	push   %eax
    1648:	ff 75 08             	pushl  0x8(%ebp)
    164b:	e8 e3 fd ff ff       	call   1433 <putc>
    1650:	83 c4 10             	add    $0x10,%esp
    1653:	eb 25                	jmp    167a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1655:	83 ec 08             	sub    $0x8,%esp
    1658:	6a 25                	push   $0x25
    165a:	ff 75 08             	pushl  0x8(%ebp)
    165d:	e8 d1 fd ff ff       	call   1433 <putc>
    1662:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1668:	0f be c0             	movsbl %al,%eax
    166b:	83 ec 08             	sub    $0x8,%esp
    166e:	50                   	push   %eax
    166f:	ff 75 08             	pushl  0x8(%ebp)
    1672:	e8 bc fd ff ff       	call   1433 <putc>
    1677:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    167a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1681:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1685:	8b 55 0c             	mov    0xc(%ebp),%edx
    1688:	8b 45 f0             	mov    -0x10(%ebp),%eax
    168b:	01 d0                	add    %edx,%eax
    168d:	0f b6 00             	movzbl (%eax),%eax
    1690:	84 c0                	test   %al,%al
    1692:	0f 85 94 fe ff ff    	jne    152c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1698:	90                   	nop
    1699:	c9                   	leave  
    169a:	c3                   	ret    

0000169b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    169b:	55                   	push   %ebp
    169c:	89 e5                	mov    %esp,%ebp
    169e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    16a1:	8b 45 08             	mov    0x8(%ebp),%eax
    16a4:	83 e8 08             	sub    $0x8,%eax
    16a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16aa:	a1 40 1c 00 00       	mov    0x1c40,%eax
    16af:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16b2:	eb 24                	jmp    16d8 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    16b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b7:	8b 00                	mov    (%eax),%eax
    16b9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16bc:	77 12                	ja     16d0 <free+0x35>
    16be:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16c4:	77 24                	ja     16ea <free+0x4f>
    16c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c9:	8b 00                	mov    (%eax),%eax
    16cb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16ce:	77 1a                	ja     16ea <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d3:	8b 00                	mov    (%eax),%eax
    16d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16de:	76 d4                	jbe    16b4 <free+0x19>
    16e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e3:	8b 00                	mov    (%eax),%eax
    16e5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16e8:	76 ca                	jbe    16b4 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ed:	8b 40 04             	mov    0x4(%eax),%eax
    16f0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16fa:	01 c2                	add    %eax,%edx
    16fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ff:	8b 00                	mov    (%eax),%eax
    1701:	39 c2                	cmp    %eax,%edx
    1703:	75 24                	jne    1729 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1705:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1708:	8b 50 04             	mov    0x4(%eax),%edx
    170b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    170e:	8b 00                	mov    (%eax),%eax
    1710:	8b 40 04             	mov    0x4(%eax),%eax
    1713:	01 c2                	add    %eax,%edx
    1715:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1718:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    171b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    171e:	8b 00                	mov    (%eax),%eax
    1720:	8b 10                	mov    (%eax),%edx
    1722:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1725:	89 10                	mov    %edx,(%eax)
    1727:	eb 0a                	jmp    1733 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1729:	8b 45 fc             	mov    -0x4(%ebp),%eax
    172c:	8b 10                	mov    (%eax),%edx
    172e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1731:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1733:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1736:	8b 40 04             	mov    0x4(%eax),%eax
    1739:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1740:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1743:	01 d0                	add    %edx,%eax
    1745:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1748:	75 20                	jne    176a <free+0xcf>
    p->s.size += bp->s.size;
    174a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    174d:	8b 50 04             	mov    0x4(%eax),%edx
    1750:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1753:	8b 40 04             	mov    0x4(%eax),%eax
    1756:	01 c2                	add    %eax,%edx
    1758:	8b 45 fc             	mov    -0x4(%ebp),%eax
    175b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    175e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1761:	8b 10                	mov    (%eax),%edx
    1763:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1766:	89 10                	mov    %edx,(%eax)
    1768:	eb 08                	jmp    1772 <free+0xd7>
  } else
    p->s.ptr = bp;
    176a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    176d:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1770:	89 10                	mov    %edx,(%eax)
  freep = p;
    1772:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1775:	a3 40 1c 00 00       	mov    %eax,0x1c40
}
    177a:	90                   	nop
    177b:	c9                   	leave  
    177c:	c3                   	ret    

0000177d <morecore>:

static Header*
morecore(uint nu)
{
    177d:	55                   	push   %ebp
    177e:	89 e5                	mov    %esp,%ebp
    1780:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1783:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    178a:	77 07                	ja     1793 <morecore+0x16>
    nu = 4096;
    178c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1793:	8b 45 08             	mov    0x8(%ebp),%eax
    1796:	c1 e0 03             	shl    $0x3,%eax
    1799:	83 ec 0c             	sub    $0xc,%esp
    179c:	50                   	push   %eax
    179d:	e8 69 fc ff ff       	call   140b <sbrk>
    17a2:	83 c4 10             	add    $0x10,%esp
    17a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    17a8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    17ac:	75 07                	jne    17b5 <morecore+0x38>
    return 0;
    17ae:	b8 00 00 00 00       	mov    $0x0,%eax
    17b3:	eb 26                	jmp    17db <morecore+0x5e>
  hp = (Header*)p;
    17b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    17bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17be:	8b 55 08             	mov    0x8(%ebp),%edx
    17c1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    17c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17c7:	83 c0 08             	add    $0x8,%eax
    17ca:	83 ec 0c             	sub    $0xc,%esp
    17cd:	50                   	push   %eax
    17ce:	e8 c8 fe ff ff       	call   169b <free>
    17d3:	83 c4 10             	add    $0x10,%esp
  return freep;
    17d6:	a1 40 1c 00 00       	mov    0x1c40,%eax
}
    17db:	c9                   	leave  
    17dc:	c3                   	ret    

000017dd <malloc>:

void*
malloc(uint nbytes)
{
    17dd:	55                   	push   %ebp
    17de:	89 e5                	mov    %esp,%ebp
    17e0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    17e3:	8b 45 08             	mov    0x8(%ebp),%eax
    17e6:	83 c0 07             	add    $0x7,%eax
    17e9:	c1 e8 03             	shr    $0x3,%eax
    17ec:	83 c0 01             	add    $0x1,%eax
    17ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17f2:	a1 40 1c 00 00       	mov    0x1c40,%eax
    17f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17fe:	75 23                	jne    1823 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1800:	c7 45 f0 38 1c 00 00 	movl   $0x1c38,-0x10(%ebp)
    1807:	8b 45 f0             	mov    -0x10(%ebp),%eax
    180a:	a3 40 1c 00 00       	mov    %eax,0x1c40
    180f:	a1 40 1c 00 00       	mov    0x1c40,%eax
    1814:	a3 38 1c 00 00       	mov    %eax,0x1c38
    base.s.size = 0;
    1819:	c7 05 3c 1c 00 00 00 	movl   $0x0,0x1c3c
    1820:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1823:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1826:	8b 00                	mov    (%eax),%eax
    1828:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    182b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    182e:	8b 40 04             	mov    0x4(%eax),%eax
    1831:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1834:	72 4d                	jb     1883 <malloc+0xa6>
      if(p->s.size == nunits)
    1836:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1839:	8b 40 04             	mov    0x4(%eax),%eax
    183c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    183f:	75 0c                	jne    184d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1841:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1844:	8b 10                	mov    (%eax),%edx
    1846:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1849:	89 10                	mov    %edx,(%eax)
    184b:	eb 26                	jmp    1873 <malloc+0x96>
      else {
        p->s.size -= nunits;
    184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1850:	8b 40 04             	mov    0x4(%eax),%eax
    1853:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1856:	89 c2                	mov    %eax,%edx
    1858:	8b 45 f4             	mov    -0xc(%ebp),%eax
    185b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    185e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1861:	8b 40 04             	mov    0x4(%eax),%eax
    1864:	c1 e0 03             	shl    $0x3,%eax
    1867:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    186a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    186d:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1870:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1873:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1876:	a3 40 1c 00 00       	mov    %eax,0x1c40
      return (void*)(p + 1);
    187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    187e:	83 c0 08             	add    $0x8,%eax
    1881:	eb 3b                	jmp    18be <malloc+0xe1>
    }
    if(p == freep)
    1883:	a1 40 1c 00 00       	mov    0x1c40,%eax
    1888:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    188b:	75 1e                	jne    18ab <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    188d:	83 ec 0c             	sub    $0xc,%esp
    1890:	ff 75 ec             	pushl  -0x14(%ebp)
    1893:	e8 e5 fe ff ff       	call   177d <morecore>
    1898:	83 c4 10             	add    $0x10,%esp
    189b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    189e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    18a2:	75 07                	jne    18ab <malloc+0xce>
        return 0;
    18a4:	b8 00 00 00 00       	mov    $0x0,%eax
    18a9:	eb 13                	jmp    18be <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    18ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    18b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18b4:	8b 00                	mov    (%eax),%eax
    18b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    18b9:	e9 6d ff ff ff       	jmp    182b <malloc+0x4e>
}
    18be:	c9                   	leave  
    18bf:	c3                   	ret    

000018c0 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    18c0:	55                   	push   %ebp
    18c1:	89 e5                	mov    %esp,%ebp
    18c3:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    18c6:	8b 55 08             	mov    0x8(%ebp),%edx
    18c9:	8b 45 0c             	mov    0xc(%ebp),%eax
    18cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
    18cf:	f0 87 02             	lock xchg %eax,(%edx)
    18d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    18d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    18d8:	c9                   	leave  
    18d9:	c3                   	ret    

000018da <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    18da:	55                   	push   %ebp
    18db:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    18dd:	90                   	nop
    18de:	8b 45 08             	mov    0x8(%ebp),%eax
    18e1:	6a 01                	push   $0x1
    18e3:	50                   	push   %eax
    18e4:	e8 d7 ff ff ff       	call   18c0 <xchg>
    18e9:	83 c4 08             	add    $0x8,%esp
    18ec:	85 c0                	test   %eax,%eax
    18ee:	75 ee                	jne    18de <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    18f0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    18f5:	90                   	nop
    18f6:	c9                   	leave  
    18f7:	c3                   	ret    

000018f8 <urelease>:

void urelease (struct uspinlock *lk) {
    18f8:	55                   	push   %ebp
    18f9:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    18fb:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1900:	8b 45 08             	mov    0x8(%ebp),%eax
    1903:	8b 55 08             	mov    0x8(%ebp),%edx
    1906:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    190c:	90                   	nop
    190d:	5d                   	pop    %ebp
    190e:	c3                   	ret    
