if [ "$#" -eq 0 ]; then
	echo "Missing name of program to run.\n"
	exit 1
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
./assemble.sh "basic/$1.bin"

if [ $? -ne 0 ]; then
	exit $?
fi

rm "basic/$1.bin"
qemu-system-i386 -hda "DealOS.bin"
cd basic
