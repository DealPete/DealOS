if [ "$#" -eq 0 ]; then
	echo "Missing name of program to run.\n"
	exit 1
fi

./compile.sh

if [ $? -ne 0 ]; then
	exit $?
fi

echo -n "compiling $1.bas..."
./basic "$1.bas" "$1.asm"

if [ $? -ne 0 ]; then
	exit $?
fi

echo "done"
echo -n "assembling $1.asm..."
nasm "$1.asm" -o "$1.bin"

if [ $? -ne 0 ]; then
	exit $?
fi

echo "done"
#rm "$1.asm"
cd ..
./assemble.sh "BASIC/$1.bin"

if [ $? -ne 0 ]; then
	exit $?
fi

rm "BASIC/$1.bin"
qemu-system-i386 -hda "DealOS.bin"
cd BASIC
