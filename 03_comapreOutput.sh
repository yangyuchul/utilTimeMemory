#!/bin/bash

rootA=$1
rootB=$2
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "Usage $0 old.root new.root"; exit; fi
if [ ! $2 ]; then echo "Usage $0 old.root new.root"; exit; fi
if [ ! -f $rootA ] || [ ! -f $rootB ]; then echo "Usage $0 old.root new.root"; exit; fi
~/tools/compareProducts.sh $rootA $rootB _RECO 100 20

