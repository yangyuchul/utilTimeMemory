#!/bin/bash

ListFile=$1
RunDir=$2
if  [ ! $1 ] || [ ! $2 ] || [ ! -f $ListFile ]; then echo "Usage $0 filelist dirRun "; exit; fi

if [ -d $RunDir ]; then
	echo "$RunDir exist"
	exit
fi

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
if [ "${CMSSW_BASE}/src" != "${PWD}" ]; then echo "Diff Dir" exit; fi

cd $RunDir
bName=`basename $ListFile`

#--customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 # out of date --> --era Run2_25ns from CMSSW_7_6_0_pre7 
cmsDriver="
step3 
--conditions auto:run2_mc 
--eventcontent RECOSIM,AODSIM,MINIAODSIM,DQM 
--runUnscheduled -s RAW2DIGI,L1Reco,RECO,EI,PAT,DQM:@common 
--datatier GEN-SIM-RECO,AODSIM,MINIAODSIM,DQMIO 
--era Run2_25ns
-n 1000 
--customise Validation/Performance/TimeMemoryInfo.py 
--no_exec 
--filein filelist:${bName} 
"

cmsDriver.py ${cmsDriver} --fileout file:step3.root           --python_filename step3.py
cmsDriver.py ${cmsDriver} --fileout file:step3_igprofCPU.root --python_filename step3_igprofCPU.py
cmsDriver.py ${cmsDriver} --fileout file:step3_igprofMEM.root --python_filename step3_igprofMEM.py


echo "### Running cmsRun"
pids=""

cmsRun step3.py >& step3.log &
pids="$!"

igprof -pp -z -o igprofCPU_step3.gz -t cmsRun cmsRun step3_igprofCPU.py >& step3_igprofCPU.log &
pids="$pids $!"

igprof -d -mp -o igprofMEM_step3.mp -D 10evts cmsRun step3_igprofMEM.py >& step3_igprofMEM.log &
pids="$pids $!"

echo "### PID $pids"
echo "$pids" > pid
pwdx `cat pid`

cd -

