
_usertests:     file format elf32-i386


Disassembly of section .text:

00001000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 08             	sub    $0x8,%esp
  printf(stdout, "iput test\n");
    1006:	a1 40 75 00 00       	mov    0x7540,%eax
    100b:	83 ec 08             	sub    $0x8,%esp
    100e:	68 9a 55 00 00       	push   $0x559a
    1013:	50                   	push   %eax
    1014:	e8 64 41 00 00       	call   517d <printf>
    1019:	83 c4 10             	add    $0x10,%esp

  if(mkdir("iputdir") < 0){
    101c:	83 ec 0c             	sub    $0xc,%esp
    101f:	68 a5 55 00 00       	push   $0x55a5
    1024:	e8 35 40 00 00       	call   505e <mkdir>
    1029:	83 c4 10             	add    $0x10,%esp
    102c:	85 c0                	test   %eax,%eax
    102e:	79 1b                	jns    104b <iputtest+0x4b>
    printf(stdout, "mkdir failed\n");
    1030:	a1 40 75 00 00       	mov    0x7540,%eax
    1035:	83 ec 08             	sub    $0x8,%esp
    1038:	68 ad 55 00 00       	push   $0x55ad
    103d:	50                   	push   %eax
    103e:	e8 3a 41 00 00       	call   517d <printf>
    1043:	83 c4 10             	add    $0x10,%esp
    exit();
    1046:	e8 ab 3f 00 00       	call   4ff6 <exit>
  }
  if(chdir("iputdir") < 0){
    104b:	83 ec 0c             	sub    $0xc,%esp
    104e:	68 a5 55 00 00       	push   $0x55a5
    1053:	e8 0e 40 00 00       	call   5066 <chdir>
    1058:	83 c4 10             	add    $0x10,%esp
    105b:	85 c0                	test   %eax,%eax
    105d:	79 1b                	jns    107a <iputtest+0x7a>
    printf(stdout, "chdir iputdir failed\n");
    105f:	a1 40 75 00 00       	mov    0x7540,%eax
    1064:	83 ec 08             	sub    $0x8,%esp
    1067:	68 bb 55 00 00       	push   $0x55bb
    106c:	50                   	push   %eax
    106d:	e8 0b 41 00 00       	call   517d <printf>
    1072:	83 c4 10             	add    $0x10,%esp
    exit();
    1075:	e8 7c 3f 00 00       	call   4ff6 <exit>
  }
  if(unlink("../iputdir") < 0){
    107a:	83 ec 0c             	sub    $0xc,%esp
    107d:	68 d1 55 00 00       	push   $0x55d1
    1082:	e8 bf 3f 00 00       	call   5046 <unlink>
    1087:	83 c4 10             	add    $0x10,%esp
    108a:	85 c0                	test   %eax,%eax
    108c:	79 1b                	jns    10a9 <iputtest+0xa9>
    printf(stdout, "unlink ../iputdir failed\n");
    108e:	a1 40 75 00 00       	mov    0x7540,%eax
    1093:	83 ec 08             	sub    $0x8,%esp
    1096:	68 dc 55 00 00       	push   $0x55dc
    109b:	50                   	push   %eax
    109c:	e8 dc 40 00 00       	call   517d <printf>
    10a1:	83 c4 10             	add    $0x10,%esp
    exit();
    10a4:	e8 4d 3f 00 00       	call   4ff6 <exit>
  }
  if(chdir("/") < 0){
    10a9:	83 ec 0c             	sub    $0xc,%esp
    10ac:	68 f6 55 00 00       	push   $0x55f6
    10b1:	e8 b0 3f 00 00       	call   5066 <chdir>
    10b6:	83 c4 10             	add    $0x10,%esp
    10b9:	85 c0                	test   %eax,%eax
    10bb:	79 1b                	jns    10d8 <iputtest+0xd8>
    printf(stdout, "chdir / failed\n");
    10bd:	a1 40 75 00 00       	mov    0x7540,%eax
    10c2:	83 ec 08             	sub    $0x8,%esp
    10c5:	68 f8 55 00 00       	push   $0x55f8
    10ca:	50                   	push   %eax
    10cb:	e8 ad 40 00 00       	call   517d <printf>
    10d0:	83 c4 10             	add    $0x10,%esp
    exit();
    10d3:	e8 1e 3f 00 00       	call   4ff6 <exit>
  }
  printf(stdout, "iput test ok\n");
    10d8:	a1 40 75 00 00       	mov    0x7540,%eax
    10dd:	83 ec 08             	sub    $0x8,%esp
    10e0:	68 08 56 00 00       	push   $0x5608
    10e5:	50                   	push   %eax
    10e6:	e8 92 40 00 00       	call   517d <printf>
    10eb:	83 c4 10             	add    $0x10,%esp
}
    10ee:	90                   	nop
    10ef:	c9                   	leave  
    10f0:	c3                   	ret    

000010f1 <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
    10f1:	55                   	push   %ebp
    10f2:	89 e5                	mov    %esp,%ebp
    10f4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  printf(stdout, "exitiput test\n");
    10f7:	a1 40 75 00 00       	mov    0x7540,%eax
    10fc:	83 ec 08             	sub    $0x8,%esp
    10ff:	68 16 56 00 00       	push   $0x5616
    1104:	50                   	push   %eax
    1105:	e8 73 40 00 00       	call   517d <printf>
    110a:	83 c4 10             	add    $0x10,%esp

  pid = fork();
    110d:	e8 dc 3e 00 00       	call   4fee <fork>
    1112:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
    1115:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1119:	79 1b                	jns    1136 <exitiputtest+0x45>
    printf(stdout, "fork failed\n");
    111b:	a1 40 75 00 00       	mov    0x7540,%eax
    1120:	83 ec 08             	sub    $0x8,%esp
    1123:	68 25 56 00 00       	push   $0x5625
    1128:	50                   	push   %eax
    1129:	e8 4f 40 00 00       	call   517d <printf>
    112e:	83 c4 10             	add    $0x10,%esp
    exit();
    1131:	e8 c0 3e 00 00       	call   4ff6 <exit>
  }
  if(pid == 0){
    1136:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    113a:	0f 85 92 00 00 00    	jne    11d2 <exitiputtest+0xe1>
    if(mkdir("iputdir") < 0){
    1140:	83 ec 0c             	sub    $0xc,%esp
    1143:	68 a5 55 00 00       	push   $0x55a5
    1148:	e8 11 3f 00 00       	call   505e <mkdir>
    114d:	83 c4 10             	add    $0x10,%esp
    1150:	85 c0                	test   %eax,%eax
    1152:	79 1b                	jns    116f <exitiputtest+0x7e>
      printf(stdout, "mkdir failed\n");
    1154:	a1 40 75 00 00       	mov    0x7540,%eax
    1159:	83 ec 08             	sub    $0x8,%esp
    115c:	68 ad 55 00 00       	push   $0x55ad
    1161:	50                   	push   %eax
    1162:	e8 16 40 00 00       	call   517d <printf>
    1167:	83 c4 10             	add    $0x10,%esp
      exit();
    116a:	e8 87 3e 00 00       	call   4ff6 <exit>
    }
    if(chdir("iputdir") < 0){
    116f:	83 ec 0c             	sub    $0xc,%esp
    1172:	68 a5 55 00 00       	push   $0x55a5
    1177:	e8 ea 3e 00 00       	call   5066 <chdir>
    117c:	83 c4 10             	add    $0x10,%esp
    117f:	85 c0                	test   %eax,%eax
    1181:	79 1b                	jns    119e <exitiputtest+0xad>
      printf(stdout, "child chdir failed\n");
    1183:	a1 40 75 00 00       	mov    0x7540,%eax
    1188:	83 ec 08             	sub    $0x8,%esp
    118b:	68 32 56 00 00       	push   $0x5632
    1190:	50                   	push   %eax
    1191:	e8 e7 3f 00 00       	call   517d <printf>
    1196:	83 c4 10             	add    $0x10,%esp
      exit();
    1199:	e8 58 3e 00 00       	call   4ff6 <exit>
    }
    if(unlink("../iputdir") < 0){
    119e:	83 ec 0c             	sub    $0xc,%esp
    11a1:	68 d1 55 00 00       	push   $0x55d1
    11a6:	e8 9b 3e 00 00       	call   5046 <unlink>
    11ab:	83 c4 10             	add    $0x10,%esp
    11ae:	85 c0                	test   %eax,%eax
    11b0:	79 1b                	jns    11cd <exitiputtest+0xdc>
      printf(stdout, "unlink ../iputdir failed\n");
    11b2:	a1 40 75 00 00       	mov    0x7540,%eax
    11b7:	83 ec 08             	sub    $0x8,%esp
    11ba:	68 dc 55 00 00       	push   $0x55dc
    11bf:	50                   	push   %eax
    11c0:	e8 b8 3f 00 00       	call   517d <printf>
    11c5:	83 c4 10             	add    $0x10,%esp
      exit();
    11c8:	e8 29 3e 00 00       	call   4ff6 <exit>
    }
    exit();
    11cd:	e8 24 3e 00 00       	call   4ff6 <exit>
  }
  wait();
    11d2:	e8 27 3e 00 00       	call   4ffe <wait>
  printf(stdout, "exitiput test ok\n");
    11d7:	a1 40 75 00 00       	mov    0x7540,%eax
    11dc:	83 ec 08             	sub    $0x8,%esp
    11df:	68 46 56 00 00       	push   $0x5646
    11e4:	50                   	push   %eax
    11e5:	e8 93 3f 00 00       	call   517d <printf>
    11ea:	83 c4 10             	add    $0x10,%esp
}
    11ed:	90                   	nop
    11ee:	c9                   	leave  
    11ef:	c3                   	ret    

000011f0 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
    11f0:	55                   	push   %ebp
    11f1:	89 e5                	mov    %esp,%ebp
    11f3:	83 ec 18             	sub    $0x18,%esp
  int pid;

  printf(stdout, "openiput test\n");
    11f6:	a1 40 75 00 00       	mov    0x7540,%eax
    11fb:	83 ec 08             	sub    $0x8,%esp
    11fe:	68 58 56 00 00       	push   $0x5658
    1203:	50                   	push   %eax
    1204:	e8 74 3f 00 00       	call   517d <printf>
    1209:	83 c4 10             	add    $0x10,%esp
  if(mkdir("oidir") < 0){
    120c:	83 ec 0c             	sub    $0xc,%esp
    120f:	68 67 56 00 00       	push   $0x5667
    1214:	e8 45 3e 00 00       	call   505e <mkdir>
    1219:	83 c4 10             	add    $0x10,%esp
    121c:	85 c0                	test   %eax,%eax
    121e:	79 1b                	jns    123b <openiputtest+0x4b>
    printf(stdout, "mkdir oidir failed\n");
    1220:	a1 40 75 00 00       	mov    0x7540,%eax
    1225:	83 ec 08             	sub    $0x8,%esp
    1228:	68 6d 56 00 00       	push   $0x566d
    122d:	50                   	push   %eax
    122e:	e8 4a 3f 00 00       	call   517d <printf>
    1233:	83 c4 10             	add    $0x10,%esp
    exit();
    1236:	e8 bb 3d 00 00       	call   4ff6 <exit>
  }
  pid = fork();
    123b:	e8 ae 3d 00 00       	call   4fee <fork>
    1240:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
    1243:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1247:	79 1b                	jns    1264 <openiputtest+0x74>
    printf(stdout, "fork failed\n");
    1249:	a1 40 75 00 00       	mov    0x7540,%eax
    124e:	83 ec 08             	sub    $0x8,%esp
    1251:	68 25 56 00 00       	push   $0x5625
    1256:	50                   	push   %eax
    1257:	e8 21 3f 00 00       	call   517d <printf>
    125c:	83 c4 10             	add    $0x10,%esp
    exit();
    125f:	e8 92 3d 00 00       	call   4ff6 <exit>
  }
  if(pid == 0){
    1264:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1268:	75 3b                	jne    12a5 <openiputtest+0xb5>
    int fd = open("oidir", O_RDWR);
    126a:	83 ec 08             	sub    $0x8,%esp
    126d:	6a 02                	push   $0x2
    126f:	68 67 56 00 00       	push   $0x5667
    1274:	e8 bd 3d 00 00       	call   5036 <open>
    1279:	83 c4 10             	add    $0x10,%esp
    127c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
    127f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1283:	78 1b                	js     12a0 <openiputtest+0xb0>
      printf(stdout, "open directory for write succeeded\n");
    1285:	a1 40 75 00 00       	mov    0x7540,%eax
    128a:	83 ec 08             	sub    $0x8,%esp
    128d:	68 84 56 00 00       	push   $0x5684
    1292:	50                   	push   %eax
    1293:	e8 e5 3e 00 00       	call   517d <printf>
    1298:	83 c4 10             	add    $0x10,%esp
      exit();
    129b:	e8 56 3d 00 00       	call   4ff6 <exit>
    }
    exit();
    12a0:	e8 51 3d 00 00       	call   4ff6 <exit>
  }
  sleep(1);
    12a5:	83 ec 0c             	sub    $0xc,%esp
    12a8:	6a 01                	push   $0x1
    12aa:	e8 d7 3d 00 00       	call   5086 <sleep>
    12af:	83 c4 10             	add    $0x10,%esp
  if(unlink("oidir") != 0){
    12b2:	83 ec 0c             	sub    $0xc,%esp
    12b5:	68 67 56 00 00       	push   $0x5667
    12ba:	e8 87 3d 00 00       	call   5046 <unlink>
    12bf:	83 c4 10             	add    $0x10,%esp
    12c2:	85 c0                	test   %eax,%eax
    12c4:	74 1b                	je     12e1 <openiputtest+0xf1>
    printf(stdout, "unlink failed\n");
    12c6:	a1 40 75 00 00       	mov    0x7540,%eax
    12cb:	83 ec 08             	sub    $0x8,%esp
    12ce:	68 a8 56 00 00       	push   $0x56a8
    12d3:	50                   	push   %eax
    12d4:	e8 a4 3e 00 00       	call   517d <printf>
    12d9:	83 c4 10             	add    $0x10,%esp
    exit();
    12dc:	e8 15 3d 00 00       	call   4ff6 <exit>
  }
  wait();
    12e1:	e8 18 3d 00 00       	call   4ffe <wait>
  printf(stdout, "openiput test ok\n");
    12e6:	a1 40 75 00 00       	mov    0x7540,%eax
    12eb:	83 ec 08             	sub    $0x8,%esp
    12ee:	68 b7 56 00 00       	push   $0x56b7
    12f3:	50                   	push   %eax
    12f4:	e8 84 3e 00 00       	call   517d <printf>
    12f9:	83 c4 10             	add    $0x10,%esp
}
    12fc:	90                   	nop
    12fd:	c9                   	leave  
    12fe:	c3                   	ret    

000012ff <opentest>:

// simple file system tests

void
opentest(void)
{
    12ff:	55                   	push   %ebp
    1300:	89 e5                	mov    %esp,%ebp
    1302:	83 ec 18             	sub    $0x18,%esp
  int fd;

  printf(stdout, "open test\n");
    1305:	a1 40 75 00 00       	mov    0x7540,%eax
    130a:	83 ec 08             	sub    $0x8,%esp
    130d:	68 c9 56 00 00       	push   $0x56c9
    1312:	50                   	push   %eax
    1313:	e8 65 3e 00 00       	call   517d <printf>
    1318:	83 c4 10             	add    $0x10,%esp
  fd = open("echo", 0);
    131b:	83 ec 08             	sub    $0x8,%esp
    131e:	6a 00                	push   $0x0
    1320:	68 84 55 00 00       	push   $0x5584
    1325:	e8 0c 3d 00 00       	call   5036 <open>
    132a:	83 c4 10             	add    $0x10,%esp
    132d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1330:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1334:	79 1b                	jns    1351 <opentest+0x52>
    printf(stdout, "open echo failed!\n");
    1336:	a1 40 75 00 00       	mov    0x7540,%eax
    133b:	83 ec 08             	sub    $0x8,%esp
    133e:	68 d4 56 00 00       	push   $0x56d4
    1343:	50                   	push   %eax
    1344:	e8 34 3e 00 00       	call   517d <printf>
    1349:	83 c4 10             	add    $0x10,%esp
    exit();
    134c:	e8 a5 3c 00 00       	call   4ff6 <exit>
  }
  close(fd);
    1351:	83 ec 0c             	sub    $0xc,%esp
    1354:	ff 75 f4             	pushl  -0xc(%ebp)
    1357:	e8 c2 3c 00 00       	call   501e <close>
    135c:	83 c4 10             	add    $0x10,%esp
  fd = open("doesnotexist", 0);
    135f:	83 ec 08             	sub    $0x8,%esp
    1362:	6a 00                	push   $0x0
    1364:	68 e7 56 00 00       	push   $0x56e7
    1369:	e8 c8 3c 00 00       	call   5036 <open>
    136e:	83 c4 10             	add    $0x10,%esp
    1371:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    1374:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1378:	78 1b                	js     1395 <opentest+0x96>
    printf(stdout, "open doesnotexist succeeded!\n");
    137a:	a1 40 75 00 00       	mov    0x7540,%eax
    137f:	83 ec 08             	sub    $0x8,%esp
    1382:	68 f4 56 00 00       	push   $0x56f4
    1387:	50                   	push   %eax
    1388:	e8 f0 3d 00 00       	call   517d <printf>
    138d:	83 c4 10             	add    $0x10,%esp
    exit();
    1390:	e8 61 3c 00 00       	call   4ff6 <exit>
  }
  printf(stdout, "open test ok\n");
    1395:	a1 40 75 00 00       	mov    0x7540,%eax
    139a:	83 ec 08             	sub    $0x8,%esp
    139d:	68 12 57 00 00       	push   $0x5712
    13a2:	50                   	push   %eax
    13a3:	e8 d5 3d 00 00       	call   517d <printf>
    13a8:	83 c4 10             	add    $0x10,%esp
}
    13ab:	90                   	nop
    13ac:	c9                   	leave  
    13ad:	c3                   	ret    

000013ae <writetest>:

void
writetest(void)
{
    13ae:	55                   	push   %ebp
    13af:	89 e5                	mov    %esp,%ebp
    13b1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
    13b4:	a1 40 75 00 00       	mov    0x7540,%eax
    13b9:	83 ec 08             	sub    $0x8,%esp
    13bc:	68 20 57 00 00       	push   $0x5720
    13c1:	50                   	push   %eax
    13c2:	e8 b6 3d 00 00       	call   517d <printf>
    13c7:	83 c4 10             	add    $0x10,%esp
  fd = open("small", O_CREATE|O_RDWR);
    13ca:	83 ec 08             	sub    $0x8,%esp
    13cd:	68 02 02 00 00       	push   $0x202
    13d2:	68 31 57 00 00       	push   $0x5731
    13d7:	e8 5a 3c 00 00       	call   5036 <open>
    13dc:	83 c4 10             	add    $0x10,%esp
    13df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
    13e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13e6:	78 22                	js     140a <writetest+0x5c>
    printf(stdout, "creat small succeeded; ok\n");
    13e8:	a1 40 75 00 00       	mov    0x7540,%eax
    13ed:	83 ec 08             	sub    $0x8,%esp
    13f0:	68 37 57 00 00       	push   $0x5737
    13f5:	50                   	push   %eax
    13f6:	e8 82 3d 00 00       	call   517d <printf>
    13fb:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
    13fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1405:	e9 8f 00 00 00       	jmp    1499 <writetest+0xeb>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    140a:	a1 40 75 00 00       	mov    0x7540,%eax
    140f:	83 ec 08             	sub    $0x8,%esp
    1412:	68 52 57 00 00       	push   $0x5752
    1417:	50                   	push   %eax
    1418:	e8 60 3d 00 00       	call   517d <printf>
    141d:	83 c4 10             	add    $0x10,%esp
    exit();
    1420:	e8 d1 3b 00 00       	call   4ff6 <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
    1425:	83 ec 04             	sub    $0x4,%esp
    1428:	6a 0a                	push   $0xa
    142a:	68 6e 57 00 00       	push   $0x576e
    142f:	ff 75 f0             	pushl  -0x10(%ebp)
    1432:	e8 df 3b 00 00       	call   5016 <write>
    1437:	83 c4 10             	add    $0x10,%esp
    143a:	83 f8 0a             	cmp    $0xa,%eax
    143d:	74 1e                	je     145d <writetest+0xaf>
      printf(stdout, "error: write aa %d new file failed\n", i);
    143f:	a1 40 75 00 00       	mov    0x7540,%eax
    1444:	83 ec 04             	sub    $0x4,%esp
    1447:	ff 75 f4             	pushl  -0xc(%ebp)
    144a:	68 7c 57 00 00       	push   $0x577c
    144f:	50                   	push   %eax
    1450:	e8 28 3d 00 00       	call   517d <printf>
    1455:	83 c4 10             	add    $0x10,%esp
      exit();
    1458:	e8 99 3b 00 00       	call   4ff6 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
    145d:	83 ec 04             	sub    $0x4,%esp
    1460:	6a 0a                	push   $0xa
    1462:	68 a0 57 00 00       	push   $0x57a0
    1467:	ff 75 f0             	pushl  -0x10(%ebp)
    146a:	e8 a7 3b 00 00       	call   5016 <write>
    146f:	83 c4 10             	add    $0x10,%esp
    1472:	83 f8 0a             	cmp    $0xa,%eax
    1475:	74 1e                	je     1495 <writetest+0xe7>
      printf(stdout, "error: write bb %d new file failed\n", i);
    1477:	a1 40 75 00 00       	mov    0x7540,%eax
    147c:	83 ec 04             	sub    $0x4,%esp
    147f:	ff 75 f4             	pushl  -0xc(%ebp)
    1482:	68 ac 57 00 00       	push   $0x57ac
    1487:	50                   	push   %eax
    1488:	e8 f0 3c 00 00       	call   517d <printf>
    148d:	83 c4 10             	add    $0x10,%esp
      exit();
    1490:	e8 61 3b 00 00       	call   4ff6 <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
    1495:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1499:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    149d:	7e 86                	jle    1425 <writetest+0x77>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
    149f:	a1 40 75 00 00       	mov    0x7540,%eax
    14a4:	83 ec 08             	sub    $0x8,%esp
    14a7:	68 d0 57 00 00       	push   $0x57d0
    14ac:	50                   	push   %eax
    14ad:	e8 cb 3c 00 00       	call   517d <printf>
    14b2:	83 c4 10             	add    $0x10,%esp
  close(fd);
    14b5:	83 ec 0c             	sub    $0xc,%esp
    14b8:	ff 75 f0             	pushl  -0x10(%ebp)
    14bb:	e8 5e 3b 00 00       	call   501e <close>
    14c0:	83 c4 10             	add    $0x10,%esp
  fd = open("small", O_RDONLY);
    14c3:	83 ec 08             	sub    $0x8,%esp
    14c6:	6a 00                	push   $0x0
    14c8:	68 31 57 00 00       	push   $0x5731
    14cd:	e8 64 3b 00 00       	call   5036 <open>
    14d2:	83 c4 10             	add    $0x10,%esp
    14d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
    14d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    14dc:	78 3c                	js     151a <writetest+0x16c>
    printf(stdout, "open small succeeded ok\n");
    14de:	a1 40 75 00 00       	mov    0x7540,%eax
    14e3:	83 ec 08             	sub    $0x8,%esp
    14e6:	68 db 57 00 00       	push   $0x57db
    14eb:	50                   	push   %eax
    14ec:	e8 8c 3c 00 00       	call   517d <printf>
    14f1:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
    14f4:	83 ec 04             	sub    $0x4,%esp
    14f7:	68 d0 07 00 00       	push   $0x7d0
    14fc:	68 20 9d 00 00       	push   $0x9d20
    1501:	ff 75 f0             	pushl  -0x10(%ebp)
    1504:	e8 05 3b 00 00       	call   500e <read>
    1509:	83 c4 10             	add    $0x10,%esp
    150c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
    150f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
    1516:	75 57                	jne    156f <writetest+0x1c1>
    1518:	eb 1b                	jmp    1535 <writetest+0x187>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
    151a:	a1 40 75 00 00       	mov    0x7540,%eax
    151f:	83 ec 08             	sub    $0x8,%esp
    1522:	68 f4 57 00 00       	push   $0x57f4
    1527:	50                   	push   %eax
    1528:	e8 50 3c 00 00       	call   517d <printf>
    152d:	83 c4 10             	add    $0x10,%esp
    exit();
    1530:	e8 c1 3a 00 00       	call   4ff6 <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
    1535:	a1 40 75 00 00       	mov    0x7540,%eax
    153a:	83 ec 08             	sub    $0x8,%esp
    153d:	68 0f 58 00 00       	push   $0x580f
    1542:	50                   	push   %eax
    1543:	e8 35 3c 00 00       	call   517d <printf>
    1548:	83 c4 10             	add    $0x10,%esp
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
    154b:	83 ec 0c             	sub    $0xc,%esp
    154e:	ff 75 f0             	pushl  -0x10(%ebp)
    1551:	e8 c8 3a 00 00       	call   501e <close>
    1556:	83 c4 10             	add    $0x10,%esp

  if(unlink("small") < 0){
    1559:	83 ec 0c             	sub    $0xc,%esp
    155c:	68 31 57 00 00       	push   $0x5731
    1561:	e8 e0 3a 00 00       	call   5046 <unlink>
    1566:	83 c4 10             	add    $0x10,%esp
    1569:	85 c0                	test   %eax,%eax
    156b:	79 38                	jns    15a5 <writetest+0x1f7>
    156d:	eb 1b                	jmp    158a <writetest+0x1dc>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
    156f:	a1 40 75 00 00       	mov    0x7540,%eax
    1574:	83 ec 08             	sub    $0x8,%esp
    1577:	68 22 58 00 00       	push   $0x5822
    157c:	50                   	push   %eax
    157d:	e8 fb 3b 00 00       	call   517d <printf>
    1582:	83 c4 10             	add    $0x10,%esp
    exit();
    1585:	e8 6c 3a 00 00       	call   4ff6 <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
    158a:	a1 40 75 00 00       	mov    0x7540,%eax
    158f:	83 ec 08             	sub    $0x8,%esp
    1592:	68 2f 58 00 00       	push   $0x582f
    1597:	50                   	push   %eax
    1598:	e8 e0 3b 00 00       	call   517d <printf>
    159d:	83 c4 10             	add    $0x10,%esp
    exit();
    15a0:	e8 51 3a 00 00       	call   4ff6 <exit>
  }
  printf(stdout, "small file test ok\n");
    15a5:	a1 40 75 00 00       	mov    0x7540,%eax
    15aa:	83 ec 08             	sub    $0x8,%esp
    15ad:	68 44 58 00 00       	push   $0x5844
    15b2:	50                   	push   %eax
    15b3:	e8 c5 3b 00 00       	call   517d <printf>
    15b8:	83 c4 10             	add    $0x10,%esp
}
    15bb:	90                   	nop
    15bc:	c9                   	leave  
    15bd:	c3                   	ret    

000015be <writetest1>:

void
writetest1(void)
{
    15be:	55                   	push   %ebp
    15bf:	89 e5                	mov    %esp,%ebp
    15c1:	83 ec 18             	sub    $0x18,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
    15c4:	a1 40 75 00 00       	mov    0x7540,%eax
    15c9:	83 ec 08             	sub    $0x8,%esp
    15cc:	68 58 58 00 00       	push   $0x5858
    15d1:	50                   	push   %eax
    15d2:	e8 a6 3b 00 00       	call   517d <printf>
    15d7:	83 c4 10             	add    $0x10,%esp

  fd = open("big", O_CREATE|O_RDWR);
    15da:	83 ec 08             	sub    $0x8,%esp
    15dd:	68 02 02 00 00       	push   $0x202
    15e2:	68 68 58 00 00       	push   $0x5868
    15e7:	e8 4a 3a 00 00       	call   5036 <open>
    15ec:	83 c4 10             	add    $0x10,%esp
    15ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    15f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    15f6:	79 1b                	jns    1613 <writetest1+0x55>
    printf(stdout, "error: creat big failed!\n");
    15f8:	a1 40 75 00 00       	mov    0x7540,%eax
    15fd:	83 ec 08             	sub    $0x8,%esp
    1600:	68 6c 58 00 00       	push   $0x586c
    1605:	50                   	push   %eax
    1606:	e8 72 3b 00 00       	call   517d <printf>
    160b:	83 c4 10             	add    $0x10,%esp
    exit();
    160e:	e8 e3 39 00 00       	call   4ff6 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
    1613:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    161a:	eb 4b                	jmp    1667 <writetest1+0xa9>
    ((int*)buf)[0] = i;
    161c:	ba 20 9d 00 00       	mov    $0x9d20,%edx
    1621:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1624:	89 02                	mov    %eax,(%edx)
    if(write(fd, buf, 512) != 512){
    1626:	83 ec 04             	sub    $0x4,%esp
    1629:	68 00 02 00 00       	push   $0x200
    162e:	68 20 9d 00 00       	push   $0x9d20
    1633:	ff 75 ec             	pushl  -0x14(%ebp)
    1636:	e8 db 39 00 00       	call   5016 <write>
    163b:	83 c4 10             	add    $0x10,%esp
    163e:	3d 00 02 00 00       	cmp    $0x200,%eax
    1643:	74 1e                	je     1663 <writetest1+0xa5>
      printf(stdout, "error: write big file failed\n", i);
    1645:	a1 40 75 00 00       	mov    0x7540,%eax
    164a:	83 ec 04             	sub    $0x4,%esp
    164d:	ff 75 f4             	pushl  -0xc(%ebp)
    1650:	68 86 58 00 00       	push   $0x5886
    1655:	50                   	push   %eax
    1656:	e8 22 3b 00 00       	call   517d <printf>
    165b:	83 c4 10             	add    $0x10,%esp
      exit();
    165e:	e8 93 39 00 00       	call   4ff6 <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
    1663:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1667:	8b 45 f4             	mov    -0xc(%ebp),%eax
    166a:	3d 8b 00 00 00       	cmp    $0x8b,%eax
    166f:	76 ab                	jbe    161c <writetest1+0x5e>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
    1671:	83 ec 0c             	sub    $0xc,%esp
    1674:	ff 75 ec             	pushl  -0x14(%ebp)
    1677:	e8 a2 39 00 00       	call   501e <close>
    167c:	83 c4 10             	add    $0x10,%esp

  fd = open("big", O_RDONLY);
    167f:	83 ec 08             	sub    $0x8,%esp
    1682:	6a 00                	push   $0x0
    1684:	68 68 58 00 00       	push   $0x5868
    1689:	e8 a8 39 00 00       	call   5036 <open>
    168e:	83 c4 10             	add    $0x10,%esp
    1691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    1694:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1698:	79 1b                	jns    16b5 <writetest1+0xf7>
    printf(stdout, "error: open big failed!\n");
    169a:	a1 40 75 00 00       	mov    0x7540,%eax
    169f:	83 ec 08             	sub    $0x8,%esp
    16a2:	68 a4 58 00 00       	push   $0x58a4
    16a7:	50                   	push   %eax
    16a8:	e8 d0 3a 00 00       	call   517d <printf>
    16ad:	83 c4 10             	add    $0x10,%esp
    exit();
    16b0:	e8 41 39 00 00       	call   4ff6 <exit>
  }

  n = 0;
    16b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
    16bc:	83 ec 04             	sub    $0x4,%esp
    16bf:	68 00 02 00 00       	push   $0x200
    16c4:	68 20 9d 00 00       	push   $0x9d20
    16c9:	ff 75 ec             	pushl  -0x14(%ebp)
    16cc:	e8 3d 39 00 00       	call   500e <read>
    16d1:	83 c4 10             	add    $0x10,%esp
    16d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
    16d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    16db:	75 27                	jne    1704 <writetest1+0x146>
      if(n == MAXFILE - 1){
    16dd:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
    16e4:	75 7d                	jne    1763 <writetest1+0x1a5>
        printf(stdout, "read only %d blocks from big", n);
    16e6:	a1 40 75 00 00       	mov    0x7540,%eax
    16eb:	83 ec 04             	sub    $0x4,%esp
    16ee:	ff 75 f0             	pushl  -0x10(%ebp)
    16f1:	68 bd 58 00 00       	push   $0x58bd
    16f6:	50                   	push   %eax
    16f7:	e8 81 3a 00 00       	call   517d <printf>
    16fc:	83 c4 10             	add    $0x10,%esp
        exit();
    16ff:	e8 f2 38 00 00       	call   4ff6 <exit>
      }
      break;
    } else if(i != 512){
    1704:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
    170b:	74 1e                	je     172b <writetest1+0x16d>
      printf(stdout, "read failed %d\n", i);
    170d:	a1 40 75 00 00       	mov    0x7540,%eax
    1712:	83 ec 04             	sub    $0x4,%esp
    1715:	ff 75 f4             	pushl  -0xc(%ebp)
    1718:	68 da 58 00 00       	push   $0x58da
    171d:	50                   	push   %eax
    171e:	e8 5a 3a 00 00       	call   517d <printf>
    1723:	83 c4 10             	add    $0x10,%esp
      exit();
    1726:	e8 cb 38 00 00       	call   4ff6 <exit>
    }
    if(((int*)buf)[0] != n){
    172b:	b8 20 9d 00 00       	mov    $0x9d20,%eax
    1730:	8b 00                	mov    (%eax),%eax
    1732:	3b 45 f0             	cmp    -0x10(%ebp),%eax
    1735:	74 23                	je     175a <writetest1+0x19c>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
    1737:	b8 20 9d 00 00       	mov    $0x9d20,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
    173c:	8b 10                	mov    (%eax),%edx
    173e:	a1 40 75 00 00       	mov    0x7540,%eax
    1743:	52                   	push   %edx
    1744:	ff 75 f0             	pushl  -0x10(%ebp)
    1747:	68 ec 58 00 00       	push   $0x58ec
    174c:	50                   	push   %eax
    174d:	e8 2b 3a 00 00       	call   517d <printf>
    1752:	83 c4 10             	add    $0x10,%esp
             n, ((int*)buf)[0]);
      exit();
    1755:	e8 9c 38 00 00       	call   4ff6 <exit>
    }
    n++;
    175a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
    175e:	e9 59 ff ff ff       	jmp    16bc <writetest1+0xfe>
    if(i == 0){
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    1763:	90                   	nop
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
    1764:	83 ec 0c             	sub    $0xc,%esp
    1767:	ff 75 ec             	pushl  -0x14(%ebp)
    176a:	e8 af 38 00 00       	call   501e <close>
    176f:	83 c4 10             	add    $0x10,%esp
  if(unlink("big") < 0){
    1772:	83 ec 0c             	sub    $0xc,%esp
    1775:	68 68 58 00 00       	push   $0x5868
    177a:	e8 c7 38 00 00       	call   5046 <unlink>
    177f:	83 c4 10             	add    $0x10,%esp
    1782:	85 c0                	test   %eax,%eax
    1784:	79 1b                	jns    17a1 <writetest1+0x1e3>
    printf(stdout, "unlink big failed\n");
    1786:	a1 40 75 00 00       	mov    0x7540,%eax
    178b:	83 ec 08             	sub    $0x8,%esp
    178e:	68 0c 59 00 00       	push   $0x590c
    1793:	50                   	push   %eax
    1794:	e8 e4 39 00 00       	call   517d <printf>
    1799:	83 c4 10             	add    $0x10,%esp
    exit();
    179c:	e8 55 38 00 00       	call   4ff6 <exit>
  }
  printf(stdout, "big files ok\n");
    17a1:	a1 40 75 00 00       	mov    0x7540,%eax
    17a6:	83 ec 08             	sub    $0x8,%esp
    17a9:	68 1f 59 00 00       	push   $0x591f
    17ae:	50                   	push   %eax
    17af:	e8 c9 39 00 00       	call   517d <printf>
    17b4:	83 c4 10             	add    $0x10,%esp
}
    17b7:	90                   	nop
    17b8:	c9                   	leave  
    17b9:	c3                   	ret    

000017ba <createtest>:

void
createtest(void)
{
    17ba:	55                   	push   %ebp
    17bb:	89 e5                	mov    %esp,%ebp
    17bd:	83 ec 18             	sub    $0x18,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
    17c0:	a1 40 75 00 00       	mov    0x7540,%eax
    17c5:	83 ec 08             	sub    $0x8,%esp
    17c8:	68 30 59 00 00       	push   $0x5930
    17cd:	50                   	push   %eax
    17ce:	e8 aa 39 00 00       	call   517d <printf>
    17d3:	83 c4 10             	add    $0x10,%esp

  name[0] = 'a';
    17d6:	c6 05 20 bd 00 00 61 	movb   $0x61,0xbd20
  name[2] = '\0';
    17dd:	c6 05 22 bd 00 00 00 	movb   $0x0,0xbd22
  for(i = 0; i < 52; i++){
    17e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    17eb:	eb 35                	jmp    1822 <createtest+0x68>
    name[1] = '0' + i;
    17ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f0:	83 c0 30             	add    $0x30,%eax
    17f3:	a2 21 bd 00 00       	mov    %al,0xbd21
    fd = open(name, O_CREATE|O_RDWR);
    17f8:	83 ec 08             	sub    $0x8,%esp
    17fb:	68 02 02 00 00       	push   $0x202
    1800:	68 20 bd 00 00       	push   $0xbd20
    1805:	e8 2c 38 00 00       	call   5036 <open>
    180a:	83 c4 10             	add    $0x10,%esp
    180d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
    1810:	83 ec 0c             	sub    $0xc,%esp
    1813:	ff 75 f0             	pushl  -0x10(%ebp)
    1816:	e8 03 38 00 00       	call   501e <close>
    181b:	83 c4 10             	add    $0x10,%esp

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
    181e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1822:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
    1826:	7e c5                	jle    17ed <createtest+0x33>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
    1828:	c6 05 20 bd 00 00 61 	movb   $0x61,0xbd20
  name[2] = '\0';
    182f:	c6 05 22 bd 00 00 00 	movb   $0x0,0xbd22
  for(i = 0; i < 52; i++){
    1836:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    183d:	eb 1f                	jmp    185e <createtest+0xa4>
    name[1] = '0' + i;
    183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1842:	83 c0 30             	add    $0x30,%eax
    1845:	a2 21 bd 00 00       	mov    %al,0xbd21
    unlink(name);
    184a:	83 ec 0c             	sub    $0xc,%esp
    184d:	68 20 bd 00 00       	push   $0xbd20
    1852:	e8 ef 37 00 00       	call   5046 <unlink>
    1857:	83 c4 10             	add    $0x10,%esp
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
    185a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    185e:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
    1862:	7e db                	jle    183f <createtest+0x85>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
    1864:	a1 40 75 00 00       	mov    0x7540,%eax
    1869:	83 ec 08             	sub    $0x8,%esp
    186c:	68 58 59 00 00       	push   $0x5958
    1871:	50                   	push   %eax
    1872:	e8 06 39 00 00       	call   517d <printf>
    1877:	83 c4 10             	add    $0x10,%esp
}
    187a:	90                   	nop
    187b:	c9                   	leave  
    187c:	c3                   	ret    

0000187d <dirtest>:

void dirtest(void)
{
    187d:	55                   	push   %ebp
    187e:	89 e5                	mov    %esp,%ebp
    1880:	83 ec 08             	sub    $0x8,%esp
  printf(stdout, "mkdir test\n");
    1883:	a1 40 75 00 00       	mov    0x7540,%eax
    1888:	83 ec 08             	sub    $0x8,%esp
    188b:	68 7e 59 00 00       	push   $0x597e
    1890:	50                   	push   %eax
    1891:	e8 e7 38 00 00       	call   517d <printf>
    1896:	83 c4 10             	add    $0x10,%esp

  if(mkdir("dir0") < 0){
    1899:	83 ec 0c             	sub    $0xc,%esp
    189c:	68 8a 59 00 00       	push   $0x598a
    18a1:	e8 b8 37 00 00       	call   505e <mkdir>
    18a6:	83 c4 10             	add    $0x10,%esp
    18a9:	85 c0                	test   %eax,%eax
    18ab:	79 1b                	jns    18c8 <dirtest+0x4b>
    printf(stdout, "mkdir failed\n");
    18ad:	a1 40 75 00 00       	mov    0x7540,%eax
    18b2:	83 ec 08             	sub    $0x8,%esp
    18b5:	68 ad 55 00 00       	push   $0x55ad
    18ba:	50                   	push   %eax
    18bb:	e8 bd 38 00 00       	call   517d <printf>
    18c0:	83 c4 10             	add    $0x10,%esp
    exit();
    18c3:	e8 2e 37 00 00       	call   4ff6 <exit>
  }

  if(chdir("dir0") < 0){
    18c8:	83 ec 0c             	sub    $0xc,%esp
    18cb:	68 8a 59 00 00       	push   $0x598a
    18d0:	e8 91 37 00 00       	call   5066 <chdir>
    18d5:	83 c4 10             	add    $0x10,%esp
    18d8:	85 c0                	test   %eax,%eax
    18da:	79 1b                	jns    18f7 <dirtest+0x7a>
    printf(stdout, "chdir dir0 failed\n");
    18dc:	a1 40 75 00 00       	mov    0x7540,%eax
    18e1:	83 ec 08             	sub    $0x8,%esp
    18e4:	68 8f 59 00 00       	push   $0x598f
    18e9:	50                   	push   %eax
    18ea:	e8 8e 38 00 00       	call   517d <printf>
    18ef:	83 c4 10             	add    $0x10,%esp
    exit();
    18f2:	e8 ff 36 00 00       	call   4ff6 <exit>
  }

  if(chdir("..") < 0){
    18f7:	83 ec 0c             	sub    $0xc,%esp
    18fa:	68 a2 59 00 00       	push   $0x59a2
    18ff:	e8 62 37 00 00       	call   5066 <chdir>
    1904:	83 c4 10             	add    $0x10,%esp
    1907:	85 c0                	test   %eax,%eax
    1909:	79 1b                	jns    1926 <dirtest+0xa9>
    printf(stdout, "chdir .. failed\n");
    190b:	a1 40 75 00 00       	mov    0x7540,%eax
    1910:	83 ec 08             	sub    $0x8,%esp
    1913:	68 a5 59 00 00       	push   $0x59a5
    1918:	50                   	push   %eax
    1919:	e8 5f 38 00 00       	call   517d <printf>
    191e:	83 c4 10             	add    $0x10,%esp
    exit();
    1921:	e8 d0 36 00 00       	call   4ff6 <exit>
  }

  if(unlink("dir0") < 0){
    1926:	83 ec 0c             	sub    $0xc,%esp
    1929:	68 8a 59 00 00       	push   $0x598a
    192e:	e8 13 37 00 00       	call   5046 <unlink>
    1933:	83 c4 10             	add    $0x10,%esp
    1936:	85 c0                	test   %eax,%eax
    1938:	79 1b                	jns    1955 <dirtest+0xd8>
    printf(stdout, "unlink dir0 failed\n");
    193a:	a1 40 75 00 00       	mov    0x7540,%eax
    193f:	83 ec 08             	sub    $0x8,%esp
    1942:	68 b6 59 00 00       	push   $0x59b6
    1947:	50                   	push   %eax
    1948:	e8 30 38 00 00       	call   517d <printf>
    194d:	83 c4 10             	add    $0x10,%esp
    exit();
    1950:	e8 a1 36 00 00       	call   4ff6 <exit>
  }
  printf(stdout, "mkdir test ok\n");
    1955:	a1 40 75 00 00       	mov    0x7540,%eax
    195a:	83 ec 08             	sub    $0x8,%esp
    195d:	68 ca 59 00 00       	push   $0x59ca
    1962:	50                   	push   %eax
    1963:	e8 15 38 00 00       	call   517d <printf>
    1968:	83 c4 10             	add    $0x10,%esp
}
    196b:	90                   	nop
    196c:	c9                   	leave  
    196d:	c3                   	ret    

0000196e <exectest>:

void
exectest(void)
{
    196e:	55                   	push   %ebp
    196f:	89 e5                	mov    %esp,%ebp
    1971:	83 ec 08             	sub    $0x8,%esp
  printf(stdout, "exec test\n");
    1974:	a1 40 75 00 00       	mov    0x7540,%eax
    1979:	83 ec 08             	sub    $0x8,%esp
    197c:	68 d9 59 00 00       	push   $0x59d9
    1981:	50                   	push   %eax
    1982:	e8 f6 37 00 00       	call   517d <printf>
    1987:	83 c4 10             	add    $0x10,%esp
  if(exec("echo", echoargv) < 0){
    198a:	83 ec 08             	sub    $0x8,%esp
    198d:	68 2c 75 00 00       	push   $0x752c
    1992:	68 84 55 00 00       	push   $0x5584
    1997:	e8 92 36 00 00       	call   502e <exec>
    199c:	83 c4 10             	add    $0x10,%esp
    199f:	85 c0                	test   %eax,%eax
    19a1:	79 1b                	jns    19be <exectest+0x50>
    printf(stdout, "exec echo failed\n");
    19a3:	a1 40 75 00 00       	mov    0x7540,%eax
    19a8:	83 ec 08             	sub    $0x8,%esp
    19ab:	68 e4 59 00 00       	push   $0x59e4
    19b0:	50                   	push   %eax
    19b1:	e8 c7 37 00 00       	call   517d <printf>
    19b6:	83 c4 10             	add    $0x10,%esp
    exit();
    19b9:	e8 38 36 00 00       	call   4ff6 <exit>
  }
}
    19be:	90                   	nop
    19bf:	c9                   	leave  
    19c0:	c3                   	ret    

000019c1 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
    19c1:	55                   	push   %ebp
    19c2:	89 e5                	mov    %esp,%ebp
    19c4:	83 ec 28             	sub    $0x28,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
    19c7:	83 ec 0c             	sub    $0xc,%esp
    19ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
    19cd:	50                   	push   %eax
    19ce:	e8 33 36 00 00       	call   5006 <pipe>
    19d3:	83 c4 10             	add    $0x10,%esp
    19d6:	85 c0                	test   %eax,%eax
    19d8:	74 17                	je     19f1 <pipe1+0x30>
    printf(1, "pipe() failed\n");
    19da:	83 ec 08             	sub    $0x8,%esp
    19dd:	68 f6 59 00 00       	push   $0x59f6
    19e2:	6a 01                	push   $0x1
    19e4:	e8 94 37 00 00       	call   517d <printf>
    19e9:	83 c4 10             	add    $0x10,%esp
    exit();
    19ec:	e8 05 36 00 00       	call   4ff6 <exit>
  }
  pid = fork();
    19f1:	e8 f8 35 00 00       	call   4fee <fork>
    19f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
    19f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
    1a00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1a04:	0f 85 89 00 00 00    	jne    1a93 <pipe1+0xd2>
    close(fds[0]);
    1a0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1a0d:	83 ec 0c             	sub    $0xc,%esp
    1a10:	50                   	push   %eax
    1a11:	e8 08 36 00 00       	call   501e <close>
    1a16:	83 c4 10             	add    $0x10,%esp
    for(n = 0; n < 5; n++){
    1a19:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    1a20:	eb 66                	jmp    1a88 <pipe1+0xc7>
      for(i = 0; i < 1033; i++)
    1a22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1a29:	eb 19                	jmp    1a44 <pipe1+0x83>
        buf[i] = seq++;
    1a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a2e:	8d 50 01             	lea    0x1(%eax),%edx
    1a31:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1a34:	89 c2                	mov    %eax,%edx
    1a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1a39:	05 20 9d 00 00       	add    $0x9d20,%eax
    1a3e:	88 10                	mov    %dl,(%eax)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
    1a40:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1a44:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
    1a4b:	7e de                	jle    1a2b <pipe1+0x6a>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
    1a4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1a50:	83 ec 04             	sub    $0x4,%esp
    1a53:	68 09 04 00 00       	push   $0x409
    1a58:	68 20 9d 00 00       	push   $0x9d20
    1a5d:	50                   	push   %eax
    1a5e:	e8 b3 35 00 00       	call   5016 <write>
    1a63:	83 c4 10             	add    $0x10,%esp
    1a66:	3d 09 04 00 00       	cmp    $0x409,%eax
    1a6b:	74 17                	je     1a84 <pipe1+0xc3>
        printf(1, "pipe1 oops 1\n");
    1a6d:	83 ec 08             	sub    $0x8,%esp
    1a70:	68 05 5a 00 00       	push   $0x5a05
    1a75:	6a 01                	push   $0x1
    1a77:	e8 01 37 00 00       	call   517d <printf>
    1a7c:	83 c4 10             	add    $0x10,%esp
        exit();
    1a7f:	e8 72 35 00 00       	call   4ff6 <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
    1a84:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    1a88:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
    1a8c:	7e 94                	jle    1a22 <pipe1+0x61>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
    1a8e:	e8 63 35 00 00       	call   4ff6 <exit>
  } else if(pid > 0){
    1a93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1a97:	0f 8e f4 00 00 00    	jle    1b91 <pipe1+0x1d0>
    close(fds[1]);
    1a9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1aa0:	83 ec 0c             	sub    $0xc,%esp
    1aa3:	50                   	push   %eax
    1aa4:	e8 75 35 00 00       	call   501e <close>
    1aa9:	83 c4 10             	add    $0x10,%esp
    total = 0;
    1aac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
    1ab3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
    1aba:	eb 66                	jmp    1b22 <pipe1+0x161>
      for(i = 0; i < n; i++){
    1abc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1ac3:	eb 3b                	jmp    1b00 <pipe1+0x13f>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1ac8:	05 20 9d 00 00       	add    $0x9d20,%eax
    1acd:	0f b6 00             	movzbl (%eax),%eax
    1ad0:	0f be c8             	movsbl %al,%ecx
    1ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ad6:	8d 50 01             	lea    0x1(%eax),%edx
    1ad9:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1adc:	31 c8                	xor    %ecx,%eax
    1ade:	0f b6 c0             	movzbl %al,%eax
    1ae1:	85 c0                	test   %eax,%eax
    1ae3:	74 17                	je     1afc <pipe1+0x13b>
          printf(1, "pipe1 oops 2\n");
    1ae5:	83 ec 08             	sub    $0x8,%esp
    1ae8:	68 13 5a 00 00       	push   $0x5a13
    1aed:	6a 01                	push   $0x1
    1aef:	e8 89 36 00 00       	call   517d <printf>
    1af4:	83 c4 10             	add    $0x10,%esp
    1af7:	e9 ac 00 00 00       	jmp    1ba8 <pipe1+0x1e7>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
    1afc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1b03:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1b06:	7c bd                	jl     1ac5 <pipe1+0x104>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
    1b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1b0b:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
    1b0e:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
    1b11:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1b14:	3d 00 20 00 00       	cmp    $0x2000,%eax
    1b19:	76 07                	jbe    1b22 <pipe1+0x161>
        cc = sizeof(buf);
    1b1b:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
    1b22:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1b25:	83 ec 04             	sub    $0x4,%esp
    1b28:	ff 75 e8             	pushl  -0x18(%ebp)
    1b2b:	68 20 9d 00 00       	push   $0x9d20
    1b30:	50                   	push   %eax
    1b31:	e8 d8 34 00 00       	call   500e <read>
    1b36:	83 c4 10             	add    $0x10,%esp
    1b39:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1b3c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b40:	0f 8f 76 ff ff ff    	jg     1abc <pipe1+0xfb>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
    1b46:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
    1b4d:	74 1a                	je     1b69 <pipe1+0x1a8>
      printf(1, "pipe1 oops 3 total %d\n", total);
    1b4f:	83 ec 04             	sub    $0x4,%esp
    1b52:	ff 75 e4             	pushl  -0x1c(%ebp)
    1b55:	68 21 5a 00 00       	push   $0x5a21
    1b5a:	6a 01                	push   $0x1
    1b5c:	e8 1c 36 00 00       	call   517d <printf>
    1b61:	83 c4 10             	add    $0x10,%esp
      exit();
    1b64:	e8 8d 34 00 00       	call   4ff6 <exit>
    }
    close(fds[0]);
    1b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1b6c:	83 ec 0c             	sub    $0xc,%esp
    1b6f:	50                   	push   %eax
    1b70:	e8 a9 34 00 00       	call   501e <close>
    1b75:	83 c4 10             	add    $0x10,%esp
    wait();
    1b78:	e8 81 34 00 00       	call   4ffe <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
    1b7d:	83 ec 08             	sub    $0x8,%esp
    1b80:	68 47 5a 00 00       	push   $0x5a47
    1b85:	6a 01                	push   $0x1
    1b87:	e8 f1 35 00 00       	call   517d <printf>
    1b8c:	83 c4 10             	add    $0x10,%esp
    1b8f:	eb 17                	jmp    1ba8 <pipe1+0x1e7>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
    1b91:	83 ec 08             	sub    $0x8,%esp
    1b94:	68 38 5a 00 00       	push   $0x5a38
    1b99:	6a 01                	push   $0x1
    1b9b:	e8 dd 35 00 00       	call   517d <printf>
    1ba0:	83 c4 10             	add    $0x10,%esp
    exit();
    1ba3:	e8 4e 34 00 00       	call   4ff6 <exit>
  }
  printf(1, "pipe1 ok\n");
}
    1ba8:	c9                   	leave  
    1ba9:	c3                   	ret    

00001baa <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
    1baa:	55                   	push   %ebp
    1bab:	89 e5                	mov    %esp,%ebp
    1bad:	83 ec 28             	sub    $0x28,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
    1bb0:	83 ec 08             	sub    $0x8,%esp
    1bb3:	68 51 5a 00 00       	push   $0x5a51
    1bb8:	6a 01                	push   $0x1
    1bba:	e8 be 35 00 00       	call   517d <printf>
    1bbf:	83 c4 10             	add    $0x10,%esp
  pid1 = fork();
    1bc2:	e8 27 34 00 00       	call   4fee <fork>
    1bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
    1bca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1bce:	75 02                	jne    1bd2 <preempt+0x28>
    for(;;)
      ;
    1bd0:	eb fe                	jmp    1bd0 <preempt+0x26>

  pid2 = fork();
    1bd2:	e8 17 34 00 00       	call   4fee <fork>
    1bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
    1bda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1bde:	75 02                	jne    1be2 <preempt+0x38>
    for(;;)
      ;
    1be0:	eb fe                	jmp    1be0 <preempt+0x36>

  pipe(pfds);
    1be2:	83 ec 0c             	sub    $0xc,%esp
    1be5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
    1be8:	50                   	push   %eax
    1be9:	e8 18 34 00 00       	call   5006 <pipe>
    1bee:	83 c4 10             	add    $0x10,%esp
  pid3 = fork();
    1bf1:	e8 f8 33 00 00       	call   4fee <fork>
    1bf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
    1bf9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1bfd:	75 4d                	jne    1c4c <preempt+0xa2>
    close(pfds[0]);
    1bff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1c02:	83 ec 0c             	sub    $0xc,%esp
    1c05:	50                   	push   %eax
    1c06:	e8 13 34 00 00       	call   501e <close>
    1c0b:	83 c4 10             	add    $0x10,%esp
    if(write(pfds[1], "x", 1) != 1)
    1c0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c11:	83 ec 04             	sub    $0x4,%esp
    1c14:	6a 01                	push   $0x1
    1c16:	68 5b 5a 00 00       	push   $0x5a5b
    1c1b:	50                   	push   %eax
    1c1c:	e8 f5 33 00 00       	call   5016 <write>
    1c21:	83 c4 10             	add    $0x10,%esp
    1c24:	83 f8 01             	cmp    $0x1,%eax
    1c27:	74 12                	je     1c3b <preempt+0x91>
      printf(1, "preempt write error");
    1c29:	83 ec 08             	sub    $0x8,%esp
    1c2c:	68 5d 5a 00 00       	push   $0x5a5d
    1c31:	6a 01                	push   $0x1
    1c33:	e8 45 35 00 00       	call   517d <printf>
    1c38:	83 c4 10             	add    $0x10,%esp
    close(pfds[1]);
    1c3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c3e:	83 ec 0c             	sub    $0xc,%esp
    1c41:	50                   	push   %eax
    1c42:	e8 d7 33 00 00       	call   501e <close>
    1c47:	83 c4 10             	add    $0x10,%esp
    for(;;)
      ;
    1c4a:	eb fe                	jmp    1c4a <preempt+0xa0>
  }

  close(pfds[1]);
    1c4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c4f:	83 ec 0c             	sub    $0xc,%esp
    1c52:	50                   	push   %eax
    1c53:	e8 c6 33 00 00       	call   501e <close>
    1c58:	83 c4 10             	add    $0x10,%esp
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    1c5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1c5e:	83 ec 04             	sub    $0x4,%esp
    1c61:	68 00 20 00 00       	push   $0x2000
    1c66:	68 20 9d 00 00       	push   $0x9d20
    1c6b:	50                   	push   %eax
    1c6c:	e8 9d 33 00 00       	call   500e <read>
    1c71:	83 c4 10             	add    $0x10,%esp
    1c74:	83 f8 01             	cmp    $0x1,%eax
    1c77:	74 14                	je     1c8d <preempt+0xe3>
    printf(1, "preempt read error");
    1c79:	83 ec 08             	sub    $0x8,%esp
    1c7c:	68 71 5a 00 00       	push   $0x5a71
    1c81:	6a 01                	push   $0x1
    1c83:	e8 f5 34 00 00       	call   517d <printf>
    1c88:	83 c4 10             	add    $0x10,%esp
    1c8b:	eb 7e                	jmp    1d0b <preempt+0x161>
    return;
  }
  close(pfds[0]);
    1c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1c90:	83 ec 0c             	sub    $0xc,%esp
    1c93:	50                   	push   %eax
    1c94:	e8 85 33 00 00       	call   501e <close>
    1c99:	83 c4 10             	add    $0x10,%esp
  printf(1, "kill... ");
    1c9c:	83 ec 08             	sub    $0x8,%esp
    1c9f:	68 84 5a 00 00       	push   $0x5a84
    1ca4:	6a 01                	push   $0x1
    1ca6:	e8 d2 34 00 00       	call   517d <printf>
    1cab:	83 c4 10             	add    $0x10,%esp
  kill(pid1);
    1cae:	83 ec 0c             	sub    $0xc,%esp
    1cb1:	ff 75 f4             	pushl  -0xc(%ebp)
    1cb4:	e8 6d 33 00 00       	call   5026 <kill>
    1cb9:	83 c4 10             	add    $0x10,%esp
  kill(pid2);
    1cbc:	83 ec 0c             	sub    $0xc,%esp
    1cbf:	ff 75 f0             	pushl  -0x10(%ebp)
    1cc2:	e8 5f 33 00 00       	call   5026 <kill>
    1cc7:	83 c4 10             	add    $0x10,%esp
  kill(pid3);
    1cca:	83 ec 0c             	sub    $0xc,%esp
    1ccd:	ff 75 ec             	pushl  -0x14(%ebp)
    1cd0:	e8 51 33 00 00       	call   5026 <kill>
    1cd5:	83 c4 10             	add    $0x10,%esp
  printf(1, "wait... ");
    1cd8:	83 ec 08             	sub    $0x8,%esp
    1cdb:	68 8d 5a 00 00       	push   $0x5a8d
    1ce0:	6a 01                	push   $0x1
    1ce2:	e8 96 34 00 00       	call   517d <printf>
    1ce7:	83 c4 10             	add    $0x10,%esp
  wait();
    1cea:	e8 0f 33 00 00       	call   4ffe <wait>
  wait();
    1cef:	e8 0a 33 00 00       	call   4ffe <wait>
  wait();
    1cf4:	e8 05 33 00 00       	call   4ffe <wait>
  printf(1, "preempt ok\n");
    1cf9:	83 ec 08             	sub    $0x8,%esp
    1cfc:	68 96 5a 00 00       	push   $0x5a96
    1d01:	6a 01                	push   $0x1
    1d03:	e8 75 34 00 00       	call   517d <printf>
    1d08:	83 c4 10             	add    $0x10,%esp
}
    1d0b:	c9                   	leave  
    1d0c:	c3                   	ret    

00001d0d <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
    1d0d:	55                   	push   %ebp
    1d0e:	89 e5                	mov    %esp,%ebp
    1d10:	83 ec 18             	sub    $0x18,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
    1d13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1d1a:	eb 4f                	jmp    1d6b <exitwait+0x5e>
    pid = fork();
    1d1c:	e8 cd 32 00 00       	call   4fee <fork>
    1d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
    1d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1d28:	79 14                	jns    1d3e <exitwait+0x31>
      printf(1, "fork failed\n");
    1d2a:	83 ec 08             	sub    $0x8,%esp
    1d2d:	68 25 56 00 00       	push   $0x5625
    1d32:	6a 01                	push   $0x1
    1d34:	e8 44 34 00 00       	call   517d <printf>
    1d39:	83 c4 10             	add    $0x10,%esp
      return;
    1d3c:	eb 45                	jmp    1d83 <exitwait+0x76>
    }
    if(pid){
    1d3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1d42:	74 1e                	je     1d62 <exitwait+0x55>
      if(wait() != pid){
    1d44:	e8 b5 32 00 00       	call   4ffe <wait>
    1d49:	3b 45 f0             	cmp    -0x10(%ebp),%eax
    1d4c:	74 19                	je     1d67 <exitwait+0x5a>
        printf(1, "wait wrong pid\n");
    1d4e:	83 ec 08             	sub    $0x8,%esp
    1d51:	68 a2 5a 00 00       	push   $0x5aa2
    1d56:	6a 01                	push   $0x1
    1d58:	e8 20 34 00 00       	call   517d <printf>
    1d5d:	83 c4 10             	add    $0x10,%esp
        return;
    1d60:	eb 21                	jmp    1d83 <exitwait+0x76>
      }
    } else {
      exit();
    1d62:	e8 8f 32 00 00       	call   4ff6 <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
    1d67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1d6b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1d6f:	7e ab                	jle    1d1c <exitwait+0xf>
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
    1d71:	83 ec 08             	sub    $0x8,%esp
    1d74:	68 b2 5a 00 00       	push   $0x5ab2
    1d79:	6a 01                	push   $0x1
    1d7b:	e8 fd 33 00 00       	call   517d <printf>
    1d80:	83 c4 10             	add    $0x10,%esp
}
    1d83:	c9                   	leave  
    1d84:	c3                   	ret    

00001d85 <mem>:

void
mem(void)
{
    1d85:	55                   	push   %ebp
    1d86:	89 e5                	mov    %esp,%ebp
    1d88:	83 ec 18             	sub    $0x18,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
    1d8b:	83 ec 08             	sub    $0x8,%esp
    1d8e:	68 bf 5a 00 00       	push   $0x5abf
    1d93:	6a 01                	push   $0x1
    1d95:	e8 e3 33 00 00       	call   517d <printf>
    1d9a:	83 c4 10             	add    $0x10,%esp
  ppid = getpid();
    1d9d:	e8 d4 32 00 00       	call   5076 <getpid>
    1da2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
    1da5:	e8 44 32 00 00       	call   4fee <fork>
    1daa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1dad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1db1:	0f 85 b7 00 00 00    	jne    1e6e <mem+0xe9>
    m1 = 0;
    1db7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
    1dbe:	eb 0e                	jmp    1dce <mem+0x49>
      *(char**)m2 = m1;
    1dc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1dc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1dc6:	89 10                	mov    %edx,(%eax)
      m1 = m2;
    1dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1dcb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
    1dce:	83 ec 0c             	sub    $0xc,%esp
    1dd1:	68 11 27 00 00       	push   $0x2711
    1dd6:	e8 75 36 00 00       	call   5450 <malloc>
    1ddb:	83 c4 10             	add    $0x10,%esp
    1dde:	89 45 e8             	mov    %eax,-0x18(%ebp)
    1de1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1de5:	75 d9                	jne    1dc0 <mem+0x3b>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
    1de7:	eb 1c                	jmp    1e05 <mem+0x80>
      m2 = *(char**)m1;
    1de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1dec:	8b 00                	mov    (%eax),%eax
    1dee:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
    1df1:	83 ec 0c             	sub    $0xc,%esp
    1df4:	ff 75 f4             	pushl  -0xc(%ebp)
    1df7:	e8 12 35 00 00       	call   530e <free>
    1dfc:	83 c4 10             	add    $0x10,%esp
      m1 = m2;
    1dff:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
    1e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1e09:	75 de                	jne    1de9 <mem+0x64>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
    1e0b:	83 ec 0c             	sub    $0xc,%esp
    1e0e:	68 00 50 00 00       	push   $0x5000
    1e13:	e8 38 36 00 00       	call   5450 <malloc>
    1e18:	83 c4 10             	add    $0x10,%esp
    1e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
    1e1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1e22:	75 25                	jne    1e49 <mem+0xc4>
      printf(1, "couldn't allocate mem?!!\n");
    1e24:	83 ec 08             	sub    $0x8,%esp
    1e27:	68 c9 5a 00 00       	push   $0x5ac9
    1e2c:	6a 01                	push   $0x1
    1e2e:	e8 4a 33 00 00       	call   517d <printf>
    1e33:	83 c4 10             	add    $0x10,%esp
      kill(ppid);
    1e36:	83 ec 0c             	sub    $0xc,%esp
    1e39:	ff 75 f0             	pushl  -0x10(%ebp)
    1e3c:	e8 e5 31 00 00       	call   5026 <kill>
    1e41:	83 c4 10             	add    $0x10,%esp
      exit();
    1e44:	e8 ad 31 00 00       	call   4ff6 <exit>
    }
    free(m1);
    1e49:	83 ec 0c             	sub    $0xc,%esp
    1e4c:	ff 75 f4             	pushl  -0xc(%ebp)
    1e4f:	e8 ba 34 00 00       	call   530e <free>
    1e54:	83 c4 10             	add    $0x10,%esp
    printf(1, "mem ok\n");
    1e57:	83 ec 08             	sub    $0x8,%esp
    1e5a:	68 e3 5a 00 00       	push   $0x5ae3
    1e5f:	6a 01                	push   $0x1
    1e61:	e8 17 33 00 00       	call   517d <printf>
    1e66:	83 c4 10             	add    $0x10,%esp
    exit();
    1e69:	e8 88 31 00 00       	call   4ff6 <exit>
  } else {
    wait();
    1e6e:	e8 8b 31 00 00       	call   4ffe <wait>
  }
}
    1e73:	90                   	nop
    1e74:	c9                   	leave  
    1e75:	c3                   	ret    

00001e76 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
    1e76:	55                   	push   %ebp
    1e77:	89 e5                	mov    %esp,%ebp
    1e79:	83 ec 38             	sub    $0x38,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
    1e7c:	83 ec 08             	sub    $0x8,%esp
    1e7f:	68 eb 5a 00 00       	push   $0x5aeb
    1e84:	6a 01                	push   $0x1
    1e86:	e8 f2 32 00 00       	call   517d <printf>
    1e8b:	83 c4 10             	add    $0x10,%esp

  unlink("sharedfd");
    1e8e:	83 ec 0c             	sub    $0xc,%esp
    1e91:	68 fa 5a 00 00       	push   $0x5afa
    1e96:	e8 ab 31 00 00       	call   5046 <unlink>
    1e9b:	83 c4 10             	add    $0x10,%esp
  fd = open("sharedfd", O_CREATE|O_RDWR);
    1e9e:	83 ec 08             	sub    $0x8,%esp
    1ea1:	68 02 02 00 00       	push   $0x202
    1ea6:	68 fa 5a 00 00       	push   $0x5afa
    1eab:	e8 86 31 00 00       	call   5036 <open>
    1eb0:	83 c4 10             	add    $0x10,%esp
    1eb3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
    1eb6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1eba:	79 17                	jns    1ed3 <sharedfd+0x5d>
    printf(1, "fstests: cannot open sharedfd for writing");
    1ebc:	83 ec 08             	sub    $0x8,%esp
    1ebf:	68 04 5b 00 00       	push   $0x5b04
    1ec4:	6a 01                	push   $0x1
    1ec6:	e8 b2 32 00 00       	call   517d <printf>
    1ecb:	83 c4 10             	add    $0x10,%esp
    return;
    1ece:	e9 84 01 00 00       	jmp    2057 <sharedfd+0x1e1>
  }
  pid = fork();
    1ed3:	e8 16 31 00 00       	call   4fee <fork>
    1ed8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
    1edb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1edf:	75 07                	jne    1ee8 <sharedfd+0x72>
    1ee1:	b8 63 00 00 00       	mov    $0x63,%eax
    1ee6:	eb 05                	jmp    1eed <sharedfd+0x77>
    1ee8:	b8 70 00 00 00       	mov    $0x70,%eax
    1eed:	83 ec 04             	sub    $0x4,%esp
    1ef0:	6a 0a                	push   $0xa
    1ef2:	50                   	push   %eax
    1ef3:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1ef6:	50                   	push   %eax
    1ef7:	e8 5f 2f 00 00       	call   4e5b <memset>
    1efc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 1000; i++){
    1eff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1f06:	eb 31                	jmp    1f39 <sharedfd+0xc3>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    1f08:	83 ec 04             	sub    $0x4,%esp
    1f0b:	6a 0a                	push   $0xa
    1f0d:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1f10:	50                   	push   %eax
    1f11:	ff 75 e8             	pushl  -0x18(%ebp)
    1f14:	e8 fd 30 00 00       	call   5016 <write>
    1f19:	83 c4 10             	add    $0x10,%esp
    1f1c:	83 f8 0a             	cmp    $0xa,%eax
    1f1f:	74 14                	je     1f35 <sharedfd+0xbf>
      printf(1, "fstests: write sharedfd failed\n");
    1f21:	83 ec 08             	sub    $0x8,%esp
    1f24:	68 30 5b 00 00       	push   $0x5b30
    1f29:	6a 01                	push   $0x1
    1f2b:	e8 4d 32 00 00       	call   517d <printf>
    1f30:	83 c4 10             	add    $0x10,%esp
      break;
    1f33:	eb 0d                	jmp    1f42 <sharedfd+0xcc>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
    1f35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1f39:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    1f40:	7e c6                	jle    1f08 <sharedfd+0x92>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
    1f42:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1f46:	75 05                	jne    1f4d <sharedfd+0xd7>
    exit();
    1f48:	e8 a9 30 00 00       	call   4ff6 <exit>
  else
    wait();
    1f4d:	e8 ac 30 00 00       	call   4ffe <wait>
  close(fd);
    1f52:	83 ec 0c             	sub    $0xc,%esp
    1f55:	ff 75 e8             	pushl  -0x18(%ebp)
    1f58:	e8 c1 30 00 00       	call   501e <close>
    1f5d:	83 c4 10             	add    $0x10,%esp
  fd = open("sharedfd", 0);
    1f60:	83 ec 08             	sub    $0x8,%esp
    1f63:	6a 00                	push   $0x0
    1f65:	68 fa 5a 00 00       	push   $0x5afa
    1f6a:	e8 c7 30 00 00       	call   5036 <open>
    1f6f:	83 c4 10             	add    $0x10,%esp
    1f72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
    1f75:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1f79:	79 17                	jns    1f92 <sharedfd+0x11c>
    printf(1, "fstests: cannot open sharedfd for reading\n");
    1f7b:	83 ec 08             	sub    $0x8,%esp
    1f7e:	68 50 5b 00 00       	push   $0x5b50
    1f83:	6a 01                	push   $0x1
    1f85:	e8 f3 31 00 00       	call   517d <printf>
    1f8a:	83 c4 10             	add    $0x10,%esp
    return;
    1f8d:	e9 c5 00 00 00       	jmp    2057 <sharedfd+0x1e1>
  }
  nc = np = 0;
    1f92:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    1f99:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1f9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    1f9f:	eb 3b                	jmp    1fdc <sharedfd+0x166>
    for(i = 0; i < sizeof(buf); i++){
    1fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1fa8:	eb 2a                	jmp    1fd4 <sharedfd+0x15e>
      if(buf[i] == 'c')
    1faa:	8d 55 d6             	lea    -0x2a(%ebp),%edx
    1fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1fb0:	01 d0                	add    %edx,%eax
    1fb2:	0f b6 00             	movzbl (%eax),%eax
    1fb5:	3c 63                	cmp    $0x63,%al
    1fb7:	75 04                	jne    1fbd <sharedfd+0x147>
        nc++;
    1fb9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
    1fbd:	8d 55 d6             	lea    -0x2a(%ebp),%edx
    1fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1fc3:	01 d0                	add    %edx,%eax
    1fc5:	0f b6 00             	movzbl (%eax),%eax
    1fc8:	3c 70                	cmp    $0x70,%al
    1fca:	75 04                	jne    1fd0 <sharedfd+0x15a>
        np++;
    1fcc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
    1fd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1fd7:	83 f8 09             	cmp    $0x9,%eax
    1fda:	76 ce                	jbe    1faa <sharedfd+0x134>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    1fdc:	83 ec 04             	sub    $0x4,%esp
    1fdf:	6a 0a                	push   $0xa
    1fe1:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1fe4:	50                   	push   %eax
    1fe5:	ff 75 e8             	pushl  -0x18(%ebp)
    1fe8:	e8 21 30 00 00       	call   500e <read>
    1fed:	83 c4 10             	add    $0x10,%esp
    1ff0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    1ff3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1ff7:	7f a8                	jg     1fa1 <sharedfd+0x12b>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
    1ff9:	83 ec 0c             	sub    $0xc,%esp
    1ffc:	ff 75 e8             	pushl  -0x18(%ebp)
    1fff:	e8 1a 30 00 00       	call   501e <close>
    2004:	83 c4 10             	add    $0x10,%esp
  unlink("sharedfd");
    2007:	83 ec 0c             	sub    $0xc,%esp
    200a:	68 fa 5a 00 00       	push   $0x5afa
    200f:	e8 32 30 00 00       	call   5046 <unlink>
    2014:	83 c4 10             	add    $0x10,%esp
  if(nc == 10000 && np == 10000){
    2017:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
    201e:	75 1d                	jne    203d <sharedfd+0x1c7>
    2020:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
    2027:	75 14                	jne    203d <sharedfd+0x1c7>
    printf(1, "sharedfd ok\n");
    2029:	83 ec 08             	sub    $0x8,%esp
    202c:	68 7b 5b 00 00       	push   $0x5b7b
    2031:	6a 01                	push   $0x1
    2033:	e8 45 31 00 00       	call   517d <printf>
    2038:	83 c4 10             	add    $0x10,%esp
    203b:	eb 1a                	jmp    2057 <sharedfd+0x1e1>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    203d:	ff 75 ec             	pushl  -0x14(%ebp)
    2040:	ff 75 f0             	pushl  -0x10(%ebp)
    2043:	68 88 5b 00 00       	push   $0x5b88
    2048:	6a 01                	push   $0x1
    204a:	e8 2e 31 00 00       	call   517d <printf>
    204f:	83 c4 10             	add    $0x10,%esp
    exit();
    2052:	e8 9f 2f 00 00       	call   4ff6 <exit>
  }
}
    2057:	c9                   	leave  
    2058:	c3                   	ret    

00002059 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    2059:	55                   	push   %ebp
    205a:	89 e5                	mov    %esp,%ebp
    205c:	83 ec 38             	sub    $0x38,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    205f:	c7 45 c8 9d 5b 00 00 	movl   $0x5b9d,-0x38(%ebp)
    2066:	c7 45 cc a0 5b 00 00 	movl   $0x5ba0,-0x34(%ebp)
    206d:	c7 45 d0 a3 5b 00 00 	movl   $0x5ba3,-0x30(%ebp)
    2074:	c7 45 d4 a6 5b 00 00 	movl   $0x5ba6,-0x2c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
    207b:	83 ec 08             	sub    $0x8,%esp
    207e:	68 a9 5b 00 00       	push   $0x5ba9
    2083:	6a 01                	push   $0x1
    2085:	e8 f3 30 00 00       	call   517d <printf>
    208a:	83 c4 10             	add    $0x10,%esp

  for(pi = 0; pi < 4; pi++){
    208d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    2094:	e9 f0 00 00 00       	jmp    2189 <fourfiles+0x130>
    fname = names[pi];
    2099:	8b 45 e8             	mov    -0x18(%ebp),%eax
    209c:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    20a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    unlink(fname);
    20a3:	83 ec 0c             	sub    $0xc,%esp
    20a6:	ff 75 e4             	pushl  -0x1c(%ebp)
    20a9:	e8 98 2f 00 00       	call   5046 <unlink>
    20ae:	83 c4 10             	add    $0x10,%esp

    pid = fork();
    20b1:	e8 38 2f 00 00       	call   4fee <fork>
    20b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid < 0){
    20b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    20bd:	79 17                	jns    20d6 <fourfiles+0x7d>
      printf(1, "fork failed\n");
    20bf:	83 ec 08             	sub    $0x8,%esp
    20c2:	68 25 56 00 00       	push   $0x5625
    20c7:	6a 01                	push   $0x1
    20c9:	e8 af 30 00 00       	call   517d <printf>
    20ce:	83 c4 10             	add    $0x10,%esp
      exit();
    20d1:	e8 20 2f 00 00       	call   4ff6 <exit>
    }

    if(pid == 0){
    20d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    20da:	0f 85 a5 00 00 00    	jne    2185 <fourfiles+0x12c>
      fd = open(fname, O_CREATE | O_RDWR);
    20e0:	83 ec 08             	sub    $0x8,%esp
    20e3:	68 02 02 00 00       	push   $0x202
    20e8:	ff 75 e4             	pushl  -0x1c(%ebp)
    20eb:	e8 46 2f 00 00       	call   5036 <open>
    20f0:	83 c4 10             	add    $0x10,%esp
    20f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(fd < 0){
    20f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
    20fa:	79 17                	jns    2113 <fourfiles+0xba>
        printf(1, "create failed\n");
    20fc:	83 ec 08             	sub    $0x8,%esp
    20ff:	68 b9 5b 00 00       	push   $0x5bb9
    2104:	6a 01                	push   $0x1
    2106:	e8 72 30 00 00       	call   517d <printf>
    210b:	83 c4 10             	add    $0x10,%esp
        exit();
    210e:	e8 e3 2e 00 00       	call   4ff6 <exit>
      }

      memset(buf, '0'+pi, 512);
    2113:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2116:	83 c0 30             	add    $0x30,%eax
    2119:	83 ec 04             	sub    $0x4,%esp
    211c:	68 00 02 00 00       	push   $0x200
    2121:	50                   	push   %eax
    2122:	68 20 9d 00 00       	push   $0x9d20
    2127:	e8 2f 2d 00 00       	call   4e5b <memset>
    212c:	83 c4 10             	add    $0x10,%esp
      for(i = 0; i < 12; i++){
    212f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2136:	eb 42                	jmp    217a <fourfiles+0x121>
        if((n = write(fd, buf, 500)) != 500){
    2138:	83 ec 04             	sub    $0x4,%esp
    213b:	68 f4 01 00 00       	push   $0x1f4
    2140:	68 20 9d 00 00       	push   $0x9d20
    2145:	ff 75 dc             	pushl  -0x24(%ebp)
    2148:	e8 c9 2e 00 00       	call   5016 <write>
    214d:	83 c4 10             	add    $0x10,%esp
    2150:	89 45 d8             	mov    %eax,-0x28(%ebp)
    2153:	81 7d d8 f4 01 00 00 	cmpl   $0x1f4,-0x28(%ebp)
    215a:	74 1a                	je     2176 <fourfiles+0x11d>
          printf(1, "write failed %d\n", n);
    215c:	83 ec 04             	sub    $0x4,%esp
    215f:	ff 75 d8             	pushl  -0x28(%ebp)
    2162:	68 c8 5b 00 00       	push   $0x5bc8
    2167:	6a 01                	push   $0x1
    2169:	e8 0f 30 00 00       	call   517d <printf>
    216e:	83 c4 10             	add    $0x10,%esp
          exit();
    2171:	e8 80 2e 00 00       	call   4ff6 <exit>
        printf(1, "create failed\n");
        exit();
      }

      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    2176:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    217a:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
    217e:	7e b8                	jle    2138 <fourfiles+0xdf>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit();
        }
      }
      exit();
    2180:	e8 71 2e 00 00       	call   4ff6 <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    2185:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    2189:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    218d:	0f 8e 06 ff ff ff    	jle    2099 <fourfiles+0x40>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    2193:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    219a:	eb 09                	jmp    21a5 <fourfiles+0x14c>
    wait();
    219c:	e8 5d 2e 00 00       	call   4ffe <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    21a1:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    21a5:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    21a9:	7e f1                	jle    219c <fourfiles+0x143>
    wait();
  }

  for(i = 0; i < 2; i++){
    21ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    21b2:	e9 d4 00 00 00       	jmp    228b <fourfiles+0x232>
    fname = names[i];
    21b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    21ba:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    21be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    fd = open(fname, 0);
    21c1:	83 ec 08             	sub    $0x8,%esp
    21c4:	6a 00                	push   $0x0
    21c6:	ff 75 e4             	pushl  -0x1c(%ebp)
    21c9:	e8 68 2e 00 00       	call   5036 <open>
    21ce:	83 c4 10             	add    $0x10,%esp
    21d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    total = 0;
    21d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    21db:	eb 4a                	jmp    2227 <fourfiles+0x1ce>
      for(j = 0; j < n; j++){
    21dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    21e4:	eb 33                	jmp    2219 <fourfiles+0x1c0>
        if(buf[j] != '0'+i){
    21e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    21e9:	05 20 9d 00 00       	add    $0x9d20,%eax
    21ee:	0f b6 00             	movzbl (%eax),%eax
    21f1:	0f be c0             	movsbl %al,%eax
    21f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
    21f7:	83 c2 30             	add    $0x30,%edx
    21fa:	39 d0                	cmp    %edx,%eax
    21fc:	74 17                	je     2215 <fourfiles+0x1bc>
          printf(1, "wrong char\n");
    21fe:	83 ec 08             	sub    $0x8,%esp
    2201:	68 d9 5b 00 00       	push   $0x5bd9
    2206:	6a 01                	push   $0x1
    2208:	e8 70 2f 00 00       	call   517d <printf>
    220d:	83 c4 10             	add    $0x10,%esp
          exit();
    2210:	e8 e1 2d 00 00       	call   4ff6 <exit>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    2215:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    2219:	8b 45 f0             	mov    -0x10(%ebp),%eax
    221c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
    221f:	7c c5                	jl     21e6 <fourfiles+0x18d>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    2221:	8b 45 d8             	mov    -0x28(%ebp),%eax
    2224:	01 45 ec             	add    %eax,-0x14(%ebp)

  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2227:	83 ec 04             	sub    $0x4,%esp
    222a:	68 00 20 00 00       	push   $0x2000
    222f:	68 20 9d 00 00       	push   $0x9d20
    2234:	ff 75 dc             	pushl  -0x24(%ebp)
    2237:	e8 d2 2d 00 00       	call   500e <read>
    223c:	83 c4 10             	add    $0x10,%esp
    223f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    2242:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
    2246:	7f 95                	jg     21dd <fourfiles+0x184>
          exit();
        }
      }
      total += n;
    }
    close(fd);
    2248:	83 ec 0c             	sub    $0xc,%esp
    224b:	ff 75 dc             	pushl  -0x24(%ebp)
    224e:	e8 cb 2d 00 00       	call   501e <close>
    2253:	83 c4 10             	add    $0x10,%esp
    if(total != 12*500){
    2256:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
    225d:	74 1a                	je     2279 <fourfiles+0x220>
      printf(1, "wrong length %d\n", total);
    225f:	83 ec 04             	sub    $0x4,%esp
    2262:	ff 75 ec             	pushl  -0x14(%ebp)
    2265:	68 e5 5b 00 00       	push   $0x5be5
    226a:	6a 01                	push   $0x1
    226c:	e8 0c 2f 00 00       	call   517d <printf>
    2271:	83 c4 10             	add    $0x10,%esp
      exit();
    2274:	e8 7d 2d 00 00       	call   4ff6 <exit>
    }
    unlink(fname);
    2279:	83 ec 0c             	sub    $0xc,%esp
    227c:	ff 75 e4             	pushl  -0x1c(%ebp)
    227f:	e8 c2 2d 00 00       	call   5046 <unlink>
    2284:	83 c4 10             	add    $0x10,%esp

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    2287:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    228b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
    228f:	0f 8e 22 ff ff ff    	jle    21b7 <fourfiles+0x15e>
      exit();
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    2295:	83 ec 08             	sub    $0x8,%esp
    2298:	68 f6 5b 00 00       	push   $0x5bf6
    229d:	6a 01                	push   $0x1
    229f:	e8 d9 2e 00 00       	call   517d <printf>
    22a4:	83 c4 10             	add    $0x10,%esp
}
    22a7:	90                   	nop
    22a8:	c9                   	leave  
    22a9:	c3                   	ret    

000022aa <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    22aa:	55                   	push   %ebp
    22ab:	89 e5                	mov    %esp,%ebp
    22ad:	83 ec 38             	sub    $0x38,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    22b0:	83 ec 08             	sub    $0x8,%esp
    22b3:	68 04 5c 00 00       	push   $0x5c04
    22b8:	6a 01                	push   $0x1
    22ba:	e8 be 2e 00 00       	call   517d <printf>
    22bf:	83 c4 10             	add    $0x10,%esp

  for(pi = 0; pi < 4; pi++){
    22c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    22c9:	e9 f6 00 00 00       	jmp    23c4 <createdelete+0x11a>
    pid = fork();
    22ce:	e8 1b 2d 00 00       	call   4fee <fork>
    22d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    22d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    22da:	79 17                	jns    22f3 <createdelete+0x49>
      printf(1, "fork failed\n");
    22dc:	83 ec 08             	sub    $0x8,%esp
    22df:	68 25 56 00 00       	push   $0x5625
    22e4:	6a 01                	push   $0x1
    22e6:	e8 92 2e 00 00       	call   517d <printf>
    22eb:	83 c4 10             	add    $0x10,%esp
      exit();
    22ee:	e8 03 2d 00 00       	call   4ff6 <exit>
    }

    if(pid == 0){
    22f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    22f7:	0f 85 c3 00 00 00    	jne    23c0 <createdelete+0x116>
      name[0] = 'p' + pi;
    22fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2300:	83 c0 70             	add    $0x70,%eax
    2303:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[2] = '\0';
    2306:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    230a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2311:	e9 9b 00 00 00       	jmp    23b1 <createdelete+0x107>
        name[1] = '0' + i;
    2316:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2319:	83 c0 30             	add    $0x30,%eax
    231c:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    231f:	83 ec 08             	sub    $0x8,%esp
    2322:	68 02 02 00 00       	push   $0x202
    2327:	8d 45 c8             	lea    -0x38(%ebp),%eax
    232a:	50                   	push   %eax
    232b:	e8 06 2d 00 00       	call   5036 <open>
    2330:	83 c4 10             	add    $0x10,%esp
    2333:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(fd < 0){
    2336:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    233a:	79 17                	jns    2353 <createdelete+0xa9>
          printf(1, "create failed\n");
    233c:	83 ec 08             	sub    $0x8,%esp
    233f:	68 b9 5b 00 00       	push   $0x5bb9
    2344:	6a 01                	push   $0x1
    2346:	e8 32 2e 00 00       	call   517d <printf>
    234b:	83 c4 10             	add    $0x10,%esp
          exit();
    234e:	e8 a3 2c 00 00       	call   4ff6 <exit>
        }
        close(fd);
    2353:	83 ec 0c             	sub    $0xc,%esp
    2356:	ff 75 e8             	pushl  -0x18(%ebp)
    2359:	e8 c0 2c 00 00       	call   501e <close>
    235e:	83 c4 10             	add    $0x10,%esp
        if(i > 0 && (i % 2 ) == 0){
    2361:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2365:	7e 46                	jle    23ad <createdelete+0x103>
    2367:	8b 45 f4             	mov    -0xc(%ebp),%eax
    236a:	83 e0 01             	and    $0x1,%eax
    236d:	85 c0                	test   %eax,%eax
    236f:	75 3c                	jne    23ad <createdelete+0x103>
          name[1] = '0' + (i / 2);
    2371:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2374:	89 c2                	mov    %eax,%edx
    2376:	c1 ea 1f             	shr    $0x1f,%edx
    2379:	01 d0                	add    %edx,%eax
    237b:	d1 f8                	sar    %eax
    237d:	83 c0 30             	add    $0x30,%eax
    2380:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    2383:	83 ec 0c             	sub    $0xc,%esp
    2386:	8d 45 c8             	lea    -0x38(%ebp),%eax
    2389:	50                   	push   %eax
    238a:	e8 b7 2c 00 00       	call   5046 <unlink>
    238f:	83 c4 10             	add    $0x10,%esp
    2392:	85 c0                	test   %eax,%eax
    2394:	79 17                	jns    23ad <createdelete+0x103>
            printf(1, "unlink failed\n");
    2396:	83 ec 08             	sub    $0x8,%esp
    2399:	68 a8 56 00 00       	push   $0x56a8
    239e:	6a 01                	push   $0x1
    23a0:	e8 d8 2d 00 00       	call   517d <printf>
    23a5:	83 c4 10             	add    $0x10,%esp
            exit();
    23a8:	e8 49 2c 00 00       	call   4ff6 <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    23ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    23b1:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    23b5:	0f 8e 5b ff ff ff    	jle    2316 <createdelete+0x6c>
            printf(1, "unlink failed\n");
            exit();
          }
        }
      }
      exit();
    23bb:	e8 36 2c 00 00       	call   4ff6 <exit>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    23c0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    23c4:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    23c8:	0f 8e 00 ff ff ff    	jle    22ce <createdelete+0x24>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    23ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    23d5:	eb 09                	jmp    23e0 <createdelete+0x136>
    wait();
    23d7:	e8 22 2c 00 00       	call   4ffe <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    23dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    23e0:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    23e4:	7e f1                	jle    23d7 <createdelete+0x12d>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
    23e6:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    23ea:	0f b6 45 ca          	movzbl -0x36(%ebp),%eax
    23ee:	88 45 c9             	mov    %al,-0x37(%ebp)
    23f1:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
    23f5:	88 45 c8             	mov    %al,-0x38(%ebp)
  for(i = 0; i < N; i++){
    23f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    23ff:	e9 b2 00 00 00       	jmp    24b6 <createdelete+0x20c>
    for(pi = 0; pi < 4; pi++){
    2404:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    240b:	e9 98 00 00 00       	jmp    24a8 <createdelete+0x1fe>
      name[0] = 'p' + pi;
    2410:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2413:	83 c0 70             	add    $0x70,%eax
    2416:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    2419:	8b 45 f4             	mov    -0xc(%ebp),%eax
    241c:	83 c0 30             	add    $0x30,%eax
    241f:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    2422:	83 ec 08             	sub    $0x8,%esp
    2425:	6a 00                	push   $0x0
    2427:	8d 45 c8             	lea    -0x38(%ebp),%eax
    242a:	50                   	push   %eax
    242b:	e8 06 2c 00 00       	call   5036 <open>
    2430:	83 c4 10             	add    $0x10,%esp
    2433:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    2436:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    243a:	74 06                	je     2442 <createdelete+0x198>
    243c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    2440:	7e 21                	jle    2463 <createdelete+0x1b9>
    2442:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2446:	79 1b                	jns    2463 <createdelete+0x1b9>
        printf(1, "oops createdelete %s didn't exist\n", name);
    2448:	83 ec 04             	sub    $0x4,%esp
    244b:	8d 45 c8             	lea    -0x38(%ebp),%eax
    244e:	50                   	push   %eax
    244f:	68 18 5c 00 00       	push   $0x5c18
    2454:	6a 01                	push   $0x1
    2456:	e8 22 2d 00 00       	call   517d <printf>
    245b:	83 c4 10             	add    $0x10,%esp
        exit();
    245e:	e8 93 2b 00 00       	call   4ff6 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    2463:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2467:	7e 27                	jle    2490 <createdelete+0x1e6>
    2469:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    246d:	7f 21                	jg     2490 <createdelete+0x1e6>
    246f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2473:	78 1b                	js     2490 <createdelete+0x1e6>
        printf(1, "oops createdelete %s did exist\n", name);
    2475:	83 ec 04             	sub    $0x4,%esp
    2478:	8d 45 c8             	lea    -0x38(%ebp),%eax
    247b:	50                   	push   %eax
    247c:	68 3c 5c 00 00       	push   $0x5c3c
    2481:	6a 01                	push   $0x1
    2483:	e8 f5 2c 00 00       	call   517d <printf>
    2488:	83 c4 10             	add    $0x10,%esp
        exit();
    248b:	e8 66 2b 00 00       	call   4ff6 <exit>
      }
      if(fd >= 0)
    2490:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2494:	78 0e                	js     24a4 <createdelete+0x1fa>
        close(fd);
    2496:	83 ec 0c             	sub    $0xc,%esp
    2499:	ff 75 e8             	pushl  -0x18(%ebp)
    249c:	e8 7d 2b 00 00       	call   501e <close>
    24a1:	83 c4 10             	add    $0x10,%esp
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    24a4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    24a8:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    24ac:	0f 8e 5e ff ff ff    	jle    2410 <createdelete+0x166>
  for(pi = 0; pi < 4; pi++){
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    24b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    24b6:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    24ba:	0f 8e 44 ff ff ff    	jle    2404 <createdelete+0x15a>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    24c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    24c7:	eb 38                	jmp    2501 <createdelete+0x257>
    for(pi = 0; pi < 4; pi++){
    24c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    24d0:	eb 25                	jmp    24f7 <createdelete+0x24d>
      name[0] = 'p' + i;
    24d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    24d5:	83 c0 70             	add    $0x70,%eax
    24d8:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    24db:	8b 45 f4             	mov    -0xc(%ebp),%eax
    24de:	83 c0 30             	add    $0x30,%eax
    24e1:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    24e4:	83 ec 0c             	sub    $0xc,%esp
    24e7:	8d 45 c8             	lea    -0x38(%ebp),%eax
    24ea:	50                   	push   %eax
    24eb:	e8 56 2b 00 00       	call   5046 <unlink>
    24f0:	83 c4 10             	add    $0x10,%esp
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    24f3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    24f7:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    24fb:	7e d5                	jle    24d2 <createdelete+0x228>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    24fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2501:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    2505:	7e c2                	jle    24c9 <createdelete+0x21f>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    2507:	83 ec 08             	sub    $0x8,%esp
    250a:	68 5c 5c 00 00       	push   $0x5c5c
    250f:	6a 01                	push   $0x1
    2511:	e8 67 2c 00 00       	call   517d <printf>
    2516:	83 c4 10             	add    $0x10,%esp
}
    2519:	90                   	nop
    251a:	c9                   	leave  
    251b:	c3                   	ret    

0000251c <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    251c:	55                   	push   %ebp
    251d:	89 e5                	mov    %esp,%ebp
    251f:	83 ec 18             	sub    $0x18,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    2522:	83 ec 08             	sub    $0x8,%esp
    2525:	68 6d 5c 00 00       	push   $0x5c6d
    252a:	6a 01                	push   $0x1
    252c:	e8 4c 2c 00 00       	call   517d <printf>
    2531:	83 c4 10             	add    $0x10,%esp
  fd = open("unlinkread", O_CREATE | O_RDWR);
    2534:	83 ec 08             	sub    $0x8,%esp
    2537:	68 02 02 00 00       	push   $0x202
    253c:	68 7e 5c 00 00       	push   $0x5c7e
    2541:	e8 f0 2a 00 00       	call   5036 <open>
    2546:	83 c4 10             	add    $0x10,%esp
    2549:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    254c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2550:	79 17                	jns    2569 <unlinkread+0x4d>
    printf(1, "create unlinkread failed\n");
    2552:	83 ec 08             	sub    $0x8,%esp
    2555:	68 89 5c 00 00       	push   $0x5c89
    255a:	6a 01                	push   $0x1
    255c:	e8 1c 2c 00 00       	call   517d <printf>
    2561:	83 c4 10             	add    $0x10,%esp
    exit();
    2564:	e8 8d 2a 00 00       	call   4ff6 <exit>
  }
  write(fd, "hello", 5);
    2569:	83 ec 04             	sub    $0x4,%esp
    256c:	6a 05                	push   $0x5
    256e:	68 a3 5c 00 00       	push   $0x5ca3
    2573:	ff 75 f4             	pushl  -0xc(%ebp)
    2576:	e8 9b 2a 00 00       	call   5016 <write>
    257b:	83 c4 10             	add    $0x10,%esp
  close(fd);
    257e:	83 ec 0c             	sub    $0xc,%esp
    2581:	ff 75 f4             	pushl  -0xc(%ebp)
    2584:	e8 95 2a 00 00       	call   501e <close>
    2589:	83 c4 10             	add    $0x10,%esp

  fd = open("unlinkread", O_RDWR);
    258c:	83 ec 08             	sub    $0x8,%esp
    258f:	6a 02                	push   $0x2
    2591:	68 7e 5c 00 00       	push   $0x5c7e
    2596:	e8 9b 2a 00 00       	call   5036 <open>
    259b:	83 c4 10             	add    $0x10,%esp
    259e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    25a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    25a5:	79 17                	jns    25be <unlinkread+0xa2>
    printf(1, "open unlinkread failed\n");
    25a7:	83 ec 08             	sub    $0x8,%esp
    25aa:	68 a9 5c 00 00       	push   $0x5ca9
    25af:	6a 01                	push   $0x1
    25b1:	e8 c7 2b 00 00       	call   517d <printf>
    25b6:	83 c4 10             	add    $0x10,%esp
    exit();
    25b9:	e8 38 2a 00 00       	call   4ff6 <exit>
  }
  if(unlink("unlinkread") != 0){
    25be:	83 ec 0c             	sub    $0xc,%esp
    25c1:	68 7e 5c 00 00       	push   $0x5c7e
    25c6:	e8 7b 2a 00 00       	call   5046 <unlink>
    25cb:	83 c4 10             	add    $0x10,%esp
    25ce:	85 c0                	test   %eax,%eax
    25d0:	74 17                	je     25e9 <unlinkread+0xcd>
    printf(1, "unlink unlinkread failed\n");
    25d2:	83 ec 08             	sub    $0x8,%esp
    25d5:	68 c1 5c 00 00       	push   $0x5cc1
    25da:	6a 01                	push   $0x1
    25dc:	e8 9c 2b 00 00       	call   517d <printf>
    25e1:	83 c4 10             	add    $0x10,%esp
    exit();
    25e4:	e8 0d 2a 00 00       	call   4ff6 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    25e9:	83 ec 08             	sub    $0x8,%esp
    25ec:	68 02 02 00 00       	push   $0x202
    25f1:	68 7e 5c 00 00       	push   $0x5c7e
    25f6:	e8 3b 2a 00 00       	call   5036 <open>
    25fb:	83 c4 10             	add    $0x10,%esp
    25fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    2601:	83 ec 04             	sub    $0x4,%esp
    2604:	6a 03                	push   $0x3
    2606:	68 db 5c 00 00       	push   $0x5cdb
    260b:	ff 75 f0             	pushl  -0x10(%ebp)
    260e:	e8 03 2a 00 00       	call   5016 <write>
    2613:	83 c4 10             	add    $0x10,%esp
  close(fd1);
    2616:	83 ec 0c             	sub    $0xc,%esp
    2619:	ff 75 f0             	pushl  -0x10(%ebp)
    261c:	e8 fd 29 00 00       	call   501e <close>
    2621:	83 c4 10             	add    $0x10,%esp

  if(read(fd, buf, sizeof(buf)) != 5){
    2624:	83 ec 04             	sub    $0x4,%esp
    2627:	68 00 20 00 00       	push   $0x2000
    262c:	68 20 9d 00 00       	push   $0x9d20
    2631:	ff 75 f4             	pushl  -0xc(%ebp)
    2634:	e8 d5 29 00 00       	call   500e <read>
    2639:	83 c4 10             	add    $0x10,%esp
    263c:	83 f8 05             	cmp    $0x5,%eax
    263f:	74 17                	je     2658 <unlinkread+0x13c>
    printf(1, "unlinkread read failed");
    2641:	83 ec 08             	sub    $0x8,%esp
    2644:	68 df 5c 00 00       	push   $0x5cdf
    2649:	6a 01                	push   $0x1
    264b:	e8 2d 2b 00 00       	call   517d <printf>
    2650:	83 c4 10             	add    $0x10,%esp
    exit();
    2653:	e8 9e 29 00 00       	call   4ff6 <exit>
  }
  if(buf[0] != 'h'){
    2658:	0f b6 05 20 9d 00 00 	movzbl 0x9d20,%eax
    265f:	3c 68                	cmp    $0x68,%al
    2661:	74 17                	je     267a <unlinkread+0x15e>
    printf(1, "unlinkread wrong data\n");
    2663:	83 ec 08             	sub    $0x8,%esp
    2666:	68 f6 5c 00 00       	push   $0x5cf6
    266b:	6a 01                	push   $0x1
    266d:	e8 0b 2b 00 00       	call   517d <printf>
    2672:	83 c4 10             	add    $0x10,%esp
    exit();
    2675:	e8 7c 29 00 00       	call   4ff6 <exit>
  }
  if(write(fd, buf, 10) != 10){
    267a:	83 ec 04             	sub    $0x4,%esp
    267d:	6a 0a                	push   $0xa
    267f:	68 20 9d 00 00       	push   $0x9d20
    2684:	ff 75 f4             	pushl  -0xc(%ebp)
    2687:	e8 8a 29 00 00       	call   5016 <write>
    268c:	83 c4 10             	add    $0x10,%esp
    268f:	83 f8 0a             	cmp    $0xa,%eax
    2692:	74 17                	je     26ab <unlinkread+0x18f>
    printf(1, "unlinkread write failed\n");
    2694:	83 ec 08             	sub    $0x8,%esp
    2697:	68 0d 5d 00 00       	push   $0x5d0d
    269c:	6a 01                	push   $0x1
    269e:	e8 da 2a 00 00       	call   517d <printf>
    26a3:	83 c4 10             	add    $0x10,%esp
    exit();
    26a6:	e8 4b 29 00 00       	call   4ff6 <exit>
  }
  close(fd);
    26ab:	83 ec 0c             	sub    $0xc,%esp
    26ae:	ff 75 f4             	pushl  -0xc(%ebp)
    26b1:	e8 68 29 00 00       	call   501e <close>
    26b6:	83 c4 10             	add    $0x10,%esp
  unlink("unlinkread");
    26b9:	83 ec 0c             	sub    $0xc,%esp
    26bc:	68 7e 5c 00 00       	push   $0x5c7e
    26c1:	e8 80 29 00 00       	call   5046 <unlink>
    26c6:	83 c4 10             	add    $0x10,%esp
  printf(1, "unlinkread ok\n");
    26c9:	83 ec 08             	sub    $0x8,%esp
    26cc:	68 26 5d 00 00       	push   $0x5d26
    26d1:	6a 01                	push   $0x1
    26d3:	e8 a5 2a 00 00       	call   517d <printf>
    26d8:	83 c4 10             	add    $0x10,%esp
}
    26db:	90                   	nop
    26dc:	c9                   	leave  
    26dd:	c3                   	ret    

000026de <linktest>:

void
linktest(void)
{
    26de:	55                   	push   %ebp
    26df:	89 e5                	mov    %esp,%ebp
    26e1:	83 ec 18             	sub    $0x18,%esp
  int fd;

  printf(1, "linktest\n");
    26e4:	83 ec 08             	sub    $0x8,%esp
    26e7:	68 35 5d 00 00       	push   $0x5d35
    26ec:	6a 01                	push   $0x1
    26ee:	e8 8a 2a 00 00       	call   517d <printf>
    26f3:	83 c4 10             	add    $0x10,%esp

  unlink("lf1");
    26f6:	83 ec 0c             	sub    $0xc,%esp
    26f9:	68 3f 5d 00 00       	push   $0x5d3f
    26fe:	e8 43 29 00 00       	call   5046 <unlink>
    2703:	83 c4 10             	add    $0x10,%esp
  unlink("lf2");
    2706:	83 ec 0c             	sub    $0xc,%esp
    2709:	68 43 5d 00 00       	push   $0x5d43
    270e:	e8 33 29 00 00       	call   5046 <unlink>
    2713:	83 c4 10             	add    $0x10,%esp

  fd = open("lf1", O_CREATE|O_RDWR);
    2716:	83 ec 08             	sub    $0x8,%esp
    2719:	68 02 02 00 00       	push   $0x202
    271e:	68 3f 5d 00 00       	push   $0x5d3f
    2723:	e8 0e 29 00 00       	call   5036 <open>
    2728:	83 c4 10             	add    $0x10,%esp
    272b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    272e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2732:	79 17                	jns    274b <linktest+0x6d>
    printf(1, "create lf1 failed\n");
    2734:	83 ec 08             	sub    $0x8,%esp
    2737:	68 47 5d 00 00       	push   $0x5d47
    273c:	6a 01                	push   $0x1
    273e:	e8 3a 2a 00 00       	call   517d <printf>
    2743:	83 c4 10             	add    $0x10,%esp
    exit();
    2746:	e8 ab 28 00 00       	call   4ff6 <exit>
  }
  if(write(fd, "hello", 5) != 5){
    274b:	83 ec 04             	sub    $0x4,%esp
    274e:	6a 05                	push   $0x5
    2750:	68 a3 5c 00 00       	push   $0x5ca3
    2755:	ff 75 f4             	pushl  -0xc(%ebp)
    2758:	e8 b9 28 00 00       	call   5016 <write>
    275d:	83 c4 10             	add    $0x10,%esp
    2760:	83 f8 05             	cmp    $0x5,%eax
    2763:	74 17                	je     277c <linktest+0x9e>
    printf(1, "write lf1 failed\n");
    2765:	83 ec 08             	sub    $0x8,%esp
    2768:	68 5a 5d 00 00       	push   $0x5d5a
    276d:	6a 01                	push   $0x1
    276f:	e8 09 2a 00 00       	call   517d <printf>
    2774:	83 c4 10             	add    $0x10,%esp
    exit();
    2777:	e8 7a 28 00 00       	call   4ff6 <exit>
  }
  close(fd);
    277c:	83 ec 0c             	sub    $0xc,%esp
    277f:	ff 75 f4             	pushl  -0xc(%ebp)
    2782:	e8 97 28 00 00       	call   501e <close>
    2787:	83 c4 10             	add    $0x10,%esp

  if(link("lf1", "lf2") < 0){
    278a:	83 ec 08             	sub    $0x8,%esp
    278d:	68 43 5d 00 00       	push   $0x5d43
    2792:	68 3f 5d 00 00       	push   $0x5d3f
    2797:	e8 ba 28 00 00       	call   5056 <link>
    279c:	83 c4 10             	add    $0x10,%esp
    279f:	85 c0                	test   %eax,%eax
    27a1:	79 17                	jns    27ba <linktest+0xdc>
    printf(1, "link lf1 lf2 failed\n");
    27a3:	83 ec 08             	sub    $0x8,%esp
    27a6:	68 6c 5d 00 00       	push   $0x5d6c
    27ab:	6a 01                	push   $0x1
    27ad:	e8 cb 29 00 00       	call   517d <printf>
    27b2:	83 c4 10             	add    $0x10,%esp
    exit();
    27b5:	e8 3c 28 00 00       	call   4ff6 <exit>
  }
  unlink("lf1");
    27ba:	83 ec 0c             	sub    $0xc,%esp
    27bd:	68 3f 5d 00 00       	push   $0x5d3f
    27c2:	e8 7f 28 00 00       	call   5046 <unlink>
    27c7:	83 c4 10             	add    $0x10,%esp

  if(open("lf1", 0) >= 0){
    27ca:	83 ec 08             	sub    $0x8,%esp
    27cd:	6a 00                	push   $0x0
    27cf:	68 3f 5d 00 00       	push   $0x5d3f
    27d4:	e8 5d 28 00 00       	call   5036 <open>
    27d9:	83 c4 10             	add    $0x10,%esp
    27dc:	85 c0                	test   %eax,%eax
    27de:	78 17                	js     27f7 <linktest+0x119>
    printf(1, "unlinked lf1 but it is still there!\n");
    27e0:	83 ec 08             	sub    $0x8,%esp
    27e3:	68 84 5d 00 00       	push   $0x5d84
    27e8:	6a 01                	push   $0x1
    27ea:	e8 8e 29 00 00       	call   517d <printf>
    27ef:	83 c4 10             	add    $0x10,%esp
    exit();
    27f2:	e8 ff 27 00 00       	call   4ff6 <exit>
  }

  fd = open("lf2", 0);
    27f7:	83 ec 08             	sub    $0x8,%esp
    27fa:	6a 00                	push   $0x0
    27fc:	68 43 5d 00 00       	push   $0x5d43
    2801:	e8 30 28 00 00       	call   5036 <open>
    2806:	83 c4 10             	add    $0x10,%esp
    2809:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    280c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2810:	79 17                	jns    2829 <linktest+0x14b>
    printf(1, "open lf2 failed\n");
    2812:	83 ec 08             	sub    $0x8,%esp
    2815:	68 a9 5d 00 00       	push   $0x5da9
    281a:	6a 01                	push   $0x1
    281c:	e8 5c 29 00 00       	call   517d <printf>
    2821:	83 c4 10             	add    $0x10,%esp
    exit();
    2824:	e8 cd 27 00 00       	call   4ff6 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    2829:	83 ec 04             	sub    $0x4,%esp
    282c:	68 00 20 00 00       	push   $0x2000
    2831:	68 20 9d 00 00       	push   $0x9d20
    2836:	ff 75 f4             	pushl  -0xc(%ebp)
    2839:	e8 d0 27 00 00       	call   500e <read>
    283e:	83 c4 10             	add    $0x10,%esp
    2841:	83 f8 05             	cmp    $0x5,%eax
    2844:	74 17                	je     285d <linktest+0x17f>
    printf(1, "read lf2 failed\n");
    2846:	83 ec 08             	sub    $0x8,%esp
    2849:	68 ba 5d 00 00       	push   $0x5dba
    284e:	6a 01                	push   $0x1
    2850:	e8 28 29 00 00       	call   517d <printf>
    2855:	83 c4 10             	add    $0x10,%esp
    exit();
    2858:	e8 99 27 00 00       	call   4ff6 <exit>
  }
  close(fd);
    285d:	83 ec 0c             	sub    $0xc,%esp
    2860:	ff 75 f4             	pushl  -0xc(%ebp)
    2863:	e8 b6 27 00 00       	call   501e <close>
    2868:	83 c4 10             	add    $0x10,%esp

  if(link("lf2", "lf2") >= 0){
    286b:	83 ec 08             	sub    $0x8,%esp
    286e:	68 43 5d 00 00       	push   $0x5d43
    2873:	68 43 5d 00 00       	push   $0x5d43
    2878:	e8 d9 27 00 00       	call   5056 <link>
    287d:	83 c4 10             	add    $0x10,%esp
    2880:	85 c0                	test   %eax,%eax
    2882:	78 17                	js     289b <linktest+0x1bd>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    2884:	83 ec 08             	sub    $0x8,%esp
    2887:	68 cb 5d 00 00       	push   $0x5dcb
    288c:	6a 01                	push   $0x1
    288e:	e8 ea 28 00 00       	call   517d <printf>
    2893:	83 c4 10             	add    $0x10,%esp
    exit();
    2896:	e8 5b 27 00 00       	call   4ff6 <exit>
  }

  unlink("lf2");
    289b:	83 ec 0c             	sub    $0xc,%esp
    289e:	68 43 5d 00 00       	push   $0x5d43
    28a3:	e8 9e 27 00 00       	call   5046 <unlink>
    28a8:	83 c4 10             	add    $0x10,%esp
  if(link("lf2", "lf1") >= 0){
    28ab:	83 ec 08             	sub    $0x8,%esp
    28ae:	68 3f 5d 00 00       	push   $0x5d3f
    28b3:	68 43 5d 00 00       	push   $0x5d43
    28b8:	e8 99 27 00 00       	call   5056 <link>
    28bd:	83 c4 10             	add    $0x10,%esp
    28c0:	85 c0                	test   %eax,%eax
    28c2:	78 17                	js     28db <linktest+0x1fd>
    printf(1, "link non-existant succeeded! oops\n");
    28c4:	83 ec 08             	sub    $0x8,%esp
    28c7:	68 ec 5d 00 00       	push   $0x5dec
    28cc:	6a 01                	push   $0x1
    28ce:	e8 aa 28 00 00       	call   517d <printf>
    28d3:	83 c4 10             	add    $0x10,%esp
    exit();
    28d6:	e8 1b 27 00 00       	call   4ff6 <exit>
  }

  if(link(".", "lf1") >= 0){
    28db:	83 ec 08             	sub    $0x8,%esp
    28de:	68 3f 5d 00 00       	push   $0x5d3f
    28e3:	68 0f 5e 00 00       	push   $0x5e0f
    28e8:	e8 69 27 00 00       	call   5056 <link>
    28ed:	83 c4 10             	add    $0x10,%esp
    28f0:	85 c0                	test   %eax,%eax
    28f2:	78 17                	js     290b <linktest+0x22d>
    printf(1, "link . lf1 succeeded! oops\n");
    28f4:	83 ec 08             	sub    $0x8,%esp
    28f7:	68 11 5e 00 00       	push   $0x5e11
    28fc:	6a 01                	push   $0x1
    28fe:	e8 7a 28 00 00       	call   517d <printf>
    2903:	83 c4 10             	add    $0x10,%esp
    exit();
    2906:	e8 eb 26 00 00       	call   4ff6 <exit>
  }

  printf(1, "linktest ok\n");
    290b:	83 ec 08             	sub    $0x8,%esp
    290e:	68 2d 5e 00 00       	push   $0x5e2d
    2913:	6a 01                	push   $0x1
    2915:	e8 63 28 00 00       	call   517d <printf>
    291a:	83 c4 10             	add    $0x10,%esp
}
    291d:	90                   	nop
    291e:	c9                   	leave  
    291f:	c3                   	ret    

00002920 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    2920:	55                   	push   %ebp
    2921:	89 e5                	mov    %esp,%ebp
    2923:	83 ec 58             	sub    $0x58,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    2926:	83 ec 08             	sub    $0x8,%esp
    2929:	68 3a 5e 00 00       	push   $0x5e3a
    292e:	6a 01                	push   $0x1
    2930:	e8 48 28 00 00       	call   517d <printf>
    2935:	83 c4 10             	add    $0x10,%esp
  file[0] = 'C';
    2938:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    293c:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    2940:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2947:	e9 fc 00 00 00       	jmp    2a48 <concreate+0x128>
    file[1] = '0' + i;
    294c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    294f:	83 c0 30             	add    $0x30,%eax
    2952:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    2955:	83 ec 0c             	sub    $0xc,%esp
    2958:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    295b:	50                   	push   %eax
    295c:	e8 e5 26 00 00       	call   5046 <unlink>
    2961:	83 c4 10             	add    $0x10,%esp
    pid = fork();
    2964:	e8 85 26 00 00       	call   4fee <fork>
    2969:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    296c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2970:	74 3b                	je     29ad <concreate+0x8d>
    2972:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    2975:	ba 56 55 55 55       	mov    $0x55555556,%edx
    297a:	89 c8                	mov    %ecx,%eax
    297c:	f7 ea                	imul   %edx
    297e:	89 c8                	mov    %ecx,%eax
    2980:	c1 f8 1f             	sar    $0x1f,%eax
    2983:	29 c2                	sub    %eax,%edx
    2985:	89 d0                	mov    %edx,%eax
    2987:	01 c0                	add    %eax,%eax
    2989:	01 d0                	add    %edx,%eax
    298b:	29 c1                	sub    %eax,%ecx
    298d:	89 ca                	mov    %ecx,%edx
    298f:	83 fa 01             	cmp    $0x1,%edx
    2992:	75 19                	jne    29ad <concreate+0x8d>
      link("C0", file);
    2994:	83 ec 08             	sub    $0x8,%esp
    2997:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    299a:	50                   	push   %eax
    299b:	68 4a 5e 00 00       	push   $0x5e4a
    29a0:	e8 b1 26 00 00       	call   5056 <link>
    29a5:	83 c4 10             	add    $0x10,%esp
    29a8:	e9 87 00 00 00       	jmp    2a34 <concreate+0x114>
    } else if(pid == 0 && (i % 5) == 1){
    29ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    29b1:	75 3b                	jne    29ee <concreate+0xce>
    29b3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    29b6:	ba 67 66 66 66       	mov    $0x66666667,%edx
    29bb:	89 c8                	mov    %ecx,%eax
    29bd:	f7 ea                	imul   %edx
    29bf:	d1 fa                	sar    %edx
    29c1:	89 c8                	mov    %ecx,%eax
    29c3:	c1 f8 1f             	sar    $0x1f,%eax
    29c6:	29 c2                	sub    %eax,%edx
    29c8:	89 d0                	mov    %edx,%eax
    29ca:	c1 e0 02             	shl    $0x2,%eax
    29cd:	01 d0                	add    %edx,%eax
    29cf:	29 c1                	sub    %eax,%ecx
    29d1:	89 ca                	mov    %ecx,%edx
    29d3:	83 fa 01             	cmp    $0x1,%edx
    29d6:	75 16                	jne    29ee <concreate+0xce>
      link("C0", file);
    29d8:	83 ec 08             	sub    $0x8,%esp
    29db:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    29de:	50                   	push   %eax
    29df:	68 4a 5e 00 00       	push   $0x5e4a
    29e4:	e8 6d 26 00 00       	call   5056 <link>
    29e9:	83 c4 10             	add    $0x10,%esp
    29ec:	eb 46                	jmp    2a34 <concreate+0x114>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    29ee:	83 ec 08             	sub    $0x8,%esp
    29f1:	68 02 02 00 00       	push   $0x202
    29f6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    29f9:	50                   	push   %eax
    29fa:	e8 37 26 00 00       	call   5036 <open>
    29ff:	83 c4 10             	add    $0x10,%esp
    2a02:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    2a05:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2a09:	79 1b                	jns    2a26 <concreate+0x106>
        printf(1, "concreate create %s failed\n", file);
    2a0b:	83 ec 04             	sub    $0x4,%esp
    2a0e:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2a11:	50                   	push   %eax
    2a12:	68 4d 5e 00 00       	push   $0x5e4d
    2a17:	6a 01                	push   $0x1
    2a19:	e8 5f 27 00 00       	call   517d <printf>
    2a1e:	83 c4 10             	add    $0x10,%esp
        exit();
    2a21:	e8 d0 25 00 00       	call   4ff6 <exit>
      }
      close(fd);
    2a26:	83 ec 0c             	sub    $0xc,%esp
    2a29:	ff 75 e8             	pushl  -0x18(%ebp)
    2a2c:	e8 ed 25 00 00       	call   501e <close>
    2a31:	83 c4 10             	add    $0x10,%esp
    }
    if(pid == 0)
    2a34:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2a38:	75 05                	jne    2a3f <concreate+0x11f>
      exit();
    2a3a:	e8 b7 25 00 00       	call   4ff6 <exit>
    else
      wait();
    2a3f:	e8 ba 25 00 00       	call   4ffe <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    2a44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2a48:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    2a4c:	0f 8e fa fe ff ff    	jle    294c <concreate+0x2c>
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    2a52:	83 ec 04             	sub    $0x4,%esp
    2a55:	6a 28                	push   $0x28
    2a57:	6a 00                	push   $0x0
    2a59:	8d 45 bd             	lea    -0x43(%ebp),%eax
    2a5c:	50                   	push   %eax
    2a5d:	e8 f9 23 00 00       	call   4e5b <memset>
    2a62:	83 c4 10             	add    $0x10,%esp
  fd = open(".", 0);
    2a65:	83 ec 08             	sub    $0x8,%esp
    2a68:	6a 00                	push   $0x0
    2a6a:	68 0f 5e 00 00       	push   $0x5e0f
    2a6f:	e8 c2 25 00 00       	call   5036 <open>
    2a74:	83 c4 10             	add    $0x10,%esp
    2a77:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    2a7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    2a81:	e9 93 00 00 00       	jmp    2b19 <concreate+0x1f9>
    if(de.inum == 0)
    2a86:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    2a8a:	66 85 c0             	test   %ax,%ax
    2a8d:	75 05                	jne    2a94 <concreate+0x174>
      continue;
    2a8f:	e9 85 00 00 00       	jmp    2b19 <concreate+0x1f9>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2a94:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    2a98:	3c 43                	cmp    $0x43,%al
    2a9a:	75 7d                	jne    2b19 <concreate+0x1f9>
    2a9c:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    2aa0:	84 c0                	test   %al,%al
    2aa2:	75 75                	jne    2b19 <concreate+0x1f9>
      i = de.name[1] - '0';
    2aa4:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    2aa8:	0f be c0             	movsbl %al,%eax
    2aab:	83 e8 30             	sub    $0x30,%eax
    2aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    2ab1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2ab5:	78 08                	js     2abf <concreate+0x19f>
    2ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2aba:	83 f8 27             	cmp    $0x27,%eax
    2abd:	76 1e                	jbe    2add <concreate+0x1bd>
        printf(1, "concreate weird file %s\n", de.name);
    2abf:	83 ec 04             	sub    $0x4,%esp
    2ac2:	8d 45 ac             	lea    -0x54(%ebp),%eax
    2ac5:	83 c0 02             	add    $0x2,%eax
    2ac8:	50                   	push   %eax
    2ac9:	68 69 5e 00 00       	push   $0x5e69
    2ace:	6a 01                	push   $0x1
    2ad0:	e8 a8 26 00 00       	call   517d <printf>
    2ad5:	83 c4 10             	add    $0x10,%esp
        exit();
    2ad8:	e8 19 25 00 00       	call   4ff6 <exit>
      }
      if(fa[i]){
    2add:	8d 55 bd             	lea    -0x43(%ebp),%edx
    2ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ae3:	01 d0                	add    %edx,%eax
    2ae5:	0f b6 00             	movzbl (%eax),%eax
    2ae8:	84 c0                	test   %al,%al
    2aea:	74 1e                	je     2b0a <concreate+0x1ea>
        printf(1, "concreate duplicate file %s\n", de.name);
    2aec:	83 ec 04             	sub    $0x4,%esp
    2aef:	8d 45 ac             	lea    -0x54(%ebp),%eax
    2af2:	83 c0 02             	add    $0x2,%eax
    2af5:	50                   	push   %eax
    2af6:	68 82 5e 00 00       	push   $0x5e82
    2afb:	6a 01                	push   $0x1
    2afd:	e8 7b 26 00 00       	call   517d <printf>
    2b02:	83 c4 10             	add    $0x10,%esp
        exit();
    2b05:	e8 ec 24 00 00       	call   4ff6 <exit>
      }
      fa[i] = 1;
    2b0a:	8d 55 bd             	lea    -0x43(%ebp),%edx
    2b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2b10:	01 d0                	add    %edx,%eax
    2b12:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    2b15:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    2b19:	83 ec 04             	sub    $0x4,%esp
    2b1c:	6a 10                	push   $0x10
    2b1e:	8d 45 ac             	lea    -0x54(%ebp),%eax
    2b21:	50                   	push   %eax
    2b22:	ff 75 e8             	pushl  -0x18(%ebp)
    2b25:	e8 e4 24 00 00       	call   500e <read>
    2b2a:	83 c4 10             	add    $0x10,%esp
    2b2d:	85 c0                	test   %eax,%eax
    2b2f:	0f 8f 51 ff ff ff    	jg     2a86 <concreate+0x166>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    2b35:	83 ec 0c             	sub    $0xc,%esp
    2b38:	ff 75 e8             	pushl  -0x18(%ebp)
    2b3b:	e8 de 24 00 00       	call   501e <close>
    2b40:	83 c4 10             	add    $0x10,%esp

  if(n != 40){
    2b43:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    2b47:	74 17                	je     2b60 <concreate+0x240>
    printf(1, "concreate not enough files in directory listing\n");
    2b49:	83 ec 08             	sub    $0x8,%esp
    2b4c:	68 a0 5e 00 00       	push   $0x5ea0
    2b51:	6a 01                	push   $0x1
    2b53:	e8 25 26 00 00       	call   517d <printf>
    2b58:	83 c4 10             	add    $0x10,%esp
    exit();
    2b5b:	e8 96 24 00 00       	call   4ff6 <exit>
  }

  for(i = 0; i < 40; i++){
    2b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2b67:	e9 45 01 00 00       	jmp    2cb1 <concreate+0x391>
    file[1] = '0' + i;
    2b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2b6f:	83 c0 30             	add    $0x30,%eax
    2b72:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    2b75:	e8 74 24 00 00       	call   4fee <fork>
    2b7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    2b7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2b81:	79 17                	jns    2b9a <concreate+0x27a>
      printf(1, "fork failed\n");
    2b83:	83 ec 08             	sub    $0x8,%esp
    2b86:	68 25 56 00 00       	push   $0x5625
    2b8b:	6a 01                	push   $0x1
    2b8d:	e8 eb 25 00 00       	call   517d <printf>
    2b92:	83 c4 10             	add    $0x10,%esp
      exit();
    2b95:	e8 5c 24 00 00       	call   4ff6 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    2b9a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    2b9d:	ba 56 55 55 55       	mov    $0x55555556,%edx
    2ba2:	89 c8                	mov    %ecx,%eax
    2ba4:	f7 ea                	imul   %edx
    2ba6:	89 c8                	mov    %ecx,%eax
    2ba8:	c1 f8 1f             	sar    $0x1f,%eax
    2bab:	29 c2                	sub    %eax,%edx
    2bad:	89 d0                	mov    %edx,%eax
    2baf:	89 c2                	mov    %eax,%edx
    2bb1:	01 d2                	add    %edx,%edx
    2bb3:	01 c2                	add    %eax,%edx
    2bb5:	89 c8                	mov    %ecx,%eax
    2bb7:	29 d0                	sub    %edx,%eax
    2bb9:	85 c0                	test   %eax,%eax
    2bbb:	75 06                	jne    2bc3 <concreate+0x2a3>
    2bbd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2bc1:	74 28                	je     2beb <concreate+0x2cb>
       ((i % 3) == 1 && pid != 0)){
    2bc3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    2bc6:	ba 56 55 55 55       	mov    $0x55555556,%edx
    2bcb:	89 c8                	mov    %ecx,%eax
    2bcd:	f7 ea                	imul   %edx
    2bcf:	89 c8                	mov    %ecx,%eax
    2bd1:	c1 f8 1f             	sar    $0x1f,%eax
    2bd4:	29 c2                	sub    %eax,%edx
    2bd6:	89 d0                	mov    %edx,%eax
    2bd8:	01 c0                	add    %eax,%eax
    2bda:	01 d0                	add    %edx,%eax
    2bdc:	29 c1                	sub    %eax,%ecx
    2bde:	89 ca                	mov    %ecx,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    2be0:	83 fa 01             	cmp    $0x1,%edx
    2be3:	75 7c                	jne    2c61 <concreate+0x341>
       ((i % 3) == 1 && pid != 0)){
    2be5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2be9:	74 76                	je     2c61 <concreate+0x341>
      close(open(file, 0));
    2beb:	83 ec 08             	sub    $0x8,%esp
    2bee:	6a 00                	push   $0x0
    2bf0:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2bf3:	50                   	push   %eax
    2bf4:	e8 3d 24 00 00       	call   5036 <open>
    2bf9:	83 c4 10             	add    $0x10,%esp
    2bfc:	83 ec 0c             	sub    $0xc,%esp
    2bff:	50                   	push   %eax
    2c00:	e8 19 24 00 00       	call   501e <close>
    2c05:	83 c4 10             	add    $0x10,%esp
      close(open(file, 0));
    2c08:	83 ec 08             	sub    $0x8,%esp
    2c0b:	6a 00                	push   $0x0
    2c0d:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c10:	50                   	push   %eax
    2c11:	e8 20 24 00 00       	call   5036 <open>
    2c16:	83 c4 10             	add    $0x10,%esp
    2c19:	83 ec 0c             	sub    $0xc,%esp
    2c1c:	50                   	push   %eax
    2c1d:	e8 fc 23 00 00       	call   501e <close>
    2c22:	83 c4 10             	add    $0x10,%esp
      close(open(file, 0));
    2c25:	83 ec 08             	sub    $0x8,%esp
    2c28:	6a 00                	push   $0x0
    2c2a:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c2d:	50                   	push   %eax
    2c2e:	e8 03 24 00 00       	call   5036 <open>
    2c33:	83 c4 10             	add    $0x10,%esp
    2c36:	83 ec 0c             	sub    $0xc,%esp
    2c39:	50                   	push   %eax
    2c3a:	e8 df 23 00 00       	call   501e <close>
    2c3f:	83 c4 10             	add    $0x10,%esp
      close(open(file, 0));
    2c42:	83 ec 08             	sub    $0x8,%esp
    2c45:	6a 00                	push   $0x0
    2c47:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c4a:	50                   	push   %eax
    2c4b:	e8 e6 23 00 00       	call   5036 <open>
    2c50:	83 c4 10             	add    $0x10,%esp
    2c53:	83 ec 0c             	sub    $0xc,%esp
    2c56:	50                   	push   %eax
    2c57:	e8 c2 23 00 00       	call   501e <close>
    2c5c:	83 c4 10             	add    $0x10,%esp
    2c5f:	eb 3c                	jmp    2c9d <concreate+0x37d>
    } else {
      unlink(file);
    2c61:	83 ec 0c             	sub    $0xc,%esp
    2c64:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c67:	50                   	push   %eax
    2c68:	e8 d9 23 00 00       	call   5046 <unlink>
    2c6d:	83 c4 10             	add    $0x10,%esp
      unlink(file);
    2c70:	83 ec 0c             	sub    $0xc,%esp
    2c73:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c76:	50                   	push   %eax
    2c77:	e8 ca 23 00 00       	call   5046 <unlink>
    2c7c:	83 c4 10             	add    $0x10,%esp
      unlink(file);
    2c7f:	83 ec 0c             	sub    $0xc,%esp
    2c82:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c85:	50                   	push   %eax
    2c86:	e8 bb 23 00 00       	call   5046 <unlink>
    2c8b:	83 c4 10             	add    $0x10,%esp
      unlink(file);
    2c8e:	83 ec 0c             	sub    $0xc,%esp
    2c91:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    2c94:	50                   	push   %eax
    2c95:	e8 ac 23 00 00       	call   5046 <unlink>
    2c9a:	83 c4 10             	add    $0x10,%esp
    }
    if(pid == 0)
    2c9d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2ca1:	75 05                	jne    2ca8 <concreate+0x388>
      exit();
    2ca3:	e8 4e 23 00 00       	call   4ff6 <exit>
    else
      wait();
    2ca8:	e8 51 23 00 00       	call   4ffe <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    2cad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2cb1:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    2cb5:	0f 8e b1 fe ff ff    	jle    2b6c <concreate+0x24c>
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    2cbb:	83 ec 08             	sub    $0x8,%esp
    2cbe:	68 d1 5e 00 00       	push   $0x5ed1
    2cc3:	6a 01                	push   $0x1
    2cc5:	e8 b3 24 00 00       	call   517d <printf>
    2cca:	83 c4 10             	add    $0x10,%esp
}
    2ccd:	90                   	nop
    2cce:	c9                   	leave  
    2ccf:	c3                   	ret    

00002cd0 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    2cd0:	55                   	push   %ebp
    2cd1:	89 e5                	mov    %esp,%ebp
    2cd3:	83 ec 18             	sub    $0x18,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    2cd6:	83 ec 08             	sub    $0x8,%esp
    2cd9:	68 df 5e 00 00       	push   $0x5edf
    2cde:	6a 01                	push   $0x1
    2ce0:	e8 98 24 00 00       	call   517d <printf>
    2ce5:	83 c4 10             	add    $0x10,%esp

  unlink("x");
    2ce8:	83 ec 0c             	sub    $0xc,%esp
    2ceb:	68 5b 5a 00 00       	push   $0x5a5b
    2cf0:	e8 51 23 00 00       	call   5046 <unlink>
    2cf5:	83 c4 10             	add    $0x10,%esp
  pid = fork();
    2cf8:	e8 f1 22 00 00       	call   4fee <fork>
    2cfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    2d00:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2d04:	79 17                	jns    2d1d <linkunlink+0x4d>
    printf(1, "fork failed\n");
    2d06:	83 ec 08             	sub    $0x8,%esp
    2d09:	68 25 56 00 00       	push   $0x5625
    2d0e:	6a 01                	push   $0x1
    2d10:	e8 68 24 00 00       	call   517d <printf>
    2d15:	83 c4 10             	add    $0x10,%esp
    exit();
    2d18:	e8 d9 22 00 00       	call   4ff6 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    2d1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2d21:	74 07                	je     2d2a <linkunlink+0x5a>
    2d23:	b8 01 00 00 00       	mov    $0x1,%eax
    2d28:	eb 05                	jmp    2d2f <linkunlink+0x5f>
    2d2a:	b8 61 00 00 00       	mov    $0x61,%eax
    2d2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    2d32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2d39:	e9 9a 00 00 00       	jmp    2dd8 <linkunlink+0x108>
    x = x * 1103515245 + 12345;
    2d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2d41:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    2d47:	05 39 30 00 00       	add    $0x3039,%eax
    2d4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    2d4f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    2d52:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    2d57:	89 c8                	mov    %ecx,%eax
    2d59:	f7 e2                	mul    %edx
    2d5b:	89 d0                	mov    %edx,%eax
    2d5d:	d1 e8                	shr    %eax
    2d5f:	89 c2                	mov    %eax,%edx
    2d61:	01 d2                	add    %edx,%edx
    2d63:	01 c2                	add    %eax,%edx
    2d65:	89 c8                	mov    %ecx,%eax
    2d67:	29 d0                	sub    %edx,%eax
    2d69:	85 c0                	test   %eax,%eax
    2d6b:	75 23                	jne    2d90 <linkunlink+0xc0>
      close(open("x", O_RDWR | O_CREATE));
    2d6d:	83 ec 08             	sub    $0x8,%esp
    2d70:	68 02 02 00 00       	push   $0x202
    2d75:	68 5b 5a 00 00       	push   $0x5a5b
    2d7a:	e8 b7 22 00 00       	call   5036 <open>
    2d7f:	83 c4 10             	add    $0x10,%esp
    2d82:	83 ec 0c             	sub    $0xc,%esp
    2d85:	50                   	push   %eax
    2d86:	e8 93 22 00 00       	call   501e <close>
    2d8b:	83 c4 10             	add    $0x10,%esp
    2d8e:	eb 44                	jmp    2dd4 <linkunlink+0x104>
    } else if((x % 3) == 1){
    2d90:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    2d93:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    2d98:	89 c8                	mov    %ecx,%eax
    2d9a:	f7 e2                	mul    %edx
    2d9c:	d1 ea                	shr    %edx
    2d9e:	89 d0                	mov    %edx,%eax
    2da0:	01 c0                	add    %eax,%eax
    2da2:	01 d0                	add    %edx,%eax
    2da4:	29 c1                	sub    %eax,%ecx
    2da6:	89 ca                	mov    %ecx,%edx
    2da8:	83 fa 01             	cmp    $0x1,%edx
    2dab:	75 17                	jne    2dc4 <linkunlink+0xf4>
      link("cat", "x");
    2dad:	83 ec 08             	sub    $0x8,%esp
    2db0:	68 5b 5a 00 00       	push   $0x5a5b
    2db5:	68 f0 5e 00 00       	push   $0x5ef0
    2dba:	e8 97 22 00 00       	call   5056 <link>
    2dbf:	83 c4 10             	add    $0x10,%esp
    2dc2:	eb 10                	jmp    2dd4 <linkunlink+0x104>
    } else {
      unlink("x");
    2dc4:	83 ec 0c             	sub    $0xc,%esp
    2dc7:	68 5b 5a 00 00       	push   $0x5a5b
    2dcc:	e8 75 22 00 00       	call   5046 <unlink>
    2dd1:	83 c4 10             	add    $0x10,%esp
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    2dd4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2dd8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    2ddc:	0f 8e 5c ff ff ff    	jle    2d3e <linkunlink+0x6e>
    } else {
      unlink("x");
    }
  }

  if(pid)
    2de2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2de6:	74 07                	je     2def <linkunlink+0x11f>
    wait();
    2de8:	e8 11 22 00 00       	call   4ffe <wait>
    2ded:	eb 05                	jmp    2df4 <linkunlink+0x124>
  else
    exit();
    2def:	e8 02 22 00 00       	call   4ff6 <exit>

  printf(1, "linkunlink ok\n");
    2df4:	83 ec 08             	sub    $0x8,%esp
    2df7:	68 f4 5e 00 00       	push   $0x5ef4
    2dfc:	6a 01                	push   $0x1
    2dfe:	e8 7a 23 00 00       	call   517d <printf>
    2e03:	83 c4 10             	add    $0x10,%esp
}
    2e06:	90                   	nop
    2e07:	c9                   	leave  
    2e08:	c3                   	ret    

00002e09 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    2e09:	55                   	push   %ebp
    2e0a:	89 e5                	mov    %esp,%ebp
    2e0c:	83 ec 28             	sub    $0x28,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    2e0f:	83 ec 08             	sub    $0x8,%esp
    2e12:	68 03 5f 00 00       	push   $0x5f03
    2e17:	6a 01                	push   $0x1
    2e19:	e8 5f 23 00 00       	call   517d <printf>
    2e1e:	83 c4 10             	add    $0x10,%esp
  unlink("bd");
    2e21:	83 ec 0c             	sub    $0xc,%esp
    2e24:	68 10 5f 00 00       	push   $0x5f10
    2e29:	e8 18 22 00 00       	call   5046 <unlink>
    2e2e:	83 c4 10             	add    $0x10,%esp

  fd = open("bd", O_CREATE);
    2e31:	83 ec 08             	sub    $0x8,%esp
    2e34:	68 00 02 00 00       	push   $0x200
    2e39:	68 10 5f 00 00       	push   $0x5f10
    2e3e:	e8 f3 21 00 00       	call   5036 <open>
    2e43:	83 c4 10             	add    $0x10,%esp
    2e46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    2e49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2e4d:	79 17                	jns    2e66 <bigdir+0x5d>
    printf(1, "bigdir create failed\n");
    2e4f:	83 ec 08             	sub    $0x8,%esp
    2e52:	68 13 5f 00 00       	push   $0x5f13
    2e57:	6a 01                	push   $0x1
    2e59:	e8 1f 23 00 00       	call   517d <printf>
    2e5e:	83 c4 10             	add    $0x10,%esp
    exit();
    2e61:	e8 90 21 00 00       	call   4ff6 <exit>
  }
  close(fd);
    2e66:	83 ec 0c             	sub    $0xc,%esp
    2e69:	ff 75 f0             	pushl  -0x10(%ebp)
    2e6c:	e8 ad 21 00 00       	call   501e <close>
    2e71:	83 c4 10             	add    $0x10,%esp

  for(i = 0; i < 500; i++){
    2e74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2e7b:	eb 63                	jmp    2ee0 <bigdir+0xd7>
    name[0] = 'x';
    2e7d:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    2e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e84:	8d 50 3f             	lea    0x3f(%eax),%edx
    2e87:	85 c0                	test   %eax,%eax
    2e89:	0f 48 c2             	cmovs  %edx,%eax
    2e8c:	c1 f8 06             	sar    $0x6,%eax
    2e8f:	83 c0 30             	add    $0x30,%eax
    2e92:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    2e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e98:	99                   	cltd   
    2e99:	c1 ea 1a             	shr    $0x1a,%edx
    2e9c:	01 d0                	add    %edx,%eax
    2e9e:	83 e0 3f             	and    $0x3f,%eax
    2ea1:	29 d0                	sub    %edx,%eax
    2ea3:	83 c0 30             	add    $0x30,%eax
    2ea6:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    2ea9:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    2ead:	83 ec 08             	sub    $0x8,%esp
    2eb0:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    2eb3:	50                   	push   %eax
    2eb4:	68 10 5f 00 00       	push   $0x5f10
    2eb9:	e8 98 21 00 00       	call   5056 <link>
    2ebe:	83 c4 10             	add    $0x10,%esp
    2ec1:	85 c0                	test   %eax,%eax
    2ec3:	74 17                	je     2edc <bigdir+0xd3>
      printf(1, "bigdir link failed\n");
    2ec5:	83 ec 08             	sub    $0x8,%esp
    2ec8:	68 29 5f 00 00       	push   $0x5f29
    2ecd:	6a 01                	push   $0x1
    2ecf:	e8 a9 22 00 00       	call   517d <printf>
    2ed4:	83 c4 10             	add    $0x10,%esp
      exit();
    2ed7:	e8 1a 21 00 00       	call   4ff6 <exit>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    2edc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2ee0:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    2ee7:	7e 94                	jle    2e7d <bigdir+0x74>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    2ee9:	83 ec 0c             	sub    $0xc,%esp
    2eec:	68 10 5f 00 00       	push   $0x5f10
    2ef1:	e8 50 21 00 00       	call   5046 <unlink>
    2ef6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 500; i++){
    2ef9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2f00:	eb 5e                	jmp    2f60 <bigdir+0x157>
    name[0] = 'x';
    2f02:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    2f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2f09:	8d 50 3f             	lea    0x3f(%eax),%edx
    2f0c:	85 c0                	test   %eax,%eax
    2f0e:	0f 48 c2             	cmovs  %edx,%eax
    2f11:	c1 f8 06             	sar    $0x6,%eax
    2f14:	83 c0 30             	add    $0x30,%eax
    2f17:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    2f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2f1d:	99                   	cltd   
    2f1e:	c1 ea 1a             	shr    $0x1a,%edx
    2f21:	01 d0                	add    %edx,%eax
    2f23:	83 e0 3f             	and    $0x3f,%eax
    2f26:	29 d0                	sub    %edx,%eax
    2f28:	83 c0 30             	add    $0x30,%eax
    2f2b:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    2f2e:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    2f32:	83 ec 0c             	sub    $0xc,%esp
    2f35:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    2f38:	50                   	push   %eax
    2f39:	e8 08 21 00 00       	call   5046 <unlink>
    2f3e:	83 c4 10             	add    $0x10,%esp
    2f41:	85 c0                	test   %eax,%eax
    2f43:	74 17                	je     2f5c <bigdir+0x153>
      printf(1, "bigdir unlink failed");
    2f45:	83 ec 08             	sub    $0x8,%esp
    2f48:	68 3d 5f 00 00       	push   $0x5f3d
    2f4d:	6a 01                	push   $0x1
    2f4f:	e8 29 22 00 00       	call   517d <printf>
    2f54:	83 c4 10             	add    $0x10,%esp
      exit();
    2f57:	e8 9a 20 00 00       	call   4ff6 <exit>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    2f5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2f60:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    2f67:	7e 99                	jle    2f02 <bigdir+0xf9>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    2f69:	83 ec 08             	sub    $0x8,%esp
    2f6c:	68 52 5f 00 00       	push   $0x5f52
    2f71:	6a 01                	push   $0x1
    2f73:	e8 05 22 00 00       	call   517d <printf>
    2f78:	83 c4 10             	add    $0x10,%esp
}
    2f7b:	90                   	nop
    2f7c:	c9                   	leave  
    2f7d:	c3                   	ret    

00002f7e <subdir>:

void
subdir(void)
{
    2f7e:	55                   	push   %ebp
    2f7f:	89 e5                	mov    %esp,%ebp
    2f81:	83 ec 18             	sub    $0x18,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    2f84:	83 ec 08             	sub    $0x8,%esp
    2f87:	68 5d 5f 00 00       	push   $0x5f5d
    2f8c:	6a 01                	push   $0x1
    2f8e:	e8 ea 21 00 00       	call   517d <printf>
    2f93:	83 c4 10             	add    $0x10,%esp

  unlink("ff");
    2f96:	83 ec 0c             	sub    $0xc,%esp
    2f99:	68 6a 5f 00 00       	push   $0x5f6a
    2f9e:	e8 a3 20 00 00       	call   5046 <unlink>
    2fa3:	83 c4 10             	add    $0x10,%esp
  if(mkdir("dd") != 0){
    2fa6:	83 ec 0c             	sub    $0xc,%esp
    2fa9:	68 6d 5f 00 00       	push   $0x5f6d
    2fae:	e8 ab 20 00 00       	call   505e <mkdir>
    2fb3:	83 c4 10             	add    $0x10,%esp
    2fb6:	85 c0                	test   %eax,%eax
    2fb8:	74 17                	je     2fd1 <subdir+0x53>
    printf(1, "subdir mkdir dd failed\n");
    2fba:	83 ec 08             	sub    $0x8,%esp
    2fbd:	68 70 5f 00 00       	push   $0x5f70
    2fc2:	6a 01                	push   $0x1
    2fc4:	e8 b4 21 00 00       	call   517d <printf>
    2fc9:	83 c4 10             	add    $0x10,%esp
    exit();
    2fcc:	e8 25 20 00 00       	call   4ff6 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    2fd1:	83 ec 08             	sub    $0x8,%esp
    2fd4:	68 02 02 00 00       	push   $0x202
    2fd9:	68 88 5f 00 00       	push   $0x5f88
    2fde:	e8 53 20 00 00       	call   5036 <open>
    2fe3:	83 c4 10             	add    $0x10,%esp
    2fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2fe9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2fed:	79 17                	jns    3006 <subdir+0x88>
    printf(1, "create dd/ff failed\n");
    2fef:	83 ec 08             	sub    $0x8,%esp
    2ff2:	68 8e 5f 00 00       	push   $0x5f8e
    2ff7:	6a 01                	push   $0x1
    2ff9:	e8 7f 21 00 00       	call   517d <printf>
    2ffe:	83 c4 10             	add    $0x10,%esp
    exit();
    3001:	e8 f0 1f 00 00       	call   4ff6 <exit>
  }
  write(fd, "ff", 2);
    3006:	83 ec 04             	sub    $0x4,%esp
    3009:	6a 02                	push   $0x2
    300b:	68 6a 5f 00 00       	push   $0x5f6a
    3010:	ff 75 f4             	pushl  -0xc(%ebp)
    3013:	e8 fe 1f 00 00       	call   5016 <write>
    3018:	83 c4 10             	add    $0x10,%esp
  close(fd);
    301b:	83 ec 0c             	sub    $0xc,%esp
    301e:	ff 75 f4             	pushl  -0xc(%ebp)
    3021:	e8 f8 1f 00 00       	call   501e <close>
    3026:	83 c4 10             	add    $0x10,%esp

  if(unlink("dd") >= 0){
    3029:	83 ec 0c             	sub    $0xc,%esp
    302c:	68 6d 5f 00 00       	push   $0x5f6d
    3031:	e8 10 20 00 00       	call   5046 <unlink>
    3036:	83 c4 10             	add    $0x10,%esp
    3039:	85 c0                	test   %eax,%eax
    303b:	78 17                	js     3054 <subdir+0xd6>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    303d:	83 ec 08             	sub    $0x8,%esp
    3040:	68 a4 5f 00 00       	push   $0x5fa4
    3045:	6a 01                	push   $0x1
    3047:	e8 31 21 00 00       	call   517d <printf>
    304c:	83 c4 10             	add    $0x10,%esp
    exit();
    304f:	e8 a2 1f 00 00       	call   4ff6 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    3054:	83 ec 0c             	sub    $0xc,%esp
    3057:	68 ca 5f 00 00       	push   $0x5fca
    305c:	e8 fd 1f 00 00       	call   505e <mkdir>
    3061:	83 c4 10             	add    $0x10,%esp
    3064:	85 c0                	test   %eax,%eax
    3066:	74 17                	je     307f <subdir+0x101>
    printf(1, "subdir mkdir dd/dd failed\n");
    3068:	83 ec 08             	sub    $0x8,%esp
    306b:	68 d1 5f 00 00       	push   $0x5fd1
    3070:	6a 01                	push   $0x1
    3072:	e8 06 21 00 00       	call   517d <printf>
    3077:	83 c4 10             	add    $0x10,%esp
    exit();
    307a:	e8 77 1f 00 00       	call   4ff6 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    307f:	83 ec 08             	sub    $0x8,%esp
    3082:	68 02 02 00 00       	push   $0x202
    3087:	68 ec 5f 00 00       	push   $0x5fec
    308c:	e8 a5 1f 00 00       	call   5036 <open>
    3091:	83 c4 10             	add    $0x10,%esp
    3094:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    3097:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    309b:	79 17                	jns    30b4 <subdir+0x136>
    printf(1, "create dd/dd/ff failed\n");
    309d:	83 ec 08             	sub    $0x8,%esp
    30a0:	68 f5 5f 00 00       	push   $0x5ff5
    30a5:	6a 01                	push   $0x1
    30a7:	e8 d1 20 00 00       	call   517d <printf>
    30ac:	83 c4 10             	add    $0x10,%esp
    exit();
    30af:	e8 42 1f 00 00       	call   4ff6 <exit>
  }
  write(fd, "FF", 2);
    30b4:	83 ec 04             	sub    $0x4,%esp
    30b7:	6a 02                	push   $0x2
    30b9:	68 0d 60 00 00       	push   $0x600d
    30be:	ff 75 f4             	pushl  -0xc(%ebp)
    30c1:	e8 50 1f 00 00       	call   5016 <write>
    30c6:	83 c4 10             	add    $0x10,%esp
  close(fd);
    30c9:	83 ec 0c             	sub    $0xc,%esp
    30cc:	ff 75 f4             	pushl  -0xc(%ebp)
    30cf:	e8 4a 1f 00 00       	call   501e <close>
    30d4:	83 c4 10             	add    $0x10,%esp

  fd = open("dd/dd/../ff", 0);
    30d7:	83 ec 08             	sub    $0x8,%esp
    30da:	6a 00                	push   $0x0
    30dc:	68 10 60 00 00       	push   $0x6010
    30e1:	e8 50 1f 00 00       	call   5036 <open>
    30e6:	83 c4 10             	add    $0x10,%esp
    30e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    30ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    30f0:	79 17                	jns    3109 <subdir+0x18b>
    printf(1, "open dd/dd/../ff failed\n");
    30f2:	83 ec 08             	sub    $0x8,%esp
    30f5:	68 1c 60 00 00       	push   $0x601c
    30fa:	6a 01                	push   $0x1
    30fc:	e8 7c 20 00 00       	call   517d <printf>
    3101:	83 c4 10             	add    $0x10,%esp
    exit();
    3104:	e8 ed 1e 00 00       	call   4ff6 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    3109:	83 ec 04             	sub    $0x4,%esp
    310c:	68 00 20 00 00       	push   $0x2000
    3111:	68 20 9d 00 00       	push   $0x9d20
    3116:	ff 75 f4             	pushl  -0xc(%ebp)
    3119:	e8 f0 1e 00 00       	call   500e <read>
    311e:	83 c4 10             	add    $0x10,%esp
    3121:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    3124:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    3128:	75 0b                	jne    3135 <subdir+0x1b7>
    312a:	0f b6 05 20 9d 00 00 	movzbl 0x9d20,%eax
    3131:	3c 66                	cmp    $0x66,%al
    3133:	74 17                	je     314c <subdir+0x1ce>
    printf(1, "dd/dd/../ff wrong content\n");
    3135:	83 ec 08             	sub    $0x8,%esp
    3138:	68 35 60 00 00       	push   $0x6035
    313d:	6a 01                	push   $0x1
    313f:	e8 39 20 00 00       	call   517d <printf>
    3144:	83 c4 10             	add    $0x10,%esp
    exit();
    3147:	e8 aa 1e 00 00       	call   4ff6 <exit>
  }
  close(fd);
    314c:	83 ec 0c             	sub    $0xc,%esp
    314f:	ff 75 f4             	pushl  -0xc(%ebp)
    3152:	e8 c7 1e 00 00       	call   501e <close>
    3157:	83 c4 10             	add    $0x10,%esp

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    315a:	83 ec 08             	sub    $0x8,%esp
    315d:	68 50 60 00 00       	push   $0x6050
    3162:	68 ec 5f 00 00       	push   $0x5fec
    3167:	e8 ea 1e 00 00       	call   5056 <link>
    316c:	83 c4 10             	add    $0x10,%esp
    316f:	85 c0                	test   %eax,%eax
    3171:	74 17                	je     318a <subdir+0x20c>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    3173:	83 ec 08             	sub    $0x8,%esp
    3176:	68 5c 60 00 00       	push   $0x605c
    317b:	6a 01                	push   $0x1
    317d:	e8 fb 1f 00 00       	call   517d <printf>
    3182:	83 c4 10             	add    $0x10,%esp
    exit();
    3185:	e8 6c 1e 00 00       	call   4ff6 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    318a:	83 ec 0c             	sub    $0xc,%esp
    318d:	68 ec 5f 00 00       	push   $0x5fec
    3192:	e8 af 1e 00 00       	call   5046 <unlink>
    3197:	83 c4 10             	add    $0x10,%esp
    319a:	85 c0                	test   %eax,%eax
    319c:	74 17                	je     31b5 <subdir+0x237>
    printf(1, "unlink dd/dd/ff failed\n");
    319e:	83 ec 08             	sub    $0x8,%esp
    31a1:	68 7d 60 00 00       	push   $0x607d
    31a6:	6a 01                	push   $0x1
    31a8:	e8 d0 1f 00 00       	call   517d <printf>
    31ad:	83 c4 10             	add    $0x10,%esp
    exit();
    31b0:	e8 41 1e 00 00       	call   4ff6 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    31b5:	83 ec 08             	sub    $0x8,%esp
    31b8:	6a 00                	push   $0x0
    31ba:	68 ec 5f 00 00       	push   $0x5fec
    31bf:	e8 72 1e 00 00       	call   5036 <open>
    31c4:	83 c4 10             	add    $0x10,%esp
    31c7:	85 c0                	test   %eax,%eax
    31c9:	78 17                	js     31e2 <subdir+0x264>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    31cb:	83 ec 08             	sub    $0x8,%esp
    31ce:	68 98 60 00 00       	push   $0x6098
    31d3:	6a 01                	push   $0x1
    31d5:	e8 a3 1f 00 00       	call   517d <printf>
    31da:	83 c4 10             	add    $0x10,%esp
    exit();
    31dd:	e8 14 1e 00 00       	call   4ff6 <exit>
  }

  if(chdir("dd") != 0){
    31e2:	83 ec 0c             	sub    $0xc,%esp
    31e5:	68 6d 5f 00 00       	push   $0x5f6d
    31ea:	e8 77 1e 00 00       	call   5066 <chdir>
    31ef:	83 c4 10             	add    $0x10,%esp
    31f2:	85 c0                	test   %eax,%eax
    31f4:	74 17                	je     320d <subdir+0x28f>
    printf(1, "chdir dd failed\n");
    31f6:	83 ec 08             	sub    $0x8,%esp
    31f9:	68 bc 60 00 00       	push   $0x60bc
    31fe:	6a 01                	push   $0x1
    3200:	e8 78 1f 00 00       	call   517d <printf>
    3205:	83 c4 10             	add    $0x10,%esp
    exit();
    3208:	e8 e9 1d 00 00       	call   4ff6 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    320d:	83 ec 0c             	sub    $0xc,%esp
    3210:	68 cd 60 00 00       	push   $0x60cd
    3215:	e8 4c 1e 00 00       	call   5066 <chdir>
    321a:	83 c4 10             	add    $0x10,%esp
    321d:	85 c0                	test   %eax,%eax
    321f:	74 17                	je     3238 <subdir+0x2ba>
    printf(1, "chdir dd/../../dd failed\n");
    3221:	83 ec 08             	sub    $0x8,%esp
    3224:	68 d9 60 00 00       	push   $0x60d9
    3229:	6a 01                	push   $0x1
    322b:	e8 4d 1f 00 00       	call   517d <printf>
    3230:	83 c4 10             	add    $0x10,%esp
    exit();
    3233:	e8 be 1d 00 00       	call   4ff6 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    3238:	83 ec 0c             	sub    $0xc,%esp
    323b:	68 f3 60 00 00       	push   $0x60f3
    3240:	e8 21 1e 00 00       	call   5066 <chdir>
    3245:	83 c4 10             	add    $0x10,%esp
    3248:	85 c0                	test   %eax,%eax
    324a:	74 17                	je     3263 <subdir+0x2e5>
    printf(1, "chdir dd/../../dd failed\n");
    324c:	83 ec 08             	sub    $0x8,%esp
    324f:	68 d9 60 00 00       	push   $0x60d9
    3254:	6a 01                	push   $0x1
    3256:	e8 22 1f 00 00       	call   517d <printf>
    325b:	83 c4 10             	add    $0x10,%esp
    exit();
    325e:	e8 93 1d 00 00       	call   4ff6 <exit>
  }
  if(chdir("./..") != 0){
    3263:	83 ec 0c             	sub    $0xc,%esp
    3266:	68 02 61 00 00       	push   $0x6102
    326b:	e8 f6 1d 00 00       	call   5066 <chdir>
    3270:	83 c4 10             	add    $0x10,%esp
    3273:	85 c0                	test   %eax,%eax
    3275:	74 17                	je     328e <subdir+0x310>
    printf(1, "chdir ./.. failed\n");
    3277:	83 ec 08             	sub    $0x8,%esp
    327a:	68 07 61 00 00       	push   $0x6107
    327f:	6a 01                	push   $0x1
    3281:	e8 f7 1e 00 00       	call   517d <printf>
    3286:	83 c4 10             	add    $0x10,%esp
    exit();
    3289:	e8 68 1d 00 00       	call   4ff6 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    328e:	83 ec 08             	sub    $0x8,%esp
    3291:	6a 00                	push   $0x0
    3293:	68 50 60 00 00       	push   $0x6050
    3298:	e8 99 1d 00 00       	call   5036 <open>
    329d:	83 c4 10             	add    $0x10,%esp
    32a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    32a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    32a7:	79 17                	jns    32c0 <subdir+0x342>
    printf(1, "open dd/dd/ffff failed\n");
    32a9:	83 ec 08             	sub    $0x8,%esp
    32ac:	68 1a 61 00 00       	push   $0x611a
    32b1:	6a 01                	push   $0x1
    32b3:	e8 c5 1e 00 00       	call   517d <printf>
    32b8:	83 c4 10             	add    $0x10,%esp
    exit();
    32bb:	e8 36 1d 00 00       	call   4ff6 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    32c0:	83 ec 04             	sub    $0x4,%esp
    32c3:	68 00 20 00 00       	push   $0x2000
    32c8:	68 20 9d 00 00       	push   $0x9d20
    32cd:	ff 75 f4             	pushl  -0xc(%ebp)
    32d0:	e8 39 1d 00 00       	call   500e <read>
    32d5:	83 c4 10             	add    $0x10,%esp
    32d8:	83 f8 02             	cmp    $0x2,%eax
    32db:	74 17                	je     32f4 <subdir+0x376>
    printf(1, "read dd/dd/ffff wrong len\n");
    32dd:	83 ec 08             	sub    $0x8,%esp
    32e0:	68 32 61 00 00       	push   $0x6132
    32e5:	6a 01                	push   $0x1
    32e7:	e8 91 1e 00 00       	call   517d <printf>
    32ec:	83 c4 10             	add    $0x10,%esp
    exit();
    32ef:	e8 02 1d 00 00       	call   4ff6 <exit>
  }
  close(fd);
    32f4:	83 ec 0c             	sub    $0xc,%esp
    32f7:	ff 75 f4             	pushl  -0xc(%ebp)
    32fa:	e8 1f 1d 00 00       	call   501e <close>
    32ff:	83 c4 10             	add    $0x10,%esp

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3302:	83 ec 08             	sub    $0x8,%esp
    3305:	6a 00                	push   $0x0
    3307:	68 ec 5f 00 00       	push   $0x5fec
    330c:	e8 25 1d 00 00       	call   5036 <open>
    3311:	83 c4 10             	add    $0x10,%esp
    3314:	85 c0                	test   %eax,%eax
    3316:	78 17                	js     332f <subdir+0x3b1>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    3318:	83 ec 08             	sub    $0x8,%esp
    331b:	68 50 61 00 00       	push   $0x6150
    3320:	6a 01                	push   $0x1
    3322:	e8 56 1e 00 00       	call   517d <printf>
    3327:	83 c4 10             	add    $0x10,%esp
    exit();
    332a:	e8 c7 1c 00 00       	call   4ff6 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    332f:	83 ec 08             	sub    $0x8,%esp
    3332:	68 02 02 00 00       	push   $0x202
    3337:	68 75 61 00 00       	push   $0x6175
    333c:	e8 f5 1c 00 00       	call   5036 <open>
    3341:	83 c4 10             	add    $0x10,%esp
    3344:	85 c0                	test   %eax,%eax
    3346:	78 17                	js     335f <subdir+0x3e1>
    printf(1, "create dd/ff/ff succeeded!\n");
    3348:	83 ec 08             	sub    $0x8,%esp
    334b:	68 7e 61 00 00       	push   $0x617e
    3350:	6a 01                	push   $0x1
    3352:	e8 26 1e 00 00       	call   517d <printf>
    3357:	83 c4 10             	add    $0x10,%esp
    exit();
    335a:	e8 97 1c 00 00       	call   4ff6 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    335f:	83 ec 08             	sub    $0x8,%esp
    3362:	68 02 02 00 00       	push   $0x202
    3367:	68 9a 61 00 00       	push   $0x619a
    336c:	e8 c5 1c 00 00       	call   5036 <open>
    3371:	83 c4 10             	add    $0x10,%esp
    3374:	85 c0                	test   %eax,%eax
    3376:	78 17                	js     338f <subdir+0x411>
    printf(1, "create dd/xx/ff succeeded!\n");
    3378:	83 ec 08             	sub    $0x8,%esp
    337b:	68 a3 61 00 00       	push   $0x61a3
    3380:	6a 01                	push   $0x1
    3382:	e8 f6 1d 00 00       	call   517d <printf>
    3387:	83 c4 10             	add    $0x10,%esp
    exit();
    338a:	e8 67 1c 00 00       	call   4ff6 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    338f:	83 ec 08             	sub    $0x8,%esp
    3392:	68 00 02 00 00       	push   $0x200
    3397:	68 6d 5f 00 00       	push   $0x5f6d
    339c:	e8 95 1c 00 00       	call   5036 <open>
    33a1:	83 c4 10             	add    $0x10,%esp
    33a4:	85 c0                	test   %eax,%eax
    33a6:	78 17                	js     33bf <subdir+0x441>
    printf(1, "create dd succeeded!\n");
    33a8:	83 ec 08             	sub    $0x8,%esp
    33ab:	68 bf 61 00 00       	push   $0x61bf
    33b0:	6a 01                	push   $0x1
    33b2:	e8 c6 1d 00 00       	call   517d <printf>
    33b7:	83 c4 10             	add    $0x10,%esp
    exit();
    33ba:	e8 37 1c 00 00       	call   4ff6 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    33bf:	83 ec 08             	sub    $0x8,%esp
    33c2:	6a 02                	push   $0x2
    33c4:	68 6d 5f 00 00       	push   $0x5f6d
    33c9:	e8 68 1c 00 00       	call   5036 <open>
    33ce:	83 c4 10             	add    $0x10,%esp
    33d1:	85 c0                	test   %eax,%eax
    33d3:	78 17                	js     33ec <subdir+0x46e>
    printf(1, "open dd rdwr succeeded!\n");
    33d5:	83 ec 08             	sub    $0x8,%esp
    33d8:	68 d5 61 00 00       	push   $0x61d5
    33dd:	6a 01                	push   $0x1
    33df:	e8 99 1d 00 00       	call   517d <printf>
    33e4:	83 c4 10             	add    $0x10,%esp
    exit();
    33e7:	e8 0a 1c 00 00       	call   4ff6 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    33ec:	83 ec 08             	sub    $0x8,%esp
    33ef:	6a 01                	push   $0x1
    33f1:	68 6d 5f 00 00       	push   $0x5f6d
    33f6:	e8 3b 1c 00 00       	call   5036 <open>
    33fb:	83 c4 10             	add    $0x10,%esp
    33fe:	85 c0                	test   %eax,%eax
    3400:	78 17                	js     3419 <subdir+0x49b>
    printf(1, "open dd wronly succeeded!\n");
    3402:	83 ec 08             	sub    $0x8,%esp
    3405:	68 ee 61 00 00       	push   $0x61ee
    340a:	6a 01                	push   $0x1
    340c:	e8 6c 1d 00 00       	call   517d <printf>
    3411:	83 c4 10             	add    $0x10,%esp
    exit();
    3414:	e8 dd 1b 00 00       	call   4ff6 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3419:	83 ec 08             	sub    $0x8,%esp
    341c:	68 09 62 00 00       	push   $0x6209
    3421:	68 75 61 00 00       	push   $0x6175
    3426:	e8 2b 1c 00 00       	call   5056 <link>
    342b:	83 c4 10             	add    $0x10,%esp
    342e:	85 c0                	test   %eax,%eax
    3430:	75 17                	jne    3449 <subdir+0x4cb>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    3432:	83 ec 08             	sub    $0x8,%esp
    3435:	68 14 62 00 00       	push   $0x6214
    343a:	6a 01                	push   $0x1
    343c:	e8 3c 1d 00 00       	call   517d <printf>
    3441:	83 c4 10             	add    $0x10,%esp
    exit();
    3444:	e8 ad 1b 00 00       	call   4ff6 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3449:	83 ec 08             	sub    $0x8,%esp
    344c:	68 09 62 00 00       	push   $0x6209
    3451:	68 9a 61 00 00       	push   $0x619a
    3456:	e8 fb 1b 00 00       	call   5056 <link>
    345b:	83 c4 10             	add    $0x10,%esp
    345e:	85 c0                	test   %eax,%eax
    3460:	75 17                	jne    3479 <subdir+0x4fb>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    3462:	83 ec 08             	sub    $0x8,%esp
    3465:	68 38 62 00 00       	push   $0x6238
    346a:	6a 01                	push   $0x1
    346c:	e8 0c 1d 00 00       	call   517d <printf>
    3471:	83 c4 10             	add    $0x10,%esp
    exit();
    3474:	e8 7d 1b 00 00       	call   4ff6 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3479:	83 ec 08             	sub    $0x8,%esp
    347c:	68 50 60 00 00       	push   $0x6050
    3481:	68 88 5f 00 00       	push   $0x5f88
    3486:	e8 cb 1b 00 00       	call   5056 <link>
    348b:	83 c4 10             	add    $0x10,%esp
    348e:	85 c0                	test   %eax,%eax
    3490:	75 17                	jne    34a9 <subdir+0x52b>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    3492:	83 ec 08             	sub    $0x8,%esp
    3495:	68 5c 62 00 00       	push   $0x625c
    349a:	6a 01                	push   $0x1
    349c:	e8 dc 1c 00 00       	call   517d <printf>
    34a1:	83 c4 10             	add    $0x10,%esp
    exit();
    34a4:	e8 4d 1b 00 00       	call   4ff6 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    34a9:	83 ec 0c             	sub    $0xc,%esp
    34ac:	68 75 61 00 00       	push   $0x6175
    34b1:	e8 a8 1b 00 00       	call   505e <mkdir>
    34b6:	83 c4 10             	add    $0x10,%esp
    34b9:	85 c0                	test   %eax,%eax
    34bb:	75 17                	jne    34d4 <subdir+0x556>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    34bd:	83 ec 08             	sub    $0x8,%esp
    34c0:	68 7e 62 00 00       	push   $0x627e
    34c5:	6a 01                	push   $0x1
    34c7:	e8 b1 1c 00 00       	call   517d <printf>
    34cc:	83 c4 10             	add    $0x10,%esp
    exit();
    34cf:	e8 22 1b 00 00       	call   4ff6 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    34d4:	83 ec 0c             	sub    $0xc,%esp
    34d7:	68 9a 61 00 00       	push   $0x619a
    34dc:	e8 7d 1b 00 00       	call   505e <mkdir>
    34e1:	83 c4 10             	add    $0x10,%esp
    34e4:	85 c0                	test   %eax,%eax
    34e6:	75 17                	jne    34ff <subdir+0x581>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    34e8:	83 ec 08             	sub    $0x8,%esp
    34eb:	68 99 62 00 00       	push   $0x6299
    34f0:	6a 01                	push   $0x1
    34f2:	e8 86 1c 00 00       	call   517d <printf>
    34f7:	83 c4 10             	add    $0x10,%esp
    exit();
    34fa:	e8 f7 1a 00 00       	call   4ff6 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    34ff:	83 ec 0c             	sub    $0xc,%esp
    3502:	68 50 60 00 00       	push   $0x6050
    3507:	e8 52 1b 00 00       	call   505e <mkdir>
    350c:	83 c4 10             	add    $0x10,%esp
    350f:	85 c0                	test   %eax,%eax
    3511:	75 17                	jne    352a <subdir+0x5ac>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    3513:	83 ec 08             	sub    $0x8,%esp
    3516:	68 b4 62 00 00       	push   $0x62b4
    351b:	6a 01                	push   $0x1
    351d:	e8 5b 1c 00 00       	call   517d <printf>
    3522:	83 c4 10             	add    $0x10,%esp
    exit();
    3525:	e8 cc 1a 00 00       	call   4ff6 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    352a:	83 ec 0c             	sub    $0xc,%esp
    352d:	68 9a 61 00 00       	push   $0x619a
    3532:	e8 0f 1b 00 00       	call   5046 <unlink>
    3537:	83 c4 10             	add    $0x10,%esp
    353a:	85 c0                	test   %eax,%eax
    353c:	75 17                	jne    3555 <subdir+0x5d7>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    353e:	83 ec 08             	sub    $0x8,%esp
    3541:	68 d1 62 00 00       	push   $0x62d1
    3546:	6a 01                	push   $0x1
    3548:	e8 30 1c 00 00       	call   517d <printf>
    354d:	83 c4 10             	add    $0x10,%esp
    exit();
    3550:	e8 a1 1a 00 00       	call   4ff6 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    3555:	83 ec 0c             	sub    $0xc,%esp
    3558:	68 75 61 00 00       	push   $0x6175
    355d:	e8 e4 1a 00 00       	call   5046 <unlink>
    3562:	83 c4 10             	add    $0x10,%esp
    3565:	85 c0                	test   %eax,%eax
    3567:	75 17                	jne    3580 <subdir+0x602>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    3569:	83 ec 08             	sub    $0x8,%esp
    356c:	68 ed 62 00 00       	push   $0x62ed
    3571:	6a 01                	push   $0x1
    3573:	e8 05 1c 00 00       	call   517d <printf>
    3578:	83 c4 10             	add    $0x10,%esp
    exit();
    357b:	e8 76 1a 00 00       	call   4ff6 <exit>
  }
  if(chdir("dd/ff") == 0){
    3580:	83 ec 0c             	sub    $0xc,%esp
    3583:	68 88 5f 00 00       	push   $0x5f88
    3588:	e8 d9 1a 00 00       	call   5066 <chdir>
    358d:	83 c4 10             	add    $0x10,%esp
    3590:	85 c0                	test   %eax,%eax
    3592:	75 17                	jne    35ab <subdir+0x62d>
    printf(1, "chdir dd/ff succeeded!\n");
    3594:	83 ec 08             	sub    $0x8,%esp
    3597:	68 09 63 00 00       	push   $0x6309
    359c:	6a 01                	push   $0x1
    359e:	e8 da 1b 00 00       	call   517d <printf>
    35a3:	83 c4 10             	add    $0x10,%esp
    exit();
    35a6:	e8 4b 1a 00 00       	call   4ff6 <exit>
  }
  if(chdir("dd/xx") == 0){
    35ab:	83 ec 0c             	sub    $0xc,%esp
    35ae:	68 21 63 00 00       	push   $0x6321
    35b3:	e8 ae 1a 00 00       	call   5066 <chdir>
    35b8:	83 c4 10             	add    $0x10,%esp
    35bb:	85 c0                	test   %eax,%eax
    35bd:	75 17                	jne    35d6 <subdir+0x658>
    printf(1, "chdir dd/xx succeeded!\n");
    35bf:	83 ec 08             	sub    $0x8,%esp
    35c2:	68 27 63 00 00       	push   $0x6327
    35c7:	6a 01                	push   $0x1
    35c9:	e8 af 1b 00 00       	call   517d <printf>
    35ce:	83 c4 10             	add    $0x10,%esp
    exit();
    35d1:	e8 20 1a 00 00       	call   4ff6 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    35d6:	83 ec 0c             	sub    $0xc,%esp
    35d9:	68 50 60 00 00       	push   $0x6050
    35de:	e8 63 1a 00 00       	call   5046 <unlink>
    35e3:	83 c4 10             	add    $0x10,%esp
    35e6:	85 c0                	test   %eax,%eax
    35e8:	74 17                	je     3601 <subdir+0x683>
    printf(1, "unlink dd/dd/ff failed\n");
    35ea:	83 ec 08             	sub    $0x8,%esp
    35ed:	68 7d 60 00 00       	push   $0x607d
    35f2:	6a 01                	push   $0x1
    35f4:	e8 84 1b 00 00       	call   517d <printf>
    35f9:	83 c4 10             	add    $0x10,%esp
    exit();
    35fc:	e8 f5 19 00 00       	call   4ff6 <exit>
  }
  if(unlink("dd/ff") != 0){
    3601:	83 ec 0c             	sub    $0xc,%esp
    3604:	68 88 5f 00 00       	push   $0x5f88
    3609:	e8 38 1a 00 00       	call   5046 <unlink>
    360e:	83 c4 10             	add    $0x10,%esp
    3611:	85 c0                	test   %eax,%eax
    3613:	74 17                	je     362c <subdir+0x6ae>
    printf(1, "unlink dd/ff failed\n");
    3615:	83 ec 08             	sub    $0x8,%esp
    3618:	68 3f 63 00 00       	push   $0x633f
    361d:	6a 01                	push   $0x1
    361f:	e8 59 1b 00 00       	call   517d <printf>
    3624:	83 c4 10             	add    $0x10,%esp
    exit();
    3627:	e8 ca 19 00 00       	call   4ff6 <exit>
  }
  if(unlink("dd") == 0){
    362c:	83 ec 0c             	sub    $0xc,%esp
    362f:	68 6d 5f 00 00       	push   $0x5f6d
    3634:	e8 0d 1a 00 00       	call   5046 <unlink>
    3639:	83 c4 10             	add    $0x10,%esp
    363c:	85 c0                	test   %eax,%eax
    363e:	75 17                	jne    3657 <subdir+0x6d9>
    printf(1, "unlink non-empty dd succeeded!\n");
    3640:	83 ec 08             	sub    $0x8,%esp
    3643:	68 54 63 00 00       	push   $0x6354
    3648:	6a 01                	push   $0x1
    364a:	e8 2e 1b 00 00       	call   517d <printf>
    364f:	83 c4 10             	add    $0x10,%esp
    exit();
    3652:	e8 9f 19 00 00       	call   4ff6 <exit>
  }
  if(unlink("dd/dd") < 0){
    3657:	83 ec 0c             	sub    $0xc,%esp
    365a:	68 74 63 00 00       	push   $0x6374
    365f:	e8 e2 19 00 00       	call   5046 <unlink>
    3664:	83 c4 10             	add    $0x10,%esp
    3667:	85 c0                	test   %eax,%eax
    3669:	79 17                	jns    3682 <subdir+0x704>
    printf(1, "unlink dd/dd failed\n");
    366b:	83 ec 08             	sub    $0x8,%esp
    366e:	68 7a 63 00 00       	push   $0x637a
    3673:	6a 01                	push   $0x1
    3675:	e8 03 1b 00 00       	call   517d <printf>
    367a:	83 c4 10             	add    $0x10,%esp
    exit();
    367d:	e8 74 19 00 00       	call   4ff6 <exit>
  }
  if(unlink("dd") < 0){
    3682:	83 ec 0c             	sub    $0xc,%esp
    3685:	68 6d 5f 00 00       	push   $0x5f6d
    368a:	e8 b7 19 00 00       	call   5046 <unlink>
    368f:	83 c4 10             	add    $0x10,%esp
    3692:	85 c0                	test   %eax,%eax
    3694:	79 17                	jns    36ad <subdir+0x72f>
    printf(1, "unlink dd failed\n");
    3696:	83 ec 08             	sub    $0x8,%esp
    3699:	68 8f 63 00 00       	push   $0x638f
    369e:	6a 01                	push   $0x1
    36a0:	e8 d8 1a 00 00       	call   517d <printf>
    36a5:	83 c4 10             	add    $0x10,%esp
    exit();
    36a8:	e8 49 19 00 00       	call   4ff6 <exit>
  }

  printf(1, "subdir ok\n");
    36ad:	83 ec 08             	sub    $0x8,%esp
    36b0:	68 a1 63 00 00       	push   $0x63a1
    36b5:	6a 01                	push   $0x1
    36b7:	e8 c1 1a 00 00       	call   517d <printf>
    36bc:	83 c4 10             	add    $0x10,%esp
}
    36bf:	90                   	nop
    36c0:	c9                   	leave  
    36c1:	c3                   	ret    

000036c2 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    36c2:	55                   	push   %ebp
    36c3:	89 e5                	mov    %esp,%ebp
    36c5:	83 ec 18             	sub    $0x18,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    36c8:	83 ec 08             	sub    $0x8,%esp
    36cb:	68 ac 63 00 00       	push   $0x63ac
    36d0:	6a 01                	push   $0x1
    36d2:	e8 a6 1a 00 00       	call   517d <printf>
    36d7:	83 c4 10             	add    $0x10,%esp

  unlink("bigwrite");
    36da:	83 ec 0c             	sub    $0xc,%esp
    36dd:	68 bb 63 00 00       	push   $0x63bb
    36e2:	e8 5f 19 00 00       	call   5046 <unlink>
    36e7:	83 c4 10             	add    $0x10,%esp
  for(sz = 499; sz < 12*512; sz += 471){
    36ea:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    36f1:	e9 a8 00 00 00       	jmp    379e <bigwrite+0xdc>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    36f6:	83 ec 08             	sub    $0x8,%esp
    36f9:	68 02 02 00 00       	push   $0x202
    36fe:	68 bb 63 00 00       	push   $0x63bb
    3703:	e8 2e 19 00 00       	call   5036 <open>
    3708:	83 c4 10             	add    $0x10,%esp
    370b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    370e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3712:	79 17                	jns    372b <bigwrite+0x69>
      printf(1, "cannot create bigwrite\n");
    3714:	83 ec 08             	sub    $0x8,%esp
    3717:	68 c4 63 00 00       	push   $0x63c4
    371c:	6a 01                	push   $0x1
    371e:	e8 5a 1a 00 00       	call   517d <printf>
    3723:	83 c4 10             	add    $0x10,%esp
      exit();
    3726:	e8 cb 18 00 00       	call   4ff6 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    372b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3732:	eb 3f                	jmp    3773 <bigwrite+0xb1>
      int cc = write(fd, buf, sz);
    3734:	83 ec 04             	sub    $0x4,%esp
    3737:	ff 75 f4             	pushl  -0xc(%ebp)
    373a:	68 20 9d 00 00       	push   $0x9d20
    373f:	ff 75 ec             	pushl  -0x14(%ebp)
    3742:	e8 cf 18 00 00       	call   5016 <write>
    3747:	83 c4 10             	add    $0x10,%esp
    374a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    374d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3750:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3753:	74 1a                	je     376f <bigwrite+0xad>
        printf(1, "write(%d) ret %d\n", sz, cc);
    3755:	ff 75 e8             	pushl  -0x18(%ebp)
    3758:	ff 75 f4             	pushl  -0xc(%ebp)
    375b:	68 dc 63 00 00       	push   $0x63dc
    3760:	6a 01                	push   $0x1
    3762:	e8 16 1a 00 00       	call   517d <printf>
    3767:	83 c4 10             	add    $0x10,%esp
        exit();
    376a:	e8 87 18 00 00       	call   4ff6 <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
    376f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3773:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    3777:	7e bb                	jle    3734 <bigwrite+0x72>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    3779:	83 ec 0c             	sub    $0xc,%esp
    377c:	ff 75 ec             	pushl  -0x14(%ebp)
    377f:	e8 9a 18 00 00       	call   501e <close>
    3784:	83 c4 10             	add    $0x10,%esp
    unlink("bigwrite");
    3787:	83 ec 0c             	sub    $0xc,%esp
    378a:	68 bb 63 00 00       	push   $0x63bb
    378f:	e8 b2 18 00 00       	call   5046 <unlink>
    3794:	83 c4 10             	add    $0x10,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    3797:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    379e:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    37a5:	0f 8e 4b ff ff ff    	jle    36f6 <bigwrite+0x34>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    37ab:	83 ec 08             	sub    $0x8,%esp
    37ae:	68 ee 63 00 00       	push   $0x63ee
    37b3:	6a 01                	push   $0x1
    37b5:	e8 c3 19 00 00       	call   517d <printf>
    37ba:	83 c4 10             	add    $0x10,%esp
}
    37bd:	90                   	nop
    37be:	c9                   	leave  
    37bf:	c3                   	ret    

000037c0 <bigfile>:

void
bigfile(void)
{
    37c0:	55                   	push   %ebp
    37c1:	89 e5                	mov    %esp,%ebp
    37c3:	83 ec 18             	sub    $0x18,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    37c6:	83 ec 08             	sub    $0x8,%esp
    37c9:	68 fb 63 00 00       	push   $0x63fb
    37ce:	6a 01                	push   $0x1
    37d0:	e8 a8 19 00 00       	call   517d <printf>
    37d5:	83 c4 10             	add    $0x10,%esp

  unlink("bigfile");
    37d8:	83 ec 0c             	sub    $0xc,%esp
    37db:	68 09 64 00 00       	push   $0x6409
    37e0:	e8 61 18 00 00       	call   5046 <unlink>
    37e5:	83 c4 10             	add    $0x10,%esp
  fd = open("bigfile", O_CREATE | O_RDWR);
    37e8:	83 ec 08             	sub    $0x8,%esp
    37eb:	68 02 02 00 00       	push   $0x202
    37f0:	68 09 64 00 00       	push   $0x6409
    37f5:	e8 3c 18 00 00       	call   5036 <open>
    37fa:	83 c4 10             	add    $0x10,%esp
    37fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    3800:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3804:	79 17                	jns    381d <bigfile+0x5d>
    printf(1, "cannot create bigfile");
    3806:	83 ec 08             	sub    $0x8,%esp
    3809:	68 11 64 00 00       	push   $0x6411
    380e:	6a 01                	push   $0x1
    3810:	e8 68 19 00 00       	call   517d <printf>
    3815:	83 c4 10             	add    $0x10,%esp
    exit();
    3818:	e8 d9 17 00 00       	call   4ff6 <exit>
  }
  for(i = 0; i < 20; i++){
    381d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3824:	eb 52                	jmp    3878 <bigfile+0xb8>
    memset(buf, i, 600);
    3826:	83 ec 04             	sub    $0x4,%esp
    3829:	68 58 02 00 00       	push   $0x258
    382e:	ff 75 f4             	pushl  -0xc(%ebp)
    3831:	68 20 9d 00 00       	push   $0x9d20
    3836:	e8 20 16 00 00       	call   4e5b <memset>
    383b:	83 c4 10             	add    $0x10,%esp
    if(write(fd, buf, 600) != 600){
    383e:	83 ec 04             	sub    $0x4,%esp
    3841:	68 58 02 00 00       	push   $0x258
    3846:	68 20 9d 00 00       	push   $0x9d20
    384b:	ff 75 ec             	pushl  -0x14(%ebp)
    384e:	e8 c3 17 00 00       	call   5016 <write>
    3853:	83 c4 10             	add    $0x10,%esp
    3856:	3d 58 02 00 00       	cmp    $0x258,%eax
    385b:	74 17                	je     3874 <bigfile+0xb4>
      printf(1, "write bigfile failed\n");
    385d:	83 ec 08             	sub    $0x8,%esp
    3860:	68 27 64 00 00       	push   $0x6427
    3865:	6a 01                	push   $0x1
    3867:	e8 11 19 00 00       	call   517d <printf>
    386c:	83 c4 10             	add    $0x10,%esp
      exit();
    386f:	e8 82 17 00 00       	call   4ff6 <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    3874:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3878:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    387c:	7e a8                	jle    3826 <bigfile+0x66>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    387e:	83 ec 0c             	sub    $0xc,%esp
    3881:	ff 75 ec             	pushl  -0x14(%ebp)
    3884:	e8 95 17 00 00       	call   501e <close>
    3889:	83 c4 10             	add    $0x10,%esp

  fd = open("bigfile", 0);
    388c:	83 ec 08             	sub    $0x8,%esp
    388f:	6a 00                	push   $0x0
    3891:	68 09 64 00 00       	push   $0x6409
    3896:	e8 9b 17 00 00       	call   5036 <open>
    389b:	83 c4 10             	add    $0x10,%esp
    389e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    38a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    38a5:	79 17                	jns    38be <bigfile+0xfe>
    printf(1, "cannot open bigfile\n");
    38a7:	83 ec 08             	sub    $0x8,%esp
    38aa:	68 3d 64 00 00       	push   $0x643d
    38af:	6a 01                	push   $0x1
    38b1:	e8 c7 18 00 00       	call   517d <printf>
    38b6:	83 c4 10             	add    $0x10,%esp
    exit();
    38b9:	e8 38 17 00 00       	call   4ff6 <exit>
  }
  total = 0;
    38be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    38c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    38cc:	83 ec 04             	sub    $0x4,%esp
    38cf:	68 2c 01 00 00       	push   $0x12c
    38d4:	68 20 9d 00 00       	push   $0x9d20
    38d9:	ff 75 ec             	pushl  -0x14(%ebp)
    38dc:	e8 2d 17 00 00       	call   500e <read>
    38e1:	83 c4 10             	add    $0x10,%esp
    38e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    38e7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    38eb:	79 17                	jns    3904 <bigfile+0x144>
      printf(1, "read bigfile failed\n");
    38ed:	83 ec 08             	sub    $0x8,%esp
    38f0:	68 52 64 00 00       	push   $0x6452
    38f5:	6a 01                	push   $0x1
    38f7:	e8 81 18 00 00       	call   517d <printf>
    38fc:	83 c4 10             	add    $0x10,%esp
      exit();
    38ff:	e8 f2 16 00 00       	call   4ff6 <exit>
    }
    if(cc == 0)
    3904:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    3908:	74 7a                	je     3984 <bigfile+0x1c4>
      break;
    if(cc != 300){
    390a:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    3911:	74 17                	je     392a <bigfile+0x16a>
      printf(1, "short read bigfile\n");
    3913:	83 ec 08             	sub    $0x8,%esp
    3916:	68 67 64 00 00       	push   $0x6467
    391b:	6a 01                	push   $0x1
    391d:	e8 5b 18 00 00       	call   517d <printf>
    3922:	83 c4 10             	add    $0x10,%esp
      exit();
    3925:	e8 cc 16 00 00       	call   4ff6 <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    392a:	0f b6 05 20 9d 00 00 	movzbl 0x9d20,%eax
    3931:	0f be d0             	movsbl %al,%edx
    3934:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3937:	89 c1                	mov    %eax,%ecx
    3939:	c1 e9 1f             	shr    $0x1f,%ecx
    393c:	01 c8                	add    %ecx,%eax
    393e:	d1 f8                	sar    %eax
    3940:	39 c2                	cmp    %eax,%edx
    3942:	75 1a                	jne    395e <bigfile+0x19e>
    3944:	0f b6 05 4b 9e 00 00 	movzbl 0x9e4b,%eax
    394b:	0f be d0             	movsbl %al,%edx
    394e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3951:	89 c1                	mov    %eax,%ecx
    3953:	c1 e9 1f             	shr    $0x1f,%ecx
    3956:	01 c8                	add    %ecx,%eax
    3958:	d1 f8                	sar    %eax
    395a:	39 c2                	cmp    %eax,%edx
    395c:	74 17                	je     3975 <bigfile+0x1b5>
      printf(1, "read bigfile wrong data\n");
    395e:	83 ec 08             	sub    $0x8,%esp
    3961:	68 7b 64 00 00       	push   $0x647b
    3966:	6a 01                	push   $0x1
    3968:	e8 10 18 00 00       	call   517d <printf>
    396d:	83 c4 10             	add    $0x10,%esp
      exit();
    3970:	e8 81 16 00 00       	call   4ff6 <exit>
    }
    total += cc;
    3975:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3978:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    397b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
    397f:	e9 48 ff ff ff       	jmp    38cc <bigfile+0x10c>
    if(cc < 0){
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    3984:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    3985:	83 ec 0c             	sub    $0xc,%esp
    3988:	ff 75 ec             	pushl  -0x14(%ebp)
    398b:	e8 8e 16 00 00       	call   501e <close>
    3990:	83 c4 10             	add    $0x10,%esp
  if(total != 20*600){
    3993:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    399a:	74 17                	je     39b3 <bigfile+0x1f3>
    printf(1, "read bigfile wrong total\n");
    399c:	83 ec 08             	sub    $0x8,%esp
    399f:	68 94 64 00 00       	push   $0x6494
    39a4:	6a 01                	push   $0x1
    39a6:	e8 d2 17 00 00       	call   517d <printf>
    39ab:	83 c4 10             	add    $0x10,%esp
    exit();
    39ae:	e8 43 16 00 00       	call   4ff6 <exit>
  }
  unlink("bigfile");
    39b3:	83 ec 0c             	sub    $0xc,%esp
    39b6:	68 09 64 00 00       	push   $0x6409
    39bb:	e8 86 16 00 00       	call   5046 <unlink>
    39c0:	83 c4 10             	add    $0x10,%esp

  printf(1, "bigfile test ok\n");
    39c3:	83 ec 08             	sub    $0x8,%esp
    39c6:	68 ae 64 00 00       	push   $0x64ae
    39cb:	6a 01                	push   $0x1
    39cd:	e8 ab 17 00 00       	call   517d <printf>
    39d2:	83 c4 10             	add    $0x10,%esp
}
    39d5:	90                   	nop
    39d6:	c9                   	leave  
    39d7:	c3                   	ret    

000039d8 <fourteen>:

void
fourteen(void)
{
    39d8:	55                   	push   %ebp
    39d9:	89 e5                	mov    %esp,%ebp
    39db:	83 ec 18             	sub    $0x18,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    39de:	83 ec 08             	sub    $0x8,%esp
    39e1:	68 bf 64 00 00       	push   $0x64bf
    39e6:	6a 01                	push   $0x1
    39e8:	e8 90 17 00 00       	call   517d <printf>
    39ed:	83 c4 10             	add    $0x10,%esp

  if(mkdir("12345678901234") != 0){
    39f0:	83 ec 0c             	sub    $0xc,%esp
    39f3:	68 ce 64 00 00       	push   $0x64ce
    39f8:	e8 61 16 00 00       	call   505e <mkdir>
    39fd:	83 c4 10             	add    $0x10,%esp
    3a00:	85 c0                	test   %eax,%eax
    3a02:	74 17                	je     3a1b <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    3a04:	83 ec 08             	sub    $0x8,%esp
    3a07:	68 dd 64 00 00       	push   $0x64dd
    3a0c:	6a 01                	push   $0x1
    3a0e:	e8 6a 17 00 00       	call   517d <printf>
    3a13:	83 c4 10             	add    $0x10,%esp
    exit();
    3a16:	e8 db 15 00 00       	call   4ff6 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    3a1b:	83 ec 0c             	sub    $0xc,%esp
    3a1e:	68 fc 64 00 00       	push   $0x64fc
    3a23:	e8 36 16 00 00       	call   505e <mkdir>
    3a28:	83 c4 10             	add    $0x10,%esp
    3a2b:	85 c0                	test   %eax,%eax
    3a2d:	74 17                	je     3a46 <fourteen+0x6e>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    3a2f:	83 ec 08             	sub    $0x8,%esp
    3a32:	68 1c 65 00 00       	push   $0x651c
    3a37:	6a 01                	push   $0x1
    3a39:	e8 3f 17 00 00       	call   517d <printf>
    3a3e:	83 c4 10             	add    $0x10,%esp
    exit();
    3a41:	e8 b0 15 00 00       	call   4ff6 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3a46:	83 ec 08             	sub    $0x8,%esp
    3a49:	68 00 02 00 00       	push   $0x200
    3a4e:	68 4c 65 00 00       	push   $0x654c
    3a53:	e8 de 15 00 00       	call   5036 <open>
    3a58:	83 c4 10             	add    $0x10,%esp
    3a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    3a5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3a62:	79 17                	jns    3a7b <fourteen+0xa3>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    3a64:	83 ec 08             	sub    $0x8,%esp
    3a67:	68 7c 65 00 00       	push   $0x657c
    3a6c:	6a 01                	push   $0x1
    3a6e:	e8 0a 17 00 00       	call   517d <printf>
    3a73:	83 c4 10             	add    $0x10,%esp
    exit();
    3a76:	e8 7b 15 00 00       	call   4ff6 <exit>
  }
  close(fd);
    3a7b:	83 ec 0c             	sub    $0xc,%esp
    3a7e:	ff 75 f4             	pushl  -0xc(%ebp)
    3a81:	e8 98 15 00 00       	call   501e <close>
    3a86:	83 c4 10             	add    $0x10,%esp
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3a89:	83 ec 08             	sub    $0x8,%esp
    3a8c:	6a 00                	push   $0x0
    3a8e:	68 bc 65 00 00       	push   $0x65bc
    3a93:	e8 9e 15 00 00       	call   5036 <open>
    3a98:	83 c4 10             	add    $0x10,%esp
    3a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    3a9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3aa2:	79 17                	jns    3abb <fourteen+0xe3>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    3aa4:	83 ec 08             	sub    $0x8,%esp
    3aa7:	68 ec 65 00 00       	push   $0x65ec
    3aac:	6a 01                	push   $0x1
    3aae:	e8 ca 16 00 00       	call   517d <printf>
    3ab3:	83 c4 10             	add    $0x10,%esp
    exit();
    3ab6:	e8 3b 15 00 00       	call   4ff6 <exit>
  }
  close(fd);
    3abb:	83 ec 0c             	sub    $0xc,%esp
    3abe:	ff 75 f4             	pushl  -0xc(%ebp)
    3ac1:	e8 58 15 00 00       	call   501e <close>
    3ac6:	83 c4 10             	add    $0x10,%esp

  if(mkdir("12345678901234/12345678901234") == 0){
    3ac9:	83 ec 0c             	sub    $0xc,%esp
    3acc:	68 26 66 00 00       	push   $0x6626
    3ad1:	e8 88 15 00 00       	call   505e <mkdir>
    3ad6:	83 c4 10             	add    $0x10,%esp
    3ad9:	85 c0                	test   %eax,%eax
    3adb:	75 17                	jne    3af4 <fourteen+0x11c>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    3add:	83 ec 08             	sub    $0x8,%esp
    3ae0:	68 44 66 00 00       	push   $0x6644
    3ae5:	6a 01                	push   $0x1
    3ae7:	e8 91 16 00 00       	call   517d <printf>
    3aec:	83 c4 10             	add    $0x10,%esp
    exit();
    3aef:	e8 02 15 00 00       	call   4ff6 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    3af4:	83 ec 0c             	sub    $0xc,%esp
    3af7:	68 74 66 00 00       	push   $0x6674
    3afc:	e8 5d 15 00 00       	call   505e <mkdir>
    3b01:	83 c4 10             	add    $0x10,%esp
    3b04:	85 c0                	test   %eax,%eax
    3b06:	75 17                	jne    3b1f <fourteen+0x147>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    3b08:	83 ec 08             	sub    $0x8,%esp
    3b0b:	68 94 66 00 00       	push   $0x6694
    3b10:	6a 01                	push   $0x1
    3b12:	e8 66 16 00 00       	call   517d <printf>
    3b17:	83 c4 10             	add    $0x10,%esp
    exit();
    3b1a:	e8 d7 14 00 00       	call   4ff6 <exit>
  }

  printf(1, "fourteen ok\n");
    3b1f:	83 ec 08             	sub    $0x8,%esp
    3b22:	68 c5 66 00 00       	push   $0x66c5
    3b27:	6a 01                	push   $0x1
    3b29:	e8 4f 16 00 00       	call   517d <printf>
    3b2e:	83 c4 10             	add    $0x10,%esp
}
    3b31:	90                   	nop
    3b32:	c9                   	leave  
    3b33:	c3                   	ret    

00003b34 <rmdot>:

void
rmdot(void)
{
    3b34:	55                   	push   %ebp
    3b35:	89 e5                	mov    %esp,%ebp
    3b37:	83 ec 08             	sub    $0x8,%esp
  printf(1, "rmdot test\n");
    3b3a:	83 ec 08             	sub    $0x8,%esp
    3b3d:	68 d2 66 00 00       	push   $0x66d2
    3b42:	6a 01                	push   $0x1
    3b44:	e8 34 16 00 00       	call   517d <printf>
    3b49:	83 c4 10             	add    $0x10,%esp
  if(mkdir("dots") != 0){
    3b4c:	83 ec 0c             	sub    $0xc,%esp
    3b4f:	68 de 66 00 00       	push   $0x66de
    3b54:	e8 05 15 00 00       	call   505e <mkdir>
    3b59:	83 c4 10             	add    $0x10,%esp
    3b5c:	85 c0                	test   %eax,%eax
    3b5e:	74 17                	je     3b77 <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    3b60:	83 ec 08             	sub    $0x8,%esp
    3b63:	68 e3 66 00 00       	push   $0x66e3
    3b68:	6a 01                	push   $0x1
    3b6a:	e8 0e 16 00 00       	call   517d <printf>
    3b6f:	83 c4 10             	add    $0x10,%esp
    exit();
    3b72:	e8 7f 14 00 00       	call   4ff6 <exit>
  }
  if(chdir("dots") != 0){
    3b77:	83 ec 0c             	sub    $0xc,%esp
    3b7a:	68 de 66 00 00       	push   $0x66de
    3b7f:	e8 e2 14 00 00       	call   5066 <chdir>
    3b84:	83 c4 10             	add    $0x10,%esp
    3b87:	85 c0                	test   %eax,%eax
    3b89:	74 17                	je     3ba2 <rmdot+0x6e>
    printf(1, "chdir dots failed\n");
    3b8b:	83 ec 08             	sub    $0x8,%esp
    3b8e:	68 f6 66 00 00       	push   $0x66f6
    3b93:	6a 01                	push   $0x1
    3b95:	e8 e3 15 00 00       	call   517d <printf>
    3b9a:	83 c4 10             	add    $0x10,%esp
    exit();
    3b9d:	e8 54 14 00 00       	call   4ff6 <exit>
  }
  if(unlink(".") == 0){
    3ba2:	83 ec 0c             	sub    $0xc,%esp
    3ba5:	68 0f 5e 00 00       	push   $0x5e0f
    3baa:	e8 97 14 00 00       	call   5046 <unlink>
    3baf:	83 c4 10             	add    $0x10,%esp
    3bb2:	85 c0                	test   %eax,%eax
    3bb4:	75 17                	jne    3bcd <rmdot+0x99>
    printf(1, "rm . worked!\n");
    3bb6:	83 ec 08             	sub    $0x8,%esp
    3bb9:	68 09 67 00 00       	push   $0x6709
    3bbe:	6a 01                	push   $0x1
    3bc0:	e8 b8 15 00 00       	call   517d <printf>
    3bc5:	83 c4 10             	add    $0x10,%esp
    exit();
    3bc8:	e8 29 14 00 00       	call   4ff6 <exit>
  }
  if(unlink("..") == 0){
    3bcd:	83 ec 0c             	sub    $0xc,%esp
    3bd0:	68 a2 59 00 00       	push   $0x59a2
    3bd5:	e8 6c 14 00 00       	call   5046 <unlink>
    3bda:	83 c4 10             	add    $0x10,%esp
    3bdd:	85 c0                	test   %eax,%eax
    3bdf:	75 17                	jne    3bf8 <rmdot+0xc4>
    printf(1, "rm .. worked!\n");
    3be1:	83 ec 08             	sub    $0x8,%esp
    3be4:	68 17 67 00 00       	push   $0x6717
    3be9:	6a 01                	push   $0x1
    3beb:	e8 8d 15 00 00       	call   517d <printf>
    3bf0:	83 c4 10             	add    $0x10,%esp
    exit();
    3bf3:	e8 fe 13 00 00       	call   4ff6 <exit>
  }
  if(chdir("/") != 0){
    3bf8:	83 ec 0c             	sub    $0xc,%esp
    3bfb:	68 f6 55 00 00       	push   $0x55f6
    3c00:	e8 61 14 00 00       	call   5066 <chdir>
    3c05:	83 c4 10             	add    $0x10,%esp
    3c08:	85 c0                	test   %eax,%eax
    3c0a:	74 17                	je     3c23 <rmdot+0xef>
    printf(1, "chdir / failed\n");
    3c0c:	83 ec 08             	sub    $0x8,%esp
    3c0f:	68 f8 55 00 00       	push   $0x55f8
    3c14:	6a 01                	push   $0x1
    3c16:	e8 62 15 00 00       	call   517d <printf>
    3c1b:	83 c4 10             	add    $0x10,%esp
    exit();
    3c1e:	e8 d3 13 00 00       	call   4ff6 <exit>
  }
  if(unlink("dots/.") == 0){
    3c23:	83 ec 0c             	sub    $0xc,%esp
    3c26:	68 26 67 00 00       	push   $0x6726
    3c2b:	e8 16 14 00 00       	call   5046 <unlink>
    3c30:	83 c4 10             	add    $0x10,%esp
    3c33:	85 c0                	test   %eax,%eax
    3c35:	75 17                	jne    3c4e <rmdot+0x11a>
    printf(1, "unlink dots/. worked!\n");
    3c37:	83 ec 08             	sub    $0x8,%esp
    3c3a:	68 2d 67 00 00       	push   $0x672d
    3c3f:	6a 01                	push   $0x1
    3c41:	e8 37 15 00 00       	call   517d <printf>
    3c46:	83 c4 10             	add    $0x10,%esp
    exit();
    3c49:	e8 a8 13 00 00       	call   4ff6 <exit>
  }
  if(unlink("dots/..") == 0){
    3c4e:	83 ec 0c             	sub    $0xc,%esp
    3c51:	68 44 67 00 00       	push   $0x6744
    3c56:	e8 eb 13 00 00       	call   5046 <unlink>
    3c5b:	83 c4 10             	add    $0x10,%esp
    3c5e:	85 c0                	test   %eax,%eax
    3c60:	75 17                	jne    3c79 <rmdot+0x145>
    printf(1, "unlink dots/.. worked!\n");
    3c62:	83 ec 08             	sub    $0x8,%esp
    3c65:	68 4c 67 00 00       	push   $0x674c
    3c6a:	6a 01                	push   $0x1
    3c6c:	e8 0c 15 00 00       	call   517d <printf>
    3c71:	83 c4 10             	add    $0x10,%esp
    exit();
    3c74:	e8 7d 13 00 00       	call   4ff6 <exit>
  }
  if(unlink("dots") != 0){
    3c79:	83 ec 0c             	sub    $0xc,%esp
    3c7c:	68 de 66 00 00       	push   $0x66de
    3c81:	e8 c0 13 00 00       	call   5046 <unlink>
    3c86:	83 c4 10             	add    $0x10,%esp
    3c89:	85 c0                	test   %eax,%eax
    3c8b:	74 17                	je     3ca4 <rmdot+0x170>
    printf(1, "unlink dots failed!\n");
    3c8d:	83 ec 08             	sub    $0x8,%esp
    3c90:	68 64 67 00 00       	push   $0x6764
    3c95:	6a 01                	push   $0x1
    3c97:	e8 e1 14 00 00       	call   517d <printf>
    3c9c:	83 c4 10             	add    $0x10,%esp
    exit();
    3c9f:	e8 52 13 00 00       	call   4ff6 <exit>
  }
  printf(1, "rmdot ok\n");
    3ca4:	83 ec 08             	sub    $0x8,%esp
    3ca7:	68 79 67 00 00       	push   $0x6779
    3cac:	6a 01                	push   $0x1
    3cae:	e8 ca 14 00 00       	call   517d <printf>
    3cb3:	83 c4 10             	add    $0x10,%esp
}
    3cb6:	90                   	nop
    3cb7:	c9                   	leave  
    3cb8:	c3                   	ret    

00003cb9 <dirfile>:

void
dirfile(void)
{
    3cb9:	55                   	push   %ebp
    3cba:	89 e5                	mov    %esp,%ebp
    3cbc:	83 ec 18             	sub    $0x18,%esp
  int fd;

  printf(1, "dir vs file\n");
    3cbf:	83 ec 08             	sub    $0x8,%esp
    3cc2:	68 83 67 00 00       	push   $0x6783
    3cc7:	6a 01                	push   $0x1
    3cc9:	e8 af 14 00 00       	call   517d <printf>
    3cce:	83 c4 10             	add    $0x10,%esp

  fd = open("dirfile", O_CREATE);
    3cd1:	83 ec 08             	sub    $0x8,%esp
    3cd4:	68 00 02 00 00       	push   $0x200
    3cd9:	68 90 67 00 00       	push   $0x6790
    3cde:	e8 53 13 00 00       	call   5036 <open>
    3ce3:	83 c4 10             	add    $0x10,%esp
    3ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    3ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3ced:	79 17                	jns    3d06 <dirfile+0x4d>
    printf(1, "create dirfile failed\n");
    3cef:	83 ec 08             	sub    $0x8,%esp
    3cf2:	68 98 67 00 00       	push   $0x6798
    3cf7:	6a 01                	push   $0x1
    3cf9:	e8 7f 14 00 00       	call   517d <printf>
    3cfe:	83 c4 10             	add    $0x10,%esp
    exit();
    3d01:	e8 f0 12 00 00       	call   4ff6 <exit>
  }
  close(fd);
    3d06:	83 ec 0c             	sub    $0xc,%esp
    3d09:	ff 75 f4             	pushl  -0xc(%ebp)
    3d0c:	e8 0d 13 00 00       	call   501e <close>
    3d11:	83 c4 10             	add    $0x10,%esp
  if(chdir("dirfile") == 0){
    3d14:	83 ec 0c             	sub    $0xc,%esp
    3d17:	68 90 67 00 00       	push   $0x6790
    3d1c:	e8 45 13 00 00       	call   5066 <chdir>
    3d21:	83 c4 10             	add    $0x10,%esp
    3d24:	85 c0                	test   %eax,%eax
    3d26:	75 17                	jne    3d3f <dirfile+0x86>
    printf(1, "chdir dirfile succeeded!\n");
    3d28:	83 ec 08             	sub    $0x8,%esp
    3d2b:	68 af 67 00 00       	push   $0x67af
    3d30:	6a 01                	push   $0x1
    3d32:	e8 46 14 00 00       	call   517d <printf>
    3d37:	83 c4 10             	add    $0x10,%esp
    exit();
    3d3a:	e8 b7 12 00 00       	call   4ff6 <exit>
  }
  fd = open("dirfile/xx", 0);
    3d3f:	83 ec 08             	sub    $0x8,%esp
    3d42:	6a 00                	push   $0x0
    3d44:	68 c9 67 00 00       	push   $0x67c9
    3d49:	e8 e8 12 00 00       	call   5036 <open>
    3d4e:	83 c4 10             	add    $0x10,%esp
    3d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    3d54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3d58:	78 17                	js     3d71 <dirfile+0xb8>
    printf(1, "create dirfile/xx succeeded!\n");
    3d5a:	83 ec 08             	sub    $0x8,%esp
    3d5d:	68 d4 67 00 00       	push   $0x67d4
    3d62:	6a 01                	push   $0x1
    3d64:	e8 14 14 00 00       	call   517d <printf>
    3d69:	83 c4 10             	add    $0x10,%esp
    exit();
    3d6c:	e8 85 12 00 00       	call   4ff6 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    3d71:	83 ec 08             	sub    $0x8,%esp
    3d74:	68 00 02 00 00       	push   $0x200
    3d79:	68 c9 67 00 00       	push   $0x67c9
    3d7e:	e8 b3 12 00 00       	call   5036 <open>
    3d83:	83 c4 10             	add    $0x10,%esp
    3d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    3d89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3d8d:	78 17                	js     3da6 <dirfile+0xed>
    printf(1, "create dirfile/xx succeeded!\n");
    3d8f:	83 ec 08             	sub    $0x8,%esp
    3d92:	68 d4 67 00 00       	push   $0x67d4
    3d97:	6a 01                	push   $0x1
    3d99:	e8 df 13 00 00       	call   517d <printf>
    3d9e:	83 c4 10             	add    $0x10,%esp
    exit();
    3da1:	e8 50 12 00 00       	call   4ff6 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    3da6:	83 ec 0c             	sub    $0xc,%esp
    3da9:	68 c9 67 00 00       	push   $0x67c9
    3dae:	e8 ab 12 00 00       	call   505e <mkdir>
    3db3:	83 c4 10             	add    $0x10,%esp
    3db6:	85 c0                	test   %eax,%eax
    3db8:	75 17                	jne    3dd1 <dirfile+0x118>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    3dba:	83 ec 08             	sub    $0x8,%esp
    3dbd:	68 f2 67 00 00       	push   $0x67f2
    3dc2:	6a 01                	push   $0x1
    3dc4:	e8 b4 13 00 00       	call   517d <printf>
    3dc9:	83 c4 10             	add    $0x10,%esp
    exit();
    3dcc:	e8 25 12 00 00       	call   4ff6 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    3dd1:	83 ec 0c             	sub    $0xc,%esp
    3dd4:	68 c9 67 00 00       	push   $0x67c9
    3dd9:	e8 68 12 00 00       	call   5046 <unlink>
    3dde:	83 c4 10             	add    $0x10,%esp
    3de1:	85 c0                	test   %eax,%eax
    3de3:	75 17                	jne    3dfc <dirfile+0x143>
    printf(1, "unlink dirfile/xx succeeded!\n");
    3de5:	83 ec 08             	sub    $0x8,%esp
    3de8:	68 0f 68 00 00       	push   $0x680f
    3ded:	6a 01                	push   $0x1
    3def:	e8 89 13 00 00       	call   517d <printf>
    3df4:	83 c4 10             	add    $0x10,%esp
    exit();
    3df7:	e8 fa 11 00 00       	call   4ff6 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    3dfc:	83 ec 08             	sub    $0x8,%esp
    3dff:	68 c9 67 00 00       	push   $0x67c9
    3e04:	68 2d 68 00 00       	push   $0x682d
    3e09:	e8 48 12 00 00       	call   5056 <link>
    3e0e:	83 c4 10             	add    $0x10,%esp
    3e11:	85 c0                	test   %eax,%eax
    3e13:	75 17                	jne    3e2c <dirfile+0x173>
    printf(1, "link to dirfile/xx succeeded!\n");
    3e15:	83 ec 08             	sub    $0x8,%esp
    3e18:	68 34 68 00 00       	push   $0x6834
    3e1d:	6a 01                	push   $0x1
    3e1f:	e8 59 13 00 00       	call   517d <printf>
    3e24:	83 c4 10             	add    $0x10,%esp
    exit();
    3e27:	e8 ca 11 00 00       	call   4ff6 <exit>
  }
  if(unlink("dirfile") != 0){
    3e2c:	83 ec 0c             	sub    $0xc,%esp
    3e2f:	68 90 67 00 00       	push   $0x6790
    3e34:	e8 0d 12 00 00       	call   5046 <unlink>
    3e39:	83 c4 10             	add    $0x10,%esp
    3e3c:	85 c0                	test   %eax,%eax
    3e3e:	74 17                	je     3e57 <dirfile+0x19e>
    printf(1, "unlink dirfile failed!\n");
    3e40:	83 ec 08             	sub    $0x8,%esp
    3e43:	68 53 68 00 00       	push   $0x6853
    3e48:	6a 01                	push   $0x1
    3e4a:	e8 2e 13 00 00       	call   517d <printf>
    3e4f:	83 c4 10             	add    $0x10,%esp
    exit();
    3e52:	e8 9f 11 00 00       	call   4ff6 <exit>
  }

  fd = open(".", O_RDWR);
    3e57:	83 ec 08             	sub    $0x8,%esp
    3e5a:	6a 02                	push   $0x2
    3e5c:	68 0f 5e 00 00       	push   $0x5e0f
    3e61:	e8 d0 11 00 00       	call   5036 <open>
    3e66:	83 c4 10             	add    $0x10,%esp
    3e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    3e6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3e70:	78 17                	js     3e89 <dirfile+0x1d0>
    printf(1, "open . for writing succeeded!\n");
    3e72:	83 ec 08             	sub    $0x8,%esp
    3e75:	68 6c 68 00 00       	push   $0x686c
    3e7a:	6a 01                	push   $0x1
    3e7c:	e8 fc 12 00 00       	call   517d <printf>
    3e81:	83 c4 10             	add    $0x10,%esp
    exit();
    3e84:	e8 6d 11 00 00       	call   4ff6 <exit>
  }
  fd = open(".", 0);
    3e89:	83 ec 08             	sub    $0x8,%esp
    3e8c:	6a 00                	push   $0x0
    3e8e:	68 0f 5e 00 00       	push   $0x5e0f
    3e93:	e8 9e 11 00 00       	call   5036 <open>
    3e98:	83 c4 10             	add    $0x10,%esp
    3e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    3e9e:	83 ec 04             	sub    $0x4,%esp
    3ea1:	6a 01                	push   $0x1
    3ea3:	68 5b 5a 00 00       	push   $0x5a5b
    3ea8:	ff 75 f4             	pushl  -0xc(%ebp)
    3eab:	e8 66 11 00 00       	call   5016 <write>
    3eb0:	83 c4 10             	add    $0x10,%esp
    3eb3:	85 c0                	test   %eax,%eax
    3eb5:	7e 17                	jle    3ece <dirfile+0x215>
    printf(1, "write . succeeded!\n");
    3eb7:	83 ec 08             	sub    $0x8,%esp
    3eba:	68 8b 68 00 00       	push   $0x688b
    3ebf:	6a 01                	push   $0x1
    3ec1:	e8 b7 12 00 00       	call   517d <printf>
    3ec6:	83 c4 10             	add    $0x10,%esp
    exit();
    3ec9:	e8 28 11 00 00       	call   4ff6 <exit>
  }
  close(fd);
    3ece:	83 ec 0c             	sub    $0xc,%esp
    3ed1:	ff 75 f4             	pushl  -0xc(%ebp)
    3ed4:	e8 45 11 00 00       	call   501e <close>
    3ed9:	83 c4 10             	add    $0x10,%esp

  printf(1, "dir vs file OK\n");
    3edc:	83 ec 08             	sub    $0x8,%esp
    3edf:	68 9f 68 00 00       	push   $0x689f
    3ee4:	6a 01                	push   $0x1
    3ee6:	e8 92 12 00 00       	call   517d <printf>
    3eeb:	83 c4 10             	add    $0x10,%esp
}
    3eee:	90                   	nop
    3eef:	c9                   	leave  
    3ef0:	c3                   	ret    

00003ef1 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    3ef1:	55                   	push   %ebp
    3ef2:	89 e5                	mov    %esp,%ebp
    3ef4:	83 ec 18             	sub    $0x18,%esp
  int i, fd;

  printf(1, "empty file name\n");
    3ef7:	83 ec 08             	sub    $0x8,%esp
    3efa:	68 af 68 00 00       	push   $0x68af
    3eff:	6a 01                	push   $0x1
    3f01:	e8 77 12 00 00       	call   517d <printf>
    3f06:	83 c4 10             	add    $0x10,%esp

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    3f09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3f10:	e9 e7 00 00 00       	jmp    3ffc <iref+0x10b>
    if(mkdir("irefd") != 0){
    3f15:	83 ec 0c             	sub    $0xc,%esp
    3f18:	68 c0 68 00 00       	push   $0x68c0
    3f1d:	e8 3c 11 00 00       	call   505e <mkdir>
    3f22:	83 c4 10             	add    $0x10,%esp
    3f25:	85 c0                	test   %eax,%eax
    3f27:	74 17                	je     3f40 <iref+0x4f>
      printf(1, "mkdir irefd failed\n");
    3f29:	83 ec 08             	sub    $0x8,%esp
    3f2c:	68 c6 68 00 00       	push   $0x68c6
    3f31:	6a 01                	push   $0x1
    3f33:	e8 45 12 00 00       	call   517d <printf>
    3f38:	83 c4 10             	add    $0x10,%esp
      exit();
    3f3b:	e8 b6 10 00 00       	call   4ff6 <exit>
    }
    if(chdir("irefd") != 0){
    3f40:	83 ec 0c             	sub    $0xc,%esp
    3f43:	68 c0 68 00 00       	push   $0x68c0
    3f48:	e8 19 11 00 00       	call   5066 <chdir>
    3f4d:	83 c4 10             	add    $0x10,%esp
    3f50:	85 c0                	test   %eax,%eax
    3f52:	74 17                	je     3f6b <iref+0x7a>
      printf(1, "chdir irefd failed\n");
    3f54:	83 ec 08             	sub    $0x8,%esp
    3f57:	68 da 68 00 00       	push   $0x68da
    3f5c:	6a 01                	push   $0x1
    3f5e:	e8 1a 12 00 00       	call   517d <printf>
    3f63:	83 c4 10             	add    $0x10,%esp
      exit();
    3f66:	e8 8b 10 00 00       	call   4ff6 <exit>
    }

    mkdir("");
    3f6b:	83 ec 0c             	sub    $0xc,%esp
    3f6e:	68 ee 68 00 00       	push   $0x68ee
    3f73:	e8 e6 10 00 00       	call   505e <mkdir>
    3f78:	83 c4 10             	add    $0x10,%esp
    link("README", "");
    3f7b:	83 ec 08             	sub    $0x8,%esp
    3f7e:	68 ee 68 00 00       	push   $0x68ee
    3f83:	68 2d 68 00 00       	push   $0x682d
    3f88:	e8 c9 10 00 00       	call   5056 <link>
    3f8d:	83 c4 10             	add    $0x10,%esp
    fd = open("", O_CREATE);
    3f90:	83 ec 08             	sub    $0x8,%esp
    3f93:	68 00 02 00 00       	push   $0x200
    3f98:	68 ee 68 00 00       	push   $0x68ee
    3f9d:	e8 94 10 00 00       	call   5036 <open>
    3fa2:	83 c4 10             	add    $0x10,%esp
    3fa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    3fa8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3fac:	78 0e                	js     3fbc <iref+0xcb>
      close(fd);
    3fae:	83 ec 0c             	sub    $0xc,%esp
    3fb1:	ff 75 f0             	pushl  -0x10(%ebp)
    3fb4:	e8 65 10 00 00       	call   501e <close>
    3fb9:	83 c4 10             	add    $0x10,%esp
    fd = open("xx", O_CREATE);
    3fbc:	83 ec 08             	sub    $0x8,%esp
    3fbf:	68 00 02 00 00       	push   $0x200
    3fc4:	68 ef 68 00 00       	push   $0x68ef
    3fc9:	e8 68 10 00 00       	call   5036 <open>
    3fce:	83 c4 10             	add    $0x10,%esp
    3fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    3fd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3fd8:	78 0e                	js     3fe8 <iref+0xf7>
      close(fd);
    3fda:	83 ec 0c             	sub    $0xc,%esp
    3fdd:	ff 75 f0             	pushl  -0x10(%ebp)
    3fe0:	e8 39 10 00 00       	call   501e <close>
    3fe5:	83 c4 10             	add    $0x10,%esp
    unlink("xx");
    3fe8:	83 ec 0c             	sub    $0xc,%esp
    3feb:	68 ef 68 00 00       	push   $0x68ef
    3ff0:	e8 51 10 00 00       	call   5046 <unlink>
    3ff5:	83 c4 10             	add    $0x10,%esp
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    3ff8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3ffc:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    4000:	0f 8e 0f ff ff ff    	jle    3f15 <iref+0x24>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    4006:	83 ec 0c             	sub    $0xc,%esp
    4009:	68 f6 55 00 00       	push   $0x55f6
    400e:	e8 53 10 00 00       	call   5066 <chdir>
    4013:	83 c4 10             	add    $0x10,%esp
  printf(1, "empty file name OK\n");
    4016:	83 ec 08             	sub    $0x8,%esp
    4019:	68 f2 68 00 00       	push   $0x68f2
    401e:	6a 01                	push   $0x1
    4020:	e8 58 11 00 00       	call   517d <printf>
    4025:	83 c4 10             	add    $0x10,%esp
}
    4028:	90                   	nop
    4029:	c9                   	leave  
    402a:	c3                   	ret    

0000402b <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    402b:	55                   	push   %ebp
    402c:	89 e5                	mov    %esp,%ebp
    402e:	83 ec 18             	sub    $0x18,%esp
  int n, pid;

  printf(1, "fork test\n");
    4031:	83 ec 08             	sub    $0x8,%esp
    4034:	68 06 69 00 00       	push   $0x6906
    4039:	6a 01                	push   $0x1
    403b:	e8 3d 11 00 00       	call   517d <printf>
    4040:	83 c4 10             	add    $0x10,%esp

  for(n=0; n<1000; n++){
    4043:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    404a:	eb 1d                	jmp    4069 <forktest+0x3e>
    pid = fork();
    404c:	e8 9d 0f 00 00       	call   4fee <fork>
    4051:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    4054:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4058:	78 1a                	js     4074 <forktest+0x49>
      break;
    if(pid == 0)
    405a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    405e:	75 05                	jne    4065 <forktest+0x3a>
      exit();
    4060:	e8 91 0f 00 00       	call   4ff6 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    4065:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    4069:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    4070:	7e da                	jle    404c <forktest+0x21>
    4072:	eb 01                	jmp    4075 <forktest+0x4a>
    pid = fork();
    if(pid < 0)
      break;
    4074:	90                   	nop
    if(pid == 0)
      exit();
  }

  if(n == 1000){
    4075:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    407c:	75 3b                	jne    40b9 <forktest+0x8e>
    printf(1, "fork claimed to work 1000 times!\n");
    407e:	83 ec 08             	sub    $0x8,%esp
    4081:	68 14 69 00 00       	push   $0x6914
    4086:	6a 01                	push   $0x1
    4088:	e8 f0 10 00 00       	call   517d <printf>
    408d:	83 c4 10             	add    $0x10,%esp
    exit();
    4090:	e8 61 0f 00 00       	call   4ff6 <exit>
  }

  for(; n > 0; n--){
    if(wait() < 0){
    4095:	e8 64 0f 00 00       	call   4ffe <wait>
    409a:	85 c0                	test   %eax,%eax
    409c:	79 17                	jns    40b5 <forktest+0x8a>
      printf(1, "wait stopped early\n");
    409e:	83 ec 08             	sub    $0x8,%esp
    40a1:	68 36 69 00 00       	push   $0x6936
    40a6:	6a 01                	push   $0x1
    40a8:	e8 d0 10 00 00       	call   517d <printf>
    40ad:	83 c4 10             	add    $0x10,%esp
      exit();
    40b0:	e8 41 0f 00 00       	call   4ff6 <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }

  for(; n > 0; n--){
    40b5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    40b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    40bd:	7f d6                	jg     4095 <forktest+0x6a>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
    40bf:	e8 3a 0f 00 00       	call   4ffe <wait>
    40c4:	83 f8 ff             	cmp    $0xffffffff,%eax
    40c7:	74 17                	je     40e0 <forktest+0xb5>
    printf(1, "wait got too many\n");
    40c9:	83 ec 08             	sub    $0x8,%esp
    40cc:	68 4a 69 00 00       	push   $0x694a
    40d1:	6a 01                	push   $0x1
    40d3:	e8 a5 10 00 00       	call   517d <printf>
    40d8:	83 c4 10             	add    $0x10,%esp
    exit();
    40db:	e8 16 0f 00 00       	call   4ff6 <exit>
  }

  printf(1, "fork test OK\n");
    40e0:	83 ec 08             	sub    $0x8,%esp
    40e3:	68 5d 69 00 00       	push   $0x695d
    40e8:	6a 01                	push   $0x1
    40ea:	e8 8e 10 00 00       	call   517d <printf>
    40ef:	83 c4 10             	add    $0x10,%esp
}
    40f2:	90                   	nop
    40f3:	c9                   	leave  
    40f4:	c3                   	ret    

000040f5 <sbrktest>:

void
sbrktest(void)
{
    40f5:	55                   	push   %ebp
    40f6:	89 e5                	mov    %esp,%ebp
    40f8:	53                   	push   %ebx
    40f9:	83 ec 64             	sub    $0x64,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    40fc:	a1 40 75 00 00       	mov    0x7540,%eax
    4101:	83 ec 08             	sub    $0x8,%esp
    4104:	68 6b 69 00 00       	push   $0x696b
    4109:	50                   	push   %eax
    410a:	e8 6e 10 00 00       	call   517d <printf>
    410f:	83 c4 10             	add    $0x10,%esp
  oldbrk = sbrk(0);
    4112:	83 ec 0c             	sub    $0xc,%esp
    4115:	6a 00                	push   $0x0
    4117:	e8 62 0f 00 00       	call   507e <sbrk>
    411c:	83 c4 10             	add    $0x10,%esp
    411f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    4122:	83 ec 0c             	sub    $0xc,%esp
    4125:	6a 00                	push   $0x0
    4127:	e8 52 0f 00 00       	call   507e <sbrk>
    412c:	83 c4 10             	add    $0x10,%esp
    412f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){
    4132:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4139:	eb 4f                	jmp    418a <sbrktest+0x95>
    b = sbrk(1);
    413b:	83 ec 0c             	sub    $0xc,%esp
    413e:	6a 01                	push   $0x1
    4140:	e8 39 0f 00 00       	call   507e <sbrk>
    4145:	83 c4 10             	add    $0x10,%esp
    4148:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    414b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    414e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    4151:	74 24                	je     4177 <sbrktest+0x82>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    4153:	a1 40 75 00 00       	mov    0x7540,%eax
    4158:	83 ec 0c             	sub    $0xc,%esp
    415b:	ff 75 e8             	pushl  -0x18(%ebp)
    415e:	ff 75 f4             	pushl  -0xc(%ebp)
    4161:	ff 75 f0             	pushl  -0x10(%ebp)
    4164:	68 76 69 00 00       	push   $0x6976
    4169:	50                   	push   %eax
    416a:	e8 0e 10 00 00       	call   517d <printf>
    416f:	83 c4 20             	add    $0x20,%esp
      exit();
    4172:	e8 7f 0e 00 00       	call   4ff6 <exit>
    }
    *b = 1;
    4177:	8b 45 e8             	mov    -0x18(%ebp),%eax
    417a:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    417d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4180:	83 c0 01             	add    $0x1,%eax
    4183:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
    4186:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    418a:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    4191:	7e a8                	jle    413b <sbrktest+0x46>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    4193:	e8 56 0e 00 00       	call   4fee <fork>
    4198:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    419b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    419f:	79 1b                	jns    41bc <sbrktest+0xc7>
    printf(stdout, "sbrk test fork failed\n");
    41a1:	a1 40 75 00 00       	mov    0x7540,%eax
    41a6:	83 ec 08             	sub    $0x8,%esp
    41a9:	68 91 69 00 00       	push   $0x6991
    41ae:	50                   	push   %eax
    41af:	e8 c9 0f 00 00       	call   517d <printf>
    41b4:	83 c4 10             	add    $0x10,%esp
    exit();
    41b7:	e8 3a 0e 00 00       	call   4ff6 <exit>
  }
  c = sbrk(1);
    41bc:	83 ec 0c             	sub    $0xc,%esp
    41bf:	6a 01                	push   $0x1
    41c1:	e8 b8 0e 00 00       	call   507e <sbrk>
    41c6:	83 c4 10             	add    $0x10,%esp
    41c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    41cc:	83 ec 0c             	sub    $0xc,%esp
    41cf:	6a 01                	push   $0x1
    41d1:	e8 a8 0e 00 00       	call   507e <sbrk>
    41d6:	83 c4 10             	add    $0x10,%esp
    41d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    41dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    41df:	83 c0 01             	add    $0x1,%eax
    41e2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    41e5:	74 1b                	je     4202 <sbrktest+0x10d>
    printf(stdout, "sbrk test failed post-fork\n");
    41e7:	a1 40 75 00 00       	mov    0x7540,%eax
    41ec:	83 ec 08             	sub    $0x8,%esp
    41ef:	68 a8 69 00 00       	push   $0x69a8
    41f4:	50                   	push   %eax
    41f5:	e8 83 0f 00 00       	call   517d <printf>
    41fa:	83 c4 10             	add    $0x10,%esp
    exit();
    41fd:	e8 f4 0d 00 00       	call   4ff6 <exit>
  }
  if(pid == 0)
    4202:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    4206:	75 05                	jne    420d <sbrktest+0x118>
    exit();
    4208:	e8 e9 0d 00 00       	call   4ff6 <exit>
  wait();
    420d:	e8 ec 0d 00 00       	call   4ffe <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    4212:	83 ec 0c             	sub    $0xc,%esp
    4215:	6a 00                	push   $0x0
    4217:	e8 62 0e 00 00       	call   507e <sbrk>
    421c:	83 c4 10             	add    $0x10,%esp
    421f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    4222:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4225:	ba 00 00 40 06       	mov    $0x6400000,%edx
    422a:	29 c2                	sub    %eax,%edx
    422c:	89 d0                	mov    %edx,%eax
    422e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    4231:	8b 45 dc             	mov    -0x24(%ebp),%eax
    4234:	83 ec 0c             	sub    $0xc,%esp
    4237:	50                   	push   %eax
    4238:	e8 41 0e 00 00       	call   507e <sbrk>
    423d:	83 c4 10             	add    $0x10,%esp
    4240:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) {
    4243:	8b 45 d8             	mov    -0x28(%ebp),%eax
    4246:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    4249:	74 1b                	je     4266 <sbrktest+0x171>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    424b:	a1 40 75 00 00       	mov    0x7540,%eax
    4250:	83 ec 08             	sub    $0x8,%esp
    4253:	68 c4 69 00 00       	push   $0x69c4
    4258:	50                   	push   %eax
    4259:	e8 1f 0f 00 00       	call   517d <printf>
    425e:	83 c4 10             	add    $0x10,%esp
    exit();
    4261:	e8 90 0d 00 00       	call   4ff6 <exit>
  }
  lastaddr = (char*) (BIG-1);
    4266:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    426d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    4270:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    4273:	83 ec 0c             	sub    $0xc,%esp
    4276:	6a 00                	push   $0x0
    4278:	e8 01 0e 00 00       	call   507e <sbrk>
    427d:	83 c4 10             	add    $0x10,%esp
    4280:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    4283:	83 ec 0c             	sub    $0xc,%esp
    4286:	68 00 f0 ff ff       	push   $0xfffff000
    428b:	e8 ee 0d 00 00       	call   507e <sbrk>
    4290:	83 c4 10             	add    $0x10,%esp
    4293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    4296:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    429a:	75 1b                	jne    42b7 <sbrktest+0x1c2>
    printf(stdout, "sbrk could not deallocate\n");
    429c:	a1 40 75 00 00       	mov    0x7540,%eax
    42a1:	83 ec 08             	sub    $0x8,%esp
    42a4:	68 02 6a 00 00       	push   $0x6a02
    42a9:	50                   	push   %eax
    42aa:	e8 ce 0e 00 00       	call   517d <printf>
    42af:	83 c4 10             	add    $0x10,%esp
    exit();
    42b2:	e8 3f 0d 00 00       	call   4ff6 <exit>
  }
  c = sbrk(0);
    42b7:	83 ec 0c             	sub    $0xc,%esp
    42ba:	6a 00                	push   $0x0
    42bc:	e8 bd 0d 00 00       	call   507e <sbrk>
    42c1:	83 c4 10             	add    $0x10,%esp
    42c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    42c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42ca:	2d 00 10 00 00       	sub    $0x1000,%eax
    42cf:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    42d2:	74 1e                	je     42f2 <sbrktest+0x1fd>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    42d4:	a1 40 75 00 00       	mov    0x7540,%eax
    42d9:	ff 75 e0             	pushl  -0x20(%ebp)
    42dc:	ff 75 f4             	pushl  -0xc(%ebp)
    42df:	68 20 6a 00 00       	push   $0x6a20
    42e4:	50                   	push   %eax
    42e5:	e8 93 0e 00 00       	call   517d <printf>
    42ea:	83 c4 10             	add    $0x10,%esp
    exit();
    42ed:	e8 04 0d 00 00       	call   4ff6 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    42f2:	83 ec 0c             	sub    $0xc,%esp
    42f5:	6a 00                	push   $0x0
    42f7:	e8 82 0d 00 00       	call   507e <sbrk>
    42fc:	83 c4 10             	add    $0x10,%esp
    42ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    4302:	83 ec 0c             	sub    $0xc,%esp
    4305:	68 00 10 00 00       	push   $0x1000
    430a:	e8 6f 0d 00 00       	call   507e <sbrk>
    430f:	83 c4 10             	add    $0x10,%esp
    4312:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    4315:	8b 45 e0             	mov    -0x20(%ebp),%eax
    4318:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    431b:	75 1b                	jne    4338 <sbrktest+0x243>
    431d:	83 ec 0c             	sub    $0xc,%esp
    4320:	6a 00                	push   $0x0
    4322:	e8 57 0d 00 00       	call   507e <sbrk>
    4327:	83 c4 10             	add    $0x10,%esp
    432a:	89 c2                	mov    %eax,%edx
    432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    432f:	05 00 10 00 00       	add    $0x1000,%eax
    4334:	39 c2                	cmp    %eax,%edx
    4336:	74 1e                	je     4356 <sbrktest+0x261>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    4338:	a1 40 75 00 00       	mov    0x7540,%eax
    433d:	ff 75 e0             	pushl  -0x20(%ebp)
    4340:	ff 75 f4             	pushl  -0xc(%ebp)
    4343:	68 58 6a 00 00       	push   $0x6a58
    4348:	50                   	push   %eax
    4349:	e8 2f 0e 00 00       	call   517d <printf>
    434e:	83 c4 10             	add    $0x10,%esp
    exit();
    4351:	e8 a0 0c 00 00       	call   4ff6 <exit>
  }
  if(*lastaddr == 99){
    4356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    4359:	0f b6 00             	movzbl (%eax),%eax
    435c:	3c 63                	cmp    $0x63,%al
    435e:	75 1b                	jne    437b <sbrktest+0x286>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    4360:	a1 40 75 00 00       	mov    0x7540,%eax
    4365:	83 ec 08             	sub    $0x8,%esp
    4368:	68 80 6a 00 00       	push   $0x6a80
    436d:	50                   	push   %eax
    436e:	e8 0a 0e 00 00       	call   517d <printf>
    4373:	83 c4 10             	add    $0x10,%esp
    exit();
    4376:	e8 7b 0c 00 00       	call   4ff6 <exit>
  }

  a = sbrk(0);
    437b:	83 ec 0c             	sub    $0xc,%esp
    437e:	6a 00                	push   $0x0
    4380:	e8 f9 0c 00 00       	call   507e <sbrk>
    4385:	83 c4 10             	add    $0x10,%esp
    4388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    438b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    438e:	83 ec 0c             	sub    $0xc,%esp
    4391:	6a 00                	push   $0x0
    4393:	e8 e6 0c 00 00       	call   507e <sbrk>
    4398:	83 c4 10             	add    $0x10,%esp
    439b:	29 c3                	sub    %eax,%ebx
    439d:	89 d8                	mov    %ebx,%eax
    439f:	83 ec 0c             	sub    $0xc,%esp
    43a2:	50                   	push   %eax
    43a3:	e8 d6 0c 00 00       	call   507e <sbrk>
    43a8:	83 c4 10             	add    $0x10,%esp
    43ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    43ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
    43b1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    43b4:	74 1e                	je     43d4 <sbrktest+0x2df>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    43b6:	a1 40 75 00 00       	mov    0x7540,%eax
    43bb:	ff 75 e0             	pushl  -0x20(%ebp)
    43be:	ff 75 f4             	pushl  -0xc(%ebp)
    43c1:	68 b0 6a 00 00       	push   $0x6ab0
    43c6:	50                   	push   %eax
    43c7:	e8 b1 0d 00 00       	call   517d <printf>
    43cc:	83 c4 10             	add    $0x10,%esp
    exit();
    43cf:	e8 22 0c 00 00       	call   4ff6 <exit>
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    43d4:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    43db:	eb 76                	jmp    4453 <sbrktest+0x35e>
    ppid = getpid();
    43dd:	e8 94 0c 00 00       	call   5076 <getpid>
    43e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    43e5:	e8 04 0c 00 00       	call   4fee <fork>
    43ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    43ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    43f1:	79 1b                	jns    440e <sbrktest+0x319>
      printf(stdout, "fork failed\n");
    43f3:	a1 40 75 00 00       	mov    0x7540,%eax
    43f8:	83 ec 08             	sub    $0x8,%esp
    43fb:	68 25 56 00 00       	push   $0x5625
    4400:	50                   	push   %eax
    4401:	e8 77 0d 00 00       	call   517d <printf>
    4406:	83 c4 10             	add    $0x10,%esp
      exit();
    4409:	e8 e8 0b 00 00       	call   4ff6 <exit>
    }
    if(pid == 0){
    440e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    4412:	75 33                	jne    4447 <sbrktest+0x352>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    4414:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4417:	0f b6 00             	movzbl (%eax),%eax
    441a:	0f be d0             	movsbl %al,%edx
    441d:	a1 40 75 00 00       	mov    0x7540,%eax
    4422:	52                   	push   %edx
    4423:	ff 75 f4             	pushl  -0xc(%ebp)
    4426:	68 d1 6a 00 00       	push   $0x6ad1
    442b:	50                   	push   %eax
    442c:	e8 4c 0d 00 00       	call   517d <printf>
    4431:	83 c4 10             	add    $0x10,%esp
      kill(ppid);
    4434:	83 ec 0c             	sub    $0xc,%esp
    4437:	ff 75 d0             	pushl  -0x30(%ebp)
    443a:	e8 e7 0b 00 00       	call   5026 <kill>
    443f:	83 c4 10             	add    $0x10,%esp
      exit();
    4442:	e8 af 0b 00 00       	call   4ff6 <exit>
    }
    wait();
    4447:	e8 b2 0b 00 00       	call   4ffe <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    444c:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    4453:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    445a:	76 81                	jbe    43dd <sbrktest+0x2e8>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    445c:	83 ec 0c             	sub    $0xc,%esp
    445f:	8d 45 c8             	lea    -0x38(%ebp),%eax
    4462:	50                   	push   %eax
    4463:	e8 9e 0b 00 00       	call   5006 <pipe>
    4468:	83 c4 10             	add    $0x10,%esp
    446b:	85 c0                	test   %eax,%eax
    446d:	74 17                	je     4486 <sbrktest+0x391>
    printf(1, "pipe() failed\n");
    446f:	83 ec 08             	sub    $0x8,%esp
    4472:	68 f6 59 00 00       	push   $0x59f6
    4477:	6a 01                	push   $0x1
    4479:	e8 ff 0c 00 00       	call   517d <printf>
    447e:	83 c4 10             	add    $0x10,%esp
    exit();
    4481:	e8 70 0b 00 00       	call   4ff6 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4486:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    448d:	e9 88 00 00 00       	jmp    451a <sbrktest+0x425>
    if((pids[i] = fork()) == 0){
    4492:	e8 57 0b 00 00       	call   4fee <fork>
    4497:	89 c2                	mov    %eax,%edx
    4499:	8b 45 f0             	mov    -0x10(%ebp),%eax
    449c:	89 54 85 a0          	mov    %edx,-0x60(%ebp,%eax,4)
    44a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    44a3:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    44a7:	85 c0                	test   %eax,%eax
    44a9:	75 4a                	jne    44f5 <sbrktest+0x400>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    44ab:	83 ec 0c             	sub    $0xc,%esp
    44ae:	6a 00                	push   $0x0
    44b0:	e8 c9 0b 00 00       	call   507e <sbrk>
    44b5:	83 c4 10             	add    $0x10,%esp
    44b8:	ba 00 00 40 06       	mov    $0x6400000,%edx
    44bd:	29 c2                	sub    %eax,%edx
    44bf:	89 d0                	mov    %edx,%eax
    44c1:	83 ec 0c             	sub    $0xc,%esp
    44c4:	50                   	push   %eax
    44c5:	e8 b4 0b 00 00       	call   507e <sbrk>
    44ca:	83 c4 10             	add    $0x10,%esp
      write(fds[1], "x", 1);
    44cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
    44d0:	83 ec 04             	sub    $0x4,%esp
    44d3:	6a 01                	push   $0x1
    44d5:	68 5b 5a 00 00       	push   $0x5a5b
    44da:	50                   	push   %eax
    44db:	e8 36 0b 00 00       	call   5016 <write>
    44e0:	83 c4 10             	add    $0x10,%esp
      // sit around until killed
      for(;;) sleep(1000);
    44e3:	83 ec 0c             	sub    $0xc,%esp
    44e6:	68 e8 03 00 00       	push   $0x3e8
    44eb:	e8 96 0b 00 00       	call   5086 <sleep>
    44f0:	83 c4 10             	add    $0x10,%esp
    44f3:	eb ee                	jmp    44e3 <sbrktest+0x3ee>
    }
    if(pids[i] != -1)
    44f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    44f8:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    44fc:	83 f8 ff             	cmp    $0xffffffff,%eax
    44ff:	74 15                	je     4516 <sbrktest+0x421>
      read(fds[0], &scratch, 1);
    4501:	8b 45 c8             	mov    -0x38(%ebp),%eax
    4504:	83 ec 04             	sub    $0x4,%esp
    4507:	6a 01                	push   $0x1
    4509:	8d 55 9f             	lea    -0x61(%ebp),%edx
    450c:	52                   	push   %edx
    450d:	50                   	push   %eax
    450e:	e8 fb 0a 00 00       	call   500e <read>
    4513:	83 c4 10             	add    $0x10,%esp
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4516:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    451a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    451d:	83 f8 09             	cmp    $0x9,%eax
    4520:	0f 86 6c ff ff ff    	jbe    4492 <sbrktest+0x39d>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    4526:	83 ec 0c             	sub    $0xc,%esp
    4529:	68 00 10 00 00       	push   $0x1000
    452e:	e8 4b 0b 00 00       	call   507e <sbrk>
    4533:	83 c4 10             	add    $0x10,%esp
    4536:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4539:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4540:	eb 2b                	jmp    456d <sbrktest+0x478>
    if(pids[i] == -1)
    4542:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4545:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    4549:	83 f8 ff             	cmp    $0xffffffff,%eax
    454c:	74 1a                	je     4568 <sbrktest+0x473>
      continue;
    kill(pids[i]);
    454e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4551:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    4555:	83 ec 0c             	sub    $0xc,%esp
    4558:	50                   	push   %eax
    4559:	e8 c8 0a 00 00       	call   5026 <kill>
    455e:	83 c4 10             	add    $0x10,%esp
    wait();
    4561:	e8 98 0a 00 00       	call   4ffe <wait>
    4566:	eb 01                	jmp    4569 <sbrktest+0x474>
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
      continue;
    4568:	90                   	nop
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4569:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    456d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4570:	83 f8 09             	cmp    $0x9,%eax
    4573:	76 cd                	jbe    4542 <sbrktest+0x44d>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    4575:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    4579:	75 1b                	jne    4596 <sbrktest+0x4a1>
    printf(stdout, "failed sbrk leaked memory\n");
    457b:	a1 40 75 00 00       	mov    0x7540,%eax
    4580:	83 ec 08             	sub    $0x8,%esp
    4583:	68 ea 6a 00 00       	push   $0x6aea
    4588:	50                   	push   %eax
    4589:	e8 ef 0b 00 00       	call   517d <printf>
    458e:	83 c4 10             	add    $0x10,%esp
    exit();
    4591:	e8 60 0a 00 00       	call   4ff6 <exit>
  }

  if(sbrk(0) > oldbrk)
    4596:	83 ec 0c             	sub    $0xc,%esp
    4599:	6a 00                	push   $0x0
    459b:	e8 de 0a 00 00       	call   507e <sbrk>
    45a0:	83 c4 10             	add    $0x10,%esp
    45a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    45a6:	76 20                	jbe    45c8 <sbrktest+0x4d3>
    sbrk(-(sbrk(0) - oldbrk));
    45a8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    45ab:	83 ec 0c             	sub    $0xc,%esp
    45ae:	6a 00                	push   $0x0
    45b0:	e8 c9 0a 00 00       	call   507e <sbrk>
    45b5:	83 c4 10             	add    $0x10,%esp
    45b8:	29 c3                	sub    %eax,%ebx
    45ba:	89 d8                	mov    %ebx,%eax
    45bc:	83 ec 0c             	sub    $0xc,%esp
    45bf:	50                   	push   %eax
    45c0:	e8 b9 0a 00 00       	call   507e <sbrk>
    45c5:	83 c4 10             	add    $0x10,%esp

  printf(stdout, "sbrk test OK\n");
    45c8:	a1 40 75 00 00       	mov    0x7540,%eax
    45cd:	83 ec 08             	sub    $0x8,%esp
    45d0:	68 05 6b 00 00       	push   $0x6b05
    45d5:	50                   	push   %eax
    45d6:	e8 a2 0b 00 00       	call   517d <printf>
    45db:	83 c4 10             	add    $0x10,%esp
}
    45de:	90                   	nop
    45df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    45e2:	c9                   	leave  
    45e3:	c3                   	ret    

000045e4 <validateint>:

void
validateint(int *p)
{
    45e4:	55                   	push   %ebp
    45e5:	89 e5                	mov    %esp,%ebp
    45e7:	53                   	push   %ebx
    45e8:	83 ec 10             	sub    $0x10,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    45eb:	b8 0d 00 00 00       	mov    $0xd,%eax
    45f0:	8b 55 08             	mov    0x8(%ebp),%edx
    45f3:	89 d1                	mov    %edx,%ecx
    45f5:	89 e3                	mov    %esp,%ebx
    45f7:	89 cc                	mov    %ecx,%esp
    45f9:	cd 40                	int    $0x40
    45fb:	89 dc                	mov    %ebx,%esp
    45fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    4600:	90                   	nop
    4601:	83 c4 10             	add    $0x10,%esp
    4604:	5b                   	pop    %ebx
    4605:	5d                   	pop    %ebp
    4606:	c3                   	ret    

00004607 <validatetest>:

void
validatetest(void)
{
    4607:	55                   	push   %ebp
    4608:	89 e5                	mov    %esp,%ebp
    460a:	83 ec 18             	sub    $0x18,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    460d:	a1 40 75 00 00       	mov    0x7540,%eax
    4612:	83 ec 08             	sub    $0x8,%esp
    4615:	68 13 6b 00 00       	push   $0x6b13
    461a:	50                   	push   %eax
    461b:	e8 5d 0b 00 00       	call   517d <printf>
    4620:	83 c4 10             	add    $0x10,%esp
  hi = 1100*1024;
    4623:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    462a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    4631:	e9 8a 00 00 00       	jmp    46c0 <validatetest+0xb9>
    if((pid = fork()) == 0){
    4636:	e8 b3 09 00 00       	call   4fee <fork>
    463b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    463e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4642:	75 14                	jne    4658 <validatetest+0x51>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    4644:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4647:	83 ec 0c             	sub    $0xc,%esp
    464a:	50                   	push   %eax
    464b:	e8 94 ff ff ff       	call   45e4 <validateint>
    4650:	83 c4 10             	add    $0x10,%esp
      exit();
    4653:	e8 9e 09 00 00       	call   4ff6 <exit>
    }
    sleep(0);
    4658:	83 ec 0c             	sub    $0xc,%esp
    465b:	6a 00                	push   $0x0
    465d:	e8 24 0a 00 00       	call   5086 <sleep>
    4662:	83 c4 10             	add    $0x10,%esp
    sleep(0);
    4665:	83 ec 0c             	sub    $0xc,%esp
    4668:	6a 00                	push   $0x0
    466a:	e8 17 0a 00 00       	call   5086 <sleep>
    466f:	83 c4 10             	add    $0x10,%esp
    kill(pid);
    4672:	83 ec 0c             	sub    $0xc,%esp
    4675:	ff 75 ec             	pushl  -0x14(%ebp)
    4678:	e8 a9 09 00 00       	call   5026 <kill>
    467d:	83 c4 10             	add    $0x10,%esp
    wait();
    4680:	e8 79 09 00 00       	call   4ffe <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    4685:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4688:	83 ec 08             	sub    $0x8,%esp
    468b:	50                   	push   %eax
    468c:	68 22 6b 00 00       	push   $0x6b22
    4691:	e8 c0 09 00 00       	call   5056 <link>
    4696:	83 c4 10             	add    $0x10,%esp
    4699:	83 f8 ff             	cmp    $0xffffffff,%eax
    469c:	74 1b                	je     46b9 <validatetest+0xb2>
      printf(stdout, "link should not succeed\n");
    469e:	a1 40 75 00 00       	mov    0x7540,%eax
    46a3:	83 ec 08             	sub    $0x8,%esp
    46a6:	68 2d 6b 00 00       	push   $0x6b2d
    46ab:	50                   	push   %eax
    46ac:	e8 cc 0a 00 00       	call   517d <printf>
    46b1:	83 c4 10             	add    $0x10,%esp
      exit();
    46b4:	e8 3d 09 00 00       	call   4ff6 <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    46b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    46c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    46c3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    46c6:	0f 86 6a ff ff ff    	jbe    4636 <validatetest+0x2f>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    46cc:	a1 40 75 00 00       	mov    0x7540,%eax
    46d1:	83 ec 08             	sub    $0x8,%esp
    46d4:	68 46 6b 00 00       	push   $0x6b46
    46d9:	50                   	push   %eax
    46da:	e8 9e 0a 00 00       	call   517d <printf>
    46df:	83 c4 10             	add    $0x10,%esp
}
    46e2:	90                   	nop
    46e3:	c9                   	leave  
    46e4:	c3                   	ret    

000046e5 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    46e5:	55                   	push   %ebp
    46e6:	89 e5                	mov    %esp,%ebp
    46e8:	83 ec 18             	sub    $0x18,%esp
  int i;

  printf(stdout, "bss test\n");
    46eb:	a1 40 75 00 00       	mov    0x7540,%eax
    46f0:	83 ec 08             	sub    $0x8,%esp
    46f3:	68 53 6b 00 00       	push   $0x6b53
    46f8:	50                   	push   %eax
    46f9:	e8 7f 0a 00 00       	call   517d <printf>
    46fe:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < sizeof(uninit); i++){
    4701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    4708:	eb 2e                	jmp    4738 <bsstest+0x53>
    if(uninit[i] != '\0'){
    470a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    470d:	05 00 76 00 00       	add    $0x7600,%eax
    4712:	0f b6 00             	movzbl (%eax),%eax
    4715:	84 c0                	test   %al,%al
    4717:	74 1b                	je     4734 <bsstest+0x4f>
      printf(stdout, "bss test failed\n");
    4719:	a1 40 75 00 00       	mov    0x7540,%eax
    471e:	83 ec 08             	sub    $0x8,%esp
    4721:	68 5d 6b 00 00       	push   $0x6b5d
    4726:	50                   	push   %eax
    4727:	e8 51 0a 00 00       	call   517d <printf>
    472c:	83 c4 10             	add    $0x10,%esp
      exit();
    472f:	e8 c2 08 00 00       	call   4ff6 <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    4734:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    4738:	8b 45 f4             	mov    -0xc(%ebp),%eax
    473b:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    4740:	76 c8                	jbe    470a <bsstest+0x25>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    4742:	a1 40 75 00 00       	mov    0x7540,%eax
    4747:	83 ec 08             	sub    $0x8,%esp
    474a:	68 6e 6b 00 00       	push   $0x6b6e
    474f:	50                   	push   %eax
    4750:	e8 28 0a 00 00       	call   517d <printf>
    4755:	83 c4 10             	add    $0x10,%esp
}
    4758:	90                   	nop
    4759:	c9                   	leave  
    475a:	c3                   	ret    

0000475b <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    475b:	55                   	push   %ebp
    475c:	89 e5                	mov    %esp,%ebp
    475e:	83 ec 18             	sub    $0x18,%esp
  int pid, fd;

  unlink("bigarg-ok");
    4761:	83 ec 0c             	sub    $0xc,%esp
    4764:	68 7b 6b 00 00       	push   $0x6b7b
    4769:	e8 d8 08 00 00       	call   5046 <unlink>
    476e:	83 c4 10             	add    $0x10,%esp
  pid = fork();
    4771:	e8 78 08 00 00       	call   4fee <fork>
    4776:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    4779:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    477d:	0f 85 97 00 00 00    	jne    481a <bigargtest+0xbf>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    4783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    478a:	eb 12                	jmp    479e <bigargtest+0x43>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    478c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    478f:	c7 04 85 60 75 00 00 	movl   $0x6b88,0x7560(,%eax,4)
    4796:	88 6b 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    479a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    479e:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    47a2:	7e e8                	jle    478c <bigargtest+0x31>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    47a4:	c7 05 dc 75 00 00 00 	movl   $0x0,0x75dc
    47ab:	00 00 00 
    printf(stdout, "bigarg test\n");
    47ae:	a1 40 75 00 00       	mov    0x7540,%eax
    47b3:	83 ec 08             	sub    $0x8,%esp
    47b6:	68 65 6c 00 00       	push   $0x6c65
    47bb:	50                   	push   %eax
    47bc:	e8 bc 09 00 00       	call   517d <printf>
    47c1:	83 c4 10             	add    $0x10,%esp
    exec("echo", args);
    47c4:	83 ec 08             	sub    $0x8,%esp
    47c7:	68 60 75 00 00       	push   $0x7560
    47cc:	68 84 55 00 00       	push   $0x5584
    47d1:	e8 58 08 00 00       	call   502e <exec>
    47d6:	83 c4 10             	add    $0x10,%esp
    printf(stdout, "bigarg test ok\n");
    47d9:	a1 40 75 00 00       	mov    0x7540,%eax
    47de:	83 ec 08             	sub    $0x8,%esp
    47e1:	68 72 6c 00 00       	push   $0x6c72
    47e6:	50                   	push   %eax
    47e7:	e8 91 09 00 00       	call   517d <printf>
    47ec:	83 c4 10             	add    $0x10,%esp
    fd = open("bigarg-ok", O_CREATE);
    47ef:	83 ec 08             	sub    $0x8,%esp
    47f2:	68 00 02 00 00       	push   $0x200
    47f7:	68 7b 6b 00 00       	push   $0x6b7b
    47fc:	e8 35 08 00 00       	call   5036 <open>
    4801:	83 c4 10             	add    $0x10,%esp
    4804:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    4807:	83 ec 0c             	sub    $0xc,%esp
    480a:	ff 75 ec             	pushl  -0x14(%ebp)
    480d:	e8 0c 08 00 00       	call   501e <close>
    4812:	83 c4 10             	add    $0x10,%esp
    exit();
    4815:	e8 dc 07 00 00       	call   4ff6 <exit>
  } else if(pid < 0){
    481a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    481e:	79 1b                	jns    483b <bigargtest+0xe0>
    printf(stdout, "bigargtest: fork failed\n");
    4820:	a1 40 75 00 00       	mov    0x7540,%eax
    4825:	83 ec 08             	sub    $0x8,%esp
    4828:	68 82 6c 00 00       	push   $0x6c82
    482d:	50                   	push   %eax
    482e:	e8 4a 09 00 00       	call   517d <printf>
    4833:	83 c4 10             	add    $0x10,%esp
    exit();
    4836:	e8 bb 07 00 00       	call   4ff6 <exit>
  }
  wait();
    483b:	e8 be 07 00 00       	call   4ffe <wait>
  fd = open("bigarg-ok", 0);
    4840:	83 ec 08             	sub    $0x8,%esp
    4843:	6a 00                	push   $0x0
    4845:	68 7b 6b 00 00       	push   $0x6b7b
    484a:	e8 e7 07 00 00       	call   5036 <open>
    484f:	83 c4 10             	add    $0x10,%esp
    4852:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    4855:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4859:	79 1b                	jns    4876 <bigargtest+0x11b>
    printf(stdout, "bigarg test failed!\n");
    485b:	a1 40 75 00 00       	mov    0x7540,%eax
    4860:	83 ec 08             	sub    $0x8,%esp
    4863:	68 9b 6c 00 00       	push   $0x6c9b
    4868:	50                   	push   %eax
    4869:	e8 0f 09 00 00       	call   517d <printf>
    486e:	83 c4 10             	add    $0x10,%esp
    exit();
    4871:	e8 80 07 00 00       	call   4ff6 <exit>
  }
  close(fd);
    4876:	83 ec 0c             	sub    $0xc,%esp
    4879:	ff 75 ec             	pushl  -0x14(%ebp)
    487c:	e8 9d 07 00 00       	call   501e <close>
    4881:	83 c4 10             	add    $0x10,%esp
  unlink("bigarg-ok");
    4884:	83 ec 0c             	sub    $0xc,%esp
    4887:	68 7b 6b 00 00       	push   $0x6b7b
    488c:	e8 b5 07 00 00       	call   5046 <unlink>
    4891:	83 c4 10             	add    $0x10,%esp
}
    4894:	90                   	nop
    4895:	c9                   	leave  
    4896:	c3                   	ret    

00004897 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    4897:	55                   	push   %ebp
    4898:	89 e5                	mov    %esp,%ebp
    489a:	53                   	push   %ebx
    489b:	83 ec 64             	sub    $0x64,%esp
  int nfiles;
  int fsblocks = 0;
    489e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    48a5:	83 ec 08             	sub    $0x8,%esp
    48a8:	68 b0 6c 00 00       	push   $0x6cb0
    48ad:	6a 01                	push   $0x1
    48af:	e8 c9 08 00 00       	call   517d <printf>
    48b4:	83 c4 10             	add    $0x10,%esp

  for(nfiles = 0; ; nfiles++){
    48b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    48be:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    48c2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    48c5:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    48ca:	89 c8                	mov    %ecx,%eax
    48cc:	f7 ea                	imul   %edx
    48ce:	c1 fa 06             	sar    $0x6,%edx
    48d1:	89 c8                	mov    %ecx,%eax
    48d3:	c1 f8 1f             	sar    $0x1f,%eax
    48d6:	29 c2                	sub    %eax,%edx
    48d8:	89 d0                	mov    %edx,%eax
    48da:	83 c0 30             	add    $0x30,%eax
    48dd:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    48e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    48e3:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    48e8:	89 d8                	mov    %ebx,%eax
    48ea:	f7 ea                	imul   %edx
    48ec:	c1 fa 06             	sar    $0x6,%edx
    48ef:	89 d8                	mov    %ebx,%eax
    48f1:	c1 f8 1f             	sar    $0x1f,%eax
    48f4:	89 d1                	mov    %edx,%ecx
    48f6:	29 c1                	sub    %eax,%ecx
    48f8:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    48fe:	29 c3                	sub    %eax,%ebx
    4900:	89 d9                	mov    %ebx,%ecx
    4902:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    4907:	89 c8                	mov    %ecx,%eax
    4909:	f7 ea                	imul   %edx
    490b:	c1 fa 05             	sar    $0x5,%edx
    490e:	89 c8                	mov    %ecx,%eax
    4910:	c1 f8 1f             	sar    $0x1f,%eax
    4913:	29 c2                	sub    %eax,%edx
    4915:	89 d0                	mov    %edx,%eax
    4917:	83 c0 30             	add    $0x30,%eax
    491a:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    491d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    4920:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    4925:	89 d8                	mov    %ebx,%eax
    4927:	f7 ea                	imul   %edx
    4929:	c1 fa 05             	sar    $0x5,%edx
    492c:	89 d8                	mov    %ebx,%eax
    492e:	c1 f8 1f             	sar    $0x1f,%eax
    4931:	89 d1                	mov    %edx,%ecx
    4933:	29 c1                	sub    %eax,%ecx
    4935:	6b c1 64             	imul   $0x64,%ecx,%eax
    4938:	29 c3                	sub    %eax,%ebx
    493a:	89 d9                	mov    %ebx,%ecx
    493c:	ba 67 66 66 66       	mov    $0x66666667,%edx
    4941:	89 c8                	mov    %ecx,%eax
    4943:	f7 ea                	imul   %edx
    4945:	c1 fa 02             	sar    $0x2,%edx
    4948:	89 c8                	mov    %ecx,%eax
    494a:	c1 f8 1f             	sar    $0x1f,%eax
    494d:	29 c2                	sub    %eax,%edx
    494f:	89 d0                	mov    %edx,%eax
    4951:	83 c0 30             	add    $0x30,%eax
    4954:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    4957:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    495a:	ba 67 66 66 66       	mov    $0x66666667,%edx
    495f:	89 c8                	mov    %ecx,%eax
    4961:	f7 ea                	imul   %edx
    4963:	c1 fa 02             	sar    $0x2,%edx
    4966:	89 c8                	mov    %ecx,%eax
    4968:	c1 f8 1f             	sar    $0x1f,%eax
    496b:	29 c2                	sub    %eax,%edx
    496d:	89 d0                	mov    %edx,%eax
    496f:	c1 e0 02             	shl    $0x2,%eax
    4972:	01 d0                	add    %edx,%eax
    4974:	01 c0                	add    %eax,%eax
    4976:	29 c1                	sub    %eax,%ecx
    4978:	89 ca                	mov    %ecx,%edx
    497a:	89 d0                	mov    %edx,%eax
    497c:	83 c0 30             	add    $0x30,%eax
    497f:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    4982:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    4986:	83 ec 04             	sub    $0x4,%esp
    4989:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    498c:	50                   	push   %eax
    498d:	68 bd 6c 00 00       	push   $0x6cbd
    4992:	6a 01                	push   $0x1
    4994:	e8 e4 07 00 00       	call   517d <printf>
    4999:	83 c4 10             	add    $0x10,%esp
    int fd = open(name, O_CREATE|O_RDWR);
    499c:	83 ec 08             	sub    $0x8,%esp
    499f:	68 02 02 00 00       	push   $0x202
    49a4:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    49a7:	50                   	push   %eax
    49a8:	e8 89 06 00 00       	call   5036 <open>
    49ad:	83 c4 10             	add    $0x10,%esp
    49b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    49b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    49b7:	79 18                	jns    49d1 <fsfull+0x13a>
      printf(1, "open %s failed\n", name);
    49b9:	83 ec 04             	sub    $0x4,%esp
    49bc:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    49bf:	50                   	push   %eax
    49c0:	68 c9 6c 00 00       	push   $0x6cc9
    49c5:	6a 01                	push   $0x1
    49c7:	e8 b1 07 00 00       	call   517d <printf>
    49cc:	83 c4 10             	add    $0x10,%esp
      break;
    49cf:	eb 6b                	jmp    4a3c <fsfull+0x1a5>
    }
    int total = 0;
    49d1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    49d8:	83 ec 04             	sub    $0x4,%esp
    49db:	68 00 02 00 00       	push   $0x200
    49e0:	68 20 9d 00 00       	push   $0x9d20
    49e5:	ff 75 e8             	pushl  -0x18(%ebp)
    49e8:	e8 29 06 00 00       	call   5016 <write>
    49ed:	83 c4 10             	add    $0x10,%esp
    49f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    49f3:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    49fa:	7e 0c                	jle    4a08 <fsfull+0x171>
        break;
      total += cc;
    49fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    49ff:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    4a02:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    4a06:	eb d0                	jmp    49d8 <fsfull+0x141>
    }
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
    4a08:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    4a09:	83 ec 04             	sub    $0x4,%esp
    4a0c:	ff 75 ec             	pushl  -0x14(%ebp)
    4a0f:	68 d9 6c 00 00       	push   $0x6cd9
    4a14:	6a 01                	push   $0x1
    4a16:	e8 62 07 00 00       	call   517d <printf>
    4a1b:	83 c4 10             	add    $0x10,%esp
    close(fd);
    4a1e:	83 ec 0c             	sub    $0xc,%esp
    4a21:	ff 75 e8             	pushl  -0x18(%ebp)
    4a24:	e8 f5 05 00 00       	call   501e <close>
    4a29:	83 c4 10             	add    $0x10,%esp
    if(total == 0)
    4a2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4a30:	74 09                	je     4a3b <fsfull+0x1a4>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    4a32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    4a36:	e9 83 fe ff ff       	jmp    48be <fsfull+0x27>
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    4a3b:	90                   	nop
  }

  while(nfiles >= 0){
    4a3c:	e9 db 00 00 00       	jmp    4b1c <fsfull+0x285>
    char name[64];
    name[0] = 'f';
    4a41:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    4a45:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    4a48:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    4a4d:	89 c8                	mov    %ecx,%eax
    4a4f:	f7 ea                	imul   %edx
    4a51:	c1 fa 06             	sar    $0x6,%edx
    4a54:	89 c8                	mov    %ecx,%eax
    4a56:	c1 f8 1f             	sar    $0x1f,%eax
    4a59:	29 c2                	sub    %eax,%edx
    4a5b:	89 d0                	mov    %edx,%eax
    4a5d:	83 c0 30             	add    $0x30,%eax
    4a60:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    4a63:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    4a66:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    4a6b:	89 d8                	mov    %ebx,%eax
    4a6d:	f7 ea                	imul   %edx
    4a6f:	c1 fa 06             	sar    $0x6,%edx
    4a72:	89 d8                	mov    %ebx,%eax
    4a74:	c1 f8 1f             	sar    $0x1f,%eax
    4a77:	89 d1                	mov    %edx,%ecx
    4a79:	29 c1                	sub    %eax,%ecx
    4a7b:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    4a81:	29 c3                	sub    %eax,%ebx
    4a83:	89 d9                	mov    %ebx,%ecx
    4a85:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    4a8a:	89 c8                	mov    %ecx,%eax
    4a8c:	f7 ea                	imul   %edx
    4a8e:	c1 fa 05             	sar    $0x5,%edx
    4a91:	89 c8                	mov    %ecx,%eax
    4a93:	c1 f8 1f             	sar    $0x1f,%eax
    4a96:	29 c2                	sub    %eax,%edx
    4a98:	89 d0                	mov    %edx,%eax
    4a9a:	83 c0 30             	add    $0x30,%eax
    4a9d:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    4aa0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    4aa3:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    4aa8:	89 d8                	mov    %ebx,%eax
    4aaa:	f7 ea                	imul   %edx
    4aac:	c1 fa 05             	sar    $0x5,%edx
    4aaf:	89 d8                	mov    %ebx,%eax
    4ab1:	c1 f8 1f             	sar    $0x1f,%eax
    4ab4:	89 d1                	mov    %edx,%ecx
    4ab6:	29 c1                	sub    %eax,%ecx
    4ab8:	6b c1 64             	imul   $0x64,%ecx,%eax
    4abb:	29 c3                	sub    %eax,%ebx
    4abd:	89 d9                	mov    %ebx,%ecx
    4abf:	ba 67 66 66 66       	mov    $0x66666667,%edx
    4ac4:	89 c8                	mov    %ecx,%eax
    4ac6:	f7 ea                	imul   %edx
    4ac8:	c1 fa 02             	sar    $0x2,%edx
    4acb:	89 c8                	mov    %ecx,%eax
    4acd:	c1 f8 1f             	sar    $0x1f,%eax
    4ad0:	29 c2                	sub    %eax,%edx
    4ad2:	89 d0                	mov    %edx,%eax
    4ad4:	83 c0 30             	add    $0x30,%eax
    4ad7:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    4ada:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    4add:	ba 67 66 66 66       	mov    $0x66666667,%edx
    4ae2:	89 c8                	mov    %ecx,%eax
    4ae4:	f7 ea                	imul   %edx
    4ae6:	c1 fa 02             	sar    $0x2,%edx
    4ae9:	89 c8                	mov    %ecx,%eax
    4aeb:	c1 f8 1f             	sar    $0x1f,%eax
    4aee:	29 c2                	sub    %eax,%edx
    4af0:	89 d0                	mov    %edx,%eax
    4af2:	c1 e0 02             	shl    $0x2,%eax
    4af5:	01 d0                	add    %edx,%eax
    4af7:	01 c0                	add    %eax,%eax
    4af9:	29 c1                	sub    %eax,%ecx
    4afb:	89 ca                	mov    %ecx,%edx
    4afd:	89 d0                	mov    %edx,%eax
    4aff:	83 c0 30             	add    $0x30,%eax
    4b02:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    4b05:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    4b09:	83 ec 0c             	sub    $0xc,%esp
    4b0c:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    4b0f:	50                   	push   %eax
    4b10:	e8 31 05 00 00       	call   5046 <unlink>
    4b15:	83 c4 10             	add    $0x10,%esp
    nfiles--;
    4b18:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    4b1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4b20:	0f 89 1b ff ff ff    	jns    4a41 <fsfull+0x1aa>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    4b26:	83 ec 08             	sub    $0x8,%esp
    4b29:	68 e9 6c 00 00       	push   $0x6ce9
    4b2e:	6a 01                	push   $0x1
    4b30:	e8 48 06 00 00       	call   517d <printf>
    4b35:	83 c4 10             	add    $0x10,%esp
}
    4b38:	90                   	nop
    4b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    4b3c:	c9                   	leave  
    4b3d:	c3                   	ret    

00004b3e <uio>:

void
uio()
{
    4b3e:	55                   	push   %ebp
    4b3f:	89 e5                	mov    %esp,%ebp
    4b41:	83 ec 18             	sub    $0x18,%esp
  #define RTC_ADDR 0x70
  #define RTC_DATA 0x71

  ushort port = 0;
    4b44:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
  uchar val = 0;
    4b4a:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
  int pid;

  printf(1, "uio test\n");
    4b4e:	83 ec 08             	sub    $0x8,%esp
    4b51:	68 ff 6c 00 00       	push   $0x6cff
    4b56:	6a 01                	push   $0x1
    4b58:	e8 20 06 00 00       	call   517d <printf>
    4b5d:	83 c4 10             	add    $0x10,%esp
  pid = fork();
    4b60:	e8 89 04 00 00       	call   4fee <fork>
    4b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    4b68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4b6c:	75 3a                	jne    4ba8 <uio+0x6a>
    port = RTC_ADDR;
    4b6e:	66 c7 45 f6 70 00    	movw   $0x70,-0xa(%ebp)
    val = 0x09;  /* year */
    4b74:	c6 45 f5 09          	movb   $0x9,-0xb(%ebp)
    /* http://wiki.osdev.org/Inline_Assembly/Examples */
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    4b78:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    4b7c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
    4b80:	ee                   	out    %al,(%dx)
    port = RTC_DATA;
    4b81:	66 c7 45 f6 71 00    	movw   $0x71,-0xa(%ebp)
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    4b87:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
    4b8b:	89 c2                	mov    %eax,%edx
    4b8d:	ec                   	in     (%dx),%al
    4b8e:	88 45 f5             	mov    %al,-0xb(%ebp)
    printf(1, "uio: uio succeeded; test FAILED\n");
    4b91:	83 ec 08             	sub    $0x8,%esp
    4b94:	68 0c 6d 00 00       	push   $0x6d0c
    4b99:	6a 01                	push   $0x1
    4b9b:	e8 dd 05 00 00       	call   517d <printf>
    4ba0:	83 c4 10             	add    $0x10,%esp
    exit();
    4ba3:	e8 4e 04 00 00       	call   4ff6 <exit>
  } else if(pid < 0){
    4ba8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4bac:	79 17                	jns    4bc5 <uio+0x87>
    printf (1, "fork failed\n");
    4bae:	83 ec 08             	sub    $0x8,%esp
    4bb1:	68 25 56 00 00       	push   $0x5625
    4bb6:	6a 01                	push   $0x1
    4bb8:	e8 c0 05 00 00       	call   517d <printf>
    4bbd:	83 c4 10             	add    $0x10,%esp
    exit();
    4bc0:	e8 31 04 00 00       	call   4ff6 <exit>
  }
  wait();
    4bc5:	e8 34 04 00 00       	call   4ffe <wait>
  printf(1, "uio test done\n");
    4bca:	83 ec 08             	sub    $0x8,%esp
    4bcd:	68 2d 6d 00 00       	push   $0x6d2d
    4bd2:	6a 01                	push   $0x1
    4bd4:	e8 a4 05 00 00       	call   517d <printf>
    4bd9:	83 c4 10             	add    $0x10,%esp
}
    4bdc:	90                   	nop
    4bdd:	c9                   	leave  
    4bde:	c3                   	ret    

00004bdf <argptest>:

void argptest()
{
    4bdf:	55                   	push   %ebp
    4be0:	89 e5                	mov    %esp,%ebp
    4be2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  fd = open("init", O_RDONLY);
    4be5:	83 ec 08             	sub    $0x8,%esp
    4be8:	6a 00                	push   $0x0
    4bea:	68 3c 6d 00 00       	push   $0x6d3c
    4bef:	e8 42 04 00 00       	call   5036 <open>
    4bf4:	83 c4 10             	add    $0x10,%esp
    4bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (fd < 0) {
    4bfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4bfe:	79 17                	jns    4c17 <argptest+0x38>
    printf(2, "open failed\n");
    4c00:	83 ec 08             	sub    $0x8,%esp
    4c03:	68 41 6d 00 00       	push   $0x6d41
    4c08:	6a 02                	push   $0x2
    4c0a:	e8 6e 05 00 00       	call   517d <printf>
    4c0f:	83 c4 10             	add    $0x10,%esp
    exit();
    4c12:	e8 df 03 00 00       	call   4ff6 <exit>
  }
  read(fd, sbrk(0) - 1, -1);
    4c17:	83 ec 0c             	sub    $0xc,%esp
    4c1a:	6a 00                	push   $0x0
    4c1c:	e8 5d 04 00 00       	call   507e <sbrk>
    4c21:	83 c4 10             	add    $0x10,%esp
    4c24:	83 e8 01             	sub    $0x1,%eax
    4c27:	83 ec 04             	sub    $0x4,%esp
    4c2a:	6a ff                	push   $0xffffffff
    4c2c:	50                   	push   %eax
    4c2d:	ff 75 f4             	pushl  -0xc(%ebp)
    4c30:	e8 d9 03 00 00       	call   500e <read>
    4c35:	83 c4 10             	add    $0x10,%esp
  close(fd);
    4c38:	83 ec 0c             	sub    $0xc,%esp
    4c3b:	ff 75 f4             	pushl  -0xc(%ebp)
    4c3e:	e8 db 03 00 00       	call   501e <close>
    4c43:	83 c4 10             	add    $0x10,%esp
  printf(1, "arg test passed\n");
    4c46:	83 ec 08             	sub    $0x8,%esp
    4c49:	68 4e 6d 00 00       	push   $0x6d4e
    4c4e:	6a 01                	push   $0x1
    4c50:	e8 28 05 00 00       	call   517d <printf>
    4c55:	83 c4 10             	add    $0x10,%esp
}
    4c58:	90                   	nop
    4c59:	c9                   	leave  
    4c5a:	c3                   	ret    

00004c5b <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    4c5b:	55                   	push   %ebp
    4c5c:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    4c5e:	a1 44 75 00 00       	mov    0x7544,%eax
    4c63:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    4c69:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    4c6e:	a3 44 75 00 00       	mov    %eax,0x7544
  return randstate;
    4c73:	a1 44 75 00 00       	mov    0x7544,%eax
}
    4c78:	5d                   	pop    %ebp
    4c79:	c3                   	ret    

00004c7a <main>:

int
main(int argc, char *argv[])
{
    4c7a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    4c7e:	83 e4 f0             	and    $0xfffffff0,%esp
    4c81:	ff 71 fc             	pushl  -0x4(%ecx)
    4c84:	55                   	push   %ebp
    4c85:	89 e5                	mov    %esp,%ebp
    4c87:	51                   	push   %ecx
    4c88:	83 ec 04             	sub    $0x4,%esp
  printf(1, "usertests starting\n");
    4c8b:	83 ec 08             	sub    $0x8,%esp
    4c8e:	68 5f 6d 00 00       	push   $0x6d5f
    4c93:	6a 01                	push   $0x1
    4c95:	e8 e3 04 00 00       	call   517d <printf>
    4c9a:	83 c4 10             	add    $0x10,%esp

  if(open("usertests.ran", 0) >= 0){
    4c9d:	83 ec 08             	sub    $0x8,%esp
    4ca0:	6a 00                	push   $0x0
    4ca2:	68 73 6d 00 00       	push   $0x6d73
    4ca7:	e8 8a 03 00 00       	call   5036 <open>
    4cac:	83 c4 10             	add    $0x10,%esp
    4caf:	85 c0                	test   %eax,%eax
    4cb1:	78 17                	js     4cca <main+0x50>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    4cb3:	83 ec 08             	sub    $0x8,%esp
    4cb6:	68 84 6d 00 00       	push   $0x6d84
    4cbb:	6a 01                	push   $0x1
    4cbd:	e8 bb 04 00 00       	call   517d <printf>
    4cc2:	83 c4 10             	add    $0x10,%esp
    exit();
    4cc5:	e8 2c 03 00 00       	call   4ff6 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    4cca:	83 ec 08             	sub    $0x8,%esp
    4ccd:	68 00 02 00 00       	push   $0x200
    4cd2:	68 73 6d 00 00       	push   $0x6d73
    4cd7:	e8 5a 03 00 00       	call   5036 <open>
    4cdc:	83 c4 10             	add    $0x10,%esp
    4cdf:	83 ec 0c             	sub    $0xc,%esp
    4ce2:	50                   	push   %eax
    4ce3:	e8 36 03 00 00       	call   501e <close>
    4ce8:	83 c4 10             	add    $0x10,%esp

  argptest();
    4ceb:	e8 ef fe ff ff       	call   4bdf <argptest>
  createdelete();
    4cf0:	e8 b5 d5 ff ff       	call   22aa <createdelete>
  linkunlink();
    4cf5:	e8 d6 df ff ff       	call   2cd0 <linkunlink>
  concreate();
    4cfa:	e8 21 dc ff ff       	call   2920 <concreate>
  fourfiles();
    4cff:	e8 55 d3 ff ff       	call   2059 <fourfiles>
  sharedfd();
    4d04:	e8 6d d1 ff ff       	call   1e76 <sharedfd>

  bigargtest();
    4d09:	e8 4d fa ff ff       	call   475b <bigargtest>
  bigwrite();
    4d0e:	e8 af e9 ff ff       	call   36c2 <bigwrite>
  bigargtest();
    4d13:	e8 43 fa ff ff       	call   475b <bigargtest>
  bsstest();
    4d18:	e8 c8 f9 ff ff       	call   46e5 <bsstest>
  sbrktest();
    4d1d:	e8 d3 f3 ff ff       	call   40f5 <sbrktest>
  validatetest();
    4d22:	e8 e0 f8 ff ff       	call   4607 <validatetest>

  opentest();
    4d27:	e8 d3 c5 ff ff       	call   12ff <opentest>
  writetest();
    4d2c:	e8 7d c6 ff ff       	call   13ae <writetest>
  writetest1();
    4d31:	e8 88 c8 ff ff       	call   15be <writetest1>
  createtest();
    4d36:	e8 7f ca ff ff       	call   17ba <createtest>

  openiputtest();
    4d3b:	e8 b0 c4 ff ff       	call   11f0 <openiputtest>
  exitiputtest();
    4d40:	e8 ac c3 ff ff       	call   10f1 <exitiputtest>
  iputtest();
    4d45:	e8 b6 c2 ff ff       	call   1000 <iputtest>

  mem();
    4d4a:	e8 36 d0 ff ff       	call   1d85 <mem>
  pipe1();
    4d4f:	e8 6d cc ff ff       	call   19c1 <pipe1>
  preempt();
    4d54:	e8 51 ce ff ff       	call   1baa <preempt>
  exitwait();
    4d59:	e8 af cf ff ff       	call   1d0d <exitwait>

  rmdot();
    4d5e:	e8 d1 ed ff ff       	call   3b34 <rmdot>
  fourteen();
    4d63:	e8 70 ec ff ff       	call   39d8 <fourteen>
  bigfile();
    4d68:	e8 53 ea ff ff       	call   37c0 <bigfile>
  subdir();
    4d6d:	e8 0c e2 ff ff       	call   2f7e <subdir>
  linktest();
    4d72:	e8 67 d9 ff ff       	call   26de <linktest>
  unlinkread();
    4d77:	e8 a0 d7 ff ff       	call   251c <unlinkread>
  dirfile();
    4d7c:	e8 38 ef ff ff       	call   3cb9 <dirfile>
  iref();
    4d81:	e8 6b f1 ff ff       	call   3ef1 <iref>
  forktest();
    4d86:	e8 a0 f2 ff ff       	call   402b <forktest>
  bigdir(); // slow
    4d8b:	e8 79 e0 ff ff       	call   2e09 <bigdir>

  uio();
    4d90:	e8 a9 fd ff ff       	call   4b3e <uio>

  exectest();
    4d95:	e8 d4 cb ff ff       	call   196e <exectest>

  exit();
    4d9a:	e8 57 02 00 00       	call   4ff6 <exit>

00004d9f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    4d9f:	55                   	push   %ebp
    4da0:	89 e5                	mov    %esp,%ebp
    4da2:	57                   	push   %edi
    4da3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    4da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
    4da7:	8b 55 10             	mov    0x10(%ebp),%edx
    4daa:	8b 45 0c             	mov    0xc(%ebp),%eax
    4dad:	89 cb                	mov    %ecx,%ebx
    4daf:	89 df                	mov    %ebx,%edi
    4db1:	89 d1                	mov    %edx,%ecx
    4db3:	fc                   	cld    
    4db4:	f3 aa                	rep stos %al,%es:(%edi)
    4db6:	89 ca                	mov    %ecx,%edx
    4db8:	89 fb                	mov    %edi,%ebx
    4dba:	89 5d 08             	mov    %ebx,0x8(%ebp)
    4dbd:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    4dc0:	90                   	nop
    4dc1:	5b                   	pop    %ebx
    4dc2:	5f                   	pop    %edi
    4dc3:	5d                   	pop    %ebp
    4dc4:	c3                   	ret    

00004dc5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    4dc5:	55                   	push   %ebp
    4dc6:	89 e5                	mov    %esp,%ebp
    4dc8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    4dcb:	8b 45 08             	mov    0x8(%ebp),%eax
    4dce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    4dd1:	90                   	nop
    4dd2:	8b 45 08             	mov    0x8(%ebp),%eax
    4dd5:	8d 50 01             	lea    0x1(%eax),%edx
    4dd8:	89 55 08             	mov    %edx,0x8(%ebp)
    4ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
    4dde:	8d 4a 01             	lea    0x1(%edx),%ecx
    4de1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    4de4:	0f b6 12             	movzbl (%edx),%edx
    4de7:	88 10                	mov    %dl,(%eax)
    4de9:	0f b6 00             	movzbl (%eax),%eax
    4dec:	84 c0                	test   %al,%al
    4dee:	75 e2                	jne    4dd2 <strcpy+0xd>
    ;
  return os;
    4df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    4df3:	c9                   	leave  
    4df4:	c3                   	ret    

00004df5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    4df5:	55                   	push   %ebp
    4df6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    4df8:	eb 08                	jmp    4e02 <strcmp+0xd>
    p++, q++;
    4dfa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    4dfe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    4e02:	8b 45 08             	mov    0x8(%ebp),%eax
    4e05:	0f b6 00             	movzbl (%eax),%eax
    4e08:	84 c0                	test   %al,%al
    4e0a:	74 10                	je     4e1c <strcmp+0x27>
    4e0c:	8b 45 08             	mov    0x8(%ebp),%eax
    4e0f:	0f b6 10             	movzbl (%eax),%edx
    4e12:	8b 45 0c             	mov    0xc(%ebp),%eax
    4e15:	0f b6 00             	movzbl (%eax),%eax
    4e18:	38 c2                	cmp    %al,%dl
    4e1a:	74 de                	je     4dfa <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    4e1c:	8b 45 08             	mov    0x8(%ebp),%eax
    4e1f:	0f b6 00             	movzbl (%eax),%eax
    4e22:	0f b6 d0             	movzbl %al,%edx
    4e25:	8b 45 0c             	mov    0xc(%ebp),%eax
    4e28:	0f b6 00             	movzbl (%eax),%eax
    4e2b:	0f b6 c0             	movzbl %al,%eax
    4e2e:	29 c2                	sub    %eax,%edx
    4e30:	89 d0                	mov    %edx,%eax
}
    4e32:	5d                   	pop    %ebp
    4e33:	c3                   	ret    

00004e34 <strlen>:

uint
strlen(char *s)
{
    4e34:	55                   	push   %ebp
    4e35:	89 e5                	mov    %esp,%ebp
    4e37:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    4e3a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    4e41:	eb 04                	jmp    4e47 <strlen+0x13>
    4e43:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    4e47:	8b 55 fc             	mov    -0x4(%ebp),%edx
    4e4a:	8b 45 08             	mov    0x8(%ebp),%eax
    4e4d:	01 d0                	add    %edx,%eax
    4e4f:	0f b6 00             	movzbl (%eax),%eax
    4e52:	84 c0                	test   %al,%al
    4e54:	75 ed                	jne    4e43 <strlen+0xf>
    ;
  return n;
    4e56:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    4e59:	c9                   	leave  
    4e5a:	c3                   	ret    

00004e5b <memset>:

void*
memset(void *dst, int c, uint n)
{
    4e5b:	55                   	push   %ebp
    4e5c:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    4e5e:	8b 45 10             	mov    0x10(%ebp),%eax
    4e61:	50                   	push   %eax
    4e62:	ff 75 0c             	pushl  0xc(%ebp)
    4e65:	ff 75 08             	pushl  0x8(%ebp)
    4e68:	e8 32 ff ff ff       	call   4d9f <stosb>
    4e6d:	83 c4 0c             	add    $0xc,%esp
  return dst;
    4e70:	8b 45 08             	mov    0x8(%ebp),%eax
}
    4e73:	c9                   	leave  
    4e74:	c3                   	ret    

00004e75 <strchr>:

char*
strchr(const char *s, char c)
{
    4e75:	55                   	push   %ebp
    4e76:	89 e5                	mov    %esp,%ebp
    4e78:	83 ec 04             	sub    $0x4,%esp
    4e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
    4e7e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    4e81:	eb 14                	jmp    4e97 <strchr+0x22>
    if(*s == c)
    4e83:	8b 45 08             	mov    0x8(%ebp),%eax
    4e86:	0f b6 00             	movzbl (%eax),%eax
    4e89:	3a 45 fc             	cmp    -0x4(%ebp),%al
    4e8c:	75 05                	jne    4e93 <strchr+0x1e>
      return (char*)s;
    4e8e:	8b 45 08             	mov    0x8(%ebp),%eax
    4e91:	eb 13                	jmp    4ea6 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    4e93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    4e97:	8b 45 08             	mov    0x8(%ebp),%eax
    4e9a:	0f b6 00             	movzbl (%eax),%eax
    4e9d:	84 c0                	test   %al,%al
    4e9f:	75 e2                	jne    4e83 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    4ea1:	b8 00 00 00 00       	mov    $0x0,%eax
}
    4ea6:	c9                   	leave  
    4ea7:	c3                   	ret    

00004ea8 <gets>:

char*
gets(char *buf, int max)
{
    4ea8:	55                   	push   %ebp
    4ea9:	89 e5                	mov    %esp,%ebp
    4eab:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4eae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    4eb5:	eb 42                	jmp    4ef9 <gets+0x51>
    cc = read(0, &c, 1);
    4eb7:	83 ec 04             	sub    $0x4,%esp
    4eba:	6a 01                	push   $0x1
    4ebc:	8d 45 ef             	lea    -0x11(%ebp),%eax
    4ebf:	50                   	push   %eax
    4ec0:	6a 00                	push   $0x0
    4ec2:	e8 47 01 00 00       	call   500e <read>
    4ec7:	83 c4 10             	add    $0x10,%esp
    4eca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    4ecd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4ed1:	7e 33                	jle    4f06 <gets+0x5e>
      break;
    buf[i++] = c;
    4ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4ed6:	8d 50 01             	lea    0x1(%eax),%edx
    4ed9:	89 55 f4             	mov    %edx,-0xc(%ebp)
    4edc:	89 c2                	mov    %eax,%edx
    4ede:	8b 45 08             	mov    0x8(%ebp),%eax
    4ee1:	01 c2                	add    %eax,%edx
    4ee3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    4ee7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    4ee9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    4eed:	3c 0a                	cmp    $0xa,%al
    4eef:	74 16                	je     4f07 <gets+0x5f>
    4ef1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    4ef5:	3c 0d                	cmp    $0xd,%al
    4ef7:	74 0e                	je     4f07 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4efc:	83 c0 01             	add    $0x1,%eax
    4eff:	3b 45 0c             	cmp    0xc(%ebp),%eax
    4f02:	7c b3                	jl     4eb7 <gets+0xf>
    4f04:	eb 01                	jmp    4f07 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    4f06:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    4f07:	8b 55 f4             	mov    -0xc(%ebp),%edx
    4f0a:	8b 45 08             	mov    0x8(%ebp),%eax
    4f0d:	01 d0                	add    %edx,%eax
    4f0f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    4f12:	8b 45 08             	mov    0x8(%ebp),%eax
}
    4f15:	c9                   	leave  
    4f16:	c3                   	ret    

00004f17 <stat>:

int
stat(char *n, struct stat *st)
{
    4f17:	55                   	push   %ebp
    4f18:	89 e5                	mov    %esp,%ebp
    4f1a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4f1d:	83 ec 08             	sub    $0x8,%esp
    4f20:	6a 00                	push   $0x0
    4f22:	ff 75 08             	pushl  0x8(%ebp)
    4f25:	e8 0c 01 00 00       	call   5036 <open>
    4f2a:	83 c4 10             	add    $0x10,%esp
    4f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    4f30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4f34:	79 07                	jns    4f3d <stat+0x26>
    return -1;
    4f36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    4f3b:	eb 25                	jmp    4f62 <stat+0x4b>
  r = fstat(fd, st);
    4f3d:	83 ec 08             	sub    $0x8,%esp
    4f40:	ff 75 0c             	pushl  0xc(%ebp)
    4f43:	ff 75 f4             	pushl  -0xc(%ebp)
    4f46:	e8 03 01 00 00       	call   504e <fstat>
    4f4b:	83 c4 10             	add    $0x10,%esp
    4f4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    4f51:	83 ec 0c             	sub    $0xc,%esp
    4f54:	ff 75 f4             	pushl  -0xc(%ebp)
    4f57:	e8 c2 00 00 00       	call   501e <close>
    4f5c:	83 c4 10             	add    $0x10,%esp
  return r;
    4f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    4f62:	c9                   	leave  
    4f63:	c3                   	ret    

00004f64 <atoi>:

int
atoi(const char *s)
{
    4f64:	55                   	push   %ebp
    4f65:	89 e5                	mov    %esp,%ebp
    4f67:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    4f6a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    4f71:	eb 25                	jmp    4f98 <atoi+0x34>
    n = n*10 + *s++ - '0';
    4f73:	8b 55 fc             	mov    -0x4(%ebp),%edx
    4f76:	89 d0                	mov    %edx,%eax
    4f78:	c1 e0 02             	shl    $0x2,%eax
    4f7b:	01 d0                	add    %edx,%eax
    4f7d:	01 c0                	add    %eax,%eax
    4f7f:	89 c1                	mov    %eax,%ecx
    4f81:	8b 45 08             	mov    0x8(%ebp),%eax
    4f84:	8d 50 01             	lea    0x1(%eax),%edx
    4f87:	89 55 08             	mov    %edx,0x8(%ebp)
    4f8a:	0f b6 00             	movzbl (%eax),%eax
    4f8d:	0f be c0             	movsbl %al,%eax
    4f90:	01 c8                	add    %ecx,%eax
    4f92:	83 e8 30             	sub    $0x30,%eax
    4f95:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4f98:	8b 45 08             	mov    0x8(%ebp),%eax
    4f9b:	0f b6 00             	movzbl (%eax),%eax
    4f9e:	3c 2f                	cmp    $0x2f,%al
    4fa0:	7e 0a                	jle    4fac <atoi+0x48>
    4fa2:	8b 45 08             	mov    0x8(%ebp),%eax
    4fa5:	0f b6 00             	movzbl (%eax),%eax
    4fa8:	3c 39                	cmp    $0x39,%al
    4faa:	7e c7                	jle    4f73 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    4fac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    4faf:	c9                   	leave  
    4fb0:	c3                   	ret    

00004fb1 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    4fb1:	55                   	push   %ebp
    4fb2:	89 e5                	mov    %esp,%ebp
    4fb4:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    4fb7:	8b 45 08             	mov    0x8(%ebp),%eax
    4fba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    4fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
    4fc0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    4fc3:	eb 17                	jmp    4fdc <memmove+0x2b>
    *dst++ = *src++;
    4fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4fc8:	8d 50 01             	lea    0x1(%eax),%edx
    4fcb:	89 55 fc             	mov    %edx,-0x4(%ebp)
    4fce:	8b 55 f8             	mov    -0x8(%ebp),%edx
    4fd1:	8d 4a 01             	lea    0x1(%edx),%ecx
    4fd4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    4fd7:	0f b6 12             	movzbl (%edx),%edx
    4fda:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    4fdc:	8b 45 10             	mov    0x10(%ebp),%eax
    4fdf:	8d 50 ff             	lea    -0x1(%eax),%edx
    4fe2:	89 55 10             	mov    %edx,0x10(%ebp)
    4fe5:	85 c0                	test   %eax,%eax
    4fe7:	7f dc                	jg     4fc5 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    4fe9:	8b 45 08             	mov    0x8(%ebp),%eax
}
    4fec:	c9                   	leave  
    4fed:	c3                   	ret    

00004fee <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    4fee:	b8 01 00 00 00       	mov    $0x1,%eax
    4ff3:	cd 40                	int    $0x40
    4ff5:	c3                   	ret    

00004ff6 <exit>:
SYSCALL(exit)
    4ff6:	b8 02 00 00 00       	mov    $0x2,%eax
    4ffb:	cd 40                	int    $0x40
    4ffd:	c3                   	ret    

00004ffe <wait>:
SYSCALL(wait)
    4ffe:	b8 03 00 00 00       	mov    $0x3,%eax
    5003:	cd 40                	int    $0x40
    5005:	c3                   	ret    

00005006 <pipe>:
SYSCALL(pipe)
    5006:	b8 04 00 00 00       	mov    $0x4,%eax
    500b:	cd 40                	int    $0x40
    500d:	c3                   	ret    

0000500e <read>:
SYSCALL(read)
    500e:	b8 05 00 00 00       	mov    $0x5,%eax
    5013:	cd 40                	int    $0x40
    5015:	c3                   	ret    

00005016 <write>:
SYSCALL(write)
    5016:	b8 10 00 00 00       	mov    $0x10,%eax
    501b:	cd 40                	int    $0x40
    501d:	c3                   	ret    

0000501e <close>:
SYSCALL(close)
    501e:	b8 15 00 00 00       	mov    $0x15,%eax
    5023:	cd 40                	int    $0x40
    5025:	c3                   	ret    

00005026 <kill>:
SYSCALL(kill)
    5026:	b8 06 00 00 00       	mov    $0x6,%eax
    502b:	cd 40                	int    $0x40
    502d:	c3                   	ret    

0000502e <exec>:
SYSCALL(exec)
    502e:	b8 07 00 00 00       	mov    $0x7,%eax
    5033:	cd 40                	int    $0x40
    5035:	c3                   	ret    

00005036 <open>:
SYSCALL(open)
    5036:	b8 0f 00 00 00       	mov    $0xf,%eax
    503b:	cd 40                	int    $0x40
    503d:	c3                   	ret    

0000503e <mknod>:
SYSCALL(mknod)
    503e:	b8 11 00 00 00       	mov    $0x11,%eax
    5043:	cd 40                	int    $0x40
    5045:	c3                   	ret    

00005046 <unlink>:
SYSCALL(unlink)
    5046:	b8 12 00 00 00       	mov    $0x12,%eax
    504b:	cd 40                	int    $0x40
    504d:	c3                   	ret    

0000504e <fstat>:
SYSCALL(fstat)
    504e:	b8 08 00 00 00       	mov    $0x8,%eax
    5053:	cd 40                	int    $0x40
    5055:	c3                   	ret    

00005056 <link>:
SYSCALL(link)
    5056:	b8 13 00 00 00       	mov    $0x13,%eax
    505b:	cd 40                	int    $0x40
    505d:	c3                   	ret    

0000505e <mkdir>:
SYSCALL(mkdir)
    505e:	b8 14 00 00 00       	mov    $0x14,%eax
    5063:	cd 40                	int    $0x40
    5065:	c3                   	ret    

00005066 <chdir>:
SYSCALL(chdir)
    5066:	b8 09 00 00 00       	mov    $0x9,%eax
    506b:	cd 40                	int    $0x40
    506d:	c3                   	ret    

0000506e <dup>:
SYSCALL(dup)
    506e:	b8 0a 00 00 00       	mov    $0xa,%eax
    5073:	cd 40                	int    $0x40
    5075:	c3                   	ret    

00005076 <getpid>:
SYSCALL(getpid)
    5076:	b8 0b 00 00 00       	mov    $0xb,%eax
    507b:	cd 40                	int    $0x40
    507d:	c3                   	ret    

0000507e <sbrk>:
SYSCALL(sbrk)
    507e:	b8 0c 00 00 00       	mov    $0xc,%eax
    5083:	cd 40                	int    $0x40
    5085:	c3                   	ret    

00005086 <sleep>:
SYSCALL(sleep)
    5086:	b8 0d 00 00 00       	mov    $0xd,%eax
    508b:	cd 40                	int    $0x40
    508d:	c3                   	ret    

0000508e <uptime>:
SYSCALL(uptime)
    508e:	b8 0e 00 00 00       	mov    $0xe,%eax
    5093:	cd 40                	int    $0x40
    5095:	c3                   	ret    

00005096 <shm_open>:
SYSCALL(shm_open)
    5096:	b8 16 00 00 00       	mov    $0x16,%eax
    509b:	cd 40                	int    $0x40
    509d:	c3                   	ret    

0000509e <shm_close>:
SYSCALL(shm_close)	
    509e:	b8 17 00 00 00       	mov    $0x17,%eax
    50a3:	cd 40                	int    $0x40
    50a5:	c3                   	ret    

000050a6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    50a6:	55                   	push   %ebp
    50a7:	89 e5                	mov    %esp,%ebp
    50a9:	83 ec 18             	sub    $0x18,%esp
    50ac:	8b 45 0c             	mov    0xc(%ebp),%eax
    50af:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    50b2:	83 ec 04             	sub    $0x4,%esp
    50b5:	6a 01                	push   $0x1
    50b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
    50ba:	50                   	push   %eax
    50bb:	ff 75 08             	pushl  0x8(%ebp)
    50be:	e8 53 ff ff ff       	call   5016 <write>
    50c3:	83 c4 10             	add    $0x10,%esp
}
    50c6:	90                   	nop
    50c7:	c9                   	leave  
    50c8:	c3                   	ret    

000050c9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    50c9:	55                   	push   %ebp
    50ca:	89 e5                	mov    %esp,%ebp
    50cc:	53                   	push   %ebx
    50cd:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    50d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    50d7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    50db:	74 17                	je     50f4 <printint+0x2b>
    50dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    50e1:	79 11                	jns    50f4 <printint+0x2b>
    neg = 1;
    50e3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    50ea:	8b 45 0c             	mov    0xc(%ebp),%eax
    50ed:	f7 d8                	neg    %eax
    50ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    50f2:	eb 06                	jmp    50fa <printint+0x31>
  } else {
    x = xx;
    50f4:	8b 45 0c             	mov    0xc(%ebp),%eax
    50f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    50fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    5101:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    5104:	8d 41 01             	lea    0x1(%ecx),%eax
    5107:	89 45 f4             	mov    %eax,-0xc(%ebp)
    510a:	8b 5d 10             	mov    0x10(%ebp),%ebx
    510d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    5110:	ba 00 00 00 00       	mov    $0x0,%edx
    5115:	f7 f3                	div    %ebx
    5117:	89 d0                	mov    %edx,%eax
    5119:	0f b6 80 48 75 00 00 	movzbl 0x7548(%eax),%eax
    5120:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    5124:	8b 5d 10             	mov    0x10(%ebp),%ebx
    5127:	8b 45 ec             	mov    -0x14(%ebp),%eax
    512a:	ba 00 00 00 00       	mov    $0x0,%edx
    512f:	f7 f3                	div    %ebx
    5131:	89 45 ec             	mov    %eax,-0x14(%ebp)
    5134:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    5138:	75 c7                	jne    5101 <printint+0x38>
  if(neg)
    513a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    513e:	74 2d                	je     516d <printint+0xa4>
    buf[i++] = '-';
    5140:	8b 45 f4             	mov    -0xc(%ebp),%eax
    5143:	8d 50 01             	lea    0x1(%eax),%edx
    5146:	89 55 f4             	mov    %edx,-0xc(%ebp)
    5149:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    514e:	eb 1d                	jmp    516d <printint+0xa4>
    putc(fd, buf[i]);
    5150:	8d 55 dc             	lea    -0x24(%ebp),%edx
    5153:	8b 45 f4             	mov    -0xc(%ebp),%eax
    5156:	01 d0                	add    %edx,%eax
    5158:	0f b6 00             	movzbl (%eax),%eax
    515b:	0f be c0             	movsbl %al,%eax
    515e:	83 ec 08             	sub    $0x8,%esp
    5161:	50                   	push   %eax
    5162:	ff 75 08             	pushl  0x8(%ebp)
    5165:	e8 3c ff ff ff       	call   50a6 <putc>
    516a:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    516d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    5171:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    5175:	79 d9                	jns    5150 <printint+0x87>
    putc(fd, buf[i]);
}
    5177:	90                   	nop
    5178:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    517b:	c9                   	leave  
    517c:	c3                   	ret    

0000517d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    517d:	55                   	push   %ebp
    517e:	89 e5                	mov    %esp,%ebp
    5180:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    5183:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    518a:	8d 45 0c             	lea    0xc(%ebp),%eax
    518d:	83 c0 04             	add    $0x4,%eax
    5190:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    5193:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    519a:	e9 59 01 00 00       	jmp    52f8 <printf+0x17b>
    c = fmt[i] & 0xff;
    519f:	8b 55 0c             	mov    0xc(%ebp),%edx
    51a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    51a5:	01 d0                	add    %edx,%eax
    51a7:	0f b6 00             	movzbl (%eax),%eax
    51aa:	0f be c0             	movsbl %al,%eax
    51ad:	25 ff 00 00 00       	and    $0xff,%eax
    51b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    51b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    51b9:	75 2c                	jne    51e7 <printf+0x6a>
      if(c == '%'){
    51bb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    51bf:	75 0c                	jne    51cd <printf+0x50>
        state = '%';
    51c1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    51c8:	e9 27 01 00 00       	jmp    52f4 <printf+0x177>
      } else {
        putc(fd, c);
    51cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    51d0:	0f be c0             	movsbl %al,%eax
    51d3:	83 ec 08             	sub    $0x8,%esp
    51d6:	50                   	push   %eax
    51d7:	ff 75 08             	pushl  0x8(%ebp)
    51da:	e8 c7 fe ff ff       	call   50a6 <putc>
    51df:	83 c4 10             	add    $0x10,%esp
    51e2:	e9 0d 01 00 00       	jmp    52f4 <printf+0x177>
      }
    } else if(state == '%'){
    51e7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    51eb:	0f 85 03 01 00 00    	jne    52f4 <printf+0x177>
      if(c == 'd'){
    51f1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    51f5:	75 1e                	jne    5215 <printf+0x98>
        printint(fd, *ap, 10, 1);
    51f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
    51fa:	8b 00                	mov    (%eax),%eax
    51fc:	6a 01                	push   $0x1
    51fe:	6a 0a                	push   $0xa
    5200:	50                   	push   %eax
    5201:	ff 75 08             	pushl  0x8(%ebp)
    5204:	e8 c0 fe ff ff       	call   50c9 <printint>
    5209:	83 c4 10             	add    $0x10,%esp
        ap++;
    520c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    5210:	e9 d8 00 00 00       	jmp    52ed <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    5215:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    5219:	74 06                	je     5221 <printf+0xa4>
    521b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    521f:	75 1e                	jne    523f <printf+0xc2>
        printint(fd, *ap, 16, 0);
    5221:	8b 45 e8             	mov    -0x18(%ebp),%eax
    5224:	8b 00                	mov    (%eax),%eax
    5226:	6a 00                	push   $0x0
    5228:	6a 10                	push   $0x10
    522a:	50                   	push   %eax
    522b:	ff 75 08             	pushl  0x8(%ebp)
    522e:	e8 96 fe ff ff       	call   50c9 <printint>
    5233:	83 c4 10             	add    $0x10,%esp
        ap++;
    5236:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    523a:	e9 ae 00 00 00       	jmp    52ed <printf+0x170>
      } else if(c == 's'){
    523f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    5243:	75 43                	jne    5288 <printf+0x10b>
        s = (char*)*ap;
    5245:	8b 45 e8             	mov    -0x18(%ebp),%eax
    5248:	8b 00                	mov    (%eax),%eax
    524a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    524d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    5251:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    5255:	75 25                	jne    527c <printf+0xff>
          s = "(null)";
    5257:	c7 45 f4 ae 6d 00 00 	movl   $0x6dae,-0xc(%ebp)
        while(*s != 0){
    525e:	eb 1c                	jmp    527c <printf+0xff>
          putc(fd, *s);
    5260:	8b 45 f4             	mov    -0xc(%ebp),%eax
    5263:	0f b6 00             	movzbl (%eax),%eax
    5266:	0f be c0             	movsbl %al,%eax
    5269:	83 ec 08             	sub    $0x8,%esp
    526c:	50                   	push   %eax
    526d:	ff 75 08             	pushl  0x8(%ebp)
    5270:	e8 31 fe ff ff       	call   50a6 <putc>
    5275:	83 c4 10             	add    $0x10,%esp
          s++;
    5278:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    527c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    527f:	0f b6 00             	movzbl (%eax),%eax
    5282:	84 c0                	test   %al,%al
    5284:	75 da                	jne    5260 <printf+0xe3>
    5286:	eb 65                	jmp    52ed <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5288:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    528c:	75 1d                	jne    52ab <printf+0x12e>
        putc(fd, *ap);
    528e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    5291:	8b 00                	mov    (%eax),%eax
    5293:	0f be c0             	movsbl %al,%eax
    5296:	83 ec 08             	sub    $0x8,%esp
    5299:	50                   	push   %eax
    529a:	ff 75 08             	pushl  0x8(%ebp)
    529d:	e8 04 fe ff ff       	call   50a6 <putc>
    52a2:	83 c4 10             	add    $0x10,%esp
        ap++;
    52a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    52a9:	eb 42                	jmp    52ed <printf+0x170>
      } else if(c == '%'){
    52ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    52af:	75 17                	jne    52c8 <printf+0x14b>
        putc(fd, c);
    52b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    52b4:	0f be c0             	movsbl %al,%eax
    52b7:	83 ec 08             	sub    $0x8,%esp
    52ba:	50                   	push   %eax
    52bb:	ff 75 08             	pushl  0x8(%ebp)
    52be:	e8 e3 fd ff ff       	call   50a6 <putc>
    52c3:	83 c4 10             	add    $0x10,%esp
    52c6:	eb 25                	jmp    52ed <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    52c8:	83 ec 08             	sub    $0x8,%esp
    52cb:	6a 25                	push   $0x25
    52cd:	ff 75 08             	pushl  0x8(%ebp)
    52d0:	e8 d1 fd ff ff       	call   50a6 <putc>
    52d5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    52d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    52db:	0f be c0             	movsbl %al,%eax
    52de:	83 ec 08             	sub    $0x8,%esp
    52e1:	50                   	push   %eax
    52e2:	ff 75 08             	pushl  0x8(%ebp)
    52e5:	e8 bc fd ff ff       	call   50a6 <putc>
    52ea:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    52ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    52f4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    52f8:	8b 55 0c             	mov    0xc(%ebp),%edx
    52fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    52fe:	01 d0                	add    %edx,%eax
    5300:	0f b6 00             	movzbl (%eax),%eax
    5303:	84 c0                	test   %al,%al
    5305:	0f 85 94 fe ff ff    	jne    519f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    530b:	90                   	nop
    530c:	c9                   	leave  
    530d:	c3                   	ret    

0000530e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    530e:	55                   	push   %ebp
    530f:	89 e5                	mov    %esp,%ebp
    5311:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5314:	8b 45 08             	mov    0x8(%ebp),%eax
    5317:	83 e8 08             	sub    $0x8,%eax
    531a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    531d:	a1 e8 75 00 00       	mov    0x75e8,%eax
    5322:	89 45 fc             	mov    %eax,-0x4(%ebp)
    5325:	eb 24                	jmp    534b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5327:	8b 45 fc             	mov    -0x4(%ebp),%eax
    532a:	8b 00                	mov    (%eax),%eax
    532c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    532f:	77 12                	ja     5343 <free+0x35>
    5331:	8b 45 f8             	mov    -0x8(%ebp),%eax
    5334:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    5337:	77 24                	ja     535d <free+0x4f>
    5339:	8b 45 fc             	mov    -0x4(%ebp),%eax
    533c:	8b 00                	mov    (%eax),%eax
    533e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    5341:	77 1a                	ja     535d <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5343:	8b 45 fc             	mov    -0x4(%ebp),%eax
    5346:	8b 00                	mov    (%eax),%eax
    5348:	89 45 fc             	mov    %eax,-0x4(%ebp)
    534b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    534e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    5351:	76 d4                	jbe    5327 <free+0x19>
    5353:	8b 45 fc             	mov    -0x4(%ebp),%eax
    5356:	8b 00                	mov    (%eax),%eax
    5358:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    535b:	76 ca                	jbe    5327 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    535d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    5360:	8b 40 04             	mov    0x4(%eax),%eax
    5363:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    536a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    536d:	01 c2                	add    %eax,%edx
    536f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    5372:	8b 00                	mov    (%eax),%eax
    5374:	39 c2                	cmp    %eax,%edx
    5376:	75 24                	jne    539c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    5378:	8b 45 f8             	mov    -0x8(%ebp),%eax
    537b:	8b 50 04             	mov    0x4(%eax),%edx
    537e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    5381:	8b 00                	mov    (%eax),%eax
    5383:	8b 40 04             	mov    0x4(%eax),%eax
    5386:	01 c2                	add    %eax,%edx
    5388:	8b 45 f8             	mov    -0x8(%ebp),%eax
    538b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    538e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    5391:	8b 00                	mov    (%eax),%eax
    5393:	8b 10                	mov    (%eax),%edx
    5395:	8b 45 f8             	mov    -0x8(%ebp),%eax
    5398:	89 10                	mov    %edx,(%eax)
    539a:	eb 0a                	jmp    53a6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    539c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    539f:	8b 10                	mov    (%eax),%edx
    53a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    53a4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    53a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53a9:	8b 40 04             	mov    0x4(%eax),%eax
    53ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    53b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53b6:	01 d0                	add    %edx,%eax
    53b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    53bb:	75 20                	jne    53dd <free+0xcf>
    p->s.size += bp->s.size;
    53bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53c0:	8b 50 04             	mov    0x4(%eax),%edx
    53c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    53c6:	8b 40 04             	mov    0x4(%eax),%eax
    53c9:	01 c2                	add    %eax,%edx
    53cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53ce:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    53d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    53d4:	8b 10                	mov    (%eax),%edx
    53d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53d9:	89 10                	mov    %edx,(%eax)
    53db:	eb 08                	jmp    53e5 <free+0xd7>
  } else
    p->s.ptr = bp;
    53dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53e0:	8b 55 f8             	mov    -0x8(%ebp),%edx
    53e3:	89 10                	mov    %edx,(%eax)
  freep = p;
    53e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    53e8:	a3 e8 75 00 00       	mov    %eax,0x75e8
}
    53ed:	90                   	nop
    53ee:	c9                   	leave  
    53ef:	c3                   	ret    

000053f0 <morecore>:

static Header*
morecore(uint nu)
{
    53f0:	55                   	push   %ebp
    53f1:	89 e5                	mov    %esp,%ebp
    53f3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    53f6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    53fd:	77 07                	ja     5406 <morecore+0x16>
    nu = 4096;
    53ff:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    5406:	8b 45 08             	mov    0x8(%ebp),%eax
    5409:	c1 e0 03             	shl    $0x3,%eax
    540c:	83 ec 0c             	sub    $0xc,%esp
    540f:	50                   	push   %eax
    5410:	e8 69 fc ff ff       	call   507e <sbrk>
    5415:	83 c4 10             	add    $0x10,%esp
    5418:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    541b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    541f:	75 07                	jne    5428 <morecore+0x38>
    return 0;
    5421:	b8 00 00 00 00       	mov    $0x0,%eax
    5426:	eb 26                	jmp    544e <morecore+0x5e>
  hp = (Header*)p;
    5428:	8b 45 f4             	mov    -0xc(%ebp),%eax
    542b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    542e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    5431:	8b 55 08             	mov    0x8(%ebp),%edx
    5434:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    5437:	8b 45 f0             	mov    -0x10(%ebp),%eax
    543a:	83 c0 08             	add    $0x8,%eax
    543d:	83 ec 0c             	sub    $0xc,%esp
    5440:	50                   	push   %eax
    5441:	e8 c8 fe ff ff       	call   530e <free>
    5446:	83 c4 10             	add    $0x10,%esp
  return freep;
    5449:	a1 e8 75 00 00       	mov    0x75e8,%eax
}
    544e:	c9                   	leave  
    544f:	c3                   	ret    

00005450 <malloc>:

void*
malloc(uint nbytes)
{
    5450:	55                   	push   %ebp
    5451:	89 e5                	mov    %esp,%ebp
    5453:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5456:	8b 45 08             	mov    0x8(%ebp),%eax
    5459:	83 c0 07             	add    $0x7,%eax
    545c:	c1 e8 03             	shr    $0x3,%eax
    545f:	83 c0 01             	add    $0x1,%eax
    5462:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    5465:	a1 e8 75 00 00       	mov    0x75e8,%eax
    546a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    546d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    5471:	75 23                	jne    5496 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    5473:	c7 45 f0 e0 75 00 00 	movl   $0x75e0,-0x10(%ebp)
    547a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    547d:	a3 e8 75 00 00       	mov    %eax,0x75e8
    5482:	a1 e8 75 00 00       	mov    0x75e8,%eax
    5487:	a3 e0 75 00 00       	mov    %eax,0x75e0
    base.s.size = 0;
    548c:	c7 05 e4 75 00 00 00 	movl   $0x0,0x75e4
    5493:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5496:	8b 45 f0             	mov    -0x10(%ebp),%eax
    5499:	8b 00                	mov    (%eax),%eax
    549b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    549e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54a1:	8b 40 04             	mov    0x4(%eax),%eax
    54a4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    54a7:	72 4d                	jb     54f6 <malloc+0xa6>
      if(p->s.size == nunits)
    54a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54ac:	8b 40 04             	mov    0x4(%eax),%eax
    54af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    54b2:	75 0c                	jne    54c0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    54b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54b7:	8b 10                	mov    (%eax),%edx
    54b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    54bc:	89 10                	mov    %edx,(%eax)
    54be:	eb 26                	jmp    54e6 <malloc+0x96>
      else {
        p->s.size -= nunits;
    54c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54c3:	8b 40 04             	mov    0x4(%eax),%eax
    54c6:	2b 45 ec             	sub    -0x14(%ebp),%eax
    54c9:	89 c2                	mov    %eax,%edx
    54cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54ce:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    54d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54d4:	8b 40 04             	mov    0x4(%eax),%eax
    54d7:	c1 e0 03             	shl    $0x3,%eax
    54da:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    54dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
    54e3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    54e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    54e9:	a3 e8 75 00 00       	mov    %eax,0x75e8
      return (void*)(p + 1);
    54ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    54f1:	83 c0 08             	add    $0x8,%eax
    54f4:	eb 3b                	jmp    5531 <malloc+0xe1>
    }
    if(p == freep)
    54f6:	a1 e8 75 00 00       	mov    0x75e8,%eax
    54fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    54fe:	75 1e                	jne    551e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    5500:	83 ec 0c             	sub    $0xc,%esp
    5503:	ff 75 ec             	pushl  -0x14(%ebp)
    5506:	e8 e5 fe ff ff       	call   53f0 <morecore>
    550b:	83 c4 10             	add    $0x10,%esp
    550e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    5511:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    5515:	75 07                	jne    551e <malloc+0xce>
        return 0;
    5517:	b8 00 00 00 00       	mov    $0x0,%eax
    551c:	eb 13                	jmp    5531 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    551e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    5521:	89 45 f0             	mov    %eax,-0x10(%ebp)
    5524:	8b 45 f4             	mov    -0xc(%ebp),%eax
    5527:	8b 00                	mov    (%eax),%eax
    5529:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    552c:	e9 6d ff ff ff       	jmp    549e <malloc+0x4e>
}
    5531:	c9                   	leave  
    5532:	c3                   	ret    

00005533 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    5533:	55                   	push   %ebp
    5534:	89 e5                	mov    %esp,%ebp
    5536:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    5539:	8b 55 08             	mov    0x8(%ebp),%edx
    553c:	8b 45 0c             	mov    0xc(%ebp),%eax
    553f:	8b 4d 08             	mov    0x8(%ebp),%ecx
    5542:	f0 87 02             	lock xchg %eax,(%edx)
    5545:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    5548:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    554b:	c9                   	leave  
    554c:	c3                   	ret    

0000554d <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    554d:	55                   	push   %ebp
    554e:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    5550:	90                   	nop
    5551:	8b 45 08             	mov    0x8(%ebp),%eax
    5554:	6a 01                	push   $0x1
    5556:	50                   	push   %eax
    5557:	e8 d7 ff ff ff       	call   5533 <xchg>
    555c:	83 c4 08             	add    $0x8,%esp
    555f:	85 c0                	test   %eax,%eax
    5561:	75 ee                	jne    5551 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    5563:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    5568:	90                   	nop
    5569:	c9                   	leave  
    556a:	c3                   	ret    

0000556b <urelease>:

void urelease (struct uspinlock *lk) {
    556b:	55                   	push   %ebp
    556c:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    556e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    5573:	8b 45 08             	mov    0x8(%ebp),%eax
    5576:	8b 55 08             	mov    0x8(%ebp),%edx
    5579:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    557f:	90                   	nop
    5580:	5d                   	pop    %ebp
    5581:	c3                   	ret    
