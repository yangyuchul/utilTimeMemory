#!/bin/bash

ListFile=$1
RunDir=$2
RunDepth="10"
if  [ ! $1 ] || [ ! $2 ] || [ ! -f $ListFile ]; then echo "Usage $0 filelist dirRun runDepth[bit]"; exit; fi
if [ $3 ]; then RunDepth=$3; fi
if [ -d $RunDir ]; then echo "$RunDir exist"; exit; fi

mkdir -p $RunDir
cp -r $ListFile $RunDir

source cmssw.set
echo "### PWD: $PWD"
echo "### CMS: ${CMSSW_BASE}/src"
echo "### InputFiles"
cat $ListFile | while read line; do
#	echo "$line"
	edmEventSize -v $line | grep File
	isOK=$?
	if [ "$isOK" != "0" ]; then echo "FileError $line"; exit; fi
done
if [ "${CMSSW_BASE}/src" != "${PWD}" ]; then echo "Diff Dir"; exit; fi

cd $RunDir
bName=`basename $ListFile`

cmsDriver="
step3 
--conditions auto:run2_mc 
--eventcontent RECOSIM,AODSIM,MINIAODSIM,DQM 
--runUnscheduled -s RAW2DIGI,L1Reco,RECO,EI,PAT,DQM:@common 
--datatier GEN-SIM-RECO,AODSIM,MINIAODSIM,DQMIO 
--customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1
-n -1
--customise Validation/Performance/TimeMemoryInfo.py 
--no_exec 
--filein filelist:${bName} 
"

echo "### Running cmsRun"
pids=""

if [ "${RunDepth:0:1}" == "1" ]; then
	cmsDriver.py ${cmsDriver} --fileout file:step3.root --python_filename step3.py
	cmsRun step3.py >& step3.log &
	pid="$!"
	pids="$pid"
	/x3/cms/ycyang/RECO/ppMCTimeMem/utilTimeMemory/PSinfo.sh $pid &
fi

if [ "${RunDepth:1:1}" == "1" ]; then
	cmsDriver.py ${cmsDriver} --fileout file:step3_igprofCPU.root --python_filename step3_igprofCPU.py
	igprof -pp -z -o igprofCPU_step3.gz -t cmsRun cmsRun step3_igprofCPU.py >& step3_igprofCPU.log &
	pids="$pids $!"
	cmsDriver.py ${cmsDriver} --fileout file:step3_igprofMEM.root --python_filename step3_igprofMEM.py
	igprof -d -mp -o igprofMEM_step3.mp -D 10evts cmsRun step3_igprofMEM.py >& step3_igprofMEM.log &
	pids="$pids $!"
fi

echo "### PID $pids"
echo "$pids" > pid
pwdx `cat pid`

cd -

