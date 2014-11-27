#!/bin/bash

if [ ! -d "$1" ] || [ ! -d "$2" ] || [ ! -e "$3" ]; then
   echo "usage: mm2any.sh <Source Dir> <Target Dir> <Inst File>"
   exit 1
fi

Source=$1
Target=$2
Files=$(cat $3)

for i in ${Files}
do
    echo "Transforming $i ..."
   ./mm2any.awk -v output=dzn $Source/$i > $Target/${i%.*}.dzn
done

