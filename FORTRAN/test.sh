TESTNUM=5

make

rval=$?
if [ $rval -ne 0 ]; then
	exit $rval
fi

for i in `seq 1 $TESTNUM`;
do
	echo -n "compiling tests/test$i.f..."
	./fortran.native "tests/test$i"

	rval=$?
	if [ $rval -ne 0 ]; then
		exit $rval
	fi

	echo "done"
	echo -n "assembling tests/test$i.asm..."

	nasm "tests/test$i.asm" -o "tests/test$i.bin"

	if [ $? -ne 0 ]; then
		exit $?
	fi

	echo "done"
done

echo
echo "All test compiled successfully"
