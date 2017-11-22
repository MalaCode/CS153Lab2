
_sh:     file format elf32-i386


Disassembly of section .text:

00001000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
    1006:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    100a:	75 05                	jne    1011 <runcmd+0x11>
    exit();
    100c:	e8 c4 0e 00 00       	call   1ed5 <exit>

  switch(cmd->type){
    1011:	8b 45 08             	mov    0x8(%ebp),%eax
    1014:	8b 00                	mov    (%eax),%eax
    1016:	83 f8 05             	cmp    $0x5,%eax
    1019:	77 09                	ja     1024 <runcmd+0x24>
    101b:	8b 04 85 90 24 00 00 	mov    0x2490(,%eax,4),%eax
    1022:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
    1024:	83 ec 0c             	sub    $0xc,%esp
    1027:	68 64 24 00 00       	push   $0x2464
    102c:	e8 6b 03 00 00       	call   139c <panic>
    1031:	83 c4 10             	add    $0x10,%esp

  case EXEC:
    ecmd = (struct execcmd*)cmd;
    1034:	8b 45 08             	mov    0x8(%ebp),%eax
    1037:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
    103a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    103d:	8b 40 04             	mov    0x4(%eax),%eax
    1040:	85 c0                	test   %eax,%eax
    1042:	75 05                	jne    1049 <runcmd+0x49>
      exit();
    1044:	e8 8c 0e 00 00       	call   1ed5 <exit>
    exec(ecmd->argv[0], ecmd->argv);
    1049:	8b 45 f4             	mov    -0xc(%ebp),%eax
    104c:	8d 50 04             	lea    0x4(%eax),%edx
    104f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1052:	8b 40 04             	mov    0x4(%eax),%eax
    1055:	83 ec 08             	sub    $0x8,%esp
    1058:	52                   	push   %edx
    1059:	50                   	push   %eax
    105a:	e8 ae 0e 00 00       	call   1f0d <exec>
    105f:	83 c4 10             	add    $0x10,%esp
    printf(2, "exec %s failed\n", ecmd->argv[0]);
    1062:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1065:	8b 40 04             	mov    0x4(%eax),%eax
    1068:	83 ec 04             	sub    $0x4,%esp
    106b:	50                   	push   %eax
    106c:	68 6b 24 00 00       	push   $0x246b
    1071:	6a 02                	push   $0x2
    1073:	e8 e4 0f 00 00       	call   205c <printf>
    1078:	83 c4 10             	add    $0x10,%esp
    break;
    107b:	e9 c6 01 00 00       	jmp    1246 <runcmd+0x246>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    1080:	8b 45 08             	mov    0x8(%ebp),%eax
    1083:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
    1086:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1089:	8b 40 14             	mov    0x14(%eax),%eax
    108c:	83 ec 0c             	sub    $0xc,%esp
    108f:	50                   	push   %eax
    1090:	e8 68 0e 00 00       	call   1efd <close>
    1095:	83 c4 10             	add    $0x10,%esp
    if(open(rcmd->file, rcmd->mode) < 0){
    1098:	8b 45 f0             	mov    -0x10(%ebp),%eax
    109b:	8b 50 10             	mov    0x10(%eax),%edx
    109e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10a1:	8b 40 08             	mov    0x8(%eax),%eax
    10a4:	83 ec 08             	sub    $0x8,%esp
    10a7:	52                   	push   %edx
    10a8:	50                   	push   %eax
    10a9:	e8 67 0e 00 00       	call   1f15 <open>
    10ae:	83 c4 10             	add    $0x10,%esp
    10b1:	85 c0                	test   %eax,%eax
    10b3:	79 1e                	jns    10d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
    10b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10b8:	8b 40 08             	mov    0x8(%eax),%eax
    10bb:	83 ec 04             	sub    $0x4,%esp
    10be:	50                   	push   %eax
    10bf:	68 7b 24 00 00       	push   $0x247b
    10c4:	6a 02                	push   $0x2
    10c6:	e8 91 0f 00 00       	call   205c <printf>
    10cb:	83 c4 10             	add    $0x10,%esp
      exit();
    10ce:	e8 02 0e 00 00       	call   1ed5 <exit>
    }
    runcmd(rcmd->cmd);
    10d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10d6:	8b 40 04             	mov    0x4(%eax),%eax
    10d9:	83 ec 0c             	sub    $0xc,%esp
    10dc:	50                   	push   %eax
    10dd:	e8 1e ff ff ff       	call   1000 <runcmd>
    10e2:	83 c4 10             	add    $0x10,%esp
    break;
    10e5:	e9 5c 01 00 00       	jmp    1246 <runcmd+0x246>

  case LIST:
    lcmd = (struct listcmd*)cmd;
    10ea:	8b 45 08             	mov    0x8(%ebp),%eax
    10ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
    10f0:	e8 c7 02 00 00       	call   13bc <fork1>
    10f5:	85 c0                	test   %eax,%eax
    10f7:	75 12                	jne    110b <runcmd+0x10b>
      runcmd(lcmd->left);
    10f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10fc:	8b 40 04             	mov    0x4(%eax),%eax
    10ff:	83 ec 0c             	sub    $0xc,%esp
    1102:	50                   	push   %eax
    1103:	e8 f8 fe ff ff       	call   1000 <runcmd>
    1108:	83 c4 10             	add    $0x10,%esp
    wait();
    110b:	e8 cd 0d 00 00       	call   1edd <wait>
    runcmd(lcmd->right);
    1110:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1113:	8b 40 08             	mov    0x8(%eax),%eax
    1116:	83 ec 0c             	sub    $0xc,%esp
    1119:	50                   	push   %eax
    111a:	e8 e1 fe ff ff       	call   1000 <runcmd>
    111f:	83 c4 10             	add    $0x10,%esp
    break;
    1122:	e9 1f 01 00 00       	jmp    1246 <runcmd+0x246>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    1127:	8b 45 08             	mov    0x8(%ebp),%eax
    112a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
    112d:	83 ec 0c             	sub    $0xc,%esp
    1130:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1133:	50                   	push   %eax
    1134:	e8 ac 0d 00 00       	call   1ee5 <pipe>
    1139:	83 c4 10             	add    $0x10,%esp
    113c:	85 c0                	test   %eax,%eax
    113e:	79 10                	jns    1150 <runcmd+0x150>
      panic("pipe");
    1140:	83 ec 0c             	sub    $0xc,%esp
    1143:	68 8b 24 00 00       	push   $0x248b
    1148:	e8 4f 02 00 00       	call   139c <panic>
    114d:	83 c4 10             	add    $0x10,%esp
    if(fork1() == 0){
    1150:	e8 67 02 00 00       	call   13bc <fork1>
    1155:	85 c0                	test   %eax,%eax
    1157:	75 4c                	jne    11a5 <runcmd+0x1a5>
      close(1);
    1159:	83 ec 0c             	sub    $0xc,%esp
    115c:	6a 01                	push   $0x1
    115e:	e8 9a 0d 00 00       	call   1efd <close>
    1163:	83 c4 10             	add    $0x10,%esp
      dup(p[1]);
    1166:	8b 45 e0             	mov    -0x20(%ebp),%eax
    1169:	83 ec 0c             	sub    $0xc,%esp
    116c:	50                   	push   %eax
    116d:	e8 db 0d 00 00       	call   1f4d <dup>
    1172:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
    1175:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1178:	83 ec 0c             	sub    $0xc,%esp
    117b:	50                   	push   %eax
    117c:	e8 7c 0d 00 00       	call   1efd <close>
    1181:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
    1184:	8b 45 e0             	mov    -0x20(%ebp),%eax
    1187:	83 ec 0c             	sub    $0xc,%esp
    118a:	50                   	push   %eax
    118b:	e8 6d 0d 00 00       	call   1efd <close>
    1190:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->left);
    1193:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1196:	8b 40 04             	mov    0x4(%eax),%eax
    1199:	83 ec 0c             	sub    $0xc,%esp
    119c:	50                   	push   %eax
    119d:	e8 5e fe ff ff       	call   1000 <runcmd>
    11a2:	83 c4 10             	add    $0x10,%esp
    }
    if(fork1() == 0){
    11a5:	e8 12 02 00 00       	call   13bc <fork1>
    11aa:	85 c0                	test   %eax,%eax
    11ac:	75 4c                	jne    11fa <runcmd+0x1fa>
      close(0);
    11ae:	83 ec 0c             	sub    $0xc,%esp
    11b1:	6a 00                	push   $0x0
    11b3:	e8 45 0d 00 00       	call   1efd <close>
    11b8:	83 c4 10             	add    $0x10,%esp
      dup(p[0]);
    11bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
    11be:	83 ec 0c             	sub    $0xc,%esp
    11c1:	50                   	push   %eax
    11c2:	e8 86 0d 00 00       	call   1f4d <dup>
    11c7:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
    11ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
    11cd:	83 ec 0c             	sub    $0xc,%esp
    11d0:	50                   	push   %eax
    11d1:	e8 27 0d 00 00       	call   1efd <close>
    11d6:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
    11d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
    11dc:	83 ec 0c             	sub    $0xc,%esp
    11df:	50                   	push   %eax
    11e0:	e8 18 0d 00 00       	call   1efd <close>
    11e5:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->right);
    11e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11eb:	8b 40 08             	mov    0x8(%eax),%eax
    11ee:	83 ec 0c             	sub    $0xc,%esp
    11f1:	50                   	push   %eax
    11f2:	e8 09 fe ff ff       	call   1000 <runcmd>
    11f7:	83 c4 10             	add    $0x10,%esp
    }
    close(p[0]);
    11fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
    11fd:	83 ec 0c             	sub    $0xc,%esp
    1200:	50                   	push   %eax
    1201:	e8 f7 0c 00 00       	call   1efd <close>
    1206:	83 c4 10             	add    $0x10,%esp
    close(p[1]);
    1209:	8b 45 e0             	mov    -0x20(%ebp),%eax
    120c:	83 ec 0c             	sub    $0xc,%esp
    120f:	50                   	push   %eax
    1210:	e8 e8 0c 00 00       	call   1efd <close>
    1215:	83 c4 10             	add    $0x10,%esp
    wait();
    1218:	e8 c0 0c 00 00       	call   1edd <wait>
    wait();
    121d:	e8 bb 0c 00 00       	call   1edd <wait>
    break;
    1222:	eb 22                	jmp    1246 <runcmd+0x246>

  case BACK:
    bcmd = (struct backcmd*)cmd;
    1224:	8b 45 08             	mov    0x8(%ebp),%eax
    1227:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
    122a:	e8 8d 01 00 00       	call   13bc <fork1>
    122f:	85 c0                	test   %eax,%eax
    1231:	75 12                	jne    1245 <runcmd+0x245>
      runcmd(bcmd->cmd);
    1233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1236:	8b 40 04             	mov    0x4(%eax),%eax
    1239:	83 ec 0c             	sub    $0xc,%esp
    123c:	50                   	push   %eax
    123d:	e8 be fd ff ff       	call   1000 <runcmd>
    1242:	83 c4 10             	add    $0x10,%esp
    break;
    1245:	90                   	nop
  }
  exit();
    1246:	e8 8a 0c 00 00       	call   1ed5 <exit>

0000124b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
    124b:	55                   	push   %ebp
    124c:	89 e5                	mov    %esp,%ebp
    124e:	83 ec 08             	sub    $0x8,%esp
  printf(2, "$ ");
    1251:	83 ec 08             	sub    $0x8,%esp
    1254:	68 a8 24 00 00       	push   $0x24a8
    1259:	6a 02                	push   $0x2
    125b:	e8 fc 0d 00 00       	call   205c <printf>
    1260:	83 c4 10             	add    $0x10,%esp
  memset(buf, 0, nbuf);
    1263:	8b 45 0c             	mov    0xc(%ebp),%eax
    1266:	83 ec 04             	sub    $0x4,%esp
    1269:	50                   	push   %eax
    126a:	6a 00                	push   $0x0
    126c:	ff 75 08             	pushl  0x8(%ebp)
    126f:	e8 c6 0a 00 00       	call   1d3a <memset>
    1274:	83 c4 10             	add    $0x10,%esp
  gets(buf, nbuf);
    1277:	83 ec 08             	sub    $0x8,%esp
    127a:	ff 75 0c             	pushl  0xc(%ebp)
    127d:	ff 75 08             	pushl  0x8(%ebp)
    1280:	e8 02 0b 00 00       	call   1d87 <gets>
    1285:	83 c4 10             	add    $0x10,%esp
  if(buf[0] == 0) // EOF
    1288:	8b 45 08             	mov    0x8(%ebp),%eax
    128b:	0f b6 00             	movzbl (%eax),%eax
    128e:	84 c0                	test   %al,%al
    1290:	75 07                	jne    1299 <getcmd+0x4e>
    return -1;
    1292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1297:	eb 05                	jmp    129e <getcmd+0x53>
  return 0;
    1299:	b8 00 00 00 00       	mov    $0x0,%eax
}
    129e:	c9                   	leave  
    129f:	c3                   	ret    

000012a0 <main>:

int
main(void)
{
    12a0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    12a4:	83 e4 f0             	and    $0xfffffff0,%esp
    12a7:	ff 71 fc             	pushl  -0x4(%ecx)
    12aa:	55                   	push   %ebp
    12ab:	89 e5                	mov    %esp,%ebp
    12ad:	51                   	push   %ecx
    12ae:	83 ec 14             	sub    $0x14,%esp
  static char buf[100];
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
    12b1:	eb 16                	jmp    12c9 <main+0x29>
    if(fd >= 3){
    12b3:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
    12b7:	7e 10                	jle    12c9 <main+0x29>
      close(fd);
    12b9:	83 ec 0c             	sub    $0xc,%esp
    12bc:	ff 75 f4             	pushl  -0xc(%ebp)
    12bf:	e8 39 0c 00 00       	call   1efd <close>
    12c4:	83 c4 10             	add    $0x10,%esp
      break;
    12c7:	eb 1b                	jmp    12e4 <main+0x44>
{
  static char buf[100];
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
    12c9:	83 ec 08             	sub    $0x8,%esp
    12cc:	6a 02                	push   $0x2
    12ce:	68 ab 24 00 00       	push   $0x24ab
    12d3:	e8 3d 0c 00 00       	call   1f15 <open>
    12d8:	83 c4 10             	add    $0x10,%esp
    12db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    12de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12e2:	79 cf                	jns    12b3 <main+0x13>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
    12e4:	e9 94 00 00 00       	jmp    137d <main+0xdd>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
    12e9:	0f b6 05 80 2a 00 00 	movzbl 0x2a80,%eax
    12f0:	3c 63                	cmp    $0x63,%al
    12f2:	75 5f                	jne    1353 <main+0xb3>
    12f4:	0f b6 05 81 2a 00 00 	movzbl 0x2a81,%eax
    12fb:	3c 64                	cmp    $0x64,%al
    12fd:	75 54                	jne    1353 <main+0xb3>
    12ff:	0f b6 05 82 2a 00 00 	movzbl 0x2a82,%eax
    1306:	3c 20                	cmp    $0x20,%al
    1308:	75 49                	jne    1353 <main+0xb3>
      // Chdir must be called by the parent, not the child.
      buf[strlen(buf)-1] = 0;  // chop \n
    130a:	83 ec 0c             	sub    $0xc,%esp
    130d:	68 80 2a 00 00       	push   $0x2a80
    1312:	e8 fc 09 00 00       	call   1d13 <strlen>
    1317:	83 c4 10             	add    $0x10,%esp
    131a:	83 e8 01             	sub    $0x1,%eax
    131d:	c6 80 80 2a 00 00 00 	movb   $0x0,0x2a80(%eax)
      if(chdir(buf+3) < 0)
    1324:	b8 83 2a 00 00       	mov    $0x2a83,%eax
    1329:	83 ec 0c             	sub    $0xc,%esp
    132c:	50                   	push   %eax
    132d:	e8 13 0c 00 00       	call   1f45 <chdir>
    1332:	83 c4 10             	add    $0x10,%esp
    1335:	85 c0                	test   %eax,%eax
    1337:	79 44                	jns    137d <main+0xdd>
        printf(2, "cannot cd %s\n", buf+3);
    1339:	b8 83 2a 00 00       	mov    $0x2a83,%eax
    133e:	83 ec 04             	sub    $0x4,%esp
    1341:	50                   	push   %eax
    1342:	68 b3 24 00 00       	push   $0x24b3
    1347:	6a 02                	push   $0x2
    1349:	e8 0e 0d 00 00       	call   205c <printf>
    134e:	83 c4 10             	add    $0x10,%esp
      continue;
    1351:	eb 2a                	jmp    137d <main+0xdd>
    }
    if(fork1() == 0)
    1353:	e8 64 00 00 00       	call   13bc <fork1>
    1358:	85 c0                	test   %eax,%eax
    135a:	75 1c                	jne    1378 <main+0xd8>
      runcmd(parsecmd(buf));
    135c:	83 ec 0c             	sub    $0xc,%esp
    135f:	68 80 2a 00 00       	push   $0x2a80
    1364:	e8 ab 03 00 00       	call   1714 <parsecmd>
    1369:	83 c4 10             	add    $0x10,%esp
    136c:	83 ec 0c             	sub    $0xc,%esp
    136f:	50                   	push   %eax
    1370:	e8 8b fc ff ff       	call   1000 <runcmd>
    1375:	83 c4 10             	add    $0x10,%esp
    wait();
    1378:	e8 60 0b 00 00       	call   1edd <wait>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
    137d:	83 ec 08             	sub    $0x8,%esp
    1380:	6a 64                	push   $0x64
    1382:	68 80 2a 00 00       	push   $0x2a80
    1387:	e8 bf fe ff ff       	call   124b <getcmd>
    138c:	83 c4 10             	add    $0x10,%esp
    138f:	85 c0                	test   %eax,%eax
    1391:	0f 89 52 ff ff ff    	jns    12e9 <main+0x49>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
    1397:	e8 39 0b 00 00       	call   1ed5 <exit>

0000139c <panic>:
}

void
panic(char *s)
{
    139c:	55                   	push   %ebp
    139d:	89 e5                	mov    %esp,%ebp
    139f:	83 ec 08             	sub    $0x8,%esp
  printf(2, "%s\n", s);
    13a2:	83 ec 04             	sub    $0x4,%esp
    13a5:	ff 75 08             	pushl  0x8(%ebp)
    13a8:	68 c1 24 00 00       	push   $0x24c1
    13ad:	6a 02                	push   $0x2
    13af:	e8 a8 0c 00 00       	call   205c <printf>
    13b4:	83 c4 10             	add    $0x10,%esp
  exit();
    13b7:	e8 19 0b 00 00       	call   1ed5 <exit>

000013bc <fork1>:
}

int
fork1(void)
{
    13bc:	55                   	push   %ebp
    13bd:	89 e5                	mov    %esp,%ebp
    13bf:	83 ec 18             	sub    $0x18,%esp
  int pid;

  pid = fork();
    13c2:	e8 06 0b 00 00       	call   1ecd <fork>
    13c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
    13ca:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    13ce:	75 10                	jne    13e0 <fork1+0x24>
    panic("fork");
    13d0:	83 ec 0c             	sub    $0xc,%esp
    13d3:	68 c5 24 00 00       	push   $0x24c5
    13d8:	e8 bf ff ff ff       	call   139c <panic>
    13dd:	83 c4 10             	add    $0x10,%esp
  return pid;
    13e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    13e3:	c9                   	leave  
    13e4:	c3                   	ret    

000013e5 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
    13e5:	55                   	push   %ebp
    13e6:	89 e5                	mov    %esp,%ebp
    13e8:	83 ec 18             	sub    $0x18,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
    13eb:	83 ec 0c             	sub    $0xc,%esp
    13ee:	6a 54                	push   $0x54
    13f0:	e8 3a 0f 00 00       	call   232f <malloc>
    13f5:	83 c4 10             	add    $0x10,%esp
    13f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
    13fb:	83 ec 04             	sub    $0x4,%esp
    13fe:	6a 54                	push   $0x54
    1400:	6a 00                	push   $0x0
    1402:	ff 75 f4             	pushl  -0xc(%ebp)
    1405:	e8 30 09 00 00       	call   1d3a <memset>
    140a:	83 c4 10             	add    $0x10,%esp
  cmd->type = EXEC;
    140d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1410:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
    1416:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    1419:	c9                   	leave  
    141a:	c3                   	ret    

0000141b <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
    141b:	55                   	push   %ebp
    141c:	89 e5                	mov    %esp,%ebp
    141e:	83 ec 18             	sub    $0x18,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
    1421:	83 ec 0c             	sub    $0xc,%esp
    1424:	6a 18                	push   $0x18
    1426:	e8 04 0f 00 00       	call   232f <malloc>
    142b:	83 c4 10             	add    $0x10,%esp
    142e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
    1431:	83 ec 04             	sub    $0x4,%esp
    1434:	6a 18                	push   $0x18
    1436:	6a 00                	push   $0x0
    1438:	ff 75 f4             	pushl  -0xc(%ebp)
    143b:	e8 fa 08 00 00       	call   1d3a <memset>
    1440:	83 c4 10             	add    $0x10,%esp
  cmd->type = REDIR;
    1443:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1446:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
    144c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    144f:	8b 55 08             	mov    0x8(%ebp),%edx
    1452:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
    1455:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1458:	8b 55 0c             	mov    0xc(%ebp),%edx
    145b:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
    145e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1461:	8b 55 10             	mov    0x10(%ebp),%edx
    1464:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
    1467:	8b 45 f4             	mov    -0xc(%ebp),%eax
    146a:	8b 55 14             	mov    0x14(%ebp),%edx
    146d:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
    1470:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1473:	8b 55 18             	mov    0x18(%ebp),%edx
    1476:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
    1479:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    147c:	c9                   	leave  
    147d:	c3                   	ret    

0000147e <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
    147e:	55                   	push   %ebp
    147f:	89 e5                	mov    %esp,%ebp
    1481:	83 ec 18             	sub    $0x18,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
    1484:	83 ec 0c             	sub    $0xc,%esp
    1487:	6a 0c                	push   $0xc
    1489:	e8 a1 0e 00 00       	call   232f <malloc>
    148e:	83 c4 10             	add    $0x10,%esp
    1491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
    1494:	83 ec 04             	sub    $0x4,%esp
    1497:	6a 0c                	push   $0xc
    1499:	6a 00                	push   $0x0
    149b:	ff 75 f4             	pushl  -0xc(%ebp)
    149e:	e8 97 08 00 00       	call   1d3a <memset>
    14a3:	83 c4 10             	add    $0x10,%esp
  cmd->type = PIPE;
    14a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a9:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
    14af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b2:	8b 55 08             	mov    0x8(%ebp),%edx
    14b5:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
    14b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14bb:	8b 55 0c             	mov    0xc(%ebp),%edx
    14be:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
    14c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    14c4:	c9                   	leave  
    14c5:	c3                   	ret    

000014c6 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
    14c6:	55                   	push   %ebp
    14c7:	89 e5                	mov    %esp,%ebp
    14c9:	83 ec 18             	sub    $0x18,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
    14cc:	83 ec 0c             	sub    $0xc,%esp
    14cf:	6a 0c                	push   $0xc
    14d1:	e8 59 0e 00 00       	call   232f <malloc>
    14d6:	83 c4 10             	add    $0x10,%esp
    14d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
    14dc:	83 ec 04             	sub    $0x4,%esp
    14df:	6a 0c                	push   $0xc
    14e1:	6a 00                	push   $0x0
    14e3:	ff 75 f4             	pushl  -0xc(%ebp)
    14e6:	e8 4f 08 00 00       	call   1d3a <memset>
    14eb:	83 c4 10             	add    $0x10,%esp
  cmd->type = LIST;
    14ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14f1:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
    14f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14fa:	8b 55 08             	mov    0x8(%ebp),%edx
    14fd:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
    1500:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1503:	8b 55 0c             	mov    0xc(%ebp),%edx
    1506:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
    1509:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    150c:	c9                   	leave  
    150d:	c3                   	ret    

0000150e <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
    150e:	55                   	push   %ebp
    150f:	89 e5                	mov    %esp,%ebp
    1511:	83 ec 18             	sub    $0x18,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
    1514:	83 ec 0c             	sub    $0xc,%esp
    1517:	6a 08                	push   $0x8
    1519:	e8 11 0e 00 00       	call   232f <malloc>
    151e:	83 c4 10             	add    $0x10,%esp
    1521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
    1524:	83 ec 04             	sub    $0x4,%esp
    1527:	6a 08                	push   $0x8
    1529:	6a 00                	push   $0x0
    152b:	ff 75 f4             	pushl  -0xc(%ebp)
    152e:	e8 07 08 00 00       	call   1d3a <memset>
    1533:	83 c4 10             	add    $0x10,%esp
  cmd->type = BACK;
    1536:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1539:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
    153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1542:	8b 55 08             	mov    0x8(%ebp),%edx
    1545:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
    1548:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    154b:	c9                   	leave  
    154c:	c3                   	ret    

0000154d <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
    154d:	55                   	push   %ebp
    154e:	89 e5                	mov    %esp,%ebp
    1550:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int ret;

  s = *ps;
    1553:	8b 45 08             	mov    0x8(%ebp),%eax
    1556:	8b 00                	mov    (%eax),%eax
    1558:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
    155b:	eb 04                	jmp    1561 <gettoken+0x14>
    s++;
    155d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
    1561:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1564:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1567:	73 1e                	jae    1587 <gettoken+0x3a>
    1569:	8b 45 f4             	mov    -0xc(%ebp),%eax
    156c:	0f b6 00             	movzbl (%eax),%eax
    156f:	0f be c0             	movsbl %al,%eax
    1572:	83 ec 08             	sub    $0x8,%esp
    1575:	50                   	push   %eax
    1576:	68 40 2a 00 00       	push   $0x2a40
    157b:	e8 d4 07 00 00       	call   1d54 <strchr>
    1580:	83 c4 10             	add    $0x10,%esp
    1583:	85 c0                	test   %eax,%eax
    1585:	75 d6                	jne    155d <gettoken+0x10>
    s++;
  if(q)
    1587:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    158b:	74 08                	je     1595 <gettoken+0x48>
    *q = s;
    158d:	8b 45 10             	mov    0x10(%ebp),%eax
    1590:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1593:	89 10                	mov    %edx,(%eax)
  ret = *s;
    1595:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1598:	0f b6 00             	movzbl (%eax),%eax
    159b:	0f be c0             	movsbl %al,%eax
    159e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
    15a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15a4:	0f b6 00             	movzbl (%eax),%eax
    15a7:	0f be c0             	movsbl %al,%eax
    15aa:	83 f8 29             	cmp    $0x29,%eax
    15ad:	7f 14                	jg     15c3 <gettoken+0x76>
    15af:	83 f8 28             	cmp    $0x28,%eax
    15b2:	7d 28                	jge    15dc <gettoken+0x8f>
    15b4:	85 c0                	test   %eax,%eax
    15b6:	0f 84 94 00 00 00    	je     1650 <gettoken+0x103>
    15bc:	83 f8 26             	cmp    $0x26,%eax
    15bf:	74 1b                	je     15dc <gettoken+0x8f>
    15c1:	eb 3a                	jmp    15fd <gettoken+0xb0>
    15c3:	83 f8 3e             	cmp    $0x3e,%eax
    15c6:	74 1a                	je     15e2 <gettoken+0x95>
    15c8:	83 f8 3e             	cmp    $0x3e,%eax
    15cb:	7f 0a                	jg     15d7 <gettoken+0x8a>
    15cd:	83 e8 3b             	sub    $0x3b,%eax
    15d0:	83 f8 01             	cmp    $0x1,%eax
    15d3:	77 28                	ja     15fd <gettoken+0xb0>
    15d5:	eb 05                	jmp    15dc <gettoken+0x8f>
    15d7:	83 f8 7c             	cmp    $0x7c,%eax
    15da:	75 21                	jne    15fd <gettoken+0xb0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
    15dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
    15e0:	eb 75                	jmp    1657 <gettoken+0x10a>
  case '>':
    s++;
    15e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
    15e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15e9:	0f b6 00             	movzbl (%eax),%eax
    15ec:	3c 3e                	cmp    $0x3e,%al
    15ee:	75 63                	jne    1653 <gettoken+0x106>
      ret = '+';
    15f0:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
    15f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
    15fb:	eb 56                	jmp    1653 <gettoken+0x106>
  default:
    ret = 'a';
    15fd:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
    1604:	eb 04                	jmp    160a <gettoken+0xbd>
      s++;
    1606:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
    160a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    160d:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1610:	73 44                	jae    1656 <gettoken+0x109>
    1612:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1615:	0f b6 00             	movzbl (%eax),%eax
    1618:	0f be c0             	movsbl %al,%eax
    161b:	83 ec 08             	sub    $0x8,%esp
    161e:	50                   	push   %eax
    161f:	68 40 2a 00 00       	push   $0x2a40
    1624:	e8 2b 07 00 00       	call   1d54 <strchr>
    1629:	83 c4 10             	add    $0x10,%esp
    162c:	85 c0                	test   %eax,%eax
    162e:	75 26                	jne    1656 <gettoken+0x109>
    1630:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1633:	0f b6 00             	movzbl (%eax),%eax
    1636:	0f be c0             	movsbl %al,%eax
    1639:	83 ec 08             	sub    $0x8,%esp
    163c:	50                   	push   %eax
    163d:	68 48 2a 00 00       	push   $0x2a48
    1642:	e8 0d 07 00 00       	call   1d54 <strchr>
    1647:	83 c4 10             	add    $0x10,%esp
    164a:	85 c0                	test   %eax,%eax
    164c:	74 b8                	je     1606 <gettoken+0xb9>
      s++;
    break;
    164e:	eb 06                	jmp    1656 <gettoken+0x109>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
    1650:	90                   	nop
    1651:	eb 04                	jmp    1657 <gettoken+0x10a>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
    1653:	90                   	nop
    1654:	eb 01                	jmp    1657 <gettoken+0x10a>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
    1656:	90                   	nop
  }
  if(eq)
    1657:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    165b:	74 0e                	je     166b <gettoken+0x11e>
    *eq = s;
    165d:	8b 45 14             	mov    0x14(%ebp),%eax
    1660:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1663:	89 10                	mov    %edx,(%eax)

  while(s < es && strchr(whitespace, *s))
    1665:	eb 04                	jmp    166b <gettoken+0x11e>
    s++;
    1667:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;

  while(s < es && strchr(whitespace, *s))
    166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    166e:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1671:	73 1e                	jae    1691 <gettoken+0x144>
    1673:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1676:	0f b6 00             	movzbl (%eax),%eax
    1679:	0f be c0             	movsbl %al,%eax
    167c:	83 ec 08             	sub    $0x8,%esp
    167f:	50                   	push   %eax
    1680:	68 40 2a 00 00       	push   $0x2a40
    1685:	e8 ca 06 00 00       	call   1d54 <strchr>
    168a:	83 c4 10             	add    $0x10,%esp
    168d:	85 c0                	test   %eax,%eax
    168f:	75 d6                	jne    1667 <gettoken+0x11a>
    s++;
  *ps = s;
    1691:	8b 45 08             	mov    0x8(%ebp),%eax
    1694:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1697:	89 10                	mov    %edx,(%eax)
  return ret;
    1699:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    169c:	c9                   	leave  
    169d:	c3                   	ret    

0000169e <peek>:

int
peek(char **ps, char *es, char *toks)
{
    169e:	55                   	push   %ebp
    169f:	89 e5                	mov    %esp,%ebp
    16a1:	83 ec 18             	sub    $0x18,%esp
  char *s;

  s = *ps;
    16a4:	8b 45 08             	mov    0x8(%ebp),%eax
    16a7:	8b 00                	mov    (%eax),%eax
    16a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
    16ac:	eb 04                	jmp    16b2 <peek+0x14>
    s++;
    16ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
    16b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16b5:	3b 45 0c             	cmp    0xc(%ebp),%eax
    16b8:	73 1e                	jae    16d8 <peek+0x3a>
    16ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16bd:	0f b6 00             	movzbl (%eax),%eax
    16c0:	0f be c0             	movsbl %al,%eax
    16c3:	83 ec 08             	sub    $0x8,%esp
    16c6:	50                   	push   %eax
    16c7:	68 40 2a 00 00       	push   $0x2a40
    16cc:	e8 83 06 00 00       	call   1d54 <strchr>
    16d1:	83 c4 10             	add    $0x10,%esp
    16d4:	85 c0                	test   %eax,%eax
    16d6:	75 d6                	jne    16ae <peek+0x10>
    s++;
  *ps = s;
    16d8:	8b 45 08             	mov    0x8(%ebp),%eax
    16db:	8b 55 f4             	mov    -0xc(%ebp),%edx
    16de:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
    16e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16e3:	0f b6 00             	movzbl (%eax),%eax
    16e6:	84 c0                	test   %al,%al
    16e8:	74 23                	je     170d <peek+0x6f>
    16ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16ed:	0f b6 00             	movzbl (%eax),%eax
    16f0:	0f be c0             	movsbl %al,%eax
    16f3:	83 ec 08             	sub    $0x8,%esp
    16f6:	50                   	push   %eax
    16f7:	ff 75 10             	pushl  0x10(%ebp)
    16fa:	e8 55 06 00 00       	call   1d54 <strchr>
    16ff:	83 c4 10             	add    $0x10,%esp
    1702:	85 c0                	test   %eax,%eax
    1704:	74 07                	je     170d <peek+0x6f>
    1706:	b8 01 00 00 00       	mov    $0x1,%eax
    170b:	eb 05                	jmp    1712 <peek+0x74>
    170d:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1712:	c9                   	leave  
    1713:	c3                   	ret    

00001714 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
    1714:	55                   	push   %ebp
    1715:	89 e5                	mov    %esp,%ebp
    1717:	53                   	push   %ebx
    1718:	83 ec 14             	sub    $0x14,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
    171b:	8b 5d 08             	mov    0x8(%ebp),%ebx
    171e:	8b 45 08             	mov    0x8(%ebp),%eax
    1721:	83 ec 0c             	sub    $0xc,%esp
    1724:	50                   	push   %eax
    1725:	e8 e9 05 00 00       	call   1d13 <strlen>
    172a:	83 c4 10             	add    $0x10,%esp
    172d:	01 d8                	add    %ebx,%eax
    172f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
    1732:	83 ec 08             	sub    $0x8,%esp
    1735:	ff 75 f4             	pushl  -0xc(%ebp)
    1738:	8d 45 08             	lea    0x8(%ebp),%eax
    173b:	50                   	push   %eax
    173c:	e8 61 00 00 00       	call   17a2 <parseline>
    1741:	83 c4 10             	add    $0x10,%esp
    1744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
    1747:	83 ec 04             	sub    $0x4,%esp
    174a:	68 ca 24 00 00       	push   $0x24ca
    174f:	ff 75 f4             	pushl  -0xc(%ebp)
    1752:	8d 45 08             	lea    0x8(%ebp),%eax
    1755:	50                   	push   %eax
    1756:	e8 43 ff ff ff       	call   169e <peek>
    175b:	83 c4 10             	add    $0x10,%esp
  if(s != es){
    175e:	8b 45 08             	mov    0x8(%ebp),%eax
    1761:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    1764:	74 26                	je     178c <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
    1766:	8b 45 08             	mov    0x8(%ebp),%eax
    1769:	83 ec 04             	sub    $0x4,%esp
    176c:	50                   	push   %eax
    176d:	68 cb 24 00 00       	push   $0x24cb
    1772:	6a 02                	push   $0x2
    1774:	e8 e3 08 00 00       	call   205c <printf>
    1779:	83 c4 10             	add    $0x10,%esp
    panic("syntax");
    177c:	83 ec 0c             	sub    $0xc,%esp
    177f:	68 da 24 00 00       	push   $0x24da
    1784:	e8 13 fc ff ff       	call   139c <panic>
    1789:	83 c4 10             	add    $0x10,%esp
  }
  nulterminate(cmd);
    178c:	83 ec 0c             	sub    $0xc,%esp
    178f:	ff 75 f0             	pushl  -0x10(%ebp)
    1792:	e8 eb 03 00 00       	call   1b82 <nulterminate>
    1797:	83 c4 10             	add    $0x10,%esp
  return cmd;
    179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    179d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    17a0:	c9                   	leave  
    17a1:	c3                   	ret    

000017a2 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
    17a2:	55                   	push   %ebp
    17a3:	89 e5                	mov    %esp,%ebp
    17a5:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
    17a8:	83 ec 08             	sub    $0x8,%esp
    17ab:	ff 75 0c             	pushl  0xc(%ebp)
    17ae:	ff 75 08             	pushl  0x8(%ebp)
    17b1:	e8 99 00 00 00       	call   184f <parsepipe>
    17b6:	83 c4 10             	add    $0x10,%esp
    17b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
    17bc:	eb 23                	jmp    17e1 <parseline+0x3f>
    gettoken(ps, es, 0, 0);
    17be:	6a 00                	push   $0x0
    17c0:	6a 00                	push   $0x0
    17c2:	ff 75 0c             	pushl  0xc(%ebp)
    17c5:	ff 75 08             	pushl  0x8(%ebp)
    17c8:	e8 80 fd ff ff       	call   154d <gettoken>
    17cd:	83 c4 10             	add    $0x10,%esp
    cmd = backcmd(cmd);
    17d0:	83 ec 0c             	sub    $0xc,%esp
    17d3:	ff 75 f4             	pushl  -0xc(%ebp)
    17d6:	e8 33 fd ff ff       	call   150e <backcmd>
    17db:	83 c4 10             	add    $0x10,%esp
    17de:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
    17e1:	83 ec 04             	sub    $0x4,%esp
    17e4:	68 e1 24 00 00       	push   $0x24e1
    17e9:	ff 75 0c             	pushl  0xc(%ebp)
    17ec:	ff 75 08             	pushl  0x8(%ebp)
    17ef:	e8 aa fe ff ff       	call   169e <peek>
    17f4:	83 c4 10             	add    $0x10,%esp
    17f7:	85 c0                	test   %eax,%eax
    17f9:	75 c3                	jne    17be <parseline+0x1c>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
    17fb:	83 ec 04             	sub    $0x4,%esp
    17fe:	68 e3 24 00 00       	push   $0x24e3
    1803:	ff 75 0c             	pushl  0xc(%ebp)
    1806:	ff 75 08             	pushl  0x8(%ebp)
    1809:	e8 90 fe ff ff       	call   169e <peek>
    180e:	83 c4 10             	add    $0x10,%esp
    1811:	85 c0                	test   %eax,%eax
    1813:	74 35                	je     184a <parseline+0xa8>
    gettoken(ps, es, 0, 0);
    1815:	6a 00                	push   $0x0
    1817:	6a 00                	push   $0x0
    1819:	ff 75 0c             	pushl  0xc(%ebp)
    181c:	ff 75 08             	pushl  0x8(%ebp)
    181f:	e8 29 fd ff ff       	call   154d <gettoken>
    1824:	83 c4 10             	add    $0x10,%esp
    cmd = listcmd(cmd, parseline(ps, es));
    1827:	83 ec 08             	sub    $0x8,%esp
    182a:	ff 75 0c             	pushl  0xc(%ebp)
    182d:	ff 75 08             	pushl  0x8(%ebp)
    1830:	e8 6d ff ff ff       	call   17a2 <parseline>
    1835:	83 c4 10             	add    $0x10,%esp
    1838:	83 ec 08             	sub    $0x8,%esp
    183b:	50                   	push   %eax
    183c:	ff 75 f4             	pushl  -0xc(%ebp)
    183f:	e8 82 fc ff ff       	call   14c6 <listcmd>
    1844:	83 c4 10             	add    $0x10,%esp
    1847:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
    184a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    184d:	c9                   	leave  
    184e:	c3                   	ret    

0000184f <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
    184f:	55                   	push   %ebp
    1850:	89 e5                	mov    %esp,%ebp
    1852:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
    1855:	83 ec 08             	sub    $0x8,%esp
    1858:	ff 75 0c             	pushl  0xc(%ebp)
    185b:	ff 75 08             	pushl  0x8(%ebp)
    185e:	e8 ec 01 00 00       	call   1a4f <parseexec>
    1863:	83 c4 10             	add    $0x10,%esp
    1866:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
    1869:	83 ec 04             	sub    $0x4,%esp
    186c:	68 e5 24 00 00       	push   $0x24e5
    1871:	ff 75 0c             	pushl  0xc(%ebp)
    1874:	ff 75 08             	pushl  0x8(%ebp)
    1877:	e8 22 fe ff ff       	call   169e <peek>
    187c:	83 c4 10             	add    $0x10,%esp
    187f:	85 c0                	test   %eax,%eax
    1881:	74 35                	je     18b8 <parsepipe+0x69>
    gettoken(ps, es, 0, 0);
    1883:	6a 00                	push   $0x0
    1885:	6a 00                	push   $0x0
    1887:	ff 75 0c             	pushl  0xc(%ebp)
    188a:	ff 75 08             	pushl  0x8(%ebp)
    188d:	e8 bb fc ff ff       	call   154d <gettoken>
    1892:	83 c4 10             	add    $0x10,%esp
    cmd = pipecmd(cmd, parsepipe(ps, es));
    1895:	83 ec 08             	sub    $0x8,%esp
    1898:	ff 75 0c             	pushl  0xc(%ebp)
    189b:	ff 75 08             	pushl  0x8(%ebp)
    189e:	e8 ac ff ff ff       	call   184f <parsepipe>
    18a3:	83 c4 10             	add    $0x10,%esp
    18a6:	83 ec 08             	sub    $0x8,%esp
    18a9:	50                   	push   %eax
    18aa:	ff 75 f4             	pushl  -0xc(%ebp)
    18ad:	e8 cc fb ff ff       	call   147e <pipecmd>
    18b2:	83 c4 10             	add    $0x10,%esp
    18b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
    18b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    18bb:	c9                   	leave  
    18bc:	c3                   	ret    

000018bd <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
    18bd:	55                   	push   %ebp
    18be:	89 e5                	mov    %esp,%ebp
    18c0:	83 ec 18             	sub    $0x18,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
    18c3:	e9 b6 00 00 00       	jmp    197e <parseredirs+0xc1>
    tok = gettoken(ps, es, 0, 0);
    18c8:	6a 00                	push   $0x0
    18ca:	6a 00                	push   $0x0
    18cc:	ff 75 10             	pushl  0x10(%ebp)
    18cf:	ff 75 0c             	pushl  0xc(%ebp)
    18d2:	e8 76 fc ff ff       	call   154d <gettoken>
    18d7:	83 c4 10             	add    $0x10,%esp
    18da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
    18dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
    18e0:	50                   	push   %eax
    18e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
    18e4:	50                   	push   %eax
    18e5:	ff 75 10             	pushl  0x10(%ebp)
    18e8:	ff 75 0c             	pushl  0xc(%ebp)
    18eb:	e8 5d fc ff ff       	call   154d <gettoken>
    18f0:	83 c4 10             	add    $0x10,%esp
    18f3:	83 f8 61             	cmp    $0x61,%eax
    18f6:	74 10                	je     1908 <parseredirs+0x4b>
      panic("missing file for redirection");
    18f8:	83 ec 0c             	sub    $0xc,%esp
    18fb:	68 e7 24 00 00       	push   $0x24e7
    1900:	e8 97 fa ff ff       	call   139c <panic>
    1905:	83 c4 10             	add    $0x10,%esp
    switch(tok){
    1908:	8b 45 f4             	mov    -0xc(%ebp),%eax
    190b:	83 f8 3c             	cmp    $0x3c,%eax
    190e:	74 0c                	je     191c <parseredirs+0x5f>
    1910:	83 f8 3e             	cmp    $0x3e,%eax
    1913:	74 26                	je     193b <parseredirs+0x7e>
    1915:	83 f8 2b             	cmp    $0x2b,%eax
    1918:	74 43                	je     195d <parseredirs+0xa0>
    191a:	eb 62                	jmp    197e <parseredirs+0xc1>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
    191c:	8b 55 ec             	mov    -0x14(%ebp),%edx
    191f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1922:	83 ec 0c             	sub    $0xc,%esp
    1925:	6a 00                	push   $0x0
    1927:	6a 00                	push   $0x0
    1929:	52                   	push   %edx
    192a:	50                   	push   %eax
    192b:	ff 75 08             	pushl  0x8(%ebp)
    192e:	e8 e8 fa ff ff       	call   141b <redircmd>
    1933:	83 c4 20             	add    $0x20,%esp
    1936:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
    1939:	eb 43                	jmp    197e <parseredirs+0xc1>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
    193b:	8b 55 ec             	mov    -0x14(%ebp),%edx
    193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1941:	83 ec 0c             	sub    $0xc,%esp
    1944:	6a 01                	push   $0x1
    1946:	68 01 02 00 00       	push   $0x201
    194b:	52                   	push   %edx
    194c:	50                   	push   %eax
    194d:	ff 75 08             	pushl  0x8(%ebp)
    1950:	e8 c6 fa ff ff       	call   141b <redircmd>
    1955:	83 c4 20             	add    $0x20,%esp
    1958:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
    195b:	eb 21                	jmp    197e <parseredirs+0xc1>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
    195d:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1960:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1963:	83 ec 0c             	sub    $0xc,%esp
    1966:	6a 01                	push   $0x1
    1968:	68 01 02 00 00       	push   $0x201
    196d:	52                   	push   %edx
    196e:	50                   	push   %eax
    196f:	ff 75 08             	pushl  0x8(%ebp)
    1972:	e8 a4 fa ff ff       	call   141b <redircmd>
    1977:	83 c4 20             	add    $0x20,%esp
    197a:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
    197d:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
    197e:	83 ec 04             	sub    $0x4,%esp
    1981:	68 04 25 00 00       	push   $0x2504
    1986:	ff 75 10             	pushl  0x10(%ebp)
    1989:	ff 75 0c             	pushl  0xc(%ebp)
    198c:	e8 0d fd ff ff       	call   169e <peek>
    1991:	83 c4 10             	add    $0x10,%esp
    1994:	85 c0                	test   %eax,%eax
    1996:	0f 85 2c ff ff ff    	jne    18c8 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
    199c:	8b 45 08             	mov    0x8(%ebp),%eax
}
    199f:	c9                   	leave  
    19a0:	c3                   	ret    

000019a1 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
    19a1:	55                   	push   %ebp
    19a2:	89 e5                	mov    %esp,%ebp
    19a4:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
    19a7:	83 ec 04             	sub    $0x4,%esp
    19aa:	68 07 25 00 00       	push   $0x2507
    19af:	ff 75 0c             	pushl  0xc(%ebp)
    19b2:	ff 75 08             	pushl  0x8(%ebp)
    19b5:	e8 e4 fc ff ff       	call   169e <peek>
    19ba:	83 c4 10             	add    $0x10,%esp
    19bd:	85 c0                	test   %eax,%eax
    19bf:	75 10                	jne    19d1 <parseblock+0x30>
    panic("parseblock");
    19c1:	83 ec 0c             	sub    $0xc,%esp
    19c4:	68 09 25 00 00       	push   $0x2509
    19c9:	e8 ce f9 ff ff       	call   139c <panic>
    19ce:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
    19d1:	6a 00                	push   $0x0
    19d3:	6a 00                	push   $0x0
    19d5:	ff 75 0c             	pushl  0xc(%ebp)
    19d8:	ff 75 08             	pushl  0x8(%ebp)
    19db:	e8 6d fb ff ff       	call   154d <gettoken>
    19e0:	83 c4 10             	add    $0x10,%esp
  cmd = parseline(ps, es);
    19e3:	83 ec 08             	sub    $0x8,%esp
    19e6:	ff 75 0c             	pushl  0xc(%ebp)
    19e9:	ff 75 08             	pushl  0x8(%ebp)
    19ec:	e8 b1 fd ff ff       	call   17a2 <parseline>
    19f1:	83 c4 10             	add    $0x10,%esp
    19f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
    19f7:	83 ec 04             	sub    $0x4,%esp
    19fa:	68 14 25 00 00       	push   $0x2514
    19ff:	ff 75 0c             	pushl  0xc(%ebp)
    1a02:	ff 75 08             	pushl  0x8(%ebp)
    1a05:	e8 94 fc ff ff       	call   169e <peek>
    1a0a:	83 c4 10             	add    $0x10,%esp
    1a0d:	85 c0                	test   %eax,%eax
    1a0f:	75 10                	jne    1a21 <parseblock+0x80>
    panic("syntax - missing )");
    1a11:	83 ec 0c             	sub    $0xc,%esp
    1a14:	68 16 25 00 00       	push   $0x2516
    1a19:	e8 7e f9 ff ff       	call   139c <panic>
    1a1e:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
    1a21:	6a 00                	push   $0x0
    1a23:	6a 00                	push   $0x0
    1a25:	ff 75 0c             	pushl  0xc(%ebp)
    1a28:	ff 75 08             	pushl  0x8(%ebp)
    1a2b:	e8 1d fb ff ff       	call   154d <gettoken>
    1a30:	83 c4 10             	add    $0x10,%esp
  cmd = parseredirs(cmd, ps, es);
    1a33:	83 ec 04             	sub    $0x4,%esp
    1a36:	ff 75 0c             	pushl  0xc(%ebp)
    1a39:	ff 75 08             	pushl  0x8(%ebp)
    1a3c:	ff 75 f4             	pushl  -0xc(%ebp)
    1a3f:	e8 79 fe ff ff       	call   18bd <parseredirs>
    1a44:	83 c4 10             	add    $0x10,%esp
    1a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
    1a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
    1a4d:	c9                   	leave  
    1a4e:	c3                   	ret    

00001a4f <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
    1a4f:	55                   	push   %ebp
    1a50:	89 e5                	mov    %esp,%ebp
    1a52:	83 ec 28             	sub    $0x28,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
    1a55:	83 ec 04             	sub    $0x4,%esp
    1a58:	68 07 25 00 00       	push   $0x2507
    1a5d:	ff 75 0c             	pushl  0xc(%ebp)
    1a60:	ff 75 08             	pushl  0x8(%ebp)
    1a63:	e8 36 fc ff ff       	call   169e <peek>
    1a68:	83 c4 10             	add    $0x10,%esp
    1a6b:	85 c0                	test   %eax,%eax
    1a6d:	74 16                	je     1a85 <parseexec+0x36>
    return parseblock(ps, es);
    1a6f:	83 ec 08             	sub    $0x8,%esp
    1a72:	ff 75 0c             	pushl  0xc(%ebp)
    1a75:	ff 75 08             	pushl  0x8(%ebp)
    1a78:	e8 24 ff ff ff       	call   19a1 <parseblock>
    1a7d:	83 c4 10             	add    $0x10,%esp
    1a80:	e9 fb 00 00 00       	jmp    1b80 <parseexec+0x131>

  ret = execcmd();
    1a85:	e8 5b f9 ff ff       	call   13e5 <execcmd>
    1a8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
    1a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a90:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
    1a93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
    1a9a:	83 ec 04             	sub    $0x4,%esp
    1a9d:	ff 75 0c             	pushl  0xc(%ebp)
    1aa0:	ff 75 08             	pushl  0x8(%ebp)
    1aa3:	ff 75 f0             	pushl  -0x10(%ebp)
    1aa6:	e8 12 fe ff ff       	call   18bd <parseredirs>
    1aab:	83 c4 10             	add    $0x10,%esp
    1aae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
    1ab1:	e9 87 00 00 00       	jmp    1b3d <parseexec+0xee>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
    1ab6:	8d 45 e0             	lea    -0x20(%ebp),%eax
    1ab9:	50                   	push   %eax
    1aba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    1abd:	50                   	push   %eax
    1abe:	ff 75 0c             	pushl  0xc(%ebp)
    1ac1:	ff 75 08             	pushl  0x8(%ebp)
    1ac4:	e8 84 fa ff ff       	call   154d <gettoken>
    1ac9:	83 c4 10             	add    $0x10,%esp
    1acc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    1acf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1ad3:	0f 84 84 00 00 00    	je     1b5d <parseexec+0x10e>
      break;
    if(tok != 'a')
    1ad9:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
    1add:	74 10                	je     1aef <parseexec+0xa0>
      panic("syntax");
    1adf:	83 ec 0c             	sub    $0xc,%esp
    1ae2:	68 da 24 00 00       	push   $0x24da
    1ae7:	e8 b0 f8 ff ff       	call   139c <panic>
    1aec:	83 c4 10             	add    $0x10,%esp
    cmd->argv[argc] = q;
    1aef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
    1af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1af8:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
    1afc:	8b 55 e0             	mov    -0x20(%ebp),%edx
    1aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1b02:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1b05:	83 c1 08             	add    $0x8,%ecx
    1b08:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
    1b0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
    1b10:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1b14:	7e 10                	jle    1b26 <parseexec+0xd7>
      panic("too many args");
    1b16:	83 ec 0c             	sub    $0xc,%esp
    1b19:	68 29 25 00 00       	push   $0x2529
    1b1e:	e8 79 f8 ff ff       	call   139c <panic>
    1b23:	83 c4 10             	add    $0x10,%esp
    ret = parseredirs(ret, ps, es);
    1b26:	83 ec 04             	sub    $0x4,%esp
    1b29:	ff 75 0c             	pushl  0xc(%ebp)
    1b2c:	ff 75 08             	pushl  0x8(%ebp)
    1b2f:	ff 75 f0             	pushl  -0x10(%ebp)
    1b32:	e8 86 fd ff ff       	call   18bd <parseredirs>
    1b37:	83 c4 10             	add    $0x10,%esp
    1b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
    1b3d:	83 ec 04             	sub    $0x4,%esp
    1b40:	68 37 25 00 00       	push   $0x2537
    1b45:	ff 75 0c             	pushl  0xc(%ebp)
    1b48:	ff 75 08             	pushl  0x8(%ebp)
    1b4b:	e8 4e fb ff ff       	call   169e <peek>
    1b50:	83 c4 10             	add    $0x10,%esp
    1b53:	85 c0                	test   %eax,%eax
    1b55:	0f 84 5b ff ff ff    	je     1ab6 <parseexec+0x67>
    1b5b:	eb 01                	jmp    1b5e <parseexec+0x10f>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    1b5d:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
    1b5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1b61:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1b64:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
    1b6b:	00 
  cmd->eargv[argc] = 0;
    1b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1b72:	83 c2 08             	add    $0x8,%edx
    1b75:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
    1b7c:	00 
  return ret;
    1b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1b80:	c9                   	leave  
    1b81:	c3                   	ret    

00001b82 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
    1b82:	55                   	push   %ebp
    1b83:	89 e5                	mov    %esp,%ebp
    1b85:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
    1b88:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    1b8c:	75 0a                	jne    1b98 <nulterminate+0x16>
    return 0;
    1b8e:	b8 00 00 00 00       	mov    $0x0,%eax
    1b93:	e9 e4 00 00 00       	jmp    1c7c <nulterminate+0xfa>

  switch(cmd->type){
    1b98:	8b 45 08             	mov    0x8(%ebp),%eax
    1b9b:	8b 00                	mov    (%eax),%eax
    1b9d:	83 f8 05             	cmp    $0x5,%eax
    1ba0:	0f 87 d3 00 00 00    	ja     1c79 <nulterminate+0xf7>
    1ba6:	8b 04 85 3c 25 00 00 	mov    0x253c(,%eax,4),%eax
    1bad:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    1baf:	8b 45 08             	mov    0x8(%ebp),%eax
    1bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
    1bb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1bbc:	eb 14                	jmp    1bd2 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
    1bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1bc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1bc4:	83 c2 08             	add    $0x8,%edx
    1bc7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
    1bcb:	c6 00 00             	movb   $0x0,(%eax)
    return 0;

  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
    1bce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1bd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1bd8:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
    1bdc:	85 c0                	test   %eax,%eax
    1bde:	75 de                	jne    1bbe <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
    1be0:	e9 94 00 00 00       	jmp    1c79 <nulterminate+0xf7>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    1be5:	8b 45 08             	mov    0x8(%ebp),%eax
    1be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
    1beb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1bee:	8b 40 04             	mov    0x4(%eax),%eax
    1bf1:	83 ec 0c             	sub    $0xc,%esp
    1bf4:	50                   	push   %eax
    1bf5:	e8 88 ff ff ff       	call   1b82 <nulterminate>
    1bfa:	83 c4 10             	add    $0x10,%esp
    *rcmd->efile = 0;
    1bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1c00:	8b 40 0c             	mov    0xc(%eax),%eax
    1c03:	c6 00 00             	movb   $0x0,(%eax)
    break;
    1c06:	eb 71                	jmp    1c79 <nulterminate+0xf7>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    1c08:	8b 45 08             	mov    0x8(%ebp),%eax
    1c0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
    1c0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c11:	8b 40 04             	mov    0x4(%eax),%eax
    1c14:	83 ec 0c             	sub    $0xc,%esp
    1c17:	50                   	push   %eax
    1c18:	e8 65 ff ff ff       	call   1b82 <nulterminate>
    1c1d:	83 c4 10             	add    $0x10,%esp
    nulterminate(pcmd->right);
    1c20:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c23:	8b 40 08             	mov    0x8(%eax),%eax
    1c26:	83 ec 0c             	sub    $0xc,%esp
    1c29:	50                   	push   %eax
    1c2a:	e8 53 ff ff ff       	call   1b82 <nulterminate>
    1c2f:	83 c4 10             	add    $0x10,%esp
    break;
    1c32:	eb 45                	jmp    1c79 <nulterminate+0xf7>

  case LIST:
    lcmd = (struct listcmd*)cmd;
    1c34:	8b 45 08             	mov    0x8(%ebp),%eax
    1c37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
    1c3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1c3d:	8b 40 04             	mov    0x4(%eax),%eax
    1c40:	83 ec 0c             	sub    $0xc,%esp
    1c43:	50                   	push   %eax
    1c44:	e8 39 ff ff ff       	call   1b82 <nulterminate>
    1c49:	83 c4 10             	add    $0x10,%esp
    nulterminate(lcmd->right);
    1c4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1c4f:	8b 40 08             	mov    0x8(%eax),%eax
    1c52:	83 ec 0c             	sub    $0xc,%esp
    1c55:	50                   	push   %eax
    1c56:	e8 27 ff ff ff       	call   1b82 <nulterminate>
    1c5b:	83 c4 10             	add    $0x10,%esp
    break;
    1c5e:	eb 19                	jmp    1c79 <nulterminate+0xf7>

  case BACK:
    bcmd = (struct backcmd*)cmd;
    1c60:	8b 45 08             	mov    0x8(%ebp),%eax
    1c63:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
    1c66:	8b 45 e0             	mov    -0x20(%ebp),%eax
    1c69:	8b 40 04             	mov    0x4(%eax),%eax
    1c6c:	83 ec 0c             	sub    $0xc,%esp
    1c6f:	50                   	push   %eax
    1c70:	e8 0d ff ff ff       	call   1b82 <nulterminate>
    1c75:	83 c4 10             	add    $0x10,%esp
    break;
    1c78:	90                   	nop
  }
  return cmd;
    1c79:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1c7c:	c9                   	leave  
    1c7d:	c3                   	ret    

00001c7e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1c7e:	55                   	push   %ebp
    1c7f:	89 e5                	mov    %esp,%ebp
    1c81:	57                   	push   %edi
    1c82:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1c86:	8b 55 10             	mov    0x10(%ebp),%edx
    1c89:	8b 45 0c             	mov    0xc(%ebp),%eax
    1c8c:	89 cb                	mov    %ecx,%ebx
    1c8e:	89 df                	mov    %ebx,%edi
    1c90:	89 d1                	mov    %edx,%ecx
    1c92:	fc                   	cld    
    1c93:	f3 aa                	rep stos %al,%es:(%edi)
    1c95:	89 ca                	mov    %ecx,%edx
    1c97:	89 fb                	mov    %edi,%ebx
    1c99:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1c9c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1c9f:	90                   	nop
    1ca0:	5b                   	pop    %ebx
    1ca1:	5f                   	pop    %edi
    1ca2:	5d                   	pop    %ebp
    1ca3:	c3                   	ret    

00001ca4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1ca4:	55                   	push   %ebp
    1ca5:	89 e5                	mov    %esp,%ebp
    1ca7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1caa:	8b 45 08             	mov    0x8(%ebp),%eax
    1cad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1cb0:	90                   	nop
    1cb1:	8b 45 08             	mov    0x8(%ebp),%eax
    1cb4:	8d 50 01             	lea    0x1(%eax),%edx
    1cb7:	89 55 08             	mov    %edx,0x8(%ebp)
    1cba:	8b 55 0c             	mov    0xc(%ebp),%edx
    1cbd:	8d 4a 01             	lea    0x1(%edx),%ecx
    1cc0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    1cc3:	0f b6 12             	movzbl (%edx),%edx
    1cc6:	88 10                	mov    %dl,(%eax)
    1cc8:	0f b6 00             	movzbl (%eax),%eax
    1ccb:	84 c0                	test   %al,%al
    1ccd:	75 e2                	jne    1cb1 <strcpy+0xd>
    ;
  return os;
    1ccf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1cd2:	c9                   	leave  
    1cd3:	c3                   	ret    

00001cd4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1cd4:	55                   	push   %ebp
    1cd5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1cd7:	eb 08                	jmp    1ce1 <strcmp+0xd>
    p++, q++;
    1cd9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1cdd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    1ce1:	8b 45 08             	mov    0x8(%ebp),%eax
    1ce4:	0f b6 00             	movzbl (%eax),%eax
    1ce7:	84 c0                	test   %al,%al
    1ce9:	74 10                	je     1cfb <strcmp+0x27>
    1ceb:	8b 45 08             	mov    0x8(%ebp),%eax
    1cee:	0f b6 10             	movzbl (%eax),%edx
    1cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
    1cf4:	0f b6 00             	movzbl (%eax),%eax
    1cf7:	38 c2                	cmp    %al,%dl
    1cf9:	74 de                	je     1cd9 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1cfb:	8b 45 08             	mov    0x8(%ebp),%eax
    1cfe:	0f b6 00             	movzbl (%eax),%eax
    1d01:	0f b6 d0             	movzbl %al,%edx
    1d04:	8b 45 0c             	mov    0xc(%ebp),%eax
    1d07:	0f b6 00             	movzbl (%eax),%eax
    1d0a:	0f b6 c0             	movzbl %al,%eax
    1d0d:	29 c2                	sub    %eax,%edx
    1d0f:	89 d0                	mov    %edx,%eax
}
    1d11:	5d                   	pop    %ebp
    1d12:	c3                   	ret    

00001d13 <strlen>:

uint
strlen(char *s)
{
    1d13:	55                   	push   %ebp
    1d14:	89 e5                	mov    %esp,%ebp
    1d16:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1d19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1d20:	eb 04                	jmp    1d26 <strlen+0x13>
    1d22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1d26:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1d29:	8b 45 08             	mov    0x8(%ebp),%eax
    1d2c:	01 d0                	add    %edx,%eax
    1d2e:	0f b6 00             	movzbl (%eax),%eax
    1d31:	84 c0                	test   %al,%al
    1d33:	75 ed                	jne    1d22 <strlen+0xf>
    ;
  return n;
    1d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1d38:	c9                   	leave  
    1d39:	c3                   	ret    

00001d3a <memset>:

void*
memset(void *dst, int c, uint n)
{
    1d3a:	55                   	push   %ebp
    1d3b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1d3d:	8b 45 10             	mov    0x10(%ebp),%eax
    1d40:	50                   	push   %eax
    1d41:	ff 75 0c             	pushl  0xc(%ebp)
    1d44:	ff 75 08             	pushl  0x8(%ebp)
    1d47:	e8 32 ff ff ff       	call   1c7e <stosb>
    1d4c:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1d4f:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1d52:	c9                   	leave  
    1d53:	c3                   	ret    

00001d54 <strchr>:

char*
strchr(const char *s, char c)
{
    1d54:	55                   	push   %ebp
    1d55:	89 e5                	mov    %esp,%ebp
    1d57:	83 ec 04             	sub    $0x4,%esp
    1d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
    1d5d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1d60:	eb 14                	jmp    1d76 <strchr+0x22>
    if(*s == c)
    1d62:	8b 45 08             	mov    0x8(%ebp),%eax
    1d65:	0f b6 00             	movzbl (%eax),%eax
    1d68:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1d6b:	75 05                	jne    1d72 <strchr+0x1e>
      return (char*)s;
    1d6d:	8b 45 08             	mov    0x8(%ebp),%eax
    1d70:	eb 13                	jmp    1d85 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1d72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1d76:	8b 45 08             	mov    0x8(%ebp),%eax
    1d79:	0f b6 00             	movzbl (%eax),%eax
    1d7c:	84 c0                	test   %al,%al
    1d7e:	75 e2                	jne    1d62 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1d85:	c9                   	leave  
    1d86:	c3                   	ret    

00001d87 <gets>:

char*
gets(char *buf, int max)
{
    1d87:	55                   	push   %ebp
    1d88:	89 e5                	mov    %esp,%ebp
    1d8a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1d8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1d94:	eb 42                	jmp    1dd8 <gets+0x51>
    cc = read(0, &c, 1);
    1d96:	83 ec 04             	sub    $0x4,%esp
    1d99:	6a 01                	push   $0x1
    1d9b:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1d9e:	50                   	push   %eax
    1d9f:	6a 00                	push   $0x0
    1da1:	e8 47 01 00 00       	call   1eed <read>
    1da6:	83 c4 10             	add    $0x10,%esp
    1da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1dac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1db0:	7e 33                	jle    1de5 <gets+0x5e>
      break;
    buf[i++] = c;
    1db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1db5:	8d 50 01             	lea    0x1(%eax),%edx
    1db8:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1dbb:	89 c2                	mov    %eax,%edx
    1dbd:	8b 45 08             	mov    0x8(%ebp),%eax
    1dc0:	01 c2                	add    %eax,%edx
    1dc2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1dc6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1dc8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1dcc:	3c 0a                	cmp    $0xa,%al
    1dce:	74 16                	je     1de6 <gets+0x5f>
    1dd0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1dd4:	3c 0d                	cmp    $0xd,%al
    1dd6:	74 0e                	je     1de6 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ddb:	83 c0 01             	add    $0x1,%eax
    1dde:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1de1:	7c b3                	jl     1d96 <gets+0xf>
    1de3:	eb 01                	jmp    1de6 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1de5:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1de9:	8b 45 08             	mov    0x8(%ebp),%eax
    1dec:	01 d0                	add    %edx,%eax
    1dee:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1df1:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1df4:	c9                   	leave  
    1df5:	c3                   	ret    

00001df6 <stat>:

int
stat(char *n, struct stat *st)
{
    1df6:	55                   	push   %ebp
    1df7:	89 e5                	mov    %esp,%ebp
    1df9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1dfc:	83 ec 08             	sub    $0x8,%esp
    1dff:	6a 00                	push   $0x0
    1e01:	ff 75 08             	pushl  0x8(%ebp)
    1e04:	e8 0c 01 00 00       	call   1f15 <open>
    1e09:	83 c4 10             	add    $0x10,%esp
    1e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1e0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1e13:	79 07                	jns    1e1c <stat+0x26>
    return -1;
    1e15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1e1a:	eb 25                	jmp    1e41 <stat+0x4b>
  r = fstat(fd, st);
    1e1c:	83 ec 08             	sub    $0x8,%esp
    1e1f:	ff 75 0c             	pushl  0xc(%ebp)
    1e22:	ff 75 f4             	pushl  -0xc(%ebp)
    1e25:	e8 03 01 00 00       	call   1f2d <fstat>
    1e2a:	83 c4 10             	add    $0x10,%esp
    1e2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1e30:	83 ec 0c             	sub    $0xc,%esp
    1e33:	ff 75 f4             	pushl  -0xc(%ebp)
    1e36:	e8 c2 00 00 00       	call   1efd <close>
    1e3b:	83 c4 10             	add    $0x10,%esp
  return r;
    1e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1e41:	c9                   	leave  
    1e42:	c3                   	ret    

00001e43 <atoi>:

int
atoi(const char *s)
{
    1e43:	55                   	push   %ebp
    1e44:	89 e5                	mov    %esp,%ebp
    1e46:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1e49:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1e50:	eb 25                	jmp    1e77 <atoi+0x34>
    n = n*10 + *s++ - '0';
    1e52:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1e55:	89 d0                	mov    %edx,%eax
    1e57:	c1 e0 02             	shl    $0x2,%eax
    1e5a:	01 d0                	add    %edx,%eax
    1e5c:	01 c0                	add    %eax,%eax
    1e5e:	89 c1                	mov    %eax,%ecx
    1e60:	8b 45 08             	mov    0x8(%ebp),%eax
    1e63:	8d 50 01             	lea    0x1(%eax),%edx
    1e66:	89 55 08             	mov    %edx,0x8(%ebp)
    1e69:	0f b6 00             	movzbl (%eax),%eax
    1e6c:	0f be c0             	movsbl %al,%eax
    1e6f:	01 c8                	add    %ecx,%eax
    1e71:	83 e8 30             	sub    $0x30,%eax
    1e74:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1e77:	8b 45 08             	mov    0x8(%ebp),%eax
    1e7a:	0f b6 00             	movzbl (%eax),%eax
    1e7d:	3c 2f                	cmp    $0x2f,%al
    1e7f:	7e 0a                	jle    1e8b <atoi+0x48>
    1e81:	8b 45 08             	mov    0x8(%ebp),%eax
    1e84:	0f b6 00             	movzbl (%eax),%eax
    1e87:	3c 39                	cmp    $0x39,%al
    1e89:	7e c7                	jle    1e52 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1e8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1e8e:	c9                   	leave  
    1e8f:	c3                   	ret    

00001e90 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1e90:	55                   	push   %ebp
    1e91:	89 e5                	mov    %esp,%ebp
    1e93:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    1e96:	8b 45 08             	mov    0x8(%ebp),%eax
    1e99:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
    1e9f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1ea2:	eb 17                	jmp    1ebb <memmove+0x2b>
    *dst++ = *src++;
    1ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1ea7:	8d 50 01             	lea    0x1(%eax),%edx
    1eaa:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1ead:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1eb0:	8d 4a 01             	lea    0x1(%edx),%ecx
    1eb3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1eb6:	0f b6 12             	movzbl (%edx),%edx
    1eb9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1ebb:	8b 45 10             	mov    0x10(%ebp),%eax
    1ebe:	8d 50 ff             	lea    -0x1(%eax),%edx
    1ec1:	89 55 10             	mov    %edx,0x10(%ebp)
    1ec4:	85 c0                	test   %eax,%eax
    1ec6:	7f dc                	jg     1ea4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1ec8:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1ecb:	c9                   	leave  
    1ecc:	c3                   	ret    

00001ecd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1ecd:	b8 01 00 00 00       	mov    $0x1,%eax
    1ed2:	cd 40                	int    $0x40
    1ed4:	c3                   	ret    

00001ed5 <exit>:
SYSCALL(exit)
    1ed5:	b8 02 00 00 00       	mov    $0x2,%eax
    1eda:	cd 40                	int    $0x40
    1edc:	c3                   	ret    

00001edd <wait>:
SYSCALL(wait)
    1edd:	b8 03 00 00 00       	mov    $0x3,%eax
    1ee2:	cd 40                	int    $0x40
    1ee4:	c3                   	ret    

00001ee5 <pipe>:
SYSCALL(pipe)
    1ee5:	b8 04 00 00 00       	mov    $0x4,%eax
    1eea:	cd 40                	int    $0x40
    1eec:	c3                   	ret    

00001eed <read>:
SYSCALL(read)
    1eed:	b8 05 00 00 00       	mov    $0x5,%eax
    1ef2:	cd 40                	int    $0x40
    1ef4:	c3                   	ret    

00001ef5 <write>:
SYSCALL(write)
    1ef5:	b8 10 00 00 00       	mov    $0x10,%eax
    1efa:	cd 40                	int    $0x40
    1efc:	c3                   	ret    

00001efd <close>:
SYSCALL(close)
    1efd:	b8 15 00 00 00       	mov    $0x15,%eax
    1f02:	cd 40                	int    $0x40
    1f04:	c3                   	ret    

00001f05 <kill>:
SYSCALL(kill)
    1f05:	b8 06 00 00 00       	mov    $0x6,%eax
    1f0a:	cd 40                	int    $0x40
    1f0c:	c3                   	ret    

00001f0d <exec>:
SYSCALL(exec)
    1f0d:	b8 07 00 00 00       	mov    $0x7,%eax
    1f12:	cd 40                	int    $0x40
    1f14:	c3                   	ret    

00001f15 <open>:
SYSCALL(open)
    1f15:	b8 0f 00 00 00       	mov    $0xf,%eax
    1f1a:	cd 40                	int    $0x40
    1f1c:	c3                   	ret    

00001f1d <mknod>:
SYSCALL(mknod)
    1f1d:	b8 11 00 00 00       	mov    $0x11,%eax
    1f22:	cd 40                	int    $0x40
    1f24:	c3                   	ret    

00001f25 <unlink>:
SYSCALL(unlink)
    1f25:	b8 12 00 00 00       	mov    $0x12,%eax
    1f2a:	cd 40                	int    $0x40
    1f2c:	c3                   	ret    

00001f2d <fstat>:
SYSCALL(fstat)
    1f2d:	b8 08 00 00 00       	mov    $0x8,%eax
    1f32:	cd 40                	int    $0x40
    1f34:	c3                   	ret    

00001f35 <link>:
SYSCALL(link)
    1f35:	b8 13 00 00 00       	mov    $0x13,%eax
    1f3a:	cd 40                	int    $0x40
    1f3c:	c3                   	ret    

00001f3d <mkdir>:
SYSCALL(mkdir)
    1f3d:	b8 14 00 00 00       	mov    $0x14,%eax
    1f42:	cd 40                	int    $0x40
    1f44:	c3                   	ret    

00001f45 <chdir>:
SYSCALL(chdir)
    1f45:	b8 09 00 00 00       	mov    $0x9,%eax
    1f4a:	cd 40                	int    $0x40
    1f4c:	c3                   	ret    

00001f4d <dup>:
SYSCALL(dup)
    1f4d:	b8 0a 00 00 00       	mov    $0xa,%eax
    1f52:	cd 40                	int    $0x40
    1f54:	c3                   	ret    

00001f55 <getpid>:
SYSCALL(getpid)
    1f55:	b8 0b 00 00 00       	mov    $0xb,%eax
    1f5a:	cd 40                	int    $0x40
    1f5c:	c3                   	ret    

00001f5d <sbrk>:
SYSCALL(sbrk)
    1f5d:	b8 0c 00 00 00       	mov    $0xc,%eax
    1f62:	cd 40                	int    $0x40
    1f64:	c3                   	ret    

00001f65 <sleep>:
SYSCALL(sleep)
    1f65:	b8 0d 00 00 00       	mov    $0xd,%eax
    1f6a:	cd 40                	int    $0x40
    1f6c:	c3                   	ret    

00001f6d <uptime>:
SYSCALL(uptime)
    1f6d:	b8 0e 00 00 00       	mov    $0xe,%eax
    1f72:	cd 40                	int    $0x40
    1f74:	c3                   	ret    

00001f75 <shm_open>:
SYSCALL(shm_open)
    1f75:	b8 16 00 00 00       	mov    $0x16,%eax
    1f7a:	cd 40                	int    $0x40
    1f7c:	c3                   	ret    

00001f7d <shm_close>:
SYSCALL(shm_close)	
    1f7d:	b8 17 00 00 00       	mov    $0x17,%eax
    1f82:	cd 40                	int    $0x40
    1f84:	c3                   	ret    

00001f85 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1f85:	55                   	push   %ebp
    1f86:	89 e5                	mov    %esp,%ebp
    1f88:	83 ec 18             	sub    $0x18,%esp
    1f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
    1f8e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1f91:	83 ec 04             	sub    $0x4,%esp
    1f94:	6a 01                	push   $0x1
    1f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1f99:	50                   	push   %eax
    1f9a:	ff 75 08             	pushl  0x8(%ebp)
    1f9d:	e8 53 ff ff ff       	call   1ef5 <write>
    1fa2:	83 c4 10             	add    $0x10,%esp
}
    1fa5:	90                   	nop
    1fa6:	c9                   	leave  
    1fa7:	c3                   	ret    

00001fa8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1fa8:	55                   	push   %ebp
    1fa9:	89 e5                	mov    %esp,%ebp
    1fab:	53                   	push   %ebx
    1fac:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1faf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1fb6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1fba:	74 17                	je     1fd3 <printint+0x2b>
    1fbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1fc0:	79 11                	jns    1fd3 <printint+0x2b>
    neg = 1;
    1fc2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
    1fcc:	f7 d8                	neg    %eax
    1fce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1fd1:	eb 06                	jmp    1fd9 <printint+0x31>
  } else {
    x = xx;
    1fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
    1fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1fd9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1fe0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1fe3:	8d 41 01             	lea    0x1(%ecx),%eax
    1fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1fef:	ba 00 00 00 00       	mov    $0x0,%edx
    1ff4:	f7 f3                	div    %ebx
    1ff6:	89 d0                	mov    %edx,%eax
    1ff8:	0f b6 80 50 2a 00 00 	movzbl 0x2a50(%eax),%eax
    1fff:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    2003:	8b 5d 10             	mov    0x10(%ebp),%ebx
    2006:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2009:	ba 00 00 00 00       	mov    $0x0,%edx
    200e:	f7 f3                	div    %ebx
    2010:	89 45 ec             	mov    %eax,-0x14(%ebp)
    2013:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2017:	75 c7                	jne    1fe0 <printint+0x38>
  if(neg)
    2019:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    201d:	74 2d                	je     204c <printint+0xa4>
    buf[i++] = '-';
    201f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2022:	8d 50 01             	lea    0x1(%eax),%edx
    2025:	89 55 f4             	mov    %edx,-0xc(%ebp)
    2028:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    202d:	eb 1d                	jmp    204c <printint+0xa4>
    putc(fd, buf[i]);
    202f:	8d 55 dc             	lea    -0x24(%ebp),%edx
    2032:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2035:	01 d0                	add    %edx,%eax
    2037:	0f b6 00             	movzbl (%eax),%eax
    203a:	0f be c0             	movsbl %al,%eax
    203d:	83 ec 08             	sub    $0x8,%esp
    2040:	50                   	push   %eax
    2041:	ff 75 08             	pushl  0x8(%ebp)
    2044:	e8 3c ff ff ff       	call   1f85 <putc>
    2049:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    204c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    2050:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2054:	79 d9                	jns    202f <printint+0x87>
    putc(fd, buf[i]);
}
    2056:	90                   	nop
    2057:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    205a:	c9                   	leave  
    205b:	c3                   	ret    

0000205c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    205c:	55                   	push   %ebp
    205d:	89 e5                	mov    %esp,%ebp
    205f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    2062:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    2069:	8d 45 0c             	lea    0xc(%ebp),%eax
    206c:	83 c0 04             	add    $0x4,%eax
    206f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    2072:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    2079:	e9 59 01 00 00       	jmp    21d7 <printf+0x17b>
    c = fmt[i] & 0xff;
    207e:	8b 55 0c             	mov    0xc(%ebp),%edx
    2081:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2084:	01 d0                	add    %edx,%eax
    2086:	0f b6 00             	movzbl (%eax),%eax
    2089:	0f be c0             	movsbl %al,%eax
    208c:	25 ff 00 00 00       	and    $0xff,%eax
    2091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    2094:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2098:	75 2c                	jne    20c6 <printf+0x6a>
      if(c == '%'){
    209a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    209e:	75 0c                	jne    20ac <printf+0x50>
        state = '%';
    20a0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    20a7:	e9 27 01 00 00       	jmp    21d3 <printf+0x177>
      } else {
        putc(fd, c);
    20ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    20af:	0f be c0             	movsbl %al,%eax
    20b2:	83 ec 08             	sub    $0x8,%esp
    20b5:	50                   	push   %eax
    20b6:	ff 75 08             	pushl  0x8(%ebp)
    20b9:	e8 c7 fe ff ff       	call   1f85 <putc>
    20be:	83 c4 10             	add    $0x10,%esp
    20c1:	e9 0d 01 00 00       	jmp    21d3 <printf+0x177>
      }
    } else if(state == '%'){
    20c6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    20ca:	0f 85 03 01 00 00    	jne    21d3 <printf+0x177>
      if(c == 'd'){
    20d0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    20d4:	75 1e                	jne    20f4 <printf+0x98>
        printint(fd, *ap, 10, 1);
    20d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    20d9:	8b 00                	mov    (%eax),%eax
    20db:	6a 01                	push   $0x1
    20dd:	6a 0a                	push   $0xa
    20df:	50                   	push   %eax
    20e0:	ff 75 08             	pushl  0x8(%ebp)
    20e3:	e8 c0 fe ff ff       	call   1fa8 <printint>
    20e8:	83 c4 10             	add    $0x10,%esp
        ap++;
    20eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    20ef:	e9 d8 00 00 00       	jmp    21cc <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    20f4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    20f8:	74 06                	je     2100 <printf+0xa4>
    20fa:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    20fe:	75 1e                	jne    211e <printf+0xc2>
        printint(fd, *ap, 16, 0);
    2100:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2103:	8b 00                	mov    (%eax),%eax
    2105:	6a 00                	push   $0x0
    2107:	6a 10                	push   $0x10
    2109:	50                   	push   %eax
    210a:	ff 75 08             	pushl  0x8(%ebp)
    210d:	e8 96 fe ff ff       	call   1fa8 <printint>
    2112:	83 c4 10             	add    $0x10,%esp
        ap++;
    2115:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    2119:	e9 ae 00 00 00       	jmp    21cc <printf+0x170>
      } else if(c == 's'){
    211e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    2122:	75 43                	jne    2167 <printf+0x10b>
        s = (char*)*ap;
    2124:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2127:	8b 00                	mov    (%eax),%eax
    2129:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    212c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    2130:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2134:	75 25                	jne    215b <printf+0xff>
          s = "(null)";
    2136:	c7 45 f4 54 25 00 00 	movl   $0x2554,-0xc(%ebp)
        while(*s != 0){
    213d:	eb 1c                	jmp    215b <printf+0xff>
          putc(fd, *s);
    213f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2142:	0f b6 00             	movzbl (%eax),%eax
    2145:	0f be c0             	movsbl %al,%eax
    2148:	83 ec 08             	sub    $0x8,%esp
    214b:	50                   	push   %eax
    214c:	ff 75 08             	pushl  0x8(%ebp)
    214f:	e8 31 fe ff ff       	call   1f85 <putc>
    2154:	83 c4 10             	add    $0x10,%esp
          s++;
    2157:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    215b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    215e:	0f b6 00             	movzbl (%eax),%eax
    2161:	84 c0                	test   %al,%al
    2163:	75 da                	jne    213f <printf+0xe3>
    2165:	eb 65                	jmp    21cc <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    2167:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    216b:	75 1d                	jne    218a <printf+0x12e>
        putc(fd, *ap);
    216d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2170:	8b 00                	mov    (%eax),%eax
    2172:	0f be c0             	movsbl %al,%eax
    2175:	83 ec 08             	sub    $0x8,%esp
    2178:	50                   	push   %eax
    2179:	ff 75 08             	pushl  0x8(%ebp)
    217c:	e8 04 fe ff ff       	call   1f85 <putc>
    2181:	83 c4 10             	add    $0x10,%esp
        ap++;
    2184:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    2188:	eb 42                	jmp    21cc <printf+0x170>
      } else if(c == '%'){
    218a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    218e:	75 17                	jne    21a7 <printf+0x14b>
        putc(fd, c);
    2190:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    2193:	0f be c0             	movsbl %al,%eax
    2196:	83 ec 08             	sub    $0x8,%esp
    2199:	50                   	push   %eax
    219a:	ff 75 08             	pushl  0x8(%ebp)
    219d:	e8 e3 fd ff ff       	call   1f85 <putc>
    21a2:	83 c4 10             	add    $0x10,%esp
    21a5:	eb 25                	jmp    21cc <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    21a7:	83 ec 08             	sub    $0x8,%esp
    21aa:	6a 25                	push   $0x25
    21ac:	ff 75 08             	pushl  0x8(%ebp)
    21af:	e8 d1 fd ff ff       	call   1f85 <putc>
    21b4:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    21b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    21ba:	0f be c0             	movsbl %al,%eax
    21bd:	83 ec 08             	sub    $0x8,%esp
    21c0:	50                   	push   %eax
    21c1:	ff 75 08             	pushl  0x8(%ebp)
    21c4:	e8 bc fd ff ff       	call   1f85 <putc>
    21c9:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    21cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    21d3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    21d7:	8b 55 0c             	mov    0xc(%ebp),%edx
    21da:	8b 45 f0             	mov    -0x10(%ebp),%eax
    21dd:	01 d0                	add    %edx,%eax
    21df:	0f b6 00             	movzbl (%eax),%eax
    21e2:	84 c0                	test   %al,%al
    21e4:	0f 85 94 fe ff ff    	jne    207e <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    21ea:	90                   	nop
    21eb:	c9                   	leave  
    21ec:	c3                   	ret    

000021ed <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    21ed:	55                   	push   %ebp
    21ee:	89 e5                	mov    %esp,%ebp
    21f0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    21f3:	8b 45 08             	mov    0x8(%ebp),%eax
    21f6:	83 e8 08             	sub    $0x8,%eax
    21f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    21fc:	a1 ec 2a 00 00       	mov    0x2aec,%eax
    2201:	89 45 fc             	mov    %eax,-0x4(%ebp)
    2204:	eb 24                	jmp    222a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    2206:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2209:	8b 00                	mov    (%eax),%eax
    220b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    220e:	77 12                	ja     2222 <free+0x35>
    2210:	8b 45 f8             	mov    -0x8(%ebp),%eax
    2213:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    2216:	77 24                	ja     223c <free+0x4f>
    2218:	8b 45 fc             	mov    -0x4(%ebp),%eax
    221b:	8b 00                	mov    (%eax),%eax
    221d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    2220:	77 1a                	ja     223c <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    2222:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2225:	8b 00                	mov    (%eax),%eax
    2227:	89 45 fc             	mov    %eax,-0x4(%ebp)
    222a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    222d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    2230:	76 d4                	jbe    2206 <free+0x19>
    2232:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2235:	8b 00                	mov    (%eax),%eax
    2237:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    223a:	76 ca                	jbe    2206 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    223c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    223f:	8b 40 04             	mov    0x4(%eax),%eax
    2242:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    2249:	8b 45 f8             	mov    -0x8(%ebp),%eax
    224c:	01 c2                	add    %eax,%edx
    224e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2251:	8b 00                	mov    (%eax),%eax
    2253:	39 c2                	cmp    %eax,%edx
    2255:	75 24                	jne    227b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    2257:	8b 45 f8             	mov    -0x8(%ebp),%eax
    225a:	8b 50 04             	mov    0x4(%eax),%edx
    225d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2260:	8b 00                	mov    (%eax),%eax
    2262:	8b 40 04             	mov    0x4(%eax),%eax
    2265:	01 c2                	add    %eax,%edx
    2267:	8b 45 f8             	mov    -0x8(%ebp),%eax
    226a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    226d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2270:	8b 00                	mov    (%eax),%eax
    2272:	8b 10                	mov    (%eax),%edx
    2274:	8b 45 f8             	mov    -0x8(%ebp),%eax
    2277:	89 10                	mov    %edx,(%eax)
    2279:	eb 0a                	jmp    2285 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    227b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    227e:	8b 10                	mov    (%eax),%edx
    2280:	8b 45 f8             	mov    -0x8(%ebp),%eax
    2283:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    2285:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2288:	8b 40 04             	mov    0x4(%eax),%eax
    228b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    2292:	8b 45 fc             	mov    -0x4(%ebp),%eax
    2295:	01 d0                	add    %edx,%eax
    2297:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    229a:	75 20                	jne    22bc <free+0xcf>
    p->s.size += bp->s.size;
    229c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    229f:	8b 50 04             	mov    0x4(%eax),%edx
    22a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    22a5:	8b 40 04             	mov    0x4(%eax),%eax
    22a8:	01 c2                	add    %eax,%edx
    22aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    22ad:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    22b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
    22b3:	8b 10                	mov    (%eax),%edx
    22b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    22b8:	89 10                	mov    %edx,(%eax)
    22ba:	eb 08                	jmp    22c4 <free+0xd7>
  } else
    p->s.ptr = bp;
    22bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    22bf:	8b 55 f8             	mov    -0x8(%ebp),%edx
    22c2:	89 10                	mov    %edx,(%eax)
  freep = p;
    22c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    22c7:	a3 ec 2a 00 00       	mov    %eax,0x2aec
}
    22cc:	90                   	nop
    22cd:	c9                   	leave  
    22ce:	c3                   	ret    

000022cf <morecore>:

static Header*
morecore(uint nu)
{
    22cf:	55                   	push   %ebp
    22d0:	89 e5                	mov    %esp,%ebp
    22d2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    22d5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    22dc:	77 07                	ja     22e5 <morecore+0x16>
    nu = 4096;
    22de:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    22e5:	8b 45 08             	mov    0x8(%ebp),%eax
    22e8:	c1 e0 03             	shl    $0x3,%eax
    22eb:	83 ec 0c             	sub    $0xc,%esp
    22ee:	50                   	push   %eax
    22ef:	e8 69 fc ff ff       	call   1f5d <sbrk>
    22f4:	83 c4 10             	add    $0x10,%esp
    22f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    22fa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    22fe:	75 07                	jne    2307 <morecore+0x38>
    return 0;
    2300:	b8 00 00 00 00       	mov    $0x0,%eax
    2305:	eb 26                	jmp    232d <morecore+0x5e>
  hp = (Header*)p;
    2307:	8b 45 f4             	mov    -0xc(%ebp),%eax
    230a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    230d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2310:	8b 55 08             	mov    0x8(%ebp),%edx
    2313:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    2316:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2319:	83 c0 08             	add    $0x8,%eax
    231c:	83 ec 0c             	sub    $0xc,%esp
    231f:	50                   	push   %eax
    2320:	e8 c8 fe ff ff       	call   21ed <free>
    2325:	83 c4 10             	add    $0x10,%esp
  return freep;
    2328:	a1 ec 2a 00 00       	mov    0x2aec,%eax
}
    232d:	c9                   	leave  
    232e:	c3                   	ret    

0000232f <malloc>:

void*
malloc(uint nbytes)
{
    232f:	55                   	push   %ebp
    2330:	89 e5                	mov    %esp,%ebp
    2332:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    2335:	8b 45 08             	mov    0x8(%ebp),%eax
    2338:	83 c0 07             	add    $0x7,%eax
    233b:	c1 e8 03             	shr    $0x3,%eax
    233e:	83 c0 01             	add    $0x1,%eax
    2341:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    2344:	a1 ec 2a 00 00       	mov    0x2aec,%eax
    2349:	89 45 f0             	mov    %eax,-0x10(%ebp)
    234c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2350:	75 23                	jne    2375 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    2352:	c7 45 f0 e4 2a 00 00 	movl   $0x2ae4,-0x10(%ebp)
    2359:	8b 45 f0             	mov    -0x10(%ebp),%eax
    235c:	a3 ec 2a 00 00       	mov    %eax,0x2aec
    2361:	a1 ec 2a 00 00       	mov    0x2aec,%eax
    2366:	a3 e4 2a 00 00       	mov    %eax,0x2ae4
    base.s.size = 0;
    236b:	c7 05 e8 2a 00 00 00 	movl   $0x0,0x2ae8
    2372:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    2375:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2378:	8b 00                	mov    (%eax),%eax
    237a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    237d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2380:	8b 40 04             	mov    0x4(%eax),%eax
    2383:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    2386:	72 4d                	jb     23d5 <malloc+0xa6>
      if(p->s.size == nunits)
    2388:	8b 45 f4             	mov    -0xc(%ebp),%eax
    238b:	8b 40 04             	mov    0x4(%eax),%eax
    238e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    2391:	75 0c                	jne    239f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    2393:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2396:	8b 10                	mov    (%eax),%edx
    2398:	8b 45 f0             	mov    -0x10(%ebp),%eax
    239b:	89 10                	mov    %edx,(%eax)
    239d:	eb 26                	jmp    23c5 <malloc+0x96>
      else {
        p->s.size -= nunits;
    239f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23a2:	8b 40 04             	mov    0x4(%eax),%eax
    23a5:	2b 45 ec             	sub    -0x14(%ebp),%eax
    23a8:	89 c2                	mov    %eax,%edx
    23aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23ad:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    23b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23b3:	8b 40 04             	mov    0x4(%eax),%eax
    23b6:	c1 e0 03             	shl    $0x3,%eax
    23b9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    23bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
    23c2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    23c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    23c8:	a3 ec 2a 00 00       	mov    %eax,0x2aec
      return (void*)(p + 1);
    23cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23d0:	83 c0 08             	add    $0x8,%eax
    23d3:	eb 3b                	jmp    2410 <malloc+0xe1>
    }
    if(p == freep)
    23d5:	a1 ec 2a 00 00       	mov    0x2aec,%eax
    23da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    23dd:	75 1e                	jne    23fd <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    23df:	83 ec 0c             	sub    $0xc,%esp
    23e2:	ff 75 ec             	pushl  -0x14(%ebp)
    23e5:	e8 e5 fe ff ff       	call   22cf <morecore>
    23ea:	83 c4 10             	add    $0x10,%esp
    23ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    23f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    23f4:	75 07                	jne    23fd <malloc+0xce>
        return 0;
    23f6:	b8 00 00 00 00       	mov    $0x0,%eax
    23fb:	eb 13                	jmp    2410 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    23fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2400:	89 45 f0             	mov    %eax,-0x10(%ebp)
    2403:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2406:	8b 00                	mov    (%eax),%eax
    2408:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    240b:	e9 6d ff ff ff       	jmp    237d <malloc+0x4e>
}
    2410:	c9                   	leave  
    2411:	c3                   	ret    

00002412 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    2412:	55                   	push   %ebp
    2413:	89 e5                	mov    %esp,%ebp
    2415:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    2418:	8b 55 08             	mov    0x8(%ebp),%edx
    241b:	8b 45 0c             	mov    0xc(%ebp),%eax
    241e:	8b 4d 08             	mov    0x8(%ebp),%ecx
    2421:	f0 87 02             	lock xchg %eax,(%edx)
    2424:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    2427:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    242a:	c9                   	leave  
    242b:	c3                   	ret    

0000242c <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    242c:	55                   	push   %ebp
    242d:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    242f:	90                   	nop
    2430:	8b 45 08             	mov    0x8(%ebp),%eax
    2433:	6a 01                	push   $0x1
    2435:	50                   	push   %eax
    2436:	e8 d7 ff ff ff       	call   2412 <xchg>
    243b:	83 c4 08             	add    $0x8,%esp
    243e:	85 c0                	test   %eax,%eax
    2440:	75 ee                	jne    2430 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    2442:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    2447:	90                   	nop
    2448:	c9                   	leave  
    2449:	c3                   	ret    

0000244a <urelease>:

void urelease (struct uspinlock *lk) {
    244a:	55                   	push   %ebp
    244b:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    244d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    2452:	8b 45 08             	mov    0x8(%ebp),%eax
    2455:	8b 55 08             	mov    0x8(%ebp),%edx
    2458:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    245e:	90                   	nop
    245f:	5d                   	pop    %ebp
    2460:	c3                   	ret    
