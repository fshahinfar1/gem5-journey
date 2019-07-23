#!/bin/bash

BINDIR="/root/ASCYLIB/bin"

set -x
duration=$1
mem=$2

let duration=$duration*1000
let range=$mem*32
let mem=$mem*20

echo $range
echo $mem

$BINDIR/lb-ht_java -d $duration -i $mem -n 16 -r $range -u 0 -p 0 -l 4
