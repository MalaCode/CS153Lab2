
_ls:     file format elf32-i386


Disassembly of section .text:

00001000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	53                   	push   %ebx
    1004:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
    1007:	83 ec 0c             	sub    $0xc,%esp
    100a:	ff 75 08             	pushl  0x8(%ebp)
    100d:	e8 c9 03 00 00       	call   13db <strlen>
    1012:	83 c4 10             	add    $0x10,%esp
    1015:	89 c2                	mov    %eax,%edx
    1017:	8b 45 08             	mov    0x8(%ebp),%eax
    101a:	01 d0                	add    %edx,%eax
    101c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    101f:	eb 04                	jmp    1025 <fmtname+0x25>
    1021:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1025:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1028:	3b 45 08             	cmp    0x8(%ebp),%eax
    102b:	72 0a                	jb     1037 <fmtname+0x37>
    102d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1030:	0f b6 00             	movzbl (%eax),%eax
    1033:	3c 2f                	cmp    $0x2f,%al
    1035:	75 ea                	jne    1021 <fmtname+0x21>
    ;
  p++;
    1037:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
    103b:	83 ec 0c             	sub    $0xc,%esp
    103e:	ff 75 f4             	pushl  -0xc(%ebp)
    1041:	e8 95 03 00 00       	call   13db <strlen>
    1046:	83 c4 10             	add    $0x10,%esp
    1049:	83 f8 0d             	cmp    $0xd,%eax
    104c:	76 05                	jbe    1053 <fmtname+0x53>
    return p;
    104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1051:	eb 60                	jmp    10b3 <fmtname+0xb3>
  memmove(buf, p, strlen(p));
    1053:	83 ec 0c             	sub    $0xc,%esp
    1056:	ff 75 f4             	pushl  -0xc(%ebp)
    1059:	e8 7d 03 00 00       	call   13db <strlen>
    105e:	83 c4 10             	add    $0x10,%esp
    1061:	83 ec 04             	sub    $0x4,%esp
    1064:	50                   	push   %eax
    1065:	ff 75 f4             	pushl  -0xc(%ebp)
    1068:	68 90 1e 00 00       	push   $0x1e90
    106d:	e8 e6 04 00 00       	call   1558 <memmove>
    1072:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
    1075:	83 ec 0c             	sub    $0xc,%esp
    1078:	ff 75 f4             	pushl  -0xc(%ebp)
    107b:	e8 5b 03 00 00       	call   13db <strlen>
    1080:	83 c4 10             	add    $0x10,%esp
    1083:	ba 0e 00 00 00       	mov    $0xe,%edx
    1088:	89 d3                	mov    %edx,%ebx
    108a:	29 c3                	sub    %eax,%ebx
    108c:	83 ec 0c             	sub    $0xc,%esp
    108f:	ff 75 f4             	pushl  -0xc(%ebp)
    1092:	e8 44 03 00 00       	call   13db <strlen>
    1097:	83 c4 10             	add    $0x10,%esp
    109a:	05 90 1e 00 00       	add    $0x1e90,%eax
    109f:	83 ec 04             	sub    $0x4,%esp
    10a2:	53                   	push   %ebx
    10a3:	6a 20                	push   $0x20
    10a5:	50                   	push   %eax
    10a6:	e8 57 03 00 00       	call   1402 <memset>
    10ab:	83 c4 10             	add    $0x10,%esp
  return buf;
    10ae:	b8 90 1e 00 00       	mov    $0x1e90,%eax
}
    10b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    10b6:	c9                   	leave  
    10b7:	c3                   	ret    

000010b8 <ls>:

void
ls(char *path)
{
    10b8:	55                   	push   %ebp
    10b9:	89 e5                	mov    %esp,%ebp
    10bb:	57                   	push   %edi
    10bc:	56                   	push   %esi
    10bd:	53                   	push   %ebx
    10be:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
    10c4:	83 ec 08             	sub    $0x8,%esp
    10c7:	6a 00                	push   $0x0
    10c9:	ff 75 08             	pushl  0x8(%ebp)
    10cc:	e8 0c 05 00 00       	call   15dd <open>
    10d1:	83 c4 10             	add    $0x10,%esp
    10d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    10d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    10db:	79 1a                	jns    10f7 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
    10dd:	83 ec 04             	sub    $0x4,%esp
    10e0:	ff 75 08             	pushl  0x8(%ebp)
    10e3:	68 29 1b 00 00       	push   $0x1b29
    10e8:	6a 02                	push   $0x2
    10ea:	e8 35 06 00 00       	call   1724 <printf>
    10ef:	83 c4 10             	add    $0x10,%esp
    return;
    10f2:	e9 e3 01 00 00       	jmp    12da <ls+0x222>
  }

  if(fstat(fd, &st) < 0){
    10f7:	83 ec 08             	sub    $0x8,%esp
    10fa:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
    1100:	50                   	push   %eax
    1101:	ff 75 e4             	pushl  -0x1c(%ebp)
    1104:	e8 ec 04 00 00       	call   15f5 <fstat>
    1109:	83 c4 10             	add    $0x10,%esp
    110c:	85 c0                	test   %eax,%eax
    110e:	79 28                	jns    1138 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
    1110:	83 ec 04             	sub    $0x4,%esp
    1113:	ff 75 08             	pushl  0x8(%ebp)
    1116:	68 3d 1b 00 00       	push   $0x1b3d
    111b:	6a 02                	push   $0x2
    111d:	e8 02 06 00 00       	call   1724 <printf>
    1122:	83 c4 10             	add    $0x10,%esp
    close(fd);
    1125:	83 ec 0c             	sub    $0xc,%esp
    1128:	ff 75 e4             	pushl  -0x1c(%ebp)
    112b:	e8 95 04 00 00       	call   15c5 <close>
    1130:	83 c4 10             	add    $0x10,%esp
    return;
    1133:	e9 a2 01 00 00       	jmp    12da <ls+0x222>
  }

  switch(st.type){
    1138:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
    113f:	98                   	cwtl   
    1140:	83 f8 01             	cmp    $0x1,%eax
    1143:	74 48                	je     118d <ls+0xd5>
    1145:	83 f8 02             	cmp    $0x2,%eax
    1148:	0f 85 7e 01 00 00    	jne    12cc <ls+0x214>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
    114e:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
    1154:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
    115a:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
    1161:	0f bf d8             	movswl %ax,%ebx
    1164:	83 ec 0c             	sub    $0xc,%esp
    1167:	ff 75 08             	pushl  0x8(%ebp)
    116a:	e8 91 fe ff ff       	call   1000 <fmtname>
    116f:	83 c4 10             	add    $0x10,%esp
    1172:	83 ec 08             	sub    $0x8,%esp
    1175:	57                   	push   %edi
    1176:	56                   	push   %esi
    1177:	53                   	push   %ebx
    1178:	50                   	push   %eax
    1179:	68 51 1b 00 00       	push   $0x1b51
    117e:	6a 01                	push   $0x1
    1180:	e8 9f 05 00 00       	call   1724 <printf>
    1185:	83 c4 20             	add    $0x20,%esp
    break;
    1188:	e9 3f 01 00 00       	jmp    12cc <ls+0x214>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
    118d:	83 ec 0c             	sub    $0xc,%esp
    1190:	ff 75 08             	pushl  0x8(%ebp)
    1193:	e8 43 02 00 00       	call   13db <strlen>
    1198:	83 c4 10             	add    $0x10,%esp
    119b:	83 c0 10             	add    $0x10,%eax
    119e:	3d 00 02 00 00       	cmp    $0x200,%eax
    11a3:	76 17                	jbe    11bc <ls+0x104>
      printf(1, "ls: path too long\n");
    11a5:	83 ec 08             	sub    $0x8,%esp
    11a8:	68 5e 1b 00 00       	push   $0x1b5e
    11ad:	6a 01                	push   $0x1
    11af:	e8 70 05 00 00       	call   1724 <printf>
    11b4:	83 c4 10             	add    $0x10,%esp
      break;
    11b7:	e9 10 01 00 00       	jmp    12cc <ls+0x214>
    }
    strcpy(buf, path);
    11bc:	83 ec 08             	sub    $0x8,%esp
    11bf:	ff 75 08             	pushl  0x8(%ebp)
    11c2:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
    11c8:	50                   	push   %eax
    11c9:	e8 9e 01 00 00       	call   136c <strcpy>
    11ce:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
    11d1:	83 ec 0c             	sub    $0xc,%esp
    11d4:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
    11da:	50                   	push   %eax
    11db:	e8 fb 01 00 00       	call   13db <strlen>
    11e0:	83 c4 10             	add    $0x10,%esp
    11e3:	89 c2                	mov    %eax,%edx
    11e5:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
    11eb:	01 d0                	add    %edx,%eax
    11ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
    11f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
    11f3:	8d 50 01             	lea    0x1(%eax),%edx
    11f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
    11f9:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
    11fc:	e9 aa 00 00 00       	jmp    12ab <ls+0x1f3>
      if(de.inum == 0)
    1201:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
    1208:	66 85 c0             	test   %ax,%ax
    120b:	75 05                	jne    1212 <ls+0x15a>
        continue;
    120d:	e9 99 00 00 00       	jmp    12ab <ls+0x1f3>
      memmove(p, de.name, DIRSIZ);
    1212:	83 ec 04             	sub    $0x4,%esp
    1215:	6a 0e                	push   $0xe
    1217:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
    121d:	83 c0 02             	add    $0x2,%eax
    1220:	50                   	push   %eax
    1221:	ff 75 e0             	pushl  -0x20(%ebp)
    1224:	e8 2f 03 00 00       	call   1558 <memmove>
    1229:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
    122c:	8b 45 e0             	mov    -0x20(%ebp),%eax
    122f:	83 c0 0e             	add    $0xe,%eax
    1232:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
    1235:	83 ec 08             	sub    $0x8,%esp
    1238:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
    123e:	50                   	push   %eax
    123f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
    1245:	50                   	push   %eax
    1246:	e8 73 02 00 00       	call   14be <stat>
    124b:	83 c4 10             	add    $0x10,%esp
    124e:	85 c0                	test   %eax,%eax
    1250:	79 1b                	jns    126d <ls+0x1b5>
        printf(1, "ls: cannot stat %s\n", buf);
    1252:	83 ec 04             	sub    $0x4,%esp
    1255:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
    125b:	50                   	push   %eax
    125c:	68 3d 1b 00 00       	push   $0x1b3d
    1261:	6a 01                	push   $0x1
    1263:	e8 bc 04 00 00       	call   1724 <printf>
    1268:	83 c4 10             	add    $0x10,%esp
        continue;
    126b:	eb 3e                	jmp    12ab <ls+0x1f3>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    126d:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
    1273:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
    1279:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
    1280:	0f bf d8             	movswl %ax,%ebx
    1283:	83 ec 0c             	sub    $0xc,%esp
    1286:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
    128c:	50                   	push   %eax
    128d:	e8 6e fd ff ff       	call   1000 <fmtname>
    1292:	83 c4 10             	add    $0x10,%esp
    1295:	83 ec 08             	sub    $0x8,%esp
    1298:	57                   	push   %edi
    1299:	56                   	push   %esi
    129a:	53                   	push   %ebx
    129b:	50                   	push   %eax
    129c:	68 51 1b 00 00       	push   $0x1b51
    12a1:	6a 01                	push   $0x1
    12a3:	e8 7c 04 00 00       	call   1724 <printf>
    12a8:	83 c4 20             	add    $0x20,%esp
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
    12ab:	83 ec 04             	sub    $0x4,%esp
    12ae:	6a 10                	push   $0x10
    12b0:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
    12b6:	50                   	push   %eax
    12b7:	ff 75 e4             	pushl  -0x1c(%ebp)
    12ba:	e8 f6 02 00 00       	call   15b5 <read>
    12bf:	83 c4 10             	add    $0x10,%esp
    12c2:	83 f8 10             	cmp    $0x10,%eax
    12c5:	0f 84 36 ff ff ff    	je     1201 <ls+0x149>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
    12cb:	90                   	nop
  }
  close(fd);
    12cc:	83 ec 0c             	sub    $0xc,%esp
    12cf:	ff 75 e4             	pushl  -0x1c(%ebp)
    12d2:	e8 ee 02 00 00       	call   15c5 <close>
    12d7:	83 c4 10             	add    $0x10,%esp
}
    12da:	8d 65 f4             	lea    -0xc(%ebp),%esp
    12dd:	5b                   	pop    %ebx
    12de:	5e                   	pop    %esi
    12df:	5f                   	pop    %edi
    12e0:	5d                   	pop    %ebp
    12e1:	c3                   	ret    

000012e2 <main>:

int
main(int argc, char *argv[])
{
    12e2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    12e6:	83 e4 f0             	and    $0xfffffff0,%esp
    12e9:	ff 71 fc             	pushl  -0x4(%ecx)
    12ec:	55                   	push   %ebp
    12ed:	89 e5                	mov    %esp,%ebp
    12ef:	53                   	push   %ebx
    12f0:	51                   	push   %ecx
    12f1:	83 ec 10             	sub    $0x10,%esp
    12f4:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
    12f6:	83 3b 01             	cmpl   $0x1,(%ebx)
    12f9:	7f 15                	jg     1310 <main+0x2e>
    ls(".");
    12fb:	83 ec 0c             	sub    $0xc,%esp
    12fe:	68 71 1b 00 00       	push   $0x1b71
    1303:	e8 b0 fd ff ff       	call   10b8 <ls>
    1308:	83 c4 10             	add    $0x10,%esp
    exit();
    130b:	e8 8d 02 00 00       	call   159d <exit>
  }
  for(i=1; i<argc; i++)
    1310:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    1317:	eb 21                	jmp    133a <main+0x58>
    ls(argv[i]);
    1319:	8b 45 f4             	mov    -0xc(%ebp),%eax
    131c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    1323:	8b 43 04             	mov    0x4(%ebx),%eax
    1326:	01 d0                	add    %edx,%eax
    1328:	8b 00                	mov    (%eax),%eax
    132a:	83 ec 0c             	sub    $0xc,%esp
    132d:	50                   	push   %eax
    132e:	e8 85 fd ff ff       	call   10b8 <ls>
    1333:	83 c4 10             	add    $0x10,%esp

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
    1336:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    133a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    133d:	3b 03                	cmp    (%ebx),%eax
    133f:	7c d8                	jl     1319 <main+0x37>
    ls(argv[i]);
  exit();
    1341:	e8 57 02 00 00       	call   159d <exit>

00001346 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1346:	55                   	push   %ebp
    1347:	89 e5                	mov    %esp,%ebp
    1349:	57                   	push   %edi
    134a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    134b:	8b 4d 08             	mov    0x8(%ebp),%ecx
    134e:	8b 55 10             	mov    0x10(%ebp),%edx
    1351:	8b 45 0c             	mov    0xc(%ebp),%eax
    1354:	89 cb                	mov    %ecx,%ebx
    1356:	89 df                	mov    %ebx,%edi
    1358:	89 d1                	mov    %edx,%ecx
    135a:	fc                   	cld    
    135b:	f3 aa                	rep stos %al,%es:(%edi)
    135d:	89 ca                	mov    %ecx,%edx
    135f:	89 fb                	mov    %edi,%ebx
    1361:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1364:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1367:	90                   	nop
    1368:	5b                   	pop    %ebx
    1369:	5f                   	pop    %edi
    136a:	5d                   	pop    %ebp
    136b:	c3                   	ret    

0000136c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    136c:	55                   	push   %ebp
    136d:	89 e5                	mov    %esp,%ebp
    136f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1372:	8b 45 08             	mov    0x8(%ebp),%eax
    1375:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1378:	90                   	nop
    1379:	8b 45 08             	mov    0x8(%ebp),%eax
    137c:	8d 50 01             	lea    0x1(%eax),%edx
    137f:	89 55 08             	mov    %edx,0x8(%ebp)
    1382:	8b 55 0c             	mov    0xc(%ebp),%edx
    1385:	8d 4a 01             	lea    0x1(%edx),%ecx
    1388:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    138b:	0f b6 12             	movzbl (%edx),%edx
    138e:	88 10                	mov    %dl,(%eax)
    1390:	0f b6 00             	movzbl (%eax),%eax
    1393:	84 c0                	test   %al,%al
    1395:	75 e2                	jne    1379 <strcpy+0xd>
    ;
  return os;
    1397:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    139a:	c9                   	leave  
    139b:	c3                   	ret    

0000139c <strcmp>:

int
strcmp(const char *p, const char *q)
{
    139c:	55                   	push   %ebp
    139d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    139f:	eb 08                	jmp    13a9 <strcmp+0xd>
    p++, q++;
    13a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    13a5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    13a9:	8b 45 08             	mov    0x8(%ebp),%eax
    13ac:	0f b6 00             	movzbl (%eax),%eax
    13af:	84 c0                	test   %al,%al
    13b1:	74 10                	je     13c3 <strcmp+0x27>
    13b3:	8b 45 08             	mov    0x8(%ebp),%eax
    13b6:	0f b6 10             	movzbl (%eax),%edx
    13b9:	8b 45 0c             	mov    0xc(%ebp),%eax
    13bc:	0f b6 00             	movzbl (%eax),%eax
    13bf:	38 c2                	cmp    %al,%dl
    13c1:	74 de                	je     13a1 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    13c3:	8b 45 08             	mov    0x8(%ebp),%eax
    13c6:	0f b6 00             	movzbl (%eax),%eax
    13c9:	0f b6 d0             	movzbl %al,%edx
    13cc:	8b 45 0c             	mov    0xc(%ebp),%eax
    13cf:	0f b6 00             	movzbl (%eax),%eax
    13d2:	0f b6 c0             	movzbl %al,%eax
    13d5:	29 c2                	sub    %eax,%edx
    13d7:	89 d0                	mov    %edx,%eax
}
    13d9:	5d                   	pop    %ebp
    13da:	c3                   	ret    

000013db <strlen>:

uint
strlen(char *s)
{
    13db:	55                   	push   %ebp
    13dc:	89 e5                	mov    %esp,%ebp
    13de:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    13e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    13e8:	eb 04                	jmp    13ee <strlen+0x13>
    13ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    13ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
    13f1:	8b 45 08             	mov    0x8(%ebp),%eax
    13f4:	01 d0                	add    %edx,%eax
    13f6:	0f b6 00             	movzbl (%eax),%eax
    13f9:	84 c0                	test   %al,%al
    13fb:	75 ed                	jne    13ea <strlen+0xf>
    ;
  return n;
    13fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1400:	c9                   	leave  
    1401:	c3                   	ret    

00001402 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1402:	55                   	push   %ebp
    1403:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1405:	8b 45 10             	mov    0x10(%ebp),%eax
    1408:	50                   	push   %eax
    1409:	ff 75 0c             	pushl  0xc(%ebp)
    140c:	ff 75 08             	pushl  0x8(%ebp)
    140f:	e8 32 ff ff ff       	call   1346 <stosb>
    1414:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1417:	8b 45 08             	mov    0x8(%ebp),%eax
}
    141a:	c9                   	leave  
    141b:	c3                   	ret    

0000141c <strchr>:

char*
strchr(const char *s, char c)
{
    141c:	55                   	push   %ebp
    141d:	89 e5                	mov    %esp,%ebp
    141f:	83 ec 04             	sub    $0x4,%esp
    1422:	8b 45 0c             	mov    0xc(%ebp),%eax
    1425:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1428:	eb 14                	jmp    143e <strchr+0x22>
    if(*s == c)
    142a:	8b 45 08             	mov    0x8(%ebp),%eax
    142d:	0f b6 00             	movzbl (%eax),%eax
    1430:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1433:	75 05                	jne    143a <strchr+0x1e>
      return (char*)s;
    1435:	8b 45 08             	mov    0x8(%ebp),%eax
    1438:	eb 13                	jmp    144d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    143a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    143e:	8b 45 08             	mov    0x8(%ebp),%eax
    1441:	0f b6 00             	movzbl (%eax),%eax
    1444:	84 c0                	test   %al,%al
    1446:	75 e2                	jne    142a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1448:	b8 00 00 00 00       	mov    $0x0,%eax
}
    144d:	c9                   	leave  
    144e:	c3                   	ret    

0000144f <gets>:

char*
gets(char *buf, int max)
{
    144f:	55                   	push   %ebp
    1450:	89 e5                	mov    %esp,%ebp
    1452:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    145c:	eb 42                	jmp    14a0 <gets+0x51>
    cc = read(0, &c, 1);
    145e:	83 ec 04             	sub    $0x4,%esp
    1461:	6a 01                	push   $0x1
    1463:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1466:	50                   	push   %eax
    1467:	6a 00                	push   $0x0
    1469:	e8 47 01 00 00       	call   15b5 <read>
    146e:	83 c4 10             	add    $0x10,%esp
    1471:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1474:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1478:	7e 33                	jle    14ad <gets+0x5e>
      break;
    buf[i++] = c;
    147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    147d:	8d 50 01             	lea    0x1(%eax),%edx
    1480:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1483:	89 c2                	mov    %eax,%edx
    1485:	8b 45 08             	mov    0x8(%ebp),%eax
    1488:	01 c2                	add    %eax,%edx
    148a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    148e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1490:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1494:	3c 0a                	cmp    $0xa,%al
    1496:	74 16                	je     14ae <gets+0x5f>
    1498:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    149c:	3c 0d                	cmp    $0xd,%al
    149e:	74 0e                	je     14ae <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    14a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a3:	83 c0 01             	add    $0x1,%eax
    14a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
    14a9:	7c b3                	jl     145e <gets+0xf>
    14ab:	eb 01                	jmp    14ae <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    14ad:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    14ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
    14b1:	8b 45 08             	mov    0x8(%ebp),%eax
    14b4:	01 d0                	add    %edx,%eax
    14b6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    14b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
    14bc:	c9                   	leave  
    14bd:	c3                   	ret    

000014be <stat>:

int
stat(char *n, struct stat *st)
{
    14be:	55                   	push   %ebp
    14bf:	89 e5                	mov    %esp,%ebp
    14c1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    14c4:	83 ec 08             	sub    $0x8,%esp
    14c7:	6a 00                	push   $0x0
    14c9:	ff 75 08             	pushl  0x8(%ebp)
    14cc:	e8 0c 01 00 00       	call   15dd <open>
    14d1:	83 c4 10             	add    $0x10,%esp
    14d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    14d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14db:	79 07                	jns    14e4 <stat+0x26>
    return -1;
    14dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    14e2:	eb 25                	jmp    1509 <stat+0x4b>
  r = fstat(fd, st);
    14e4:	83 ec 08             	sub    $0x8,%esp
    14e7:	ff 75 0c             	pushl  0xc(%ebp)
    14ea:	ff 75 f4             	pushl  -0xc(%ebp)
    14ed:	e8 03 01 00 00       	call   15f5 <fstat>
    14f2:	83 c4 10             	add    $0x10,%esp
    14f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    14f8:	83 ec 0c             	sub    $0xc,%esp
    14fb:	ff 75 f4             	pushl  -0xc(%ebp)
    14fe:	e8 c2 00 00 00       	call   15c5 <close>
    1503:	83 c4 10             	add    $0x10,%esp
  return r;
    1506:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1509:	c9                   	leave  
    150a:	c3                   	ret    

0000150b <atoi>:

int
atoi(const char *s)
{
    150b:	55                   	push   %ebp
    150c:	89 e5                	mov    %esp,%ebp
    150e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1511:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1518:	eb 25                	jmp    153f <atoi+0x34>
    n = n*10 + *s++ - '0';
    151a:	8b 55 fc             	mov    -0x4(%ebp),%edx
    151d:	89 d0                	mov    %edx,%eax
    151f:	c1 e0 02             	shl    $0x2,%eax
    1522:	01 d0                	add    %edx,%eax
    1524:	01 c0                	add    %eax,%eax
    1526:	89 c1                	mov    %eax,%ecx
    1528:	8b 45 08             	mov    0x8(%ebp),%eax
    152b:	8d 50 01             	lea    0x1(%eax),%edx
    152e:	89 55 08             	mov    %edx,0x8(%ebp)
    1531:	0f b6 00             	movzbl (%eax),%eax
    1534:	0f be c0             	movsbl %al,%eax
    1537:	01 c8                	add    %ecx,%eax
    1539:	83 e8 30             	sub    $0x30,%eax
    153c:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    153f:	8b 45 08             	mov    0x8(%ebp),%eax
    1542:	0f b6 00             	movzbl (%eax),%eax
    1545:	3c 2f                	cmp    $0x2f,%al
    1547:	7e 0a                	jle    1553 <atoi+0x48>
    1549:	8b 45 08             	mov    0x8(%ebp),%eax
    154c:	0f b6 00             	movzbl (%eax),%eax
    154f:	3c 39                	cmp    $0x39,%al
    1551:	7e c7                	jle    151a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1553:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1556:	c9                   	leave  
    1557:	c3                   	ret    

00001558 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1558:	55                   	push   %ebp
    1559:	89 e5                	mov    %esp,%ebp
    155b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    155e:	8b 45 08             	mov    0x8(%ebp),%eax
    1561:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1564:	8b 45 0c             	mov    0xc(%ebp),%eax
    1567:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    156a:	eb 17                	jmp    1583 <memmove+0x2b>
    *dst++ = *src++;
    156c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    156f:	8d 50 01             	lea    0x1(%eax),%edx
    1572:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1575:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1578:	8d 4a 01             	lea    0x1(%edx),%ecx
    157b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    157e:	0f b6 12             	movzbl (%edx),%edx
    1581:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1583:	8b 45 10             	mov    0x10(%ebp),%eax
    1586:	8d 50 ff             	lea    -0x1(%eax),%edx
    1589:	89 55 10             	mov    %edx,0x10(%ebp)
    158c:	85 c0                	test   %eax,%eax
    158e:	7f dc                	jg     156c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1590:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1593:	c9                   	leave  
    1594:	c3                   	ret    

00001595 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1595:	b8 01 00 00 00       	mov    $0x1,%eax
    159a:	cd 40                	int    $0x40
    159c:	c3                   	ret    

0000159d <exit>:
SYSCALL(exit)
    159d:	b8 02 00 00 00       	mov    $0x2,%eax
    15a2:	cd 40                	int    $0x40
    15a4:	c3                   	ret    

000015a5 <wait>:
SYSCALL(wait)
    15a5:	b8 03 00 00 00       	mov    $0x3,%eax
    15aa:	cd 40                	int    $0x40
    15ac:	c3                   	ret    

000015ad <pipe>:
SYSCALL(pipe)
    15ad:	b8 04 00 00 00       	mov    $0x4,%eax
    15b2:	cd 40                	int    $0x40
    15b4:	c3                   	ret    

000015b5 <read>:
SYSCALL(read)
    15b5:	b8 05 00 00 00       	mov    $0x5,%eax
    15ba:	cd 40                	int    $0x40
    15bc:	c3                   	ret    

000015bd <write>:
SYSCALL(write)
    15bd:	b8 10 00 00 00       	mov    $0x10,%eax
    15c2:	cd 40                	int    $0x40
    15c4:	c3                   	ret    

000015c5 <close>:
SYSCALL(close)
    15c5:	b8 15 00 00 00       	mov    $0x15,%eax
    15ca:	cd 40                	int    $0x40
    15cc:	c3                   	ret    

000015cd <kill>:
SYSCALL(kill)
    15cd:	b8 06 00 00 00       	mov    $0x6,%eax
    15d2:	cd 40                	int    $0x40
    15d4:	c3                   	ret    

000015d5 <exec>:
SYSCALL(exec)
    15d5:	b8 07 00 00 00       	mov    $0x7,%eax
    15da:	cd 40                	int    $0x40
    15dc:	c3                   	ret    

000015dd <open>:
SYSCALL(open)
    15dd:	b8 0f 00 00 00       	mov    $0xf,%eax
    15e2:	cd 40                	int    $0x40
    15e4:	c3                   	ret    

000015e5 <mknod>:
SYSCALL(mknod)
    15e5:	b8 11 00 00 00       	mov    $0x11,%eax
    15ea:	cd 40                	int    $0x40
    15ec:	c3                   	ret    

000015ed <unlink>:
SYSCALL(unlink)
    15ed:	b8 12 00 00 00       	mov    $0x12,%eax
    15f2:	cd 40                	int    $0x40
    15f4:	c3                   	ret    

000015f5 <fstat>:
SYSCALL(fstat)
    15f5:	b8 08 00 00 00       	mov    $0x8,%eax
    15fa:	cd 40                	int    $0x40
    15fc:	c3                   	ret    

000015fd <link>:
SYSCALL(link)
    15fd:	b8 13 00 00 00       	mov    $0x13,%eax
    1602:	cd 40                	int    $0x40
    1604:	c3                   	ret    

00001605 <mkdir>:
SYSCALL(mkdir)
    1605:	b8 14 00 00 00       	mov    $0x14,%eax
    160a:	cd 40                	int    $0x40
    160c:	c3                   	ret    

0000160d <chdir>:
SYSCALL(chdir)
    160d:	b8 09 00 00 00       	mov    $0x9,%eax
    1612:	cd 40                	int    $0x40
    1614:	c3                   	ret    

00001615 <dup>:
SYSCALL(dup)
    1615:	b8 0a 00 00 00       	mov    $0xa,%eax
    161a:	cd 40                	int    $0x40
    161c:	c3                   	ret    

0000161d <getpid>:
SYSCALL(getpid)
    161d:	b8 0b 00 00 00       	mov    $0xb,%eax
    1622:	cd 40                	int    $0x40
    1624:	c3                   	ret    

00001625 <sbrk>:
SYSCALL(sbrk)
    1625:	b8 0c 00 00 00       	mov    $0xc,%eax
    162a:	cd 40                	int    $0x40
    162c:	c3                   	ret    

0000162d <sleep>:
SYSCALL(sleep)
    162d:	b8 0d 00 00 00       	mov    $0xd,%eax
    1632:	cd 40                	int    $0x40
    1634:	c3                   	ret    

00001635 <uptime>:
SYSCALL(uptime)
    1635:	b8 0e 00 00 00       	mov    $0xe,%eax
    163a:	cd 40                	int    $0x40
    163c:	c3                   	ret    

0000163d <shm_open>:
SYSCALL(shm_open)
    163d:	b8 16 00 00 00       	mov    $0x16,%eax
    1642:	cd 40                	int    $0x40
    1644:	c3                   	ret    

00001645 <shm_close>:
SYSCALL(shm_close)	
    1645:	b8 17 00 00 00       	mov    $0x17,%eax
    164a:	cd 40                	int    $0x40
    164c:	c3                   	ret    

0000164d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    164d:	55                   	push   %ebp
    164e:	89 e5                	mov    %esp,%ebp
    1650:	83 ec 18             	sub    $0x18,%esp
    1653:	8b 45 0c             	mov    0xc(%ebp),%eax
    1656:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1659:	83 ec 04             	sub    $0x4,%esp
    165c:	6a 01                	push   $0x1
    165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1661:	50                   	push   %eax
    1662:	ff 75 08             	pushl  0x8(%ebp)
    1665:	e8 53 ff ff ff       	call   15bd <write>
    166a:	83 c4 10             	add    $0x10,%esp
}
    166d:	90                   	nop
    166e:	c9                   	leave  
    166f:	c3                   	ret    

00001670 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1670:	55                   	push   %ebp
    1671:	89 e5                	mov    %esp,%ebp
    1673:	53                   	push   %ebx
    1674:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1677:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    167e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1682:	74 17                	je     169b <printint+0x2b>
    1684:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1688:	79 11                	jns    169b <printint+0x2b>
    neg = 1;
    168a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1691:	8b 45 0c             	mov    0xc(%ebp),%eax
    1694:	f7 d8                	neg    %eax
    1696:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1699:	eb 06                	jmp    16a1 <printint+0x31>
  } else {
    x = xx;
    169b:	8b 45 0c             	mov    0xc(%ebp),%eax
    169e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    16a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    16a8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    16ab:	8d 41 01             	lea    0x1(%ecx),%eax
    16ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    16b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    16b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    16b7:	ba 00 00 00 00       	mov    $0x0,%edx
    16bc:	f7 f3                	div    %ebx
    16be:	89 d0                	mov    %edx,%eax
    16c0:	0f b6 80 7c 1e 00 00 	movzbl 0x1e7c(%eax),%eax
    16c7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    16cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
    16ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
    16d1:	ba 00 00 00 00       	mov    $0x0,%edx
    16d6:	f7 f3                	div    %ebx
    16d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    16db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    16df:	75 c7                	jne    16a8 <printint+0x38>
  if(neg)
    16e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    16e5:	74 2d                	je     1714 <printint+0xa4>
    buf[i++] = '-';
    16e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16ea:	8d 50 01             	lea    0x1(%eax),%edx
    16ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
    16f0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    16f5:	eb 1d                	jmp    1714 <printint+0xa4>
    putc(fd, buf[i]);
    16f7:	8d 55 dc             	lea    -0x24(%ebp),%edx
    16fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16fd:	01 d0                	add    %edx,%eax
    16ff:	0f b6 00             	movzbl (%eax),%eax
    1702:	0f be c0             	movsbl %al,%eax
    1705:	83 ec 08             	sub    $0x8,%esp
    1708:	50                   	push   %eax
    1709:	ff 75 08             	pushl  0x8(%ebp)
    170c:	e8 3c ff ff ff       	call   164d <putc>
    1711:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1714:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    171c:	79 d9                	jns    16f7 <printint+0x87>
    putc(fd, buf[i]);
}
    171e:	90                   	nop
    171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1722:	c9                   	leave  
    1723:	c3                   	ret    

00001724 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1724:	55                   	push   %ebp
    1725:	89 e5                	mov    %esp,%ebp
    1727:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    172a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1731:	8d 45 0c             	lea    0xc(%ebp),%eax
    1734:	83 c0 04             	add    $0x4,%eax
    1737:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    173a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1741:	e9 59 01 00 00       	jmp    189f <printf+0x17b>
    c = fmt[i] & 0xff;
    1746:	8b 55 0c             	mov    0xc(%ebp),%edx
    1749:	8b 45 f0             	mov    -0x10(%ebp),%eax
    174c:	01 d0                	add    %edx,%eax
    174e:	0f b6 00             	movzbl (%eax),%eax
    1751:	0f be c0             	movsbl %al,%eax
    1754:	25 ff 00 00 00       	and    $0xff,%eax
    1759:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    175c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1760:	75 2c                	jne    178e <printf+0x6a>
      if(c == '%'){
    1762:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1766:	75 0c                	jne    1774 <printf+0x50>
        state = '%';
    1768:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    176f:	e9 27 01 00 00       	jmp    189b <printf+0x177>
      } else {
        putc(fd, c);
    1774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1777:	0f be c0             	movsbl %al,%eax
    177a:	83 ec 08             	sub    $0x8,%esp
    177d:	50                   	push   %eax
    177e:	ff 75 08             	pushl  0x8(%ebp)
    1781:	e8 c7 fe ff ff       	call   164d <putc>
    1786:	83 c4 10             	add    $0x10,%esp
    1789:	e9 0d 01 00 00       	jmp    189b <printf+0x177>
      }
    } else if(state == '%'){
    178e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1792:	0f 85 03 01 00 00    	jne    189b <printf+0x177>
      if(c == 'd'){
    1798:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    179c:	75 1e                	jne    17bc <printf+0x98>
        printint(fd, *ap, 10, 1);
    179e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    17a1:	8b 00                	mov    (%eax),%eax
    17a3:	6a 01                	push   $0x1
    17a5:	6a 0a                	push   $0xa
    17a7:	50                   	push   %eax
    17a8:	ff 75 08             	pushl  0x8(%ebp)
    17ab:	e8 c0 fe ff ff       	call   1670 <printint>
    17b0:	83 c4 10             	add    $0x10,%esp
        ap++;
    17b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    17b7:	e9 d8 00 00 00       	jmp    1894 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    17bc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    17c0:	74 06                	je     17c8 <printf+0xa4>
    17c2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    17c6:	75 1e                	jne    17e6 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    17c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    17cb:	8b 00                	mov    (%eax),%eax
    17cd:	6a 00                	push   $0x0
    17cf:	6a 10                	push   $0x10
    17d1:	50                   	push   %eax
    17d2:	ff 75 08             	pushl  0x8(%ebp)
    17d5:	e8 96 fe ff ff       	call   1670 <printint>
    17da:	83 c4 10             	add    $0x10,%esp
        ap++;
    17dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    17e1:	e9 ae 00 00 00       	jmp    1894 <printf+0x170>
      } else if(c == 's'){
    17e6:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    17ea:	75 43                	jne    182f <printf+0x10b>
        s = (char*)*ap;
    17ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
    17ef:	8b 00                	mov    (%eax),%eax
    17f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    17f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    17f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17fc:	75 25                	jne    1823 <printf+0xff>
          s = "(null)";
    17fe:	c7 45 f4 73 1b 00 00 	movl   $0x1b73,-0xc(%ebp)
        while(*s != 0){
    1805:	eb 1c                	jmp    1823 <printf+0xff>
          putc(fd, *s);
    1807:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180a:	0f b6 00             	movzbl (%eax),%eax
    180d:	0f be c0             	movsbl %al,%eax
    1810:	83 ec 08             	sub    $0x8,%esp
    1813:	50                   	push   %eax
    1814:	ff 75 08             	pushl  0x8(%ebp)
    1817:	e8 31 fe ff ff       	call   164d <putc>
    181c:	83 c4 10             	add    $0x10,%esp
          s++;
    181f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1823:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1826:	0f b6 00             	movzbl (%eax),%eax
    1829:	84 c0                	test   %al,%al
    182b:	75 da                	jne    1807 <printf+0xe3>
    182d:	eb 65                	jmp    1894 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    182f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1833:	75 1d                	jne    1852 <printf+0x12e>
        putc(fd, *ap);
    1835:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1838:	8b 00                	mov    (%eax),%eax
    183a:	0f be c0             	movsbl %al,%eax
    183d:	83 ec 08             	sub    $0x8,%esp
    1840:	50                   	push   %eax
    1841:	ff 75 08             	pushl  0x8(%ebp)
    1844:	e8 04 fe ff ff       	call   164d <putc>
    1849:	83 c4 10             	add    $0x10,%esp
        ap++;
    184c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1850:	eb 42                	jmp    1894 <printf+0x170>
      } else if(c == '%'){
    1852:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1856:	75 17                	jne    186f <printf+0x14b>
        putc(fd, c);
    1858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    185b:	0f be c0             	movsbl %al,%eax
    185e:	83 ec 08             	sub    $0x8,%esp
    1861:	50                   	push   %eax
    1862:	ff 75 08             	pushl  0x8(%ebp)
    1865:	e8 e3 fd ff ff       	call   164d <putc>
    186a:	83 c4 10             	add    $0x10,%esp
    186d:	eb 25                	jmp    1894 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    186f:	83 ec 08             	sub    $0x8,%esp
    1872:	6a 25                	push   $0x25
    1874:	ff 75 08             	pushl  0x8(%ebp)
    1877:	e8 d1 fd ff ff       	call   164d <putc>
    187c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    187f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1882:	0f be c0             	movsbl %al,%eax
    1885:	83 ec 08             	sub    $0x8,%esp
    1888:	50                   	push   %eax
    1889:	ff 75 08             	pushl  0x8(%ebp)
    188c:	e8 bc fd ff ff       	call   164d <putc>
    1891:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    1894:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    189b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    189f:	8b 55 0c             	mov    0xc(%ebp),%edx
    18a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18a5:	01 d0                	add    %edx,%eax
    18a7:	0f b6 00             	movzbl (%eax),%eax
    18aa:	84 c0                	test   %al,%al
    18ac:	0f 85 94 fe ff ff    	jne    1746 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    18b2:	90                   	nop
    18b3:	c9                   	leave  
    18b4:	c3                   	ret    

000018b5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    18b5:	55                   	push   %ebp
    18b6:	89 e5                	mov    %esp,%ebp
    18b8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    18bb:	8b 45 08             	mov    0x8(%ebp),%eax
    18be:	83 e8 08             	sub    $0x8,%eax
    18c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    18c4:	a1 a8 1e 00 00       	mov    0x1ea8,%eax
    18c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    18cc:	eb 24                	jmp    18f2 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    18ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18d1:	8b 00                	mov    (%eax),%eax
    18d3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    18d6:	77 12                	ja     18ea <free+0x35>
    18d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    18de:	77 24                	ja     1904 <free+0x4f>
    18e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18e3:	8b 00                	mov    (%eax),%eax
    18e5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    18e8:	77 1a                	ja     1904 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    18ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18ed:	8b 00                	mov    (%eax),%eax
    18ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    18f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    18f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    18f8:	76 d4                	jbe    18ce <free+0x19>
    18fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    18fd:	8b 00                	mov    (%eax),%eax
    18ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1902:	76 ca                	jbe    18ce <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1904:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1907:	8b 40 04             	mov    0x4(%eax),%eax
    190a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1911:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1914:	01 c2                	add    %eax,%edx
    1916:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1919:	8b 00                	mov    (%eax),%eax
    191b:	39 c2                	cmp    %eax,%edx
    191d:	75 24                	jne    1943 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    191f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1922:	8b 50 04             	mov    0x4(%eax),%edx
    1925:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1928:	8b 00                	mov    (%eax),%eax
    192a:	8b 40 04             	mov    0x4(%eax),%eax
    192d:	01 c2                	add    %eax,%edx
    192f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1932:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1935:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1938:	8b 00                	mov    (%eax),%eax
    193a:	8b 10                	mov    (%eax),%edx
    193c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    193f:	89 10                	mov    %edx,(%eax)
    1941:	eb 0a                	jmp    194d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1943:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1946:	8b 10                	mov    (%eax),%edx
    1948:	8b 45 f8             	mov    -0x8(%ebp),%eax
    194b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    194d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1950:	8b 40 04             	mov    0x4(%eax),%eax
    1953:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    195a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    195d:	01 d0                	add    %edx,%eax
    195f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1962:	75 20                	jne    1984 <free+0xcf>
    p->s.size += bp->s.size;
    1964:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1967:	8b 50 04             	mov    0x4(%eax),%edx
    196a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    196d:	8b 40 04             	mov    0x4(%eax),%eax
    1970:	01 c2                	add    %eax,%edx
    1972:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1975:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1978:	8b 45 f8             	mov    -0x8(%ebp),%eax
    197b:	8b 10                	mov    (%eax),%edx
    197d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1980:	89 10                	mov    %edx,(%eax)
    1982:	eb 08                	jmp    198c <free+0xd7>
  } else
    p->s.ptr = bp;
    1984:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1987:	8b 55 f8             	mov    -0x8(%ebp),%edx
    198a:	89 10                	mov    %edx,(%eax)
  freep = p;
    198c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    198f:	a3 a8 1e 00 00       	mov    %eax,0x1ea8
}
    1994:	90                   	nop
    1995:	c9                   	leave  
    1996:	c3                   	ret    

00001997 <morecore>:

static Header*
morecore(uint nu)
{
    1997:	55                   	push   %ebp
    1998:	89 e5                	mov    %esp,%ebp
    199a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    199d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    19a4:	77 07                	ja     19ad <morecore+0x16>
    nu = 4096;
    19a6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    19ad:	8b 45 08             	mov    0x8(%ebp),%eax
    19b0:	c1 e0 03             	shl    $0x3,%eax
    19b3:	83 ec 0c             	sub    $0xc,%esp
    19b6:	50                   	push   %eax
    19b7:	e8 69 fc ff ff       	call   1625 <sbrk>
    19bc:	83 c4 10             	add    $0x10,%esp
    19bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    19c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    19c6:	75 07                	jne    19cf <morecore+0x38>
    return 0;
    19c8:	b8 00 00 00 00       	mov    $0x0,%eax
    19cd:	eb 26                	jmp    19f5 <morecore+0x5e>
  hp = (Header*)p;
    19cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    19d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    19d8:	8b 55 08             	mov    0x8(%ebp),%edx
    19db:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    19de:	8b 45 f0             	mov    -0x10(%ebp),%eax
    19e1:	83 c0 08             	add    $0x8,%eax
    19e4:	83 ec 0c             	sub    $0xc,%esp
    19e7:	50                   	push   %eax
    19e8:	e8 c8 fe ff ff       	call   18b5 <free>
    19ed:	83 c4 10             	add    $0x10,%esp
  return freep;
    19f0:	a1 a8 1e 00 00       	mov    0x1ea8,%eax
}
    19f5:	c9                   	leave  
    19f6:	c3                   	ret    

000019f7 <malloc>:

void*
malloc(uint nbytes)
{
    19f7:	55                   	push   %ebp
    19f8:	89 e5                	mov    %esp,%ebp
    19fa:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    19fd:	8b 45 08             	mov    0x8(%ebp),%eax
    1a00:	83 c0 07             	add    $0x7,%eax
    1a03:	c1 e8 03             	shr    $0x3,%eax
    1a06:	83 c0 01             	add    $0x1,%eax
    1a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1a0c:	a1 a8 1e 00 00       	mov    0x1ea8,%eax
    1a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1a14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1a18:	75 23                	jne    1a3d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1a1a:	c7 45 f0 a0 1e 00 00 	movl   $0x1ea0,-0x10(%ebp)
    1a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a24:	a3 a8 1e 00 00       	mov    %eax,0x1ea8
    1a29:	a1 a8 1e 00 00       	mov    0x1ea8,%eax
    1a2e:	a3 a0 1e 00 00       	mov    %eax,0x1ea0
    base.s.size = 0;
    1a33:	c7 05 a4 1e 00 00 00 	movl   $0x0,0x1ea4
    1a3a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a40:	8b 00                	mov    (%eax),%eax
    1a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a48:	8b 40 04             	mov    0x4(%eax),%eax
    1a4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1a4e:	72 4d                	jb     1a9d <malloc+0xa6>
      if(p->s.size == nunits)
    1a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a53:	8b 40 04             	mov    0x4(%eax),%eax
    1a56:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1a59:	75 0c                	jne    1a67 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a5e:	8b 10                	mov    (%eax),%edx
    1a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a63:	89 10                	mov    %edx,(%eax)
    1a65:	eb 26                	jmp    1a8d <malloc+0x96>
      else {
        p->s.size -= nunits;
    1a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a6a:	8b 40 04             	mov    0x4(%eax),%eax
    1a6d:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1a70:	89 c2                	mov    %eax,%edx
    1a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a75:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a7b:	8b 40 04             	mov    0x4(%eax),%eax
    1a7e:	c1 e0 03             	shl    $0x3,%eax
    1a81:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a87:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1a8a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a90:	a3 a8 1e 00 00       	mov    %eax,0x1ea8
      return (void*)(p + 1);
    1a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a98:	83 c0 08             	add    $0x8,%eax
    1a9b:	eb 3b                	jmp    1ad8 <malloc+0xe1>
    }
    if(p == freep)
    1a9d:	a1 a8 1e 00 00       	mov    0x1ea8,%eax
    1aa2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1aa5:	75 1e                	jne    1ac5 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    1aa7:	83 ec 0c             	sub    $0xc,%esp
    1aaa:	ff 75 ec             	pushl  -0x14(%ebp)
    1aad:	e8 e5 fe ff ff       	call   1997 <morecore>
    1ab2:	83 c4 10             	add    $0x10,%esp
    1ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1ab8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1abc:	75 07                	jne    1ac5 <malloc+0xce>
        return 0;
    1abe:	b8 00 00 00 00       	mov    $0x0,%eax
    1ac3:	eb 13                	jmp    1ad8 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ac8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ace:	8b 00                	mov    (%eax),%eax
    1ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1ad3:	e9 6d ff ff ff       	jmp    1a45 <malloc+0x4e>
}
    1ad8:	c9                   	leave  
    1ad9:	c3                   	ret    

00001ada <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    1ada:	55                   	push   %ebp
    1adb:	89 e5                	mov    %esp,%ebp
    1add:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    1ae0:	8b 55 08             	mov    0x8(%ebp),%edx
    1ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
    1ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1ae9:	f0 87 02             	lock xchg %eax,(%edx)
    1aec:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    1aef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1af2:	c9                   	leave  
    1af3:	c3                   	ret    

00001af4 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1af4:	55                   	push   %ebp
    1af5:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1af7:	90                   	nop
    1af8:	8b 45 08             	mov    0x8(%ebp),%eax
    1afb:	6a 01                	push   $0x1
    1afd:	50                   	push   %eax
    1afe:	e8 d7 ff ff ff       	call   1ada <xchg>
    1b03:	83 c4 08             	add    $0x8,%esp
    1b06:	85 c0                	test   %eax,%eax
    1b08:	75 ee                	jne    1af8 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1b0a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    1b0f:	90                   	nop
    1b10:	c9                   	leave  
    1b11:	c3                   	ret    

00001b12 <urelease>:

void urelease (struct uspinlock *lk) {
    1b12:	55                   	push   %ebp
    1b13:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1b15:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1b1a:	8b 45 08             	mov    0x8(%ebp),%eax
    1b1d:	8b 55 08             	mov    0x8(%ebp),%edx
    1b20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1b26:	90                   	nop
    1b27:	5d                   	pop    %ebp
    1b28:	c3                   	ret    
