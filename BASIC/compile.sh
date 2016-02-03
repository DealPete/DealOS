#!/bin/sh
echo -n "Compiling basic compiler..."
yacc -d basic.y

if [ $? -ne 0 ]; then
	exit $?
fi

flex -i basic.l

if [ $? -ne 0 ]; then
	exit $?
fi

cc compiler.c y.tab.c -o basic -lfl -ly

if [ $? -ne 0 ]; then
	exit $?
fi

echo "done"
rm y.tab.h y.tab.c lex.yy.c
exit 0
