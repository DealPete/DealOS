#!/bin/sh

echo -n "assembling DealOS.asm..."
nasm DealOS.asm -o DealOS.bin

if [ $? -ne 0 ]; then
	exit $?
fi

echo "done"

if [ "$#" -gt 0 ]; then
	cat $1 >> DealOS.bin
fi
