#!/bin/bash
#set -x
echo "#        +--------------------------------------+"
echo "#        |  Show History of EXFOR Entries       |"
echo "#        |  v.zerkin@gmail.com, ver.2024-05-23  |"
echo "#        +--------------------------------------+"
echo "#"
echo "#Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
echo "#"
t00=`date +%s`

filenames="*/*/*.x4"
#filenames="2/*/*.x4 O/*/*.x4"
#filenames="J/*/*.x4 K/*/*.x4 R/*/*.x4"

ii=0;ia=0;nEntry=0;sym0="."
nupd=0;maxnn=0;emaxnn="";n1upd=0;max1nn=0;emax1nn=""
echo "## Entry #Hist  EXFOR-date Center:TRANS Entry:N2   Latest-HISTORY-record"
for x4file in $filenames; do
    if [ -f $x4file ]; then
	ii=$((ii+1))
	nEntry=$((nEntry+1))
	name=`basename $x4file`
	Entry=${name%.*}
	sym1=${Entry:0:1}
	if [ "$sym1" != "$sym0" ]; then
	    if [ $ia -gt 0 ]; then echo "#---------------Area:${sym0} #Entry:$ia #Updates:$n1upd #maxHistory=$max1nn:Entry=$emax1nn"; echo "#"; fi
	    sym0=$sym1; ia=0; n1upd=0; max1nn=0; emax1nn=""
	fi
	ia=$((ia+1))
#	hist=`git log --pretty="format:%h %as %s" -- "${x4file}"`
	hist=`git log --pretty="format:%s" -- "${x4file}"`
	nn=`echo "$hist"|wc -l`
	nupd=$((nupd+nn))
	n1upd=$((n1upd+nn))
#	hist="${hist//$'\n'/$'\n'$'\t'}"	#replace linefeed \n by \n\t
#	echo "$ii) $Entry [$nn] $hist"
	hist="${hist//$'\n'/$'\n'$'\t'$'\t'}"	#replace linefeed \n by \n\t\t
	echo "$ii) $Entry $nn	$hist"
	if [ $nn -gt $maxnn ]; then maxnn=$nn; emaxnn=$Entry; fi
	if [ $nn -gt $max1nn ]; then max1nn=$nn; emax1nn=$Entry; fi

#tst	if [ $ii -ge 25 ]; then break; fi  #tst
    fi
done
if [ $ia -gt 0 ]; then echo "#---------------Area:${sym0} #Entry:$ia #Updates:$n1upd #maxHistory=$max1nn:Entry=$emax1nn"; fi

echo "#---------------Total #Entry:$nEntry #Updates:$nupd #maxHistory=$maxnn:Entry=$emaxnn"
echo "#"
echo "#Script:$0 `date +%F,%T` finished."
t11=`date +%s`; dt=$(($t11-t00))
echo "#Elapsed time: $((dt/3600)):$((dt/60%60)):$((dt%60))"
