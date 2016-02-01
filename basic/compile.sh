#!/bin/sh
echo -n "Compiling basic compiler..."
yacc -d basic.y
flex -i basic.l
cc compiler.c y.tab.c -o basic -lfl -ly
rm y.tab.h y.tab.c lex.yy.c
echo "done"
