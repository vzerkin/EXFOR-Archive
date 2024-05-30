#!/bin/bash
#set -x
echo "#        +--------------------------------------+"
echo "#        |  Show History of EXFOR Entries       |"
echo "#        |  v.zerkin@gmail.com, ver.2024-05-27  |"
echo "#        +--------------------------------------+"
echo "#"
echo "#Script:$0 `date +%F`,`date +%T` on `uname -n`/`uname -s`"
t00=`date +%s`

lst="lst.lst"
ls1="lst.lst1"
ls2="lst.lst2"
out="history_updates.txt"

echo "#Step-1: `date +%F,%T` get full log. Wait..."
git log --name-only --pretty="format:%s" >$lst  #all updates
echo "">>$lst
t1=`date +%s`; dt=$(($t1-t00))
echo "#Step-1: `date +%F,%T` get full log. Finished. Time:${dt}.sec"

echo "#Step-2: `date +%F,%T` process full log. Wait..."
declare -a arr
nn=0; itot=0
rm -f $ls1
t0=`date +%s`
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
#	    for i in $(seq 1 $nn); do
	    i=1; while [ $i -le $nn ]; do  #"for loop" for "GNU bash, version <= 3.1.23"
		str1=${arr[$i]}
		ext=${str1##*.}
#		echo "-$i ${itot} [${str1}] [$comm]">$ls1
		if [ "$ext" = "x4" ]; then
		    itot=$(($itot+1))
		    if [ $((itot%10000)) -eq 0 ]; then
			t1=`date +%s`; dt=$(($t1-t0))
			echo "	$itot) $str1 t:${dt}.sec"
		    fi
#		    echo "$itot ${str1} #$comm">>$ls1
		    printf "%s|%08d|%s\n" "${str1}" $itot "$comm">>$ls1
		fi
		i=$((i+1)) #end of while implementing "for loop"
	    done
	fi
	nn=0
    fi
    #if [ $ii -ge 10000 ]; then break; fi  #tst
done < $lst
t1=`date +%s`; dt=$(($t1-t0))
echo "#Step-2: `date +%F,%T` process full log. Finished. #Updates:${itot}. Time:${dt}.sec"

echo "#Step-3: `date +%F,%T` output history. Wait..."
#cat $ls1 |awk '{ print $2 }'|sort -u >$ls2
sort -u $ls1 >$ls2
echo "--------" >>$ls2

ii=0;ia=0;nEntry=0;sym0=".";prevEntry="";
nupd=0;maxnn=0;emaxnn="";n1upd=0;max1nn=0;emax1nn=""
echo "#Full history `date +%F,%T`" >$out
echo "## Entry #Hist  EXFOR-date Center:TRANS Entry:N2   Latest-HISTORY-record" >>$out
t0=`date +%s`
nn=0; declare -a arr
while IFS= read -r str0; do
    ii=$(($ii+1))

    IFS='|' read -ra array <<< "$str0"
    x4file=${array[0]}
    hist=${array[2]}
    name=${x4file##*/}
    Entry=${name%.*}

    if [ "$Entry" = "$prevEntry" ]; then
	arr[$nn]=$hist
	nn=$((nn+1))
    else
	nEntry=$((nEntry+1))
	if [ $nn -gt 0 ];  then

	    if [ $((nEntry%1000)) -eq 0 ]; then
		t1=`date +%s`; dt=$(($t1-t0))
		echo "	$nEntry) $x4file ${dt}.sec $((dt/60)):$((dt%60))"
	    fi

	    sym1=${prevEntry:0:1}
	    #echo "$ii) [$x4file] $sym1 $sym0 $ia"
	    if [ "$sym1" != "$sym0" ]; then
		if [ $ia -gt 0 ]; then
		    echo "#---------------Area:${sym0} #Entry:$ia #Updates:$n1upd #maxHistory=$max1nn:Entry=$emax1nn" >>$out
		    echo "#" >>$out
		fi
		sym0=$sym1; ia=0; n1upd=0; max1nn=0; emax1nn=""
	    fi
	    ia=$((ia+1))
	    nupd=$((nupd+nn))
	    n1upd=$((n1upd+nn))
	    if [ $nn -gt $maxnn ];  then maxnn=$nn;  emaxnn=$prevEntry;  fi
	    if [ $nn -gt $max1nn ]; then max1nn=$nn; emax1nn=$prevEntry; fi

	    str1=${arr[0]}
	    echo "$((nEntry-1))) $prevEntry $nn	$str1" >>$out
	    i=1
	    while [ $i -lt $nn ]; do  #"for loop" for "GNU bash, version <= 3.1.23"
		str1=${arr[$i]}
		echo "		$str1" >>$out
		i=$((i+1)) #end of while implementing "for loop"
	    done
	fi
	prevEntry=$Entry
	arr[0]=$hist
	nn=1
    fi

    if [ "$str0" = "--------" ]; then 
	nEntry=$((nEntry-1))
	break
    fi

#if [ $nEntry -ge 10 ]; then break; fi  #tst
done < $ls2

if [ $ia -gt 0 ]; then
    echo "#---------------Area:${sym0} #Entry:$ia #Updates:$n1upd #maxHistory=$max1nn:Entry=$emax1nn">>$out
    echo "#" >>$out
fi
echo "#---------------Total #Entry:$nEntry #Updates:$nupd #maxHistory=$maxnn:Entry=$emaxnn" >>$out
echo "#" >>$out
t1=`date +%s`; dt=$(($t1-t0))
echo "#Step-3: `date +%F,%T` output history. Finished. #Entries:$nEntry. Time:${dt}.sec"

echo "#Script:$0 `date +%F,%T` finished."
t11=`date +%s`; dt=$(($t11-t00))
echo "#Elapsed time: $((dt/3600)):$((dt/60%60)):$((dt%60))"

rm $lst $ls1 $ls2

grep Area $out |tr ' ' '\t' >area_updates.txt
