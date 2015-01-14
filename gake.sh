#!/bin/ksh
# because `make` is like a fun, but high-maintenance SO.
# cmake and autoconf are just tragedies.


_CC="cc"
_STD="c99"
_FLAGS="-Wall -pedantic --std=$_STD"


MkObj ( ) {
	# Make object files
	# params:
	#   - output file name
	#   - source file names (1..)
	#

	out_fname=$1
	shift

	if [[ -e $out_fname ]]
	then
		rm $out_fname
	fi

	$_CC $_FLAGS -c -o $out_fname $@
}


MkProg ( ) {
	# Make program
	# params:
	#   - program file name
	#   - source file names (1..)
	#

	prog_fname=`basename $1`
	build_dname=`dirname $1`
	shift

	if [[ ! -d $build_dname ]]
	then
		mkdir $build_dname
	fi
	

	# Go through the source files, build those to
	# object files and then build the final program
	# out of those object files.
	#
	files=""
	pids=""
	for src_path
	do
		name=`basename $src_path .c`
		obj_path=$build_dname/$name".o"

		if [[ $src_path -nt $obj_path || ! -e $obj_path ]]
		then
			MkObj $obj_path $src_path &
		fi

		pids=$pids" $!"
		files=$files" $obj_path"
	done

	# wait for everything to finish
	for pid in $pids
	do
		wait $pid
	done

	$_CC $_FLAGS -o $build_dname/$prog_fname $files
	rm $build_dname/*.o

}


# Fetch possible options and run MkProg accordingly
#
while getopts :I: opt
do
	case $opt in
		I) _FLAGS=$_FLAGS" -I$OPTARG"
			;;
	esac
done
shift $((OPTIND-1))

MkProg $@

