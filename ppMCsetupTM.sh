#!/bin/bash

# echo "usage: $0 CMSSW_7_6_0_pre3 slc6_amd64_gcc493"

ver=$1
scram=$2

cmsswVersion=$ver
export SCRAM_ARCH=${scram}
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
source $VO_CMS_SW_DIR/cmsset_default.sh
scram p -n ${cmsswVersion} CMSSW ${cmsswVersion}
result0="$?"
if [ "${result0}" != "0" ]; then echo "### Error Step0"; exit; fi

cd ${cmsswVersion}/src
eval `scramv1 runtime -sh`

echo "### WorkingDir $PWD"
echo "### CMSSW_BASE $CMSSW_BASE"

cat << EOF > cmssw.set
export SCRAM_ARCH=${scram}
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
source \${VO_CMS_SW_DIR}/cmsset_default.sh
eval \`scramv1 runtime -sh\`
EOF

das_client.py --limit 0 --query "dataset dataset=/RelValTTbar*/${ver}*PU25ns*/*BUG" >& dataset.txt
echo "### dataset "
cat dataset.txt

numDataset=`cat dataset.txt | wc -l`
if [ ${numDataset} == "1" ]; then
	echo "OK Found 1 dataset `cat dataset.txt`"
fi





