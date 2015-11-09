#!/bin/bash

#usage 3_compareDiffTime.sh OldDir NewDir

v1=$1
v2=$2

file1="${v1}/src/TimeMemory/step3.log"
file2="${v2}/src/TimeMemory/step3.log"

echo "file1 $file1"
echo "file2 $file2"

v1=`basename $v1`
v2=`basename $v2`

result="timeDiff_step3_${v2}_${v1}.txt"
tempFile="temp_timeDiff_step3_${v2}_${v1}.txt"

echo "### Short Comparison (top 10 lines) excluding the first events: $v1 vs $v2" > $result
~/tools/timeDiffFromReport.sh $file1 $file2 > ${tempFile}
excludingFirstLine=`grep -n "The same excluding the first event" ${tempFile} | cut -f1 -d:`
head -n `expr $excludingFirstLine + 12` $tempFile | tail -n 13 >> $result
echo "" >> $result

echo "### Full Comparison $v1 vs $v2 " >> $result
cat $tempFile >> $result
echo "" >> $result
rm -rf $tempFile
head -n 10 $result
mv $result  /x3/cms/ycyang/RECO/ppMCTimeMem/reco/
ls -1 /x3/cms/ycyang/RECO/ppMCTimeMem/reco/$result
echo ""

