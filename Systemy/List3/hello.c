#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
  printf(1, "\n--- Test Kolorow Xv6 ---\n");

  printf(1, "%1 To jest 1\n");
  printf(1, "%2 To jest 2\n");
  printf(1, "%3 To jest 3\n");
  printf(1, "%4 To jest 4\n");
  printf(1, "%5 To jest 5\n");
  printf(1, "%6 To jest 6\n");
  printf(1, "%7 To jest 7\n");
  printf(1, "%r To jest r-reset\n");
  printf(1, "%4H %6e %2l %1l %5o %r!\n\n");

  exit();
}

