#!/bin/bash

ToDir="/disk3/ycyang/"
if [ "${HOSTNAME}" == "ccp1u" ]; then ToDir="/x4/cms/ycyang/"; fi
if [ "${HOSTNAME}" == "ccp" ]; then ToDir="/x4/cms/ycyang/"; fi
if [ "${HOSTNAME:0:4}" == "node" ]; then ToDir="/x4/cms/ycyang/"; fi
if [ "${HOSTNAME:0:4}" == "ui02" ]; then ToDir="/hcp/data/data02/ycyang/"; fi

function dirString() {
   dataStr=${1//\//_D_}
   echo ${dataStr/_D_/}
}

function fileDown() {
	GlobalURL="root://cms-xrd-global.cern.ch/"
	KnuURL="root://cluster142.knu.ac.kr/"
	KistiURL="root://cms-xrdr.sdfarm.kr/xrd/"
	
	URL=${GlobalURL}
	data=$1
	if [ "$2" != "" ]; then ToDir=$2; fi
	
	bDir=`dirname $data`
	if [ ! -d ${ToDir}/${bDir} ]; then mkdir -p ${ToDir}/${bDir} ; fi
	if [ ! -f ${ToDir}${data} ]; then
	   echo "# xrdcp ${URL}/${data} ${ToDir}${data}"
	   xrdcp ${URL}/${data} ${ToDir}${data}
	fi
}

if [ ! $1 ]; then echo "usage: $0 dataset nEvents"; exit; fi

dataset=$1
nDown=-1
skips=""
if [ $2 ]; then nDown=$2; fi
iarg=0
for arg in $@
do
	((iarg++))
	if [ ${iarg} -ge 3 ]; then 
		skips="$skips $arg"; 
		skipStr="${skipStr}_${arg}"
	fi
done

echo "### Downloading $nDown events in $dataset"
name=`dirString $dataset`
das_client.py --limit 0 --query "file dataset=${dataset} | grep file.name, file.nevents" | grep root > .${name}.nevent
tevt=0
listFile=${name}_nEvt${nDown}${skipStr}.localfile
rm -rf $listFile
ifile=0
cat .${name}.nevent | while read thisLine; do
	((ifile++))
	isSkip=0
	for nSkip in $skips; do if [ "$nSkip" == "$ifile" ]; then isSkip=1; fi; done
	if [ "$isSkip" == "1" ]; then echo "### Skip $thisLine"; continue; fi
	file=`echo $thisLine | awk '{print $1}'`
	nevt=`echo $thisLine | awk '{print $2}'`
	tevt=`expr $tevt + $nevt`
	fileDown $file $ToDir
	echo "file:${ToDir}/${file}" >> $listFile
	echo "$file $nevt $tevt"
	if [ $tevt -ge $nDown ] && [ $nDown -ne -1 ]; then break; fi
done



