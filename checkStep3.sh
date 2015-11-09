#!/bin/bash

if [ $1 ]; then cd $1; fi
source cmssw.set

function checkRunEvent() {
numEvents=$1
addString=$2
file1=TimeMemory/step3${addString}.log
file2=TimeMemory/step3${addString}.root
file3=TimeMemory/step3${addString}_inAODSIM.root
file4=TimeMemory/step3${addString}_inMINIAODSIM.root

if [ $file1 ] && [ $file2 ] && [ $file3 ] && [ $file4 ]; then
	echo "### Check run Events $addString $PWD/TimeMemory"
	nEvt1=`grep "^Begin processing" $file1 | wc -l`
	nEvt2=`edmEventSize -v $file2 | grep File | awk '{print $4}'`
	nEvt3=`edmEventSize -v $file3 | grep File | awk '{print $4}'`
	nEvt4=`edmEventSize -v $file4 | grep File | awk '{print $4}'`
	echo "$numEvents $nEvt1 $nEvt2 $nEvt3 $nEvt4 | `expr $numEvents - $nEvt1` `expr $numEvents - $nEvt2` `expr $numEvents - $nEvt3` `expr $numEvents - $nEvt4`  "
	echo ""
else
	ls -al $file1 $file2 $file3 $file4 
fi

}

checkRunEvent 1000 
checkRunEvent 1000 _igprofCPU
checkRunEvent 1000 _igprofMEM

