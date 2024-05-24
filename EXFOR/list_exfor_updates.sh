#!/bin/bash
#set -x
echo "        +--------------------------------------+"
echo "        |  List: EXFOR updates (backup files)  |"
echo "        |  v.zerkin@gmail.com, ver.2024-05-12  |"
echo "        +--------------------------------------+"
#echo ""
echo "Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
echo ""
#git log --pretty="format: %s"|grep "EXFOR.entry.csv"|awk '{ print $1 }'
#git log --pretty="format: %s"|grep "EXFOR.entry.csv"
git log --pretty="format: %s"|grep "EXFOR.entry.csv"|awk '{ print $1" "$2" "$3}'
nn=`git log --pretty="format: %s"|grep "EXFOR.entry.csv"|awk '{ print $1 }'|wc -l`
maxdat=`git log --pretty="format: %s"|grep "EXFOR.entry.csv"|awk '{ print $1 }'|head -n 1`
mindat=`git log --pretty="format: %s"|grep "EXFOR.entry.csv"|awk '{ print $1 }'|tail -n 1`
echo "----------------------------------------------------"
echo "Total: ${nn} updates from [$mindat] to [$maxdat]"
