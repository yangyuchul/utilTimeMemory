#!/bin/bash

find . -name "*getTimeMemSummary.txt" | sort -r

echo "| CMSSW_VERSION | MaxMemory(evt) | AverageTime | MaxTime(evt) |" > /tmp/sumtemp.tmp

isFirst=1
name=""
for file in $@
do
#	echo $file
	cmsswV=`basename $file`
	cmsswV=${cmsswV/_getTimeMemSummary.txt/}
	if [ "$isFirst" == "1" ]; then name=$cmsswV; isFirst=2; fi
   memStr=`grep "RSS" $file | awk '{print "Memory:","Max", $10, "on evt", $13}'`
   timStr=`grep "^M1 Time" $file | awk '{print "Time:", "Average", $4, "Max", $7, "on evt", $11}'`
   MomeryMAX=`grep "RSS" $file | awk '{print $10}'`
   MomeryMAXEvt=`grep "RSS" $file | awk '{print $13}'`
   TimeAVG=`grep "^M1 Time" $file | awk '{print $4}'`
   TimeMAX=`grep "^M1 Time" $file | awk '{print $7}'`
   TimeMAXEvt=`grep "^M1 Time" $file | awk '{print $11}'`
   echo "| $cmsswV | $MomeryMAX($MomeryMAXEvt) | $TimeAVG | $TimeMAX($TimeMAXEvt) |" >> /tmp/sumtemp.tmp
done

column -t /tmp/sumtemp.tmp > shortSummary_${name}.txt
cat shortSummary_${name}.txt
ls shortSummary_${name}.txt


