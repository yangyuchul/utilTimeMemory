#!/bin/bash

SCRAM_ARCHs="
#slc6_amd64_gcc481
#slc6_amd64_gcc490
#slc6_amd64_gcc491
slc6_amd64_gcc493
slc7_amd64_gcc493
"

for ARCH in $SCRAM_ARCHs
do
	if [ "${ARCH:0:1}" == "#" ]; then continue; fi
   echo "### $ARCH ###"
   export SCRAM_ARCH=$ARCH
   export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
   source $VO_CMS_SW_DIR/cmsset_default.sh
   scram list CMSSW | grep CMSSW
   echo ""
   echo ""
   echo ""
done


