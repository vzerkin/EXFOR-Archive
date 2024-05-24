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

lst="lst.lst"
ls1="lst.lst1"
ls2="lst.lst2"

git log --name-only --pretty="format:%s" >$lst  #all updates
echo "">>$lst
declare -a arr
nn=0; itot=0
rm -f $ls1
while IFS= read -r str0; do
    ii=$(($ii+1))
    if [ "$str0" != "" ]; then
#	echo "+$nn) [$str0]"
	arr[$nn]=$str0
	nn=$((nn+1))
    else
	if [ $nn -gt 1 ]; then
	    comm=${arr[0]}
	    nn=$((nn-1))
	    for i in $(seq 1 $nn); do
		str1=${arr[$i]}
		ext=${str1##*.}
#		echo "-$i ${itot} [${str1}] [$comm]">$ls1
		if [ "$ext" = "x4" ]; then
		    itot=$(($itot+1))
#		    echo "$itot ${str1} #$comm">>$ls1
		    printf "%07d %s #%s\n" $itot "${str1}" "$comm">>$ls1
		fi
	    done
	fi
	nn=0
    fi
#tst	if [ $ii -ge 1250 ]; then break; fi  #tst
done < $lst

cat $ls1 |awk '{ print $2 }'|sort -u >$ls2
ii=0;ia=0;nEntry=0;sym0="."
nupd=0;maxnn=0;emaxnn="";n1upd=0;max1nn=0;emax1nn=""
echo "## Entry #Hist  EXFOR-date Center:TRANS Entry:N2   Latest-HISTORY-record"
while IFS= read -r x4file; do
    ii=$(($ii+1))
    hist=`cat $ls1|grep $x4file`
    name=`basename $x4file`
    Entry=${name%.*}
    nEntry=$((nEntry+1))
    nn=`echo "$hist"|wc -l`
    hst=`echo "${hist}"|sed "s/[^#]*#//"`
    hist="${hst//$'\n'/$'\n'$'\t'$'\t'}"	#replace linefeed \n by \n\t\t
	sym1=${Entry:0:1}
	if [ "$sym1" != "$sym0" ]; then
	    if [ $ia -gt 0 ]; then echo "#---------------Area:${sym0} #Entry:$ia #Updates:$n1upd #maxHistory=$max1nn:Entry=$emax1nn"; echo "#"; fi
	    sym0=$sym1; ia=0; n1upd=0; max1nn=0; emax1nn=""
	fi
	ia=$((ia+1))
	nupd=$((nupd+nn))
	n1upd=$((n1upd+nn))
	if [ $nn -gt $maxnn ];  then maxnn=$nn;  emaxnn=$Entry;  fi
	if [ $nn -gt $max1nn ]; then max1nn=$nn; emax1nn=$Entry; fi
    echo "$ii) $Entry $nn	$hist"
#tst	if [ $ii -ge 25 ]; then break; fi  #tst
done < $ls2

if [ $ia -gt 0 ]; then echo "#---------------Area:${sym0} #Entry:$ia #Updates:$n1upd #maxHistory=$max1nn:Entry=$emax1nn"; fi
echo "#---------------Total #Entry:$nEntry #Updates:$nupd #maxHistory=$maxnn:Entry=$emaxnn"
echo "#"
echo "#Script:$0 `date +%F,%T` finished."
t11=`date +%s`; dt=$(($t11-t00))
echo "#Elapsed time: $((dt/3600)):$((dt/60%60)):$((dt%60))"

rm $lst $ls1 $ls2

#bash show_history_fast.sh >show_history_fast.tto
#grep Area show_history_fast.tto >area_updates.tto
