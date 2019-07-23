#!/bin/bash

function usage {
        echo "usage $run.sh arg1 arg2"
        echo "  arg1    duration of test"
	echo "  arg2	How much memory to take"
        exit 1
}

RUN_SCRIPT_DIR="/root/scripts"

BINDIR="/root/ASCYLIB/bin"
DEFAULT_DURATION=10  # ten second

if (( $# < 1 )); then
        duration=$DEFAULT_DURATION
else
	duration=$1
fi

if (( $# < 2 )); then
	mem_size=32
else
	mem_size=$2
fi

acceptable_values=(32 64 128)
dist=10000000000
best_fit=32
for val in ${acceptable_values[*]}; do
	if (( $mem_size == $val )); then
		echo $val
		best_fit=$val
		break
	fi
	d=$(( $mem_size - $val ))
	if (( $d < 0 )); then
		d=$(( -$d ))
	fi
	if (( $d < $dist )); then
		dist=$d
		best_fit=$val
	fi
done

mem_size=$best_fit
echo "Memory allocation " $mem_size

if (( $mem_size == 32)); then
# 32 GB
$RUN_SCRIPT_DIR/run-sl.sh $duration 4194304
$RUN_SCRIPT_DIR/run-ht.sh $duration 30554432 
$RUN_SCRIPT_DIR/run-bste.sh $duration 16777216 
$RUN_SCRIPT_DIR/run-bsti.sh $duration 16777216 
fi

if (( $mem_size == 64)); then
# 64 GB
$RUN_SCRIPT_DIR/run-sl.sh $duration 8388608
$RUN_SCRIPT_DIR/lb-ht_java $duration 67108864 
$RUN_SCRIPT_DIR/run-bste.sh $duration 33554432 
$RUN_SCRIPT_DIR/run-bsti.sh $duration 33554432
fi

if (( $mem_size == 128)); then
# 128 GB
$RUN_SCRIPT_DIR/run-sl.sh $duration 16777216 
#$RUN_SCRIPT_DIR/lb-ht_java $duration TODO
$RUN_SCRIPT_DIR/run-bste.sh $duration 67108864
$RUN_SCRIPT_DIR/run-bsti.sh $duration 67108864
fi


