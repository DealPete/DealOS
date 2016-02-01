if [ "$#" -eq 0 ]; then
	echo "Missing name of program to run."
	exit 1
fi

./compile.sh
if [ $? -eq 0 ]; then
	echo -n "assembling $1.asm..."
	nasm "$1.asm" -o "$1.bin"
	if [ $? -eq 0 ]; then
		echo "done"
		rm "$1.asm"
		cd ..
		./assemble.sh "basic/$1.bin"
		if [ $? -eq 0 ]; then
			qemu-system-i386 -hda "DealOS.bin"
			cd basic
		fi
	fi
fi
