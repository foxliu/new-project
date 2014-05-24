#include <stdio.h>
#include <stdlib.h>
#include "menu5_head.h"

int char_to_terminal(int char_to_write)
{
  if(output_stream) putc(char_to_write, output_stream);
  return 0;
}