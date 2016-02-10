#!/bin/sh
echo -n "Compiling basic compiler..."
yacc -d basic.y

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

flex -i basic.l

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

cc compiler.c y.tab.c -o basic -lfl -ly

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

echo "done"
rm y.tab.h y.tab.c lex.yy.c
exit 0
