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

echo "done"
echo -n "assembling $1.asm..."

nasm $1.asm -o $1.bin

if [ $? -ne 0 ]; then
	exit $?
fi

echo "done"

cd ..
echo -n "assembling stage1.asm..."
nasm stage1.asm -o DealOS.bin

if [ $? -ne 0 ]; then
	exit $?
fi

echo "done"

echo -n "concatenating $1.bin to DealOS.bin..."
cat "BASIC/$1.bin" >> DealOS.bin
echo "done"

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

qemu-system-i386 -hda "DealOS.bin"
cd BASIC
