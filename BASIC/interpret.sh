#!/bin/sh
echo -n "compiling basic interpreter..."
yacc -d basic.y
flex -i basic.l
cc interpreter.c y.tab.c -o basic -lfl -ly
rm y.tab.h y.tab.c lex.yy.c
echo "done"

