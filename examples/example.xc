#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  char new[50] = "hello world!";
  printf("%s\n", new);
  char *result_1 = sed s/"hello"/("hi")/(new);
  printf("%s\n", result_1);

}
