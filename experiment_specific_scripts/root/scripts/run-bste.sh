#!/bin/bash

BINDIR="/root/ASCYLIB/bin"

duration=$1
mem=$2

let duration=$duration*1000
let mem=$mem*16
let range=$mem*2

$BINDIR/lf-bst-aravind -d $duration  -i $mem -n 1 -r $range -u 0 -p 0
