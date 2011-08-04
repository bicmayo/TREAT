#!/bin/sh
## merge sift ids

if [ $# != 1 ];
then
	echo "Usage: <sift dir>";
else
	set -x
	echo `date`
	sift=$1
	cd $sift
	cat *.ID > $sift/siftids
	echo `date`
fi
	
	
