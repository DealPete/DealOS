if [ "$#" -eq 0 ]; then
	echo "Missing name of program to run.\n"
	exit 1
fi

./compile.sh

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

echo -n "compiling $1.bas..."
./basic "$1.bas" "$1.asm"

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

rm basic
echo "done"
echo -n "assembling $1.asm..."
nasm "$1.asm" -o "$1.bin"

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

rm "$1.asm"
echo "done"
cd ..
./assemble.sh "BASIC/$1.bin"

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

rm "BASIC/$1.bin"
qemu-system-i386 -hda "DealOS.bin"
cd BASIC
