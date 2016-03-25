if [ "$#" -eq 0 ]; then
	echo "Missing name of program to run.\n"
	exit 1
fi

make

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

echo -n "compiling $1.f..."
./fortran.native "$1"

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
cat "FORTRAN/$1.bin" >> DealOS.bin
echo "done"

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

qemu-system-i386 -hda "DealOS.bin"
cd FORTRAN 
