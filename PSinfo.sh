#!/bin/bash

pid=$1
rm -rf .${pid}.psinfo.temp
while true; do
	if [ -f $2 ]; then grep "^Begin" step3.log | tail -n 1 >> .${pid}.psinfo.temp; fi
	echo -n "`date` " >> .${pid}.psinfo.temp 
	ps -p $pid -o pid,rss,size,vsize,time,cmd | tail -n 1 >>  .${pid}.psinfo.temp 
	pmap $pid >> .${pid}.psinfo.temp
	ls -al >> .${pid}.psinfo.temp
	echo "" >> .${pid}.psinfo.temp
	sleep 10 
	if [ "`ps $pid | wc -l`" == "1" ]; then break; fi
done
mv .${pid}.psinfo.temp ${pid}.psinfo



