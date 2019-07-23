#!/bin/bash

BINDIR="/root/ASCYLIB/bin"
duration=$1
mem=$2

let duration=$duration*1000
let mem=$mem*20
let range=$mem*2

echo $duration
$BINDIR/lf-sl_fraser  -d $duration -i $mem -n 16 -r $range -u 0 -p 0 -l 2
