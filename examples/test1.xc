#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


int main() {
 sed {  1 d;
	4 ~ 5 d;
	/"b"/ d;
	s /'1'/('a')/;
	2 s /'a'/('2')/;
  };
}
