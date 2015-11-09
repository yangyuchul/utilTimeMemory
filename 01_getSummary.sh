#!/bin/bash

if [ ! $1 ] || [ ! -d $1 ]; then
	echo "Not Found CMSSW_BASE dir, Usage $0 dirCMSSW_BASE"
	exit
fi

bDir="${1}/src/TimeMemory"
bName=`basename $1`

echo "### $bName $bDir"
pyFile=$bDir/step3.py
logA=$bDir/step3.log
fileCPU=${bDir}/igprofCPU_step3.gz
fileMEM=${bDir}/igprofMEM_step3.mp

ls -al $logA $fileCPU $fileMEM

data=`grep "file:" $pyFile | grep root | grep store | head -n 1 | cut -d"'" -f2 | cut -d ":" -f2 | sed 's/\/x4\/cms\/ycyang\/\///'`
dataset=`das_client.py --limit 0 --query "dataset file=${data}"`

echo "# Running ~/tools/getTimeMemSummary.sh $logA > ${bName}_getTimeMemSummary.txt"
~/tools/getTimeMemSummary.sh $logA > ${bName}_getTimeMemSummary.txt

echo "# Running igprof-analyse --demangle --gdb $fileCPU >& ${bName}_igprofCPU.txt"
igprof-analyse --demangle --gdb $fileCPU >& ${bName}_igprofCPU.txt

echo "# Running igprof-analyse --sqlite -v --demangle --gdb $fileCPU |  sqlite3 ${bName}_igprofCPU.sql3"
igprof-analyse --sqlite -v --demangle --gdb $fileCPU |  sqlite3 ${bName}_igprofCPU.sql3

echo "# Running igprof-analyse --sqlite -v --demangle --gdb -r MEM_LIVE $fileMEM | sqlite3 ${bName}_igprofMEM.sql3"
igprof-analyse --sqlite -v --demangle --gdb -r MEM_LIVE $fileMEM | sqlite3 ${bName}_igprofMEM.sql3

echo "http://155.230.186.130/cgi-bin/igprof-navigator/${bName}_igprofCPU"
echo "http://155.230.186.130/cgi-bin/igprof-navigator/${bName}_igprofMEM"

mv ${bName}_getTimeMemSummary.txt ${bName}_igprofCPU.txt /x3/cms/ycyang/RECO/ppMCTimeMem/reco/
mv ${bName}_igprofCPU.sql3 ${bName}_igprofMEM.sql3  /x3/cms/ycyang/RECO/ppMCTimeMem/reco/data/

cat << EOF 

<!-- Start $bName -->
   <li> ${bName} (Dataset: $dataset)
   <ul style="line-height: 150%" >
      <li> Step3(RECO+PAT) : 
         [<a href="reco/${bName}_getTimeMemSummary.txt">getTimeMemSummary (25202.0)</a>] &nbsp;
         [<a href="cgi-bin/igprof-navigator/${bName}_igprofCPU">CPU Profiler igprof(25202.0)</a>] &nbsp;
         [<a href="cgi-bin/igprof-navigator/${bName}_igprofMEM">Memory Profiler igprof(25202.0)</a>] &nbsp;
         <ul style="line-height: 120%">
            <li> <small>Comparison w/ :
               [<a href="reco/">TimeDiff</a>] &nbsp;
               [<a href="reco/">Igprof CPU</a>] &nbsp;
               </small>
            <li> <small> delta(igprofCPU) report [ (New-Old)/OldTotal > 0.5% ] :
               </small>
         </ul>
   </ul>
<!-- End $bName -->

EOF

