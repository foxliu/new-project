#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <termios.h>
#include <term.h>
#include <curses.h>
#include "menu5_head.h"

int getchoice(char *greet, char *choices[], FILE *in, FILE *out)
{
  int chosen = 0;
  int selected = 0;
  int screenrow, screencol = 10;
  char **option;
  char *cursor, *clear;
  
  output_stream = out;
  
  setupterm(NULL, fileno(out),(int *)0);
  cursor = tigetstr("cpu");
  clear = tigetstr("clear");
  
  screenrow = 4;
  tputs(clear, 1, (int *)char_to_terminal);
  tputs(tparm(cursor, screenrow, screencol), 1, char_to_terminal);
  fprintf(out, "Choice: %s", greet);
  screenrow += 2;
  option = choices;
  while(*option) {
	tputs(tparm(cursor, screenrow, screencol), 1, char_to_terminal);
	fprintf(out, "%s", *option);
	screenrow++;
	option++;
  }
  fprintf(out, "\n");
  
  do {
	fflush(out);
	selected = fgetc(in);
	option = choices;
	while(*option){
	  if(selected == *option[0]) {
		chosen = 1;
		break;
	  }
	  option++;
  }
  if(!chosen) {
	tputs(tparm(cursor, screenrow, screencol), 1, char_to_terminal);
	fprintf(out, "Incorrect choice, select again\n");
  }
} while(!chosen);
tputs(clear, 1, char_to_terminal);
return selected;
}