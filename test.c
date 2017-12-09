#include "types.h"
#include "user.h"
#include "fcntl.h"


int test(int n)
{
   test(n+1);
   return n;
}
int main(int argc, char *argv[])
{
   int pid=0;
   pid=fork();
   if(pid==0){
   int x=1;
   printf(1, "address %x\n", &x);
   test(1);
   exit();
   }
   wait();
   exit();
}
